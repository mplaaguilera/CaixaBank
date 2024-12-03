/**********************************************************************************************************************
 Name:      AV_MassReassignOwnerOppsBPR_Controller
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for av_MassReassignOwnerOpps LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION  USER_STORY			AUTHOR				DATE        Description
   	1.0		 US692335			Elisabeth R.		16/10/2023		Init version
   	1.1		 Fix			    Elisabeth R.		08/11/2023		Added assign method

***********************************************************************************************************************/
public with sharing class AV_MassReassignOwnerOppsBPR_Controller {

	private final static Integer MAX_RESULTS 	= 10;
    private final static Integer MAX_LIMIT 		= 49900;
    private final static String  ID_GCF			= (String) [SELECT Id FROM User WHERE Alias = :AV_AppConstants.AV_ALIAS_AVTF9 WITH SECURITY_ENFORCED LIMIT 1].Id;
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
		User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
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
		query += ' ORDER BY Account.AV_InterlocName__c,CloseDate  ASC LIMIT ' + Integer.valueOf(page)*100 + ' OFFSET ' + (Integer.valueOf(page)-1)*100;
		query = query.replaceAll('[{}]', '');
		AV_LogDebug.printLogDebug(methodName, '-----> Query to execute: ' + query);
		totalSize = '1'.equals(page) ? getNumberOfOpps(countQuery) : -1;
		String queryToExec = headerQuery + query;
		List<Opportunity> lista = capsulateQuery(queryToExec);

		ObjectList resultObject = new ObjectList();
        Set <Id> idSet = new Set<Id>();

		if(lista != null && !lista.isEmpty()){

			for(Opportunity o : lista){
				idSet.add(o.AccountId);
			}
			Map <Id, Account> accountIdObjMap;
			Map<Id,AV_GrupoInterlocucion__c> clientGroupMap = new Map<Id,AV_GrupoInterlocucion__c>();
			List<AV_GrupoInterlocucion__c> interlocutionGroup = [SELECT Name, AV_Numper__c, AV_Numper__r.Name, AV_IsInterlocutor__c FROM AV_GrupoInterlocucion__c WHERE AV_Numper__c IN :idSet AND RecordType.DeveloperName =: AV_AppConstants.INTERLOC_GROUP_RT];
								
			if(interlocutionGroup != null && !interlocutionGroup.isEmpty()){

				for(AV_GrupoInterlocucion__c ig : interlocutionGroup){


					clientGroupMap.put(ig.AV_Numper__c,ig);
				}

			}

			List<OpportunityWrapper> wrapperList = new List<OpportunityWrapper>();

			for(Opportunity o: lista){

				OpportunityWrapper oppWrapper = new OpportunityWrapper();
				oppWrapper.ahorro = o.Account.AV_AhorroEInversion__c;
				oppWrapper.financiacion = o.Account.AV_Financiacion__c;
				oppWrapper.ingresos = o.Account.AV_Ingresos__c;
				oppWrapper.origen = o.AV_Origen__c;
				oppWrapper.accountId = o.AccountId;
				oppWrapper.accountName = o.Account.Name;
				oppWrapper.preconcedido = o.Account.AV_Preconceived__c;
				oppWrapper.myBox = o.Account.AV_MyBox__c;
				oppWrapper.targetAuto = o.Account.AV_TargetAuto__c;
                oppWrapper.age = o.Account.AV_Age__c;
				oppWrapper.closeDate = o.CloseDate;
				oppWrapper.oppId = o.Id;
				oppWrapper.ownerId = o.OwnerId;
				oppWrapper.ownerName = o.Owner.Name;
				oppWrapper.center = o.AV_Center__c;
				oppWrapper.pfId = o.AV_PF__c;
                oppWrapper.pfName = o.AV_PF__r.Name;
                oppWrapper.product = o.AV_Product__c;
                oppWrapper.includeInPrioritizingCustomers = o.AV_IncludeInPrioritizingCustomers__c;
                oppWrapper.potencial = o.AV_Potencial__c;
				oppWrapper.fechaProxRecordatorio = o.AV_FechaProximoRecordatorio__c;
				oppWrapper.stage = o.StageName;
				oppWrapper.gestor = o.AV_Gestor__c;
				oppWrapper.recordTypeId = o.RecordTypeId;
				oppWrapper.recordTypeName = o.RecordType.Name;
				oppWrapper.oppName = o.Name;
				oppWrapper.groupInterlocutor = o.Account.AV_Group__c;
				oppWrapper.interlocutor = o.Account.AV_InterlocName__c;
                oppWrapper.interlocutionGroup = clientGroupMap.get(o.AccountId);
				wrapperList.add(oppWrapper);
			}

			resultObject = new ObjectList('Opportunity', totalSize, wrapperList);
		}

		return resultObject;
	}
	
	/**
	 * @description		Change Quality Cloud
	 */
	private static List<Opportunity> capsulateQuery(String q){
		return (List<Opportunity>) Database.query(q);
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
	 * @description		Assigment Opportunity to new Owner
	 * @param	objectName	The name of the object being assigned.
	 * @param	contactId	The ID of the contact for the assignment.
	 * @param selectedRows	 A list of sObjects representing the selected rows for the assignment.
	 */
	@AuraEnabled
	public static String assign(String objectName , String contactId, List<String> selectedRowIds){
		Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.OptAllOrNone = false;
		dmlOptions.EmailHeader.triggerUserEmail = false;
		List<Opportunity> oppos = new List<Opportunity>();
		for(String o : selectedRowIds){
			Opportunity oppo = new Opportunity(Id = o, OwnerId = contactId);
			oppos.add(oppo);
		}
		Database.SaveResult[] srList = Database.update(oppos, dmlOptions);
		return String.valueOf(srList.size());
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
		public List<OpportunityWrapper> recordList;
                
		public ObjectList(String objectName, Integer totalSize, List<OpportunityWrapper> recordList) {
			this.objectName = objectName;
			this.totalSize = totalSize;
			this.recordList = recordList;
		}
        
        public ObjectList() {
            this.objectName = '';
            this.totalSize = 0;
        	this.recordList = new List<OpportunityWrapper>();
        }

		public void add(ObjectList ol) {
			this.totalSize += ol.totalSize;
			this.recordList.addAll(ol.recordList);
		}
	}


    public class OpportunityWrapper {
		@AuraEnabled
		public Decimal ahorro;
        @AuraEnabled
		public Decimal financiacion;
        @AuraEnabled
		public Decimal ingresos;
        @AuraEnabled
		public String center;
        @AuraEnabled
		public String gestor;
        @AuraEnabled
		public Boolean includeInPrioritizingCustomers;
        @AuraEnabled
		public String origen;
        @AuraEnabled
		public String pfId;
        @AuraEnabled
		public String pfName;
        @AuraEnabled
		public String product;
        @AuraEnabled
		public String potencial;
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
		public Date fechaProxRecordatorio;
        @AuraEnabled
		public Date closeDate;
        @AuraEnabled
		public String oppId;
        @AuraEnabled
		public String ownerId;
        @AuraEnabled
		public String ownerName;
        @AuraEnabled
		public String recordTypeId;
        @AuraEnabled
		public String recordTypeName;
        @AuraEnabled
		public String stage;
        @AuraEnabled
		public String oppName;
        @AuraEnabled
		public String groupInterlocutor;
        @AuraEnabled
		public String interlocutor;
		@AuraEnabled
		public AV_GrupoInterlocucion__c interlocutionGroup;
	}

}