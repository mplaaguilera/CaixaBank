public without sharing class SAC_AsignarTMEs {
/*****************************************************************
 * Name: SAC_AsignarTMEs
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Updatear TMEs de las reclamaciones
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US227582         Luis Mesa      03/06/21     Creación
*****************************************************************/

    private static final Id RTSAC_PARAMETRIZACIONTME = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_TME').getRecordTypeId();
    private static final Id RTTMECASO = Schema.SObjectType.SAC_TMECaso__c.getRecordTypeInfosByDeveloperName().get('SAC_TMECaso').getRecordTypeId();

    public static void modificarTiemposPretension(List<Case> listNewCase, Map<Id, Case> mapOldCase, List<Case> listOldCase){

    /*****************************************************************
     * Proposito: Método para comprobar que pretensiones han cambiado de estado
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US227582         Luis Mesa      03/06/21     Creación
    *****************************************************************/
    //update
        List<Case> reclamacionesNew = new List<Case>(); //Modificar el estado de la reclamacion
        List<Case> reclamacionesOld = new List<Case>(); //Modificar el TME asociado, en caso de que exista y su TPE
        
        for (Case caso : listNewCase) {
            if (mapOldCase.containsKey(caso.Id)) {
                if(/*String.isNotBlank( mapOldCase.get(caso.Id).SEG_Detalle__c ) &&*/
                    (caso.Status != mapOldCase.get(caso.Id).Status || caso.SEG_Grupo__c != mapOldCase.get(caso.Id).SEG_Grupo__c /*|| caso.SEG_Detalle__c != mapOldCase.get(caso.Id).SEG_Detalle__c*/)){
                        reclamacionesNew.add(caso);
                        reclamacionesOld.add(mapOldCase.get(caso.Id));
                }
            }
        }

        if(!reclamacionesNew.isEmpty()){
            //si no hay parametrizacion que pasa?
            closeTPE(reclamacionesOld);
            changeSLA(reclamacionesNew);
        }
    }

    public static void changeSLA(List<Case> reclamacionesNew){
 
        /*****************************************************************
         * Proposito: Método para asignar los tiempos de los SLAs a los casos
         *              dependiendo del estado en el que se encuentre la reclamacion 
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US227582         Luis Mesa      03/06/21     Creación
        *****************************************************************/

        Id tipoRegistro = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SAC_TME').getRecordTypeId();
        Id tipoRegistroTMECaso = Schema.SObjectType.SAC_TMECaso__c.getRecordTypeInfosByDeveloperName().get('SAC_TMECaso').getRecordTypeId();
        Id tipoRegistroTMEGlobal = Schema.SObjectType.SAC_TMECaso__c.getRecordTypeInfosByDeveloperName().get('SAC_TMEGlobal').getRecordTypeId();
        Id tipoRegistroTMEPreAlta = Schema.SObjectType.SAC_TMECaso__c.getRecordTypeInfosByDeveloperName().get('SAC_PreAlta').getRecordTypeId();


        Map<Id, Case> mapaReclamacionesNew = new Map<Id, Case>(reclamacionesNew);
        List<SAC_TMECaso__c> tmes = [SELECT Id, SAC_Caso__c, SAC_Parametrizacion__c, SAC_Parametrizacion__r.SAC_Estados__c, SAC_Caso__r.Status, Name, RecordTypeId
                                    FROM SAC_TMECaso__c 
                                    WHERE SAC_Caso__c IN: reclamacionesNew AND RecordTypeId != :tipoRegistroTMEGlobal AND RecordTypeId != :tipoRegistroTMEPreAlta];
        List<String> nombresParametriaciones = new List<String>();
        
        Map<Id,List<String>> nombresParametriacionesMap = new Map<Id,List<String>>();
        for(SAC_TMECaso__c tme : tmes){
            nombresParametriaciones.add(tme.Name);
            //nombresParametriacionesMap.put(tme.SAC_Caso__c);
            
            if(nombresParametriacionesMap.containsKey(tme.SAC_Caso__c)){
                List<String> nomParam = new List<String>();
                nomParam = nombresParametriacionesMap.get(tme.SAC_Caso__c);
                nomParam.add(tme.Name);
                nombresParametriacionesMap.put(tme.SAC_Caso__c, nomParam);
            }
            else{
                List<String> nomParam = new List<String>();
                nomParam.add(tme.Name);
                nombresParametriacionesMap.put(tme.SAC_Caso__c, nomParam);
            }
        }
        
        List<SAC_TMECaso__c> tmesNuevos = new List<SAC_TMECaso__c>();

        List<String> mccsCasos = new List<String>();
        List<String> canalProcedencia = new List<String>();
        Set<String> estados = new Set<String>();
        Map<Id,String> mapEstados = new Map<Id,String>();
        
        for(Case caso : reclamacionesNew){
            mccsCasos.add(caso.SEG_Detalle__c);
            canalProcedencia.add(caso.CC_Canal_Procedencia__c);
            estados.add(caso.Status);
            mapEstados.put(caso.Id, caso.Status);
        }
        if(!tmes.isEmpty()){
            //hay TME en el caso, hay que comprobar si hay que crearlo o no; y crear su TPE nuevo
            //falta filtrar por estado -> para ello siempre que se cree un TME hay que pasarle un objeto parametrizacion relacionado
            Map<Id, SAC_TMECaso__c> mapaTmesNuevos = new Map<Id, SAC_TMECaso__c>();
            for(SAC_TMECaso__c tme : tmes){
                if(tme.SAC_Parametrizacion__r.SAC_Estados__c != null){
                    List<String> estadoParams = tme.SAC_Parametrizacion__r.SAC_Estados__c.split(';');
                    if(!estadoParams.isEmpty()){
                        for(String estadoActual : estadoParams){
                            //es estadoCaso el mismo que el del TME.parametrizacion.SAC_ESTADO??
                            //if(estados.contains(estadoActual) ){
                            if(mapEstados.get(tme.SAC_Caso__c).contains(estadoActual)){
                                //Existe un TME.Name nombre igual al nombre de la parametrizacion?? 
                                if (!mapaTmesNuevos.containsKey(tme.Id)) {
                                    mapaTmesNuevos.put(tme.Id, tme);
                                }
                                //tmesNuevos.add(tme); Esta línea se comentó porque entraban tmes duplicados
                            }
                        }
                        /*if(!tmesNuevos.isEmpty()){
                            insertarTPE(tmesNuevos);
                            tmesNuevos.clear();
                        }*/
                    }
                }
            }
            tmesNuevos.addAll(mapaTmesNuevos.values());
                //comprobar cuales pueden ser las parametrizaciones a los casos
            List<SAC_ParametrizacionSLATME__c> parametrizacionesTMEs = [SELECT Id, SAC_Estados__c, SAC_Duracion__c, SAC_MCC__c, Name, SAC_CanalProcedencia__c, RecordTypeId, SAC_DuplicadoMCCProcedenciaEstado__c
                                                                        FROM SAC_ParametrizacionSLATME__c 
                                                                        WHERE /*SAC_Estados__c IN: estados 
                                                                            AND */((SAC_MCC__c IN: mccsCasos) OR SAC_TMEGeneral__c = TRUE )
                                                                            AND SAC_CanalProcedencia__c IN: canalProcedencia
                                                                            AND RecordTypeId =: tipoRegistro];

            //System.debug('lista parametrizaciones ---> '+parametrizacionesTMEs);
            
            if(!parametrizacionesTMEs.isEmpty()){

                //mapa estado/parametrizacion
                Map<String, List<SAC_ParametrizacionSLATME__c>> mapaEstadoParametrizacion = new Map<String, List<SAC_ParametrizacionSLATME__c>>();
                
                for(SAC_ParametrizacionSLATME__c parametrizacion : parametrizacionesTMEs){
                    List<String> estadoParams = parametrizacion.SAC_Estados__c.split(';');
                    for(String estadoUnico : estadoParams){
                        String llave = /*parametrizacion.SAC_MCC__c + */parametrizacion.SAC_CanalProcedencia__c + estadoUnico;
                        //comprobar si el mapa ya tiene registro
                        List<SAC_ParametrizacionSLATME__c> listadoParams = new List<SAC_ParametrizacionSLATME__c>();
                        if(mapaEstadoParametrizacion.containsKey(llave)){
                            listadoParams = mapaEstadoParametrizacion.get(llave);
                            listadoParams.add(parametrizacion);
                            mapaEstadoParametrizacion.put(llave, listadoParams);
                        }
                        else{
                            listadoParams.add(parametrizacion);
                            mapaEstadoParametrizacion.put(llave, listadoParams);
                        }
                    }

                }
                for(Case caso : reclamacionesNew){
                    String estado = caso.Status;
                    String mcc = caso.SEG_Detalle__c;
                    String canal = caso.CC_Canal_Procedencia__c;

                    String duplicado = /*mcc + */canal + estado;
                    
                    if(mapaEstadoParametrizacion.containsKey(duplicado)){
                        List<SAC_ParametrizacionSLATME__c> parametrizaciones = mapaEstadoParametrizacion.get(duplicado);
                        for(SAC_ParametrizacionSLATME__c parametrizacionFinal : parametrizaciones){
                            //if(!nombresParametriaciones.contains(parametrizacionFinal.Name)){
                            if(!nombresParametriacionesMap.get(caso.Id).contains(parametrizacionFinal.Name)){

                                for(String estadoFinal : estados){
                                    String duplicadoAuxiliar = /*mcc + */canal + estadoFinal;
                                    Integer posicion = nombresParametriaciones.indexOf(duplicadoAuxiliar);
                                    //system.debug(posicion);
                                    //system.debug(parametrizacionFinal.Name);
                                    if(posicion == -1 /*&& parametrizacionFinal.Name == nombresParametriaciones.get(posicion)*/){
                                        SAC_TMECaso__c tmeNuevo = new SAC_TMECaso__c();
                                        tmeNuevo.SAC_Parametrizacion__c = parametrizacionFinal.Id;
                                        tmeNuevo.SAC_Caso__c = caso.Id;
                                        tmeNuevo.SAC_TMEDefinido__c = parametrizacionFinal.SAC_Duracion__c;
                                        tmeNuevo.RecordTypeId = tipoRegistroTMECaso;
                                        tmeNuevo.Name = parametrizacionFinal.Name;
                                        tmesNuevos.add(tmeNuevo);
                                    }
                                }
                            }
                        }
                    }
                }
                if(!tmesNuevos.isEmpty()){   
                    //System.debug('por el primero -> '+tmesNuevos);
                    /*for (SAC_TMECaso__c tme : tmesNuevos) {
                        System.debug('tme dentro del bucle primero --> '+tme);
                    }*/
                    //Añadido 01/03/23 para eliminar posibles tmes duplicados
                    tmesNuevos = controlarTMEsDuplicados(tmesNuevos);
                    insertarTMOconTPE(tmesNuevos, mapaReclamacionesNew);
                }
            }
        }
        //inicio falta
        else{
            //conseguir parametrizacion del nuevo estado / mcc reclamacion
            List<SAC_ParametrizacionSLATME__c> parametrizacionesParaTMES = [SELECT Id, SAC_Estados__c, SAC_Duracion__c, SAC_MCC__c, Name, SAC_CanalProcedencia__c, RecordTypeId, SAC_DuplicadoMCCProcedenciaEstado__c
                                                                            FROM SAC_ParametrizacionSLATME__c 
                                                                            WHERE /*SAC_Estados__c IN: estados 
                                                                                AND */((SAC_MCC__c IN: mccsCasos) OR SAC_TMEGeneral__c = TRUE )
                                                                                AND SAC_CanalProcedencia__c IN: canalProcedencia
                                                                                AND RecordTypeId =: tipoRegistro];

            Map<String, List<SAC_ParametrizacionSLATME__c>> mapaEstadoParametrizacion = new Map<String, List<SAC_ParametrizacionSLATME__c>>();
            if(!parametrizacionesParaTMES.isEmpty()){
                for(SAC_ParametrizacionSLATME__c parametrizacion : parametrizacionesParaTMES){
                    if (!parametrizacion.SAC_Estados__c.split(';').isEmpty()) {
                        List<String> estadoParams = parametrizacion.SAC_Estados__c.split(';');
                        for(String estadoUnico : estadoParams){
                            String llave = /*parametrizacion.SAC_MCC__c +*/ parametrizacion.SAC_CanalProcedencia__c + estadoUnico;
                            //comprobar si el mapa ya tiene registro
                            List<SAC_ParametrizacionSLATME__c> listadoParams = new List<SAC_ParametrizacionSLATME__c>();
                            if(mapaEstadoParametrizacion.containsKey(llave)){
                                listadoParams = mapaEstadoParametrizacion.get(llave);
                                listadoParams.add(parametrizacion);
                                mapaEstadoParametrizacion.put(llave, listadoParams);
                            }
                            else{
                                listadoParams.add(parametrizacion);
                                mapaEstadoParametrizacion.put(llave, listadoParams);
                            }
                        }
                    }
                }
            }
            //for de casos, recuperar para cada caso el mcc entrada estado y crear un string en el que comparar la key del map, 
            //si coincide, ya se que parametrizacion hay que hacerle al nuevo TME para cada caso
            
            for(Case caso : reclamacionesNew){
                String mcc = caso.SEG_Detalle__c;
                String estado = caso.Status;
                String canal = caso.CC_Canal_Procedencia__c;

                String param = /*mcc +*/ canal + estado;
                if(mapaEstadoParametrizacion.containsKey(param)){
                    List<SAC_ParametrizacionSLATME__c> parametrizacionesFinales = mapaEstadoParametrizacion.get(param);
                    for(SAC_ParametrizacionSLATME__c parametrizacionFinal : parametrizacionesFinales){
                        if(!nombresParametriaciones.contains(parametrizacionFinal.Name)){
                            SAC_TMECaso__c tmeNuevo = new SAC_TMECaso__c();
                            tmeNuevo.SAC_Parametrizacion__c = parametrizacionFinal.Id;
                            tmeNuevo.RecordTypeId = tipoRegistroTMECaso;
                            tmeNuevo.SAC_Caso__c = caso.Id;
                            tmeNuevo.SAC_TMEDefinido__c = parametrizacionFinal.SAC_Duracion__c;
                            tmeNuevo.Name = parametrizacionFinal.Name;
                            tmesNuevos.add(tmeNuevo);
                        }
                    }
                }
                else{
                    SAC_TMECaso__c tmeNuevo = new SAC_TMECaso__c();
                    tmeNuevo.SAC_Caso__c = caso.Id;
                    tmeNuevo.RecordTypeId = tipoRegistroTMECaso;
                    tmeNuevo.SAC_TMEDefinido__c = 30;
                    tmeNuevo.Name = 'TME Genérico';
                    tmesNuevos.add(tmeNuevo);
                }
            }
            if(!tmesNuevos.isEmpty()){   
                //System.debug('por el segundo -> '+tmesNuevos);
                insertarTMOconTPE(tmesNuevos, mapaReclamacionesNew);
            }
        }
    }
    
    public static void insertarTPE(List<SAC_TMECaso__c> tmes, Map<Id, Case> mapaReclamacionesNew){ 
        /*****************************************************************
         * Proposito: Método para insertar TPEs 
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US227582         Luis Mesa      03/06/21     Creación
        *****************************************************************/
            List<SAC_TiempoEstados__c> tpes = new List<SAC_TiempoEstados__c>();

            if(!tmes.isEmpty()){
                for(SAC_TMECaso__c tme : tmes){
                    SAC_TiempoEstados__c tpe = new SAC_TiempoEstados__c();
                    tpe.SAC_Estado__c = tme.SAC_Caso__r.Status;
                    tpe.SAC_Inicio__c = system.now();
                    tpe.SAC_TMECaso__c = tme.Id;
                    if (mapaReclamacionesNew.containsKey(tme.SAC_Caso__c) && String.isNotBlank(mapaReclamacionesNew.get(tme.SAC_Caso__c).SEG_Grupo__c)) {
                        tpe.SAC_Grupo__c = mapaReclamacionesNew.get(tme.SAC_Caso__c).SEG_Grupo__c;
                    }
                    tpes.add(tpe);
                }
            }
            else{
                throw new AuraHandledException('Fallo al crear un TPE');
            } 
            upsert(tpes);
        }

    public static void closeTPE(List<Case> reclamacionesOld){ 
         
    /*****************************************************************
     * Proposito: Método para cerrar los TPEs
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US227582         Luis Mesa      03/06/21     Creación
    *****************************************************************/
       Id RTTMEGlobal = Schema.SObjectType.SAC_TMECaso__c.getRecordTypeInfosByDeveloperName().get('SAC_TMEGlobal').getRecordTypeId();

        List<SAC_TiempoEstados__c> tpes = [SELECT Id, SAC_Estado__c, SAC_Duracion__c, SAC_Fin__c, SAC_Inicio__c, SAC_TMECaso__r.SAC_Caso__c
                                            FROM SAC_TiempoEstados__c
                                            WHERE SAC_TMECaso__r.SAC_Caso__c IN: reclamacionesOld
                                            AND SAC_TMECaso__r.RecordTypeId != :RTTMEGlobal];


        if(!tpes.isEmpty()){
            for(SAC_TiempoEstados__c tpe : tpes){
                if(tpe.SAC_Fin__c == null){
                    tpe.SAC_Fin__c = system.now();
                }
            }  
            update tpes;
        }
    }

    public static void insertarTMOconTPE(List<SAC_TMECaso__c> tmesNuevos, Map<Id, Case> mapaReclamacionesNew) {   
        List<Database.UpsertResult> result = Database.upsert(tmesNuevos,false);
        List<Id> listOfIds = new List<Id>();
        Map<Id,Id> mapaDeIdesAux = new Map<Id,Id>();

        for (Database.UpsertResult sr : result) {
            if (sr.isSuccess()) {
                listOfIds.add(sr.getId());
                mapaDeIdesAux.put(sr.getId(), sr.getId());
            }
        }

        List<SAC_TMECaso__c> listaTMOAux = new List<SAC_TMECaso__c>();

        if(!tmesNuevos.isEmpty()){
            for (SAC_TMECaso__c tmeAux : tmesNuevos) {
                if(mapaDeIdesAux.containsKey(tmeAux.id)){
                    listaTMOAux.add(tmeAux);
                }
            }
        }

        if(!listaTMOAux.isEmpty()) {
            insertarTPE(listaTMOAux, mapaReclamacionesNew);
        }
        
    }

    private static List<SAC_TMECaso__c> controlarTMEsDuplicados(List<SAC_TMECaso__c> listaTMEsNuevos) {
        List<SAC_TMECaso__c> listaTMEsFiltrados = new List<SAC_TMECaso__c>();
        Map<Id, List<SAC_TMECaso__c>> mapaParamTME = new Map<Id, List<SAC_TMECaso__c>>();
        //Recorrer lista tmes para buscar duplicados
        for (SAC_TMECaso__c tmeNuevo : listaTMEsNuevos) {
            //Si el mapa no contiene la parametrización del tme, se inicializa con la parametrización de key y su lista de tmes de valor, además de la lista final de tmes filtrados
            if (!mapaParamTME.containsKey(tmeNuevo.SAC_Parametrizacion__c)) {
                List<SAC_TMECaso__c> listaTmes = new List<SAC_TMECaso__c>();
                listaTmes.add(tmeNuevo);
                mapaParamTME.put(tmeNuevo.SAC_Parametrizacion__c, listaTmes);
                listaTMEsFiltrados.add(tmeNuevo);
            //Si el mapa contiene tmes con la parametrización, se recorren dichos tmes    
            } else {
                Boolean duplicado = false;
                for (SAC_TMECaso__c tme : mapaParamTME.get(tmeNuevo.SAC_Parametrizacion__c)) {
                    //Si el tme del mapa tiene el mismo nombre, mismo recordtypeId y mismo name que el tme de la listaTMEsNuevos, lo consideramos duplicado
                    if (tme.SAC_Caso__c == tmeNuevo.SAC_Caso__c && tme.RecordTypeId == tmeNuevo.RecordTypeId && tme.Name == tmeNuevo.Name) {
                        duplicado = true; //Activación booleano para indicar que es un duplicado
                    }
                }
                //Si no es duplicado, se añade a la lista de tmes de dicha parametrización en el mapa y a la lista final de tmes filtrados
                if (!duplicado) {
                    mapaParamTME.get(tmeNuevo.SAC_Parametrizacion__c).add(tmeNuevo);
                    listaTMEsFiltrados.add(tmeNuevo);
                }
            }
        }
        //Retornar lista filtrada
        return listaTMEsFiltrados;
    }
        
}