global with sharing class CC_Notificacion_Borrado_SC implements Schedulable{
    global void execute(SchedulableContext SC) {
        Date fecha = System.today().addDays(-30);
        List<CC_Historial_Notificacion__c> notificaciones = [SELECT Id FROM CC_Historial_Notificacion__c WHERE CreatedDate <= :fecha];
        delete notificaciones;
    }
}