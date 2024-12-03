/*****************************************************************************************
 * Name: EV_BatchEmailCMCustom
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Lanzar un batch 24h antes del evento que mande un recordatorio vía email.
 * 
 * -------
 * VERSION        USER_STORY         AUTHOR                                 DATE         Description
 * 1.0            US635293           Carolina Lopez / Humberto Vilchez      23/06/2023   Init Version
 * 1.1            US661500           Carolina Lopez                         25/07/2023   Include new field EV_TechSummit__c and remove RT TechSummit
 * 1.2			  US680535			 Daniel Rodriguez						31/7/2023	 Remove html code and change principal query
 * 1.3            US680535           Mamen Arias                            10/08/2023   Change the reminder from 2 days to 1
 * 1.4		      US680535           Daniel Rodriguez                       18/08/2023   Manage error in send email
******************************************************************************************/
public without sharing class EV_BatchEmailCMCustom implements Database.Batchable<sObject>, Schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext dbc) {
        Date currentDate   = System.today();
        Date afterOneDayDate = currentDate.addDays(1);

        return Database.getQueryLocator([SELECT id,EV_CampaignId__r.Name,EV_LeadId__c, EV_Status__c, EV_CodigoQR__c,EV_FirstName__c, EV_CampaignId__r.StartDate, EV_CampaignId__r.EV_HoraInicio__c, EV_CampaignId__r.EV_HoraFin__c, EV_CampaignId__r.EV_Description__c,EV_CampaignId__r.EV_Duracion__c, EV_CampaignId__r.EV_LugarDeCelebracion__c, EV_LeadId__r.Email, RecordTypeId, EV_CampaignId__c, EV_CampaignId__r.EV_TechSummit__c 
                                FROM EV_CampaignMemberC__c 
                                WHERE EV_CampaignId__r.StartDate = : afterOneDayDate AND EV_CampaignId__r.EV_TechSummit__c = true AND EV_CampaignId__r.EV_NewArchitecture__c = true AND EV_Status__c != 'QR Enviado']);
    }
    
    public void execute(Database.BatchableContext dbc, List<EV_CampaignMemberC__c> lstCampaignsMC){
        EV_LogDebug.printLogDebug('EV_BatchEmailCMCustom ::lstCampaignsMC::',String.valueof(lstCampaignsMC));
        EmailTemplate emailTemplateOficina = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName = 'EV_MassEmailTech'];           
        List<EV_CampaignMemberC__c> campaignMemUpdList = new List<EV_CampaignMemberC__c>();
        Map<String, String> msjsError = new Map<String, String>();
        Messaging.MassEmailMessage massEmail = new Messaging.MassEmailMessage();
        Set<Id> leadIdsSet = new Set<Id>();
        Set<Id> campaignIdsSet = new Set<Id>();
        List<Id> leadList = new List<Id>();
        
        if(!lstCampaignsMC.isEmpty()){
            for (EV_CampaignMemberC__c campMem : lstCampaignsMC) {
                campaignIdsSet.add(campMem.EV_CampaignId__c);
                leadIdsSet.add(campMem.EV_LeadId__c);
                campMem.EV_Status__c = 'QR enviado';
                campaignMemUpdList.add(campMem);
            }
            if(!leadIdsSet.isEmpty()){
                leadList.addAll(leadIdsSet);
            }
            massEmail.setTargetObjectIds(leadList);
            massEmail.setTemplateId(emailTemplateOficina.Id);
            massEmail.setSaveAsActivity(false);
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.MassEmailMessage[] { massEmail });
            
            for (Messaging.SendEmailResult result : results) {
                if (result.isSuccess()) {
                    EV_LogDebug.printLogDebug('result.isSuccess()',String.valueof(result));
                } else {
                    String errorMessage = 'Error al enviar el correo electrónico: ';
                    if (result.getErrors() != null && !result.getErrors().isEmpty()) {
                        for (Messaging.SendEmailError error : result.getErrors()) {
                            errorMessage += error.getMessage() + '\n';
                            msjsError.put(error.getMessage(), String.valueof(error));
                        }
                    }
                    CBK_Log.error(msjsError);
                }
            }

            EV_LogDebug.printLogDebug('results SendEmailResult:',String.valueof(results));
            EV_LogDebug.printLogDebug('campaignMemUpdList:',String.valueof(campaignMemUpdList));
            if(!results.isEmpty()){
                if(results[0].success && !campaignMemUpdList.isEmpty()){
                    update campaignMemUpdList;
                }
            }
        }  
    }
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new EV_BatchEmailCMCustom());
    }
    public void finish(Database.BatchableContext dbc){
        EV_LogDebug.printLogDebug('FINISH ',String.valueof(dbc));

     }
}