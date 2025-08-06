/**********************************************************************************************************************
Name:	  CIBE_UpdateOpportunityGC_Batch
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para actualizar las oportunidades relacionadas a grupos comerciales
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US776093		Luis Martínez       16/12/2023			Init version
***********************************************************************************************************************/

public class CIBE_UpdateOpportunityGC_Batch implements Database.Batchable<sObject>, Database.Stateful,Schedulable {
    
	public Integer recordsProcessed = 0;
    public static final String BATCHNAME = 'CIBE_UpdateOpportunityGC_Batch';

    private static final String RT_ACCR = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();
    
	private String avQuery;
	
    public CIBE_UpdateOpportunityGC_Batch(){
        this.avQuery = setQuery();
    }

    public CIBE_UpdateOpportunityGC_Batch(String avQuery){
        this.avQuery = avQuery;
    }
	
	private String setQuery(){        
        List<FinServ__AccountAccountRelation__c> listaAccR = [SELECT id, FinServ__Account__c, FinServ__RelatedAccount__c
                                                            FROM FinServ__AccountAccountRelation__c 
                                                            WHERE RecordTypeId = :RT_ACCR AND FinServ__Role__r.Name = 'Parent' AND
                                                            LastModifiedDate = LAST_N_DAYS:3 AND AV_ToDelete__c = false
															ORDER BY LastModifiedDate DESC LIMIT 1];
        
		if (!listaAccR.isEmpty()){
			avQuery = 'SELECT id, FinServ__Account__c, FinServ__RelatedAccount__c FROM FinServ__AccountAccountRelation__c WHERE RecordTypeId = :RT_ACCR AND FinServ__Role__r.Name = \'Parent\' AND LastModifiedDate = LAST_N_DAYS:3 AND AV_ToDelete__c = false ORDER BY LastModifiedDate DESC LIMIT 200';
		}
        return avQuery;
    }
    
	/**
	 * Find the last CIBE_FechaCargaGE__c date and the accountRelations differents from that date
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
    public Database.QueryLocator start(Database.BatchableContext bc){
        if(String.isBlank(avQuery)){
            avQuery = setQuery();
        }

        return Database.getQueryLocator(avQuery);
    }
    
	/**
	 * Delete the AccountRelations
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<FinServ__AccountAccountRelation__c> param with the list of AccountRelations.
	 */
    public void execute(Database.BatchableContext bc, List<FinServ__AccountAccountRelation__c> scope){
        recordsProcessed = scope.size();
        List<Opportunity> listOppUpd = new List<Opportunity>();
		Map<Id,FinServ__AccountAccountRelation__c> mapFSAR = new Map<Id,FinServ__AccountAccountRelation__c>();
		List <String> rtOpp = new List <String>{CIBE_AppConstants.OPP_INICIATIVACIB_RT,
												CIBE_AppConstants.OPP_INICIATIVAEMP_RT,
												CIBE_AppConstants.OPP_SUGERENCIACIB_RT,
												CIBE_AppConstants.OPP_SUGERENCIAEMP_RT,
												CIBE_AppConstants.OPP_ALERTACIB_RT,
												CIBE_AppConstants.OPP_ALERTAEMP_RT,
												CIBE_AppConstants.OPP_ACCIONCIB_RT,
												CIBE_AppConstants.OPP_ACCIONEMP_RT};

		for(FinServ__AccountAccountRelation__c acc : scope) {
			if(acc.FinServ__RelatedAccount__c !=null){
				mapFSAR.put(acc.FinServ__RelatedAccount__c,acc);
			}
		}

        List<Opportunity> listaOpp = [SELECT Id, CIBE_GrupoComercial__c, AccountId  FROM Opportunity WHERE RecordType.DeveloperName IN :rtOpp AND AccountId IN:mapFSAR.KeySet()];
        for(Opportunity opp : listaOpp) {
            if(mapFSAR.containsKey(opp.AccountId) && opp.CIBE_GrupoComercial__c != mapFSAR.get(opp.AccountId).FinServ__Account__c){
                opp.CIBE_GrupoComercial__c = mapFSAR.get(opp.AccountId).FinServ__Account__c;
                listOppUpd.add(opp);
            }
		}
		if(listOppUpd != null && listOppUpd.size()>0){
			Database.SaveResult [] updates = Database.Update(listOppUpd, false);
			boolean hasError = false;
			List<Object> objs = new List<Object>();
			Map<String, String> msjs = new Map<String, String>();
			for (Integer i = 0; i < listOppUpd.size(); i++) {
				Database.SaveResult dr = updates[i];
				if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
					msjs.put(listOppUpd[i].Id, ((String)dr.getErrors()[0].getMessage()));
					objs.add(listOppUpd[i]);
					hasError = true;
				}
			}
			if(hasError) {
				CBK_Log.error(msjs, objs);
			}
		}
    }
    
	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
    public void finish(Database.BatchableContext bc){
        String methodName='finish';
		CBK_Log.debug(BATCHNAME+' '+methodName, 'Record Processes: ' + recordsProcessed);
    }

	/**
	 * Executes the scheduled Apex job
	 *
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	public void execute(SchedulableContext sc) {
		Database.executeBatch(new CIBE_UpdateOpportunityGC_Batch());
	}
}