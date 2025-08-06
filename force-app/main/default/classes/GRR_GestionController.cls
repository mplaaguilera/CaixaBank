public with sharing class GRR_GestionController {
     @AuraEnabled(cacheable=true)
    public static List<GRR_Gestion__c> getGestionesByCaseId(Id caseId, String recordType) {
        return [
            SELECT GRR_Interviniente__c,Id, GRR_Numero_Contrato__c, GRR_Fecha_Antiguedad_Deuda__c,GRR_Tipo_Producto__c,GRR_Numero_Producto__c,GRR_Cirbe_Externo__c,GRR_Importe_Riesgo_directo__c
            FROM GRR_Gestion__c 
            WHERE GRR_Case_Gestion__c = :caseId AND RecordType.DeveloperName = :recordType
            ORDER BY GRR_Fecha_Antiguedad_Deuda__c DESC
        ];
    }
    @AuraEnabled(cacheable=true)
    public static Id getGestionRecordTypeId(String recordType) {
        return [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'GRR_Gestion__c' 
            AND DeveloperName = :recordType
            LIMIT 1
        ].Id;
    }


}