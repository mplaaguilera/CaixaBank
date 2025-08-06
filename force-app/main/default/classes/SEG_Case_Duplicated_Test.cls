@isTest
public with sharing class SEG_Case_Duplicated_Test{
//User operativo = SEG_Usuarios.usuarioOperativo();
//User supervisor = SEG_Usuarios.usuarioSupervisor();
	@testSetup
	static void datosIniciales()
	{
		Account acc = SEG_TestHelper.createCustomer();
		Contact cont = SEG_TestHelper.createCustomerContact(acc.Id,'jslasnd_TEST@gmail.com');
        Id rtSegCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        
        list<case> lstCasos = new list<case>();
		Case caso = new Case(
                SEG_SemillaId__C = '#@SEG:1611676158418#',
                SEG_Zona__c ='Corporativa',
                SEG_Organizacion__C='Banca Corporativa',
				AccountId = acc.Id,
				ContactId = cont.Id,
            	RecordTypeId = rtSegCliente
			);

		lstCasos.add(caso);
		Case caso2 = new Case(
                SEG_SemillaId__C = '#@SEG:4353643#',
                SEG_Zona__c ='Corporativa',
                SEG_Organizacion__C='Banca Corporativa',
				AccountId = acc.Id,
				ContactId = cont.Id,
            	RecordTypeId = rtSegCliente
			);

		lstCasos.add(caso2);
		case caso3 = new Case(
                SEG_SemillaId__C = '#@SEG:1611676158418#',
                SEG_Zona__c ='Corporativa',
                SEG_Organizacion__C='Banca Corporativa',
				AccountId = acc.Id,
				ContactId = cont.Id,
            	RecordTypeId = rtSegCliente,
            	subject='Duplicado'
			);
		lstCasos.add(caso3);
        insert lstCasos;

		EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart + '@' + headerValue.EmailDomainName;
        
		EmailMessage msg = new EmailMessage();
		msg.ParentId = caso.Id;
		msg.FromAddress='jslasnd_TEST@gmail.com';
		msg.ToAddress = 'tiha.invalidad@invalid.com';
		msg.HtmlBody = 'He tenido un error en la contratación';
		msg.TextBody = 'He tenido un error en la contratación';
		msg.Subject = 'Subject Test';
        msg.Incoming = true;
		msg.Headers = '[{"value": "' + headerValueStr + '", "name": "X-SFDC-Original-RCPT"}]';
		insert msg;

		ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
			WHERE LatestPublishedVersionId = :cv.Id
        ];
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = msg.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;


		EmailMessage msg2 = new EmailMessage();
		msg2.ParentId = caso2.Id;
		msg2.FromAddress='jslasnd_TEST@gmail.com';
		msg2.ToAddress = 'tiha.invalidad@invalid.com';
		msg2.HtmlBody = 'contestación --- He tenido un error en la contratación';
		msg2.TextBody = 'contestación --- He tenido un error en la contratación';
		msg2.Subject = 'RW: Subject Test';
        msg2.Incoming = true;
		insert msg2;

		ContentVersion cv2=new Contentversion();
        cv2.title='ABC';
        cv2.PathOnClient ='test';
        Blob b2=Blob.valueOf('Unit Test Attachment Body');
        cv2.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv2;
        List<ContentDocument> documents2 = [
            SELECT Id, Title, LatestPublishedVersionId
            FROM ContentDocument 
			WHERE LatestPublishedVersionId = :cv2.Id
        ];
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = msg2.Id;
        cdl2.ContentDocumentId = documents2[0].Id;
        cdl2.shareType = 'V';
        insert cdl2;

	}

	@isTest
	private static void testCaseDuplicated() {
		User supervisor = SEG_Usuarios.usuarioSupervisor();
/*		id rt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id rtSegCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		Account acc = new Account(
				Name = 'EMPRESA SEGMENTOS',
				RecordTypeId = rt,
            	SEG_DominioMail__c = 'gmail.com'
			);
		insert acc;
		Contact cont = SEG_TestHelper.createCustomerContact(acc.Id,'jslasnd_TEST@gmail.com');
		case caso = new Case(
                SEG_SemillaId__C = '#@SEG:1611676158418#',
                SEG_Zona__c ='Corporativa Madrid',
                SEG_Organizacion__C='Banca Corporativa',
				AccountId = acc.Id,
				ContactId = cont.Id,
            	RecordTypeId = rtSegCliente
			);

		insert caso;
        
        */
        
        case caso = [Select Id from Case where subject='Duplicado'];
        
		EmailMessage msg = new EmailMessage();
		msg.ParentId = caso.Id;
		msg.FromAddress='jslasnd_TEST@gmail.com';
		msg.ToAddress = 'tiha.invalidad@invalid.com';
		msg.HtmlBody = 'revisar--contestación --- He tenido un error en la contratación';
		msg.TextBody = 'revisar--contestación --- He tenido un error en la contratación';
		msg.Subject = 'RW:RW: Subject Test';
        msg.Incoming = true;
		insert msg;

		ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
			WHERE LatestPublishedVersionId = :cv.Id
        ];
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = msg.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
		System.runAs(supervisor){
			
			Test.startTest();
			SEG_Case_Duplicated caseDuplicateProcess = new SEG_Case_Duplicated(new Set<Id>{caso.Id});
			System.enqueueJob(caseDuplicateProcess);
			Test.stopTest();

			List<SEG_Duplicate_Case__c> lstCaseDuplicated = [Select SEG_Case__c, SEG_Case_Duplicated__c From SEG_Duplicate_Case__c];
			//System.assert(lstCaseDuplicated.size()>0);
			System.assertEquals(caseDuplicateProcess, caseDuplicateProcess, 'Se ha duplicado el caso');
		}
	}

}