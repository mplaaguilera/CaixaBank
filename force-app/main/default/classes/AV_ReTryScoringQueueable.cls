/**********************************************************************************************************************
Name: AV_ReTryScoringQueueable
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Hacer los reintentos del cálculo del scoring de forma asíncrona
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY		AUTHOR			  	DATE			Description
1.0			FE144643        Luis Fernández      29/12/2023		Init version
1.1         DT03            Luis Fernández      12/04/2024      -Get rid of useles lines and new times for relaunching queuable.
                                                                -Added new params to cbk_log.SaveError method call
1.2         PPM100205278    Luis Fernández      28/05/2024       Added No gestionada wherever Vencida is 

***********************************************************************************************************************/
public with sharing class AV_ReTryScoringQueueable implements Queueable {
    Integer reintentosMaximos = 4;
    Set<String> clientsToRetry;
    Integer reintentos;
    Exception exp;
    List<Object> failedClients = new List<Object>();
    String transactionType;
    public AV_ReTryScoringQueueable(Set<String> clientsToRetry,Exception exp,Integer reintentos,String transactionType) {
        this.clientsToRetry = clientsToRetry;
        this.reintentos = reintentos;
        this.transactionType = transactionType;
        for(String client : clientsToRetry){
            failedClients.add((String) client);
        }
        this.exp = exp;
    }

    /**
	 * Executes the Queueable job
	 * @param qc	QueueableContext param that contains the context of the queueable
	 */
	public void execute(QueueableContext qc) {

        Set<String> retailRts = new Set<String>{ 
            AV_AppConstants.OPPINICIATIVA_RT,
            AV_AppConstants.OPPALERTACOM_RT,
            AV_AppConstants.OPPPROPUESTA_RT,
            AV_AppConstants.OPPSUGERENCIA_RT,
            AV_AppConstants.OPPLLAMADA_RT
        };
        Set<String> zeroStatus = new Set<String>{
            AV_AppConstants.OPP_STATUS_POTENCIAL,
            AV_AppConstants.OPP_STATUS_ENGESTION,
            AV_AppConstants.OPP_STATUS_VENCIDO,
            AV_AppConstants.OPP_STATUS_NO_GESTIONADA
        };
        Set<String> accsToWork = clientsToRetry ;
        List<Opportunity> opposForRecalculateScoring = [SELECT Id,AV_PotencialityOpportunityValue__c,AccountId FROM Opportunity WHERE AccountId IN :accsToWork AND RecordType.DeveloperName IN :retailRts AND StageName IN :zeroStatus];
        List<Account> processedClients = AV_OpportunityTriggerHelper.calculateScoreClient(opposForRecalculateScoring,new List<String>(accsToWork),true,transactionType);

        Map<Id,Account> mapIdClients = new Map<Id,Account>(processedClients);
        List<Database.SaveResult> srUpdtClients = Database.update(processedClients,false);

            Set<String> failedClientsAgain = new Set<String>();
            for(Integer i=0;i<srUpdtClients.size();i++){
                if(!srUpdtClients[i].isSuccess()){
                    failedClientsAgain.add(processedClients[i].Id);
                }
            }
            
            if(!failedClientsAgain.isEmpty()){

                ++reintentos;
                if( (reintentos < reintentosMaximos)){
                    if(!Test.isRunningTest()){
                        System.enqueueJob(new AV_ReTryScoringQueueable(clientsToRetry,exp,reintentos,transactionType),Integer.valueOf(Math.pow(2,reintentos)));
                    }
                    
                }else if(reintentos == reintentosMaximos){
                        CBK_Log.saveError('AV_Scoring',exp,exp.getMessage(),failedClients,new Map<String,String>{'state__c' => 'PENDING'});
                }
            }
    }
}