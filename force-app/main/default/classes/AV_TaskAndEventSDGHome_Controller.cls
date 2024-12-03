/**********************************************************************************************************************
Name:	  AV_taskAndEventSDGHome_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Tareas y eventos de la Homa page
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	  	AUTHOR		   		DATE				Description
	1.1			DE56793	      	Patricia Solano  	11/15/2022		  	Init version
	1.2         Fix           	Elisabeth R.       	18/01/2022         	Added hour and minute attributes to CLS_TypeAttributes
	1.3         Fix SortBy    	Elisabeth Rodríguez 09/02/2022        	Added sortBy attribute
	1.4			Fix PMD Errors	Daniel Rodriguez	05/10/2023			Add WITH SECURITY_ENFORCED and isAccessible() fields
	1.5         US769112        Oscar Moreno        27/12/2023          The query of getRecords method is filtered based on the AV_OpportunitiesSearcherV2 PS 
	1.6 		Deuda Técnica	Gonzalo Ávila		21/03/2024			Replace the use of Sortable Data Grid 
	1.7			PPM100211786	Ángel Medina		02/05/2024			Change query for custom setting
	1.8			PPM100492394	Ángel Medina		17/10/2024			Add events multige in YesterdayEvents	
***********************************************************************************************************************/
public with sharing class AV_TaskAndEventSDGHome_Controller {
	
	public static final String OBJECT_TASK = 'Task';
	public static final String OBJECT_EVENT = 'Event';

	@AuraEnabled(cacheable=true)
	public static DataResponse getRecords(String objectType){
		String methodName = 'getRecords';
		
		DataResponse response = new DataResponse();
		Set<String> setFieldApiNames = new Set<String>();
		Set<String> picklistField = new Set<String>();
		List<Column> listCols = new List<Column>();
		List<Column> listColsToShow = new List<Column>();
		String fieldStatusFilter;
		Set<Id> setTaskHeaderIds = new Set<Id>();

		List<String> labelTask = new List<String>{'PRIORIDAD', 'ORIGEN', 'CLIENTE', 'ASUNTO', 'ESTADO', 'FECHA VENCIMIENTO'};
		List<String> labelEvent = new List<String>{'CLIENTE','ASUNTO','FECHA EVENTO','TIPO','ESTADO'};

						
		
		response.labelObject = objectType.equalsIgnoreCase('TodayTask') || objectType.equalsIgnoreCase('PendingTask') ? SObjectType.Task.getLabelPlural() : SObjectType.Event.getLabelPlural();				
		if(objectType.equalsIgnoreCase('TodayTask') || objectType.equalsIgnoreCase('PendingTask')){
			response.icono = 'standard:task';
			fieldStatusFilter = 'Status';
		}else if(objectType.equalsIgnoreCase('TodayEvents') || objectType.equalsIgnoreCase('YesterdayEvents')){
			response.icono=  'standard:event';
			fieldStatusFilter = 'CSBD_Evento_Estado__c';
		}

		if(objectType.equals('TodayTask')){
			response.title = AV_AppConstants.TODAYS_TASKS_TITLE;
		}else if(objectType.equals('PendingTask')){
			response.title = AV_AppConstants.PENDING_TASKS_TITLE;
		}else if(objectType.equals('TodayEvents')){
			response.title = AV_AppConstants.TODAYS_APPOINTMENTS_TITLE;
		}else if(objectType.equals('YesterdayEvents')){
			response.title = AV_AppConstants.YESTERDAYS_APPOINTMENTS_TITLE;
		}

		
		if(objectType.equals('TodayTask') || objectType.equals('PendingTask')){
				for(String label : labelTask){
					Column col = new Column();
					col.sortable = true;
					col.label = label;
					col.hideDefaultActions = true;

					if(label.equalsIgnoreCase('PRIORIDAD')){
						col.fieldName = 'Priority';
						col.type = 'text';
					}
					if(label.equalsIgnoreCase('ORIGEN')){
						col.fieldName = 'AV_Origen__c';
						col.sortBy = 'AV_Origen__c';
					}
					else if(label.equalsIgnoreCase('CLIENTE')){
						col.fieldName = 'clientLink';
						col.type = 'url';
						CLS_TypeAttributes attributes = new CLS_TypeAttributes();
						CLS_Label labelscs = new CLS_Label();
						Tooltip tooltip = new Tooltip();
						tooltip.fieldName = 'clientLabel';
						labelscs.fieldName = 'clientLabel';
						col.sortBy = 'clientLabel';
						attributes.label = labelscs;
						attributes.tooltip = tooltip;
						col.typeAttributes = attributes;
					}
					else if(label.equalsIgnoreCase('ASUNTO')){
						col.fieldName = 'subjectLink';
						col.type = 'url';
						CLS_TypeAttributes attributes = new CLS_TypeAttributes();
						CLS_Label labelscs = new CLS_Label();
						Tooltip tooltip = new Tooltip();
						tooltip.fieldName = 'subjectLabel';
						labelscs.fieldName = 'subjectLabel';
						col.sortBy = 'subjectLabel';
						attributes.label = labelscs;
						attributes.tooltip = tooltip;
						col.typeAttributes = attributes;
					}
					else if(label.equalsIgnoreCase('ESTADO')){
						col.fieldName = 'Status';
						col.type = 'text';
					}
					else if(label.equalsIgnoreCase('FECHA VENCIMIENTO')){
						col.fieldName = 'ActivityDate';
						col.sortBy = 'ActivityDate';
						col.type = 'date';
						CLS_TypeAttributes attributes = new CLS_TypeAttributes();
						attributes.day = '2-digit';
						attributes.month = 'short';
						attributes.year = 'numeric';
						attributes.hour = '2-digit'; 
						attributes.minute = '2-digit'; 
						col.typeAttributes = attributes;
					}
					listCols.add(col);
				}
				if(objectType.equals('TodayTask')){
					response.cols = listCols;
        			List<Task> queryTask = new List<Task>();
        			queryTask = [SELECT AV_Origen__c, Account.Name, AV_VerRegistro__c, ActivityDate, Id, OwnerId, Subject, What.Name,TOLABEL (Priority),TOLABEL (Status) FROM Task WHERE ( Status IN ( 'Open','Pendiente no localizado') AND AV_ToDelete__c = FALSE AND ActivityDate = TODAY AND AV_VisibleByLoggedUser__c = true AND ((RecordType.DeveloperName IN ( 'AV_Otros') AND AV_OrigenApp__c != 'AV_SalesforceTaskOpp') OR (RecordType.DeveloperName in ('AV_AlertaComercial') AND AV_OrigenApp__c = 'AV_CallMe' )))];
			        response.data = queryTask;
				}else if(objectType.equals('PendingTask')){
					response.cols = listCols;
        			List<Task> queryTask = new List<Task>();
        			queryTask = [SELECT AV_Origen__c, Account.Name, AV_VerRegistro__c, ActivityDate, Id, OwnerId, Subject, What.Name,TOLABEL (Priority),TOLABEL (Status) FROM Task WHERE ActivityDate >= LAST_N_DAYS:3 and ActivityDate < TODAY and RecordType.DeveloperName = 'AV_Otros' and Status in ('Open','Pendiente no localizado') and AV_OrigenApp__c != 'AV_SalesforceTaskOpp' and AV_VisibleByLoggedUser__c = true and AV_ToDelete__c = false ORDER BY ActivityDate ASC];
			        response.data = queryTask;
				}
		}
		if(objectType.equals('TodayEvents') || objectType.equals('YesterdayEvents')){
			for(String label : labelEvent){
				Column col = new Column();
					col.sortable = true;
					col.label = label;
					col.hideDefaultActions = true;

					if(label.equalsIgnoreCase('CLIENTE')){
						col.fieldName = 'clientLink';
						col.type = 'url';
						CLS_TypeAttributes attributes = new CLS_TypeAttributes();
						CLS_Label labelscs = new CLS_Label();
						Tooltip tooltip = new Tooltip();
						tooltip.fieldName = 'clientLabel';
						labelscs.fieldName = 'clientLabel';
						col.sortBy = 'clientLabel';
						attributes.label = labelscs;
						attributes.tooltip = tooltip;
						col.typeAttributes = attributes;
					}
					else if(label.equalsIgnoreCase('ASUNTO')){
						col.fieldName = 'subjectLink';
						col.type = 'url';
						CLS_TypeAttributes attributes = new CLS_TypeAttributes();
						CLS_Label labelscs = new CLS_Label();
						Tooltip tooltip = new Tooltip();
						tooltip.fieldName = 'subjectLabel';
						labelscs.fieldName = 'subjectLabel';
						col.sortBy = 'subjectLabel';
						attributes.label = labelscs;
						attributes.tooltip = tooltip;
						col.typeAttributes = attributes;
					}
					else if(label.equalsIgnoreCase('FECHA EVENTO')){
						col.fieldName = 'StartDateTime';
						col.sortBy = 'StartDateTime';
						col.type = 'date';
						CLS_TypeAttributes attributes = new CLS_TypeAttributes();
						attributes.day = '2-digit';
						attributes.month = 'short';
						attributes.year = 'numeric';
						attributes.hour = '2-digit'; 
						attributes.minute = '2-digit'; 
						col.typeAttributes = attributes;

					}
					else if(label.equalsIgnoreCase('TIPO')){
						col.fieldName = 'AV_Tipo__c';
						col.type = 'text';
					}
					else if(label.equalsIgnoreCase('ESTADO')){
						col.fieldName = 'CSBD_Evento_Estado__c';
						col.type = 'text';
					}
					
					listCols.add(col);
			}
			if(objectType.equals('TodayEvents')){
				response.cols = listCols;

				
				List<AV_RecordConfiguration__c> recordConfigurationCS = [SELECT AV_RecordType__c, AV_Status__c, AV_Type__c FROM AV_RecordConfiguration__c LIMIT 1];
				if(!recordConfigurationCS.isEmpty()){
					AV_RecordConfiguration__c record = recordConfigurationCS[0];
					String recordType = record.AV_RecordType__c;
					String status = record.AV_Status__c;
					String type = record.AV_Type__c;

					List<String> statusList = status.split(',');
					List<String> typeList = type.split(',');
					List<Event> queryEvent = new List<Event>();
					queryEvent = [SELECT Account.Name, AV_VerRegistro__c, StartDateTime, Id, OwnerId, Subject, What.Name,TOLABEL (AV_Tipo__c),TOLABEL (CSBD_Evento_Estado__c) FROM Event 
					WHERE RecordType.DeveloperName = :recordType 
					AND TOLABEL(CSBD_Evento_Estado__c) IN :statusList 
					AND TOLABEL(AV_Tipo__c) IN :typeList
					AND ActivityDate = TODAY AND AV_VisibleByLoggedUser__c = true 
					ORDER BY StartDateTime ASC];
					response.data = queryEvent;
				}
			}
			if(objectType.equals('YesterdayEvents')){
				response.cols = listCols;
				List<User> currentUser = [SELECT Id, AV_NumeroOficinaEmpresa__c FROM User WHERE Id = :UserInfo.getUserId()];
				String multiGestId = AV_PoolEvents_Controller.getCurrentDT(currentUser[0].AV_NumeroOficinaEmpresa__c);
				String center = (currentUser[0].AV_NumeroOficinaEmpresa__c.contains(AV_AppConstants.DASH)) ? currentUser[0].AV_NumeroOficinaEmpresa__c.split(AV_AppConstants.DASH)[1] : currentUser[0].AV_NumeroOficinaEmpresa__c;

				List<Event> unifiedResults = [
					SELECT What.Name, Account.Name, Id, AccountId, Account.AV_Numperso__c, Subject, ActivityDateTime, StartDateTime, TOLABEL(AV_Tipo__c), TOLABEL(CSBD_Evento_Estado__c), RecordType.DeveloperName, AV_VerRegistro__c, OwnerId, AV_Center__c
					FROM Event 
					WHERE RecordType.DeveloperName IN ('AV_EventosConCliente', :AV_AppConstants.EVENTCLIENTE_RT) 
					AND ActivityDate = YESTERDAY 
					AND CSBD_Evento_Estado__c = 'Pendiente'
					AND ((AV_VisibleByLoggedUser__c = true AND OwnerId = :UserInfo.getUserId()) OR (OwnerId = :multiGestId AND AV_Center__c = :center))
					ORDER BY StartDateTime ASC
				];
				response.data = unifiedResults;
			}
		}
		return response;
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
		public Tooltip tooltip;	//Subject
	}

	public class CLS_Label {
		@AuraEnabled
		public String fieldName;
	}

	public class CLS_Class {
		@AuraEnabled
		public String fieldName;
	}
	public class Tooltip {
		@AuraEnabled
		public String fieldName;
	}

}