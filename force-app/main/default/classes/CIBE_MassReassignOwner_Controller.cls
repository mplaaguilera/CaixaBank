/**********************************************************************************************************************
	Name:      CIBE_MassReassignOwner_Controller
	Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for CIBE_MassReassignOwner LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION			USER_STORY			AUTHOR				DATE			Description
	1.0				US164351			Luis Martínez		03/01/2023		Init version
	2.0				US532487			Jose Maria			15/03/2023		Jerarquia CIB desde cartera cliente
	3.0									Jose Maria			23/03/2023		Nuevos campos Redes,Negocios,Sectores.
	4.0									Jose Maria			20/04/2023		Auto cálculo de jerarquía
***********************************************************************************************************************/
public with sharing class CIBE_MassReassignOwner_Controller {

	private final static Integer MAX_RESULTS 	= 10;
	private final static Integer MAX_LIMIT 		= 49900;
    private final static String  ID_GCF			= (String)[SELECT ID FROM USER WHERE ALIAS = 'AV-TF9' LIMIT 1].Id;
	public static Integer numberOfRecords;

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

	/**
     * @description             Gets the inferior centers from the immediately superior centers list
     * @param superiorCenters   List of immediately superior centers
     */
    public static List<Account> getInferiorCenters(List<Id> superiorCenters) {
        List<Account> inferiorCenters = [SELECT Id, Name, CC_Numero_Oficina__c, AV_CentroSuperior__c, CC_Numero_Oficina_Empresa__c FROM Account WHERE AV_CentroSuperior__c IN :superiorCenters];
        return inferiorCenters;
    }

	/**
     * @description     Gets the ids from the list passed
     * @param accs      Accounts you want the ids from
     */
    public static List<Id> getCenterIds(List<Account> accs) {
        List<Id> ids = new List<Id>();
        for (Account a : accs) {ids.add(a.Id);}
        return ids;
    }

	//Método para pasar qualityClouds
	private static List<Task> capsulateQuery(String q){
		return (List<Task>) Database.query(q);
	}
	private static List<Contact> capsulateQueryCon(String q){
		return (List<Contact>) Database.query(q);
	}
	private static List<User> capsulateQueryUser(String q){
		return (List<User>) Database.query(q);
	}


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
    }

	@AuraEnabled
	public static String nameContactAssign(String contactId){
		List<User> us  = [Select Id, Name From User Where Id = :contactId];
		if (us.isEmpty()) {
			return null;
		}else{
			return us[0].Name;
		}
	}

    @AuraEnabled
    public static ObjectList getBaseData(String clientFilter, String subjectFilter, String origenFilter, String[] statusFilter, Date fechaVHasta, Date fechaVDesde, String[] employeeFilter, String page,String office) {
		ObjectList result = new ObjectList();
		List<String> listEmployees = employeeFilter;	
		String employeeFilterFinal = '';
		String gestorFilter = '';
		for(String aux : listEmployees){
			employeeFilterFinal += aux + ',';
		}
		if (String.isNotBlank(employeeFilterFinal)){
			employeeFilterFinal= employeeFilterFinal.removeEnd(',');
			ObjectList ol1 = getTasksFilter(clientFilter,subjectFilter,origenFilter,statusFilter,fechaVHasta, fechaVDesde, employeeFilter, page, office);
			result.add(ol1);
		}
		return result;
	}


	@AuraEnabled
	public static List<OptionsEmployee> getEmployees(String oficina){
		List<OptionsEmployee> employees = new List<OptionsEmployee>();
		List<OptionsEmployee> employeesSorted = new List<OptionsEmployee>();
		List<Id> employeesId = new List<Id>();
		List<String> profileDN = new List<String>{AV_AppConstants.AV_PROFILE, CIBE_AppConstants.CIBE_GESTOR};
		if(User.SObjectType.getDescribe().isAccessible() &&
		Schema.SObjectType.User.fields.AV_NumeroOficinaEmpresa__c.isAccessible()&&
		Schema.SObjectType.User.fields.AV_ExternalID__c.isAccessible()){	
			if (String.isBlank(oficina)) {
				return null;
			}else if (String.isNotBlank(oficina)) {
				String[] data = oficina.split('\\{\\|}');
				if (data.size() > 1) {
					List<Recordtype> taskRecordTypeId = [SELECT Id, DeveloperName FROM Recordtype WHERE (Name = :data[2] OR DeveloperName = :data[2]) AND SobjectType='Task'];
					String centerRt = data[0] + '-' + taskRecordTypeId[0].Id;
					Set<Id> setIdsRts = (new Map<Id,RecordType>(taskRecordTypeId)).keySet().clone();
					AggregateResult[] tasksWithCenter = [SELECT OwnerId, Owner.Name 
														FROM Task
														WHERE (AV_CenterRtIndex__c = :centerRt OR AV_Center__c =:data[0] ) AND
														Owner.Profile.name IN :profileDN AND RecordTypeId IN :setIdsRts 
														GROUP BY OwnerId, Owner.Name];

					if (!tasksWithCenter.isEmpty()) {
						for (AggregateResult t : tasksWithCenter) {
								employeesId.add((Id)t.get('OwnerId'));
								employeesSorted.add(new OptionsEmployee((Id)t.get('OwnerId'),(String)t.get('Name')));
						}
					}
				}else if(data.size() == 1){
					String userQuery = 'SELECT Id, name  from User WHERE AV_NumeroOficinaEmpresa__c LIKE \'%'+String.escapeSingleQuotes(oficina)+'%\' AND IsActive = true Limit 100';
					List<User> emps = capsulateQueryUser(userQuery);
					if(!emps.isEmpty() && emps != null){
						for(User u : emps){
							employeesId.add(u.Id);
							employeesSorted.add(new OptionsEmployee(u.Id,u.Name));
						}
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

	

	public static Set<Id> getInferiorCenterIds() {
		List<Account> offices = new List<Account>();
		List<Account> inferiorOffices = new List<Account>();
		List<Id> ids = new List<Id>();
		Set<Id> result = new Set<Id>();

		User currentUser = [SELECT AV_Funcion__c, AV_NumeroOficinaEmpresa__c FROM User WHERE Id = :UserInfo.getUserId()];
        Account userCenter = [SELECT Id, Name, CC_Numero_Oficina__c, AV_centroSuperior__c, CC_Numero_Oficina_Empresa__c FROM Account
                            WHERE CC_Numero_Oficina_Empresa__c = :currentUser.AV_NumeroOficinaEmpresa__c];

		String funcion = String.isNotBlank(currentUser.AV_Funcion__c) ? currentUser.AV_Funcion__c : '';
		ids.add(userCenter.Id);
		if ('DT'.equals(funcion)) {offices.addAll(getInferiorCenters(ids));}
		if ('DC'.equals(funcion) || !offices.isEmpty()) {
            if (!offices.isEmpty()) {ids.clear();ids.addAll(getCenterIds(offices));offices.clear();}
			inferiorOffices.addAll(getInferiorCenters(ids));
		}
		if ('DAN'.equals(funcion) || !inferiorOffices.isEmpty()) {
			if (!inferiorOffices.isEmpty()) {
				ids.clear();
				ids.addAll(getCenterIds(inferiorOffices));
				offices.clear();
			}
			offices.addAll(getInferiorCenters(ids));
		}
		if (!offices.isEmpty()) {
			for (Account a : offices) {	result.add(a.Id);}
		} else {
			result.add(userCenter.Id);
		}
		return result;
	}

	

    private static ObjectList getTasksFilter(String clientFilter,String subjectFilter,String origenFilter,String [] statusFilter, Date fechaVHasta, Date fechaVDesde, String [] employeeFilter, String page, String office){
		String methodName = 'getTasksFilter';
		String quote = '\'';
		Integer totalSize;
		String centerRt;
		String queryCont;
		List<List<SObject>> searchResults = new List<List<SObject>>();
		List<Account> listCentroSector = new List<Account>();
		List<Contact> listContact = new List<Contact>();
		List<String> listNumCentro = new List<String>();

		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(origenFilter).getRecordTypeId();
		String taskRecordtypePriorizados;

		if(office != null && office.isNumeric()){
			centerRt = office + '-' + taskRecordTypeId;
		}else if(office != null){
			searchResults = [FIND :office IN ALL FIELDS RETURNING
			Account(Id, Name, CIBE_SectoresPaises__c,CC_Numero_Oficina__c WHERE CIBE_SectoresPaises__c!=null and RecordType.Id =: accRecordTypeId)	LIMIT :MAX_RESULTS];
			listCentroSector = (List<Account>) searchResults[0];
			if(listCentroSector.isEmpty()){
				queryCont='SELECT Id, name, toLabel(CIBE_Sector__c),AV_UsuarioAsociado__c,AV_UsuarioAsociado__r.AV_NumeroOficinaEmpresa__c,CC_Numero_Oficina__c FROM Contact WHERE ((AV_UsuarioAsociado__c != null OR CC_Numero_Oficina__c != null) AND CIBE_Cartera__c LIKE \'%'+office+'%\')';
				
				listContact = capsulateQueryCon(queryCont);
				if(!listContact.isEmpty()){
					for(Contact con : listContact){
						if(con.CC_Numero_Oficina__c != null){
							listNumCentro.add(con.CC_Numero_Oficina__c+ '-' + taskRecordTypeId);
						}
					}	
				}
			}else{
				for(Account acc:listCentroSector){
					if(acc.CC_Numero_Oficina__c != null){
						listNumCentro.add(acc.CC_Numero_Oficina__c+ '-' + taskRecordTypeId);
					}
				}
			}
		}		

		String avQuery='Select Id, Subject, AV_CenterRtIndex__c, RecordType.DeveloperName, ActivityDate, AV_Valor1__c, Account.Name, Owner.Name, OwnerId, AccountId, AV_Origen__c, TOLABEL(Status), TOLABEL(Priority),AV_Center__c FROM Task WHERE ';
		//String subQuery = ', (Select Id, Name,AV_NumeroOficinaEmpresa__c FROM User) ';
		if(statusFilter != null){
			avQuery = avQuery + 'Status IN '+AV_AppUtilities.arrayToStringIn(statusFilter);
		}
		if(subjectFilter != null){
			avQuery = avQuery + ' AND Subject like \'%'+String.escapeSingleQuotes(subjectFilter)+'%\'';
		}
		if(fechaVDesde != null){
			DateTime f1=(DateTime)fechaVDesde;
			avQuery = avQuery + ' AND ActivityDate >= '+f1.format('yyyy-MM-dd');
		}
		if(fechaVHasta != null){
			DateTime f2=(DateTime)fechaVHasta;
			avQuery = avQuery + ' AND ActivityDate <= '+f2.format('yyyy-MM-dd');
		}
        if(origenFilter != null){
			avQuery = avQuery + ' AND RecordType.DeveloperName = \''+origenFilter+'\'';
		}
		if(clientFilter != null) {
			avQuery = avQuery + ' AND AccountId = \''+clientFilter+'\'';
		}
		if (centerRt != null && employeeFilter.size()==0) {
			avQuery = avQuery + ' AND AV_CenterRtIndex__c = \''+ centerRt +'\'';
		}
        if(employeeFilter != null) {
			if (ID_GCF.equalsIgnoreCase(employeeFilter[0]) && employeeFilter.size()==1) {
				if(centerRt != null){
					avQuery = avQuery + ' AND OwnerId = \''+ID_GCF+'\' AND AV_CenterRtIndex__c =\''+centerRt+'\'';
				}else if(!listNumCentro.isEmpty()){
					avQuery = avQuery + ' AND OwnerId = \''+ID_GCF+'\' AND AV_CenterRtIndex__c IN '+AV_AppUtilities.arrayToStringIn(listNumCentro);
				}
            } else if (employeeFilter[0].contains(ID_GCF) && employeeFilter.size()==1 ) {
				if(centerRt != null){
					avQuery = avQuery + ' AND AV_CenterRtIndex__c = \''+centerRt+'\'';
				}else if(!listNumCentro.isEmpty()){
					avQuery = avQuery + ' AND AV_CenterRtIndex__c IN '+AV_AppUtilities.arrayToStringIn(listNumCentro);
				}
            } else {
					if(centerRt != null){
						avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_CenterRtIndex__c = \''+centerRt+'\'';
					}else if(!listNumCentro.isEmpty()){
						avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_CenterRtIndex__c IN '+AV_AppUtilities.arrayToStringIn(listNumCentro);
					}
				}
		} else {
			avQuery = avQuery + ' AND AV_CodigoGestorAsignado__c = null';
		}
		avQuery= avQuery+' AND AV_ToDelete__C = FALSE ORDER BY ActivityDate ASC NULLS FIRST LIMIT 100 OFFSET '+((Integer.valueOf(page)-1)*100);

		List<Task> lista = capsulateQuery(avQuery);
		totalSize = '1'.equals(page) ? lista.size() : -1;
		return new ObjectList('Task', totalSize, lista);
	}

	
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> search(String searchTerm, List<String> seletcedIds, Boolean myOffice) {
		List<Profile> lstProfileId = [SELECT Id FROM Profile WHERE Name = :AV_AppConstants.AV_PROFILE OR Name = :CIBE_AppConstants.CIBE_GESTOR];
		User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId()];
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		
		if (Boolean.valueOf(myOffice)) {
			if(!seletcedIds.isEmpty()){
				searchResults = [ FIND :searchTerm IN ALL FIELDS RETURNING
				User(Id, Name, AV_NumeroOficinaEmpresa__c  WHERE Id NOT IN :seletcedIds and IsActive=true and ProfileId IN:lstProfileId and AV_NumeroOficinaEmpresa__c=:emp.AV_NumeroOficinaEmpresa__c)LIMIT :MAX_RESULTS];
			} else {
				searchResults = [ FIND :searchTerm IN ALL FIELDS RETURNING
				User(Id, Name, AV_NumeroOficinaEmpresa__c  
				WHERE IsActive=true and ProfileId IN:lstProfileId and AV_NumeroOficinaEmpresa__c=:emp.AV_NumeroOficinaEmpresa__c)
				LIMIT :MAX_RESULTS];
			}
		} else {
			if(!seletcedIds.isEmpty()){
				searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
				User(Id, Name, AV_NumeroOficinaEmpresa__c  
				WHERE Id NOT IN :seletcedIds and IsActive=true and ProfileId IN:lstProfileId and AV_NumeroOficinaEmpresa__c!=:emp.AV_NumeroOficinaEmpresa__c) LIMIT :MAX_RESULTS];
			} else {
				searchResults = [ FIND :searchTerm IN ALL FIELDS RETURNING
				User(Id, Name, AV_NumeroOficinaEmpresa__c  WHERE IsActive=true and ProfileId IN:lstProfileId and AV_NumeroOficinaEmpresa__c!=:emp.AV_NumeroOficinaEmpresa__c)
				LIMIT :MAX_RESULTS];
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
			results.add(new AV_LookupSearchResult(u.Id,'User',userIcon,	u.Name,	'Centro • ' + userCentro));
		}
		results.sort();
		return results;
	}

	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchAccount(String searchTerm, List<String> selectedIds) {
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		Set<String> setLabelsRts = new Set<String>{CIBE_AppConstants.ACCOUNT_CLIENTE_RT,'CC_ClientePA'}; 
		Set<Id> setIdsRts = AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRts);

		if(!selectedIds.isEmpty()){
			searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
							Account(Id, Name, AV_Numperso__c WHERE Id NOT IN :selectedIds and RecordType.Id IN: setIdsRts and AV_Confidencial__c=false)
							LIMIT :MAX_RESULTS];
		} else{
			searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
							Account(Id, Name, AV_Numperso__c WHERE RecordType.Id IN: setIdsRts and AV_Confidencial__c=false)
							LIMIT :MAX_RESULTS];
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
					'Codigo • ' + acc.AV_Numperso__c 
				)
			);
		}
		results.sort();
		return results;
	}

    @AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchOffice(String searchTerm, List<String> selectedIds) {
		Set<String> directores = new Set<String>{'DT', 'DC', 'DAN'};
		Set<String> gestor = new Set<String>{'Gestor', 'Oficina'};
		String sscc = 'SSCC';
		String searchT = '*'+searchTerm +'*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		Set<Id> offices = getInferiorCenterIds();
		Account[] listAccount = new List<Account>();
		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

		User currentUser = [SELECT AV_Funcion__c, AV_NumeroOficinaEmpresa__c
							FROM User
							WHERE Id = :UserInfo.getUserId()];
		Account centroUsuario = [SELECT Id, Name, CC_Numero_Oficina__c, AV_CentroSuperior__c, CC_Numero_Oficina_Empresa__c
								FROM Account
								WHERE CC_Numero_Oficina_Empresa__c = :currentUser.AV_NumeroOficinaEmpresa__c ];
	
		if (String.isNotBlank(currentUser.AV_Funcion__c) && directores.contains(currentUser.AV_Funcion__c)) {
				if(!Test.isRunningTest()){
					searchResults = [FIND :searchT IN ALL FIELDS RETURNING
					Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id IN :offices and RecordType.Id =: accRecordTypeId) LIMIT :MAX_RESULTS];
				}else{
					searchResults = [FIND :searchT IN Name FIELDS RETURNING
					Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id IN :offices and RecordType.Id =: accRecordTypeId)
					LIMIT :MAX_RESULTS];
				}
		} else if (String.isNotBlank(currentUser.AV_Funcion__c) && gestor.contains(currentUser.AV_Funcion__c)) {
				if(searchT != currentUser.AV_NumeroOficinaEmpresa__c){
					searchResults = [FIND :searchT IN ALL FIELDS RETURNING
					Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE RecordType.Id =: accRecordTypeId)
					LIMIT :MAX_RESULTS];
				} else{
					searchResults = [FIND :searchT IN All FIELDS RETURNING
					Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id = :centroUsuario.Id and RecordType.Id =: accRecordTypeId) LIMIT :MAX_RESULTS];
				}	
		} else if (String.isNotBlank(currentUser.AV_Funcion__c) && sscc.equals(currentUser.AV_Funcion__c)) {
					searchResults = [FIND :searchT IN All FIELDS RETURNING
					Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE RecordType.Id =: accRecordTypeId) LIMIT :MAX_RESULTS];
		}	
		String productIcon = 'standard:account';
		if(searchResults.size()>0){
			listAccount = (List<Account>) searchResults[0];
			for (Account acc : listAccount) {
				results.add(new AV_LookupSearchResult(acc.Id,'Account',productIcon,acc.Name,'Número • ' + acc.CC_Numero_Oficina__c));
			}
			results.sort();
		}
		return results;
	}

    
	@AuraEnabled
	public static ObjectList getBaseDataCIB(String clientFilter, String subjectFilter, String origenFilter, String[] statusFilter, Date fechaVHasta, Date fechaVDesde, String[] employeeFilter, String page) {
		ObjectList result = new ObjectList();
		List<String> listEmployees = employeeFilter;	
		String employeeFilterFinal = '';
		String gestorFilter = '';
		for(String aux : listEmployees){
			employeeFilterFinal += aux + ',';
		}
		if (String.isNotBlank(employeeFilterFinal)){
			employeeFilterFinal= employeeFilterFinal.removeEnd(',');
			ObjectList ol1 = getTasksFilterCIB(clientFilter,subjectFilter,origenFilter,statusFilter,fechaVHasta, fechaVDesde, employeeFilter, page);
			result.add(ol1);
		}
		return result;
	}

	private static ObjectList getTasksFilterCIB(String clientFilter,String subjectFilter,String origenFilter,String [] statusFilter, Date fechaVHasta, Date fechaVDesde, String [] employeeFilter, String page){
		String methodName = 'getTasksFilter';
		String quote = '\'';
		Integer totalSize;
		String centerRt;
		String queryCont;
		List<List<SObject>> searchResults = new List<List<SObject>>();
		List<Account> listCentroSector = new List<Account>();
		List<Contact> listContact = new List<Contact>();
		List<String> listNumCentro = new List<String>();

		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(origenFilter).getRecordTypeId();


		String avQuery='Select Id, Subject, AV_CenterRtIndex__c, RecordType.DeveloperName, ActivityDate, AV_Valor1__c, Account.Name, Owner.Name, OwnerId, AccountId, AV_Origen__c, TOLABEL(Status), TOLABEL(Priority),AV_Center__c FROM Task WHERE ';
		if(statusFilter != null){
			avQuery = avQuery + 'Status IN '+AV_AppUtilities.arrayToStringIn(statusFilter);
		}
		if(subjectFilter != null){
			avQuery = avQuery + ' AND Subject like \'%'+String.escapeSingleQuotes(subjectFilter)+'%\'';
		}
		if(fechaVDesde != null){
			DateTime f1=(DateTime)fechaVDesde;
			avQuery = avQuery + ' AND ActivityDate >= '+f1.format('yyyy-MM-dd');
		}
		if(fechaVHasta != null){
			DateTime f2=(DateTime)fechaVHasta;
			avQuery = avQuery + ' AND ActivityDate <= '+f2.format('yyyy-MM-dd');
		}
        if(origenFilter != null){
			avQuery = avQuery + ' AND RecordType.DeveloperName = \''+origenFilter+'\'';
		}
		if(clientFilter != null) {
			avQuery = avQuery + ' AND AccountId = \''+clientFilter+'\'';
		}
        if(employeeFilter != null) {
			avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter);	
		}
		avQuery= avQuery+' AND AV_ToDelete__C = FALSE ORDER BY ActivityDate ASC NULLS FIRST LIMIT 100 OFFSET '+((Integer.valueOf(page)-1)*100);

		List<Task> lista = capsulateQuery(avQuery);
		totalSize = '1'.equals(page) ? lista.size() : -1;
		return new ObjectList('Task', totalSize, lista);
	}

	@AuraEnabled
	public static List<OptionsEmployee> getEmployeesCIB(String searchTerm, String valueId, String userLogin, String userName, Boolean allQuery){
		List<Id> employeesId = new List<Id>();
		List<OptionsEmployee> employees = new List<OptionsEmployee>();
		List<OptionsEmployee> employeesSorted = new List<OptionsEmployee>();

		List<CIBE_Hierarchy__c> listJerarquias =  new List<CIBE_Hierarchy__c>();
		if (allQuery) {
			listJerarquias = [SELECT Id,CIBE_Contact__c,CIBE_Contact__r.name FROM CIBE_Hierarchy__c WHERE recordType.DeveloperName='CIBE_Employee' ORDER BY Name];
		}else{
			listJerarquias = [SELECT Id,CIBE_Contact__c,CIBE_Contact__r.name FROM CIBE_Hierarchy__c WHERE recordType.DeveloperName='CIBE_Employee' AND (CIBE_CentrosCarteras__c=:valueId OR CIBE_RedesSegmentos__c=:valueId OR CIBE_Negocios__c=:valueId OR CIBE_SectoresPaises__c=:valueId) ORDER BY Name];

		}
		List<Id> listContactsHierar = new List<Id>();
		for(CIBE_Hierarchy__c h : listJerarquias){
			listContactsHierar.add(h.CIBE_Contact__c);
		}

		List<Contact> listContacts = [SELECT Id,Name, AV_UsuarioAsociado__c, AV_UsuarioAsociado__r.name, AV_UsuarioAsociado__r.IsActive FROM Contact WHERE Id=: listContactsHierar];
//		List<Id> listUserContacts = new List<Id>();
		List<Id> listIdUser = new List<Id>();

		for(Contact c : listContacts){
			//listUserContacts.add(c.AV_UsuarioAsociado__c);
			if(c.AV_UsuarioAsociado__r.IsActive){
				listIdUser.add(c.AV_UsuarioAsociado__c);
				employeesId.add(c.AV_UsuarioAsociado__c);
				employeesSorted.add(new OptionsEmployee(c.AV_UsuarioAsociado__c,c.AV_UsuarioAsociado__r.Name));
			}
		}

		/*List<String> listIdUser = new List<String>();
		List<User> listUsers =  [SELECT Id, Name, AV_NumeroOficinaEmpresa__c FROM User WHERE IsActive = true AND Id=:listUserContacts LIMIT :MAX_LIMIT];
		if(!listUsers.isEmpty()){
			for(User u : listUsers){
				listIdUser.add(u.Id);
				employeesId.add(u.Id);
				employeesSorted.add(new OptionsEmployee(u.Id,u.Name));
			}
		}*/
		

		String employeesAlls=string.join(employeesId,',');
		if(employeesId.size()>1) {
			employees.add(new OptionsEmployee(ID_GCF+','+employeesAlls,'TODOS - CENTRO '));
		}
		if(!listIdUser.contains(userLogin)){	
			employees.add(new OptionsEmployee(userLogin,userName));
		}
		employees.add(new OptionsEmployee(ID_GCF,'Sin Gestor / Eap - CENTRO '));
		employeesSorted.sort();
		employees.addAll(employeesSorted);
		return employees;
		
	}

	public class PicklistItems{
		@AuraEnabled
		public String value { get; set; }

		@AuraEnabled
		public string label { get; set; }

	}

	@AuraEnabled(cacheable = true) 
	public static List<PicklistItems> picklistValues(String inputField, String inputObj) {
		PicklistItems pickItem;
		List<PicklistItems> lstpickItem = new list<PicklistItems> ();
		Map<String, String> values = new Map<String, String> { };

		List<CBK_PicklistValues__c> pickObj = [Select Id, CBK_ParentId__c, CBK_HasDependency__c, CBK_Dependencies__c, CBK_Picklist__c, Name, CBK_Object__c, CBK_Picklist__r.Name
											FROM CBK_PicklistValues__c where CBK_Picklist__r.Name = :inputField AND CBK_Picklist__r.CBK_Object__c =:inputObj
											ORDER BY Name];

		if (pickObj != null && pickObj.size() > 0) {
			for (CBK_PicklistValues__c pv : pickObj) {
				pickItem = new PicklistItems();
				pickItem.label = pv.Name;
				pickItem.value = pv.Id;
				lstpickItem.add(pickItem);
			}
		}
	return lstpickItem;
	}


	@AuraEnabled(cacheable = true)
	public static List<PicklistItems> picklistValuesDependency(String inputField, String inputValue, String inputObj) {		
		List<CBK_PicklistValues__c> pickObj = [SELECT Id, CBK_ParentId__c, CBK_HasDependency__c, CBK_Dependencies__c, CBK_Picklist__c, Name, CBK_Object__c, CBK_Picklist__r.Name FROM CBK_PicklistValues__c where CBK_Picklist__r.Name = :inputField AND Id = :inputValue AND CBK_Picklist__r.CBK_Object__c =:inputObj];
		List<PicklistItems> lstpickItemAll = new list<PicklistItems> ();
        System.debug('pickObj '+pickObj);

		if(!pickObj.isEmpty()){
			List<string> valuesName = new List<string> ();
			for (CBK_PicklistValues__c pv : pickObj) {
				if(pv.CBK_Dependencies__c !=null){
					valuesName.addAll(pv.CBK_Dependencies__c.split(';'));
				}
			}
			System.debug('valuesName '+valuesName);

			String pickDepend = getPicklistDependiente(inputField);
			System.debug('pickDepend '+pickDepend);

			List<CBK_PicklistValues__c> pickObjDepend = [SELECT Id, Name, CBK_Picklist__r.Name FROM CBK_PicklistValues__c WHERE NAME =: valuesName AND CBK_Picklist__r.Name =:pickDepend ORDER BY Name];
			System.debug('pickObjDepend '+pickObjDepend);

			for (CBK_PicklistValues__c pv : pickObjDepend) {
				PicklistItems pickItem = new PicklistItems();
				pickItem.label = pv.name;
				pickItem.value = pv.id;
				lstpickItemAll.add(pickItem);
			}
		}
		System.debug('lstpickItemAll '+lstpickItemAll);

		return lstpickItemAll;		
	}

	public static String getPicklistDependiente(String inputField) {
		String result;
		if(inputField.equalsIgnoreCase(CIBE_AppConstants.PICK_NEGOCIOS)){
			result = CIBE_AppConstants.PICK_REDES_SEG;
		}else if(inputField.equalsIgnoreCase(CIBE_AppConstants.PICK_REDES_SEG)){
			result = CIBE_AppConstants.PICK_SECTORES_PAI;
		}else if(inputField.equalsIgnoreCase(CIBE_AppConstants.PICK_SECTORES_PAI)){
			result = CIBE_AppConstants.PICK_CENTROS_CAR;
		}

		return result;
	}


	public static List<CBK_PicklistValues__c> getAllvaluesByField(String inputField) {
		List<CBK_PicklistValues__c> pickObj = [Select Id, CBK_ParentId__c, CBK_HasDependency__c, CBK_Dependencies__c, CBK_Picklist__c, Name, CBK_Object__c, CBK_Picklist__r.Name 
		FROM CBK_PicklistValues__c where CBK_Picklist__r.CBK_ParentId__r.Name = :inputField];
		return pickObj;
	}


	@AuraEnabled(cacheable = true) 
	public static PicklistHierarchy picklistValuesUserLogin(String inputUser) {
		PicklistHierarchy pickItem = new PicklistHierarchy ();
		List<String> listNegocio = new List<String>();
        List<String> listRedes = new List<String>();
        List<String> listSector = new List<String>();
        List<String> listCentro = new List<String>();

		List<Contact> listContact = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :inputUser];
		
        if(!listContact.isEmpty()) {
            List<Id> listId = new List<Id>();
            for(Contact c : listContact){
                listId.add(c.id);
            }
            if(!listId.isEmpty()) {
                List<CIBE_Hierarchy__c > pickHierar = [SELECT Id,CIBE_Negocios__c, CIBE_RedesSegmentos__c, CIBE_SectoresPaises__c,CIBE_CentrosCarteras__c FROM CIBE_Hierarchy__c WHERE CIBE_Contact__C = :listId];
                
                if(!pickHierar.isEmpty()) {
                    for (CIBE_Hierarchy__c pv : pickHierar) {
                        if(!listNegocio.contains(pv.CIBE_Negocios__c)){
                            listNegocio.add(pv.CIBE_Negocios__c);
                        }
						if(!listRedes.contains(pv.CIBE_RedesSegmentos__c)){
                            listRedes.add(pv.CIBE_RedesSegmentos__c);
                        }
                        if(!listSector.contains(pv.CIBE_SectoresPaises__c)){
                            listSector.add(pv.CIBE_SectoresPaises__c);
                        }
                        if(!listCentro.contains(pv.CIBE_CentrosCarteras__c)){
                            listCentro.add(pv.CIBE_CentrosCarteras__c);
                        }
                    }
                    if(listNegocio.size()==1){
                        pickItem.idNegocio=(listNegocio).get(0);
                    }
                    if(listRedes.size()==1){
                        pickItem.idRedes=(listRedes).get(0);
                    }
                    if(listSector.size()==1){
                        pickItem.idSector=(listSector).get(0);
                    }
                    if(listCentro.size()==1){
                        pickItem.idCentro=(listCentro).get(0);
                    }
				
                }
			}
        }
        return pickItem;
	}
    
    public class PicklistHierarchy{
		@AuraEnabled
		public string idNegocio { get; set; }
		@AuraEnabled
		public string idRedes { get; set; }
		@AuraEnabled
		public string idSector { get; set; }
		@AuraEnabled
		public string idCentro { get; set; }
	}

}