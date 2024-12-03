/**********************************************************************************************************************
 Name:	  CIBE_OppCerradoNegativoSchedulable
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para pasar a estado(CIBE_CerradoNegativo__c) 'No gestionada' todas las oportunidades
que tengan su estado en 'Vencido' mas de tres meses o si la fecha de proxima gestion no esta informada en el plazo de 1 mes.
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		    AUTHOR				        DATE				Description
	1.0			US807446		    Lucia                       14/02/2024			Init version
***********************************************************************************************************************/
public class CIBE_OppCerradoNegativoSchedulable implements Database.Batchable<sObject>, Database.Stateful{

    public Integer recordsProcessed = 0;
    public static String limitBatch;
    public static final String BATCHNAME = 'CIBE_OppCerradoNegativo_Batch';
	private static List<String> listRTs = new List<String>{CIBE_AppConstants.OPP_INICIATIVAEMP_RT,
                                                CIBE_AppConstants.OPP_ACCIONEMP_RT,
												CIBE_AppConstants.OPP_ALERTAEMP_RT,
												CIBE_AppConstants.OPP_SUGERENCIAEMP_RT};

    private static List<String> stageName = new List<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_VENCIDO};

    public CIBE_OppCerradoNegativoSchedulable(){
        limitBatch = AV_ScheduleBatch__mdt.getInstance(BATCHNAME).AV_Limit__c;
    }

    public CIBE_OppCerradoNegativoSchedulable(String avQuery){
        limitBatch = AV_ScheduleBatch__mdt.getInstance(BATCHNAME).AV_Limit__c;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String  cibeQuery;
        if (String.isBlank(limitBatch)){
            cibeQuery = 'SELECT Id, CIBE_CerradoNegativo__c , StageName, Name FROM Opportunity WHERE StageName IN :stageName AND RecordType.DeveloperName IN : listRTs AND (CIBE_LastUpdatedCerradoNegativo__c < LAST_N_MONTHS:3)';
        } else{
            cibeQuery = 'SELECT Id, CIBE_CerradoNegativo__c , StageName, Name FROM Opportunity WHERE StageName IN :stageName AND RecordType.DeveloperName IN : listRTs AND (CIBE_LastUpdatedCerradoNegativo__c < LAST_N_MONTHS:3) LIMIT '+ limitBatch+'';
        }

        return Database.getQueryLocator(cibeQuery);
    }

    /**
	 * Cambio del CIBE_CerradoNegativo__c a No gestionada
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Opportunity> param with the list of Accounts.
	 */
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
		try{
            if(!scope.isEmpty()){
                recordsProcessed = scope.size();
				
                for(Opportunity opp : scope){
                    opp.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_CERRNEGA;
                    opp.CIBE_CerradoNegativo__c = 'No gestionada';
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
        Integer numb = String.Isblank(limitBatch)? 50 : Integer.valueOf(limitBatch);
        List<Opportunity> opps = [SELECT Id, CIBE_CerradoNegativo__c , StageName, Name FROM Opportunity WHERE StageName IN :stageName AND RecordType.DeveloperName IN : listRTs AND (CIBE_LastUpdatedCerradoNegativo__c < LAST_N_MONTHS:3)];
        if(!opps.isEmpty()){
            CBK_BatchJob.executeBatch('CIBE_OppCerradoNegativoSchedulable', numb ,params);
        }
    }

}