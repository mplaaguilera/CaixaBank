@isTest
public with sharing class CC_CaixabankTalks_EmailService_Test {
    
    @isTest
    public static void testCorreoEntranteCastellano() {
        
        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        List<String> lstCcAdd = new List<String>();
        String buzonCaixabankTalks = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Caixabank_Talks_ESP' LIMIT 1].CC_Direccion_Correo__c;
        List<String> lstToAdd = new List<String>();
        lstToAdd.add('email1@test.com');
        lstToAdd.add(buzonCaixabankTalks);
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_CaixabankTalks') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }
        header.value = headerValueStr;
        header.name = 'X-SFDC-Original-RCPT';

        /*header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';*/
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = buzonCaixabankTalks;
        correo.subject = 'asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.toAddresses = lstToAdd;
        correo.ccAddresses = lstCcAdd;
        correo.htmlBody = 'TEST CAIXABANK TALKS';
        correo.headers = new List<Messaging.InboundEmail.Header>{header};

        //Adjuntos binarios
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario1 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario1.body = blob.valueOf('my attachment text');
        adjuntoBinario1.fileName = 'textfileone.txt';
        adjuntoBinario1.mimeTypeSubType = 'text/plain';
        adjuntoBinario1.headers = new List<Messaging.InboundEmail.Header>{header};
        
        Messaging.InboundEmail.BinaryAttachment adjuntoBinario2 = new Messaging.InboundEmail.BinaryAttachment();
        adjuntoBinario2.body = blob.valueOf('my attachment text 2');
        adjuntoBinario2.fileName = 'text2fileone.txt';
        adjuntoBinario2.mimeTypeSubType = 'text/plain';
        
        correo.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{adjuntoBinario1, adjuntoBinario2};
        
        //Adjunto de texto
        Messaging.InboundEmail.TextAttachment adjuntoTexto = new Messaging.InboundEmail.TextAttachment();
        adjuntoTexto.body = 'my attachment text';
        adjuntoTexto.fileName = 'textfiletwo3.txt';
        adjuntoTexto.mimeTypeSubType = 'texttwo/plain';
        correo.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{adjuntoTexto};
        
        Test.startTest();
        
        CC_CaixabankTalks_EmailService emailServiceCaixaBankTalks = new CC_CaixabankTalks_EmailService();
        emailServiceCaixaBankTalks.handleInboundEmail(correo, envelope);     
        Test.stopTest();
        
    }
}