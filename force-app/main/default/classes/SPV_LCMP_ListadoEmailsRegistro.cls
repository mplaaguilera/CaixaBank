public with sharing class SPV_LCMP_ListadoEmailsRegistro {
   
    @AuraEnabled(cacheable=true)
    public static List<EmailMessage> getEmails(Id recordId) {

        return [SELECT Id, Subject ,relatedToId, CreatedDate, FromAddress, ToAddress FROM EmailMessage WHERE relatedToId =: recordId ORDER BY CreatedDate DESC];
    }
}