@isTest
public class CC_Push_SMS_Test {
    @TestSetup
    static void testSetup(){
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        UserRole rolCC = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        PermissionSet psSupervisor = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        User gestorCsbd;
        User usuarioAdmin = new User();        
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = rolCC.Id;
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        insert usuarioAdmin;

        System.runAs(usuarioAdmin)
        {
            List<User> userInsert = new List<User>();
        User supervisor = new User();
        supervisor.ProfileId = profileId;
        supervisor.FirstName = 'Supervisor';
        supervisor.LastName = 'last11';
        supervisor.Email = 'tuser000@amamama.com';
        supervisor.Username = 'tuser000@supervisor.com' + System.currentTimeMillis();
        supervisor.CompanyName = 'MST';
        supervisor.Title = 'title';
        supervisor.Alias = 'alias';
        supervisor.TimeZoneSidKey = 'Europe/Paris';
        supervisor.EmailEncodingKey = 'UTF-8';
        supervisor.LanguageLocaleKey = 'es';
        supervisor.LocaleSidKey = 'es_ES';
        supervisor.UserRoleId = rolCC.Id;
        userInsert.add(supervisor);
        
        User gestor = new User();
        gestor.LastName = 'Gestor CSBD Test';
        gestor.Alias = 'gestor';
        gestor.Email = 'gestorcsbd@caixabank.com.invalid';
        gestor.Username = 'gestorcsbd_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
        gestor.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSBD Gestor'].Id;
        gestor.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'CSBD_Generico'].Id;
        gestor.EmailEncodingkey = 'ISO-8859-1';
        gestor.LanguageLocaleKey = 'es';
        gestor.LocalesIdKey = 'es';
        gestor.TimezonesIdKey = 'Europe/Madrid';
        userInsert.add(gestor);
        insert userInsert;
        gestorCsbd = gestor;

        insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psClasses.Id);
        insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psSupervisor.Id);
        PermissionSet psGestorCsbd = [SELECT Id FROM PermissionSet WHERE Name = 'CSBD_PS_Gestor'];
        insert new PermissionSetAssignment(PermissionSetId = psGestorCsbd.id, AssigneeId = gestor.Id);
        Case oCaso = new Case();
        oCaso.Subject = 'Test SMS';
        oCaso.Origin = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = '666112233';
        oCaso.CC_CanalNotifCli__c = 'SMS';
        oCaso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        insert oCaso;
        CBK_IntegrationSetting__c customSetting = new CBK_IntegrationSetting__c();
        customSetting.Name = 'CC_Envio_SMS';
        customSetting.NamedCredential__c = 'callout:API_GWT_PRO_CCSF/distribution/messages/applicationAlerts/send';
        customSetting.RegistroTrazaIntegracion__c = true;
        insert customSetting;
    }
    System.runAs(gestorCsbd) {
    Map<String, Object> camposOportunidad = new Map<String, Object>{'CSBD_Titulo__c' => 'Oportunidad Test'};
    Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_CMB', camposOportunidad);
    }
    }

    private class MockHttpResponseExito implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            // res.setBody('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><ns2:ProcesarEventoResponse xmlns:ns2="http://servicioexternoenviosws.alertasfinancenvios.mca.si.absis.lacaixa.es/"><return><datosError/><listaMensajes><canalEnvio>SMS</canalEnvio><destinatario>34-650XXXXXX</destinatario><texto>Test Salesforce.</texto><tipoEnvio>Online</tipoEnvio></listaMensajes></return></ns2:ProcesarEventoResponse></soap:Body></soap:Envelope>');
            res.setBody('{"messageList":[{"addressee":"34-666555444","text":"TextoPrueba","channel":"SMS","sendType":"Online"}],"infoBean":{}}');
            res.setStatusCode(200);
            return res;
        }
    }
    @isTest
    private static void sendSMSExito() {

        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Id idCaso = [SELECT Id FROM Case LIMIT 1].Id;
        System.runAs(supervisor)
        {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        String mensaje = 'TextoPrueba';
        String result = CC_PUSH_SMS.enviarNotificacionPush(idCaso, '666555444', mensaje);
        Test.stopTest();
        System.assertEquals('OK', result);
    }
    }
    @isTest
    private static void sendSMSExitoCSBD() {

        User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];
        Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];
        System.runAs(gestorCsbd)
        {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        String mensaje = 'TextoPrueba';
        String result = CC_PUSH_SMS.enviarNotificacionPush(oportunidad.Id, '666555444', mensaje);
        Test.stopTest();
        System.assertEquals('OK', result);
    }
    }

    private class MockHttpResponseError implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
           // res.setBody('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><ns2:ProcesarEventoResponse xmlns:ns2="http://servicioexternoenviosws.alertasfinancenvios.mca.si.absis.lacaixa.es/"><return><datosError><codigoError>ERRENV0008</codigoError><mensajeError>LONGITUD DE BLOQUE NO NUMERICA.</mensajeError></datosError></return></ns2:ProcesarEventoResponse></soap:Body></soap:Envelope>');
            res.setBody('{"messageList":[],"infoBean":{"infoCode":"ERRENV0005","infoMessage":"EVENTO INEXISTENTE EN LA TAUX DE EVENTOS: 2800000000000.."}}');

            res.setStatusCode(400);
            return res;
        }
    }
    @isTest
    private static void sendSMSError() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Id idCaso = [SELECT Id FROM Case LIMIT 1].Id;
        System.runAs(supervisor)
        {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());
        String mensaje = 'Mensaje de test. La longitud de este mensaje es de más de 160 carácteres porque nos interesa conseguir toda la cobertura posible. Pongo una frase más para llegar a 179 carácteres.';
        String result = CC_PUSH_SMS.enviarNotificacionPush(idCaso, '666112233', mensaje);
        Test.stopTest();

        System.assertEquals('KO: {"messageList":[],"infoBean":{"infoCode":"ERRENV0005","infoMessage":"EVENTO INEXISTENTE EN LA TAUX DE EVENTOS: 2800000000000.."}}', result);
    }
}
}