public with sharing class CC_Conversacion_IA_Controller {

	@AuraEnabled(cacheable=true)
    public static String getRTCase(Id recordId) {
        Case caso = [SELECT RecordType.Name FROM Case WHERE Id = :recordId LIMIT 1];
        return caso.RecordType.Name;
    }

    @AuraEnabled
    public static void updateValoracionAI(Id recordId, String str) {
        Case caso = [SELECT Id FROM Case WHERE Id = :recordId LIMIT 1];
        caso.CC_Valoracion_AI__c = str;
        update caso;
    }
}