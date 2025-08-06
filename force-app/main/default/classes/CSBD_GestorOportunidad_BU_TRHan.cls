public with sharing class CSBD_GestorOportunidad_BU_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CSBD_Gestor_Oportunidad__c>) tp.newList, (Map<Id, CSBD_Gestor_Oportunidad__c>) tp.newMap, (List<CSBD_Gestor_Oportunidad__c>) tp.oldList, (Map<Id, CSBD_Gestor_Oportunidad__c>) tp.oldMap);
	}

	private void process(List<CSBD_Gestor_Oportunidad__c> listNewObj, Map<Id, CSBD_Gestor_Oportunidad__c> mapNewObj, List<CSBD_Gestor_Oportunidad__c> listOldObj, Map<Id, CSBD_Gestor_Oportunidad__c> mapOldObj) {
        actualizarColaGestorOportunidad(listNewObj, mapOldObj);
    }

    private static void actualizarColaGestorOportunidad (List<CSBD_Gestor_Oportunidad__c> listNewObj, Map<Id, CSBD_Gestor_Oportunidad__c> mapOldObj) {
        Set<Id> oportunidadIds = new Set<Id>();
        List<CSBD_Gestor_Oportunidad__c> gestorOportunidadCambiarOwner = new List<CSBD_Gestor_Oportunidad__c>();
        Set<String> tiposOportunidad = new Set<String>();
        for(CSBD_Gestor_Oportunidad__c gestorOportunidad: listNewObj) {
            if(mapOldObj.get(gestorOportunidad.Id).CSBD_Estado__c != gestorOportunidad.CSBD_Estado__c && gestorOportunidad.CSBD_Estado__c == 'Pendiente de asignar') {
                //Registros para los que hay que recalcular el owner
                oportunidadIds.add(gestorOportunidad.CSBD_Oportunidad__c);
                gestorOportunidadCambiarOwner.add(gestorOportunidad);
                if(gestorOportunidad.CSBD_Tipo_de_oportunidad__c != null) {
                    tiposOportunidad.add(gestorOportunidad.CSBD_Tipo_de_oportunidad__c);
                }
            }
        }
        if(!gestorOportunidadCambiarOwner.isEmpty()) {
            //Actualizamos el owner del Gestor Oportunidad y cambiamos el estado a activo
            CSBD_GestorOportunidad.calcularColaGestorOportunidad(oportunidadIds, gestorOportunidadCambiarOwner, tiposOportunidad);
        }
    }

}