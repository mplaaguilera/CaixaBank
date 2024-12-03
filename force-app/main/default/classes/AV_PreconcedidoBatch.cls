/**********************************************************************************************************************
 Name:	  AV_PreconcedidoBatch
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Proceso Batch para asociar Cliente el máximo importe preconcedido asociado.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Carolina Alonso		30/06/2020			Init version
	1.1			App FSC		  	David Rufo			01/12/2020			Improve the limit query: dynamic limit query 

***********************************************************************************************************************/
global class AV_PreconcedidoBatch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {

	global Integer recordsProcessed = 0;
	global static final String BATCHNAME = 'AV_PreconcedidoBatch';
	
	/**
	 * Create a list of Account that the Fecha última modificación preconcedido is null or less than 7 days.
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String methodName = 'start';
        Datetime filterDate = Date.today() - 7;
		String query = 'SELECT Id, AV_NumPerso__c, AV_Preconcedidos__c,AV_FechaUltimaModifPreconcedido__c ' +
						'FROM Account WHERE RecordType.DeveloperName = \'CC_CLientePA\' and AV_NumPerso__c != null ' +
						'and (AV_FechaUltimaModifPreconcedido__c = null or AV_FechaUltimaModifPreconcedido__c <  ' +
						filterDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'') +
						' ) ORDER BY CreatedDate ASC';
		
        String batchLimit = AV_SchedulerBatches.getLimit(BATCHNAME);
        if (String.isNotBlank(batchLimit)){
			query += ' LIMIT ' + batchLimit;
		}
        
        AV_LogDebug.printLogDebug(methodName, 'Query: ' + query);
		return Database.getQueryLocator(query);
	}

	/**
	 * Update Field Preconcedido in Account
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param listAccounts List<Account> param with the list of Accounts.
	 */
	global void execute(Database.BatchableContext bc, List<Account> listAccounts){
		// Procesar cada batch de registros
		String methodName = 'execute';
		try{
			recordsProcessed = listAccounts.size();
			AV_LogDebug.printLogDebug(methodName,'Data which has Fecha última modificación Preconcedido null or less than 7 days : ' + listAccounts.size());

			Map<String, Map<String, Decimal>> mapProductImportePreconcedido = createMapPreconcedidosProduct(listAccounts);
			List<Account> listAccountsToUpdate = new List<Account>();
			for(Account cliente : listAccounts){
				Map<String,Decimal> mapProductImporte = mapProductImportePreconcedido.get(cliente.AV_NumPerso__c);
				List<String> listProd = new List<String>();
				if(mapProductImporte != null){
					listProd.addAll(mapProductImporte.keySet());
					List<Decimal> listImportes = new List<Decimal>();
					listImportes = mapProductImporte.values();
					Decimal importePreconcedido;
					String maxValuePreconcedidos = '';
					if(!listImportes.isEmpty()){
						importePreconcedido = listImportes.get(0);
						maxValuePreconcedidos = importePreconcedido.setScale(2).format();
						if(!maxValuePreconcedidos.contains(',')){
							maxValuePreconcedidos = maxValuePreconcedidos + ',00 €';
						} else{
							maxValuePreconcedidos = maxValuePreconcedidos + ' €';
						}
					}
					String nameProd;
					if(!listProd.isEmpty()){
						nameProd = listProd.get(0);
					}
					if(String.isNotBlank(maxValuePreconcedidos)){
						if(String.isNotBlank(nameProd)){
							cliente.AV_Preconcedidos__c = maxValuePreconcedidos + ' ( ' + nameProd + ' )';
						} else{
							cliente.AV_Preconcedidos__c = maxValuePreconcedidos;
						}					
						cliente.AV_FechaUltimaModifPreconcedido__c = Date.today();
						listAccountsToUpdate.add(cliente);
					}
				}
			}
			if(!listAccountsToUpdate.isEmpty()){
				Database.update(listAccountsToUpdate);
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
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new AV_PreconcedidoBatch());
	}

	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	global void finish(Database.BatchableContext bc){
		String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);
	}

	/**
	 * Create Map of max Importe Preconcedido associated with NumPerso
	 *
	 * @param listAccounts	lista de Accounts
	 */
	private Map<String, Map<String, Decimal>> createMapPreconcedidosProduct(List<Account> listAccounts) {
		Set<Id> setIdsAccount = new Set<ID>();
		for(Account cliente : listAccounts){
				setIdsAccount.add(cliente.Id);
		}
		
		// List<AV_ProductClient__c> listPFCliente = new AV_Query('AV_ProductClient__c')
		// 												.selectFields('Id')
		// 												.selectFields('AV_Cliente__r.AV_NumPerso__c')
		// 												.selectFields('AV_ImportePreconcedido__c')
		// 												.selectFields('AV_ProductoFicha__r.AV_ProductoFicha__r.Name')
		// 												.addConditionIn('AV_Cliente__c', setIdsAccount)
		// 												.addConditionNotEq('AV_ImportePreconcedido__c', null)
		// 												.run();
		List<AV_ProductClient__c> listPFCliente = [SELECT Id,AV_Cliente__r.AV_NumPerso__c,AV_ImportePreconcedido__c,AV_ProductoFicha__r.AV_ProductoFicha__r.Name 
		FROM AV_ProductClient__c WHERE AV_Cliente__c IN :setIdsAccount AND AV_ImportePreconcedido__c != NULL];   

		Map<String, Map<String, Decimal>> mapPreconcedidos = new Map<String, Map<String, Decimal>>();
		Map<String, Decimal> mapPreconcedidosProduct = new Map<String, Decimal>();
		
		for(AV_ProductClient__c pfCliente : listPFCliente){
			if(mapPreconcedidos.containsKey(pfCliente.AV_Cliente__r.AV_NumPerso__c) && mapPreconcedidos.get(pfCliente.AV_Cliente__r.AV_NumPerso__c) != null) {
				Map<String, Decimal> mapOldValuePreconcedidos = mapPreconcedidos.get(pfCliente.AV_Cliente__r.AV_NumPerso__c);
				List<Decimal> listPreconcedidos = mapOldValuePreconcedidos.values();
				Decimal oldValuePreconcedidos = listPreconcedidos.get(0);

				if(oldValuePreconcedidos < pfCliente.AV_ImportePreconcedido__c){
					mapPreconcedidosProduct.put(pfCliente.AV_ProductoFicha__r.AV_ProductoFicha__r.Name,pfCliente.AV_ImportePreconcedido__c);
					mapPreconcedidos.put(pfCliente.AV_Cliente__r.AV_NumPerso__c, mapPreconcedidosProduct);
				}
			} else{
				mapPreconcedidosProduct.put(pfCliente.AV_ProductoFicha__r.AV_ProductoFicha__r.Name,pfCliente.AV_ImportePreconcedido__c);
				mapPreconcedidos.put(pfCliente.AV_Cliente__r.AV_NumPerso__c,mapPreconcedidosProduct);
			}
		}
		return mapPreconcedidos;
	}
}