@isTest
public with sharing class SACH_EmailMessage_Test {
    
    
    @testSetup
    static void data(){
        
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        
        Contact contacto = new Contact(LastName = 'Test', CC_Numero_Documento__c = '36592162J', CC_Sexo__c = 'V');
        insert contacto;
        
        //Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.ContactId = contacto.Id;
        caso.RecordTypeId = rtCaso;
        insert caso;
               
    }
    
    /**
     * Comprobación de creación del emailMessage con HTML.
    */
    @isTest
    private static void testHTML() {
        
        Case caso = [Select id, ContactId from Case where Subject = 'Caso Test' limit 1];
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // setup the data for the email
        email.subject = 'Create Contact';
        email.fromAddress = 'someaddress@email.com';
        email.plainTextBody = 'email body\n2225256325\nTitle';
        
        //add an Binary attachment
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        //add an Text atatchment
            
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
            
        Test.startTest();
        //Ejecución de la prueba
        EmailMessage emailCreado = SACH_EmailMessage.crearEmailMessage(email, 'toaddress@email.com', caso.Id, caso.ContactId, 'cuerpo del correo');
        Test.stopTest();
        
        //Comprobar que se crea el email
        System.assert(emailCreado.Id != null, 'El emailMessage no se ha creado.');
    }
    
    // /**
    //  * Comprobación de creación del emailMessage sin HTML.
    // */
    // @isTest
    // private static void testWithOutHTML() {
        
    //     Case caso = [Select id, ContactId from Case where Subject = 'Caso Test' limit 1];
        
    //     // create a new email and envelope object
    //     Messaging.InboundEmail email = new Messaging.InboundEmail() ;
    //     Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
    //     // setup the data for the email
    //     email.subject = 'Create Contact';
    //     email.fromAddress = 'someaddress@email.com';
    //     email.plainTextBody = 'email body\n2225256325\nTitle';
        
    //     //add an Binary attachment
    //     Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
    //     attachment.body = blob.valueOf('my attachment text');
    //     attachment.fileName = 'textfileone.txt';
    //     attachment.mimeTypeSubType = 'text/plain';
    //     email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
    //     //add an Text atatchment
            
    //     Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
    //     attachmenttext.body = 'my attachment text';
    //     attachmenttext.fileName = 'textfiletwo3.txt';
    //     attachmenttext.mimeTypeSubType = 'texttwo/plain';
    //     email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
            
    //     Test.startTest();
    //     //Ejecución de la prueba
    //     EmailMessage emailCreado = SACH_EmailMessage.crearEmailMessage(email, 'toaddress@email.com', caso.Id, caso.ContactId, 'cuerpo del correo');
    //     Test.stopTest();
        
    //     //Comprobar que se crea el email
    //     System.assert(emailCreado.Id != null, 'El emailMessage no se ha creado.');
    // }
    
}