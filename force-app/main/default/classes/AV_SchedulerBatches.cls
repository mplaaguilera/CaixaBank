/**********************************************************************************************************************
 Name:	AV_SchedulerBatches
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso para programar la ejecución o la desactivación de los procesos Batch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION	 USER_STORY	  	 AUTHOR			     DATE			  Description
	1.0		 App FSC		 Maria Telleria	     28/04/2020		  Init version
	2.0		 App FSC		 David Rufo		     29/04/2020		  Update class for execution on base Metadata object: AV_ScheduleBatch__mdt
	2.1		 App FSC		 Carolina Alonso	 05/05/2020		  Add logic for launch batches AV_SaleExperience, AV_HierarchyEmployees and AV_DeleteEvents
	2.2		 App FSC		 Carolina Alonso	 18/05/2020		  Add logic for launch batch AV_ConfidentialBatch
	2.3		 App FSC		 Carolina Alonso	 30/06/2020		  Add logic for launch batch AV_PreconcedidoBatch
	2.4		 App FSC		 María Telleria	     14/07/2020		  Add logic for launch batches AV_DeleteRecordsRetosBatch, AV_DeleteRecordsVentasBatch and AV_DeleteRecordsContactBatch
	2.5		 App FSC		 Esperanza Conde	 16/07/2020		  Add logic for launch AV_EnmascaramientoBatch y AV_EnmascaramientoEmpresaBatch
	2.6		 Limit Query	 Esperanza Conde	 24/07/2020		  Add logic for limit in delete batches
	2.7		 Limit Query	 Esperanza Conde	 18/08/2020		  Add logic for limit in AV_SaleExperience
	2.8		 App FSC		 Carolina Alonso	 26/08/2020		  Add logic for launch batch AV_TaskStatusBatch
	2.9		 App FSC		 Carolina Alonso	 02/09/2020		  Add logic for launch batch AV_RegularizeHeaderCustomActivity
	2.10	 App FSC		 Jashanpreet Singh	 14/10/2020		  Add logic for launch batch AV_ProccessAccountsOwnersBatch
	3.0		 App FSC		 Esperanza Conde	 19/10/2020		  Add logic for launch batch AV_OpportunityStatusBatch
	3.1		 App FSC		 Sandra Gómez		 04/11/2020		  Change method active with param and delete method getScheduleBatch
	3.2		 App FSC		 Carolina Alonso	 20/11/2020		  Delete logic for launch batch AV_ProccessAccountsOwnersBatch
	3.3		 App FSC		 David Rufo	 		 29/11/2020		  Fix bug - Deactivate batches
 	3.4		 App FSC		 Sandra Gómez		 02/12/2020		  Improve the limit query: dynamic limit query
	3.5		 FIX			 David Rufo			 22/06/2021		  New method for retrieve the number of the days
	3.6		 USXXXXXX		 Daniel Rodriguez	 22/11/2021		  add FWK Batches
	3.7		 US245181		 Daniel Rodriguez	 02/12/2021		  Add logic for launch batch AV_DeleteAccountTeamMemberBatch and not Call AV_ConfidentialBatch
	3.8 	 US592987		 Ángel Medina		 30/05/2023		  Changed AV_Query to SOQL queries
	3.9      US671736        Oscar Moreno        17/10/2023       Add logic for launch batches AV_DeleteCarteraCliente and AV_DeleteCarteraGestor

***********************************************************************************************************************/
public with sharing class AV_SchedulerBatches {

	private static final String FILTER_METADATA = 'AV_%';

	/**
	 * Schedule the Batch classes
	 */
	public static void activate() {
		String methodName = 'activate';
		try {
			List<AV_ScheduleBatch__mdt> listData = getMetadata('true');
			if (listData != null && !listData.isEmpty()) {
				for (AV_ScheduleBatch__mdt schedMdt : listData) {
                    AV_LogDebug.printLogDebug(methodName, 'Batch: ' + schedMdt.DeveloperName);
					activate(schedMdt.DeveloperName);
				}
				AV_LogDebug.printLogDebug(methodName, '****************** Batches activated: ' + listData.size());
			}
		}catch (Exception e){
			AV_LogDebug.printException(methodName, e);
		}
	}

	/**
	 * Unschedule the Batch classes
	 */
	public static void deactivate(){
		String methodName = 'deactivate';
		try {
			List<AV_ScheduleBatch__mdt> listData = getMetadata('all');
			//AV_LogDebug.printLogDebug(methodName, 'List batches: ' + listData);
			if (listData != null && !listData.isEmpty()) {

				List<CronTrigger> listCron = new List<CronTrigger>();
				//Get the trigger object's related with the name of the trigger
				for (AV_ScheduleBatch__mdt schedMdt : listData) {
                    try{
                        AV_LogDebug.printLogDebug(methodName, 'Batch: ' + schedMdt.DeveloperName);
                        CronTrigger ct = getObjFromJobName(schedMdt.DeveloperName);
                        if (ct!=null){
                            listCron.add(ct);
                        }
                    }catch (Exception e){
						AV_LogDebug.printLogDebug(methodName, 'Batch: ' + schedMdt.DeveloperName + ', no active');
					}
				}

				//Abort all the triggers
				for(CronTrigger crj : listCron){
					System.abortJob(crj.Id);
				}
				AV_LogDebug.printLogDebug(methodName, '****************** Batches deactivated: ' + listCron.size());
			}
		}catch (Exception e){
			AV_LogDebug.printException(methodName, e);
		}
	}
    
    /**
	 * Unschedule the batch wished by JobName
	 * @param jobName	-> the name of the Job to abort the process
	 */
    public static void deactivate(String jobName){
        if(String.isBlank(jobName)){
			AV_LogDebug.printLogError('deactivate', 'Param empty');
            return;
		}
        CronTrigger ct = getObjFromJobName(jobName);
        if (ct!=null){
            System.abortJob(ct.Id);
        }
    }

	/**
	 * Get the metadata of the batches
	 * @param option	-> option to retrieve: all, true or false
	 * 						by default -> retrieve only the active jobs
	 */
	public static List<AV_ScheduleBatch__mdt> getMetadata(String option){
		List<AV_ScheduleBatch__mdt> listData = null;
		String query = ' SELECT Id, Label, MasterLabel, DeveloperName, AV_Active__c, AV_CronTrigger__c, AV_Limit__c FROM AV_ScheduleBatch__mdt WHERE DeveloperName LIKE :FILTER_METADATA  ';
        
        if ('all'.equalsIgnoreCase(option)){
			listData = (List<AV_ScheduleBatch__mdt>) Database.query(query);
        }
        else if ('true'.equalsIgnoreCase(option) || 'false'.equalsIgnoreCase(option)){
			query += ' AND AV_Active__c = ' + Boolean.valueOf(option);
			listData = (List<AV_ScheduleBatch__mdt>) Database.query(query);
        }
        else{
			query += ' AND AV_Active__c = true ';
			listData = (List<AV_ScheduleBatch__mdt>) Database.query(query);
        }
        
		return listData;
	}
    
    /**
	 * getIdFromJob  Look for a CronTrigger sObject based on the name
	 * @param  jobName  Name of job
	 * @return		  Id of the Job
	 */
	private static Crontrigger getObjFromJobName(String jobName){
		if(String.isBlank(jobName)){
			AV_LogDebug.printLogError('getObjFromJobName', 'No Programmed Job');
            return null;
		}
		Crontrigger ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName limit 1];
		return ct;
	}

	/**
	 * Activation for each batch process
	 * @param nameBatch  -> DeveloperName of the batch process
	 */
	public static void activate(String nameBatch){
        if (String.isBlank(nameBatch)){
            throw new AV_ApplicationException('Illegal name, the value is empty');
        }
		if (nameBatch.equalsIgnoreCase('AV_SaleExperience')){
			AV_ScheduleBatch__mdt scheduler = AV_AppUtilities.getScheduleBatch(nameBatch);
			System.schedule(scheduler.DeveloperName, scheduler.AV_CronTrigger__c, new AV_SaleExperienceBatch());
		} 
		else if (nameBatch.equalsIgnoreCase('AV_HierarchyEmployees')){
			AV_ScheduleBatch__mdt scheduler = AV_AppUtilities.getScheduleBatch(nameBatch);
			System.schedule(scheduler.DeveloperName, scheduler.AV_CronTrigger__c, new AV_HierarchyEmployeesBatch());
		}
		//else if (nameBatch.equalsIgnoreCase('AV_ConfidentialBatch')){
			//AV_ScheduleBatch__mdt scheduler = AV_AppUtilities.getScheduleBatch(nameBatch);
			//System.schedule(scheduler.DeveloperName, scheduler.AV_CronTrigger__c, new AV_ConfidentialBatch());
		//}
		else if (nameBatch.equalsIgnoreCase('AV_PreconcedidoBatch')){
			AV_ScheduleBatch__mdt scheduler = AV_AppUtilities.getScheduleBatch(nameBatch);
			System.schedule(scheduler.DeveloperName, scheduler.AV_CronTrigger__c, new AV_PreconcedidoBatch());
		}
		else if (nameBatch.equalsIgnoreCase('AV_DeleteCarteraCliente')){
			AV_ScheduleBatch__mdt scheduler = AV_AppUtilities.getScheduleBatch(nameBatch);
			System.schedule(scheduler.DeveloperName, scheduler.AV_CronTrigger__c, new AV_DeleteRecordsCartCliBatch());
		}
		else if (nameBatch.equalsIgnoreCase('AV_DeleteCarteraGestor')){
			AV_ScheduleBatch__mdt scheduler = AV_AppUtilities.getScheduleBatch(nameBatch);
			System.schedule(scheduler.DeveloperName, scheduler.AV_CronTrigger__c, new AV_DeleteRecordsCarteraGestorBatch());
		}
		 else if (nameBatch.equalsIgnoreCase('AV_TaskStatusBatch')){
			AV_ScheduleBatch__mdt scheduler = AV_AppUtilities.getScheduleBatch(nameBatch);
			System.schedule(scheduler.DeveloperName, scheduler.AV_CronTrigger__c, new AV_TaskStatusBatch());
		}		
		else if (nameBatch.equalsIgnoreCase('AV_RegularizeHeaderCustomActivity')){
			AV_ScheduleBatch__mdt scheduler = AV_AppUtilities.getScheduleBatch(nameBatch);
			System.schedule(scheduler.DeveloperName, scheduler.AV_CronTrigger__c, new AV_RegularizeHeaderCustomActivity());
		}
		else if (nameBatch.equalsIgnoreCase('AV_RegularizeHeaderCustomActivityEvents')){
			AV_ScheduleBatch__mdt scheduler = AV_AppUtilities.getScheduleBatch(nameBatch);
			System.schedule(scheduler.DeveloperName, scheduler.AV_CronTrigger__c, new AV_RegularizeHeaderCustomActivityEvents());
		}
		else if (nameBatch.equalsIgnoreCase('AV_OpportunityStatusBatch')){
			AV_ScheduleBatch__mdt scheduler = AV_AppUtilities.getScheduleBatch(nameBatch);
			System.schedule(scheduler.DeveloperName, scheduler.AV_CronTrigger__c, new AV_OpportunityStatusBatch());
		}
		else if (nameBatch.equalsIgnoreCase('AV_DeleteAccountTeamMemberBatch')){
			AV_ScheduleBatch__mdt scheduler = AV_AppUtilities.getScheduleBatch(nameBatch);
			System.schedule(scheduler.DeveloperName, scheduler.AV_CronTrigger__c, new AV_DeleteAccountTeamMemberBatch());
		} 
		else if (nameBatch.equalsIgnoreCase('AV_LeadOpportunity_AnonymityBatch')){
			AV_ScheduleBatch__mdt scheduler = AV_AppUtilities.getScheduleBatch(nameBatch);
			System.schedule(scheduler.DeveloperName, scheduler.AV_CronTrigger__c, new AV_DeleteAccountTeamMemberBatch());
        }
		else if (nameBatch.equalsIgnoreCase('AV_DeletePermissionBatch')){
			AV_ScheduleBatch__mdt scheduler = AV_AppUtilities.getScheduleBatch(nameBatch);
			System.schedule(scheduler.DeveloperName, scheduler.AV_CronTrigger__c, new AV_DeletePermissionBatch());
        }
		else {
			throw new AV_ApplicationException('No Batch found with name: ' + nameBatch);
		}
	}
	
	/**
	 * Activation for mask data batch process
	 */
	public static void executeMaskProcess(){
		String maskParticularBatch = 'AV_EnmascaramientoBatch';
		String maskEmpresaBatch = 'AV_EnmascaramientoEmpresaBatch';
		Set<String> listUser = new Set<String>();
		listUser.add(UserInfo.getUserId());
		
		AV_ScheduleBatch__mdt schedulerParticular = AV_AppUtilities.getScheduleBatch(maskParticularBatch);
		map<String,Object> paramsParticular = new map<String,Object>();
		paramsParticular.put('limitBatch',schedulerParticular.AV_Limit__c);
		paramsParticular.put('setUserIds',listUser);
		String paramParStr = JSON.serialize(paramsParticular);  
		CBK_BatchJob.executeBatchFuture('AV_EnmascaramientoBatch', 200 ,paramParStr); 
		
		//Database.executeBatch(new AV_EnmascaramientoBatch(schedulerParticular.AV_Limit__c));

		AV_ScheduleBatch__mdt schedulerEmpresa = AV_AppUtilities.getScheduleBatch(maskEmpresaBatch);
		map<String,Object> paramsEmpresa = new map<String,Object>();
		paramsEmpresa.put('limitBatch',schedulerEmpresa.AV_Limit__c);
		paramsEmpresa.put('setUserIds',listUser);
		String paramEmStr = JSON.serialize(paramsEmpresa);  
		CBK_BatchJob.executeBatchFuture('AV_EnmascaramientoEmpresaBatch', 200 ,paramEmStr); 
		
		//Database.executeBatch(new AV_EnmascaramientoEmpresaBatch(schedulerEmpresa.AV_Limit__c));
	}
    
    public static AV_ScheduleBatch__mdt getCMBatch(String batchName){
        return AV_AppUtilities.getScheduleBatch(batchName);
    }
    
    /**
	 * Retrieve the limit of the batch
	 * @param batchName -> the name of the batch
	 */
    public static String getLimit(String batchName){
        AV_ScheduleBatch__mdt scheduler = getCMBatch(batchName);
        return scheduler.AV_Limit__c;
    }
    
    /**
	 * Retrieve the number of the days for query batch
	 * @param batchName -> the name of the batch
	 */
    public static Integer getNumDays(String batchName){
        AV_ScheduleBatch__mdt scheduler = getCMBatch(batchName);
        return Integer.valueOf(scheduler.AV_NumDays__c);
    }
    
}