public without sharing class SAC_refreshView {
    
    @AuraEnabled
    static public Case recuperarCaso(Id caseId){
        Case caseSR = new Case();

        caseSR = [SELECT id, Status, LastModifiedDate
        FROM Case WHERE id = :caseId LIMIT 1];

        return caseSR; 
    }

}