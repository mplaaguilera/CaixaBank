public with sharing class CSBD_GestorOportunidad_AU_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CSBD_Gestor_Oportunidad__c>) tp.newList, (Map<Id, CSBD_Gestor_Oportunidad__c>) tp.newMap, (List<CSBD_Gestor_Oportunidad__c>) tp.oldList, (Map<Id, CSBD_Gestor_Oportunidad__c>) tp.oldMap);
	}

	private void process(List<CSBD_Gestor_Oportunidad__c> listNewObj, Map<Id, CSBD_Gestor_Oportunidad__c> mapNewObj, List<CSBD_Gestor_Oportunidad__c> listOldObj, Map<Id, CSBD_Gestor_Oportunidad__c> mapOldObj) {
        indicarAltaBajaOmnichannelOportunidad(listNewObj, mapOldObj);
    }

    private static void indicarAltaBajaOmnichannelOportunidad(List<CSBD_Gestor_Oportunidad__c> listNewObj, Map<Id, CSBD_Gestor_Oportunidad__c> mapOldObj) {
        Set<Id> oportunidadesIdsAlta = new Set<Id>();
        Set<Id> oportunidadesIdsBaja = new Set<Id>();
        for(CSBD_Gestor_Oportunidad__c gestorOportunidad: listNewObj) {
            if(mapOldObj.get(gestorOportunidad.Id).CSBD_Estado__c != gestorOportunidad.CSBD_Estado__c) {
                if(gestorOportunidad.CSBD_Estado__c != 'Inactivo') {
                    oportunidadesIdsAlta.add(gestorOportunidad.CSBD_Oportunidad__c);
                }
                else if(gestorOportunidad.CSBD_Estado__c == 'Inactivo') {
                    oportunidadesIdsBaja.add(gestorOportunidad.CSBD_Oportunidad__c);
                }
            }
        }
        if(!oportunidadesIdsAlta.isEmpty() || !oportunidadesIdsBaja.isEmpty()) {
            CSBD_Opportunity.indicarAltaBajaOmnichannelOportunidad(oportunidadesIdsAlta, oportunidadesIdsBaja);
        }
    }
}