public with sharing class CSBD_GestorOportunidad_BI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CSBD_Gestor_Oportunidad__c>) tp.newList, (Map<Id, CSBD_Gestor_Oportunidad__c>) tp.newMap);
	}

	private void process(List<CSBD_Gestor_Oportunidad__c> listNewObj, Map<Id, CSBD_Gestor_Oportunidad__c> mapNewObj) {
        actualizarColaGestorOportunidad(listNewObj);
        indicarAltaOmnichannelOportunidad(listNewObj);
    }

    private static void actualizarColaGestorOportunidad (List<CSBD_Gestor_Oportunidad__c> listNewObj) {
        Set<Id> oportunidadIds = new Set<Id>();
        List<CSBD_Gestor_Oportunidad__c> gestorOportunidadCambiarOwner = new List<CSBD_Gestor_Oportunidad__c>();
        Set<String> tiposOportunidad = new Set<String>();
        for(CSBD_Gestor_Oportunidad__c gestorOportunidad: listNewObj) {
            if(gestorOportunidad.CSBD_Estado__c == 'Pendiente de asignar') {
                oportunidadIds.add(gestorOportunidad.CSBD_Oportunidad__c);
                gestorOportunidadCambiarOwner.add(gestorOportunidad);
                if(gestorOportunidad.CSBD_Tipo_de_oportunidad__c != null) {
                    tiposOportunidad.add(gestorOportunidad.CSBD_Tipo_de_oportunidad__c);
                }
            }
        }
        if(!gestorOportunidadCambiarOwner.isEmpty()) {
            CSBD_GestorOportunidad.calcularColaGestorOportunidad(oportunidadIds, gestorOportunidadCambiarOwner, tiposOportunidad);
        }
    }

    private static void indicarAltaOmnichannelOportunidad(List<CSBD_Gestor_Oportunidad__c> listNewObj) {
        Set<Id> oportunidadesIds = new Set<Id>();
        for(CSBD_Gestor_Oportunidad__c gestorOportunidad: listNewObj) {
            if(gestorOportunidad.CSBD_Estado__c != 'Inactivo') {
                oportunidadesIds.add(gestorOportunidad.CSBD_Oportunidad__c);
            }
        }
        if(!oportunidadesIds.isEmpty()) {
            CSBD_Opportunity.indicarAltaBajaOmnichannelOportunidad(oportunidadesIds);
        }
    }
}