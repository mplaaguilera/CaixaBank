/**********************************************************************************************************************
Name:	  AV_ClientCommentsController
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora de los componentes "av_ClientComments"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY		AUTHOR			DATE			Description
    1.0			US147562		Álvaro López	20/01/2021		Init version
    1.1			US147315		Sandra Gómez	15/03/2021		Add recordId in CommentItem and remove condition AV_CommentLastModifiedDate__c
	1.2			FIX				David Rufo		10/05/2021		Fix issue with tasks and events don't display historical comments
	1.3			FIX				David Rufo		28/06/2021		Fix queries to filter by RecordType of MC project (AV_%)
	1.4			Fix performance	Carolina Alonso	21/10/2021		Fix performance in the method getEventTasks and getOpps
	1.5		    AV_Query IT	    Daniel Rodríguez02/03/2022	    Change AV_Query to SOQL for User, Account, Contact
	1.6         US673516        Elisabeth R.    02/10/2023      Changed getOppsHistory method, added getCases method and changed map to return
***********************************************************************************************************************/
public with sharing class AV_ClientCommentsController {

	/**
	 * @description		Get client comments from event, task and opportunity records 
	 * @param accID   	String format accountId
	 * @return Map<String,List<CommentItem>> returns a map of String (month and year) and list of CommentItem class with the client comments info 
	 */
	@AuraEnabled
	public static Map<String,List<CommentItem>> getClientComments(String accId, String filter) {
		
		List<CommentItem> lstCommItems = new List<CommentItem>();
        getEventTasks(accId, lstCommItems, filter);
        AV_LogDebug.printLogDebug('getClientComments', 'List of events + tasks: ' + lstCommItems.size());

        getOppsHistory(accId, lstCommItems, filter);
        AV_LogDebug.printLogDebug('getClientComments', 'List of events + tasks + opps: ' + lstCommItems.size());
		
		getCases(accId, lstCommItems, filter);
        AV_LogDebug.printLogDebug('getClientComments', 'List of events + tasks + opps + cases: ' + lstCommItems.size());

        
        //Order data + return list of data
		lstCommItems.sort();

		Map<String,List<CommentItem>> dateCommentListMap = groupByDate(lstCommItems);

		return dateCommentListMap;
	}


	 /**
     * Returns a map that relates the apiName and the label of the values from the picklist field Status from Activity.
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
     * Returns a map that relates the apiName and the label of the values from the picklist field AV_Tipo__c from event.
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
     * Returns a map that relates the apiName and the label of the values from the picklist field Status from Case.
     * @param String typeApiName
     * @return String
     */
    private static Map<String,String> getCaseStatusLabel(){
        List<Schema.PicklistEntry> typePicklist = Case.Status.getDescribe().getPicklistValues();
		Map<String,String> result = new Map<String,String>();
		for(Schema.PicklistEntry type : typePicklist){
			result.put(type.getValue(), type.getLabel());
		}
        return result;
    }

	/**
     * Returns a map that relates the apiName and the label of the values from the picklist field Stage from Opportunity.
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
    
    private static void getEventTasks(String accId, List<CommentItem> lstCommItems, String filter){
		Set<String> setTaskRT = new Set<String>{'AV_AlertaComercial','AV_Priorizador', 'AV_ConversacionPendiente', 'AV_MorosidadNormativa',
											'AV_Priorizador','AV_ExperienciaCliente', 'AV_Otros', 'AV_Onboarding'};
		
		Set<String> setTaskStatus = new Set<String>{'Gestionada positiva', 'Gestionada negativa', 'Gestionado no localizado'};


		List<Event> lstClientEvents;
		List<Task> lstClientTasks;

		if(filter == null ){
			lstClientEvents = [Select Id, Description, Subject, AV_Tipo__c, OwnerId, Owner.Name, ActivityDate From Event Where AccountId =: accId and RecordType.DeveloperName ='AV_EventosConCliente' and IsChild = false and (CSBD_Evento_Estado__c ='Gestionada Positiva' OR (CSBD_Evento_Estado__c ='Pendiente' and ActivityDate >=LAST_N_DAYS:30) OR CSBD_Evento_Estado__c ='Cancelado' )];
			lstClientTasks = [Select Id, Description, Subject, AV_Tipo__c, Status, OwnerId, Owner.Name, ActivityDate From Task Where AccountId =: accId and RecordType.DeveloperName in :setTaskRT AND Status in : setTaskStatus and AV_ToDelete__c = FALSE];

		}else{

			String filterLike = '%'+filter+'%';

			lstClientEvents = [Select Id, Description, Subject, AV_Tipo__c, OwnerId, Owner.Name, ActivityDate From Event Where AccountId =: accId and RecordType.DeveloperName ='AV_EventosConCliente' and IsChild = false and (CSBD_Evento_Estado__c ='Gestionada Positiva' OR (CSBD_Evento_Estado__c ='Pendiente' and ActivityDate >=LAST_N_DAYS:30) OR CSBD_Evento_Estado__c ='Cancelado' ) AND Subject LIKE : filterLike ];
			lstClientTasks = [Select Id, Description, Subject, AV_Tipo__c, Status, OwnerId, Owner.Name, ActivityDate From Task Where AccountId =: accId and RecordType.DeveloperName in :setTaskRT AND Status in : setTaskStatus and AV_ToDelete__c = FALSE AND Subject LIKE :filterLike];

		}
        
		Map<Id, Event> mapEvts = new Map<Id, Event>();
		Map<Id, Task> mapTasks = new Map<Id, Task>();

		for(Event ev : lstClientEvents) {
			mapEvts.put(ev.Id, ev);
		}
		for(Task tsk : lstClientTasks) {
			mapTasks.put(tsk.Id, tsk);
		}


        //List of events
        if(lstClientEvents != null && !lstClientEvents.isEmpty()) {

			Map<String,String> typeEventLabels = getContactTypeLabel();

			for(Event data : lstClientEvents) {
                  
						Datetime dtEvent = datetime.newInstance(data.ActivityDate.year(), data.ActivityDate.month(),data.ActivityDate.day());
						String dateOutput = dtEvent.format('dd-MM-yyyy');

						lstCommItems.add(new CommentItem( dtEvent, dateOutput, 'event', data.Owner.Name, null, 
                                                    	 data.Description, 'Cita - ' + data.Subject, data.Id, null, typeEventLabels.get(data.AV_Tipo__c),null));

			}
		}
        
        //List of tasks
        if(lstClientTasks != null && !lstClientTasks.isEmpty()) {

			Map<String,String> statusTaskLabels = getTaskStatusLabel();
			Map<String,String> typeTaskLabels = getContactTypeLabel();

			for(Task data : lstClientTasks) {
                if (String.isNotBlank(data.Description)){

						Datetime dtTask = datetime.newInstance(data.ActivityDate.year(), data.ActivityDate.month(),data.ActivityDate.day());
						String dateOutput = dtTask.format('dd-MM-yyyy');

                        lstCommItems.add(new CommentItem(dtTask, dateOutput, 'task', data.Owner.Name, null, 
                                                         data.Description, 'Tarea - ' + data.Subject, data.Id, statusTaskLabels.get(data.Status), typeTaskLabels.get(data.AV_Tipo__c), null));

                }
			}
		}
    }

	private static void getOppsHistory(String accId, List<CommentItem> lstCommItems, String filter){

		Set<String> setRTOpp = new Set<String>{'AV_AlertaComercial', 'AV_Iniciativa', 'AV_Propuesta', 'AV_Sugerencia','CSBD_Accion_Comercial','CSBD_Chat','CSBD_CMB','CSBD_CMN','CSBD_Compra_Estrella','CSBD_Desistimiento','CSBD_DesistimientoPAI','CSBD_Hipoteca','CSBD_Prestamo','CSBD_Renting','CSBD_TPV','AV_CallMe'};
		Set<String> setStatusOpp = new Set<String>{'Cerrado positivo','No interesado','No apto','Con venta','Potencial','En gestión/insistir','Cerrado positivo','Cerrada negativa','Formalizada','Perdida'};

		List<AV_CommentsHistory__c> lstClientOppsHistory;

		if(filter == null ){

			lstClientOppsHistory = [Select Id, AV_NewComment__c, AV_Opportunity__r.CloseDate, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c From AV_CommentsHistory__c Where AV_Opportunity__r.AccountId = :accId AND  AV_Opportunity__r.RecordType.DeveloperName in : setRTOpp AND AV_Opportunity__r.StageName in : setStatusOpp ];

		}else{

			String filterLike = '%'+filter+'%';
			lstClientOppsHistory = [Select Id, AV_NewComment__c, AV_Opportunity__r.CloseDate, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate, AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c From AV_CommentsHistory__c Where AV_Opportunity__r.AccountId = :accId AND  AV_Opportunity__r.RecordType.DeveloperName in : setRTOpp AND AV_Opportunity__r.StageName in : setStatusOpp AND AV_Opportunity__r.Name LIKE :filterLike];

		}

        
        //List of opportunities history
		if(lstClientOppsHistory != null && !lstClientOppsHistory.isEmpty()) {

			Map<String,String> stageOppLabels = getOppStageLabel();

			for(AV_CommentsHistory__c oppH : lstClientOppsHistory) {
				if (String.isNotBlank(oppH.AV_NewComment__c)) {

					Date dateOpp = oppH.AV_Opportunity__r.LastModifiedDate.date();
					String dateOutput = oppH.AV_Opportunity__r.LastModifiedDate.format('dd-MM-yyyy');

					lstCommItems.add(new CommentItem(oppH.AV_Opportunity__r.LastModifiedDate, dateOutput, 'opportunity', oppH.AV_Opportunity__r.Owner.Name, 
                                                oppH.AV_Opportunity__r.AV_PF__r.Name, oppH.AV_NewComment__c, 'Oportunidad - ' +  oppH.AV_Opportunity__r.Name, oppH.AV_Opportunity__c, stageOppLabels.get(oppH.AV_Opportunity__r.StageName), null, null));
				}
			}
		}
	}

	

	private static void getCases(String accId, List<CommentItem> lstCommItems, String filter){

		List<Case> lstClientCases;
		if(filter == null){

			lstClientCases = [Select Id, ProductId, Product.Name, CC_Tipo_Contacto__c, Status, Origin, CC_Fecha_Prevista__c, CreatedDate  From Case Where AccountId = :accId ];

		}else{

			String filterLike = '%'+filter+'%';
			lstClientCases = [Select Id, ProductId, Product.Name, CC_Tipo_Contacto__c, Status, Origin, CC_Fecha_Prevista__c, CreatedDate  From Case Where AccountId = :accId AND Product.Name LIKE : filterLike ];

		}


        
        //List of cases
		if(lstClientCases != null && !lstClientCases.isEmpty()) {

			Map<String,String> statusCaseLabels = getCaseStatusLabel();

			String productName;

			for(Case c : lstClientCases) {

				if(c.Product?.Name != null){
					productName ='- '+ c.Product?.Name;
				}else{
					productName='' ;
				}

				Date dateCase = c.CreatedDate.date();
				String dateOutput = c.CreatedDate.format('dd-MM-yyyy');
				lstCommItems.add(new CommentItem( c.CreatedDate, dateOutput, 'case', null, 
                                                 c.ProductId, c.CC_Tipo_Contacto__c, 'Caso '  + productName, c.Id, statusCaseLabels.get(c.Status), null, c.Origin));

					
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
		public Long id;
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
		public DateTime dateTimeField;
		@AuraEnabled
		public String dateField;
		@AuraEnabled
		public String recordId;
		@AuraEnabled
		public String status;
		@AuraEnabled
		public String contactType;
		@AuraEnabled
		public String caseChannel;


		// Constructor
		public CommentItem(DateTime dt, String  d, String ty, String emp, String prod, String comm, String sub, String rId, String statusC, String cType, String caseChannelC) {
			type = ty;
			employee = emp;
			product = prod;
			comment = comm;
			subject = sub;
			dateTimeField = dt;
			dateField = d;
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