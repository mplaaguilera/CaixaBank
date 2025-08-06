/**********************************************************************************************************************
 Name:	  CBK_Mask_Batch_Test
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para la clase CBK_MaskUtilities del framework de registro de enmascaramiento.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	26/05/2021			Init version
***********************************************************************************************************************/
@IsTest private with sharing class CBK_Mask_Batch_Test {
    /**
    * @description Método de setup de datos para los test 
    * @author   fzaragoza | 14/06/2021 
    **/
    @testSetup static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            Account acc = new Account();
            acc.Name = 'Prueba Test ' + i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            testAccts.add(acc);
        }
        insert testAccts;
    }
	/**
    * @description Método de test para validar la invocación del batch
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void  testBatch() {
        Test.StartTest();
        CBK_Mask_Batch batch = new CBK_Mask_Batch();
		Database.executeBatch(batch);
        Test.stopTest();
    }
    /**
    * @description Método de test para validar la invocación del batch
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void  testBatchLimit() {
        Test.StartTest();
        CBK_Mask_Batch batch = new CBK_Mask_Batch(100);
		Database.executeBatch(batch);
        Test.stopTest();
    }
    /**
    * @description Método de test para validar la invocación del batch
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void  testBatchDetail() {
        Test.StartTest();
        CBK_Mask_Batch batch = new CBK_Mask_Batch('Account',0,false,null,true);
		Database.executeBatch(batch);
        Test.stopTest();
    }
    /**
    * @description Método de test para validar la invocación del batch
    * @author   fzaragoza | 14/06/2021 
    **/
    @IsTest static void  testBatchObject() {
        Test.StartTest();
        CBK_Mask_Batch batch = new CBK_Mask_Batch('Account',10,false);
		Database.executeBatch(batch);
        Test.stopTest();
    }
    	/**
    * @description Método de test para validar la invocación de la funcionalidad de valorIdSiguiente
    * @author   fzaragoza | 21/07/2021 
    **/
	@SuppressWarnings('PMD.AvoidHardcodingId')
    @IsTest static void testValorIdSiguiente() {
		List<Map<String, String>> chunkList = CBK_MaskUtilities.chunkIDRange('00Q5r000001BX2JEAW', '00Q5r000001Iv0LEAS', 1000000);
		Id lastId = CBK_Mask_Batch.getRangeEndingId('00Q5r000001BX2JEAW',chunkList);
		System.AssertEquals('00Q5r000001FjBK',lastId,'No coincide con resultado esperado');
        Id lastIdNull = CBK_Mask_Batch.getRangeEndingId('00Q5r000001Iv0LEAS',chunkList);
		System.AssertEquals(null,lastIdNull,'No coincide con resultado esperado');

	}
}