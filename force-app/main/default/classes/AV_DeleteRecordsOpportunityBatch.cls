/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsOpportunityBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch de borrado de Oportunidades cuando el campo To Delete está marcado
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE			Description
	1.0			App FSC				Maria Telleria		23/04/2020		Init version
	2.0			App FSC				Esperanza Conde		24/07/2020		Include LastModifiedDate = LAST_N_DAYS:7 in the query
	3.0			App FSC				Carolina Alonso		08/09/2020		Include logic to remove the associated records from AV_CustomActivityOpportunity__c
	3.1			App FSC				Carolina Alonso		28/09/2020		Delete order by in query
	3.2			App FSC				Sandra Gómez		04/11/2020		Modify method finish
	2.4			App FSC		  		Sandra Gómez		02/12/2020		Improve the limit query: dynamic limit query
	2.5			App FSC				Esperanza Conde		18/12/2020		Include false in Delete method.
	2.6			App FSC		  		Sandra Gómez		01/02/2021		Include enqueueJob
	2.7			Hotfix IOP Enero	Carolina Alonso		02/02/2021		Delete LastModifiedDate in the query
	2.8			FIX					David Rufo			31/05/2021		Use the Query FWK
	2.9			FIX					David Rufo			22/06/2021			Use the number of days via Custom Metadata
	3.0		    AV_Query IT	        Daniel Rodríguez    03/03/2022	        Change AV_Query to SOQL for User, Account, Contact
    3.1        US671736             Oscar Moreno        17/10/2023          Delete the content of the class


***********************************************************************************************************************/
public class AV_DeleteRecordsOpportunityBatch {
	
     public static void deleteRecord(){
        
    }
	
}