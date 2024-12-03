/**********************************************************************************************************************
 Name:	  AV_ReTryScoringBatch
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso reintentar los scorings fallidos de forma asíncrona apartir de la lectura de los CBK_Logs
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			FE144643		Luis Fernández	    09/01/2024			Init version
    1.1         DT03            Luis Fernández      12/04/2024          -Changed initial query and fixed duplicated log problems
    1.2         PPM100205278    Luis Fernández      28/05/2024          Added No gestionada wherever Vencida is 
***********************************************************************************************************************/
public with sharing class AV_ReTryScoringBatch implements Database.Batchable<sObject>, Database.Stateful   {
    public AV_ReTryScoringBatch(){

    }
	public Database.QueryLocator start(Database.BatchableContext bc){
        String methodName = 'start';
        String query = 'select Id, Framework_Logging__c, Detail__c,Framework_Logging__r.Subject__c,Framework_Logging__r.State__c from CBK_Log_Detail__c where Framework_Logging__r.Transaction_ID__c = \'AV_Scoring\' AND Framework_Logging__r.state__c IN  (\'PENDING\',\'SOLVED\')';

        return Database.getQueryLocator(query);
    }   

	public void execute(Database.BatchableContext bc,List<CBK_Log_Detail__c> listLogs){
        Set<String> retailRts = new Set<String>{ 
            AV_AppConstants.OPPINICIATIVA_RT,
            AV_AppConstants.OPPALERTACOM_RT,
            AV_AppConstants.OPPPROPUESTA_RT,
            AV_AppConstants.OPPSUGERENCIA_RT,
            AV_AppConstants.OPPLLAMADA_RT
        };
		Savepoint sp = Database.setSavepoint();
        Map<String,List<Id>> logToOppoMap = new Map<String,List<Id>>();
        Map<Id,CBK_Log_Detail__c> mapLogs = new Map<Id,CBK_Log_Detail__c>(listLogs);
        List<Id> newAccountsToUpdt = new List<Id>();
        
        List<Opportunity> oppToRecalculate = new List<Opportunity>() ;
        List<Account> accToRecalculate = new List<Account>() ;
        List<Id> logsToClose = new List<Id>(); 
        List<Id> logsToClean = new List<Id>();
        Set<Id> accountsToReUpdt = new Set<Id>(); 
        for(CBK_Log_Detail__c log :listLogs){
            if(log.Framework_Logging__r.State__c.equals('PENDING') ){
                    accountsToReUpdt.add(log.Detail__c);
                if(!logsToClose.contains(log.Framework_Logging__c)){
                    logsToClose.add(log.Framework_Logging__c);
                }
                
            }
            if(log.Framework_Logging__r.State__c.equals('SOLVED') && !logsToClean.contains(log.Framework_Logging__c)){
                
                logsToClean.add(log.Framework_Logging__c);
            }
        }

        if(!logsToClean.isEmpty()){
            List<Database.DeleteResult> delSolvedRes = Database.delete(logsToClean,false);
        }
        Map<String,Decimal> oppToScore;
        Map<String,Decimal> accScore;
        Set<String> zeroStatus = new Set<String>{
            AV_AppConstants.OPP_STATUS_ENGESTION,
            AV_AppConstants.OPP_STATUS_POTENCIAL,
            AV_AppConstants.OPP_STATUS_VENCIDO,
            AV_AppConstants.OPP_STATUS_NO_GESTIONADA

        };
           
               List<Opportunity> opposForRecalculateScoring = [SELECT Id,AV_PotencialityOpportunityValue__c,AccountId FROM Opportunity WHERE  AccountId IN :accountsToReUpdt AND StageName IN :zeroStatus AND RecordType.DeveloperName IN :retailRts ORDER BY Account.AV_NumPerso__c asc];
           
               List<Database.SaveResult> srAcc = Database.update(AV_OpportunityTriggerHelper.calculateScoreClient(opposForRecalculateScoring,newAccountsToUpdt,true,null));
               Boolean finishBatch = true;
               for(Database.SaveResult sr : srAcc){
               if(!sr.isSuccess()){
                   finishBatch = false;
                   Database.rollback( sp );
                   break; 
               }
              }
              if(finishBatch){
                List<CBK_Log__c> logsToCloseObj = new List<CBK_Log__c>();
                for(Id logId :logsToClose ){
                    logsToCloseObj.add(new CBK_Log__c(Id = logId, state__c = 'SOLVED'));
                }

                Database.update(logsToCloseObj,false);
              }
            }

    // }   
	public void finish(Database.BatchableContext bc){
    }   


}