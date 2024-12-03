public with sharing class SAC_EmailMessage_BD_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<EmailMessage>)tp.oldList, (Map<Id, EmailMessage>)tp.oldMap);
    }
    private void process(List<EmailMessage> oldList, Map<Id, EmailMessage> mapOldObj){
        preventEmailDeletion(oldList);
    }
    public static void preventEmailDeletion(List<EmailMessage> oldList) {
        // Check permission set
        Boolean hasPermissionSet = false;
        List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'SAC_SystemAdmin' LIMIT 1];
        if(!psa.isEmpty()){
            hasPermissionSet = true;
        }        
        // Prevent deletion
        for(EmailMessage email: oldList){
            if(!hasPermissionSet){
                email.addError('No se puede eliminar el email.');
            }
        }
    }
}