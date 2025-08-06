public with sharing class CSBD_AlertaTelefoniaController {

    @AuraEnabled
    public static Opportunity obtenerOpp(String recId) {
        Opportunity oportunidad;
        if (Schema.sObjectType.Opportunity.isAccessible()) {
            oportunidad = [SELECT CSBD_Producto_MIFID__c, StageName, IsClosed FROM Opportunity WHERE Id = :recId];
        }
        return oportunidad;
    }
}