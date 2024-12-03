/********************************************************************************************************************
 Name:    AV_TaskReport_Controller
 Copyright © 2023  CaixaBank
--------------------------------------------------------------------------------------------------------------------
 Proposito: Gives support to av_TaskReport LWC and child components.
	*av_ContactBlockTaskReport
---------------------------------------------------------------------------------------------------------------------
 Historial
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 VERSION        USER_STORY          AUTHOR              DATE            Description
 1.0            US602653            Sandra Gómez        29/09/2023      Init version.
 1.1            Fix Sin Cita        Sandra Gómez        29/01/2024      Change method createEvent add AV_ContactGenerateAppointment__c
 1.2            US796306            Oscar Moreno        20/02/2024      Add unlinkOpp method
 1.3            US796361            Oscar Moreno        20/03/2024      Modify method eventAndTaskProcess
 1.4			PPM100205279		Luis Fernández		13/05/2024		Added new attribute to OpportunityWrapper NoOfrecerHasta in order to inform AV_NoOfrecerHasta__c when it proceds.
 1.5            PPM100130465        Oscar Moreno        05/07/2024       Replace PS_CHECKONOFF with PS_OLDHOMETASK
 1.6            PPM100265806        Oscar Moreno        12/09/2024       Add the owneridopp attribute to OpportunityWrap class 
1.7				PM100492394			Luis Fernández		01/10/2024		Added owner property to task wrapper
 *********************************************************************************************************************/
public with sharing class AV_TaskReport_Controller {

	public class TaskWrapper{
		@AuraEnabled
		public String id {get;set;}
		@AuraEnabled 
		public String tipo {get;set;}
		@AuraEnabled
		public String accountId {get;set;}
		@AuraEnabled
		public String accountName {get;set;}
		@AuraEnabled
		public String accountRt {get;set;}
		@AuraEnabled
		public Boolean contactIntouch {get;set;}
		@AuraEnabled
		public String headerId {get;set;}
		@AuraEnabled
		public String subjectTask {get;set;}
		@AuraEnabled
		public String statusTask {get;set;}
		@AuraEnabled
		public Date activityDateTask {get;set;}
		@AuraEnabled
		public String priorityTask {get;set;}
		@AuraEnabled
		public String recordType {get;set;}
		@AuraEnabled
		public String descripcion {get;set;}
		@AuraEnabled
		public DateTime reminder {get;set;}
		@AuraEnabled
		public String owner {get;set;}
	}

	public class OppResulWrap {
		@AuraEnabled 
		public Map<String,Opportunity> mapOldOpp;
		@AuraEnabled 
		public List<String> opposId;
		@AuraEnabled 
		public String results;
	}

	public class TaskEvent {
		@AuraEnabled 
		public Id idTaskEvent; // is field Id
		@AuraEnabled 
		public Id taskHeader; // is field AV_Task__c
		@AuraEnabled 
		public String subject; // is field Subject
		@AuraEnabled 
		public Date activityDate; // is field ActivityDate
		@AuraEnabled 
		public String origenApp; // is field AV_OrigenApp__c
	}

	public class EventReport {
		@AuraEnabled
		public String type {get;set;}
		@AuraEnabled
		public String typeEvent {get;set;}
		@AuraEnabled
		public Integer duracion {get;set;}
		@AuraEnabled
		public DateTime activityDateTime {get;set;}
		@AuraEnabled
		public String accountId {get;set;}
		@AuraEnabled
		public Boolean memorableInterview {get;set;}
		@AuraEnabled
		public Boolean comercial {get;set;}
		@AuraEnabled
		public String comment {get;set;}
		@AuraEnabled
		public String office {get;set;}
		@AuraEnabled
		public String contactPerson {get;set;}
		@AuraEnabled
		public String location {get;set;}
	}

	public class TaskReport {
		@AuraEnabled
		public String type {get;set;}
		@AuraEnabled
		public String idTask {get;set;}
		@AuraEnabled
		public String typeTask {get;set;}
		@AuraEnabled
		public String statusTask {get;set;}
		@AuraEnabled
		public String accountId {get;set;}
		@AuraEnabled
		public String recordType {get;set;}
		@AuraEnabled
		public String comentaryTask {get;set;}
		@AuraEnabled
		public String ownerid {get;set;}
	}

	public class TaskBlockReport {
		@AuraEnabled
		public String id {get;set;}
		@AuraEnabled
		public String status {get;set;}
		@AuraEnabled
		public String comment {get;set;}
		@AuraEnabled
		public String owner {get;set;}
	}

	public class OpportunityReport {
		@AuraEnabled
		public String id {get;set;}
		@AuraEnabled
		public String newPath {get;set;}
		@AuraEnabled
		public String Name {get;set;}
		@AuraEnabled
		public String ProdId {get;set;}
		@AuraEnabled
		public Date proximaGestion {get;set;}
		@AuraEnabled
		public String expectativa {get;set;}
		@AuraEnabled
		public String resolucion {get;set;}
		@AuraEnabled
		public String comentario {get;set;}
		@AuraEnabled
		public Boolean tenencia {get;set;}
		@AuraEnabled
		public String otraEntidad {get;set;}
		@AuraEnabled
		public Date fechaOtraEntidad {get;set;}
		@AuraEnabled
		public String subProducto {get;set;}
		@AuraEnabled
		public String margin {get;set;}
		@AuraEnabled
		public String cuota {get;set;}
		@AuraEnabled
		public String importe {get;set;}
		@AuraEnabled
		public String importeOtraEntidad {get;set;}
		@AuraEnabled
		public Date closedate {get;set;}
		@AuraEnabled
		public Boolean mainVinculed {get;set;}
		@AuraEnabled
		public Boolean isVinculed {get;set;}
		@AuraEnabled
		public Boolean agendado {get;set;}
		@AuraEnabled
		public Boolean validable {get;set;}
		@AuraEnabled
		public Date noofrecerhasta {get;set;}
		@AuraEnabled
		public String owneridopp {get;set;}
	}

	public class ResultEventTask{
		@AuraEnabled 
		public Map<Id,TaskEvent> headerActivitys;
		@AuraEnabled 
		public Map<String,String> mapProducNameId;
		@AuraEnabled 
		public Map<String,String> mapProducIdOpp;
		@AuraEnabled 
		public Map<String,OpportunityReport> opportunities;
		@AuraEnabled 
		public String result;
		@AuraEnabled 
		public List<Task> listTaskChangeDate;
		@AuraEnabled 
		public List<Task> listTaskToDelete;
		@AuraEnabled 
		public List<AV_CustomActivityOpportunity__c> listTaskOpportunityDelete;
		@AuraEnabled
		public TaskEventBack dataBack;
	}

	public class TaskEventBack{
		@AuraEnabled 
		public List<Task> insertTasksDelete;
		@AuraEnabled
		public List<AV_CustomActivityOpportunity__c> insertTaskOppDelete;
		@AuraEnabled
		public List<String> deleteIdTasksInsert;
		@AuraEnabled
		public List<String> deleteIdEventInsert;
		@AuraEnabled
		public List<String> deleteIdCommentsHistoryInsert;
		@AuraEnabled
		public List<String> deleteManageHistInsert;
		@AuraEnabled
		public List<Task> updateTaskUpdated;
		@AuraEnabled
		public Map<String,String> mapNewHeader;
	}

	/**
	 * @description     Retrieves the description and type of the task
	 * @param id        Id of the task about to be closed
	 */
	@AuraEnabled
	public static TaskWrapper getTaskData(String id){
		String methodName = 'getTaskData';
		TaskWrapper taskWrapper = new TaskWrapper();
		try {
			Task ta = [SELECT Id, OwnerId, RecordType.DeveloperName, Description,ReminderDateTime,Subject, AV_Tipo__c, AccountId, ActivityDate, toLabel(Priority), toLabel(Status), Account.Name, Account.RecordType.DeveloperName, AV_Task__c FROM Task WHERE Id = :id LIMIT 1];
			taskWrapper.id = ta.Id;
			taskWrapper.tipo = ta.AV_Tipo__c;
			taskWrapper.accountId = ta.AccountId;
			taskWrapper.accountName = ta.Account.Name;
			taskWrapper.accountRt = ta.Account.RecordType.DeveloperName;
			taskWrapper.headerId = ta.AV_Task__c;
			taskWrapper.subjectTask = ta.Subject;
			taskWrapper.statusTask = ta.Status;
			taskWrapper.activityDateTask = ta.ActivityDate;
			taskWrapper.priorityTask = ta.Priority;
			taskWrapper.recordType = ta.RecordType.DeveloperName;
			taskWrapper.descripcion = ta.Description;
			taskWrapper.reminder = ta.ReminderDateTime;
			taskWrapper.owner = ta.OwnerId;
			List<Contact> co = [SELECT AV_EmpleadoIntouch__c  FROM Contact WHERE AV_UsuarioAsociado__c = :UserInfo.getUserId() LIMIT 1];
			if (co != null && !co.isEmpty()) {
				taskWrapper.contactIntouch = co[0].AV_EmpleadoIntouch__c;
			}
		} catch (Exception e) {
			AV_LogDebug.printException(methodName, e);
			throw new AuraHandledException(e.getMessage());
		}
		return taskWrapper;
	}

	/**
	 * @description     Lookup of Office
	 */
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchOffice(String searchTerm, List<String> selectedIds) {
		Integer maxResults = 10;
		searchTerm +='*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		searchResults = [
			FIND :searchTerm
			IN Name FIELDS
			RETURNING Account(
				Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c
				WHERE RecordType.Id = :accRecordTypeId
			)
			LIMIT :maxResults
		];
		String productIcon = 'standard:account';
		Account[] listAccount = (List<Account>) searchResults[0];
		for (Account acc : listAccount) {
			results.add(
				new AV_LookupSearchResult(
					acc.Id,
					AV_AppConstants.OBJECT_NAME_ACCOUNT,
					productIcon,
					acc.Name,
					'Número • ' + acc.CC_Numero_Oficina__c
				)
			);
		}
		results.sort();
		return results;
	}

	/**
	 * @description         Lookup of Contact in field Contact Person
	 * @param searchTerm    filter to search in object Contact
	 * @param selectedIds   list of Ids selected of object contact
	 * @param accountId     Id of account to filter in query
	 * @return              Contact to show lookup
	 */
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchContact(String searchTerm, List<String> selectedIds, String accountId){
		String methodName = 'getContact';
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		if(selectedIds!= null && !selectedIds.isEmpty()){
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
				Contact(Id, Name, CC_CargoRepresentante__c WHERE Id NOT IN :selectedIds AND RecordType.DeveloperName='CIBE_Apoderado' and AccountId = :AccountId)
				LIMIT 10];
		} else {
			searchResults = [
			FIND :searchTerm
			IN ALL FIELDS
			RETURNING
				Contact(Id, Name, CC_CargoRepresentante__c WHERE RecordType.DeveloperName='CIBE_Apoderado' and AccountId = :accountId)
			LIMIT 10];
		}
		String userIcon = 'standard:contact';
		List<String> listIds = new List<String>();
		if(searchResults!=null) {
			Contact[] listUsers = (List<Contact>) searchResults[0];
			for (Contact u : listUsers) {
				if (u.CC_CargoRepresentante__c != null) {
					results.add(new AV_LookupSearchResult(u.Id,'Contact',userIcon,u.Name,u.CC_CargoRepresentante__c));
				} else {
					results.add(new AV_LookupSearchResult(u.Id,'Contact',userIcon,u.Name,''));
				}
				listIds.add(u.Id);
			}
			results.sort();
		}
		String contactAccount ='Select Id, Name, CC_CargoRepresentante__c FROM Contact WHERE RecordType.DeveloperName=\'CIBE_Apoderado\' and AccountId = :accountId limit 10';
		if (listIds != null && !listIds.isEmpty()) {
			contactAccount ='Select Id, Name, CC_CargoRepresentante__c FROM Contact WHERE Id NOT IN :listIds and RecordType.DeveloperName=\'CIBE_Apoderado\' and AccountId = :accountId limit 10';
		}
		List<Contact> listContact= capsulateQuery(contactAccount,listIds,accountId);
		if(listContact!= null && !listContact.isEmpty()) {
			for (Contact p : listContact) {
				if (p.CC_CargoRepresentante__c != null) {
					results.add(new AV_LookupSearchResult(p.Id,'Contact',userIcon,p.Name,p.CC_CargoRepresentante__c));
				}else {
					results.add(new AV_LookupSearchResult(p.Id,'Contact',userIcon,p.Name,''));
				}
			}
		}
		return results;
	}

	/**
	* @description      method to query with string
	* @param q          query to execute
	* @param listIds    list of Ids contact
	* @param accountId  Id of account
	* @return           list contact of return query
	*/
	private static List<Contact> capsulateQuery(String q, List<String> listIds, String accountId) {
		return (List<Contact>) Database.query(q);
	}

	/**
	* @description                  to insert/update opportunity get of report
	* @param opportunities          map with id opportunity and map with data of opportunity to update/insert
	* @param isInsert               boolean of insert/update
	* @param accountId              Id of account
	* @return                       result OK or error, list of ids insert/update and map of old opp update
	*/
	@AuraEnabled
	public static OppResulWrap insertOrUpdateOpp(Map<String,OpportunityReport> opportunities,String accountId, Boolean isInsert){
		Savepoint sp = Database.setSavepoint();
		List<Opportunity> listOpp = new List<Opportunity>();
		String result = 'OK';
		List<String> listIds = new List<String>();
		Map<String,Opportunity> mapOldOpp = new Map<String,Opportunity> ();
		List<String> opposId = new List<String>();
		List<String> listAllIds = new List<String>();
		for(String oppoId : opportunities.keySet()){
			Opportunity nextOppo = new Opportunity();
			OpportunityReport wrappedOppo = opportunities.get(oppoId);
			if (wrappedOppo.validable) {
				nextOppo.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
				if(!oppoId.contains('idProvisional')){
					nextOppo.Id = wrappedOppo.id;
					listIds.add(nextOppo.Id);
				}else{
					nextOppo.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY,AV_AppConstants.OPPINICIATIVA_RT).Id;
					nextOppo.AV_PF__c = wrappedOppo.ProdId;
				}
				if(wrappedOppo.Name != null) {
					nextOppo.Name = wrappedOppo.Name;
				}
				if(wrappedOppo.newPath != null) {
					nextOppo.StageName = wrappedOppo.newPath;
				}
				if(wrappedOppo.proximaGestion != null) {
					nextOppo.AV_FechaProximoRecordatorio__c = wrappedOppo.proximaGestion;
				}
				if(wrappedOppo.expectativa != null) {
					nextOppo.AV_Potencial__c = wrappedOppo.expectativa;
				}
				if(wrappedOppo.resolucion != null) {
					nextOppo.AV_Resolucion__c = wrappedOppo.resolucion;
				}
				if(wrappedOppo.importe != null) {
					nextOppo.AV_AmountEuro__c = Decimal.valueOf(wrappedOppo.importe.replace(',', '.'));
				}
				if(wrappedOppo.comentario != null) {
					nextOppo.AV_Comentarios__c = wrappedOppo.comentario;
				}
				if(wrappedOppo.tenencia != null) {
					nextOppo.AV_Tenencia__c = (wrappedOppo.tenencia) ? 'S' : 'N';
				}
				if(wrappedOppo.otraEntidad != null) {
					nextOppo.AV_Entidad__c = wrappedOppo.otraEntidad;
				}
				if(wrappedOppo.fechaOtraEntidad != null) {
					nextOppo.AV_FechaVencimiento__c = wrappedOppo.fechaOtraEntidad;
				}
				if(wrappedOppo.subProducto != null) {
					nextOppo.AV_ByProduct__c = wrappedOppo.subProducto;
				} 
				if(wrappedOppo.margin != null) {
					nextOppo.AV_MarginEuro__c = Decimal.valueOf(wrappedOppo.margin.replace(',', '.'));
				}
				if(wrappedOppo.importeOtraEntidad != null) {
					nextOppo.Amount = Decimal.valueOf(wrappedOppo.importeOtraEntidad.replace(',', '.'));
				}
				if(wrappedOppo.cuota != null) {
					nextOppo.AV_Cuota__c = Double.valueOf(wrappedOppo.cuota.replace(',', '.'));
				}
				if(wrappedOppo.agendado != null && wrappedOppo.newPath != null && !wrappedOppo.agendado && wrappedOppo.newPath == AV_AppConstants.OPP_STATUS_ENGESTION) {
					nextOppo.AV_IncludeInPrioritizingCustomers__c = true;
				} else if (wrappedOppo.newPath != AV_AppConstants.OPP_STATUS_ENGESTION) {
					nextOppo.AV_IncludeInPrioritizingCustomers__c = false;
				}
				if (accountId != null) {
					nextOppo.AccountId = accountId;
				}
				if(wrappedOppo.closedate != null) {
					nextOppo.CloseDate = wrappedOppo.closedate;
				}
				if(wrappedOppo.owneridopp != null) {
					nextOppo.OwnerId = wrappedOppo.owneridopp;
				}
				if(wrappedOppo.noofrecerhasta != null){
					nextOppo.AV_NoOfrecerHasta__c = wrappedOppo.noofrecerhasta; 
				}	
				listOpp.add(nextOppo);
			} else {
				listIds.add(wrappedOppo.id);
			}
		}
		if (listIds != null && !listIds.isEmpty()) {
			List<Opportunity> listOldOpp = [Select Id, AV_IncludeInPrioritizingCustomers__c,AV_FechaProximoRecordatorio__c, StageName, AV_Potencial__c, Amount, CloseDate, AV_Cuota__c, AV_Resolucion__c, AV_AmountEuro__c, AV_Comentarios__c, AV_Tenencia__c, AV_Entidad__c, AV_FechaVencimiento__c,AV_MarginEuro__c, AV_ByProduct__c,OwnerId from Opportunity where Id in :listIds];  
			if (listOldOpp != null && !listOldOpp.isEmpty()) {
				for(Opportunity opp: listOldOpp) {
					mapOldOpp.put(opp.Id,opp);
				}
			}
		}
		if (isInsert) {
			List<Database.SaveResult> srOppos = Database.insert(listOpp,false);
			for(Database.SaveResult ur : srOppos){
				if(!ur.isSuccess()) {
					Database.rollback(sp);
					result = ur.getErrors()[0].getMessage();
				} else {
					opposId.add(ur.getId());
				}
			}
		} else {
			List<Database.SaveResult> srOppos = Database.update(listOpp,false);
			for(Database.SaveResult ur : srOppos){
				if(!ur.isSuccess()) {
					Database.rollback(sp);
					result = ur.getErrors()[0].getMessage();
				} else {
					opposId.add(ur.getId());
				}
			}
		}
		OppResulWrap resultAll = new OppResulWrap();
		resultAll.mapOldOpp = mapOldOpp;
		resultAll.opposId = opposId;
		resultAll.results = result;
		return resultAll;
	}

	/**
	* @description                  to insert/update event and task get of report
	* @param opportunities          map with id opportunity and map with data of opportunity to update/insert
	* @param event                  data of event to insert
	* @param task                   data of task to update
	* @param taskBlock              list of task to update of block of task priorizador or avisos
	* @param mapOldOpp              map of Opportunities old
	* @param opposId                list of Ids of Opportunities insert
	* @return                       result OK or error, list of ids insert/update and map of old opp update
	*/
	@AuraEnabled
	public static ResultEventTask eventAndTaskProcess(EventReport event,TaskReport task, Map<String,TaskBlockReport> taskBlock, Map<String,OpportunityReport> opportunities,Map<String,Opportunity> mapOldOpp, List<String> opposId) {
		Boolean hasCustomPermission = FeatureManagement.checkPermission(AV_AppConstants.PS_OLDHOMETASK);
		Savepoint sp = Database.setSavepoint();
		String result = 'OK';
		//Back
		List<Task> listTaskUpdateOld = new List<Task>();
		List<String> listIdsManageHistInsert = new List<String>();
		List<String> listIdsEventInsert = new List<String>();
		List<String> listIdsCommentsHistoryInsert = new List<String>();
		List<AV_CustomActivityOpportunity__c> listTaskOppDeleteOld = new List<AV_CustomActivityOpportunity__c>();
		Map<String,String> mapNewHeader = new Map<String,String>();
		List<Task> listTaskDeleteOld = new List<Task>();
		List<String> listIdsTaskInsert = new List<String>();
		//Task
		List<Task> tskToUpt = new List<Task>();
		List<String> listIdsTskToUpt = new List<String>();
		//Para el nombre del evento segun el producto de la oportunidad
		Map<String,String> mapProducIdName = new Map<String,String>();
		Map<String,String> mapProducNameId = new Map<String,String>();
		Map<String,String> mapProducIdOpp = new Map<String,String>();
		//Para el metodo de check on off 
		List<AV_CustomActivityOpportunity__c> listTaskOpportunityDelete = new List<AV_CustomActivityOpportunity__c>();
		List<Task> listTaskToDelete = new List<Task>();
		List<Task> listTaskChangeDate = new List<Task>();
		//Para el metodo de crear la tarea-opp
		List<String> resultsEventTask = new List<String>();
		Map<Id,TaskEvent> headerActivitys = new Map<Id,TaskEvent>();
		List<AV_ManagementHistory__c> lmh = new List<AV_ManagementHistory__c>();
		if(taskBlock != null && !taskBlock.isEmpty()){ //Bloque de tareas
			tskToUpt = blockTask(taskBlock,task,event);
		}
		resultsEventTask.add(task.idTask);
		listIdsTskToUpt.add(task.idTask);
		if (listIdsTskToUpt != null && !listIdsTskToUpt.isEmpty()) {
			List<Task> listIdsTskToUptAdd = [SELECT Id, Description, Status, ActivityDate, AV_Tipo__c FROM Task WHERE Id in :listIdsTskToUpt];
			if (listIdsTskToUptAdd != null && !listIdsTskToUptAdd.isEmpty()) {
				listTaskUpdateOld.addAll(listIdsTskToUptAdd);
			}
		}
		tskToUpt.add(createTask(task,event));
		if (tskToUpt != null && !tskToUpt.isEmpty()) {
			for(Task ta : tskToUpt) {
				ta.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
			}

			List<Database.SaveResult> srUpdtTsk = Database.update(tskToUpt,false);
			for(Database.SaveResult err : srUpdtTsk){
				if(!err.isSuccess()){
					result = err.getErrors()[0].getMessage();
				}
			}
			for(Task t : tskToUpt){
				lmh.add(
					new AV_ManagementHistory__c(
						AV_ActivityId__c = t.Id,
						AV_Date__c = System.today(),
						AV_Type__c = t.AV_Tipo__c,
						AV_Status__c = t.Status,
						AV_Comment__c = t.Description
					)
				);
				listIdsTskToUpt.add(t.Id);
			}
			if (lmh != null && !lmh.isEmpty()) {
				List<Database.SaveResult> srInsertManaHis = Database.insert(lmh,false);
				for(Database.SaveResult err : srInsertManaHis){
					if(!err.isSuccess()){
						result = err.getErrors()[0].getMessage();
					} else {
						listIdsManageHistInsert.add(err.getId());
					}
				}
			}
		}
		if(opportunities != null && !opportunities.isEmpty()) {
			String nameOppMain;
			//Para el check on off
			Map<String,OpportunityReport> mapCreateTaskCheckOnOff = new Map<String,OpportunityReport>();
			Map<String,OpportunityReport> mapOpportunities = new Map<String,OpportunityReport>();
			//Para el back
			List<String> listIdsTaskOpportunityDelete = new List<String>();
			List<String> listTaskToDeleteIds = new List<String>();
			List<String> listTaskChangeDateIds = new List<String>();
			List<String> listIdsOppCheck = new List<String>();
			for(String oppoId : opportunities.keySet()){
				String idOppNew = null;
				if((opportunities.get(oppoId).id.contains('idProvisional') || !mapOldOpp.get(oppoId).AV_IncludeInPrioritizingCustomers__c) && opportunities.get(oppoId).agendado == false && opportunities.get(oppoId).newPath == AV_AppConstants.OPP_STATUS_ENGESTION) { //Check on off por fechas, segun si esta en gestion si no es agendado si no esta creada la oportunidad y si esta creada mira si la oportunidad anteriormente tuviera el check on of deshabilitado
					if(opposId != null && !opposId.isEmpty() && opportunities.get(oppoId).id.contains('idProvisional')){
						idOppNew = opposId.remove(0);
						opportunities.get(oppoId).id = idOppNew;
					}
					if (idOppNew != null) {
						mapProducIdOpp.put(opportunities.get(oppoId).ProdId,idOppNew);
						mapCreateTaskCheckOnOff.put(idOppNew,opportunities.get(oppoId));
					}else {
						mapProducIdOpp.put(opportunities.get(oppoId).ProdId,oppoId);
						mapCreateTaskCheckOnOff.put(oppoId,opportunities.get(oppoId));
					}
				}else if(!opportunities.get(oppoId).id.contains('idProvisional') && (((mapOldOpp.get(oppoId).AV_IncludeInPrioritizingCustomers__c && (opportunities.get(oppoId).proximaGestion != null && mapOldOpp.get(oppoId).AV_FechaProximoRecordatorio__c != opportunities.get(oppoId).proximaGestion))) && opportunities.get(oppoId).agendado == false && opportunities.get(oppoId).newPath == AV_AppConstants.OPP_STATUS_ENGESTION) || opportunities.get(oppoId).newPath != AV_AppConstants.OPP_STATUS_ENGESTION) { //Check on off por fechas, segun si esta en gestion si no es agendado si esta creada y tiene el check on off habilitado y cambia de fecha de proxima gestion o la que no estan en gestion insistir
					if(opposId != null && !opposId.isEmpty() && opportunities.get(oppoId).id.contains('idProvisional')){
						idOppNew = opposId.remove(0);
						opportunities.get(oppoId).id = idOppNew;
					}
					if (idOppNew != null) {
						mapOpportunities.put(idOppNew,opportunities.get(oppoId));
						listIdsOppCheck.add(idOppNew);
					}else {
						mapOpportunities.put(oppoId,opportunities.get(oppoId));
						listIdsOppCheck.add(oppoId);
					}
				}
				if(opposId != null && !opposId.isEmpty() && opportunities.get(oppoId).id.contains('idProvisional') && idOppNew == null){
					opportunities.get(oppoId).id = opposId.remove(0);
				}
				if (opportunities.get(oppoId).mainVinculed) { //Nombre del evento cuando la cita no es No comercial
					nameOppMain = (String) opportunities.get(oppoId).Name;
				}
			}
			//Check on off
			if (mapOpportunities != null && listIdsOppCheck != null && !listIdsOppCheck.isEmpty()) { //si esta creada y tiene el check on off habilitado y cambia de fecha de proxima gestion y no tiene ninguna tarea de check on off en potencial o en gestion CHECK ON OFF para cambiarla de fecha o crear una nueva  o si no esta en gestion para eliminar la tarea y la tarea-oportunidad
				List<AV_CustomActivityOpportunity__c> listTaskOppCheck = [SELECT Id, AV_Task__c, AV_Opportunity__c, AV_Opportunity__r.AV_FechaProximoRecordatorio__c, AV_Opportunity__r.StageName FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN :listIdsOppCheck AND AV_Task__c != null];
				List<String> listOppNoCreateTask = new List<String>();
				if (listTaskOppCheck != null && !listTaskOppCheck.isEmpty()) {
					Map<String,AV_CustomActivityOpportunity__c> mapTaskOppId = new Map<String,AV_CustomActivityOpportunity__c>();
					Map<String,List<AV_CustomActivityOpportunity__c>> mapTaskOppIdHeader = new Map<String,List<AV_CustomActivityOpportunity__c>>();
					Map<String,List<String>> mapTaskOppIdHeaderId = new Map<String,List<String>>();
					List<String> listHeaderIdToDelete = new List<String>();
					for (AV_CustomActivityOpportunity__c caopp : listTaskOppCheck) {
						mapTaskOppId.put(caopp.AV_Task__c,caopp);
						if(mapTaskOppIdHeader.containsKey(caopp.AV_Task__c)) {
							mapTaskOppIdHeader.get(caopp.AV_Task__c).add(caopp);
						} else {
							mapTaskOppIdHeader.put(caopp.AV_Task__c, new List<AV_CustomActivityOpportunity__c>{caopp});
						}
						if(mapTaskOppIdHeaderId.containsKey(caopp.AV_Task__c)) {
							mapTaskOppIdHeaderId.get(caopp.AV_Task__c).add(caopp.Id);
						} else {
							mapTaskOppIdHeaderId.put(caopp.AV_Task__c, new List<String>{caopp.Id});
						}
						if (caopp.AV_Opportunity__r.StageName != AV_AppConstants.OPP_STATUS_ENGESTION) {
							listHeaderIdToDelete.add(caopp.AV_Task__c);
						}
					}
					if (mapTaskOppId != null && mapTaskOppIdHeader != null && mapTaskOppIdHeaderId != null) {
						List<Task> listTaskOppCheckOn = [SELECT Id, AV_OrigenApp__c, AV_Task__c, IsClosed, ActivityDate FROM Task WHERE AV_Task__c IN :mapTaskOppId.keySet()];
						if (listTaskOppCheckOn != null && !listTaskOppCheckOn.isEmpty()) {
							for (Task ta : listTaskOppCheckOn) {
								if (listHeaderIdToDelete != null && !listHeaderIdToDelete.isEmpty() && listHeaderIdToDelete.contains(ta.AV_Task__c) && ta.AV_OrigenApp__c == AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF && mapTaskOppIdHeader.get(ta.AV_Task__c) != null && !ta.IsClosed) {//Esta es la parte en el que check on-off cuando pasa a cerrada la oportunidad que borra la tarea-oportunidad y la tarea
									listTaskOpportunityDelete.addAll(mapTaskOppIdHeader.get(ta.AV_Task__c));
									listIdsTaskOpportunityDelete.addAll(mapTaskOppIdHeaderId.get(ta.AV_Task__c));
									listTaskToDelete.add(ta);
									listTaskToDeleteIds.add(ta.Id);
									listOppNoCreateTask.add(mapTaskOppId.get(ta.AV_Task__c).AV_Opportunity__c);
								} else if (ta.AV_OrigenApp__c == AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF && !ta.IsClosed && mapTaskOppId.get(ta.AV_Task__c) != null) { // Para que modifice la tarea en caso de cambio de fecha de la oportunidad
									if (ta.ActivityDate != mapTaskOppId.get(ta.AV_Task__c).AV_Opportunity__r.AV_FechaProximoRecordatorio__c) { //Solo se modifica si es diferente la fecha de vencimiento de la tarea
										ta.ActivityDate = mapTaskOppId.get(ta.AV_Task__c).AV_Opportunity__r.AV_FechaProximoRecordatorio__c;
										listTaskChangeDate.add(ta);
										listTaskChangeDateIds.add(ta.Id);
										listOppNoCreateTask.add(mapTaskOppId.get(ta.AV_Task__c).AV_Opportunity__c);
									}
								}
							}
						}
					}
				}
				if (mapOpportunities != null && !mapOpportunities.isEmpty()) {
					for (String idOpp : mapOpportunities.keySet()) {
						if ((listOppNoCreateTask == null|| listOppNoCreateTask.isEmpty() || !listOppNoCreateTask.contains(idOpp)) && mapOpportunities.get(idOpp).agendado == false && mapOpportunities.get(idOpp).newPath == AV_AppConstants.OPP_STATUS_ENGESTION){ //Para que cree las de check on off en caso de cambio de fecha
							mapProducIdOpp.put(mapOpportunities.get(idOpp).ProdId, idOpp);
							mapCreateTaskCheckOnOff.put(idOpp, mapOpportunities.get(idOpp));
						}
					}
				}
			}
			if (listTaskOpportunityDelete != null && listIdsTaskOpportunityDelete != null && !listIdsTaskOpportunityDelete.isEmpty() && !listTaskOpportunityDelete.isEmpty()) { //Eliminacion de las tarea-oportunidades check-on off
				List<AV_CustomActivityOpportunity__c> listIdsTaskOpportunityDeleteAdd = [SELECT OwnerId, RecordTypeId, AV_ExternalID__c, AV_Opportunity__c, AV_Task__c, AV_OrigenApp__c, AV_Amount__c, AV_Commentary__c, AV_Concepto1__c, AV_Concepto2__c, AV_Concepto3__c, AV_Concepto4__c, AV_Concepto5__c, AV_DischargeDate__c, AV_DueDate__c, AV_Entity__c, AV_FeeAmount__c, AV_Gestor__c, AV_HoldingAnotherEntity__c, AV_IsMain__c, AV_NextEventDate__c, AV_Priority__c, AV_Product__c, AV_ReviewDate__c, AV_Stage__c, AV_TypeOfInterest__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, AV_WarningDate__c, AV_LicensePlate__c, AV_IncludeInPrioritizingCustomers__c, AV_FechaVencimiento__c, AV_ActivityDate__c, AV_Status__c, AV_Resolucion__c, AV_Channel__c, AV_AmountEuro__c, AV_ByProduct__c, AV_MarginEuro__c FROM AV_CustomActivityOpportunity__c WHERE Id IN :listIdsTaskOpportunityDelete];
				if (listIdsTaskOpportunityDeleteAdd != null && !listIdsTaskOpportunityDeleteAdd.isEmpty()) {
					List<AV_CustomActivityOpportunity__c> listTaskOppBack = new List<AV_CustomActivityOpportunity__c>();
					for (AV_CustomActivityOpportunity__c taOpp : listIdsTaskOpportunityDeleteAdd) {
						listTaskOppBack.add(AV_ReportAppointment_Controller.structureTaskOppInsertBack(taOpp));
					}
					listTaskOppDeleteOld.addAll(listTaskOppBack); //lista de tareas-opp old
				}
			}
			if (listTaskToDelete != null && listTaskToDeleteIds != null && !listTaskToDeleteIds.isEmpty() && !listTaskToDelete.isEmpty()) {
				List<Task> listTaskToDeleteIdsAdd = [SELECT RecordTypeId, WhoId, WhatId, Subject, ActivityDate, Status, Priority, OwnerId, Description, ReminderDateTime, IsReminderSet,AV_ALVEN__c, AV_CodigoGestorAsignado__c,   AV_NoGestionable__c, AV_Type__c, AV_ExternalID__c, AV_ConVenta__c, AV_Task__c, AV_Tipo__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, AV_OrigenApp__c, AV_BranchPhysicalMeet__c, AV_ColorEtiqueta__c, AV_DurationToNoticeToManager__c, AV_FechaFinAccionComercial__c, AV_Center__c, AV_PrioritizingSort__c, AV_FechaInicioVigencia__c, AV_Chanel__c, AV_PEA__c, AV_Purpose__c, AV_IdDelActaMifid__c, AV_CenterRtIndex__c, AV_PriorityTask__c, AV_AssociatedOpportunityId__c, AV_SurveyValue__c, AV_PEA2__c, AV_OrigenAct__c, AV_VisiblePorElClienteEnNow__c, AV_Case__c FROM Task WHERE Id IN :listTaskToDeleteIds];
				if (listTaskToDeleteIdsAdd != null && !listTaskToDeleteIdsAdd.isEmpty()) {
					List<Task> listTaskBack = new List<Task>();
					for (Task ta : listTaskToDeleteIdsAdd) {
						mapNewHeader.put(ta.AV_ExternalID__c,ta.AV_Task__c);
						ta.AV_Task__c = null;
						listTaskBack.add(AV_ReportAppointment_Controller.structureTaskInsertBack(ta));
					}
					listTaskDeleteOld.addAll(listTaskBack); //lista de tareas old
				}
			}
			if (listTaskChangeDate != null && listTaskChangeDateIds != null && !listTaskChangeDateIds.isEmpty() && !listTaskChangeDate.isEmpty()) { //update task Due Date Check on off
				if (listTaskChangeDateIds != null && !listTaskChangeDateIds.isEmpty()) {
					List<Task> listTaskChangeDateIdsAdd = [SELECT Id, ActivityDate FROM Task WHERE Id IN :listTaskChangeDateIds];
					if (listTaskChangeDateIdsAdd != null && !listTaskChangeDateIdsAdd.isEmpty()) {
						listTaskUpdateOld.addAll(listTaskChangeDateIdsAdd); //lista de tareas old
					}
				}
				for(Task ta : listTaskChangeDate) {
					ta.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
				}
			}
			//Creaccion del evento
			if (event != null && event.activityDateTime != null) {
				Database.SaveResult sr = Database.insert(createEvent(event,nameOppMain),false);
				if(!sr.isSuccess()) {
					result = sr.getErrors()[0].getMessage();
				} else {
					resultsEventTask.add(sr.getId());  
					listIdsEventInsert.add(sr.getId());
				}
			}
			//Creaccion de las tareas de check on off
			List<Task> recordsToInsert = new List<Task>();
			if(hasCustomPermission){
				if (mapProducIdOpp != null && mapCreateTaskCheckOnOff != null) {
					List<Product2> listproducts = [Select Id, Name from Product2 where Id in :mapProducIdOpp.keySet()];
					if (listproducts != null && !listproducts.isEmpty()) {
						for (Product2 pro : listproducts) {
							mapProducIdName.put(pro.Id,pro.Name);
							mapProducNameId.put(pro.Name,pro.Id);
						}
						if (mapProducIdName != null && !mapProducIdName.isEmpty()) {
							RecordType rtTask = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK,AV_AppConstants.TASKINICIATIVA_RT);
							for(String oppId : mapCreateTaskCheckOnOff.keySet()){ // Tareas de check on off
								Task nextRecord = new Task();
								nextRecord.RecordTypeId = rtTask.Id;
								nextRecord.WhatId = task.accountId;
								nextRecord.Status = 'Open';
								nextRecord.Priority = 'A';
								nextRecord.ActivityDate = mapCreateTaskCheckOnOff.get(oppId).proximaGestion;
								nextRecord.Subject = mapProducIdName.get(mapCreateTaskCheckOnOff.get(oppId).ProdId);
								nextRecord.AV_OrigenApp__c= AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF;
								recordsToInsert.add(nextRecord);
							}
						}
					}
				}
			}
			if(recordsToInsert != null && !recordsToInsert.isEmpty()) {
				List<Database.SaveResult> srs = Database.insert(recordsToInsert,false);
				for(Database.SaveResult res : srs){
					if(!res.isSuccess()) {
						result = res.getErrors()[0].getMessage();
					} else {
						resultsEventTask.add(res.getId());
						listIdsTaskInsert.add(res.getId());
					}
				}
			}
			
			List<AV_CommentsHistory__c> commHistList = new List<AV_CommentsHistory__c>();
			Set<Id> setIds = new Set<Id>();
			for (String opportunityId : opportunities.keySet()) {
				OpportunityReport oppRep = opportunities.get(opportunityId);
				String id = oppRep.id;
				setIds.add(id);
				
			}
			List<Contact> contactList = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c =:UserInfo.getUserId() ];
			headerActivitys = new Map<Id,TaskEvent>();
			if (resultsEventTask != null && !resultsEventTask.isEmpty()) {
				if (event != null && event.activityDateTime != null) {
					List<Event> listEvent = [SELECT Id, AV_Task__c, Subject, ActivityDate, AV_OrigenApp__c FROM EVENT WHERE Id IN :resultsEventTask];
					if (listEvent!=null && !listEvent.isEmpty()) {
						for(Event ev : listEvent) {
							TaskEvent te = new TaskEvent();
							te.idTaskEvent = ev.Id;
							te.taskHeader = ev.AV_Task__c;
							te.subject = ev.Subject;
							te.activityDate = ev.ActivityDate;
							te.origenApp = ev.AV_OrigenApp__c;
							headerActivitys.put(ev.Id,te);
							if(mapOldOpp != null){

							for(String oppoId : opportunities.keySet()){
								if(opportunities.get(oppoId)!= null  && (mapOldOpp.get(oppoId) == null || (mapOldOpp.get(oppoId) != null && (mapOldOpp.get(oppoId).AV_Comentarios__c != opportunities.get(oppoId).comentario || mapOldOpp.get(oppoId).StageName != opportunities.get(oppoId).newPath)))){
									AV_CommentsHistory__c ch = new AV_CommentsHistory__c();
									String comentario = (String)opportunities.get(oppoId).comentario;
									ch.AV_NewComment__c = comentario;
									ch.AV_Opportunity__c = (String)opportunities.get(oppoId).id;
									if(mapOldOpp!=null && mapOldOpp.get(oppoId)!= null){
										ch.AV_OldComment__c = (String)mapOldOpp.get(oppoId).AV_Comentarios__c;
										ch.AV_OldStatus__c = mapOldOpp.get(oppoId).StageName;
									}
									ch.AV_ModificationDate__c = System.today();
									if(contactList != null && !contactList.isEmpty()){
										ch.AV_AssignedEmployee__c = contactList[0].Id;
									}
									ch.AV_OpportunityStatus__c = (String)opportunities.get(oppoId).newPath;
									ch.AV_Event__c = (String)ev.Id;
									commHistList.add(ch);
								}
							}
						}else{
							for(String oppoId : opportunities.keySet()){
								AV_CommentsHistory__c ch = new AV_CommentsHistory__c();
								String comentario = (String)opportunities.get(oppoId).comentario;
								ch.AV_NewComment__c = comentario;
								ch.AV_Opportunity__c = (String)opportunities.get(oppoId).id;
								ch.AV_ModificationDate__c = System.today();
								if(contactList != null && !contactList.isEmpty()){
									ch.AV_AssignedEmployee__c = contactList[0].Id;
								}
								ch.AV_OpportunityStatus__c = (String)opportunities.get(oppoId).newPath;
								ch.AV_Event__c = (String)ev.Id;
								commHistList.add(ch);

							}

						}
							//
						}
					}
				}
				List<Task> listTask = [SELECT Id, AV_Task__c, Subject, ActivityDate, AV_OrigenApp__c FROM TASK WHERE Id IN :resultsEventTask];
				if (listTask!=null && !listTask.isEmpty()) {
					for(Task ta : listTask) {
						TaskEvent te = new TaskEvent();
						te.idTaskEvent = ta.Id;
						te.taskHeader = ta.AV_Task__c;
						te.subject = ta.Subject;
						te.activityDate = ta.ActivityDate;
						te.origenApp = ta.AV_OrigenApp__c;
						headerActivitys.put(ta.Id,te);
						if(ta.Id == task.idTask && !(event != null && event.activityDateTime != null)) {
							for(String oppoId : opportunities.keySet()){
                                //if(opportunities.get(oppoId)!= null  && (mapOldOpp.get(oppoId) == null || (mapOldOpp.get(oppoId) != null && (mapOldOpp.get(oppoId).AV_Comentarios__c != opportunities.get(oppoId).comentario || mapOldOpp.get(oppoId).StageName != opportunities.get(oppoId).newPath)))){
                                if(opportunities.get(oppoId)!= null  && (mapOldOpp == null || (mapOldOpp != null && mapOldOpp.get(oppoId) == null) || (mapOldOpp != null && mapOldOpp.get(oppoId) != null && (mapOldOpp.get(oppoId).AV_Comentarios__c != opportunities.get(oppoId).comentario || mapOldOpp.get(oppoId).StageName != opportunities.get(oppoId).newPath)))){
                                    AV_CommentsHistory__c ch = new AV_CommentsHistory__c();
                                    String comentario = (String)opportunities.get(oppoId).comentario;
                                    ch.AV_NewComment__c = comentario;
                                    ch.AV_Opportunity__c = (String)opportunities.get(oppoId).id;
                                    if(mapOldOpp!=null && mapOldOpp.get(oppoId)!= null){
                                        ch.AV_OldComment__c = (String)mapOldOpp.get(oppoId).AV_Comentarios__c;
                                        ch.AV_OldStatus__c = mapOldOpp.get(oppoId).StageName;
                                    }
                                    ch.AV_ModificationDate__c = System.today();
                                    if(contactList != null && !contactList.isEmpty()){
                                        ch.AV_AssignedEmployee__c = contactList[0].Id;
                                    }
                                    ch.AV_OpportunityStatus__c = (String)opportunities.get(oppoId).newPath;
                                    ch.AV_Task__c = (String)ta.Id;
                                    commHistList.add(ch);
                                }   
							}
						}
					}
				}
				if(commHistList!= null){
					List<Database.SaveResult> srCommHistList = Database.insert(commHistList,false);
					for(Database.SaveResult ur : srCommHistList){
						if(!ur.isSuccess()) {
							result = ur.getErrors()[0].getMessage();
						} else {
							listIdsCommentsHistoryInsert.add(ur.getId());
						}
					}
				}
			}

		} else if (event != null && event.activityDateTime != null) {
			Database.SaveResult sr = Database.insert(createEvent(event,null),false);
			if(!sr.isSuccess()) {
				result = sr.getErrors()[0].getMessage();
			} else {
				listIdsEventInsert.add(sr.getId());
			}
		}
		if (result != 'OK') {
			Database.rollback(sp);
		}
		TaskEventBack allBack = new TaskEventBack();
		allBack.insertTasksDelete = listTaskDeleteOld;
		allBack.insertTaskOppDelete = listTaskOppDeleteOld;
		allBack.deleteIdTasksInsert = listIdsTaskInsert;
		allBack.deleteIdEventInsert = listIdsEventInsert;
		allBack.deleteIdCommentsHistoryInsert = listIdsCommentsHistoryInsert;
		allBack.deleteManageHistInsert = listIdsManageHistInsert;
		allBack.updateTaskUpdated = listTaskUpdateOld;
		allBack.mapNewHeader = mapNewHeader;
		ResultEventTask allResult = new ResultEventTask();
		allResult.headerActivitys = headerActivitys;
		allResult.mapProducNameId = mapProducNameId;
		allResult.mapProducIdOpp = mapProducIdOpp;
		allResult.opportunities = opportunities;
		allResult.result = result;
		allResult.dataBack = allBack;
		allResult.listTaskChangeDate = listTaskChangeDate;
		allResult.listTaskToDelete = listTaskToDelete;
		allResult.listTaskOpportunityDelete = listTaskOpportunityDelete;
		return allResult;
	}

	/**
	 * @description     List to update of block task priorizador and avisos
	 * @param tasks     map of tasks update in block task priorizador and avisos
	 * @param task      task update of report
	 * @param event     event insert of report
	 * @return          list task to update
	 */
	private static List<Task> blockTask(Map<String,TaskBlockReport> tasks, TaskReport task, EventReport event){
		List<Task> taskToUpdt = new List<Task>();
		for(String tskId : tasks.keySet()){
			Task nextTsk = new Task();
			TaskBlockReport tsk = tasks.get(tskId);
			if(tsk.id != null ){
				nextTsk.Id = tsk.id;
			}
			if(tsk.status != null ){
				nextTsk.Status = tsk.status;
			}
			if(tsk.owner != null ){
				nextTsk.OwnerId = tsk.owner;
			}
			if (event != null && event.activityDateTime != null) {
				nextTsk.ActivityDate =  Date.newInstance(event.activityDateTime.year(), event.activityDateTime.month(), event.activityDateTime.day());
			} else {
				nextTsk.ActivityDate = System.today();
			}
			if(tsk.comment != null ){
				nextTsk.Description = tsk.comment;
			}
			if(event != null && event.typeEvent != null) {
				nextTsk.AV_Tipo__c = event.typeEvent;
			} else {
				nextTsk.AV_Tipo__c = task.typeTask;
			}
			// nextTsk.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
			taskToUpdt.add(nextTsk);
		}
		return taskToUpdt;
	}

	/**
	 * @description     Task to update of report
	 * @param task      task update of report
	 * @param event     event insert of report
	 * @return          task to update
	 */
	private static Task createTask(TaskReport task,EventReport event){
		Task recordToInsert = new Task();
		recordToInsert.Id = task.idTask;
		recordToInsert.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
		if(task.typeTask != null) {
			recordToInsert.AV_Tipo__c = task.typeTask;
		}
		if (task.recordType == AV_AppConstants.TASKINICIATIVA_RT || task.recordType == AV_AppConstants.TASKALERTACOM_RT) {
			if (event != null && event.activityDateTime != null) {
				recordToInsert.ActivityDate = Date.newInstance(event.activityDateTime.year(), event.activityDateTime.month(), event.activityDateTime.day());
			} else {
				recordToInsert.ActivityDate = System.today();
			}
		}
		recordToInsert.Status = task.statusTask;
		recordToInsert.AV_ContactGenerateAppointment__c = AV_AppConstants.NO_GENERATE;
		recordToInsert.Description = task.comentaryTask;
		if(task.ownerid != null){
			recordToInsert.OwnerId = task.ownerid;
		}
		return recordToInsert;
	}

	/**
	 * @description     Event to update of report
	 * @param task      task update of report
	 * @param event     event insert of report
	 * @return          event to update
	 */
	private static Event createEvent(EventReport event, String nameOppMain){
		RecordType rtEvent = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT,AV_AppConstants.EVENTCLIENTE_RT);
		Event recordToInsert = new Event();
		recordToInsert.RecordTypeId = rtEvent.Id;
		recordToInsert.WhatId = event.accountId;
		recordToInsert.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
		recordToInsert.AV_Tipo__c = event.typeEvent;
		if (event.comercial) { //Si la cita es No comercial 
			recordToInsert.Subject = 'Gestión operativa';
			recordToInsert.AV_Purpose__c ='002';
		}else if (nameOppMain != null){
			recordToInsert.Subject = nameOppMain;
			recordToInsert.AV_Purpose__c ='001'; 
		}else {
			recordToInsert.Subject = 'Gestión operativa';
			recordToInsert.AV_Purpose__c ='002';
		}
		if (event.comment != null) {
			recordToInsert.Description = event.comment;
		}
		recordToInsert.EndDateTime = event.activityDateTime;
		recordToInsert.StartDateTime = recordToInsert.EndDateTime.addMinutes(-1*(event.duracion));
		recordToInsert.AV_MemorableInterview__c = event.memorableInterview;
		if (event.office != null) {
			recordToInsert.Location = event.office;
			recordToInsert.AV_BranchPhysicalMeet__c = event.office;
		}else if (event.location != null) {
			recordToInsert.Location = event.location;
		}
		if (event.contactPerson != null) {
			recordToInsert.WhoId = event.contactPerson;
		}
		recordToInsert.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_CERRADO;
		recordToInsert.AV_ContactGenerateAppointment__c = AV_AppConstants.NO_GENERATE;
		return recordToInsert;
	}

	/**
	 * @description                 Create Task-Opportunity
	 * @param resultTaskEvent       Result of create Task or Event with headers to associate with opportunity
	 * @return                      response witn error or OK
	 */
	@AuraEnabled
	public static String createTaskOpp(String jsonResultTaskEvent, TaskReport task) {
		List<Database.SaveResult> srs;
		String result = 'OK';
		List<AV_CustomActivityOpportunity__c> cao = new List<AV_CustomActivityOpportunity__c>();
		List<AV_CustomActivityOpportunity__c> caoUpdate = new List<AV_CustomActivityOpportunity__c>();
		Savepoint sp = Database.setSavepoint();
		ResultEventTask resultTaskEvent = (ResultEventTask)Json.deserialize(jsonResultTaskEvent,ResultEventTask.class);
		String taskReport;
		if (resultTaskEvent.headerActivitys!= null && !resultTaskEvent.headerActivitys.isEmpty()) {
			for(String taskId : resultTaskEvent.headerActivitys.keySet()){
				String taskIdStr = (String) resultTaskEvent.headerActivitys.get(taskId).taskHeader;
				Boolean isTheEvent = ((Id) taskId).getSObjectType().getDescribe().getName().equals(AV_AppConstants.OBJECT_NAME_EVENT);
				if (taskIdStr != null) {
					String taskName = (String) resultTaskEvent.headerActivitys.get(taskId).subject;
					String taskOrigenApp = (String) resultTaskEvent.headerActivitys.get(taskId).origenApp;
					if (taskId == task.idTask) {
						taskReport = taskIdStr; //Para la tarea que se updatea en el reporte
					} else if (taskOrigenApp != null && taskOrigenApp != AV_AppConstants.CLIENT_REPORT_ORIGENAPP) {
						if(resultTaskEvent.mapProducNameId.get(taskName) != null){ //Para el check on off
							if (resultTaskEvent.mapProducIdOpp.get(resultTaskEvent.mapProducNameId.get(taskName)) != null) {
								cao.add(
									new AV_CustomActivityOpportunity__c(
										AV_Opportunity__c = (Id) resultTaskEvent.mapProducIdOpp.get(resultTaskEvent.mapProducNameId.get(taskName)),
										AV_Task__c = taskIdStr,
										AV_IsMain__c = true,
										AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP
									)
								);
							}
						}
					} else if (isTheEvent) {
						for (String oppoId : resultTaskEvent.opportunities.keySet()) { //Para el event que se crea en el reporte
							cao.add(
								new AV_CustomActivityOpportunity__c(
									AV_Opportunity__c = resultTaskEvent.opportunities.get(oppoId).id,
									AV_Task__c = taskIdStr,
									AV_IsMain__c = resultTaskEvent.opportunities.get(oppoId).mainVinculed,
									AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP
								)
							);
						}
					} else {
						taskReport = taskIdStr; //Para la tarea que se updatea en el reporte
					}
				}  
			}
		}
		if(taskReport != null) {
			List<AV_CustomActivityOpportunity__c> listTaskOpp = [SELECT Id, AV_Opportunity__c, AV_IsMain__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c != null AND AV_Task__c = :taskReport];
			Map<String,AV_CustomActivityOpportunity__c> mapIdsOpp = new Map<String,AV_CustomActivityOpportunity__c>();
			String mainClosed;
			Boolean otherMain = false;
			if (listTaskOpp != null && !listTaskOpp.isEmpty()) {
				for (AV_CustomActivityOpportunity__c to : listTaskOpp) {
					mapIdsOpp.put(to.AV_Opportunity__c, to);
					if (to.AV_IsMain__c) {
						mainClosed = to.Id;
					}
				}
			}
			for (String oppoId : resultTaskEvent.opportunities.keySet()) {
				if (!mapIdsOpp.containsKey(oppoId)) {
					cao.add(
						new AV_CustomActivityOpportunity__c(
							AV_Opportunity__c = resultTaskEvent.opportunities.get(oppoId).id,
							AV_Task__c = taskReport,
							AV_IsMain__c = resultTaskEvent.opportunities.get(oppoId).mainVinculed,
							AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP
						)
					);
					if (resultTaskEvent.opportunities.get(oppoId).mainVinculed) {
						otherMain = true;
					}
				} else if (mapIdsOpp != null && mapIdsOpp.get(oppoId) != null && resultTaskEvent.opportunities.get(oppoId).mainVinculed != mapIdsOpp.get(oppoId).AV_IsMain__c) {
					if (mainClosed != mapIdsOpp.get(oppoId).Id) {
						caoUpdate.add(
							new AV_CustomActivityOpportunity__c(
								Id = mapIdsOpp.get(oppoId).Id,
								AV_Task__c = taskReport,
								AV_IsMain__c = resultTaskEvent.opportunities.get(oppoId).mainVinculed,
								AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP
							)
						);
						if (resultTaskEvent.opportunities.get(oppoId).mainVinculed) {
							otherMain = true;
						}
					}
				}
			}
			if (mainClosed != null && otherMain) {
				caoUpdate.add(
					new AV_CustomActivityOpportunity__c(
						Id = mainClosed,
						AV_Task__c = taskReport,
						AV_IsMain__c = false,
						AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP
					)
				);
			}
		}
		if (cao != null && !cao.isEmpty()) {
			srs = Database.insert(cao,false);
			for(Database.SaveResult res : srs){
				if(!res.isSuccess()) {
					result = res.getErrors()[0].getMessage();
				}
			}
		}
		if (caoUpdate != null && !caoUpdate.isEmpty()) {
			srs = Database.update(caoUpdate,false);
			for(Database.SaveResult res : srs){
				if(!res.isSuccess()) {
					result = res.getErrors()[0].getMessage();
				}
			}
		}
		if (result != 'OK') {
			Database.rollback(sp);
		}
		return result;
}


	@AuraEnabled
	public static void unlinkOpp(List<Id> oppId, String recInfo) {
	String methodName = 'unlinkOpp';
		// Query AV_CustomActivityOpportunity__c records using the list of Opportunity Ids
		List<AV_CustomActivityOpportunity__c> listOppTask = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN :oppId AND AV_Task__c = :recInfo];
		

		// Change the owner
		User user = AV_AppUtilities.getUserInfo();
		List<AV_CustomActivityOpportunity__c> oppTaskToUpdate = new List<AV_CustomActivityOpportunity__c>();

		for (AV_CustomActivityOpportunity__c oppTask : listOppTask) {
			oppTaskToUpdate.add(new AV_CustomActivityOpportunity__c(Id = oppTask.Id, OwnerId = user.Id));
		}

		if (!oppTaskToUpdate.isEmpty()) {
			Database.update(oppTaskToUpdate, false);
			AV_LogDebug.printLogDebug(methodName, 'oppTaskToUpdate: ' + oppTaskToUpdate);
			List<Database.DeleteResult> listDeleteResult = Database.delete(oppTaskToUpdate, false);
			AV_AppUtilities.displayErrors(methodName, listDeleteResult);
		}
	}

	

}