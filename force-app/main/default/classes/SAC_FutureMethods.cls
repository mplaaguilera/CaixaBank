public without sharing class SAC_FutureMethods {
    /*****************************************************************
     * Name: SAC_FutureMethods
     * Copyright © 2021  CaixaBank
     * 
     * Proposito: Clase que agrupa a todos los métodos future en un único método para el proyecto SAC.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            N/A           Luis Mesa García  14/09/2021     Creación
     *                              Carlos Solis Caño
     * 2.0            US866223      Alexandre Perez   03/04/2024   Nuevo método fechaAsignTMO
     *****************************************************************/
    
        private static Set<String> objetos = new Set<String>{'Case'};
        private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
        private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
        private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();
        private static final Id RECTYPECONSAC = mapRTsObjects.get('Case').get('SAC_ConsultaSAC').getRecordTypeId();
    
        public static void gestionMetodosFuturos(List<Case> newListCase, Map<Id, Case> mapOldCase/*, List<Case> familia*/){
        /*****************************************************************
         * Proposito: Método que realiza la llamada a los correspondientes métodos Future
         *              -> update SAC_ComportamientoSLAs
         *              -> update SAC_Notificacion.
         * 1.1: Modificación para no pausar el sla cuando se entra en estado negociación
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            N/A           Luis Mesa García  14/09/2021     Creación
         *                              Carlos Solis Caño
         * 1.1            US392178      Sergio Martín     04/08/2023    Modificación
         *****************************************************************/
    
            //filtrar info si cambia cierta info:
                // si cambia el mcc(DEG_Detalle__c) => recuperar familia y hacer update de toda ella                => llamada a future1
                // si cambia el estado (Status)   => llamar al metodo comprobar pausas hacer update de la familia   => llamada a future2
                
            List<Case> listaPausas = new List<Case>();
            List<Case> listaMccs = new List<Case>();
            List<Case> familia = new List<Case>();
    
            //Listas para las notificaciones
            Set<String> idesCasosAlta = new Set<String>();
            Set<String> ides48Letrado = new Set<String>();
            Set<String> ides48Regulatorio = new Set<String>();
            Set<String> ides24Letrado = new Set<String>();
            Set<String> ides24Regulatorio = new Set<String>();
    
            //Variable que decide el metodo que se ejecuta dentro del @future
            Integer numMetodo = 0;
            for(Case caso : newListCase){
                if(mapOldCase.containsKey(caso.Id)){ 
                    //cambia status
                    if(
                        //pausar slas
                        // ((caso.Status != mapOldCase.get(caso.Id).Status || caso.SAC_ReclamanteConformeNegociacion__c != mapOldCase.get(caso.Id).SAC_ReclamanteConformeNegociacion__c )
                        //     && (caso.Status == 'SAC_006' || (caso.Status == 'SAC_007' && caso.SAC_ReclamanteConformeNegociacion__c == true) 
                        // )) 
                        (caso.Status != mapOldCase.get(caso.Id).Status && caso.Status == 'SAC_006' )  
                        || 
                        //reanudar slas
                        // ((caso.Status != mapOldCase.get(caso.Id).Status || (caso.SAC_ReclamanteConformeNegociacion__c == false && mapOldCase.get(caso.Id).SAC_ReclamanteConformeNegociacion__c == true))
                        //     && ((mapOldCase.get(caso.Id).Status == 'SAC_006' && caso.Status != 'SAC_006' && caso.Status != 'SAC_007') 
                        //         || (mapOldCase.get(caso.Id).Status == 'SAC_007' && caso.Status != 'SAC_006' && caso.Status != 'SAC_007')
                        //         || ((mapOldCase.get(caso.Id).Status == 'SAC_007' ||  mapOldCase.get(caso.Id).Status == 'SAC_006') && caso.Status == 'SAC_007' && caso.SAC_ReclamanteConformeNegociacion__c == false) 
                        // ))
                        (caso.Status != mapOldCase.get(caso.Id).Status)
                            && ((mapOldCase.get(caso.Id).Status == 'SAC_006' && caso.Status != 'SAC_006'))
                    ){
                        //lista para cambios de estado con paradas y reanudacion de slas
                        listaPausas.add(caso);
                    }
                    //cambia mcc o canal de procedencia o (casoEspecial sin ser un cambio a nulo y sin ser estado ejecución)
                    if(caso.SEG_Detalle__c != mapOldCase.get(caso.Id).SEG_Detalle__c || caso.CC_Canal_Procedencia__c != mapOldCase.get(caso.Id).CC_Canal_Procedencia__c || 
                       (caso.SAC_CasoEspecial__c != mapOldCase.get(caso.Id).SAC_CasoEspecial__c && String.isNotBlank(caso.SAC_CasoEspecial__c) && caso.Status != 'SAC_004')
                       ||(caso.Status != mapOldCase.get(caso.Id).Status && (caso.Status == 'SAC_009' || mapOldCase.get(caso.Id).Status == 'SAC_009'))){
                        listaMccs.add(caso);
                    }
                }
            }
    
            //llamada metodos future
            if(!listaPausas.isEmpty() && !listaMccs.isEmpty()){
                List<Case> listaConjunta = new List<Case>();
                listaConjunta.addAll(listaPausas); 
                listaConjunta.addAll(listaMccs);
                familia = SAC_ComportamientoSLAs.buscarFamiliaCasos(listaConjunta);
                Set<String> setIds = new Set<String>();
                for(Case caso : familia){
                    setIds.add(caso.Id);
                }
                numMetodo = 2;
                //updateFamilia(setIds, numMetodo);
                contextoFamilia(setIds, numMetodo);
            }
            else if(!listaPausas.isEmpty()){
                familia = SAC_ComportamientoSLAs.buscarFamiliaCasos(listaPausas);
                Set<String> setIds = new Set<String>();
                for(Case caso : familia){
                    setIds.add(caso.Id);
                }
                numMetodo = 2;
                //updateFamilia(setIds, numMetodo);
                contextoFamilia(setIds, numMetodo);
            }
            else if(!listaMccs.isEmpty()){
                familia = SAC_ComportamientoSLAs.buscarFamiliaCasos(listaMccs);
                Set<String> setIds = new Set<String>();
                for(Case caso : familia){ 
                    setIds.add(caso.Id);
                }
                numMetodo = 1;
                //updateFamilia(setIds, numMetodo);
                contextoFamilia(setIds, numMetodo);
            }
        }

        
        /*****************************************************************
        * Proposito: dependiendo de en que contexto esté la ejecución actual
        * decide si lanzarlo como future
        * 
        * Historial
        * -------
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0            US749927         Alexandre Perez   9/11/2023     Creación
        *****************************************************************/
        public static void contextoFamilia(Set<String> listaIds, Integer numMetodo){
            //por ahora el problema es con un queueable, pero en un futuro ser deberían incluir el resto de contextos asíncronos
            if(System.isQueueable() || System.isFuture()) {
                ejecutarFamiliaSincrono(listaIds, numMetodo);
            } else {
                ejecutarFamiliaAsincrono(listaIds, numMetodo);
            }
        }

        /*****************************************************************
        * Proposito: en caso de venir de un contexto queueable para evitar errores de colisiones el future se deberá
        * ejecutar de manera síncrona
        * 
        * Historial
        * -------
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0            US749927         Alexandre Perez   9/11/2023     Creación
        *****************************************************************/
        public static void ejecutarFamiliaSincrono(Set<String> listaIds, Integer numMetodo){
            updateFamilia(listaIds, numMetodo);
        }

        /*****************************************************************
        * Proposito: en caso de venir de un contexto normal, se debe ejecutar en asíncrono
        * 
        * Historial
        * -------
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0            N/A              Alexandre Perez   9/11/2023     Creación
        *****************************************************************/
        @future
        public static void ejecutarFamiliaAsincrono(Set<String> listaIds, Integer numMetodo){
            updateFamilia(listaIds, numMetodo);
        }
    
        //@future
        public static void updateFamilia(Set<String> listaIds, Integer numMetodo){
         /*****************************************************************
         * Proposito: Método Future con utilidad para las diferentes casuísticas controladas por la variable numMetodo:
         *              1. Cambio de MCC que comporta tener que revisar las clases MilestoneTimeCalculator a través de un Update
         *              2. Pausa y reanudación de SLAs cuando cambia el Estado del registro a un estado de pausa o reanudación. Puede englobar el punto 1.
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            N/A           Luis Mesa García  14/09/2021     Creación
         *                              Carlos Solis Caño
         *****************************************************************/
            List<Case> listaFamilia = new List<Case>();
            if (numMetodo == 1 || numMetodo == 2) {
                listaFamilia = [SELECT id, SAC_Reclamacion__c, RecordTypeId, Status, SAC_EnvioParcial__c, SAC_ReclamanteConformeNegociacion__c, isStopped,
                                SAC_TiempoSLALetradoAlta__c, SAC_TiempoSLARegulatorio__c, SEG_Detalle__c, CC_Canal_Procedencia__c, SAC_CasoEspecial__c,
                                SAC_Reclamacion__r.SAC_CasoEspecial__c, SAC_Prorrogado__c
                                FROM Case
                                WHERE (RecordTypeId = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPEPRETENSION)
                                AND Id IN :listaIds];
            }
    
            if(numMetodo == 2){
                //update de familia al cambiar estado
                listaFamilia = comprobarPausas(listaFamilia);
            }
            if(numMetodo == 1){
                //update de familia al cambiar estado
                listaFamilia = SAC_CalculoSLA.buscarParametrizacionMCC(listaFamilia);
            }
            if(!listaFamilia.isEmpty()){
                List<Database.SaveResult> updateResults = Database.update(listaFamilia,false);
                Boolean hasError = false;
                List<Object> objs = new List<Object>();
                Map<String, String> msjs = new Map<String, String>();
                for (Integer i = 0; i < listaFamilia.size(); i++) {
                    Database.SaveResult sr = updateResults[i];
                    if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                        msjs.put(listaFamilia[i].Id, ((String) sr.getErrors()[0].getMessage()));
                        objs.add(listaFamilia[i]);
                        hasError = true;
                    }
                }

                if(hasError) {
                    CBK_Log.error(msjs, objs);
                }
            }
                
        }
        
        public static List<Case> comprobarPausas(List<Case> listaFamilia){
        /*****************************************************************
         * Proposito: Método que realiza la llamada a los correspondientes métodos Future
         *              -> update SAC_ComportamientoSLAs
         *              -> update SAC_Notificacion.
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            N/A           Luis Mesa García  14/09/2021     Creación
         *                              Carlos Solis Caño
         *****************************************************************/
            List<Case> listaReclamaciones = new List<Case>();
            List<Case> listaPretensiones = new List<Case>();
            List<Case> listaUpdatear = new List<Case>();
            //Separo las reclamaciones de las pretensiones
            for (Case caso : listaFamilia) {
                if (caso.RecordTypeId == RECTYPERECLAMACION) {
                    listaReclamaciones.add(caso);
                } else if (caso.RecordTypeId == RECTYPEPRETENSION) {
                    listaPretensiones.add(caso);
                }
            }
    
            //Monto mapa llamando al método que lo hace
            Map<Id,List<Case>> mapaPadreHijas = new Map<Id,List<Case>>();
            mapaPadreHijas = SAC_ComportamientoSLAs.montarMapaReclamacionFamilia(listaFamilia);
    
            //Recorro el mapa y la lista de casos asociados a cada reclamación
            for (Case reclamacion : listaReclamaciones) {
                Boolean pausarFamilia = false;
                if (mapaPadreHijas.containsKey(reclamacion.Id)) {
                    //Si alguno de los casos de cada familia está en estado de parada, lo guardo en el Boolean 'pausarFamilia'
                    for (Case caso : mapaPadreHijas.get(reclamacion.Id)) {
                        // MOD: Comentado pausa subsanación por US959472
                        // if (caso.Status == 'SAC_006') { //Subsanación
                        //     caso.isStopped = true;
                        //     pausarFamilia = true;
                        // }
                        if (caso.Status == 'SAC_007' && caso.SAC_ReclamanteConformeNegociacion__c) { //Negociación
                            caso.isStopped = true;
                            pausarFamilia = true;
                        }
                    }
                    //Con el anterior Boolean, si alguno de los casos está pausado en la familia de esta reclamación, pauso el resto de la familia.
                    //De lo contrario (es decir, si nadie de la familia está en estado de pausa), reanudo el SLA de toda la familia
                    if (pausarFamilia) {
                        for (Case caso : mapaPadreHijas.get(reclamacion.Id)) {
                            //Cada caso lo devuelvo a una lista que posteriormente retornaré con todas las modificaciones hechas.
                            caso.isStopped = true;
                            listaUpdatear.add(caso);
                        }
                    } else {
                        for (Case caso : mapaPadreHijas.get(reclamacion.Id)) {
                            //Cada caso lo devuelvo a una lista que posteriormente retornaré con todas las modificaciones hechas.
                            caso.isStopped = false;
                            listaUpdatear.add(caso);
                        }
                    }
                }
            }
            //Finalmente, updateamos la lista con las pausas de los casos modificados
            return listaUpdatear;
        }

        /*****************************************************************
        * Proposito: dependiendo de en que contexto esté la ejecución actual
        * decide si lanzarlo como future
        * 
        * Historial
        * -------
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0            US749927         Alexandre Perez   9/11/2023     Creación
        *****************************************************************/
        //contextoPermisosLetrado
        public static void permisosLetrado(List<Id> listaIds){
            //por ahora el problema es con un queueable, pero en un futuro ser deberían incluir el resto de contextos asíncronos
            if(System.isFuture()) {
                ejecutarPermisosLetradoSincrono(listaIds);
            } else {
                ejecutarPermisosLetradoAsincrono(listaIds);
            }
        }

        /*****************************************************************
        * Proposito: en caso de venir de un contexto future para evitar errores de colisiones el future se deberá
        * ejecutar de manera síncrona
        * 
        * Historial
        * -------
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0            US749927         Alexandre Perez   9/11/2023     Creación
        *****************************************************************/
        public static void ejecutarPermisosLetradoSincrono(List<Id> listaIds){
            contextoPermisosLetrado(listaIds);
        }

        /*****************************************************************
        * Proposito: en caso de venir de un contexto normal, se debe ejecutar en asíncrono
        * 
        * Historial
        * -------
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0            N/A              Alexandre Perez   9/11/2023     Creación
        *****************************************************************/
        @future
        public static void ejecutarPermisosLetradoAsincrono(List<Id> listaIds){
            contextoPermisosLetrado(listaIds);
        }
    
        //@future
        // public static void permisosLetrado(List<Id> listaIdsReclamaciones) {
        public static void contextoPermisosLetrado(List<Id> listaIdsReclamaciones) {
            //Buscar las pretensiones hijas de las reclamaciones
            List<Case> listaPretensiones = [SELECT Id, SAC_Reclamacion__c, OwnerId FROM Case WHERE RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c = :listaIdsReclamaciones];
    
            if (!listaPretensiones.isEmpty()) {
                Map<Id, Set<Id>> mapaRecPretOwner = new Map<Id, Set<Id>>();
                for (Case caso : listaPretensiones) {
                    if (mapaRecPretOwner.containsKey(caso.SAC_Reclamacion__c)) {
                        mapaRecPretOwner.get(caso.SAC_Reclamacion__c).add(caso.Id);
                    } else {
                        Set<Id> listaIdsOwners = new Set<Id>();
                        listaIdsOwners.add(caso.OwnerId);
                        mapaRecPretOwner.put(caso.SAC_Reclamacion__c, listaIdsOwners);
                    }
                }
    
                //Recorrer mapa y poner permisos a las reclamaciones con los letrados de sus pretensiones hijas
                List<CaseShare> listaCaseShareNuevos = new List<CaseShare>();
                for (Id idReclamacion : mapaRecPretOwner.keySet()) {
                    for (Id idOwner : mapaRecPretOwner.get(idReclamacion)) {
                        CaseShare csNuevo = new CaseShare();
                        csNuevo.CaseId = idReclamacion;
                        csNuevo.UserOrGroupId = idOwner;
                        csNuevo.CaseAccessLevel='Edit';
                        listaCaseShareNuevos.add(csNuevo);
                    }
                }
    
                //Insertar los permisos omitiendo los repetidos
                SAC_DatabaseDML.insertListDML(listaCaseShareNuevos, false);
                //Database.insert(listaCaseShareNuevos, false);
            }
        }
    
        /*****************************************************************
         * Proposito: Añade permisos para que el gestor de la reclamación pueda modificar
         * las pretensiones hijas. Se ejecuta cuando se pasa la reclamación a análisis y se
         * efectúa el balanceo
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            N/A              Carlos Solis  27/04/2022    Creación
         *****************************************************************/
        @future
        public static void permisosGestor(Set<Id> setIdsReclamaciones) {
            List<Case> listaCasos = [SELECT Id, RecordTypeId, OwnerId, SAC_Reclamacion__c FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPEPRETENSION)
                                    AND (
                                        (RecordTypeId = :RECTYPERECLAMACION AND ID IN :setIdsReclamaciones)
                                        OR (RecordTypeId = :RECTYPEPRETENSION AND SAC_Reclamacion__c IN :setIdsReclamaciones)
                                    )];
            
            Map<Id, List<Case>> mapaRecPretensiones = new Map<Id, List<Case>>();
            Map<Id, Case> mapaReclamaciones = new Map<Id, Case>();
            for (Case caso : listaCasos) {
                if (caso.RecordTypeId == RECTYPERECLAMACION) {
                    mapaRecPretensiones.put(caso.Id, new List<Case>());
                    mapaReclamaciones.put(caso.Id, caso);
                }
            }
    
            for (Case caso : listaCasos) {
                if (caso.RecordTypeId == RECTYPEPRETENSION && mapaRecPretensiones.containsKey(caso.SAC_Reclamacion__c)) {
                    mapaRecPretensiones.get(caso.SAC_Reclamacion__c).add(caso);
                }
            }
    
            List<CaseShare> listaCSNuevos = new List<CaseShare>();
            for (Id idReclamacion : mapaRecPretensiones.keySet()) {
                for (Case pretension : mapaRecPretensiones.get(idReclamacion)) {
                    if (mapaReclamaciones.containsKey(idReclamacion)) {
                        CaseShare csNuevo = new CaseShare();
                        csNuevo.CaseId = pretension.Id;
                        csNuevo.UserOrGroupId = mapaReclamaciones.get(idReclamacion).OwnerId;
                        csNuevo.CaseAccessLevel='Edit';
                        listaCSNuevos.add(csNuevo);
                    }
                }
            }
    
            if (!listaCSNuevos.isEmpty()) {
                SAC_DatabaseDML.insertListDML(listaCSNuevos, false);
                //Database.insert(listaCSNuevos, false);
            }
        }


         /*****************************************************************
        * Proposito: dependiendo de en que contexto esté la ejecución actual
        * decide si lanzarlo como future
        * 
        * Historial
        * -------
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0            US866223         Alexandre Perez   09/04/2024   Creación
        *****************************************************************/
        public static void fechaAsignacionTMO(Datetime fechaAsignacion, list<Id> caseId){
            //mirar si estoy en contexto asíncrono para evitar errores
            if(System.isFuture() || System.isBatch() || System.isScheduled()) {
                fechaAsignacionTMOSincrono(fechaAsignacion, caseId);
            } else {
                fechaAsignacionTMOAsincrono(fechaAsignacion, caseId);
            }
        }

         /*****************************************************************
        * Proposito: en caso de venir de un contexto future para evitar errores de colisiones el future se deberá
        * ejecutar de manera síncrona
        * 
        * Historial
        * -------
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0            US866223         Alexandre Perez   09/04/2024     Creación
        *****************************************************************/
        public static void fechaAsignacionTMOSincrono(Datetime fechaAsignacion, list<Id> caseId){
            logicaFechaAsignacionTMO(fechaAsignacion, caseId);
        }

        /*****************************************************************
        * Proposito: en caso de venir de un contexto normal, se debe ejecutar en asíncrono
        * 
        * Historial
        * -------
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0            US866223         Alexandre Perez   09/04/2024     Creación
        *****************************************************************/
        @future
        public static void fechaAsignacionTMOAsincrono(Datetime fechaAsignacion, list<Id> caseId){
            logicaFechaAsignacionTMO(fechaAsignacion, caseId);
        }

        /*****************************************************************
         * Proposito: Lógica que modifica el campo de fecha asignación a nivel de tiempo estados que 
         * cuelga del TMO de alta del caso
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            US866223         Alex Pérez     03/04/2024   Creación
         *****************************************************************/
        public static void logicaFechaAsignacionTMO(Datetime fechaAsignacion, list<Id> caseId){
            try {
                map<Id, Id> mapTmecaso = new map<Id, Id>();
                map<Id, SAC_TiempoEstados__c> mapTe = new map<Id, SAC_TiempoEstados__c>();
                List<SAC_TMECaso__c> ltme = [SELECT Id, SAC_Caso__c FROM SAC_TMECaso__c WHERE SAC_Caso__c = :caseId and name = 'TMO Alta' WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];
                for(SAC_TMECaso__c tme : ltme){
                    mapTmecaso.put(tme.SAC_Caso__c, tme.Id);
                }

                if(!mapTmecaso.isEmpty()){
                    list<SAC_TiempoEstados__c> teList = [SELECT Id, SAC_FechaAsignacion__c, SAC_TMECaso__c FROM SAC_TiempoEstados__c WHERE SAC_TMECaso__c = : mapTmecaso.values()  WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];

                    for(SAC_TiempoEstados__c te : teList){
                        te.SAC_FechaAsignacion__c = fechaAsignacion;
                        mapTe.put(te.SAC_TMECaso__c, te);
                    }
    
                    Database.SaveResult[] srList;
                    boolean hasError = false;
                    List<Object> errorObjs = new List<Object>();
                    Map<String, String> errorMsjs = new Map<String, String>();
    
                    srList = Database.update(mapTe.values(), false);
                    for (Integer i = 0; i < mapTe.values().size(); i++) {
                        Database.SaveResult sr = srList[i];
                        if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                            errorMsjs.put(sr.getErrors()[0].getStatusCode() + '', ((String)sr.getErrors()[0].getMessage()));
                            errorObjs.add(mapTe.values().get(0));
                            hasError = true;
                        }
                    }
    
                    if(hasError) {
                        CBK_Log.error(errorMsjs, errorObjs);
                    }         
                }    
            } catch (Exception e) {
                CBK_Log.error(e);
            }
        }
        /*****************************************************************
        * @description	calculo milisegundos
        * Método adicional para milisegundos de los días recibidos por parámetro
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0            US967476         Borja Lavesiera   05/08/2024   Creación
        *****************************************************************/
        public static void changeOwnerPretensionesHijas(list<Id> reclaCaseIds, Set<Id> reclaOwnerId){
            //mirar si estoy en contexto asíncrono para evitar errores
            if(System.isFuture() || System.isBatch() || System.isScheduled()) {
                changeOwnerPretensHijasSincrono(reclaCaseIds, reclaOwnerId);
            } else {
                changeOwnerPretensHijasAsincrono(reclaCaseIds, reclaOwnerId);
            }
        }

         /*****************************************************************
        * @description en caso de venir de un contexto future para evitar errores de colisiones el future se deberá
        * ejecutar de manera síncrona
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0            US967476         Borja Lavesiera   05/08/2024   Creación
        *****************************************************************/
        public static void changeOwnerPretensHijasSincrono(list<Id> reclaCaseIds, Set<Id> reclaOwnerId){
            logicaChangeOwnerPretensHijas(reclaCaseIds, reclaOwnerId);
        }

        /*****************************************************************
        * @description en caso de venir de un contexto normal, se debe ejecutar en asíncrono
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0            US967476         Borja Lavesiera   05/08/2024   Creación
        *****************************************************************/
        @future
        public static void changeOwnerPretensHijasAsincrono(list<Id> reclaCaseIds, Set<Id> reclaOwnerId){
            logicaChangeOwnerPretensHijas(reclaCaseIds, reclaOwnerId);
        }
         /*****************************************************************
         * @description Lógica que modifica el owner de las pretensiones en el alta 
         * cuando cambia el owner de la reclamación a un usuario no a una cola
         * VERSION        USER_STORY       AUTHOR             DATE         Description
         * 1.0            US967476         Borja Lavesiera    05/08/2024   Creación
         *****************************************************************/
        public static void logicaChangeOwnerPretensHijas(list<Id> reclaCaseIds, Set<Id> reclaOwnerId){
            try {
                
                Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

                List<Case> childPretensiones = [SELECT Id, ParentId, RecordTypeId, OwnerId 
                                 FROM Case 
                                 WHERE SAC_Reclamacion__c IN :reclaCaseIds 
                                 AND RecordTypeId = :recTypePretension
                                 AND Status = 'SAC_001' WITH SECURITY_ENFORCED];
                // Mapa para almacenar los casos que necesitan actualización
                
                map<Id, Case> mapCasesToUpdate = new map<Id, Case>();

                for (Case pretensionUpdate : childPretensiones) {
                    for (Id ownerId : reclaOwnerId) {
                        if (pretensionUpdate.OwnerId != ownerId) {
                            pretensionUpdate.OwnerId = ownerId;
                            mapCasesToUpdate.put(pretensionUpdate.Id, pretensionUpdate);
                        }
                    }
                }
                // Actualizamos las pretensiones hijas
                if (!mapCasesToUpdate.isEmpty()) {
                    Database.SaveResult[] srList;
                    boolean hasError = false;
                    List<Object> errorObjs = new List<Object>();
                    Map<String, String> errorMsjs = new Map<String, String>();
    
                    srList = Database.update(mapCasesToUpdate.values(), false);
                    for (Integer i = 0; i < mapCasesToUpdate.values().size(); i++) {
                        Database.SaveResult sr = srList[i];
                        if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                            errorMsjs.put(sr.getErrors()[0].getStatusCode() + '', ((String)sr.getErrors()[0].getMessage()));
                            errorObjs.add(mapCasesToUpdate.values().get(0));
                            hasError = true;
                        }
                    }

                    if(hasError) {
                        CBK_Log.error(errorMsjs, errorObjs);
                    }  
                } 
  
            } catch (Exception e) {
                CBK_Log.error(e);
            }
        }

        /*****************************************************************
        * @description envío del acuse de recibo via carta postal, creación del content version y actualización de la carta
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0             US994116      Raúl Santos       12/09/24        Creación
        *****************************************************************/
        @future(callout=true)
        public static void generarCartaPostal(String idCarta, String idCaso){

            Case caso = [SELECT Id, CaseNumber FROM Case WHERE Id = :idCaso LIMIT 1];

            String vfHostname = DomainCreator.getVisualforceHostname(null);
            String urlVF = 'https://' + vfHostname + '/apex/SAC_CartaPDF?id=' + idCarta;

            PageReference pageRef = new PageReference(urlVF);
            Blob body;

            if(Test.isRunningTest()){
                body = blob.valueOf('Unit.Test');
            }
            else{              
                body = pageRef.getContentAsPDF();                
            }
            
            ContentVersion cv = new ContentVersion(
                Title= caso.CaseNumber + ' Carta postal Acuse Recibo', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = body,
                FirstPublishLocationId = caso.Id,
                SAC_StringRedaccion_fileupload__c = 'carta postal acuse recibo',
                SAC_Bloque__c = 'SAC_Tramitacion'
            );
            SAC_DatabaseDML.insertDML(cv, true);
        
            ContentVersion content = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId =: caso.Id AND SAC_StringRedaccion_fileupload__c =: 'carta postal acuse recibo' ORDER BY CreatedDate DESC LIMIT 1];
            SAC_DocumentoEnvio__c carta = [SELECT id FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c = :caso.Id AND SAC_Documento__c = null AND Id = :idCarta LIMIT 1];
    
            carta.SAC_Version__c = content.Id;
            carta.SAC_Documento__c = content.ContentDocumentId;
            carta.SAC_URL__c = urlVF;
    
            SAC_DatabaseDML.updateDML(carta, true);

            caso.CC_AcuseRecibo__c = '2';
            SAC_DatabaseDML.updateDML(caso, true);

        }

        /*****************************************************************
        * @description Procesar la consulta SAC que se ha cambiado el grupo letrado
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0             US683740      Raúl Santos    09/01/25        Creación
        *****************************************************************/
        public static void eliminarPermisosOwnerLetrado(Set<Id> setIdConsultaSAC, Map<Id, Case> mapOldCase){

            List<Case> listConsultasSAC = [SELECT SAC_Letrado__c FROM Case WHERE RecordTypeId = :RECTYPECONSAC AND Id IN :setIdConsultaSAC];

            Set<String> nameUserLetrado = new Set<String>();
            if(!listConsultasSAC.isEmpty()){
                for(Case caso : listConsultasSAC){
                    if(mapOldCase.get(caso.Id).SAC_Letrado__c != 'Pte. Asignar'){
                        nameUserLetrado.add(mapOldCase.get(caso.Id).SAC_Letrado__c);
                    }
                }
            }

            if(!nameUserLetrado.isEmpty()){
                eliminarCaseShareConsulta(setIdConsultaSAC, nameUserLetrado);
            }            
        }

        /*****************************************************************
        * @description Eliminar los permisos de edicción del owner letrado sobre la consulta SAC
        * VERSION        USER_STORY       AUTHOR            DATE         Description
        * 1.0             US683740      Raúl Santos    09/01/25        Creación
        *****************************************************************/
        @future
        public static void eliminarCaseShareConsulta(Set<Id> setIdConsultaSAC, Set<String> nombreUsuario){

            //Quitar permisos sobre el registro al propietario letrado
            List<User> usuarios = [SELECT Id FROM User WHERE Name IN :nombreUsuario];

            if(!usuarios.isEmpty()){
                List<CaseShare> eliminarCS = [SELECT Id FROM CaseShare WHERE CaseId IN :setIdConsultaSAC AND UserOrGroupId IN :usuarios];
            
                if(Schema.sObjectType.Case.isUpdateable() && !eliminarCS.isEmpty()){  
                    SAC_DatabaseDML.deleteListDML(eliminarCS, true); 
                }else{
                    throw new AuraHandledException('No tienes permisos');
                }
            }
        }
    }