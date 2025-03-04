public without sharing class CC_Opportunity_AI_HandlerHelper {

    public static void actualizarNombreOpp(List<Id> idOportunidades) {
        update CSBD_Opportunity.actualizarNombreOportunidades([SELECT CSBD_Identificador__c, RecordTypeId, AccountId, CreatedDate
                                                                FROM Opportunity WHERE Id IN :idOportunidades]);
    }

    @future
    public static void actualizarIdOportunidadEnCase(String oportunidadesJson) {
        List<Opportunity> oportunidades = (List<Opportunity>)JSON.deserialize(oportunidadesJson, List<Opportunity>.class);
        Id recordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_MAC');
        List<Case> casesToUpdate = new List<Case>();
        List<CBK_Case_Extension__c> aRecordsToInsert = new List<CBK_Case_Extension__c>();
        Map<Id, CBK_Case_Extension__c> caseExtensionMap = new Map<Id, CBK_Case_Extension__c>();

        for (Opportunity opp : oportunidades) {
            if (opp.RecordTypeId == recordType && opp.CSBD_CasoOrigen__c != null) {
                CBK_Case_Extension__c cbkCaseExtension = new CBK_Case_Extension__c(
                    CC_Oportunidad_Relacionada_Lookup__c = opp.Id
                );
                aRecordsToInsert.add(cbkCaseExtension);
                caseExtensionMap.put(opp.CSBD_CasoOrigen__c, cbkCaseExtension);
            }
        }
        if (!aRecordsToInsert.isEmpty()) {
            insert aRecordsToInsert;
        }

        for (Case relatedCase : [SELECT Id FROM Case WHERE Id IN :caseExtensionMap.keySet()]) {
            CBK_Case_Extension__c cbkCaseExtension = caseExtensionMap.get(relatedCase.Id);
            if (cbkCaseExtension != null) {
                relatedCase.CBK_Case_Extension_Id__c = cbkCaseExtension.Id;
                casesToUpdate.add(relatedCase);
            }
        }
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }


}