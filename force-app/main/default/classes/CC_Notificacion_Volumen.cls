public with sharing class CC_Notificacion_Volumen {

    public static CC_Notificacion_Volumen__c ultimaNotificacion(Id idAgrupador) {
        List<CC_Notificacion_Volumen__c> n = [SELECT CC_Llamadas_Atendidas__c, CC_Llamadas_Abandonadas__c, LastModifiedDate
                                                FROM CC_Notificacion_Volumen__c
                                                WHERE CC_Agrupador_Id__c = :idAgrupador AND CC_Estado__c = 'Enviada'
                                                ORDER BY CreatedDate DESC LIMIT 1];
        return n.isEmpty() ? null : n[0];
    }
}