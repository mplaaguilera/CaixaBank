public with sharing class SPV_AsignarTMEs {


    /***********************************************************************************************
     * Proposito: Al cambiar de estado la reclamación, comprobar si se debe añadir algún TMO
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US1260225      Álex Polo       03/06/2025     Creación
     ***********************************************************************************************/
    public static void insertarTMOconTPE(List<Case> listNewReclamaciones, Map<Id, Case> mapOldObj) {

        Id tipoRegistro = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SPV_TMO').getRecordTypeId();
        Id tipoRegistroTMECaso = Schema.SObjectType.SAC_TMECaso__c.getRecordTypeInfosByDeveloperName().get('SPV_TMECaso').getRecordTypeId();

        List<SAC_ParametrizacionSLATME__c> listaParametrizacionesCasoAniadir = new List<SAC_ParametrizacionSLATME__c>();
        List<SAC_ParametrizacionSLATME__c> listaTMEs = [SELECT Id, Name, SAC_Estados__c FROM SAC_ParametrizacionSLATME__c WHERE RecordTypeId = :tipoRegistro];      //Se obtienen las parametrizaciones de TME de SPV
        List<SAC_TMECaso__c> listaTMEsAniadir = new List<SAC_TMECaso__c>();
        Map<Id, Case> mapaCasos = new Map<Id, Case>();

        
        for(Case recla : listNewReclamaciones){
            if(mapOldObj == null || (mapOldObj.containsKey(recla.Id) && recla.Status != mapOldObj.get(recla.Id).Status)){
                //if(recla.Status == 'SPV_Envio'){
                    if(!mapaCasos.containsKey(recla.Id)){
                        mapaCasos.put(recla.Id, recla);
                    }
                    listaParametrizacionesCasoAniadir.clear();
                    //List<SAC_ParametrizacionSLATME__c> listaTMEsEnvio = new List<SAC_ParametrizacionSLATME__c>();
                    //Se recorren los TMES para buscar cuál coindice con el estado en el cual se encuentra la reclamación para añadirselo como TMECaso
                    for(SAC_ParametrizacionSLATME__c tme : listaTMEs){
                        List<String> estadosDelTME = tme.SAC_Estados__c.split(';');     //Es un multipicklist, sus valores se separan por ;
                        if(!estadosDelTME.isEmpty()){
                            for(String estado : estadosDelTME){
                                if(estado == recla.Status){
                                    listaParametrizacionesCasoAniadir.add(tme);
                                }
                            }
                        }
                    }

                    //Una vez se han recorrido todos las Parametrizaciones TMEs posibles para la reclamación, se añaden como TMECaso a la reclamación
                    for(SAC_ParametrizacionSLATME__c parametrizacion : listaParametrizacionesCasoAniadir){
                        SAC_TMECaso__c tme = new SAC_TMECaso__c();
                        tme.SAC_Caso__c = recla.Id;
                        tme.RecordTypeId = tipoRegistroTMECaso;
                        tme.Name = parametrizacion.Name;
                        listaTMEsAniadir.add(tme);
                        //SPV_DatabaseDML.insertDML(tme, false);
                    }

                //}

            }
        }  


        //Una vez obtenidos todos los TMEs a añadir para las reclamaciones, se insertan y se añaden sus correspondientes TPEs
        /*if(!listaTMEsAniadir.isEmpty()){
            //ANTES DE INSERTAR, COMPROBAR SI HAY DUPLICADOS, si lo hay, en vez de crear ese tmecaso, se crea un nuevo tpe asociado a ese tmecaso que ya existe
            SPV_DatabaseDML.insertListDML(listaTMEsAniadir, true);
            insertarTPEs(listaTMEsAniadir, mapaCasos); 
        }*/
        //Una vez obtenidos todos los TMEs a añadir para las reclamaciones, se insertan y se añaden sus correspondientes TPEs
        if(!listaTMEsAniadir.isEmpty()){
            //Comprobar si hay TMECaso duplicados, para los que lo estén, se creará un nuevo TPE relacionado a este en lugar de crear otro TMECaso
            Map<String, List<SAC_TMECaso__c>> mapaTMEDuplicados = controlarTMEsDuplicados(listaTMEsAniadir, mapaCasos);
            if(!mapaTMEDuplicados.get('TME Añadir').isEmpty()){
                SPV_DatabaseDML.insertListDML(mapaTMEDuplicados.get('TME Añadir'), true);
            }
            if(!mapaTMEDuplicados.get('TME Nuevos TPE').isEmpty()){
                insertarTPEs(mapaTMEDuplicados.get('TME Nuevos TPE'), mapaCasos); 
            }
        }
    }


    /***********************************************************************************************
     * Proposito: Insertar los TPE para los nuevos TME o insertar nuevo TPE para los TME ya añadidos pero
     * cerrados en caso de haber vuelto a un estado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US1260225      Álex Polo       03/06/2025     Creación
     ***********************************************************************************************/
    public static void insertarTPEs(List<SAC_TMECaso__c> listaTMEsAniadir, Map<Id, Case> mapaCasos){

        List<SAC_TiempoEstados__c> listaTPEsAniadir = new List<SAC_TiempoEstados__c>();
        for(SAC_TMECaso__c tme : listaTMEsAniadir){
            SAC_TiempoEstados__c tpe = new SAC_TiempoEstados__c();
            tpe.SAC_Estado__c = mapaCasos.get(tme.SAC_Caso__c).Status;
            tpe.SAC_Inicio__c = CBK_UtilsDate.nowSYS();
            tpe.SAC_TMECaso__c = tme.Id;
            listaTPEsAniadir.add(tpe);
        }
        SPV_DatabaseDML.insertListDML(listaTPEsAniadir, true);

    }

    /***********************************************************************************************
     * Proposito: Comprobar si un TME a añadir es duplicado o no
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US1260225      Álex Polo       03/06/2025     Creación
     ***********************************************************************************************/
    public static Map<String, List<SAC_TMECaso__c>> controlarTMEsDuplicados(List<SAC_TMECaso__c> listaTMEsAniadir, Map<Id, Case> mapaCasos){
        Set<Id> listaIdsCasos = new Set<Id>();
        Map<Id, List<SAC_TMECaso__c>> mapaCasoTMEsAsociados = new Map<Id, List<SAC_TMECaso__c>>();
        List<SAC_TMECaso__c> listaTMENuevos = new List<SAC_TMECaso__c>();
        List<SAC_TMECaso__c> listaTmeAniadirTPE = new List<SAC_TMECaso__c>();

        for(SAC_TMECaso__c tme : listaTMEsAniadir){
            listaIdsCasos.add(tme.SAC_Caso__c);
        }

        //Obtener los TMECaso que tienen las reclamaciones asociados
        List<SAC_TMECaso__c> listaTMEs = [SELECT Id, Name, RecordTypeId, SAC_Caso__c FROM SAC_TMECaso__c WHERE SAC_Caso__c IN :listaIdsCasos];
        //Crear mapa relacionando Reclamación - TMEs asociados
        for(SAC_TMECaso__c tmeYaAsociado : listaTMEs){
            if(mapaCasoTMEsAsociados.containsKey(tmeYaAsociado.SAC_Caso__c)){
                mapaCasoTMEsAsociados.get(tmeYaAsociado.SAC_Caso__c).add(tmeYaAsociado);
            }else{
                List<SAC_TMECaso__c> listTME = new List<SAC_TMECaso__c>();
                listTME.add(tmeYaAsociado);
                mapaCasoTMEsAsociados.put(tmeYaAsociado.SAC_Caso__c, listTME);
            }
        }

        //Para cada TME que se va a intentar añadir, comprobar si está duplicado
        for(SAC_TMECaso__c tmePorAniadir : listaTMEsAniadir){
            List<SAC_TMECaso__c> listaTmeAsociados = new List<SAC_TMECaso__c>();
            listaTmeAsociados = mapaCasoTMEsAsociados.get(tmePorAniadir.SAC_Caso__c);
            if(listaTmeAsociados != null){
                if(!listaTmeAsociados.isEmpty()){
                    Boolean tmeDuplicado = false;
                    for(SAC_TMECaso__c tmeAsociado : listaTmeAsociados){
                        //Para cada TME nuevo, se comprueba si su reclamación ya tiene ese TME asociado (no se quiere añadir el mismo dos veces)    
                        if(tmeAsociado.Name == tmePorAniadir.Name){
                            tmeDuplicado = true;
                            //Si está duplicado, no se añade a la lista de los TMECaso por añadir, pero sí a la de los TME a añadirles un TPE nuevo
                            listaTmeAniadirTPE.add(tmeAsociado);
                        }
                    }

                    //Una vez recorridos todos los asociados, si el nuevo a añadir no se ha encontrado duplicado, se añade este TME y además se le crea un TPE nuevo
                    if(tmeDuplicado == false){
                        listaTMENuevos.add(tmePorAniadir);
                        listaTmeAniadirTPE.add(tmePorAniadir);
                    }
                }else{  //Si la reclamación no tiene ningún TME asociado, entonces este no estará duplicado, se tiene que añadir junto con su TME
                    listaTMENuevos.add(tmePorAniadir);
                    listaTmeAniadirTPE.add(tmePorAniadir);
                }
            }else{      //Si la reclamación no tiene ningún TME asociado, entonces este no estará duplicado, se tiene que añadir junto con su TME
                listaTMENuevos.add(tmePorAniadir);
                listaTmeAniadirTPE.add(tmePorAniadir);
            }
        }

        //Se devolverá el siguiente mapa para poder acceder a las dos listas por separado
        Map<String, List<SAC_TMECaso__c>> mapaReturn = new Map<String, List<SAC_TMECaso__c>>();
        mapaReturn.put('TME Añadir', listaTMENuevos);
        mapaReturn.put('TME Nuevos TPE', listaTmeAniadirTPE);
        return mapaReturn;

    }


    /***********************************************************************************************
     * Proposito: Finalizar el TMO correspondiente al pasar de estado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0             US1260225      Álex Polo       03/06/2025     Creación
     ***********************************************************************************************/
    public static void finalizarTMO(List<Case> listNewReclamaciones, Map<Id, Case> mapOldObj){
        Id tipoRegistro = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SPV_TMO').getRecordTypeId();
        Id tipoRegistroTMECaso = Schema.SObjectType.SAC_TMECaso__c.getRecordTypeInfosByDeveloperName().get('SPV_TMECaso').getRecordTypeId();
        List<Case> listaReclaCambiaEstado = new List<Case>();
        Map<Id, List<SAC_TiempoEstados__c>> mapaCasoTpes = new Map<Id, List<SAC_TiempoEstados__c>>();
        List<SAC_TiempoEstados__c> listaTPEsActualizar = new List<SAC_TiempoEstados__c>();

        //Obtener las relcamaciones que cambiand e estado
        for(Case recla : listNewReclamaciones){
            if(mapOldObj.containsKey(recla.Id) && recla.Status != mapOldObj.get(recla.Id).Status){
                listaReclaCambiaEstado.add(recla);
            }
        }

        if(!listaReclaCambiaEstado.isEmpty()){
            //Obtener los tmeCaso que tienen asociados las reclamaciones
            List<SAC_TMECaso__c> listaTMOsCaso = [SELECT Id, SAC_Caso__c FROM SAC_TMECaso__c WHERE RecordTypeId =: tipoRegistroTMECaso AND SAC_Caso__c IN: listaReclaCambiaEstado];
            
            //Para cada tme, se obtienen los tpe que no hayan sido finalizados (esto es el último tpe creado de cada tme asociado a la reclamación)
            if(!listaTMOsCaso.isEmpty()){
                List<SAC_TiempoEstados__c> listaTPEsCaso = [SELECT Id, SAC_TMECaso__r.SAC_Caso__c, SAC_Estado__c FROM SAC_TiempoEstados__c  WHERE SAC_TMECaso__c =: listaTMOsCaso AND SAC_Fin__c = null ORDER BY CreatedDate desc ];
                //Se contruye un mapa que relacione cada caso con sus tpes -> Reclamación - Lista Tpes asociados sin finalizar
                for(SAC_TiempoEstados__c tpe : listaTPEsCaso){
                    if(mapaCasoTpes.containsKey(tpe.SAC_TMECaso__r.SAC_Caso__c)){
                        mapaCasoTpes.get(tpe.SAC_TMECaso__r.SAC_Caso__c).add(tpe);
                    }else{
                        List<SAC_TiempoEstados__c> listTPE = new List<SAC_TiempoEstados__c>();
                        listTPE.add(tpe);
                        mapaCasoTpes.put(tpe.SAC_TMECaso__r.SAC_Caso__c, listTPE);
                    }
                }
            }

            for(Case recla : listaReclaCambiaEstado){
                List<SAC_TiempoEstados__c> tpeDeCaso = new List<SAC_TiempoEstados__c>();
                if(mapaCasoTpes.containsKey(recla.Id)){
                    tpeDeCaso = mapaCasoTpes.get(recla.Id);     //Se cogen los TPE que el caso ya tiene asociados, para ver cuál se tiene que finalizar
                
                    //Si el nuevo Status no es envío, se completan los tpe que sean de envío
                    /*if(recla.Status != 'SPV_Envio' && mapOldObj.get(recla.Id).Status == 'SPV_Envio'){
                        for(SAC_TiempoEstados__c tpe : tpeDeCaso){
                            if(tpe.SAC_Estado__c == 'SPV_Envio'){
                                //tpe.SAC_Fin__c = Datetime.newInstance(2025,6,4, 17,01,05);
                                tpe.SAC_Fin__c = CBK_UtilsDate.nowSYS();
                                listaTPEsActualizar.add(tpe);
                            }
                        }
                    }*/
                    //Añadir aquí debajo condiciones para cerrar el resto de tmos

                    //Al cambiar de estado, se deben cerrar los TPE que pertenecen al estado del cual se está saliendo
                    if(recla.Status != mapOldObj.get(recla.Id).Status){
                        for(SAC_TiempoEstados__c tpe : tpeDeCaso){
                            if(tpe.SAC_Estado__c == mapOldObj.get(recla.Id).Status){    //Se cierran los tpe que pertenezcan al estado del que se está saliendo
                                //tpe.SAC_Fin__c = Datetime.newInstance(2025,6,4, 17,01,05);
                                tpe.SAC_Fin__c = CBK_UtilsDate.nowSYS();
                                listaTPEsActualizar.add(tpe);
                            }
                        }
                    }
                }
            }

            //Se actualizan aquellos TPEs a los que se les ha añadido fecha fin
            if(!listaTPEsActualizar.isEmpty()){
                SPV_DatabaseDML.updateListDML(listaTPEsActualizar, true);
            }
        }
    }

}