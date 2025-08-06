@isTest
public with sharing class HDT_Case_Axiliar_Masivas_Test {

    @testSetup
    static void setupTestData() {
        // Crear EmailMessages de prueba
        List<EmailMessage> emailMessages = new List<EmailMessage>();

        for (Integer i = 0; i < 3; i++) {
            EmailMessage email = new EmailMessage();
            email.SAC_EnvioRedaccion__c = 'TestType';
            email.Subject = 'Correo de prueba ' + i;
            email.TextBody = 'Cuerpo del mensaje ' + i;
            emailMessages.add(email);
        }

        insert emailMessages;

        // Simular fechas de creación (importante para la consulta con CreatedDate)
        DateTime testTime = System.now().addMinutes(-10); // Hace 10 minutos

        for (EmailMessage email : emailMessages) {
            Test.setCreatedDate(email.Id, testTime);
        }
    }

    @isTest
    static void testHasRecentEmail() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        // Definir el límite de tiempo para la consulta
        DateTime limiteMinutos = System.now().addMinutes(-15); // Últimos 15 minutos

        Test.startTest();
        List<EmailMessage> recentEmails = HDT_Case_Axiliar_Masivas.hasRecentEmail('TestType', limiteMinutos);
        Test.stopTest();

        // Verificar que se han recuperado los correos esperados
        System.assertEquals(1, recentEmails.size(), 'Debe recuperar exactamente 3 correos recientes.');
        }
    } 
}