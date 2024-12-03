/**********************************************************************************************************************
 Name:      AV_NewEvent_Controller
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora para el componente AV_NewEvent e hijos 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION        USER_STORY       AUTHOR           DATE                Description
   	1.0            US518461         Luis Fernández   06/09/2023          Init version
	1.1			   Fix PMD Errors   Daniel Rodriguez 09/10/2023     	 Add WITH SECURITY_ENFORCED in queries
	1.2			   US562059         Luis Fernández   05/12/2023          Added new method getEmployeeInfo in order to retrieve user from his contact's plate
	1.3            --               Oscar Moreno     15/01/2024          Modify processCheckOnOffCreate,processCheckOnOffUpdate,processCheckOnOffDelete methods. The users dont enter with the PS AV_OpportunitiesSearcherV2
	1.4			   IN1115491		Sandra Gómez	 30/01/2024			 Modify method createEventFromReport to add if AV_PrivateBanking
	1.5            US796361         Oscar Moreno     20/03/2024          Modify createOrUpdateOpportunitiesFromReport method
	1.6			   PPM100205278		Luis Fernández   28/05/2024			 Added No Getionada status
	1.6			   Fix Timeline	    Luis Fernández	 03/06/2024			 Quit off av_commentsHistory__c logic from createOrUpdateOpportunities method
	1.7            US170552         Oscar Moreno     05/07/2024          Change processCheckOnOffDelete,processCheckOnOffCreate,processCheckOnOffUpdated methods. Only users with PS AV_CheckOnOff will be able to create tasks check on/off
	1.8            PPM100130465     Oscar Moreno     05/07/2024          Replace PS_CHECKONOFF with PS_OLDHOMETASK and revert logic
    1.9            PPM100265806     Oscar Moreno     12/09/2024          Add the owneridopp attribute to OppoWrap class 
	2.0			   PPM100538432		Sandra Gómez	 18/09/2024			 Change originApp of event in methods createEvent and createEventFromReport and Add method syncWithGcf
***********************************************************************************************************************/
public without sharing class AV_NewEvent_Controller {

	/**
	 * Inner class in order to wrap Opportunities info
	 */
	public class OppoWrap implements Comparable{
		@AuraEnabled 
		public String Id;
		@AuraEnabled 
		public String Name;
		@AuraEnabled 
		public String Stage;
		@AuraEnabled 
		public Date Fecha;
		@AuraEnabled 
		public String Potencial;
		@AuraEnabled 
		public String Comentarios;
		@AuraEnabled 
		public String Resolucion;
		@AuraEnabled 
		public Decimal ImportePropio;
		@AuraEnabled 
		public Decimal Margen;
		@AuraEnabled 
		public Decimal ImporteOtraEntidad;    
		@AuraEnabled 
		public String OtraEntidad;
		@AuraEnabled 
		public String OtraEntidadNombre;
		@AuraEnabled
		public Decimal ImporteCuota;
		@AuraEnabled
		public String SubProductId;
		@AuraEnabled
		public String SubProductName;
		@AuraEnabled
		public String ProductoMain;
		@AuraEnabled
		public Decimal Propension;
		@AuraEnabled 
		public Date CloseDate;
		@AuraEnabled 
		public Boolean mainVinculed = false;
		@AuraEnabled
		public Boolean PrioritzingCustomer;
		@AuraEnabled
		public String RecordType;
		@AuraEnabled
		public String HistoryComment = '';
		@AuraEnabled
		public String Subestado = '';
		@AuraEnabled 
		public Boolean IsNewProduct; 
		@AuraEnabled
		public String owneridopp;

	
		
		public OppoWrap(Opportunity oppo){
			this.Id = oppo.Id; 
			this.Name = oppo.Name;
			this.Stage = oppo.StageName; 
			this.Fecha = oppo.AV_FechaProximoRecordatorio__c;
			this.Potencial = oppo.AV_Potencial__c;
			this.Comentarios = oppo.AV_Comentarios__c;
			this.Resolucion = oppo.AV_Resolucion__c;
			this.ImportePropio = oppo.AV_AmountEuro__c;
			this.Margen = oppo.AV_MarginEuro__c;
			this.ImporteOtraEntidad = oppo.Amount;
			this.OtraEntidad = oppo.AV_Tenencia__c;
			this.OtraEntidadNombre = oppo.AV_Entidad__c;
			this.ImporteCuota = oppo.AV_Cuota__c;
			this.SubProductId = oppo.AV_ByProduct__c;
			this.SubProductName = oppo.AV_ByProduct__r.Name;
			this.ProductoMain = oppo.AV_PF__c;
			this.Propension = oppo.AV_Propensity__c;
			this.CloseDate = oppo.CloseDate;
			this.PrioritzingCustomer = oppo.AV_IncludeInPrioritizingCustomers__c ;
			this.RecordType = oppo.RecordTypeId;
			this.Subestado = oppo.AV_Subestado__c; 
			this.IsNewProduct = oppo.AV_PF__r.AV_NewReportActions__c;
			this.owneridopp = oppo.OwnerId; 
			
		}
		public Integer compareTo(Object compareTo) {
			OppoWrap compareToEmp = (OppoWrap) compareTo;
			 if (this.Propension > compareToEmp.Propension) {
				return 1;
			}
			if (this.Propension == compareToEmp.Propension) {
				return 0;
			}
			return -1;        
		}
	}

	/**
	 * Inner class in order to return ordered information to the javascript lwc.
	 */
	public class OpportunitiesInfo{
		@AuraEnabled
		public List<OppoWrap> clientOppos;
		@AuraEnabled
		public List<Id> productsToNotShow;
	}

	/**
	 * @description			Lookup of Account in field CC_Client and CC_ClientPA recordtype
	 * @param searchTerm 	filter to search in object Account
	 * @return 				Account to show lookup
	 */
	@AuraEnabled 
	public static List<AV_LookupSearchResult> searchClients(String searchTerm) {
		Integer maxResult = 10;
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		Set<String> accountRts = new Set<String>{
			AV_AppConstants.ACCOUNT_ENT_RT,
			AV_AppConstants.ACCOUNT_PA_RT
		};
		searchResults = [
			FIND :searchTerm
			IN ALL FIELDS
			RETURNING
			Account(Id, Name WHERE RecordType.DeveloperName IN :accountRts)
			LIMIT :maxResult
		];
		String accountIcon = AV_AppConstants.ICON_ACCOUNT;
		Account[] listClients = (List<Account>) searchResults[0];
		for (Account a : listClients) {
			results.add(
				new AV_LookupSearchResult(
					a.Id,
					AV_AppConstants.OBJECT_NAME_ACCOUNT,
					accountIcon,
					a.Name,
					null
				)
			);
		}
		results.sort();
		return results;
	}

	/**
	 * @description			Lookup for User who are active, has contact and are retail profile
	 * @param searchTerm 	filter to search in object Account
	 * @return 				Account to show User
	 */
	@AuraEnabled 
	public static List<AV_LookupSearchResult> searchEmployees(String searchTerm,List<String> selectedIds) {
		Integer maxResult = 10;
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		if(selectedIds != null && !selectedIds.isEmpty()) {
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
				User(Id, Name, AV_NumeroOficinaEmpresa__c WHERE IsActive=true and Profile.Name = :AV_AppConstants.AV_PROFILE AND Id IN (SELECT AV_UsuarioAsociado__c FROM Contact) AND Id NOT IN :selectedIds)
				LIMIT :maxResult
			];
		} else {
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
				User(Id, Name, AV_NumeroOficinaEmpresa__c WHERE IsActive=true and Profile.Name = :AV_AppConstants.AV_PROFILE AND Id IN (SELECT AV_UsuarioAsociado__c FROM Contact))
				LIMIT :maxResult
			];
		}
		String userIcon = AV_AppConstants.ICON_USER;
		User[] listUser = (List<User>) searchResults[0];
		for (User u : listUser) {
			results.add(
				new AV_LookupSearchResult(
					u.Id,
					AV_AppConstants.OBJECT_NAME_USER,
					userIcon,
					u.Name,
					u.AV_NumeroOficinaEmpresa__c
				)
			);
		}
		results.sort();
		return results;
	}
	
	/**
	 * @description			Lookup of Contact in field Contact Person
	 * @param searchTerm 	filter to search in object Contact
	 * @param selectedIds 	list of Ids selected of object contact
	 * @param accountId 	Id of account to filter in query
	 * @return 				Contact to show lookup
	 */
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchContact(String searchTerm, List<String> selectedIds, String accountId){
		String methodName = 'getContact';
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = [
			FIND :searchTerm
			IN ALL FIELDS
			RETURNING
				Contact(Id, Name, CC_CargoRepresentante__c WHERE RecordType.DeveloperName= :CIBE_AppConstants.CONTACT_APODERADO_RT and AccountId = :accountId)
			LIMIT 10
		];
		String userIcon = 'standard:contact';
		List<String> listIds = new List<String>();
		if(searchResults!=null) {
			Contact[] listUsers = (List<Contact>) searchResults[0];
			for (Contact u : listUsers) {
				if (u.CC_CargoRepresentante__c != null) {
					results.add(new AV_LookupSearchResult(u.Id,AV_AppConstants.OBJECT_NAME_CONTACT,userIcon,u.Name,u.CC_CargoRepresentante__c));
				} else {
					results.add(new AV_LookupSearchResult(u.Id,AV_AppConstants.OBJECT_NAME_CONTACT,userIcon,u.Name,''));
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
					results.add(new AV_LookupSearchResult(p.Id,AV_AppConstants.OBJECT_NAME_CONTACT,userIcon,p.Name,p.CC_CargoRepresentante__c));
				} else {
					results.add(new AV_LookupSearchResult(p.Id,AV_AppConstants.OBJECT_NAME_CONTACT,userIcon,p.Name,''));
				}
			}
		}
		return results;
	}

	/**
	* @description 		method to query with string
	* @param q 			query to execute
	* @param listIds 	list of Ids contact
	* @param accountId 	Id of account
	* @return 			list contact of return query
	*/
	private static List<Contact> capsulateQuery(String q, List<String> listIds, String accountId) {
		return (List<Contact>) Database.query(q);
	}

	/**
	 * @description			Lookup for User who are active are retail profile
	 * in order to select attendes for the event that is being created
	 * @param searchTerm 	filter to search in object Account
	 * @param selectedIds 	list of Ids selected of object contact
	 * @return 				Account to show User
	 */
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchAttendees(String searchTerm, List<String> selectedIds,String currentUser) {
		Integer maxResult = 10;
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		if(!selectedIds.isEmpty()) {
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
				User(Id, Name, AV_NumeroOficinaEmpresa__c WHERE Id NOT IN :selectedIds and IsActive=true and Id != :currentUser and Profile.Name= :AV_AppConstants.AV_PROFILE)
				LIMIT :maxResult
			];
		} else {
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
				User(Id, Name, AV_NumeroOficinaEmpresa__c WHERE IsActive=true and Id != :currentUser and Profile.Name= :AV_AppConstants.AV_PROFILE)
				LIMIT :maxResult
			];
		}
		String userIcon = AV_AppConstants.ICON_USER;
		User[] listUser = (List<User>) searchResults[0];
		for (User u : listUser) {
			results.add(
				new AV_LookupSearchResult(
					u.Id,
					AV_AppConstants.OBJECT_NAME_USER,
					userIcon,
					u.Name,
					null
				)
			);
		}
		results.sort();
		return results;
	}

	/**
	 * @description			Lookup of Account in field CC_CentroCaixaBank recordtype
	 * @param searchTerm 	filter to search in object Account
	 * @param selectedIds 	list of Ids selected of object contact
	 * @return 				Account to show lookup
	 */
	@AuraEnabled
	public static List<AV_LookupSearchResult> searchOffice(String searchTerm, List<String> selectedIds) {
		Integer maxResult = 10;
		searchTerm +='*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(AV_AppConstants.ACCOUNT_CTO_RT).getRecordTypeId();
		searchResults = [
			FIND :searchTerm
			IN Name FIELDS
			RETURNING Account(
				Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c
				WHERE RecordType.Id = :accRecordTypeId
			)
			LIMIT :maxResult
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

	private static String formatDateForHistoryComment(String lastDate) {
		String dateParsed = lastDate.substring(0,10);
		String[] dateAtomized = dateParsed.split(AV_AppConstants.DASH);
		return dateAtomized[2]+'/'+dateAtomized[1]+'/'+dateAtomized[0];
	}

	/**
	 * Given the accoundId of the event client, it return all the retail Rt Opportunities that are
	 * Potential or in En gestión/Insistir stage, and also the ones that are Vencidas and are AV_Iniciativa recordtype.
	 * It orders it by propensity and StageName and returns also the list of products to do not show to this client.
	 * @return OpportunitiesInfo 
	 */
	@AuraEnabled 
	public static OpportunitiesInfo retrieveAccountOpportunities(String accountId) {
		OpportunitiesInfo response = new OpportunitiesInfo();
		Set<String> retailRts = new Set<String>{ 
			AV_AppConstants.OPPINICIATIVA_RT,
			AV_AppConstants.OPPALERTACOM_RT,
			AV_AppConstants.OPPPROPUESTA_RT,
			AV_AppConstants.OPPSUGERENCIA_RT,
			AV_AppConstants.OPPLLAMADA_RT
		};
		Set<String> requiredStages = new Set<String> {
			AV_AppConstants.OPP_STATUS_POTENCIAL,
			AV_AppConstants.OPP_STATUS_ENGESTION,
			AV_AppConstants.OPP_STATUS_VENCIDO,
			AV_AppConstants.OPP_STATUS_NO_GESTIONADA
		};
		List<Opportunity> associatedOppo = [SELECT Id,Name,StageName,AV_FechaProximoRecordatorio__c,AV_Potencial__c,AV_Comentarios__c,AV_Resolucion__c,AV_AmountEuro__c,AV_MarginEuro__c,Amount,AV_Tenencia__c,AV_Entidad__c,AV_Cuota__c,AV_ByProduct__c,AV_ByProduct__r.Name,AV_PF__c,AV_Propensity__c,CloseDate,AV_IncludeInPrioritizingCustomers__c,RecordTypeId,AV_Subestado__c,AV_PF__r.AV_NewReportActions__c,OwnerId FROM Opportunity WHERE AccountId = :accountId AND ((RecordType.DeveloperName IN :retailRts AND StageName IN :requiredStages)) WITH SECURITY_ENFORCED ORDER BY AV_FechaProximoRecordatorio__c DESC NULLS LAST]; 
		List<OppoWrap> objToSend = new List<OppoWrap>();
		Map<String,List<OppoWrap>> stageOppoMap = new Map<String,List<OppoWrap>>();
		response.productsToNotShow = new List<Id>();
		Set<Id> retrievedOppos = new Set<Id>();
		for(Opportunity oppId : associatedOppo) {
			retrievedOppos.add(oppId.Id);
		}
		List<AV_CommentsHistory__c> comentaryList = [SELECT AV_Opportunity__c,AV_NewComment__c,LastModifiedDate FROM AV_CommentsHistory__c WHERE AV_Opportunity__c IN :retrievedOppos AND AV_Opportunity__c != null ORDER BY AV_Opportunity__c, LastModifiedDate DESC];
		Map<Id,String> commentOppo = new Map<Id,String>();
		for(AV_CommentsHistory__c cmm : comentaryList) {
			if(!commentOppo.keySet().contains(cmm.AV_Opportunity__c)  && !String.isBlank(cmm.AV_NewComment__c)) {
				commentOppo.put(cmm.AV_Opportunity__c,formatDateForHistoryComment( String.valueOf(cmm.LastModifiedDate))+'{|}'+cmm.AV_NewComment__c);
			}
		}
		for(Opportunity opp : associatedOppo) {
			if(!response.productsToNotShow.contains(opp.AV_PF__c)) {
				response.productsToNotShow.add(opp.AV_PF__c);
			}
			OppoWrap nextOpp = new OppoWrap(opp);
			if(commentOppo.keySet().contains(opp.Id)) {
				nextOpp.HistoryComment = commentOppo.get(opp.Id);
			}
			if(stageOppoMap.keySet().contains(opp.StageName)) {
				stageOppoMap.get(opp.StageName).add(nextOpp);
			} else {
				stageOppoMap.put(opp.StageName,new List<OppoWrap>{ nextOpp});
			}
		}
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_POTENCIAL) != null) {
			stageOppoMap.get(AV_AppConstants.OPP_STATUS_POTENCIAL).sort();
		}
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_ENGESTION) != null) {
			objToSend.addAll(stageOppoMap.get(AV_AppConstants.OPP_STATUS_ENGESTION));
		}
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_POTENCIAL) != null) {
			objToSend.addAll(stageOppoMap.get(AV_AppConstants.OPP_STATUS_POTENCIAL));
		}
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_VENCIDO) != null) {
			objToSend.addAll(stageOppoMap.get(AV_AppConstants.OPP_STATUS_VENCIDO));
		}
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_NO_GESTIONADA) != null) {
			objToSend.addAll(stageOppoMap.get(AV_AppConstants.OPP_STATUS_NO_GESTIONADA));
		}
		response.clientOppos = objToSend;
		requiredStages.addAll(new Set<String>{
			AV_AppConstants.OPP_STATUS_VENCIDO,
			AV_AppConstants.OPP_STATUS_NO_GESTIONADA
		});
		List<Opportunity> listOppForProdutsToNotShow = [SELECT AV_PF__c FROM Opportunity WHERE AccountId = :accountId AND (StageName  IN :requiredStages AND RecordType.DeveloperName IN :retailRts) WITH SECURITY_ENFORCED]; 
		for(Opportunity opp : listOppForProdutsToNotShow) {
			if(!response.productsToNotShow.contains(opp.AV_PF__c)) {
				response.productsToNotShow.add(opp.AV_PF__c);
			}
		}
		return response;
	}

	/**
	 * @description			Return a list of AV_Potencial__C picklistValues
	 * @param fields 		List of fields to get values of picklist field
	 * @return 				List of values with label and value of picklist
	 */
	@AuraEnabled(cacheable=true)
	public static List<Map<String, String>> getPicklistValues(String[] fields) {
		List<Map<String, String>> listPicklist = new List<Map<String, String>>();
		// Get the describe for the object
		DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(AV_AppConstants.OBJECT_NAME_OPPORTUNITY).getDescribe();
		// Get the field dynamically
		DescribeFieldResult fieldResult = objResult.fields.getMap().get(AV_AppConstants.OPPO_POTENCIAL_FIELD).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for(Schema.PicklistEntry pickListVal : ple) {
			listPicklist.add(new Map<String, String>{'label' =>pickListVal.getLabel(), 'value' => String.valueOf(pickListVal.getValue())});
		}
		return listPicklist;
	}

	/**
	 * Search in all fields Product2 that are AV_PF recordtype and has not Level and has an External id and are visible
	 * @param String searchTerm 
	 * @param List<String> ids to do not return search on the query
	 * @return List<AV_LookupSearchResult>
	 */
	@AuraEnabled
	public static List<AV_LookupSearchResult> searchProduct(String searchTerm, List<String> selectedIds) {
		String methodName = 'searchProduct';
		Integer maxResult = 10;
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		if(!selectedIds.isEmpty()) {
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
				Product2(Id, Name, AV_ExternalID__c,AV_NewReportActions__c WHERE Id NOT IN :selectedIds and RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true)
				LIMIT :maxResult
			];
		} else {
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Product2(Id, Name, AV_ExternalID__c,AV_NewReportActions__c WHERE RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true)
				LIMIT :maxResult
			];
		}
		String productIcon = 'standard:product';
		Product2[] listProduct = (List<Product2>) searchResults[0];
		for (Product2 p : listProduct) {
			results.add(
				new AV_LookupSearchResult(
					p.Id,'Product2',productIcon,p.Name,'Codigo • ' + p.AV_ExternalID__c,p.AV_NewReportActions__c
				)
			);
		}
		results.sort();
		return results;
	}

	private static Date formatDate(String dateToFormat) {
		String[] splitedDate = dateToFormat.split(AV_AppConstants.DASH);//Split by '-'
		Integer year = Integer.valueOf(splitedDate[0]);
		Integer month = Integer.valueOf(splitedDate[1]);
		Integer day = Integer.valueOf(splitedDate[2]);
		return date.newInstance(year,month,day);
	}

	/**
	 * It inserts on the database the event with the information specified on the lwc
	 * @param String evt Pre-made Event object 
	 * @return A string that its OK if the insert is succesfuls and a error message if is not succesful
	 */
	@AuraEnabled
	public static String createEvent(Event evt) {
		String separador = '{|}';
		Savepoint sp = Database.setSavepoint();
		String methodName = 'createEvent';
		String response = 'OK';
		evt.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
		evt.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT,AV_AppConstants.EVENTCLIENTE_RT).Id;
		evt.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE;
		Id eventId;
		if(evt.Id != null){
			try{
				Database.SaveResult sr = Database.update(evt);
				eventId = evt.Id;
			}catch(Exception err){
				CBK_Log.error(err);
			response = 'Fail-'+err.getMessage(); 
	
		}
		}else{
			try{
				Database.SaveResult sr = Database.insert(evt);
				eventId = sr.getId();
			}catch(Exception err){
				CBK_Log.error(err);
				response = 'Fail-'+err.getMessage(); 
	
			}

		}
		List<Event> operatedEvent = [SELECT AV_Task__c FROM Event WHERE Id = :eventId LIMIT 1];
		return (!operatedEvent.isEmpty()) ? eventId+separador+operatedEvent[0].AV_Task__c : 'Fail-: No records';
	}

	@AuraEnabled
	public static Map<String,String> createEventFromReport(Event evt,SObject objectToReport, SObject taskToClose,String originReport,CC_Llamada__c callObj,Date dateToQuery) {
		String separador = '{|}';
		Savepoint sp = Database.setSavepoint();
		String methodName = 'createEventFromReport';
		Map<String,String>  response = new Map<String,String>();
		String newEventId;
		if(evt != null) {
			evt.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
			evt.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT,AV_AppConstants.EVENTCLIENTE_RT).Id;
			evt.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE;
			
			Database.SaveResult sr = Database.insert(evt,false);
			if(sr.isSuccess()) {
				String newEventTaskHeader = [SELECT AV_Task__c FROM Event WHERE Id = :sr.getId() WITH SECURITY_ENFORCED LIMIT 1].AV_Task__c;
				response.put('newEventIdWithHeader',(sr.getId()+separador+newEventTaskHeader));
			} else {
				Database.Error err = sr.getErrors()[0];
				response.put('errorResult',('Fail-'+err.getMessage())); 
				AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
				Database.rollback( sp );
			}
		}
		if(objectToReport != null) {
			String type = objectToReport.getSObjectType().getDescribe().getName();
			if((originReport != null && originReport.equals(AV_AppConstants.OBJECT_NAME_TASK) ) || (originReport != null && originReport.equals(AV_AppConstants.OBJECT_NAME_OPPORTUNITY))) {
				if(taskToClose != null) {
					Task tskBforeUpdate = [SELECT Status, Description,AV_ContactGenerateAppointment__c FROM TASK WHERE Id = :((Id) (taskToClose.get('AV_ActivityId__c'))) LIMIT 1];
					response.put('backClosedTask',JSON.serialize(tskBforeUpdate,false));
					Boolean updatingTask = type.equals(AV_AppConstants.OBJECT_NAME_TASK);
					Task taskToUpdate = new Task();
					taskToUpdate.Id = (Id) (taskToClose.get('AV_ActivityId__c'));
					taskToUpdate.AV_ContactGenerateAppointment__c = AV_AppConstants.GENERATE_APPOINTMENT;
					taskToUpdate.Status = (updatingTask) ? ( (String) objectToReport.get('Status')) : AV_AppConstants.CERRADO_ESTADO;
					taskToUpdate.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
					taskToUpdate.AV_Tipo__c = updatingTask ? (String) objectToReport.get('AV_Tipo__c') : (String) taskToClose.get('AV_Type__c');
					if ((updatingTask) && !String.isBlank((String) objectToReport.get('Description'))) {
						taskToUpdate.Description =  (String) objectToReport.get('Description') ;
					}
					taskToUpdate.OwnerId = (String) taskToClose.get('OwnerId');
					

					Database.SaveResult srTask = Database.update(taskToUpdate,false);
					if(!srTask.isSuccess()) {
						Database.Error err = srTask.getErrors()[0];
						response.put('errorResult',('Fail-'+err.getMessage()));
						AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
						Database.rollback( sp );
						return response;
					} else {
						Database.SaveResult srmmh = Database.insert(taskToClose,false);
						if(!srmmh.isSuccess()) {
							Database.Error err = srmmh.getErrors()[0];
							response.put('errorResult',('Fail-'+err.getMessage()));
							AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
							Database.rollback( sp );
							return response;
						} else {
							response.put('backManagementClosedTask',srmmh.getId());
						}
					}
				}
				objectToReport.put('RecordTypeId',(String) (AV_AppUtilities.getRecordType(type,(String) objectToReport.get('RecordTypeId')).Id));
				if(originReport.equals(AV_AppConstants.OBJECT_NAME_OPPORTUNITY) || type.equals(AV_AppConstants.OBJECT_NAME_EVENT)) {
					objectToReport.put('AV_ContactGenerateAppointment__c',AV_AppConstants.GENERATE_APPOINTMENT);
					Database.SaveResult sri = Database.insert(objectToReport,false);
					if(!sri.isSuccess()) {
						Database.Error err = sri.getErrors()[0];
						response.put('errorResult',('Fail-'+err.getMessage()));
						AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
						Database.rollback( sp );
						return response;
					} else {
						String newObjectId = sri.getId();
						String queryToHeader = 'SELECT AV_Task__c FROM ' + type + ' WHERE Id = :newObjectId WITH SECURITY_ENFORCED LIMIT 1';
						SObject taskHeader = capsulateQuery(queryToHeader,newObjectId);
						String newObjectHeaderId = (String) taskHeader.get('AV_Task__c');
						response.put('insertedId',(newObjectId));
						response.put('insertedHeaderId',(newObjectHeaderId));
					}
				}
			} else if((originReport != null && originReport.equals('CC_Llamada__c'))){
				AV_CallReport_Controller.EventAndCallWrapper processedCallReport = AV_CallReport_Controller.processEventAndCall((Event) objectToReport, (CC_Llamada__c) callObj, (String) objectToReport.get('WhatId'), dateToQuery, (String) objectToReport.get('AV_CodigoGestorAsignado__c'));
				if(processedCallReport.evtBack != null){
					response.put('operation','update');
					response.put('evtBack',JSON.serialize(processedCallReport.evtBack));
					response.put('updatedEventHeaderId',processedCallReport.evtBack.AV_Task__c);
					response.put('operatedEventId',processedCallReport.evtBack.Id);
				}else{
					response.put('operation','insert');
					response.put('evtBackId',processedCallReport.evtToDelBack);
					response.put('operatedEventId',processedCallReport.evtToDelBack);
					response.put('headerNewEvt',processedCallReport.headerNewEvt);
				}
				response.put('callBackRep',JSON.serialize(processedCallReport.callBackRep));
			}else {
				Boolean isPrivateBacking = FeatureManagement.checkPermission('AV_PrivateBanking');
				Event eventBeforeUpdate;
				if(isPrivateBacking) {
					eventBeforeUpdate = [SELECT Id, AV_Tipo__c, WhatId, StartDateTime, EndDateTime, AV_MemorableInterview__c, Description, AV_BranchPhysicalMeet__c, WhoId, Location, AV_ContactGenerateAppointment__c FROM EVENT WHERE ID = :objectToReport.Id WITH SECURITY_ENFORCED LIMIT 1];
				} else {
					eventBeforeUpdate = [SELECT Id, AV_Tipo__c, WhatId, StartDateTime, EndDateTime, Description, AV_BranchPhysicalMeet__c, WhoId, Location, AV_ContactGenerateAppointment__c FROM EVENT WHERE ID = :objectToReport.Id WITH SECURITY_ENFORCED LIMIT 1];
				}
				Database.SaveResult sru = Database.update(objectToReport,false);
				if(!sru.isSuccess()) {
					Database.Error err = sru.getErrors()[0];
					response.put('errorResult',('Fail-'+err.getMessage()));
					AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
					Database.rollback( sp );
				} else {
					Event evtToSerialize = new Event();
					evtToSerialize.Id = eventBeforeUpdate.Id;
					evtToSerialize.AV_Tipo__c = eventBeforeUpdate.AV_Tipo__c;
					evtToSerialize.WhatId = eventBeforeUpdate.WhatId;
					evtToSerialize.StartDateTime = eventBeforeUpdate.StartDateTime;
					evtToSerialize.EndDateTime = eventBeforeUpdate.EndDateTime;
					if(isPrivateBacking) {
						evtToSerialize.AV_MemorableInterview__c = eventBeforeUpdate.AV_MemorableInterview__c;
					}
					evtToSerialize.Description = eventBeforeUpdate.Description;
					evtToSerialize.AV_BranchPhysicalMeet__c = eventBeforeUpdate.AV_BranchPhysicalMeet__c;
					evtToSerialize.WhoId = eventBeforeUpdate.WhoId;
					evtToSerialize.Location = eventBeforeUpdate.Location;
					evtToSerialize.AV_ContactGenerateAppointment__c = eventBeforeUpdate.AV_ContactGenerateAppointment__c;
					response.put('backReportEvent',(JSON.serialize(evtToSerialize,false)));
				}
			}
		}
		return response;
	}

	/**
	 * Given the id of the recently created event, it create a list of Event Relations in order to create the attendes for the event
	 * @param eventId Id of the main event
	 * @param List<String> List of users id that will be attendes of the event
	 * @return Whether a list of the EventRelations id that has been inserted, or a string with the errors if the insert has not been succesful
	 */
	 @AuraEnabled
	 public static List<String> createEventRelation(Id eventId,List<String> attendes) {
		String methodName = 'createEventRelation';
		List<String> result = new List<String>();
		Savepoint sp = Database.setSavepoint();
		List<EventRelation> evtRelList = new List<EventRelation>();
		if(attendes != null && !attendes.isEmpty()) {
			for(String att : attendes) {
				EventRelation evRel = new EventRelation();
				evRel.RelationId = att;
				evRel.EventId = eventId;
				evRel.isWhat = false;
				evRel.isParent = false;
				evRel.isInvitee = true;
				evtRelList.add(evRel);			
			}	
		}
		List<Database.SaveResult> srList = Database.insert(evtRelList,false);
		for(Database.SaveResult sr : srList) {
			if(!sr.isSuccess()) {
				if(!result.isEmpty()) {
					result.clear();
				}
				result.add('Fail');
				for(Database.Error err : sr.getErrors()) {
					result.add(err.getMessage());
					AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
				}
				Database.rollback(sp);
				break;
			} else {
				result.add(sr.getId());
			}
		}
		return result;
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
	
	@AuraEnabled
	public static CreatedOpportunitiesWrapper createOrUpdateOpportunitiesFromReport(Map<String,Map<String,Object>> opposToInsertOrUpdate,String accountId,Map<String,Opportunity> mapOldOpp,String eventId,String objectFirstReport, String objectSecondaryReport) {
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
		
		Set<Id> setIds = new Set<Id>();
		for (String outerKey : opposToInsertOrUpdate.keySet()) {
			Map<String, Object> innerMap = opposToInsertOrUpdate.get(outerKey);
			String id = (String)innerMap.get('id');
			setIds.add(id);
		}
		List<Contact> contactList = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c =:UserInfo.getUserId() ];
		Event evento = new Event();
		Task  task = new Task();
		if(objectFirstReport == 'Event'  && objectSecondaryReport == 'Event'){
			 evento = [Select Id FROM Event WHERE AV_Task__c =: eventId];
		}
		else if(objectFirstReport == 'Task' && objectSecondaryReport == 'Task' ){
			task = [Select Id FROM Task WHERE AV_Task__c =: eventId];
		}
		else if(objectFirstReport == 'Task' && objectSecondaryReport == 'Event' ){
			evento = [Select Id FROM Event WHERE AV_Task__c =: eventId];
		}
		else if(objectFirstReport == 'Opportunity' && objectSecondaryReport == 'Event' ){
			evento = [Select Id FROM Event WHERE AV_Task__c =: eventId];
		}
		else if(objectFirstReport == 'Opportunity' && objectSecondaryReport == 'Task' ){
			task = [Select Id FROM Task WHERE AV_Task__c =: eventId];
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
	*@param caosInsertedEvent AV_CustomActivityOpportunity__c records for second report ready configured
	*@param caosTaskRecordReport AV_CustomActivityOpportunity__c records for first report already configured
	*@param commentsHistoryFromReport List of comment history objets mounted and ready to be inserted
	*@param isCallReport Boolean that informs whether the report is from CC_Llamada__c or not
	 * 
	 */
	@AuraEnabled
	public static List<String> vinculateFromReport(Map<String,Boolean> opposAndMain,String recordHeaderId, List<AV_CustomActivityOpportunity__c> caosInsertedEvent,List<AV_CustomActivityOpportunity__c> caosTaskRecordReport,List<AV_CommentsHistory__c> commentsHistoryFromReport,Boolean isCallReport) {
		String methodName = 'vinculateFromReport';
		Savepoint sp = Database.setSavepoint();
		List<String> responseOk = new List<String>{'OK'};
		List<String> responseNOk = new List<String>{'NOK'};
		Set<String> openStages = new Set<String>{
			AV_AppConstants.OPP_STATUS_POTENCIAL,
			AV_AppConstants.OPP_STATUS_ENGESTION
		};	
		Set<String> retailRts = new Set<String>{ 
			AV_AppConstants.OPPINICIATIVA_RT,
			AV_AppConstants.OPPALERTACOM_RT,
			AV_AppConstants.OPPPROPUESTA_RT,
			AV_AppConstants.OPPSUGERENCIA_RT,
			AV_AppConstants.OPPLLAMADA_RT
		};
		if(isCallReport){//Si viene por parte de la nueva lógica del reporte de llamadas, hará las vinculaciones con la lógica pertinente y se desestima el resto del método;

			List<String> callReportVinculationsFirtsScreen =  AV_CallReport_Controller.processVinculations(opposAndMain,recordHeaderId,commentsHistoryFromReport);
			if(callReportVinculationsFirtsScreen[0].equals('NOK')){
				return responseNOk;
			}
			if(caosInsertedEvent != null && !caosInsertedEvent.isEmpty()) {

				try{
					Database.insert(caosInsertedEvent);
				}catch(Exception err){
					Database.rollback(sp);
					CBK_Log.error(err);
					return responseNOk;
				}
		
			}

			return responseOk;

		}
		if(opposAndMain != null && !opposAndMain.keySet().isEmpty() && recordHeaderId != null) {
			Set<String> opposToCheckCao = opposAndMain.keySet();
			Map<String,Boolean> mainMapCopy = opposAndMain.clone();
			List<AV_CustomActivityOpportunity__c> existingCaos = [SELECT AV_Opportunity__c,AV_IsMain__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :recordHeaderId AND AV_opportunity__c != NULL];
			List<AV_CustomActivityOpportunity__c> caosToSwitch = new List<AV_CustomActivityOpportunity__c>();
			List<AV_CustomActivityOpportunity__c> newCaos = new List<AV_CustomActivityOpportunity__c>();
			Map<String,String> oppoToCao = new Map<String,String>();
			AV_CustomActivityOpportunity__c oldCao;
			Boolean changeMain = false;
			String newMain;
			for(String oppId : opposAndMain.keySet()) {
				if(opposAndMain.get(oppId)) {
					newMain = oppId;
				}
			}
			if(existingCaos != null && !existingCaos.isEmpty()) {
				for(AV_CustomActivityOpportunity__c cao : existingCaos) {
					oppoToCao.put(cao.AV_Opportunity__c,cao.Id);
					if(cao.AV_IsMain__c) {
						oldCao = cao;
					}
					if(opposAndMain.containsKey(cao.AV_Opportunity__c)) {
						opposAndMain.remove(cao.AV_Opportunity__c);
					}
				}
			}
			if(!opposAndMain.isEmpty()) {
				String newMainOpp;
				for(String oppId : opposAndMain.keySet()) {

					newCaos.add(
						new AV_CustomActivityOpportunity__c(
							AV_Opportunity__c = oppId,
							AV_Task__c = recordHeaderId,
							AV_IsMain__c = opposAndMain.get(oppId),
							AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP
							)
							);
				}
				if(newMain != null && oldCao != null) {
					if(!newMain.equals(oldCao.AV_Opportunity__c)) {
						oldCao.AV_IsMain__c = false;
						caosToSwitch.add(oldCao);
					}
					if(!opposAndMain.containsKey(newMain)) {
						caosToSwitch.add(new AV_CustomActivityOpportunity__c (Id = oppoToCao.get(newMain),AV_IsMain__c = true));	
					}
				}
			} else {
				if(mainMapCopy != null && oldCao!= null && !mainMapCopy.isEmpty() && mainMapCopy.containsKey(oldCao.AV_Opportunity__c) && !mainMapCopy.get(oldCao.AV_Opportunity__c)) {
					oldCao.AV_IsMain__c = false;
					caosToSwitch.add(oldCao);
					for(String oppId : mainMapCopy.keySet()) {
						if(mainMapCopy.get(oppId)) {
							caosToSwitch.add(new AV_CustomActivityOpportunity__c (Id = oppoToCao.get(oppId),AV_IsMain__c = true));
						}
					}
				}
			}
			List<AV_CustomActivityOpportunity__c> closedMains = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :recordHeaderId AND AV_Opportunity__r.StageName NOT IN :openStages AND AV_Opportunity__r.Recordtype.DeveloperName IN :retailRts AND AV_IsMain__c = true AND Id NOT IN :((new Map<Id,AV_CustomActivityOpportunity__c>(caosToSwitch)).keySet())];
			if(!closedMains.isEmpty()) {
				for(AV_CustomActivityOpportunity__c cao : closedMains) {
					caosToSwitch.add(new AV_CustomActivityOpportunity__c( Id = cao.Id , AV_IsMain__c = false ));
				}
			}
			if(!caosToSwitch.isEmpty()) {
				try{
					Database.update(caosToSwitch);
				}catch(Exception err){
					Database.rollback(sp);
					CBK_Log.error(err);
					return responseNOk;
				}
			
			}
			if(!newCaos.isEmpty()) {

				try{
					Database.insert(newCaos);
				}catch(Exception err){
					Database.rollback(sp);
					CBK_Log.error(err);
					return responseNOk;
				}
	
			}
		}
		if(caosInsertedEvent != null && !caosInsertedEvent.isEmpty()) {

			try{
				Database.insert(caosInsertedEvent);
			}catch(Exception err){
				Database.rollback(sp);
				CBK_Log.error(err);
				return responseNOk;
			}
	
		}
		if(caosTaskRecordReport != null && !caosTaskRecordReport.isEmpty() ) {

			try{
				Database.insert(caosTaskRecordReport);
			}catch(Exception err){
				Database.rollback(sp);
				CBK_Log.error(err);
				return responseNOk;
			}
		
		}

		if(commentsHistoryFromReport != null && !commentsHistoryFromReport.isEmpty()){

			List<Contact> usrCnt = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :UserInfo.getUserId() LIMIT 1];
			
			if(!usrCnt.isEmpty()){
			for(AV_CommentsHistory__c cmmh : commentsHistoryFromReport){
				cmmh.AV_AssignedEmployee__c = usrCnt[0].Id;
			}
		}

		try{
			Database.insert(commentsHistoryFromReport);
		}catch(Exception err){
				Database.rollback(sp);
				CBK_Log.error(err);
				return responseNOk;
		}
		
	}
		return responseOk;
	}

	@AuraEnabled//TAREAS DEL CLIENTE
	public static Map<String,List<String>> closeClientTasks(List<Task> tasksToClose) {
		String methodName = 'closeClientTasks';
		Map<String,List<String>> response = new Map<String,List<String>>();
		Savepoint sp = Database.setSavepoint();
		if(tasksToClose != null && !tasksToClose.isEmpty()) {
			Map<Id,Task> backTasks = new Map<Id,Task>([SELECT Id,Description,Status,ActivityDate,ReminderDateTime,AV_Tipo__c,AV_OrigenApp__c,AV_ContactGenerateAppointment__c FROM Task WHERE Id IN :((new Map<Id,Task>(tasksToClose)).keySet())]);
			List<Database.SaveResult> sru = Database.update(tasksToClose,false);
			response.put('updatedClientTasksBack',new List<String>());
			for(Database.SaveResult sr : sru) {
				if(sr.isSuccess()) {
					response.get('updatedClientTasksBack').add(JSON.serialize(backTasks.get(sr.getId()),false));
				} else {
					Database.rollback(sp);
					response.clear();
					response.put('errorList',new List<String>());
					for(Database.Error err : sr.getErrors()) {
						String errorStr =  'Error updating closed tasks: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
						response.get('errorList').add(errorStr);
						AV_LogDebug.printLogDebug(methodName,errorStr);
					}
					return response;
				}
			}
			if(backTasks != null && !backTasks.isEmpty()) {
				List<AV_ManagementHistory__c> mmhToInsert = new List<AV_ManagementHistory__c>();
				for(Task t : backTasks.values()) {
					mmhToInsert.add(
						new AV_ManagementHistory__c(
							AV_ActivityId__c = t.Id,
							AV_Comment__c = t.Description,
							AV_Date__c = t.ActivityDate,
							AV_Reminder__c = t.ReminderDateTime,
							AV_Status__c = t.Status,
							AV_Type__c = t.AV_Tipo__c
						)
					);
				}
				response.put('insertedMMHofClosedTasks',new List<String>());
				if(!mmhToInsert.isEmpty()) {
					List<Database.SaveResult> srmmhList = Database.insert(mmhToInsert,false);
					for(Database.SaveResult srmmh : srmmhList) {
						if(srmmh.isSuccess()) {
							response.get('insertedMMHofClosedTasks').add(srmmh.getId());
						} else {
							Database.rollback(sp);
							response.put('errorList',new List<String>());
							response.clear();
							for(Database.Error err : srmmh.getErrors()) {
								String errorStr =  'Error inserting managementHistory from closedTask: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
								response.get('errorList').add(errorStr);
								AV_LogDebug.printLogDebug(methodName,errorStr);
							}
							return response;
						}
					}
				}
			}
			return response;
		}
		return response;
	}

	@AuraEnabled
	public static CreatedOpportunitiesWrapper processCheckOnOffCreate(Map<String,List<String>> checkOnOff,String accountId) {
		Boolean hasCustomPermission = FeatureManagement.checkPermission(AV_AppConstants.PS_OLDHOMETASK); 
		String methodName = 'processCheckOnOffCreate';
		Savepoint sp = Database.setSavepoint();
		List<String> opposToCreateCheckOnOff = checkOnOff.get('create');
		CreatedOpportunitiesWrapper reportProccesInfo = new CreatedOpportunitiesWrapper();
		if(hasCustomPermission) {         
			RecordType rtTask = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK,AV_AppConstants.TASKINICIATIVA_RT);
			List<Task> checkOnOffToInsert = new List<Task>();
			if(opposToCreateCheckOnOff != null && !opposToCreateCheckOnOff.isEmpty()) {
				Map<String,Task> oppoTaskRelation = new Map<String,Task>();
				for(String oppInfo : opposToCreateCheckOnOff) {	
					Task nextRecord = new Task();
					nextRecord.WhatId = accountId;
					nextRecord.Status = AV_AppConstants.TASK_STATUS_PENDIENTE;
					nextRecord.Priority = AV_AppConstants.TASK_PRIORITY_HIGH;
					nextRecord.ActivityDate = formatDate(oppInfo.split('---')[2]);
					nextRecord.Subject = ((String) oppInfo.split('---')[1]);
					nextRecord.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF;
					oppoTaskRelation.put((oppInfo.split('---')[0]),nextRecord);
					checkOnOffToInsert.add(nextRecord);
				}
				if(!checkOnOffToInsert.isEmpty()) {
					List<Database.SaveResult> srList = Database.insert(checkOnOffToInsert,false);
					for(Database.SaveResult sr : srList) {
						if(sr.isSuccess()) {
							reportProccesInfo.bckCOF.createdIdsToDelete.add(sr.getId());
						} else {
							Database.rollback(sp);
							reportProccesInfo.errorList = new List<String>();
							for(Database.Error err : sr.getErrors()) {
								String errorStr =  'Error insert checkOnOff: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
								reportProccesInfo.errorList.add(errorStr);
								AV_LogDebug.printLogDebug(methodName,errorStr);
							}
						}
					}
					if(!reportProccesInfo.bckCOF.createdIdsToDelete.isEmpty()) {
						List<AV_CustomActivityOpportunity__c> caoToInsert = new List<AV_CustomActivityOpportunity__c>();
						Map<Id,Task> tasksInserted = new Map<Id,Task>([SELECT Id, AV_Task__c FROM Task WHERE Id IN :reportProccesInfo.bckCOF.createdIdsToDelete WITH SECURITY_ENFORCED]);
						for(String oppInfo : opposToCreateCheckOnOff) {
							String oppId = oppInfo.split('---')[0];
							String taskHeaderId = tasksInserted.get(oppoTaskRelation.get(oppId).Id).AV_Task__c;
							caoToInsert.add(
								new AV_CustomActivityOpportunity__c(
									AV_Opportunity__c = oppId,
									AV_Task__c = taskHeaderId,
									AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF,
									AV_IsMain__c = true,
									AV_IncludeInPrioritizingCustomers__c = true
								)
							);
						}
						if(!caoToInsert.isEmpty()) {
							List<Database.SaveResult> srcao = Database.insert(caoToInsert,false);
							for(Database.SaveResult sr : srcao) {
								if(sr.isSuccess()) {
									reportProccesInfo.bckCOF.createdCaosToDelete.add(sr.getId());
								} else {
									Database.rollback(sp);
									reportProccesInfo.errorList = new List<String>();
									for(Database.Error err : sr.getErrors()) {
										String errorStr =  'Error inserting new CAOS: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
										reportProccesInfo.errorList.add(errorStr);
										AV_LogDebug.printLogDebug(methodName,errorStr);
									}
								}
							}
						}
					}
				}
			}
		}
		return reportProccesInfo;
	}

	@AuraEnabled
	public static CreatedOpportunitiesWrapper processCheckOnOffUpdate(Map<String,List<String>> checkOnOff,String accountId) {
		String methodName = 'processCheckOnOffUpdate';
		Boolean hasCustomPermission = FeatureManagement.checkPermission(AV_AppConstants.PS_OLDHOMETASK); 
		Savepoint sp = Database.setSavepoint();
		CreatedOpportunitiesWrapper reportProccesInfo = new CreatedOpportunitiesWrapper();
		List<String> opposToUpdateCheckOnOff = checkOnOff.get('update');
		if(hasCustomPermission) {
			if(opposToUpdateCheckOnOff != null && !opposToUpdateCheckOnOff.isEmpty()) {
				Map<String,String> opposIdToNextDate = new Map<String,String>();
				Map<String,String> opposIdToName = new Map<String,String>();
				for(String oppId : opposToUpdateCheckOnOff) {
					opposIdToNextDate.put(oppId.split('---')[0],oppId.split('---')[2]);
					opposIdToName.put(oppId.split('---')[0],oppId.split('---')[1]);
				}
				List<AV_CustomActivityOpportunity__c> existintCaosCheckOnOff = [SELECT Id,AV_Task__c,AV_Opportunity__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN :opposIdToNextDate.keySet() AND AV_IncludeInPrioritizingCustomers__c = true WITH SECURITY_ENFORCED];
				Map<String,AV_CustomActivityOpportunity__c> headerToCaoMap = new Map<String,AV_CustomActivityOpportunity__c>();
				for(AV_CustomActivityOpportunity__c cao : existintCaosCheckOnOff) {
					headerToCaoMap.put(cao.AV_Task__c,cao);
				}
				Map<Id,Task> existingTasksCheckOnOff = new Map<Id,Task>([SELECT Id,AV_Task__c,ActivityDate FROM Task WHERE AV_Task__c IN :headerToCaoMap.keySet() AND isClosed = FALSE AND AV_OrigenApp__c = :AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF WITH SECURITY_ENFORCED]); 
				List<Task> tskCheckOnOffToUpdate = new List<Task>();
				for(Id tskId : existingTasksCheckOnOff.keySet()) {
					Task currentTask = existingTasksCheckOnOff.get(tskId);
					reportProccesInfo.bckCOF.updatedTasksToRestore.add(currentTask);
					Date newDate = formatDate(opposIdToNextDate.get(headerToCaoMap.get(currentTask.AV_Task__c).AV_Opportunity__c));
					tskCheckOnOffToUpdate.add(new Task(Id = tskId,  ActivityDate = newDate));
				}
				if(!tskCheckOnOffToUpdate.isEmpty()) {
					List<Database.SaveResult> srU = Database.update(tskCheckOnOffToUpdate,false);
					for(Database.SaveResult sr : srU) {
						if(!sr.isSuccess()) {
							Database.rollback(sp);
							reportProccesInfo.errorList = new List<String>();
							for(Database.Error err : sr.getErrors()) {
								String errorStr =  'Error inserting new CAOS: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
								reportProccesInfo.errorList.add(errorStr);
								AV_LogDebug.printLogDebug(methodName,errorStr);
							}
						}
					}
				}
			}
		}
		return reportProccesInfo;
	}

	@AuraEnabled
	public static CreatedOpportunitiesWrapper processCheckOnOffDelete(Map<String,List<String>> checkOnOff,String accountId) {
		String methodName = 'processCheckOnOffDelete';
		Boolean hasCustomPermission = FeatureManagement.checkPermission(AV_AppConstants.PS_OLDHOMETASK); 
		Savepoint sp = Database.setSavepoint();
		CreatedOpportunitiesWrapper reportProccesInfo = new CreatedOpportunitiesWrapper();
		String separador = '---';
		List<String> opposToDeleteCheckOnOff = checkOnOff.get('delete');
		if(hasCustomPermission) {
			if(opposToDeleteCheckOnOff != null && !opposToDeleteCheckOnOff.isEmpty()) {
				Map<String,List<AV_CustomActivityOpportunity__c>> relatedHeaderCaoListMap = new Map<String,List<AV_CustomActivityOpportunity__c>>();
				Map<String,String> opposRelatedWithHeaderTsk = new Map<String,String>();
				Set<Id> relatedCaoId = new Set<Id>();
				List<AV_CustomActivityOpportunity__c> caoList = [SELECT OwnerId, RecordTypeId, AV_ExternalID__c, AV_Opportunity__c,AV_Task__c, AV_OrigenApp__c, AV_Amount__c, AV_Commentary__c, AV_Concepto1__c, AV_Concepto3__c, AV_Concepto4__c, AV_Concepto5__c, AV_DischargeDate__c, AV_DueDate__c, AV_Entity__c, AV_FeeAmount__c, AV_Gestor__c, AV_HoldingAnotherEntity__c, AV_IsMain__c, AV_NextEventDate__c, AV_Priority__c, AV_Product__c, AV_ReviewDate__c, AV_Stage__c, AV_TypeOfInterest__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, AV_WarningDate__c, AV_LicensePlate__c, AV_IncludeInPrioritizingCustomers__c, AV_FechaVencimiento__c, AV_ActivityDate__c, AV_Status__c, AV_Resolucion__c, AV_Channel__c, AV_AmountEuro__c, AV_ByProduct__c, AV_MarginEuro__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN :opposToDeleteCheckOnOff AND AV_Task__c != NULL WITH SECURITY_ENFORCED];
				Map<String,List<Id>> opportunityToHeaders = new Map<String,List<Id>>();
				for(AV_CustomActivityOpportunity__c cao : caoList) {
					if(!relatedHeaderCaoListMap.containsKey(cao.AV_Task__c)) {
						relatedHeaderCaoListMap.put(cao.AV_Task__c, new List<AV_CustomActivityOpportunity__c>{cao});
					} else {
						relatedHeaderCaoListMap.get(cao.AV_Task__c).add(cao);
					}
					opposRelatedWithHeaderTsk.put(cao.AV_Task__c,cao.AV_Opportunity__c);
				}
				List<Task> checkonOffTasks = [SELECT RecordTypeId, WhoId, WhatId, Subject, ActivityDate, Status, Priority, OwnerId, Description, ReminderDateTime, IsReminderSet,AV_ALVEN__c,AV_CodigoGestorAsignado__c,  AV_NoGestionable__c, AV_Type__c, AV_ExternalID__c, AV_ConVenta__c,AV_Task__c, AV_Tipo__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c,AV_Valor4__c, AV_Valor5__c, AV_OrigenApp__c, AV_BranchPhysicalMeet__c, AV_ColorEtiqueta__c, AV_DurationToNoticeToManager__c, AV_FechaFinAccionComercial__c, AV_Center__c, AV_PrioritizingSort__c, AV_FechaInicioVigencia__c, AV_Chanel__c, AV_PEA__c, AV_Purpose__c, AV_IdDelActaMifid__c, AV_CenterRtIndex__c, AV_PriorityTask__c, AV_AssociatedOpportunityId__c, AV_SurveyValue__c, AV_PEA2__c, AV_OrigenAct__c, AV_VisiblePorElClienteEnNow__c, AV_Case__c,IsClosed FROM Task WHERE AV_Task__c IN :relatedHeaderCaoListMap.keySet() WITH SECURITY_ENFORCED];
				Map<Id,List<Task>> oppTaskMap = new Map<Id,List<Task>>();
				Map<String,Task> headerIdToTask = new Map<String,Task>();
				List<Id> tskToDelete = new List<Id>();
				List<Id> caoToDelete = new List<Id>();
				for(Task ta : checkonOffTasks){
					if(!ta.IsClosed && !relatedHeaderCaoListMap.get(ta.AV_Task__c).isEmpty() && ta.AV_OrigenApp__c != null && ta.AV_OrigenApp__c.equals(AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF)){
						if(!tskToDelete.contains(ta.Id)){
							tskToDelete.add(ta.Id);
						}
						reportProccesInfo.bckCOF.caoToRestoreBack.addAll(relatedHeaderCaoListMap.get(ta.AV_Task__c));
						reportProccesInfo.bckCOF.taskToRestoreBack.add(ta);
						reportProccesInfo.bckCOF.taskOpposRelation.put(ta.AV_Task__c,ta.AV_ExternalID__c);
						headerIdToTask.put(ta.AV_Task__c,ta);
					}
				}
				if(!reportProccesInfo.bckCOF.caoToRestoreBack.isEmpty()) {
					for(AV_CustomActivityOpportunity__c caoToDel : reportProccesInfo.bckCOF.caoToRestoreBack) {
						if(!caoToDelete.contains(caoToDel.Id)) {
							caoToDelete.add(caoToDel.Id);
						}
					}
				}	
				if(!caoToDelete.isEmpty()){
					List<Database.DeleteResult> drCaoDelete = Database.delete(caoToDelete,false);
					for(Database.DeleteResult dr : drCaoDelete){
						if(!dr.isSuccess()){
							Database.rollback( sp );
							reportProccesInfo.errorList = new List<String>();
							for(Database.Error err : dr.getErrors()){
								String errorStr =  'Error delete cao: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
								reportProccesInfo.errorList.add(errorStr);
								AV_LogDebug.printLogDebug(methodName,errorStr);
							}
							return reportProccesInfo;
						}
					}
				}
				if(!tskToDelete.isEmpty()){
					List<Database.DeleteResult> drTaskToDelete = Database.delete(tskToDelete,false);
					for(Database.DeleteResult dr : drTaskToDelete){
						if(!dr.isSuccess()){
							Database.rollback( sp );
							reportProccesInfo.errorList = new List<String>();
							for(Database.Error err : dr.getErrors()){
								String errorStr =  'Error: Task' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
								reportProccesInfo.errorList.add(errorStr);
								AV_LogDebug.printLogDebug(methodName,errorStr);
							}
							return reportProccesInfo;
						}
					}
				}
			}
		}
		return reportProccesInfo;
	}

	/**
	 * Create and update the opportunities edited on the component. It deletes too the checkOnOff tasks related to the updated opportunities.
	 * Deletes the AV_CustomActivityOpportunity__c records too
	 * @param Map<String,Map<String,Object>> opposToInsertOrUpdate => Object that contains updated and inserted oppos
	 * @param String accoundId Id from the event client that is being created
	 * @CreatedOpportunitiesWrapper Wrapped response
	 */
	@AuraEnabled
	public static CreatedOpportunitiesWrapper createOrUpdateOpportunities(Map<String,Map<String,Object>> opposToInsertOrUpdate,String accountId, String eventIdCreated){
		String methodName = 'createOrUpdateOpportunities**';
		CreatedOpportunitiesWrapper response = new CreatedOpportunitiesWrapper();
		Savepoint sp = Database.setSavepoint();
		Id iniciativaRt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY,AV_AppConstants.OPPINICIATIVA_RT).Id;
		List<Map<String,Object>> wrappedOppsToInsert = new List<Map<String,Object>>();
		List<Map<String,Object>> wrappedOppsToUpdate = new List<Map<String,Object>>();
		List<Opportunity> opposToInsert = new List<Opportunity>();		
		List<Opportunity> opposToUpdate = new List<Opportunity>();
		List<String> listIdsCommentsHistoryInsert = new List<String>();
		Map<String,String> opposRelatedWithHeaderTsk = new Map<String,String>();
		Map<String,Opportunity> mapOldOpp = new Map<String,Opportunity>();
		Map<String,Opportunity> opposUpdatedMap = new Map<String,Opportunity>();
		Map<String,List<AV_CustomActivityOpportunity__c>> relatedHeaderCaoListMap = new Map<String,List<AV_CustomActivityOpportunity__c>>();
		Set<Id> caoCheckOnOffToDelete = new Set<Id>();
		Set<Id> tskCheckOnOffToDelete = new Set<Id>();
		Map<String,String> tskToHeaderMap = new Map<String,String>();
		Set<String> opposToCleanCheckOnOff = new Set<String>();
		for(String objId : opposToInsertOrUpdate.keySet()) {
			if(objId.contains('idProvisional')) {
				wrappedOppsToInsert.add(opposToInsertOrUpdate.get(objId));
			} else {
				wrappedOppsToUpdate.add(opposToInsertOrUpdate.get(objId));
				if((Boolean) (opposToInsertOrUpdate.get(objId).get('priorizado'))) {
					opposToCleanCheckOnOff.add(objId);
				}
			}
		}
		if(!wrappedOppsToInsert.isEmpty()) {
			opposToInsert = unWrappOppos(wrappedOppsToInsert,iniciativaRt,accountId);
		}
		if(!wrappedOppsToUpdate.isEmpty()) {
			opposToUpdate = unWrappOppos(wrappedOppsToUpdate,iniciativaRt,accountId);
			List<String> listIdsOpps = new List<String>();
			for(Opportunity opp :  opposToUpdate) {
				opposUpdatedMap.put(opp.Id,opp);
				listIdsOpps.add(opp.Id);
			}
			List<Opportunity> listOldOpp = [Select Id, StageName, AV_Comentarios__c FROM Opportunity WHERE Id in :listIdsOpps];
			for (Opportunity opp : listOldOpp) {
				mapOldOpp.put(opp.Id, opp);
			}
		}
		//Buscamos las tareas del checkonOff para borrarlas y guardarlas para el back
		Set<Id> relatedCaoId = new Set<Id>();
		List<AV_CustomActivityOpportunity__c> caoList = [SELECT OwnerId, RecordTypeId, AV_ExternalID__c, AV_Opportunity__c, AV_Task__c, AV_OrigenApp__c, AV_Amount__c, AV_Commentary__c, AV_Concepto1__c, AV_Concepto2__c, AV_Concepto3__c, AV_Concepto4__c, AV_Concepto5__c, AV_DischargeDate__c, AV_DueDate__c, AV_Entity__c, AV_FeeAmount__c, AV_Gestor__c, AV_HoldingAnotherEntity__c, AV_IsMain__c, AV_NextEventDate__c, AV_Priority__c, AV_Product__c, AV_ReviewDate__c, AV_Stage__c, AV_TypeOfInterest__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, AV_WarningDate__c, AV_LicensePlate__c, AV_IncludeInPrioritizingCustomers__c, AV_FechaVencimiento__c, AV_ActivityDate__c, AV_Status__c, AV_Resolucion__c, AV_Channel__c, AV_AmountEuro__c, AV_ByProduct__c, AV_MarginEuro__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN :opposToCleanCheckOnOff AND AV_Task__c != NULL WITH SECURITY_ENFORCED];
		Map<String,List<Id>> opportunityToHeaders = new Map<String,List<Id>>();
		for(AV_CustomActivityOpportunity__c cao : caoList) {
			if(!relatedHeaderCaoListMap.keySet().contains(cao.AV_Task__c)) {
				relatedHeaderCaoListMap.put(cao.AV_Task__c, new List<AV_CustomActivityOpportunity__c>{cao});
			} else {
				relatedHeaderCaoListMap.get(cao.AV_Task__c).add(cao);
			}
			opposRelatedWithHeaderTsk.put(cao.AV_Task__c,cao.AV_Opportunity__c);
		}
		List<Task> checkonOffTasks = [SELECT RecordTypeId, WhoId, WhatId, Subject, ActivityDate, Status, Priority, OwnerId, Description, ReminderDateTime, IsReminderSet,AV_ALVEN__c, AV_CodigoGestorAsignado__c, AV_NoGestionable__c, AV_Type__c, AV_ExternalID__c, AV_ConVenta__c, AV_Task__c, AV_Tipo__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, AV_OrigenApp__c, AV_BranchPhysicalMeet__c, AV_ColorEtiqueta__c, AV_DurationToNoticeToManager__c, AV_FechaFinAccionComercial__c, AV_Center__c, AV_PrioritizingSort__c, AV_FechaInicioVigencia__c, AV_Chanel__c, AV_PEA__c, AV_Purpose__c, AV_IdDelActaMifid__c, AV_CenterRtIndex__c, AV_PriorityTask__c, AV_AssociatedOpportunityId__c, AV_SurveyValue__c, AV_PEA2__c, AV_OrigenAct__c, AV_VisiblePorElClienteEnNow__c, AV_Case__c,IsClosed FROM Task WHERE AV_Task__c IN :relatedHeaderCaoListMap.keySet() AND AV_OrigenApp__c = :AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF WITH SECURITY_ENFORCED];
		Map<Id,List<Task>> oppTaskMap = new Map<Id,List<Task>>();
		Map<String,Task> headerIdToTask = new Map<String,Task>();
		List<Id> tskToDelete = new List<Id>();
		List<Id> caoToDelete = new List<Id>();
		for(Task ta : checkonOffTasks) {
			if(!ta.IsClosed && !relatedHeaderCaoListMap.get(ta.AV_Task__c).isEmpty()) {
				if(!tskToDelete.contains(ta.Id)) {
					tskToDelete.add(ta.Id);
				}
				response.caoToRestoreBack.addAll(relatedHeaderCaoListMap.get(ta.AV_Task__c));
				response.taskToRestoreBack.add(ta);
				response.taskOpposRelation.put(ta.AV_Task__c,ta.AV_ExternalID__c);
				headerIdToTask.put(ta.AV_Task__c,ta);
			}
		}
		if(!response.caoToRestoreBack.isEmpty()) {
			for(AV_CustomActivityOpportunity__c caoToDel : response.caoToRestoreBack) {
				if(!caoToDelete.contains(caoToDel.Id)) {
					caoToDelete.add(caoToDel.Id);
				}
			}
		}
		if(!opposToInsert.isEmpty()) {
			List<Database.SaveResult> srListInsert = Database.insert(opposToInsert,false);
			Integer indexOfWrap = 0;
			for(Database.SaveResult sr : srListInsert) {
				if(sr.isSuccess()) {
					if(indexOfWrap < srListInsert.size()) {
						wrappedOppsToInsert[indexOfWrap++].put('id',sr.getId());
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
				if(!sr.isSuccess()){
					Database.rollback( sp );
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
		List<AV_CommentsHistory__c> commHistList = new List<AV_CommentsHistory__c>();
		Set<Id> setIds = new Set<Id>();
		for (String outerKey : opposToInsertOrUpdate.keySet()) {
			Map<String, Object> innerMap = opposToInsertOrUpdate.get(outerKey);
			String id = (String)innerMap.get('id');
			setIds.add(id);
		}
		List<Contact> contactList = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c =:UserInfo.getUserId() ];
		for(String oppId : opposToInsertOrUpdate.keySet()) {
			Map<String,Object> wrappedOppo = opposToInsertOrUpdate.get(oppId);
			if(mapOldOpp.get(oppId) == null || (mapOldOpp.get(oppId) != null && (mapOldOpp.get(oppId).AV_Comentarios__c != wrappedOppo.get('comentario') || mapOldOpp.get(oppId).StageName != wrappedOppo.get('newPath')))){
				AV_CommentsHistory__c ch = new AV_CommentsHistory__c();
				String comentario = (String)wrappedOppo.get('comentario');
				ch.AV_NewComment__c = comentario;
				ch.AV_Opportunity__c = (String)wrappedOppo.get('id');
				if(mapOldOpp!=null && mapOldOpp.get(oppId)!= null){
					ch.AV_OldComment__c = (String)mapOldOpp.get(oppId).AV_Comentarios__c;
					ch.AV_OldStatus__c = mapOldOpp.get(oppId).StageName;
				}
				ch.AV_ModificationDate__c = System.today();
				if(contactList != null && !contactList.isEmpty()){
					ch.AV_AssignedEmployee__c = contactList[0].Id;
				}
				ch.AV_OpportunityStatus__c = (String)wrappedOppo.get('newPath');
				ch.AV_Event__c =  eventIdCreated;
				commHistList.add(ch);						
			}
		}
		if(commHistList!= null){
			List<Database.SaveResult> srCommHistList = Database.insert(commHistList,false);
			for(Database.SaveResult ur : srCommHistList){
				if(!ur.isSuccess()) {
					if(response.errorList == null){
						response.errorList = new List<String>();
					}
					response.errorList.add(ur.getErrors()[0].getMessage()); 
				} else {
					listIdsCommentsHistoryInsert.add(ur.getId());
				}
			}
			response.deleteIdCommentsHistoryInsert = listIdsCommentsHistoryInsert;
		}
		if(!caoToDelete.isEmpty()) {
			List<Database.DeleteResult> drCaoDelete = Database.delete(caoToDelete,false);
			for(Database.DeleteResult dr : drCaoDelete){
				if(!dr.isSuccess()) {
					Database.rollback( sp );
					response.errorList = new List<String>();
					for(Database.Error err : dr.getErrors()) {
						String errorStr =  'Error delete cao: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
						response.errorList.add(errorStr);
						AV_LogDebug.printLogDebug(methodName,errorStr);
					}
					return response;
				}
			}
		}
		if(!tskToDelete.isEmpty()) {
			List<Database.DeleteResult> drTaskToDelete = Database.delete(tskToDelete,false);
			for(Database.DeleteResult dr : drTaskToDelete){
				if(!dr.isSuccess()) {
					Database.rollback( sp );
					response.errorList = new List<String>();
					for(Database.Error err : dr.getErrors()) {
						String errorStr =  'Error: Task' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
						response.errorList.add(errorStr);
						AV_LogDebug.printLogDebug(methodName,errorStr);
					}
					return response;
				}
			}
		}
		response.editedOpportunities = opposToInsertOrUpdate;
		return response;
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
	* Delete the create event and the attendes events (The ones that come from EventRelationship records) if a backreport is needed
	@param List<String> recordsToDelete Id's of the record to delete
	@return Wheter Ok or message error if the delete is succesfull or not
	*/
	@AuraEnabled
	public static String backupEventsAndAttendes(List<String> recordsToDelete,String jsonEventToBackReport,Id newRecordFromTaskToDel, String jsonTaskToReOpen,String mmhToDel,String jsonCallBack) {
		String methodName = 'backupEventsAndAttendes';
		String result = 'OK';
		if(recordsToDelete != null && !recordsToDelete.isEmpty()) {
			List<Database.DeleteResult> delRes = Database.delete(recordsToDelete,false);
			for(Database.DeleteResult dr : delRes) {
				if(!dr.isSuccess()) {
					for(Database.Error err : dr.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
					}
					return 'NOK';
				}	
			}
		}
		if(jsonEventToBackReport != null) {
			Event evtToRestore= (Event) JSON.deserialize(jsonEventToBackReport,Event.Class);
			Database.SaveResult sru = Database.update(evtToRestore,false);
			if(!sru.isSuccess()) {
				Database.Error err = sru.getErrors()[0];
				AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
				return 'NOK';
			}
		}
		if(jsonCallBack != null) {
			CC_Llamada__c callToRestore= (CC_Llamada__c) JSON.deserialize(jsonCallBack,CC_Llamada__c.Class);
			Database.SaveResult sru = Database.update(callToRestore,false);
			if(!sru.isSuccess()) {
				Database.Error err = sru.getErrors()[0];
				AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
				return 'NOK';
			}
		}
		if(newRecordFromTaskToDel != null) {
			Database.DeleteResult  dr = Database.delete(newRecordFromTaskToDel,false);
			if(!dr.isSuccess()) {
				Database.Error err = dr.getErrors()[0];
				AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
				return 'NOK';
			}
		}
		if(jsonTaskToReOpen != null) {
			Task tToReOpen = (Task) JSON.deserialize(jsonTaskToReOpen,Task.class);
			Database.SaveResult sru = Database.update(tToReOpen,false);
			if(!sru.isSuccess()) {
				Database.Error err = sru.getErrors()[0];
				AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
				return 'NOK';
			}
			if(mmhToDel != null) {
				Database.DeleteResult dr = Database.delete((Id) mmhToDel,false);
				if(!dr.isSuccess()) {
					Database.Error err = dr.getErrors()[0];
					AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
					return 'NOK';
				}
			}
		}
		return result;
	}

	/**
	* Insert the relations of updated and created opportunities to the created Event
	* @param caosToInsert Pre-made cao object that comes with the opportunity id and the AV_IsMain__c filled
	* @param evtId Created event to relate
	* @return String that is Ok or an error message wheter the insertions are succesful or not
	*/
	@AuraEnabled
	public static String vinculateOpposToTheNewEvent(List<AV_CustomActivityOpportunity__c> caosToInsert,Id evtId) {
		Savepoint sp = Database.setSavepoint();
		String methodName = 'vinculateOpposToTheNewEvent';
		String result = 'OK';
		Id taskId = [SELECT AV_Task__C FROM Event WHERE Id =: evtId  WITH SECURITY_ENFORCED LIMIT 1].AV_Task__c;
		for(AV_CustomActivityOpportunity__c cao :caosToInsert) {
			cao.AV_Task__C = taskId;
			cao.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
		}
		List<Database.SaveResult> srList = Database.insert(caosToInsert,false);
		for(Database.SaveResult sr : srList){
			if(!sr.isSuccess()) {
				for(Database.Error err : sr.getErrors()) {
					AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
				}
				Database.rollback(sp);
				return 'NOK';
			}
		}
		return result;
	}

	/**
	* Deletes created opportunities and restore back the updated opportunities if there is an error in some point of the whole report
	* Restore back the deleted checkOnOff tasks and caos 
	* @param createdIds Id of the created opportunities
	* @param oldOppos Initial states of the opportunities when the report is open. Updated opportunities will be back to this state
	* @param tskToRestore List of the checkOnOff taks in order to restore them back
	* @param caoToRestore Same as the tasks
	* @param entityRelations Map that will relate the externalId from the checkOnOff taks with the old AV_Task__c in order to re-build correct relationships
	*/
	@AuraEnabled
	public static String backReportOppos(List<String> createdIds,List<String> tskCheckOnOffToDel,List<String> caoCheckOnOffToDel, List<Opportunity> oldOppos,List<Task> tskToRestore, List<AV_CustomActivityOpportunity__c> caoToRestore, Map<String,String> entityRelations, List<String> deleteIdCommentsHistoryInsert) {
		String methodName = 'backReportOppos';
		String response = 'OK';
		List<Database.DeleteResult> drList;
		Savepoint sp = Database.setSavepoint();
	
		if(caoCheckOnOffToDel != null && !caoCheckOnOffToDel.isEmpty()) {
			List<Database.DeleteResult> delRes = Database.delete(caoCheckOnOffToDel,false);
			for(Database.DeleteResult del : delRes) {
				if(!del.isSuccess()) {
					response = '';
					for(Database.Error err : del.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
						response += (err.getMessage()+'-');
					}
					return response;
				}
			}
		}
		if(tskCheckOnOffToDel != null && !tskCheckOnOffToDel.isEmpty()) {
			List<Database.DeleteResult> delRes = Database.delete(tskCheckOnOffToDel,false);
			for(Database.DeleteResult del : delRes) {
				if(!del.isSuccess()) {
					response = '';
					for(Database.Error err : del.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
						response += (err.getMessage()+'-');
					}
					return response;
				}
			}
		}
		if(createdIds != null && !createdIds.isEmpty()) {
			drList = Database.delete(createdIds,false);
			for(Database.DeleteResult dr : drList){
				if(!dr.isSuccess()) {
					response = '';
					for(Database.Error err : dr.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
						response += ('Error borrando opos '+err.getMessage()+'-');
					}
					return response;
				}
			}
		}
		if(oldOppos != null && !oldOppos.isEmpty()) {
			List<Database.SaveResult> srList = Database.update(oldOppos,false);
			for(Database.SaveResult sr : srList) {
				if(!sr.isSuccess()) {
					response = '';
					for(Database.Error err : sr.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
						response += (err.getMessage()+'-');
					}
					return response;
				}
			}
		}
		if(tskToRestore != null && !tskToRestore.isEmpty()) {
			for(Task taskBack : tskToRestore) {
				taskBack.Id = null;
				taskBack.AV_Task__c = null;
			}
			List<Database.SaveResult> srInsertTaskList = Database.insert(tskToRestore,false);
			List<Id> restoredTasks = new List<Id>();
			for(Database.SaveResult srT : srInsertTaskList) {
				if(!srT.isSuccess()) {
					Database.rollback(sp);
					for(Database.Error errT : srT.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: taskInsertBack ' + errT.getStatusCode() + ' - ' + errT.getMessage() + '. ' + 'Fields that affected this error: ' + errT.getFields());
						response += (errT.getMessage()+'-');
					}
					return response;
				} else {
					restoredTasks.add(srT.getId());
				}
			}
			List<Task> listTasksForHeaderId = [SELECT AV_ExternalID__c,AV_Task__c,Owner.Name FROM Task WHERE ID IN :restoredTasks WITH SECURITY_ENFORCED];
			Map<String,String> newTaskIdToExternalID = new Map<String,String>();
			for(Task t : listTasksForHeaderId) {
				newTaskIdToExternalID.put(t.AV_ExternalId__c,t.AV_Task__c);
			}
			for(AV_CustomActivityOpportunity__c caoBack : caoToRestore) {
				caoBack.Id = null;
				String sameExternalIDFromOldTask = entityRelations.get(caoBack.AV_Task__c);
				caoBack.AV_Task__c = newTaskIdToExternalID.get(sameExternalIDFromOldTask);
			}
			List<Database.SaveResult> srCaoInsert = Database.insert(caoToRestore,false);
			for(Database.SaveResult srCaoR : srCaoInsert) {
				if(!srCaoR.isSuccess()) {
					Database.rollback(sp);
					for(Database.Error errC : srCaoR.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: caoInsertBack' + errC.getStatusCode() + ' - ' + errC.getMessage() + '. ' + 'Fields that affected this error: ' + errC.getFields());
						response += (errC.getMessage()+'-');
					}
					return response;
				}
			}
		}
		if (deleteIdCommentsHistoryInsert != null && !deleteIdCommentsHistoryInsert.isEmpty()) {
			List<AV_CommentsHistory__c> listCommentHistoryDelete = new List<AV_CommentsHistory__c>();
			for (String idCH : deleteIdCommentsHistoryInsert) {
				listCommentHistoryDelete.add(new AV_CommentsHistory__c(Id=idCH));
			}
			List<Database.DeleteResult> listSrDelete = Database.delete(listCommentHistoryDelete,false);
			for (Database.DeleteResult sr: listSrDelete) {
				if(!sr.isSuccess()) {           
					for(Database.Error err : sr.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
						response += (err.getMessage()+'-');
					}
				}
			}
		}
		return response;
	}

	/**
	* @description     					Procces owners of Opportunity where create a Opportunity type Iniciativa so fill the fields and send to API Oppotunity
	* @param  listIdsOppUpdateCreated  	list of new Opportunity records and update records
	*/
	@AuraEnabled
	public static string sendOppToGCF(List<String> listIdsOppUpdateCreated,String canal) {
		String methodName='sendOppToGCF';
		String result = 'OK';
		if (listIdsOppUpdateCreated != null && !listIdsOppUpdateCreated.isEmpty()) {
			List<Opportunity> listToGcf = new List<Opportunity>();
			List<Opportunity> listOpp = [Select Id, RecordType.DeveloperName, AV_ExternalId__c, AV_IncludeInPrioritizingCustomers__c,AV_FechaProximoRecordatorio__c, StageName, AV_Potencial__c, Amount, CloseDate, AV_Cuota__c, AV_Resolucion__c, AV_AmountEuro__c, AV_Comentarios__c, AV_Tenencia__c, AV_Entidad__c, AV_FechaVencimiento__c,AV_MarginEuro__c, AV_ByProduct__c,AV_Channel__c,OwnerId from Opportunity where Id in :listIdsOppUpdateCreated WITH SECURITY_ENFORCED];  
			List<Opportunity> lstOppToUpdt = new List<Opportunity>(); 

			if (listOpp != null && !listOpp.isEmpty()) {
				for (Opportunity opp : listOpp) {
					opp.AV_Channel__c = canal; 
					lstOppToUpdt.add(opp); 
					if (opp.RecordType.DeveloperName == AV_AppConstants.OPPINICIATIVA_RT) {
						listToGcf.add(opp);
					}
				}
				
				if(lstOppToUpdt!= null && !lstOppToUpdt.isEmpty()){
					List<Database.SaveResult> listSr = Database.update(lstOppToUpdt, false);
					for (Database.SaveResult sr: listSr) {
						if(!sr.isSuccess()) {           
							for(Database.Error err : sr.getErrors()) {
								AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
								
							}
						}
					}
				}
				
				if (listToGcf != null && !listToGcf.isEmpty()) {
					AV_SetFieldsAPIOpp_SyncOpportunity.sendToGCF(json.serialize(listToGcf));
				}else {
					result = 'No se envian a GCF las oportunidades relizadas en esta operación, ya que no hay iniciativa';
				}
			} else {
				result = 'No se envian a GCF las oportunidades relizadas en esta operación, ya que no las encuentra';
			}
		}
		return result;
	}

	@AuraEnabled
	public static String backClosedTaskReport(List<Task> tskToBack,List<String> mmhToDel) {
		String methodName = 'backClosedTaskReport';
		if(tskToBack != null && !tskToBack.isEmpty()) {
			List<Database.SaveResult> updateBack = Database.update(tskToBack,false);
			for(Database.SaveResult sr : updateBack) {
				if(!sr.isSuccess()) {
					String response = '';
					for(Database.Error errC : sr.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: backing closed tasks' + errC.getStatusCode() + ' - ' + errC.getMessage() + '. ' + 'Fields that affected this error: ' + errC.getFields());
						response += ('-'+errC.getMessage());
					}
					return response;
				}
			}
			if(mmhToDel != null && !mmhToDel.isEmpty()) {
				List<AV_ManagementHistory__c> mmhToDelList = new List<AV_ManagementHistory__c>();
				for(String mmhToDelId : mmhToDel) {
					mmhToDelList.add(new AV_ManagementHistory__c(Id = mmhToDelId));
				}
				List<Database.DeleteResult> delMMh = Database.delete(mmhToDelList,false);
				for(Database.DeleteResult sr : delMMh) {
					if(!sr.isSuccess()){
						String response = '';
						for(Database.Error errC : sr.getErrors()) {
							AV_LogDebug.printLogDebug(methodName, 'Error deleting closed tasks mmh' + errC.getStatusCode() + ' - ' + errC.getMessage() + '. ' + 'Fields that affected this error: ' + errC.getFields());
							response += ('-'+errC.getMessage());
						}
						return response;
					}
				}
			}
		}
		return 'OK';
	}

	/**
	 * @description		Method to pass quality clouds
	 */
	private static SObject capsulateQuery(String q,String idToInsert) {	
		String newObjectId = idToInsert;
		return (SObject) Database.query(q);
	}

	@AuraEnabled
	public static Map<String,String> getEmployeeInfo(String contactPlate) {
		List<Contact> contactToRetrieve = [SELECT AV_UsuarioAsociado__c, AV_UsuarioAsociado__r.Name,AV_UsuarioAsociado__r.AV_NumeroOficinaEmpresa__c FROM Contact WHERE CC_Matricula__c = :contactPlate LIMIT 1];
		if(!contactToRetrieve.isEmpty()) {
			return new Map<String,String>{
				'contactId' => contactToRetrieve[0].AV_UsuarioAsociado__c,
				'contactName' => contactToRetrieve[0].AV_UsuarioAsociado__r.Name,
				'contactOfficeNumber' => contactToRetrieve[0].AV_UsuarioAsociado__r.AV_NumeroOficinaEmpresa__c
			};
		}else {
			return new Map<String,String>{'error' => 'El gestor no tiene un contacto asociado.'};
		}
	}

	@AuraEnabled
	public static string getUserTimeZone(){
		return [SELECT TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId()].TimeZoneSidKey;
	}

	@AuraEnabled
	public static String syncWithGcf(String idEvent){
		String result ='OK';
		String methodName = 'syncWithGcf';
		List<Event> listEvent = [SELECT Id, IsRecurrence2, IsRecurrence, WhatId, AV_ExternalId__c, WhoId, AV_Tipo__c, OwnerId, AV_CodigoGestorAsignado__c, AV_origenApp__c, RecordTypeId, AV_BranchPhysicalMeet__c, Location, StartDateTime, EndDateTime, Description, isPrivate, Subject, CSBD_Evento_Estado__c FROM Event WHERE Id = :idEvent];
		if(listEvent!=null && !listEvent.isEmpty()){
			String jsonString = json.serialize(listEvent);
			AV_CitaPrevia_SyncEvents.insertOrUpdateEvent(jsonString, false);
		} else {
			result = 'No se encontraron eventos';
		}
		return result;
	}
}