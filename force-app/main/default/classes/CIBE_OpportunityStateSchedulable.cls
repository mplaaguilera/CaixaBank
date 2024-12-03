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
    public static final String BATCHNAME = 'CIBE_OpportunityState_Batch';
	private static List<String> listRTs = new List<String>{CIBE_AppConstants.OPP_INICIATIVA_RT,
												CIBE_AppConstants.OPP_INICIATIVACIB_RT,
												CIBE_AppConstants.OPP_INICIATIVAEMP_RT,
												CIBE_AppConstants.OPP_ACCIONCIB_RT,
												CIBE_AppConstants.OPP_ACCIONEMP_RT,
												CIBE_AppConstants.OPP_ALERTACIB_RT,
												CIBE_AppConstants.OPP_ALERTAEMP_RT,
												CIBE_AppConstants.OPP_SUGERENCIACIB_RT,
												CIBE_AppConstants.OPP_SUGERENCIAEMP_RT, 
												CIBE_AppConstants.OPP_CENTRALIZADA_RT};

	private static List<String> stageName = new List<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL,
                                                            CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO,
                                                            CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA,
                                                            CIBE_AppConstants.OPPORTUNITY_STATUS_CONVENTA,
                                                            CIBE_AppConstants.OPPORTUNITY_STATUS_NOAPTO,
                                                            CIBE_AppConstants.OPPORTUNITY_STATUS_NOINTERE};
		
    private String avQuery;
    
    /*public CIBE_OpportunityStateSchedulable(){
		
    }*/
	
    public CIBE_OpportunityStateSchedulable(){
		
		this.avQuery = setQuery();
    }

    public CIBE_OpportunityStateSchedulable(String avQuery){
		
		this.avQuery = avQuery;
    }

	private String setQuery(){
		String batchLimit = AV_SchedulerBatches.getLimit(BATCHNAME);

		if (String.isBlank(batchLimit)){
            avQuery = 'SELECT Id, CloseDate, StageName, Name FROM Opportunity WHERE CloseDate >= LAST_N_MONTHS:18 AND CloseDate < TODAY AND StageName IN :stageName AND RecordType.DeveloperName IN : listRTs';
        } else{
        	avQuery = 'SELECT Id, CloseDate, StageName, Name FROM Opportunity WHERE CloseDate >= LAST_N_MONTHS:18 AND CloseDate < TODAY AND StageName IN :stageName AND RecordType.DeveloperName IN : listRTs LIMIT '+ batchLimit;
        }
		
        return avQuery;
    }
    
	/**
	 * Encuentra las oportunidades con  CloseDate inferior a hoy y StageName 'CIBE_Vencido'
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
	 * Cambio del StageName a CIBE_Vencido
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Opportunity> param with the list of Accounts.
	 */
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
		try{
            if(!scope.isEmpty()){
                recordsProcessed = scope.size();
				
                for(Opportunity opp : scope){
					// opp.CloseDate = Date.today();
                    opp.StageName = 'CIBE_Vencido';
                }
                if(!scope.isEmpty() && Schema.Opportunity.SObjectType.getDescribe().isUpdateable()){
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
        String methodName='finish';
		AV_LogDebug.printLogDebug(methodName, 'Record Processes: ' + recordsProcessed);
    }

	/**
	 * Executes the scheduled Apex job
	 *
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	public void execute(SchedulableContext sc) {
		Database.executeBatch(new CIBE_OpportunityStateSchedulable());
	}
    
}