public with sharing class CSBD_DisponibilidadGestores_Apex {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> init() {
        return new Map<String, Object>{
            'currentUserName' => UserInfo.getName(),
            'calendarViewShares' => [SELECT Parent.PublisherId, Parent.Publisher.Type, Parent.Publisher.Name, Parent.Color
                                        FROM CalendarViewShare WHERE UserOrGroupId = :UserInfo.getUserId()
                                        AND Parent.IsDisplayed = TRUE ORDER BY Parent.Publisher.Name ASC]
        };
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, List<Event>> getEventosGestores(Date fecha, List<Id> idGestores) {
        Map<Id, List<Event>> eventos = new Map<Id, List<Event>>();
        if (!idGestores.isEmpty() && fecha != null) {
            for (Event evento : [SELECT OwnerId, Subject, StartDateTime, EndDateTime FROM Event
                                    WHERE RecordType.DeveloperName LIKE 'CSBD_%' AND OwnerId IN :idGestores
                                    AND StartDateTime >= :Datetime.newInstance(fecha, Time.newInstance(0, 0, 0, 0))
                                    AND EndDateTime <= :Datetime.newInstance(fecha, Time.newInstance(23, 59, 59, 999))
                                    AND CSBD_Evento_Estado__c NOT IN ('Completado', 'Cancelado')
                                    ORDER BY StartDateTime ASC]) {
                if (!eventos.containsKey(evento.OwnerId)) {
                    eventos.put(evento.OwnerId, new List<Event>{evento});
                } else {
                    eventos.get(evento.OwnerId).add(evento);
                }
            }
        }
        return eventos;
    }
}