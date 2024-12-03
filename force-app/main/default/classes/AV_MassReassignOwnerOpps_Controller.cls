/**********************************************************************************************************************
 Name:      AV_MassReassignOwnerOpps_Controller
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for av_MassReassignOwnerOpps LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION  USER_STORY			AUTHOR				DATE        Description
   	1.0      US377759			Víctor Santiago		16/05/2022  Init version
	1.1      Fix Buscador		Víctor Santiago		10/06/2022  AV_Query to SOQL
	1.2		 DE63086			Sandra Gómez		08/08/2022	whitout sharing
	1.3		 Fix Oficina		Sandra Gómez		08/08/2022	Change options of employee with office
	1.4		 US464548 			Luis Fernández		19/12/2022	Added new fields to filter querys (AV_Potencial__c, LastModifiedDate and """)
	1.5      DE79573             Oscar Moreno       07/07/2023  Change searchOffice method to show the assigned office and lower offices
	1.6      US587408        	Ángel Medina        14/07/2023  Added AV_Group__c and AV_InterlocName__c to retrieved fields
   	1.7		 US692335			Elisabeth R.		16/10/2023	Added hasCustomPermission method
	1.8		 Revisar queries 	Ángel Medina		12/02/2024	Modify query from sosl to soql
***********************************************************************************************************************/
public without sharing class AV_MassReassignOwnerOpps_Controller {

	private final static Integer MAX_RESULTS 	= 10;
    private final static Integer MAX_LIMIT 		= 49900;
    private final static String  ID_GCF			= (String) [SELECT Id FROM User WHERE Alias = :AV_AppConstants.AV_ALIAS_AVTF9 LIMIT 1].Id;
	private final static String ALL_LABEL 		= 'all';
	public static Integer numberOfRecords;

	/**
	 * @description		Call LWC with filters Opportunity
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
	 * @param	potencial	The filter for the potential.
	 * @param	fechaModif	The filter for the modification date.
	 * @param	indicadoresCli	A list of strings representing client indicators.
	 */
	@AuraEnabled
    public static ObjectList getBaseData(String clientFilter, String subjectFilter, String origenFilter, String statusFilter,
	Date dueDate2Filter, Date dueDateFilter, String[] employeeFilter, String[] filterList, Date fechaCierreFilter, Date fechaGestionFilter,
	String page,String myBoxFilter,Boolean preconceivedFilter,String targetAutoFilter,String office,String potencial, Date fechaModif,List<String> indicadoresCli) {
		ObjectList result = new ObjectList();
		List<String> listEmployees = employeeFilter;				
		String employeeFilterFinal = '';
		String gestorFilter = '';
		for(String aux : listEmployees){
			employeeFilterFinal += aux + ',';
		}
	
		if(origenFilter.equals(ALL_LABEL)){
			origenFilter = null;
		}
		
			employeeFilterFinal= employeeFilterFinal.removeEnd(',');
			ObjectList ol1 = getOppsFilter(fechaCierreFilter, fechaGestionFilter, filterList, employeeFilter, origenFilter, statusFilter, subjectFilter, clientFilter, page, myBoxFilter, preconceivedFilter, targetAutoFilter, office,potencial, fechaModif,indicadoresCli);
			result.add(ol1);
		return result;
	}

	/**
	 * @description		Lookup of User Assigment
	 * @param officeFilterData The filter for the office.
	 */
	@AuraEnabled
	public static List<OptionsEmployee> getEmployees(String officeFilterData){
		List<OptionsEmployee> employees = new List<OptionsEmployee>();
		List<OptionsEmployee> employeesSorted = new List<OptionsEmployee>();
		List<Id> employeesId = new List<Id>();
		User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId()];
		if (String.isNotBlank(officeFilterData)) {
			String[] data = officeFilterData.split('\\{\\|}');
			if (data.size() > 1) {
				String profileId = [
					SELECT Id
					FROM Profile
					WHERE Name = :AV_AppConstants.AV_PROFILE
				].Id;
				Set<String> allRts = new Set<String>{
					AV_AppConstants.OPPINICIATIVA_RT,
					AV_AppConstants.OPPALERTACOM_RT,
					AV_AppConstants.OPPPROPUESTA_RT,
					AV_AppConstants.OPPSUGERENCIA_RT
				};
				List<RecordType> listRt = new List<RecordType>();
				
				Set<Id> setIdsRts = new Set<Id>();
				if(data[2] != ALL_LABEL){
					setIdsRts = AV_AppUtilities.getRecordTypeIdsInSet(new Set<String>{data[2]});			
					}else{
						setIdsRts = AV_AppUtilities.getRecordTypeIdsInSet(allRts);			
						}
						
				// Set<Id> setIdsRts = (new Map<Id,RecordType>(listRT)).keySet().clone();				
				AggregateResult[] oppsWithCenter = [
					SELECT OwnerId, Owner.Name
					FROM Opportunity
					WHERE AV_Center__c = :data[0] AND Owner.ProfileId = :profileId AND StageName = :data[1] AND RecordTypeId IN :setIdsRts
					GROUP BY OwnerId, Owner.Name
				];
				if (!oppsWithCenter.isEmpty()) {
					for (AggregateResult opp : oppsWithCenter) {
						employeesId.add((Id)opp.get('OwnerId'));
						employeesSorted.add(new OptionsEmployee((Id)opp.get('OwnerId'),(String)opp.get('Name')));
					}
				}
			} else if (data.size() == 1) {
				List<User> searchResults = [
					SELECT Id, Name, AV_NumeroOficinaEmpresa__c
                  	FROM User
                  	WHERE AV_NumeroOficinaEmpresa__c LIKE :('%' + officeFilterData + '%') AND IsActive = true
                  	LIMIT :MAX_LIMIT
				];
				if(!searchResults.isEmpty() && searchResults != null){
					for(User u : searchResults){
						employeesId.add(u.Id);
						employeesSorted.add(new OptionsEmployee(u.Id,u.Name));
					}
				}
			}
		}
		String employeesAlls=string.join(employeesId,',');
		if(employeesId.size()>1 ) {
			employees.add(new OptionsEmployee(ID_GCF+','+employeesAlls,'TODOS - CENTRO ' + officeFilterData.split('\\{\\|}')[0]));
		}
		employees.add(new OptionsEmployee(ID_GCF, AV_AppConstants.SINGESTOR_EAP_CENTRO + officeFilterData.split('\\{\\|}')[0]));
		employeesSorted.sort();
		employees.addAll(employeesSorted);
		return employees;		
	}

	/**
	 * @description		Result of Opportunity in Query
	 * @param fechaCierreFilter	The filter for the closing date.
	 * @param fechaGestionFilter The filter for the management date.
	 * @param filterList	An array of strings representing general filters.
	 * @param employeeFilter	An array of strings representing employee filters.
	 * @param origenFilter	The filter for the origin.
	 * @param statusFilter	The filter for the status.
	 * @param subjectFilter	The filter for the subject.
	 * @param clientFilter	The filter for the client.
	 * @param page	The page number for pagination.
	 * @param myBoxFilter The filter for "my box".
	 * @param preconceivedFilter	A boolean filter for preconceived data.
	 * @param targetAutoFilter	he filter for the target automation.
	 * @param office	The filter for the office.
	 * @param potencial	The filter for the potential.
	 * @param fechaModif	The filter for the modification date.
	 * @param indicadoresCli	A list of strings representing client indicators.
	 */
	private static ObjectList getOppsFilter(Date fechaCierreFilter,Date fechaGestionFilter, String[] filterList, String[] employeeFilter, String origenFilter, String statusFilter, String subjectFilter, String clientFilter, String page, String myBoxFilter, Boolean preconceivedFilter, String targetAutoFilter, String office,String potencial, Date fechaModif,List<String> indicadoresCli) {
		String methodName = 'getOppsFilter';
		Integer totalSize;
		User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId()];
		Set<String> setLabelsRts = new Set<String>{
			AV_AppConstants.OPPALERTACOM_RT,
			AV_AppConstants.OPPINICIATIVA_RT, 
			AV_AppConstants.OPPPROPUESTA_RT, 
			AV_AppConstants.OPPSUGERENCIA_RT,
            AV_AppConstants.OPPLLAMADA_RT};
		Set<String> setStatusOpen = new Set<String>{AV_AppConstants.OPP_STATUS_POTENCIAL, AV_AppConstants.OPP_STATUS_ENGESTION};
		Set<Id> setIdsRts = AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRts);
		Id oppRecordTypeId;
		if(origenFilter != null){
			oppRecordTypeId= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(origenFilter).getRecordTypeId();
		}
		Set<String> stageNull = new Set<String>{AV_AppConstants.OPP_STATUS_POTENCIAL, AV_AppConstants.OPP_STATUS_ENGESTION};
		Set<String> setOppFields = new Set<String>{'Id', 'Name', 'AV_PF__c','AV_Product__c', 'AV_ClientProduct__c','AV_PF__r.Name',
													'AV_IncludeInPrioritizingCustomers__c', 'AV_Gestor__c', 'RecordTypeId', 'RecordType.Name', 
													'AV_FechaProximoRecordatorio__c', 'AV_Valor1__c', 'AV_Concepto1__c', 'AV_Valor2__c', 'AV_Concepto2__c', 
													'AV_Valor3__c', 'AV_Concepto3__c', 'AV_Valor4__c', 'AV_Concepto4__c', 'AV_Valor5__c', 'AV_Concepto5__c', 
													'AV_Tenencia__c', 'AV_Entidad__c', 'CloseDate', 'AV_Cuota__c', 'Amount', 'AV_TipoInteres__c', 'AV_Comentarios__c', 
													'AV_Center__c', 'Account.Name', 'Owner.Name', 'OwnerId', 'AccountId','AV_Origen__c',
													'Account.AV_OficinaPrincipal__r.CC_Numero_Oficina_Empresa__c', 'Account.AV_Preconceived__c',
													'Account.AV_Age__c', 'Account.AV_AhorroEInversion__c', 'Account.AV_Financiacion__c', 'Account.AV_Ingresos__c', 'Account.AV_Group__c','Account.AV_InterlocName__c'};
		String query ;
		String toLabelFields = 'TOLABEL(StageName), TOLABEL(AV_Potencial__c), TOLABEL(Account.AV_MyBox__c), TOLABEL(Account.AV_TargetAuto__c)';
		String headerQuery = 'SELECT ' + String.join(new List<String>(setOppFields), ',') + ', ' + toLabelFields;
		String headerCountQuery = 'SELECT COUNT(Id) ';
		query = ' FROM Opportunity WHERE AV_ToDelete__c = false';
		if(subjectFilter != null){
			query += ' AND Name Like \'%' + subjectFilter + '%\'';
		}
		if(fechaCierreFilter != null){
			Datetime dt = (DateTime) fechaCierreFilter;
			query += ' AND CloseDate <= ' + dt.format('yyyy-MM-dd');
		}

		if(filterList != null && !filterList.isEmpty()){
			query += ' AND AV_PF__c IN ' + AV_AppUtilities.arrayToStringIn(filterList);
		}
		if(fechaGestionFilter != null){
			Datetime dt = (DateTime) fechaGestionFilter;
			query += ' AND AV_FechaProximoRecordatorio__c >= ' + dt.format('yyyy-MM-dd');
		}
		if(origenFilter != null){
			query += ' AND RecordType.Id = \'' + oppRecordTypeId + '\'';
		} else {
			query += ' AND RecordType.Id IN (';
			Integer i = 0;
			for(String rt : setIdsRts){
				query += '\'' + rt + '\'';
				query += (++i == (setIdsRts.size()))?')':',';
			}
	}
		if(clientFilter != null){
			query += ' AND AccountId = \'' + clientFilter + '\'';
		}
		if(statusFilter != null){
			query += ' AND StageName = \'' + statusFilter + '\'';
		}
		if(myBoxFilter != null) {
			if (myBoxFilter == AV_AppConstants.NOT_SELECTED) {
				query = query + ' AND Account.AV_MyBox__C = null';
			} else {
				query = query + ' AND Account.AV_MyBox__C = \''+myBoxFilter+'\'';
			}
		}
		if(preconceivedFilter != null){
			query = query + ' AND Account.AV_IsPreconceived__c = '+preconceivedFilter;
		}
		if(targetAutoFilter!=null) {
			if (targetAutoFilter == AV_AppConstants.NOT_SELECTED) {
				query = query + ' AND Account.AV_TargetAuto__c = null';
			} else {
				query = query + ' AND Account.AV_TargetAuto__c = \''+targetAutoFilter+'\'';
			}
		}
		if(potencial != null){
			query = query + ' AND AV_Potencial__c = \''+ potencial +'\'';
		}
		
		if(fechaModif != null){
			Datetime dateModif = (Datetime) fechaModif;
			query = query + ' AND AV_FechaModificacion__c = '+ dateModif.format('yyyy-MM-dd') ;
		}
		if(!indicadoresCli.isEmpty()){
			query += ' AND Account.AV_IndicadoresClientes__c INCLUDES (';
			String debug = '(';
			Integer j = 0;
			for(String valor : indicadoresCli){
				query += '\'' + valor + '\'';
				query += (++j == (indicadoresCli.size()))?')':',';
			}

		}
		if(employeeFilter != null) {
			if (ID_GCF.equalsIgnoreCase(employeeFilter[0]) && employeeFilter.size()==1) {
				query = query + ' AND OwnerId = \''+ID_GCF+'\' AND AV_Center__c =\''+office+'\'';
			} else if (employeeFilter[0].contains(ID_GCF) && employeeFilter.size()==1) {
				query = query + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_Center__c =\''+office+'\'';
			} else if (employeeFilter.contains(ID_GCF)) {
				query = query + ' AND AV_Center__c =\''+office+'\'';
			} else {
				query = query + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_Center__c =\''+office+'\'';
			}
		} else {
			query = query + ' AND AV_CodigoGestorAsignado__c = null';
		}
		String countQuery = headerCountQuery+ query;
		query += ' ORDER BY CloseDate ASC LIMIT ' + Integer.valueOf(page)*100 + ' OFFSET ' + (Integer.valueOf(page)-1)*100;
		query = query.replaceAll('[{}]', '');
		AV_LogDebug.printLogDebug(methodName, '-----> Query to execute: ' + query);
		totalSize = '1'.equals(page) ? getNumberOfOpps(countQuery) : -1;
		String queryToExec = headerQuery + query;
		List<Opportunity> lista = capsulateQuery(queryToExec);
		return new ObjectList('Opportunity', totalSize, lista);
	}
	
	/**
	 * @description		Change Quality Cloud
	 */
	private static List<Opportunity> capsulateQuery(String q){
		return (List<Opportunity>) Database.query(q);
	}

	/**
	 * @description		Lookup of User Utilizado en el buscador de opportunity
	 * @param searchTerm
	 * @param selectedIds A list of selected user IDs.
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
	 * @description		Lookup of User 
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
	 * @description		Lookup of Product
	 * @param	searchTerm	The search term to look up users.
	 * @param	selectedIds	A list of selected user IDs.
	 */
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchProduct(String searchTerm, List<String> selectedIds) {
		String methodName = 'searchProduct';
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();

		Id productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(AV_AppConstants.PRODUCT_PF_RT).getRecordTypeId();

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

	/**
	 * @description		Lookup of Account
	 * @param	searchTerm	The search term to look up users.
	 * @param	selectedIds	A list of selected user IDs.
	 */
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchAccount(String searchTerm, List<String> selectedIds) {
		
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		Set<String> setLabelsRts = new Set<String>{AV_AppConstants.ACCOUNT_ENT_RT, AV_AppConstants.ACCOUNT_PA_RT};
		Set<Id> setIdsRts = AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRts);

		if(!selectedIds.isEmpty()){
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Account(Id, Name, AV_Numperso__c WHERE Id NOT IN :selectedIds and RecordType.Id IN: setIdsRts and AV_Numperso__c!=null and AV_Confidencial__c=false)
				LIMIT :MAX_RESULTS
			];
		} else{
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Account(Id, Name, AV_Numperso__c WHERE RecordType.Id IN: setIdsRts and AV_Numperso__c!=null and AV_Confidencial__c=false)
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
					'Codigo • ' + acc.AV_Numperso__c 
				)
			);
		}
		results.sort();

		return results;
	}

	/**
	 * @description		Lookup of Office
	 * @param	searchTerm	The search term to look up users.
	 * @param	selectedIds	A list of selected user IDs.
	 */
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchOffice(String searchTerm, List<String> selectedIds) {
		Set<String> directores = new Set<String>{AV_AppConstants.FUNCION_DT, AV_AppConstants.FUNCION_DC, AV_AppConstants.FUNCION_DAN};
		Set<String> gestor = new Set<String>{AV_AppConstants.FUNCION_GESTOR, AV_AppConstants.FUNCION_OFICINA};
		String sscc = AV_AppConstants.FUNCION_SSCC;
		searchTerm +='*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(AV_AppConstants.ACCOUNT_CTO_RT).getRecordTypeId();

		User currentUser = [
			SELECT AV_Funcion__c, AV_NumeroOficinaEmpresa__c, AV_OriginalOfficeNumber__c
			FROM User
			WHERE Id = :UserInfo.getUserId()
		];
		
		
		Set<Id> offices;
		if (currentUser.AV_OriginalOfficeNumber__c != null) {
			offices = AV_MassReassignOwner_Controller.getInferiorCenterIds(currentUser);
		}else {
			offices = AV_MassReassignOwner_Controller.getInferiorCenterIds();
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
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id NOT IN :selectedIds and (Id = :centroUsuario.Id or Id IN :offices) and RecordType.Id =: accRecordTypeId)
						LIMIT :MAX_RESULTS
					];
				} else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id NOT IN :selectedIds and Id IN :offices and RecordType.Id =: accRecordTypeId)
						LIMIT :MAX_RESULTS
					];
				}
			} else{
				if (currentUser.AV_OriginalOfficeNumber__c != null) {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE (Id = :centroUsuario.Id or Id IN :offices) and RecordType.Id =: accRecordTypeId)
						LIMIT :MAX_RESULTS
					];
				}else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE (Id = :centroUsuario.Id or Id IN :offices) and RecordType.Id =: accRecordTypeId)
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
			} else{
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
				} else {
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
	 * @description		Assigment Opportunity to new Owner
	 * @param	objectName	The name of the object being assigned.
	 * @param	contactId	The ID of the contact for the assignment.
	 * @param selectedRows	 A list of sObjects representing the selected rows for the assignment.
	 */
	@AuraEnabled
	public static String assign(String objectName , String contactId, List<sObject> selectedRows){
		Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.OptAllOrNone = false;
		dmlOptions.EmailHeader.triggerUserEmail = false;

		List<Opportunity> oppos = new List<Opportunity>();
		for(sObject o : selectedRows){
			String oId = o.get('Id').toString();
			Opportunity oppo = new Opportunity(Id = oId, OwnerId = contactId);
			oppos.add(oppo);
		}
		Database.SaveResult[] srList = Database.update(oppos, dmlOptions);
		return String.valueOf(srList.size());
	}

	/**
	 * @description		Gets Name User assigment Contact
	 * @param contactId 	The ID of the Contact for which to retrieve the assigned user's name.
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
	 * @description		Gets the total number of records of the query used in getOppsFilter (without 
	 * 					OFFSET and LIMIT)
	 */
	public static Integer getNumberOfOpps(String query) {
		return Integer.valueOf((capsulateCountQuery(query)).get(0).get('expr0'));
	}

	/**
	 * @description		Change Quality Cloud
	 */
	private static List<AggregateResult> capsulateCountQuery(String q){
		return (List<AggregateResult>) Database.query(q);
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
	@AuraEnabled
	public static List<Map<String,String>> getIndicadorCliOptions(){
		List<Schema.PicklistEntry> indicadorField = Account.AV_IndicadoresClientes__c.getDescribe().getPicklistValues();
		List<Map<String,String>> result = new List<Map<String,String>>();
		for(Schema.PicklistEntry entry : indicadorField){
			result.add(
				new Map<String,String>{'label' => entry.getLabel(),'value' => entry.getValue()}
			);
			
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

	@AuraEnabled
	public static Boolean hasCustomPermission(){
		return FeatureManagement.checkPermission('AV_PrivateBanking');
	}
}