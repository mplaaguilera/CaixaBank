/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsActHeadBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch de borrado de Cabecera-Tarea cuando el campo To Delete está marcado
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY		AUTHOR				DATE				Description
   1.0			App FSC			Maria Telleria		23/04/2020			Init version
   2.0			App FSC			Esperanza Conde		24/07/2020			Include LastModifiedDate = LAST_N_DAYS:7 in the query
   3.0			App FSC			Carolina Alonso		02/09/2020			Add logic to delete the AV_HeaderCustomActivity__c that are 
																		   not associated with any task or event
   3.1			App FSC			Carolina Alonso		28/09/2020			Delete order by in query
   3.2			App FSC			Sandra Gómez		04/11/2020			Modify method finish
   3.3			App FSC		  	Sandra Gómez		02/12/2020			Improve the limit query: dynamic limit query
   3.4			App FSC			Esperanza Conde		18/12/2020			Include false in Delete method.
   3.5			App FSC			Esperanza Conde		20/01/2021			Delete the logic in the finish method
   3.6			FIX				David Rufo			31/05/2021			Use the Query FWK
   3.7         US671736         Oscar Moreno        17/10/2023          Delete the content of the class
   3.8          QC              Oscar Moreno        05/06/2024       Return a String of deleteRecord method
***********************************************************************************************************************/
public class AV_DeleteRecordsActHeadBatch {
   
	 public static String deleteRecord(){
        return 'entra en deleteRecords';
    }
}