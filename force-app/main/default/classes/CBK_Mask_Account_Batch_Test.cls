/**********************************************************************************************************************
 Name:	  CBK_Mask_Account_Batch_Test
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para la clase CBK_Mask_Account_Batch del framework de registro de enmascaramiento.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	26/05/2021			Init version
***********************************************************************************************************************/
@IsTest private with sharing class CBK_Mask_Account_Batch_Test {
    /**
    * @description Método de setup de datos para los test 
    * @author   fzaragoza | 14/06/2021 
    **/
    @testSetup static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            Account acc = new Account();
            acc.FirstName = 'Prueba';
            acc.LastName = 'Test ' + i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Particular').getRecordTypeId();
            testAccts.add(acc);
        }
        insert testAccts;
        List<Account> testAccts2 = new List<Account>();
        for(Integer i=0;i<1;i++) {
            Account acc = new Account();
            acc.Name = 'centro ' + i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Centro CaixaBank').getRecordTypeId();
            testAccts2.add(acc);
        }
        insert testAccts2;
        // Alta de datos para la prueba
        Account acc = new Account();
		acc.FirstName = 'Prueba';
        acc.LastName = 'Test';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        acc.CC_Numero_Documento__c = '45855598S';
        acc.CC_NumPerso__c = '533752';
        insert acc;
    }
	/**
    * @description Método de test para validar la invocación del batch
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void  testBatch() {
        Test.StartTest();
        CBK_Mask_Account_Batch batch = new CBK_Mask_Account_Batch();
		Database.executeBatch(batch);
        Test.stopTest();
    }
    /**
    * @description Método de test para validar la invocación del batch
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void  testBatchLimit() {
        Test.StartTest();
        CBK_Mask_Account_Batch batch = new CBK_Mask_Account_Batch('100');
		Database.executeBatch(batch);
        Test.stopTest();
    }

    /**
    * @description Método de test para validar la invocación del batch
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void  testBatchModulo() {
        Test.StartTest();
        CBK_Mask_Account_Batch batch = new CBK_Mask_Account_Batch(0,3);
		Database.executeBatch(batch);
        Test.stopTest();
    }
    
    /**
    * @description Método de test para validar la invocación del batch
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void  testBatchLimitMododule() {
        Test.StartTest();
        CBK_Mask_Account_Batch batch = new CBK_Mask_Account_Batch('100',0,3);
		Database.executeBatch(batch);
        Test.stopTest();
    }

}