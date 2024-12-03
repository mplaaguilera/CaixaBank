/**********************************************************************************************************************
 Name: AV_MassCreateData
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Propósito: Añadir datos de prueba para Analytics en STRESS.
-----------------------------------------------------------------------------------------------------------------------
Historial
-----------------------------------------------------------------------------------------------------------------------
	VERSION         USER_STORY      AUTHOR          	DATE            Description
	1.0             US196253        Víctor Santiago 	08/06/2021      Init version
	1.1             US237376        Víctor Santiago 	28/06/2021      Fixed 502 response. Onboarding tasks cannot be
																		processed as 'Gestionada positiva'.
	1.2             Fix        		Víctor Santiago 	09/07/2021      Added populateClientIdsList, clearCustomSetting,
																		generateData and clearData methods.
	1.3             Fix        		Víctor Santiago 	08/09/2021		getHeaderCustomAct fixed
	1.4		    	AV_Query IT	   Daniel Rodríguez	   04/02/2022	    Change AV_Query to SOQL for User, Account, Contact
	1.5				US326386        Luis Fernández      20/10/2022      Deleted all "AV_AIniciativaDel__c" mentions 
	1.6             Fix- Solve QC   Oscar Moreno        29/02/2024      Delete try-catch in clearCustomSetting method        

***********************************************************************************************************************/
public with sharing class AV_MassCreateData {

		private static final Map<String, RecordType> TASKRT = AV_AppUtilities.getRecordTypeInMap(
		new Set<String>{

			AV_AppConstants.TASKINICIATIVA_RT,
			AV_AppConstants.TASKALERTACOM_RT,
			AV_AppConstants.TASKEXPCLIENT_RT,
			AV_AppConstants.TASKONBOARDING_RT,
			AV_AppConstants.TASKPRIORIZADOR_RT,
			AV_AppConstants.TASKCPENDIENTE_RT,
			AV_AppConstants.TASKCONTACTGCF_RT,
			AV_AppConstants.TASKAVISOS_RT
		});


	private static final Map<String, String> TASKPRIORITY = new Map<String, String> {
		'Muy Alta' => 'Y',
		'Alta' => 'A',
		'Media' => 'M'
	};

	private static final Map<String, String> TASKSTATUS = new Map<String, String> {
		'Pendiente' => 'Open',
		'Pendiente no localizado' => 'Pendiente no localizado',
		'Gestionada positiva' => 'Gestionada positiva',
		'Gestionada negativa' => 'Gestionada negativa',
		'No gestionada' => 'No gestionada'
	};

	private static final Map<String, String> ACTIVITYORIGEN = new Map<String, String> {
		'Acción Comercial' => 'AV_AccionComercial',
		'Alerta Comercial' => 'AV_AlertaComercial',
		'Citas no cerradas' => 'AV_CitasNoCerradas',
		'Citas Previas' => 'AV_CitasPrevias',
		'Experiencia Cliente' => 'AV_CloseDeLoop',
		'Iniciativa Gestor/a' => 'AV_IniciativaGestora',
		'Llamadas' => 'AV_Llamadas',
		'Muro' => 'AV_Muro',
		'OnBoarding' => 'AV_OnBoarding',
		'Otros' => 'AV_Otros',
		'Priorizador' => 'AV_Priorizador',
		'R2B' => 'AV_R2B',
		'Tareas AVE' => 'AV_ContactosGCF',
		'Morosidad' => 'AV_Morosidad',
		'Normativo' => 'AV_Normativo',
		'Avisos' => 'AV_Avisos'
	};


	private static final Map<String, RecordType> EVENTRT = AV_AppUtilities.getRecordTypeInMap(
		new Set<String>{AV_AppConstants.EVENTGESTOR_RT,AV_AppConstants.EVENTCLIENTE_RT});
			
		
	
	private static final Map<String, String> EVENTSTATUS = new Map<String, String> {
		'Pendiente' => 'Pendiente',
		/*'Completado' => 'Completado',
		'Cancelado' => 'Cancelado',*/
		'Cerrado' => 'Gestionada Positiva'
	};

	private static final Map<String, String> EVENTINICIATIVA = new Map<String, String> {
		'Cliente' => 'Cliente',
		'Empleado/a' => 'Gestor'
	};

	private static final Map<String, String> ACTIVITYTYPE = new Map<String, String> {
		'Cita en la oficina' => 'CTO',
		'Cita telefónica' => 'CTF',
		'Videollamada' => 'VLD',
		'Visita del gestor' => '001',
		'Llamada' => 'LMD',
		'Cita en otra oficina CaixaBank' => 'CTOOC',
		'Email,sms,etc' => 'ESE',
		'Muro' => '030'
	};

	private static final Map<String, RecordType> OPPRT = AV_AppUtilities.getRecordTypeInMap(
		new Set<String>{
			AV_AppConstants.OPPINICIATIVA_RT,
			AV_AppConstants.OPPALERTACOM_RT,
			AV_AppConstants.OPPPROPUESTA_RT,
			AV_AppConstants.OPPSUGERENCIA_RT
		}
	);

	private static final Map<String, String> OPPSTAGENAME = new Map<String, String> {
		'Potencial' => AV_AppConstants.OPP_STATUS_POTENCIAL,
		'En gestión/insistir' => AV_AppConstants.OPP_STATUS_ENGESTION,
		'Cerrado positivo' => AV_AppConstants.OPP_STATUS_CERRPOST,
		'No interesado' => AV_AppConstants.OPP_STATUS_NOINTERE,
		'No apto' => AV_AppConstants.OPP_STATUS_NOAPTO,
		'Con venta' => AV_AppConstants.OPP_STATUS_CONVENTA,
		'Vencido' => AV_AppConstants.OPP_STATUS_VENCIDO
	};

	private static Map<Id, Id> clientOpps = new Map<Id, Id>();
	private static List<String> clientIds = new List<String>();

	public static Integer queryNUMBER;

	/**
	 * @description			Starts the creation process. Use this method to launch the insertion process.
	 * 						New Records = @queryNumber x Number of object RT types
	 * 						E.g. If @queryNumber = 100, it will create:
	 * 							- 100 x 8 different Task RT = 800 tasks
	 *  						- 100 x 4 different Opportunity RT = 400 opportunities
	 *  						- 100 x 2 different Event RT = 200 events
	 * @param queryNumber	Number of queries to be executed, that is, number of employees and accounts.
	 */
	public static void generateData(Integer queryNumber) {
		String methodName = 'generateData';
		queryNUMBER = queryNumber;
		populateCustomSetting();
		AV_LogDebug.printLogDebug(methodName, 'Custom Setting data filling finished: ' + queryNumber);
	}
	
	public static void generateTasks(Integer queryNumber) {
        String methodName = 'generateTasks';
		queryNUMBER = queryNumber;
		insertTasks();
        AV_LogDebug.printLogDebug(methodName, 'Insert tasks finished: ' + queryNumber);
	}
    
    public static void generateEvents(Integer queryNumber) {
        String methodName = 'generateEvents';
		queryNUMBER = queryNumber;
		insertEvents();
        AV_LogDebug.printLogDebug(methodName, 'Insert events finished: ' + queryNumber);
	}
    
    public static void generateOpps(Integer queryNumber) {
        String methodName = 'generateOpps';
		queryNUMBER = queryNumber;
		insertOpps();
        AV_LogDebug.printLogDebug(methodName, 'Insert opps finished: ' + queryNumber);
	}
    
    public static void generateLinkOppsToTasks(Integer queryNumber) {
        String methodName = 'generateLinkOppsToTasks';
		queryNUMBER = queryNumber;
		linkOppsToTasks();
        AV_LogDebug.printLogDebug(methodName, 'Link task-opps finished: ' + queryNumber);
	}

	public static void clearData() {
		String methodName = 'clearData';
		clearCustomSetting();
		AV_LogDebug.printLogDebug(methodName, 'Custom Setting data removing finished.');
	}

	/**
	 * @description     Creates a Task
	 */
	private static Task createTask(TaskAux attrs) {
		Task tarea  = new Task();

		tarea.WhatId = attrs.accId;
		tarea.OwnerId = attrs.user != null ? attrs.user : UserInfo.getUserId();
		tarea.AV_CodigoGestorAsignado__c = attrs.emp;
		tarea.Subject = attrs.subject;
		tarea.Status = attrs.status;
		tarea.Priority = attrs.priority;
		tarea.RecordTypeId = attrs.rt.Id;
		tarea.ActivityDate = attrs.actDate;
		tarea.Description = attrs.description;
		tarea.AV_OrigenAct__c = attrs.origenAct;
		tarea.AV_Tipo__c = attrs.tipo;

		return tarea;
	}

	/**
	 * @description              Creates an Event
	 */
	private static Event createEvent(EventAux attrs) {
		Event event = new Event();

		event.OwnerId = attrs.user != null ? attrs.user : UserInfo.getUserId();
		event.Subject = attrs.subject;
		if ('AV_EventosConCliente'.equals(attrs.rt.DeveloperName)) {event.WhatId = attrs.accId;}
		event.RecordTypeId = attrs.rt.Id;
		event.ActivityDate = attrs.activityDate;
		event.AV_Tipo__c = attrs.tipo;
		event.ActivityDateTime = attrs.activityDatetime;
		event.StartDateTime = attrs.startDatetime;
		event.EndDateTime = attrs.endDatetime;
		event.DurationInMinutes = attrs.durationInMinutes;
		event.CSBD_Evento_Estado__c = attrs.status;
		event.AV_OrigenApp__c = attrs.origenApp;
		event.Description = attrs.description;
		event.AV_InOutbound__c = attrs.inOutbound;

		return event;
	}

	/**
	 * @description     Creates an Opportunity
	 */
	private static Opportunity createOpportunity(OpportunityAux attrs){
		Opportunity opp = new Opportunity();

		opp.AccountId = attrs.accId;
		opp.OwnerId = attrs.user;
		opp.Name = attrs.name;
		opp.StageName = attrs.stageName;
		opp.RecordTypeId = attrs.rt.Id;
		opp.CloseDate = attrs.closeDate;
		opp.AV_Comentarios__c = attrs.comment;
		opp.AV_Gestor__c = attrs.employee;
		opp.AV_Center__c = attrs.center;
		opp.AV_PF__c = attrs.pf;
		//opp.AV_Product__c = attrs.product;

		return opp;
	}

	/**
	 * @description		Insert tasks to the database.
	 */
	private static void insertTasks() {
		List<Task> tasks = new List<Task>();
		TaskAux taskAux = new TaskAux();
		List<Contact> employees = getEmployees(queryNUMBER);
		List<String> clients = getClientIds();
		List<Account> centers = getCenters(queryNUMBER);
		Map<String, String> onboardingStatus = TASKSTATUS;
		onboardingStatus.remove('Gestionada positiva'); //tareas onboarding no admiten gestionada positiva
		String methodName = 'insertTasks';
		Integer counter = 1;
		Integer dateCounter = 1;

		for (RecordType rt : TASKRT.values()) {
			for (Contact emp : employees) {
				taskAux.accId = clients.get(counter-1);
				taskAux.user = emp.AV_UsuarioAsociado__c;//clients.get(counter-1).OwnerId;
				taskAux.rt = rt;
				taskAux.actDate = createDate(dateCounter);
				taskAux.subject = 'Task ' + rt.Name + ' ' + counter;
				taskAux.priority = getMapValue(TASKPRIORITY.values(), employees.size(), counter);
				taskAux.tipo = getMapValue(ACTIVITYTYPE.values(), employees.size(), counter);
				if ('CTOOC'.equals(taskAux.tipo)) {
					taskAux.tipo = getMapValue(ACTIVITYTYPE.values(), employees.size(), counter+1);
				}
				if (AV_AppConstants.TASKONBOARDING_RT.equals(rt.DeveloperName)) {
					taskAux.status = getMapValue(onboardingStatus.values(), employees.size(), counter);
				} else {
					taskAux.status = getMapValue(TASKSTATUS.values(), employees.size(), counter);
				}
				taskAux.origenAct = ACTIVITYORIGEN.get(rt.Name);
				taskAux.center = centers.get(counter-1).CC_Numero_Oficina__c;

				tasks.add(createTask(taskAux));
				counter++;
				dateCounter = dateCounter > 2 ? 0 : dateCounter;
				dateCounter++;
			}
			counter = 1;
		}

		System.enqueueJob(new AV_MassCreateDataQueueable(tasks, 'Task'));
	}

	/**
	 * @description		Insert events to the database.
	 */
	private static void insertEvents() {
		List<Event> events = new List<Event>();
		EventAux eventAux = new EventAux();
		Set<String> forbiddenTypes = new Set<String> {'ESE', '030'};
		List<String> inOutboundValues = new List<String> {'Entrada', 'Salida'};
		List<Contact> employees = getEmployees(queryNUMBER);
		List<String> clients = getClientIds();
		String methodName = 'insertEvents';
		Integer counter = 1;
		Integer dateCounter = 1;

		for (RecordType rt : EVENTRT.values()) {
			for (Contact emp : employees) {
				eventAux.accId = clients.get(counter-1);
				eventAux.user = emp.AV_UsuarioAsociado__c;//clients.get(counter-1).OwnerId;
				eventAux.rt = rt;
				eventAux.activityDate = createDate(dateCounter);
				eventAux.startDatetime = DateTime.newInstance(eventAux.activityDate.year(), eventAux.activityDate.month(), eventAux.activityDate.day(), 01, 01, 01);
				eventAux.activityDatetime = eventAux.startDatetime;
				eventAux.endDatetime = eventAux.startDatetime.addMinutes(Math.round(Math.random() * 60));
				eventAux.durationInMinutes = getDurationInMinutes(eventAux.startDatetime, eventAux.endDatetime);
				eventAux.subject = 'Event ' + rt.Name + ' ' + counter;
				eventAux.aIniciativaDel = getMapValue(EVENTINICIATIVA.values(), employees.size(), counter);
				eventAux.status = getMapValue(EVENTSTATUS.values(), employees.size(), counter);
				eventAux.tipo = getMapValue(ACTIVITYTYPE.values(), employees.size(), counter);
				if (forbiddenTypes.contains(eventAux.tipo) || ('AV_EventosGestorA'.equals(rt.DeveloperName) && 'CTOOC'.equals(eventAux.tipo))) {
					eventAux.tipo = getMapValue(ACTIVITYTYPE.values(), employees.size(), 1);
				}
				eventAux.origenApp = AV_AppConstants.SALESFORCE_ORIGENAPP;
				eventAux.inOutbound = inOutboundValues.get(Math.round(Math.random()));
				
				events.add(createEvent(eventAux));
				counter++;
				dateCounter = dateCounter > 2 ? 0 : dateCounter;
				dateCounter++;
			}
			counter = 1;
		}
		System.debug('Eventos! ->' + events + ' -> ' + events.size());
		System.enqueueJob(new AV_MassCreateDataQueueable(events, 'Event'));
	}

	/**
	 * @description		Insert opportunities to the database.
	 */
	private static void insertOpps() {
		List<Opportunity> opps = new List<Opportunity>();
		OpportunityAux opportunityAux = new OpportunityAux();
		List<Contact> employees = getEmployees(queryNUMBER);
		List<String> clients = getClientIds();
		List<Product2> products = getProducts(queryNUMBER);
		List<Account> centers = getCenters(queryNUMBER);
		String methodName = 'insertOpps';
		Integer counter = 1;
		Integer dateCounter = 1;

		for (RecordType rt : OPPRT.values()) {
			for (Contact emp : employees) {
				opportunityAux.accId = clients.get(counter-1);
				opportunityAux.employee = emp.Id;
				opportunityAux.user = emp.AV_UsuarioAsociado__c;
				opportunityAux.rt = rt;
				opportunityAux.closeDate = createDate(dateCounter);
				opportunityAux.name = 'Opportunity ' + rt.Name + ' ' + counter;
				opportunityAux.stageName = getMapValue(OPPSTAGENAME.values(), employees.size(), counter);
				if ('Iniciativa'.equals(rt.Name)) {
					opportunityAux.center = centers.get(counter-1).CC_Numero_Oficina__c;
					opportunityAux.pf = products.get(counter-1).Id;
					opportunityAux.product = products.get(counter-1).Description;
				}

				opps.add(createOpportunity(opportunityAux));
				counter++;
				dateCounter = dateCounter > 2 ? 0 : dateCounter;
				dateCounter++;
			}
			counter = 1;
		}

		System.enqueueJob(new AV_MassCreateDataQueueable(opps, 'Opportunity'));
	}

	/**
	 * @description		After inserting the tasks and opportunities, the use of this method will link half of
	 * 					the tasks with all the opportunities.
	 */
	private static void linkOppsToTasks() {
		List<AV_CustomActivityOpportunity__c> caoList = new List<AV_CustomActivityOpportunity__c>();
		List<String> accs = getClientIds();
		Map<Id, List<Task>> tasks = getClientTasks(accs);
		Map<Id, List<Opportunity>> opps = getClientOpps(accs);
		if (!tasks.isEmpty() && !opps.isEmpty()) {
			for (String id : accs) {
				if (tasks.get(id) != null && opps.get(id) != null) {
					linkOppsBucle(tasks,accs,id);
				}
			}
			System.enqueueJob(new AV_MassCreateDataQueueable(caoList, 'Tarea-Oportunidad'));
		}
	}
/**
 * Method to reduce cognitive complexity of linkOppsToTasks
 */
	private static List<AV_CustomActivityOpportunity__c> linkOppsBucle(Map<Id, List<Task>> tasks,List<String> accs, String id){
		List<AV_CustomActivityOpportunity__c> caoList = new List<AV_CustomActivityOpportunity__c>();
		Id rtTareaOpor = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TAREA_OPOR, AV_AppConstants.TAREA_OPOR_RT).Id;
		Map<Id, List<Opportunity>> opps = getClientOpps(accs);
		Map<String, String> headers = getHeaderCustomAct();
		Integer loopSize = 1;
		for (Integer i = 0; i < tasks.get(id).size()/2; i++) {
			caoList.addAll(createTareasOportunidad(loopSize, tasks.get(id), opps.get(id), headers, rtTareaOpor));
			loopSize = loopSize >= 4 ? 1 : loopSize + 1;
		}
		return caoList;
	}

	/**
	 * @description		Creates Tarea-Oportunidad to link tasks with opportunities. It links tasks from 1
	 * 					opportunity up to 4, using the loops variable. It also makes the first link as main.
	 */
	private static List<AV_CustomActivityOpportunity__c> createTareasOportunidad(Integer loops, List<Task> tasks, List<Opportunity> opps, Map<String, String> headers, Id rtTareaOpor) {
		List<AV_CustomActivityOpportunity__c> caoList = new List<AV_CustomActivityOpportunity__c>();

		for (Integer i = 0; i < loops; i++) {
			if (i < tasks.size() && i < opps.size()) {
				AV_CustomActivityOpportunity__c cao = new AV_CustomActivityOpportunity__c();
				cao.OwnerId = tasks.get(i).OwnerId;
				cao.Name = 'Available Opportunity ' + (i+1);
				cao.RecordTypeId = rtTareaOpor;
				cao.AV_Task__c = headers.get(tasks.get(loops - 1).AV_ExternalID__c);
				cao.AV_Opportunity__c = opps.get(i).Id;
				if (i == 1) {
					cao.AV_IsMain__c = true;
				}
				caoList.add(cao);
			}
			break;
		}

		return caoList;
	}

	private class TaskAux {
		public Id accId;
		public Id user;
		public RecordType rt;
		public Date actDate;
		public String emp;
		public String subject;
		public String priority;
		public String status;
		public String tipo;
		public String origenAct;
		public String center;
		public String description = 'Default description';
	}

	private class EventAux {
		public Id accId;
		public Id user;
		public RecordType rt;
		public Date activityDate;
		public Datetime activityDatetime;
		public Datetime startDatetime;
		public Datetime endDatetime;
		public Integer durationInMinutes;
		public String status;
		public String inOutbound;
		public String tipo;
		public String origenApp;
		public String subject;
		public String aIniciativaDel;
		public String description = 'Default description';
	}

	private class OpportunityAux {
		public Id accId;
		public Id employee;
		public Id user;
		public Id pf;
		public RecordType rt;
		public Date closeDate;
		public Date proximoRecordatorio;
		public String product;
		public String center;
		public String name;
		public String stageName;
		public String comment = 'Default comment';
	}

	private static List<Contact> getEmployees(Integer queryNumber) {
		List<Contact> employees = new List<Contact>();
		System.debug('LECTURA -> ' + Schema.sObjectType.Contact.isQueryable());
		if (Schema.sObjectType.Contact.isQueryable()) {
		 employees= [Select Id, AV_UsuarioAsociado__c From Contact Where CC_Matricula__c != null and AV_UsuarioAsociado__c != null and AV_UsuarioAsociado__r.AV_NumeroOficinaEmpresa__c != null and AV_UsuarioAsociado__r.IsActive = true and RecordType.DeveloperName = 'CC_Empleado' limit :queryNumber];	// 
		}

		return employees;
	}

	private static List<Account> getClients(Integer queryNumber) {
		//List<String> rtDevNames = new List<String> {'CC_Cliente', 'CC_ClientePA'};
		List<Account> clients = new List<Account>();
		if(Schema.sObjectType.Account.isAccessible()){
			 clients= [Select Id, OwnerId, RecordType.DeveloperName, CC_NumPerso__c From Account Where AV_NumPerso__c != null and RecordType.DeveloperName in ('CC_Cliente', 'CC_ClientePA') limit :queryNumber];
		}

		return clients;
	}

	/**
	 * @description		Populates the custom setting with client ids.
	 */
	private static void populateCustomSetting() {

		List<Account> accs = getClients(queryNUMBER);
		Integer counter = 1;
		List<AV_DataAnalyticsTest__c> dataAnalyticList = new List<AV_DataAnalyticsTest__c>();
		for (Account a : accs) {
		
			dataAnalyticList.add( new AV_DataAnalyticsTest__c(
				Name = 'ClientId_' + counter,
				AV_ClientId__c = a.Id
			));
			counter++;
		}
			Database.upsert(dataAnalyticList,true);

	}

	/**
	 * @description		Clears out the custom setting. Call when the whole process ends.
	 */
	private static void clearCustomSetting() {
		List<AV_DataAnalyticsTest__c> dat = AV_DataAnalyticsTest__c.getAll().values();
		Database.DeleteResult[] deletionResult = Database.delete(dat, true);
		for(Database.deleteResult res : deletionResult) {
			if(!res.isSuccess()) {
				for(Database.Error err : res.getErrors()) {
					CBK_Log.error(err.getStatusCode() + ': ' + err.getMessage());
				}
			}
		}
	}

	private static List<String> getClientIds() {
		List<String> ids = new List<String>();
		List<AV_DataAnalyticsTest__c> dat = AV_DataAnalyticsTest__c.getAll().values();
		for (AV_DataAnalyticsTest__c obj : dat) {
			ids.add(obj.AV_ClientId__c);
		}
		return ids;
	}

	private static List<Product2> getProducts(Integer queryNumber) {

		List<Product2> products = new List<Product2>();
		if (Schema.sObjectType.Product2.isAccessible()) {

		 products = [SELECT Id, AV_NombrePF__c,Description FROM Product2 WHERE AV_ExternalID__c != null
								   AND AV_Nivel__c = NULL LIMIT :queryNumber];
		}
		return products;
	}

	private static List<Account> getCenters(Integer queryNumber) {
		List<Account> centers = new List<Account>();
		if (Schema.sObjectType.Account.isAccessible()) {

		centers= [Select Id, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c From Account Where RecordType.DeveloperName = 'CC_CentroCaixaBank' limit :queryNumber];
		}

		return centers;
	}

	/**
	 * @description		Returns a map with a task External ID as key and a AV_HeaderCustomActivity
	 * 					as value, repeated for all the tasks that were created with this class.
	 */
	private static Map<String, String> getHeaderCustomAct() {
		Map<String, String> taskHeader = new Map<String, String>();
		Set<String> externalIds = new Set<String>();

		List<Task> tasks = new List<Task>();
		if (Schema.sObjectType.Task.isAccessible()) {

		 tasks = [SELECT AV_ExternalID__c FROM Task WHERE Subject LIKE 'Task %' and CreatedDate > :Datetime.now().addHours(-1)];
		}
        for (Task t : tasks){
			externalIds.add(t.AV_ExternalID__c);
        }
		List<AV_HeaderCustomActivity__c> headers = new List<AV_HeaderCustomActivity__c>();
		if (Schema.sObjectType.AV_HeaderCustomActivity__c.isAccessible()) {
		 headers = [SELECT Id,AV_ExternalID__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c IN :externalIds
													AND CreatedDate > :Datetime.now().addHours(-1)];
		}

		for (AV_HeaderCustomActivity__c header : headers) {
			taskHeader.put(header.AV_ExternalID__c, header.Id);
		}

		return taskHeader;
	}

	/**
	 * @description		Returns a map with an AccountId as key and a list of all related
	 * 					tasks as value, repeated for all Accounts passed as parameter.
	 */
	private static Map<Id, List<Task>> getClientTasks(List<String> accs) {
		Map<Id, List<Task>> clientTasks = new Map<Id, List<Task>>();
		Set<String> ids = new Set<String>();
		for (String id : accs) {
			ids.add(id);
		}
		
		List<Task> tasks = new List<Task>();
		if (Schema.sObjectType.Task.isAccessible()) {

		 tasks = [SELECT Id,AV_ExternalID__c,AccountId,OwnerId FROM Task WHERE AccountId IN :ids 
								AND Subject LIKE 'Task %' AND CreatedDate > :Datetime.now().addHours(-1)];
		}
		for(Task ta : tasks) {
			if (!clientTasks.containsKey(ta.AccountId)) {
				clientTasks.put(ta.AccountId,new List<Task>{ta});
			} else {
				List<Task> listTasks = new List<Task>();
				listTasks.add(ta);
				listTasks.addAll(clientTasks.get(ta.AccountId));
				clientTasks.put(ta.AccountId,listTasks);
			}
		}
		
		return clientTasks;
	}

	/**
	 * @description		Returns a map with an AccountId as key and a list of all related
	 * 					opportunities as value, repeated for all Accounts passed as parameter.
	 */
	private static Map<Id, List<Opportunity>> getClientOpps(List<String> accs) {
		Map<Id, List<Opportunity>> clientOpps = new Map<Id, List<Opportunity>>();
		Set<String> ids = new Set<String>();
		for (String id : accs) {
			ids.add(id);
		}
		// List<Opportunity> opps = new AV_Query('Opportunity')
		// 				.selectFields('Id, AccountId')
		// 				.addConditionIn('AccountId', ids)
		// 				.addConditionLike('Name', 'Opportunity %')
		// 				.addConditionGt('CreatedDate', Datetime.now().addHours(-1))
		// 				.run();
		List<Opportunity> opps = [SELECT Id,AccountId FROM Opportunity WHERE AccountId IN :ids 
								 AND Name LIKE 'Opportunity %' AND CreatedDate > :Datetime.now().addHours(-1)];
		
		for(Opportunity o : opps) {
			if (!clientOpps.containsKey(o.AccountId)) {
				clientOpps.put(o.AccountId,new List<Opportunity>{o});
			} else {
				List<Opportunity> listOpps = new List<Opportunity>();
				listOpps.add(o);
				listOpps.addAll(clientOpps.get(o.AccountId));
				clientOpps.put(o.AccountId,listOpps);
			}
		}

		return clientOpps;
	}

	private static String getMapValue(List<String> itemList, Integer numEmple, Integer loopNum) {
		String result = '';
		Integer counter = 0;

		for (Integer i = 0; i <= numEmple; i ++) {
			if (i >= loopNum) {
				result = itemList.get(counter);
				break;
			}
			
			counter++;
			counter = counter == itemList.size() ? 0 : counter;
		}

		return result;
	}

	/**
	 * @description     Creates an equal number of old, current and future Dates when called
	 *                  inside a loop.
	 * @param numIter   Loop size, number of iterations
	 * @param loopNum   Loop index
	 */
	private static Date createDate(Integer counter) {
		Date d;

		if (counter == 1) {
			d = Date.today().addMonths(-1);
		} else if (counter == 2) {
			d = Date.today();
		} else {
			d = Date.today().addMonths(1);
		}

		return d;
	}

	/**
	 * @description 	Returns the time difference between two Datetimes in minutes.
	 * @param startTime	Start time
	 * @param endTime	End time
	 */
	private static Integer getDurationInMinutes(Datetime startTime, Datetime endTime) {
		return (Integer) (endTime.getTime() - startTime.getTime()) / (1000 * 60);
	}

}