@isTest
public with sharing class CC_Notificacion_Borrado_SC_Test {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    public static testMethod void borradoAntiguasNotificaciones(){
        CC_Historial_Notificacion__c notificacionAntigua = new CC_Historial_Notificacion__c(
            CC_Mensaje__c = 'Aviso de hace un mes',
            CC_Tipo__c = 'warning'
        );
        insert notificacionAntigua;        
        Test.setCreatedDate(notificacionAntigua.Id, Datetime.now().addDays(-31));

        CC_Historial_Notificacion__c notificacionNueva = new CC_Historial_Notificacion__c(
            CC_Mensaje__c = 'Aviso de hoy',
            CC_Tipo__c = 'warning'
        );
        insert notificacionNueva;
        Test.setCreatedDate(notificacionNueva.Id, Datetime.now());
		
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP, 
            new CC_Notificacion_Borrado_SC());    
        Test.stopTest();
        
        List<CC_Historial_Notificacion__c> notificaciones = [SELECT Id FROM CC_Historial_Notificacion__c];
        System.assertEquals(1, notificaciones.size());
        System.assertEquals(notificacionNueva.Id, notificaciones[0].Id);
    }
}