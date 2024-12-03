public with sharing class CIBE_PDFViewerController {

    @AuraEnabled
    public static String getPDFContent(String recordId, String visualforceName, Boolean hasRecordId) {
        if(String.isNotBlank(visualforceName)) {
            List<Event> events = new List<Event>();
            try {
                PageReference pageRef = new PageReference('/apex/' + visualforceName);

                if(hasRecordId && String.isNotBlank(recordId)) {
                    pageRef.getParameters().put('recordId', recordId);
                }

                return EncodingUtil.base64Encode(pageRef.getContent());
            } catch(Exception e) {
                throw new VisualforceException('There was a problem generating the pdf document: ' + e.getMessage());
            }
        }

        throw new IllegalArgumentException('El recordId informado es ' + recordId + ' y el visualforceName es ' + visualforceName);
    }

    public class VisualforceException extends Exception {}

}