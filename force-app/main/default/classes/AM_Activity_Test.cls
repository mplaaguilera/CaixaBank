@isTest
public class AM_Activity_Test {
    
    @testSetup
    static void data(){
        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
        
        Case caso2 = new Case();
        caso2.CC_Idioma__c = 'es';
        caso2.RecordTypeId = recordTypeCaso;
        caso2.Subject = 'Prueba crear actividad rechazo';
        caso2.Status = 'Rechazado';
        caso2.Origin = 'Email';
        caso2.OwnerId = UserInfo.getUserId();
        caso2.CC_Canal_Procedencia__c = 'Buzón Carteras';
        caso2.CC_Canal_Resolucion__c = 'Buzón Carteras';
        caso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso2;        
    }

    
    @isTest
    public static void crearActividad() {

        Case caso = [SELECT Id, ownerId, Status FROM Case WHERE Status = 'Rechazado' LIMIT 1];
        System.assertEquals(0, [SELECT Id FROM Task WHERE Type = 'Rechazado' AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task')].size());
        Test.startTest();
        AM_Activity.crearActividad(caso.Id, caso.Status, 'Pruebas de actividad');

        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Task WHERE Type = 'Rechazado' AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task')].size());
    }
    
    @isTest
    public static void crearActividadPendiente() {

        Case caso = [SELECT Id, ownerId, Status FROM Case WHERE Status = 'Rechazado' LIMIT 1];
        System.assertEquals(0, [SELECT Id FROM Task WHERE Type = 'Rechazado' AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task')].size());
        Test.startTest();
        AM_Activity.crearActividadPendiente(caso.Id, caso.Status, 'Pruebas de actividad');

        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Task WHERE Type = 'Rechazado' AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task')].size());
    }
    
    

}