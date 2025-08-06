/**********************************************************************************************************************
 Name:	  CIBE_TeamsGCFQueueable
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Lanza la Api de GCF
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY		AUTHOR				DATE				Description
   1.0			App FSC			Jose Maria			26/16/2023			Init version (Copy all from retail)

***********************************************************************************************************************/
public class CIBE_TeamsGCFQueueable implements Queueable, Database.AllowsCallouts {
    
    String jsonString;
    String subject;
    String eventId;
    Datetime endDateTime;
    Datetime startDateTime;
    String headerId;
    String userName;
    String azureId;
    List<String> attendes;
    String contactoPrincipal;

    public CIBE_TeamsGCFQueueable(String serializedEvent, String subject, Datetime endDateTime, Datetime startDateTime, String headerId, String userName, String azureId) {
        this.jsonString=serializedEvent;
        this.subject=subject;
        this.endDateTime=endDateTime;
        this.startDateTime=startDateTime;
        this.headerId=headerId;
        this.userName=userName;
        this.azureId=azureId;
    }
    
    public CIBE_TeamsGCFQueueable(String serializedEvent, Event evt, String userName, String azureId, List<String> attendes, String contactoPrincipal) {
        
        this.jsonString=serializedEvent;
        this.eventId = evt.Id;
        this.subject=evt.Subject;
        this.endDateTime=evt.EndDateTime;
        this.startDateTime=evt.StartDateTime;
        this.headerId=evt.AV_Task__c;
        this.userName=userName;
        this.azureId=azureId;
        this.attendes=attendes;
        this.contactoPrincipal = contactoPrincipal;
    }

    /**
	 * Executes the Queueable job
	 * @param qc	QueueableContext param that contains the context of the queueable
	 */
	public void execute(QueueableContext qc) {
        futureCreateMeeting(eventId, subject, endDateTime, startDateTime, headerId, userName, azureId, jsonString, attendes, contactoPrincipal);
        if (!Test.isRunningTest()) {
            insertEventGCFFuture(jsonString);
        }
	}

    @future(callout=true)
    public static void insertEventGCFFuture(String jsonString){
		String methodName = 'insertEventGCF';
        
		CIBE_AppUtilities.SearchRT rtGestor = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_GESTOR_RT);
        CIBE_AppUtilities.SearchRT rtGestorCIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_GESTOR_RT);
        Set<Id> setRtGestor	= CIBE_EventTriggerHelper.getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtGestor,rtGestorCIB});
		
		List<Event> eventList = new List<Event>();
        try {
            Event e = (Event) JSON.deserialize(jsonString, Event.class);
			eventList.add(e);
            CBK_Log.debug('CIBE_TeamsGCFQueueable', 'List<Event> eventList', eventList);
        } catch(Exception ex) {
            CBK_Log.error('CIBE_TeamsGCFQueueable', jsonString);
        }
        
		Set<Id> idsAccount = new Set<Id>();
		Set<Id> idsContactPerson = new Set<Id>();
		Set<String> idsOwner = new Set<String>();
        Map<Id,Event> mapRecurrentEvents = new Map<Id,Event>();
        Map<String, Event> mapEventsHeaders = new Map<String, Event>();
		for(Event e : eventList) {
            if (e.IsRecurrence2|| e.IsRecurrence){
                mapRecurrentEvents.put(e.Id, e);
		}
		
            if(String.isNotBlank(e.WhatId)) {
                idsAccount.add(e.WhatId);
        }

            if(String.isNotBlank(e.WhoId)) {
                idsContactPerson.add(e.WhoId);
            }

            idsOwner.add(e.OwnerId);

            if(String.isNotBlank(e.AV_ExternalId__c)) {
                mapEventsHeaders.put(e.AV_ExternalId__c, e);
            }
        }
		
        Map<Id,User> mapEmployee = new Map<Id,User>();
        if(User.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.User.fields.AV_ExternalID__c.isAccessible() &&
            Schema.SObjectType.User.fields.AV_NumeroOficinaEmpresa__c.isAccessible()&&
            Schema.SObjectType.User.fields.Username.isAccessible()) {
            mapEmployee = new Map<Id,User>([SELECT Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c, Username FROM User WHERE Id IN :idsOwner]);		
        }

        Map<Id, Contact> mapContactPerson = new Map<Id, Contact>();
        if(Contact.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.Contact.fields.CIBE_NumPerso__c.isAccessible()) {
            mapContactPerson = new Map<Id, Contact>([SELECT Id, Name, CIBE_NumPerso__c FROM Contact WHERE Id IN :idsContactPerson]);
            }

        Map<Id,Account> mapCustomer = new Map<Id,Account>();
        if(Account.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.Account.fields.AV_NumPerso__c.isAccessible() &&
            Schema.SObjectType.Account.fields.Name.isAccessible() &&
            Schema.SObjectType.Account.fields.FirstName.isAccessible()&&
            Schema.SObjectType.Account.fields.LastName.isAccessible()) {
            mapCustomer = new Map<Id,Account>([SELECT Id, Name, AV_NumPerso__c, FirstName, LastName FROM Account WHERE Id IN :idsAccount]);
        }

		
		Map<String, String> mapEventIds = new Map<String, String>();
        if(mapRecurrentEvents != null && !mapRecurrentEvents.isEmpty()){
            mapEventIds = CIBE_CitaPrevia_SyncEvents.getExternalIdRecurrentEvent(mapRecurrentEvents);
        }
        
		Map<String, AV_HeaderCustomActivity__c> mapHeaderTask = new Map<String, AV_HeaderCustomActivity__c>();
		if(mapEventsHeaders != null && !mapEventsHeaders.isEmpty()){
            List<AV_HeaderCustomActivity__c> listHeaderTask  = new List<AV_HeaderCustomActivity__c>();
            if(
                AV_HeaderCustomActivity__c.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.AV_HeaderCustomActivity__c.fields.AV_ExternalId__c.isAccessible() &&
                Schema.SObjectType.AV_HeaderCustomActivity__c.fields.AV_UrlTeams__c.isAccessible()
            ) {
                listHeaderTask  = [SELECT Id, AV_ExternalId__c, AV_UrlTeams__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalId__c IN :mapEventsHeaders.keySet()];
            }
            if(!listHeaderTask.isEmpty()){
                for(AV_HeaderCustomActivity__c aux : listHeaderTask){
                    mapHeaderTask.put(aux.AV_ExternalID__c, aux);
                }
            }
		}

		List<Event> eventToUpdate = new List<Event>();
		List<CBK_Activity_Extension__c> crmTareas = new List<CBK_Activity_Extension__c>();
		List<AV_HeaderCustomActivity__c> customHeaders = new List<AV_HeaderCustomActivity__c>();
		for(Event evento : eventList) {
		try{
			AV_HeaderCustomActivity__c headerTask = null;
				if(mapHeaderTask.containsKey(evento.AV_ExternalID__c)) {
					headerTask = mapHeaderTask.get(evento.AV_ExternalID__c);
				}
			
            String externalID = evento.AV_ExternalID__c;
			if (evento.IsRecurrence2 || evento.IsRecurrence){
				externalID = mapEventIds.get(evento.Id);
			}
           
				CIBE_CitaPrevia_Integration.Event parms = CIBE_CitaPrevia_SyncEvents.buildBodyRequest(evento, mapCustomer?.get(evento.WhatId), mapEmployee?.get(evento.OwnerId), headerTask, mapContactPerson?.get(evento.WhoId));
				
				CBK_Log.debug('CIBE_TeamsGCFQueueable', 'CIBE_CitaPrevia_Integration.Event parms', new List<Object>{ parms });

			if((!String.isNotBlank(externalID) && externalID.startsWith(CIBE_EventTriggerHelper.SUFFIX_EXTERNALID)) || !((evento.IsRecurrence2 || evento.IsRecurrence) && String.isNotBlank(externalID))){
					CIBE_CitaPrevia_Integration.InsCntResponse res = new CIBE_CitaPrevia_Integration.InsCntResponse();
				if (!mapEmployee.get(evento.OwnerId).Username.contains('gcf-integration')) {
						res = CIBE_CitaPrevia_Integration.intCnt(
							parms, 
							String.isNotBlank(mapEmployee.get(evento.OwnerId).AV_ExternalID__c) ? mapEmployee.get(evento.OwnerId).AV_ExternalID__c : '000000'
						);
				}else {
						res = CIBE_CitaPrevia_Integration.intCnt(
                            parms,
                            String.isNotBlank(evento.AV_CodigoGestorAsignado__c) ? evento.AV_CodigoGestorAsignado__c : '000000'
                        );
				}
                
					CBK_Log.debug('CIBE_TeamsGCFQueueable', 'CIBE_CitaPrevia_Integration.InsCntResponse res', new List<Object>{ res });
                    CIBE_CitaPrevia_SyncEvents.saveResponseAPI(crmTareas, evento, JSON.serialize(res));
					
				if('201'.equalsIgnoreCase(res.StatusCode)){
					Event eUpt = new Event();
					eUpt.Id = evento.Id;
					if (!evento.IsRecurrence2 || !evento.IsRecurrence){
						eUpt.AV_ExternalID__c = res.eventPremiumId; 
					}
						if (eUpt.AV_origenApp__c != CIBE_AppConstants.OUTLOOK_ORIGENAPP) {
					eUpt.AV_origenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
                        }
					eventToUpdate.add(eUpt);
						if (setRtGestor.contains(evento.RecordTypeId) && (evento.IsRecurrence || evento.IsRecurrence2)) {							
						AV_HeaderCustomActivity__c headerCustomAct = CIBE_CitaPrevia_SyncEvents.createRecurrentEventHeader(evento, res.eventPremiumId);
						if (headerCustomAct != null) {
								customHeaders.add(headerCustomAct);
						}
					}
				}
			}
		}catch(AV_ApplicationException ae){
                CIBE_CitaPrevia_SyncEvents.saveResponseAPI(crmTareas, evento, ae.getMessage());
                CBK_Log.error('CIBE_TeamsGCFQueueable', ae, ae.getMessage());
            } catch(Exception ae2) {
                String message = ('Line: ' + ae2.getLineNumber() + ' - ' + ae2.getMessage());
                CBK_Log.error('CIBE_TeamsGCFQueueable', ae2, message);
		}
		}
			
		if(!eventToUpdate.isEmpty()) {
            List<Database.SaveResult> listResult = Database.update(eventToUpdate, false);

            boolean hasError = false;
            List<Object> objs = new List<Object>();
            Map<String, String> msjs = new Map<String, String>();
            for (Integer i = 0; i < eventToUpdate.size(); i++) {
                Database.SaveResult dr = listResult[i];
                if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                    msjs.put(eventToUpdate[i].Id, ((String)dr.getErrors()[0].getMessage()));
                    objs.add(eventToUpdate[i]);
                    hasError = true;
                }
            }
            
            if(hasError) {
                CBK_Log.error(msjs, objs);
            }
        }

		if(!crmTareas.isEmpty()) {
            List<CBK_Activity_Extension__c> crmTaskToUpdate = CIBE_CitaPrevia_SyncEvents.checkCrmTaskOverride(crmTareas);
            if(!crmTaskToUpdate.isEmpty()) {
                List<Database.SaveResult> listResult = Database.update(crmTaskToUpdate, false);
                
                boolean hasError = false;
                List<Object> objs = new List<Object>();
                Map<String, String> msjs = new Map<String, String>();
                for (Integer i = 0; i < crmTaskToUpdate.size(); i++) {
                    Database.SaveResult dr = listResult[i];
                    if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                        msjs.put(crmTaskToUpdate[i].Id, ((String)dr.getErrors()[0].getMessage()));
                        objs.add(crmTaskToUpdate[i]);
                        hasError = true;
                    }
                }
                
                if(hasError) {
                    CBK_Log.error(msjs, objs);
                }
            }
    
            List<Database.UpsertResult> listResult2 = Database.upsert(crmTareas, false);

            boolean hasError = false;
            List<Object> objs = new List<Object>();
            Map<String, String> msjs = new Map<String, String>();
            for (Integer i = 0; i < crmTareas.size(); i++) {
                Database.UpsertResult dr = listResult2[i];
                if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                    msjs.put(crmTareas[i].Id, ((String)dr.getErrors()[0].getMessage()));
                    objs.add(crmTareas[i]);
                    hasError = true;
                }
            }
            
            if(hasError) {
                CBK_Log.error(msjs, objs);
            }
        }

		if (!customHeaders.isEmpty()) {
            List<Database.SaveResult> listResult = Database.insert(customHeaders, false);

            boolean hasError = false;
            List<Object> objs = new List<Object>();
            Map<String, String> msjs = new Map<String, String>();
            for (Integer i = 0; i < customHeaders.size(); i++) {
                Database.SaveResult dr = listResult[i];
                if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                    msjs.put(customHeaders[i].Id, ((String)dr.getErrors()[0].getMessage()));
                    objs.add(customHeaders[i]);
                    hasError = true;
                }
            }
            
            if(hasError) {
                CBK_Log.error(msjs, objs);
		}
		}
	}

    private static void futureCreateMeeting(String eventId, String subject, Datetime endDateTime, Datetime startDateTime, String headerId, String userName, String azureId, String jsonString, List<String> attendes, String contactoPrincipal){
		String methodName = 'futureCreateMeeting';
		system.debug('### futureCreateMeeting');
        system.debug('### attendes ' + attendes);
        system.debug('### contactoPrincipal ' + contactoPrincipal);
        AV_AzureTeamsToken__c tok = AV_AzureTeamsToken__c.getValues('AzureTeamToken');
		CIBE_Teams_Integration.Response res = new CIBE_Teams_Integration.Response();
		Boolean firstToken = false;
		String userId;
		String accessToken;
		String delToken = null;
		CIBE_Teams_Integration.Meeting meet = new CIBE_Teams_Integration.Meeting();
		meet.startDateTime = startDateTime;
		meet.endDateTime = endDateTime;
		meet.subject = subject;
		if(tok!=null && tok.AV_ExpiresIn__c != null ){
            
			Datetime exp = tok.CreatedDate.addSeconds( Integer.valueOf(tok.AV_ExpiresIn__c));
			if(System.now() >= exp){
				delToken = tok.Id;
                system.debug('### 1er if ');
				res = CIBE_Teams_Integration.getToken();
				accessToken = res.data.access_token;
			}else{
                system.debug('### 2do if ');
				accessToken = CIBE_Teams_Integration.getTokenString(new String[]{
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
            system.debug('### 3er if ');
			firstToken = true;
			res = CIBE_Teams_Integration.getToken();
			accessToken = res.data.access_token;
		}
        system.debug('### accessToken '+ accessToken);
        system.debug('### azureId '+ azureId);
		if(!String.isBlank(azureId)){
			userId = azureId;
		}else{
			if(!String.isBlank(userName)){
				userId = CIBE_Teams_Integration.getUserId(accessToken,userName);
			}
		}
        system.debug('### userId '+ userId);
		if(accessToken != null && userId != null){
            system.debug('### futureCreateMeeting');
			String joinUrl = CIBE_Teams_Integration.createMeeting(accessToken, meet,userId);
			system.debug('### joinUrl ' + joinUrl);

			if(String.isNotBlank(headerId)) {
				List<AV_HeaderCustomActivity__c> headers = new List<AV_HeaderCustomActivity__c>{new AV_HeaderCustomActivity__c(Id = headerId, AV_UrlTeams__c = joinUrl)};
				Database.SaveResult [] headerUpdate = Database.update(headers, false);
                
	
				boolean hasError = false;
				Map<String, String> msjs = new Map<String, String>();
				List<Object> objs = new List<Object>();
				for (Integer i = 0; i < headers.size(); i++) {
					Database.SaveResult sr = headerUpdate[i];
					if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
						msjs.put(headers[i].Id, ((String)sr.getErrors()[0].getMessage()));
						objs.add(headers[i]);
						hasError = true;
					}
				}
                
                
	
				if(hasError) {
					CBK_Log.error(msjs, objs);
                }else if((attendes != null && !attendes.isEmpty()) || contactoPrincipal != null){
                        CIBE_NewEventController.updateEventWithURL(eventId, attendes, contactoPrincipal,joinUrl);
                }
			}
			
			try{
				if(String.isNotBlank(delToken)){
					AV_AzureTeamsToken__c teamToken = new AV_AzureTeamsToken__c();
					teamToken.Id = delToken;
					CIBE_Teams_Integration.processBody(teamToken,accessToken);
					teamToken.AV_ExpiresIn__c = res.data.expires_in;
					teamToken.Name = 'AzureTeamToken';
					List<AV_AzureTeamsToken__c> tokens = new List<AV_AzureTeamsToken__c>{teamToken};
					Database.SaveResult [] tokenUpdate = Database.update(tokens, false);

					boolean hasError = false;
					Map<String, String> msjs = new Map<String, String>();
					List<Object> objs = new List<Object>();
					for (Integer i = 0; i < tokens.size(); i++) {
						Database.SaveResult sr = tokenUpdate[i];
						if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
							msjs.put(tokens[i].Id, ((String)sr.getErrors()[0].getMessage()));
							objs.add(tokens[i]);
							hasError = true;
						}
					}
		
					if(hasError) {
						CBK_Log.error(msjs, objs);
					}
				} else if (firstToken) {
					AV_AzureTeamsToken__c teamToken = new AV_AzureTeamsToken__c();
					CIBE_Teams_Integration.processBody(teamToken,accessToken);
					teamToken.AV_ExpiresIn__c = res.data.expires_in;
					teamToken.Name = 'AzureTeamToken';
					List<AV_AzureTeamsToken__c> tokens = new List<AV_AzureTeamsToken__c>{teamToken};
					Database.SaveResult [] tokenInsert = Database.insert(tokens, false);

					boolean hasError = false;
					Map<String, String> msjs = new Map<String, String>();
					List<Object> objs = new List<Object>();
					for (Integer i = 0; i < tokens.size(); i++) {
						Database.SaveResult sr = tokenInsert[i];
						if(!sr.isSuccess() && !sr.getErrors().isEmpty()) {
							msjs.put(tokens[i].Id, ((String)sr.getErrors()[0].getMessage()));
							objs.add(tokens[i]);
							hasError = true;
						}
					}
		
					if(hasError) {
						CBK_Log.error(msjs, objs);
					}
				}
			}catch(Exception ex){
				CBK_Log.error('CIBE_TeamsGCFQueueable', ex, ex.getMessage());
			}
		}
	}
}