/**********************************************************************************************************************
Name:	  AV_Header_Controller_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_Header_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
    VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0			Test Class		Ángel Medina		28/06/2023		Init version. Copy the CIBE_Header_Controller_Test class from CIBE 
    1.1		    Fix PMD Errors	Daniel Rodriguez	24/11/2023	    Modify test method getAccountInfoTest
-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/

@isTest
public with sharing class AV_Header_Controller_Test {
    
    private static final String FILTER_SOBJECT	= 'Account';
    private static final String FIELDSET_NAME	= 'AV_FlexiHeader';

    @TestSetup
    static void setup(){
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
        AV_TestHelper.insertNeededPermissions(userGestor);

        String pea = 'Acceso operativa{|}https://l.tf7.lacaixa.es/TF7WebUtilities/redirect/test';
        String pea2 = '01{|}Acceso operativa{|}https://l.tf7.lacaixa.es/TF7WebUtilities/redirect/test';
        String pea3 = '02{|}Acceso operativa{|}https://google.com';

        List<Account> listAccounts = new List<Account>();
        System.runAs(userGcf){
            Account centro = AV_TestHelper.createCaixaCenterSinInsert();
            centro.OwnerId = userGestor.Id;
            
            Test.startTest();
            Account acc = AV_TestHelper.createCustomerSinInsert();
            acc.OwnerId = userGestor.Id;
            acc.AV_NumPerso__c = '123';

            listAccounts.add(centro);
            listAccounts.add(acc);
            Database.insert(listAccounts,false);
            Contact contact = AV_TestHelper.createEmployee(listAccounts[0], userGestor,userGestor.AV_ExternalId__c);   
            Event eventoCliente = AV_TestHelper.createEvent(userGestor, DateTime.now(), listAccounts[1]);
        }
               
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK')); 
		
    }

    @isTest
    private static void getNameTest() {
        User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        
        Test.startTest();
        System.runAs(us){
           Account acc = [select id from account limit 1]; 
           String valorCampo = AV_Header_Controller.getName(acc.id,'name');
           System.assertEquals(true ,valorCampo != Null , 'KO');  
        }
		Test.stopTest();  
    }
  
    @isTest
    private static void getActionsTest() {
        User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        Map<String, AV_FlowActions__mdt> uniqueActions = new Map<String, AV_FlowActions__mdt>();
        for (AV_FlowActions__mdt action : [SELECT Id, Label, AV_FlowName__c FROM AV_FlowActions__mdt WHERE AV_Setting__c = 'AV_Account']) {
            if (!uniqueActions.containsKey(action.Label)) {
                uniqueActions.put(action.Label, action);
            }
        }

        Test.startTest();
        System.runAs(us) {
            List<AV_Header_Controller.Action> actionf = AV_Header_Controller.getActions('AV_Account');
            System.assertEquals(actionf.size() > 0, true, 'KO');
        }
        Test.stopTest();
    }

    @isTest
    private static void getFieldsTest() {
        User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        
        Test.startTest();
        System.runAs(us){
        Account acc = [select id from account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1]; 
        Event evt = [select id from Event limit 1];
        List<Object> listField= AV_Header_Controller.getFields(acc.id, 'AV_FlexiHeader');
        List<Object> listField2= AV_Header_Controller.getFields(evt.id, 'AV_HeaderFields');
        System.assertEquals(true, !listField2.isEmpty(), 'KO'); 
        }
 		Test.stopTest();  
    }
    
    @isTest
    private static void getAccountInfoTest(){
        User us = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        Account accCliente = [SELECT Id, Name, RecordType.DeveloperName FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT LIMIT 1];
		Contact cont =[SELECT Id, AV_NumPerso__c FROM Contact LIMIT 1];
        Event event = [SELECT Id FROM Event WHERE WhatId = :accCliente.Id];

        Test.startTest();
        System.runAS(us){
            Map<String, String> accountInfo = AV_Header_Controller.getAccountInfo(event.Id, null);
            Map<String,String> accountInfo1 = AV_Header_Controller.getAccountInfo(accCliente.Id, cont.AV_NumPerso__c);
            System.assertNotEquals(null, accountInfo.size(), 'KO');
            System.assertNotEquals(null, accountInfo1.size(), 'KO');

        }
        Test.stopTest();
        
    }   
}