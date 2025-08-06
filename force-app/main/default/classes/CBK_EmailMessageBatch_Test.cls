@isTest
private class CBK_EmailMessageBatch_Test {
    @testSetup
    static void setup(){
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id,
            LastName = 'LastNameTest',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
        insert user;

        string rtId3 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso3 = new Case();
		caso3.Origin = 'Chat';
		caso3.Description = 'test3';
		caso3.RecordTypeId = rtId3;
		caso3.CC_Canal_Procedencia__c = 'Web';
		caso3.CC_Tipo_Contacto__c = 'Consulta';
		insert caso3;

        List<EmailMessage> lst = new List<EmailMessage> ();
		EmailMessage correo = new EmailMessage();
		correo.ParentId = caso3.Id;
		correo.RelatedToId = caso3.Id;
		correo.Incoming = false;
		correo.Subject = 'EMAILCASO';
		correo.TextBody = 'EMAILCASO';
		correo.FromAddress = 'oficinatecnica.salesforce@silk.es';
		correo.ToAddress = 'prueba@ibm.com';
        correo.CcAddress = 'prueba@ibm.com';
        correo.BccAddress = 'prueba@ibm.com';
        correo.MessageIdentifier = 'XXXXXXX';
        insert correo;

        EmailMessage correo2 = new EmailMessage();
		correo2.ParentId = caso3.Id;
		correo2.RelatedToId = caso3.Id;
		correo2.Incoming = false;
		correo2.Subject = 'EMAILCASO';
		correo2.HtmlBody = 'EMAILCASO';
		correo2.FromAddress = 'oficinatecnica.salesforce@silk.es';
		correo2.ToAddress = 'prueba@ibm.com';
        correo2.CcAddress = 'prueba@ibm.com';
        correo2.BccAddress = 'prueba@ibm.com';
        correo2.MessageIdentifier = 'XXXXXX1';
        insert correo2;

        String strAddress = 'test@test.com';
        for (integer i=0; i<120; i++ ){
            strAddress+=';'+'test'+i+'@test.com';
        }

        EmailMessage correo3 = new EmailMessage();
		correo3.ParentId = caso3.Id;
		correo3.RelatedToId = caso3.Id;
		correo3.Incoming = false;
		correo3.Subject = 'EMAILCASO';
		correo3.HtmlBody = 'EMAILCASO';
		correo3.FromAddress = 'oficinatecnica.salesforce@silk.es';
		correo3.ToAddress = strAddress;
        correo3.CcAddress = 'prueba@ibm.com';
        correo3.BccAddress = 'prueba@ibm.com';
        correo3.MessageIdentifier = 'XXXXXX2';
        insert correo3;

        String strCCAddress = 'test@test.com';
        for (integer i=0; i<120; i++ ){
            strCCAddress+=';'+'test'+i+'@test.com';
        }

        EmailMessage correo4 = new EmailMessage();
		correo4.ParentId = caso3.Id;
		correo4.RelatedToId = caso3.Id;
		correo4.Incoming = false;
		correo4.Subject = 'EMAILCASO';
		correo4.HtmlBody = 'EMAILCASO';
		correo4.FromAddress = 'oficinatecnica.salesforce@silk.es';
		correo4.ToAddress = 'prueba@ibm.com';
        correo4.CcAddress = strAddress;
        correo4.BccAddress = 'prueba@ibm.com';
        correo4.MessageIdentifier = 'XXXXXX3';
        insert correo4;

        String strBCCAddress = 'test@test.com';
        for (integer i=0; i<120; i++ ){
            strBCCAddress+=';'+'test'+i+'@test.com';
        }
        EmailMessage correo5 = new EmailMessage();
		correo5.ParentId = caso3.Id;
		correo5.RelatedToId = caso3.Id;
		correo5.Incoming = false;
		correo5.Subject = 'EMAILCASO';
		correo5.HtmlBody = 'EMAILCASO';
		correo5.FromAddress = 'oficinatecnica.salesforce@silk.es';
		correo5.ToAddress = 'prueba@ibm.com';
        correo5.CcAddress = 'prueba@ibm.com';
        correo5.BccAddress = strBCCAddress;
        correo5.MessageIdentifier = 'XXXXXX4';
        insert correo5;

        CBK_EmailMessageResend__c emresend =  new CBK_EmailMessageResend__c();
        emresend.CBK_EmailMessageId__c = correo.Id;
        emresend.CBK_Status__c = 'Pendiente';
        insert emresend;

        CBK_EmailMessageResend__c emresend2 =  new CBK_EmailMessageResend__c();
        emresend2.CBK_EmailMessageId__c = correo2.Id;
        emresend2.CBK_Status__c = 'Pendiente';
        insert emresend2;

        CBK_EmailMessageResend__c emresend3 =  new CBK_EmailMessageResend__c();
        emresend3.CBK_EmailMessageId__c = correo3.Id;
        emresend3.CBK_Status__c = 'Pendiente';
        insert emresend3;

        CBK_EmailMessageResend__c emresend4 =  new CBK_EmailMessageResend__c();
        emresend4.CBK_EmailMessageId__c = correo4.Id;
        emresend4.CBK_Status__c = 'Pendiente';
        insert emresend4;

        CBK_EmailMessageResend__c emresend5 =  new CBK_EmailMessageResend__c();
        emresend5.CBK_EmailMessageId__c = correo5.Id;
        emresend5.CBK_Status__c = 'Pendiente';
        insert emresend5;

        List<String> idsCV = new List<String>();
        Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
        ContentVersion cnv = new ContentVersion();
        cnv.title = 'test content pdf';
        cnv.PathOnClient = 'Test_1';
        cnv.VersionData = beforeblob;
        insert cnv;
        idsCV.add(cnv.Id);
        
        ContentVersion cnv22 = new ContentVersion();
        cnv22.title = 'test content image';
        cnv22.PathOnClient = 'Test_2';
        cnv22.VersionData = beforeblob;
        insert cnv22;
        idsCV.add(cnv22.Id);
 
        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        idsCV.add(cv.Id);
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
			WHERE LatestPublishedVersionId IN :idsCV
        ];
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = correo.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        ContentDocumentLink cd2 = New ContentDocumentLink();
        cd2.LinkedEntityId = correo.Id;
        cd2.ContentDocumentId = documents[1].Id;
        cd2.shareType = 'V';
        insert cd2;

        ContentDocumentLink cd3 = New ContentDocumentLink();
        cd3.LinkedEntityId = correo.Id;
        cd3.ContentDocumentId = documents[2].Id;
        cd3.shareType = 'V';
        insert cd3;
    }

    @isTest
	private static void testbacth() {
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        Test.startTest();
        System.runAs (usr) {
            CBK_EmailMessageBatch batch = new CBK_EmailMessageBatch();
            Id batchId = Database.executeBatch(batch);
        }
        Test.stopTest();
        
    }
}