@isTest
private class SAC_EmailMessage_BI_TRHan_Test{

	@testSetup
	static void testDummy(){

		User usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
		SAC_DatabaseDML.insertDML(usuario, false);
        //Database.insert(usuario);
	}

	@isTest
	static void test(){
		User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
		SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            string rtId3 = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
			Case caso =  new Case();
			caso.Origin = 'Email';
			caso.Description = 'test1';
			caso.RecordTypeId = rtId3;
			SAC_DatabaseDML.insertDML(caso, false);
			//Database.insert(caso);

			EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
			String headerValueSTR = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

			List<EmailMessage> lst =  new List<EmailMessage>();
			EmailMessage correo = new EmailMessage();
			correo.ParentId = caso.Id;
			correo.RelatedToId = caso.Id;
			correo.Incoming = false;
			correo.Subject = 'EMAILCASO3';
			correo.TextBody = 'EMAILCASO3';
			correo.FromAddress = 'Test@test.com';
			correo.ToAddress = 'prueba@ibm.com';
			correo.Headers = '[{"value": "' + headerValueSTR + '","name": "X-SDFC-Original-RCPT"}]';
			SAC_DatabaseDML.insertDML(correo, false);
			//Database.insert(correo);	
			
			System.assertNotEquals(null, correo.Subject, 'correo');
        }
        Test.stopTest();
	}
}