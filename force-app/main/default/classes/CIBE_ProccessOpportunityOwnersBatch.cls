/**********************************************************************************************************************
 Name:	  CIBE_ProccessOpportunityOwnersBatch
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para cambiar el ownerId de las Oportunidades.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US639303		Bea	                21/07/2023			Init version


***********************************************************************************************************************/
public class CIBE_ProccessOpportunityOwnersBatch implements Database.Batchable<sObject>, Database.Stateful {

	public Integer recordsProcessed = 0;

	public String limitBatch;
	public Set<String> setUserIds;
    
    public CIBE_ProccessOpportunityOwnersBatch(String limitQuery, Set<String> userId) {
		limitBatch = '100';
		setUserIds = new Set<String>();
        setUserIds.addAll(userId);
    }

	    /*Se declara un constructor vacío y sin parámetros y con un System.Debug dentro para que no salte un error de constructor vacío.
	  Es necesario para que ejecute el Framework de batch porque busca en CBK_BatchJob el constructor vacío y allí rellena los parámetros*/
	  public CIBE_ProccessOpportunityOwnersBatch() {
		System.debug('Constructor sin parametros de CIBE_ProccessOpportunityOwnersBatch');
	}
	
	/**
	 * Get a list of Opportunities to process the owners

	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {

		String methodName = 'start';
		List <String> rtCIBE = new List <String>{
            CIBE_AppConstants.OPP_INICIATIVA_RT,
            CIBE_AppConstants.OPP_INICIATIVACIB_RT,
            CIBE_AppConstants.OPP_INICIATIVAEMP_RT,
            CIBE_AppConstants.OPP_ACCIONCIB_RT,
            CIBE_AppConstants.OPP_ACCIONEMP_RT,
            CIBE_AppConstants.OPP_ALERTACIB_RT,
            CIBE_AppConstants.OPP_ALERTAEMP_RT,
            CIBE_AppConstants.OPP_SUGERENCIACIB_RT,
            CIBE_AppConstants.OPP_SUGERENCIAEMP_RT,
            CIBE_AppConstants.OPP_CENTRALIZADA_RT
        };

		String cibeQuery = 'SELECT Id, OwnerId, AV_Gestor__r.AV_UsuarioAsociado__c FROM Opportunity ';
		cibeQuery += ' WHERE LastModifiedDate >= LAST_N_MONTHS:2 ';
		cibeQuery += ' AND AV_Gestor__r.AV_UsuarioAsociado__c IN ' + AV_AppUtilities.setToStringIn(setUserIds);
		cibeQuery += ' AND RecordType.DeveloperName IN ' + AV_AppUtilities.listToStringIn(rtCIBE);
		cibeQuery += ' LIMIT ' + Integer.valueOf(limitBatch);
		
		return Database.getQueryLocator(cibeQuery);

	}

	/**
	 * Update account OwnerId
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Opportunity> param with the list of Opportunities
	 */
	public void execute(Database.BatchableContext bc, List<Opportunity> scope){
		// Procesar cada batch de registros

		String methodName = 'execute';
		try{
            recordsProcessed = scope.size();
            List<Opportunity> listDataToUpdate = new List<Opportunity>();
			for(Opportunity data : scope) {
                if (data.OwnerId != data.AV_Gestor__r.AV_UsuarioAsociado__c){
						data.OwnerId = data.AV_Gestor__r.AV_UsuarioAsociado__c;
						listDataToUpdate.add(data);
                }
			}
            recordsProcessed = listDataToUpdate.size();
			Database.update(listDataToUpdate, false);

		}catch(System.Exception e){
			AV_LogDebug.printException(methodName, e);
		}
	}

	/**
	 * Executes the scheduled Apex job
	 *
	 * @param sc	SchedulableContext param that contains the job ID
	 */

	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	public void finish(Database.BatchableContext bc){
		String methodName='finish';
        map<String,Object> params = new map<String,Object>();
		params.put('limitBatch',limitBatch);
		params.put('setUserIds',setUserIds);
		CBK_BatchJob.executeBatch('CIBE_ProccessNotifymeOwnersBatch', 100 ,params);
		
		// CIBE_ProccessNotifymeOwnersBatch notifyMeBatch = new CIBE_ProccessNotifymeOwnersBatch(limitBatch, setUserIds);
		// Database.executeBatch(notifyMeBatch);
	}
}