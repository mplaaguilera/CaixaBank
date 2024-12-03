public  with sharing class CC_Agrupador_AI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        String test;
        //process((List<CC_Agrupador__c>)tp.newList, (Map<Id, CC_Agrupador__c>)tp.newMap);
    }

    /*private void process(List<CC_Agrupador__c> listNewObj, Map<Id, CC_Agrupador__c> mapNewObj) {
        // Si se trata de una Comunicación Informativa, se asocian a ella todos los casos que tengan el mismo MCC o la misma Campaña especificada en la Comunicación Informativa
        //asociarCasosAComunicacionInformativa(listNewObj);
    }
    
    private void asociarCasosAComunicacionInformativa(List<CC_Agrupador__c> listNewObj) {
        List<Case> casosActualizar = new List<Case>();
        Set<Id> setCausas = new Set<Id>();
        Set<Id> setCampana = new Set<Id>();
        Map<Id, Id> mapAgrupadorCausa = new Map<Id, Id>();
        Map<Id, Id> mapAgrupadorCampana = new Map<Id, Id>();
        Id comunicacionInformativaRecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        Id comunicacionInformativaCampanaRecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Campana').getRecordTypeId();
        for (CC_Agrupador__c agrupador : listNewObj) {
            if (agrupador.RecordTypeId == comunicacionInformativaRecordTypeId && agrupador.CC_Tematica_Id__c != null && agrupador.CC_Producto_Servicio__c != null && agrupador.CC_Motivo__c != null && agrupador.CC_Causa__c != null && !setCausas.contains(agrupador.CC_Causa__c) && !mapAgrupadorCausa.containsKey(agrupador.CC_Causa__c)) {
                setCausas.add(agrupador.CC_Causa__c);
                mapAgrupadorCausa.put(agrupador.CC_Causa__c, agrupador.Id);
            } else if (agrupador.RecordTypeId == comunicacionInformativaCampanaRecordTypeId && agrupador.CC_Campana__c != null && !setCampana.contains(agrupador.CC_Campana__c) && !mapAgrupadorCampana.containsKey(agrupador.CC_Campana__c)) {
                setCampana.add(agrupador.CC_Campana__c);
                mapAgrupadorCampana.put(agrupador.CC_Campana__c, agrupador.Id);
            }
        }

        if(!setCausas.isEmpty()){
            for (Case casoConMismaCausa : [SELECT Id, CC_Comunicacion_Informativa__c, CC_MCC_Causa__c, CC_Admin__c FROM Case WHERE CC_MCC_Tematica__c != null AND CC_MCC_ProdServ__c != null AND CC_MCC_Motivo__c != null AND CC_MCC_Causa__c != null AND CC_MCC_Causa__c IN :setCausas AND CreatedDate = TODAY AND Status != 'Rechazado' AND CC_Tipo_Contacto__c != 'Incidencia' AND CC_Agrupador_Id__c = null WITH SECURITY_ENFORCED]) {
                casoConMismaCausa.CC_Comunicacion_Informativa__c = mapAgrupadorCausa.get(casoConMismaCausa.CC_MCC_Causa__c);
                casoConMismaCausa.CC_Admin__c = true;
                casosActualizar.add(casoConMismaCausa);
            }
        }

        if(!setCampana.isEmpty()){
            for (Case casoConMismaCampana : [SELECT Id, CC_Comunicacion_Informativa_Campana__c, CC_Campana__c, CC_Admin__c FROM Case WHERE CC_Campana__c != null AND CC_Campana__c IN :setCampana AND CreatedDate = TODAY AND Status != 'Rechazado' AND CC_Tipo_Contacto__c != 'Incidencia' AND CC_Agrupador_Id__c = null WITH SECURITY_ENFORCED]) {
                casoConMismaCampana.CC_Comunicacion_Informativa_Campana__c = mapAgrupadorCampana.get(casoConMismaCampana.CC_Campana__c);
                casoConMismaCampana.CC_Admin__c = true;
                casosActualizar.add(casoConMismaCampana);
            }
        }

        if(!casosActualizar.isEmpty() && Schema.sObjectType.Case.fields.CC_Comunicacion_Informativa_Campana__c.isUpdateable() && Schema.sObjectType.Case.fields.CC_Comunicacion_Informativa__c.isUpdateable()){
            update casosActualizar;
        }
        
        List<Case> casosActualizarAux = new List<Case>();
        for (Case casoActualizar : casosActualizar) {
            casoActualizar.CC_Admin__c = false;
            casosActualizarAux.add(casoActualizar);
        }
        update casosActualizarAux;
    }*/
}