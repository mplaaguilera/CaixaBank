/**********************************************************************************************************************
 Name:	  EV_ChangeStatus_AI_TRHan
 Copyright © 2024  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de EV_ChangeStatus__e (Platform Event) AfterInsert
----------------------------------------------------------------------------------------------------------------------
Historial
----------------------------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		    DE75856             Carolina Lopez      08/02/2024			Init version
    1.1         FIX                 Carolina Lopez      08/04/2024          Modify the job logic with unique names using custom configuration and optimize the query.
***********************************************************************************************************************/
public without sharing class EV_ChangeStatus_AI_TRHan {
    public static void changeStatusCamp(List<EV_ChangeStatus__e> lstCS) {
        if(!lstCS.isEmpty()){
            EV_LogDebug.printLogDebug('@@changeStatusCamp ', String.valueOf(lstCS));
            EV_ByPass__c cSettingTokens = EV_ByPass__c.getOrgDefaults();
            String jobName = cSettingTokens.EV_ScheduleName__c + '_%';
            Map<String, CronTrigger> mapJobPending = new Map<String, CronTrigger>();
            List<CronTrigger> lstCron = new List<CronTrigger>();
            
            if(Schema.sObjectType.CronTrigger.isAccessible()){
                lstCron = [SELECT Id, CronjobDetail.Name, State, NextFireTime  
                            FROM CronTrigger WHERE CronjobDetail.JobType = '7' AND CronjobDetail.Name like:jobName AND State != 'DELETED' ORDER BY NextFireTime desc];
                for(CronTrigger jobs : lstCron){
                    mapJobPending.put(jobs.cronjobdetail.name, jobs); 
                }
            }
            for(EV_ChangeStatus__e event : lstCS) { 
                if(event.EV_ScheduledTime__c != null){
                    String jobNameUnico = cSettingTokens.EV_ScheduleName__c + '_' + String.valueOf(event.EV_ExecutionDate__c);
                    if(!mapJobPending.containsKey(jobNameUnico)){
                        EV_LogDebug.printLogDebug('@@event.EV_ScheduledTime__c containsKey ', String.valueOf(event.EV_ScheduledTime__c));
                        EV_LogDebug.printLogDebug('@@event.EV_ExecutionDate__c containsKey ', String.valueOf(event.EV_ExecutionDate__c));
                        System.schedule(jobNameUnico, event.EV_ScheduledTime__c, new EV_SCHChangeStatus());
                    }else {
                        CronTrigger existingJob = mapJobPending.get(jobNameUnico);
                        if (existingJob.NextFireTime != event.EV_ExecutionDate__c) {
                            System.abortJob(existingJob.Id);
                            EV_LogDebug.printLogDebug('@@event.EV_ScheduledTime__c ', String.valueOf(event.EV_ScheduledTime__c));
                            EV_LogDebug.printLogDebug('@@event.EV_ExecutionDate__c ', String.valueOf(event.EV_ExecutionDate__c));
                            System.schedule(jobNameUnico, event.EV_ScheduledTime__c, new EV_SCHChangeStatus());
                        }
                    }
                }
            }
        }
    }
}