public without sharing class CC_Opportunity_AI_HandlerHelper {
    public static void actualizarNombreOpp (List<Id> idOportunidades){
        update CSBD_Opportunity.actualizarNombreOportunidades([SELECT CSBD_Identificador__c, RecordTypeId, AccountId, CreatedDate
                                                                FROM Opportunity WHERE Id IN :idOportunidades]);
    }

    public static void actualizarIdOportunidadEnCase(List<Opportunity> oportunidades) {
        Map<Id, CBK_Case_Extension__c> caseExtensions = new Map<Id, CBK_Case_Extension__c>();

        Id recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_MAC').getRecordTypeId();
        for (Opportunity opp : oportunidades) {
            if (opp.RecordTypeId == recordType && opp.CSBD_CasoOrigen__c != null) {
                CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                caseExtension.CC_Oportunidad_Relacionada_Lookup__c = opp.Id;
                caseExtensions.put(opp.CSBD_CasoOrigen__c, caseExtension);
            }
        }
        if (!caseExtensions.isEmpty()) {
            insert caseExtensions.values();
        }

        List<Case> casos = new List<Case>();
        for (Id idCaso : caseExtensions.keySet()) {
            Case caso = new Case(Id = idCaso);
            caso.CBK_Case_Extension_Id__c = caseExtensions.get(idCaso).Id;
            casos.add(caso);
        }
        if (!casos.isEmpty()) {
            update casos;
        }
    }
}