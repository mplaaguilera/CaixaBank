@isTest
public without sharing class SAC_EmailServiceConsultaCOPS_Test {
    @TestSetup
    static void makeData(){
        //usuario a usar
        List<User> usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
        Database.insert(usuario);

        System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario[0].Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }
    }

    @isTest
    static void emailServiceTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        Messaging.InboundEmail.BinaryAttachment binAttachment = new Messaging.InboundEmail.BinaryAttachment();
        binAttachment.body = blob.valueOf('my attachment text');
        binAttachment.fileName = 'textfile.txt';
        binAttachment.mimeTypeSubType = 'text/plain';

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
        String headerValueCAM = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.name = 'X-SFDC-Original-RCPT';
        header.value = headerValueCAM;

        Messaging.InboundEmail.TextAttachment txtAttachment = new Messaging.InboundEmail.TextAttachment();
        txtAttachment.body = 'my attachment text';
        txtAttachment.fileName = 'textfile2.txt';
        txtAttachment.mimeTypeSubType = 'text/plain';

        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        email.subject = 'Email entrante';
        email.fromname = 'emailentrante@entrante.com';
        email.fromAddress = 'emailentrantes@entrante.com';        
        List<String> direcciones = new List<String>();
        direcciones.add('prueba@testsac.com');
        direcciones.add('consulta_cops@entrante.com');
        email.toAddresses = direcciones;
        email.ccAddresses = direcciones;
        email.plainTextBody = 'threadId';
        email.htmlBody= 'eeso';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { binAttachment};
        email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {txtAttachment};
        email.headers = new Messaging.InboundEmail.Header[] {header};

        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'emailentrante@entrante.com';
        env.toAddress = 'prueba@testsac.com';

        Test.startTest();
        System.runAs(usuario) {
            //llamar a la clase del email service
            SAC_EmailServiceConsultaCOPS emailProcess = new SAC_EmailServiceConsultaCOPS();
            emailProcess.handleInboundEmail(email, env);
        }
        Test.stopTest();

        System.assertNotEquals([SELECT ID FROM Case].size(), 0, 'No se ha insertado el mail');
    }
}