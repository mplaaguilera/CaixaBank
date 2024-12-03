public without sharing class SAC_UpdateEstadosPretensiones { 
    /*****************************************************************
 * Name: SAC_UpdateEstadosPretensiones
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Cambios automáticos de estados de pretensiones
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219266         Luis Mesa      17/05/21     Creación
 * 2.0             ---             Marcela Neira  28/09/21     Modificación
 *                                 Esteve Llao
*****************************************************************/

    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
    
    /*****************************************************************
     * Proposito: Método para updatear las pretensiones en la BBDD
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219266         Luis Mesa      17/05/21     Creación
    *****************************************************************/
    public static void actualizarEStados(List<Case> listaCasosSelect, List<Case> listaReclaCambiarEstado, Map<Id,Case> mapaDatosCasosActualizar){
        Map<Id,List<Case>> mapaPretensiones = new Map<Id,List<Case>>(); 
        List<case> listaCasos2 = new List<case>();
        List<Case> pretensionesReclamacion = new List<Case>();
        String idReclaPrincipal;

        for (Case caso: listaReclaCambiarEstado) {
            list<case> listaAux = new list<case>();
            mapaPretensiones.put(caso.id, listaAux ); 
            idReclaPrincipal = caso.SAC_PretensionPrincipal__c;   
        }
        for (Case caso : listaCasosSelect) {  
            if(mapaPretensiones.containsKey(caso.SAC_Reclamacion__c) && caso.RecordTypeId == RECTYPEPRETENSION  && 
                caso.Status != 'SAC_009'  && (caso.SAC_SentidoResolucion__c != 'SAC_004' || (caso.SAC_SentidoResolucion__c == 'SAC_004' && caso.SAC_Reclamacion__r.Status == 'SAC_006'))){ //Que no incluya las pretensiones en Baja ni en Inadmisión (Excepto si se pasa a subsanacion)
                mapaPretensiones.get(caso.SAC_Reclamacion__c).add(caso);
            } else if(mapaPretensiones.containsKey(caso.SAC_Reclamacion__c) && caso.RecordTypeId == RECTYPEPRETENSION && caso.Status == 'SAC_009' && caso.id != idReclaPrincipal && caso.SAC_EsPrincipal__c == true) { //Que en caso de no ser la pretensión principal y tenga el campo SAC_EsPrincipal__c a true ponga el valor en false
                caso.SAC_EsPrincipal__c = false;
                mapaDatosCasosActualizar.put(caso.id, caso);
            }        
        }      

        for( ID ide : mapaPretensiones.keySet()){ 
            pretensionesReclamacion.addAll(mapaPretensiones.get(ide) );         
        }

        if(!pretensionesReclamacion.isEmpty()){
            comprobarEstados(pretensionesReclamacion, mapaDatosCasosActualizar);
        }
    }

    public static void comprobarEstados(List<Case> pretensionesReclamacion,  Map<Id,Case> mapaDatosCasosActualizar){
        /*****************************************************************
         * Proposito: Método para updatear las pretensiones en la BBDD
         * 1.1 : Modificado para que cuando se pase a análisis una reclamación la pretensión principal marque el check de SAC_EsPrincipal__c
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR             DATE         Description
         * 1.0            US219266         Luis Mesa        17/05/21        Creación
         * 1.1            US574649         Sergio Martín    02/05/23       Modificación
        *****************************************************************/
        for(Case pretensionSinActualizar : pretensionesReclamacion){
            if((pretensionSinActualizar.Status == 'SAC_003' || pretensionSinActualizar.Status == 'SAC_004') &&
            pretensionSinActualizar.SAC_Reclamacion__r.Status == 'SAC_001'){
                throw new AuraHandledException( 'Revisa el estado de las pretensiones antes de cambiar el estado de la reclamación.' );
            }
            
            if((pretensionSinActualizar.SAC_Reclamacion__r.Status == 'SAC_006' && pretensionSinActualizar.Status == 'SAC_002') ||
            (pretensionSinActualizar.SAC_Reclamacion__r.Status == 'SAC_001' && pretensionSinActualizar.Status == 'SAC_002') ||
            (pretensionSinActualizar.SAC_Reclamacion__r.Status == 'SAC_002' && pretensionSinActualizar.status != 'SAC_006') ||
            pretensionSinActualizar.SAC_Reclamacion__r.Status == 'SAC_005' || pretensionSinActualizar.Status == 'SAC_006'  ||
            (pretensionSinActualizar.SAC_Reclamacion__r.Status == 'SAC_006' && pretensionSinActualizar.Status == 'SAC_001') ||
            (pretensionSinActualizar.SAC_Reclamacion__r.Status != 'SAC_005' && pretensionSinActualizar.Status == 'SAC_005') ){

                if(pretensionSinActualizar.SAC_Reclamacion__r.Status == 'SAC_002' && pretensionSinActualizar.status == 'SAC_001' && pretensionSinActualizar.SAC_Reclamacion__r.SAC_PretensionPrincipal__c == pretensionSinActualizar.id) {
                    pretensionSinActualizar.SAC_EsPrincipal__c = true;  
                }

                pretensionSinActualizar.Status = pretensionSinActualizar.SAC_Reclamacion__r.Status;
                pretensionSinActualizar.SAC_StatusAuxiliar__c = pretensionSinActualizar.SAC_Reclamacion__r.Status;
            }
            if(pretensionSinActualizar.SAC_Reclamacion__r.Status == 'SAC_005'){
                pretensionSinActualizar.SAC_MotivoInadmision__c = pretensionSinActualizar.SAC_Reclamacion__r.SAC_MotivoInadmision__c;
                pretensionSinActualizar.SAC_SentidoResolucion__c = pretensionSinActualizar.SAC_Reclamacion__r.SAC_SentidoResolucion__c;
            }
        }

        for (Case caso : pretensionesReclamacion) {
            if(mapaDatosCasosActualizar.containsKey(caso.id)){
                mapaDatosCasosActualizar.get(caso.id).Status = caso.Status;
                mapaDatosCasosActualizar.get(caso.id).SAC_StatusAuxiliar__c = caso.Status;
            }else if (!mapaDatosCasosActualizar.containsKey(caso.id)){
                mapaDatosCasosActualizar.put(caso.id, caso);
            }
        }
    }
}