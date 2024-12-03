public with sharing class CC_Notificacion_Volumen_Crear_Controller {

    @AuraEnabled
    public static Map<String, Integer> inicializarVolumenes(Id recordId) {

        Map<String, Integer> retorno = new Map<String, Integer>();

        Id idAgrupador = recordId;
        if (recordId.getSobjectType() == CC_Notificacion_Volumen__c.sObjectType) {
            idAgrupador = [SELECT CC_Agrupador_Id__c FROM CC_Notificacion_Volumen__c WHERE Id = :recordId LIMIT 1].CC_Agrupador_Id__c;
        }

        CC_Agrupador__c agrupador = [SELECT CC_Agrupador_Padre_Formula__c FROM CC_Agrupador__c WHERE Id = :idAgrupador LIMIT 1];

        Integer llamadasAtendidas = [SELECT Count() FROM Case WHERE CC_Agrupador_Id__r.CC_Agrupador_Padre_Formula__c = :agrupador.CC_Agrupador_Padre_Formula__c];
        retorno.put('llamadasAtendidas', llamadasAtendidas);

        CC_Notificacion_Volumen__c notificacionAnterior = CC_Notificacion_Volumen.ultimaNotificacion(recordId);
        if (notificacionAnterior == null) {
            retorno.put('llamadasAtendidasParcial', 0);
            retorno.put('llamadasAbandonadasAnterior', 0);
        } else {
            retorno.put('llamadasAtendidasParcial', llamadasAtendidas - (Integer)notificacionAnterior.CC_Llamadas_Atendidas__c);
            retorno.put('llamadasAbandonadasAnterior', (Integer)notificacionAnterior.CC_Llamadas_Abandonadas__c);
        }
        return retorno;
    }

    @AuraEnabled
    public static String fechaUltimaNotificacion(Id recordId) {
        CC_Notificacion_Volumen__c notificacionAnterior = CC_Notificacion_Volumen.ultimaNotificacion(recordId);
        if (notificacionAnterior != null) {
            return String.valueOfGmt(notificacionAnterior.LastModifiedDate);
        } else {
            return '';
        }
    }
}