/**********************************************************************************************************************
 Name:      AV_MassReassignOwner_Controller
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for av_MassReassignOwner LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION			USER_STORY			AUTHOR				DATE			Description
   	1.0				US164351			Álvaro López		03/02/2021		Init version
	1.1				FIX					Jash				18/05/2021		Fix problem with mass emails after change owner in Task's
	1.2				FIX					Sandra Gómez		20/05/2021		Add field Account and fixes
	1.3				US258535			Sandra Gómez		02/09/2021		Add options TODOS and Sin gestor
	1.4				Fix Performance		Carolina Alonso		21/10/2021		Add condition in methods searchAccount, searchProduct and search to fix performance
	1.5				US268502			Daniel Rodriguez	01/02/2022		Add method searchUser for report Opportunity
	1.6				US293288			Víctor Santiago		03/02/2022		Optimized query in search method and increased MAX_RESULTS
	1.7				US316110			Víctor Santiago		08/02/2022		Modified method getOppsFilter to avoid opps with ToDelete==true
	1.8		        AV_Query IT	        Daniel Rodríguez	07/02/2022	    Change AV_Query to SOQL for User, Account, Contact
	1.9		        Org Health	        Víctor Santiago		29/03/2022	    Modified for pagination: getBaseData, getOpps, getOppsFilter, getTasks, getTasksFilter, getNumberOfOpps, getNumberOfTasks, ObjectList
	1.10		    Org Health	        Víctor Santiago		11/04/2022	    Added limit in getNumberOfOpps and getNumberOfTasks to avoid runtime error with gestor
	2.0				Fix Buscador		Sandra Gómez		10/06/2022		Change all and AV_Query
	2.1				US455996	  		Luis Fernández    	27/10/2022		Added "AV_ToDelete__C = FALSE" to query condition + Fixed Quality Clouds
	2.2             US457841            Elisabeth Rodríguez 28/11/2022      Changed AV_Center__c to AV_CenterRtIndex__c, employeeFilter conditions and oficina parameter
	2.3				US533963			Luis Fernández		04/04/2023		Changed query inside the method getOffices in order to retrieve DAN office.
	2.4				US582839			Elisabeth Rodríguez	05/03/2023		Changed queries to add 'notAssigned' value to origenFilter
	2.5             DE79573             Oscar Moreno        07/07/2023      Change searchOffice method to show the assigned office and lower offices
	2.6         	US587408        	Ángel Medina        14/07/2023  	Added AV_Group__c and AV_InterlocName__c to retrieved fields
	2.7		        US692335			Elisabeth R.		16/10/2023	    Added hasCustomPermission method

***********************************************************************************************************************/
public with sharing class AV_MassReassignOwner_Controller {

	private final static Integer MAX_RESULTS 	= 10;
	private final static Integer MAX_LIMIT 		= 49900;
    private final static String  ID_GCF			= (String)[SELECT ID FROM USER WHERE ALIAS = :AV_AppConstants.AV_ALIAS_AVTF9 LIMIT 1].Id;
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
	 * @description		get Employees
	 * @param	office	The filter for the office.
	 */
	@AuraEnabled
	public static List<OptionsEmployee> getEmployees(String oficina){

		List<OptionsEmployee> employees = new List<OptionsEmployee>();
		List<OptionsEmployee> employeesSorted = new List<OptionsEmployee>();
		List<Id> employeesId = new List<Id>();
		User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId()];

		if (String.isBlank(oficina)) {
			return null;
		}else if (String.isNotBlank(oficina)) {
			String[] data = oficina.split('\\{\\|}');

			if (data.size() > 1) {

				Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(data[2]).getRecordTypeId();
				String centerRt = data[0] + '-' + taskRecordTypeId;

				String profileId = [
					SELECT Id
					FROM Profile
					WHERE Name = :AV_AppConstants.AV_PROFILE
				].Id;
				List<RecordType> listRT = [
					SELECT Id, DeveloperName
					FROM RecordType
					WHERE Name = :data[2]
					
				];
				Set<Id> setIdsRts = (new Map<Id,RecordType>(listRT)).keySet().clone();				
				AggregateResult[] tasksWithCenter = [
					SELECT OwnerId, Owner.Name
					FROM Task
					WHERE AV_CenterRtIndex__c = :centerRt AND Owner.ProfileId = :profileId AND Status = :data[1] AND RecordTypeId IN :setIdsRts
					
					GROUP BY OwnerId, Owner.Name
				];
		
				if (!tasksWithCenter.isEmpty()) {
					for (AggregateResult t : tasksWithCenter) {
							employeesId.add((Id)t.get('OwnerId'));
							employeesSorted.add(new OptionsEmployee((Id)t.get('OwnerId'),(String)t.get('Name')));
					}
				}

			}else if(data.size() == 1){

				List<List<SObject>> searchResults = [
					FIND :oficina
					IN ALL FIELDS
					RETURNING User(Id, Name, AV_NumeroOficinaEmpresa__c WHERE IsActive = true)
					LIMIT :MAX_LIMIT
				];
				List<User> emps = (List<User>) searchResults[0];
				if(!emps.isEmpty() && emps != null){
					for(User u : emps){
						employeesId.add(u.Id);
						employeesSorted.add(new OptionsEmployee(u.Id,u.Name));
					}
				}
			}
		}
		

		String employeesAlls=string.join(employeesId,',');
		if(employeesId.size()>1) {
			employees.add(new OptionsEmployee(ID_GCF+','+employeesAlls,'TODOS - CENTRO '+oficina.split('\\{\\|}')[0]));
		}
		employees.add(new OptionsEmployee(ID_GCF,'Sin Gestor / Eap - CENTRO '+oficina.split('\\{\\|}')[0]));
		employeesSorted.sort();
		employees.addAll(employeesSorted);
		return employees;		

	}

	public class OptionsOffice {
		@AuraEnabled
		public String value;
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String code;
		public OptionsOffice(String value, String label, String code){
			this.value = value;
			this.label = label;
			this.code = code;
		}
	}

	/**
     * @description             Gets the inferior centers from the immediately superior centers list
     * @param superiorCenters   List of  superior centers
	 * @param acc   current account
     */
    public static Id getOfficePermission(List<Id> superiorCenters,Account acc) {
		Id officeId;
		List<Account> inferiorCenters = [SELECT Id, Name, CC_Numero_Oficina__c, AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c,AV_CentroSuperior__r.AV_CentroSuperior__c, AV_CentroSuperior__c, CC_Numero_Oficina_Empresa__c FROM Account WHERE (AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c IN :superiorCenters OR AV_CentroSuperior__r.AV_CentroSuperior__c IN :superiorCenters OR AV_CentroSuperior__c IN :superiorCenters) AND Id = :acc.Id LIMIT 1];
		if (inferiorCenters!= null && !inferiorCenters.isEmpty()) {
			for (Id off : superiorCenters) {
				if (off == inferiorCenters[0].AV_CentroSuperior__c) {
					officeId = off;
				} else if (off == inferiorCenters[0].AV_CentroSuperior__r.AV_CentroSuperior__c) {
					officeId = off;
				} else if (off == inferiorCenters[0].AV_CentroSuperior__r.AV_CentroSuperior__r.AV_CentroSuperior__c) {
					officeId = off;
				}
			}
		} else {
			for (Id off : superiorCenters) {
				if (acc.Id == off) {
					officeId = off;
				}
			}
		}
		return officeId;
    }

	/**
	 * @description		Get Ids for Inferior Center
	 * @param us  Individual user
	 */
	public static Set<Id> getInferiorCenterIds(User us) {
		List<Account> offices = new List<Account>();
		List<Account> inferiorOffices = new List<Account>();
		List<Id> ids = new List<Id>();
		Set<Id> result = new Set<Id>();
		Account userCenter = [
            SELECT Id, Name, CC_Numero_Oficina__c, AV_CentroSuperior__c, CC_Numero_Oficina_Empresa__c
            FROM Account
            WHERE CC_Numero_Oficina_Empresa__c = :us.AV_NumeroOficinaEmpresa__c
        ];
		Map<String,String> mapOfficeUsCedido = new Map<String,String>();
		List<AV_OfficePermission__c> officePermList = [SELECT Id , name,AV_OficinaCedida__c,AV_Assigner__c,AV_Assigner__r.AV_Funcion__c,AV_UsuarioCedido__c FROM AV_OfficePermission__c  WHERE AV_UsuarioCedido__c =: UserInfo.getUserId() AND AV_FinalPermiso__c >=: Date.Today()];
		List<Id> listOffice = new List<Id>();
		String funcion;
		if(officePermList!= null){
			for(AV_OfficePermission__c offPerm : officePermList){
				if(offPerm.AV_OficinaCedida__c!=null){
					mapOfficeUsCedido.put(offPerm.AV_OficinaCedida__c,offPerm.AV_Assigner__r.AV_Funcion__c);
					listOffice.add(offPerm.AV_OficinaCedida__c);
				}
			}
			String officePermission = getOfficePermission(listOffice,userCenter);
			if (officePermission != null && mapOfficeUsCedido.get(officePermission) != null) {
				funcion = mapOfficeUsCedido.get(officePermission);
			}
		}
		if(funcion == null) {
			funcion = String.isNotBlank(us.AV_Funcion__c) ? us.AV_Funcion__c : '';
		}
		ids.add(userCenter.Id);
		if (AV_AppConstants.FUNCION_DT.equals(funcion)) {
			offices.addAll(getInferiorCenters(ids));
		}
		if (AV_AppConstants.FUNCION_DC.equals(funcion) || !offices.isEmpty()) {
			if (!offices.isEmpty()) {
				ids.clear();
				ids.addAll(getCenterIds(offices));
				offices.clear();
			}
			inferiorOffices.addAll(getInferiorCenters(ids));
		}
		if (AV_AppConstants.FUNCION_DAN.equals(funcion) || !inferiorOffices.isEmpty()) {
			if (!inferiorOffices.isEmpty()) {
				ids.clear();
				ids.addAll(getCenterIds(inferiorOffices));
				offices.clear();
			}
			offices.addAll(getInferiorCenters(ids));
		}
		if (!offices.isEmpty()) {
			for (Account a : offices) {
				result.add(a.Id);
			}
		} else {
			result.add(userCenter.Id);
		}
		return result;
	}

	/**
	 * @description		Get Ids for Inferior Center
	 */
	public static Set<Id> getInferiorCenterIds() {
		List<Account> offices = new List<Account>();
		List<Account> inferiorOffices = new List<Account>();
		List<Id> ids = new List<Id>();
		Set<Id> result = new Set<Id>();

		User currentUser = [
			SELECT AV_Funcion__c, AV_NumeroOficinaEmpresa__c
			FROM User
			WHERE Id = :UserInfo.getUserId()
		];
		Account userCenter = [
            SELECT Id, Name, CC_Numero_Oficina__c, AV_CentroSuperior__c, CC_Numero_Oficina_Empresa__c
            FROM Account
            WHERE CC_Numero_Oficina_Empresa__c = :currentUser.AV_NumeroOficinaEmpresa__c
        ];
		String funcion = String.isNotBlank(currentUser.AV_Funcion__c) ? currentUser.AV_Funcion__c : '';
		ids.add(userCenter.Id);
		if (AV_AppConstants.FUNCION_DT.equals(funcion)) {
			offices.addAll(getInferiorCenters(ids));
		}
		if (AV_AppConstants.FUNCION_DC.equals(funcion) || !offices.isEmpty()) {
			if (!offices.isEmpty()) {
				ids.clear();
				ids.addAll(getCenterIds(offices));
				offices.clear();
			}
			inferiorOffices.addAll(getInferiorCenters(ids));
		}
		if (AV_AppConstants.FUNCION_DAN.equals(funcion) || !inferiorOffices.isEmpty()) {
			if (!inferiorOffices.isEmpty()) {
				ids.clear();
				ids.addAll(getCenterIds(inferiorOffices));
				offices.clear();
			}
			offices.addAll(getInferiorCenters(ids));
		}
		if (!offices.isEmpty()) {
			for (Account a : offices) {
				result.add(a.Id);
			}
		} else {
			result.add(userCenter.Id);
		}
		return result;
	}

	/**
     * @description             Gets the inferior centers from the immediately superior centers list
     * @param superiorCenters   List of  superior centers
     */
    public static List<Account> getInferiorCenters(List<Id> superiorCenters) {
		List<Account> centrosInferioresTotales = new List<Account>();
        List<Account> inferiorCenters = [
            SELECT Id, Name, CC_Numero_Oficina__c, AV_CentroSuperior__c, CC_Numero_Oficina_Empresa__c
            FROM Account
            WHERE AV_CentroSuperior__c IN :superiorCenters
        ];
		for(Account a: inferiorCenters){
			centrosInferioresTotales.add(a);
		}
		

		List<Account> inferiorCenters2 =[
			SELECT Id, Name, CC_Numero_Oficina__c, AV_CentroSuperior__c, CC_Numero_Oficina_Empresa__c
            FROM Account
            WHERE AV_CentroSuperior__c IN : inferiorCenters
		];
		for(Account a: inferiorCenters2){
			centrosInferioresTotales.add(a);
		}
        
		return centrosInferioresTotales;
    }

	/**
     * @description     Gets the ids from the list passed
     * @param accs      Accounts you want the ids from
     */
    public static List<Id> getCenterIds(List<Account> accs) {
        List<Id> ids = new List<Id>();
        for (Account a : accs) {
            ids.add(a.Id);
        }
        return ids;
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

		avQuery= avQuery+' AND AV_ToDelete__C = FALSE ORDER BY ActivityDate ASC NULLS FIRST LIMIT 100 OFFSET '+((Integer.valueOf(page)-1)*100);
        AV_LogDebug.printLogDebug(methodName, '-----> Query to execute: ' + avQuery);
		totalSize = '1'.equals(page) ? getNumberOfTasks(subjectFilter, origenFilter, statusFilter, dueDate2Filter, dueDateFilter, employeeFilter, clientFilter, myBoxFilter, preconceivedFilter, targetAutoFilter, office,page) : -1;
		List<Task> lista = capsulateQuery(avQuery);
		return new ObjectList('Task', totalSize, lista);
	}

	private static List<Task> capsulateQuery(String q){//Método para pasar qualityClouds
		return (List<Task>) Database.query(q);
	}

	/**
	 * @description		Lookup of User 
	 * @param	searchTerm	 The search term to look up users.
	 * @param	selectedIds		A list of selected user IDs.
	 */
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchUser(String searchTerm, List<String> selectedIds) {
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		
		if(!selectedIds.isEmpty()){
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					User(Id, Name, AV_ExternalID__c WHERE Id NOT IN :selectedIds and IsActive=true and Profile.Name = :AV_AppConstants.AV_PROFILE)
				LIMIT :MAX_RESULTS
			];
		}
		else{
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					User(Id, Name, AV_ExternalID__c WHERE IsActive=true and Profile.Name = :AV_AppConstants.AV_PROFILE)
				LIMIT :MAX_RESULTS
			];

		}

		String userIcon = 'standard:user';
		User[] listUser = (List<User>) searchResults[0];
		for (User u : listUser) {
			results.add(
				new AV_LookupSearchResult(
					u.Id,
					'User',
					userIcon,
					u.Name,
					'Matrícula • ' + u.AV_ExternalID__c
				)
			);
		}
		results.sort();

		return results;
	}

	/**
	 * @description		Lookup of Search 
	 * @param	searchTerm	 The search term to look up users.
	 * @param	selectedIds		A list of selected user IDs.
	 * @param	myOffice	A boolean indicating whether to filter by the user's office.
	 */
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> search(String searchTerm, List<String> selectedIds, Boolean myOffice) {
		Profile p = [SELECT Id FROM Profile WHERE Name = :AV_AppConstants.AV_PROFILE];
		
		User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId()];
		
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		
		if (Boolean.valueOf(myOffice)) {
			if(!selectedIds.isEmpty()){
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
						User(Id, Name, AV_NumeroOficinaEmpresa__c  WHERE Id NOT IN :selectedIds and IsActive=true and ProfileId = :p.Id and AV_NumeroOficinaEmpresa__c=:emp.AV_NumeroOficinaEmpresa__c)
					LIMIT :MAX_RESULTS
				];
			} else {
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
						User(Id, Name, AV_NumeroOficinaEmpresa__c  WHERE IsActive=true and ProfileId = :p.Id and AV_NumeroOficinaEmpresa__c=:emp.AV_NumeroOficinaEmpresa__c)
					LIMIT :MAX_RESULTS
				];
			}
		} else {
			if(!selectedIds.isEmpty()){
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
						User(Id, Name, AV_NumeroOficinaEmpresa__c  WHERE Id NOT IN :selectedIds and IsActive=true and ProfileId = :p.Id and AV_NumeroOficinaEmpresa__c!=:emp.AV_NumeroOficinaEmpresa__c)
					LIMIT :MAX_RESULTS
				];
			} else {
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
						User(Id, Name, AV_NumeroOficinaEmpresa__c  WHERE IsActive=true and ProfileId = :p.Id and AV_NumeroOficinaEmpresa__c!=:emp.AV_NumeroOficinaEmpresa__c)
					LIMIT :MAX_RESULTS
				];
			}
		}
		String userIcon = 'standard:user';
		String userCentro = '';
		User[] listUser = (List<User>) searchResults[0];
		for (User u : listUser) {
			if (u.AV_NumeroOficinaEmpresa__c != null && u.AV_NumeroOficinaEmpresa__c.length() >= 5) {
				userCentro = u.AV_NumeroOficinaEmpresa__c.substring(4);
			} else {
				userCentro = u.AV_NumeroOficinaEmpresa__c;
			}
			results.add(
				new AV_LookupSearchResult(
					u.Id,
					'User',
					userIcon,
					u.Name,
					'Centro • ' + userCentro
				)
			);
		}
		results.sort();

		return results;
	}


	/**
	 * @description		Lookup of Search Account 
	 * @param	searchTerm	 The search term to look up users.
	 * @param	selectedIds		A list of selected user IDs.
	 * @param	myOffice	A boolean indicating whether to filter by the user's office.
	 */
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchAccount(String searchTerm, List<String> selectedIds) {
		
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();

		if(!selectedIds.isEmpty()){
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Account(Id, Name, AV_Numperso__c WHERE Id NOT IN :selectedIds and RecordType.DeveloperName IN (:AV_AppConstants.ACCOUNT_ENT_RT, :AV_AppConstants.ACCOUNT_PA_RT) and AV_Numperso__c!=null and AV_Confidencial__c=false)
				LIMIT :MAX_RESULTS
			];
		} else{
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Account(Id, Name, AV_Numperso__c WHERE RecordType.DeveloperName IN (:AV_AppConstants.ACCOUNT_ENT_RT, :AV_AppConstants.ACCOUNT_PA_RT) and AV_Numperso__c!=null and AV_Confidencial__c=false)
				LIMIT :MAX_RESULTS
			];

		}		

		String productIcon = 'standard:account';
		Account[] listAccount = (List<Account>) searchResults[0];
		for (Account acc : listAccount) {
			results.add(
				new AV_LookupSearchResult(
					acc.Id,
					'Account',
					productIcon,
					acc.Name,
					''
				)
			);
		}
		results.sort();

		return results;
	}

	/**
	 * @description		Lookup of Search Office 
	 * @param	searchTerm	 The search term to look up users.
	 * @param	selectedIds		A list of selected user IDs.
	 */
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchOffice(String searchTerm, List<String> selectedIds) {
		Set<String> directores = new Set<String>{AV_AppConstants.FUNCION_DT, AV_AppConstants.FUNCION_DC, AV_AppConstants.FUNCION_DAN};
		Set<String> gestor = new Set<String>{AV_AppConstants.FUNCION_GESTOR, AV_AppConstants.FUNCION_OFICINA};
		String sscc = AV_AppConstants.FUNCION_SSCC;
		searchTerm +='*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		User currentUser = [
			SELECT AV_Funcion__c, 
			AV_NumeroOficinaEmpresa__c, 
			AV_OriginalOfficeNumber__c
			FROM User
			WHERE Id = :UserInfo.getUserId()
			
		];
		Set<Id> offices;
		if (currentUser.AV_OriginalOfficeNumber__c != null) {
			offices = getInferiorCenterIds(currentUser);
		}else {
			offices = getInferiorCenterIds();
		}
		Account centroUsuario = [
            SELECT Id, Name, CC_Numero_Oficina__c, AV_CentroSuperior__c, CC_Numero_Oficina_Empresa__c
            FROM Account
            WHERE CC_Numero_Oficina_Empresa__c = :currentUser.AV_NumeroOficinaEmpresa__c
			
        ];
		if (String.isNotBlank(currentUser.AV_Funcion__c) && directores.contains(currentUser.AV_Funcion__c)) {
			if(!selectedIds.isEmpty()){
				if (currentUser.AV_OriginalOfficeNumber__c != null) {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id NOT IN :selectedIds and (Id = :centroUsuario.Id or Id IN :offices) and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :MAX_RESULTS
					];
				}else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id NOT IN :selectedIds and Id IN :offices and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :MAX_RESULTS
					];
				}
			} else{
				if (currentUser.AV_OriginalOfficeNumber__c != null) {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE (Id = :centroUsuario.Id or Id IN :offices) and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :MAX_RESULTS
					];
				}else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE (Id IN :offices OR Id = :centroUsuario.Id) and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :MAX_RESULTS
					];
				}
			}	
		} else if ((String.isNotBlank(currentUser.AV_Funcion__c) && gestor.contains(currentUser.AV_Funcion__c))) {
			if(!selectedIds.isEmpty()){
				if (currentUser.AV_OriginalOfficeNumber__c != null) {
				searchResults = [
					FIND :searchTerm
					IN Name FIELDS
					RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE (Id = :centroUsuario.Id or Id in :offices) and Id NOT IN :selectedIds and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
					LIMIT :MAX_RESULTS
				];
			} else{
				searchResults = [
					FIND :searchTerm
					IN Name FIELDS
					RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id = :centroUsuario.Id and Id NOT IN :selectedIds and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
					LIMIT :MAX_RESULTS
				];
			}	
			} else{
				if (currentUser.AV_OriginalOfficeNumber__c != null) {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE (Id = :centroUsuario.Id or Id in :offices) and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :MAX_RESULTS
					];
				} else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id = :centroUsuario.Id and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :MAX_RESULTS
					];
				}
			}	
		} else if (String.isNotBlank(currentUser.AV_Funcion__c) && sscc.equals(currentUser.AV_Funcion__c)) {
			if(!selectedIds.isEmpty()){
				if (currentUser.AV_OriginalOfficeNumber__c != null) {
				searchResults = [
					FIND :searchTerm
					IN Name FIELDS
					RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id in :offices and Id NOT IN :selectedIds and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
					LIMIT :MAX_RESULTS
				];
			} else{
				searchResults = [
					FIND :searchTerm
					IN Name FIELDS
					RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id NOT IN :selectedIds and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
					LIMIT :MAX_RESULTS
				];
			}	
			} else{
				if (currentUser.AV_OriginalOfficeNumber__c != null) {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id in :offices and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :MAX_RESULTS
					];
				} else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :MAX_RESULTS
					];
				}
			}	
		}	
		String productIcon = 'standard:account';
		Account[] listAccount = (List<Account>) searchResults[0];
		for (Account acc : listAccount) {
			results.add(
				new AV_LookupSearchResult(
					acc.Id,
					'Account',
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
	* @description   Assigns selected tasks to a new Contact.
	* @param objectName     The name of the object being assigned (unused in this method).
	* @param contactId      The ID of the Contact to whom the tasks will be assigned.
	* @param selectedRows   A list of sObjects representing the selected tasks to be assigned.
	*/
	@AuraEnabled
	public static String assign(String objectName , String contactId, List<sObject> selectedRows){
		Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.OptAllOrNone = false;
		dmlOptions.EmailHeader.triggerUserEmail = false;
		if (String.isNotBlank(objectName)) {
			List<Id> tasks = new List<Id>();
			for(sObject o : selectedRows){
				String tId = o.get('Id').toString();
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
	* @description   Retrieves the name of the User assigned to a specific Contact.
	* @param contactId   The ID of the Contact for which to retrieve the assigned User's name.
	*/
	@AuraEnabled
	public static String nameContactAssign(String contactId){
		List<User> us  = [Select Id, Name From User Where Id = :contactId];
		if (us.isEmpty()) {
			return null;
		}else{
			return us[0].Name;
		}
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
	 * Type of object used to encapsulate the list of records and the total number of records
	 */
	public class ObjectList {
		@AuraEnabled
		public String objectName;
		@AuraEnabled
		public Integer totalSize;
		@AuraEnabled
		public List<SObject> recordList;

		public ObjectList(String objectName, Integer totalSize, List<SObject> recordList) {
			this.objectName = objectName;
			this.totalSize = totalSize;
			this.recordList = recordList;
		}
		public ObjectList() {
			this.objectName = '';
			this.totalSize = 0;
			this.recordList = new List<SObject>();
		}

		public void add(ObjectList ol) {
			this.totalSize += ol.totalSize;
			this.recordList.addAll(ol.recordList);
		}

		public Boolean isEmpty(){
			return this.totalSize == 0;
		}
	}
    
	@AuraEnabled
	public static Boolean hasCustomPermission(){
		return FeatureManagement.checkPermission('AV_PrivateBanking');
	}
    
}