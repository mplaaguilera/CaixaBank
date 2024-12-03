public without sharing class SPV_HandlerWithoutSharingMethods {

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
                casoActual.AccountId = cuentaActual.Id;
                casoActual.ContactId = contactActual.Id;
                update casoActual;
            }
            else{
                SPV_LCMP_BusquedaCliente.crearReclamanteSecundario(accountId, accountId, caseId);
            }
        }
        catch (Exception e) {CBK_Log.error(e);throw new AuraHandledException(e.getMessage());}
    }

    public static void insertarAccionShare(SAC_Accion__c tarea) {
        List<SAC_Accion__Share> accionesShare = new List<SAC_Accion__Share>();
                    accionesShare.add(new SAC_Accion__Share(
                            ParentId = tarea.Id,
                            UserOrGroupId = userInfo.getUserId(),
                            AccessLevel = 'Edit'
                        ));
        Database.insert(accionesShare);
    }

}