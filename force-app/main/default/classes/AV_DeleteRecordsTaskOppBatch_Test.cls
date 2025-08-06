/**********************************************************************************************************************
 Name:      AV_DeleteRecordsTaskOppBatch_test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_DeleteRecordsTaskOppBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            App FSC          Maria Telleria   23/04/2020          Init version
   1.1			  App FSC		   Sandra Gómez		04/11/2020			Refactor
   1.2            US671736         Oscar Moreno     17/10/2023          Delete the content of the class
   1.3            QC              Oscar Moreno      05/06/2024          Insert AssertEquals on deleteRecordTest method

***********************************************************************************************************************/
@isTest
private class AV_DeleteRecordsTaskOppBatch_Test {
    
    @isTest
    public static void deleteRecordTest(){

		        AV_DeleteRecordsTaskOppBatch.deleteRecord();
                System.assertEquals(  AV_DeleteRecordsTaskOppBatch.deleteRecord(),'entra en deleteRecord');
    }
	
}