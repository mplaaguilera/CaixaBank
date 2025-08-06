/**********************************************************************************************************************
 Name:	  AV_TableGroupedByClient_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para el componente LWC AV_TableGroupedByClient
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Ainhoa				01/04/2023			Init version
	1.0			App FSC			Sandra				09/05/2023			Fix order by
	1.1         US584234        Laura  M            17/05/2023          Modified method valueOf to add all initiatives
	1.2         US646244        Oscar Moreno        07/08/2023          Add parameter origenFilter in getData method
	1.3         US646244        Oscar Moreno        07/08/2023          Add searchSubject method
	1.4         US646244        Oscar Moreno        07/08/2023          Add orderTaskByOrigen method
	1.5         US720234        Oscar Moreno        04/10/2023          Modify getData query. Change the query for search by subject
	1.6         US769122        Oscar Moreno        27/12/2023          Modify getData method
	1.7			Fix Ejec Lentas	Sandra Gómez		14/02/2024			Change method getData remove query Account	
	3.0         PPM100130465    Oscar Moreno       05/07/2024           Replace PS_OPPSRCHV2 with PS_OLDHOMETASK and revert logic
	3.1         FIX06080819     Gonzalo Avila       22/08/2024           Add AV_Center__c in query of getData method if !isBpr && !isOldHomeTsk
	3.2			PPM100492394	Luis Fernández		16/09/2024			Added new logic in getData to filter Multigestor tasks when current user is a pool user and added net method getEmployees
***********************************************************************************************************************/
public without sharing class AV_TableGroupedByClient_Controller {

	private final static Integer MAX_RESULTS 	= 10;

	public static String userId = String.valueOf(UserInfo.getUserId());

	public class TableGroupedByClientWrapper {
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String origen;
		@AuraEnabled
		public String subject;
		@AuraEnabled
		public String value1;
		@AuraEnabled
		public String value2;
		@AuraEnabled
		public String status;
		@AuraEnabled
		public Date expirationDate;
		@AuraEnabled
		public String business;
		@AuraEnabled
		public Decimal age;
		@AuraEnabled
		public Double savingsAndInvestment;
		@AuraEnabled
		public Double financing;
		@AuraEnabled
		public Double income;
		@AuraEnabled
		public Double preApproved;
		@AuraEnabled
		public String mybox;
		@AuraEnabled
		public String targetAuto;
		@AuraEnabled
		public Id accountId;
		@AuraEnabled
		public Id taskId;
		@AuraEnabled
		public String groupField;
		@AuraEnabled
		public String interlocName;
		@AuraEnabled 
		public Decimal prio;
		@AuraEnabled
		public AV_GrupoInterlocucion__c interlocutionGroup;
		@AuraEnabled
		public String gestorId;
		@AuraEnabled
		public String gestorName;
	}

	public class Filters {
		@AuraEnabled
		public String subjectFilterValue {get; set;} 
		@AuraEnabled
		public Boolean preconcedidoFilterValue {get; set;}
		@AuraEnabled
		public String myBoxFilterValue {get; set;}
		@AuraEnabled
		public String targetAutoFilterValue {get; set;}
		@AuraEnabled
		public String origenFilterValue {get; set;}
		@AuraEnabled
		public List<String> employeesFilter {get; set;}
		@AuraEnabled
		public String officeFilter {get; set;}
	}

	/**
	* @description     	get data 
	* @param filterResults
	* @param origenFilter
	*/
	@AuraEnabled(cacheable=false)
	public static List<TableGroupedByClientWrapper> getData(Filters filterResults, String [] origenFilter) {
		String methodName = 'getData';
		Boolean isBpr = FeatureManagement.checkPermission(AV_AppConstants.PS_PRIVATEBANKING);
		Boolean isOldHomeTsk = FeatureManagement.checkPermission(AV_AppConstants.PS_OLDHOMETASK);
		List <TableGroupedByClientWrapper> wrapperList = new List <TableGroupedByClientWrapper>();
		List <Id> idAccountsList = new List <Id>();
		Set <Id> idSet = new Set<Id>();
		List<String> statusList = new List<String>{AV_AppConstants.TASK_STATUS_PENDIENTE, AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL};
		List<String> recordTypeList;
		if(isOldHomeTsk){
			recordTypeList = new List<String>{ AV_AppConstants.TASKONBOARDING_RT, AV_AppConstants.TASKEXPCLIENT_RT,AV_AppConstants.TASKPRIORIZADOR_RT,AV_AppConstants.TASKALERTACOM_RT};
		}else{
			recordTypeList = new List<String>{ AV_AppConstants.TASKONBOARDING_RT, AV_AppConstants.TASKEXPCLIENT_RT};
		}
		String avQuery = 'Select Id, AV_OrigenAct__c,AV_Origen__c , AccountId, WhatId, OwnerId,Owner.Name,RecordType.Name, Subject, Status, ActivityDate, AV_Valor1__c, AV_Valor2__c,Account.AV_Priority__c,RecordType.DeveloperName, Account.Name, Account.AV_Negocio__c, Account.AV_Age__c, Account.AV_AhorroEInversion__c, Account.AV_Financiacion__c, Account.AV_Ingresos__c, Account.AV_Preconceived__c, Account.AV_IsPreconceived__c, Account.AV_MyBox__c,Account.AV_TargetAuto__c,Account.AV_Group__c,Account.AV_InterlocName__c FROM Task ';
		if(!isBpr) {
			avQuery = 'Select Id, AV_OrigenAct__c,AV_Origen__c , AccountId, WhatId, OwnerId,Owner.Name, RecordType.Name, Subject, Status, ActivityDate, AV_Valor1__c, AV_Valor2__c,Account.AV_Priority__c,RecordType.DeveloperName, Account.Name, Account.AV_Negocio__c, Account.AV_Age__c, Account.AV_AhorroEInversion__c, Account.AV_Financiacion__c, Account.AV_Ingresos__c, Account.AV_Preconceived__c, Account.AV_IsPreconceived__c, Account.AV_MyBox__c,Account.AV_TargetAuto__c FROM Task ';
		}
		if(!filterResults.employeesFilter.isEmpty()){

			String employeesArray = '(';
			for(String empId : filterResults.employeesFilter){
				employeesArray += ('\''+empId+'\',');
			}
			employeesArray = employeesArray.removeEnd(',')+')';
			avQuery = avQuery +  'WHERE Status IN ' + AV_AppUtilities.arrayToStringIn(statusList) + ' AND OwnerId IN '+employeesArray +' AND AV_ToDelete__c = FALSE';
		}else{
			return new List<TableGroupedByClientWrapper>();
		}

		List<User> userCenter = [SELECT AV_NumeroOficinaEmpresa__c,AV_Pool__c FROM USER WHERE Id = :userId];  
		if(filterResults.subjectFilterValue != null ){
			avQuery = avQuery + ' AND Subject like \'%'+ filterResults.subjectFilterValue+'%\''; 
		}
		if(origenFilter != null && !origenFilter.isEmpty()){
			if(origenFilter.contains(AV_AppConstants.TASKINICIATIVA_RT) && origenFilter.size() == 1){
				if(isOldHomeTsk){
					avQuery = avQuery + ' AND RecordType.DeveloperName  = \'' + AV_AppConstants.TASKINICIATIVA_RT + '\'' ;
					avQuery = avQuery + ' AND (ActivityDate = LAST_N_DAYS:7 OR ActivityDate = TODAY)';
				}else{
					avQuery = avQuery + ' AND RecordType.DeveloperName  = \'' + AV_AppConstants.TASKINICIATIVA_RT + '\'' ;
					avQuery = avQuery + ' AND (ActivityDate = LAST_N_DAYS:7 OR ActivityDate = TODAY) AND AV_OrigenApp__c != \'AV_SalesforceTaskOpp\' AND AV_OrigenApp__c != \'AV_SalesforceTaskOpp_Iniciativa\'';
				}
			}else if(!origenFilter.contains(AV_AppConstants.TASKINICIATIVA_RT)){
				if(isOldHomeTsk){
					avQuery = avQuery + ' AND RecordType.DeveloperName  IN ' + AV_AppUtilities.arrayToStringIn(origenFilter);
					avQuery = avQuery + ' AND (ActivityDate = TODAY OR ActivityDate = NEXT_N_DAYS:180)';
				}else{
					if(origenFilter.contains(AV_AppConstants.OPPALERTACOM_RT)){
						avQuery = avQuery + ' AND RecordType.DeveloperName = \'' + AV_AppConstants.OPPALERTACOM_RT+ '\'  AND AV_OrigenApp__c != \'AV_SalesforceTaskOpp_Iniciativa\' AND AV_OrigenApp__c != \'AV_CallMe\' ';
					}else{
						avQuery = avQuery + ' AND RecordType.DeveloperName  IN ' + AV_AppUtilities.arrayToStringIn(origenFilter);
						avQuery = avQuery + ' AND (ActivityDate = TODAY OR ActivityDate = NEXT_N_DAYS:180)';
					}
				}
			}else{
				origenFilter.remove(origenFilter.indexOf(AV_AppConstants.TASKINICIATIVA_RT));
				avQuery = avQuery + ' AND ((RecordType.DeveloperName IN ' + AV_AppUtilities.arrayToStringIn(origenFilter) ; 
				avQuery = avQuery + ' AND (ActivityDate = TODAY OR ActivityDate = NEXT_N_DAYS:180)) OR (RecordType.DeveloperName = \'' + AV_AppConstants.TASKINICIATIVA_RT + '\'' ;
				avQuery = avQuery + ' AND (ActivityDate = LAST_N_DAYS:7 OR ActivityDate = TODAY)))'; 
			}
		}else{
			avQuery = avQuery + ' AND ((RecordType.DeveloperName IN ' + AV_AppUtilities.arrayToStringIn(recordTypeList) ; 
			avQuery = avQuery + ' AND (ActivityDate = TODAY OR ActivityDate = NEXT_N_DAYS:180)) OR (RecordType.DeveloperName = \'' + AV_AppConstants.TASKINICIATIVA_RT + '\'' ;
			if(isOldHomeTsk){
				avQuery = avQuery + ' AND (ActivityDate = LAST_N_DAYS:7 OR ActivityDate = TODAY)))';
			}else{
				avQuery = avQuery + ' AND (ActivityDate = LAST_N_DAYS:7 OR ActivityDate = TODAY) AND AV_OrigenApp__c != \'AV_SalesforceTaskOpp\' AND AV_OrigenApp__c != \'AV_SalesforceTaskOpp_Iniciativa\') OR(RecordType.DeveloperName IN (\'' + AV_AppConstants.OPPALERTACOM_RT+ '\') AND AV_OrigenApp__c != \'AV_SalesforceTaskOpp_Iniciativa\' AND AV_OrigenApp__c != \'AV_CallMe\' ))'; 
			}
		}
		
		if(!isBpr && !isOldHomeTsk){
			avQuery = avQuery + ' AND AV_Center__c = \''+ filterResults.officeFilter + '\''; 
		}
		
		if(isBpr){
			avQuery = avQuery + ' ORDER BY Account.AV_InterlocName__c , Account.AV_Priority__c  DESC, Subject ASC';
		}else{
			avQuery = avQuery + ' ORDER BY Account.AV_Priority__c DESC, Subject ASC';
		}
		AV_LogDebug.printLogDebug(methodName, 'QUERY--> ' + avQuery);
		List<Task> listOfTask = capsulateQuery(avQuery);
		List<Task> listTaskToProcess = new List<Task>();
		listOfTask = orderTaskByOrigen(listOfTask);
		if(listOfTask != null && !listOfTask.isEmpty()){
			for(Task t : listOfTask){
				if (idSet.contains(t.AccountId) && t.AccountId != null) {
					idSet.add(t.AccountId);
				}
				if (t.AccountId != null) {
					listTaskToProcess.add(t);
				}
			}
			if (listTaskToProcess != null && !listTaskToProcess.isEmpty()) {
				Map<Id,AV_GrupoInterlocucion__c> clientGroupMap = new Map<Id,AV_GrupoInterlocucion__c>();
				if(isBpr && idSet != null && !idSet.isEmpty()){
					List<AV_GrupoInterlocucion__c> interlocutionGroup = [SELECT Name, AV_Numper__c, AV_Numper__r.Name, AV_IsInterlocutor__c FROM AV_GrupoInterlocucion__c WHERE AV_Numper__c IN :idSet AND RecordType.DeveloperName =: AV_AppConstants.INTERLOC_GROUP_RT];
					if(interlocutionGroup != null && !interlocutionGroup.isEmpty()){
						for(AV_GrupoInterlocucion__c ig : interlocutionGroup){
							clientGroupMap.put(ig.AV_Numper__c,ig);
						}
					}                                             
				}
				DescribeFieldResult fieldResultStatus = Task.Status.getDescribe();
				DescribeFieldResult fieldResultMyBox = Account.AV_MyBox__c.getDescribe();
				DescribeFieldResult fieldResultTarget = Account.AV_TargetAuto__c.getDescribe();
				DescribeFieldResult fieldResultNegocio = Account.AV_Negocio__c.getDescribe();
				List<Schema.PicklistEntry> picklistValuesStatus = fieldResultStatus.getPicklistValues();
				List<String> picklistValuesOrigen = new List<String>();
				picklistValuesOrigen.add('Alerta Comercial');
				picklistValuesOrigen.add('Experiencia Cliente');
				picklistValuesOrigen.add('Iniciativa Gestor/a');
				picklistValuesOrigen.add('Priorizador');
				picklistValuesOrigen.add('AV_Onboarding');
				List<Schema.PicklistEntry> picklistValuesMyBox = fieldResultMyBox.getPicklistValues();
				List<Schema.PicklistEntry> picklistValuesTarget = fieldResultTarget.getPicklistValues();
				List<Schema.PicklistEntry> picklistValuesNegocio = fieldResultNegocio.getPicklistValues();
				Decimal score = getScore();
				for(Task t: listTaskToProcess) {
					
					TableGroupedByClientWrapper wrapper = new TableGroupedByClientWrapper();
					if(t.AccountId != null){
						if( (filterResults.preconcedidoFilterValue != null && filterResults.preconcedidoFilterValue != t.Account.AV_IsPreconceived__c) || (filterResults.myBoxFilterValue != null && filterResults.myBoxFilterValue != t.Account.AV_MyBox__c) || (filterResults.targetAutoFilterValue != null && filterResults.targetAutoFilterValue != t.Account.AV_TargetAuto__c) ){
							continue;
						}else{
							wrapper.gestorId = t.OwnerId;
							wrapper.gestorName = t.Owner.Name;
							wrapper.name = t.Account.Name;
							wrapper.subject = t.Subject;
							wrapper.value1 = t.AV_Valor1__c;
							wrapper.value2 = t.AV_Valor2__c;
							wrapper.expirationDate = t.ActivityDate;
							wrapper.accountId = t.AccountId;
							wrapper.taskId = t.Id;
							wrapper.prio = t.Account.AV_Priority__c;
							if(isBpr){
								wrapper.groupField = t.Account.AV_Group__c;
								wrapper.interlocName = t.Account.AV_InterlocName__c;
								wrapper.interlocutionGroup = clientGroupMap.get(t.AccountId);
							}
							wrapper.origen = t.AV_Origen__c;
							String picklistValueStatus = (String) t.get(Task.Status);
							for (Schema.PicklistEntry entry : picklistValuesStatus) {
								if (entry.getValue().equals(picklistValueStatus)) {
									wrapper.Status = entry.getLabel();
									break;
								}
							}
							wrapper.age = t.Account.AV_Age__c;
							if(t.Account.AV_AhorroEInversion__c != null){
							wrapper.savingsAndInvestment = t.Account.AV_AhorroEInversion__c;
							}
							if(t.Account.AV_Financiacion__c != null){
							wrapper.financing = t.Account.AV_Financiacion__c;
							}
							if(t.Account.AV_Ingresos__c != null){
							wrapper.income = t.Account.AV_Ingresos__c;
							}
							if(t.Account.AV_Preconceived__c != null){
							wrapper.preApproved = t.Account.AV_Preconceived__c;
							}
							String picklistValueMyBox = (String) t.Account.AV_MyBox__c;
							for (Schema.PicklistEntry entry : picklistValuesMyBox) {
								if (entry.getValue().equals(picklistValueMyBox)) {
									wrapper.mybox = entry.getLabel();
									break;
								}
							}
							String picklistValueTarget = (String) t.Account.AV_TargetAuto__c;
							for (Schema.PicklistEntry entry : picklistValuesTarget) {
								if (entry.getValue().equals(picklistValueTarget)) {
									wrapper.targetAuto = entry.getLabel();
									break;
								}
							}
							String picklistValueNegocio = (String) t.Account.AV_Negocio__c;
							for (Schema.PicklistEntry entry : picklistValuesNegocio) {
								if (entry.getValue().equals(picklistValueNegocio)) {
									wrapper.business = entry.getLabel();
									break;
								}
							}
							String picklistValue = (String) t.get(Task.AV_Origen__c);
							for (String entry : picklistValuesOrigen) {
								if (entry.equals(picklistValue)) {
									wrapper.origen = entry;
									break;
								}
							}
							idAccountsList.add(t.AccountId);
							wrapperList.add(wrapper);
						}
					}
				}
			}
			return wrapperList;
		}else{
			return null;
		}
	}

	private static List<Task> capsulateQuery(String q){
		return (List<Task>) Database.query(q);
	}

	/**
	* @description     	get score of alerta comercial of task
	*/
	public static Decimal getScore(){
		AV_Score__c scoreTaskAlert = [SELECT AV_Score__c  FROM AV_Score__c WHERE AV_Object__c = 'Task' AND AV_RecordType__c = :AV_AppConstants.TASKALERTACOM_RT LIMIT 1];
		if(scoreTaskAlert != null){
			return scoreTaskAlert.AV_Score__c;
		}else{
			return null;
		}
	}

	/**
	* @description     	order a list of task by Origen 
	* @param task List of Task
	*/
	public static List<Task> orderTaskByOrigen(List<Task> tasks){
		Map<Decimal,List<Task>> mapTaskPriority = new Map<Decimal,List<Task>>();
		List<Task> result = new List<Task>();
		if(tasks!=null){
			for(Task t:tasks){
				if(mapTaskPriority.keySet().contains(t.Account.AV_Priority__c)){     
					mapTaskPriority.get(t.Account.AV_Priority__c).add(t);       
				}else{
					mapTaskPriority.put(t.Account.AV_Priority__c,new List<Task>{t});
				}
			}
			List<String> ordenTareas = new List<String>{'Alerta Comercial', 'Experiencia de Cliente', 'Iniciativa gestor', 'Priorizador', 'Onboarding'};
			Map<String,Integer> orderRt = new Map<String,Integer>{
				AV_AppConstants.TASKALERTACOM_RT=> 1,
				AV_AppConstants.TASKEXPCLIENT_RT=> 2,
				AV_AppConstants.TASKINICIATIVA_RT=> 3,
				AV_AppConstants.TASKPRIORIZADOR_RT=> 4,
				AV_AppConstants.TASKONBOARDING_RT=> 5
			};
			for(Decimal ky : mapTaskPriority.keySet()){
				List<Task> tskPrio = mapTaskPriority.get(ky);
				if(tskPrio != null && tskPrio.size()>1){
					List<OrderByRt> listWrapperOrder = new List<OrderByRt>();
					for(Task tskToOrder : tskPrio){
						listWrapperOrder.add(new OrderByRt(tskToOrder,orderRt.get(tskToOrder.RecordType.DeveloperName)));
					}
					listWrapperOrder.sort();
					tskPrio.clear();
					for(OrderByRt order : listWrapperOrder){
						tskPrio.add(order.tsk);
					}
				}
			}
			List<Decimal> mapKeysParsedList = new List<Decimal>(mapTaskPriority.keySet());
			mapKeysParsedList.sort();
			for(Integer i=mapKeysParsedList.size()-1;i>=0;i--){
				result.addAll(mapTaskPriority.get(mapKeysParsedList.get(i)));
			}
			return result;
		}
		return null;
	}
/**
	 * @description		Lookup of User Assigment
	 * @param officeFilterData The filter for the office.
	 */
	@AuraEnabled
	public static List<OptionsEmployee> getEmployees(String officeFilterData){
		String  idGcf = (String) [SELECT Id FROM User WHERE Alias = :AV_AppConstants.AV_ALIAS_AVTF9 LIMIT 1].Id;	
		String allLabel = 'all';
		Integer maxLimit = 49900;
		List<OptionsEmployee> employees = new List<OptionsEmployee>();
		List<OptionsEmployee> employeesSorted = new List<OptionsEmployee>();
		List<Id> employeesId = new List<Id>();
		User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId()];
		String bancaPrivadaId = AV_PoolEvents_Controller.getCurrentDT(emp.AV_NumeroOficinaEmpresa__c);
		if (String.isNotBlank(officeFilterData)) {
			String[] data = officeFilterData.split('\\{\\|}');
			if (data.size() > 1) {
			
				Set<String> allRts = new Set<String>{
					AV_AppConstants.TASKINICIATIVA_RT,
					AV_AppConstants.TASKALERTACOM_RT,
					AV_AppConstants.TASKAVISOS_RT,
					AV_AppConstants.TASKCONTACTGCF_RT,
					AV_AppConstants.TASKEXPCLIENT_RT,
					AV_AppConstants.TASKONBOARDING_RT,
					AV_AppConstants.TASKPRIORIZADOR_RT,
					AV_AppConstants.TASKCPENDIENTE_RT
				};				
				List<RecordType> listRt = new List<RecordType>();
				
				Set<Id> setIdsRts = (data[1] != allLabel) ? AV_AppUtilities.getRecordTypeIdsInSet(new Set<String>(data[1].split(','))) : AV_AppUtilities.getRecordTypeIdsInSet(allRts);			
			
				AggregateResult[] taskWithCenter = [
					SELECT OwnerId, Owner.Name
					FROM Task
					WHERE AV_Center__c = :data[0] AND Owner.Profile.Name = :AV_AppConstants.AV_PROFILE AND RecordTypeId IN :setIdsRts AND OwnerId != :bancaPrivadaId
					GROUP BY OwnerId, Owner.Name
				];
				if (!taskWithCenter.isEmpty()) {
					for (AggregateResult tsk : taskWithCenter) {
						employeesId.add((Id)tsk.get('OwnerId'));
						employeesSorted.add(new OptionsEmployee((Id)tsk.get('OwnerId'),(String)tsk.get('Name')));
					}
				}
			} else if (data.size() == 1) {

				List<User> searchResults = [
					SELECT Id, Name, AV_NumeroOficinaEmpresa__c FROM User WHERE Profile.Name = :AV_AppConstants.AV_PROFILE
					AND AV_NumeroOficinaEmpresa__c LIKE :('%' + officeFilterData + '%') 
					LIMIT :maxLimit
				];
				if(!searchResults.isEmpty() && searchResults != null){
					for(User u : searchResults){
						employeesId.add(u.Id);
						employeesSorted.add(new OptionsEmployee(u.Id,u.Name));
					}
				}
			}
		}
		if(employeesId.size() > 1) {
			String employeesAlls=string.join(employeesId,',');
			employees.add(new OptionsEmployee(idGcf+','+employeesAlls,'Todos-' + officeFilterData.split('\\{\\|}')[0]));
		}
		employees.add(new OptionsEmployee(idGcf, AV_AppConstants.SINGESTOR_EAP_CENTRO + officeFilterData.split('\\{\\|}')[0]));
		employees.add(new OptionsEmployee(bancaPrivadaId,AV_AppConstants.MULTIGENAME));

		if(employeesId.size() > 0){
			employeesSorted.sort();
			employees.addAll(employeesSorted);
		}
		return employees;		
	}
	private class OrderByRt implements Comparable{
		public Task tsk;
		public Integer order;
		public OrderByRt(Task tsk,Integer order){
			this.tsk = tsk;
			this.order = order;
		}
		public Integer compareTo(Object compareTo) {
			OrderByRt compareToEmp = (OrderByRt) compareTo;
			if (this.order > compareToEmp.order) {
				return 1;
			}
			if (this.order == compareToEmp.order) {
				return 0;
			}
			return -1;        
		}
	}

	
	/**
	* @description Object to options employee in filters more
	*/
	public class OptionsEmployee implements Comparable  {
		@AuraEnabled
		public String value;
		@AuraEnabled
		public String label;
		public OptionsEmployee(String value, String label){
			this.label = label;
			this.value = value;		
		}
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
}