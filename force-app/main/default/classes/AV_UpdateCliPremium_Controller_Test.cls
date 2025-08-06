/**********************************************************************************************************************
Name:	  AV_UpdateCliPremium_Controller_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase AV_UpdateCliPremium_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Álvaro López	   	   22/10/2020		Init version
1.2			Test Class	   Sandra Gómez	   	   30/11/2020		add method retrieveCustomerDataTestNull
1.3			US157772	   Sandra Gómez		   08/03/2021		add in setup Account
1.4			Fix Cli Pre... Víctor Santiago	   05/10/2021		Added method testGetCliPremiumData
1.5		    AV_Query IT	   Daniel Rodríguez	   07/02/2022	    Change AV_Query to SOQL for User and Account
1.6         US485705       Luis Fernández      09/02/2023       Added  
1.7         US592987		Ángel Medina		30/05/2023		Changed AV_Query to SOQL queries
1.8          QC            Oscar Moreno        12/06/2024       Delete UserInfo.geetUserId()
***********************************************************************************************************************/
@isTest
public with sharing class AV_UpdateCliPremium_Controller_Test {

    @TestSetup
    static void setup(){
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 

        AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition WHERE DeveloperName = 'AV_CRM_Intouch' LIMIT 1];        
		UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = usuarioGcf.Id , FormFactor = 'Small');  
		insert app;
        
        Account dummyAcc = AV_TestHelper.createCustomer();
        //Account center = AV_TestHelper.createCaixaCenter();
        Account center = AV_TestHelper.createCustomerWithNumperson('12345');
        User dummyUser = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
        //Contact contact = AV_TestHelper.createEmployee(center, dummyUser);
        
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        Event lastContactEv = AV_TestHelper.createEvent(dummyUser, System.now().addDays(1), dummyAcc);
        AV_Collective__c colective = new AV_Collective__c(AV_ExternalID__c = '922', Name = 'Test 922');
        Database.insert(colective);
        AV_AzureTeamsToken__c cs = new AV_AzureTeamsToken__c();
        cs.Name = 'AdobeToken';
        cs.AV_ExpiresIn__c = 0; //Zero so cs.LastModifiedDate < now and syncCJ calls login method
        insert cs;
        
        Account acc1 = 	AV_TestHelper.createCustomer2();
        acc1.AV_DataTreatment__c='3';
        acc1.AV_Rentabilidad__c = 11;				
		acc1.AV_Preconceived__c = 23;
		acc1.AV_IngresosPension__c = 43;
		acc1.AV_IngresosPersonales__c = null;
		acc1.AV_IngresosProfesionales__c = null;
		acc1.AV_TargetAuto__c = 'S';
		acc1.AV_Colectivos__c = 'S';
        update acc1;
    }

    @isTest
    private static void retrieveCustomerDataTest(){
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Account acc = [Select Id, AV_NumPerso__c From Account limit 1];
        acc.AV_NumPerso__c = '13550';
        Database.update(acc);
        Event ev = [SELECT Id, StartDateTime, AV_Tipo__c FROM Event LIMIT 1];
        ev.WhatId = acc.Id;
        ev.AV_Tipo__c = '001';
        ev.StartDateTime = System.now();
        Database.update(ev);
        AV_ProductClient__c PFC=AV_TestHelper.createPFCliente();
        PFC.AV_ImportePreconcedido__c=1500;
        PFC.AV_Cliente__c=acc.Id;
        Database.update(PFC);
        RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_ClientePA');
        Account acc2 = new Account(
				FirstName = 'OLGA',
				LastName = 'ROBLES GEA',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '16849239',
				AV_Negocio__c = 'BPA'
			);
		insert acc2;

		Test.startTest();		
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERDATA','OK'));
        String response;
        System.runAs(usuarioGcf){
            response = AV_UpdateCliPremium_Controller.retrieveCustomerData(acc.AV_NumPerso__c, null, null);
        }
        AV_UpdateCliPremium_Controller.updateRecordApex(response,acc.Id);
        Map<String, Object> mapClientToUpdate = (Map<String, Object>)JSON.deserializeUntyped(response);
        AV_UpdateCliPremium_Controller.updateRecordApex(response, acc.Id);
		Test.stopTest();
        System.assertEquals(acc.AV_NumPerso__c, mapClientToUpdate.get('AV_NumPerso__c'));
        System.assertEquals('1.500,00 €',mapClientToUpdate.get('AV_Preconcedidos__c'));
        System.assertEquals('OLGA ROBLES GEA',mapClientToUpdate.get('AV_Interloc__c'));
    }
    
    @isTest
    private static void retrieveCustomerDataTestNull(){
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 
        RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_ClientePA');
		Account acc = new Account(
				FirstName = 'FirstName2',
				LastName = 'LastName2',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '13550',
				AV_Negocio__c = null
			);
		insert acc;
        AV_ProductClient__c PFC=AV_TestHelper.createPFCliente();
        PFC.AV_ImportePreconcedido__c=0;
        PFC.AV_Cliente__c=acc.Id;
        Database.update(PFC);

		Test.startTest();		
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERDATA2','OK'));
        String response; 
        System.runAs(usuarioGcf){
            response = AV_UpdateCliPremium_Controller.retrieveCustomerData(acc.AV_NumPerso__c, null, null);
        }
        Map<String, Object> mapClientToUpdate = (Map<String, Object>)JSON.deserializeUntyped(response);
		Test.stopTest();
        System.assertEquals(acc.AV_NumPerso__c, mapClientToUpdate.get('AV_NumPerso__c'));
        System.assertEquals(null,mapClientToUpdate.get('AV_Preconcedidos__c'));
        System.assertEquals('Interlocutor de grupo de clientes',mapClientToUpdate.get('AV_Interloc__c'));
    }
    
    @isTest
    public static void testGetCustomerJourneys() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 

        Account acc = [SELECT Id FROM Account Limit 1];
        Test.startTest();
        Map<String, HttpCalloutMock> header2TestResp =
                                   new Map<String,HttpCalloutMock>();
        header2TestResp.put('"xtk:session#Logon"',new AV_MockCallout_Test('CJ_Login','OK'));
        header2TestResp.put('"nms:recipient#lookUpCJ"',new AV_MockCallout_Test('CJ_LookUpList','OK'));
         header2TestResp.put('"nms:recipient#marketing360"',new AV_MockCallout_Test('CJ_Marketing360','OK'));
 
        HttpCalloutMock multiCalloutMock =
                                   new AV_MultiRequestMock_Test(header2TestResp);
 
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        String result;
        System.runAs(usuarioGcf){
            result = AV_UpdateCliPremium_Controller.getCustomerJourney(String.valueOf(acc.Id));
        }
        Test.stopTest();
        System.assertNotEquals('OK', result);

    }

    @isTest
    public static void testGetCliPremiumData() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 

        //
        RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_ClientePA');
		Account acc = new Account(
				FirstName = 'FirstName3',
				LastName = 'LastName3',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '13551',
				AV_Negocio__c = null,
                AV_FechaRefrescoClientePremium__c = System.today(),
                AV_JSONClientePremium__c = null
			);
		insert acc;
        
        //
        //Account acc = [Select Id, AV_Confidencial__c, AV_NumPerso__c From Account Where FirstName = 'FirstName' and AV_NumPerso__c = '12345' limit 1];
        acc.AV_NumPerso__c = '13550';
        Database.update(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_CUSTOMMERDATA','OK'));
        String response;  
        System.runAs(usuarioGcf){
            response = AV_UpdateCliPremium_Controller.getCliPremiumData(acc.Id);
            
        }
        Map<String, Object> mapClientToUpdate = (Map<String, Object>)JSON.deserializeUntyped(response);
        Test.stopTest();
        System.assertEquals(acc.AV_NumPerso__c, mapClientToUpdate.get('AV_NumPerso__c'));
    }
    
    @isTest
    public static void testValidateTreatmentData(){
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 

        Account acc1= [Select id,AV_DataTreatment__c,AV_Rentabilidad__c,AV_Preconceived__c,AV_IngresosPension__c,AV_IngresosPersonales__c,AV_IngresosProfesionales__c,AV_TargetAuto__c,AV_Colectivos__c,AV_LoyaltySignals__c  from Account where AV_Negocio__c = 'BPA'  limit 1];
        Account acc2 = [SELECT Id,AV_DataTreatment__c FROM Account WHERE AV_DataTreatment__c = '3'];
        acc1.AV_DataTreatment__c = '2'; 
        Database.update(acc1);  
        Test.startTest();
        System.runAs(usuarioGcf){
            AV_UpdateCliPremium_Controller.validateTreatmentData(acc1.id);
            AV_UpdateCliPremium_Controller.validateTreatmentData(acc2.id);
        }

        Test.stopTest();
       
        System.assert(acc1.AV_LoyaltySignals__c == null);
        
    }
}