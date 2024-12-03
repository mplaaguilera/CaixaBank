public with sharing class CC_Agrupador_BI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Agrupador__c>)tp.newList, (Map<Id, CC_Agrupador__c>)tp.newMap);
    }

    private void process(List<CC_Agrupador__c> listNewObj, Map<Id, CC_Agrupador__c> mapNewObj) {
        // Si se trata de una Comunicación Informativa, se impide la inserción en caso de que ya exista una con el mismo MCC o la misma Campaña
        impedirCreacionComunicacionInformativaDuplicada(listNewObj);
    }
    
    private void impedirCreacionComunicacionInformativaDuplicada(List<CC_Agrupador__c> listNewObj) {
        Set<Id> setCausas = new Set<Id>();
        Set<Id> setCampanas = new Set<Id>();
        List<CC_Agrupador__c> lstAgrupadorCausa = new List<CC_Agrupador__c>();
        List<CC_Agrupador__c> lstAgrupadorMotivo = new List<CC_Agrupador__c>();
        Id comunicacionInformativaRecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        Id comunicacionInformativaCampanaRecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Campana').getRecordTypeId();
        for (CC_Agrupador__c agrupador : listNewObj) {
            if (agrupador.RecordTypeId == comunicacionInformativaRecordTypeId) {
                setCausas.add(agrupador.CC_Causa__c);
                lstAgrupadorCausa.add(agrupador);
            } else if (agrupador.RecordTypeId == comunicacionInformativaCampanaRecordTypeId) {
                setCampanas.add(agrupador.CC_Campana__c);
                lstAgrupadorMotivo.add(agrupador);
            }
        }

        if(!setCausas.isEmpty()){
            List<CC_Agrupador__c> comunicacionesInformativas = [SELECT Id, CC_Causa__c FROM CC_Agrupador__c WHERE RecordTypeId = :comunicacionInformativaRecordTypeId AND CreatedDate = TODAY AND CC_Estado__c = 'Activo' AND CC_Causa__c IN :setCausas WITH SECURITY_ENFORCED];
            List<Id> idsComunicacionInformativa = new List<Id>();

            if (!comunicacionesInformativas.isEmpty()) {
                for (CC_Agrupador__c com : comunicacionesInformativas) {
                    idsComunicacionInformativa.add(com.CC_Causa__c);
                }
                for (CC_Agrupador__c agrupador : lstAgrupadorCausa) {
                    if(idsComunicacionInformativa.contains(agrupador.CC_Causa__c)){
                        agrupador.addError('No se puede crear el agrupador. Ya hay un agrupador activo de tipo "Comunicación Informativa" con la misma Causa y fecha de hoy.');
                    }
                }
            }
        }
        
        if(!setCampanas.isEmpty()){
            List<CC_Agrupador__c> comunicacionInformativasCampana = [SELECT Id, CC_Campana__c FROM CC_Agrupador__c WHERE RecordTypeId = :comunicacionInformativaCampanaRecordTypeId AND CreatedDate = TODAY AND CC_Estado__c = 'Activo' AND CC_Campana__c IN :setCampanas  WITH SECURITY_ENFORCED]; 
            List<Id> idsComunicacionInformativaCampana = new List<Id>();

            if (!comunicacionInformativasCampana.isEmpty()) {
                for (CC_Agrupador__c com : comunicacionInformativasCampana) {
                    idsComunicacionInformativaCampana.add(com.CC_Campana__c);
                }
                for (CC_Agrupador__c agrupador : lstAgrupadorMotivo) {
                    if(idsComunicacionInformativaCampana.contains(agrupador.CC_Campana__c)){
                        agrupador.addError('No se puede crear el agrupador. Ya hay un agrupador activo de tipo "Comunicación Informativa de Campaña" con la misma Campaña y fecha de hoy.');
                    }
                }
            }
        }
    }
}