/**********************************************************************************************************************
Name:	  CIBE_UpdateCliPremium_Controller_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase CIBE_UpdateCliPremium_Controller_Test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Álvaro López	   	   22/10/2020		Init version
1.2			Test Class	   Sandra Gómez	   	   30/11/2020		add method retrieveCustomerDataTestNull
1.3			US157772	   Sandra Gómez		   08/03/2021		add in setup Account
1.4			Fix Cli Pre... Víctor Santiago	   05/10/2021		Added method testGetCliPremiumData
1.5		    AV_Query IT	   Daniel Rodríguez	    07/02/2022	    Change AV_Query to SOQL for User and Account
1.6                        Alexandre Perez     21/06/2023       Eliminar adobeCampaign
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_UpdateCliPremium_Controller_Test {

    @TestSetup
    static void setup(){
        /*AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition WHERE DeveloperName = 'AV_CRM_Intouch' LIMIT 1];        
		UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = UserInfo.getUserId(), FormFactor = 'Small');
		insert app;*/

        List<CBK_IntegrationSetting__c> listEndpointConf = new list<CBK_IntegrationSetting__c>();
        CBK_IntegrationSetting__c endpointConf = new CBK_IntegrationSetting__c(Name='getCustomers', NamedCredential__c = 'getCustomers');
        listEndpointConf.add(endpointConf);
        insert listEndpointConf;


        Account dummyAcc = AV_TestHelper.createCustomer();
        Account center = AV_TestHelper.createCaixaCenter();
        User dummyUser = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
        Contact contact = AV_TestHelper.createEmployee(center, dummyUser);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        Event lastContactEv = AV_TestHelper.createEvent(dummyUser, System.now().addDays(1), dummyAcc);
        AV_Collective__c colective = new AV_Collective__c(AV_ExternalID__c = '922', Name = 'Test 922');
        Database.insert(colective);
        AV_AzureTeamsToken__c cs = new AV_AzureTeamsToken__c();
        cs.Name = 'AdobeToken';
        cs.AV_ExpiresIn__c = 0; //Zero so cs.LastModifiedDate < now and syncCJ calls login method
        insert cs;
    }

    @isTest
    private static void retrieveCustomerDataTest(){
        Account acc = [Select Id, AV_NumPerso__c From Account limit 1];
        CIBE_UpdateCliPremium_Controller.WrapperResponse response = new   CIBE_UpdateCliPremium_Controller.WrapperResponse();

        //Account acc = (Account) new AV_Query('Account').selectFields('Id, AV_NumPerso__c').setLimit(1).fetch();
        acc.AV_NumPerso__c = '13550';
        Database.update(acc);
        Event ev = (Event) new AV_Query('Event').selectFields('Id, StartDateTime, AV_Tipo__c').setLimit(1).fetch();
        ev.WhatId = acc.Id;
        ev.AV_Tipo__c = '001';
        ev.StartDateTime = System.now();
        Database.update(ev);
        AV_ProductClient__c pfc=AV_TestHelper.createPFCliente();
        PFC.AV_ImportePreconcedido__c=1500;
        PFC.AV_Cliente__c=acc.Id;
        Database.update(PFC);
        RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_ClientePA');
        Account acc2 = new Account(
				FirstName = 'OLGA',
				LastName = 'ROBLES GEA',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '1670',
				AV_Negocio__c = 'BPA'
			);
		insert acc2;
        Date todayDate = date.today().addDays(-6);

        User usrTest = [SELECT ID FROM USER LIMIT 1];  

		Test.startTest();		
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('EXTENDED','OK'));
        System.runAs(usrTest) {

            response = CIBE_UpdateCliPremium_Controller.retrieveCustomerData(acc.AV_NumPerso__c, todayDate, null);
                }		Test.stopTest();

                system.debug([SELECT cibe_cirbe__c FROM Account where id = : acc.id].cibe_cirbe__c);
        System.debug('get retrieveCustomerData -->' + response);


        System.assertEquals(acc.AV_NumPerso__c, String.valueOf(response.customerData.customerInternalId));
       
    }
    
    @isTest
    private static void retrieveCustomerDataTestNull(){
        RecordType rt = AV_AppUtilities.getRecordType('Account', 'CC_ClientePA');
        CIBE_UpdateCliPremium_Controller.WrapperResponse response = new   CIBE_UpdateCliPremium_Controller.WrapperResponse();
        CIBE_UpdateCliPremium_Controller.WrapperResponse emptyResponse = new   CIBE_UpdateCliPremium_Controller.WrapperResponse();
        User usrTest = [SELECT ID FROM USER LIMIT 1];  

		Account acc = new Account(
				FirstName = 'FirstName2',
				LastName = 'LastName2',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '13550',
				AV_Negocio__c = null
			);
		insert acc;
        AV_ProductClient__c pfc=AV_TestHelper.createPFCliente();
        PFC.AV_ImportePreconcedido__c=0;
        PFC.AV_Cliente__c=acc.Id;
        Database.update(PFC);
        Date todayDate = date.today().addDays(-6);

		Test.startTest();		
		    Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('EXTENDED','OK'));
            System.runAs(usrTest) {
            response = CIBE_UpdateCliPremium_Controller.retrieveCustomerData(null, todayDate, null);
            //CIBE_UpdateCliPremium_Controller.updateAccount(response);
            }
		Test.stopTest();
        system.debug([SELECT cibe_cirbe__c FROM Account where id = : acc.id].cibe_cirbe__c);
        system.debug([SELECT av_cirbefee__c FROM Account where id = : acc.id].av_cirbefee__c);
        system.debug(response.customerData);
        System.assertEquals(null,response.customerData);
    }
    
   /* @isTest
    public static void testGetCustomerJourneys() {
        User usrTest = [SELECT ID FROM USER LIMIT 1];  

        Account acc = [SELECT Id FROM Account Limit 1];
        String result = '';
        Test.startTest();
        Map<String, HttpCalloutMock> header2TestResp =
                                   new Map<String,HttpCalloutMock>();
        header2TestResp.put('"xtk:session#Logon"',new AV_MockCallout_Test('CJ_Login','OK'));
        header2TestResp.put('"nms:recipient#lookUpCJ"',new AV_MockCallout_Test('CJ_LookUpList','OK'));
         header2TestResp.put('"nms:recipient#marketing360"',new AV_MockCallout_Test('CJ_Marketing360','OK'));
 
        HttpCalloutMock multiCalloutMock =new AV_MultiRequestMock_Test(header2TestResp);
 
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        System.runAs(usrTest) {
             result = CIBE_UpdateCliPremium_Controller.getCustomerJourney(String.valueOf(acc.Id));
        }
        Test.stopTest();
        System.assert(true,String.isBlank(result));

    }*/

    @isTest
    public static void testGetCliPremiumData() {
        User usrTest = [SELECT ID FROM USER LIMIT 1];  

        CIBE_UpdateCliPremium_Controller.WrapperResponse response = new   CIBE_UpdateCliPremium_Controller.WrapperResponse();

        Account acc = [Select Id, AV_Confidencial__c, AV_NumPerso__c From Account Where FirstName = 'FirstName' and AV_NumPerso__c = '123' limit 1];
        /*Account acc = (Account) new AV_Query('Account')
                        .selectFields('Id, AV_Confidencial__c, AV_NumPerso__c')
                        .addConditionEq('FirstName', 'FirstName')
                        .addConditionEq('AV_NumPerso__c', '123')
                        .fetch();*/
        acc.AV_NumPerso__c = '13550';
        Database.update(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('EXTENDED','OK'));
        System.runAs(usrTest) {
            response = CIBE_UpdateCliPremium_Controller.getCliPremiumData(acc.Id);
        }
        Test.stopTest();
        System.debug('get Cli Premium Data Response -->' + response);
   
        System.assertEquals(acc.AV_NumPerso__c,  String.valueOf(response.customerData.customerInternalId));
    }

    @isTest
    public static void testGetCliPremiumDataEmptyBalance() {
        User usrTest = [SELECT ID FROM USER LIMIT 1];  

        CIBE_UpdateCliPremium_Controller.WrapperResponse response = new   CIBE_UpdateCliPremium_Controller.WrapperResponse();

        Account acc = [Select Id, AV_Confidencial__c, AV_NumPerso__c From Account Where FirstName = 'FirstName' and AV_NumPerso__c = '123' limit 1];
        /*Account acc = (Account) new AV_Query('Account')
                        .selectFields('Id, AV_Confidencial__c, AV_NumPerso__c')
                        .addConditionEq('FirstName', 'FirstName')
                        .addConditionEq('AV_NumPerso__c', '123')
                        .fetch();*/
        acc.AV_NumPerso__c = '13550';
        Database.update(acc);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('EXTENDED_EMPTY_BALANCE','OK'));
        System.runAs(usrTest) {
            response = CIBE_UpdateCliPremium_Controller.getCliPremiumData(acc.Id);
        }
        Test.stopTest();
        System.debug('get Cli Premium Data Response -->' + response);
   
        System.assertEquals(acc.AV_NumPerso__c,  String.valueOf(response.customerData.customerInternalId));
    }
}