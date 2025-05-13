public without sharing class CC_Opportunity_AI_HandlerHelper {
    public static void actualizarNombreOpp (List<Id> idOportunidades){
        update CSBD_Opportunity.actualizarNombreOportunidades([SELECT CSBD_Identificador__c, RecordTypeId, AccountId, CreatedDate
                                                                FROM Opportunity WHERE Id IN :idOportunidades]);
    }


    public static void actualizarIdOportunidadEnCase(String oportunidadesJson) {
        List<Opportunity> oportunidades = (List<Opportunity>)JSON.deserialize(oportunidadesJson, List<Opportunity>.class);
        Id recordTypeMAC = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_MAC');
        List<Opportunity> oportunidadesToUpdate = new List<Opportunity>();

        for (Opportunity opp : oportunidades) {
            if (opp.RecordTypeId == recordTypeMAC && opp.CSBD_CasoOrigen__c != null) {
                oportunidadesToUpdate.add(opp);
            }
        }
        if (!oportunidadesToUpdate.isEmpty()) {
            if(!System.isFuture() && !System.isBatch()){
                actualizarCasoDerivadoAsync(JSON.serialize(oportunidadesToUpdate));
            } else {
                actualizarCasoDerivadoSync(JSON.serialize(oportunidadesToUpdate));
            }
        }     
      
    }

    @future
    public static void actualizarCasoDerivadoAsync(String oportunidadesJson){     
        actualizarCasoDerivadoMAC(oportunidadesJson);
    }

    public static void actualizarCasoDerivadoSync(String oportunidadesJson){     
        actualizarCasoDerivadoMAC(oportunidadesJson);
    }

    public static void actualizarCasoDerivadoMAC(String oportunidadesJson){
        List<Opportunity> oportunidades = (List<Opportunity>)JSON.deserialize(oportunidadesJson, List<Opportunity>.class);      
        List<CBK_Case_Extension__c> aRecordToUpsert = new List<CBK_Case_Extension__c>();
        Map<Id, CBK_Case_Extension__c> caseExtensionConOpp = new Map<Id, CBK_Case_Extension__c>();

        for (Opportunity opp : oportunidades) {
            if (opp.CSBD_CasoOrigen__c != null) {
                CBK_Case_Extension__c cbkCaseExtension = new CBK_Case_Extension__c(
                    CC_Oportunidad_Relacionada_Lookup__c = opp.Id
                );            
               caseExtensionConOpp.put(opp.CSBD_CasoOrigen__c, cbkCaseExtension);
            }
        }
    
        Map<Id, CBK_Case_Extension__c> caseExtensionToCase = new Map<Id, CBK_Case_Extension__c>();
        for (Case relatedCase : [SELECT Id, CBK_Case_Extension_Id__c FROM Case WHERE Id IN :caseExtensionConOpp.keySet()]) {
            CBK_Case_Extension__c cbkCaseExtension = caseExtensionConOpp.get(relatedCase.Id);
            if (cbkCaseExtension != null) {
                if (relatedCase.CBK_Case_Extension_Id__c != null) {
                    cbkCaseExtension.Id = relatedCase.CBK_Case_Extension_Id__c;
                    aRecordToUpsert.add(cbkCaseExtension);                   
                } else {                
                    aRecordToUpsert.add(cbkCaseExtension);
                    caseExtensionToCase.put(relatedCase.Id, cbkCaseExtension);
                }
            }
        }
        //Upsert los records de CBK_Case_Extension__c
        if (!aRecordToUpsert.isEmpty()) {
            upsert aRecordToUpsert;

            if (!caseExtensionToCase.isEmpty()) {
                List<Case> casesToUpdate = new List<Case>();
                for (Id relatedCaseId : caseExtensionToCase.keySet()) {
                    Case caseToUpdate = new Case(
                        Id = relatedCaseId,
                        CBK_Case_Extension_Id__c = caseExtensionToCase.get(relatedCaseId).Id
                    );
                    casesToUpdate.add(caseToUpdate);
                }
                if (!casesToUpdate.isEmpty()) {
                    update casesToUpdate;
                }
            }
        }
    }


}