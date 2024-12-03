/**********************************************************************************************************************
 Name:	  AV_GestorReassignmentFuture
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Proceso Future para asociar tareas, oportunidades y eventos de un cliente a un gestor.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Víctor Santiago		29/01/2021			Init version
	1.1			Fix Bugs		David Rufo			09/03/2021			Fix: more debug + nullpointer
	1.2			Fix Bugs		David Rufo			31/05/2021			Fix: possible nullpointer to retrieve map data from account
	1.4			DE46491/DE46686	Sandra Gómez		02/06/2021			Change method processRelatedToAccount and getMapEventToUpdate
	1.5			DE52465			Sandra Gómez		30/09/2021			Refactor
	1.6         DE46491         Daniel Rodriguez    14/12/2021          Fix: do not update Onboarding Task when EAP/Gestor changes
	1.7			Fix				Sandra Gómez		04/04/2022			Change to Queueable
	1.8			US534621		Vladislav Lityagin	20/02/2023			Modified getMapOppToUpdate adding new RT CallMe and getMapEventToUpdate adding RT EventosConClientes
	1.9			Fix-US534621	Sandra Gómez		29/03/2023			Fix RT Propuesta and add AV_AppConstants
	2.0			US603731		Sandra Gómez		22/05/2022			New parameter in method processRelatedToAccount callQueueable and new estructure ListsOppTaskEvent

***********************************************************************************************************************/
public with sharing class AV_GestorReassignmentFuture {
	
	private static AV_AppUtilities.SearchRT rtIniciativa 	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
	private static AV_AppUtilities.SearchRT rtAlertaComercial	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKALERTACOM_RT);
	private static AV_AppUtilities.SearchRT rtAvisos	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKAVISOS_RT);
	private static AV_AppUtilities.SearchRT rtContactosGCF	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKCONTACTGCF_RT);
	private static AV_AppUtilities.SearchRT rtExpCliente	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKEXPCLIENT_RT);
	private static AV_AppUtilities.SearchRT rtPriorizador	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKPRIORIZADOR_RT);
	private static AV_AppUtilities.SearchRT rtCPendiente	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKCPENDIENTE_RT);

	/**
	 * @description		 	Get all the ID's of the RT
	 */
	public static Set<Id> getAllRT(){
		Set<AV_AppUtilities.SearchRT> setLabelsRt = new Set<AV_AppUtilities.SearchRT>{rtIniciativa, rtAlertaComercial,rtAvisos,rtContactosGCF,rtExpCliente,rtPriorizador,rtCPendiente};
		return AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
	}  
	
	/**
	 * @description:	update the owners of the tasks, events and opps related with the client's
	 * @param serializedClientsList		list of the clients
	 * @param eapGestorsIds				list of the employees ID's
	 */
	public static AV_GestorReassignmentFuture.ListsOppTaskEvent processRelatedToAccount(String serializedClientsList, Set<Id> eapGestorsIds, String serializedClientsListOld, Set<Id> eapGestorsIdsOld, Boolean callQueueable) {
		String methodName = 'processRelatedToAccount';
		List<Account> lstClientes = (List<Account>)JSON.deserialize(serializedClientsList, List<Account>.class);
		Map<Id,String> mapEAPGestorUser = new Map<Id,String>();
		Map<Id,Boolean> mapEAPGestorIntouchOld = new Map<Id,Boolean>();  
		Map<Id,Boolean> mapEAPGestorIntouch = new Map<Id,Boolean>();
		RecordType eventClientRT = AV_AppUtilities.getRecordType('Event','AV_EventosConCliente');
		List<Contact> listEmployees= [Select Id, CC_Matricula__c, AV_UsuarioAsociado__c,AV_EmpleadoIntouch__c From Contact Where Id in :eapGestorsIds and AV_UsuarioAsociado__r.IsActive = true];      		
		AV_LogDebug.printLogDebug(methodName, 'listEmployees: ' + listEmployees);
		AV_LogDebug.printLogDebug(methodName, 'eapGestorsIds: ' + eapGestorsIds);
		if(listEmployees != null && !listEmployees.isEmpty()){
			for(Contact c : listEmployees){
				mapEAPGestorUser.put(c.Id, c.CC_Matricula__c);
				mapEAPGestorIntouch.put(c.Id,c.AV_EmpleadoIntouch__c);
			}
		}
		List<Account> lstClientesOld = (List<Account>)JSON.deserialize(serializedClientsListOld, List<Account>.class);
		Map<Id,Account> mapOld = new Map<Id,Account>();
		for (Account a : lstClientesOld) {
			mapOld.put(a.Id,a);
		}
		Map<Id,String> mapEAPGestorUserOld = new Map<Id,String>(); 
		List<Contact> listEmployeesOld= [Select Id, CC_Matricula__c, AV_UsuarioAsociado__c,AV_EmpleadoIntouch__c From Contact Where Id in :eapGestorsIdsOld and AV_UsuarioAsociado__r.IsActive = true];               
		AV_LogDebug.printLogDebug(methodName, 'listEmployeesOld: ' + listEmployeesOld);
		AV_LogDebug.printLogDebug(methodName, 'eapGestorsIdsOld: ' + eapGestorsIdsOld);
		if(listEmployeesOld != null && !listEmployeesOld.isEmpty()){
			for(Contact c : listEmployeesOld){
				mapEAPGestorUserOld.put(c.Id, c.CC_Matricula__c);
				mapEAPGestorIntouchOld.put(c.Id,c.AV_EmpleadoIntouch__c);

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
				if (mapOpps!=null && !mapOpps.isEmpty() && mapOpps.containsKey(acc.Id)) {
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
			if (listOppToUpdate != null && !listOppToUpdate.isEmpty()){
				AV_LogDebug.printLogDebug(methodName, 'listOppToUpdate: ' + listOppToUpdate.size());
				AV_LogDebug.printLogDebug(methodName, 'listTaskToUpdate: ' + listTaskToUpdate.size());
				AV_LogDebug.printLogDebug(methodName, 'listEventToUpdate: ' + listEventToUpdate.size());
				System.enqueueJob(new AV_GestorReassignmentQueueable(listOppToUpdate,listTaskToUpdate, listEventToUpdate));
			} else if (listTaskToUpdate != null && !listTaskToUpdate.isEmpty()) {
				AV_LogDebug.printLogDebug(methodName, 'listTaskToUpdate: ' + listTaskToUpdate.size());
				AV_LogDebug.printLogDebug(methodName, 'listEventToUpdate: ' + listEventToUpdate.size());
				System.enqueueJob(new AV_GestorReassignmentTaskQueueable(listTaskToUpdate,listEventToUpdate));
			} else if (listEventToUpdate != null && !listEventToUpdate.isEmpty()) {
				AV_LogDebug.printLogDebug(methodName, 'listEventToUpdate: ' + listEventToUpdate.size());
				System.enqueueJob(new AV_GestorReassignmentEventsQueueable(listEventToUpdate));
			}
		}

		return new ListsOppTaskEvent(listOppToUpdate,listTaskToUpdate, listEventToUpdate);
	}

	public class ListsOppTaskEvent {
		public List<Opportunity> listOpportunity;
		public List<Task> listTask;
		public List<Event> listEvent;
		public ListsOppTaskEvent(List<Opportunity> listOpportunity, List<Task> listTask, List<Event> listEvent) {
			this.listOpportunity=listOpportunity;
			this.listTask=listTask;
			this.listEvent=listEvent;
		}
	}

	/**
	 * @description:	Get the list of the tasks to update of the client
	 * @param setClientesIds	client id's to update
	 */
	private static Map<Id,List<Task>> getMapTaskToUpdate(Set<Id> setClientesIds){
		String methodName = 'getMapTaskToUpdate';
		Set<Id> setIdsRt = getAllRT();
		Set<String> setStatus = new Set<String>{AV_AppConstants.TASK_STATUS_PENDIENTE,AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL};
		List<Task> listTareasAsociadas = [SELECT AccountId,AV_CodigoGestorAsignado__c FROM Task WHERE AccountId IN :setClientesIds AND RecordTypeId IN :setIdsRt AND Status IN :setStatus];
		AV_LogDebug.printLogDebug(methodName, 'listTareasAsociadas: ' + listTareasAsociadas.size());
		Map<Id,List<Task>> mapTasks = new Map<Id,List<Task>>();
		for(Task t : listTareasAsociadas){
			List<Task> listTasks = new List<Task>();
			if(mapTasks.containsKey(t.AccountId)){
				listTasks.add(t);
				listTasks.addAll(mapTasks.get(t.AccountId));
				mapTasks.put(t.AccountId, listTasks);
			}else{
				listTasks.add(t);
				mapTasks.put(t.AccountId, listTasks);
			}
		}
		return mapTasks;
	}
	
	/**
	 * @description:	Get the list of the events to update of the client
	 * @param setClientesIds	client id's to update
	 */
	private static Map<Id,List<Event>> getMapEventToUpdate(Set<Id> setClientesIds){
		String methodName = 'getMapEventToUpdate';
		Set<String> setStatus = new Set<String>{AV_AppConstants.EVENT_STATUS_PENDIENTE};
		Set<String> setRecordTypeEvent = new Set<String>{AV_AppConstants.EVENTCLIENTE_RT};
		List<Event> listEventosAsociados = [SELECT AccountId,AV_CodigoGestorAsignado__c,RecordTypeId FROM Event WHERE AccountId IN :setClientesIds AND CSBD_Evento_Estado__c IN :setStatus AND isRecurrence = false AND isRecurrence2 = false AND StartDateTime > :System.now() AND RecordType.DeveloperName IN: setRecordTypeEvent];
		AV_LogDebug.printLogDebug(methodName, 'listEventosAsociados: ' + listEventosAsociados.size());
		Map<Id,List<Event>> mapEvents = new Map<Id,List<Event>>();
		for(Event e : listEventosAsociados){
			List<Event> listEvents = new List<Event>();
			if(mapEvents.containsKey(e.AccountId)){
				listEvents.add(e);
				listEvents.addAll(mapEvents.get(e.AccountId));
				mapEvents.put(e.AccountId, listEvents);
			}else{
				listEvents.add(e);
				mapEvents.put(e.AccountId, listEvents);
			} 
		}
		return mapEvents;
	}
	
	/**
	 * @description:	Get the list of the opps to update of the client
	 * @param setClientesIds	client id's to update
	 */
	private static Map<Id,List<Opportunity>> getMapOppToUpdate(Set<Id> setClientesIds){
		String methodName = 'getMapOppToUpdate';
		Set<String> setStages = new Set<String>{AV_AppConstants.OPP_STATUS_POTENCIAL,AV_AppConstants.OPP_STATUS_ENGESTION};
		Set<String> setRecordType = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPINICIATIVA_RT,AV_AppConstants.OPPSUGERENCIA_RT,AV_AppConstants.OPPLLAMADA_RT,AV_AppConstants.OPPPROPUESTA_RT};
		List<Opportunity> listOportunidadesAsociadas = [SELECT AccountId,AV_Gestor__c FROM Opportunity WHERE AccountId IN :setClientesIds AND StageName IN :setStages AND RecordType.DeveloperName IN: setRecordType];							
		AV_LogDebug.printLogDebug(methodName, 'listOportunidadesAsociadas: ' + listOportunidadesAsociadas.size());
		Map<Id,List<Opportunity>> mapOpps = new Map<Id,List<Opportunity>>();
		for(Opportunity o : listOportunidadesAsociadas){
			List<Opportunity> listOpps = new List<Opportunity>();
			if(mapOpps.containsKey(o.AccountId)){
				listOpps.add(o);
				listOpps.addAll(mapOpps.get(o.AccountId));
				mapOpps.put(o.AccountId, listOpps);
			}else{
				listOpps.add(o);
				mapOpps.put(o.AccountId, listOpps);
			} 
		}
		return mapOpps;
	}
}