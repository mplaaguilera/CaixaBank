/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsActHeadBatch_test
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Test de la clase AV_DeleteRecordsActHeadBatch
=======================================================================================================================
Historial
---------------------
   VERSION		USER_STORY		AUTHOR				DATE			Description
   1.0			App FSC			Maria Telleria		23/04/2020		Init version
   2.0			App FSC			Maria Telleria		02/09/2020		Coverage for the new logic
   2.1			App FSC			Sandra Gómez		04/11/2020		Refactor
   2.2         US671736         Oscar Moreno        17/10/2023       Delete the content of the class
   2.3          QC              Oscar Moreno        05/06/2024      Insert AssertEquals on deleteRecordTest method
  
***********************************************************************************************************************/
@isTest
private class AV_DeleteRecordsActHeadBatch_Test {

	@isTest
    public static void deleteRecordTest(){

		        AV_DeleteRecordsActHeadBatch.deleteRecord();
                System.assertEquals(AV_DeleteRecordsActHeadBatch.deleteRecord(),'entra en deleteRecords');
    }
}