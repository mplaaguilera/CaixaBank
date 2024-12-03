/**********************************************************************************************************************
 Name:      AV_DeleteRecordsVentasBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_DeleteRecordsVentasBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            App FSC          Maria Telleria   14/07/2020          Init version
   1.1			  App FSC		   Sandra Gómez		04/11/2020		    Refactor
   1.2            US671736         Oscar Moreno     17/10/2023          Delete the content of the class
   1.3            QC               Oscar Moreno     05/06/2024          Insert AssertEquals on deleteRecordTest
***********************************************************************************************************************/
@isTest
private class AV_DeleteRecordsVentasBatch_Test {
    
    @isTest
    public static void deleteRecordTest(){

		        AV_DeleteRecordsVentasBatch.deleteRecord();
                System.assertEquals(AV_DeleteRecordsVentasBatch.deleteRecord(),'entra en deleteRecord');
    }
    
}