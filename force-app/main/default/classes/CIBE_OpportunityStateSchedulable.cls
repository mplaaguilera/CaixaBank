/**********************************************************************************************************************
 Name:	  CIBE_OpportunityStateSchedulable
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para pasar a estado 'Vencido' todas las oportunidades que tengan el closeDate inferior a TODAY
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				        DATE				Description
	1.0					            Ali                        06/06/2023			Init version
***********************************************************************************************************************/
public class CIBE_OpportunityStateSchedulable implements Database.Batchable<sObject>, Database.Stateful {

    public Integer recordsProcessed = 0;
    public String limitBatch;
    public static final String BATCHNAME = 'CIBE_OpportunityState_Batch';
	private static List<String> listRTs = new List<String>{	CIBE_AppConstants.OPP_INICIATIVACIB_RT,
												CIBE_AppConstants.OPP_INICIATIVAEMP_RT,
												CIBE_AppConstants.OPP_ACCIONCIB_RT,
												CIBE_AppConstants.OPP_ACCIONEMP_RT,
												CIBE_AppConstants.OPP_ALERTACIB_RT,
												CIBE_AppConstants.OPP_ALERTAEMP_RT,
												CIBE_AppConstants.OPP_SUGERENCIACIB_RT,
												CIBE_AppConstants.OPP_SUGERENCIAEMP_RT};

	private static List<String> stageName = new List<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL,
                                                            CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO,
                                                            CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA,
                                                            CIBE_AppConstants.OPPORTUNITY_STATUS_CONVENTA,
                                                            CIBE_AppConstants.OPPORTUNITY_STATUS_NOAPTO,
                                                            CIBE_AppConstants.OPPORTUNITY_STATUS_NOINTERE};                     
	
    public CIBE_OpportunityStateSchedulable(){
        limitBatch = AV_ScheduleBatch__mdt.getInstance(BATCHNAME).AV_Limit__c;
    }

    public CIBE_OpportunityStateSchedulable(String avQuery){
        //AV_SchedulerBatches.getLimit(BATCHNAME);
        limitBatch = AV_ScheduleBatch__mdt.getInstance(BATCHNAME).AV_Limit__c;
    }
    
	/**
	 * Encuentra las oportunidades con  CloseDate inferior a hoy y StageName 'CIBE_Vencido'
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
    public Database.QueryLocator start(Database.BatchableContext bc){
        String  cibeQuery;
        if (String.isBlank(limitBatch)){
            cibeQuery = 'SELECT Id, RecordType.DeveloperName, CIBE_LastUpdatedCerradoNegativo__c, CloseDate, StageName, Name FROM Opportunity WHERE CloseDate >= LAST_N_MONTHS:18 AND CloseDate < TODAY AND StageName IN :stageName AND RecordType.DeveloperName IN : listRTs';
        } else{
            cibeQuery = 'SELECT Id, RecordType.DeveloperName, CIBE_LastUpdatedCerradoNegativo__c, CloseDate, StageName, Name FROM Opportunity WHERE CloseDate >= LAST_N_MONTHS:18 AND CloseDate < TODAY AND StageName IN :stageName AND RecordType.DeveloperName IN : listRTs LIMIT '+ limitBatch;
        }
        return Database.getQueryLocator(cibeQuery);
    }
    
	/**
	 * Cambio del StageName a CIBE_Vencido
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Opportunity> param with the list of Accounts.
	 */
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        DateTime createdFormatDate = System.today();
		try{
            if(!scope.isEmpty()){
                recordsProcessed = scope.size();
				
                for(Opportunity opp : scope){
                    opp.StageName = 'CIBE_Vencido';
                }
                if(!scope.isEmpty() && Opportunity.SObjectType.getDescribe().isUpdateable()){
                    Database.SaveResult[] srList = Database.update(scope, false);
                    boolean hasError = false;
                    List<Object> objs = new List<Object>();
                    Map<String, String> msjs = new Map<String, String>();
                    for (Integer i = 0; i < scope.size(); i++) {
                        Database.SaveResult sr = srList[i];
                        if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                            msjs.put(scope[i].Id + '_' + scope[i].Name, ((String)sr.getErrors()[0].getMessage()));
                            objs.add(scope[i]);
                            hasError = true;
                        }
                    }
                    if(hasError) {
                        CBK_Log.error(msjs, objs);
                    }
                }
            }
        } catch(System.Exception e) {
            CBK_Log.error(e);
        }
    }
    
	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
    public void finish(Database.BatchableContext bc){
        map<String,Object> params = new map<String,Object>();
		params.put('limitBatch',limitBatch);
        CBK_BatchJob.executeBatch('CIBE_OpportunityStateSchedulable', 5 ,params);    
    }
    
}