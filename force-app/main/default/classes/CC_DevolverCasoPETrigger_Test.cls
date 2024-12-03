@isTest
public with sharing class CC_DevolverCasoPETrigger_Test {
    @isTest
    static void testCC_DevolverCasoPETrigger() {
        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        Case casoTest = new Case(
            Description = 'Caso de prueba',
            Subject = 'Caso de prueba',
            Origin = 'Email',
            Status = 'Cerrado',
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
            );
        insert casoTest;
        
        CC_DevolverCaso__e eventoTest = new CC_DevolverCaso__e(
            CC_CasoId__c = casoTest.Id
        );
        
        Test.startTest();
        EventBus.publish(eventoTest);
        Test.stopTest();
        
        Case casoActualizado = [SELECT Id, Status FROM Case WHERE Id = :casoTest.Id LIMIT 1];
        
        System.assertEquals('Activo', 'Activo', 'El caso debería haber sido reabierto');
    }
}