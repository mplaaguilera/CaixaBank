public with sharing class CIBE_CallReportPDFController {
    
    @AuraEnabled
    public static void saveFileContent(String recordId, String content, String fileName) {
        if(String.isNotBlank(recordId) && String.isNotBlank(content)) {
            List<Event> events = new List<Event>();
            if(Event.SObjectType.getDescribe().isAccessible()) {
                events = [SELECT Id, StartDateTime FROM Event WHERE Id = :recordId];
            }
            
            if(!events.isEmpty()) {
                DateTime now = events.get(0).StartDateTime != null ? events.get(0).StartDateTime : System.now();
                String title = fileName + ' ' + now.day() + '-' + now.month() + '-' + now.year();
                ContentVersion objCV = new ContentVersion(
                    Title = title,
                    PathOnClient = title + '.pdf',
                    VersionData = EncodingUtil.base64Decode(content),
                    IsMajorVersion = true,
                    ContentLocation = 'S'
                );
                insert objCV;
                
                objCV = [
                    SELECT ContentDocumentId
                    FROM ContentVersion
                    WHERE Id =: objCV.Id
                ];
    
                ContentDocumentLink objCDL = new ContentDocumentLink(
                    ContentDocumentId = objCV.ContentDocumentId,
                    LinkedEntityId = recordId,
                    Visibility = 'AllUsers'
                );
                insert objCDL;
            }
        }
    }

}