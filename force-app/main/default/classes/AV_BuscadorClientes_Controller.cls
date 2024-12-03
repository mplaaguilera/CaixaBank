/**********************************************************************************************************************
 Name:      AV_BuscadorClientes_Controller
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for av_BuscadorClientes LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION		USER_STORY			AUTHOR				DATE		Description
   	1.0			US295559			Víctor Santiago		04/08/2022	Init version
	1.1			Fix					Sandra Gómez		01/12/2022	Error queries and whitout
	1.2         US493064            Elisabeth Rodríguez 21/12/2022  Modified filter query getBooks
	1.3         Fix SortBy          Elisabeth Rodríguez 09/02/2022  Modified return currency fields for sorting functionality
	1.4         DE74258          	Patricia Solano		22/03/2022  Modified to pass quality clouds for fix of method getNumberOfCustomers
    1.5         DE79573             Oscar Moreno        07/07/2023  Change searchOffice method to show the assigned office and lower offices
	1.6         US587408        	Ángel Medina        14/07/2023  Added AV_Group__c and AV_InterlocName__c to retrieved fields
***********************************************************************************************************************/
public without sharing class AV_BuscadorClientes_Controller {
    
    private final static Integer MAX_RESULTS 	= 10;
    private final static Integer MAX_LIMIT 		= 49900;
    private final static String  ID_GCF			= [SELECT Id FROM User WHERE Profile.Name = :AV_AppConstants.AV_PROFILE_APIONLY  AND Alias = :AV_AppConstants.AV_ALIAS_AVTF9 LIMIT 1].Id;
	public static Integer numberOfRecords;

	/**
	 * @description		Get BaseData
	 * @param office	 the customer's office
	 * @param negocio	the customer's business type
	 * @param employeeFilter	Filter for employees related to the customer
	 * @param cartera	the customer's portfolio type
	 * @param modelo	the customer's model
	 * @param edadMin	the customer's minimum age
	 * @param edadMax	the customer's maximum age
	 * @param ingresos	 the customer's minimum income
	 * @param ingresosMax	the customer's maximum income
	 * @param ahorroMin	the customer's minimum savings
	 * @param ahorroMax	the customer's maximum savings
	 * @param financiacionMin	the customer's minimum financing amount
	 * @param financiacionMax	the customer's maximum financing amount
	 * @param rentabilidadMin	the customer's minimum profitability
	 * @param rentabilidadMax	the customer's maximum profitability
	 * @param exp	the customer's experience
	 * @param myBox	the customer's "myBox" status
	 * @param preconMin	the customer's minimum precon value
	 * @param preconMax	the customer's maximum precon value
	 * @param targetAuto	the customer's car target
	 * @param page	Page number for result pagination
	 * @param grupo	Group to which the customer belongs
	 * @param interlocName	Customer's interlocutor name
	 */

	@AuraEnabled
    public static ObjectList getBaseData(String office, String negocio, String[] employeeFilter,
	String cartera, String modelo, String edadMin, String edadMax, String ingresosMin, String ingresosMax,
	String ahorroMin, String ahorroMax, String financiacionMin, String financiacionMax, String rentabilidadMin,
	String rentabilidadMax, String exp, String mybox, String preconMin, String preconMax, String targetAuto, String page, String grupo, String interlocName) {
		ObjectList result = new ObjectList();
		ObjectList ol = getCustomers(office, negocio, employeeFilter, cartera, modelo, edadMin, edadMax, ingresosMin, ingresosMax, ahorroMin, ahorroMax, financiacionMin, financiacionMax, rentabilidadMin, rentabilidadMax, exp, mybox, preconMin, preconMax, targetAuto, page, grupo, interlocName);
		return ol;
	}

	/**
	 * @description		Get customers by OwnerId (selected employees)
	 * @param office	 for the customer's office
	 * @param negocioFilter	Filter for the customer's business type
	 * @param employeeFilter	Filter for employees related to the customer
	 * @param carteraFilter	Filter for the customer's portfolio type
	 * @param modeloFilter	Filter for the customer's model
	 * @param edadMinFilter	Filter for the customer's minimum age
	 * @param edadMaxFilter	Filter for the customer's maximum age
	 * @param ingresosMinFilter	 Filter for the customer's minimum income
	 * @param ingresosMaxFilter	Filter for the customer's maximum income
	 * @param ahorroMinFilter	Filter for the customer's minimum savings
	 * @param ahorroMaxFilter	Filter for the customer's maximum savings
	 * @param financiacionMinFilter	Filter for the customer's minimum financing amount
	 * @param financiacionMaxFilter	Filter for the customer's maximum financing amount
	 * @param rentabilidadMinFilter	Filter for the customer's minimum profitability
	 * @param rentabilidadMaxFilter	Filter for the customer's maximum profitability
	 * @param experienciaFilter	Filter for the customer's experience
	 * @param myBoxFilter	Filter for the customer's "myBox" status
	 * @param preconMinFilter	Filter for the customer's minimum precon value
	 * @param preconMaxFilter	Filter for the customer's maximum precon value
	 * @param targetAutoFilter	Filter for the customer's car target
	 * @param page	Page number for result pagination
	 * @param grupo	Group to which the customer belongs
	 * @param interlocName	Customer's interlocutor name
	 */
	
    private static ObjectList getCustomers(String office, String negocioFilter, String[] employeeFilter,
	String carteraFilter, String modeloFilter, String edadMinFilter, String edadMaxFilter, String ingresosMinFilter,
	String ingresosMaxFilter, String ahorroMinFilter, String ahorroMaxFilter, String financiacionMinFilter, String financiacionMaxFilter,
	String rentabilidadMinFilter, String rentabilidadMaxFilter, String experienciaFilter, String myBoxFilter, String preconMinFilter,
	String preconMaxFilter, String targetAutoFilter, String page, String grupo, String interlocName) {
        String methodName = 'getCustomers';
        String query;
		Integer totalSize;
        Set<String> fields = new Set<String>{
            'Id', 'Name', 'CC_Numero_Documento__c', 'AV_Age__c', 'AV_Ingresos__c', 'AV_AhorroEInversion__c',
            'AV_Financiacion__c', 'AV_Rentabilidad__c', 'AV_Vinculacion__c', 'AV_Satisfaccion__c',
            'AV_EAPGestor__c', 'AV_EAPGestor__r.Name', 'Owner.AV_NumeroOficinaEmpresa__c', 'AV_Preconceived__c', 'AV_Group__c', 'AV_InterlocName__c'
        };
        String toLabelFields = 'TOLABEL(AV_AttentionModel__c), TOLABEL(AV_Negocio__c), TOLABEL(Account.AV_MyBox__c), TOLABEL(Account.AV_TargetAuto__c)';
		Set<String> rtDevNames = new Set<String>{AV_AppConstants.ACCOUNT_ENT_RT, AV_AppConstants.ACCOUNT_PA_RT};
        query = 'SELECT ' + String.join(new List<String>(fields), ',') + ', ' + toLabelFields + ' FROM Account WHERE RecordType.DeveloperName IN ' + AV_AppUtilities.setToStringIn(rtDevNames);
        if (String.isNotBlank(negocioFilter)) {
			if ('TODOS'.equals(negocioFilter)) {
				query += ' AND AV_Negocio__c != null';
			} else {
				query += ' AND AV_Negocio__c INCLUDES (\'' + negocioFilter + '\')';
			}
		}
		if (String.isNotBlank(modeloFilter)) {
            query += ' AND AV_AttentionModel__c = \'' + modeloFilter + '\'';
        }
        if (String.isNotBlank(edadMinFilter)) {
            query += ' AND AV_Age__c >= ' + edadMinFilter;
        }
		if (String.isNotBlank(edadMaxFilter)) {
			query += ' AND AV_Age__c <= ' + edadMaxFilter;
		}
        if (String.isNotBlank(ingresosMinFilter)) {
            query += ' AND AV_Ingresos__c >= ' + ingresosMinFilter;
        }
		if (String.isNotBlank(ingresosMaxFilter)) {
            query += ' AND AV_Ingresos__c <= ' + ingresosMaxFilter;
        }
        if (String.isNotBlank(ahorroMinFilter)) {
            query += ' AND AV_AhorroEInversion__c >= ' + ahorroMinFilter;
        }
		if (String.isNotBlank(ahorroMaxFilter)) {
            query += ' AND AV_AhorroEInversion__c <= ' + ahorroMaxFilter;
        }
        if (String.isNotBlank(financiacionMinFilter)) {
            query += ' AND AV_Financiacion__c >= ' + financiacionMinFilter;
        }
		if (String.isNotBlank(financiacionMaxFilter)) {
            query += ' AND AV_Financiacion__c <= ' + financiacionMaxFilter;
        }
        if (String.isNotBlank(rentabilidadMinFilter)) {
            query += ' AND AV_Rentabilidad__c >= ' + rentabilidadMinFilter;
        }
		if (String.isNotBlank(rentabilidadMaxFilter)) {
            query += ' AND AV_Rentabilidad__c <= ' + rentabilidadMaxFilter;
        }
        if (String.isNotBlank(experienciaFilter)) {
            query += ' AND AV_Satisfaccion__c = \'' + experienciaFilter + '\'';
        }
        if (String.isNotBlank(myBoxFilter)) {
			if (myBoxFilter == AV_AppConstants.NOT_SELECTED) {
				query += ' AND AV_MyBox__C = null';
			} else {
				query += ' AND AV_MyBox__C = \'' + myBoxFilter + '\'';
			}
		}
		if (String.isNotBlank(preconMinFilter)) {
			query += ' AND AV_Preconceived__c >= ' + preconMinFilter;
		}
		if (String.isNotBlank(preconMaxFilter)) {
			query += ' AND AV_Preconceived__c <= ' + preconMaxFilter;
		}
		if (String.isNotBlank(targetAutoFilter)) {
			if (targetAutoFilter == AV_AppConstants.NOT_SELECTED) {
				query += ' AND AV_TargetAuto__c = null';
			} else {
				query += ' AND AV_TargetAuto__c = \'' + targetAutoFilter + '\'';
			}
		}
		if (employeeFilter!=null && !employeeFilter.isEmpty()) {
			if (ID_GCF.equalsIgnoreCase(employeeFilter[0]) && employeeFilter.size()==1) {
				query += ' AND OwnerId = \''+ID_GCF+'\' AND AV_OficinaPrincipal__r.CC_Numero_Oficina__c = \''+office+'\'';
            } else if (employeeFilter[0].contains(ID_GCF) && employeeFilter.size()==1) {
				query += ' AND (OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter[0].remove(ID_GCF+',').split(','))+' OR (OwnerId = \''+ID_GCF+'\' AND AV_OficinaPrincipal__r.CC_Numero_Oficina__c = \''+office+'\'))';
            } else if (employeeFilter.contains(ID_GCF)) {
				query += ' AND Owner.AV_NumeroOficinaEmpresa__c = \'001-'+office+'\'';
            } else {
				query += ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter);
            }
		}
		query += ' LIMIT ' + Integer.valueOf(page)*100 + ' OFFSET ' + (Integer.valueOf(page)-1)*100;
		query = query.replaceAll('[{}]', '');
		AV_LogDebug.printLogDebug(methodName, '-----> Query to execute: ' + query);
		List<Account> queryResult = capsulateQuery(query);
		List<AV_BookMember__c> carteras = getCarteras(queryResult, carteraFilter);
		List<ClientData> data = mapClientData(queryResult, carteras, carteraFilter);
		totalSize = '1'.equals(page) ? getNumberOfCustomers(office, negocioFilter, employeeFilter, carteraFilter, modeloFilter, edadMinFilter, edadMaxFilter, ingresosMinFilter, ingresosMaxFilter, ahorroMinFilter, ahorroMaxFilter, financiacionMinFilter, financiacionMaxFilter, rentabilidadMinFilter, rentabilidadMaxFilter, experienciaFilter, myBoxFilter, preconMinFilter, preconMaxFilter, targetAutoFilter, page) : -1;
		return new ObjectList('Account', totalSize, data);
    }


	/**
	 * @description		Get the total number of records of the query used in getCustomers (without 
	 * OFFSET and LIMIT)
	 * @param office	 for the customer's office
	 * @param negocioFilter	Filter for the customer's business type
	 * @param employeeFilter	Filter for employees related to the customer
	 * @param carteraFilter	Filter for the customer's portfolio type
	 * @param modeloFilter	Filter for the customer's model
	 * @param edadMinFilter	Filter for the customer's minimum age
	 * @param edadMaxFilter	Filter for the customer's maximum age
	 * @param ingresosMinFilter	 Filter for the customer's minimum income
	 * @param ingresosMaxFilter	Filter for the customer's maximum income
	 * @param ahorroMinFilter	Filter for the customer's minimum savings
	 * @param ahorroMaxFilter	Filter for the customer's maximum savings
	 * @param financiacionMinFilter	Filter for the customer's minimum financing amount
	 * @param financiacionMaxFilter	Filter for the customer's maximum financing amount
	 * @param rentabilidadMinFilter	Filter for the customer's minimum profitability
	 * @param rentabilidadMaxFilter	Filter for the customer's maximum profitability
	 * @param experienciaFilter	Filter for the customer's experience
	 * @param myBoxFilter	Filter for the customer's "myBox" status
	 * @param preconMinFilter	Filter for the customer's minimum precon value
	 * @param preconMaxFilter	Filter for the customer's maximum precon value
	 * @param targetAutoFilter	Filter for the customer's car target
	 * @param page	Page number for result pagination
	 */
	public static Integer getNumberOfCustomers(String office, String negocioFilter, String[] employeeFilter,
	String carteraFilter, String modeloFilter, String edadMinFilter, String edadMaxFilter, String ingresosMinFilter,
	String ingresosMaxFilter, String ahorroMinFilter, String ahorroMaxFilter, String financiacionMinFilter, String financiacionMaxFilter,
	String rentabilidadMinFilter, String rentabilidadMaxFilter, String experienciaFilter, String myBoxFilter, String preconMinFilter,
	String preconMaxFilter, String targetAutoFilter, String page) {
		String methodName = 'getNumberOfCustomers';
        String query;
		Integer result;
		Set<String> rtDevNames = new Set<String>{AV_AppConstants.ACCOUNT_ENT_RT, AV_AppConstants.ACCOUNT_PA_RT};
        query = 'SELECT COUNT(Id) FROM Account WHERE RecordType.DeveloperName IN ' + AV_AppUtilities.setToStringIn(rtDevNames);
        if (String.isNotBlank(negocioFilter)) {
			if ('TODOS'.equals(negocioFilter)) {
				query += ' AND AV_Negocio__c != null';
			} else {
				query += ' AND AV_Negocio__c INCLUDES (\'' + negocioFilter + '\')';
			}
		}
		if (String.isNotBlank(modeloFilter)) {
            query += ' AND AV_AttentionModel__c = \'' + modeloFilter + '\'';
        }
        if (String.isNotBlank(edadMinFilter)) {
            query += ' AND AV_Age__c >= ' + edadMinFilter;
        }
		if (String.isNotBlank(edadMaxFilter)) {
			query += ' AND AV_Age__c <= ' + edadMaxFilter;
		}
        if (String.isNotBlank(ingresosMinFilter)) {
            query += ' AND AV_Ingresos__c >= ' + ingresosMinFilter;
        }
		if (String.isNotBlank(ingresosMaxFilter)) {
            query += ' AND AV_Ingresos__c <= ' + ingresosMaxFilter;
        }
        if (String.isNotBlank(ahorroMinFilter)) {
            query += ' AND AV_AhorroEInversion__c >= ' + ahorroMinFilter;
        }
		if (String.isNotBlank(ahorroMaxFilter)) {
            query += ' AND AV_AhorroEInversion__c <= ' + ahorroMaxFilter;
        }
        if (String.isNotBlank(financiacionMinFilter)) {
            query += ' AND AV_Financiacion__c >= ' + financiacionMinFilter;
        }
		if (String.isNotBlank(financiacionMaxFilter)) {
            query += ' AND AV_Financiacion__c <= ' + financiacionMaxFilter;
        }
        if (String.isNotBlank(rentabilidadMinFilter)) {
            query += ' AND AV_Rentabilidad__c >= ' + rentabilidadMinFilter;
        }
		if (String.isNotBlank(rentabilidadMaxFilter)) {
            query += ' AND AV_Rentabilidad__c <= ' + rentabilidadMaxFilter;
        }
        if (String.isNotBlank(experienciaFilter)) {
            query += ' AND AV_Satisfaccion__c = \'' + experienciaFilter + '\'';
        }
        if (String.isNotBlank(myBoxFilter)) {
			if (myBoxFilter == AV_AppConstants.NOT_SELECTED) {
				query += ' AND AV_MyBox__C = null';
			} else {
				query += ' AND AV_MyBox__C = \'' + myBoxFilter + '\'';
			}
		}
		if (String.isNotBlank(preconMinFilter)) {
			query += ' AND AV_Preconceived__c >= ' + preconMinFilter;
		}
		if (String.isNotBlank(preconMaxFilter)) {
			query += ' AND AV_Preconceived__c <= ' + preconMaxFilter;
		}
		if (String.isNotBlank(targetAutoFilter)) {
			if (targetAutoFilter == AV_AppConstants.NOT_SELECTED) {
				query += ' AND AV_TargetAuto__c = null';
			} else {
				query += ' AND AV_TargetAuto__c = \'' + targetAutoFilter + '\'';
			}
		}
		if (employeeFilter!=null && !employeeFilter.isEmpty()) {
			if (ID_GCF.equalsIgnoreCase(employeeFilter[0]) && employeeFilter.size()==1) {
				query += ' AND OwnerId = \''+ID_GCF+'\' AND AV_OficinaPrincipal__r.CC_Numero_Oficina__c = \''+office+'\'';
            } else if (employeeFilter[0].contains(ID_GCF) && employeeFilter.size()==1) {
				query += ' AND (OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter[0].remove(ID_GCF+',').split(','))+' OR (OwnerId = \''+ID_GCF+'\' AND AV_OficinaPrincipal__r.CC_Numero_Oficina__c = \''+office+'\'))';
            } else if (employeeFilter.contains(ID_GCF)) {
				query += ' AND Owner.AV_NumeroOficinaEmpresa__c = \'001-'+office+'\'';
            } else {
				query += ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter);
            }
		}
		query = query.replaceAll('[{}]', '');
		AV_LogDebug.printLogDebug(methodName, '-----> Query to execute: ' + query);
		result = Integer.valueOf(capsulateQueryAggregateResult(query).get(0).get('expr0'));
		return result;
	}

	/**
	 * @description		Method to pass quality clouds
	 */
	private static List<AggregateResult> capsulateQueryAggregateResult(String q){
		return (List<AggregateResult>) Database.query(q);
	}

	/**
	 * @description		Method to pass quality clouds
	 */
	private static List<Account> capsulateQuery(String q){
		return (List<Account>) Database.query(q);
	}

	/**
	 * @description		Get book info to populate lwc 'Cartera/cesta' field
	 * @param	clients	 list of new account records
	 */
	private static List<AV_BookMember__c> getCarteras(List<Account> clients, String carteraFilter) {
		List<String> booksList = new List<String>();
		if(carteraFilter != null){
			if(carteraFilter.contains(',')){
				booksList = carteraFilter.split(',');
			}
		}
		Map<Id, Account> clientMap = new Map<Id, Account>();
		List<AV_BookMember__c> bmList = new List<AV_BookMember__c>();
		if (!clients.isEmpty()) {
			clientMap.putAll(clients);
			if (String.isNotBlank(carteraFilter)) {
				if(!booksList.isEmpty() && booksList != null){
					bmList = [
					SELECT AV_Cartera__c, AV_Cartera__r.AV_ExternalID__c, AV_Cliente__c
					FROM AV_BookMember__c
					WHERE AV_Cliente__c IN :clientMap.keySet() AND AV_Cartera__c IN :booksList
				];

				}else{
					bmList = [
						SELECT AV_Cartera__c, AV_Cartera__r.AV_ExternalID__c, AV_Cliente__c
						FROM AV_BookMember__c
						WHERE AV_Cliente__c IN :clientMap.keySet() AND AV_Cartera__c = :carteraFilter
					];
				}
				
			} else {
				bmList = [
					SELECT AV_Cartera__c, AV_Cartera__r.AV_ExternalID__c, AV_Cliente__c
					FROM AV_BookMember__c
					WHERE AV_Cliente__c IN :clientMap.keySet()
				];
			}
		}
		return bmList;
	}

	/**
	 * @description		Get employees from the selected office
	 * @param	oficina	for the customer's office		
	 */
	@AuraEnabled
	public static List<optionsEmployee> getEmployees(String oficina){
		List<optionsEmployee> employees = new List<optionsEmployee>();
		List<optionsEmployee> employeesSorted = new List<optionsEmployee>();
		List<Id> employeesId = new List<Id>();
		List<User> emps = new List<User>();
		User emp = new User();
		String offiNumber;
		if (oficina.length() > 5) {
			emps = [
				SELECT Id, Name
				FROM User
				WHERE AV_NumeroOficinaEmpresa__c = :oficina
				AND IsActive = TRUE 
				AND AV_ProfileName__c = :AV_AppConstants.AV_PROFILE
			];
		} else {
			String filter = '%' + oficina;
			emps = [
				SELECT Id, Name
				FROM User
				WHERE AV_NumeroOficinaEmpresa__c LIKE :filter
				AND IsActive = TRUE 
				AND AV_ProfileName__c = :AV_AppConstants.AV_PROFILE
			];
		}
		if(!emps.isEmpty() && emps != null){
			for(User u : emps){
				employeesId.add(u.Id);
				employeesSorted.add(new optionsEmployee(u.Id,u.Name));
			}
		}
		String employeesAlls = String.join(employeesId, ',');
		if(employeesId.size() > 1) {
			employees.add(new optionsEmployee(ID_GCF + ',' + employeesAlls, AV_AppConstants.ALL_CENTER + oficina));
		}
		employees.add(new optionsEmployee(ID_GCF, AV_AppConstants.SINGESTOR_EAP_CENTRO + oficina));
		employeesSorted.sort();
		employees.addAll(employeesSorted);
		return employees;		
	}

	/**
	 * @description		Get books from the selected office
	 * @param employeeId
	 */
	@AuraEnabled
	public static List<OptionsBook> getBooks(String employeeId){

		List<OptionsBook> books = new List<OptionsBook>();
		List<OptionsBook> booksSorted = new List<OptionsBook>();
		List<Id> booksId = new List<Id>();

		List<AV_BookManagementMember__c> bmm = new List<AV_BookManagementMember__c>();
		bmm = [
				SELECT Id, AV_Cartera__c, AV_ExternalID__c, AV_EmpleadoGestor__r.Name
				FROM AV_BookManagementMember__c
				WHERE AV_EmpleadoGestor__r.AV_UsuarioAsociado__c = :employeeId
			];
		
		if(!bmm.isEmpty() && bmm != null){
			for(AV_BookManagementMember__c b : bmm){
				booksId.add(b.AV_Cartera__c);
				booksSorted.add(new OptionsBook(b.AV_Cartera__c, b.AV_ExternalID__c));
			}
		}

		String allBooks = String.join(booksId, ',');
		if(booksId.size() > 1) {
			books.add(new OptionsBook(allBooks, AV_AppConstants.ALL_MANAGER + bmm[0].AV_EmpleadoGestor__r.Name));
		}

		booksSorted.sort();
		books.addAll(booksSorted);

		return books;
	}

	/**
	 * @description		Get the office based on the introduced search term
	 * @param searchTerm
	 * @param selectedIds	list of string records
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
							Account(
								Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c
								WHERE Id NOT IN :selectedIds and (Id = :centroUsuario.Id or Id IN :offices) and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT
							)
						LIMIT :MAX_RESULTS
					];
				} else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(
								Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c
								WHERE Id NOT IN :selectedIds and Id IN :offices and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT
							)
						LIMIT :MAX_RESULTS
					];
				}
			} else{
				if (currentUser.AV_OriginalOfficeNumber__c != null) {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(
								Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c
								WHERE (Id = :centroUsuario.Id or Id IN :offices) and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT
							)
						LIMIT :MAX_RESULTS
					];
				} else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(
								Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c
								WHERE (Id = :centroUsuario.Id or Id IN :offices) and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT
							)
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
	 * @description		Map client's data to be send to the LWC
	 * @param clients	list of clients records
	 * @param carteras	list of carteras records
	 * @param carteraFilter Filter for the customer's portfolio type
	 */
	public static List<ClientData> mapClientData(List<Account> clients, List<AV_BookMember__c> carteras, String carteraFilter) {
		List<ClientData> data = new List<ClientData>();
		Map<Id, AV_BookMember__c> bookMap = new Map<Id, AV_BookMember__c>();
		if (!clients.isEmpty()) {
			bookMap = mapCarteras(carteras);
			for (Account cli : clients) {
				// if filtered by cartera only show customers with specified cartera
				if (String.isNotBlank(carteraFilter) && bookMap.get(cli.Id) == null) {
					continue;
				}
				ClientData cd = new ClientData();
				cd.cartera = bookMap.get(cli.Id);
				cd.modelo = cli.AV_AttentionModel__c;
				cd.id = cli.Id;
				cd.name = cli.Name;
				cd.nif = cli.CC_Numero_Documento__c;
				cd.edad = (Integer) cli.AV_Age__c;
				if(cli.AV_Ingresos__c != null){
					cd.ingresos = cli.AV_Ingresos__c;
				}else{
					cd.ingresos = 0;
				}
				if(cli.AV_AhorroEInversion__c != null){
					cd.ahorro = cli.AV_AhorroEInversion__c;

				}else{
					cd.ahorro = 0;
				}
				if(cli.AV_Financiacion__c != null){
					cd.financiacion = cli.AV_Financiacion__c;

				}else{
					cd.financiacion = 0;
				}if(cli.AV_Rentabilidad__c != null){
					cd.rentabilidad = cli.AV_Rentabilidad__c;
				}else{
					cd.rentabilidad = 0;
				}
				cd.negocio = cli.AV_Negocio__c;
				cd.vinculacion = cli.AV_Vinculacion__c;
				if(cli.AV_Satisfaccion__c == AV_AppConstants.ZERO){
                    cd.experiencia = null;
                }else{
                    cd.experiencia = cli.AV_Satisfaccion__c;
                }

				cd.gestorId = cli.AV_EAPGestor__c;
				cd.gestorName = cli.AV_EAPGestor__r.Name;
				cd.office = cli.Owner.AV_NumeroOficinaEmpresa__c;
				cd.myBox = cli.AV_MyBox__c;
				if(cli.AV_Preconceived__c != null){
					cd.precon = cli.AV_Preconceived__c;
				}else{
					cd.precon = 0;
				}
				cd.targetAuto = cli.AV_TargetAuto__c;
				//cd.grupo = cli.AV_Group__c;
				//cd.interlocName = cli.AV_InterlocName__c;
				data.add(cd);
			}
		}
		return data;
	}

	/**
	 * @description		Map cartera as: Map<client, cartera)
	 * @param carteras list of carteras records
	 */
	public static Map<Id, AV_BookMember__c> mapCarteras(List<AV_BookMember__c> carteras) {
		Map<Id, AV_BookMember__c> bookMap = new Map<Id, AV_BookMember__c>();
		if (!carteras.isEmpty()) {
			for (AV_BookMember__c cartera : carteras) {
				bookMap.put(cartera.AV_Cliente__c, cartera);
			}
		}
		return bookMap;
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
		public List<Object> recordList;
                
		public ObjectList(String objectName, Integer totalSize, List<Object> recordList) {
			this.objectName = objectName;
			this.totalSize = totalSize;
			this.recordList = recordList;
		}
        
        public ObjectList() {
            this.objectName = '';
            this.totalSize = 0;
        	this.recordList = new List<Object>();
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

	public class OptionsBook implements Comparable{
		@AuraEnabled
		public String value;
		@AuraEnabled
		public String label;

		public OptionsBook(String value, String label){
			this.label = label;
			this.value = value;		
		}
	
		/**
		 * Allow to sort search results based on title
		 */
		public Integer compareTo(Object compareTo) {
			OptionsBook other = (OptionsBook) compareTo;
			if (this.label == null) {
				return (other.label == null) ? 0 : 1;
			}
			if (other.label == null) {
				return -1;
			}
			return this.label.compareTo(other.label);
		}
	}

	public class ClientData {
		@AuraEnabled
		public String id;
		@AuraEnabled
		public AV_BookMember__c cartera;
		@AuraEnabled
		public String modelo;
		@AuraEnabled
		public String name;
		@AuraEnabled
		public String nif;
		@AuraEnabled
		public Integer edad;
		@AuraEnabled
		public Double ingresos;
		@AuraEnabled
		public Double ahorro;
		@AuraEnabled
		public Double financiacion;
		@AuraEnabled
		public Double rentabilidad;
		@AuraEnabled
		public String negocio;
		@AuraEnabled
		public String vinculacion;
		@AuraEnabled
		public String experiencia;
		@AuraEnabled
		public String gestorId;
		@AuraEnabled
		public String gestorName;
		@AuraEnabled
		public String office;
		@AuraEnabled
		public String myBox;
		@AuraEnabled
		public Double precon;
		@AuraEnabled
		public String targetAuto;
		@AuraEnabled
		public String grupo;
		@AuraEnabled
		public String interlocName;
	}
}