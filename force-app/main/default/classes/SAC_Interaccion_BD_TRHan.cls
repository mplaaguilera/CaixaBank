public with sharing class SAC_Interaccion_BD_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Interaccion__c>)tp.oldList, (Map<Id, SAC_Interaccion__c>)tp.oldMap);
    }
    private void process(List<SAC_Interaccion__c> oldList, Map<Id, SAC_Interaccion__c> mapOldObj){
        preventConsultaDeletion(oldList);
    }
    public static void preventConsultaDeletion(List<SAC_Interaccion__c> oldList) {
        // Check permission set
        Boolean hasPermissionSet = false;
        List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'SAC_SystemAdmin' LIMIT 1];
        if(!psa.isEmpty()){
            hasPermissionSet = true;
        } 
        // Prevent deletion
        for(SAC_Interaccion__c consulta: oldList){
            if(!hasPermissionSet){
                consulta.addError('No se puede eliminar la consulta.');
            }
        }
    }
}