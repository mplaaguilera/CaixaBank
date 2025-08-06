/**********************************************************************************************************************
 Name:      AV_CallReport_Controller
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora para el componente AV_NewEvent e hijos 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION        USER_STORY       AUTHOR           DATE                Description
   	1.0            US518461         Luis Fernández   06/09/2023          Init version
***********************************************************************************************************************/
public with sharing class AV_CallReport_Controller {
    public static final Map<String,List<Integer>> DURATION_TO_TIME_RANGE = getDurationRanges();
    public static final Map<String,String> DURATION_TO_SUBJECT_MAP = new Map<String,String>{
        'Corta' => 'Llamada',
        'Media' => 'Cita Telefónica',
        'Larga' => 'Cita Telefónica'
    };
    // public static final Map<String,String> durationToTypeMap = new Map<String,String>{
    //     'Corta' => 'LMD',
    //     'Media' => 'CTF',
    //     'Larga' => 'CTF'
    // };
    public class CallInfoWrapper{
        @AuraEnabled 
        public string clientName;
        @AuraEnabled 
        public string clientId;
        @AuraEnabled 
        public string typeAppointment;
        @AuraEnabled 
        public string dateCall;
        @AuraEnabled 
        public Date dateCallParsed;
        @AuraEnabled 
        public string initTime;
        @AuraEnabled 
        public String duration;
        @AuraEnabled 
        public string assignedEmployeeId;
        @AuraEnabled 
        public string assignedEmployeeExternalId;
        @AuraEnabled 
        public string assignedEmployeeName;
        @AuraEnabled 
        public string origin;
        @AuraEnabled 
        public string phone;
        @AuraEnabled 
        public string subject;
        @AuraEnabled 
        public Datetime startTimeFull;
        @AuraEnabled 
        public String clientRtDevName;
        @AuraEnabled 
        public String clientIntouch;
        @AuraEnabled
        public CC_Llamada__c originalCallToBack;
    }

    private static Date formatDate(String dateToFormat){
		String[] splitedDate = dateToFormat.split(AV_AppConstants.DASH);//Split by '-'
		Integer year = Integer.valueOf(splitedDate[0]);
		Integer month = Integer.valueOf(splitedDate[1]);
		Integer day = Integer.valueOf(splitedDate[2]);
		return date.newInstance(year,month,day);
	}

    /**
     * Given an Call Id, returns all information needed to build the report of the call
     */
    @AuraEnabled
	public static CallInfoWrapper getCallInfo(String callId) {
       CallInfoWrapper response = new CallInfoWrapper();
       List<CC_Llamada__c> callRecord = [SELECT AV_State__c,AV_Account__c,AV_Account__r.RecordType.DeveloperName,OwnerId,Owner.Name,AV_Account__r.Name,CC_Fecha_Inicio__c,AV_Duration__c,AV_FirstEmployee__c,AV_FirstEmployee__r.Name,OB_Telefono__c,CC_Tipo__c FROM  CC_Llamada__c WHERE Id = :callId WITH SECURITY_ENFORCED];
        if(callRecord != null && !callRecord.isEmpty()){
			List<User> gestor = [SELECT AV_ExternalId__c FROM USER WHERE Id = :callRecord[0].OwnerId LIMIT 1 ];
			String duration = getTypeDuration(Integer.valueOf(callRecord[0].AV_Duration__c));
			
            response.clientName = callRecord[0].AV_Account__r.Name;
            response.clientId = callRecord[0].AV_Account__c;
			response.typeAppointment = DURATION_TO_SUBJECT_MAP.get(duration);
            response.dateCall = callRecord[0].CC_Fecha_Inicio__c.format('dd/MM/YYYY');
            response.dateCallParsed = (callRecord[0].CC_Fecha_Inicio__c).date();
			response.initTime = callRecord[0].CC_Fecha_Inicio__c.format('HH:mm');
            response.duration = callRecord[0].AV_Duration__c;
            response.assignedEmployeeId = callRecord[0].OwnerId;
            response.assignedEmployeeName = callRecord[0].Owner.Name;
            response.origin = callRecord[0].CC_Tipo__c;
            response.phone = callRecord[0].OB_Telefono__c;
            response.subject = DURATION_TO_SUBJECT_MAP.get(duration);
            response.startTimeFull = callRecord[0].CC_Fecha_Inicio__c;
            response.clientRtDevName = callRecord[0].AV_Account__r.RecordType.DeveloperName;
			if(gestor != null){
				response.assignedEmployeeExternalId = gestor[0].AV_ExternalId__c;
			}
			List<Contact> cntGestor = [SELECT AV_EmpleadoIntouch__c,CC_Matricula__c  FROM Contact WHERE AV_UsuarioAsociado__c = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
			response.clientIntouch = (!cntGestor.isEmpty()) ? String.valueOf(cntGestor[0].AV_EmpleadoIntouch__c) : null;

            response.originalCallToBack = callRecord[0];
            return response;
        }else{
            return null;
        }
    }




    private static Map<String,List<Integer>> getDurationRanges(){
       Map<String,List<Integer>> response = new Map<String,List<Integer>>();
        List<AV_CallDurationType__c> durationCs = [SELECT Name,MinDuration__c,MaxDuration__c FROM AV_CallDurationType__c];
        for(AV_CallDurationType__c cs : durationCs){
            response.put(cs.Name,new List<Integer>{Integer.valueOf(cs.MinDuration__c),Integer.valueOf(cs.MaxDuration__c)});
        }

        return response;
    }
     
    private static string getTypeDuration(Integer duration){
        String currentType;
        for(String type : DURATION_TO_TIME_RANGE.keySet()){
            List<Integer> rangePair = DURATION_TO_TIME_RANGE.get(type);
            if(duration >= rangePair[0] && duration < rangePair[1] || (type.equals('Larga') && duration > rangePair[0])){
                currentType = type;
                break;
            }
        }

        return currentType;
    }


	public class EventAndCallWrapper{
		@AuraEnabled
		public String error;
		@AuraEnabled
		public Event evtBack;
		@AuraEnabled
		public String evtToDelBack;
		@AuraEnabled
		public String headerNewEvt;
		@AuraEnabled
		public Boolean result;
		@AuraEnabled
		public CC_LLamada__c callBackRep;
	}
  	@AuraEnabled
  	public static EventAndCallWrapper processEventAndCall(Event evtToUpsert,CC_Llamada__c callToReport,String accountId,Date evtDate,String gestorAsociado){
		Savepoint sp = Database.setSavepoint();
        String methodName = 'processEventAndCall';

		EventAndCallWrapper response = new EventAndCallWrapper();
		response.result = false;
		try{
			List<CC_Llamada__c> callBack= [SELECT AV_State__c FROM CC_Llamada__c WHERE Id = :callToReport.Id];
			if(!callBack.isEmpty()){
				response.callBackRep = callBack[0];
			}

			Database.update(callToReport,true);
		}catch(Exception err){
			CBK_Log.error(err);
			response.error = err.getMessage();
			return response;
		}

		if(callToReport.AV_State__c?.equals('Gestionada')){
			evtToUpsert.DurationInMinutes = Integer.valueOf(evtToUpsert.DurationInMinutes);
			List<Event> currentEvents = [SELECT Id,Subject,Description,ActivityDateTime,StartDateTime,DurationInMinutes,WhatId,AV_Task__c,AV_Tipo__c,AV_Purpose__c,CC_Llamada_Id__c FROM Event WHERE WhatId = :accountId AND AV_CodigoGestorAsignado__c = :gestorAsociado AND ActivityDate = :evtDate AND CSBD_Evento_Estado__c = :AV_AppConstants.EVENT_STATUS_PENDIENTE AND RecordType.DeveloperName = :AV_AppConstants.EVENTCLIENTE_RT ORDER BY CreatedDate DESC LIMIT 1];
			
			if(!currentEvents.isEmpty()){
				if(evtToUpsert.AV_Purpose__c != null && evtToUpsert.AV_Purpose__c.equals(AV_AppConstants.PURPOSE_GESTION_OPERATIVA)){
					List<AV_CustomActivityOpportunity__c> existingCaos = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE RecordType.DeveloperName = :AV_AppConstants.OPPTASK_RT AND AV_Task__c = :currentEvents[0].AV_Task__c AND AV_Opportunity__c != NULL LIMIT 1];
					if(!existingCaos.isEmpty()){
						evtToUpsert.AV_Purpose__c = AV_AppConstants.PURPOSE_GESTION_COMERCIAL;
					}
				}
				evtToUpsert.Id = currentEvents[0].Id;
				evtToUpsert.CC_Llamada_Id__c = callToReport.Id;
				try{
					Database.update(evtToUpsert,true);
					response.evtBack = currentEvents[0];
				}catch(Exception err){
                    Database.rollback(sp);
					CBK_Log.error(err);
					response.error = err.getMessage();
					return response;
				}
			}else{
				try{
					RecordType rtCli = [SELECT Id FROM RecordType WHERE Sobjecttype = :AV_AppConstants.OBJECT_NAME_EVENT AND DeveloperName = :AV_AppConstants.EVENTCLIENTE_RT];
					evtToUpsert.RecordTypeId = rtCli.Id;
					Database.SaveResult newEvt = Database.insert(evtToUpsert,true);
					response.evtToDelBack = newEvt.getId();
					Event createdEvt = [SELECT AV_Task__c FROM Event WHERE Id = :response.evtToDelBack];
					response.headerNewEvt = createdEvt.AV_Task__c;
				}catch(Exception err){
                    Database.rollback(sp);
					CBK_Log.error(err);
					response.error = err.getMessage();
					return response;
				}
			}
		}
		response.result = true;
		return response;

  	}
		/**
	* Inner class that unites all the information needed for continue with the report when it comes to insert and update opportunities
	* editedOpportunities => Json that relate the id of the opportunity with another object that contains opportunity in field:value structure after being updated
	* errorList => List that contains the errors. Method will exit aftwr the first error and it will contains that transaction error messages
	* taskToRestoreBack => If they exist, it save a copy from the deleted checkOnOff tasks in order to restor them back if report fail later
	* caoToRestoreBack => Same as the tasks
	* taskOpposRelation => Map that relates the checkOnOff tasks external id with is AV_Task__c in order to re-build AV_CustomActivityOpportunity__c if a reportback is needed
	*/
	public class CreatedOpportunitiesWrapper{
		@AuraEnabled
		public  Map<String,Map<String,Object>> editedOpportunities;
		@AuraEnabled
		public List<String> errorList;
		@AuraEnabled
		public List<Task> taskToRestoreBack = new List<Task>();
		@AuraEnabled
		public List<String> deleteIdCommentsHistoryInsert;
		@AuraEnabled
		public List<AV_CustomActivityOpportunity__c> caoToRestoreBack = new List<AV_CustomActivityOpportunity__c>();
		@AuraEnabled
		public Map<String,String> taskOpposRelation = new Map<String,String>();
		@AuraEnabled
		public Map<String,List<String>> checkOnOffOpposId = new Map<String,List<String>>();
		@AuraEnabled
		public BackCheckOnOff bckCOF = new BackCheckOnOff();//OBJECTO BACK PARA EL EL GUARDADO DESDE REPORTE DE EVENTOS, NO DEL ALTA. 
	}
	
	public class BackCheckOnOff {
		@AuraEnabled
		public List<String> createdIdsToDelete = new List<String>();//CHECK ON OFF CREADOS PARA BORRAR
		@AuraEnabled
		public List<String> createdCaosToDelete = new List<String>();//CAO DE LAS CHECK ON OFF PARA BORRAR
		@AuraEnabled
		public List<Task> updatedTasksToRestore = new List<Task>();//LISTA SIN UPDATEAR DE LAS TAREAS
		@AuraEnabled
		public List<Task> taskToRestoreBack = new List<Task>();//TAREAS A RESTAURAR
		@AuraEnabled
		public List<AV_CustomActivityOpportunity__c> caoToRestoreBack = new List<AV_CustomActivityOpportunity__c>();//CAOS A RESTAURAR
		@AuraEnabled
		public Map<String,String> taskOpposRelation = new Map<String,String>();//RELACIONES PARA RELACIONAR LAS CAOS CON LAS TAREAS
	}
		/** 
	* Private method that return wrapped opportunities to Opportunity record
	* @param oppoWrappedList 
	* @param accountId
	*/
	private static List<Opportunity> unWrappOppos(List<Map<String,Object>> oppoWrappedList,Id iniciativaRt,String accountId) {
		List<Opportunity> opposToInsert = new List<Opportunity>();
		for(Map<String,Object> wrappedOppo : oppoWrappedList) {
			Opportunity nextOpp = new Opportunity();
			nextOpp.StageName = (String) wrappedOppo.get('newPath');
			nextOpp.Name = (String) wrappedOppo.get('Name');
			nextOpp.AV_PF__c = (String) wrappedOppo.get('ProdId');
			nextOpp.AccountId = accountId;
			nextOpp.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
			if(wrappedOppo.get('agendado') != null) {
				if((Boolean) wrappedOppo.get('agendado')) {
					nextOpp.AV_IncludeInPrioritizingCustomers__c = false;
				} else if(nextOpp.StageName == AV_AppConstants.OPP_STATUS_ENGESTION && !( (Boolean) wrappedOppo.get('agendado'))) {
					nextOpp.AV_IncludeInPrioritizingCustomers__c = true;
				} else {
					nextOpp.AV_IncludeInPrioritizingCustomers__c = false;
				}
			} else {
				nextOpp.AV_IncludeInPrioritizingCustomers__c = false;
			}
			if((String) wrappedOppo.get('proximaGestion') != null ) {
				nextOpp.AV_FechaProximoRecordatorio__c =  parseDate( (String) wrappedOppo.get('proximaGestion'));
			}
			if(!(((String) wrappedOppo.get('id')).contains('idProvisional'))) {
				nextOpp.Id =(Id) wrappedOppo.get('id');
				nextOpp.RecordTypeId = (Id) wrappedOppo.get('recordtype');
			} else {
				nextOpp.RecordTypeId = iniciativaRt;
			}
			if((String) wrappedOppo.get('comentario') != null) {
				nextOpp.AV_Comentarios__c =  (String) wrappedOppo.get('comentario');
			}
			if((String) wrappedOppo.get('expectativa') != null) {
				nextOpp.AV_Potencial__c =  (String) wrappedOppo.get('expectativa');
			}
			if(wrappedOppo.get('importe') != null) {
				nextOpp.AV_AmountEuro__c = Decimal.valueOf(((String)wrappedOppo.get('importe')).replace(',', '.'));
			}
			if((String) wrappedOppo.get('cuota') != null) {
				nextOpp.AV_Cuota__c =  Decimal.valueOf((String) wrappedOppo.get('cuota'));
			}
			if(wrappedOppo.get('importeOtraEntidad') != null) {
				nextOpp.Amount = Decimal.valueOf(((String)wrappedOppo.get('importeOtraEntidad')).replace(',', '.'));
			}
			if(wrappedOppo.get('margin') != null) {
				nextOpp.AV_MarginEuro__c = Decimal.valueOf(((String)wrappedOppo.get('margin')).replace(',', '.'));
			}
			if(wrappedOppo.get('otraEntidad') != null) {
				nextOpp.AV_Entidad__c = (String) wrappedOppo.get('otraEntidad');
			}
			if(wrappedOppo.get('subProducto') != null) {
				nextOpp.AV_ByProduct__c = (Id) wrappedOppo.get('subProducto');
			} 
			if(wrappedOppo.get('fechaOtraEntidad') != null) {
				nextOpp.AV_FechaVencimiento__c = (Date) parseDate( (String) wrappedOppo.get('fechaOtraEntidad'));
			}
			if(wrappedOppo.get('subestado') != null) {
				nextOpp.AV_Subestado__c = (String) wrappedOppo.get('subestado');
			}
			if(wrappedOppo.get('resolucion') != null) {
				nextOpp.AV_Resolucion__c = (String) wrappedOppo.get('resolucion');
			}
			if(wrappedOppo.get('noofrecerhasta') != null){
				nextOpp.AV_NoOfrecerHasta__c = (Date) formatDate( (String) wrappedOppo.get('noofrecerhasta')); 
			}
			if(wrappedOppo.get('owneridopp') != null) {
				nextOpp.OwnerId = (String) wrappedOppo.get('owneridopp');
			}	

			opposToInsert.add(nextOpp);
		}
		return opposToInsert;
	}
		/**
	* Private method for convert a Date string that comes from javascript
	*to the one that Event fields need 
	@param String Date to parse
	@return Parsed Date
	*/
	private static Date parseDate(String dateString) {
		String[] dateToArray = dateString.split(AV_AppConstants.DASH);
		Integer year = Integer.valueOf(dateToArray[0]);
		Integer month = Integer.valueOf(dateToArray[1]);
		Integer day = Integer.valueOf(dateToArray[2]);
		return date.newInstance(year,month,day);
	}
	@AuraEnabled
	public static CreatedOpportunitiesWrapper createOrUpdateOpportunitiesFromReport(Map<String,Map<String,Object>> opposToInsertOrUpdate,String accountId,Map<String,Opportunity> mapOldOpp,String eventId) {
		String methodName = 'createOrUpdateOpportunitiesFromReport';
		Savepoint sp = Database.setSavepoint();
		CreatedOpportunitiesWrapper response = new CreatedOpportunitiesWrapper();
		List<Map<String,Object>> opposToInsertListWrapp = new List<Map<String,Object>>();
		List<String> listIdsCommentsHistoryInsert = new List<String>();
		List<Map<String,Object>> opposToUpdateListWrapp = new List<Map<String,Object>>();
		Id iniciativaRt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY,AV_AppConstants.OPPINICIATIVA_RT).Id;
		for(String opp : opposToInsertOrUpdate.keySet()) {
			if(opp.contains('idProvisional')) {//oportunidades para crear
				opposToInsertListWrapp.add(opposToInsertOrUpdate.get(opp));
			} else {
				opposToUpdateListWrapp.add(opposToInsertOrUpdate.get(opp));
			}
		}
		List<Opportunity> opposToInsert = new List<Opportunity>();
		List<Opportunity> opposToUpdate = new List<Opportunity>();
		if(!opposToInsertListWrapp.isEmpty()) {
			opposToInsert = unWrappOppos(opposToInsertListWrapp,iniciativaRt,accountId);
		}
		if(!opposToUpdateListWrapp.isEmpty()) {
			opposToUpdate = unWrappOppos(opposToUpdateListWrapp,iniciativaRt,accountId);
		}
		if(!opposToInsert.isEmpty()) {
			List<Database.SaveResult> srListInsert = Database.insert(opposToInsert,false);
			Integer indexOfWrap = 0;
			for(Database.SaveResult sr : srListInsert) {
				if(sr.isSuccess()) {
					if(indexOfWrap < srListInsert.size()) {
						opposToInsertListWrapp[indexOfWrap++].put('id',sr.getId());
					}
				} else {
					response.errorList = new List<String>();
					Database.rollback(sp);
					for(Database.Error err : sr.getErrors()) {
						String errorStr =  'Error insert: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
						response.errorList.add(errorStr);
						AV_LogDebug.printLogDebug(methodName,errorStr);
					}
					return response;
				}
			}
		}
		if(!opposToUpdate.isEmpty()) {
			List<Database.SaveResult> srListUpdate = Database.update(opposToUpdate,false);
			Set<Id> debugSet = new Set<Id>();
			for(Database.SaveResult sr : srListUpdate) {
				if(!sr.isSuccess()) {
					Database.rollback(sp);
					response.errorList = new List<String>();
					for(Database.Error err : sr.getErrors()) {
						String errorStr =  'Error update: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
						response.errorList.add(errorStr);
						AV_LogDebug.printLogDebug(methodName,errorStr);
					}
					return response;
				}
			}
		}
		// List<AV_CommentsHistory__c> commHistList = new List<AV_CommentsHistory__c>();
		Set<Id> setIds = new Set<Id>();
		for (String outerKey : opposToInsertOrUpdate.keySet()) {
			Map<String, Object> innerMap = opposToInsertOrUpdate.get(outerKey);
			String id = (String)innerMap.get('id');
			setIds.add(id);
		}
		response.editedOpportunities = opposToInsertOrUpdate;
		//Iteraramos las oportunidades y búscaremos las que requieren que les sea creado un check on off, las que necesitan un editado y las que han de ser borradas
		List<String> opposToEditCheckOnOff = new List<String>();
		List<String> opposToCreateCheckOnOff = new List<String>();
		List<String> opposToDeleteCheckOnOff = new List<String>();
		List<String> opposUpdateToValidateCheckOnOff = new List<String>();
		Set<String> openStatus = new Set<String>{
			AV_AppConstants.OPP_STATUS_ENGESTION,
			AV_AppConstants.OPP_STATUS_POTENCIAL
		};
		for(String oppId : opposToInsertOrUpdate.keySet()) {
			Map<String,Object> wrappedOppo = opposToInsertOrUpdate.get(oppId);
			if(mapOldOpp.get(oppId) != null) {
				String oldDate = ((mapOldOpp.get(oppId).AV_FechaProximoRecordatorio__c != null))?String.valueOf(mapOldOpp.get(oppId).AV_FechaProximoRecordatorio__c).substring(0,10):String.valueOf(mapOldOpp.get(oppId).CloseDate);
				if(wrappedOppo.get('newPath').equals(AV_AppConstants.OPP_STATUS_ENGESTION) && wrappedOppo.get('agendado') == false) {
					//Buscamos las que requieren crear o editar un check on of. las que se tienen que crear o editar se verá más tarde en la query según tenga ya la tarea o no.
					String taskName = (oppId.contains('idProvisional')) ? ((String) wrappedOppo.get('Name')) : ((String) wrappedOppo.get('productName'));
					String oppInfoContainer = ((String) wrappedOppo.get('id')) + '---' + taskName + '---' + ((String) wrappedOppo.get('proximaGestion'));
					if(wrappedOppo.get('proximaGestion') != null && ((oppId.contains('idProvisional')) || (mapOldOpp.get(oppId) != null && (mapOldOpp.get(oppId).AV_IncludeInPrioritizingCustomers__c == false)))) {
						opposToCreateCheckOnOff.add(oppInfoContainer);
					} else if(mapOldOpp.get(oppId) != null && (mapOldOpp.get(oppId).AV_IncludeInPrioritizingCustomers__c == true) ) {
						if(wrappedOppo.get('proximaGestion') != null && (!(wrappedOppo.get('proximaGestion').equals(oldDate)))) {/*condicion fecha*/
							opposToEditCheckOnOff.add(oppInfoContainer);
						} else {
							opposUpdateToValidateCheckOnOff.add(oppInfoContainer);
						}
					}
				} else if((!openStatus.contains( ((String)wrappedOppo.get('newPath'))) && openStatus.contains(mapOldOpp.get(oppId).StageName) ) || wrappedOppo.get('agendado') == true) {//Buscamos las agendadas para borrarle el check on off si lo tienen.
					opposToDeleteCheckOnOff.add( (String) wrappedOppo.get('id'));
				}
			}
		}
		List<String> allEditOppos = new List<String>();
		allEditOppos.addAll(opposToEditCheckOnOff);
		allEditOppos.addAll(opposUpdateToValidateCheckOnOff);
		Set<Id> allEditOpposId = new Set<Id>();
		Set<String> removePositions = new Set<String>();
		for(String oppIdStr : allEditOppos) {
			allEditOpposId.add(oppIdStr.split('---')[0]);
		}
		Map<String,String> headerOppoMap = new Map<String,String>();
		Map<String,AV_CustomActivityOpportunity__c> opposWithCheckOnOffList= new Map<String,AV_CustomActivityOpportunity__c>([SELECT AV_opportunity__c,AV_Task__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c in :allEditOpposId AND AV_Task__c != null]);
		Set<String> opposWithCheckOnOff = new Set<String>();
		for(AV_CustomActivityOpportunity__c cao : opposWithCheckOnOffList.values()) {
			headerOppoMap.put(cao.AV_Task__c, cao.AV_Opportunity__c);
		}
		List<Task> tasksWithCheckOnOff = [SELECT Id,Status,AV_Task__c,isClosed FROM Task WHERE AV_Task__c IN :headerOppoMap.keySet()];
		for(Task ta : tasksWithCheckOnOff) {
			if(headerOppoMap.containsKey(ta.AV_Task__c) && !ta.isClosed) {
				opposWithCheckOnOff.add(headerOppoMap.get(ta.AV_Task__c));
			}
		}
		List<String> opposWithoutCheckOnOff = new List<String>();
		if(opposWithCheckOnOff != null && !opposWithCheckOnOff.isEmpty()){
			for(String oppo : allEditOppos) {
				if(!opposWithCheckOnOff.contains(oppo.split('---')[0])) {
					opposToCreateCheckOnOff.add(oppo);
					if(opposToEditCheckOnOff.contains(oppo)) {
						opposToEditCheckOnOff.remove(opposToEditCheckOnOff.indexOf(oppo));
					}
				}
			}
		} else if(!opposToEditCheckOnOff.isEmpty() || !opposUpdateToValidateCheckOnOff.isEmpty()) {
			opposToCreateCheckOnOff.addAll(allEditOppos);
			opposToEditCheckOnOff.clear();
		}
		response.checkOnOffOpposId = new Map<String,List<String>>{
			'create' => opposToCreateCheckOnOff,
			'update' => opposToEditCheckOnOff,
			'delete' => opposToDeleteCheckOnOff
		};
		return response;
	}
    /**
	 * Method to handle vinculations to first and second record from reports that goes with additional Event.
	*@param opposAndMain Map that related the opportunities to vinculate and his AV_IsMain__c
	*@param recordHeaderId AV_Task__c of the activity of the first record edited
	*@param commentsHistoryFromReport List of comment history objets mounted and ready to be inserted
	 * 
	 */
	@AuraEnabled 
	public static List<String> processVinculations(Map<String,Boolean> opposAndMain,String recordHeaderId,List<AV_CommentsHistory__c> commentsHistory){

		String methodName = 'processVinculations';
		List<String> response = new List<String>();
		Savepoint sp = Database.setSavepoint();

	
		if(!opposAndMain.isEmpty()){
			List<AV_CustomActivityOpportunity__c> existingCaos = [SELECT Id,AV_IsMain__c,AV_Opportunity__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :recordHeaderId AND AV_Task__c != NULL AND AV_Opportunity__c != NULL];
			List<AV_CustomActivityOpportunity__c> caosNewEvent = new List<AV_CustomActivityOpportunity__c>();
			if(!existingCaos.isEmpty()){
				String newMainOpp;
				for(String opp : opposAndMain.keySet()){
					if(opposAndMain.get(opp)){
						newMainOpp = opp;
						break;
					}
				}
				List<AV_CustomActivityOpportunity__c> oldCaosToUpdt = new List<AV_CustomActivityOpportunity__c>();
				Set<String> alreadyExistingCaos = new Set<String>();
				for(AV_CustomActivityOpportunity__c existingCao : existingCaos){
					if(existingCao.AV_IsMain__c && existingCao.AV_Opportunity__c != newMainOpp){
						existingCao.AV_IsMain__c = false;
						oldCaosToUpdt.add(existingCao);
					}
					if(existingCao.AV_Opportunity__c == newMainOpp){
						existingCao.AV_IsMain__c = true;
						oldCaosToUpdt.add(existingCao);
					}
					if(opposAndMain.containsKey((String) existingCao.AV_Opportunity__c)){
						alreadyExistingCaos.add(existingCao.AV_Opportunity__c);
					}
				}
					for(String oppo : opposAndMain.keySet()){	
						if(!alreadyExistingCaos.contains(oppo)){

							caosNewEvent.add(
								new AV_CustomActivityOpportunity__c(
									AV_Task__c = recordHeaderId,
									AV_Opportunity__c = oppo,
									AV_IsMain__c = opposAndMain.get(oppo),
									AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP
								)
							);
						}
					}
				if(!oldCaosToUpdt.isEmpty()){
					try{
						Database.update(oldCaosToUpdt,true);
					}catch(Exception err){
						Database.rollBack(sp);
						CBK_Log.error(err);
						response.add('NOK');
						response.add(err.getMessage());
						return response;
		
					}
				}

				if(!caosNewEvent.isEmpty()){
					try{
						Database.insert(caosNewEvent,true);
					}catch(Exception err){
						Database.rollBack(sp);
						CBK_Log.error(err);
						response.add('NOK');
						response.add(err.getMessage());
						return response;
		
					}
				}
			}else{

				for(String opp : opposAndMain.keySet()){
					caosNewEvent.add(
						new AV_CustomActivityOpportunity__c(
							AV_Task__c = recordHeaderId,
							AV_Opportunity__c = opp,
							AV_IsMain__c = opposAndMain.get(opp),
							AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP
						)
					);
				}
				try{
					Database.insert(caosNewEvent,true);
				}catch(Exception err){
					Database.rollBack(sp);
					CBK_Log.error(err);
					response.add('NOK');
					response.add(err.getMessage());
					return response;
	
				}
			}
	}
	if(commentsHistory != null && !commentsHistory.isEmpty()){
		List<Contact> usrCnt = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :UserInfo.getUserId() LIMIT 1];
			
		if(!usrCnt.isEmpty()){
			for(AV_CommentsHistory__c cmmh : commentsHistory){
				cmmh.AV_AssignedEmployee__c = usrCnt[0].Id;
			}
		}
		try{
			Database.insert(commentsHistory,true);
		}catch(Exception err){
			Database.rollBack(sp);
			CBK_Log.error(err);
			response.add('NOK');
			response.add(err.getMessage());
			return response;

		}
	}
	response.add('OK');
	return response;
	}

    /**
     * Method to rollback upserted event and cc_llamada__c in call report
     * 
     */

     @AuraEnabled
     public static String backUpsertedEventAndCall(String eventToDel,Event evtToRollBack,CC_Llamada__c callToRollBack){
        Savepoint sp = Database.setSavepoint();

        String methodName = 'backUpsertedEventAndCall';
        if(eventToDel != null){
            try{
                Database.delete(new Event(Id = eventToDel));
            }catch(Exception err){
                Database.rollBack(sp);
			    CBK_Log.error(err);
				return 'NOK => '+err.getMessage();
            }
        }else if(evtToRollBack != null){
			evtToRollBack.DurationInMinutes = Integer.valueOf(evtToRollBack.DurationInMinutes);
            try{
                Database.update(evtToRollBack);
            }catch(Exception err){
                Database.rollBack(sp);
			    CBK_Log.error(err);
	    		return 'NOK => '+err.getMessage();
            }
        }
		
        if(callToRollBack != null){
			try{
                Database.update(callToRollBack);
            }catch(Exception err){
				Database.rollBack(sp);
			    CBK_Log.error(err);
				return 'NOK => '+err.getMessage();
            }
        }

        return 'OK';
     }
}