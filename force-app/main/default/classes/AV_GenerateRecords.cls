/**********************************************************************************************************************
Name:	  AV_GenerateRecords
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Script para pruebas automáticas
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR              DATE			Description
    1.0         US466765                                            Patricia Solano     21/11/2022		Init version
	1.1			US466765           Vladislav Lityagin  21/11/2022		Modified createTask and insertTasks
	
***********************************************************************************************************************/
public with sharing class AV_GenerateRecords {

	/**
	 * @description insert a task
	 * @param numRecord -> number of records to insert
	 * @param developerNameRt -> developername for recordType of task
	 * @param activityDate -> date of activity
	 * @param initDate -> init date for task
	 * @param endDate -> end date for task
	 * @param status -> status of task
	 * @param hasOpportunityLink -> boolean for opportunity linked
	 */
    public static void insertTasks(Integer numRecord, String developerNameRt, Date activityDate, Date initDate, Date endDate, String status, Boolean hasOpportunityLink){
       	Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		List<Task> tasksList = createTask(numRecord, developerNameRt, activityDate, initDate, endDate, status, hasOpportunityLink);
		List<AV_CustomActivityOpportunity__c> custActList = new List<AV_CustomActivityOpportunity__c>();
        List<AV_ManagementHistory__c> mhList = new List<AV_ManagementHistory__c>();
		System.enqueueJob(new AV_GenerateRecordsTaskQueueable(tasksList, custActList, mhList, hasOpportunityLink, hasCustomPermission));
	}

	/**
	 * @description creates a list of tasks
	 * @param numRecord -> number of records to insert
	 * @param developerNameRt -> developername for recordType of task
	 * @param activityDate -> date of activity
	 * @param initDate -> init date for task
	 * @param endDate -> end date for task
	 * @param status -> status of task
	 * @param hasOpportunityLink -> boolean for opportunity linked
	 */
	public static List<Task> createTask(Integer numRecord, String developerNameRt, Date activityDate, Date initDate, Date endDate, String status, Boolean hasOpportunityLink){
		RecordType auxRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName =: developerNameRt AND SobjectType = 'Task'];	
		Integer auxNumRecord = numRecord;
		List<Contact> employees = getEmployees(numRecord);
		List<Account> clients = getClients(numRecord);
		List<Task> tasksList = new List<Task>();
		List<String> statusSet = new List<String> {
			AV_AppConstants.TASK_STATUS_PENDIENTE,
			AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL,
			AV_AppConstants.GESTIONADO_NEGATIVA_ESTADO,
			AV_AppConstants.CERRADO_ESTADO,
			AV_AppConstants.NO_GESTIONADA
		};
		List<String> taskStatus = new List<String> {
			AV_AppConstants.GESTIONADO_POSITIVO_ESTADO,
			AV_AppConstants.GESTIONADO_NEGATIVA_ESTADO,
			AV_AppConstants.GESTIONADO_NO_LOCALIZADO
		};
		List<String> taskPriority = new List<String> {'A', 'Y', 'M'};
		List<Account> centers = getCenters(numRecord);
		List<Task> listDataTask = [SELECT Id, AV_Task__c, AV_ExternalID__c FROM Task WHERE RecordType.DeveloperName =: developerNameRt ORDER BY CreatedDate DESC LIMIT :auxNumRecord];
		List<Task> listNews = new List<Task>();
		List<Boolean> priorityTasks = new List<Boolean> {true, false};
		Set<Id> accIds = new Set<Id>();
		Map<Id, Task> mapOldTask = new Map<Id, Task>(listDataTask); 
		Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		String methodName = 'insertTasks';
		Integer count = 1;
		Integer countAccount = 1;
		Integer countSubject = 1;
		Integer partitionLimit;
		Integer countEmployees = 1;
				
		for(Integer i = 0;i < numRecord; i++){
			Integer statusPosition = (Integer) Math.floor(Math.random()*statusSet.size());
			Integer priorityPosition = (Integer) Math.floor(Math.random()*taskPriority.size());
			Task auxTask = new Task();
			auxTask.WhatId = clients.get(countAccount - 1).Id;
			auxTask.OwnerId = employees.get(countEmployees-1).AV_UsuarioAsociado__c;
			auxTask.Subject = 'Tarea ' + (i+1);
			auxTask.ActivityDate = activityDate;
			auxTask.Priority = taskPriority.get(priorityPosition);
			auxTask.Description = 'Default Task description';
			auxTask.AV_CodigoGestorAsignado__c = employees.get(countEmployees-1).CC_Matricula__c;
			auxTask.Status = status != null ? status : statusSet.get(statusPosition);
			auxTask.AV_PriorityTask__c = priorityTasks.get(Math.round(Math.random()));
			auxTask.RecordTypeId = auxRecordType.Id;
			auxTask.AV_Center__c = centers.get(countSubject - 1).CC_Numero_Oficina__c;
			auxTask.AV_FechaFinAccionComercial__c = endDate;
			auxTask.AV_FechaInicioVigencia__c = initDate;
			if ((developerNameRt.equals(AV_AppConstants.TASKINICIATIVA_RT)) ||
				(!developerNameRt.equals(AV_AppConstants.TASKINICIATIVA_RT) && taskStatus.contains(auxTask.Status))) {
					listNews.add(auxTask);
			}

			countEmployees++;
			if((countEmployees - 1) == employees.size()){
				countEmployees = 1;
			}
			countSubject++;
			if((countSubject - 1) == centers.size()){
				countSubject = 1;
			}
			countAccount++;
			if((countAccount - 1) == clients.size()){
				countAccount = 1;
			}
			tasksList.add(auxTask);
		}

		/*if (hasCustomPermission){
			createManagementHistory(listNews);
		}*/
		return tasksList;
	}

	/**
	 * @description insert an event
	 * @param numRecord -> number of records to insert
	 * @param developerNameRt -> developername for recordType of event
	 * @param activityDate -> due date
	 * @param type -> type of event
	 * @param status -> CSBD_Evento_Estado__c of event
	 * @param hasOpportunityLink -> boolean for opportunity linked
	 */
	public static void insertEvents(Integer numRecord, String developerNameRt, Date activityDate, String type, String status, Boolean hasOpportunityLink){
		RecordType auxRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName =: developerNameRt AND SobjectType = 'Event'];	
		List<Contact> employees = getEmployees(numRecord);
		List<Account> clients = getClients(numRecord);
		List<Account> centers = getCenters(numRecord); 
		List<Event> eventList = new List<Event>();
		List<AV_CustomActivityOpportunity__c> custActList = new List<AV_CustomActivityOpportunity__c>();
		List<String> statusEvent = new List<String> {AV_AppConstants.EVENT_STATUS_PENDIENTE, AV_AppConstants.GESTIONADO_POSITIVO_ESTADO};
		List<String> inOutboundValues = new List<String> {'Entrada', 'Salida'};
		List<String> origenApp = new List<String> {AV_AppConstants.SALESFORCE_ORIGENAPP, AV_AppConstants.OUTLOOK_ORIGENAPP};
		String methodName = 'insertEvents';
		Integer partitionLimit;
		Integer countCenter = 1;
		Integer countClient = 1;
		Integer countEmployees = 1;

		for(Integer i = 0 ; i < numRecord; i++){
			Event eventAux = new Event();
			if (developerNameRt == AV_AppConstants.EVENTCLIENTE_RT){
				eventAux.WhatId = clients.get(countClient - 1).Id;
			}
			eventAux.OwnerId = employees.get(countEmployees-1).AV_UsuarioAsociado__c;
			eventAux.RecordTypeId = auxRecordType.Id;
			eventAux.ActivityDate = activityDate;
			eventAux.ActivityDateTime = eventAux.StartDateTime;
			eventAux.StartDateTime = DateTime.newInstance(eventAux.activityDate.year(), eventAux.activityDate.month(), eventAux.activityDate.day(), 01, 01, 01);
			eventAux.EndDateTime = eventAux.StartDateTime.addMinutes(Math.round(Math.random() * 60));
			eventAux.DurationInMinutes = getDurationInMinutes(eventAux.StartDateTime, eventAux.EndDateTime);
			eventAux.CSBD_Evento_Estado__c = status != null ? status : statusEvent.get(Math.round(Math.random()));
			eventAux.AV_InOutbound__c = inOutboundValues.get(Math.round(Math.random()));
			eventAux.Subject = 'Evento ' + (i+1);
			eventAux.Description = 'Default Event description';
			eventAux.AV_Center__c = centers.get(countCenter - 1).CC_Numero_Oficina__c;
			eventAux.AV_CodigoGestorAsignado__c = employees.get(countEmployees-1).CC_Matricula__c;
			eventAux.AV_Tipo__c = type;
			if (developerNameRt.equals(AV_AppConstants.EVENTCLIENTE_RT)) {
				eventAux.AV_OrigenApp__c = origenApp.get(0);
			} else {
				eventAux.AV_OrigenApp__c = origenApp.get(Math.round(Math.random()));
			}
			if(type.equals(AV_AppConstants.CITA_OFICINA_TIPO)){
				eventAux.AV_BranchPhysicalMeet__c = eventAux.AV_Center__c;
			}

			countEmployees++;
			if((countEmployees - 1) == employees.size()){
				countEmployees = 1;
			}
			countCenter++;
			if((countCenter - 1) == centers.size()){
				countCenter = 1;
			}
			countClient++;
			if((countClient - 1) == clients.size()){
				countClient = 1;
			}
			eventList.add(eventAux);		
			}
			if (developerNameRt.equals(AV_AppConstants.EVENTGESTOR_RT)) {
				hasOpportunityLink = false;
			}
			System.enqueueJob(new AV_GenerateRecordsEventQueueable(eventList, custActList, hasOpportunityLink));
		}

	/**
	 * @description insert an opportunity
	 * @param numRecord -> number of records to insert
	 * @param developerNameRt -> developername for recordType of opportunity
	 * @param dueDate -> due date for entity
	 * @param stageName -> StageName of opportunity
	 * @param includePrioritizingCustomers -> AV_IncludeInPrioritizingCustomers__c of opportunity, if it is true creates AV_CustomActivityOpportunity__c
	 */
	public static void insertOpportunities(Integer numRecord, String developerNameRt, Date dueDate, String stageName, Boolean includePrioritizingCustomers){
		List<Opportunity> opportunityList = createOpportunities(numRecord, developerNameRt, dueDate, stageName, includePrioritizingCustomers);
		System.enqueueJob(new AV_GenerateRecordsQueueable(opportunityList));
	}
				
	/**
	 * @description create a list of opportunities
	 * @param numRecord -> number of records to insert
	 * @param developerNameRt -> developername for recordType of opportunity
	 * @param dueDate -> due date of entity
	 * @param stageName -> stageName for opportunity
	 * @param includePrioritizingCustomers -> AV_IncludeInPrioritizingCustomers__c of opportunity. The maximum number of records with true value is 200
	 */
	public static List<Opportunity> createOpportunities(Integer numRecord, String developerNameRt, Date dueDate, String stageName, Boolean includePrioritizingCustomers){
		RecordType auxRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName =: developerNameRt AND SobjectType = 'Opportunity' ORDER BY CreatedDate DESC];	
		List<Opportunity> opportunityList = new List<Opportunity>();
		List<String> oppStageName = new List<String> {	
			AV_AppConstants.OPP_STATUS_ENGESTION, 
			AV_AppConstants.OPP_STATUS_POTENCIAL,
			AV_AppConstants.OPP_STATUS_CERRPOST, 
			AV_AppConstants.OPP_STATUS_CERRNEG,
			AV_AppConstants.OPP_STATUS_NOINTERE,
			AV_AppConstants.OPP_STATUS_NOAPTO,
			AV_AppConstants.OPP_STATUS_CONVENTA,
			AV_AppConstants.OPP_STATUS_VENCIDO
		};
		List<String> potentialOpp = new List<String> {'S','A','B','M','VP'};
		List<Contact> employees = getEmployees(numRecord);
		List<Account> clients = getClients(numRecord);
		List<Product2> products = getProducts();
		List<Account> centers = getCenters(numRecord); 
		Map<Id,List<Id>> mapClientProduct =  getClientProducMap(clients);
		String  methodName = 'insertOpportunities';
		Integer count = 1;
		Integer productCount = 1;
		Integer maxAccounts = 1;
		Integer countSubject = 1;
		Integer partitionLimit;
		Integer auxPartition;
		Integer employeeCount = 1;
		for(Integer i = 0 ;i < numRecord; i++){
			Integer stageNamePosition = (Integer) Math.floor(Math.random()*oppStageName.size());
			Integer potentialPosition = (Integer) Math.floor(Math.random()*potentialOpp.size());
			Boolean insertProduct = false;
			Integer bucleSecurity = 0;
			Opportunity opportunityAux = new Opportunity();
			opportunityAux.AccountId = clients.get(maxAccounts - 1).Id;
			opportunityAux.OwnerId = employees.get(employeeCount-1).AV_UsuarioAsociado__c;
			opportunityAux.RecordTypeId = auxRecordType.Id;
			opportunityAux.Name = 'Oportunidad ' + (i+1);
			opportunityAux.AV_Gestor__c = employees.get(employeeCount-1).Id;
			opportunityAux.StageName = stageName != null ? stageName : oppStageName.get(stageNamePosition);
			opportunityAux.AV_Potencial__c = potentialOpp.get(potentialPosition);
			opportunityAux.AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
			opportunityAux.AV_Comentarios__c = 'Default Opportunity comment';
			opportunityAux.AV_FechaActivacion__c = System.today();
			opportunityAux.AV_FechaAlta__c = System.today();
			opportunityAux.CloseDate = dueDate;
			opportunityAux.AV_FechaVencimiento__c = dueDate;
			opportunityAux.AV_FechaFinAccionComercial__c = dueDate;
			opportunityAux.AV_Center__c = centers.get(countSubject - 1).CC_Numero_Oficina__c;
			if (!opportunityAux.StageName.equals(AV_AppConstants.OPP_STATUS_POTENCIAL)) {
				opportunityAux.AV_FechaProximoRecordatorio__c = dueDate;
				opportunityAux.AV_FechaModificacion__c = System.today();
			}
			if (includePrioritizingCustomers && opportunityAux.StageName.equals(AV_AppConstants.OPP_STATUS_ENGESTION)) {
				opportunityAux.AV_IncludeInPrioritizingCustomers__c = includePrioritizingCustomers;
			} 

			while(!insertProduct){
				bucleSecurity++;
				if(!mapClientProduct.keySet().contains(opportunityAux.accountId)){
					opportunityAux.AV_PF__c = products.get(productCount - 1).Id;
					mapClientProduct.put(opportunityAux.accountId,new List<String>{products.get(productCount - 1).Id});
					insertProduct = true;
				}else{
					if(!mapClientProduct.get(opportunityAux.accountId).contains(products.get(productCount - 1).Id)){
						opportunityAux.AV_PF__c = products.get(productCount - 1).Id;
						mapClientProduct.get(opportunityAux.AccountId).add(products.get(productCount - 1).Id);
						insertProduct = true;
					}else{
						productCount++;
						if((productCount - 1) == products.size()){
							productCount = 1;
						}						
					}
				}
				if(bucleSecurity == 300){
					insertProduct = true;
				}
			}
			
			employeeCount++;
			if((employeeCount - 1) == employees.size()){
				employeeCount = 1;
			}
			productCount++;
			if((productCount - 1) == products.size()){
				productCount = 1;
			}
			maxAccounts++;
			if((maxAccounts - 1) == clients.size()){
				maxAccounts = 1;
			}
			countSubject++;
			if((countSubject - 1) == centers.size()){
				countSubject = 1;
			}
			opportunityList.add(opportunityAux);
		}
		return opportunityList;
	}

	/**
	 * @description insert a AV_CustomActivityOpportunity__c for oportunities if task has an opportunity linked
	 * @param  numRecord  number of records
	 * @param  oppMap 	map of opportunities
	 * @param  taskMap  map of id event 
	 * @param  accIds 	set of id accounts
	 */
    public static List<AV_CustomActivityOpportunity__c> insertTaskOpportunity (Integer numRecord, Map<Id, List<Opportunity>> oppMap, Map<Id, Task> taskMap, Set<Id> accIds) {
		List<Opportunity> opportunityList = new List<Opportunity>();
		List<Task> tasksList = new List<Task>();
		List<AV_CustomActivityOpportunity__c> custActList = new List<AV_CustomActivityOpportunity__c>();
		
		for (Id acc : accIds) {
			if(oppMap.get(acc) != null){
				for(Opportunity opp : oppMap.get(acc)){
					AV_CustomActivityOpportunity__c custAct = new AV_CustomActivityOpportunity__c();
					custAct.AV_Opportunity__c = opp.Id;
					custAct.AV_Task__c = taskMap.get(acc).AV_Task__c;
					custActList.add(custAct);
				}
			}
		}
		return custActList;
	}

	/**
	 * @description insert a AV_CustomActivityOpportunity__c for task if task has an opportunity linked
	 * @param  numRecord  number of records
	 * @param  oppMap 	map of opportunities
	 * @param  taskMap  map of id event 
	 * @param  accIds 	set of id accounts
	 */
    public static List<AV_CustomActivityOpportunity__c> insertEventOpportunity (Integer numRecord, Map<Id, List<Opportunity>> oppMap, Map<Id, Event> taskMap, Set<Id> accIds) {
		List<Opportunity> opportunityList = new List<Opportunity>();
		List<Task> tasksList = new List<Task>();
		List<Event> eventList = new List<Event>();
		List<AV_CustomActivityOpportunity__c> custActList = new List<AV_CustomActivityOpportunity__c>();
		
		for (Id acc : accIds) {
			if(oppMap.get(acc) != null){
				for(Opportunity opp : oppMap.get(acc)){
					AV_CustomActivityOpportunity__c custAct = new AV_CustomActivityOpportunity__c();
					custAct.AV_Opportunity__c = opp.Id;
					custAct.AV_Task__c = taskMap.get(acc).AV_Task__c;
					custActList.add(custAct);
				}
			}
		}
		return custActList;
	}

	/**
	* @description  create a management history for all tasks
	* @param  listNews  list of new Task records
	*/
	public static List<AV_ManagementHistory__c> createManagementHistory(List<Task> listNews) {
		List<Task> lstToProcess = new List<Task>();
		List<AV_ManagementHistory__c> histList = new List<AV_ManagementHistory__c>();
		for(Task ta : listNews) {
			lstToProcess.add(ta);
		}
		
		if(!lstToProcess.isEmpty()) {
			for(Task auxTa : lstToProcess) {
				AV_ManagementHistory__c mh = new AV_ManagementHistory__c(
					AV_ActivityId__c = auxTa.Id,
					AV_Status__c = auxTa.Status,
					AV_Type__c = auxTa.AV_Tipo__c,
					AV_Comment__c = auxTa.Description,
					AV_Date__c = Date.today()
				);
				if (auxTa.IsReminderSet && auxTa.ReminderDateTime != null) {
					mh.AV_Reminder__c = auxTa.ReminderDateTime;
				}
				histList.add(mh);
			}
			/*if (!histList.isEmpty()) {
                //Database.insert(histList, false);
			}*/
		}
        return histList;
	}

	/**
	 * @description methot to get customers
	 * @param numRecord -> number of records
	 */
	private static List<Account> getClients(Integer numRecord) {
		List<Account> clients = new List<Account>();
		if(Schema.sObjectType.Account.isAccessible()){
			 clients = [SELECT Id, OwnerId, RecordType.DeveloperName, CC_NumPerso__c, AV_OficinaPrincipalRelacionas__c FROM Account WHERE RecordType.DeveloperName in ('CC_Cliente', 'CC_ClientePA') AND AV_NumPerso__c != null ORDER BY CreatedDate DESC LIMIT :numRecord];
		}
		return clients;
	}

	/**
	 * @description methot to get employees
	 * @param numRecord -> number of records
	 */
	public static List<Contact> getEmployees(Integer numRecord) {
		if(numRecord != 1 ){
			numRecord--;
		}
		List<Contact> employees = new List<Contact>();
		Set<String> matriculasEmployes = new Set<String>();
		List<Contact> rightEmployees = new List<Contact>();
		if (Schema.sObjectType.Contact.isQueryable()) {
			employees = [SELECT Id, AV_UsuarioAsociado__c, CC_Matricula__c FROM Contact WHERE CC_Matricula__c != null AND AV_UsuarioAsociado__c != null AND AV_UsuarioAsociado__r.AV_NumeroOficinaEmpresa__c != null AND AV_UsuarioAsociado__r.IsActive = true AND RecordType.DeveloperName = 'CC_Empleado' LIMIT :numRecord];	 
		}
			return employees;
	}

	/**
	 * @description methot to get centers 
	 * @param numRecord -> number of records
	 */
	public static List<Account> getCenters(Integer numRecord) {
		List<Account> centers = new List<Account>();
		if (Schema.sObjectType.Account.isAccessible()) {
			centers = [SELECT Id, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c FROM Account WHERE RecordType.DeveloperName = 'CC_CentroCaixaBank' AND CC_Numero_Oficina__c != null  LIMIT :numRecord];
		}
		return centers;
	}

	/**
	 * @description methot to get products 
	 */
	public static List<Product2> getProducts() {
		List<Product2> products = new List<Product2>();
		if (Schema.sObjectType.Product2.isAccessible()) {

		 products = [SELECT Id,Name, AV_NombrePF__c,Description FROM Product2 WHERE AV_ExternalID__c != null AND AV_Nivel__c = NULL AND RecordType.DeveloperName = :AV_AppConstants.PRODUCT_PF_RT ORDER BY CreatedDate];
		}
		return products;
	}

	/**
	 * @description  returns the time difference between two Datetimes in minutes.
	 * @param startTime	Start time
	 * @param endTime	End time
	 */
	public static Integer getDurationInMinutes(Datetime startTime, Datetime endTime) {
		return (Integer) (endTime.getTime() - startTime.getTime()) / (1000 * 60);
	}

	/**
	 * @description get the client product
	 * @param client -> list of accounts
	 */
	public static Map<Id,List<Id>> getClientProducMap(List<Account> client){
		Map<Id,List<String>> result = new Map<Id,List<Id>>();
		Set<Id> clientId = new Set<Id>();
		Set<String> rts = new Set<String>{
			AV_AppConstants.OPPINICIATIVA_RT,
			AV_AppConstants.OPPALERTACOM_RT,
			AV_AppConstants.OPPPROPUESTA_RT,
			AV_AppConstants.OPPSUGERENCIA_RT,
			AV_AppConstants.OPPLLAMADA_RT
		};
		for(Account cli : client){
			clientId.add(cli.Id);
		}
		List<Opportunity> oppoAsociadas = [SELECT AccountId,AV_PF__c FROM Opportunity WHERE AccountId IN :clientId AND AV_PF__c != null AND RecordType.DeveloperName IN :rts];
		for(Opportunity opp : oppoAsociadas){
			if(result.keySet().contains(opp.AccountId)){
				result.get(opp.AccountId).add(opp.AV_PF__c);
			}else{
				result.put(opp.AccountId,new List<String>{opp.AV_PF__c});
			}
		}
		return result;
	}
}