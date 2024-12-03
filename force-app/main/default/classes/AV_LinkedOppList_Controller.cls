/**********************************************************************************************************************
Name:	  AV_LinkedOppList_Controller
Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Tareas y eventos asociados a la oportunidad
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	  AUTHOR		   	DATE				Description
	1.0			US139557	  Esperanza Conde  	02/12/2020		  	Init version
	1.1			Fix     	  Esperanza Conde  	10/12/2020		  	Filtro fechas: Tareas (ActivityDate >= LAST_WEEK), 
																				   Eventos (StartDateTime >= TODAY)
	1.2			US177365	  David Rufo		03/03/2021		  	Update method "getRecordsByDynamicQuery" to retrieve 
																	all the vinculed data
	1.3         US177365      Víctor Santiago   11/03/2021          Task query orderBy DESC, condition implemented to add
																	to CSBD_Evento_Estado__c the HTML 'class' tag

	1.4         US196065      Víctor Santiago   08/04/2021          getTaskHeaderIds() implemented
	1.5         DE54414       Sandra Gómez      07/01/2022          Add filter status in Task
	1.6         FIX           Luis Fernández    11/07/2022          Changed AV_Query to SOQL queries
	1.7         US450626      Sandra Gómez      13/09/2022          Changed method getRecordsByDynamicQuery add condition in Event isChild
	1.8 		US455996	  Luis Fernández    27/10/2022			Added "AV_ToDelete__C = FALSE" to query condition in getRecordsByDynamicQuery method
	1.9         DE56793       Elisabeth Rodríguez 21/11/2022        Changed getRecordsByDynamicQuery method for Accounts
	2.0         Fix           Elisabeth R.       18/01/2022         Added hour and minute attributes to CLS_TypeAttributes
	2.1 		Fix			  Ángel Medina		09/02/2023			Changed method getRecordsByDynamicQuery and getTaskHeaderIds add filter RecordTypes
																	Create method setToString to resolve bugs QC
	2.2         Fix SortBy    Elisabeth Rodríguez 09/02/2022        Added sortBy attribute
	2.3         Fix PMD Errors Humberto Vilchez    23/10/2023      	Add WITH SECURITY_ENFORCED to queries
***********************************************************************************************************************/
public with sharing class AV_LinkedOppList_Controller {
	
	public static final String OBJECT_TASK = 'Task';
	public static final String OBJECT_EVENT = 'Event';
	
	@AuraEnabled(cacheable=true)
	public static DataResponse getRecords(String recordId, String sdgApiName){
		String methodName = 'getRecords';
		
		DataResponse response = new DataResponse();
		List<SObject> listRecords = new List<SObject>();
		Set<String> setFieldApiNames = new Set<String>();
		Set<String> picklistField = new Set<String>();
		List<Column> listCols = new List<Column>();
		List<Column> listColsToShow = new List<Column>();
		String fieldStatusFilter;
		Set<Id> setTaskHeaderIds = new Set<Id>();
		
		
		//Build columnsç
		List<sortablegrid__SDG_Field__c> listFields = new List<sortablegrid__SDG_Field__c>();
		if(Schema.sObjectType.sortablegrid__SDG_Field__c.isAccessible()){
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
			response.title = Label.AV_TaskRelatedLabel;
			fieldStatusFilter = 'Status';
		}else if(targetObjectName.equalsIgnoreCase(OBJECT_EVENT)){
			response.icono=  'standard:event';
			response.title = Label.AV_EventRelatedLabel;
			fieldStatusFilter = 'CSBD_Evento_Estado__c';
		}

		for(sortablegrid__SDG_Field__c sdgf : listFields) {
			Column col = new Column();
			Schema.DisplayType fldType;
			if (!sdgf.sortablegrid__APIName__c.equalsIgnoreCase('Owner.Name')
				&& !sdgf.sortablegrid__APIName__c.equalsIgnoreCase('AV_VerRegistroAsunto__c)')){
					Map<String, Schema.SObjectField> mapa;
					if(targetObjectName.equalsIgnoreCase(OBJECT_TASK)){
						mapa = Schema.SObjectType.Task.fields.getMap();
					}else if(targetObjectName.equalsIgnoreCase(OBJECT_EVENT)){
						mapa = Schema.SObjectType.Event.fields.getMap();	
					}	
					Schema.SObjectField field = mapa.get(sdgf.sortablegrid__APIName__c);
					fldType = field.getDescribe().getType();
			} 

            if(!sdgf.sortablegrid__APIName__c.equalsIgnoreCase('Owner.Name') || !sdgf.sortablegrid__APIName__c.equalsIgnoreCase('AV_VerRegistroAsunto__c')){
                col.sortBy = sdgf.sortablegrid__APIName__c;
            }
			col.sortable = true;
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
					col.sortBy = 'ownerLabel';
					col.typeAttributes = attributes;
				}

			if(sdgf.sortablegrid__APIName__c.equalsIgnoreCase('AV_VerRegistroAsunto__c')) {
				col.fieldName = 'subjectLink';
				col.type = 'url';
				CLS_TypeAttributes attributes = new CLS_TypeAttributes();
				CLS_Label label = new CLS_Label();
				label.fieldName = 'subjectLabel';
				attributes.label = label;
				col.sortBy = 'subjectLabel';
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
 
			setTaskHeaderIds = getTaskHeaderIds(recordId);

		}
		listRecords = getRecordsByDynamicQuery(recordId, setFieldApiNames, picklistField, targetObjectName, fieldStatusFilter, setTaskHeaderIds);
		AV_LogDebug.printLogDebug(methodName, 'Registro recuperados: ' + listRecords.size());
		AV_LogDebug.printLogDebug(methodName, 'Columnas total: ' +listCols);
		
		response.cols = listCols;
		response.data = listRecords;
		return response;
	}

	
	private static List<SObject> getRecordsByDynamicQuery(String recordId, Set<String> setFieldApiNames, Set<String> picklistField, String targetObjectName, String fieldStatusFilter, Set<Id> setTaskHeaderIds){
		String methodName = 'getRecordsByDynamicQuery';
		if (setFieldApiNames==null){
			setFieldApiNames = new Set<String>();
		}
		setFieldApiNames.add('Id');
		setFieldApiNames.add('OwnerId');
		setFieldApiNames.add('Subject');
		Set<String> taskStatus = new Set<String> {
			'Open', // Pendiente
			'Pendiente no localizado',
			'Gestionada positiva',
			'Gestionada negativa',
			'Gestionado no localizado',
			'No gestionada'
		};
		
		//Create query to execute at the end of the method
		String querysoql = 'SELECT ';
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
				querysoql += ' ,TOLABEL (' + fieldpick + ')';
			}
		}
		querysoql += ' FROM  ' + targetObjectName;
		String formatSetTaskHeaderIds = ' (\'\')';
		if(!setTaskHeaderIds.isEmpty()){
			i=0;
			formatSetTaskHeaderIds= '(';
		for(String id :setTaskHeaderIds){
			formatSetTaskHeaderIds += '\''+id+'\'';
			formatSetTaskHeaderIds += ((++i)!=setTaskHeaderIds.size())?',':')';
		}
		}
		i=0;
		String formatTaskStatusSet = '(';
		for(String status : taskStatus){
			formatTaskStatusSet += '\''+status+'\'';
			formatTaskStatusSet += ((++i)!=taskStatus.size())?',':')';
		}

	
		List<String> listRt = new List<String>{
			AV_AppConstants.TASKINICIATIVA_RT,
			AV_AppConstants.TASKALERTACOM_RT,
			AV_AppConstants.TASKAVISOS_RT,
			AV_AppConstants.TASKEXPCLIENT_RT,
			AV_AppConstants.TASKONBOARDING_RT,
			AV_AppConstants.TASKPRIORIZADOR_RT
		};

		List<String> taskRTStatus = new List<String>{
			AV_AppConstants.TASK_STATUS_PENDIENTE,
			AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL
		};

		String eventStatus = AV_AppConstants.EVENT_STATUS_PENDIENTE;
		String eventClientRT = AV_AppConstants.EVENTCLIENTE_RT;
		String tareaOppRT = AV_AppConstants.OPPTASK_RT;

		if(recordId.startsWith('001')){
			//Task object
			if(OBJECT_TASK.equalsIgnoreCase(targetObjectName)){
				querysoql += ' WHERE RecordType.DeveloperName IN ' + setToString(listRt) + ' AND (ActivityDate=LAST_N_DAYS:3 OR ActivityDate>=TODAY) AND Status IN ' + setToString(taskRTStatus) + ' AND AV_ToDelete__c = false and WhatId =\''+ recordId + '\'' ;
			//Event object
			}else if(OBJECT_EVENT.equalsIgnoreCase(targetObjectName)){
				querysoql += ' WHERE StartDateTime >= TODAY AND CSBD_Evento_Estado__c =\'' + eventStatus + '\' AND RecordType.DeveloperName =\'' + eventClientRT + '\' AND IsChild = false AND WhatId =\'' + recordId + '\'';
			}

		}else{
		//Task object
			if(OBJECT_TASK.equalsIgnoreCase(targetObjectName)){
				querysoql += ' WHERE AV_Task__c IN ' + setToString(setTaskHeaderIds) + ' AND AV_ToDelete__c = FALSE AND AV_Task__c != NULL AND RecordType.DeveloperName IN ' + setToString(listRt) + ' AND Status IN ' + setToString(taskStatus) + ' ORDER BY ActivityDate ASC';
				
				//Event object
			}else if(OBJECT_EVENT.equalsIgnoreCase(targetObjectName)){
				querysoql += ' WHERE AV_Task__c IN ' + setToString(setTaskHeaderIds) + ' AND IsChild = false AND AV_Task__c != NULL AND RecordType.DeveloperName =\'' + eventClientRT + '\' ORDER BY StartDateTime DESC';
			}
		}
		return capsulateQuery(querysoql);
	}
	
	private static String setToString (Set<String> setToTransfrom){
		String result = ' (\'\')';
		if(!setToTransfrom.isEmpty()){
			Integer i=0;
			result= '(';
			for(String id :setToTransfrom){
				result += '\''+id+'\'';
				result += ((++i)!=setToTransfrom.size())?',':')';
			}
		}
		return result;
	}

	private static String setToString (List<String> setToTransfrom){
		String result = ' (\'\')';
		if(!setToTransfrom.isEmpty()){
			Integer i=0;
			result= '(';
			for(String id :setToTransfrom){
				result += '\''+id+'\'';
				result += ((++i)!=setToTransfrom.size())?',':')';
			}
		}
		return result;
	}

	private static String setToString (Set<Id> setToTransfrom){
		String result = ' (\'\')';
		if(!setToTransfrom.isEmpty()){
			Integer i=0;
			result= '(';
			for(String id :setToTransfrom){
				result += '\''+id+'\'';
				result += ((++i)!=setToTransfrom.size())?',':')';
			}
		}
		return result;
	}

	private static List<SObject> capsulateQuery(String q){
		return Database.query(q);
	}

	/**
	 * Gets task header ids depending on the flexipage where the LWC component is located,
	 * that is, Opportunity or Account.
	 */
	public static Set<Id> getTaskHeaderIds(String recordId) {
		List<AV_CustomActivityOpportunity__c> listCao = new List<AV_CustomActivityOpportunity__c>();
		List<Task> tasks = new List<Task>();
		Set<Id> ids = new Set<Id>();
		Set<String> selectedFields = new Set<String> {
			'Id',
			'RecordType.DeveloperName',
			'AV_Task__c',
			'Status',
			'ActivityDate'
		};
		Set<String> taskRecordTypes = new Set<String> {
			'AV_AlertaComercial',
			'AV_MorosidadNormativa',
			'AV_ConversacionPendiente',
			'AV_ExperienciaCliente',
			'AV_Onboarding',
			'AV_Priorizador'
		};
		Set<String> taskStatus = new Set<String> {
			'Open', // Pendiente
			'Pendiente no localizado',
			'Gestionada positiva',
			'Gestionada negativa',
			'Gestionado no localizado',
			'No gestionada'
		};
		if (recordId.startsWith('006')) { // Opp
	
			if(Schema.sObjectType.AV_CustomActivityOpportunity__c.isAccessible()){
				listCao = [SELECT AV_Task__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c = :recordId AND RecordType.DeveloperName IN (:AV_AppConstants.TAREA_OPOR_RT) WITH SECURITY_ENFORCED];
			}
			if (!listCao.isEmpty()) {
				for (AV_CustomActivityOpportunity__c cao : listCao) {
					if (cao.AV_Task__c != null) {
						ids.add(cao.AV_Task__c);
					}
				}
			}
		} else if (recordId.startsWith('001')) { // Acc
			//CAMPOS AÑADIDOS MANUALMENTE. ANTES SE LLAMABAN DESDE UN SET INICIALIZADO EN LA LINEA 223 
			if(Schema.sObjectType.Task.isAccessible()){
				tasks = [SELECT  Id,
				RecordType.DeveloperName,
				AV_Task__c,
				Status,
				ActivityDate FROM Task WHERE AccountId = :recordId 
				AND RecordType.DeveloperName IN (:AV_AppConstants.TASKINICIATIVA_RT, :AV_AppConstants.TASKALERTACOM_RT, :AV_AppConstants.TASKAVISOS_RT, :AV_AppConstants.TASKCONTACTGCF_RT, :AV_AppConstants.TASKEXPCLIENT_RT, :AV_AppConstants.TASKONBOARDING_RT, :AV_AppConstants.TASKPRIORIZADOR_RT, :AV_AppConstants.TASKCPENDIENTE_RT) WITH SECURITY_ENFORCED];
			}
			if (!tasks.isEmpty()) {
				for (Task t : tasks) {
					if (t.AV_Task__c == null) {
						continue;
					}
						if ('AV_Otros'.equals(t.RecordType.DeveloperName)) { // Iniciativa Gestor/a
							if (taskStatus.contains(t.Status) &&
							t.ActivityDate >= (Date.today() - 3) &&
							t.ActivityDate <= (Date.today() + 180)) {
								ids.add(t.AV_Task__c);
							}
						} else if (taskRecordTypes.contains(t.RecordType.DeveloperName)) {
							if (taskRecordTypes.contains(t.RecordType.DeveloperName) && (('Open'.equals(t.Status) || 'Pendiente no localizado'.equals(t.Status)) &&
									t.ActivityDate >= Date.today() &&
									t.ActivityDate <= (Date.today() + 180))) {
										ids.add(t.AV_Task__c);
							}
						}
					}

				}
			}
		return ids;

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