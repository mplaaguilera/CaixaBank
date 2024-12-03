public with sharing class OB_Llamada_AU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_Llamada__c>)tp.newList, (Map<Id, CC_Llamada__c>)tp.oldMap);
    }

    private void process(List<CC_Llamada__c> listNewObj, Map<Id, CC_Llamada__c> mapOldObj) {
        listNewObj = descartarLlamadasNoOutbound(listNewObj);
        if (!listNewObj.isEmpty()) {
            cambioPropietario(listNewObj, mapOldObj);
            validacionRechazo(listNewObj, mapOldObj);
            marcarParaEnvioGddo(listNewObj, mapOldObj);
        }
    }

    private static void cambioPropietario(List<CC_Llamada__c> listNewObj, Map<Id, CC_Llamada__c> mapOldObj) {
        List<Id> idLlamadasCambioPropietario = new List<Id>();
        for (CC_Llamada__c newLlamada : listNewObj) {
            if (newLlamada.OwnerId != mapOldObj.get(newLlamada.Id).OwnerId) {
                idLlamadasCambioPropietario.add(newLlamada.Id);
            }
        }
        OB_Llamada.accionesCambioPropietario(idLlamadasCambioPropietario);
    }

    private static void validacionRechazo(List<CC_Llamada__c> listNewObj, Map<Id, CC_Llamada__c> mapOldObj) {
        List<Id> idLlamadasValidadas = new List<Id>();
        List<Id> idLlamadasRechazadas = new List<Id>();
        for (CC_Llamada__c newLlamada : listNewObj) {
            if (mapOldObj.get(newLlamada.Id).OB_Estado__c == 'OB_Pendiente_Validacion') {
                if (newLlamada.OB_Estado__c == 'OB_Cerrada') {
                    idLlamadasValidadas.add(newLlamada.Id);
                } else if (newLlamada.OB_Estado__c == 'OB_Rechazada') {
                    idLlamadasRechazadas.add(newLlamada.Id);
                }
            }
        }
        OB_Llamada.accionesValidar(idLlamadasValidadas);
        OB_Llamada.accionesRechazar(idLlamadasRechazadas);
    }

    private static List<CC_Llamada__c> descartarLlamadasNoOutbound(List<CC_Llamada__c> llamadas) {
        List<CC_Llamada__c> llamadasOutbound = new List<CC_Llamada__c>();
        for (CC_Llamada__c llamada : llamadas) {
            if (Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosById().get(llamada.RecordTypeId).getDeveloperName().startsWith('OB_')) {
                llamadasOutbound.add(llamada);
            }
        }
        return llamadasOutbound;
    }

    private static void marcarParaEnvioGddo(List<CC_Llamada__c> listNewObj, Map<Id, CC_Llamada__c> mapOldObj) {
        List<Id> idLlamadasCerradas = new List<Id>();
        for (CC_Llamada__c newLlamada : listNewObj) {
            if (mapOldObj.get(newLlamada.Id).OB_Estado__c != 'OB_Cerrada'
            && newLlamada.OB_Estado__c == 'OB_Cerrada') {
                idLlamadasCerradas.add(newLlamada.Id);
            }
        }
        OB_Llamada.envioGdd(idLlamadasCerradas);
    }
}