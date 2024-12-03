/**********************************************************************************************************************
 Name:	  EV_BatchCampaignMemberNoClients
 Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase para batch de ocultamiento de leads
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		                	  Daniel Rodriguez    27/09/2022			Modify query and randon generator
    1.1                           Mamen Arias         22/11/2022            Modify query with more filters Accionistas
	1.2							  Daniel Rodriguez	14/03/2023				Modify if leadIds if null

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
        List<CampaignMember> mems = [Select Id, LeadId, EV_ConsentmientoGeneral__c, Campaign.StartDate, Lead.RecordType.DeveloperName from CampaignMember where ((Lead.RecordType.DeveloperName = 'EV_Evento' and EV_ConsentmientoGeneral__c = true and Campaign.StartDate <= :dateConsentimientoActivo and lead.email != '') or (Lead.RecordType.DeveloperName = 'EV_Evento' and EV_ConsentmientoGeneral__c = false and Campaign.StartDate <= :dateNoConsentimiento and lead.email != '') or (Lead.RecordType.DeveloperName = 'EV_LeadAccionistas' and Campaign.StartDate <= :dateAccionista and lead.email != '')) and LeadId != null and Campaign.status = '005'];

        if(mems!=null){
            for(CampaignMember m : mems){
                leadIds.add(m.LeadId);
            }
        }
        if(!leadIds.isEmpty()){
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