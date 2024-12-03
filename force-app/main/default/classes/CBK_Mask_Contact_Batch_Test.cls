/**********************************************************************************************************************
 Name:	  CBK_Mask_Contact_Batch_Test
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para la clase CBK_MaskUtilities del framework de registro de enmascaramiento.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	26/05/2021			Init version
***********************************************************************************************************************/
@IsTest private with sharing class CBK_Mask_Contact_Batch_Test {
    /**
    * @description Método de setup de datos para los test 
    * @author   fzaragoza | 14/06/2021 
    **/
    @testSetup static void setup() {
        // Create common test accounts
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            Account acc = new Account();
            acc.Name = 'Prueba Test ' + i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            testAccts.add(acc);
        }
        insert testAccts;
        Account acc = [SELECT Id FROM Account Limit 1];
        Id colaboradorContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        List <Contact> lstCtcs = new List <Contact> ();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = colaboradorContactRT;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = acc.ID;
        lstCtcs.add(cnt1);
        Contact cnt2 = new Contact();
        cnt2.recordtypeId = colaboradorContactRT;
        cnt2.lastname = 'cnt2';
        cnt2.email = 'Atest@test.com';
        cnt2.AccountId = acc.ID;
        lstCtcs.add(cnt2);
        Contact cnt3 = new Contact();
        cnt3.recordtypeId = colaboradorContactRT;
        cnt3.lastname = 'cnt3';
        cnt3.email = 'Btest@test.com';
        cnt3.AccountId = acc.ID;
        lstCtcs.add(cnt3);
        insert lstCtcs;
    }
	/**
    * @description Método de test para validar la invocación del batch
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void  testBatch() {
        Test.StartTest();
        CBK_Mask_Contact_Batch batch = new CBK_Mask_Contact_Batch();
		Database.executeBatch(batch);
        Test.stopTest();
    }
    /**
    * @description Método de test para validar la invocación del batch
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void  testBatchLimit() {
        Test.StartTest();
        CBK_Mask_Contact_Batch batch = new CBK_Mask_Contact_Batch('100');
		Database.executeBatch(batch);
        Test.stopTest();
    }
    /**
    * @description Método de test para validar la invocación del batch con rango
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void  testBatchRange() {
        Map<String, String> rangeBatch = new Map<String, String>();
        String firstID = String.valueOf([Select Id from contact order by ID ASC Limit 1].Id);
        String lastID = String.valueOf([Select Id from contact order by ID DESC Limit 1].Id);
        rangeBatch.put('first',firstID);
        rangeBatch.put('last',lastID);
        Test.StartTest();
        CBK_Mask_Contact_Batch batch = new CBK_Mask_Contact_Batch(rangeBatch);
		Database.executeBatch(batch);
        Test.stopTest();
    }
    /**
    * @description Método de test para validar la invocación del batch
    * @author   fzaragoza | 21/07/2021 
    **/
    @IsTest static void  testBatchLimitModulo() {
        Test.StartTest();
        CBK_Mask_Contact_Batch batch = new CBK_Mask_Contact_Batch('100',0,2);
		Database.executeBatch(batch);
        Test.stopTest();
    }
    /**
    * @description Método de test para validar la invocación del batch con rango
    * @author   fzaragoza | 21/07/2021 
    **/
    @IsTest static void  testBatchRangeModulo() {
        Map<String, String> rangeBatch = new Map<String, String>();
        String firstID = String.valueOf([Select Id from contact order by ID ASC Limit 1].Id);
        String lastID = String.valueOf([Select Id from contact order by ID DESC Limit 1].Id);
        rangeBatch.put('first',firstID);
        rangeBatch.put('last',lastID);
        Test.StartTest();
        CBK_Mask_Contact_Batch batch = new CBK_Mask_Contact_Batch(rangeBatch,0,2);
		Database.executeBatch(batch);
        Test.stopTest();
    }
}