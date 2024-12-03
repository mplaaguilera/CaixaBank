/**********************************************************************************************************************
 Name:      CIBE_MassReassignOwnerOpps_Controller
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for CIBE_MassReassignOwnerOpps_Controller LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION  USER_STORY			AUTHOR				DATE        Description
	1.0      US380297			Luis Martínez		16/11/2022  Init version
***********************************************************************************************************************/
public without sharing class CIBE_MassReassignOwnerOpps_Controller {

	private final static Integer MAX_RESULTS 	= 10;
    private final static Integer MAX_LIMIT 		= 49900;
    private final static String  ID_GCF			= (String) [SELECT Id FROM User WHERE Alias = 'AV-TF9' LIMIT 1].Id;
	public static Integer numberOfRecords;

	@AuraEnabled
    public static ObjectList getBaseData(String clientFilter, String subjectFilter, String origenFilter, String statusFilter,String[] employeeFilter,
	String[] filterList, Date fechaCierreD, Date fechaCierreH,String page,String office,String targetProbabilidad,Double importeFilter, String[] participesFilter) {
		ObjectList result = new ObjectList();
		List<String> listEmployees = employeeFilter;				
		String employeeFilterFinal = '';
		for(String aux : listEmployees){
			employeeFilterFinal += aux + ',';
		}
		if (String.isNotBlank(employeeFilterFinal)){
			employeeFilterFinal= employeeFilterFinal.removeEnd(',');
			ObjectList ol1 = getOppsFilter(fechaCierreD, fechaCierreH, filterList, employeeFilter, origenFilter, statusFilter, subjectFilter, clientFilter, page, office, targetProbabilidad,importeFilter, participesFilter);
			result.add(ol1);
		}
		return result;
	}

	@AuraEnabled
	public static List<OptionsEmployee> getEmployees(String officeFilterData){
		List<OptionsEmployee> employees = new List<OptionsEmployee>();
		List<OptionsEmployee> employeesSorted = new List<OptionsEmployee>();
		List<Id> employeesId = new List<Id>();
		User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId()];
		List<Profile> lstProfileId = [SELECT Id FROM Profile WHERE Name = :AV_AppConstants.AV_PROFILE OR Name = :CIBE_AppConstants.CIBE_GESTOR];

		if (String.isNotBlank(officeFilterData)) {
			String[] data = officeFilterData.split('\\{\\|}');
			if (data.size() > 1) {
				List<RecordType> listRT = [SELECT Id, DeveloperName FROM RecordType WHERE Name = :data[2]];
				Set<Id> setIdsRts = (new Map<Id,RecordType>(listRT)).keySet().clone();				
				AggregateResult[] oppsWithCenter = [SELECT OwnerId, Owner.Name  FROM Opportunity
                                                    WHERE AV_Center__c = :data[0] AND Owner.ProfileId IN :lstProfileId AND StageName = :data[1] AND RecordTypeId IN :setIdsRts
                                                    GROUP BY OwnerId, Owner.Name];
				if (!oppsWithCenter.isEmpty()) {
					for (AggregateResult opp : oppsWithCenter) {
						employeesId.add((Id)opp.get('OwnerId'));
						employeesSorted.add(new OptionsEmployee((Id)opp.get('OwnerId'),(String)opp.get('Name')));
					}
				}
			} else if (data.size() == 1) {
				List<List<SObject>> searchResults = [FIND :officeFilterData IN ALL FIELDS 
                RETURNING User(Id, Name, AV_NumeroOficinaEmpresa__c WHERE IsActive = true) LIMIT :MAX_LIMIT];
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
			employees.add(new OptionsEmployee(ID_GCF+','+employeesAlls,'TODOS - CENTRO ' + officeFilterData.split('\\{\\|}')[0]));
		}
		employees.add(new OptionsEmployee(ID_GCF,'Sin Gestor / Eap - CENTRO ' + officeFilterData.split('\\{\\|}')[0]));
		employeesSorted.sort();
		employees.addAll(employeesSorted);
		return employees;		
	}

	private static ObjectList getOppsFilter(Date fechaCierreD,Date fechaCierreH, String[] filterList, String[] employeeFilter, String origenFilter, String statusFilter, String subjectFilter, String clientFilter, String page, String office, 
	String targetProbabilidad, Double importeFilter ,String[] participesFilter) {
		String methodName = 'getOppsFilter';
		Integer totalSize;
		Id oppRecordTypeId;
		User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId()];
		Set<String> setLabelsRts = new Set<String>{CIBE_AppConstants.OPP_ACCIONEMP_RT,CIBE_AppConstants.OPP_SUGERENCIAEMP_RT,CIBE_AppConstants.OPP_ALERTAEMP_RT,CIBE_AppConstants.OPP_INICIATIVAEMP_RT};

		//ERI
		Set<Id> setIdsRts = AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRts);
		//OTM
		List<OpportunityTeamMember> listaOtm = new List<OpportunityTeamMember>();
		Set<Id> setIdsOP = new Set<Id>();

		String childOtm=',(Select id, name, OpportunityId, CIBE_Centro__c from OpportunityTeamMembers)';
		if(String.isBlank(origenFilter)){origenFilter =CIBE_AppConstants.OPP_INICIATIVAEMP_RT;}

		oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(origenFilter).getRecordTypeId();

		if(participesFilter!=null && !participesFilter.isEmpty() ){
			listaOtm  = [Select id, name, OpportunityId, userid from OpportunityTeamMember WHERE id IN:participesFilter OR user.name IN:participesFilter];
		}
		
		Set<String> stageNull = new Set<String>{'Potencial', 'En curso'};
		Set<String> setOppFields = new Set<String>{'Id', 'Name', 'AV_PF__c','AV_Product__c', 'AV_ClientProduct__c','AV_PF__r.Name',
													'CIBE_Balance__c','Amount','CIBE_Comisiones__c',
													'AV_IncludeInPrioritizingCustomers__c', 'AV_Gestor__c', 'RecordTypeId', 'RecordType.Name', 
													'AV_FechaProximoRecordatorio__c', 'AV_Comentarios__c', 
													'AV_Entidad__c', 'CloseDate', 'AV_Cuota__c', 'AV_TipoInteres__c', 
													'AV_Center__c', 'Account.Name', 'Owner.Name', 'OwnerId', 'AccountId','AV_Origen__c',
													'Account.AV_OficinaPrincipal__r.CC_Numero_Oficina_Empresa__c', 'Account.AV_Preconceived__c',
													'Account.AV_AhorroEInversion__c', 'Account.AV_Financiacion__c', 'Account.AV_Ingresos__c'};
		String query;
		String toLabelFields = 'TOLABEL(StageName), TOLABEL(AV_Potencial__c), TOLABEL(Account.AV_MyBox__c), TOLABEL(Account.AV_TargetAuto__c),TOLABEL(CIBE_ProbabilidadExito__c) ';
		
		query = 'SELECT ' + String.join(new List<String>(setOppFields), ',') + ', ' + toLabelFields + ''+childOtm+' FROM Opportunity WHERE AV_ToDelete__c = false';
		
		if(subjectFilter != null){
			query += ' AND Name Like \'%' + subjectFilter + '%\'';
		}
		if(fechaCierreD != null){
			Datetime dt = (DateTime) fechaCierreD;
			query += ' AND CloseDate  >= ' + dt.format('yyyy-MM-dd');
		}
		if(fechaCierreH != null){
			Datetime dt2 = (DateTime) fechaCierreH;
			query += ' AND CloseDate <=' + dt2.format('yyyy-MM-dd');
		}
		if(filterList != null && !filterList.isEmpty()){
			query += ' AND AV_PF__c IN ' + AV_AppUtilities.arrayToStringIn(filterList);
		}
		if(origenFilter != null){
			query += ' AND RecordType.Id = \'' + oppRecordTypeId + '\'';
		} else {
			query += ' AND RecordType.Id IN ' + setIdsRts;
		}
		if(clientFilter != null){
			query += ' AND AccountId = \'' + clientFilter + '\'';
		}
		if(!String.IsBlank(statusFilter) ){
			query += ' AND StageName = \'' + statusFilter + '\'';
		}
		if(targetProbabilidad != null){
			query += ' AND CIBE_ProbabilidadExito__c = \'' + targetProbabilidad + '\'';
		}
		if(importeFilter != null && importeFilter != 0){
			query += ' AND Amount > ' + importeFilter ;
		}
		if(!listaOtm.isEmpty()) {
			List<String> setOtm = new List<String>();
			for(OpportunityTeamMember tm:listaOtm){
				setOtm.add(tm.OpportunityId);
			}
			system.debug('setOtm: ' + setOtm);
			query = query + ' AND id IN '+AV_AppUtilities.arrayToStringIn(setOtm);
		}
		if(employeeFilter != null) {
			if (ID_GCF.equalsIgnoreCase(employeeFilter[0]) && employeeFilter.size()==1) {
				query = query + ' AND OwnerId = \''+ID_GCF+'\' AND AV_Center__c =\''+office+'\'';
            } else if (employeeFilter[0].contains(ID_GCF) && employeeFilter.size()==1) {
				query = query + ' AND (OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter[0].remove(ID_GCF+',').split(','))+' OR (OwnerId = \''+ID_GCF+'\' AND AV_Center__c =\''+office+'\'))';
            } else if (employeeFilter.contains(ID_GCF)) {
				employeeFilter.remove(employeeFilter.indexOf(ID_GCF));
				query = query + ' AND (OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' OR (OwnerId = \''+ID_GCF+'\' AND AV_Center__c =\''+office+'\'))';
            } else {
				query = query + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter);
            }
		} else {
			query = query + ' AND AV_CodigoGestorAsignado__c = null';
		}
		query += ' ORDER BY CloseDate ASC LIMIT ' + Integer.valueOf(page)*100 + ' OFFSET ' + (Integer.valueOf(page)-1)*100;
		query = query.replaceAll('[{}]', '');
		AV_LogDebug.printLogDebug(methodName, '-----> Query to execute: ' + query);
		//totalSize = '1'.equals(page) ? getNumberOfOpps(fechaCierreD, fechaCierreH, filterList, employeeFilter, origenFilter, statusFilter, subjectFilter, clientFilter, page, office, targetProbabilidad,importeFilter,participesFilter) : -1;
		//totalSize = '1'.equals(page) ? getNumberOfOpps(query) : -1;
	
		List<Opportunity> lista = capsulateQuery(query);
		system.debug('lista: '+lista);
		totalSize = '1'.equals(page) ? lista.size() : -1;

		return new ObjectList('Opportunity', totalSize, lista);
	}


	
	private static List<Opportunity> capsulateQuery(String q){//Método para pasar qualityClouds
		return (List<Opportunity>) Database.query(q);
	}

	//Utilizado para buscador de oportunidades
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchUser(String searchTerm, List<String> selectedIds) {
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		String pGestor=CIBE_AppConstants.CIBE_GESTOR;
		String pAvUser=AV_AppConstants.AV_PROFILE;
		
		if(!selectedIds.isEmpty()){
			searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
			User(Id, Name, AV_ExternalID__c WHERE Id NOT IN :selectedIds and IsActive=true and (Profile.Name=:pAvUser OR Profile.Name = :pGestor))LIMIT :MAX_RESULTS];
		}
		else{
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					User(Id, Name, AV_ExternalID__c WHERE IsActive=true and (Profile.Name=:pAvUser OR Profile.Name = :pGestor))
				LIMIT :MAX_RESULTS
			];

		}

		String userIcon = 'standard:user';
		User[] listUser = (List<User>) searchResults[0];
		for (User u : listUser) {
			results.add(new AV_LookupSearchResult(u.Id,'User',userIcon,u.Name,'Matrícula • ' + u.AV_ExternalID__c));
		}
		results.sort();

		return results;
	}

	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> search(String searchTerm, List<String> selectedIds, Boolean myOffice) {
		List<Profile> lstProfileId = [SELECT Id FROM Profile WHERE Name = :AV_AppConstants.AV_PROFILE OR Name = :CIBE_AppConstants.CIBE_GESTOR];

		User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId()];
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		
		if (Boolean.valueOf(myOffice)) {
			if(!selectedIds.isEmpty()){
				searchResults = [ FIND :searchTerm IN ALL FIELDS RETURNING
				User(Id, Name, AV_NumeroOficinaEmpresa__c  WHERE Id NOT IN :selectedIds and IsActive=true and ProfileId IN:lstProfileId and AV_NumeroOficinaEmpresa__c=:emp.AV_NumeroOficinaEmpresa__c)LIMIT :MAX_RESULTS];
			} else {
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
						User(Id, Name, AV_NumeroOficinaEmpresa__c  
						WHERE IsActive=true and ProfileId IN:lstProfileId and AV_NumeroOficinaEmpresa__c=:emp.AV_NumeroOficinaEmpresa__c)
					LIMIT :MAX_RESULTS
				];
			}
		} else {
			if(!selectedIds.isEmpty()){
				searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
				User(Id, Name, AV_NumeroOficinaEmpresa__c  
				WHERE Id NOT IN :selectedIds and IsActive=true and ProfileId IN:lstProfileId and AV_NumeroOficinaEmpresa__c!=:emp.AV_NumeroOficinaEmpresa__c) LIMIT :MAX_RESULTS];
			} else {
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
						User(Id, Name, AV_NumeroOficinaEmpresa__c  WHERE IsActive=true and ProfileId IN:lstProfileId and AV_NumeroOficinaEmpresa__c!=:emp.AV_NumeroOficinaEmpresa__c)
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
			results.add(new AV_LookupSearchResult(u.Id,'User',userIcon,	u.Name,	'Centro • ' + userCentro));
		}
		results.sort();

		return results;
	}

	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchProduct(String searchTerm, List<String> selectedIds) {
		String methodName = 'searchProduct';
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		Id productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('AV_PF').getRecordTypeId();

		if(!selectedIds.isEmpty()){
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Product2(Id, Name, AV_ExternalID__c WHERE Id NOT IN :selectedIds and RecordType.Id =: productRecordTypeId and AV_Nivel__c=null and AV_ExternalID__c!=null)
				LIMIT :MAX_RESULTS
			];
		}
		else{
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Product2(Id, Name, AV_ExternalID__c WHERE RecordType.Id =: productRecordTypeId and AV_Nivel__c=null and AV_ExternalID__c!=null)
				LIMIT :MAX_RESULTS
			];
		}
		String productIcon = 'standard:product';
		Product2[] listProduct = (List<Product2>) searchResults[0];
		for (Product2 p : listProduct) {
			results.add(
				new AV_LookupSearchResult(
					p.Id,
					'Product2',
					productIcon,
					p.Name,
					'Codigo • ' + p.AV_ExternalID__c
				)
			);
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
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Account(Id, Name, AV_Numperso__c WHERE Id NOT IN :selectedIds and RecordType.Id IN: setIdsRts and AV_Confidencial__c=false)
				LIMIT :MAX_RESULTS
			];
		} else{
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Account(Id, Name, AV_Numperso__c WHERE RecordType.Id IN: setIdsRts and AV_Confidencial__c=false)
				LIMIT :MAX_RESULTS
			];
		}		
		system.debug('searchResults: '+searchResults);
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
		system.debug('results: '+results);

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
		system.debug('currentUser: '+currentUser);
		system.debug('centroUsuario: '+centroUsuario);
	
		if (String.isNotBlank(currentUser.AV_Funcion__c) && directores.contains(currentUser.AV_Funcion__c)) {
				system.debug('1 if 2 query: ');
				if(!Test.isRunningTest()){
					searchResults = [FIND :searchT IN ALL FIELDS RETURNING
					Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id IN :offices and RecordType.Id =: accRecordTypeId)
					LIMIT :MAX_RESULTS];
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
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id = :centroUsuario.Id and RecordType.Id =: accRecordTypeId)
							LIMIT :MAX_RESULTS];
				}	
		} else if (String.isNotBlank(currentUser.AV_Funcion__c) && sscc.equals(currentUser.AV_Funcion__c)) {
				searchResults = [FIND :searchT IN All FIELDS RETURNING
						Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE RecordType.Id =: accRecordTypeId)
						LIMIT :MAX_RESULTS];
		}	
		String productIcon = 'standard:account';
        listAccount = (List<Account>) searchResults[0];
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
	private static List<OpportunityTeamMember> capsulateQueryTM(String q){//Método para pasar qualityClouds
		return (List<OpportunityTeamMember>) Database.query(q);
	}

	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchParticipe(String searchTerm, List<String> selectedIds,String numOficina) {
		String methodName = 'searchParticipe';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();

		String query ='SELECT Id, Name, OpportunityId, UserId, User.name, CIBE_Centro__c ';
		query+='FROM OpportunityTeamMember WHERE name  LIKE \'%'+searchTerm+'%\'';
		List<OpportunityTeamMember> queryteamMembers = new List<OpportunityTeamMember>();
		List<OpportunityTeamMember> teamMembers = new List<OpportunityTeamMember>();
		Set<Id> setOtm = new Set<Id>();
		queryteamMembers =capsulateQueryTM(query);

		for(OpportunityTeamMember q:queryteamMembers){
			if(!setOtm.contains(q.UserId)){
				setOtm.add(q.UserId);
				teamMembers.add(q);
			}
		}
		System.debug('teamMembers: '+teamMembers);
		String productIcon = 'standard:user';
		for (OpportunityTeamMember p : teamMembers) {
			System.debug('for teamMembers: '+p);
			results.add(
				new AV_LookupSearchResult(
					p.id,
					'OpportunityTeamMember',
					productIcon,
					p.Name,
					p.CIBE_Centro__c
				)
			);
		}
		results.sort();
		system.debug('results: '+results);

		return results;
	}
	@AuraEnabled
	public static String assign(String objectName , String contactId, List<sObject> selectedRows){
		Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.OptAllOrNone = false;
		dmlOptions.EmailHeader.triggerUserEmail = false;
		system.debug('objectName: '+objectName);
		system.debug('contactId: '+contactId);
		system.debug('selectedRows: '+selectedRows);

		List<Opportunity> oppos = new List<Opportunity>();
		for(sObject o : selectedRows){
			String oId = o.get('Id').toString();
			Opportunity oppo = new Opportunity(Id = oId, OwnerId = contactId);
			oppos.add(oppo);
		}
		system.debug('oppos: '+oppos);

		Database.SaveResult[] srList = Database.update(oppos, dmlOptions);
		return String.valueOf(srList.size());
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


	/**
	 * @description		Get the center that are inferior to current user depending
	 * 					on the user's AV_Funcion__c
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
		if ('DT'.equals(funcion)) {
			offices.addAll(getInferiorCenters(ids));
		}
		if ('DC'.equals(funcion) || !offices.isEmpty()) {
			if (!offices.isEmpty()) {
				ids.clear();
				ids.addAll(getCenterIds(offices));
				offices.clear();
			}
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
     * @param superiorCenters   List of immediately superior centers
     */
    public static List<Account> getInferiorCenters(List<Id> superiorCenters) {
        List<Account> inferiorCenters = [
            SELECT Id, Name, CC_Numero_Oficina__c, AV_CentroSuperior__c, CC_Numero_Oficina_Empresa__c
            FROM Account
            WHERE AV_CentroSuperior__c IN :superiorCenters
        ];
        return inferiorCenters;
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
}