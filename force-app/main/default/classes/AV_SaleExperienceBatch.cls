/**********************************************************************************************************************
 Name:	  AV_SaleExperienceBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para asociar el ProductoFicha-Experiencia a las Ventas
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso		04/05/2020			Init version
	1.1			App FSC			Carolina Alonso		09/07/2020			Update filter query
	1.2			Limit query		David Rufo			22/07/2020			Update query limit to batch process
	1.3			Mark Date		David Rufo			28/07/2020			Include the mark to not process customer without business
	1.4			Proccess Date	Esperanza Conde		18/08/2020			Change < for = in the query
	1.5			App FSC			David Rufo			24/08/2020			Update treat business client like BPA for: 
																		empty cases + others differents than BPA, BPE, NEG
	1.6			App FSC			David Rufo			09/09/2020			Updated the query for check all the data through the
																		field AV_FechaProcesadoBatch__c
	1.7			Hotfix		  	Carolina Alonso		07/10/2020			Fix problem with the huge amount or records	
	1.8			App FSC		  	David Rufo			01/12/2020			Improve the limit query: dynamic limit query
	1.9			FIX				David Rufo			31/05/2021			Use the Query FWK
	2.0		    AV_Query IT	    Daniel Rodríguez    09/03/2022	        Change AV_Query to SOQL for User, Account, Contact
	2.1         USXXXXXX	    Daniel Rodríguez	10/03/2022          Apex errors. Add custom field to concatenate negocio and external and map Product experience
	2.2			Org Health		Carolina Alonso		17/03/2022			Add condition to retrieve only registers created in the last 15 days
	2.3			DT02			Luis Fernández		29/04/2024			Optimitzed code, get rid of nested loop for finding matching AV_ProductExperience__c.

***********************************************************************************************************************/
public class AV_SaleExperienceBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
   
	public Integer recordsProcessed = 0;
	public static final String BATCHNAME = 'AV_SaleExperience';
	
    private String avQuery;
	
    public AV_SaleExperienceBatch(){
        avQuery = setQuery();
    }

    public AV_SaleExperienceBatch(String avQuery){
        this.avQuery = avQuery;
    }
    
    private String setQuery(){
        String limitBatch = AV_SchedulerBatches.getLimit(BATCHNAME);
		String toBeProcess= '\''+Label.AV_BatchLabel_ToBeProcess+'\'';
        Integer numDays = AV_SchedulerBatches.getNumDays(BATCHNAME);
		avQuery = 'Select Id, AV_Cliente__r.AV_Negocio__c, AV_Cliente__c, AV_Producto__c, AV_ParentExternalId__c, AV_PFExperiencia__c, AV_FechaProcesadoBatch__c, AV_BatchProcessSaleExperience__c FROM AV_Sales__c where CreatedDate = LAST_N_DAYS:'+numDays+' and AV_BatchProcessSaleExperience__c = '+toBeProcess;
		if(String.isNotBlank(limitBatch)){
			avQuery += ' LIMIT '+ Integer.valueOf(limitBatch);
		}

        return avQuery;
    }
    
	/**
	 * Create a list of Ventas that do not have an associated ProductoFicha-Experiencia (AV_PFExperiencia__c).
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';
		if(avQuery==null){
            avQuery = setQuery();
        }
        AV_LogDebug.printLogDebug(methodName, 'Query to execute: ' + avQuery);
		
		return Database.getQueryLocator(avQuery);
	}

	/**
	 * Update the PFExperienia of selected Ventas
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param listVentas List<AV_Sales__c> param with the list of Ventas to update.
	 */
	public void execute(Database.BatchableContext bc, List<AV_Sales__c> listVentas){
		// Procesar cada batch de registros
		String methodName = 'execute';

		
		try{
			recordsProcessed = listVentas.size();
			AV_LogDebug.printLogDebug(methodName,'Data does not have an associated ProductoFicha-Experiencia: ' + listVentas.size());
			Set<String> listBusiness = new Set<String>{'BPA','BPE','NEG'};

			List<AV_ProductExperience__c> listProductExp= [Select Id, AV_ExternalID__c from AV_ProductExperience__c WHERE AV_ExternalID__c != NULL];
			//List<AV_ProductExperience__c> listProductExp = new AV_Query('AV_ProductExperience__c').selectFields('Id, AV_ExternalID__c').run();
			List<AV_Sales__c> listVentasToUpdate = new List<AV_Sales__c>();			
			Map<String,String> prodExpToExtCode = new Map<String,String>();
			for(AV_ProductExperience__c pexp : listProductExp){
				prodExpToExtCode.put(pexp.AV_ExternalId__c,pexp.Id);
			}

			for(AV_Sales__c sale : listVentas){
				if (sale.AV_Cliente__c!=null && sale.AV_ParentExternalId__c!=null) {
					//BPA, BPE and NEG have experience, the rest will be treat like BPA
					String businessCustomer = sale.AV_Cliente__r.AV_Negocio__c;
					if (String.isBlank(businessCustomer) || !listBusiness.contains(businessCustomer)) {
						businessCustomer = 'BPA';
					} 
					//Update the PF Experience
					String extKey = businessCustomer+'_'+sale.AV_ParentExternalId__c;
					if(prodExpToExtCode.get(extKey) != null){
						sale.AV_PFExperiencia__c = prodExpToExtCode.get(extKey);
					}
				}
				
				//Update the date of process
				sale.AV_FechaProcesadoBatch__c = System.now();
				if(!listVentasToUpdate.contains(sale)){
					listVentasToUpdate.add(sale);
				}
			}
			
			//Update the sales
			if(listVentasToUpdate!=null && !listVentasToUpdate.isEmpty()){
				Database.update(listVentasToUpdate);
				AV_LogDebug.printLogDebug(methodName,'Records updated: ' + listVentasToUpdate.size());
			}
		}catch(System.Exception e){
			AV_LogDebug.printException(methodName, e);
		}
	}

	/**
	 * Executes the scheduled Apex job
	 *
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	public void execute(SchedulableContext sc) {
		Database.executeBatch(new AV_SaleExperienceBatch());
	}

	/** 
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	public void finish(Database.BatchableContext bc){
		String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);
	}	
}