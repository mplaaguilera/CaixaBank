/**********************************************************************************************************************
Name:	  AV_AccountTriggerHelper_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_AccountTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Álvaro López	   	   07/10/2020		Init version
1.1         Val. Sprints   Víctor Santiago     08/02/2021       Changed MATRICULA_SAMPLE to matriculaSample
1.2			US180910	   Sandra Gómez		   02/03/2021		Add method executeAccountTriggerUpdatingOficinaPrincipalRelacionas
1.3			Fix Confide... Víctor Santiago	   05/10/2021		Added method executeUpdateOppConfidentiality
1.4		    AV_Query IT	   Daniel Rodríguez	   04/02/2022	    Change AV_Query to SOQL for User and Account
***********************************************************************************************************************/
@isTest
public with sharing class AV_AccountTriggerHelper_Test {
    @TestSetup
    static void setup(){
        Account acc = AV_TestHelper.createCustomerWithComment();
        List<CBK_ForbiddenWord__c> listDummyWords = new List<CBK_ForbiddenWord__c>();
        CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
        listDummyWords.add(word);
        CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CAUCASIC', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
        listDummyWords.add(word2);
        Database.insert(listDummyWords, false);

        AV_TestHelper.activateLogger();
        String matriculaSample = 'U0009003';
        String labelProfile;
        if (String.isBlank(labelProfile)){
            labelProfile = 'Standard User';
        }
        List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
        Profile p = (Profile)result.get(0);
        User u1 = new User(
            Alias = 'tsAlias',
            Email = 'testdevdev@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            ProfileId = p.Id,
            UserName = 'testdevdev@test.com.dev',
            AV_ExternalID__c = matriculaSample
        );
        insert u1;
        Contact c =  AV_TestHelper.createEmployee(null,u1);
        Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
        insert pb;
        Datetime currentDateTime = Datetime.now();
        Event eventTest = AV_TestHelper.createEventConCliente(u1, currentDateTime, acc);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_CAMBIOEMPLEADO','OK'));
        
        
       
       
        Lead l = AV_TestHelper.createLead();
        AV_LeadOpportunity__c lo = AV_TestHelper.createLeadOpportunity(l);
    }

    /**
	 * Execute the Trigger class (AV_Account_BI_TRHan) and check if the Ultima Actualización date has been inserted correctly.
	 */
	@isTest
	public static void executeAccountTrigger() {
		Test.startTest();
		Account cienteCreado = [select AV_FechaUltimaActualizacion__c from Account Limit 1];
        Test.stopTest();
		System.assertNotEquals(null, cienteCreado.AV_FechaUltimaActualizacion__c);
    }
    

    /**
	 * Execute the Trigger class (AV_Account_BU_TRHan) and check if the Ultima Actualización date has been inserted correctly.
	 */
	@isTest
	public static void executeAccountTriggerUpdate() {
		Test.startTest();
		Account cienteCreadoOld = [select AV_FechaUltimaActualizacion__c,Description  from Account Limit 1];
		Datetime clienteCreadoOld = cienteCreadoOld.AV_FechaUltimaActualizacion__c;
		cienteCreadoOld.Description = 'Este cliente de prueba esta siendo testeado con un nuevo comentario';
		Database.update(cienteCreadoOld);
		Account cienteUpdated = [select AV_FechaUltimaActualizacion__c from Account where Id = :cienteCreadoOld.Id];
        Test.stopTest();
		System.assertNotEquals(clienteCreadoOld, cienteUpdated.AV_FechaUltimaActualizacion__c);
	}
	
	/**
	 * Execute the Trigger class (AV_Account_BU_TRHan) and check if the Ultima Actualización date has been inserted correctly.
	 */
	@isTest
	public static void executeAccountTriggerUpdatingDate() {
		Test.startTest();
		Account cienteCreadoOld = [select AV_FechaUltimaActualizacion__c from Account Limit 1];
		Datetime clienteCreadoOld = cienteCreadoOld.AV_FechaUltimaActualizacion__c;
		cienteCreadoOld.AV_FechaUltimaActualizacion__c = Date.today() + 5;
		Database.update(cienteCreadoOld);
		Account cienteUpdated = [select AV_FechaUltimaActualizacion__c from Account where Id = :cienteCreadoOld.Id];
        Test.stopTest();
		System.assertNotEquals(clienteCreadoOld, cienteUpdated.AV_FechaUltimaActualizacion__c);
    }
    

    /**
	 * Execute the Trigger class (AV_Account_BU_TRHan) and check if the EAP Gestor has been modified correctly.
	 */
	@isTest
	public static void executeAccountTriggerUpdatingEAPGestor() {
		User usrTest = [select Id from User limit 1];
        AV_GestorReassignmentQueueable.doChainJob = false;
        Account cienteCreadoOld = [select Id, AV_EAPGestor__c from Account Limit 1];
        Contact c = [Select id from Contact Where AV_UsuarioAsociado__c != null];
		cienteCreadoOld.AV_EAPGestor__c = c.Id;
		update cienteCreadoOld;
        Account cienteUpdated = [select AV_EAPGestor__c from Account where Id = :cienteCreadoOld.Id];
        String externalId = '12345';
        Test.startTest();
        Task tskTest = AV_TestHelper.createTareaExternalId(usrTest, externalId);
        tskTest.WhatId = cienteCreadoOld.Id;
        update tskTest;
        AV_TestHelper.createOpportunityWithEmpleado(cienteCreadoOld, c);
        Test.stopTest();
		System.assertNotEquals(null, cienteUpdated.AV_EAPGestor__c);
    }
    
    @isTest
	public static void executeAccountTriggerUpdatingOficinaPrincipalRelacionas() {
        Test.startTest();
        RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_CentroCaixaBank');
		Account centroCaixa = new Account();
		centroCaixa.Name = '00615 STORE DOS DE MAIG-ROSSELLO';
		centroCaixa.CC_Numero_Oficina_Empresa__c = '001-00615';
		centroCaixa.CC_Numero_Oficina__c = '00615';
		centroCaixa.RecordTypeId = rt.Id;
		insert centroCaixa;
        RecordType rt2 = AV_AppUtilities.getRecordType('Account', 'CC_ClientePA');
		Account acc = new Account(
				FirstName = 'FirstName',
				LastName = 'LastName',
				RecordTypeId = rt2.Id,
				AV_NumPerso__c = '1235',
				AV_Negocio__c = 'BPA',
            	AV_OficinaPrincipal__c = centroCaixa.Id
			);
		insert acc;
        Account accUpdated = [select AV_OficinaPrincipalRelacionas__c from Account where Id = :acc.Id];
		Test.stopTest();
        System.assertNotEquals(null, accUpdated.AV_OficinaPrincipalRelacionas__c);
    }

    @isTest
    public static void executeUpdateOppConfidentiality() {
        Account acc = [Select Id, AV_Confidencial__c From Account Where FirstName = 'FirstName' and AV_NumPerso__c = '123' limit 1];
        /*Account acc = (Account) new AV_Query('Account')
                        .selectFields('Id, AV_Confidencial__c')
                        .addConditionEq('FirstName', 'FirstName')
                        .addConditionEq('AV_NumPerso__c', '123')
                        .fetch();*/
        AV_TestHelper.createOpportunity(acc);
        Test.startTest();
        acc.AV_Confidencial__c = true;
        Database.update(acc);
        Test.stopTest();
        List<Opportunity> opps = [Select Id, AV_ClienteConfidencial__c From Opportunity Where Name = 'Alerta Comercial'];
        /*List<Opportunity> opps = new AV_Query('Opportunity')
                        .selectFields('Id, AV_ClienteConfidencial__c')
                        .addConditionEq('Name', 'Alerta Comercial')
                        .run();*/
                        System.debug('opps --> ' + opps);
        Opportunity opp = [Select Id, AV_ClienteConfidencial__c From Opportunity Where Name = 'Alerta Comercial' and CloseDate = :(System.today() + 5) and AV_ExternalID__c != '00000001' limit 1];
        /*Opportunity opp = (Opportunity) new AV_Query('Opportunity')
                        .selectFields('Id, AV_ClienteConfidencial__c')
                        .addConditionEq('Name', 'Alerta Comercial')
                        .addConditionEq('CloseDate', (System.today() + 5))
                        .addConditionNotEq('AV_ExternalID__c', '00000001')
                        .fetch();*/
        System.assertEquals(true, opp.AV_ClienteConfidencial__c == acc.AV_Confidencial__c, 'Confidentiality was not updated.');
    }
    
   

    @isTest
    public static void executeRelatedAccountAndLead() {
        
        RecordType rtPAccountTest = AV_AppUtilities.getRecordType('Account', 'CC_ClientePA');
       
        Lead lOld =  [SELECT Id, AV_CustomerId__c, AV_Birthdate__c, AV_IsClient__c from Lead WHERE AV_CustomerId__c = '00000000Z' LIMIT 1];
        AV_LeadOpportunity__c lo = [SELECT Id from AV_LeadOpportunity__c WHERE AV_Lead__c=:lOld.Id LIMIT 1];
        
        Account accountTest = new Account();
        accountTest.PersonBirthdate = Date.newInstance(1968, 12, 09);
        accountTest.AV_Cliente__c = true;
        accountTest.CC_Numero_Documento__c = '00000000Z';
        accountTest.FirstName = 'FirstName';
        accountTest.LastName = 'LastName';
        accountTest.RecordTypeId = rtPAccountTest.Id;
        
        Test.startTest();
        insert accountTest;
        Test.stopTest();
		Lead lNew =  [SELECT Id, AV_CustomerId__c, AV_Birthdate__c, AV_IsClient__c from Lead WHERE AV_CustomerId__c = '00000000Z' LIMIT 1];
        System.assertEquals(lNew.AV_IsClient__c, true);
    }
}