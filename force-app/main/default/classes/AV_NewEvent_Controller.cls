/**********************************************************************************************************************
 Name:      AV_AppConstants
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora para el componente AV_NewEvent e hijos 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION        USER_STORY       AUTHOR           DATE                Description
   	1.0            US518461         Luis Fernández   06/09/2023          Init version
	1.1			   Fix PMD Errors   Daniel Rodriguez 09/10/2023     	 Add WITH SECURITY_ENFORCED in queries
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
		Integer MAXRESULTS = 10;
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
			LIMIT :MAXRESULTS
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
	public static List<AV_LookupSearchResult> searchEmployees(String searchTerm) {
		Integer MAXRESULTS = 10;
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					User(Id, Name, AV_NumeroOficinaEmpresa__c 
					WHERE IsActive=true and Profile.Name = :AV_AppConstants.AV_PROFILE
					AND Id IN (SELECT AV_UsuarioAsociado__c FROM Contact)
					)
				LIMIT :MAXRESULTS
			];
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
		List<List<SObject>> searchResults = new List<List<SObject>>();
			searchResults = [
			FIND :searchTerm
			IN ALL FIELDS
			RETURNING
				Contact(Id, Name, CC_CargoRepresentante__c WHERE RecordType.DeveloperName= :CIBE_AppConstants.CONTACT_APODERADO_RT and AccountId = :accountId)
			LIMIT 10];
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
				}else {
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
	public static List<AV_LookupSearchResult> searchAttendees(String searchTerm, List<String> selectedIds) {
		Integer MAXRESULTS = 10;
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		
		if(!selectedIds.isEmpty()){
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
				User(Id, Name, AV_NumeroOficinaEmpresa__c WHERE Id NOT IN :selectedIds and IsActive=true and Profile.Name= :AV_AppConstants.AV_PROFILE)
				LIMIT :MAXRESULTS
				];
			}
			else{
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
					User(Id, Name, AV_NumeroOficinaEmpresa__c WHERE IsActive=true and Profile.Name= :AV_AppConstants.AV_PROFILE)
					LIMIT :MAXRESULTS
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
		Integer MAXRESULTS = 10;
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
			LIMIT :MAXRESULTS
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
	 * Given the accoundId of the event client, it return all the retail Rt Opportunities that are
	 * Potential or in En gestión/Insistir stage, and also the ones that are Vencidas and are AV_Iniciativa recordtype.
	 * It orders it by propensity and StageName and returns also the list of products to do not show to this client.
	 * @return OpportunitiesInfo 
	 */

	@AuraEnabled 
	public static OpportunitiesInfo retrieveAccountOpportunities(String accountId){
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
			AV_AppConstants.OPP_STATUS_ENGESTION
		};
		List<Opportunity> associatedOppo = [
			SELECT Id,
			Name,
			StageName,
			AV_FechaProximoRecordatorio__c,
			AV_Potencial__c,
			AV_Comentarios__c,
			AV_Resolucion__c,
			AV_AmountEuro__c,
			AV_MarginEuro__c,
			Amount,
			AV_Tenencia__c,
			AV_Entidad__c,
			AV_Cuota__c,
			AV_ByProduct__c,
			AV_ByProduct__r.Name,
			AV_PF__c,
			AV_Propensity__c,
			CloseDate,
			AV_IncludeInPrioritizingCustomers__c,
			RecordTypeId 
			FROM Opportunity 
			WHERE AccountId = :accountId 
			AND 
				( 
				(RecordType.DeveloperName IN :retailRts AND StageName IN :requiredStages)
					OR
				(RecordType.DeveloperName = :  AV_AppConstants.OPPINICIATIVA_RT AND StageName = :AV_AppConstants.OPP_STATUS_VENCIDO)
				) WITH SECURITY_ENFORCED
				ORDER BY AV_FechaProximoRecordatorio__c DESC NULLS LAST
		];  
		List<OppoWrap> objToSend = new List<OppoWrap>();
		Map<String,List<OppoWrap>> stageOppoMap = new Map<String,List<OppoWrap>>();
		response.productsToNotShow = new List<Id>();
		for(Opportunity opp : associatedOppo){

			if(!response.productsToNotShow.contains(opp.AV_PF__c)){
				response.productsToNotShow.add(opp.AV_PF__c);
			}

			if(stageOppoMap.keySet().contains(opp.StageName)){
				stageOppoMap.get(opp.StageName).add(new OppoWrap(opp));
			}else{
				stageOppoMap.put(opp.StageName,new List<OppoWrap>{ new OppoWrap(opp)});
			}
		}
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_POTENCIAL) != null){
			stageOppoMap.get(AV_AppConstants.OPP_STATUS_POTENCIAL).sort();
		}
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_ENGESTION) != null){
			objToSend.addAll(stageOppoMap.get(AV_AppConstants.OPP_STATUS_ENGESTION));
		}
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_POTENCIAL) != null){
			objToSend.addAll(stageOppoMap.get(AV_AppConstants.OPP_STATUS_POTENCIAL));
		}
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_VENCIDO) != null){
			objToSend.addAll(stageOppoMap.get(AV_AppConstants.OPP_STATUS_VENCIDO));
		}

		response.clientOppos = objToSend;
		requiredStages.addAll(new Set<String>{
			AV_AppConstants.OPP_STATUS_NOAPTO,
			AV_AppConstants.OPP_STATUS_VENCIDO

		});
		List<Opportunity> listOppForProdutsToNotShow = [SELECT AV_PF__c FROM Opportunity 
		WHERE AccountId = :accountId 
		AND (StageName  IN :requiredStages AND RecordType.DeveloperName IN :retailRts) WITH SECURITY_ENFORCED]; 
		for(Opportunity opp : listOppForProdutsToNotShow){
			if(!response.productsToNotShow.contains(opp.AV_PF__c)){
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
		for(Schema.PicklistEntry pickListVal : ple){
			listPicklist.add(new Map<String, String>{
				'label' =>pickListVal.getLabel(), 
				'value' => String.valueOf(pickListVal.getValue())});
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
		Integer MAXRESULTS = 10;
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		if(!selectedIds.isEmpty()){
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
				Product2(Id, Name, AV_ExternalID__c WHERE Id NOT IN :selectedIds and RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true)
				LIMIT :MAXRESULTS
			];
		}
		else{
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Product2(Id, Name, AV_ExternalID__c WHERE RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true)
				LIMIT :MAXRESULTS
			];
		}
		String productIcon = 'standard:product';
		Product2[] listProduct = (List<Product2>) searchResults[0];
		for (Product2 p : listProduct) {
			results.add(
				new AV_LookupSearchResult(
					p.Id,'Product2',productIcon,p.Name,'Codigo • ' + p.AV_ExternalID__c
				)
			);
		}
		results.sort();
		return results;
	}

	/**
	 * It inserts on the database the event with the information specified on the lwc
	 * @param String evt Pre-made Event object 
	 * @return A string that its OK if the insert is succesfuls and a error message if is not succesful
	 */
	@AuraEnabled
	public static String createEvent(Event evt) {
		Savepoint sp = Database.setSavepoint();
		String methodName = 'createEvent';
		String response = 'OK';
		evt.AV_OrigenApp__c = AV_AppConstants.SALESFORCE_ORIGENAPP;
		evt.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT,AV_AppConstants.EVENTCLIENTE_RT).Id;
		evt.CSBD_Evento_Estado__c = AV_AppConstants.EVENT_STATUS_PENDIENTE;

		Database.SaveResult sr = Database.insert(evt,false);

		if(sr.isSuccess()){
			response = sr.getId();
		}else{
			Database.Error err = sr.getErrors()[0];
			response = 'Fail-'+err.getMessage(); 
			AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());

			Database.rollback( sp );
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
	 public static List<String> createEventRelation(Id eventId,List<String> attendes){
		String methodName = 'createEventRelation';
		List<String> result = new List<String>();
		Savepoint sp = Database.setSavepoint();
		List<EventRelation> evtRelList = new List<EventRelation>();

		if(attendes != null && !attendes.isEmpty()){

			for(Id att : attendes){
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

		for(Database.SaveResult sr : srList){
			if(!sr.isSuccess()){
				if(!result.isEmpty()){
					result.clear();
				}
				result.add('Fail');
				for(Database.Error err : sr.getErrors()){
					result.add(err.getMessage());
					AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
				}
				Database.rollback(sp);
				break;
			}else{
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
	 
	 private static Date parseDate(String dateString){
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
		public List<AV_CustomActivityOpportunity__c> caoToRestoreBack = new List<AV_CustomActivityOpportunity__c>();
		@AuraEnabled
		public Map<String,String> taskOpposRelation = new Map<String,String>();
		}

	/**
	 * Create and update the opportunities edited on the component. It deletes too the checkOnOff tasks related to the updated opportunities.
	 * Deletes the AV_CustomActivityOpportunity__c records too
	 * @param Map<String,Map<String,Object>> newOppos => Object that contains updated and inserted oppos
	 * @param String accoundId Id from the event client that is being created
	 * @CreatedOpportunitiesWrapper Wrapped response
	 */

	 @AuraEnabled
	 public static CreatedOpportunitiesWrapper createOpportunities(Map<String,Map<String,Object>> newOppos,String accountId){
		String methodName = 'createOpportunities';
		CreatedOpportunitiesWrapper response = new CreatedOpportunitiesWrapper();

		Savepoint sp = Database.setSavepoint();

		Id iniciativaRt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY,AV_AppConstants.OPPINICIATIVA_RT).Id;
		
		List<Map<String,Object>> wrappedOppsToInsert = new List<Map<String,Object>>();
		List<Map<String,Object>> wrappedOppsToUpdate = new List<Map<String,Object>>();

		List<Opportunity> opposToInsert = new List<Opportunity>();		
		List<Opportunity> opposToUpdate = new List<Opportunity>();
		Map<String,String> opposRelatedWithHeaderTsk = new Map<String,String>();
		Map<String,Opportunity> opposUpdatedMap = new Map<String,Opportunity>();
		Map<String,List<AV_CustomActivityOpportunity__c>> relatedHeaderCaoListMap = new Map<String,List<AV_CustomActivityOpportunity__c>>();
		// Map<Task,List<OppoWrap>> taskWithOpposMap = new Map<Task,List<OppoWrap>>(); 
		Set<Id> caoCheckOnOffToDelete = new Set<Id>();
		Set<Id> tskCheckOnOffToDelete = new Set<Id>();
		Map<String,String> tskToHeaderMap = new Map<String,String>();
		// Map<String,Map<String,Object>> errorListInMap = new Map<String,Map<String,Object>>{'Fail' => new Map<String,Object>()};
		Set<String> opposToCleanCheckOnOff = new Set<String>();
		for(String objId : newOppos.keySet()){

			if(objId.contains('idProvisional')){
				wrappedOppsToInsert.add(newOppos.get(objId));
			}else{
				wrappedOppsToUpdate.add(newOppos.get(objId));

				if( (Boolean) (newOppos.get(objId).get('priorizado'))){
					opposToCleanCheckOnOff.add(objId);
				}
			}	


		}

		if(!wrappedOppsToInsert.isEmpty()){
			opposToInsert = unWrappOppos(wrappedOppsToInsert,iniciativaRt,accountId);
		}

		if(!wrappedOppsToUpdate.isEmpty()){
			opposToUpdate = unWrappOppos(wrappedOppsToUpdate,iniciativaRt,accountId);
			for(Opportunity opp :  opposToUpdate){
				opposUpdatedMap.put(opp.Id,opp);
			}
		}

	

		//Buscamos las tareas del checkonOff para borrarlas y guardarlas para el back

		Set<Id> relatedCaoId = new Set<Id>();

		List<AV_CustomActivityOpportunity__c> caoList = [SELECT OwnerId, RecordTypeId, AV_ExternalID__c, AV_Opportunity__c,
		 AV_Task__c, AV_OrigenApp__c, AV_Amount__c, AV_Commentary__c, AV_Concepto1__c, AV_Concepto2__c, AV_Concepto3__c, 
		 AV_Concepto4__c, AV_Concepto5__c, AV_DischargeDate__c, AV_DueDate__c, AV_Entity__c, AV_FeeAmount__c, AV_Gestor__c, 
		 AV_HoldingAnotherEntity__c, AV_IsMain__c, AV_NextEventDate__c, AV_Priority__c, AV_Product__c, AV_ReviewDate__c, 
		 AV_Stage__c, AV_TypeOfInterest__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, 
		 AV_WarningDate__c, AV_LicensePlate__c, AV_IncludeInPrioritizingCustomers__c, AV_FechaVencimiento__c, 
		 AV_ActivityDate__c, AV_Status__c, AV_Resolucion__c, AV_Channel__c, AV_AmountEuro__c, AV_ByProduct__c, 
		 AV_MarginEuro__c 

		 FROM AV_CustomActivityOpportunity__c 
		 WHERE AV_Opportunity__c IN :opposToCleanCheckOnOff
		 AND AV_Task__c != NULL
		 WITH SECURITY_ENFORCED];

		Map<String,List<Id>> opportunityToHeaders = new Map<String,List<Id>>();

		for(AV_CustomActivityOpportunity__c cao : caoList){
			// caoCheckOnOffToDelete.add(cao.Id);
			if(!relatedHeaderCaoListMap.keySet().contains(cao.AV_Task__c)){
				relatedHeaderCaoListMap.put(cao.AV_Task__c, new List<AV_CustomActivityOpportunity__c>{cao});
			}else{
				relatedHeaderCaoListMap.get(cao.AV_Task__c).add(cao);
			}

			opposRelatedWithHeaderTsk.put(cao.AV_Task__c,cao.AV_Opportunity__c);

		}

		List<Task> checkonOffTasks = [SELECT 

		RecordTypeId, WhoId, WhatId, Subject, ActivityDate, Status, Priority, OwnerId, 
		Description, ReminderDateTime, IsReminderSet,AV_ALVEN__c,
		AV_CodigoGestorAsignado__c, AV_Concepto1__c, AV_Concepto2__c, 
		AV_NoGestionable__c, AV_Type__c, AV_ExternalID__c, AV_ConVenta__c,
		AV_Task__c, AV_Tipo__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c,
		AV_Valor4__c, AV_Valor5__c, AV_OrigenApp__c, AV_BranchPhysicalMeet__c, 
		AV_ColorEtiqueta__c, AV_DurationToNoticeToManager__c, AV_FechaFinAccionComercial__c, 
		AV_Center__c, AV_PrioritizingSort__c, AV_FechaInicioVigencia__c, AV_Chanel__c, AV_PEA__c, 
		AV_Purpose__c, AV_IdDelActaMifid__c, AV_CenterRtIndex__c, 
		AV_UrlsQR__c, AV_PriorityTask__c, AV_AssociatedOpportunityId__c, 
		AV_SurveyValue__c, AV_PEA2__c, AV_OrigenAct__c, 
		AV_VisiblePorElClienteEnNow__c, AV_Case__c,IsClosed

		FROM Task
		WHERE AV_Task__c IN :relatedHeaderCaoListMap.keySet() 
		AND AV_OrigenApp__c = :AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF WITH SECURITY_ENFORCED];

		Map<Id,List<Task>> oppTaskMap = new Map<Id,List<Task>>();
		Map<String,Task> headerIdToTask = new Map<String,Task>();
		List<Id> tskToDelete = new List<Id>();
		List<Id> caoToDelete = new List<Id>();
		for(Task ta : checkonOffTasks){
			if(!ta.IsClosed && !relatedHeaderCaoListMap.get(ta.AV_Task__c).isEmpty()){
				// caoToDelete.addAll(relatedHeaderCaoListMap.get(ta.AV_Task__c));
				if(!tskToDelete.contains(ta.Id)){
					tskToDelete.add(ta.Id);
				}
				response.caoToRestoreBack.addAll(relatedHeaderCaoListMap.get(ta.AV_Task__c));
				response.taskToRestoreBack.add(ta);
				response.taskOpposRelation.put(ta.AV_Task__c,ta.AV_ExternalID__c);
				headerIdToTask.put(ta.AV_Task__c,ta);

				}
			}

		if(!response.caoToRestoreBack.isEmpty()){
			for(AV_CustomActivityOpportunity__c caoToDel : response.caoToRestoreBack){
				if(!caoToDelete.contains(caoToDel.Id)){
					caoToDelete.add(caoToDel.Id);
				}
			}
		}

		if(!opposToInsert.isEmpty()){

			List<Database.SaveResult> srListInsert = Database.insert(opposToInsert,false);
			
			Integer indexOfWrap = 0;
			for(Database.SaveResult sr : srListInsert){
				if(sr.isSuccess()){
					if(indexOfWrap < srListInsert.size()){
						wrappedOppsToInsert[indexOfWrap++].put('id',sr.getId());
					}
				}else{
					response.errorList = new List<String>();
					Database.rollback(sp);
					for(Database.Error err : sr.getErrors()){
						String errorStr =  'Error insert: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
						response.errorList.add(errorStr);
						// errorListInMap.put(err.getMessage(), new Map<String,Object>());
						AV_LogDebug.printLogDebug(methodName,errorStr);
					}
					return response;
				}
			}
		}
		
		if(!opposToUpdate.isEmpty()){
			
			List<Database.SaveResult> srListUpdate = Database.update(opposToUpdate,false);
			Set<Id> debugSet = new Set<Id>();
			for(Database.SaveResult sr : srListUpdate){
				if(!sr.isSuccess()){
					Database.rollback( sp );
					response.errorList = new List<String>();
					for(Database.Error err : sr.getErrors()){
						String errorStr =  'Error update: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
						response.errorList.add(errorStr);
						// errorListInMap.put(err.getMessage(), new Map<String,Object>());
						AV_LogDebug.printLogDebug(methodName,errorStr);
					}
					return response;
					
				}
			}
	
		}

		if(!caoToDelete.isEmpty()){
			List<Database.DeleteResult> drCaoDelete = Database.delete(caoToDelete,false);

			for(Database.DeleteResult dr : drCaoDelete){
				if(!dr.isSuccess()){
					Database.rollback( sp );
					response.errorList = new List<String>();
					for(Database.Error err : dr.getErrors()){

						String errorStr =  'Error delete cao: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
						response.errorList.add(errorStr);
						// errorListInMap.put(err.getMessage(), new Map<String,Object>());
						AV_LogDebug.printLogDebug(methodName,errorStr);
					}

					return response;
				}
			}
		}

		if(!tskToDelete.isEmpty()){
			List<Database.DeleteResult> drTaskToDelete = Database.delete(tskToDelete,false);

			for(Database.DeleteResult dr : drTaskToDelete){
				if(!dr.isSuccess()){
					Database.rollback( sp );
					response.errorList = new List<String>();
					for(Database.Error err : dr.getErrors()){

						String errorStr =  'Error: Task' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
						response.errorList.add(errorStr);
						// errorListInMap.put(err.getMessage(), new Map<String,Object>());
						AV_LogDebug.printLogDebug(methodName,errorStr);
					}

					return response;
				}
			}
		}
		response.editedOpportunities = newOppos;
		return response;
			
		}
		
	/** 
	* Private method that return wrapped opportunities to Opportunity record
	* @param oppoWrappedList 
	* @param accountId
	*/
	 private static List<Opportunity> unWrappOppos(List<Map<String,Object>> oppoWrappedList,Id iniciativaRt,String accountId){

		List<Opportunity> opposToInsert = new List<Opportunity>();
		
		for(Map<String,Object> wrappedOppo : oppoWrappedList){
			Opportunity nextOpp = new Opportunity();
			nextOpp.StageName = (String) wrappedOppo.get('newPath');
			nextOpp.Name = (String) wrappedOppo.get('Name');
			nextOpp.AV_PF__c = (String) wrappedOppo.get('ProdId');
			nextOpp.AccountId = accountId;
			nextOpp.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
			nextOpp.AV_IncludeInPrioritizingCustomers__c = false;
			
			if( (String) wrappedOppo.get('proximaGestion') != null ){
				nextOpp.AV_FechaProximoRecordatorio__c =  parseDate( (String) wrappedOppo.get('proximaGestion'));
			}


			if( !(((String) wrappedOppo.get('id')).contains('idProvisional'))){
				nextOpp.Id =(Id) wrappedOppo.get('id');
				nextOpp.RecordTypeId = (Id) wrappedOppo.get('recordtype');
				// nextOpp.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
			}else{
				nextOpp.RecordTypeId = iniciativaRt;
			}

			
			if( (String) wrappedOppo.get('comentario') != null){
				nextOpp.AV_Comentarios__c =  (String) wrappedOppo.get('comentario');
			}
			
			if( (String) wrappedOppo.get('expectativa') != null){
				nextOpp.AV_Potencial__c =  (String) wrappedOppo.get('expectativa');
			}
			
			if(wrappedOppo.get('importe') != null) {
				nextOpp.AV_AmountEuro__c = Decimal.valueOf(((String)wrappedOppo.get('importe')).replace(',', '.'));
			}
			
			if( (String) wrappedOppo.get('cuota') != null){
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
	 public static String backupEventsAndAttendes(List<String> recordsToDelete){

		String methodName = 'backupEventsAndAttendes';
		String result = 'OK';
		if(!recordsToDelete.isEmpty()){

			List<Database.DeleteResult> delRes = Database.delete(recordsToDelete,false);
			
			for(Database.DeleteResult dr : delRes){
			if(!dr.isSuccess()){
				for(Database.Error err : dr.getErrors()){
					AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
				}

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
	 public static String vinculateOpposToTheNewEvent(List<AV_CustomActivityOpportunity__c> caosToInsert,Id evtId){
		Savepoint sp = Database.setSavepoint();
		String methodName = 'vinculateOpposToTheNewEvent';
		String result = 'OK';
		Id taskId = [SELECT AV_Task__C FROM Event WHERE Id =: evtId LIMIT 1].AV_Task__c;

		for(AV_CustomActivityOpportunity__c cao :caosToInsert){
			cao.AV_Task__C = taskId;
			cao.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
			
		}
		
		List<Database.SaveResult> srList = Database.insert(caosToInsert,false);

		for(Database.SaveResult sr : srList){
			if(!sr.isSuccess()){
				for(Database.Error err : sr.getErrors()){
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
	 public static String backReportOppos(List<String> createdIds,
	 List<Opportunity> oldOppos,List<Task> tskToRestore, List<AV_CustomActivityOpportunity__c> caoToRestore,
	 Map<String,String> entityRelations){
		String methodName = 'backReportOppos';
		String response = 'OK';

		List<Database.DeleteResult> drList;
		Savepoint sp = Database.setSavepoint();
		if(createdIds != null && !createdIds.isEmpty()){
			drList = Database.delete(createdIds,false);
			for(Database.DeleteResult dr : drList){
				if(!dr.isSuccess()){
					response = '';
					for(Database.Error err : dr.getErrors()){
						AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
						response += (err.getMessage()+'-');
					}
					
					return response;
				}
			}
		}
			
		if(oldOppos != null && !oldOppos.isEmpty()){

			List<Database.SaveResult> srList = Database.update(oldOppos,false);
			
			for(Database.SaveResult sr : srList){
			if(!sr.isSuccess()){
				response = '';
				for(Database.Error err : sr.getErrors()){
					AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
					response += (err.getMessage()+'-');
				}
				
				return response;
			}
		}
		
	}

		if(tskToRestore != null && !tskToRestore.isEmpty()){

			for(Task taskBack : tskToRestore){

				taskBack.Id = null;
				taskBack.AV_Task__c = null;
			}

			
			List<Database.SaveResult> srInsertTaskList = Database.insert(tskToRestore,false);
			List<Id> restoredTasks = new List<Id>();
			for(Database.SaveResult srT : srInsertTaskList){
				if(!srT.isSuccess()){
					Database.rollback(sp);
					for(Database.Error errT : srT.getErrors()){
						AV_LogDebug.printLogDebug(methodName, 'Error: taskInsertBack ' + errT.getStatusCode() + ' - ' + errT.getMessage() + '. ' + 'Fields that affected this error: ' + errT.getFields());
						response += (errT.getMessage()+'-');
					}
					return response;

				}else{
					restoredTasks.add(srT.getId());
				}
			}
			List<Task> listTasksForHeaderId = [SELECT AV_ExternalID__c,AV_Task__c,Owner.Name FROM Task WHERE ID IN :restoredTasks];
			Map<String,String> newTaskIdToExternalID = new Map<String,String>();
			for(Task t : listTasksForHeaderId){
				newTaskIdToExternalID.put(t.AV_ExternalId__c,t.AV_Task__c);
			}
			for(AV_CustomActivityOpportunity__c caoBack : caoToRestore){
				caoBack.Id = null;
				String sameExternalIDFromOldTask = entityRelations.get(caoBack.AV_Task__c);
				caoBack.AV_Task__c = newTaskIdToExternalID.get(sameExternalIDFromOldTask);
				
			}

			List<Database.SaveResult> srCaoInsert = Database.insert(caoToRestore,false);

			for(Database.SaveResult srCaoR : srCaoInsert){

				if(!srCaoR.isSuccess()){
					Database.rollback(sp);
					for(Database.Error errC : srCaoR.getErrors()){
						AV_LogDebug.printLogDebug(methodName, 'Error: caoInsertBack' + errC.getStatusCode() + ' - ' + errC.getMessage() + '. ' + 'Fields that affected this error: ' + errC.getFields());
						response += (errC.getMessage()+'-');
					}
					return response;
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
	public static string sendOppToGCF(List<String> listIdsOppUpdateCreated){
		String result = 'OK';
		if (listIdsOppUpdateCreated != null && !listIdsOppUpdateCreated.isEmpty()) {
			List<Opportunity> listToGcf = new List<Opportunity>();
			List<Opportunity> listOpp = [Select Id, RecordType.DeveloperName, AV_ExternalId__c, AV_IncludeInPrioritizingCustomers__c,AV_FechaProximoRecordatorio__c, StageName, AV_Potencial__c, Amount, CloseDate, AV_Cuota__c, AV_Resolucion__c, AV_AmountEuro__c, AV_Comentarios__c, AV_Tenencia__c, AV_Entidad__c, AV_FechaVencimiento__c,AV_MarginEuro__c, AV_ByProduct__c from Opportunity where Id in :listIdsOppUpdateCreated];
			if (listOpp != null && !listOpp.isEmpty()) {
				for (Opportunity opp : listOpp) {
					if (opp.RecordType.DeveloperName == AV_AppConstants.OPPINICIATIVA_RT) {
						listToGcf.add(opp);
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

}