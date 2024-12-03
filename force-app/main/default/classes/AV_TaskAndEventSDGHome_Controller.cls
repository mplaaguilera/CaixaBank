/**********************************************************************************************************************
Name:	  AV_taskAndEventSDGHome_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Tareas y eventos de la Homa page
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	  	AUTHOR		   	DATE					Description
	1.1			DE56793	      	Patricia Solano  	11/15/2022		  	Init version
	1.2         Fix           	Elisabeth R.       	18/01/2022         	Added hour and minute attributes to CLS_TypeAttributes
	1.3         Fix SortBy    	Elisabeth Rodríguez 09/02/2022        	Added sortBy attribute
	1.4			Fix PMD Errors	Daniel Rodriguez	05/10/2023			Add WITH SECURITY_ENFORCED and isAccessible() fields
***********************************************************************************************************************/
public with sharing class AV_TaskAndEventSDGHome_Controller {
	
	public static final String OBJECT_TASK = 'Task';
	public static final String OBJECT_EVENT = 'Event';

	@AuraEnabled(cacheable=true)
	public static DataResponse getRecords(String sdgApiName){
		String methodName = 'getRecords';
		
		DataResponse response = new DataResponse();
		List<SObject> listRecords = new List<SObject>();
		Set<String> setFieldApiNames = new Set<String>();
		Set<String> picklistField = new Set<String>();
		List<Column> listCols = new List<Column>();
		List<Column> listColsToShow = new List<Column>();
		String fieldStatusFilter;
		Set<Id> setTaskHeaderIds = new Set<Id>();
		
		
		//Build columns
		List<sortablegrid__SDG_Field__c> listFields = new List<sortablegrid__SDG_Field__c>();
		if(Schema.sObjectType.sortablegrid__SDG_Field__c.isAccessible() && Schema.SObjectType.sortablegrid__SDG_Field__c.fields.sortablegrid__APIName__c.isAccessible()
		&& Schema.SObjectType.sortablegrid__SDG_Field__c.fields.sortablegrid__FieldOrder__c.isAccessible()){
			 listFields = [SELECT sortablegrid__APIName__c, 
			sortablegrid__FieldOrder__c, sortablegrid__Override_Label__c,
			sortablegrid__sdg__r.sortablegrid__sObjectName__c 
			FROM sortablegrid__SDG_Field__c 
			WHERE sortablegrid__is_valid_field__c = true
			AND sortablegrid__sdg__r.sortablegrid__SDG_Tag__c = :sdgApiName WITH SECURITY_ENFORCED
			ORDER BY sortablegrid__FieldOrder__c];
		}

		String targetObjectName = listFields.get(0).sortablegrid__sdg__r.sortablegrid__sObjectName__c;				
		
		response.labelObject = targetObjectName.equalsIgnoreCase(OBJECT_TASK) ? SObjectType.Task.getLabelPlural() : SObjectType.Event.getLabelPlural();				
		if(targetObjectName.equalsIgnoreCase(OBJECT_TASK)){
			response.icono = 'standard:task';
			fieldStatusFilter = 'Status';
		}else if(targetObjectName.equalsIgnoreCase(OBJECT_EVENT)){
			response.icono=  'standard:event';
			fieldStatusFilter = 'CSBD_Evento_Estado__c';
		}

		if(sdgApiName.equals(AV_AppConstants.TODAYS_TASKS)){

			response.title = AV_AppConstants.TODAYS_TASKS_TITLE;

		}else if(sdgApiName.equals(AV_AppConstants.PENDING_TASKS)){

			response.title = AV_AppConstants.PENDING_TASKS_TITLE;

		}else if(sdgApiName.equals(AV_AppConstants.TODAYS_APPOINTMENTS)){

			response.title = AV_AppConstants.TODAYS_APPOINTMENTS_TITLE;

		}else if(sdgApiName.equals(AV_AppConstants.YESTERDAYS_APPOINTMENTS)){

			response.title = AV_AppConstants.YESTERDAYS_APPOINTMENTS_TITLE;

		}

		for(sortablegrid__SDG_Field__c sdgf : listFields) {
			Column col = new Column();
			Schema.DisplayType fldType;
			if (!sdgf.sortablegrid__APIName__c.equalsIgnoreCase('Owner.Name')
				&& !sdgf.sortablegrid__APIName__c.equalsIgnoreCase('AV_VerRegistroAsunto__c') && !sdgf.sortablegrid__APIName__c.equalsIgnoreCase('Account.Name') 
				&& !sdgf.sortablegrid__APIName__c.equalsIgnoreCase('AV_VerRegistro__c')){
					Map<String, Schema.SObjectField> mapa;
					if(targetObjectName.equalsIgnoreCase(OBJECT_TASK)){
						mapa = Schema.SObjectType.Task.fields.getMap();
					}else if(targetObjectName.equalsIgnoreCase(OBJECT_EVENT)){
						mapa = Schema.SObjectType.Event.fields.getMap();	
					}	
					Schema.SObjectField field = mapa.get(sdgf.sortablegrid__APIName__c);
					fldType = field.getDescribe().getType();
			} 

			col.sortable = true;
			if(!sdgf.sortablegrid__APIName__c.equalsIgnoreCase('Account.Name') || !sdgf.sortablegrid__APIName__c.equalsIgnoreCase('AV_VerRegistro__c')){
				col.sortBy = sdgf.sortablegrid__APIName__c;
			}
			col.label = sdgf.sortablegrid__Override_Label__c;
			col.fieldName = sdgf.sortablegrid__APIName__c;
			col.hideDefaultActions = true;
			if(fldType != Null && fldType == Schema.DisplayType.Picklist){
				picklistField.add(col.fieldName); 
			}else{
				setFieldApiNames.add(col.fieldName);
			}
			
			if(fldType != Null && (fldType == Schema.DisplayType.DateTime || fldType == Schema.DisplayType.Date)) {
				col.type = 'date';
				CLS_TypeAttributes attributes = new CLS_TypeAttributes();
				attributes.day = '2-digit';
				attributes.month = 'short';
				attributes.year = 'numeric';
				col.typeAttributes = attributes;
				if(fldType == Schema.DisplayType.DateTime){
					attributes.hour = '2-digit';
            		attributes.minute = '2-digit';
				}
				
			}
			
			if(sdgf.sortablegrid__APIName__c.equalsIgnoreCase('Owner.name')) {
					col.fieldName = 'ownerLink';
					col.type = 'url';
					CLS_TypeAttributes attributes = new CLS_TypeAttributes();
					CLS_Label label = new CLS_Label();
					label.fieldName = 'ownerLabel';
					attributes.label = label;
					attributes.tooltip = 'Owner.name';
					col.typeAttributes = attributes;
			}

			if(sdgf.sortablegrid__APIName__c.equalsIgnoreCase('Account.Name')) {
				col.fieldName = 'clientLink';
				col.type = 'url';
				CLS_TypeAttributes attributes = new CLS_TypeAttributes();
				CLS_Label label = new CLS_Label();
				label.fieldName = 'clientLabel';
				col.sortBy = 'clientLabel';
				attributes.label = label;
				col.typeAttributes = attributes;
			}

			if(sdgf.sortablegrid__APIName__c.equalsIgnoreCase('AV_VerRegistro__c')) {
				col.fieldName = 'subjectLink';
				col.type = 'url';
				CLS_TypeAttributes attributes = new CLS_TypeAttributes();
				CLS_Label label = new CLS_Label();
				label.fieldName = 'subjectLabel';
				col.sortBy = 'subjectLabel';
				attributes.label = label;
				attributes.tooltip = 'Subject';
				col.typeAttributes = attributes;
			}

			if(sdgf.sortablegrid__APIName__c.equalsIgnoreCase('Status')) {
				col.fieldName = 'Status';
				col.type = 'text';
			}

			if(sdgf.sortablegrid__APIName__c.equalsIgnoreCase('CSBD_Evento_Estado__c')) {
				col.fieldName = 'CSBD_Evento_Estado__c';
				col.type = 'text';
			}
			listCols.add(col);
 
		}

		listRecords = getRecordsByDynamicQuery(sdgApiName, setFieldApiNames, picklistField, targetObjectName, fieldStatusFilter);
		AV_LogDebug.printLogDebug(methodName, 'Registro recuperados: ' + listRecords.size());
		AV_LogDebug.printLogDebug(methodName, 'Columnas total: ' +listCols);
		
		response.cols = listCols;
		response.data = listRecords;
		return response;
	}
	
	private static List<SObject> getRecordsByDynamicQuery(String sdgApiName, Set<String> setFieldApiNames, Set<String> picklistField, String targetObjectName, String fieldStatusFilter){
		String methodName = 'getRecordsByDynamicQuery';

		if (setFieldApiNames==null){
			setFieldApiNames = new Set<String>();
		}
		setFieldApiNames.add('Id');
		setFieldApiNames.add('OwnerId');
		setFieldApiNames.add('Subject');
		setFieldApiNames.add('What.Name');


		
		//Create query to execute at the end of the method
		String querysoql = 'SELECT';
		integer i=0;
		for(String field : setFieldApiNames){
			querysoql += ' '+field;
			i++;
			if(i!= setFieldApiNames.size()) {
                querysoql += ',';
            }
		
		}
		if(!picklistField.isEmpty()){
			for(String fieldPick : picklistField){
				querysoql += ',TOLABEL (' + fieldpick + ')';
			}
		}
		querysoql += ' FROM '+targetObjectName ;
		
		if(sdgApiName.equals(AV_AppConstants.TODAYS_TASKS)){
			querysoql += ' WHERE ( Status IN ( \'Open\',\'Pendiente no localizado\') AND AV_ToDelete__c = FALSE AND ActivityDate = TODAY AND AV_VisibleByLoggedUser__c = true AND ((RecordType.DeveloperName IN ( \'AV_Otros\') AND AV_OrigenApp__c != \'AV_SalesforceTaskOpp\') OR (RecordType.DeveloperName in (\'AV_AlertaComercial\') AND AV_OrigenApp__c = \'AV_CallMe\' )))';
		}else if(sdgApiName.equals(AV_AppConstants.PENDING_TASKS)){
			querysoql += ' WHERE ActivityDate >= LAST_N_DAYS:3 and ActivityDate < TODAY and RecordType.DeveloperName = \'AV_Otros\' and Status in (\'Open\',\'Pendiente no localizado\') and AV_OrigenApp__c != \'AV_SalesforceTaskOpp\' and AV_VisibleByLoggedUser__c = true and AV_ToDelete__c = false ORDER BY ActivityDate ASC';
		}else if(sdgApiName.equals(AV_AppConstants.TODAYS_APPOINTMENTS)){
			querysoql += ' WHERE RecordType.DeveloperName in (\'AV_EventosConCliente\') and ActivityDate = TODAY and AV_VisibleByLoggedUser__c = true ORDER BY StartDateTime ASC';
		}else if(sdgApiName.equals(AV_AppConstants.YESTERDAYS_APPOINTMENTS)){
			querysoql += ' WHERE RecordType.DeveloperName in (\'AV_EventosConCliente\') and ActivityDate = YESTERDAY and AV_VisibleByLoggedUser__c = true and CSBD_Evento_Estado__c = \'Pendiente\' ORDER BY StartDateTime ASC';
		}

		return Database.query(querysoql);
	}
	
	public class DataResponse {
		@AuraEnabled
		public String labelObject;
		@AuraEnabled
		public String icono;
		@AuraEnabled
		public String title;
		@AuraEnabled
		public List<Column> cols;
		@AuraEnabled
		public List<Object> data;
	}
	
	public class Column {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String fieldName;
		@AuraEnabled
		public String type;
		@AuraEnabled
		public CLS_TypeAttributes typeAttributes;
		@AuraEnabled
		public Map<String, CLS_Class> cellAttributes;
		@AuraEnabled
		public boolean sortable;
		@AuraEnabled
		public String sortBy;
		@AuraEnabled
		public boolean hideDefaultActions;
		
		public Column() {
			typeAttributes = new CLS_TypeAttributes();
		}		
	}
	
	public class CLS_TypeAttributes {
		@AuraEnabled
		public CLS_Label label;
		@AuraEnabled
		public String day;
		@AuraEnabled
		public String month;
		@AuraEnabled
		public String year;
		@AuraEnabled
		public String hour;
		@AuraEnabled
		public String minute;
		@AuraEnabled
		public String tooltip;	//Subject
	}

	public class CLS_Label {
		@AuraEnabled
		public String fieldName;
	}

	public class CLS_Class {
		@AuraEnabled
		public String fieldName;
	}

}