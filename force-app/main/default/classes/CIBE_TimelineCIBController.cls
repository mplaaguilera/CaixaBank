/**********************************************************************************************************************
Name:	  CIBE_TimelineCIBController
Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora de los componentes "CIBE_TimelineCIB"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0			US740191		Ali, Bea			16/02/2024		Init version
	1.1			IN1214936		Luis				28/10/2024		Fix No se visualizan las oportunidades vencidas
***********************************************************************************************************************/
public with sharing class CIBE_TimelineCIBController {

	/**
		* @description								Get client comments FROM event, task AND opportunity records 
		* @param accID   							String format accountId
		* @return Map<String,List<CommentItem>> 	returns a map of String (month AND year) AND list of CommentItem class with the client comments info 
		*/
		@AuraEnabled
		public static Map<String,List<CommentItem>> getClientComments(String accId, String filter, Boolean cita, Boolean oportunidad, Boolean tarea, Boolean inicial, String filterDate) {

			if(inicial){
			List<CommentItem> lstCommItems = new List<CommentItem>();
			
			getEvent(accId, lstCommItems, filter, filterDate);
			
			getOppsHistory(accId, lstCommItems, filter, filterDate);
			
			//Order data + return list of data
			lstCommItems.sort();
			Map<String,List<CommentItem>> dateCommentListMap = groupByDate(lstCommItems);
			return dateCommentListMap;

			}else if(cita == false && tarea == false && oportunidad == false){
				List<CommentItem> lstCommItems = new List<CommentItem>();
				getEvent(accId, lstCommItems, filter, filterDate);
				getTask(accId, lstCommItems, filter, filterDate);
				getOppsHistory(accId, lstCommItems, filter, filterDate);
				//Order data + return list of data
				lstCommItems.sort();
				Map<String,List<CommentItem>> dateCommentListMap = groupByDate(lstCommItems);
				return dateCommentListMap;
	
			}else{
				List<CommentItem> lstCommItems = new List<CommentItem>();
				if(cita == true ){
					getEvent(accId, lstCommItems, filter, filterDate);
				}
				if(tarea == true ){
					getTask(accId, lstCommItems, filter, filterDate);
				}
				if(oportunidad == true ){
					getOppsHistory(accId, lstCommItems, filter, filterDate);
				}
			
				//Order data + return list of data
				lstCommItems.sort();
				Map<String,List<CommentItem>> dateCommentListMap = groupByDate(lstCommItems);
				return dateCommentListMap;
			}
		}
	
		/**
		* Returns a map that relates the apiName AND the label of the values FROM the picklist field Status FROM Activity.
		* @param String typeApiName
		* @return String
		*/
		private static Map<String,String> getTaskStatusLabel(){
			List<Schema.PicklistEntry> statusPicklist = Task.Status.getDescribe().getPicklistValues();
			Map<String,String> result = new Map<String,String>();
			for(Schema.PicklistEntry status : statusPicklist){
				result.put(status.getValue(), status.getLabel());
			}
			return result;
		}
	
		/**
		* Returns a map that relates the apiName AND the label of the values FROM the picklist field AV_Tipo__c FROM event.
		* @param String typeApiName
		* @return String
		*/
		private static Map<String,String> getContactTypeLabel(){
			List<Schema.PicklistEntry> typePicklist = Task.AV_Tipo__c.getDescribe().getPicklistValues();
			Map<String,String> result = new Map<String,String>();
			for(Schema.PicklistEntry type : typePicklist){
				result.put(type.getValue(), type.getLabel());
			}
			return result;
		}
	
		/**
		 * Returns a map that relates the apiName AND the label of the values FROM the picklist field Stage FROM Opportunity.
		 * @param String typeApiName
		 * @return String
		 */
		private static Map<String,String> getOppStageLabel(){
			List<Schema.PicklistEntry> typePicklist = Opportunity.StageName.getDescribe().getPicklistValues();
			Map<String,String> result = new Map<String,String>();
			for(Schema.PicklistEntry type : typePicklist){
				result.put(type.getValue(), type.getLabel());
			}
			return result;
		}
		
		private static void getTask(String accId, List<CommentItem> lstCommItems, String filter, String filterDate){
			Set<String> setTaskRT = new Set<String>{CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT, CIBE_AppConstants.TASK_ONBOARDING_CIB_RT,
													CIBE_AppConstants.TASK_PRIORIZADOS_CIB_RT, CIBE_AppConstants.TASK_OTROS_CIB_RT,
													CIBE_AppConstants.TASK_AVISOS_CIB_RT, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT};												
			
			
			Set<String> setTaskStatus = new Set<String>{CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO, CIBE_AppConstants.GESTIONADO_NEGATIVA_ESTADO,
														CIBE_AppConstants.GESTIONADO_NO_LOCALIZADO};
			List<Task> lstClientTasks;
	
			if(filter == null ){
				lstClientTasks = [SELECT Id, Description, Subject, AV_Tipo__c, Status, OwnerId, Owner.Name, ActivityDate, CompletedDateTime 
									FROM Task 
									WHERE AccountId =: accId 
									//AND RecordType.DeveloperName IN :setTaskRT 
									// AND AV_ToDelete__c = FALSE 
									AND Status IN : setTaskStatus
									AND ActivityDate >=  :Date.valueOf(filterDate)
									AND ActivityDate <= TODAY];
			}else{
				String filterLike = '%'+filter+'%';

				lstClientTasks = [SELECT Id, Description, Subject, AV_Tipo__c, Status, OwnerId, Owner.Name, ActivityDate, CompletedDateTime 
									FROM Task 
									WHERE AccountId =: accId 
									//AND RecordType.DeveloperName IN :setTaskRT 
									// AND AV_ToDelete__c = FALSE 
									AND Status IN : setTaskStatus 
									AND Subject LIKE :filterLike
									AND ActivityDate >=  :Date.valueOf(filterDate)
									AND ActivityDate <= TODAY];
			}
	
			Map<Id, Task> mapTasks = new Map<Id, Task>();

			for(Task tsk : lstClientTasks) {
				mapTasks.put(tsk.Id, tsk);
			}
			//List of tasks
			if(lstClientTasks != null && !lstClientTasks.isEmpty()) {
				Map<String,String> statusTaskLabels = getTaskStatusLabel();
				Map<String,String> typeTaskLabels = getContactTypeLabel();
				for(Task data : lstClientTasks) {
	
					if (String.isNotBlank(data.Description)){
	
						Datetime dtTask = datetime.newInstance(data.ActivityDate.year(), data.ActivityDate.month(),data.ActivityDate.day());
						String dateOutput = dtTask.format('dd-MM-yyyy');
	
						lstCommItems.add(new CommentItem(dtTask, 
														dateOutput, 
														'task', 
														data.Owner.Name, 
														null, 
														data.Description, 
														Label.CIBE_Task + ' - ' + data.Subject, 
														data.Id, 
														statusTaskLabels.get(data.Status), 
														typeTaskLabels.get(data.AV_Tipo__c), 
														null));
					}
				}
			}
		}

		private static void getEvent(String accId, List<CommentItem> lstCommItems, String filter, String filterDate){
			List<Event> lstClientEvents;
			List<Task> lstClientTasks;
			List<String> rtClienteCIB = new List<String>{CIBE_AppConstants.EVENT_CLIENTE_CIB_RT,CIBE_AppConstants.EVENT_CLIENTE_RT};
			List<String> statusClienteCIB = new List<String>{'Gestionada Positiva','Planificada','Pendiente','Realizada', 'Vencida'};

			if(filter == null ){
				lstClientEvents = [SELECT Id, Description, Subject, AV_Tipo__c, OwnerId, Owner.Name, ActivityDate, StartDateTime, CSBD_Evento_Estado__c 
									FROM Event 
									WHERE AccountId =: accId 
									AND RecordType.DeveloperName IN :rtClienteCIB
									AND IsChild = false 
									AND CSBD_Evento_Estado__c IN:statusClienteCIB
									AND ActivityDate >= :Date.valueOf(filterDate)
									AND ActivityDate <= TODAY];

			}else{
				String filterLike = '%'+filter+'%';

				lstClientEvents = [SELECT Id, Description, Subject, AV_Tipo__c, OwnerId, Owner.Name, ActivityDate, StartDateTime, CSBD_Evento_Estado__c
									FROM Event 
									WHERE AccountId =: accId 
									AND RecordType.DeveloperName IN :rtClienteCIB 
									AND IsChild = false 
									AND CSBD_Evento_Estado__c IN:statusClienteCIB
									AND Subject LIKE : filterLike
									AND ActivityDate >=  :Date.valueOf(filterDate)
									AND ActivityDate <= TODAY];
			}
	
			//Integer event = lstClientEvents.size();
			Map<Id, Event> mapEvts = new Map<Id, Event>();
			for(Event ev : lstClientEvents) {
				mapEvts.put(ev.Id, ev);
			}
			//List of events
			if(lstClientEvents != null && !lstClientEvents.isEmpty()) {
				// Mapa con los APInames y labels de AV_Tipo
				Map<String,String> typeEventLabels = getContactTypeLabel();
	
				for(Event data : lstClientEvents) {
	
					Datetime dtEvent = datetime.newInstance(data.StartDateTime.year(), data.StartDateTime.month(),data.StartDateTime.day());
					String dateOutput = dtEvent.format('dd-MM-yyyy');
					
					List<String> translationNames = new List<String>{data.CSBD_Evento_Estado__c};
					Map<String, String> translations = CIBE_TranslationUtilities.getInstance().addTranslationNames(translationNames).queryTranslations().getTranslations();
					String statusEvent = String.isNotBlank(translations.get(data.CSBD_Evento_Estado__c)) ? translations.get(data.CSBD_Evento_Estado__c) : data.CSBD_Evento_Estado__c;

					lstCommItems.add(new CommentItem( dtEvent, 
														dateOutput, 
														'event', 
														data.Owner.Name, 
														null, 
														data.Description, 
														Label.CIBE_Event + ' - ' + data.Subject, 
														data.Id, 
														statusEvent, 
														typeEventLabels.get(data.AV_Tipo__c),
														null));
				}
			}
		}
	
		private static void getOppsHistory(String accId, List<CommentItem> lstCommItems, String filter, String filterDate){
			Set<String> setRTOpp = new Set<String>{CIBE_AppConstants.OPP_INICIATIVACIB_RT, CIBE_AppConstants.OPP_ACCIONCIB_RT, CIBE_AppConstants.OPP_ALERTACIB_RT, CIBE_AppConstants.OPP_SUGERENCIACIB_RT};
			
			Set<String> setStatusOpp = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA, CIBE_AppConstants.OPPORTUNITY_STATUS_VENCIDO, 
													CIBE_AppConstants.OPPORTUNITY_STATUS_CERRPOSI, CIBE_AppConstants.OPPORTUNITY_STATUS_CERRNEGA,
													CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO, CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL};
			
			List<AV_CommentsHistory__c> lstClientOppsHistory;
			Map<Id, AV_CommentsHistory__c> mapClientOppsHistory = new Map<Id, AV_CommentsHistory__c>();
			List<Opportunity> lstOpp;

			if(filter == null ){
				lstClientOppsHistory = [SELECT Id, AV_NewComment__c, AV_Opportunity__r.CloseDate, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c, LastModifiedDate 
										FROM AV_CommentsHistory__c 
										WHERE AV_Opportunity__r.AccountId = :accId 
										AND AV_Opportunity__r.RecordType.DeveloperName IN :setRTOpp 
										AND AV_Opportunity__r.StageName IN :setStatusOpp 
										AND AV_Opportunity__r.CloseDate >= :Date.valueOf(filterDate)
										AND AV_Opportunity__r.CloseDate <= TODAY];

				for (AV_CommentsHistory__c comment : lstClientOppsHistory) {
					mapClientOppsHistory.put(comment.AV_Opportunity__c, comment);
				}
				
				lstOpp = [SELECT Id, CloseDate,  Owner.Name, AV_PF__r.Name, Name, StageName, LastModifiedDate, AV_Comentarios__c
										FROM Opportunity
										WHERE AccountId = :accId 
										AND RecordType.DeveloperName IN :setRTOpp 
										AND StageName IN :setStatusOpp 
										AND CloseDate >= :Date.valueOf(filterDate)
										AND CloseDate <= TODAY
										AND Id NOT IN : mapClientOppsHistory.keySet()
										];

			}else{

				String filterLike = '%'+filter+'%';
				lstClientOppsHistory = [SELECT Id, AV_NewComment__c, AV_Opportunity__r.CloseDate, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate, AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c, LastModifiedDate 
										FROM AV_CommentsHistory__c 
										WHERE 
										AV_Opportunity__r.AccountId = :accId 
										AND AV_Opportunity__r.RecordType.DeveloperName IN : setRTOpp 
										AND AV_Opportunity__r.StageName IN : setStatusOpp 
										AND AV_Opportunity__r.Name LIKE :filterLike 
										AND AV_Opportunity__r.CloseDate >= :Date.valueOf(filterDate)
										AND AV_Opportunity__r.CloseDate <= TODAY];
				
				for (AV_CommentsHistory__c comment : lstClientOppsHistory) {
					mapClientOppsHistory.put(comment.AV_Opportunity__c, comment);
				}
				
				lstOpp = [SELECT Id, CloseDate,  Owner.Name, AV_PF__r.Name, Name, StageName, LastModifiedDate, AV_Comentarios__c
										FROM Opportunity
										WHERE AccountId = :accId 
										AND RecordType.DeveloperName IN :setRTOpp 
										AND StageName IN :setStatusOpp 
										AND Name LIKE :filterLike
										AND CloseDate >= :Date.valueOf(filterDate)
										AND CloseDate <= TODAY
										AND Id NOT IN : mapClientOppsHistory.keySet()
										];
			}

			//List of opportunities history
			if(lstClientOppsHistory != null && !lstClientOppsHistory.isEmpty()) {
				// map apiName AND the label of the values FROM the picklist field Stage FROM Opportunity.
				Map<String,String> stageOppLabels = getOppStageLabel();
				for(AV_CommentsHistory__c oppH : lstClientOppsHistory) {
					// if (String.isNotBlank(oppH.AV_NewComment__c)) { IN1214936
						Datetime dateOpp = datetime.newInstance(oppH.AV_Opportunity__r.CloseDate.year(), oppH.AV_Opportunity__r.CloseDate.month(),oppH.AV_Opportunity__r.CloseDate.day());
						String dateOutput = dateOpp.format('dd-MM-yyyy');
	
						lstCommItems.add(new CommentItem(dateOpp, 
															dateOutput, 
															'opportunity', 
															oppH.AV_Opportunity__r.Owner.Name, 
															oppH.AV_Opportunity__r.AV_PF__r.Name,
															oppH.AV_NewComment__c, 
															Label.CIBE_Oportunidad + ' - ' +  oppH.AV_Opportunity__r.Name, 
															oppH.AV_Opportunity__c, 
															stageOppLabels.get(oppH.AV_Opportunity__r.StageName), 
															null, 
															null));
					// }
				}
			}

			//List of opportunities
			if(lstOpp != null && !lstOpp.isEmpty()) {
				// map apiName AND the label of the values FROM the picklist field Stage FROM Opportunity.
				Map<String,String> stageOppLabels = getOppStageLabel();
				for(Opportunity opp : lstOpp) {
					
					Datetime dateOpp = datetime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(),opp.CloseDate.day());
					String dateOutput = dateOpp.format('dd-MM-yyyy');

					lstCommItems.add(new CommentItem(dateOpp, 
														dateOutput, 
														'opportunity', 
														opp.Owner.Name, 
														opp.AV_PF__r.Name,
														opp.AV_Comentarios__c, 
														Label.CIBE_Oportunidad + ' - ' +  opp.Name, 
														opp.Id, 
														stageOppLabels.get(opp.StageName), 
														null, 
														null));
					
				}
			}
		}
	
		private static Map<String,List<CommentItem>> groupByDate(List<CommentItem> lstCommItems){
			Map<String,List<CommentItem>> dateCommentListMap = new Map<String,List<CommentItem>>();
			Map<String,String> monthMap = new Map<String,String>{'January' => 'Enero', 'February' => 'Febrero', 'March' => 'Marzo','April' => 'Abril', 'May' => 'Mayo', 'June' => 'Junio','July' => 'Julio', 'August' => 'Agosto', 'September' => 'Septiembre','October' => 'Octubre', 'November' => 'Noviembre', 'December' => 'Diciembre'};
			for(CommentItem c: lstCommItems){
	
				if(c.dateTimeField != null){
	
					Date dateFieldAux = c.dateTimeField.date();
					String monthYearString =  monthMap.get(c.dateTimeField.format('MMMM')) + ' ' + String.valueOf(dateFieldAux.year());
	
					if( dateCommentListMap.containsKey(monthYearString) ){
						List<CommentItem> commentList = dateCommentListMap.get(monthYearString);
						commentList.add(c);
						dateCommentListMap.put(monthYearString, commentList);
					}else{
						List<CommentItem> commentList = new List<CommentItem>();
						commentList.add(c);
						dateCommentListMap.put(monthYearString, commentList);
					}
				}
			}
			return dateCommentListMap;
		}
	
		public class CommentItem implements Comparable {
			@AuraEnabled
			public DateTime dateTimeField;
			@AuraEnabled
			public String dateField;
			@AuraEnabled
			public String type;
			@AuraEnabled
			public String employee;
			@AuraEnabled
			public String product;
			@AuraEnabled
			public String comment;
			@AuraEnabled
			public String subject;
			@AuraEnabled
			public String recordId;
			@AuraEnabled
			public String status;
			@AuraEnabled
			public String contactType;
			@AuraEnabled
			public String caseChannel;
			@AuraEnabled
			public Long id;
	
	
			// Constructor
			public CommentItem(DateTime dt, String  d, String ty, String emp, String prod, String comm, String sub, String rId, String statusC, String cType, String caseChannelC) {
				dateTimeField = dt;
				dateField = d;
				type = ty;
				employee = emp;
				product = prod;
				comment = comm;
				subject = sub;
				recordId = rId;
				status = statusC;
				contactType = cType;
				caseChannel = caseChannelC;
			}
	
			public Integer compareTo(Object compareTo) {
				CommentItem compareToItem = (CommentItem)compareTo;
			
				// Convertir las fechas a DateTime y luego a milisegundos (timestamp) para la comparación
				Long thisTimestamp = dateTimeField != null ? dateTimeField.getTime() : null;
				Long compareToTimestamp = compareToItem.dateTimeField != null ? compareToItem.dateTimeField.getTime() : null;
			
				// Manejar casos donde dateTimeField puede ser null en alguno de los objetos
				if (thisTimestamp == null && compareToTimestamp == null){
					return 0;
				} 
				if (thisTimestamp == null){
					return 1; // o -1 dependiendo de si quieres nulls al principio o al final
				} 
				if (compareToTimestamp == null){
					return -1; // o 1 dependiendo de si quieres nulls al principio o al final
				} 
				// Comparar los timestamps
				if (thisTimestamp < compareToTimestamp){
					return 1; // o -1 para orden ascendente
				} 
				if (thisTimestamp > compareToTimestamp){
					return -1; // o 1 para orden ascendente
				} 
			
				return 0;        
			}
		}
	}