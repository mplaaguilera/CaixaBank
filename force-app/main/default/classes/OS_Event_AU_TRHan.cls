public with sharing class OS_Event_AU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Event>)tp.newList, (Map<Id, Event>)tp.newMap, (List<Event>)tp.oldList, (Map<Id, Event>)tp.oldMap);
    }

    private void process(List<Event> listNewObj, Map<Id, Event> mapNewObj, List<Event> listOldObj, Map<Id, Event> mapOldObj) {
        alertaVencida(mapOldObj, listNewObj);
    }

    private void alertaVencida(Map<Id, Event> mapOldObj, List<Event> listNewObj) {
        List<Event> eventosFiltrados = new List<Event>();
        Set<Id> eventoCasosIds = new Set<Id>();
        Map<Id, String> mapIdCasoIdEvento = new Map<Id, String>();
        for(Event evento: listNewObj) {
            if(Schema.SObjectType.Event.getRecordTypeInfosById().get(evento.RecordTypeId).getDeveloperName() == 'OS_Alerta' && evento.OS_Alerta_Vencida__c == true && evento.OS_Alerta_Vencida__c != mapOldObj.get(evento.Id).OS_Alerta_Vencida__c){
                eventosFiltrados.add(evento);
                eventoCasosIds.add(evento.WhatId);
            }
        }
        if(!eventoCasosIds.isEmpty() && eventoCasosIds != null) {
        List<Case> casosFiltrados = [SELECT CaseNumber FROM Case WHERE Id IN :eventoCasosIds];
        for(Case cadaCasoFiltrado: casosFiltrados) {
            for(Id cadaEventoCasoIds : eventoCasosIds){
                if (cadaEventoCasoIds == cadaCasoFiltrado.Id){
                    mapIdCasoIdEvento.put(cadaCasoFiltrado.Id, cadaCasoFiltrado.CaseNumber);
                }
            }
        }
        if (!eventosFiltrados.isEmpty()){
            CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'OS_Notificacion_Fecha_Alerta'];
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setBody('Se reactivó el caso, puede retormar su gestión.');
            notification.setNotificationTypeId(type.Id);
            for (Event cadaEventoFiltrado : eventosFiltrados) {
                notification.setSenderId(cadaEventoFiltrado.OwnerId);
                notification.setTitle('Alerta para el caso ' + mapIdCasoIdEvento.get(cadaEventoFiltrado.WhatId));
                notification.setTargetId(cadaEventoFiltrado.Id);
                notification.send(new Set<String> { cadaEventoFiltrado.OwnerId });
            }
        }
    }
}}