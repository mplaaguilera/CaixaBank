/**********************************************************************************************************************
 Name:	  AV_TeamsGCF_Queueable
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Lanza la Api de GCF
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY		AUTHOR				DATE				Description
   1.0			App FSC			Sandra Gómez		27/06/2022			Init version
   1.1			Fix PMD Errors  Daniel Rodriguez	05/10/2023			Add square brackets to if clauses
   1.2          IN1123492       Elisabeth R.        04/04/2024          Add contact person in event params
   1.3         FIX28080841     Oscar Moreno         03/09/2024          Fix error The Global modifier should be avoided.
***********************************************************************************************************************/
public class AV_TeamsGCF_Queueable implements Queueable, Database.AllowsCallouts {
    
    String jsonString;
    String subject;
    Datetime endDateTime;
    Datetime startDateTime;
    String headerId;
    String userName;
    String azureId;

    public AV_TeamsGCF_Queueable(String serializedEvent, String subject, Datetime endDateTime, Datetime startDateTime, String headerId, String userName, String azureId) {
        this.jsonString=serializedEvent;
        this.subject=subject;
        this.endDateTime=endDateTime;
        this.startDateTime=startDateTime;
        this.headerId=headerId;
        this.userName=userName;
        this.azureId=azureId;
    }

    /**
	 * Executes the Queueable job
	 * @param qc	QueueableContext param that contains the context of the queueable
	 */
	public void execute(QueueableContext qc) {
        futureCreateMeeting(subject, endDateTime, startDateTime, headerId, userName, azureId, jsonString);
        if (!Test.isRunningTest()) {
            insertEventGCFFuture(jsonString);
        }
	}

    @Future(callout=true)
    public static void insertEventGCFFuture(String jsonString){
		String methodName = 'insertEventGCF';
		Event evento = (Event)Json.deserialize(jsonString,Event.class);
		Id evGestorRT = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTGESTOR_RT).Id;
		List<Event> eventToUpdate = new List<Event>();
		List<CBK_Activity_Extension__c> crmTareas = new List<CBK_Activity_Extension__c>();
		Set<Id> idsAccount = new Set<Id>();
		// Set<Id> idsOwner = new Set<Id>();
		Set<String> idsOwner = new Set<String>();
		Map<Id,Account> mapCustomer = new Map<Id,Account>();
		Map<Id,User> mapEmployee = new Map<Id,User>();
		Map<String,Event> mapEventsHeaders = new Map<String,Event>();
        Map<Id,Event> mapRecurrentEvents = new Map<Id,Event>();
		List<AV_HeaderCustomActivity__c> cumstomHeaders = new List<AV_HeaderCustomActivity__c>();

		Integer limiteQ = 1;
		Set<Id> idsContactPerson = new Set<Id>();
		idsContactPerson.add(evento.WhoId);

		if (evento.IsRecurrence2 || evento.IsRecurrence){
			mapRecurrentEvents.put(evento.Id, evento);
		}
		idsAccount.add(evento.WhatId);
		idsOwner.add(evento.OwnerId);
		if(!String.isEmpty(evento.AV_ExternalId__c)){
			 mapEventsHeaders.put(evento.AV_ExternalId__c, evento);
		}
		//Get list of employees
		List<User> employeeList = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c, Username From User Where Id in :idsOwner];					
		for(User u : employeeList){
			mapEmployee.put(u.Id,u);
		}
		//Get list of customers related with the events
		List<Account> customer = [Select Id, AV_NumPerso__c, FirstName, LastName From Account Where Id In :idsAccount];
		for(Account a : customer){
			mapCustomer.put(a.Id,a);
		}
		//Get the list of externalID for recurrent event
		Map<String, String> mapEventIds;
        if(mapRecurrentEvents != null && !mapRecurrentEvents.isEmpty()){
            mapEventIds = AV_CitaPrevia_SyncEvents.getExternalIdRecurrentEvent(mapRecurrentEvents);
        }
        //Get the header-task
		Map<String, AV_HeaderCustomActivity__c> mapHeaderTask = new Map<String, AV_HeaderCustomActivity__c>();
		if(mapEventsHeaders != null && !mapEventsHeaders.isEmpty()){
			List<AV_HeaderCustomActivity__c> listHeaderTask  = [Select Id, AV_ExternalId__c, AV_UrlTeams__c From AV_HeaderCustomActivity__c Where AV_ExternalId__c in :mapEventsHeaders.keySet()];
			for(AV_HeaderCustomActivity__c aux : listHeaderTask){
				mapHeaderTask.put(aux.AV_ExternalID__c, aux);
			}
		}

		// TEST PERSONA DE CONTACTO										
        Map<Id, Contact> mapContactPerson = new Map<Id, Contact>();
        if(Contact.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.Contact.fields.AV_NumPerso__c.isAccessible()) {
            limiteQ = idsContactPerson.size();
            mapContactPerson = new Map<Id, Contact>([SELECT Id, Name, AV_NumPerso__c FROM Contact WHERE Id IN :idsContactPerson Limit :limiteQ]);
        }


		//Send the data to GCF and save the response
		try{
			AV_HeaderCustomActivity__c headerTask = null;
			if(mapHeaderTask != null && !mapHeaderTask.isEmpty()){
				 headerTask = mapHeaderTask.get(evento.AV_ExternalID__c);
			}
			AV_CitaPrevia_Integration.Event parms = AV_CitaPrevia_SyncEvents.buildBodyRequest(evento, null, mapCustomer.get(evento.WhatId), mapEmployee.get(evento.OwnerId), headerTask, mapContactPerson?.get(evento.WhoId));
			String externalID = evento.AV_ExternalID__c;
			if (evento.IsRecurrence2 || evento.IsRecurrence){
				externalID = mapEventIds.get(evento.Id);
			}
			if((!String.isNotBlank(externalID) && externalID.startsWith(AV_EventTriggerHelper.SUFFIX_EXTERNALID)) || !((evento.IsRecurrence2 || evento.IsRecurrence) && String.isNotBlank(externalID))){
				AV_CitaPrevia_Integration.InsCntResponse res;
				if (!mapEmployee.get(evento.OwnerId).Username.contains('gcf-integration')) {
					res = AV_CitaPrevia_Integration.intCnt(parms, mapEmployee.get(evento.OwnerId).AV_ExternalID__c, mapEmployee.get(evento.OwnerId).AV_NumeroOficinaEmpresa__c);
				}else {
					res = AV_CitaPrevia_Integration.intCnt(parms, evento.AV_CodigoGestorAsignado__c, mapEmployee.get(evento.OwnerId).AV_NumeroOficinaEmpresa__c);
				}
				AV_LogDebug.printLogDebug(methodName, 'Insert response: ' + res);
				if('201'.equalsIgnoreCase(res.StatusCode)){
					Event eUpt = new Event();
					eUpt.Id = evento.Id;
					if (!evento.IsRecurrence2 || !evento.IsRecurrence){
						eUpt.AV_ExternalID__c = res.eventPremiumId;
					}
					eUpt.AV_origenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
					eventToUpdate.add(eUpt);
					//Create header-task only for RT=Gestor and Recurrence
					if (evento.RecordTypeId == evGestorRT && (evento.IsRecurrence2 || evento.IsRecurrence)) {
						AV_HeaderCustomActivity__c headerCustomAct = AV_CitaPrevia_SyncEvents.createRecurrentEventHeader(evento, res.eventPremiumId);
						if (headerCustomAct != null) {
							cumstomHeaders.add(headerCustomAct);
						}
					}
				}
				AV_CitaPrevia_SyncEvents.saveResponseAPI(crmTareas, evento, JSON.serialize(res));
			}
		}catch(AV_ApplicationException ae){
			AV_LogDebug.printException(methodName, ae);
			AV_CitaPrevia_SyncEvents.saveResponseAPI(crmTareas, evento, 'Description field with more than 2000 characters');
		}
		//Save data into DB
		if(eventToUpdate!=null && !eventToUpdate.isEmpty()){
			List<Database.SaveResult> listResult = Database.update(eventToUpdate, false);
			AV_AppUtilities.displayErrors(methodName, listResult);
		}
		if(crmTareas!=null && !crmTareas.isEmpty()){
			List<CBK_Activity_Extension__c> crmTaskToUpdate = AV_CitaPrevia_SyncEvents.checkCrmTaskOverride(crmTareas);
			List<Database.SaveResult> listResult = Database.update(crmTaskToUpdate, false);
			AV_LogDebug.printLogDebug(methodName, 'Result update CRM TASK----: ' + crmTaskToUpdate);
			AV_AppUtilities.displayErrors(methodName, listResult);
			
			AV_LogDebug.printLogDebug(methodName, 'Result upsert CRM TASK----: ' + crmTareas);
			List<Database.UpsertResult> listResult2 = Database.upsert(crmTareas, false);
			AV_AppUtilities.displayErrors(methodName, listResult2);
		}
		if (cumstomHeaders!=null && !cumstomHeaders.isEmpty()) {
			AV_LogDebug.printLogDebug(methodName, 'Result insert HEADER TASK----');
			List<Database.SaveResult> listResult = Database.insert(cumstomHeaders, false);
			AV_AppUtilities.displayErrors(methodName, listResult);
		}
	}

    private static void futureCreateMeeting(String subject, Datetime EndDateTime, Datetime StartDateTime, String headerId, String userName, String azureId, String jsonString){
		String methodName = 'futureCreateMeeting';
		AV_AzureTeamsToken__c tok = AV_AzureTeamsToken__c.getValues('AzureTeamToken');
		AV_Teams_Integration.Response res = new AV_Teams_Integration.Response();
		Boolean firstToken = false;
		String userId;
		String access_token;
		String delToken = null;
		AV_Teams_Integration.Meeting meet = new AV_Teams_Integration.Meeting();
		meet.startDateTime = StartDateTime;
		meet.endDateTime = EndDateTime;
		meet.subject = subject;
		if(tok!=null && tok.AV_ExpiresIn__c != null ){
			Datetime exp = tok.CreatedDate.addSeconds( Integer.valueOf(tok.AV_ExpiresIn__c));
			if(System.now() >= exp){
				delToken = tok.Id;
				res = AV_Teams_Integration.getToken();
				access_token = res.data.access_token;
			}else{
				access_token = AV_Teams_Integration.getTokenString(new String[]{
					tok.AV_Token1__c,
					tok.AV_Token2__c,
					tok.AV_Token3__c,
					tok.AV_Token4__c,
					tok.AV_Token5__c,
					tok.AV_Token6__c,
					tok.AV_Token7__c,
					tok.AV_Token8__c,
					tok.AV_Token9__c
				});
			}
		}else{
			firstToken = true;
			res = AV_Teams_Integration.getToken();
			access_token = res.data.access_token;
		}
		if(!String.isBlank(azureId)){
			userId = azureId;
		}else{
			if(!String.isBlank(userName)){
				userId = AV_Teams_Integration.getUserId(access_token,userName);
			}
		}
	
		if(access_token != null && userId != null){
			String joinUrl = AV_Teams_Integration.createMeeting(access_token, meet,userId);
			Database.update(  new AV_HeaderCustomActivity__c(Id =headerId, AV_UrlTeams__c = joinUrl ));
			try{
				if(String.isNotBlank(delToken)){
					//Database.delete(delToken);
					AV_AzureTeamsToken__c teamToken = new AV_AzureTeamsToken__c();
					teamToken.Id = delToken;
					AV_Teams_Integration.processBody(teamToken,access_token);
					teamToken.AV_ExpiresIn__c = res.data.expires_in;
					teamToken.Name = 'AzureTeamToken';
					Database.update(teamToken);
				} else if (firstToken) {
					AV_AzureTeamsToken__c teamToken = new AV_AzureTeamsToken__c();
					AV_Teams_Integration.processBody(teamToken,access_token);
					teamToken.AV_ExpiresIn__c = res.data.expires_in;
					teamToken.Name = 'AzureTeamToken';
					Database.insert(teamToken);
				}
			}catch(Exception ex){
				AV_LogDebug.printException(methodName, ex);
			}
		}
	}
}