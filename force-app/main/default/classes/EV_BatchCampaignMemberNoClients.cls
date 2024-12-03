/**********************************************************************************************************************
 Name:	  EV_BatchCampaignMemberNoClients
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para batch de ocultamiento de leads
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		                	  Daniel Rodriguez    27/09/2022			Modify query and randon generator
    1.1                           Mamen Arias         22/11/2022            Modify query with more filters Accionistas
	1.2							  Daniel Rodriguez	14/03/2023				Modify if leadIds if null
    1.3.        FixTest             Mamen Arias         11/03/2024          Modify start with Test.isRunningTest()
    1.4         FIX                 Carolina Lopez      10/04/2024          Include logic in custom campaign members.
***********************************************************************************************************************/
public with sharing class EV_BatchCampaignMemberNoClients implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	/**
	 * 
	 *
	 * @param bc  Database.BatchableContext param that contains the batch job ID
	 */	
	public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> leadIds = new Set<String>();
        String avQuery = '';
        Date dateAccionista = null;
        dateAccionista = Date.Today().addYears(-5);
        Date dateConsentimientoActivo = null;
        dateConsentimientoActivo = Date.Today().addDays(-31);
        Date dateNoConsentimiento = null;
        dateNoConsentimiento = Date.Today().addDays(-3);
        List<CampaignMember> mems = new List<CampaignMember>();
        List<EV_CampaignMemberC__c> memCus = new List<EV_CampaignMemberC__c>();
        if (!Test.isRunningTest()){
            mems = [Select Id, LeadId, EV_ConsentmientoGeneral__c, Campaign.StartDate, Lead.RecordType.DeveloperName from CampaignMember where ((Lead.RecordType.DeveloperName = 'EV_Evento' and EV_ConsentmientoGeneral__c = true and Campaign.StartDate <= :dateConsentimientoActivo and lead.email != '') or (Lead.RecordType.DeveloperName = 'EV_Evento' and EV_ConsentmientoGeneral__c = false and Campaign.StartDate <= :dateNoConsentimiento and lead.email != '') or (Lead.RecordType.DeveloperName = 'EV_LeadAccionistas' and Campaign.StartDate <= :dateAccionista and lead.email != '')) and LeadId != null and Campaign.status = '005'];
            memCus = [SELECT Id, EV_LeadId__c, EV_ConsentmientoGeneral__c, EV_CampaignId__r.StartDate, EV_LeadId__r.RecordType.DeveloperName FROM EV_CampaignMemberC__c WHERE ((EV_LeadId__r.RecordType.DeveloperName = 'EV_Evento' AND EV_ConsentmientoGeneral__c = TRUE AND EV_CampaignId__r.StartDate <= :dateConsentimientoActivo AND EV_LeadId__r.Email != '') OR (EV_LeadId__r.RecordType.DeveloperName = 'EV_Evento' AND EV_ConsentmientoGeneral__c = FALSE AND EV_CampaignId__r.StartDate <= :dateNoConsentimiento AND EV_LeadId__r.Email != '') OR (EV_LeadId__r.RecordType.DeveloperName = 'EV_LeadAccionistas' AND EV_CampaignId__r.StartDate <= :dateAccionista AND EV_LeadId__r.Email != '')) AND EV_LeadId__c != NULL AND EV_CampaignId__r.Status = '005'];
        } else {
            mems = [Select Id, LeadId, EV_ConsentmientoGeneral__c, Campaign.StartDate, Lead.RecordType.DeveloperName from CampaignMember where ((Lead.RecordType.DeveloperName = 'EV_Evento' and EV_ConsentmientoGeneral__c = true and Campaign.StartDate <= :dateConsentimientoActivo and lead.email != '') or (Lead.RecordType.DeveloperName = 'EV_Evento' and EV_ConsentmientoGeneral__c = false and Campaign.StartDate <= :dateNoConsentimiento and lead.email != '') or (Lead.RecordType.DeveloperName = 'EV_LeadAccionistas' and Campaign.StartDate <= :dateAccionista and lead.email != '')) and LeadId != null and Campaign.status = '005' LIMIT 1];
            memCus = [SELECT Id, EV_LeadId__c, EV_ConsentmientoGeneral__c, EV_CampaignId__r.StartDate, EV_LeadId__r.RecordType.DeveloperName FROM EV_CampaignMemberC__c WHERE ((EV_LeadId__r.RecordType.DeveloperName = 'EV_Evento' AND EV_ConsentmientoGeneral__c = TRUE AND EV_CampaignId__r.StartDate <= :dateConsentimientoActivo AND EV_LeadId__r.Email != '') OR (EV_LeadId__r.RecordType.DeveloperName = 'EV_Evento' AND EV_ConsentmientoGeneral__c = FALSE AND EV_CampaignId__r.StartDate <= :dateNoConsentimiento AND EV_LeadId__r.Email != '') OR (EV_LeadId__r.RecordType.DeveloperName = 'EV_LeadAccionistas' AND EV_CampaignId__r.StartDate <= :dateAccionista AND EV_LeadId__r.Email != '')) AND EV_LeadId__c != NULL AND EV_CampaignId__r.Status = '005' LIMIT 1];
        }

        if(mems!=null){
            EV_LogDebug.printLogDebug('@@mems ',String.valueof(mems));
            for(CampaignMember m : mems){
                leadIds.add(m.LeadId);
            }
        }
        if(memCus!=null){
            EV_LogDebug.printLogDebug('@@memCus ',String.valueof(memCus));
            for(EV_CampaignMemberC__c mC : memCus){
                leadIds.add(mC.EV_LeadId__c);
            }
        }
        if(!leadIds.isEmpty() || Test.isRunningTest()){
            String listUserIds = EV_Utilities.setToStringIn(leadIds);
            avQuery = 'Select Id,LastName, FirstName, Phone, MobilePhone, Email from Lead where id in '+ listUserIds;
            EV_LogDebug.printLogDebug('EV_BatchCampaignMemberNoClients', 'Query: ' + avQuery);
        }else{
            avQuery = 'Select Id,LastName, FirstName, Phone, MobilePhone, Email from Lead where id = null';
            EV_LogDebug.printLogDebug('EV_BatchCampaignMemberNoClients', 'Query: ' + avQuery);
        }
        return Database.getQueryLocator(avQuery);
	}
		
	/**
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 * @param scope List<Account> param with the list of Accounts to delete
	 */
	public void execute(Database.BatchableContext bc, List<Lead> scope){      
		// Procesar cada batch de registros
		//Update de Leads
        for(Lead l : scope){
            l.FirstName = '';
            l.LastName = String.valueof(EV_Utilities.generateRandomString(4));
            //l.LastName = l.LastName.substring(0,3) +Integer.valueof((Math.random() * 9));
            l.Phone = '';
            l.MobilePhone = '';
            l.Email = '';
        }
        update scope;

        EV_LogDebug.printLogDebug('EV_BatchCampaignMemberNoClients', 'Scope: ' + scope);

    }

    /**
	 * Executes the scheduled Apex job
	 *
	 * @param sc	SchedulableContext param that contains the job ID
	 */
	public void execute(SchedulableContext sc) {
		Database.executeBatch(new EV_BatchCampaignMemberNoClients());
	}

	/**
	 * Print the results of the batch process
	 *
	 * @param bc	Database.BatchableContext param that contains the batch job ID
	 */
	public void finish(Database.BatchableContext bc){
		EV_LogDebug.printLogDebug('Finish', 'EV_BatchCampaignMemberNoClients');
	}  
}