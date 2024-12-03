/**********************************************************************************************************************
 Name:	  AV_EventTriggerHelper
 Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Event.
------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	        AUTHOR		   		DATE				Description
	1.0			US124210		    Jashanpreet	   	    08/10/2020		    Init version
	2.0			US104665			Esperanza Conde		21/10/2020			Logic completeValueDateReal
	3.0         US130988            Jashanpreet         21/10/2020          Sync events with GCF
	4.0         US129093            Jashanpreet         11/11/2020          oppo reminder
	5.0			App FSC			    Jashanpreet			07/12/2020			Delete soql queries to get RecordTypeIds
	5.1			Check RT			David Rufo			09/12/2020			Improve common method to check RT + general RT
	5.2			App FSC				Jashanpreet 		14/12/2020			Changed error message to field
	5.3			Check Api Only		David Rufo			15/12/2020			No send data to GCF when the user has the API Only profile
	5.4			US147562			Álvaro López		13/01/2020			Added new method createCRMTask
	5.9			CustomPS			David Rufo			15/02/2021			Change API Only check for integration by Custom Permission
	6.0			DE46491/DE46686		Sandra Gómez		02/06/2021			Change method processOwnerGestores
	6.1			US237376			Víctor Santiago		28/06/2021			Added timestamp to generate a more robust ExternalID.
	6.2			FIX Outlook			David Rufo			30/06/2021			Method to identify events from outlook
	6.3			FIX Outlook			David Rufo			21/07/2021			FIX description more than 2000 characters no send to API
	6.3			FIX Outlook			Jashanpreet			27/07/2021			FIX put recordType to event without
	6.4			FIX Outlook			Carolina Alonso		28/07/2021			Modify setRecordType to add Origen Outlook in case the event doesnt have RT informed
	6.4			FIX Duplicate		David Rufo			10/08/2021			FIX duplicate online API events
	6.5			FIX Owners			Sandra Gómez		24/08/2021			Fix process Owners Gestor
	6.6			DE52465			    Sandra Gómez		30/09/2021			insertOrUpdateCodigoGestorAsignado and refactor EAP/Gestor
	6.7			Fix Recurring Evts	Víctor Santiago		22/11/2021			Method insertOrUpdateEventQueues added
	6.8			Fix IOP Diciembre	Víctor Santiago		14/12/2021			Call to AV_CitaPrevia_SyncEvents and commented insertOrUpdateEventQueues
	6.9			US286825 			Daniel Rodríguez	13/01/2022			Add Method updateNextManagementDateOpp for unification of expiration dates of opportunities with date of event or task
	7.0		    AV_Query IT		    Daniel Rodríguez	3/02/2022			Change AV_Query to SOQL for User, Account, Contact
	7.1		    US304978		    Víctor Santiago		8/04/2022			Added methods setMeetingLocation and getOfficeNumber
	7.2 		US310702			Luis Fernández		14/04/2022			Added method changeOwner
																			Modify UserGFC in processOwmerGestoresEAP method
	7.3			Fix-bucle			Sandra Gómez		19/04/2022			Change method updateNextManagementDateOpp queries in for
	7.4 		US322355 			Luis Fernández		19/05/2022			Change method syncEvents
	7.5			DE63338				Sandra Gómez		18/08/2022			Add Method checkGeneralRTWithoutOutlook
	7.6			US450626     		Sandra Gómez      	13/09/2022          Changed method syncEvents add condition in Event isChild
	7.7			US326386			Luis Fenández		14/10/2022			Added setEventChanelAndPurpose method
	7.8			DE66184				Sandra Gómez		26/10/2022			Add callApiTeams method
	7.9         Fix delete          Elisabeth Rodríguez 08/11/2022          Added deleteEvent method
	8.0			Fix delete			Sandra Gómez		30/11/2022			Modify method checkOutlookEvent and deleteEvent Added method callApiDeleteEvent
	8.1			DE69586				Sandra Gómez		12/12/2022			Modify method checkOutlookEvent AV_Externalid__c
	8.2         US453532            Elisabeth Rodríguez 14/12/2022          Added changeSubjectToCanceled method
	8.3			US481618			Ángel Medina		18/01/2023			Add new method recordChannel
	8.4			DE71529				Sandra Gómez		01/02/2023			Change method setMeetingLocation
	8.5			DE86213				Sandra Gómez		24/11/2023			Change method recordChannel duplicity list
	8.6			DE76223				Humberto Vilchez	10/01/2024			Change method updateNextManagementDateOpp to fix UNABLE_TO_LOCK_ROW error
	8.7                             Oscar Moreno        16/01/2024          Comment recordChannel method
	8.8			Ejec. Lentas		Sandra Gómez		22/02/2024			Add method fieldSubjectStartDateTime
	8.9         US839366            Oscar Moreno        28/02/2024          Add method updateNextEventDateFieldOfOpp
	9.0         Fix- too long       Oscar Moreno        10/04/2024          Modify fieldSubjectStartDateTime method for truncate subject when the length of the Subject > (subject + StartDateTime lenght)
	9.1			Fix					Sandra Gómez		18/04/2024			Change method updateNextEventDateFieldOfOpp to control null and add filter RtCliente
	9.2			US839375			Ángel Medina		18/04/2024			Modify method updateNextManagementDateOpp  to update stagename opportunity
	9.3			FIX22040914			Ali Vazquez			06/05/2024			Added extra-validation to updateNextEventDateOpportunity to avoid UNABLE_TO_LOCK_ROW
	9.4			PPM100205278		Luis Fernández		28/05/2024			Added No Gestionada status in all places where Vencido its being evaluated
	9.5			PPM100538432		Sandra Gómez		17/09/2024			Add method byPassEvent and Add parameter mapByPass in method syncEvents
	9.6         Carga de citas Pool 
				sin asignar 		Luis Fernández  	18/10/2024      	Added new method assignPoolEvents to give the owner of the gcf events to his pool DT.

***********************************************************************************************************************/
public with sharing class AV_EventTriggerHelper {

	public static final String SUFFIX_EXTERNALID 	= 'Evt-';
	
	private static AV_AppUtilities.SearchRT rtCliente 	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTCLIENTE_RT);
	private static AV_AppUtilities.SearchRT rtGestor	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_EVENT, AV_AppConstants.EVENTGESTOR_RT);
	private static Set<Id> setRtAll 		= getAllRT();
	private static Set<Id> setRtCliente		= getIdsRT(new Set<AV_AppUtilities.SearchRT>{rtCliente});
	private static Set<Id> setRtGestor		= getIdsRT(new Set<AV_AppUtilities.SearchRT>{rtGestor});
	
	/**
	 * @description		 	Check the record types
	 * @param listNews  	list of new records
	 */
	public static List<Event> checkGeneralRT(List<Event> listNews){
		List<Event> listData = new List<Event>();
		for(Event dataNew : listNews){
			if(String.isEmpty(dataNew.RecordTypeId)){
				setRecordType(dataNew);
			}
			if((setRtAll).contains(dataNew.RecordTypeId)){
				listData.add(dataNew);
			}
		}
		return listData;
	}

	/**
	 * @description		 	Check the record types and events outlook no recurrent
	 * @param listNews  	list of new records
	 */
	public static List<Event> checkGeneralRTWithoutOutlook(List<Event> listNews){
		List<Event> listData = new List<Event>();
		for(Event dataNew : listNews){
			if((setRtAll).contains(dataNew.RecordTypeId) && (!dataNew.IsRecurrence && !dataNew.IsRecurrence2)){
				listData.add(dataNew);
			}
		}
		return listData;
	}

	/**
	 * @description		 	Check non-recurrent Events
	 * @param listNews  	list of new records
	 */
	public static List<Event> checkNonRecurrentEvents(List<Event> listNews){
		List<Event> listData = new List<Event>();
		for(Event dataNew : listNews){
			if(!dataNew.IsRecurrence2){
				listData.add(dataNew);
			}
		}
		return listData;
	}

	
	/**
	 * @description		 	Get all the ID's of the RT
	 */
	public static Set<Id> getAllRT(){
		Set<AV_AppUtilities.SearchRT> setLabelsRt = new Set<AV_AppUtilities.SearchRT>{rtCliente, rtGestor};
		return AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
	}
		
	/**
	 * @description		 	Get the ID's of the RT's requested by param
	 * @param setRT			List of the RT
	 */
	public static Set<Id> getIdsRT(Set<AV_AppUtilities.SearchRT> setRT){
		return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
	}

	/**
	 * @description		    Procces event without recordType and assign to GestorA and assign Origen Outlook
	 * @param  event    	new Events records
	 */
	public static void setRecordType(Event evt){
		if(String.isEmpty(evt.RecordTypeId)){
			evt.RecordTypeId = (new list<Id>(setRtGestor) )[0] ;
			evt.AV_OrigenApp__c = AV_AppConstants.OUTLOOK_ORIGENAPP;
		}
	}	
	
	/**
	 * @description		    Procces owners of Events where field codigoGestor has changed
	 * @param  lstEvents    list of new Events records
	 * @param  mapOlds      map of old account records
	 */
	public static void processOwnerGestores(List<Event> lstEvents, Map<Id, Event> mapOlds){
		Set<Id> setIdsRt = getAllRT();
		List<Event> lstEventsCodigoGestores = new List<Event>();
		List<Event> lstEventsCodigoGestoresSinEap = new List<Event>();
		Set<String> codigosGestores = new Set<String>();
		if(mapOlds != null && !mapOlds.isEmpty()) {
			for(Event eNew : lstEvents){
				if((setIdsRt).contains(eNew.RecordTypeId) && String.isNotBlank(eNew.AV_CodigoGestorAsignado__c)
				&& eNew.AV_CodigoGestorAsignado__c != mapOlds.get(eNew.Id).AV_CodigoGestorAsignado__c){
					lstEventsCodigoGestores.add(eNew);
					codigosGestores.add(eNew.AV_CodigoGestorAsignado__c);
				} else if((setIdsRt).contains(eNew.RecordTypeId) && String.isBlank(eNew.AV_CodigoGestorAsignado__c)
				&& eNew.AV_CodigoGestorAsignado__c != mapOlds.get(eNew.Id).AV_CodigoGestorAsignado__c){
					lstEventsCodigoGestoresSinEap.add(eNew);
				}
			}
		}else{
			for(Event eNew : lstEvents){
				if((setIdsRt).contains(eNew.RecordTypeId) && String.isNotBlank(eNew.AV_CodigoGestorAsignado__c)){
					lstEventsCodigoGestores.add(eNew);
					codigosGestores.add(eNew.AV_CodigoGestorAsignado__c);
				}
			}
		}
		User userGcf = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9' limit 1];
		if(lstEventsCodigoGestoresSinEap!=null && !lstEventsCodigoGestoresSinEap.isEmpty()) {
			for(Event a : lstEventsCodigoGestoresSinEap){
				a.OwnerId = userGcf.Id;
			}
		}
		if(codigosGestores!=null && !codigosGestores.isEmpty()) {
			Map<String, Id> mapGestoresUsers = new Map<String, Id>();
			List<User> listGestoresUsers = [Select Id,AV_ExternalID__c From User Where AV_ExternalID__c in :codigosGestores and IsActive = true];
			if(listGestoresUsers != null && !listGestoresUsers.isEmpty()){
				for(User u : listGestoresUsers){
					if(String.isNotBlank(u.AV_ExternalID__c)){
						mapGestoresUsers.put(u.AV_ExternalID__c, u.Id);
					}
				}
			}
			for(Event a : lstEventsCodigoGestores){
				if(mapGestoresUsers.get(a.AV_CodigoGestorAsignado__c) != null){
					a.OwnerId = mapGestoresUsers.get(a.AV_CodigoGestorAsignado__c);
				}else{
					a.OwnerId = userGcf.Id;
				}
			}
		}	
	}

	/**
	 * @description		 Validate forbidden words in Event field 
	 * @param  listNews  list of new Event records
	 * @param mapOlds map of old Event records
	 */
	/*public static void validateForbiddenWords(List<Event> listNews, Map<Id, Event> mapOlds) {
		Set<Id> setIdsRt = getAllRT();
		List<Event> listToProcess = new List<Event>();
		List<Event> listToProcessNoRepeat = new List<Event>();
		Set<String> setFields = new Set<String>{'Description', 'Subject', 'Location'};
		String subject = '';
		Datetime startDate = null;
		if(mapOlds != null) {
			for(Event ev : listNews) {
				if((setIdsRt).contains(ev.RecordTypeId) && String.isNotBlank(ev.Description) &&
					 !AV_AppConstants.OUTLOOK_ORIGENAPP.equalsIgnoreCase(ev.AV_OrigenApp__c) && 
					( (mapOlds.get(ev.Id).Description != ev.Description) ||
					(String.isNotBlank(ev.Subject) && mapOlds.get(ev.Id).Subject != ev.Subject) ||
					(String.isNotBlank(ev.Location) && mapOlds.get(ev.Id).Location != ev.Location))){
					listToProcess.add(ev);
				}
			}
		} else {
			for(Event ev : listNews) {
				if((setIdsRt).contains(ev.RecordTypeId) && !AV_AppConstants.OUTLOOK_ORIGENAPP.equalsIgnoreCase(ev.AV_OrigenApp__c) 
					&& (String.isNotBlank(ev.Description) || String.isNotBlank(ev.Subject) || String.isNotBlank(ev.Location))) {
					listToProcess.add(ev);
				}
			}
		}
		if(!listToProcess.isEmpty()) {
			// Adds to the list only the first event from a series as well as others
			// that don't belong to the series. Made to avoid CPU time limit when
			// @listNews includes a series without end date.
			for (Event e : listToProcess) {
				if (!(e.Recurrence2PatternStartDate != null && e.Recurrence2PatternStartDate == startDate) && !subject.equals(e.Subject)) {
					listToProcessNoRepeat.add(e);
				}
				subject = e.Subject;
				startDate = e.Recurrence2PatternStartDate;
			}
			AV_ForbiddenWords.validateRecords(listToProcessNoRepeat, setFields);
		}
	}*/

	/**
	 * @description		 Create minimum data of the header custom activity
	 * @param  listNews  list of new Event records
	 */
	public static void headerCustomActivity(List<Event> listNews){
		Set<Id> setIdsRt = getAllRT();
		List<AV_HeaderCustomActivity__c> listHeaderTask = new List<AV_HeaderCustomActivity__c>();
		
		AV_LogDebug.printLogDebug('process', 'listNewObj: ' + listNews.size());

		Id evGestorRT = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(AV_AppConstants.EVENTGESTOR_RT).getRecordTypeId();

		for(Event auxEvt : listNews){
			if((setIdsRt).contains(auxEvt.RecordTypeId) && auxEvt.RecordTypeId != evGestorRT){
				if(String.isBlank(auxEvt.AV_ExternalID__c)){
					
					String externalId = SUFFIX_EXTERNALID + '$OPP$#' + (Math.round(Math.random()*1000000) + Datetime.now().getTime());
					
					if(String.isNotBlank(auxEvt.AV_AssociatedOpportunityId__c )){
						externalId = externalId.replace('$OPP$', auxEvt.AV_AssociatedOpportunityId__c);
					} else {
						externalId = externalId.replace('$OPP$', '');
					}
					auxEvt.AV_ExternalID__c = externalId;
				}
				AV_HeaderCustomActivity__c headerCustomAct = new AV_HeaderCustomActivity__c();
				if(String.isNotBlank(auxEvt.Subject) && auxEvt.Subject.length()<80){
					headerCustomAct.Name = auxEvt.Subject;
				} else {
					headerCustomAct.Name = auxEvt.AV_ExternalID__c;
				}
				headerCustomAct.AV_ExternalID__c = auxEvt.AV_ExternalID__c;
				listHeaderTask.add(headerCustomAct);
			}
		}
		//Insert data && update the field "AV_Task__c"
		if (listHeaderTask!=null && !listHeaderTask.isEmpty()){
			try{
				AV_LogDebug.printLogDebug('process', 'insert listHeaderTask: ' + listHeaderTask.size());
				Database.insert(listHeaderTask, false);
			}catch(Exception e){
				AV_LogDebug.printException('process 1', e);
			}
			try{
				//Map where the key is the external ID
				Map<String, AV_HeaderCustomActivity__c> mapHeaderTask = new Map<String, AV_HeaderCustomActivity__c>();
				for(AV_HeaderCustomActivity__c auxHeaderTask : listHeaderTask){
					mapHeaderTask.put(auxHeaderTask.AV_ExternalID__c, auxHeaderTask);
				}
				//Update field "AV_Task__c"
				for(Event auxEvt : listNews){
					AV_HeaderCustomActivity__c auxHeaderTask = mapHeaderTask.get(auxEvt.AV_ExternalID__c);
					if (auxHeaderTask!=null){
						auxEvt.AV_Task__c = auxHeaderTask.Id;
					}
				}
			}catch(Exception e){
				AV_LogDebug.printException('process', e);
			}
		}
	}

	/**
	 * @description		 Sync Events via cita previa API
	 * @param   listNews    list of new Event records
	 * @param   listOlds    list of old event records
	 */
	public static void syncEvents(List<Event> listNews, List<Event> listOlds, Map<String, Event> mapByPass){
		String methodName = 'syncEvents';
		List<Event> eventsToProcess = new List<Event>();
		Boolean hasBulkApi = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		if(!hasBulkApi && !System.isFuture() && !System.isBatch() && !System.isQueueable()){
			boolean isUpdate = false;
			//Check the new data
			if(listOlds == null || listOlds.isEmpty()){
				for(Event e : listNews){
					if(!mapByPass.containsKey(e.AV_ExternalID__c)) {
						boolean isRtGestorNoOutlook = (setRtGestor).contains(e.RecordTypeId) && (!e.IsRecurrence && !e.IsRecurrence2) && e.IsChild == false;						
						boolean isRtClienteNoOutlook = (setRtCliente).contains(e.RecordTypeId) && String.isNotBlank(e.AV_ExternalID__c) &&  (!e.IsRecurrence && !e.IsRecurrence2) && e.AV_Tipo__c != AV_AppConstants.VIDEOLLAMADA_TIPO && e.IsChild == false;
						AV_LogDebug.printLogDebug(methodName, 'isRtGestorNoOutlook: ' + isRtGestorNoOutlook);
						AV_LogDebug.printLogDebug(methodName, 'isRtClienteNoOutlook: ' + isRtClienteNoOutlook);
						if(isRtGestorNoOutlook || isRtClienteNoOutlook){
							eventsToProcess.add(e);
						}
					}
				
				}
				//Send new events to GCF
				isUpdate = false;
			}
			//Check existing data
			else{
				for(Event e : listNews){
					boolean isRtGestorNoOutlook = (setRtGestor).contains(e.RecordTypeId) && (!e.IsRecurrence && !e.IsRecurrence2) && e.IsChild == false;
					boolean isRtClienteNoOutlook = (setRtCliente).contains(e.RecordTypeId) && String.isNotBlank(e.AV_ExternalID__c) && (!e.IsRecurrence && !e.IsRecurrence2) && e.IsChild == false;
					AV_LogDebug.printLogDebug(methodName, 'isRtGestorNoOutlook: ' + isRtGestorNoOutlook);
					AV_LogDebug.printLogDebug(methodName, 'isRtClienteNoOutlook: ' + isRtClienteNoOutlook);
					if(isRtGestorNoOutlook || isRtClienteNoOutlook){
						eventsToProcess.add(e);
					}
				}
				//Update events in GCF if the event has an external ID
				isUpdate = true;
			}
			if(eventsToProcess!=null && !eventsToProcess.isEmpty()){
				String jsonString = json.serialize(eventsToProcess);
				AV_LogDebug.printLogDebug(methodName, 'eventsToProcess: ' + eventsToProcess.size());
				AV_CitaPrevia_SyncEvents.insertOrUpdateEvent(jsonString, isUpdate);
			}
		}
	}
	
	/**
	 * @description		 Check if the event is created by Outlook or by User
	 * @param  listNews  list of new Event records
	 */
	public static void checkOutlookEvent(List<Event> listNews) {
		String methodName = 'checkOutlookEvent';
		for(Event evt : listNews){
			//Check if the event is created by Outlook or by user (only RT Gestor)
			if((setRtGestor).contains(evt.RecordTypeId) && String.isBlank(evt.AV_OrigenApp__c)){
				boolean isOutlook = isOutlookEvent(evt);
				AV_LogDebug.printLogDebug(methodName, 'isOutlook: ' + isOutlook);
				if(!isOutlook){
					evt.AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
				}else{
					evt.AV_OrigenApp__c = AV_AppConstants.OUTLOOK_ORIGENAPP;
				}
			}
		}
	}
	
	/**
	 * Check if the event was created by Outlook or by User
	 */
	public static boolean isOutlookEvent(Event evt){
		String methodName = 'isOutlookEvent';
		boolean result = false;
		if(String.isNotBlank(evt.Location)){
			if (evt.Location.containsIgnoreCase('Microsoft Teams')){
				result = true;
			}else{
				result = checkOutlookTagsSize(evt);
			}
			AV_LogDebug.printLogDebug(methodName, 'result: ' + result);
		}
		return result;
	}
	
	private static boolean checkOutlookTagsSize(Event evt){
		boolean result = false;
		Set<String> contentOutlook = new Set<String>{'Microsoft Teams', 'https://teams.microsoft.com', 'https://lync.lacaixa.com', 'https://aka.ms/JoinTeamsMeeting', 'https://pexip.me/teams'};
		//Check only the main tags
		for(String aux : contentOutlook){
			if (String.isNotBlank(evt.Description) && evt.Description.containsIgnoreCase(aux)){
				result = true;
				break;
			}
			else if(String.isNotBlank(evt.Description) && evt.Description.length()>2000){
				result = true;
				break;
			}
		}
		return result;
	}

	/**
	 * @description		 Update External ID of the header custom activity
	 * @param  listNews  list of new Event records
	 * @param  mapOlds 	map of old Event records
	 */
	public static void updateHeaderCustomActivityExtId(List<Event> listNews, Map<Id, Event> mapOlds){
		Id evGestorRT = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(AV_AppConstants.EVENTGESTOR_RT).getRecordTypeId();
		Map<Id, Event> mapToProcess = new Map<Id, Event>();
		for(Event ev : listNews) {
			if((setRtAll).contains(ev.RecordTypeId) && ev.RecordTypeId != evGestorRT 
			   		&& ev.AV_ExternalID__c != mapOlds.get(ev.Id).AV_ExternalID__c) {
				mapToProcess.put(ev.AV_Task__c, ev);
			}
		}
		if(!mapToProcess.values().isEmpty() && mapToProcess != null) {
			List<AV_HeaderCustomActivity__c> lstHeaderTaskToUpd = new List<AV_HeaderCustomActivity__c>();
			List<AV_HeaderCustomActivity__c> lstHeaderTask = [Select AV_ExternalID__c, Id From AV_HeaderCustomActivity__c where Id in :mapToProcess.keySet()];
			if(!lstHeaderTask.isEmpty() && lstHeaderTask != null) {
				for(AV_HeaderCustomActivity__c headerTask : lstHeaderTask) {
					String key = headerTask.Id;
					headerTask.AV_ExternalID__c = mapToProcess.get(key).AV_ExternalID__c;
					lstHeaderTaskToUpd.add(headerTask);
				}
			}
			if(!lstHeaderTaskToUpd.isEmpty()) {
				Database.update(lstHeaderTaskToUpd, false);
			}
		}
	}

	/**
	 * @description		 Create a CRM Tarea if event has Description
	 * @param  listNews  list of new Event records
	 * @param  mapOlds 	map of old Event records
	 */
	public static void createCRMTask(List<Event> listNews, Map<Id, Event> mapOlds) {
		if(!System.isFuture() && !System.isBatch()){
			List<Event> lstToProcess = new List<Event>();
			Set<String> setEvtIds = new Set<String>();
			if(mapOlds == null) {
				for(Event ev : listNews) {
					if(String.isNotBlank(ev.Description)) {
						lstToProcess.add(ev);
						setEvtIds.add(ev.Id);
					}
				}
			} else {
				for(Event ev : listNews) {
					if(String.isNotBlank(ev.Description) && ev.Description != mapOlds.get(ev.Id).Description) {
						lstToProcess.add(ev);
						setEvtIds.add(ev.Id);
					}
				}
			}
			if(!lstToProcess.isEmpty()) {
				List<CBK_Activity_Extension__c> lstCRMTasksToUpdate = new List<CBK_Activity_Extension__c>();
				List<CBK_Activity_Extension__c> lstCRMTasksToInsert = new List<CBK_Activity_Extension__c>();
				User currentUser = [Select Name, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId() limit 1];
				String employeeInfo = currentUser.Name;
				if(String.isNotBlank(currentUser.AV_NumeroOficinaEmpresa__c) && currentUser.AV_NumeroOficinaEmpresa__c.contains('-')) {
					employeeInfo += ' (ofi ' + currentUser.AV_NumeroOficinaEmpresa__c.split('-').get(1) + ')';
				}
				if(mapOlds == null) {
					for(Event auxEv : lstToProcess) {
						CBK_Activity_Extension__c crmTask = new CBK_Activity_Extension__c(AV_ActivityId__c = auxEv.Id, AV_ExternalID__c = auxEv.AV_ExternalID__c, AV_CommentLastModifiedBy__c = employeeInfo, AV_CommentLastModifiedDate__c = System.now());
						lstCRMTasksToInsert.add(crmTask);
					}
				} else {
					List<CBK_Activity_Extension__c> lstCRMTasks = [Select Id, AV_ActivityId__c, AV_ExternalID__c, AV_CommentLastModifiedBy__c, AV_CommentLastModifiedDate__c From CBK_Activity_Extension__c where AV_ActivityId__c in :setEvtIds];
					Map<String, CBK_Activity_Extension__c> mapCRMTask = new Map<String, CBK_Activity_Extension__c>();
					for(CBK_Activity_Extension__c auxCRMTask : lstCRMTasks) {
						mapCRMTask.put(auxCRMTask.AV_ActivityId__c, auxCRMTask);
					}
					for(Event auxEv : lstToProcess) {
						CBK_Activity_Extension__c crmTask;
						if(!mapCRMTask.containsKey(auxEv.Id)) {
							crmTask = new CBK_Activity_Extension__c(AV_ActivityId__c = auxEv.Id, AV_ExternalID__c = auxEv.AV_ExternalID__c, AV_CommentLastModifiedBy__c = employeeInfo, AV_CommentLastModifiedDate__c = System.now());
							lstCRMTasksToInsert.add(crmTask);
						} else {
							crmTask = new CBK_Activity_Extension__c(Id = mapCRMTask.get(auxEv.Id).Id, AV_ExternalID__c = auxEv.AV_ExternalID__c, AV_CommentLastModifiedBy__c = employeeInfo, AV_CommentLastModifiedDate__c = System.now());
							lstCRMTasksToUpdate.add(crmTask);
						}
					}
				}
				if(!lstCRMTasksToInsert.isEmpty()) {
					Database.insert(lstCRMTasksToInsert, false);
				}
				if(!lstCRMTasksToUpdate.isEmpty()) {
					Database.update(lstCRMTasksToUpdate, false);
				}
			}
		}
	}

	/**
	 * @description		 Insert or Update AV_CodigoGestorAsignado__c in Events
	 * @param  listNews  list of new Event records
	 * @param  mapOlds 	map of old Event records
	 */
	public static void insertOrUpdateCodigoGestorAsignado(List<Event> listNews, Map<Id, Event> mapOlds){
		Set<Id> setIdsRt = getAllRT();
		List<Event> lstEvents = new List<Event>();
		List<String> listIdOwner= new List<String>();
		Map<String,String> mapUserMatri= new Map<String,String>();
		if(mapOlds == null ||  mapOlds.isEmpty()) {
			for(Event eNew : listNews){
				if((setIdsRt).contains(eNew.RecordTypeId) && String.isBlank(eNew.AV_CodigoGestorAsignado__c) && String.isNotBlank(eNew.OwnerId)){
					lstEvents.add(eNew);
					listIdOwner.add(eNew.OwnerId);
				}
			}
		} else {
			for(Event eNew : listNews){
				if((setIdsRt).contains(eNew.RecordTypeId) && eNew.OwnerId != mapOlds.get(eNew.Id).OwnerId){
					lstEvents.add(eNew);
					listIdOwner.add(eNew.OwnerId);
				} 
			}
		}
		if (lstEvents != null) {
			List<Contact> listEmployees= [Select Id, CC_Matricula__c, AV_UsuarioAsociado__c From Contact Where AV_UsuarioAsociado__c in :listIdOwner];
			if(listEmployees != null && !listEmployees.isEmpty()){
				for(Contact c : listEmployees){
					mapUserMatri.put(c.AV_UsuarioAsociado__c, c.CC_Matricula__c);
				}
			}
			for(Event e : lstEvents){
				if(mapUserMatri.get(e.OwnerId) != null) {
					e.AV_CodigoGestorAsignado__c = mapUserMatri.get(e.OwnerId);
				}
			}
		}
	}
	
	/**
	* @description		 Update updateNextManagementDateOpp of opportunity
	* @param  listNews  list of new Task records
	* @param  mapOlds   map of old records
	*/
	public static void updateNextManagementDateOpp(List<Event> listNews, Map<Id, Event> mapOlds){
		String methodName = 'updateNextManagementDateOpp';
		Set<String> setLabelsRtsTask = new Set<String>{'AV_Otros'};
		Set<String> setLabelsRtsEvent = new Set<String>{'AV_EventosConCliente'};
		Set<Id> setIdsRtsTask = getIdsRT(setLabelsRtsTask);
		Set<Id> setIdsRtsEvent = getIdsRT(setLabelsRtsEvent);
		List<Task> lstTasks = new List<Task>();
		Set<Id> setIdsHeaderEvent = new Set<Id>();
		Set<String> setIdsEvent = new Set<String>();
		Set<Id> setOpp = new Set<Id>();
		Set<Id> setTaskEventExId = new Set<Id>();
		Map<Id,List<String>> mapOppEvent = new Map<Id,List<String>>();
		List<Opportunity> listOppUpdate = new List<Opportunity>();
		Map<String,List<String>> mapTaskOpp = new Map<String,List<String>>();
		List<String> ids= new List<String>();
		Date dateOppNew = null;
		if(mapOlds != null && !mapOlds.isEmpty() ) {
			for(Event tNew : listNews){
				Event eventOld = mapOlds.get(tNew.id);
				if((setIdsRtsEvent).contains(tNew.RecordTypeId) && (eventOld.ActivityDate != tNew.ActivityDate) && tNew.AV_ExternalID__c != null && (tNew.CSBD_Evento_Estado__c == AV_AppConstants.EVENT_STATUS_PENDIENTE)){
					setIdsEvent.add(tNew.AV_ExternalID__c);
				} 
			}
			if(!setIdsEvent.isEmpty()){
				List<AV_HeaderCustomActivity__c> listHeaderTask = [Select id, AV_ExternalID__c from AV_HeaderCustomActivity__c where AV_ExternalID__c in :setIdsEvent];
				if(!listHeaderTask.isEmpty()){
					for(AV_HeaderCustomActivity__c htask : listHeaderTask){
						setIdsHeaderEvent.add(htask.Id);
					}
				}
				List<AV_CustomActivityOpportunity__c> listTaskAndOpp = [Select Id, AV_Task__r.AV_ExternalID__c, AV_Opportunity__c from AV_CustomActivityOpportunity__c where AV_Opportunity__c != null and AV_Task__c in :setIdsHeaderEvent];
				if(!listTaskAndOpp.isEmpty()){ 
					for(AV_CustomActivityOpportunity__c taskOpp : listTaskAndOpp){
						setOpp.add(taskOpp.AV_Opportunity__c);
					}
				}
				if(!setOpp.isEmpty()){  
					List<AV_CustomActivityOpportunity__c> listTaskAndOppRelated = [Select Id, AV_Task__r.AV_ExternalID__c, AV_Opportunity__c from AV_CustomActivityOpportunity__c where AV_Opportunity__c in :setOpp];
					if(!listTaskAndOppRelated.isEmpty()){ 
						for(AV_CustomActivityOpportunity__c eventkOppRelated : listTaskAndOppRelated){
							if(mapOppEvent.containsKey(eventkOppRelated.AV_Opportunity__c)) {
								mapOppEvent.get(eventkOppRelated.AV_Opportunity__c).add(eventkOppRelated.AV_Task__r.AV_ExternalID__c);
							} else {
								mapOppEvent.put(eventkOppRelated.AV_Opportunity__c, new List<String> { eventkOppRelated.AV_Task__r.AV_ExternalID__c });
							}
							if(mapTaskOpp.containsKey(eventkOppRelated.AV_Task__r.AV_ExternalID__c)) {
								mapTaskOpp.get(eventkOppRelated.AV_Task__r.AV_ExternalID__c).add(eventkOppRelated.AV_Opportunity__c);
							} else {
								mapTaskOpp.put(eventkOppRelated.AV_Task__r.AV_ExternalID__c, new List<String> {eventkOppRelated.AV_Opportunity__c});
							}
							ids.add(eventkOppRelated.AV_Task__r.AV_ExternalID__c);
						}
					}
				}
				if(!mapOppEvent.isEmpty()){
					Set<String> statusTask = new Set<String>{AV_AppConstants.TASK_STATUS_PENDIENTE, AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL};
					Set<String> statusEvent = new Set<String>{AV_AppConstants.EVENT_STATUS_PENDIENTE};
					Map<String,Date> mapOppFecha = new Map<String,Date>();
					List<Task> listTaskAndOppRelated = [Select Id, AV_ExternalID__c, ActivityDate from Task where Status in :statusTask and RecordtypeId in :setIdsRtsTask and AV_ExternalID__c in :ids and ActivityDate >= TODAY order by ActivityDate ASC];
					for(Task ta:listTaskAndOppRelated) {
						if (mapTaskOpp.get(ta.AV_ExternalID__c)!=null) {
							for(String oppId:mapTaskOpp.get(ta.AV_ExternalID__c)) {
								if (mapOppFecha.get(oppId) == null){
									mapOppFecha.put(oppId,ta.ActivityDate);
								}else if (mapOppFecha.get(oppId) > ta.ActivityDate) {
									mapOppFecha.put(oppId,ta.ActivityDate);
								}
							}
						}
					}
					List<Event> listEventAndOppRelated = [Select Id, AV_ExternalID__c, ActivityDate from Event where CSBD_Evento_Estado__c in :statusEvent and RecordtypeId in :setIdsRtsEvent and AV_ExternalID__c in :ids and ActivityDate >= TODAY order by ActivityDate ASC limit 1];
					for(Event e:listEventAndOppRelated) {
						if (mapTaskOpp.get(e.AV_ExternalID__c)!=null) {
							for(String oppId:mapTaskOpp.get(e.AV_ExternalID__c)) {
								if (mapOppFecha.get(oppId) == null) {
									mapOppFecha.put(oppId,e.ActivityDate);
								}else if (mapOppFecha.get(oppId) > e.ActivityDate) {
									mapOppFecha.put(oppId,e.ActivityDate);
								}
							}
						}
					}
					if(mapOppFecha != null) {
						Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, StageName, AV_FechaProximoRecordatorio__c FROM Opportunity WHERE Id IN :mapOppEvent.keySet()]);
						for (Id idOpp : mapOppEvent.keySet()){
							if (mapOppFecha.get(idOpp) != null) {
								Opportunity oppUpdate = new Opportunity(Id= idOpp, AV_FechaProximoRecordatorio__c = mapOppFecha.get(idOpp));
								Opportunity currentOpp  = oppMap.get(idOpp);
								if(currentOpp != null){
									if(currentOpp.AV_FechaProximoRecordatorio__c != mapOppFecha.get(idOpp) && (currentOpp.StageName == AV_AppConstants.OPP_STATUS_VENCIDO || currentOpp.StageName == AV_AppConstants.OPP_STATUS_NO_GESTIONADA)){
										oppUpdate.StageName = AV_AppConstants.OPP_STATUS_ENGESTION;
									}
								}
								listOppUpdate.add(oppUpdate);
							}	
						}
					}
				}
				if(!listOppUpdate.isEmpty()){
					Map<id,Opportunity> mapOppUpdate = new Map<id,Opportunity>(listOppUpdate);
					List<Database.SaveResult> listUpdateResult = Database.update(listOppUpdate, false);			
					for (Database.SaveResult sr : listUpdateResult) {
						if (sr.isSuccess()) {
							if(mapOppUpdate.get(sr.getId()) != null){
								mapOppUpdate.remove(sr.getId());
							}
						}
					}
					if (!mapOppUpdate.isEmpty() ) {
						List<Database.SaveResult> listUpdateErrorResult = Database.update(mapOppUpdate.values(), false);
					}
				}
			}
		}
	}
	
	/**
	 * @description		 	Get the ID's of the RT's requested by param
	 * @param setRT			List of the RT
	 */
	public static Set<Id> getIdsRT(Set<String> setRT){
		return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
	}
	
	/**
	 * @description		Populates Location and AV_Center__c after receiving
	 * 					data from GCF.
	 */
	public static void setMeetingLocation(List<Event> listNews, Map<Id, Event> mapOlds, Boolean isUpdate) {
		String methodName = 'setMeetingLocation';
		List<Event> eventsToUpdate = new List<Event>();
		Set<String> eventTypes = new Set<String>{'CTO', 'CTOOC'};
		Set<Id> ownersIds = new Set<Id>();
		List<User> ownersInfo = new List<User>();
		Map<Id, User> owners = new Map<Id, User>();
		List<User> bpaUserList = [SELECT Id FROM User WHERE Alias = :AV_AppConstants.BPA_EVENT_USER];
		User bpaUser = null;
		if(!bpaUserList.isEmpty()){
			bpaUser = bpaUserList[0];
		}
		if (listNews != null && !listNews.isEmpty()) {
			for (Event e : listNews) {
				if (eventTypes.contains(e.AV_Tipo__c) && (bpaUser == null || !e.OwnerId.equals(bpaUser?.Id))) {
					eventsToUpdate.add(e);
					ownersIds.add(e.OwnerId);
				}
			}
			if (eventsToUpdate != null && !eventsToUpdate.isEmpty()){
				ownersInfo = [SELECT Id, AV_NumeroOficinaEmpresa__c FROM User WHERE Id IN :ownersIds];
				owners.putAll(ownersInfo);
				if (isUpdate) {
					if(mapOlds != null && !mapOlds.isEmpty()) {
						for (Event e : eventsToUpdate) {
							if (String.isNotBlank(e.AV_BranchPhysicalMeet__c) && !e.AV_BranchPhysicalMeet__c.equals(mapOlds.get(e.Id).AV_BranchPhysicalMeet__c)) {
								e.Location = e.AV_BranchPhysicalMeet__c;
							} else if (String.isNotBlank(e.Location) && !e.Location.equals(mapOlds.get(e.Id).Location)) {
								e.AV_BranchPhysicalMeet__c = e.Location;
							}
						}
					}
				} else {
					for (Event e : eventsToUpdate) {
						e.Location = String.isNotBlank(e.AV_BranchPhysicalMeet__c) ? e.AV_BranchPhysicalMeet__c : null;
						e.AV_Center__c = String.isNotBlank(owners.get(e.OwnerId).AV_NumeroOficinaEmpresa__c) ? getOfficeNumber(owners.get(e.OwnerId).AV_NumeroOficinaEmpresa__c) : e.AV_Center__c;
					}
				}
			}
		}
	}

	/**
	 * @description		Gets the 5 last characters of the office number.
	 * 					I.e. pass 001-00123 and get 00123
	 * @param num		Office
	 */
	private static String getOfficeNumber(String num) {
		if (String.isNotBlank(num)) {
			if (num.contains('-')) {
				return num.mid(4, 5);
			} else {
				return num;
			}	
		}
		return null;
	}

	public static void updateCentro(List<Event> listData, Map<Id, Event> mapOldObj){
		Map<Id,String> mapOwnerOffice = new Map<Id,String>();
		Set<Id> owners = new Set<Id>();
		List<Event> eventsToProcess = new List<Event>();
		String offiNumber='';
		List<User> relevantUsers = [Select Id,Profile.Name,Alias From User Where (Profile.Name = 'API Only' and Alias = 'AV-TF9') OR Alias = :AV_AppConstants.BPA_EVENT_USER ];//Invocamos al usuario para owners sin EAP
		User userGFC;
		User bpaUser; 

		for(User u : relevantUsers){
			if(u.Profile.Name.equals('API Only') && u.Alias.equals('AV-TF9')){
				userGFC = u;
			}
			if(u.Alias.equals(AV_AppConstants.BPA_EVENT_USER)){
				bpaUser = u;
			}
		}
		if(mapOldObj != null && !mapOldObj.isEmpty()){
			for(Event e : listData){
				if(e.OwnerId != mapOldObj.get(e.Id).OwnerId){
					owners.add(e.OwnerId);
					eventsToProcess.add(e);				
				}			
			}
		}else{
			for(Event e : listData){
				if(bpaUser == null || (bpaUser != null && !e.OwnerId.equals(bpaUser?.Id))){
					owners.add(e.OwnerId);
					eventsToProcess.add(e);				
				}
			}
		}
		List<User> ownerOffice = [SELECT ID,AV_NumeroOficinaEmpresa__c FROM USER WHERE ID in :owners];
		for(User owner : ownerOffice){
			mapOwnerOffice.put(owner.Id,owner.AV_NumeroOficinaEmpresa__c);
		}
		for(Event e : eventsToProcess){	
			if(e.OwnerId != userGFC.id) {
				offiNumber= mapOwnerOffice.get(e.OwnerId);
				e.AV_Center__C = (offiNumber != null)?offiNumber.substring(offiNumber.length()-5):null;
			}	
		}
	}

	/** Change owner to SinGestorEap if new owner has not associted contact*/
	public static void changeOwner(List<Event> listNews, Map<Id, Event> mapOlds) {
		Set<Id> evtOwners = new Set<Id>();
		List<String> idOwnerWithNoEap = new List<String>();
		List<Event> evtToProcess = new List<Event>();
		List<User> userGcf = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9' limit 1];//Invocamos al usuario para owners sin EAP
		if(mapOlds != null && !mapOlds.isEmpty()){		
			for(Event evt: listNews){
				if(evt.OwnerId != mapOlds.get(evt.Id).OwnerId){
					evtToProcess.add(evt);
					evtOwners.add(evt.OwnerId);
				}
			}
		}else{
			for(Event evt: listNews){
				evtToProcess.add(evt);
				evtOwners.add(evt.OwnerId);
			}
		}
		List<User> ownerWithNoEap = [SELECT ID FROM USER WHERE id NOT IN (SELECT AV_UsuarioAsociado__c FROM contact WHERE AV_UsuarioAsociado__c in :evtOwners) AND id IN :evtOwners];
		if(ownerWithNoEap!= null && !ownerWithNoEap.isEmpty()){
			for(User u : ownerWithNoEap){
				idOwnerWithNoEap.add(u.id);
			}
			List<User> userOwner = [Select AV_ExternalID__c from User where id =: idOwnerWithNoEap[0] limit 1];
			if (userOwner != null && !userOwner.isEmpty() && userOwner[0].AV_ExternalID__c != null) {
				List<Contact> contactEmployeeNum = [Select Id from Contact Where CC_Matricula__c =: userOwner[0].AV_ExternalID__c limit 1];
				if(contactEmployeeNum != null && !contactEmployeeNum.isEmpty()){
					for(Event evt : evtToProcess){			  
						evt.OwnerId = idOwnerWithNoEap.iterator().next();
					}	
				}else{
					for(Event evt : evtToProcess){
						if (userGcf!= null && !userGcf.isEmpty()) {
							evt.OwnerId = userGcf[0].id;
						}	  
					}	
				}
			} else {
				for(Event evt : evtToProcess){
					if (userGcf!= null && !userGcf.isEmpty()) {
						evt.OwnerId = userGcf[0].id;
					}	  
				}
			}
		}
	}
	
	/**
	* @description		Set the AV_Purpose__C, AV_Chanel__c and AV_InOutBound fields when an Event is created or gived by GFC
	* @param  listNews  list of new Event records
	*/
	public static void setEventChanelAndPurpose(List<Event> listNews){
		Boolean externalEvent = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		for(Event evt : listNews){
			if(!externalEvent && !isOutlookEvent(evt)){
				evt.AV_Chanel__c = AV_AppConstants.CHANEL_MC;

				if(evt.AV_Purpose__c != null){  
					if(String.isNotBlank(evt.AV_Origen__c)){
						if(evt.AV_Origen__c.equals('Eventos con Cliente') && evt.AV_Purpose__c =='002'){
							evt.AV_Purpose__c = AV_AppConstants.PURPOSE_GESTION_OPERATIVA;
						}else if(evt.AV_Origen__c.equals('Eventos con Cliente')) {
							evt.AV_Purpose__c = AV_AppConstants.PURPOSE_GESTION_COMERCIAL;
						}
						if(evt.AV_Origen__c.equals('Eventos Gestor/a')) {
							evt.AV_Purpose__c = AV_AppConstants.PURPOSE_GESTION_OPERATIVA;
						}
					}
				}else{
					if(evt.Subject == 'Gestión operativa'){
						evt.AV_Purpose__c = AV_AppConstants.PURPOSE_GESTION_OPERATIVA;
					}else{
						evt.AV_Purpose__c = AV_AppConstants.PURPOSE_GESTION_COMERCIAL;
					}
				}
			}else{	
				if(String.isBlank(evt.AV_Purpose__c) ) {
					evt.AV_Purpose__c = AV_AppConstants.PURPOSE_GESTION_COMERCIAL;
				}
				if(String.isBlank(evt.AV_InOutbound__c) ) {
					evt.AV_InOutbound__c = AV_AppConstants.INOUTBOUND_ENTRADA;						
				}
			}
		}
	}

	/**
	* @description		Videollamada Teams with RT Con Cliente
	* @param  listNews  list of new Event records
	*/
	public static void callApiTeams(List<Event> listNews){

		List<Event> listToProcess = new List<Event>();
		List<String> listIdUserCreatedEvent = new List<String>();
		Map<String,User> mapUser = new Map<String,User>();
		for(Event evt : listNews){
			if((setRtCliente).contains(evt.RecordTypeId) && evt.AV_Tipo__c == AV_AppConstants.VIDEOLLAMADA_TIPO) {
				listToProcess.add(evt);
				listIdUserCreatedEvent.add(evt.CreatedById);
			}
		}

		if (listToProcess != null && !listToProcess.isEmpty()) {
			List<User> listEmp  = [Select Id, AV_ExternalID__c, AV_AzureId__c, FederationIdentifier From User Where Id in :listIdUserCreatedEvent limit 1];
			if (listEmp != null && !listEmp.isEmpty()) {
				for(User emp : listEmp) {
					mapUser.put(emp.Id,emp);
				}
			}
		}
		if (mapUser != null) {
			for(Event evt : listToProcess) {
				String jsonString = json.serialize(evt);
				System.enqueueJob(new AV_TeamsGCF_Queueable(jsonString, evt.Subject, evt.EndDateTime, evt.StartDateTime, evt.AV_Task__c, mapUser.get(evt.CreatedById)?.FederationIdentifier , mapUser.get(evt.CreatedById)?.AV_AzureId__c));
			}
		}
	}

	/**
	* @description		Call Method Future GCF Delete
	* @param  listOdl  list of old Event records
	*/
	public static void deleteEvent(List<Event> listOdl){
		String methodName = 'deleteEvent';
		List<Event> listToProcess= new List<Event>();
		List<String> listOwners= new List<String>();
		Map<String,User> mapOwners= new Map<String,User>();
		if (listOdl!=null && !listOdl.isEmpty()) {
			for(Event ev : listOdl) {
				if (!ev.IsRecurrence2) {
					listToProcess.add(ev);
					listOwners.add(ev.OwnerId);
				}
			}
		}
		if (listToProcess!=null && !listToProcess.isEmpty()){
			List<User> listEmployeeUser = [SELECT Id, AV_ExternalID__c,AV_NumeroOficinaEmpresa__c FROM USER WHERE ID in :listOwners];
			if (listEmployeeUser!=null && !listEmployeeUser.isEmpty()) {
				for(User us : listEmployeeUser) {
					mapOwners.put(us.Id,us);
				}
			}
		}
		if (mapOwners != null) {
			for(Event ev : listToProcess) {
				if (mapOwners.get(ev.OwnerId) != null && mapOwners.get(ev.OwnerId).AV_ExternalID__c != null && mapOwners.get(ev.OwnerId).AV_NumeroOficinaEmpresa__c != null && ev.AV_ExternalID__c != null && ev.CSBD_Evento_Estado__c != AV_AppConstants.STATUS_CANCELLED){
					callApiDeleteEvent(mapOwners.get(ev.OwnerId).AV_ExternalID__c,ev.AV_ExternalID__c,mapOwners.get(ev.OwnerId).AV_NumeroOficinaEmpresa__c);
				}
			}
		}
	}

	/**
	* @description		Call Api GCF Delete
	* @param  userExternalId  external id of user owner
	* @param  eventExternalId  externalid event
	* @param  userOficina  oficina of user owner
	*/
	@Future(callout=true)
	public static void callApiDeleteEvent(String userExternalId, String eventExternalId, String userOficina) {
		String methodName = 'callApiDeleteEvent';
		AV_CitaPrevia_Integration.DelCntResponse res = AV_CitaPrevia_Integration.delCnt(userExternalId,eventExternalId,userOficina);
		AV_LogDebug.printLogDebug(methodName, 'Response:' + res.StatusCode); 
	}


	/**
	* @description		Change the Event Subject when the status changes to Canceled
	* @param  listNews  list of new Event records
	*/
	public static void changeSubjectToCanceled(List<Event> listNews, Map<Id, Event> mapOlds){
		RecordType rtCliente = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT,AV_AppConstants.EVENTCLIENTE_RT);
		if(mapOlds != null) {
			for(Event ev : listNews) {
				if(ev.RecordTypeId  == rtCliente.Id && mapOlds.get(ev.Id).AV_ToDelete__c == false && ev.AV_ToDelete__c == true){
					if(mapOlds.get(ev.Id).CSBD_Evento_Estado__c != AV_AppConstants.STATUS_CANCELLED){
						ev.Subject = AV_AppConstants.STATUS_CANCELLED_UPPERCASE + ' - ' + ev.Subject;	
					}
					ev.CSBD_Evento_Estado__c = AV_AppConstants.STATUS_CANCELLED;
					ev.AV_ToDelete__c = false;
				}
			}
		} 
	}

	/**
	* @description		Change/create the value Event of field SubjectStartDateTime
	* @param  listNews  list of new Event records
	*/
	public static void fieldSubjectStartDateTime(List<Event> listNews){
		for(Event ev : listNews) {
			if (ev.Subject != null && ev.StartDateTime != null) {
				Integer remainingChars = 255 - String.valueOf(ev.StartDateTime).length() -1;  //-1 por el - cbk_CustomIndex
				if (ev.Subject.length() > remainingChars) {
					// Trunca el subject
					ev.CBK_CustomIndex__c = ev.Subject.substring(0, remainingChars)+'-'+ev.StartDateTime;
				}else{
					ev.CBK_CustomIndex__c = ev.Subject+'-'+ev.StartDateTime;
				}
			}
		}
	}


	/**
	* @description		update AV_NextEventDate field of Opportunity with the value of the most current date of the ActivityDate field of its related events
	* @param  listNews  list of new Event records
	* @param  listOdl  list of old Event records
	*/
	public static void updateNextEventDateFieldOfOpp(List<Event> listNews, Map<Id, Event> mapOlds){
		List<String> evtsToWork = new List<String>();
		String methodName = 'updateNextEventDateFieldOfOpp';
		if(mapOlds != null && !mapOlds.isEmpty()){
			for(Event ev : listNews){
				if(setRtCliente.contains(ev.RecordTypeId) 
				&& ev.AV_Task__c != null 
				&& ((ev.CSBD_Evento_Estado__c != null && !ev.CSBD_Evento_Estado__c.equals(AV_AppConstants.EVENT_STATUS_PENDIENTE)) || ev.ActivityDate != mapOlds.get(ev.Id).ActivityDate)){
					evtsToWork.add(ev.AV_Task__c);
				}
			}
		}else{
			for(Event ev : listNews){
				if(setRtCliente.contains(ev.RecordTypeId) && ev.AV_Task__c != null){
					evtsToWork.add(ev.AV_Task__c);
				}
			}
		}
		if(!evtsToWork.isEmpty()){
			List<AV_CustomActivityOpportunity__c> caosRelated = [SELECT Id,AV_Task__c,AV_Opportunity__c, AV_Opportunity__r.AV_NextEventDate__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c IN :evtsToWork];
			Set<String> opposRelated = new Set<String>();
			Map<String, Date> nextEventDateMap = new Map<String, Date>();

			if(!caosRelated.isEmpty()){
				for(AV_CustomActivityOpportunity__c cao : caosRelated){
					if(cao.AV_Opportunity__c != null){
						opposRelated.add(cao.AV_Opportunity__c);
						nextEventDateMap.put(cao.AV_Opportunity__c, cao.AV_Opportunity__r.AV_NextEventDate__c);
					}
				}
				List<AV_CustomActivityOpportunity__c> otherEventsToOppos = [SELECT Id,AV_Task__c,AV_Opportunity__c FROM AV_CustomActivityOpportunity__C WHERE AV_Opportunity__c IN :opposRelated];
				if(!otherEventsToOppos.isEmpty()){
					Map<String,List<String>> mapOppsToHisTasksId = new Map<String,List<String>>();
					Set<String> relatedAVTasksUnOrdered = new Set<String>();
					for(AV_CustomActivityOpportunity__c cao : otherEventsToOppos){
						if(cao.AV_Task__c != null){
							relatedAVTasksUnOrdered.add(cao.AV_Task__c);
							if(mapOppsToHisTasksId.containsKey(cao.AV_Opportunity__c)){
								mapOppsToHisTasksId.get(cao.AV_Opportunity__c).add(cao.AV_Task__c); 
							}else{
								mapOppsToHisTasksId.put(cao.AV_Opportunity__c, new List<String>{cao.AV_Task__c});
							}
						}
					}
					if(!relatedAVTasksUnOrdered.isEmpty() ){
						List<Event> relatedEvents  = [SELECT Id, ActivityDate, CSBD_Evento_Estado__c, AV_Task__c FROM Event WHERE AV_Task__c IN :relatedAVTasksUnOrdered AND CSBD_Evento_Estado__c = :AV_AppConstants.EVENT_STATUS_PENDIENTE AND AV_Task__c != null AND ActivityDate >= TODAY ORDER BY ActivityDate ASC];
						Set<String> opposUpdated = new Set<String>();
						List<Opportunity> opposForUpdate = new List<Opportunity>();
						
						if(!relatedEvents.isEmpty()){
							for(String oppId : mapOppsToHisTasksId.keySet()){
								List<String> tasksIdOfTheOppo = mapOppsToHisTasksId.get(oppId);
								Boolean finishByBreak = false;
									for(Event evt : relatedEvents){
										if(tasksIdOfTheOppo.contains(evt.AV_Task__c) ){
											if(nextEventDateMap.get(oppId) != evt.ActivityDate){
												opposForUpdate.add(new Opportunity(Id = oppId,AV_NextEventDate__c = evt.ActivityDate));
											}
											finishByBreak = true;
											break;
										}
									}
									if(!finishByBreak){
										opposForUpdate.add(new Opportunity(Id = oppId,AV_NextEventDate__c = null));
									}
							}
						}else{
							for(String oppId : opposRelated){
								opposForUpdate.add(new Opportunity(Id = oppId,AV_NextEventDate__c = null));
							}
						}
						if(!opposForUpdate.isEmpty()){
							List<Database.SaveResult> srList = Database.update(opposForUpdate,false);
							for(Database.SaveResult sr : srList){
								if(!sr.isSuccess()){
									for(Database.Error err : sr.getErrors()){
										AV_LogDebug.printLogError(methodName, err.getMessage());
									}
								}
							}
						}
					}
				}
			}
		}		
    }

	/**
	* @description     Bypass in Event by report or back
	* @param  listNews  list of new Event records
	* @param  mapOlds   map of old Event records.
	*/
	public static Map<String, Event> byPassEvent(List<Event> listNews) {
		Map<String, Event> mapReturnToAfter = new Map<String, Event>();
		for(Event e: listNews){
			if(e.AV_OrigenApp__c != null && String.isNotBlank(e.AV_OrigenApp__c) && e.AV_OrigenApp__c == AV_AppConstants.OPP_ORIGEN_SF_REPORT){
				if (e.AV_ExternalID__c == null) {
					e.AV_ExternalID__c = SUFFIX_EXTERNALID+(Math.round(Math.random()*1000000) + Datetime.now().getTime());
				}
				mapReturnToAfter.put(e.AV_ExternalID__c,e);
				e.AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
			}
		}
		return mapReturnToAfter;
	}

	/**
	 * @description Filter events inserted by GFC and owner them to the right Pool User based on the av_center__c of incoming event
	 * 
	 */

	 public static void assignPoolEvents(List<Event> listNews){
		String methodName = 'assignPoolEvents';
		List<User> bpaUser = [SELECT Id FROM User WHERE Alias = :AV_AppConstants.BPA_EVENT_USER LIMIT 1];
		if(!bpaUser.isEmpty()){
			Integer idProv = 0;
			Map<Event,String> evtsToReOwnerByCenter = new Map<Event,String>();
			for(Event e : listNews){
				if(e.OwnerId.equals(bpaUser[0].Id) && e.AV_Center__c != null){
					evtsToReOwnerByCenter.put(e,e.AV_Center__c);
				}
			}

			if(!evtsToReOwnerByCenter.isEmpty()){
				Map<String,String> centerToPoolUser = AV_PoolEvents_Controller.getCurrentDTMap(new Set<String>(evtsToReOwnerByCenter.values()));
				if(centerToPoolUser != null){

					Map<Id,User> poolUsersExtId = new Map<Id,User>([SELECT Id,AV_ExternalId__c FROM User WHERE Id IN :centerToPoolUser.values()]);
					for(Event e : listNews){
						if(evtsToReOwnerByCenter.containsKey(e) && centerToPoolUser.get(e.AV_Center__c) != null ){
							e.OwnerId = centerToPoolUser.get(e.AV_Center__c);
							if(poolUsersExtId.containsKey(e.OwnerId)){
								e.AV_CodigoGestorAsignado__c = poolUsersExtId.get(e.OwnerId).AV_ExternalId__c;
							}
						}
					}
				}
			}
		}
	 }
}