@isTest
public with sharing class SEG_Contact_BI_TRHan_Test {

    private Static Id accountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
    private Static Id contactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

    @testSetup
	static void makeData(){

         Profile p = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
         UserRole r = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
         User thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com', 
                emailencodingkey='UTF-8', lastname='Smith', 
                languagelocalekey='en_US', 
                localesidkey='en_US', profileid = p.Id, userroleid = r.Id,
                timezonesidkey='America/Los_Angeles', 
                username='testSEGBI@acme.com');
        insert thisUser;
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Operativo'];
		insert new PermissionSetAssignment(AssigneeId = thisUser.id, PermissionSetId = ps.Id);

        System.runAs (thisUser) {
        
		Account cuentaSEG = new Account();
		cuentaSEG.RecordTypeId = accountRT;
		cuentaSEG.Name = 'Empresa segmentos';
		cuentaSEG.SEG_DominioMail__c = '@cuentaSEG';
		cuentaSEG.CC_Numero_Documento__c = '11111111H';
		insert cuentaSEG;

		Contact contactoSEG = new Contact();
		contactoSEG.RecordTypeId = contactRT;
		contactoSEG.LastName = 'Contacto SEG 1';
		contactoSEG.AccountId = cuentaSEG.Id;
		contactoSEG.Email = 'test@test.com';
		insert contactoSEG;
	}
	}

    @IsTest
	static void validarDuplicidadTest(){

		User thisUser = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs (thisUser) {
        Account cuentaTest = [SELECT Id FROM Account WHERE Name = 'Empresa segmentos' LIMIT 1];
		
        Contact contactoTest = new Contact();
		contactoTest.RecordTypeId = contactRT;
		contactoTest.LastName = 'Contacto SEG Test';
		contactoTest.AccountId = cuentaTest.Id;
		contactoTest.Email = 'test@test.com';

        try {
            Test.startTest();
            insert contactoTest;
		    Test.stopTest();
        } catch (Exception e) {
            System.assertEquals(e.getMessage().contains('No se puede crear el contacto. Ya existe un contacto en la misma cuenta con el mismo email.'), true, 'El contacto se ha insertado cuando no debería poderse.');
        }
	}
}}