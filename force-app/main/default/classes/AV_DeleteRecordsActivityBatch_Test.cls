/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsActivityBatch_test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_DeleteRecordsActivityBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY		AUTHOR				DATE			Description
   1.0			App FSC			Maria Telleria		23/04/2020		Init version
   1.1			App FSC			Carolina Alonso		02/09/2020		Add coverage for new method getCabeceraTareaAsociada
   1.2			App FSC			Sandra Gómez		04/11/2020		Refactor
   1.3         US671736         Oscar Moreno        17/10/2023      Delete the content of the class

***********************************************************************************************************************/
@isTest
private class AV_DeleteRecordsActivityBatch_Test {

	@isTest
    public static void deleteRecordTest(){

		        AV_DeleteRecordsActivityBatch.deleteRecord();
    }
}