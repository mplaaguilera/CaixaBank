public without sharing class SAC_HandlerWithoutSharingMethods {
/*****************************************************************
 * Name: SAC_Balanceo
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Crear clase without sharing para poder ejecutar acciones que normalmente los usuarios no tienen permisos
 * 
 * Este clase se cubre con los siguientes test:
 * SAC_LCMP_BusquedaSecundaria_Test
 * creada clase SAC_HandlerWithoutSharingMethodsTest específica
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US277126         Luis Mesa      10/11/21     Creación
*****************************************************************/
    
    @AuraEnabled
    public static void actualizarReclamanteNoClienteWithoutSharing(String caseId, String accountId){
        try{
            List<SAC_CaseReclamante__c> reclamantes = new List<SAC_CaseReclamante__c>();
            Case casoActual;
            Account cuentaActual;
            Contact contactActual;

            if(caseId != null) {
                casoActual = [SELECT Id, AccountId FROM Case WHERE id =: caseId LIMIT 1];
                reclamantes = [SELECT Id FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: caseId];
            }
            if(accountId != null && accountId != '') {
                cuentaActual = [SELECT Id, CC_Email__c, Name FROM Account WHERE Id =: accountId LIMIT 1];
                contactActual = [SELECT Id FROM Contact WHERE AccountId =: accountId LIMIT 1];
            } 
            
            if(reclamantes.isEmpty()){
                //system.debug('id caso ' + caseId);
                casoActual.AccountId = cuentaActual.Id;
                casoActual.ContactId = contactActual.Id;
                update casoActual;
                //system.debug('caso despues update ' + casoActual);
            }
            else{
                SAC_LCMP_BusquedaCliente.crearReclamanteSecundario(accountId, accountId, caseId);
            }
        }
        catch (Exception e) {
            CBK_Log.error(e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static List<List<SObject>> queryBusquedaClienteLocal(String sBusqueda, String sCuentaRecordType) {
        List<List<SObject>> searchList = [FIND : sBusqueda IN ALL FIELDS 
                                                RETURNING 
                                                Account (Id, Name WHERE (CC_NumPerso__c <> null OR RecordTypeId=:sCuentaRecordType))
                                                LIMIT 25];

        return searchList;
    }

    public static String queryRepresentantesOrContactosCliente(String sCliente) {
        String sTipoPersona = [SELECT CC_TipoPersona__c FROM Account WHERE Id = :sCliente].CC_TipoPersona__c;

        return sTipoPersona;
    }

    /*****************************************************************
     * Proposito: Recupera las colas SAC_PendienteAsignar y SAC_PteSupervisor de la memoria del caché.
     * Si no se encuentran en el caché, hace la query a la base de datos para recuperarlas y seguidamente las inserta
     * en el caché, para que durante el resto de ejecución, siempre que se llame a este método, las recupere del caché
     * sin necesidad de repetir DML.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0            --               Carlos Solis     10/11/22     Creación
     * 1.1            US866223         Alexandre Perez  02/04/2024   añadir cola Pdte.IA
    *****************************************************************/
    public static List<Group> recuperarColasSAC() {
        List<Group> listaColas = new List<Group>();
		if (Cache.Org.contains('local.SAC.ColaSACPendienteAsignar') && Cache.Org.contains('local.SAC.ColaSACPteSupervisor') 
        && Cache.Org.contains('local.SAC.ColaSACPdteIA')) {
            /*Group colaPendienteAsignar = (Group)Cache.Org.get('local.SAC.ColaSACPendienteAsignar');
            Group colaPendienteSupervisores = (Group)Cache.Org.get('local.SAC.ColaSACPteSupervisor');
            listaColas.add(colaPendienteAsignar);
            listaColas.add(colaPendienteSupervisores);*/
            listaColas.add((group)Cache.Org.get('local.SAC.ColaSACPendienteAsignar'));
            listaColas.add((group)Cache.Org.get('local.SAC.ColaSACPteSupervisor'));
            listaColas.add((group)Cache.Org.get('local.SAC.ColaSACPdteIA'));
            //System.debug('lista de colas leídas del caché : '+listaColas);
        }
        else{

            listaColas = [SELECT Id, DeveloperName, Name FROM Group WHERE Type = 'Queue' AND 
                            (DeveloperName = 'SAC_PendienteAsignar' OR DeveloperName = 'SAC_PteSupervisor'
                            OR DeveloperName = 'SAC_GenialPdteIA')];

            //System.debug('van a cargarse las colas ----> '+listaColas);
            for (Group grupoAux : listaColas) {
                if(grupoAux.DeveloperName == 'SAC_PendienteAsignar'){
                    Cache.Org.put('local.SAC.ColaSACPendienteAsignar', grupoAux, 300);
                    //System.debug('cargamos cola : '+grupoAux);
                }else if(grupoAux.DeveloperName == 'SAC_PteSupervisor'){
                    Cache.Org.put('local.SAC.ColaSACPteSupervisor', grupoAux, 300);
                    //System.debug('cargamos cola : '+grupoAux);
                }else if(grupoAux.DeveloperName == 'SAC_GenialPdteIA'){
                    Cache.Org.put('local.SAC.ColaSACPdteIA', grupoAux, 300);
                }
            }
        }
        return listaColas;
    }
}