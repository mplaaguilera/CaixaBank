/**********************************************************************************************************************
 Name:      AV_BuscadorLeadOpp_Controller
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller class for av_BuscadorLeadOpp LWC
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   	VERSION  USER_STORY				AUTHOR				DATE        Description
   	1.0      US374367			Vladislav Lityagin		30/05/2022  Init version
	1.1		 US405453			Vladislav Lityagin		08/08/2022  Add searchNoAccount, getOriginValues
	1.2		 US450961			Oscar Moreno Rodriguez	27/09/2022	Add getProducto
	1.3		 US461262			Oscar Moreno Rodriguez	28/10/2022	Add getStageValues, getPendingReasonValues, getStatusValues, getResolutionValues
	1.4		 Fix PMD Errors		Daniel Rodriguez		30/10/2023	Add queries WITH SECURITY_ENFORCED 
***********************************************************************************************************************/
public with sharing class AV_BuscadorLeadOpp_Controller {

    private final static Integer MAX_RESULTS 	= 10;
    private final static Integer MAX_LIMIT 		= 49900;
    private final static String  ID_GCF			= [SELECT Id FROM User WHERE AV_ProfileName__c = 'API Only' AND Alias = 'AV-TF9' WITH SECURITY_ENFORCED  LIMIT 1].Id;
	public static Integer numberOfRecords;

    @AuraEnabled
    public static ObjectList getBaseData(Date creationDateFilterFrom, Date creationDateFilterUntil, String[] originMultiFilter, String[] empresaMultiFilter , String[] productoMultiFilter, Boolean altaClienteFilter,String[] statusMultiFilter, String[] stageMultiFilter, String clientFilter, String noClientFilter, String[] employeMultiFilter, String[] pendingReasonMultiFilter, String[] resolutionMultiFilter, Date dueDateFilterFrom, Date dueDateFilterUntil, Date closeDateFilterFrom, Date closeDateFilterUntil, double incomeAmountFilterFrom,double incomeAmountFilterUntil ,String page, String office) {
		ObjectList result = new ObjectList();

		Date creationDateUntil=null;
		Date dueDateUntil=null;
		Date closeDateUntil=null;
		if(creationDateFilterUntil!=null){
			creationDateUntil=creationDateFilterUntil.addDays(1);
		} 
		if(dueDateFilterUntil!=null){
			dueDateUntil=dueDateFilterUntil.addDays(1);
		} 
		if(closeDateFilterUntil!=null){
			closeDateUntil=closeDateFilterUntil.addDays(1);
		} 
        
		result = getLeadOppsFilter(creationDateFilterFrom, creationDateUntil, originMultiFilter, empresaMultiFilter,productoMultiFilter, altaClienteFilter,statusMultiFilter, stageMultiFilter, clientFilter, noClientFilter, employeMultiFilter, pendingReasonMultiFilter, resolutionMultiFilter, dueDateFilterFrom, dueDateUntil, closeDateFilterFrom, closeDateUntil,incomeAmountFilterFrom,incomeAmountFilterUntil,page, office);
		return result;
    }

	private static String setToString (List<String> setToTransform){
		String result='(\'\')';

		if(!setToTransform.isEmpty()){
			Integer i=0;
			result= '(';
		for(String str : setToTransform){
			result += '\''+str+'\'';
			result += ((++i)!=setToTransform.size())?',':')';
		}
		
	    }
		return result;
    }

	
	private static String setToString (Set<String> setToTransform){
		String result='(\'\')';

		if(!setToTransform.isEmpty()){
			Integer i=0;
			result= '(';
		for(String str : setToTransform){
			result += '\''+str+'\'';
			result += ((++i)!=setToTransform.size())?',':')';
		}
		
	    }
		return result;
    }
    
    
    private static ObjectList getLeadOppsFilter(Date creationDateFilterFrom, Date creationDateFilterUntil, String[] originMultiFilter, String[] empresaMultiFilter,String[] productoMultiFilter, Boolean altaClienteFilter, String[] statusMultiFilter, String[] stageMultiFilter, String clientFilter, String noClientFilter, String[] employeMultiFilter, String[] pendingReasonMultiFilter, String[] resolutionMultiFilter, Date dueDateFilterFrom, Date dueDateFilterUntil, Date closeDateFilterFrom, Date closeDateFilterUntil,double incomeAmountFilterFrom,double incomeAmountFilterUntil,String page, String office) {
		String methodName = 'getLeadOppsFilter';
		Integer totalSize;
		User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
		
		Set<String> stageNull = new Set<String>{AV_AppConstants.LEADOPP_STAGE_POTENCIAL, AV_AppConstants.LEADOPP_STAGE_GESTION,AV_AppConstants.LEADOPP_STAGE_NEGATIVA,AV_AppConstants.LEADOPP_STAGE_POSITIVA,AV_AppConstants.LEADOPP_STAGE_NO_APTO,AV_AppConstants.LEADOPP_STAGE_VENCIDA,AV_AppConstants.LEADOPP_STAGE_VENTA,''};
		String avQuery = 'SELECT Id, Name, AV_Lead__r.Name, AV_Lead__r.AV_NumPerso__r.AV_OficinaPrincipal__r.CC_Numero_Oficina__c, AV_CreationDate__c, AV_Lead__r.AV_numperso__r.Name, AV_Lead__r.AV_numperso__c, AV_Lead__c, AV_PrescriberId__c,AV_Empresa__c, AV_Producto__c,AV_Producto__r.Name,AV_Lead__r.AV_IsClient__c,tolabel(AV_Status__c), AV_StatusLeadOpp__c, Owner.Name, AV_PendingReason__c, AV_Resolution__c, AV_DueDate__c, AV_FechaCierreGestion__c, AV_IncomeAmount__c  FROM AV_LeadOpportunity__c';
		String recordTypeName = 'AV_PlataformasHipotecarias';
		String countQuery = 'SELECT COUNT(Id) FROM AV_LeadOpportunity__c';
		if(stageMultiFilter.size()!=0){
			avQuery = avQuery + ' WHERE AV_StatusLeadOpp__c in '+ setToString(stageMultiFilter) +' AND RecordType.DeveloperName = \'' + recordTypeName + '\'';
			countquery += ' WHERE AV_StatusLeadOpp__c in '+ setToString(stageMultiFilter) +' AND RecordType.DeveloperName = \'' + recordTypeName + '\'';
		}else{
			avQuery = avQuery + ' WHERE AV_StatusLeadOpp__c in '+ setToString(stageNull) +' AND RecordType.DeveloperName = \'' + recordTypeName + '\'';
			countquery += ' WHERE AV_StatusLeadOpp__c in '+ setToString(stageNull) +' AND RecordType.DeveloperName = \'' + recordTypeName + '\'';
		}

		if(creationDateFilterFrom!=null){
			DateTime fecha=adjustJSTtoGMS(creationDateFilterFrom);
			avQuery = avQuery + ' AND AV_CreationDate__c > ' + fecha.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
			countQuery += ' AND AV_CreationDate__c > ' + fecha.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
		}
		if(creationDateFilterUntil!=null){
			DateTime fecha=adjustJSTtoGMS(creationDateFilterUntil);
			avQuery = avQuery + ' AND AV_CreationDate__c < '+ fecha.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
		}

		if(originMultiFilter.size()!=0){
			avQuery = avQuery + ' AND AV_PrescriberId__c in '+ setToString(originMultiFilter);
			countQuery += ' AND AV_PrescriberId__c in '+ setToString(originMultiFilter);
		}

		if(empresaMultiFilter.size()!=0){
			avQuery = avQuery + ' AND AV_Empresa__c in '+ setToString(empresaMultiFilter);
			countQuery += ' AND AV_Empresa__c in '+ setToString(empresaMultiFilter);
		}
		if(productoMultiFilter.size()!=0){
		 	avQuery = avQuery + ' AND AV_Producto__r.Name in '+ setToString(productoMultiFilter);
		 	countQuery += ' AND AV_Producto__r.Name in '+ setToString(productoMultiFilter);
		}

		if(altaClienteFilter!=null){
			avQuery = avQuery + ' AND AV_Lead__r.AV_IsClient__c = ' + altaClienteFilter; 
			countQuery += ' AND AV_Lead__r.AV_IsClient__c = ' + altaClienteFilter; 
		}

		
		if(statusMultiFilter.size()!=0){
			avQuery = avQuery + ' AND AV_Status__c in '+ setToString(statusMultiFilter);
			countQuery += ' AND AV_Status__c in '+ setToString(statusMultiFilter);
		}

		if(clientFilter!=null){
			avQuery = avQuery + ' AND AV_Lead__r.AV_numperso__c = \'' + clientFilter+ '\'';
			countQuery += ' AND AV_Lead__r.AV_numperso__c = \'' + clientFilter+ '\'';
		}

		if(noClientFilter!=null){
			avQuery = avQuery + ' AND (AV_Lead__r.Id =  \'' + noClientFilter + '\'' + ' OR AV_Lead2__r.Id = \'' + noClientFilter+ '\')';
			countQuery += ' AND (AV_Lead__r.Id =  \'' + noClientFilter + '\'' + ' OR AV_Lead2__r.Id = \'' + noClientFilter+ '\')';
		}

		if(pendingReasonMultiFilter.size()!=0){
			avQuery = avQuery + ' AND AV_PendingReason__c in ' + setToString(pendingReasonMultiFilter);
			countQuery += ' AND AV_PendingReason__c in ' + setToString(pendingReasonMultiFilter);
		}
		if(resolutionMultiFilter.size()!=0){
			avQuery = avQuery + ' AND AV_Resolution__c in '+ setToString(resolutionMultiFilter);
			countQuery += ' AND AV_Resolution__c in '+ setToString(resolutionMultiFilter);
		}
		if(dueDateFilterFrom!=null){
			avQuery = avQuery + ' AND AV_DueDate__c > ' + formatearFecha(dueDateFilterFrom);
			countQuery += ' AND AV_DueDate__c > ' + formatearFecha(dueDateFilterFrom);
		}
		if(dueDateFilterUntil!=null){
			avQuery = avQuery + ' AND AV_DueDate__c < ' + formatearFecha(dueDateFilterUntil);
			countQuery += ' AND AV_DueDate__c < ' + formatearFecha(dueDateFilterUntil);
		}
		if(closeDateFilterFrom!=null){
			avQuery = avQuery + ' AND AV_FechaCierreGestion__c >= ' + formatearFecha(closeDateFilterFrom);
			countQuery += ' AND AV_FechaCierreGestion__c >= ' + formatearFecha(closeDateFilterFrom);
		}
		if(closeDateFilterUntil!=null){
			avQuery = avQuery + ' AND AV_FechaCierreGestion__c < ' + formatearFecha(closeDateFilterUntil);
			countQuery += ' AND AV_FechaCierreGestion__c < ' + formatearFecha(closeDateFilterUntil);
		}
		if(incomeAmountFilterFrom!=null ){		
			avQuery = avQuery + ' AND  AV_IncomeAmount__c >' + incomeAmountFilterFrom;
			countQuery += ' AND  AV_IncomeAmount__c >' + incomeAmountFilterFrom;
		}

		if(incomeAmountFilterUntil!=null ){
			avQuery = avQuery + ' AND  AV_IncomeAmount__c < ' + incomeAmountFilterUntil;
			countQuery += ' AND  AV_IncomeAmount__c < ' + incomeAmountFilterUntil;
		}
		
		
		if(employeMultiFilter.size() != 0) {
			if (ID_GCF.equalsIgnoreCase(employeMultiFilter[0]) && employeMultiFilter.size()==1) {
				avQuery = avQuery + ' AND OwnerId = \''+ID_GCF+'\' AND AV_Lead__r.AV_NumPerso__r.AV_OficinaPrincipal__r.CC_Numero_Oficina__c = \''+office+'\'';
				countQuery += ' AND OwnerId = \''+ID_GCF+'\' AND AV_Lead__r.AV_NumPerso__r.AV_OficinaPrincipal__r.CC_Numero_Oficina__c = \''+office+'\'';
            
			} else if (employeMultiFilter[0].contains(ID_GCF) && employeMultiFilter.size()==1) {
				avQuery = avQuery + ' AND (OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeMultiFilter[0].remove(ID_GCF+',').split(','))+' OR (OwnerId = \''+ID_GCF+'\' AND AV_Lead__r.AV_NumPerso__r.AV_OficinaPrincipal__r.CC_Numero_Oficina__c = \''+office+'\'))';
				countQuery += ' AND (OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeMultiFilter[0].remove(ID_GCF+',').split(','))+' OR (OwnerId = \''+ID_GCF+'\' AND AV_Lead__r.AV_NumPerso__r.AV_OficinaPrincipal__r.CC_Numero_Oficina__c = \''+office+'\'))';
            
			} else if (employeMultiFilter.contains(ID_GCF)) {
				employeMultiFilter.remove(employeMultiFilter.indexOf(ID_GCF));
				avQuery = avQuery + ' AND (OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeMultiFilter)+' OR (OwnerId = \''+ID_GCF+'\' AND AV_Lead__r.AV_NumPerso__r.AV_OficinaPrincipal__r.CC_Numero_Oficina__c = \''+office+'\'))';
				countQuery += ' AND (OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeMultiFilter)+' OR (OwnerId = \''+ID_GCF+'\' AND AV_Lead__r.AV_NumPerso__r.AV_OficinaPrincipal__r.CC_Numero_Oficina__c = \''+office+'\'))';
            
			} else {
				avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeMultiFilter);
				countQuery += ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeMultiFilter);
         
			}
		}

		Integer numRecords = capsulateCountQuery(countQuery);
		totalSize = '1'.equals(page) ? numRecords:-1;
		avQuery=avQuery + ' ORDER BY AV_CreationDate__c ASC NULLS FIRST LIMIT 100 OFFSET '+((Integer.valueOf(page)-1)*100);
		List <AV_LeadOpportunity__c> listLeOp= capsulateQuery(avQuery);
		

		return new ObjectList('AV_LeadOpportunity__c', totalSize, listLeOp);
	}


	

	public static String formatearFecha(Date fecha){
		DateTime f1= (DateTime)fecha;
		 return f1.format('yyyy-MM-dd');
	}

	public static  DateTime adjustJSTtoGMS(DateTime day){
		Time jstam = Time.newInstance(15, 0, 0, 0);
		return Datetime.newInstance(day.date(), jstam);
	}


	private static List<AV_LeadOpportunity__c> capsulateQuery(String q){
		return (List<AV_LeadOpportunity__c>)Database.query(q);
	}

	private static Integer capsulateCountQuery(String q){
		return Integer.valueOf(Database.query(q).get(0).get('expr0'));
	}
	

	@AuraEnabled
	public static String getOffice(){
		return [select AV_NumeroOficinaEmpresa__c from User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1].AV_NumeroOficinaEmpresa__c;
	}

	

	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchAccount(String searchTerm, List<String> selectedIds) {
		
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		
		Set<String> setStrings = new Set<String>();
		setStrings.add(AV_AppConstants.ACCOUNT_PA_RT);
		setStrings.add(AV_AppConstants.ACCOUNT_ENT_RT);
		if(!selectedIds.isEmpty()){
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Account(Id, Name, AV_Numperso__c, CC_Numero_Documento__c WHERE Id NOT IN :selectedIds and RecordType.DeveloperName IN :setStrings and AV_Numperso__c!=null and AV_Confidencial__c=false)
				LIMIT :MAX_RESULTS
			];
		} else{
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Account(Id, Name, CC_Numero_Documento__c WHERE RecordType.DeveloperName IN : setStrings and CC_Numero_Documento__c!=null and AV_Confidencial__c=false)
				LIMIT :MAX_RESULTS
			];

		}		

		String accountIcon = 'standard:account';
		Account[] listAccount = (List<Account>) searchResults[0];
		for (Account acc : listAccount) {
			results.add(
				new AV_LookupSearchResult(
					acc.Id,
					AV_AppConstants.OBJECT_NAME_ACCOUNT,
					accountIcon,
					acc.Name,
					'NIF/NIE/Pasaporte • ' + acc.CC_Numero_Documento__c 
				)
			);
		}
		results.sort();

		return results;
	}

	

	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchNoAccount(String searchTerm, List<String> selectedIds) {
		
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		Set<String> listRTs = new Set<String>();
		listRTs.add(AV_AppConstants.LEAD_PPHH_RT);
		if(!selectedIds.isEmpty()){
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Lead(Id, Name, AV_CustomerId__c WHERE Id NOT IN :selectedIds AND RecordType.DeveloperName IN :listRTs AND AV_IsClient__c != true)
				LIMIT :MAX_RESULTS
			];
		} else{
			searchResults = [
				FIND :searchTerm
				IN ALL FIELDS
				RETURNING
					Lead(Id, Name, AV_CustomerId__c WHERE RecordType.DeveloperName IN :listRTs AND AV_CustomerId__c!=null AND AV_IsClient__c != true)
				LIMIT :MAX_RESULTS
			];
	
		}		
	
		String leadIcon = 'standard:lead';
		Lead[] listLead = (List<Lead>) searchResults[0];
		for (Lead l : listLead) {
			results.add(
				new AV_LookupSearchResult(
					l.Id,
					AV_AppConstants.OBJECT_NAME_LEAD,
					leadIcon,
					l.Name,
					'NIF/NIE/Pasaporte • ' + l.AV_CustomerId__c 
				)
			);
		}
		results.sort();
	
		return results;
	}

	@AuraEnabled
	public static String assign(String contactId, List<sObject> selectedRows){
		Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.OptAllOrNone = false;
		dmlOptions.EmailHeader.triggerUserEmail = false;
		List<Id> leadOppIds = new List<Id>();
		for(sObject o : selectedRows){
			String tId = o.get('Id').toString();
			leadOppIds.add(tId);
		}
		futureUpdateLeadOpps(leadOppIds,contactId);
		return String.valueOf(leadOppIds.size());
		
	}

	@AuraEnabled
	public static String nameContactAssign(String contactId){
		List<User> us  = [Select Id, Name From User Where Id = :contactId WITH SECURITY_ENFORCED];
		if (us.isEmpty()) {
			return null;
		}else{
			return us[0].Name;
		}
	}


	@AuraEnabled
	public static List<OptionsPicklist> getOriginValues(){
		List<OptionsPicklist> origins = new List<OptionsPicklist>();

		Schema.DescribeFieldResult objFieldDescribe = AV_LeadOpportunity__c.AV_PrescriberId__c.getDescribe();
		List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
		for (Schema.PicklistEntry objPickList : lstPickListValues) {
			origins.add(new OptionsPicklist(objPickList.getValue(),objPickList.getLabel()));
		}

		return origins;
	}

	
	@AuraEnabled
	public static List<OptionsPicklist> getEmpresaValues(){
		List<OptionsPicklist> empresa = new List<OptionsPicklist>();

		
		Schema.DescribeFieldResult objFieldDescribe = AV_LeadOpportunity__c.AV_Empresa__c.getDescribe();
		List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
		for (Schema.PicklistEntry objPickList : lstPickListValues) {
			empresa.add(new OptionsPicklist(objPickList.getValue(),objPickList.getLabel()));
		}
		

		return empresa;
	}



	@AuraEnabled
	public static List<OptionsPicklist> getStageValues(){
		List<OptionsPicklist> stage = new List<OptionsPicklist>();

		
		Schema.DescribeFieldResult objFieldDescribe = AV_LeadOpportunity__c.AV_StatusLeadOpp__c.getDescribe();
		List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
		for (Schema.PicklistEntry objPickList : lstPickListValues) {
			stage.add(new OptionsPicklist(objPickList.getValue(),objPickList.getLabel()));
		}
		

		return stage;
	}

	@AuraEnabled
	public static List<OptionsPicklist> getPendingReasonValues(){
		List<OptionsPicklist> pendingReasons = new List<OptionsPicklist>();

		
		Schema.DescribeFieldResult objFieldDescribe = AV_LeadOpportunity__c.AV_PendingReason__c.getDescribe();
		List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
		for (Schema.PicklistEntry objPickList : lstPickListValues) {
			pendingReasons.add(new OptionsPicklist(objPickList.getValue(),objPickList.getLabel()));
		}
		

		return pendingReasons;
	}


	@AuraEnabled
	public static List<OptionsPicklist> getStatusValues(){
		List<OptionsPicklist> status = new List<OptionsPicklist>();

		
		Schema.DescribeFieldResult objFieldDescribe = AV_LeadOpportunity__c.AV_Status__c.getDescribe();
		List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
		for (Schema.PicklistEntry objPickList : lstPickListValues) {
			status.add(new OptionsPicklist(objPickList.getValue(),objPickList.getLabel()));
		}
		

		return status;
	}

	@AuraEnabled
	public static List<OptionsPicklist> getResolutionValues(){
		List<OptionsPicklist> resolution = new List<OptionsPicklist>();

		
		Schema.DescribeFieldResult objFieldDescribe = AV_LeadOpportunity__c.AV_Resolution__c.getDescribe();
		List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
		for (Schema.PicklistEntry objPickList : lstPickListValues) {
			resolution.add(new OptionsPicklist(objPickList.getValue(),objPickList.getLabel()));
		}
		

		return resolution;
	}



	


	@AuraEnabled
	public static List<OptionsPicklist> getEmployees(){
		List<OptionsPicklist> employees = new List<OptionsPicklist>();
		List<OptionsPicklist> employeesSorted = new List<OptionsPicklist>();
		List<Id> employeesId = new List<Id>();
		User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
		List<User> emps  = [Select Id, Name, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where AV_NumeroOficinaEmpresa__c = :emp.AV_NumeroOficinaEmpresa__c WITH SECURITY_ENFORCED];								
		if(!emps.isEmpty() && emps != null){
			for(User u : emps){
				employeesId.add(u.Id);
				employeesSorted.add(new OptionsPicklist(u.Id,u.Name));
			}
		}
		String employeesAlls=string.join(employeesId,',');
		if(employeesId.size()>1) {
			employees.add(new OptionsPicklist(ID_GCF+','+employeesAlls,'TODOS - CENTRO '+emp.AV_NumeroOficinaEmpresa__c));
		}
		employees.add(new OptionsPicklist(ID_GCF, AV_AppConstants.SINGESTOR_EAP_CENTRO +emp.AV_NumeroOficinaEmpresa__c));
		employeesSorted.sort();
		employees.addAll(employeesSorted);
		return employees;		
	}


	@AuraEnabled
	public static List<OptionsPicklist> getProducto(){
		List<OptionsPicklist> productos=new List<OptionsPicklist>();
		List<Product2> product2=new List<Product2>();
		product2=[select id,Name from Product2 where AV_PFNowIn__c=true WITH SECURITY_ENFORCED];

		if(!product2.isEmpty() && product2 !=null){
			for(Product2 a:product2){
				productos.add(new OptionsPicklist(a.id,a.Name));
			}
			productos.add(new OptionsPicklist(null,''));
		}
		return productos;
	}

	
	

	public class OptionsPicklist implements Comparable  {
		@AuraEnabled
		public String value;
		@AuraEnabled
		public String label;

		public OptionsPicklist(String value, String label){
			this.label = label;
			this.value = value;		
		}


		 // Implement the compareTo() method
		 public Integer compareTo(Object compareTo) {
			OptionsPicklist compareToProd = (OptionsPicklist)compareTo;
			 if (this.label > compareToProd.label) {
                return 1;
            }

            if (this.label == compareToProd.label) {
                return 0;
            }

            return -1;        
		}
	}


	

	@Future
    private static void futureUpdateLeadOpps(List<Id> leadOppIds, String contactId){
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.OptAllOrNone = false;
		dmlOptions.EmailHeader.triggerUserEmail = false;
        
        List<AV_LeadOpportunity__c> leadOpps = new List<AV_LeadOpportunity__c>();
        for(Id id : leadOppIds){
            AV_LeadOpportunity__c lo = new AV_LeadOpportunity__c(Id = id, OwnerId = contactId);
            leadOpps.add(lo);
        }
        Database.SaveResult[] srList = Database.update(leadOpps, dmlOptions);
        AV_AppUtilities.displayErrors('futureUpdateLeadOpps', srList);
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
    
}