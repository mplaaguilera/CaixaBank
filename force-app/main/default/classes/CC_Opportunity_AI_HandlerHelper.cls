public without sharing class CC_Opportunity_AI_HandlerHelper {
    public static void actualizarNombreOpp (List<Id> idOportunidades){
        update CSBD_Opportunity.actualizarNombreOportunidades([SELECT CSBD_Identificador__c, RecordTypeId, AccountId, CreatedDate
                                                                FROM Opportunity WHERE Id IN :idOportunidades]);
    }
}