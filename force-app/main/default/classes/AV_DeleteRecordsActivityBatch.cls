/**********************************************************************************************************************
 Name:	  AV_DeleteRecordsActivityBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch de borrado de Actividades cuando el campo To Delete está marcado
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	  		AUTHOR					DATE			Description
	1.0			App FSC		  		Maria Telleria		23/04/2020		  	Init version
	2.0			App FSC		  		Esperanza Conde		24/07/2020			Include LastModifiedDate = LAST_N_DAYS:7 in the query
	3.0			App FSC		  		Carolina Alonso		01/09/2020			Include logic to remove the associated records from AV_HeaderCustomActivity__c
	3.1			App FSC		  		Carolina Alonso		28/09/2020			Delete order by in query
	3.2			App FSC		  		Carolina Alonso		28/09/2020			Delete older RTs 'AV_Llamada', 'AV_Muro', 'AV_Email','AV_Formacion', 'AV_SMS_PUSH'
																				and Insert new RT 'AV_ExperienciaCliente'
	3.3			App FSC		  		Sandra Gómez		04/11/2020			Modify method finish
	3.4			App FSC		  		Sandra Gómez		02/12/2020			Improve the limit query: dynamic limit query
	3.5			App FSC		  		Esperanza Conde		18/12/2020			Include false in Delete method.
	3.6			App FSC		  		Esperanza Conde		20/01/2021			Method finish call to AV_DeleteRecordsOpportunityBatch
	3.7			App FSC		  		Sandra Gómez		01/02/2021			Include enqueueJob
	3.8			Hotfix IOP Enero	Carolina Alonso		02/02/2021			Delete LastModifiedDate in the query
	3.9			Fix					David Rufo			16/03/2021			Delete header-task before delete task
	4.0			FIX					David Rufo			31/05/2021			Use the Query FWK
	4.1			FIX					David Rufo			22/06/2021			Use the number of days via Custom Metadata
	4.2		    AV_Query IT	        Daniel Rodríguez	02/03/2022	        Change AV_Query to SOQL for User, Account, Contact
	4.3			OrgHealth			Carolina Alonso		17/03/2022			Change AV_Query logic to allow calling method with an external query
    4.4         US671736            Oscar Moreno        17/10/2023          Delete the content of the class

***********************************************************************************************************************/
public class AV_DeleteRecordsActivityBatch{
    
         public static void deleteRecord(){
        
    }
	
}