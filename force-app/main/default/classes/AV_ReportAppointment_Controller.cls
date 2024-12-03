/********************************************************************************************************************
 Name:    AV_ReportAppointment_Controller
 Copyright © 2023  CaixaBank
--------------------------------------------------------------------------------------------------------------------
 Proposito: Gives support to av_ReportAppointment LWC and child components.
	*av_ContactBlockAppointment
	*av_OpportunityBlockAppointment
	*av_TaskBlockAppointment
	*av_DetailOpportunityAppointment
---------------------------------------------------------------------------------------------------------------------
 Historial
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 VERSION        USER_STORY          AUTHOR              DATE            Description
 1.0            US546892            Luis Fernandez      30/06/2023      Init version.
 1.1            US546892            Sandra Gómez        01/09/2023      Modified all logica
 1.2            Fix PMD Errors      Daniel Rodriguez    05/10/2023      Add WITH SECURITY_ENFORCED in queries and modify method createTaskOpp, unWrappOpportunities
 1.3            DE87954             Sandra Gómez        23/11/2023      Change method retrieveAccountTask add parameter recordId
 1.4            --                  Oscar Moreno        15/01/2024      Modify processReportData method. The users dont enter with the PS AV_OpportunitiesSearcherV2
 1.5            Fix subject         Sandra Gómez        12/02/2024      Change field AV_Product__c to AV_ProductName__c in object OppoWrap
 1.6            US824057            Ángel Medina        22/02/2024      Add RT Iniciativa Gestor and Alerta Comercial in method retrieveAccountTask
 1.7            US796361            Oscar Moreno        12/03/2024      Modify processReportData method to create AV_CommentsHistory__c records
  1.8           IN1136424           Oscar Moreno        24/04/2024      Add a new second parameter with the value of AV_Tipo__c in sendOppToGCF method
 1.9			PPM100205278 		Luis Fernández		02/05/2024		Added new propoerty to retrieved opportunities: Product2.AV_NewReportActions__c. Added thisfield to the lookup retrieve methods
 2.0            US912532            Oscar Moreno        23/05/2024      Added isNoLocalizado parameter in unwrappOpportunity and createRecord methods
 2.1            US913185            Oscar Moreno        04/06/2024      Change processReportData method. Only users with AV_CheckOnOff PS will be able to create tasks check on/off
 2.2            PPM100130465        Oscar Moreno     05/07/2024          Replace PS_CHECKONOFF with PS_OLDHOMETASK and revert logic
 2.3            PPM100265806        Oscar Moreno        12/09/2024       Add the owneridopp attribute to OppoWrap class and add getUserInfo method
 *********************************************************************************************************************/
public with sharing class AV_ReportAppointment_Controller{

	private final static Integer MAXRESULTS     = 10;
	
	/**
	 * To result of insert or update of Opportunity
	 */
	public class OppResulWrap {
		@AuraEnabled 
		public Map<String,Opportunity> mapOldOpp;
		@AuraEnabled 
		public List<String> opposId;
		@AuraEnabled 
		public String results;
	}

	/**
	 * Inner class in order to simplify the attribute names and the weight of the Opportunity objects that will be send to the LWC
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
		public String ProductName;
		@AuraEnabled 
		public Boolean Prioritzed;
		@AuraEnabled
		public String HistoryComment = '';
		@AuraEnabled 
		public Boolean IsNewProduct; 
		@AuraEnabled 
		public String Subestado; 
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
			  this.ProductName = oppo.AV_ProductName__c;
			  this.Prioritzed = oppo.AV_IncludeInPrioritizingCustomers__c;
			  this.IsNewProduct = oppo.AV_PF__r.AV_NewReportActions__c;
			  this.Subestado = oppo.AV_Subestado__c; 
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
	 * To result of task block with priorizador and avisos
	 */
	public class TaskBlockResult{
		@AuraEnabled 
		public List<Task> updateTaskUpdated;
		@AuraEnabled 
		public List<String> deleteManageHistInsert;
		@AuraEnabled 
		public String results;
	}

	private static String formatDateForHistoryComment(String lastDate){
		String dateParsed = lastDate.substring(0,10);
		String[] dateAtomized = dateParsed.split(AV_AppConstants.DASH);

		return dateAtomized[2]+'/'+dateAtomized[1]+'/'+dateAtomized[0];
	}

	/**
	 * To result of insert, update or delete of Task/Event
	 * allResult.listTaskChangeDate = listTaskChangeDate;
		allResult.listTaskToDelete = listTaskToDelete;
		allReseul.listTaskOpportunityDelete = listTaskOpportunityDelete;
	 */
	public class TaskEventResult{
		@AuraEnabled 
		public Map<Id,TaskEvent> headerActivitys;
		@AuraEnabled 
		public Map<String,String> mapProducNameId;
		@AuraEnabled 
		public Map<String,String> mapProducIdOpp;
		@AuraEnabled 
		public Map<String,Map<Object,Object>> opportunities;
		@AuraEnabled 
		public String results;
		@AuraEnabled 
		public List<Task> listTaskChangeDate;
		@AuraEnabled 
		public List<Task> listTaskToDelete;
		@AuraEnabled 
		public List<AV_CustomActivityOpportunity__c> listTaskOpportunityDelete;
		@AuraEnabled
		public TaskEventBack dataBack;
	}

	/**
	 * Get data to TaskOpportunity
	 */
	public class TaskEventGet{
		@AuraEnabled 
		public Map<Id,TaskEvent> headerActivitys;
		@AuraEnabled 
		public Map<String,String> mapProducNameId;
		@AuraEnabled 
		public Map<String,String> mapProducIdOpp;
		@AuraEnabled 
		public Map<String,Map<String,String>> opportunities;
		@AuraEnabled 
		public String results;
		@AuraEnabled 
		public List<Task> listTaskChangeDate;
		@AuraEnabled 
		public List<Task> listTaskToDelete;
		@AuraEnabled 
		public List<AV_CustomActivityOpportunity__c> listTaskOpportunityDelete;
		@AuraEnabled
		public TaskEventBack dataBack;
	}

	/**
	 * To result of headerActivitys
	 */
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

	/**
	 * To backReport of Task/Event
	 */
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
	 * Inner class that simplify relevant info for Task object and sent it to the LWC
	 */
	public class TaskWrapp{
		@AuraEnabled 
		public String Id;
		@AuraEnabled 
		public String Subject;
		@AuraEnabled 
		public String Status;
		@AuraEnabled 
		public String Origen;
		@AuraEnabled 
		public Date Fecha;
		@AuraEnabled 
		public String Tipo;
		@AuraEnabled 
		public String Canal;
		@AuraEnabled 
		public String Owner;
		
		public TaskWrapp(Task tsk){
			this.Id = tsk.Id;
			this.Subject = tsk.Subject;
			this.Status = tsk.Status;
			this.Origen = tsk.AV_Origen__c;
			this.Fecha = tsk.ActivityDate;
			this.Owner = tsk.OwnerId; 
		}
	}

	/**
	 * Retrieves the opportunities associated to the account and send it wrapped on an inner class.
	 * After retriving the oppos, it sorts it by status and propensity
	 */
	@AuraEnabled
	public static List<OppoWrap> retrieveAccountOpportunities(String accountId){
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
		List<Opportunity> associatedOppo = [SELECT Id,Name,StageName,AV_FechaProximoRecordatorio__c,AV_Potencial__c,AV_Comentarios__c,AV_Resolucion__c,AV_AmountEuro__c,AV_MarginEuro__c,Amount,AV_Tenencia__c,AV_Entidad__c,AV_Cuota__c,AV_ByProduct__c,AV_ByProduct__r.Name,AV_PF__c,AV_Propensity__c,CloseDate,AV_Product__c,AV_ProductName__c,AV_IncludeInPrioritizingCustomers__c,AV_Channel__c,AV_PF__r.AV_NewReportActions__c,AV_Subestado__c,OwnerId FROM Opportunity WHERE AccountId = :accountId AND (RecordType.DeveloperName IN :retailRts AND StageName IN :requiredStages)WITH SECURITY_ENFORCED ORDER BY AV_FechaProximoRecordatorio__c DESC NULLS LAST];  
		List<OppoWrap> objToSend = new List<OppoWrap>();
		Set<Id> retrievedOppos = new Set<Id>();
		for(Opportunity oppId : associatedOppo){
			retrievedOppos.add(oppId.Id);
		}
		Map<String,List<OppoWrap>> stageOppoMap = new Map<String,List<OppoWrap>>();
		List<AV_CommentsHistory__c> comentaryList = [SELECT AV_Opportunity__c,AV_NewComment__c,LastModifiedDate FROM AV_CommentsHistory__c WHERE AV_Opportunity__c IN :retrievedOppos AND AV_Opportunity__c != null ORDER BY AV_Opportunity__c, LastModifiedDate DESC];
		Map<Id,String> commentOppo = new Map<Id,String>();
		for(AV_CommentsHistory__c cmm : comentaryList){
			if(!commentOppo.keySet().contains(cmm.AV_Opportunity__c)  && !String.isBlank(cmm.AV_NewComment__c)/*&& !restrictedComments.contains(cmm.AV_Opportunity__c)*/){
				commentOppo.put(cmm.AV_Opportunity__c,formatDateForHistoryComment( String.valueOf(cmm.LastModifiedDate))+'{|}'+cmm.AV_NewComment__c);
			}
		}
		for(Opportunity opp : associatedOppo){
			OppoWrap nextOppoWrap = new OppoWrap(opp);
			if(commentOppo.keySet().contains(opp.Id)){
				nextOppoWrap.HistoryComment = commentOppo.get(opp.Id);
			}
			if(stageOppoMap.keySet().contains(opp.StageName)){
				stageOppoMap.get(opp.StageName).add(nextOppoWrap);
			}else{
				stageOppoMap.put(opp.StageName,new List<OppoWrap>{ nextOppoWrap});
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
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_NO_GESTIONADA) != null){
			objToSend.addAll(stageOppoMap.get(AV_AppConstants.OPP_STATUS_NO_GESTIONADA));
		}
		return objToSend;
	}
	
	/**
	 * @description         Return a list of AV_Potencial__C picklistValues
	 * @param fields        List of fields to get values of picklist field
	 * @return              List of values with label and value of picklist
	 */
	@AuraEnabled(cacheable=true)
	public static List<List<Map<String, String>>> getPicklistValues(String[] fields) {
		List<List<Map<String, String>>> result = new List<List<Map<String, String>>>();
		String objectName = AV_AppConstants.OBJECT_NAME_OPPORTUNITY;
		String potentialField = AV_AppConstants.OPPO_POTENCIAL_FIELD;
		for(String fieldApiName : fields){
			List<Map<String, String>> listPicklist = new List<Map<String, String>>();
			// Get the describe for the object
			DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
			// Get the field dynamically
			DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldApiName).getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			if(fieldApiName.equals(potentialField)){
				for(Schema.PicklistEntry pickListVal : ple){
					listPicklist.add(new Map<String, String>{'label' =>pickListVal.getLabel(), 'value' => String.valueOf(pickListVal.getValue())});
				}
			}else{
				for(Schema.PicklistEntry pickListVal : ple){
					listPicklist.add(new Map<String, String>{'label' => String.valueOf(pickListVal.getLabel()), 'value' => String.valueOf(pickListVal.getValue())});
				}
			}
			result.add(listPicklist);
		}
		return result;
	}

	/**
	 * @description         Given a account Id, returns all the tasks which
	 * @param accountId     Id of account to filter in query
	 * @return              List tasks to show component
	 */
	@AuraEnabled
	public static List<TaskWrapp> retrieveAccountTask(String accountId, String recordId){
		Set<String> taskRt = new Set<String>{
			AV_AppConstants.TASKAVISOS_RT,
			AV_AppConstants.TASKPRIORIZADOR_RT,
            AV_AppConstants.TASKINICIATIVA_RT,
            AV_AppConstants.TASKALERTACOM_RT
		};
		Set<String> requiredStatus = new Set<String>{
			AV_AppConstants.TASK_STATUS_PENDIENTE,
			AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL
		};
		List<Task> retriTask;
		if (recordId!= null) {
			retriTask = [SELECT Id,Subject,AV_Origen__c,Status, ActivityDate,AV_Tipo__c,AV_Chanel__c,OwnerId FROM TASK WHERE AccountId = :accountId AND RecordType.DeveloperName IN :taskRt AND Id != :recordId AND Status IN :requiredStatus  WITH SECURITY_ENFORCED ORDER BY ActivityDate ASC];
		} else {
			retriTask = [SELECT Id,Subject,AV_Origen__c,Status, ActivityDate,AV_Tipo__c,AV_Chanel__c,OwnerId FROM TASK WHERE AccountId = :accountId AND RecordType.DeveloperName IN :taskRt AND Status IN :requiredStatus  WITH SECURITY_ENFORCED ORDER BY ActivityDate ASC];
		}
		List<TaskWrapp> tskToReturn = new List<TaskWrapp>();
		for(Task t : retriTask){
			tskToReturn.add(new TaskWrapp(t));
		}
		return tskToReturn;
	}

	/**
	 * @description     Lookup of Sub product
	 */
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchByProduct(String searchTerm,String product) {  
		Integer MAXRESULTS = 10;
		String methodName = 'searchByProduct';
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		searchResults = [
			FIND :searchTerm
				IN ALL FIELDS
				RETURNING
				Product2(Id, Name, AV_ExternalID__c, AV_Nivel__c, AV_NombrePF__c, AV_NombrePF__r.AV_ExternalID__c, AV_NombrePF__r.AV_Nivel__c, AV_NombrePF__r.AV_NombrePF__c, AV_NombrePF__r.AV_NombrePF__r.AV_ExternalID__c, AV_NombrePF__r.AV_NombrePF__r.Name WHERE  RecordType.DeveloperName = 'AV_Producto' and AV_Sale__c = true and AV_Nivel__c='10' and AV_ExternalID__c!=null and (AV_NombrePF__r.AV_NombrePF__c =: product or AV_NombrePF__c =: product))
				LIMIT :MAXRESULTS
			];
		String productIcon ='standard:product';
		List<Product2> listProduct= new List<Product2>();
		if(searchResults!=null) {
			listProduct = (List<Product2>) searchResults[0];
			for (Product2 p : listProduct) {
				results.add(
					new AV_LookupSearchResult(
						p.Id,'Product2',productIcon,p.Name,'Codigo • ' + p.AV_ExternalID__c
					)
				);
			}
		}
		results.sort();
		List<Product2> listProduct2 = new List<Product2>();
		if (!listProduct.isEmpty()) {
			listProduct2 = [SELECT Id,Name,AV_ExternalID__c from Product2 WHERE Id NOT IN :listProduct AND AV_Sale__c = true AND RecordType.DeveloperName = 'AV_Producto' and AV_Nivel__c = '10' and AV_ExternalID__c!=null  AND(AV_NombrePF__r.AV_NombrePF__c =:product OR AV_NombrePF__c =:product) WITH SECURITY_ENFORCED LIMIT :MAXRESULTS];

		} else {
			listProduct2 = [SELECT Id,Name,AV_ExternalID__c from Product2 WHERE RecordType.DeveloperName = 'AV_Producto' AND AV_Nivel__c = '10' AND AV_ExternalID__c!=null AND AV_Sale__c = true AND(AV_NombrePF__r.AV_NombrePF__c =:product OR AV_NombrePF__c =:product) WITH SECURITY_ENFORCED LIMIT :MAXRESULTS];
		}
		if(listProduct2!= null && !listProduct2.isEmpty()) {
			for (Product2 p : listProduct2) {
				results.add(new AV_LookupSearchResult(p.Id,'Product2',productIcon,p.Name,'Codigo • ' + p.AV_ExternalID__c));
			}
		}
		return results;
	}

	/**
	 * @description     Lookup of Office
	 */
	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchOffice(String searchTerm, List<String> selectedIds) {
		Integer MAXRESULTS = 10;
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
	 * @description         Update of Opportunities changes and delete of new opportunity
	 * @param jsonListOpp   json of list of oportunity changes
	 * @param listIdsOpp    list of Ids of opportunities new
	 * @return              response witn error or null
	 */
	@AuraEnabled
	public static String updateBackReport(String jsonListOpp,List<String> listIdsOpp){
		String methodName = 'updateBackReport';
		String response;
		if (jsonListOpp != null && jsonListOpp != '{}') {
			Map<String,Opportunity> mapOpp= (Map<String,Opportunity>)Json.deserialize(jsonListOpp,Map<String,Opportunity>.class);
			List<Opportunity> listOpp = mapOpp.values();
			for(Opportunity cao: listOpp) {
				cao.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_BACK_REPORT;
			}
			List<Database.SaveResult> listSr = Database.update(listOpp, false);
			for (Database.SaveResult sr: listSr) {
				if(!sr.isSuccess()) {           
					for(Database.Error err : sr.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
						response = response+' | '+err.getMessage();
					}
				}
			}
		}
		if (listIdsOpp != null && !listIdsOpp.isEmpty()) {
			List<Opportunity> listOppDelete = new List<Opportunity>();
			for (String IdOpp : listIdsOpp) {
				listOppDelete.add(new Opportunity(Id=IdOpp));
			}
			List<Database.DeleteResult> listSrDelete = Database.delete(listOppDelete,false);
			for (Database.DeleteResult sr: listSrDelete) {
				if(!sr.isSuccess()) {           
					for(Database.Error err : sr.getErrors()) {
						AV_LogDebug.printLogDebug(methodName, 'Error: '+err.getMessage());
						response = response+' | '+err.getMessage();
					}
				}
			}
		}
		return response;
	}

	/**
	 * @description         Update Task of Block priorizador and aviso
	 * @param eventOrTsk    map of event or task to creates
	 * @param tasks         map of task to update
	 * @return              response witn error or OK
	 */
	@AuraEnabled
	public static TaskBlockResult updateTaskBlock(Map<Object,Object> eventOrTsk, Map<String,Map<Object,Object>> tasks) {
		Savepoint sp = Database.setSavepoint();
		String results = 'OK';
		Boolean isTask = eventOrTsk.get('type').equals('task');
		List<Task> listTaskUpdateOld = new List<Task>();
		List<String> listIdsManageHistInsert = new List<String>();
		if(tasks != null && !tasks.isEmpty()){
			List<Task> tskToUpt = unWrappTask(tasks,eventOrTsk,isTask);
			List<AV_ManagementHistory__c> lmh = new List<AV_ManagementHistory__c>();
			List<String> listIdsTskToUpt = new List<String>();
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
			if (listIdsTskToUpt != null && !listIdsTskToUpt.isEmpty()) {
				List<Task> listIdsTskToUptAdd = [Select Id, Description, Status, ActivityDate, AV_Tipo__c from Task where Id in :listIdsTskToUpt WITH SECURITY_ENFORCED];
				if (listIdsTskToUptAdd != null && !listIdsTskToUptAdd.isEmpty()) {
					listTaskUpdateOld.addAll(listIdsTskToUptAdd);
				}
			}
			if (tskToUpt != null && !tskToUpt.isEmpty()) {
				for(Task ta : tskToUpt) {
					ta.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
				}
				List<Database.SaveResult> srUpdtTsk = Database.update(tskToUpt,false);
				for(Database.SaveResult err : srUpdtTsk){
					if(!err.isSuccess()){
						results = err.getErrors()[0].getMessage();
					}
				}
			}
			if (lmh != null && !lmh.isEmpty()) {
				List<Database.SaveResult> srInsertManaHis = Database.insert(lmh,false);
				for(Database.SaveResult err : srInsertManaHis){
					if(!err.isSuccess()){
						results = err.getErrors()[0].getMessage();
					} else {
						listIdsManageHistInsert.add(err.getId());
					}
				}
			}
		}
		TaskBlockResult resultAll = new TaskBlockResult();
		resultAll.updateTaskUpdated = listTaskUpdateOld;
		resultAll.deleteManageHistInsert = listIdsManageHistInsert;
		resultAll.results = results;
		return resultAll;
	}

	/**
	 * @description         Create Events and task with check on off
	 * @param eventOrTsk    map of event or task to creates
	 * @param opportunities map of opp with changes or create
	 * @param mapOldOpp     map of opportunity old (before update)
	 * @param opposId       list Ids of opportunity news
	 * @return              response witn error or OK
	 */
	@AuraEnabled
	public static TaskEventResult processReportData(Map<Object,Object> eventOrTsk, Map<String,Map<Object,Object>> opportunities, Map<String,Opportunity> mapOldOpp, List<String> opposId,Boolean isNoLocalizadoActive ){
			
		    Boolean hasCustomPermission = FeatureManagement.checkPermission(AV_AppConstants.PS_OLDHOMETASK);
			Savepoint sp = Database.setSavepoint();
			Database.SaveResult sr;
			String results = 'OK';
			List<Database.SaveResult> srs;
			Boolean isTask = eventOrTsk.get('type').equals('task');
			Map<Id,TaskEvent> headerActivitys = new Map<Id,TaskEvent>();
			List<String> listIdsTaskInsert = new List<String>();
			List<String> listIdsEventInsert = new List<String>();
			List<String> listIdsCommentsHistoryInsert = new List<String>();
			List<AV_CustomActivityOpportunity__c> listTaskOppDeleteOld = new List<AV_CustomActivityOpportunity__c>();
			Map<String,String> mapNewHeader = new Map<String,String>();
			List<Task> listTaskUpdateOld = new List<Task>();
			List<Task> listTaskDeleteOld = new List<Task>();
			Map<String,String> mapProducIdName = new Map<String,String>();
			Map<String,String> mapProducNameId = new Map<String,String>();
			Map<String,String> mapProducIdOpp = new Map<String,String>();
			List<Task> listTaskChangeDate = new List<Task>();
			List<Task> listTaskToDelete = new List<Task>();
			List<AV_CustomActivityOpportunity__c> listTaskOpportunityDelete = new List<AV_CustomActivityOpportunity__c>();
			RecordType rt = (isTask) ?AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK,AV_AppConstants.TASKINICIATIVA_RT) : AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_EVENT,AV_AppConstants.EVENTCLIENTE_RT);
			RecordType rtTask = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK,AV_AppConstants.TASKINICIATIVA_RT);
			if(opportunities != null && !opportunities.isEmpty()){
				List<String> listIdsOppDeleteTaskOpp = new List<String>();
				List<SObject> recordsToInsert = new List<SObject>();
				List<String> resultsEventTask = new List<String>();
				Map<String,Map<Object,Object>> mapCreateTaskCheckOnOff = new Map<String,Map<Object,Object>>();
				Map<String,Map<Object,Object>> mapOpportunities = new Map<String,Map<Object,Object>>();
				List<String> listIdsOppCheck = new List<String>();
				List<String> listIdsTaskOpportunityDelete = new List<String>();
				List<String> listTaskToDeleteIds = new List<String>();
				List<String> listTaskChangeDateIds = new List<String>();
				String nameOppMain;
				for(String oppoId : opportunities.keySet()){
					String idOppNew = null;
					if((( (String) opportunities.get(oppoId).get('id')).contains('idProvisional') || !mapOldOpp.get(oppoId).AV_IncludeInPrioritizingCustomers__c) && (Boolean)opportunities.get(oppoId).get('agendado') == false && opportunities.get(oppoId).get('newPath') == AV_AppConstants.OPP_STATUS_ENGESTION) { //Check on off por fechas, segun si esta en gestion si no es agendado si no esta creada la oportunidad y si esta creada mira si la oportunidad anteriormente tuviera el check on of deshabilitado
						if(opposId != null && !opposId.isEmpty() && ((String) opportunities.get(oppoId).get('id')).contains('idProvisional')){
							idOppNew = opposId.remove(0);
							opportunities.get(oppoId).put('id',idOppNew);
						}
						if (idOppNew != null) {
							mapProducIdOpp.put((String)opportunities.get(oppoId).get('ProdId'),idOppNew);
							mapCreateTaskCheckOnOff.put(idOppNew,opportunities.get(oppoId));
						}else {
							mapProducIdOpp.put((String)opportunities.get(oppoId).get('ProdId'),oppoId);
							mapCreateTaskCheckOnOff.put(oppoId,opportunities.get(oppoId));
						}
					}else if(!((String)opportunities.get(oppoId).get('id')).contains('idProvisional') && (((mapOldOpp.get(oppoId).AV_IncludeInPrioritizingCustomers__c && (opportunities.get(oppoId).get('proximaGestion') != null && mapOldOpp.get(oppoId).AV_FechaProximoRecordatorio__c != formatDate((String) opportunities.get(oppoId).get('proximaGestion')))) && (Boolean)opportunities.get(oppoId).get('agendado') == false && opportunities.get(oppoId).get('newPath') == AV_AppConstants.OPP_STATUS_ENGESTION) || opportunities.get(oppoId).get('newPath') != AV_AppConstants.OPP_STATUS_ENGESTION)) { //Check on off por fechas, segun si esta en gestion si no es agendado si esta creada y tiene el check on off habilitado y cambia de fecha de proxima gestion o la que no estan en gestion insistir
						if(opposId != null && !opposId.isEmpty() && ((String) opportunities.get(oppoId).get('id')).contains('idProvisional')){
							idOppNew = opposId.remove(0);
							opportunities.get(oppoId).put('id',idOppNew);
						}
						if (idOppNew != null) {
							mapOpportunities.put(idOppNew,opportunities.get(oppoId));
							listIdsOppCheck.add(idOppNew);
						}else {
							mapOpportunities.put(oppoId,opportunities.get(oppoId));
							listIdsOppCheck.add(oppoId);
						}
					}
					if(opposId != null && !opposId.isEmpty() && ((String) opportunities.get(oppoId).get('id')).contains('idProvisional') && idOppNew == null){
						opportunities.get(oppoId).put('id',opposId.remove(0));
					}
					if ((Boolean)opportunities.get(oppoId).get('mainVinculed')) { //Nombre del evento cuando la cita no es No comercial
						nameOppMain = (String) opportunities.get(oppoId).get('Name');
					}
				}
				if (mapOpportunities != null && listIdsOppCheck != null && !listIdsOppCheck.isEmpty()) { //si esta creada y tiene el check on off habilitado y cambia de fecha de proxima gestion y no tiene ninguna tarea de check on off en potencial o en gestion CHECK ON OFF para cambiarla de fecha o crear una nueva  o si no esta en gestion para eliminar la tarea y la tarea-oportunidad
					List<AV_CustomActivityOpportunity__c> listTaskOppCheck = [Select Id, AV_Task__c, AV_Opportunity__c, AV_Opportunity__r.AV_FechaProximoRecordatorio__c, AV_Opportunity__r.StageName from AV_CustomActivityOpportunity__c where AV_Opportunity__c in :listIdsOppCheck and AV_Task__c != null WITH SECURITY_ENFORCED];
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
							List<Task> listTaskOppCheckOn = [Select Id, AV_OrigenApp__c, AV_Task__c, IsClosed, ActivityDate,AV_Chanel__c from Task where AV_Task__c in :mapTaskOppId.keySet() WITH SECURITY_ENFORCED];
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
							if ((listOppNoCreateTask == null|| listOppNoCreateTask.isEmpty() || !listOppNoCreateTask.contains(idOpp)) && (Boolean)mapOpportunities.get(idOpp).get('agendado') == false && mapOpportunities.get(idOpp).get('newPath') == AV_AppConstants.OPP_STATUS_ENGESTION){ //Para que cree las de check on off en caso de cambio de fecha
								mapProducIdOpp.put((String)mapOpportunities.get(idOpp).get('ProdId'),idOpp);
								mapCreateTaskCheckOnOff.put(idOpp,mapOpportunities.get(idOpp));
							}
						}
					}
				}
				if (listTaskOpportunityDelete != null && listIdsTaskOpportunityDelete != null && !listIdsTaskOpportunityDelete.isEmpty() && !listTaskOpportunityDelete.isEmpty()) { //Eliminacion de las tarea-oportunidades check-on off
					List<AV_CustomActivityOpportunity__c> listIdsTaskOpportunityDeleteAdd = [Select OwnerId, RecordTypeId, AV_ExternalID__c, AV_Opportunity__c, AV_Task__c, AV_OrigenApp__c, AV_Amount__c, AV_Commentary__c, AV_Concepto1__c, AV_Concepto2__c, AV_Concepto3__c, AV_Concepto4__c, AV_Concepto5__c, AV_DischargeDate__c, AV_DueDate__c, AV_Entity__c, AV_FeeAmount__c, AV_Gestor__c, AV_HoldingAnotherEntity__c, AV_IsMain__c, AV_NextEventDate__c, AV_Priority__c, AV_Product__c, AV_ReviewDate__c, AV_Stage__c, AV_TypeOfInterest__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, AV_WarningDate__c, AV_LicensePlate__c, AV_IncludeInPrioritizingCustomers__c, AV_FechaVencimiento__c, AV_ActivityDate__c, AV_Status__c, AV_Resolucion__c, AV_Channel__c, AV_AmountEuro__c, AV_ByProduct__c, AV_MarginEuro__c from AV_CustomActivityOpportunity__c where Id in :listIdsTaskOpportunityDelete WITH SECURITY_ENFORCED];
					if (listIdsTaskOpportunityDeleteAdd != null && !listIdsTaskOpportunityDeleteAdd.isEmpty()) {
						List<AV_CustomActivityOpportunity__c> listTaskOppBack = new List<AV_CustomActivityOpportunity__c>();
						for (AV_CustomActivityOpportunity__c taOpp : listIdsTaskOpportunityDeleteAdd) {
							listTaskOppBack.add(structureTaskOppInsertBack(taOpp));
						}
						listTaskOppDeleteOld.addAll(listTaskOppBack); //lista de tareas-opp old
					}
				}
				if (listTaskToDelete != null && listTaskToDeleteIds != null && !listTaskToDeleteIds.isEmpty() && !listTaskToDelete.isEmpty()) {
					List<Task> listTaskToDeleteIdsAdd = [Select RecordTypeId, WhoId, WhatId, Subject, ActivityDate, Status, Priority, OwnerId, Description, ReminderDateTime, IsReminderSet,AV_ALVEN__c, AV_CodigoGestorAsignado__c,  AV_NoGestionable__c, AV_Type__c, AV_ExternalID__c, AV_ConVenta__c, AV_Task__c, AV_Tipo__c, AV_Valor1__c, AV_Valor2__c, AV_Valor3__c, AV_Valor4__c, AV_Valor5__c, AV_OrigenApp__c, AV_BranchPhysicalMeet__c, AV_ColorEtiqueta__c, AV_DurationToNoticeToManager__c, AV_FechaFinAccionComercial__c, AV_Center__c, AV_PrioritizingSort__c, AV_FechaInicioVigencia__c, AV_Chanel__c, AV_PEA__c, AV_Purpose__c, AV_IdDelActaMifid__c, AV_CenterRtIndex__c, AV_PriorityTask__c, AV_AssociatedOpportunityId__c, AV_SurveyValue__c, AV_PEA2__c, AV_OrigenAct__c, AV_VisiblePorElClienteEnNow__c, AV_Case__c from Task where Id in :listTaskToDeleteIds WITH SECURITY_ENFORCED];
					if (listTaskToDeleteIdsAdd != null && !listTaskToDeleteIdsAdd.isEmpty()) {
						List<Task> listTaskBack = new List<Task>();
						for (Task ta : listTaskToDeleteIdsAdd) {
							mapNewHeader.put(ta.AV_ExternalID__c,ta.AV_Task__c);
							ta.AV_Task__c = null;
							listTaskBack.add(structureTaskInsertBack(ta));
						}
						listTaskDeleteOld.addAll(listTaskBack); //lista de tareas old
					}
				}
				if (listTaskChangeDate != null && listTaskChangeDateIds != null && !listTaskChangeDateIds.isEmpty() && !listTaskChangeDate.isEmpty()) { //update task Due Date Check on off
					if (listTaskChangeDateIds != null && !listTaskChangeDateIds.isEmpty()) {
						List<Task> listTaskChangeDateIdsAdd = [Select Id, ActivityDate from Task where Id in :listTaskChangeDateIds WITH SECURITY_ENFORCED];
						if (listTaskChangeDateIdsAdd != null && !listTaskChangeDateIdsAdd.isEmpty()) {
							listTaskUpdateOld.addAll(listTaskChangeDateIdsAdd); //lista de tareas old
						}
					}
					for(Task ta : listTaskChangeDate) {
						ta.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
					}
				}

				SObject nextRecordEvent = createRecord(eventOrTsk,isTask,rt,nameOppMain,isNoLocalizadoActive); //Evento o Tarea que se crea del report  
				recordsToInsert.add(nextRecordEvent);
				
				if (!isTask) {
					if(recordsToInsert != null && !recordsToInsert.isEmpty()) {
						srs = Database.insert(recordsToInsert,false);
						for(Database.SaveResult res : srs){
							if(!res.isSuccess()) {
								results = res.getErrors()[0].getMessage();
							} else {
								resultsEventTask.add(res.getId());
								listIdsEventInsert.add(res.getId());
							}
						}
					}
					recordsToInsert = new List<SObject>();
				}
				

				 //Si tiene el PS AV_OldHomeTask
				if(hasCustomPermission){
					if (mapProducIdOpp != null && mapCreateTaskCheckOnOff != null) {
						List<Product2> listproducts = [Select Id, Name from Product2 where Id in :mapProducIdOpp.keySet() WITH SECURITY_ENFORCED];
						if (listproducts != null && !listproducts.isEmpty()) {
							for (Product2 pro : listproducts) {
								mapProducIdName.put(pro.Id,pro.Name);
								mapProducNameId.put(pro.Name,pro.Id);
							}
							if (mapProducIdName != null && !mapProducIdName.isEmpty()) {
								for(String oppId : mapCreateTaskCheckOnOff.keySet()){ // Tareas de check on off
									Task nextRecord = new Task();
									nextRecord.put('RecordTypeId',rtTask.Id);
									nextRecord.put('WhatId', (Id) eventOrTsk.get('accountId'));
									nextRecord.put('Status','Open');
									nextRecord.put('Priority','A');
									nextRecord.put('ActivityDate',formatDate((String)mapCreateTaskCheckOnOff.get(oppId).get('proximaGestion')));
									nextRecord.put('Subject',mapProducIdName.get((String) mapCreateTaskCheckOnOff.get(oppId).get('ProdId')));
									nextRecord.put('AV_OrigenApp__c',AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF);
									recordsToInsert.add(nextRecord);
								}
							}
						}
					}
				}
				
				if(recordsToInsert != null && !recordsToInsert.isEmpty()) {
					srs = Database.insert(recordsToInsert,false);
					for(Database.SaveResult res : srs){
						if(!res.isSuccess()) {
							results = res.getErrors()[0].getMessage();
						} else {
							resultsEventTask.add(res.getId());
							listIdsTaskInsert.add(res.getId());
						}
					}
				}

				List<AV_CommentsHistory__c> commHistList = new List<AV_CommentsHistory__c>();
				Set<Id> setIds = new Set<Id>();
				for (String opportunityId : opportunities.keySet()) {
					Map<Object, Object> opportunityDetails = opportunities.get(opportunityId);
					String id = (String)opportunityDetails.get('id');
					setIds.add(id);
				}
				List<Contact> contactList = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c =:UserInfo.getUserId() ];
				headerActivitys = new Map<Id,TaskEvent>();
				if (resultsEventTask != null && !resultsEventTask.isEmpty()) {
					if (!isTask) {
						List<Event> listEvent = [SELECT Id, AV_Task__c, Subject, ActivityDate, AV_OrigenApp__c,AV_Tipo__c FROM EVENT WHERE Id IN :resultsEventTask WITH SECURITY_ENFORCED];
						if (listEvent!=null && !listEvent.isEmpty()) {
							for(Event ev : listEvent) {
								TaskEvent te = new TaskEvent();
								te.idTaskEvent = ev.Id;
								te.taskHeader = ev.AV_Task__c;
								te.subject = ev.Subject;
								te.activityDate = ev.ActivityDate;
								te.origenApp = ev.AV_OrigenApp__c;
								headerActivitys.put(ev.Id,te);

								for(String oppoId : opportunities.keySet()){
									if(opportunities.get(oppoId)!= null  && (mapOldOpp.get(oppoId) == null || (mapOldOpp.get(oppoId) != null && (mapOldOpp.get(oppoId).AV_Comentarios__c != opportunities.get(oppoId).get('comentario') || mapOldOpp.get(oppoId).StageName != opportunities.get(oppoId).get('newPath'))))){
										AV_CommentsHistory__c ch = new AV_CommentsHistory__c();
										String comentario = (String)opportunities.get(oppoId).get('comentario');
										ch.AV_NewComment__c = comentario;
										ch.AV_Opportunity__c = (String)opportunities.get(oppoId).get('id');
										if(mapOldOpp!=null && mapOldOpp.get(oppoId)!= null){
											ch.AV_OldComment__c = (String)mapOldOpp.get(oppoId).AV_Comentarios__c;
											ch.AV_OldStatus__c = mapOldOpp.get(oppoId).StageName;
										}
										ch.AV_ModificationDate__c = System.today();
										if(contactList != null && !contactList.isEmpty()){
											ch.AV_AssignedEmployee__c = contactList[0].Id;
										}
										ch.AV_OpportunityStatus__c = (String)opportunities.get(oppoId).get('newPath');
										ch.AV_Event__c = (String)ev.Id;
										commHistList.add(ch);

									}
									
								}
							}
							if(commHistList!= null){
								List<Database.SaveResult> srCommHistList = Database.insert(commHistList,false);
								for(Database.SaveResult ur : srCommHistList){
									if(!ur.isSuccess()) {
										results = ur.getErrors()[0].getMessage();
									} else {
										listIdsCommentsHistoryInsert.add(ur.getId());
									}
								}
							}
							
						}
					}
					List<Task> listTask = [SELECT Id, AV_Task__c, Subject, ActivityDate, AV_OrigenApp__c,AV_Tipo__c FROM TASK WHERE Id IN :resultsEventTask WITH SECURITY_ENFORCED];
					
					if (listTask!=null && !listTask.isEmpty()) {
						for(Task ta : listTask) {
							TaskEvent te = new TaskEvent();
							te.idTaskEvent = ta.Id;
							te.taskHeader = ta.AV_Task__c;
							te.subject = ta.Subject;
							te.activityDate = ta.ActivityDate;
							te.origenApp = ta.AV_OrigenApp__c;
							headerActivitys.put(ta.Id,te);
							for(String oppoId : opportunities.keySet()){
								if(opportunities.get(oppoId)!= null && ta.AV_OrigenApp__c != AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF && (mapOldOpp.get(oppoId) == null || (mapOldOpp.get(oppoId) != null && (mapOldOpp.get(oppoId).AV_Comentarios__c != opportunities.get(oppoId).get('comentario') || mapOldOpp.get(oppoId).StageName != opportunities.get(oppoId).get('newPath'))))){
									AV_CommentsHistory__c ch = new AV_CommentsHistory__c();
									String comentario = (String)opportunities.get(oppoId).get('comentario');
									ch.AV_NewComment__c = comentario;
									ch.AV_Opportunity__c = (String)opportunities.get(oppoId).get('id');
									if(mapOldOpp != null && mapOldOpp.get(oppoId) != null) {
										ch.AV_OldComment__c = (String)mapOldOpp.get(oppoId).AV_Comentarios__c;
										ch.AV_OldStatus__c = mapOldOpp.get(oppoId).StageName;
									}
									ch.AV_ModificationDate__c = System.today();
									if(contactList != null && !contactList.isEmpty()){
										ch.AV_AssignedEmployee__c = contactList[0].Id;
									}
									ch.AV_OpportunityStatus__c = (String)opportunities.get(oppoId).get('newPath');
									ch.AV_Task__c = (String)ta.Id;
									commHistList.add(ch);
								}
								
							}
						}
						if(commHistList!= null){
							Database.insert(commHistList,false);
						}
					}
					
				}
			}else{
				sr = Database.insert(createRecord(eventOrTsk,isTask,rt,null,isNoLocalizadoActive),false);   
				if(!sr.isSuccess()) {
					results = sr.getErrors()[0].getMessage();
				} else if (isTask) {
					listIdsTaskInsert.add(sr.getId());
				} else {
					listIdsEventInsert.add(sr.getId());
				}
			}
			if (results != 'OK') {
				Database.rollback(sp);
			}
			TaskEventBack allBack = new TaskEventBack();
			allBack.insertTasksDelete = listTaskDeleteOld;
			allBack.insertTaskOppDelete = listTaskOppDeleteOld;
			allBack.deleteIdTasksInsert = listIdsTaskInsert;
			allBack.deleteIdEventInsert = listIdsEventInsert;
			allBack.deleteIdCommentsHistoryInsert = listIdsCommentsHistoryInsert;
			allBack.deleteManageHistInsert = new List<String>();
			allBack.updateTaskUpdated = listTaskUpdateOld;
			allBack.mapNewHeader = mapNewHeader;
			TaskEventResult allResult = new TaskEventResult();
			allResult.headerActivitys = headerActivitys;
			allResult.mapProducNameId = mapProducNameId;
			allResult.mapProducIdOpp = mapProducIdOpp;
			allResult.opportunities = opportunities;
			allResult.results = results;
			allResult.dataBack = allBack;
			allResult.listTaskChangeDate = listTaskChangeDate;
			allResult.listTaskToDelete = listTaskToDelete;
			allResult.listTaskOpportunityDelete = listTaskOpportunityDelete;
			return allResult;
	}

	/**
	 * @description                     Update or delete because check on off
	 * @param listTaskChangeDate        list of task to change date because check on off
	 * @param listTaskToDelete          list of task to delete
	 * @param listTaskOpportunityDelete list of task-opp to delete
	 * @return                          response witn error or OK
	 */
	@AuraEnabled
	public static String updateDeleteTaskCheckOnOff(List<Task> listTaskChangeDate, List<Task> listTaskToDelete, List<AV_CustomActivityOpportunity__c> listTaskOpportunityDelete) {
		Savepoint sp = Database.setSavepoint();
		String results = 'OK';
		if (listTaskChangeDate != null && !listTaskChangeDate.isEmpty()) {
			List<Database.SaveResult> srs = Database.update(listTaskChangeDate,false);
			for(Database.SaveResult res : srs){
				if(!res.isSuccess()) {
					results = res.getErrors()[0].getMessage();
				}
			}
		}
		if (listTaskOpportunityDelete != null && !listTaskOpportunityDelete.isEmpty()) {
			List<Database.DeleteResult> listSrDeleteTaskOpp = Database.delete(listTaskOpportunityDelete,false);
			for(Database.DeleteResult res : listSrDeleteTaskOpp){
				if(!res.isSuccess()) {
					results = res.getErrors()[0].getMessage();
				}
			}
		}
		if (listTaskToDelete != null && !listTaskToDelete.isEmpty()) {
			List<Database.DeleteResult> listSrDeleteMapTask = Database.delete(listTaskToDelete,false);//Eliminacion de las tareas sin tarea-oportunidad del check-on off
			for(Database.DeleteResult res : listSrDeleteMapTask){
				if(!res.isSuccess()) {
					results = res.getErrors()[0].getMessage();
				}
			}
		}
		if (results != 'OK') {
			Database.rollback(sp);
		}
		return results;
	}

	/**
	 * @description         Structure of Task-Opportunity to back insert
	 * @param taOpp         task-Opportunity
	 * @return              task-Opportunity to structure new
	 */
	public static AV_CustomActivityOpportunity__c structureTaskOppInsertBack(AV_CustomActivityOpportunity__c taOpp) {
		AV_CustomActivityOpportunity__c taskOppInsert = new AV_CustomActivityOpportunity__c();
		if (taOpp.OwnerId != null) {
			taskOppInsert.OwnerId = taOpp.OwnerId;
		}
		if (taOpp.RecordTypeId != null) {
			taskOppInsert.RecordTypeId = taOpp.RecordTypeId;
		}
		if (taOpp.AV_ExternalID__c != null) {
			taskOppInsert.AV_ExternalID__c = taOpp.AV_ExternalID__c;
		}
		if (taOpp.AV_Opportunity__c != null) {
			taskOppInsert.AV_Opportunity__c = taOpp.AV_Opportunity__c;
		}
		if (taOpp.AV_Task__c != null) {
			taskOppInsert.AV_Task__c = taOpp.AV_Task__c;
		}
		if (taOpp.AV_OrigenApp__c != null) {
			taskOppInsert.AV_OrigenApp__c = taOpp.AV_OrigenApp__c;
		}
		if (taOpp.AV_Amount__c != null) {
			taskOppInsert.AV_Amount__c = taOpp.AV_Amount__c;
		}
		if (taOpp.AV_Commentary__c != null) {
			taskOppInsert.AV_Commentary__c = taOpp.AV_Commentary__c;
		}
		if (taOpp.AV_Concepto1__c != null) {
			taskOppInsert.AV_Concepto1__c = taOpp.AV_Concepto1__c;
		}
		if (taOpp.AV_Concepto3__c != null) {
			taskOppInsert.AV_Concepto3__c = taOpp.AV_Concepto3__c;
		}
		if (taOpp.AV_Concepto4__c != null) {
			taskOppInsert.AV_Concepto4__c = taOpp.AV_Concepto4__c;
		}
		if (taOpp.AV_Concepto5__c != null) {
			taskOppInsert.AV_Concepto5__c = taOpp.AV_Concepto5__c;
		}
		if (taOpp.AV_DischargeDate__c != null) {
			taskOppInsert.AV_DischargeDate__c = taOpp.AV_DischargeDate__c;
		}
		if (taOpp.AV_DueDate__c != null) {
			taskOppInsert.AV_DueDate__c = taOpp.AV_DueDate__c;
		}
		if (taOpp.AV_Entity__c != null) {
			taskOppInsert.AV_Entity__c = taOpp.AV_Entity__c;
		}
		if (taOpp.AV_FeeAmount__c != null) {
			taskOppInsert.AV_FeeAmount__c = taOpp.AV_FeeAmount__c;
		}
		if (taOpp.AV_Gestor__c != null) {
			taskOppInsert.AV_Gestor__c = taOpp.AV_Gestor__c;
		}
		if (taOpp.AV_HoldingAnotherEntity__c != null) {
			taskOppInsert.AV_HoldingAnotherEntity__c = taOpp.AV_HoldingAnotherEntity__c;
		}
		if (taOpp.AV_IsMain__c != null) {
			taskOppInsert.AV_IsMain__c = taOpp.AV_IsMain__c;
		}
		if (taOpp.AV_NextEventDate__c != null) {
			taskOppInsert.AV_NextEventDate__c = taOpp.AV_NextEventDate__c;
		}
		if (taOpp.AV_Priority__c != null) {
			taskOppInsert.AV_Priority__c = taOpp.AV_Priority__c;
		}
		if (taOpp.AV_Product__c != null) {
			taskOppInsert.AV_Product__c = taOpp.AV_Product__c;
		}
		if (taOpp.AV_ReviewDate__c != null) {
			taskOppInsert.AV_ReviewDate__c = taOpp.AV_ReviewDate__c;
		}
		if (taOpp.AV_Stage__c != null) {
			taskOppInsert.AV_Stage__c = taOpp.AV_Stage__c;
		}
		if (taOpp.AV_TypeOfInterest__c != null) {
			taskOppInsert.AV_TypeOfInterest__c = taOpp.AV_TypeOfInterest__c;
		}
		if (taOpp.AV_Valor1__c != null) {
			taskOppInsert.AV_Valor1__c = taOpp.AV_Valor1__c;
		}
		if (taOpp.AV_Valor2__c != null) {
			taskOppInsert.AV_Valor2__c = taOpp.AV_Valor2__c;
		}
		if (taOpp.AV_Valor3__c != null) {
			taskOppInsert.AV_Valor3__c = taOpp.AV_Valor3__c;
		}
		if (taOpp.AV_Valor4__c != null) {
			taskOppInsert.AV_Valor4__c = taOpp.AV_Valor4__c;
		}
		if (taOpp.AV_Valor5__c != null) {
			taskOppInsert.AV_Valor5__c = taOpp.AV_Valor5__c;
		}
		if (taOpp.AV_WarningDate__c != null) {
			taskOppInsert.AV_WarningDate__c = taOpp.AV_WarningDate__c;
		}
		if (taOpp.AV_LicensePlate__c != null) {
			taskOppInsert.AV_LicensePlate__c = taOpp.AV_LicensePlate__c;
		}
		if (taOpp.AV_IncludeInPrioritizingCustomers__c != null) {
			taskOppInsert.AV_IncludeInPrioritizingCustomers__c = taOpp.AV_IncludeInPrioritizingCustomers__c;
		}
		if (taOpp.AV_FechaVencimiento__c != null) {
			taskOppInsert.AV_FechaVencimiento__c = taOpp.AV_FechaVencimiento__c;
		}
		if (taOpp.AV_ActivityDate__c != null) {
			taskOppInsert.AV_ActivityDate__c = taOpp.AV_ActivityDate__c;
		}
		if (taOpp.AV_Status__c != null) {
			taskOppInsert.AV_Status__c = taOpp.AV_Status__c;
		}
		if (taOpp.AV_Resolucion__c != null) {
			taskOppInsert.AV_Resolucion__c = taOpp.AV_Resolucion__c;
		}
		if (taOpp.AV_Channel__c != null) {
			taskOppInsert.AV_Channel__c = taOpp.AV_Channel__c;
		}
		if (taOpp.AV_AmountEuro__c != null) {
			taskOppInsert.AV_AmountEuro__c = taOpp.AV_AmountEuro__c;
		}
		if (taOpp.AV_ByProduct__c != null) {
			taskOppInsert.AV_ByProduct__c = taOpp.AV_ByProduct__c;
		}
		if (taOpp.AV_MarginEuro__c != null) {
			taskOppInsert.AV_MarginEuro__c = taOpp.AV_MarginEuro__c;
		}
		return taskOppInsert;
	}

	/**
	 * @description         Structure of Task to back insert
	 * @param ta            task
	 * @return              task to structure new
	 */
	public static Task structureTaskInsertBack(Task ta) {
		Task taskInsert = new Task();
		if (ta.RecordTypeId != null) {
			taskInsert.RecordTypeId = ta.RecordTypeId;
		}
		if (ta.WhoId != null) {
			taskInsert.WhoId = ta.WhoId;
		}
		if (ta.WhatId != null) {
			taskInsert.WhatId = ta.WhatId;
		}
		if (ta.Subject != null) {
			taskInsert.Subject = ta.Subject;
		}
		if (ta.ActivityDate != null) {
			taskInsert.ActivityDate = ta.ActivityDate;
		}
		if (ta.Status != null) {
			taskInsert.Status = ta.Status;
		}
		if (ta.Priority != null) {
			taskInsert.Priority = ta.Priority;
		}
		if (ta.OwnerId != null) {
			taskInsert.OwnerId = ta.OwnerId;
		}
		if (ta.Description != null) {
			taskInsert.Description = ta.Description;
		}
		if (ta.ReminderDateTime != null) {
			taskInsert.ReminderDateTime = ta.ReminderDateTime;
		}
		if (ta.IsReminderSet != null) {
			taskInsert.IsReminderSet = ta.IsReminderSet;
		}
		if (ta.AV_ALVEN__c != null) {
			taskInsert.AV_ALVEN__c = ta.AV_ALVEN__c;
		}
		if (ta.AV_CodigoGestorAsignado__c != null) {
			taskInsert.AV_CodigoGestorAsignado__c = ta.AV_CodigoGestorAsignado__c;
		}
		if (ta.AV_NoGestionable__c != null) {
			taskInsert.AV_NoGestionable__c = ta.AV_NoGestionable__c;
		}
		if (ta.AV_Type__c != null) {
			taskInsert.AV_Type__c = ta.AV_Type__c;
		}
		if (ta.AV_ExternalID__c != null) {
			taskInsert.AV_ExternalID__c = ta.AV_ExternalID__c;
		}
		if (ta.AV_ConVenta__c != null) {
			taskInsert.AV_ConVenta__c = ta.AV_ConVenta__c;
		}
		if (ta.AV_Task__c != null) {
			taskInsert.AV_Task__c = ta.AV_Task__c;
		}
		if (ta.AV_Tipo__c != null) {
			taskInsert.AV_Tipo__c = ta.AV_Tipo__c;
		}
		if (ta.AV_Valor1__c != null) {
			taskInsert.AV_Valor1__c = ta.AV_Valor1__c;
		}
		if (ta.AV_Valor2__c != null) {
			taskInsert.AV_Valor2__c = ta.AV_Valor2__c;
		}
		if (ta.AV_Valor3__c != null) {
			taskInsert.AV_Valor3__c = ta.AV_Valor3__c;
		}
		if (ta.AV_Valor4__c != null) {
			taskInsert.AV_Valor4__c = ta.AV_Valor4__c;
		}
		if (ta.AV_Valor5__c != null) {
			taskInsert.AV_Valor5__c = ta.AV_Valor5__c;
		}
		if (ta.AV_OrigenApp__c != null) {
			taskInsert.AV_OrigenApp__c = ta.AV_OrigenApp__c;
		}
		if (ta.AV_BranchPhysicalMeet__c != null) {
			taskInsert.AV_BranchPhysicalMeet__c = ta.AV_BranchPhysicalMeet__c;
		}
		if (ta.AV_ColorEtiqueta__c != null) {
			taskInsert.AV_ColorEtiqueta__c = ta.AV_ColorEtiqueta__c;
		}
		if (ta.AV_DurationToNoticeToManager__c != null) {
			taskInsert.AV_DurationToNoticeToManager__c = ta.AV_DurationToNoticeToManager__c;
		}
		if (ta.AV_FechaFinAccionComercial__c != null) {
			taskInsert.AV_FechaFinAccionComercial__c = ta.AV_FechaFinAccionComercial__c;
		}
		if (ta.AV_PrioritizingSort__c != null) {
			taskInsert.AV_PrioritizingSort__c = ta.AV_PrioritizingSort__c;
		}
		if (ta.AV_FechaInicioVigencia__c != null) {
			taskInsert.AV_FechaInicioVigencia__c = ta.AV_FechaInicioVigencia__c;
		}
		if (ta.AV_Chanel__c != null) {
			taskInsert.AV_Chanel__c = ta.AV_Chanel__c;
		}
		if (ta.AV_PEA__c != null) {
			taskInsert.AV_PEA__c = ta.AV_PEA__c;
		}
		if (ta.AV_Purpose__c != null) {
			taskInsert.AV_Purpose__c = ta.AV_Purpose__c;
		}
		if (ta.AV_IdDelActaMifid__c != null) {
			taskInsert.AV_IdDelActaMifid__c = ta.AV_IdDelActaMifid__c;
		}
		if (ta.AV_CenterRtIndex__c != null) {
			taskInsert.AV_CenterRtIndex__c = ta.AV_CenterRtIndex__c;
		}
		if (ta.AV_PriorityTask__c != null) {
			taskInsert.AV_PriorityTask__c = ta.AV_PriorityTask__c;
		}
		if (ta.AV_AssociatedOpportunityId__c != null) {
			taskInsert.AV_AssociatedOpportunityId__c = ta.AV_AssociatedOpportunityId__c;
		}
		if (ta.AV_SurveyValue__c != null) {
			taskInsert.AV_SurveyValue__c = ta.AV_SurveyValue__c;
		}
		if (ta.AV_PEA2__c != null) {
			taskInsert.AV_PEA2__c = ta.AV_PEA2__c;
		}
		if (ta.AV_OrigenAct__c != null) {
			taskInsert.AV_OrigenAct__c = ta.AV_OrigenAct__c;
		}
		if (ta.AV_VisiblePorElClienteEnNow__c != null) {
			taskInsert.AV_VisiblePorElClienteEnNow__c = ta.AV_VisiblePorElClienteEnNow__c;
		}
		if (ta.AV_Case__c != null) {
			taskInsert.AV_Case__c = ta.AV_Case__c;
		}
		return taskInsert;
	}

	/**
	 * @description         Update of Task/Event changes and delete of new task and task-oportunity
	 * @param jsonListOpp   json of list of oportunity changes
	 * @param listIdsOpp    list of Ids of opportunities new
	 * @return              response witn error or null
	 */
	@AuraEnabled
	public static String updateBackReportTaskEvent(String jsonBackAll){
		String methodName = 'updateBackReport';
		Map<String,String> mapChangeNewTask = new Map<String,String>();
		String response;
		if (jsonBackAll != null && jsonBackAll != '{}') {
			TaskEventBack backAll= (TaskEventBack)Json.deserialize(jsonBackAll,TaskEventBack.class);
			if (backAll.mapNewHeader != null && !backAll.mapNewHeader.isEmpty()) {
				if (backAll.insertTasksDelete != null && !backAll.insertTasksDelete.isEmpty()) {
					List<String> listIdCreateTask = new List<String>();
					List<Database.SaveResult> listSr = Database.insert(backAll.insertTasksDelete, false);
					for (Database.SaveResult sr: listSr) {
						if(!sr.isSuccess()) {           
							for(Database.Error err : sr.getErrors()) {
								AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
								response = response+' | Insert Task -> '+err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
							}
						} else {
							listIdCreateTask.add(sr.getId());
						}
					}
					if (listIdCreateTask != null && !listIdCreateTask.isEmpty()) {
						List<Task> listAfterInsertTask = [Select AV_ExternalID__c, AV_Task__c  from Task where Id in :listIdCreateTask WITH SECURITY_ENFORCED];
						if (listAfterInsertTask != null && !listAfterInsertTask.isEmpty()) {
							for(Task ta : listAfterInsertTask) {
								mapChangeNewTask.put(backAll.mapNewHeader.get(ta.AV_ExternalID__c),ta.AV_Task__c);
							}
						}
					}
				}
				if (backAll.insertTaskOppDelete != null && mapChangeNewTask != null && !mapChangeNewTask.isEmpty() && !backAll.insertTaskOppDelete.isEmpty()) {
					for (AV_CustomActivityOpportunity__c cao : backAll.insertTaskOppDelete) {
						cao.AV_Task__c = mapChangeNewTask.get(cao.AV_Task__c);
						cao.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_BACK_REPORT;
					}
					List<Database.SaveResult> listSr = Database.insert(backAll.insertTaskOppDelete, false);
					for (Database.SaveResult sr: listSr) {
						if(!sr.isSuccess()) {           
							for(Database.Error err : sr.getErrors()) {
								AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
								response = response+' | Insert Task-Opp -> '+err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
							}
						}
					}
				}
			}
			if (backAll.deleteManageHistInsert != null && !backAll.deleteManageHistInsert.isEmpty()) {
				List<AV_ManagementHistory__c> listManageHisDelete = new List<AV_ManagementHistory__c>();
				for (String idManageHis : backAll.deleteManageHistInsert) {
					listManageHisDelete.add(new AV_ManagementHistory__c(Id=idManageHis));
				}
				List<Database.DeleteResult> listSrDelete = Database.delete(listManageHisDelete,false);
				for (Database.DeleteResult sr: listSrDelete) {
					if(!sr.isSuccess()) {           
						for(Database.Error err : sr.getErrors()) {
							AV_LogDebug.printLogDebug(methodName, 'Error: '+err.getMessage());
							response = response+' | Delete Manage History -> '+err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
						}
					}
				}
			}
			if (backAll.deleteIdTasksInsert != null && !backAll.deleteIdTasksInsert.isEmpty()) {
				List<Task> listTaskDelete = new List<Task>();
				for (String idTask : backAll.deleteIdTasksInsert) {
					listTaskDelete.add(new Task(Id=idTask));
				}
				List<Database.DeleteResult> listSrDelete = Database.delete(listTaskDelete,false);
				for (Database.DeleteResult sr: listSrDelete) {
					if(!sr.isSuccess()) {           
						for(Database.Error err : sr.getErrors()) {
							AV_LogDebug.printLogDebug(methodName, 'Error: '+err.getMessage());
							response = response+' | Delete Task -> '+ err.getMessage();
						}
					}
				}
			}
			if (backAll.deleteIdEventInsert != null && !backAll.deleteIdEventInsert.isEmpty()) {
					List<Event> listEventDelete = new List<Event>();
					for (String idEvent : backAll.deleteIdEventInsert) {
						listEventDelete.add(new Event(Id=idEvent));
					}
				List<Database.DeleteResult> listSrDelete = Database.delete(listEventDelete,false);
				for (Database.DeleteResult sr: listSrDelete) {
					if(!sr.isSuccess()) {           
						for(Database.Error err : sr.getErrors()) {
							AV_LogDebug.printLogDebug(methodName, 'Error: '+err.getMessage());
							response = response+' | Delete Event -> '+err.getMessage();
						}
					}
				}
			}
			if (backAll.updateTaskUpdated != null && !backAll.updateTaskUpdated.isEmpty()) {
				List<Database.SaveResult> listSr = Database.update(backAll.updateTaskUpdated, false);
				for (Database.SaveResult sr: listSr) {
					if(!sr.isSuccess()) {           
						for(Database.Error err : sr.getErrors()) {
							AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
							response = response+' | Update Task -> '+err.getMessage();
						}
					}
				}
			}
			if (backAll.deleteIdCommentsHistoryInsert != null && !backAll.deleteIdCommentsHistoryInsert.isEmpty()) {
				List<AV_CommentsHistory__c> listCommentHistoryDelete = new List<AV_CommentsHistory__c>();
				for (String idCH : backAll.deleteIdCommentsHistoryInsert) {
					listCommentHistoryDelete.add(new AV_CommentsHistory__c(Id=idCH));
				}
				List<Database.DeleteResult> listSrDelete = Database.delete(listCommentHistoryDelete,false);
				for (Database.DeleteResult sr: listSrDelete) {
					if(!sr.isSuccess()) {           
						for(Database.Error err : sr.getErrors()) {
							AV_LogDebug.printLogDebug(methodName, 'Error: '+err.getMessage());
							response = response+' | Delete Commment History -> '+err.getMessage();
						}
					}
				}
			}
		}
		return response;
	}


	/**
	 * @description                 Create Task-Opportunity
	 * @param jsonResultTaskEvent   String with result of create Task or Event with headers to associate with opportunity
	 * @return                      response witn error or OK
	 */
	@AuraEnabled
	public static String createTaskOpp(String jsonResultTaskEvent) {
		List<Database.SaveResult> srs;
		boolean hasErrors = false;
		List<AV_CustomActivityOpportunity__c> cao = new List<AV_CustomActivityOpportunity__c>();
		Savepoint sp = Database.setSavepoint();
		TaskEventGet resultTaskEvent = (TaskEventGet)Json.deserialize(jsonResultTaskEvent,TaskEventGet.class);
		
		if (resultTaskEvent.headerActivitys!= null && !resultTaskEvent.headerActivitys.isEmpty()) {
			for(String taskId : resultTaskEvent.headerActivitys.keySet()){
				String taskIdStr = (String) resultTaskEvent.headerActivitys.get(taskId).taskHeader;
				if (taskIdStr != null) {
					String taskName = (String) resultTaskEvent.headerActivitys.get(taskId).subject;
					String taskOrigenApp = (String) resultTaskEvent.headerActivitys.get(taskId).origenApp;
					if (taskOrigenApp != AV_AppConstants.CLIENT_REPORT_ORIGENAPP) {
						/*
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
						*/
						if (taskOrigenApp ==  'AV_SFReportNoLocalizado'){
							for (String oppoId : resultTaskEvent.opportunities.keySet()) { //Para la tarea/event que se crea en el reporte
								cao.add(
									new AV_CustomActivityOpportunity__c(
										AV_Opportunity__c = (Id) resultTaskEvent.opportunities.get(oppoId).get('id'),
										AV_Task__c = taskIdStr,
										AV_IsMain__c = Boolean.valueOf(resultTaskEvent.opportunities.get(oppoId).get('mainVinculed')),
										AV_OrigenApp__c = 'AV_SFReportNoLocalizado'	
									)
								);
							}
						}else{
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
						}
						
					
					} else {
						for (String oppoId : resultTaskEvent.opportunities.keySet()) { //Para la tarea/event que se crea en el reporte
							cao.add(
								new AV_CustomActivityOpportunity__c(
									AV_Opportunity__c = (Id) resultTaskEvent.opportunities.get(oppoId).get('id'),
									AV_Task__c = taskIdStr,
									AV_IsMain__c = Boolean.valueOf(resultTaskEvent.opportunities.get(oppoId).get('mainVinculed')),
									AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP	
								)
							);
						}
					}
				}  
			}
		}
		if (cao != null && !cao.isEmpty()) {
			srs = Database.insert(cao,false);
			for(Database.SaveResult res : srs){
				if(!res.isSuccess()) {
					hasErrors = true;
					break; // Salimos del bucle si encontramos error
				}
			}
		}
		

		if (hasErrors) {
			Database.rollback(sp);
			return srs[0].getErrors()[0].getMessage(); // Devuelve el mensaje de error del primer registro fallido
		}
		return 'OK';
	}

	
	private static SObject createRecord(Map<Object,Object> eventOrTsk,Boolean isTask,RecordType rt, String nameOppMain,Boolean isNoLocalizadoActive){
		SObject recordToInsert; 
		if(isTask){
			recordToInsert = new Task();
		}else{
			recordToInsert = new Event();
		}
		recordToInsert.put('RecordTypeId',rt.Id);
		recordToInsert.put('WhatId', (Id) eventOrTsk.get('accountId'));
		
		
		if(isNoLocalizadoActive){
			recordToInsert.put('AV_OrigenApp__c', 'AV_SFReportNoLocalizado');  
		}else{
			recordToInsert.put('AV_OrigenApp__c', AV_AppConstants.CLIENT_REPORT_ORIGENAPP); 
		}
	
		recordToInsert.put('AV_ContactGenerateAppointment__c',AV_AppConstants.NO_GENERATE);
		if(!isTask){
			recordToInsert.put('AV_Tipo__c', (String) eventOrTsk.get('typeEvent'));
			if ((Boolean)eventOrTsk.get('comercial')) { //Si la cita es No comercial 
				recordToInsert.put('Subject', 'Gestión operativa');
				
			}else if (nameOppMain != null){
				recordToInsert.put('Subject', nameOppMain);
			}else {
				recordToInsert.put('Subject', 'Gestión operativa');
			}
			if (eventOrTsk.get('comment') != null) {
				recordToInsert.put('Description',(String) eventOrTsk.get('comment'));
			}
			recordToInsert.put('EndDateTime', formateDateTime((String) eventOrTsk.get('activityDateTime')));
			recordToInsert.put('StartDateTime',( (Datetime) recordToInsert.get('EndDateTime')).addMinutes(-1*(Integer.valueOf(eventOrTsk.get('duracion')))));
			recordToInsert.put('AV_MemorableInterview__c', eventOrTsk.get('memorableInterview'));
			if (eventOrTsk.get('office') != null) {
				recordToInsert.put('Location',(String) eventOrTsk.get('office'));
				recordToInsert.put('AV_BranchPhysicalMeet__c',(String) eventOrTsk.get('office'));
			}else if (eventOrTsk.get('location') != null) {
				recordToInsert.put('Location',(String) eventOrTsk.get('location'));
			}
			if (eventOrTsk.get('contactPerson') != null) {
				recordToInsert.put('WhoId',(String) eventOrTsk.get('contactPerson'));
			}
			recordToInsert.put('CSBD_Evento_Estado__c',AV_AppConstants.EVENT_STATUS_CERRADO);
		}else{
			recordToInsert.put('AV_Tipo__c', (String) eventOrTsk.get('typeTask'));
			if ((String)eventOrTsk.get('typeTask') == AV_AppConstants.ACT_TYPE_MURO) {
				recordToInsert.put('Subject', 'Muro');
			} else if ((String)eventOrTsk.get('typeTask') == AV_AppConstants.ACT_TYPE_TASK_OFFI) {
				recordToInsert.put('Subject', 'Tarea oficina');
			}else if ((String)eventOrTsk.get('typeTask') == AV_AppConstants.ACT_TYPE_EMAIL_SMS) {
				recordToInsert.put('Subject', 'Email, sms');
			}
			else{
				recordToInsert.put('Subject', 'No localizado');
			}
		    
			recordToInsert.put('ActivityDate', System.today());
			recordToInsert.put('Status',(String) eventOrTsk.get('statusTask'));
			recordToInsert.put('Priority','A');
			recordToInsert.put('Description',(String) eventOrTsk.get('comentaryTask'));
			
		}
		return recordToInsert;
	}
	
	private static Date formatDate(String dateToFormat){
		String[] splitedDate = dateToFormat.split(AV_AppConstants.DASH);//Split by '-'
		Integer year = Integer.valueOf(splitedDate[0]);
		Integer month = Integer.valueOf(splitedDate[1]);
		Integer day = Integer.valueOf(splitedDate[2]);
		return date.newInstance(year,month,day);
	}

	private static Datetime formateDateTime(String dateToFormat){
		String[] splitedDate = dateToFormat.split('T');
		String[] dateInfo = splitedDate[0].split(AV_AppConstants.DASH);
		Integer year = Integer.valueOf(dateInfo[0]);
		Integer month = Integer.valueOf(dateInfo[1]);
		Integer day = Integer.valueOf(dateInfo[2]);
		String[] timeInfo = splitedDate[1].split(AV_AppConstants.COLON);
		Integer hour = Integer.valueOf(timeInfo[0]);
		Integer minutes = Integer.valueOf(timeInfo[1]);
		return datetime.newInstanceGmt(year,month,day,hour,minutes,0);
	}

	@AuraEnabled
	public static OppResulWrap unWrappOpportunities(Map<String,Map<Object,Object>> opportunities,String accountId, Boolean isInsert,Boolean isNoLocalizado){
		Savepoint sp = Database.setSavepoint();
		boolean hasErrors = false;
		List<Opportunity> listOpp = new List<Opportunity>();
		String result = 'OK';
		List<String> listIds = new List<String>();
		Map<String,Opportunity> mapOldOpp = new Map<String,Opportunity> ();
		List<String> opposId = new List<String>();
		List<String> listAllIds = new List<String>();
		List<Database.SaveResult> srOppos = new List<Database.SaveResult>();
		for(String oppoId : opportunities.keySet()){
			Map<Object,Object> wrappedOppo = opportunities.get(oppoId);
			if(((Boolean) wrappedOppo.get('validable'))){
				Opportunity nextOppo = new Opportunity();
				nextOppo.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
				if(!oppoId.contains('idProvisional')){
					nextOppo.Id = (Id) wrappedOppo.get('id');
					listIds.add(nextOppo.Id);
				}else{
					nextOppo.RecordTypeId = AV_AppUtilities.getRecordType(
						AV_AppConstants.OBJECT_NAME_OPPORTUNITY,
						AV_AppConstants.OPPINICIATIVA_RT
					).Id;
					nextOppo.AV_PF__c = (Id) wrappedOppo.get('ProdId');
				}
				if(wrappedOppo.get('Name') != null) {
					nextOppo.Name = (String) wrappedOppo.get('Name');
				}
				if(wrappedOppo.get('newPath') != null) {
					nextOppo.StageName = (String) wrappedOppo.get('newPath');
				}
				if(wrappedOppo.get('proximaGestion') != null) {
					nextOppo.AV_FechaProximoRecordatorio__c = (Date) formatDate((String) wrappedOppo.get('proximaGestion'));
				}

				if(wrappedOppo.get('expectativa') != null) {
					nextOppo.AV_Potencial__c = (String) wrappedOppo.get('expectativa');
				}
				if(wrappedOppo.get('resolucion') != null) {
					nextOppo.AV_Resolucion__c = (String) wrappedOppo.get('resolucion');
				}
				if(wrappedOppo.get('importe') != null) {
					nextOppo.AV_AmountEuro__c = Decimal.valueOf(((String)wrappedOppo.get('importe')).replace(',', '.'));
				}
				if(wrappedOppo.get('comentario') != null) {
					nextOppo.AV_Comentarios__c = (String) wrappedOppo.get('comentario');
				}
				if(wrappedOppo.get('tenencia') != null) {
					nextOppo.AV_Tenencia__c = (Boolean.valueOf(wrappedOppo.get('tenencia'))) ? 'S' : 'N';
				}
				if(wrappedOppo.get('otraEntidad') != null) {
					nextOppo.AV_Entidad__c = (String) wrappedOppo.get('otraEntidad');
				}
				if(wrappedOppo.get('fechaOtraEntidad') != null) {
					nextOppo.AV_FechaVencimiento__c = (Date) formatDate( (String) wrappedOppo.get('fechaOtraEntidad'));
				}
				if(wrappedOppo.get('subProducto') != null) {
					nextOppo.AV_ByProduct__c = (Id) wrappedOppo.get('subProducto');
				} 
				if(wrappedOppo.get('margin') != null) {
					nextOppo.AV_MarginEuro__c = Decimal.valueOf(((String)wrappedOppo.get('margin')).replace(',', '.'));
				}
				if(wrappedOppo.get('importeOtraEntidad') != null) {
					nextOppo.Amount = Decimal.valueOf(((String)wrappedOppo.get('importeOtraEntidad')).replace(',', '.'));
				}
				if(wrappedOppo.get('cuota') != null) {
					nextOppo.AV_Cuota__c = Double.valueOf(((String)wrappedOppo.get('cuota')).replace(',', '.'));
				}
				if(isNoLocalizado){
					if(wrappedOppo.get('subestado') != null) {
						nextOppo.AV_Subestado__c = (String) wrappedOppo.get('subestado');
					}
				}
				if(wrappedOppo.get('owneridopp') != null) {
					nextOppo.OwnerId = (String) wrappedOppo.get('owneridopp');
				} 
				if(wrappedOppo.get('closedate') != null) {
					nextOppo.CloseDate = (Date) formatDate( (String) wrappedOppo.get('closedate'));
				}
				if(wrappedOppo.get('agendado') != null && wrappedOppo.get('newPath') != null && !(Boolean.valueOf(wrappedOppo.get('agendado'))) && wrappedOppo.get('newPath') == AV_AppConstants.OPP_STATUS_ENGESTION) {
					nextOppo.AV_IncludeInPrioritizingCustomers__c = true;
				} else if (wrappedOppo.get('newPath') != AV_AppConstants.OPP_STATUS_ENGESTION) {
					nextOppo.AV_IncludeInPrioritizingCustomers__c = false;
				}
				if (accountId != null) {
					nextOppo.AccountId = accountId;
				}
				
				if(wrappedOppo.get('noofrecerhasta') != null){
					nextOppo.AV_NoOfrecerHasta__c = (Date) formatDate( (String) wrappedOppo.get('noofrecerhasta')); 
				}	
				listOpp.add(nextOppo);
			}else{
				opposId.add(oppoId);
				listIds.add(oppoId);
			}
		}
		if (listIds != null && !listIds.isEmpty()) {
			List<Opportunity> listOldOpp = [Select Id, AV_IncludeInPrioritizingCustomers__c,AV_FechaProximoRecordatorio__c, StageName, AV_Potencial__c, Amount, CloseDate, AV_Cuota__c, AV_Resolucion__c, AV_AmountEuro__c, AV_Comentarios__c, AV_Tenencia__c, AV_Entidad__c, AV_FechaVencimiento__c,AV_MarginEuro__c, AV_ByProduct__c,AV_Channel__c,AV_Subestado__c,OwnerId from Opportunity where Id in :listIds WITH SECURITY_ENFORCED];  
			if (listOldOpp != null && !listOldOpp.isEmpty()) {
				for(Opportunity opp: listOldOpp) {
					mapOldOpp.put(opp.Id,opp);
				}
			}
		}
		if (isInsert) {
			srOppos = Database.insert(listOpp,false);
			for(Database.SaveResult ur : srOppos){
				if(!ur.isSuccess()) {
					hasErrors = true;
					result = ur.getErrors()[0].getMessage();
					break; // Sal del bucle
				} else {
					opposId.add(ur.getId());
				}
			}
		} else {
			srOppos = Database.update(listOpp,false);
			for(Database.SaveResult ur : srOppos){
				if(!ur.isSuccess()) {
					hasErrors = true;
					result = ur.getErrors()[0].getMessage();
					break; // Sal del bucle
				} else {
					opposId.add(ur.getId());
				}
			}
		}
		if (hasErrors) {
			Database.rollback(sp);
		}

		OppResulWrap resultAll = new OppResulWrap();
		resultAll.mapOldOpp = mapOldOpp;
		resultAll.opposId = opposId;
		resultAll.results = result;
		return resultAll;
	}

	private static List<Task> unWrappTask(Map<String,Map<Object,Object>> tasks, Map<Object,Object> eventOrTsk, Boolean isTask){
		List<Task> taskToUpdt = new List<Task>();
		for(String tskId : tasks.keySet()){
			Task nextTsk = new Task();
			Map<Object,Object> tsk = tasks.get(tskId);
			if(tsk.get('id') != null ){
				nextTsk.Id = (Id) tsk.get('id');
			}
			if(tsk.get('status') != null ){
				nextTsk.Status = (String) tsk.get('status');
			}
			if(tsk.get('owner') != null ){
				nextTsk.OwnerId = (String) tsk.get('owner');
			}
			if (isTask) {
				nextTsk.ActivityDate = System.today();
			} else {
				nextTsk.ActivityDate =  date.newinstance(formateDateTime((String) eventOrTsk.get('activityDateTime')).year(), formateDateTime((String) eventOrTsk.get('activityDateTime')).month(), formateDateTime((String) eventOrTsk.get('activityDateTime')).day());
			}
			if(tsk.get('comment') != null ){
				nextTsk.Description = (String) tsk.get('comment');
			}
			if(isTask) {
				nextTsk.AV_Tipo__c = (String) eventOrTsk.get('typeTask');
			} else {
				nextTsk.AV_Tipo__c = (String) eventOrTsk.get('typeEvent');
			}
			taskToUpdt.add(nextTsk);
		}
		return taskToUpdt;
	}

	@AuraEnabled
	public static List<AV_LookupSearchResult> searchProduct(String searchTerm, List<String> selectedIds, String accountId) {
		String methodName = 'searchProduct';
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		Set<String> rts = new Set<String>{
			AV_AppConstants.OPPALERTACOM_RT, 
			AV_AppConstants.OPPPROPUESTA_RT,
			AV_AppConstants.OPPSUGERENCIA_RT, 
			AV_AppConstants.OPPINICIATIVA_RT,
			AV_AppConstants.OPPLLAMADA_RT
		};
		Set<String> openStatusInitiativeRT = new Set<String>{
			AV_AppConstants.OPP_STATUS_POTENCIAL, 
			AV_AppConstants.OPP_STATUS_ENGESTION,
			AV_AppConstants.OPP_STATUS_NOAPTO,
			AV_AppConstants.OPP_STATUS_VENCIDO,
			AV_AppConstants.OPP_STATUS_NO_GESTIONADA
		};
		List<String> listProductIds = new List<String>();
		List<Opportunity> listOpp = [SELECT AV_PF__c FROM Opportunity WHERE AccountId = :accountId AND (StageName  IN :openStatusInitiativeRT AND RecordType.DeveloperName IN :rts) WITH SECURITY_ENFORCED]; 
		if (listOpp != null && !listOpp.isEmpty()) {
			for (Opportunity o : listOpp) {
				if(o.AV_PF__c != null) {
					listProductIds.add(o.AV_PF__c);
				}
			}
		}
		if(selectedIds != null && !selectedIds.isEmpty()){
			if (listProductIds != null && !listProductIds.isEmpty()) {
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
						Product2(Id, Name, AV_ExternalID__c,AV_NewReportActions__c WHERE Id NOT IN :selectedIds and Id NOT IN :listProductIds and RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true)
					LIMIT :MAXRESULTS
				];
			} else {
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
						Product2(Id, Name, AV_ExternalID__c,AV_NewReportActions__c WHERE Id NOT IN :selectedIds and RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true)
					LIMIT :MAXRESULTS
				];
			}
		} else{
			if (listProductIds != null && !listProductIds.isEmpty()) {
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
						Product2(Id, Name, AV_ExternalID__c,AV_NewReportActions__c WHERE Id NOT IN :listProductIds and RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true)
					LIMIT :MAXRESULTS
				];
			} else {
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
						Product2(Id, Name, AV_ExternalID__c,AV_NewReportActions__c WHERE RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true)
					LIMIT :MAXRESULTS
				];
			}
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

	/**
	* @description                      Procces owners of Opportunity where create a Opportunity type Iniciativa so fill the fields and send to API Oppotunity
	* @param  listIdsOppUpdateCreated   list of new Opportunity records and update records
	*/
	@AuraEnabled
	public static string sendOppToGCF(List<String> listIdsOppUpdateCreated,String  newEvTsk){
		String result = 'OK';
		String methodName = 'sendOppToGCF';
		if (listIdsOppUpdateCreated != null && !listIdsOppUpdateCreated.isEmpty()) {
			List<Opportunity> listToGcf = new List<Opportunity>();
			List<Opportunity> listOpp = [Select Id, RecordType.DeveloperName, AV_ExternalId__c, AV_IncludeInPrioritizingCustomers__c,AV_FechaProximoRecordatorio__c, StageName, AV_Potencial__c, Amount, CloseDate, AV_Cuota__c, AV_Resolucion__c, AV_AmountEuro__c, AV_Comentarios__c, AV_Tenencia__c, AV_Entidad__c, AV_FechaVencimiento__c,AV_MarginEuro__c, AV_ByProduct__c,AV_Channel__c,AV_Subestado__c,OwnerId from Opportunity where Id in :listIdsOppUpdateCreated WITH SECURITY_ENFORCED];
			List<Opportunity> lstOppToUpdt = new List<Opportunity>(); 

			
			if (listOpp != null && !listOpp.isEmpty()) {
				for (Opportunity opp : listOpp) {
					opp.AV_Channel__c = newEvTsk; 
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

	
	@AuraEnabled(cacheable=true)
	public static Map<String,User> getUserInfo() {
		List<User> mainUser =  [SELECT Id, Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_Pool__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		Map<String,User> response = new Map<String,User>{'gestor' => mainUser[0]};
		String multige = AV_PoolEvents_Controller.getCurrentDT(mainUser[0].AV_NumeroOficinaEmpresa__c);
		if(multige != null){
				response.put('multigestor',new User(Id = multige));
		}
		return response;
	}
	
}