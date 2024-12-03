/**********************************************************************************************************************
Name:	  CIBE_EventTriggerHelper
Copyright © 2022  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Event para CIBE
------------------------------------------------------------------------------------------------
Historial
------------------------------------------------------------------------------------------------
VERSION		USER_STORY		AUTHOR				DATE				Description
1.0							Alex Campos			17/08/2022			Init version
2.0			US481662		Jose Maria 			29/11/2022			Funcionalidad Cartera y Sector añadido al metodo ChangeOwner
3.0			US507827		Jose Maria			26/01/2023			Copy callApiTeams method from retail
3.1			US619652		Lucia				02/06/2023			Add method deleteRecordsRelatedWithEvent

------------------------------------------------------------------------------------------------
***********************************************************************************************************************/
public with sharing class CIBE_EventTriggerHelper {
    
    public static final String SUFFIX_EXTERNALID 	= 'Evt-';
    private static CIBE_AppUtilities.SearchRT rtCliente 	= new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
    private static CIBE_AppUtilities.SearchRT rtGestor	    = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_GESTOR_RT);
    private static Set<Id> setRtAll 		= getAllRT();
    private static Set<Id> setRtCliente		= getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtCliente});
    private static Set<Id> setRtGestor		= getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtGestor});


    /**
    * @description		Check the record types
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
    * @description		 	Get all the ID's of the RT from EVENT
    */
    public static Set<Id> getAllRT(){
		
        Set<CIBE_AppUtilities.SearchRT> setLabelsRt = new Set<CIBE_AppUtilities.SearchRT>{rtCliente, rtGestor};
		return CIBE_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
    }
    /* Metodo para obtener todos los RT de un objeto
     @description		 	Get all the ID's of the RT from EVENT
    
    public static Set<Id> getAllRT(){
        Schema.DescribeSObjectResult objDescribe = Event.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> recordTypeObj = objDescribe.getRecordTypeInfos();
        Set<Id> setIdsRt = New Set<Id>();
        
        for (Schema.RecordTypeInfo rt: recordTypeObj){
            if (rt.getDeveloperName().left(5)=='CIBE_') {
                setIdsRt.add(rt.getRecordTypeId());
            }
        }
        return setIdsRt;
    }
    */
    /**
    * @description		 	Get the ID's of the RT's requested by param
    * @param setRT			List of the RT
    */
    public static Set<Id> getIdsRT(Set<CIBE_AppUtilities.SearchRT> setRT){
		
        return CIBE_AppUtilities.getRecordTypeIdsInSet(setRT);
    }

    /**
	 * @description		 	Get the ID's of the RT's requested by param
	 * @param setRT			List of the RT
	 */
	public static Set<Id> getIdsRT(Set<String> setRT){
		
		return CIBE_AppUtilities.getRecordTypeIdsInSet(setRT);
	}
    
    /**w
    * @description		    Procces event without recordType and assign to GestorA and assign Origen Outlook
    * @param  event    	new Events records
    */
    public static void setRecordType(Event evt){
		
        if(String.isEmpty(evt.RecordTypeId)){
            evt.RecordTypeId = (new list<Id>(setRtGestor) )[0] ;
            evt.AV_OrigenApp__c = CIBE_AppConstants.OUTLOOK_ORIGENAPP;
        }
    }
    
    /**
    * @description		Create minimum data of the header custom activity
    * @param  listNews  list of new Event records
    */
    public static void headerCustomActivity(List<Event> listNews){
		
        Set<Id> setIdsRt = getAllRT();
        List<AV_HeaderCustomActivity__c> listHeaderTask = new List<AV_HeaderCustomActivity__c>();
        
        AV_LogDebug.printLogDebug('process', 'listNewObj: ' + listNews.size());
        
        Id evGestorRT = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.EVENT_GESTOR_RT).getRecordTypeId();
        
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
                if(AV_HeaderCustomActivity__c.SObjectType.getDescribe().isCreateable()) {
                    Database.insert(listHeaderTask, false);
                }
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
				User currentUser = new User();
				if(	
					User.SObjectType.getDescribe().isAccessible() &&
					Schema.SObjectType.User.fields.AV_NumeroOficinaEmpresa__c.isAccessible()
				) {
					currentUser = [SELECT Name, AV_NumeroOficinaEmpresa__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
				}
	
				String employeeInfo = currentUser.Name;
				if(String.isNotBlank(currentUser.AV_NumeroOficinaEmpresa__c) && currentUser.AV_NumeroOficinaEmpresa__c.contains('-')) {
					employeeInfo += ' (ofi ' + currentUser.AV_NumeroOficinaEmpresa__c.split('-').get(1) + ')';
				}
	
				if(mapOlds == null) {
					for(Event auxEv : lstToProcess) {
						CBK_Activity_Extension__c crmTask = new CBK_Activity_Extension__c(AV_ActivityId__c = auxEv.Id, AV_CommentLastModifiedBy__c = employeeInfo, AV_CommentLastModifiedDate__c = System.now());
						lstCRMTasksToInsert.add(crmTask);
					}
				} else {
					List<CBK_Activity_Extension__c> lstCRMTasks= new List<CBK_Activity_Extension__c>();

					if(
						CBK_Activity_Extension__c.SObjectType.getDescribe().isAccessible() &&
						Schema.SObjectType.CBK_Activity_Extension__c.fields.AV_ActivityId__c.isAccessible() &&
						Schema.SObjectType.CBK_Activity_Extension__c.fields.AV_CommentLastModifiedBy__c.isAccessible()&&
						Schema.SObjectType.CBK_Activity_Extension__c.fields.AV_CommentLastModifiedDate__c.isAccessible()
					) {
						lstCRMTasks = [SELECT Id, AV_ActivityId__c, AV_CommentLastModifiedBy__c, AV_CommentLastModifiedDate__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c IN :setEvtIds];
					}
					
					Map<String, CBK_Activity_Extension__c> mapCRMTask = new Map<String, CBK_Activity_Extension__c>();
					for(CBK_Activity_Extension__c auxCRMTask : lstCRMTasks) {
						mapCRMTask.put(auxCRMTask.AV_ActivityId__c, auxCRMTask);
					}
					for(Event auxEv : lstToProcess) {
						CBK_Activity_Extension__c crmTask;
						if(!mapCRMTask.containsKey(auxEv.Id)) {
							crmTask = new CBK_Activity_Extension__c(AV_ActivityId__c = auxEv.Id, AV_CommentLastModifiedBy__c = employeeInfo, AV_CommentLastModifiedDate__c = System.now());
							lstCRMTasksToInsert.add(crmTask);
						} else {
							crmTask = new CBK_Activity_Extension__c(Id = mapCRMTask.get(auxEv.Id).Id, AV_CommentLastModifiedBy__c = employeeInfo, AV_CommentLastModifiedDate__c = System.now());
							lstCRMTasksToUpdate.add(crmTask);
						}
					}
				}
				if(!lstCRMTasksToInsert.isEmpty()) {
					if(CBK_Activity_Extension__c.sObjectType.getDescribe().isCreateable()){ 
						Database.insert(lstCRMTasksToInsert, false);
					}
				}
				if(!lstCRMTasksToUpdate.isEmpty()) {
					if(CBK_Activity_Extension__c.sObjectType.getDescribe().isUpdateable()){
						Database.update(lstCRMTasksToUpdate, false);
					}
				}
			}
		}
	}

    /**
	 * @description		 Sync Events via cita previa API
	 * @param   listNews    list of new Event records
	 * @param   listOlds    list of old event records
	 */
	public static void syncEvents(List<Event> listNews, map<Id,Event> mapOlds){
		
		String methodName = 'syncEvents';
		List<Event> eventsToProcess = new List<Event>();
		
		Boolean hasBulkApi = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		if(!hasBulkApi && !System.isFuture() && !System.isBatch() && !System.isQueueable()){
			boolean isUpdate = false;
			//Check the new data
			if(mapOlds == null || mapOlds.isEmpty()){
				for(Event e : listNews){
					boolean isRtGestorNoOutlook = (setRtGestor).contains(e.RecordTypeId) 
															&& (!e.IsRecurrence && !e.IsRecurrence2);
												
					
					boolean isRtClienteNoOutlook = (setRtCliente).contains(e.RecordTypeId) 
														&& String.isNotBlank(e.AV_ExternalID__c) 
														&&  (!e.IsRecurrence && !e.IsRecurrence2)
														&& e.AV_Tipo__c != CIBE_AppConstants.VIDEOLLAMADA_TIPO;
								
					
					AV_LogDebug.printLogDebug(methodName, 'isRtGestorNoOutlook: ' + isRtGestorNoOutlook);
					AV_LogDebug.printLogDebug(methodName, 'isRtClienteNoOutlook: ' + isRtClienteNoOutlook);
					if(isRtGestorNoOutlook || isRtClienteNoOutlook){
						eventsToProcess.add(e);
					}
				}
				//Send new events to GCF
				isUpdate = false;
			}
			//Check existing data
			else{
				for(Event e : listNews){
					boolean isRtGestorNoOutlook = (setRtGestor).contains(e.RecordTypeId) 
													&&  (!e.IsRecurrence && !e.IsRecurrence2);
												
					
					boolean isRtClienteNoOutlook = (setRtCliente).contains(e.RecordTypeId) 
														&& String.isNotBlank(e.AV_ExternalID__c)
														&&  (!e.IsRecurrence && !e.IsRecurrence2);
					boolean cambioConf = false;
					if(e.CIBE_Confidential__c!= mapOlds.get(e.id).CIBE_Confidential__c){
						cambioConf= true;
					}
					
					AV_LogDebug.printLogDebug(methodName, 'isRtGestorNoOutlook: ' + isRtGestorNoOutlook);
					AV_LogDebug.printLogDebug(methodName, 'isRtClienteNoOutlook: ' + isRtClienteNoOutlook);
					if((isRtGestorNoOutlook || isRtClienteNoOutlook) && !cambioConf ){
						eventsToProcess.add(e);
					}
				}
				//Update events in GCF if the event has an external ID
				isUpdate = true;
			}
			
			if(eventsToProcess!=null && !eventsToProcess.isEmpty()){
				String jsonString = json.serialize(eventsToProcess);
				AV_LogDebug.printLogDebug(methodName, 'eventsToProcess: ' + eventsToProcess.size());
                if(!Test.isRunningTest()){
					CIBE_CitaPrevia_SyncEvents.insertOrUpdateEvent(jsonString, isUpdate);
                }
			}
		}
	}

    /**
	 * @description		 Update External ID of the header custom activity
	 * @param  listNews  list of new Event records
	 * @param  mapOlds 	map of old Event records
	 */
	public static void updateHeaderCustomActivityExtId(List<Event> listNews, Map<Id, Event> mapOlds){
		
		Id evGestorRT = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get(CIBE_AppConstants.EVENT_GESTOR_RT).getRecordTypeId();

		Map<Id, Event> mapToProcess = new Map<Id, Event>();
		for(Event ev : listNews) {
			if((setRtAll).contains(ev.RecordTypeId) && ev.RecordTypeId != evGestorRT 
					&& ev.AV_ExternalID__c != mapOlds.get(ev.Id).AV_ExternalID__c) {
				mapToProcess.put(ev.AV_Task__c, ev);
			}
		}

		if(!mapToProcess.values().isEmpty() && mapToProcess != null) {
			List<AV_HeaderCustomActivity__c> lstHeaderTaskToUpd = new List<AV_HeaderCustomActivity__c>();
			List<AV_HeaderCustomActivity__c> lstHeaderTask= new List<AV_HeaderCustomActivity__c>();
			if(
				AV_HeaderCustomActivity__c.SObjectType.getDescribe().isAccessible() &&
				Schema.SObjectType.AV_HeaderCustomActivity__c.fields.AV_ExternalID__c.isAccessible()
			) {
				lstHeaderTask = [SELECT AV_ExternalID__c, Id FROM AV_HeaderCustomActivity__c WHERE Id IN :mapToProcess.keySet()];
			}
			if(!lstHeaderTask.isEmpty() && lstHeaderTask != null) {
				for(AV_HeaderCustomActivity__c headerTask : lstHeaderTask) {
					String key = headerTask.Id;
					headerTask.AV_ExternalID__c = mapToProcess.get(key).AV_ExternalID__c;
					lstHeaderTaskToUpd.add(headerTask);
				}
			}

			if(!lstHeaderTaskToUpd.isEmpty()) {
				if(AV_HeaderCustomActivity__c.sObjectType.getDescribe().isUpdateable()){
					Database.update(lstHeaderTaskToUpd, false);
				}
			}
		}
	}

    /**
	* @description		Update updateNextManagementDateOpp of opportunity
	* @param  listNews  list of new Task records
	* @param  mapOlds   map of old records
	*/
	public static void updateNextManagementDateOpp(List<Event> listNews, Map<Id, Event> mapOlds){
		
		String methodName = 'updateNextManagementDateOpp';
		Set<String> setLabelsRtsTask = new Set<String>{CIBE_AppConstants.TASK_OTROS_CIB_RT, CIBE_AppConstants.TASK_OTROS_EMP_RT};
        Set<String> setLabelsRtsEvent = new Set<String>{CIBE_AppConstants.EVENT_CLIENTE_RT};
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
				
				if((setIdsRtsEvent).contains(tNew.RecordTypeId) && (eventOld.ActivityDate != tNew.ActivityDate) && tNew.AV_ExternalID__c != null && (tNew.CSBD_Evento_Estado__c == CIBE_AppConstants.EVENT_STATUS_PENDIENTE)){
					setIdsEvent.add(tNew.AV_ExternalID__c);
				} 
			}
			if(!setIdsEvent.isEmpty()){
				List<AV_HeaderCustomActivity__c> listHeaderTask= new List<AV_HeaderCustomActivity__c>();
				if(
					AV_HeaderCustomActivity__c.SObjectType.getDescribe().isAccessible() &&
					Schema.SObjectType.AV_HeaderCustomActivity__c.fields.AV_ExternalID__c.isAccessible()
				) {
					listHeaderTask = [SELECT id, AV_ExternalID__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c in :setIdsEvent];
				}
				
				if(!listHeaderTask.isEmpty()){
					for(AV_HeaderCustomActivity__c htask : listHeaderTask){
						
						setIdsHeaderEvent.add(htask.Id);
					}
				}
                List<AV_CustomActivityOpportunity__c> listTaskAndOpp = new List<AV_CustomActivityOpportunity__c>();
				if(
					AV_CustomActivityOpportunity__c.SObjectType.getDescribe().isAccessible() &&
					Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Task__c.isAccessible() &&
					Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_ExternalID__c.isAccessible()&&
					Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Opportunity__c.isAccessible()
				) {
					listTaskAndOpp = [SELECT Id, AV_Task__r.AV_ExternalID__c, AV_Opportunity__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c != null AND AV_Task__c in :setIdsHeaderEvent];
				}
				
				if(!listTaskAndOpp.isEmpty()){ 
					for(AV_CustomActivityOpportunity__c taskOpp : listTaskAndOpp){
						setOpp.add(taskOpp.AV_Opportunity__c);
					}
				}
				if(!setOpp.isEmpty()){  
					List<AV_CustomActivityOpportunity__c> listTaskAndOppRelated= new List<AV_CustomActivityOpportunity__c>();
					if(
						AV_CustomActivityOpportunity__c.SObjectType.getDescribe().isAccessible() &&
						Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_ExternalID__c.isAccessible() &&
						Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Opportunity__c.isAccessible()&&
						Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Task__c.isAccessible()
					) {
						listTaskAndOppRelated = [SELECT Id, AV_Task__r.AV_ExternalID__c, AV_Opportunity__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c in :setOpp];
					}
					
					
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
					Set<String> statusTask = new Set<String>{CIBE_AppConstants.TASK_STATUS_PENDIENTE, CIBE_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL};
					Set<String> statusEvent = new Set<String>{CIBE_AppConstants.EVENT_STATUS_PENDIENTE};
					Map<String,Date> mapOppFecha = new Map<String,Date>();

					List<Task> listTaskAndOppRelated= new List<Task>();
					if(
						Task.SObjectType.getDescribe().isAccessible() &&
						Schema.SObjectType.Task.fields.AV_ExternalID__c.isAccessible() &&
						Schema.SObjectType.Task.fields.ActivityDate.isAccessible()
					) {
						listTaskAndOppRelated = [SELECT Id, AV_ExternalID__c, ActivityDate FROM Task WHERE Status IN :statusTask AND RecordtypeId IN :setIdsRtsTask AND AV_ExternalID__c IN :ids AND ActivityDate >= TODAY order by ActivityDate ASC];
					}
					
					
					AV_LogDebug.printLogDebug(methodName, 'listTaskAndOppRelated: '+listTaskAndOppRelated.size());
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
					
					List<Event> listEventAndOppRelated= new List<Event>();
					if(
						Event.SObjectType.getDescribe().isAccessible() &&
						Schema.SObjectType.Event.fields.AV_ExternalID__c.isAccessible() &&
						Schema.SObjectType.Event.fields.ActivityDate.isAccessible()
					) {
						listEventAndOppRelated = [SELECT Id, AV_ExternalID__c, ActivityDate FROM Event WHERE CSBD_Evento_Estado__c IN :statusEvent AND RecordtypeId IN :setIdsRtsEvent AND AV_ExternalID__c IN :ids AND ActivityDate >= TODAY order by ActivityDate ASC limit 1];
					}
					
			
					AV_LogDebug.printLogDebug(methodName, 'listEventAndOppRelated: '+listEventAndOppRelated.size());
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
						for (Id idOpp : mapOppEvent.keySet()){
							if (mapOppFecha.get(idOpp) != null) {
								Opportunity oppUpdate = new Opportunity(Id= idOpp, AV_FechaProximoRecordatorio__c = mapOppFecha.get(idOpp));
								listOppUpdate.add(oppUpdate);
							}	
						}
					}
				}
				if(!listOppUpdate.isEmpty()){
					AV_LogDebug.printLogDebug(methodName, 'Oportunidades: ' + listOppUpdate.size());
					List<Database.SaveResult> listUpdateResult = database.update(listOppUpdate,false);
					CIBE_AppUtilities.displayErrors(methodName,listUpdateResult);
				}
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
					evt.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
				}else{
					evt.AV_OrigenApp__c = CIBE_AppConstants.OUTLOOK_ORIGENAPP;
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
		Set<String> contentOutlook = new Set<String>{'Microsoft Teams', 
													'https://teams.microsoft.com', 'https://lync.lacaixa.com', 
													'https://aka.ms/JoinTeamsMeeting', 'https://pexip.me/teams'};
		
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
	 * @description		 Change owner to SinGestorEap if new owner has not associted contact
	 * @param  listNews  list of new Task records
	 * @param mapOlds map of old Task records
	 */
	public static void changeOwner(List<Event> listNews, Map<Id, Event> mapOlds) {
		
		Set<Id> evtIds = new Set<Id>();
		Set<Id> evtOwners = new Set<Id>();
		List<Event> evtToProcess = new List<Event>();
		Map<Id,Id> mapEvt = new Map<Id,Id>();

		if(mapOlds != null && !mapOlds.isEmpty()){//update event
			for(Event evt: listNews){
				mapEvt.put(evt.id, evt.OwnerId);
				evtIds.add(evt.id);
				if(String.isNotBlank(evt.OwnerId) && evt.OwnerId != mapOlds.get(evt.Id).OwnerId){
					evtToProcess.add(evt);
					evtOwners.add(evt.OwnerId);
				}
			}
		}else{//insert event
			for(Event evt: listNews){
				if(String.isNotBlank(evt.OwnerId)){
					evtToProcess.add(evt);
					evtOwners.add(evt.OwnerId);
				}
			}
		}

		if(!evtToProcess.isEmpty() && !evtOwners.isEmpty()) {
            List<Contact> listCont = new List<Contact>();
            if(
				Contact.SObjectType.getDescribe().isAccessible() &&
				Schema.SObjectType.Contact.fields.lastmodifieddate.isAccessible() &&
				Schema.SObjectType.Contact.fields.CIBE_Sector__c.isAccessible()&&
				Schema.SObjectType.Contact.fields.CIBE_Cartera__c.isAccessible()&&
				Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible()
			) {
				listCont= [SELECT Id, lastmodifieddate,CIBE_Sector__c, CIBE_Cartera__c, AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__c IN :evtOwners];
			}
           

			List<CBK_Activity_Extension__c> listTaskExtension = new List<CBK_Activity_Extension__c>();
			if(CBK_Activity_Extension__c.SObjectType.getDescribe().isAccessible() &&
			Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_Sector__c.isAccessible()&&
			Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_Cartera__c.isAccessible()&&
			Schema.SObjectType.CBK_Activity_Extension__c.fields.AV_ActivityId__c.isAccessible()
			){
				listTaskExtension = [SELECT Id,CIBE_Sector__c,CIBE_Cartera__c,AV_ActivityId__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c IN :evtIds];
			}

            Set<ID> idsContact = new Set<ID>();
            Map<String,Contact> mapUserContact = new Map<String,Contact>();
			List<CBK_Activity_Extension__c> listActExtUpdt = new  List<CBK_Activity_Extension__c>();

            if (!listCont.isEmpty()) {
                for(Contact cnt : listCont){
                    idsContact.add(cnt.AV_UsuarioAsociado__c);
                    mapUserContact.put(cnt.AV_UsuarioAsociado__c,cnt);
                }

                if(!evtIds.isEmpty()) {
                    
                    if(!listTaskExtension.isEmpty()) {
                        for(CBK_Activity_Extension__c cbkActExt : listTaskExtension){                        
                            if(mapEvt.containsKey(cbkActExt.AV_ActivityId__c) && mapUserContact.containsKey(mapEvt.get(cbkActExt.AV_ActivityId__c)) ){
                                cbkActExt.CIBE_Cartera__c = mapUserContact.get(mapEvt.get(cbkActExt.AV_ActivityId__c)).CIBE_Cartera__c;
                                cbkActExt.CIBE_Sector__c = mapUserContact.get(mapEvt.get(cbkActExt.AV_ActivityId__c)).CIBE_Sector__c;
                                listActExtUpdt.add(cbkActExt);
                            }
                        }
                    }
                }
            }
		
			Map<Id,CBK_Activity_Extension__c> mapActExt = new Map<Id,CBK_Activity_Extension__c>();
			for(CBK_Activity_Extension__c actExt: listTaskExtension){
				mapActExt.put(actExt.AV_ActivityId__c,actExt);
			}

			
			List<User> userGcf = new List<User>();
			List<User> ownerWithNoEap = new List<User>();
			if(	User.SObjectType.getDescribe().isAccessible() ) {
				//Invocamos al usuario para owners sin EAP
				userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' LIMIT 1];
				//Retrieve users who are not in contact table 
				ownerWithNoEap = [SELECT ID FROM USER WHERE id NOT IN: idsContact AND id IN :evtOwners];
			}
			
			Set<Id> idOwnerWithNoEap = new Set<Id>();
			if(!ownerWithNoEap.isEmpty()){
				for(User u : ownerWithNoEap){
					idOwnerWithNoEap.add(u.id);
				}
			}

			for(Event evt : evtToProcess){			  
				if(idOwnerWithNoEap.contains(evt.OwnerId)){
					evt.OwnerId= userGcf[0].Id;
					if(mapActExt.containsKey(evt.id)){
						mapActExt.get(evt.id).CIBE_Cartera__c = null;
						mapActExt.get(evt.id).CIBE_Sector__c = null;
						listActExtUpdt.add(mapActExt.get(evt.id));
					}
				}	
			}

			if(!listActExtUpdt.isEmpty()) {
				if(CBK_Activity_Extension__c.sObjectType.getDescribe().isUpdateable() ){
					Database.update(listActExtUpdt, false);
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
				if((setIdsRt).contains(eNew.RecordTypeId) && String.isBlank(eNew.AV_CodigoGestorAsignado__c) 
				&& String.isNotBlank(eNew.OwnerId)){
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
			List<Contact> listEmployees= new List<Contact>();
			if(
				Contact.SObjectType.getDescribe().isAccessible() &&
				Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible() &&
				Schema.SObjectType.Contact.fields.CC_Matricula__c.isAccessible()
			) {
				listEmployees= [SELECT Id, CC_Matricula__c, AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__c IN :listIdOwner];
			}

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
						!CIBE_AppConstants.OUTLOOK_ORIGENAPP.equalsIgnoreCase(ev.AV_OrigenApp__c) && 
					( (mapOlds.get(ev.Id).Description != ev.Description) ||
					(String.isNotBlank(ev.Subject) && mapOlds.get(ev.Id).Subject != ev.Subject) ||
					(String.isNotBlank(ev.Location) && mapOlds.get(ev.Id).Location != ev.Location))){
					listToProcess.add(ev);
				}
			}
		} else {
			for(Event ev : listNews) {
				if((setIdsRt).contains(ev.RecordTypeId) && !CIBE_AppConstants.OUTLOOK_ORIGENAPP.equalsIgnoreCase(ev.AV_OrigenApp__c) 
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
	 * @description		    Procces owners of Events where field codigoGestor has changed
	 * @param  lstEvents    list of new Events records
	 * @param  mapOlds      map of old account records
	 */
	public static void processOwnerGestores(List<Event> lstEvents, Map<Id, Event> mapOlds){
		
		Set<Id> setIdsRt = getAllRT();
		List<Event> lstEventsCodigoGestores = new List<Event>();
		List<Event> lstEventsCodigoGestoresSinEap = new List<Event>();
		Set<String> codigosGestores = new Set<String>();
		Map<Id,String> mapEventUser = new Map<Id,String>();
		Map<String,String> mapExternalIdUser = new Map<String,String>();
		List<String> listExternalId = new List<String>();
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
		User userGcf= new User();
		if(	User.SObjectType.getDescribe().isAccessible() ) {
			userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' LIMIT 1];
		}

		if(lstEventsCodigoGestoresSinEap!=null && !lstEventsCodigoGestoresSinEap.isEmpty()) {
	
			for(Event a : lstEventsCodigoGestoresSinEap){
				a.OwnerId = userGcf.Id;
			}
		}

		if(codigosGestores!=null && !codigosGestores.isEmpty()) {
			Map<String, Id> mapGestoresUsers = new Map<String, Id>();
			List<User> listGestoresUsers= new List<User>();

			if(
				User.SObjectType.getDescribe().isAccessible() &&
				Schema.SObjectType.User.fields.AV_ExternalID__c.isAccessible()
			) {
				listGestoresUsers = [SELECT Id,AV_ExternalID__c FROM User WHERE AV_ExternalID__c IN :codigosGestores AND IsActive = true];
			}
			
			if(listGestoresUsers.size() > 0 && listGestoresUsers != null){
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

		if (!listNews.isEmpty()) {
			for (Event e : listNews) {
				ownersIds.add(e.OwnerId);
			}

			if(	
				User.SObjectType.getDescribe().isAccessible() &&
				Schema.SObjectType.User.fields.AV_NumeroOficinaEmpresa__c.isAccessible()) {
				ownersInfo = [SELECT Id, AV_NumeroOficinaEmpresa__c FROM User WHERE Id IN :ownersIds];
			}

			owners.putAll(ownersInfo);
			if (isUpdate) {
				if(mapOlds != null || !mapOlds.isEmpty()) {
					for (Event e : listNews) {
						if (eventTypes.contains(e.AV_Tipo__c)) {
							// if branchPhysicalMeet has value and it has changed
							if (String.isNotBlank(e.AV_BranchPhysicalMeet__c) && !e.AV_BranchPhysicalMeet__c.equals(mapOlds.get(e.Id).AV_BranchPhysicalMeet__c)) {
								e.Location = e.AV_BranchPhysicalMeet__c;
							} else {
								e.Location = mapOlds.get(e.Id).AV_BranchPhysicalMeet__c;
							}
						}
					}
				}
			} else {
				for (Event e : listNews) {
					if (eventTypes.contains(e.AV_Tipo__c)) {
						e.Location = String.isNotBlank(e.AV_BranchPhysicalMeet__c) ? e.AV_BranchPhysicalMeet__c : null;
						e.AV_Center__c = String.isNotBlank(owners.get(e.OwnerId).AV_NumeroOficinaEmpresa__c) ? getOfficeNumber(owners.get(e.OwnerId).AV_NumeroOficinaEmpresa__c) : e.AV_Center__c;
					}
				}
			}
		}
	}

	public static void updateCentro(List<Event> listData, Map<Id, Event> mapOldObj){
		
		Map<Id,String> mapOwnerOffice = new Map<Id,String>();
		Set<Id> owners = new Set<Id>();
		List<Event> eventsToProcess = new List<Event>();
		String offiNumber='';

		if(mapOldObj != null && !mapOldObj.isEmpty()){
			for(Event e : listData){
				if(e.OwnerId != mapOldObj.get(e.Id).OwnerId){
					owners.add(e.OwnerId);
					eventsToProcess.add(e);				
				}			
			}
		}else{
			for(Event e : listData){
				owners.add(e.OwnerId);
				eventsToProcess.add(e);				
			}
		}

		List<User> ownerOffice = new List<User>();
		if(
			USER.SObjectType.getDescribe().isAccessible() &&
			Schema.SObjectType.USER.fields.AV_NumeroOficinaEmpresa__c.isAccessible()
		) {
			ownerOffice = [SELECT ID,AV_NumeroOficinaEmpresa__c FROM USER WHERE ID IN :owners];
		}
		List<User> userGFC= new List<User>();
		if(	User.SObjectType.getDescribe().isAccessible() ) {
			userGFC = [SELECT ID FROM USER WHERE Alias = 'AV-TF9' and IsActive = TRUE LIMIT 1];
		}

		for(User owner : ownerOffice){
			mapOwnerOffice.put(owner.Id,owner.AV_NumeroOficinaEmpresa__c);
		}
		for(Event e : eventsToProcess){	
			if(e.OwnerId != userGFC[0].id) {
				offiNumber= mapOwnerOffice.get(e.OwnerId);
				e.AV_Center__C = (offiNumber != null)?offiNumber.substring(offiNumber.length()-5):null;
			}	
		}
	}
	/**
	 * @description		Gets the 5 last characters of the office number.
	 * 					I.e. pass 001-00123 and get 00123
	 * @param num		Office
	 */
	public static String getOfficeNumber(String num) {
		
		if (String.isNotBlank(num)) {
			if (num.contains('-')){
				return num.mid(4, 5);
			}else{
				return num;
			}
		}
		return null;
	}

	/**
	* @description    Updates opp's confidentiality according to its related account.
	*/
	//public static void setConfidentiality(List<Event> listNew, Boolean isInsert) {
	public static void setConfidentiality(List<Event> listNew, Boolean isInsert){

		Set<Id> cliIds = new Set<Id>();
		Map<Id, Boolean> cliConfidentiality = new Map<Id, Boolean>();
		Map<Id, Boolean> cliEmployee = new Map<Id, Boolean>();
		for (Event evt : listNew) {
			/*if(evt.AccountId!=null){
				cliIds.add(evt.AccountId);
			}else{
				cliIds.add(evt.whatId);
			}*/
			cliIds.add(evt.whatId);

		}
		List<Account> clients= new List<Account>();

		if(
			Account.SObjectType.getDescribe().isAccessible() &&
			Schema.SObjectType.Account.fields.AV_Confidencial__c.isAccessible() &&
			Schema.SObjectType.Account.fields.AV_Empleado__c.isAccessible()
		) {
			clients = [SELECT Id, AV_Confidencial__c, AV_Empleado__c FROM Account WHERE Id IN :cliIds];
		}

		if (!clients.isEmpty()) {
			for (Account client : clients) {
				if(client.AV_Confidencial__c){
					cliConfidentiality.put(client.Id, client.AV_Confidencial__c);
					cliEmployee.put(client.Id, client.AV_Empleado__c);
				}
				/*if(!String.IsBlank(client.AV_Empleado__c)){
					cliEmployee.put(client.Id, client.AV_Empleado__c);
				}*/
				
			}
			if (isInsert) {
				for (Event evt : listNew) {
					if(evt.whatId!=null && cliConfidentiality.containsKey(evt.whatId)){
						evt.CIBE_Confidential__c = cliConfidentiality.get(evt.whatId);
					}
					/*if(evt.AccountId!=null && cliEmployee.containsKey(evt.AccountId)){
						evt.AV_CodigoGestorAsignado__c = cliEmployee.get(evt.AccountId).AV_Empleado__c;
					}*/
				}
			} else { 
				for (Event evt : listNew) {
					if(evt.whatId!=null){
						if ((cliConfidentiality.containsKey(evt.whatId) && evt.CIBE_Confidential__c != cliConfidentiality.get(evt.whatId)) /*||
						(cliEmployee.containsKey(evt.AccountId) && evt.AV_CodigoGestorAsignado__c != cliEmployee.get(evt.AccountId).)*/) {
							evt.CIBE_Confidential__c = cliConfidentiality.get(evt.whatId);
							//evt.AV_CodigoGestorAsignado__c = cliEmployee.get(evt.AccountId).AV_Empleado__c;
						}
					}
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
			if((setRtCliente).contains(evt.RecordTypeId) && evt.AV_Tipo__c == CIBE_AppConstants.VIDEOLLAMADA_TIPO) {
				listToProcess.add(evt);
				listIdUserCreatedEvent.add(evt.CreatedById);
			}
		}
		if (listToProcess != null && !listToProcess.isEmpty()) {
			List<User> listEmp  = new List<User>();
			if(
				User.SObjectType.getDescribe().isAccessible() &&
				Schema.SObjectType.User.fields.AV_ExternalID__c.isAccessible() &&
				Schema.SObjectType.User.fields.AV_AzureId__c.isAccessible() &&
				Schema.SObjectType.User.fields.FederationIdentifier.isAccessible()
			) {
				listEmp  = [SELECT Id, AV_ExternalID__c, AV_AzureId__c, FederationIdentifier FROM User WHERE Id IN :listIdUserCreatedEvent LIMIT 1];
			}
			if (listEmp != null && !listEmp.isEmpty()) {
				for(User emp : listEmp) { 
					mapUser.put(emp.Id,emp);
				}
			}
			if (mapUser != null) {
				for(Event evt : listToProcess) {
					String jsonString = JSON.serialize(evt);
                    if(!Test.isRunningTest()){
						System.enqueueJob(new CIBE_TeamsGCFQueueable(jsonString, evt.Subject, evt.EndDateTime, evt.StartDateTime, evt.AV_Task__c, mapUser.get(evt.CreatedById)?.FederationIdentifier , mapUser.get(evt.CreatedById)?.AV_AzureId__c));
                    }
                }
			}
		}
		
	}


	/**
	 @description     	Delete Object related with Event
	 * @param  deleteEventList  list of delete Events records
	 */
	public static void deleteRecordsRelatedWithEvent(List<Event> deleteEventList){
		Map<Id, Event> mapEvent = new Map<Id, Event>(deleteEventList);
		List<AV_ManagementHistory__c> managementHistoryList = [SELECT Id FROM AV_ManagementHistory__c WHERE AV_ActivityId__c In :mapEvent.keySet()];
		List<CBK_Activity_Extension__c> eventExtensionList = [SELECT Id FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c In :mapEvent.keySet()];

		Set<String> listExternalIdsHeaderEvent = new Set<String>();
		Set<String> listIdsHeaderEvent = new Set<String>();
        for (Event e : deleteEventList){
            if (String.isNotBlank(e.AV_Task__c)){
                listIdsHeaderEvent.add(e.AV_Task__c);
            }
            else if (String.isNotBlank(e.AV_ExternalID__c)){
                listExternalIdsHeaderEvent.add(e.AV_ExternalID__c);
            }
        }
		List<AV_CustomActivityOpportunity__c> eventOppList = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE (AV_Task__c IN :listIdsHeaderEvent OR AV_Task__r.AV_ExternalID__c IN :listExternalIdsHeaderEvent) OR (AV_Task__c IN :listIdsHeaderEvent AND AV_Task__r.AV_ExternalID__c IN :listExternalIdsHeaderEvent)];
		List<AV_HeaderCustomActivity__c> listHeaderEvent = [SELECT Id FROM AV_HeaderCustomActivity__c WHERE (Id IN :listIdsHeaderEvent OR AV_ExternalID__c IN :listExternalIdsHeaderEvent) OR (Id IN :listIdsHeaderEvent AND AV_ExternalID__c IN :listExternalIdsHeaderEvent)];
        if(managementHistoryList.size() > 0 || eventExtensionList.size() > 0 || eventOppList.size() > 0 || listHeaderEvent.size() > 0) {
            System.enqueueJob(new CIBE_DeleteRelatedEventQueueable(managementHistoryList,eventExtensionList,eventOppList,listHeaderEvent));
		}
	}

	public static void updateAccessList(List<Event> eventNew, Map<Id, Event> mapEventOld){

		Map<String, Event> mapEventHCA = new Map<String, Event>();
		Map<String, Event> mapEventHCAOld = new Map<String, Event>();

		List<EventRelation> attendees = new List<EventRelation>();
		if(mapEventOld != null){
			for(Event e : eventNew){
				if(e.OwnerId != mapEventOld.get(e.Id).OwnerId){
					mapEventHCA.put(e.AV_Task__c,e);
					mapEventHCAOld.put(e.AV_Task__c,mapEventOld.get(e.Id));
				}
			}
			System.debug(mapEventHCA);
			System.debug(mapEventHCAOld);


			if(mapEventHCA != null && mapEventHCAOld != null){

				List<AV_HeaderCustomActivity__c> header = new List<AV_HeaderCustomActivity__c>();
				List<AV_HeaderCustomActivity__c> headerUp = new List<AV_HeaderCustomActivity__c>();
				if(AV_HeaderCustomActivity__c.SObjectType.getDescribe().isAccessible()) {
					header = [SELECT Id, CIBE_ConfidentialEvent__c FROM AV_HeaderCustomActivity__c WHERE Id IN :mapEventHCA.keySet()];
				}

				if(!header.isEmpty()) {
					for(AV_HeaderCustomActivity__c h : header){
						if(mapEventHCA.containsKey(h.id)){
							h.CIBE_ConfidentialEvent__c += mapEventHCA.get(h.id).OwnerId +',';
						}
						if(mapEventHCAOld.containsKey(h.id) && h.CIBE_ConfidentialEvent__c.contains(mapEventHCAOld.get(h.id).OwnerId)){
							h.CIBE_ConfidentialEvent__c = h.CIBE_ConfidentialEvent__c.remove(mapEventHCAOld.get(h.id).OwnerId)+',';
						}
						headerUp.add(h);
					}
					update headerUp;
				}
			}
		}
	}
}