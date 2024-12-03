/**********************************************************************************************************************
 Name:      AV_MassReassignOwnerBPR_Controller
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for av_MassReassignOwner LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION			USER_STORY			AUTHOR				DATE			Description
   	1.0				US692335			Elisabeth R.		16/10/2023		Init version
	1.1		        Fix			        Elisabeth R.		08/11/2023		Added assign method


***********************************************************************************************************************/
public with sharing class AV_MassReassignOwnerBPR_Controller {

	private final static Integer MAX_RESULTS 	= 10;
	private final static Integer MAX_LIMIT 		= 49900;
    private final static String  ID_GCF			= (String)[SELECT ID FROM USER WHERE ALIAS = :AV_AppConstants.AV_ALIAS_AVTF9 WITH SECURITY_ENFORCED LIMIT 1].Id;
	public static Integer numberOfRecords;

	/**
	 * @description		get BaseData
	 * @param	clientFilter	The filter for the client.
	 * @param	subjectFilter	The filter for the subject.
	 * @param	origenFilter	The filter for the origin.
	 * @param	statusFilter	The filter for the status.
	 * @param	dueDate2Filter	The filter for the secondary due date.
	 * @param	dueDateFilter	The filter for the due date.
	 * @param	employeeFilter	An array of strings representing employee filters.
	 * @param	filterList		An array of strings representing general filters.
	 * @param	fechaCierreFilter	The filter for the closing date.
	 * @param	fechaGestionFilter	The filter for the management date.
	 * @param	page	The page number for pagination.
	 * @param	myBoxFilter	The filter for "my box".
	 * @param	preconceivedFilter	A boolean filter for preconceived data.
	 * @param	targetAutoFilter	 The filter for the target automation.
	 * @param	office	The filter for the office.
	 */
    @AuraEnabled
    public static ObjectList getBaseData(String objectName, String clientFilter, String subjectFilter, String origenFilter, String[] statusFilter, Date dueDate2Filter, Date dueDateFilter, String[] employeeFilter, String filterList, Date fechaCierreFilter, Date fechaGestionFilter, String page,String myBoxFilter,Boolean preconceivedFilter,String targetAutoFilter,String office) {
		ObjectList result = new ObjectList();
	
		List<String> listEmployees = employeeFilter;	
		String employeeFilterFinal = '';
		String gestorFilter = '';
		for(String aux : listEmployees){
			employeeFilterFinal += aux + ',';
		}
		if (String.isNotBlank(employeeFilterFinal)){
			employeeFilterFinal= employeeFilterFinal.removeEnd(',');
			ObjectList ol1 = getTasksFilter(subjectFilter,origenFilter,statusFilter,dueDate2Filter, dueDateFilter, employeeFilter, clientFilter, page, myBoxFilter, preconceivedFilter, targetAutoFilter, office);
			result.add(ol1);
		}
		return result;
	}

	public class OptionsEmployee implements Comparable  {
		@AuraEnabled
		public String value;
		@AuraEnabled
		public String label;
		public OptionsEmployee(String value, String label){
			this.label = label;
			this.value = value;		
		}
		 // Implement the compareTo() method
		 public Integer compareTo(Object compareTo) {
			OptionsEmployee compareToEmp = (OptionsEmployee)compareTo;
			 if (this.label > compareToEmp.label) {
                return 1;
            }
            if (this.label == compareToEmp.label) {
                return 0;
            }
            return -1;        
		}
	}


	/**
	 * @description		Call LWC with filters Opportunity
	 * @param	clientFilter	The filter for the client.
	 * @param	subjectFilter	The filter for the subject.
	 * @param	origenFilter	The filter for the origin.
	 * @param	statusFilter	The filter for the status.
	 * @param	dueDate2Filter	The filter for the secondary due date.
	 * @param	dueDateFilter	The filter for the due date.
	 * @param	employeeFilter	An array of strings representing employee filters.
	 * @param	page	The page number for pagination.
	 * @param	myBoxFilter	The filter for "my box".
	 * @param	preconceivedFilter	A boolean filter for preconceived data.
	 * @param	targetAutoFilter	 The filter for the target automation.
	 * @param	office	The filter for the office.
	 */
	private static ObjectList getTasksFilter(String subjectFilter, String origenFilter, String[] statusFilter, Date dueDate2Filter,Date dueDateFilter, String[] employeeFilter, String clientFilter, String page,String myBoxFilter,Boolean preconceivedFilter,String targetAutoFilter,String office) {
		String methodName = 'getTasksFilter';
		String quote = '\'';
		Integer totalSize;
		
		List<String> origenFilterAll = new List<String>{
			AV_AppConstants.TASKALERTACOM_RT,
			AV_AppConstants.TASKEXPCLIENT_RT, 
			AV_AppConstants.TASKINICIATIVA_RT, 
			AV_AppConstants.TASKONBOARDING_RT, 
			AV_AppConstants.TASKPRIORIZADOR_RT};
		List<String> centerRTList = new List<String>();
		String centerRt;

		if(origenFilter =='notAssigned'){
			for(String rt : origenFilterAll){
				Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
				String centerRtItem = '\'' +office + '-' + taskRecordTypeId+ '\'';
				centerRTList.add(centerRtItem);
			}
		}else{
		Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(origenFilter).getRecordTypeId();
			centerRt = office + '-' + taskRecordTypeId;
		}

		String avQuery='Select Id, Subject, ActivityDate, AV_Valor1__c, Account.Name, Owner.Name, OwnerId, AccountId, AV_Origen__c, Account.AV_OficinaPrincipal__r.CC_Numero_Oficina_Empresa__c, Account.AV_Age__c, Account.AV_AhorroEInversion__c, Account.AV_Financiacion__c, Account.AV_Ingresos__c, Account.AV_IsPreconceived__c, Account.AV_Preconceived__c, Account.AV_Group__c, Account.AV_InterlocName__c,TOLABEL(Status), TOLABEL(Priority), TOLABEL(Account.AV_MyBox__c), TOLABEL(Account.AV_TargetAuto__c) FROM Task WHERE ';
		if(statusFilter != null){
			avQuery = avQuery + 'Status IN '+AV_AppUtilities.arrayToStringIn(statusFilter);
		}
		if(subjectFilter != null){
			avQuery = avQuery + ' AND Subject like \'%'+String.escapeSingleQuotes(subjectFilter)+'%\'';
		}
		if(dueDateFilter != null){
			DateTime f1=(DateTime)dueDateFilter;
			avQuery = avQuery + ' AND ActivityDate >= '+f1.format('yyyy-MM-dd');
		}
		if(dueDate2Filter != null){
			DateTime f2=(DateTime)dueDate2Filter;
			avQuery = avQuery + ' AND ActivityDate <= '+f2.format('yyyy-MM-dd');
		}
        if(origenFilter != null && origenFilter != 'notAssigned'){

			avQuery = avQuery + ' AND RecordType.Name = \''+origenFilter+'\'';

		}else if(origenFilter != null && origenFilter == 'notAssigned'){

			avQuery = avQuery + ' AND RecordType.Name IN '+AV_AppUtilities.arrayToStringIn(origenFilterAll);		
		}
		if(clientFilter != null) {
			avQuery = avQuery + ' AND AccountId = \''+clientFilter+'\'';
		}
		if(myBoxFilter != null) {
			if (myBoxFilter == AV_AppConstants.NOT_SELECTED) {
				avQuery = avQuery + ' AND Account.AV_MyBox__C = null';
			} else {
				avQuery = avQuery + ' AND Account.AV_MyBox__C = \''+myBoxFilter+'\'';
			}
		}
		if(preconceivedFilter != null){
			avQuery = avQuery + ' AND Account.AV_IsPreconceived__c = '+preconceivedFilter;
		}
		if(targetAutoFilter!=null) {
			if (targetAutoFilter == AV_AppConstants.NOT_SELECTED) {
				avQuery = avQuery + ' AND Account.AV_TargetAuto__c = null';
			} else {
				avQuery = avQuery + ' AND Account.AV_TargetAuto__c = \''+targetAutoFilter+'\'';
			}
		}
		if(origenFilter =='notAssigned'){
			if (office != null) {
				avQuery = avQuery + ' AND AV_CenterRtIndex__c IN '+ centerRTList ;
			}
			if(employeeFilter != null) {
				if (ID_GCF.equalsIgnoreCase(employeeFilter[0]) && employeeFilter.size()==1) {
					avQuery = avQuery + ' AND OwnerId = \''+ID_GCF+'\' AND AV_CenterRtIndex__c IN '+centerRTList;
				} else if (employeeFilter[0].contains(ID_GCF) && employeeFilter.size()==1) {
					avQuery = avQuery + ' AND AV_CenterRtIndex__c IN '+centerRTList;
				} else if (employeeFilter.contains(ID_GCF)) {
					avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_CenterRtIndex__c IN '+centerRTList;
				} else {
					avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_CenterRtIndex__c IN '+centerRTList;
				}
			} else {
				avQuery = avQuery + ' AND AV_CodigoGestorAsignado__c = null';
			}
		}else{
		if (office != null) {
			avQuery = avQuery + ' AND AV_CenterRtIndex__c = \''+ centerRt +'\'';
		}
        if(employeeFilter != null) {
			if (ID_GCF.equalsIgnoreCase(employeeFilter[0]) && employeeFilter.size()==1) {
				avQuery = avQuery + ' AND OwnerId = \''+ID_GCF+'\' AND AV_CenterRtIndex__c =\''+centerRt+'\'';
            } else if (employeeFilter[0].contains(ID_GCF) && employeeFilter.size()==1) {
				avQuery = avQuery + ' AND AV_CenterRtIndex__c = \''+centerRt+'\'';
            } else if (employeeFilter.contains(ID_GCF)) {
				avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_CenterRtIndex__c = \''+centerRt+'\'';
            } else {
				avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_CenterRtIndex__c = \''+centerRt+'\'';
            }
		} else {
			avQuery = avQuery + ' AND AV_CodigoGestorAsignado__c = null';
		}
		}

		avQuery= avQuery+' AND AV_ToDelete__C = FALSE ORDER BY Account.AV_InterlocName__c,ActivityDate  ASC NULLS FIRST LIMIT 100 OFFSET '+((Integer.valueOf(page)-1)*100);
        AV_LogDebug.printLogDebug(methodName, '-----> Query to execute: ' + avQuery);
		totalSize = '1'.equals(page) ? getNumberOfTasks(subjectFilter, origenFilter, statusFilter, dueDate2Filter, dueDateFilter, employeeFilter, clientFilter, myBoxFilter, preconceivedFilter, targetAutoFilter, office,page) : -1;
		List<Task> lista = capsulateQuery(avQuery);

		ObjectList resultObject = new ObjectList();
        Set <Id> idSet = new Set<Id>();
		if(lista != null && !lista.isEmpty()){

			for(Task t : lista){
				idSet.add(t.AccountId);
			}
			Map <Id, Account> accountIdObjMap;
			Map<Id,AV_GrupoInterlocucion__c> clientGroupMap = new Map<Id,AV_GrupoInterlocucion__c>();
			List<AV_GrupoInterlocucion__c> interlocutionGroup = [SELECT Name, AV_Numper__c, AV_Numper__r.Name, AV_IsInterlocutor__c FROM AV_GrupoInterlocucion__c WHERE AV_Numper__c IN :idSet AND RecordType.DeveloperName =: AV_AppConstants.INTERLOC_GROUP_RT];
				
			if(interlocutionGroup != null && !interlocutionGroup.isEmpty()){

				for(AV_GrupoInterlocucion__c ig : interlocutionGroup){
					clientGroupMap.put(ig.AV_Numper__c,ig);
				}

			}

			List<TaskWrapper> wrapperList = new List<TaskWrapper>();

			for(Task t: lista){

				TaskWrapper taskGroupWrapper = new TaskWrapper();
				taskGroupWrapper.ahorro = t.Account.AV_AhorroEInversion__c;
				taskGroupWrapper.financiacion = t.Account.AV_Financiacion__c;
				taskGroupWrapper.ingresos = t.Account.AV_Ingresos__c;
				taskGroupWrapper.origen = t.AV_Origen__c;
				taskGroupWrapper.accountId = t.AccountId;
				taskGroupWrapper.accountName = t.Account.Name;
				taskGroupWrapper.preconcedido = t.Account.AV_Preconceived__c;
				taskGroupWrapper.myBox = t.Account.AV_MyBox__c;
				taskGroupWrapper.targetAuto = t.Account.AV_TargetAuto__c;
                taskGroupWrapper.age = t.Account.AV_Age__c;
				taskGroupWrapper.activityDate = t.ActivityDate;
				taskGroupWrapper.taskId = t.Id;
				taskGroupWrapper.ownerId = t.OwnerId;
				taskGroupWrapper.ownerName = t.Owner.Name;
				taskGroupWrapper.priority = t.Priority;
				taskGroupWrapper.status = t.Status;
				taskGroupWrapper.subject = t.Subject;
				taskGroupWrapper.groupInterlocutor = t.Account.AV_Group__c;
				taskGroupWrapper.interlocutor = t.Account.AV_InterlocName__c;
                taskGroupWrapper.interlocutionGroup = clientGroupMap.get(t.AccountId);
				wrapperList.add(taskGroupWrapper);
			}

			resultObject = new ObjectList('Task', totalSize, wrapperList);
		}
		return resultObject;
	}

	private static List<Task> capsulateQuery(String q){//Método para pasar qualityClouds
		return (List<Task>) Database.query(q);
	}

	
	/**
	 * Gets the total number of records of the query used in getOppsTasks (without 
	 * OFFSET and LIMIT)
	 */
	public static Integer getNumberOfTasks(String subjectFilter, String origenFilter, String[] statusFilter, Date dueDate2Filter,Date dueDateFilter, String[] employeeFilter, String clientFilter, String myBoxFilter ,Boolean preconceivedFilter,String targetAutoFilter, String office,String page) {
		Integer result;

		List<String> origenFilterAll = new List<String>{AV_AppConstants.TASKALERTACOM_RT, AV_AppConstants.TASKEXPCLIENT_RT, AV_AppConstants.TASKINICIATIVA_RT, AV_AppConstants.TASKONBOARDING_RT, AV_AppConstants.TASKPRIORIZADOR_RT};
		List<String> centerRTList = new List<String>();
		String centerRt;

		if(origenFilter =='notAssigned'){
			for(String rt : origenFilterAll){
				Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
				String centerRtItem = '\'' +office + '-' + taskRecordTypeId+ '\'';
				centerRTList.add(centerRtItem);
			}
		}else{
			Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(origenFilter).getRecordTypeId();
			centerRt = office + '-' + taskRecordTypeId;
		}
		String avQuery='Select COUNT(Id) FROM Task WHERE ';
		if(statusFilter != null){
			avQuery = avQuery + 'Status IN '+AV_AppUtilities.arrayToStringIn(statusFilter);
		}
		if(subjectFilter != null){
			avQuery = avQuery + ' AND Subject like \'%'+subjectFilter+'%\'';
		}
		if(dueDateFilter != null){
			DateTime f1=(DateTime)dueDateFilter;
			avQuery = avQuery + ' AND ActivityDate >= '+f1.format('yyyy-MM-dd');
		}
		if(dueDate2Filter != null){
			DateTime f2=(DateTime)dueDate2Filter;
			avQuery = avQuery + ' AND ActivityDate <= '+f2.format('yyyy-MM-dd');
		}
        if(origenFilter != null && origenFilter != 'notAssigned'){

			avQuery = avQuery + ' AND RecordType.Name = \''+origenFilter+'\'';

		}else if(origenFilter != null && origenFilter == 'notAssigned'){

			avQuery = avQuery + ' AND RecordType.Name IN '+AV_AppUtilities.arrayToStringIn(origenFilterAll);		
		}
		if(clientFilter != null) {
			avQuery = avQuery + ' AND AccountId = \''+clientFilter+'\'';
		}
		if(myBoxFilter != null) {
			if (myBoxFilter == AV_AppConstants.NOT_SELECTED) {
				avQuery = avQuery + ' AND Account.AV_MyBox__C = null';
			} else {
				avQuery = avQuery + ' AND Account.AV_MyBox__C = \''+myBoxFilter+'\'';
			}
		}
		if(preconceivedFilter != null){
			avQuery = avQuery + ' AND Account.AV_IsPreconceived__c = '+preconceivedFilter;
		}
		if(targetAutoFilter!=null) {
			if (targetAutoFilter == AV_AppConstants.NOT_SELECTED) {
				avQuery = avQuery + ' AND Account.AV_TargetAuto__c = null';
			} else {
				avQuery = avQuery + ' AND Account.AV_TargetAuto__c = \''+targetAutoFilter+'\'';
			}
		}
		if(origenFilter =='notAssigned'){
			if (office != null) {
				avQuery = avQuery + ' AND AV_CenterRtIndex__c IN '+ centerRTList ;
			}
			if(employeeFilter != null) {
				if (ID_GCF.equalsIgnoreCase(employeeFilter[0]) && employeeFilter.size()==1) {
					avQuery = avQuery + ' AND OwnerId = \''+ID_GCF+'\' AND AV_CenterRtIndex__c IN '+centerRTList;
				} else if (employeeFilter[0].contains(ID_GCF) && employeeFilter.size()==1) {
					avQuery = avQuery + ' AND AV_CenterRtIndex__c IN '+centerRTList;
				} else if (employeeFilter.contains(ID_GCF)) {
					avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_CenterRtIndex__c IN '+centerRTList;
				} else {
					avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_CenterRtIndex__c IN '+centerRTList;
				}
			} else {
				avQuery = avQuery + ' AND AV_CodigoGestorAsignado__c = null';
			}
		}else{
		if (office != null) {
			avQuery = avQuery + ' AND AV_CenterRtIndex__c = \''+centerRt+'\'';
		}
        if(employeeFilter != null) {
			if (ID_GCF.equalsIgnoreCase(employeeFilter[0]) && employeeFilter.size()==1) {
				avQuery = avQuery + ' AND OwnerId = \''+ID_GCF+'\' AND AV_CenterRtIndex__c =\''+centerRt+'\'';
            } else if (employeeFilter[0].contains(ID_GCF) && employeeFilter.size()==1) {
				avQuery = avQuery + ' AND AV_CenterRtIndex__c = \''+centerRt+'\'';
            } else if (employeeFilter.contains(ID_GCF)) {
				avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_CenterRtIndex__c = \''+centerRt+'\'';
            } else {
				avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_CenterRtIndex__c = \''+centerRt+'\'';
            }
		} else {
			avQuery = avQuery + ' AND AV_CodigoGestorAsignado__c = null';
		}
		}
		avQuery += ' AND AV_ToDelete__C = FALSE';
		result = Integer.valueOf((capsulateCountQuery(avQuery)).get(0).get('expr0'));
		return result;
	}
    private static List<AggregateResult> capsulateCountQuery(String q){
		return (List<AggregateResult>) Database.query(q);
	}

	/**
	* @description   Assigns selected tasks to a new Contact.
	* @param objectName     The name of the object being assigned (unused in this method).
	* @param contactId      The ID of the Contact to whom the tasks will be assigned.
	* @param selectedRows   A list of sObjects representing the selected tasks to be assigned.
	*/
	@AuraEnabled
	public static String assign(String objectName , String contactId, List<String> selectedRowIds){
		Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.OptAllOrNone = false;
		dmlOptions.EmailHeader.triggerUserEmail = false;
		if (String.isNotBlank(objectName)) {
			List<Id> tasks = new List<Id>();
			for(String o : selectedRowIds){
				String tId = o;
				tasks.add(tId);
			}
			futureMassUpdateTasks(tasks,contactId);
			return String.valueOf(tasks.size());
		}
		return null;
	}

		/**
	* @description   Asynchronously updates the owner of multiple tasks to a new Contact.
	* @param tasksIds    A list of Task IDs to be updated with the new Contact as the owner.
	* @param contactId   The ID of the Contact to whom the tasks will be assigned as the new owner.
	*/
    @Future
    private static void futureMassUpdateTasks(List<Id> tasksIds, String contactId){
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.OptAllOrNone = false;
		dmlOptions.EmailHeader.triggerUserEmail = false;
        
        List<Task> tasks = new List<Task>();
        for(Id id : tasksIds){
            Task tarea = new Task(
				Id = id, 
			OwnerId = contactId);
            tasks.add(tarea);
        }
        Database.SaveResult[] srList = Database.update(tasks, dmlOptions);
        AV_AppUtilities.displayErrors('futureMassUpdateTasks', srList);
    }


	/**
	 * Type of object used to encapsulate the list of records and the total number of records
	 */
	public class ObjectList {
		@AuraEnabled
		public String objectName;
		@AuraEnabled
		public Integer totalSize;
		@AuraEnabled
		public List<TaskWrapper> recordList;

		public ObjectList(String objectName, Integer totalSize, List<TaskWrapper> recordList) {
			this.objectName = objectName;
			this.totalSize = totalSize;
			this.recordList = recordList;
		}
		public ObjectList() {
			this.objectName = '';
			this.totalSize = 0;
			this.recordList = new List<TaskWrapper>();
		}

		public void add(ObjectList ol) {
			this.totalSize += ol.totalSize;
			this.recordList.addAll(ol.recordList);
		}

		public Boolean isEmpty(){
			return this.totalSize == 0;
		}
	}


	public class TaskWrapper {
		@AuraEnabled
		public Decimal ahorro;
        @AuraEnabled
		public Decimal financiacion;
        @AuraEnabled
		public Decimal ingresos;
        @AuraEnabled
		public String origen;
        @AuraEnabled
		public String accountId;
        @AuraEnabled
		public String accountName;
        @AuraEnabled
		public Decimal preconcedido;
        @AuraEnabled
		public String myBox;
        @AuraEnabled
		public String targetAuto;
        @AuraEnabled
		public Decimal age;
        @AuraEnabled
		public Date activityDate;
        @AuraEnabled
		public String taskId;
        @AuraEnabled
		public String ownerId;
        @AuraEnabled
		public String ownerName;
        @AuraEnabled
		public String priority;
        @AuraEnabled
		public String status;
        @AuraEnabled
		public String subject;
        @AuraEnabled
		public String groupInterlocutor;
        @AuraEnabled
		public String interlocutor;
		@AuraEnabled
		public AV_GrupoInterlocucion__c interlocutionGroup;
	}
	
}