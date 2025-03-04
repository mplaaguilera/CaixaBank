public with sharing class CC_Opportunity_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Opportunity>)tp.newList, (Map<Id, Opportunity>)tp.newMap);
	}

    private static void process(List<Opportunity> listNewObj, Map<Id, Opportunity> mapNewObj) {
        List<Opportunity> listNewObjCsbd = oportunidadesCsbd(listNewObj);
        if (!listNewObjCsbd.isEmpty()) {
            actualizarNombreOportunidad(listNewObjCsbd);
            envioAdobeCampaign(listNewObjCsbd);
            if (!Test.isRunningTest()) {
                CC_Opportunity_AI_HandlerHelper.actualizarIdOportunidadEnCase(JSON.serialize(listNewObjCsbd));
            }
        }
    }

    private static void actualizarNombreOportunidad(List<Opportunity> listNewObjCsbd) {
        //Hacemos la actualización del nombre en otra clase para hacerlo without sharing por el formulario intouch
        CC_Opportunity_AI_HandlerHelper.actualizarNombreOpp(CC_MetodosUtiles.listaCampo(listNewObjCsbd, 'Id'));
    }

    private static void envioAdobeCampaign(List<Opportunity> listNewObjCsbd) {
        Id idRtProAuto = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_PROAutomatica').getRecordTypeId();
        for (Opportunity oportunidad : listNewObjCsbd) {
            if (oportunidad.RecordTypeId == idRtProAuto
            && oportunidad.CSBD_Now_NUMPERSO__c != null && oportunidad.CSBD_Now_NUMPERSO__c != '') {
                CSBD_Adobe_Campaign.enviarFuture(JSON.serialize(oportunidad));
            }
        }
    }

    private static List<Opportunity> oportunidadesCsbd(List<Opportunity> listNewObj) {
        List<Opportunity> listNewObjCsbd = new List<Opportunity>();
        Map<Id, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        for (Opportunity oportunidad : listNewObj) {
            if (recordTypes.get(oportunidad.RecordTypeId).getDeveloperName().startsWith('CSBD')) {
                listNewObjCsbd.add(oportunidad);
            }
        }
        return listNewObjCsbd;
    }
}