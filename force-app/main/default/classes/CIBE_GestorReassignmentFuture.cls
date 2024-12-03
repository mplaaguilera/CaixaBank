/**********************************************************************************************************************
 Name:	  CIBE_GestorReassignmentFuture
 Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Future para asociar tareas, oportunidades y eventos de un cliente a un gestor.
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				  DATE				Description
	1.0			App FSC			Mikel Lezama          08/11/2021	    Init version
***********************************************************************************************************************/
public with sharing class CIBE_GestorReassignmentFuture {

    private static CIBE_AppUtilities.SearchRT rtAlertaComerciaEMP 	= new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_EMP_RT);
    private static CIBE_AppUtilities.SearchRT rtOnBoardingEMP   	= new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ONBOARDING_EMP_RT);
    private static CIBE_AppUtilities.SearchRT rtPriorizadosEMP 	    = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_PRIORIZADOS_EMP_RT);
    private static CIBE_AppUtilities.SearchRT rtOtrosEMP 	        = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
    private static CIBE_AppUtilities.SearchRT rtAvisosEMP 	        = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_AVISOS_EMP_RT);
    private static CIBE_AppUtilities.SearchRT rtExpClienteEMP 	    = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT);

    private static CIBE_AppUtilities.SearchRT rtAlertaComerciaCIB 	= new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT);
    private static CIBE_AppUtilities.SearchRT rtOnBoardingCIB   	= new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ONBOARDING_CIB_RT);
    private static CIBE_AppUtilities.SearchRT rtPriorizadosCIB 	    = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_PRIORIZADOS_CIB_RT);
    private static CIBE_AppUtilities.SearchRT rtOtrosCIB 	        = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT);
    private static CIBE_AppUtilities.SearchRT rtAvisosCIB 	        = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_AVISOS_CIB_RT);
    private static CIBE_AppUtilities.SearchRT rtExpClienteCIB   	= new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT);

    private static CIBE_AppUtilities.SearchRT rtIniciativaEMP 	    = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
    private static CIBE_AppUtilities.SearchRT rtAccionEMO 	        = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ACCIONEMP_RT);
    private static CIBE_AppUtilities.SearchRT rtAlertaEMP 	        = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ALERTAEMP_RT);
    private static CIBE_AppUtilities.SearchRT rtSugerenciaEMP    	= new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_SUGERENCIAEMP_RT);

    private static CIBE_AppUtilities.SearchRT rtIniciativaCIB   	= new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
    private static CIBE_AppUtilities.SearchRT rtAccionCIB           = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ACCIONCIB_RT);
    private static CIBE_AppUtilities.SearchRT rtAlertaCIB 	        = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ALERTACIB_RT);
    private static CIBE_AppUtilities.SearchRT rtSugerenciaCIB       = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_SUGERENCIACIB_RT);

    private static CIBE_AppUtilities.SearchRT rtEventoCliente       = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);

	/**
	 * @description		 	Get all the ID's of the Task RTs
	 */
	public static Set<Id> getAllTaskRT(){
		Set<CIBE_AppUtilities.SearchRT> setLabelsRt = new Set<CIBE_AppUtilities.SearchRT>{rtAlertaComerciaCIB, rtAlertaComerciaEMP, rtOnBoardingCIB, rtOnBoardingEMP, rtPriorizadosCIB, rtPriorizadosEMP, rtOtrosCIB, rtOtrosEMP, rtAvisosCIB, rtAvisosEMP, rtExpClienteCIB, rtExpClienteEMP};
		return CIBE_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
	}  

    /**
	 * @description		 	Get all the ID's of the Opportunity RTs
	 */
	public static Set<Id> getAllOpportunityRT(){
		Set<CIBE_AppUtilities.SearchRT> setLabelsRt = new Set<CIBE_AppUtilities.SearchRT>{rtIniciativaCIB, rtIniciativaEMP, rtAccionCIB, rtAccionEMO, rtAlertaCIB, rtAlertaEMP, rtSugerenciaCIB, rtSugerenciaEMP};
		return CIBE_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
	}  

    /**
	 * @description		 	Get all the ID's of the Event RTs
	 */
	public static Set<Id> getAllEventRT(){
		Set<CIBE_AppUtilities.SearchRT> setLabelsRt = new Set<CIBE_AppUtilities.SearchRT>{rtEventoCliente};
		return CIBE_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
	}  
    
    
	/**
	 * @description:	update the owners of the tasks, events and opps related with the client's
	 * @param serializedClientsList		list of the clients
	 * @param eapGestorsIds				list of the employees ID's
	 */
	public static ListsOppTaskEvent processRelatedToAccount(String serializedClientsList, Set<Id> eapGestorsIds, String serializedClientsListOld, Set<Id> eapGestorsIdsOld, Boolean callQueueable) {
		String methodName = 'processRelatedToAccount';
		List<Account> lstClientes = (List<Account>)JSON.deserialize(serializedClientsList, List<Account>.class);
		Map<Id,String> mapEAPGestorUser = new Map<Id,String>();    
		Map<Id,Boolean> mapEAPGestorIntouchOld = new Map<Id,Boolean>();
		Map<Id,Boolean> mapEAPGestorIntouch = new Map<Id,Boolean>();
		RecordType eventClientRT = CIBE_AppUtilities.getRecordType('Event','CIBE_EventoCliente');

		List<Contact> listEmployees = new List<Contact>();
		if(Contact.SObjectType.getDescribe().isAccessible()) {
			listEmployees = [SELECT Id, CC_Matricula__c, AV_UsuarioAsociado__c, AV_EmpleadoIntouch__c
							FROM Contact
							WHERE 	Id IN :eapGestorsIds 
									AND AV_UsuarioAsociado__r.IsActive = true];      
		}
		
		if(listEmployees != null && !listEmployees.isEmpty()) {
			for(Contact c : listEmployees) {
				mapEAPGestorUser.put(c.Id, c.CC_Matricula__c);
				mapEAPGestorIntouch.put(c.Id,c.AV_EmpleadoIntouch__c);//PROV
			}
		}

		List<Account> lstClientesOld = (List<Account>)JSON.deserialize(serializedClientsListOld, List<Account>.class);
		Map<Id,Account> mapOld = new Map<Id,Account>();
		for (Account a : lstClientesOld) {
			mapOld.put(a.Id,a);
		}
		Map<Id,String> mapEAPGestorUserOld = new Map<Id,String>(); 

		List<Contact> listEmployeesOld = new List<Contact>();
		if(Contact.SObjectType.getDescribe().isAccessible()) {
			listEmployeesOld = [SELECT Id, CC_Matricula__c, AV_UsuarioAsociado__c, AV_EmpleadoIntouch__c
								FROM Contact
								WHERE 	Id IN :eapGestorsIdsOld 
										AND AV_UsuarioAsociado__r.IsActive = true];               
		}
		
		if(listEmployeesOld != null && !listEmployeesOld.isEmpty()) {
			for(Contact c : listEmployeesOld) {
				mapEAPGestorUserOld.put(c.Id, c.CC_Matricula__c);
				mapEAPGestorIntouchOld.put(c.Id,c.AV_EmpleadoIntouch__c);//prov

			}
		}

		// Me guardo las Ids de los clientes a los que se les ha cambiado el EAPGestor
		Set<Id> setClientesIds =  new Set<Id>();
		for (Account a : lstClientes) {
			setClientesIds.add(a.Id);
		}

		//Get list of tasks, events and opps
		Map<Id, List<Task>> mapTasks = getMapTaskToUpdate(setClientesIds);
		Map<Id, List<Event>> mapEvents = getMapEventToUpdate(setClientesIds);
		Map<Id, List<Opportunity>> mapOpps = getMapOppToUpdate(setClientesIds);

		List<Task> listTaskToUpdate = new List<Task>();
		List<Event> listEventToUpdate = new List<Event>();
		List<Opportunity> listOppToUpdate = new List<Opportunity>();
		// Update the employee code for: task, event and opportunity
		for (Account acc : lstClientes) {
			if (mapEAPGestorUser.containsKey(acc.AV_EAPGestor__c)) {
				//Fill the list of the tasks to update
				if (mapTasks!=null && !mapTasks.isEmpty() && mapTasks.containsKey(acc.Id)){
					for (Task t : mapTasks.get(acc.Id)) {
						if (mapOld.get(acc.Id) == null) {
							t.AV_CodigoGestorAsignado__c = mapEAPGestorUser.get(acc.AV_EAPGestor__c);

							listTaskToUpdate.add(t);
						} else {
							if (mapEAPGestorUserOld.get(mapOld.get(acc.Id).AV_EAPGestor__c) == t.AV_CodigoGestorAsignado__c) {
								t.AV_CodigoGestorAsignado__c = mapEAPGestorUser.get(acc.AV_EAPGestor__c);

								listTaskToUpdate.add(t);
							}                           
						}
					}
				}
				//Fill the list of the events to update
				if (mapEvents!=null && !mapEvents.isEmpty() && mapEvents.containsKey(acc.Id)){
					for (Event e : mapEvents.get(acc.Id)) {
						if (mapOld.get(acc.Id) == null) {
							e.AV_CodigoGestorAsignado__c = mapEAPGestorUser.get(acc.AV_EAPGestor__c);
							listEventToUpdate.add(e);
						} else {
							if (mapEAPGestorUserOld.get(mapOld.get(acc.Id).AV_EAPGestor__c) == e.AV_CodigoGestorAsignado__c) {
								if(e.RecordTypeId != eventClientRT.Id){
									e.AV_CodigoGestorAsignado__c = mapEAPGestorUser.get(acc.AV_EAPGestor__c);
									listEventToUpdate.add(e);
								}else{
									if(!(!mapEAPGestorIntouchOld.get(mapOld.get(acc.Id).AV_EAPGestor__c) && mapEAPGestorIntouch.get(acc.AV_EAPGestor__c) )){
										e.AV_CodigoGestorAsignado__c = mapEAPGestorUser.get(acc.AV_EAPGestor__c);
										listEventToUpdate.add(e);
									}
								}
							}
						}
					}
				}
				
				//Fill the list of the opps to update
				if (mapOpps!=null && !mapOpps.isEmpty() && mapOpps.containsKey(acc.Id)){
					for (Opportunity o : mapOpps.get(acc.Id)) {
						if (mapOld.get(acc.Id) == null) {
							o.AV_Gestor__c = acc.AV_EAPGestor__c;
							listOppToUpdate.add(o);
						} else {
							if (mapOld.get(acc.Id).AV_EAPGestor__c == o.AV_Gestor__c) {
								o.AV_Gestor__c = acc.AV_EAPGestor__c;
								listOppToUpdate.add(o);
							}
						}
					}
				}
			} else {
				if (mapTasks!=null && !mapTasks.isEmpty() && mapTasks.containsKey(acc.Id)){
					for (Task t : mapTasks.get(acc.Id)) {
						if (mapEAPGestorUserOld.get(mapOld.get(acc.Id).AV_EAPGestor__c) == t.AV_CodigoGestorAsignado__c) {
							t.AV_CodigoGestorAsignado__c = null;
							listTaskToUpdate.add(t);
						}
					}
				}
				
				//Fill the list of the events to update
				if (mapEvents!=null && !mapEvents.isEmpty() && mapEvents.containsKey(acc.Id)){
					for (Event e : mapEvents.get(acc.Id)) {
						if (mapEAPGestorUserOld.get(mapOld.get(acc.Id).AV_EAPGestor__c) == e.AV_CodigoGestorAsignado__c) {
							e.AV_CodigoGestorAsignado__c = null;
							listEventToUpdate.add(e);
						}
					}
				}
				
				//Fill the list of the opps to update
				if (mapOpps!=null && !mapOpps.isEmpty() && mapOpps.containsKey(acc.Id)){
					for (Opportunity o : mapOpps.get(acc.Id)) {
						if (mapOld.get(acc.Id).AV_EAPGestor__c == o.AV_Gestor__c) {
							o.AV_Gestor__c = null;
							listOppToUpdate.add(o);
						}
					}
				}
			}
		}

		if (callQueueable != null && callQueueable) {
			if (listOppToUpdate != null && !listOppToUpdate.isEmpty()) {
				System.enqueueJob(new CIBE_GestorReassignmentQueueable(listOppToUpdate, listTaskToUpdate, listEventToUpdate));
			} else if (listTaskToUpdate != null && !listTaskToUpdate.isEmpty()) {
				System.enqueueJob(new CIBE_GestorReassignmentTaskQueueable(listTaskToUpdate, listEventToUpdate));
			} else if (listEventToUpdate != null && !listEventToUpdate.isEmpty()) {
				System.enqueueJob(new CIBE_GestorReassignmentEventsQueueable(listEventToUpdate));
			}
		}

		return new ListsOppTaskEvent(listOppToUpdate,listTaskToUpdate, listEventToUpdate);		
	}

	public class ListsOppTaskEvent {
		public List<Opportunity> listOpportunity;
		public List<Task> listTask;
		public List<Event> listEvent;

		public ListsOppTaskEvent(List<Opportunity> listOpportunity, List<Task> listTask, List<Event> listEvent) {
			this.listOpportunity = listOpportunity;
			this.listTask = listTask;
			this.listEvent = listEvent;
		}
	}

	/**
	 * @description:	Get the list of the tasks to update of the client
	 * @param setClientesIds	client id's to update
	 */
    
	private static Map<Id, List<Task>> getMapTaskToUpdate(Set<Id> setClientesIds) {
		Map<Id, List<Task>> mapTasks = new Map<Id, List<Task>>();
		if(setClientesIds != null && !setClientesIds.isEmpty() && Task.SObjectType.getDescribe().isAccessible()) {
			Set<String> setStatus = new Set<String>{'Open','Pendiente no localizado','Pendiente'};
			List<Task> listTareasAsociadas = [	SELECT AccountId,AV_CodigoGestorAsignado__c, Subject 
												FROM Task 
												WHERE 	AccountId IN :setClientesIds 
														AND RecordTypeId IN :getAllTaskRT() 
														AND Status IN :setStatus];
			
			for(Task t : listTareasAsociadas) {
				List<Task> listTasks = new List<Task>();
				if(mapTasks.containsKey(t.AccountId)){
					if(!listTasks.contains(t)){listTasks.add(t);}

					listTasks.addAll(mapTasks.get(t.AccountId));
					mapTasks.put(t.AccountId, listTasks);
				}else{
					if(!listTasks.contains(t)){listTasks.add(t);}
					mapTasks.put(t.AccountId, listTasks);
				}
			}
		}
		return mapTasks;
	}
	
	/**
	 * @description:	Get the list of the events to update of the client
	 * @param setClientesIds	client id's to update
	 */ 
	private static Map<Id, List<Event>> getMapEventToUpdate(Set<Id> setClientesIds) {
		Map<Id, List<Event>> mapEvents = new Map<Id, List<Event>>();
		if(setClientesIds != null && !setClientesIds.isEmpty() && Event.SObjectType.getDescribe().isAccessible()) {
			Set<String> setStatus = new Set<String>{'Pendiente'};
			List<Event> listEventosAsociados = [SELECT AccountId,AV_CodigoGestorAsignado__c,RecordTypeId, Subject
												FROM Event 
												WHERE 	AccountId IN :setClientesIds
														AND RecordTypeId IN :getAllEventRT()
														AND CSBD_Evento_Estado__c IN :setStatus 
														AND StartDateTime > :System.now()
														AND isRecurrence = false
														AND isRecurrence2 = false];

			for(Event e : listEventosAsociados) {
				List<Event> listEvents = new List<Event>();
				if(mapEvents.containsKey(e.AccountId)){
					if(!listEvents.contains(e)){listEvents.add(e);}
					listEvents.addAll(mapEvents.get(e.AccountId));
					mapEvents.put(e.AccountId, listEvents);
				}else{
					if(!listEvents.contains(e)){listEvents.add(e);}
					mapEvents.put(e.AccountId, listEvents);
				} 
			}
		}
		return mapEvents;
	}
	
	/**
	 * @description:	Get the list of the opps to update of the client
	 * @param setClientesIds	client id's to update
	 */
	private static Map<Id,List<Opportunity>> getMapOppToUpdate(Set<Id> setClientesIds) {
		Map<Id,List<Opportunity>> mapOpps = new Map<Id,List<Opportunity>>();
		if(setClientesIds != null && !setClientesIds.isEmpty() && Opportunity.SObjectType.getDescribe().isAccessible()) {
			Set<String> setStages = new Set<String>{'Potencial', 'CIBE_Pendiente_Firma', 'En curso'};
			List<Opportunity> listOportunidadesAsociadas = [SELECT AccountId,AV_Gestor__c,Name,AV_Gestor__r.name 
															FROM Opportunity 
															WHERE 	AccountId IN :setClientesIds 
																	AND RecordTypeId IN :getAllOpportunityRT()
																	AND StageName IN :setStages];
			
			for(Opportunity o : listOportunidadesAsociadas) {
				List<Opportunity> listOpps = new List<Opportunity>();
				if(mapOpps.containsKey(o.AccountId)){
					listOpps.addAll(mapOpps.get(o.AccountId));
					if(!listOpps.contains(o)){listOpps.add(o);}
					mapOpps.put(o.AccountId, listOpps);
				}else{
					if(!listOpps.contains(o)){listOpps.add(o);}
					mapOpps.put(o.AccountId, listOpps);
				} 
			}
		}
		return mapOpps;
	}

}