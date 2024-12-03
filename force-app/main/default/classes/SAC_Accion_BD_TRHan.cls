public with sharing class SAC_Accion_BD_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Accion__c>)tp.oldList, (Map<Id, SAC_Accion__c>)tp.oldMap);
    }
    private void process(List<SAC_Accion__c> listOldObj, Map<Id, SAC_Accion__c> mapOldObj) {
        preventTareaDeletion(listOldObj);
    }
    public static void preventTareaDeletion(List<SAC_Accion__c> oldList) {
        // Check permission set
        Boolean hasPermissionSet = false;
        List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'SAC_SystemAdmin' LIMIT 1];
        if(!psa.isEmpty()){
            hasPermissionSet = true;
        }
        // Prevent deletion
        for(SAC_Accion__c tarea: oldList){
            if(!hasPermissionSet){
                tarea.addError('No se puede eliminar la tarea.');
            }
        }
    }
}