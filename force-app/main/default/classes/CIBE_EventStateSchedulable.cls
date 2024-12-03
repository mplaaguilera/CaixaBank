/**********************************************************************************************************************
Name:	  CIBE_EventStateSchedulable
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Batch para pasar a estado 'Vencido' todos eventos que tengan el closeDate inferior a TODAY
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				        DATE				Description
	1.0					            Ali & Bea                   07/03/2024			Init version
***********************************************************************************************************************/
public class CIBE_EventStateSchedulable implements Database.Batchable<sObject>, Database.Stateful {

    public Integer recordsProcessed = 0;
    public String limitBatch;
    public static final String BATCHNAME = 'CIBE_EventStateSchedulable';
	private static List<String> listRTs = new List<String>{	CIBE_AppConstants.EVENT_CLIENTE_CIB_RT,
												CIBE_AppConstants.EVENT_GESTOR_CIB_RT};

	private static List<String> stageName = new List<String>{'Planificada'};                     
	
    public CIBE_EventStateSchedulable(){
        System.debug('');
    }

    public CIBE_EventStateSchedulable(String avQuery){
        //AV_SchedulerBatches.getLimit(BATCHNAME);
        limitBatch = AV_ScheduleBatch__mdt.getInstance(BATCHNAME).AV_Limit__c;
    }
    
	/**
	 * Encuentra los eventos con  ActivityDate inferior a hoy y Estado 'Planificada'
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
    public Database.QueryLocator start(Database.BatchableContext bc){
        String  cibeQuery;
        if (String.isBlank(limitBatch)){
            cibeQuery = 'SELECT Id, RecordType.DeveloperName, ActivityDate, Subject, CSBD_Evento_Estado__c FROM Event WHERE ActivityDate>= LAST_N_MONTHS:18 AND ActivityDate< TODAY AND RecordType.DeveloperName IN : listRTs AND CSBD_Evento_Estado__c IN :stageName';
        } else{
            cibeQuery = 'SELECT Id, RecordType.DeveloperName, ActivityDate, Subject, CSBD_Evento_Estado__c FROM Event WHERE ActivityDate>= LAST_N_MONTHS:18 AND ActivityDate< TODAY AND RecordType.DeveloperName IN : listRTs AND CSBD_Evento_Estado__c IN :stageName LIMIT '+ limitBatch;
        }
        return Database.getQueryLocator(cibeQuery);
    }
    
	/**
	 * Cambio del CSBD_Evento_Estado__c a Vencida
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Event> param with the list of Accounts.
	 */
    public void execute(Database.BatchableContext bc, List<Event> scope) {
        DateTime createdFormatDate = System.today();
		try{
            if(!scope.isEmpty()){
                recordsProcessed = scope.size();
				
                for(Event event : scope){
                    event.CSBD_Evento_Estado__c = 'Vencida';
                }
                if(!scope.isEmpty() && Schema.Event.SObjectType.getDescribe().isUpdateable()){
                
                    Database.SaveResult[] srList = Database.update(scope, false);
                    boolean hasError = false;
                    List<Object> objs = new List<Object>();
                    Map<String, String> msjs = new Map<String, String>();
                    for (Integer i = 0; i < scope.size(); i++) {
                        Database.SaveResult sr = srList[i];
                        if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
                            msjs.put(scope[i].Id + '_' + scope[i].Subject, ((String)sr.getErrors()[0].getMessage()));
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
        String methodName = 'finish'; 
    }
    
}