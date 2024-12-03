public with sharing class SAC_ContentDocumentLink_BD_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<ContentDocumentLink>)tp.oldList, (Map<Id, ContentDocumentLink>)tp.oldMap);
    }
    private void process(List<ContentDocumentLink> oldList, Map<Id, ContentDocumentLink> mapOldObj){
        preventDocumentDeletion(oldList);
    }
    
    public static void preventDocumentDeletion(List<ContentDocumentLink> oldList){
        String userProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId() LIMIT 1][0].Name;
        if(userProfileName.contains('SAC_General')){
            List<ContentDocumentLink> linksToDelete = new List<ContentDocumentLink>();
            // Check permission set
            Boolean hasPermissionSet = false;
            List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'SAC_SystemAdmin' LIMIT 1];
            if(!psa.isEmpty()){
                hasPermissionSet = true;
            }
            // Get ContentDocumentLink
            for(ContentDocumentLink cdl : oldList) {
                if(cdl.LinkedEntityId != null && String.valueOf(cdl.LinkedEntityId).startsWith('02s')) {
                    linksToDelete.add(cdl);
                }
            }
            // Get EmailMessage
            if(!linksToDelete.isEmpty()){
                Set<Id> emailMessageIds = new Set<Id>();
                for (ContentDocumentLink cdl : linksToDelete){
                    emailMessageIds.add(cdl.LinkedEntityId);
                }
                // Prevent deletion
                Map<Id, EmailMessage> emailMessagesMap = new Map<Id, EmailMessage>([SELECT Id, Status FROM EmailMessage WHERE Id IN :emailMessageIds]);
                for(ContentDocumentLink cdl : oldList){
                    EmailMessage emailMsg = emailMessagesMap.get(cdl.LinkedEntityId);
                    if(emailMsg != null && emailMsg.Status == '3' && !hasPermissionSet) {
                        cdl.addError('No se pueden eliminar adjuntos de correos que ya han sido enviados.');
                    }
                }
            }
        }
    }
}