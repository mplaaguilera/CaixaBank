/**********************************************************************************************************************
 Name:	  AV_CitaPrevia_SyncEvents
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para sincronizar eventos via API de Cita Previa
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Jashanpreet        	20/10/2020			Init version
	1.1			App FSC			David Rufo        	09/02/2020			Add the secondSurname for the API callout to AVE
	1.2			App FSC			David Rufo        	03/03/2021			Method "insertOrUpdateEvent" updated
	1.3			App FSC			David Rufo        	09/03/2021			Param physicalMeeting fixed
	1.4			US176035		Víctor Santiago     07/05/2021			Method createRecurrentEventHeader created
	1.5			US176035		David Rufo     		10/05/2021			Review repeat process for 'Eventos con gestor'
	1.6			FIX Outlook		David Rufo			21/07/2021			FIX description more than 2000 characters no send to API
	1.7			FIX Outlook		Jashanpreet			27/07/2021			FIX avoid nulls for header query
	1.8			Fix Sync Events	Víctor Santiago		22/11/2021			Deleted method insertOrUpdateEvent and converted
																		all the methods to public access
	1.8			Fix IOP Dic		Víctor Santiago		14/12/2021			Added method insertOrUpdateEvent
	1.9			Fix				Sandra Gómez		13/01/2022			Fix Asesor de Ventas with AV_CodigoGestorAsignado__c
	2.0			AV_Query IT		Daniel Rodríguez	3/02/2022			Change AV_Query to SOQL for User and Account
	2.1			US304978		Víctor Santiago		07/04/2022			Added AV_BranchPhysicalMeet__c to buildBodyRequest
	2.2			US456937		Patricia Solano		10/11/2022			Modified insertOrUpdateEvent method to not call the Api of GCF
																		in case of AV_Tipo__c is not equal to 'FH'
***********************************************************************************************************************/
public with sharing class AV_CitaPrevia_SyncEvents {

	@future(callout=true)
	public static void insertOrUpdateEvent(String jsonString, Boolean isUpdate){
		String methodName = 'insertOrUpdateEvent';
		Id evGestorRT = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTGESTOR_RT).Id;
		List<Event> eventToUpdate = new List<Event>();
		List<CBK_Activity_Extension__c> crmTareas = new List<CBK_Activity_Extension__c>();
		Set<Id> idsAccount = new Set<Id>();
		//Set<Id> idsOwner = new Set<Id>();
		Set<String> idsOwner = new Set<String>();
		Map<Id,Account> mapCustomer = new Map<Id,Account>();
		Map<Id,User> mapEmployee = new Map<Id,User>();
		Map<String,Event> mapEventsHeaders = new Map<String,Event>();
        Map<Id,Event> mapRecurrentEvents = new Map<Id,Event>();
		List<Event> eventList = (List<Event>)Json.deserialize(jsonString,List<Event>.class);
		List<AV_HeaderCustomActivity__c> cumstomHeaders = new List<AV_HeaderCustomActivity__c>();
		for(Event e : eventList){
			if (e.IsRecurrence2 || e.IsRecurrence){
				mapRecurrentEvents.put(e.Id, e);
			}
			idsAccount.add(e.WhatId);
			idsOwner.add(e.OwnerId);
            if (!String.isEmpty(e.AV_ExternalId__c)) {
				mapEventsHeaders.put(e.AV_ExternalId__c, e);
			}
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
            mapEventIds = getExternalIdRecurrentEvent(mapRecurrentEvents);
        }
        //Get the header-task
		Map<String, AV_HeaderCustomActivity__c> mapHeaderTask = new Map<String, AV_HeaderCustomActivity__c>();
		if(mapEventsHeaders != null && !mapEventsHeaders.isEmpty()){
			List<AV_HeaderCustomActivity__c> listHeaderTask  = [Select Id, AV_ExternalId__c, AV_UrlTeams__c From AV_HeaderCustomActivity__c Where AV_ExternalId__c in :mapEventsHeaders.keySet()];
			for(AV_HeaderCustomActivity__c aux : listHeaderTask){
				mapHeaderTask.put(aux.AV_ExternalID__c, aux);
			}
		}
		//Send the data to GCF and save the response
		for(Event e : eventList){
			if (e.AV_Tipo__c != 'FH'){
				try{
					AV_HeaderCustomActivity__c headerTask = null;
					if(mapHeaderTask != null && !mapHeaderTask.isEmpty()) {
						headerTask = mapHeaderTask.get(e.AV_ExternalID__c);
					}
					AV_CitaPrevia_Integration.Event parms = buildBodyRequest(e, null, mapCustomer.get(e.WhatId), mapEmployee.get(e.OwnerId), headerTask);
					String externalID = e.AV_ExternalID__c;
					if (e.IsRecurrence2 || e.IsRecurrence){
						externalID = mapEventIds.get(e.Id);
					}
					//UPDATE
					if((isUpdate && String.isNotBlank(externalID) && !externalID.startsWith(AV_EventTriggerHelper.SUFFIX_EXTERNALID))
							|| ((e.IsRecurrence2 || e.IsRecurrence) && String.isNotBlank(externalID))){
						AV_CitaPrevia_Integration.MoCntResponse res;
						if (!mapEmployee.get(e.OwnerId).Username.contains('gcf-integration')){
							res =  AV_CitaPrevia_Integration.moCnt(parms, mapEmployee.get(e.OwnerId).AV_ExternalID__c, externalID, mapEmployee.get(e.OwnerId).AV_NumeroOficinaEmpresa__c);
						} else {
							res =  AV_CitaPrevia_Integration.moCnt(parms, e.AV_CodigoGestorAsignado__c, externalID, mapEmployee.get(e.OwnerId).AV_NumeroOficinaEmpresa__c);
						}
						
						AV_LogDebug.printLogDebug(methodName, 'Update response: ' + res);
						saveResponseAPI(crmTareas, e, JSON.serialize(res));
					} else{ //NEW
						AV_CitaPrevia_Integration.InsCntResponse res;
						if (!mapEmployee.get(e.OwnerId).Username.contains('gcf-integration')){
							res = AV_CitaPrevia_Integration.intCnt(parms, mapEmployee.get(e.OwnerId).AV_ExternalID__c, mapEmployee.get(e.OwnerId).AV_NumeroOficinaEmpresa__c);
						}else {
							res = AV_CitaPrevia_Integration.intCnt(parms, e.AV_CodigoGestorAsignado__c, mapEmployee.get(e.OwnerId).AV_NumeroOficinaEmpresa__c);
						}
						AV_LogDebug.printLogDebug(methodName, 'Insert response: ' + res);
						if('201'.equalsIgnoreCase(res.StatusCode)){
							Event eUpt = new Event();
							eUpt.Id = e.Id;
							if (!e.IsRecurrence2 || !e.IsRecurrence){
								eUpt.AV_ExternalID__c = res.eventPremiumId;
							}
							if (eUpt.AV_origenApp__c != AV_AppConstants.OUTLOOK_ORIGENAPP) {
								eUpt.AV_origenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
							}
							eventToUpdate.add(eUpt);
							//Create header-task only for RT=Gestor and Recurrence
							if (e.RecordTypeId == evGestorRT && (e.IsRecurrence2 || e.IsRecurrence)) {
								AV_HeaderCustomActivity__c headerCustomAct = createRecurrentEventHeader(e, res.eventPremiumId);
								if (headerCustomAct != null) {
									cumstomHeaders.add(headerCustomAct);
								}
							}
						}
						saveResponseAPI(crmTareas, e, JSON.serialize(res));
					}
				}catch(AV_ApplicationException ae){
					AV_LogDebug.printException(methodName, ae);
					saveResponseAPI(crmTareas, e, 'Description field with more than 2000 characters');
				}
			}
		}
		//Save data into DB
		if(eventToUpdate!=null && !eventToUpdate.isEmpty()){
			List<Database.SaveResult> listResult = Database.update(eventToUpdate, false);
			AV_AppUtilities.displayErrors(methodName, listResult);
		}
		if(crmTareas!=null && !crmTareas.isEmpty()){
			List<CBK_Activity_Extension__c> crmTaskToUpdate = checkCrmTaskOverride(crmTareas);
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
	
	/**
	 * Get the external ID for recurrent events
	 */
	public static Map<String, String> getExternalIdRecurrentEvent(Map<Id,Event> mapRecurrentEvents){
		Datetime startDate =null;
		Datetime endDate =null;
		for(Event e : mapRecurrentEvents.values()) {
			if(startDate == null ) {
				startDate =e.CreatedDate;
			}
			if(startDate != null && startDate > e.CreatedDate) {
				startDate =e.CreatedDate;
			} 
			if(endDate == null ) {
				endDate =e.CreatedDate;
			} 
			if(endDate != null && endDate < e.CreatedDate) {
				endDate =e.CreatedDate;
			} 
		}
		Map<String, String> mapEventIds =new Map<String, String>();
		if (mapRecurrentEvents!=null && !mapRecurrentEvents.isEmpty()){
			List<AV_HeaderCustomActivity__c> listRecurrentEvent  = [Select Id, IDTask__c, AV_ExternalID__c From AV_HeaderCustomActivity__c Where IDTask__c in :mapRecurrentEvents.keySet() and CreatedDate > :startDate.addHours(-1) and CreatedDate < :endDate.addHours(1)];
			/*List<AV_HeaderCustomActivity__c> listRecurrentEvent = new AV_Query('AV_HeaderCustomActivity__c')
										.selectFields('Id, IDTask__c, AV_ExternalID__c')
										.addConditionIn('IDTask__c', mapRecurrentEvents.keySet())
										.addConditionGT('CreatedDate', startDate.addHours(-1))
										.addConditionLT('CreatedDate', endDate.addHours(1))
										.run();*/
			for (AV_HeaderCustomActivity__c data : listRecurrentEvent){
				mapEventIds.put(data.IDTask__c, data.AV_ExternalID__c);
			}
		}
		return mapEventIds;
	}

	/**
	 * Create header-task only for recurrent event
	 */
	public static AV_HeaderCustomActivity__c createRecurrentEventHeader(Event e, String externalId) {
		AV_HeaderCustomActivity__c headerCustomAct = new AV_HeaderCustomActivity__c();
		
		if (String.isNotBlank(e.Subject) && e.Subject.length() < 80) {
			headerCustomAct.Name = e.Subject;
		} else {
			headerCustomAct.Name = externalId;
		}
		headerCustomAct.AV_ExternalID__c = externalId;
		headerCustomAct.IDTask__c = e.Id;
		return headerCustomAct;
	}
	
	public static List<CBK_Activity_Extension__c> checkCrmTaskOverride(List<CBK_Activity_Extension__c> crmTareas){
		Map<String, CBK_Activity_Extension__c> mapCrmTareas = new Map<String, CBK_Activity_Extension__c>();
		List<CBK_Activity_Extension__c> crmTaskToUpdate = new List<CBK_Activity_Extension__c>();
		for (CBK_Activity_Extension__c aux : crmTareas){
			if (String.isNotBlank(aux.AV_ReasignarCartera_Id_Task__c)){
				mapCrmTareas.put(aux.AV_ReasignarCartera_Id_Task__c, aux);
			}
			else if (String.isNotBlank(aux.AV_ActivityId__c)){
				mapCrmTareas.put(aux.AV_ActivityId__c, aux);
			}
		}
		List<CBK_Activity_Extension__c> crmTaskListExist = [Select Id, Name, AV_ActivityId__c, AV_ReasignarCartera_Id_Task__c, AV_ReasignarCartera_Id_Cliente__c, 
		AV_Reasignar_cartera_Owner__c, AV_ReasignarCartera_JSONAPI__c From CBK_Activity_Extension__c Where AV_ReasignarCartera_Id_Task__c in :mapCrmTareas.keySet() or AV_ActivityId__c in :mapCrmTareas.keySet()];
		/*List<CBK_Activity_Extension__c> crmTaskListExist = new AV_Query('CBK_Activity_Extension__c')
			.selectFields('Id, Name, AV_ActivityId__c, AV_ReasignarCartera_Id_Task__c, AV_ReasignarCartera_Id_Cliente__c, AV_Reasignar_cartera_Owner__c, AV_ReasignarCartera_JSONAPI__c')
			.addConditionIn('AV_ReasignarCartera_Id_Task__c', mapCrmTareas.keySet())
			.addConditionIn('AV_ActivityId__c', mapCrmTareas.keySet())
			.switchToDisjunction()
			.run();*/
		
		for (CBK_Activity_Extension__c crmTaskOld : crmTaskListExist){
			if (String.isNotBlank(crmTaskOld.AV_ReasignarCartera_Id_Task__c) 
					&& mapCrmTareas.get(crmTaskOld.AV_ReasignarCartera_Id_Task__c)!=null){
				CBK_Activity_Extension__c crmTaskNew = mapCrmTareas.get(crmTaskOld.AV_ReasignarCartera_Id_Task__c);
				crmTaskNew.Id = crmTaskOld.Id;
				crmTaskNew.AV_ActivityId__c = crmTaskOld.AV_ActivityId__c;
				crmTaskNew.AV_ReasignarCartera_Id_Task__c = crmTaskOld.AV_ReasignarCartera_Id_Task__c;
				crmTaskNew.AV_ReasignarCartera_Id_Cliente__c = crmTaskOld.AV_ReasignarCartera_Id_Cliente__c;
				crmTaskNew.AV_Reasignar_cartera_Owner__c = crmTaskOld.AV_Reasignar_cartera_Owner__c;
				crmTaskNew.AV_ReasignarCartera_JSONAPI__c = crmTaskOld.AV_ReasignarCartera_JSONAPI__c;
				
				crmTaskToUpdate.add(crmTaskNew);
			}
			else if (String.isNotBlank(crmTaskOld.AV_ActivityId__c)
					 	&& mapCrmTareas.get(crmTaskOld.AV_ActivityId__c)!=null){
				CBK_Activity_Extension__c crmTaskNew = mapCrmTareas.get(crmTaskOld.AV_ActivityId__c);
				crmTaskNew.Id = crmTaskOld.Id;
				crmTaskNew.AV_ActivityId__c = crmTaskOld.AV_ActivityId__c;
				crmTaskNew.AV_ReasignarCartera_Id_Task__c = crmTaskOld.AV_ReasignarCartera_Id_Task__c;
				crmTaskNew.AV_ReasignarCartera_Id_Cliente__c = crmTaskOld.AV_ReasignarCartera_Id_Cliente__c;
				crmTaskNew.AV_Reasignar_cartera_Owner__c = crmTaskOld.AV_Reasignar_cartera_Owner__c;
				crmTaskNew.AV_ReasignarCartera_JSONAPI__c = crmTaskOld.AV_ReasignarCartera_JSONAPI__c;
				
				crmTaskToUpdate.add(crmTaskNew);
			}
		}
		return crmTaskToUpdate;
	}
	
	/**
	 * Save response API
	 */
	public static void saveResponseAPI(List<CBK_Activity_Extension__c> crmTareas, Event evt, String respTxt){
		CBK_Activity_Extension__c crmTarea = new CBK_Activity_Extension__c();
		crmTarea.Name = evt.Id;
		crmTarea.AV_ActivityId__c = evt.Id;
		crmTarea.AV_ReasignarCartera_Id_Task__c = evt.Id;
		crmTarea.AV_ReasignarCartera_Id_Cliente__c = evt.WhatId;
		crmTarea.AV_Reasignar_cartera_Owner__c = evt.OwnerId;
		crmTarea.AV_ReasignarCartera_JSONAPI__c = respTxt;
		crmTareas.add(crmTarea);
	}

	@future(callout=true)
	public static void insertEventTelephoneContracting(String jsonString){
        String methodName = 'insertEventTelephoneContracting';
		List<Event> eventsUpsert = new List<Event>();
		List<CBK_Activity_Extension__c> crmTareas = new List<CBK_Activity_Extension__c>();
		Set<Id> idsAccount = new Set<Id>();
		Set<Id> idsOppo = new Set<Id>();
		Set<Id> idsOwner = new Set<Id>();
		Map<Id,Account> mapCustomer = new Map<Id,Account>();
		Map<Id,User> mapEmployee = new Map<Id,User>();
		List<Opportunity> oppoList = (List<Opportunity>)Json.deserialize(jsonString,List<Opportunity>.class);
		for(Opportunity o : oppoList){
			idsAccount.add(o.AccountId);
			idsOppo.add(o.Id);
			idsOwner.add(o.OwnerId);
		}
		List<User> employeeList = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c, Username From User Where Id in :idsOwner];
		/*List<User> employeeList = new AV_Query('User')
									.selectFields('Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c')
									.addConditionIn('Id', idsOwner)
									.run();*/
								
		for(User u : employeeList){
			mapEmployee.put(u.Id,u);
		}
		List<Account> customer = [Select Id, AV_NumPerso__c, FirstName, LastName From Account Where Id In :idsAccount];
		/*List<Account> customer = new AV_Query('Account')
									.selectFields('Id, AV_NumPerso__c, FirstName, LastName')
									.addConditionIn('Id', idsAccount)
									.run();*/

									
		for(Account a : customer){
			mapCustomer.put(a.Id,a);
		}
		Map<Id,Id> oppoIds = new Map<Id,Id>();
		//Set<String> setTaskOppFields = new Set<String>{'Id', 'AV_Task__c', 'AV_Opportunity__c'};
		List<AV_CustomActivityOpportunity__c> listTareaOpp = [Select Id, AV_Task__c,AV_Opportunity__c From AV_CustomActivityOpportunity__c Where AV_Opportunity__c in :idsOppo];
		/*List<AV_CustomActivityOpportunity__c> listTareaOpp = new AV_Query('AV_CustomActivityOpportunity__c')
															.selectFields(setTaskOppFields)
															.addConditionIn('AV_Opportunity__c', idsOppo)
															.run();*/

		if(listTareaOpp != null && !listTareaOpp.isEmpty()){
			for(AV_CustomActivityOpportunity__c cp : listTareaOpp){
				oppoIds.put(cp.AV_Task__c ,cp.AV_Opportunity__c );
			}
		}
		List<Event> listEvents = [Select Id,Subject, AV_Task__c,IsPrivate,Description,StartDateTime,EndDateTime,CSBD_Evento_Estado__c, AV_Tipo__c,RecordTypeId,OwnerId,WhatId From Event Where AV_Task__c in :oppoIds.keySet()];
		/*List<Event> listEvents = new AV_Query('Event')
								.selectFields('Id,Subject, AV_Task__c,IsPrivate,Description,StartDateTime,EndDateTime,CSBD_Evento_Estado__c, AV_Tipo__c,RecordTypeId,OwnerId,WhatId')
								.addConditionIn('AV_Task__c', oppoIds.keySet())
								.run();*/

		Map<Id,Event> oppoEventIds = new Map<Id,Event>();
		if(listEvents != null && !listEvents.isEmpty()){
			for(Event ev : listEvents){
				oppoEventIds.put(oppoIds.get(ev.AV_Task__c), ev );
			}
		}                                           
		
		for(Opportunity o : oppoList){
			Event e = new Event();
			if(oppoEventIds.containsKey(o.Id)){
				e = oppoEventIds.get(o.Id);
			}else{
				e.Subject = 'Contratación telefónica';
				e.StartDateTime = datetime.now();
				e.EndDateTime = e.StartDateTime.addMinutes(30);
				e.AV_Tipo__c = AV_AppConstants.LLAMADA_TIPO;
				e.CSBD_Evento_Estado__c = AV_AppConstants.CERRADO_ESTADO;
				e.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(AV_AppConstants.EVENTCLIENTE_RT).getRecordTypeId();
				e.OwnerId = o.OwnerId;
				e.WhatId = o.AccountId;
			}
			//Send to API
            try{
                AV_CitaPrevia_Integration.Event parms = buildBodyRequest(e, o, mapCustomer.get(o.AccountId), mapEmployee.get(o.OwnerId), null);
                AV_CitaPrevia_Integration.InsCntResponse res =  AV_CitaPrevia_Integration.intCnt(parms,mapEmployee.get(e.OwnerId).AV_ExternalID__c,
                                                                                                 String.valueOf(mapEmployee.get(e.OwnerId).AV_NumeroOficinaEmpresa__c) );
                if('201'.equalsIgnoreCase(res.StatusCode)){
                    e.AV_ExternalID__c = res.eventPremiumId;
                    e.AV_origenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
                    eventsUpsert.add(e);
                }
                saveResponseAPI(crmTareas, e, JSON.serialize(res));
            }catch(AV_ApplicationException ae){
                AV_LogDebug.printException(methodName, ae);
                saveResponseAPI(crmTareas, e, 'Description field with more than 2000 characters');
            }
		}
	   
		//Save to DB
		if(eventsUpsert!=null && !eventsUpsert.isEmpty()){
			Database.upsert(eventsUpsert, false);
		}
		if(crmTareas!=null && !crmTareas.isEmpty()){
			Database.upsert(crmTareas, false);
		}
	}

	/**
	 * Build the request to send to API (Cita Previa)
	 */
	public static AV_CitaPrevia_Integration.Event buildBodyRequest(Event event, Opportunity oppo, Account customer, User employee, AV_HeaderCustomActivity__c headerTask){
        if(String.isNotBlank(event.Description) && event.Description.length()>2000){
        	throw new AV_ApplicationException('Event with more than 2000 characters in description field');
        }
        
		AV_CitaPrevia_Integration.Event parms = new AV_CitaPrevia_Integration.Event();
		AV_CitaPrevia_Integration.Customer c = new AV_CitaPrevia_Integration.Customer();
		String strRecordName = Schema.SObjectType.Event.getRecordTypeInfosById().get(event.RecordTypeId).getDeveloperName();
        
		parms.salesforceEventId = event.Id;
		if(customer != null && customer.AV_NumPerso__c !=null){
			c.customerId = Integer.valueOf(customer.AV_NumPerso__c);
			c.name = customer.FirstName;
			c.surname = customer.LastName;
			c.secondSurname = null;
		}
		parms.subject = event.Subject;
		parms.Customer = c;
		parms.employeeEvent = employee.AV_ExternalID__c;
		//parms.MandatoryAssistances = new List<String>{employee.AV_ExternalID__c};
		//branchId
		if(!String.isEmpty( employee.AV_NumeroOficinaEmpresa__c)) {
			String branchId = employee.AV_NumeroOficinaEmpresa__c.contains('-') ? employee.AV_NumeroOficinaEmpresa__c.substringAfter('-') : employee.AV_NumeroOficinaEmpresa__c;
			parms.branchId = Integer.valueOf(branchId);
		}
		
		//type
		if(strRecordName.equals(AV_AppConstants.EVENTCLIENTE_RT)
		   		&& AV_AppConstants.LLAMADA_TIPO.equalsIgnoreCase(event.AV_Tipo__c)){
			parms.type = 'L';
		}
		else if(strRecordName.equals(AV_AppConstants.EVENTCLIENTE_RT)){
			parms.type = 'C';
		}
		else if (strRecordName.equals( AV_AppConstants.EVENTGESTOR_RT)){
			parms.type = 'O';
		}
		//locationType
		if(AV_AppConstants.CITA_OFICINA_TIPO.equalsIgnoreCase(event.AV_Tipo__c) || AV_AppConstants.VISITA_TIPO.equalsIgnoreCase(event.AV_Tipo__c) || AV_AppConstants.CITA_OTRA_OFICINA_CAIXABANK.equalsIgnoreCase(event.AV_Tipo__c)){
			parms.locationType = 'P';
		}else{
			parms.locationType = 'R';
		}
		//remoteMeeting
		if(AV_AppConstants.LLAMADA_TIPO.equalsIgnoreCase(event.AV_Tipo__c) || AV_AppConstants.CITA_TELEFONICA_TIPO.equalsIgnoreCase(event.AV_Tipo__c)){
			parms.remoteMeeting = 'L';
		}
		else if(AV_AppConstants.VIDEOLLAMADA_TIPO.equalsIgnoreCase(event.AV_Tipo__c)){
			parms.remoteMeeting = 'V';
		}
		parms.meetingRequester = 'G';
		//status
		if(AV_AppConstants.EVENT_STATUS_PENDIENTE.equalsIgnoreCase(event.CSBD_Evento_Estado__c)){
			parms.status = 'N';
		}else{
			parms.status = 'R';
		}
		//physicalMeeting
		if(parms.locationType.equals('P') && AV_AppConstants.VISITA_TIPO.equalsIgnoreCase(event.AV_Tipo__c)){
			parms.physicalMeeting = 'D'; //Domicilio cliente
		}
		else if(parms.locationType.equals('P')){
			parms.physicalMeeting = 'C'; //Centro caixa
		}
		else {
			parms.physicalMeeting = 'O'; //Otros
		}
		parms.branchPhysicalMeet = String.isNotBlank(event.AV_BranchPhysicalMeet__c) ? event.AV_BranchPhysicalMeet__c : null;
		parms.meetingPlace = event.Location;
		parms.date_X = event.StartDateTime.format('yyyy-MM-dd');
		parms.startTime = event.StartDateTime.format('HH:mm');
		parms.endTime = event.EndDateTime.format('HH:mm');
		parms.previousWarning = 'M30';
		parms.comment = event.Description;
		parms.isPrivate = event.isPrivate;
		parms.isDigitalCustomer = false;
		if (headerTask != null) {
			parms.urlVideocall = headerTask.AV_UrlTeams__c;
		}
		
		//Only for "Contratacion Telefónica" from Opportunity
		if(oppo != null){
			AV_CitaPrevia_Integration.MetadataField mfields = new AV_CitaPrevia_Integration.MetadataField();
			parms.isPhoneSale = oppo.AV_ModificacionTelefonica__c;
			mfields.fieldId = 'C20';
			mfields.value = oppo.AV_Contrato__c;
			parms.MetadataFields = new List<AV_CitaPrevia_Integration.MetadataField> {mfields};
			parms.metadataId = '110';
		}
		return parms;
	}
}