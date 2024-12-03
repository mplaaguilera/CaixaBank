public with sharing class SAC_ContentDocument_BD_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<ContentDocument>)tp.oldList, (Map<Id, ContentDocument>)tp.oldMap);
    }
    private void process(List<ContentDocument> oldList, Map<Id, ContentDocument> mapOldObj){
        preventDocumentDeletion(oldList);
    }
    
    public static void preventDocumentDeletion(List<ContentDocument> oldList){
        String userProfileName = [SELECT Id, Name FROM Profile WHERE Id =: userInfo.getProfileId() LIMIT 1][0].Name;
        if(userProfileName.contains('SAC_General')){
            // Check permission set
            Boolean hasPermissionSet = false;
            List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = 'SAC_SystemAdmin' LIMIT 1];
            if(!psa.isEmpty()){
                hasPermissionSet = true;
            }
            // Get ContentDocument
            Set<Id> contentDocumentIds = new Set<Id>();
            for(ContentDocument cd : oldList){
                contentDocumentIds.add(cd.Id);
            }
            // Note: querying LinkedEntityId IN: (SELECT Id FROM EmailMessage WHERE Status = '3') is not working. 
            // Workaround: several steps
            List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId, LinkedEntityId, LinkedEntity.Type 
                                                              FROM ContentDocumentLink 
                                                              WHERE ContentDocumentId IN :contentDocumentIds 
                                                             ];
            // Get EmailMessage
            List<String> linkedEmailMessageIds = new List<String>();
            for(ContentDocumentLink cdl: contentDocumentLinks){
                if(cdl.LinkedEntity.Type == 'EmailMessage'){
                    linkedEmailMessageIds.add(cdl.LinkedEntityId);
                }            
            }
            // Check EmailMessage Status
            List<String> sentEmailIds = new List<String>();
            for(EmailMessage email: [SELECT Id FROM EmailMessage WHERE Id IN: linkedEmailMessageIds AND Status = '3']){
                sentEmailIds.add(email.Id);
            }
            // Get ContentDocumentLink from Sent Emails
            List<ContentDocumentLink> contentDocumentLinksFromSentEmails = [SELECT ContentDocumentId, LinkedEntityId, LinkedEntity.Type 
                                                                            FROM ContentDocumentLink 
                                                                            WHERE ContentDocumentId IN :contentDocumentIds 
                                                                            AND LinkedEntityId IN: sentEmailIds
                                                                           ];
            // Get ContentDocument from Sent EmailMessage
            Set<Id> restrictedDocumentIds = new Set<Id>();
            for(ContentDocumentLink cdl :contentDocumentLinksFromSentEmails){
                restrictedDocumentIds.add(cdl.ContentDocumentId);
            }
            // Prevent deletion
            for(ContentDocument cd : oldList){
                if(restrictedDocumentIds.contains(cd.Id) && !hasPermissionSet){
                    cd.addError('No se pueden eliminar adjuntos vinculados a correos que ya han sido enviados.');
                }
            }
        }
    }
}