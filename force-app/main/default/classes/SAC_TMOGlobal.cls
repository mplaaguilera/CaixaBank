/*****************************************************************
 * Name: SAC_TMOGlobal
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Crear y modificar el TMO Global de la Reclamación
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US449416       Marcela Neira    14/09/22     Creación
*****************************************************************/
public without sharing class SAC_TMOGlobal {

    private static Set<String> objetos = new Set<String>{'Case','SAC_TMECaso__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    private static final Id RECTYPETMOGLOBAL = mapRTsObjects.get('SAC_TMECaso__c').get('SAC_TMEGlobal').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RTTMEPREALTA = mapRTsObjects.get('SAC_TMECaso__c').get('SAC_PreAlta').getRecordTypeId();
    private static final Id RTTMEGLOBAL = mapRTsObjects.get('SAC_TMECaso__c').get('SAC_TMEGlobal').getRecordTypeId();

     /*****************************************************************
     * Proposito: Método para insertar los TMOs Global y PreAlta
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US449416      Marcela Neira    14/09/22     Creación
     *                               Carlos Solis    
    *****************************************************************/

    public static void insertarTMOs(List<Case> listaRecPretCons) { 
        List<SAC_TMECaso__c> listaTMOs = new List<SAC_TMECaso__c> ();

        for (Case caso : listaRecPretCons) {
            SAC_TMECaso__c tmoGlobalAux = new SAC_TMECaso__c(RecordTypeId =RTTMEGLOBAL, Name = 'TMO Global', SAC_Caso__c = caso.Id);
            SAC_TMECaso__c tmoPrealtaAux = new SAC_TMECaso__c(RecordTypeId =RTTMEPREALTA, Name = 'TMO PreAlta', SAC_Caso__c = caso.Id);

            listaTMOs.add(tmoGlobalAux);
            listaTMOs.add(tmoPrealtaAux);
        }     

        if (!listaTMOs.isEmpty()) {
            SAC_DatabaseDML.insertListDML(listaTMOs, false);
        } 
    }   

    public static void modificarFechaInicial(List<Case> listaCasos) {   
        
        Map<Id,Case> mapaCasos = new Map<Id,Case>(listaCasos);
        Map<Id,List<SAC_TMECaso__c>> mapaTMOsCaso = new Map<Id,List<SAC_TMECaso__c>>();
        Map<Id,List<SAC_TiempoEstados__c>> mapaTPEsCaso = new Map<Id,List<SAC_TiempoEstados__c>>();
        Map<Id,SAC_TiempoEstados__c> mapaTMEActualizar = new Map<Id,SAC_TiempoEstados__c>();

        List<SAC_TMECaso__c> listaTMOsCaso = [SELECT Id, SAC_Caso__c FROM SAC_TMECaso__c WHERE RecordTypeId =: RECTYPETMOGLOBAL AND SAC_Caso__c IN: listaCasos ];
        
        if(!listaTMOsCaso.isEmpty()){ 
            //Buscamos los tpes y los ordenamos por la fecha de creacion asi más adelante solo modificamos el primer registro que es que tiene la
            //fecha de inicio la (prealta)
            List<SAC_TiempoEstados__c> listaTPEsCaso = [SELECT Id, SAC_TMECaso__r.SAC_Caso__c 
                                                        FROM SAC_TiempoEstados__c 
                                                        WHERE SAC_TMECaso__c =: listaTMOsCaso AND SAC_Estado__c = 'Global' ORDER BY CreatedDate ];
 
            if (!listaTPEsCaso.isEmpty()) {
                for (SAC_TiempoEstados__c tpe : listaTPEsCaso) {
                    if(mapaTPEsCaso.containsKey(tpe.SAC_TMECaso__r.SAC_Caso__c )){
                        List<SAC_TiempoEstados__c> listaTPEsCasoAux = mapaTPEsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c );
                        listaTPEsCasoAux.add(tpe);
                        mapaTPEsCaso.put(tpe.SAC_TMECaso__r.SAC_Caso__c , listaTPEsCasoAux);
                    }else{
                        List<SAC_TiempoEstados__c> listaTPEsCasoAux = new List<SAC_TiempoEstados__c>();
                        listaTPEsCasoAux.add(tpe);
                        mapaTPEsCaso.put(tpe.SAC_TMECaso__r.SAC_Caso__c , listaTPEsCasoAux);
                    }
                }

                for (SAC_TiempoEstados__c tpe : listaTPEsCaso) {
                    if(mapaTPEsCaso.containsKey(tpe.SAC_TMECaso__r.SAC_Caso__c ) && mapaCasos.containsKey(tpe.SAC_TMECaso__r.SAC_Caso__c)){
                         
                        //Actualizamos solo el primer registro que será el del prealta
                        //No debemos modificar los siguientes resgistros ya que el caso puede que haya salido de 'Subsanacion' o 'derivacion'
                        //Estas deben tener su propia fecha inicial  

                        if(mapaCasos.get(tpe.SAC_TMECaso__r.SAC_Caso__c).SAC_FechaRecepcion__c == null){ //Creación de una nueva reclamación vínculada
                            mapaTPEsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c )[0].SAC_Inicio__c = mapaCasos.get(tpe.SAC_TMECaso__r.SAC_Caso__c).CreatedDate;
                        }else{
                            mapaTPEsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c )[0].SAC_Inicio__c = mapaCasos.get(tpe.SAC_TMECaso__r.SAC_Caso__c).SAC_FechaRecepcion__c;
                        }
                            
                        mapaTMEActualizar.put(mapaTPEsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c )[0].Id, mapaTPEsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c )[0]);               
                    }
                }

            }

            if (!mapaTMEActualizar.values().isEmpty()) {  
                SAC_DatabaseDML.updateListDML(mapaTMEActualizar.values(), false);
            }          
        }        
    }

    public static void modificarFechaFinal(List<Case> listaCasos, Boolean modificacionDesdePretension) {  

        Map<Id,Case> mapaCasos = new Map<Id,Case>(listaCasos);
        Map<Id,List<SAC_TMECaso__c>> mapaTMOsCaso = new Map<Id,List<SAC_TMECaso__c>>();
        Map<Id,List<SAC_TiempoEstados__c>> mapaTPEsCaso = new Map<Id,List<SAC_TiempoEstados__c>>();
        Map<Id,SAC_TMECaso__c> mapaTMOUpdatear = new Map<Id,SAC_TMECaso__c> ();
        Map<Id,SAC_TiempoEstados__c> mapaTPEsUpdatear = new Map<Id,SAC_TiempoEstados__c> ();

        List<SAC_TMECaso__c> listaTMOsCaso = [SELECT Id, SAC_Caso__c FROM SAC_TMECaso__c WHERE RecordTypeId =: RECTYPETMOGLOBAL AND SAC_Caso__c IN: listaCasos ];
 
        if(!listaTMOsCaso.isEmpty()){ 
            //Buscamos los registros de TPE ordenados por la fecha de creación de forma descendente para luego más adelante
            //Solo actualizemos la fecha fin de el primer registro es decir del último creado
            List<SAC_TiempoEstados__c> listaTPEsCaso = [SELECT Id, SAC_TMECaso__r.SAC_Caso__c 
                                                        FROM SAC_TiempoEstados__c 
                                                        WHERE SAC_TMECaso__c =: listaTMOsCaso AND SAC_Estado__c = 'Global' ORDER BY CreatedDate desc ];

            //Se monta el mapa de los TMOs                                            
            for (SAC_TMECaso__c tmo : listaTMOsCaso) {
                if(mapaTMOsCaso.containsKey(tmo.SAC_Caso__c)){
                    List<SAC_TMECaso__c> listaTMOsCasoAux = mapaTMOsCaso.get(tmo.SAC_Caso__c);
                    listaTMOsCasoAux.add(tmo);
                    mapaTMOsCaso.put(tmo.SAC_Caso__c, listaTMOsCasoAux);
                }else{
                    List<SAC_TMECaso__c> listaTMOsCasoAux = new List<SAC_TMECaso__c>();
                    listaTMOsCasoAux.add(tmo);
                    mapaTMOsCaso.put(tmo.SAC_Caso__c, listaTMOsCasoAux);
                }
            } 

            //Se monta el mapa de los TPEs
            if (!listaTPEsCaso.isEmpty()) {
                for (SAC_TiempoEstados__c tpe : listaTPEsCaso) {
                    if(mapaTPEsCaso.containsKey(tpe.SAC_TMECaso__r.SAC_Caso__c )){
                        List<SAC_TiempoEstados__c> listaTPEsCasoAux = mapaTPEsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c );
                        listaTPEsCasoAux.add(tpe);
                        mapaTPEsCaso.put(tpe.SAC_TMECaso__r.SAC_Caso__c , listaTPEsCasoAux);
                    }else{
                        List<SAC_TiempoEstados__c> listaTPEsCasoAux = new List<SAC_TiempoEstados__c>();
                        listaTPEsCasoAux.add(tpe);
                        mapaTPEsCaso.put(tpe.SAC_TMECaso__r.SAC_Caso__c , listaTPEsCasoAux);
                    }
                }                

                Integer listaTPEsCasoSize = listaTPEsCaso.size();
                Integer contador = 0;
                for (SAC_TiempoEstados__c tpe : listaTPEsCaso) {
                    contador++;
                    //Ejecutar el código solo si es el ultimo tpe de la iteración para evitar que reabra todos los tpes al poner una fecha de resolución nula (salida de subsanación, reapertura, etc)
                    if(contador == listaTPEsCasoSize && mapaTPEsCaso.containsKey(tpe.SAC_TMECaso__r.SAC_Caso__c ) && mapaCasos.containsKey(tpe.SAC_TMECaso__r.SAC_Caso__c)){
                        //Modificamos solo el primer registro esto implica que es el último tpe que se ha creado 
                        //Se hace así si en algún momento de la vida del caso este ha salido de los estados de 'subsanación' o 'derivación'
                        //que es cuando se crea un nuevo TPE y debe contar de nuevo 
                        //Recordar que en el TME se hace la suma de la duración de los TPEs de cada TME

                        //Si el nuevo estado del caso es 'subsanación' o 'derivación' se informa la fecha fin con la fecha en el que entro a esos
                        //estados, si no son esos estados eso quiere decir que se ha informado un fecha de resolución y es la que debemos informar 
                        //como fecha de finalización   

                        //Si se hace una modificacion como 'Subsanacion' desde la pretensión la reclamación no tendrá todavia el estado (actualizado)
                        //asi que utilizamos el Boolean para saber si la modificacion se hace desde la pretension
                        if(modificacionDesdePretension ||
                            mapaCasos.get(tpe.SAC_TMECaso__r.SAC_Caso__c).Status == 'SAC_006' || 
                            mapaCasos.get(tpe.SAC_TMECaso__r.SAC_Caso__c).Status == 'SAC_008' ||
                            mapaCasos.get(tpe.SAC_TMECaso__r.SAC_Caso__c).Status == 'Rechazado'){
                            mapaTMOsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c)[0].SAC_FechaFin__c = System.now();                            
                            mapaTPEsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c )[0].SAC_Fin__c = System.now();                            
                        }else{
                            if(mapaCasos.get(tpe.SAC_TMECaso__r.SAC_Caso__c).Status == 'SAC_014'){
                                mapaTMOsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c)[0].SAC_FechaFin__c = System.now();                            
                                mapaTPEsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c )[0].SAC_Fin__c = System.now(); 
                            }else{
                                mapaTMOsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c)[0].SAC_FechaFin__c = mapaCasos.get(tpe.SAC_TMECaso__r.SAC_Caso__c).OS_Fecha_Resolucion__c;
                                mapaTPEsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c )[0].SAC_Fin__c = mapaCasos.get(tpe.SAC_TMECaso__r.SAC_Caso__c).OS_Fecha_Resolucion__c;
                            }  
                        } 

                        mapaTMOUpdatear.put(mapaTMOsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c)[0].Id,mapaTMOsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c)[0]);
                        mapaTPEsUpdatear.put(mapaTMOsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c)[0].Id,mapaTPEsCaso.get(tpe.SAC_TMECaso__r.SAC_Caso__c )[0]);
                    }
                }
            }
            
            if(!mapaTMOUpdatear.values().isEmpty()){   
                SAC_DatabaseDML.updateListDML(mapaTMOUpdatear.values(), false);
            }
            if(!mapaTPEsUpdatear.values().isEmpty()){    
                SAC_DatabaseDML.updateListDML(mapaTPEsUpdatear.values(), false);
            }
            
        }
    }

    

    public static void crearNuevoTPE(List<Id> listaCasos) {  
        List<SAC_TiempoEstados__c> listaTPEs = new List<SAC_TiempoEstados__c>();
        List<SAC_TMECaso__c> listaTMOsCaso = [SELECT Id, SAC_Caso__c FROM SAC_TMECaso__c WHERE RecordTypeId =: RECTYPETMOGLOBAL AND SAC_Caso__c IN: listaCasos ];
        if(!listaTMOsCaso.isEmpty()){ 
            for (SAC_TMECaso__c tmo : listaTMOsCaso) {
                SAC_TiempoEstados__c tpeGlobalAux = new SAC_TiempoEstados__c(SAC_TMECaso__c = tmo.id, 
                                                            SAC_Inicio__c = System.now(), SAC_Estado__c = 'Global');
                listaTPEs.add(tpeGlobalAux);
            }
        }
        if(!listaTPEs.isEmpty()){ 
            SAC_DatabaseDML.insertListDML(listaTPEs, false);
        }
        
    } 

    public static List<Case> filtrarListaSelect(Set<Id> idesClave, List<Case> listaCasosSelect) {

        Map<Id,Case> mapaReclamaciones = new Map<Id,Case>();

        for (Id ide : idesClave) {
            mapaReclamaciones.put(ide, new Case());
        }

        for (Case caso : listaCasosSelect) {
            if(mapaReclamaciones.containsKey(caso.Id)){
                mapaReclamaciones.put(caso.Id, caso);
            }
        }

        return mapaReclamaciones.values();
        
    }

    public static void insertarTPEVueltaSubsanacion(List<Id> listaVueltaDeSubsanacion, List<Case> listaCasosSelect) {
        //Crear mapa con key reclamacion y valor lista de pretensiones hijas
        Map<Id, List<Case>> mapaRecPrets = new Map<Id, List<Case>>();
        for (Id ideRec : listaVueltaDeSubsanacion) {
            List<Case> listaPrets = new List<Case>();
            mapaRecPrets.put(ideRec, listaPrets);
        }
        //Filtrar solo las pretensiones hijas de las cuales una haya salido de subsanación añadiendolas al mapaRecPrets
        for (Case casoSelect : listaCasosSelect) {
            if (casoSelect.recordTypeId == RECTYPEPRETENSION && mapaRecPrets.containsKey(casoSelect.SAC_Reclamacion__c)) {
                mapaRecPrets.get(casoSelect.SAC_Reclamacion__c).add(casoSelect);
            }
        }

        List<Id> listaIdsReclamacion = new List<Id>();
        //Recorrer las pretensiones de cada reclamación
        for (Id iderec : mapaRecPrets.keySet()) {
            Boolean crearTPE = true;
            for (Case pret : mapaRecPrets.get(iderec)) {
                //Si alguna de las pretensiones sigue estando en subsanación, no debe crear el TPE
                if (pret.Status == 'SAC_006') {
                    crearTPE = false;
                }
            }
            //Si no se ha encontrado ninguna pretensión en subsanación, Se añade la id de la reclamación a la lista para crear el TPE
            if (crearTPE) {
                listaIdsReclamacion.add(iderec);
            }
        }

        //Si la lista de ids de reclamación para crear TPE no está vacía, llamamos al metodo que crea los TPE pasandole dichas ids
        if (!listaIdsReclamacion.isEmpty()) {
            crearNuevoTPE(listaIdsReclamacion);
        }
    }
}