@isTest
public with sharing class GRR_EmailMessage_Test {

    private static Contact crearContacto() {
        Contact contacto = new Contact (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'),
            LastName = 'Test',
            CC_Numero_Documento__c = '36592162J'
        );
        insert contacto;
        return contacto;
    }

    private static Case crearCasoConContacto(String idcont) {
        Contact contacto = [SELECT Id FROM Contact WHERE Id = :idcont];
        Case caso = new Case (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Test',
            ContactId = contacto.Id
        );           
        insert caso;
        return caso;
    }
    
    @isTest
    public static void testCrearEmailMessage() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();

            Contact contacto = crearContacto();
            Case caso = crearCasoConContacto(contacto.Id);
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            email.subject = 'Create Contact';
            email.fromAddress = 'someaddress@email.com';
            email.plainTextBody = 'email body\n2225256325\nTitle';
            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
            attachment.body = blob.valueOf('my attachment text');
            attachment.fileName = 'textfileone.txt';
            attachment.mimeTypeSubType = 'text/plain';
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
            attachmenttext.body = 'my attachment text';
            attachmenttext.fileName = 'textfiletwo3.txt';
            attachmenttext.mimeTypeSubType = 'texttwo/plain';
            email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };

            EmailMessage emailCreado = GRR_EmailMessage.crearEmailMessage(email, 'toaddress@email.com', caso.Id, caso.ContactId, 'cuerpo del correo');
            System.assert(emailCreado.Id != null, 'El emailMessage no se ha creado.');

            Test.stopTest();
        }
    }

}