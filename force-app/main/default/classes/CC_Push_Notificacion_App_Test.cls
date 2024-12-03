@isTest
public class CC_Push_Notificacion_App_Test {
    @TestSetup
    static void testSetup(){

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id;
        UserRole roleId = [SELECT Id FROM UserRole WHERE Name = 'Contact Center' LIMIT 1];
        List<User> userList = new List<User>();

        User usuario1 = new User();
        usuario1.ProfileId = profileId;
        usuario1.UserRoleId = roleId.Id;
        usuario1.FirstName = 'Usuario Prueba';
        usuario1.LastName = 'last1';
        usuario1.Email = 'tuser000@amamama.com';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';

        userList.add(usuario1);
        insert userList;

        System.runAs(usuario1){
            
            Id tematicaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            Id productoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            Id motivoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
    
            CC_MCC__c tematica = new CC_MCC__c(
                Name = 'Tematica Test',
                RecordTypeId = tematicaId,
                CC_Tipo_Cliente__c = 'Cliente',
                CC_Canal_Operativo__c = 'Cajero',
                CC_Codigo_Externo__c = 'TE-000001'
            );
            insert tematica;
            CC_MCC__c producto = new CC_MCC__c(
                Name = 'Producto Test',
                RecordTypeId = productoId,
                CC_Tematica__c = tematica.Id,
                CC_Tipo_Cliente__c = 'Cliente',
                CC_Codigo_Externo__c = 'PR-000001'
            );
            insert producto;
            CC_MCC__c motivo = new CC_MCC__c(
                Name = 'Motivo Test',
                RecordTypeId = motivoId,
                CC_Producto_Servicio__c = producto.Id,
                CC_Tipo_Cliente__c = 'Cliente',
                CC_Codigo_Externo__c = 'MO-000001'
            );
            insert motivo;
    
            Case oCaso = new Case();
            oCaso.Subject = 'Test POSEIDON';
            oCaso.Origin = 'Email';
            oCaso.CC_Idioma__c = 'es';
            oCaso.CC_NotIncidencia__c = '1';
            oCaso.CC_MailTelfNotif__c = '666112233';
            oCaso.CC_CanalNotifCli__c = 'SMS';
            insert oCaso;

            List<CBK_IntegrationSetting__c> integracionSettings = new List<CBK_IntegrationSetting__c>();
            CBK_IntegrationSetting__c envio = new CBK_IntegrationSetting__c();
            envio.Name = 'CC_MCD_Envio_PUSH';
            envio.RegistroTrazaIntegracion__c = true;
            envio.NamedCredential__c = 'callout:MyIntegrationTest';
            integracionSettings.add(envio);

            CBK_IntegrationSetting__c enrollment = new CBK_IntegrationSetting__c();
            enrollment.Name = 'CC_MCD_Gestion_PUSH_uuIds';
            enrollment.RegistroTrazaIntegracion__c = false;
            enrollment.NamedCredential__c = 'callout:MyIntegrationTest';
            integracionSettings.add(enrollment);

            insert integracionSettings;
            
        }
        
    }

    private class MockHttpResponseExitoEnroll implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody('[AD6572B4-5322-3B7B-85EF-DEF4FE907602]');
            res.setStatusCode(200);
            return res;
        }
    }
    

    @isTest
    private static void solicitudEnrollmentExito() {
        Id idCaso = [SELECT Id FROM Case LIMIT 1].Id;
        User usuario1 = [SELECT Id FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExitoEnroll());
        
        System.runAs(usuario1){
            Map<String, Boolean> result = CC_Push_Notificacion_App.validarEnrollmentPUSH('A789BF73');
            System.assertEquals(true, result.get('IMAGIN'), 'La ejecución ha fallado.');
        }   
        Test.stopTest();
    }

    private class MockHttpResponseErrorMCD implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody('Error');
            res.setStatusCode(404);
            return res;
        }
    }
    
    @isTest
    private static void envioMCDError() {
        Id idCaso = [SELECT Id FROM Case LIMIT 1].Id;
        User usuario1 = [SELECT Id FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseErrorMCD());
        System.runAs(usuario1){
            //String sObjectId, String numPer, String textoPublico, String textoPrivado, String textoPrivadoAvanzado, String asunto, String deeplink, String idioma
            String result = CC_Push_Notificacion_App.enviarNotificacionPushApp(idCaso, 'IMAGIN', '12345','txtPublico','txtPrivado','asunto','www.google.es','es', 'String titulo', 'String sobreTitulo', 'String textoBoton', '');
            System.assertEquals('', result, 'La ejecución ha fallado.');
        }
        Test.stopTest();

        
    }

    private class MockHttpResponseErrorEnroll implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody('Error');
            res.setStatusCode(404);
            return res;
        }
    }
    
    @isTest
    private static void solicitudEnrollmentError() {
        Id idCaso = [SELECT Id FROM Case LIMIT 1].Id;
        User usuario1 = [SELECT Id FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseErrorEnroll());
        System.runAs(usuario1){
            Map<String, Boolean> result = CC_Push_Notificacion_App.validarEnrollmentPUSH('A789BF73');
            System.assertEquals(false, result.get('IMAGIN'), 'La ejecución ha fallado.');
        }
        Test.stopTest();

        
    }
    private class MockHttpResponseExitoMCD implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody('<result>Envío PUSH</result>');
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    private static void envioMCDExito() {
        Id idCaso = [SELECT Id FROM Case LIMIT 1].Id;
        User usuario1 = [SELECT Id FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExitoMCD());
        System.runAs(usuario1){
            //String sObjectId, String numPer, String textoPublico, String textoPrivado, String textoPrivadoAvanzado, String asunto, String deeplink, String idioma
            String result = CC_Push_Notificacion_App.enviarNotificacionPushApp(idCaso, 'laCaixa', '12345','txtPublico','txtPrivado','asunto','www.google.es','ca', 'String titulo', 'String sobreTitulo', 'String textoBoton', '');
            System.assertEquals('<result>Envío PUSH</result>', result, 'La ejecución ha fallado.');
        }
        Test.stopTest();

        
    }
}