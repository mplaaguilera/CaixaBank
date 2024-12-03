/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsVentasBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch de borrado de Ventas cuando el campo To Delete está marcado
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			App FSC				Maria Telleria		13/07/2020			Init version
	2.0			App FSC				Esperanza Conde		24/07/2020			Include LastModifiedDate = LAST_N_DAYS:7 in the query
	2.1			App FSC				Carolina Alonso		29/09/2020			Delete order by in query
	2.2			App FSC				Carolina Alonso		26/10/2020			Include RT in query
	2.3			App FSC				Sandra Gómez		04/11/2020			Modify method finish
	2.4			App FSC				Sandra Gómez		01/12/2020			Improve the limit query: dynamic limit query
	2.5			App FSC				Esperanza Conde		18/12/2020			Include false in Delete method.
	2.6			App FSC				Sandra Gómez		01/02/2021			Include enqueueJob
	2.7			Hotfix IOP Enero	Carolina Alonso		02/02/2021			Delete LastModifiedDate in the query
	2.8			FIX					David Rufo			31/05/2021			Use the Query FWK
	2.9			FIX					David Rufo			22/06/2021			Use the number of days via Custom Metadata
	3.0		    AV_Query IT	        Daniel Rodríguez    03/03/2022	        Change AV_Query to SOQL for User, Account, Contact
	3.1			Fix					Sandra Gómez		02/02/2022			Change Queueable Next AV_DeleteRecordsCartCliBatchQueueable and deleted Retos of chain
	3.2         US671736            Oscar Moreno        17/10/2023          Delete the content of the class
	3.3         QC                  Oscar Moreno        05/06/2024          Return a String of deleteRecord method
***********************************************************************************************************************/
public class AV_DeleteRecordsVentasBatch  {

    public static String deleteRecord(){
        return 'entra en deleteRecord';
    }
}