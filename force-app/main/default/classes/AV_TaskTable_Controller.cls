/**********************************************************************************************************************
Name:	  AV_TaskTable_Controller
Copyright © 2024  CaixaBank
=======================================================================================================================
Proposito: Controller para mostrar tareas asociadas
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0         US796346        Gonzalo Ávila  	    20/03/2024		Init version

***********************************************************************************************************************/
public with sharing class AV_TaskTable_Controller {
    @AuraEnabled(cacheable=true)
    public static DataResponse getRecords(String recordId, String objectType){
        String methodName = 'getRecords';
        
        DataResponse response = new DataResponse();
        List<Column> listCols = new List<Column>();
        Set<Id> setTaskHeaderIds = new Set<Id>();
        
        // Column labels
        List<String> labels = new List<String>{'ORIGEN', 'ASUNTO', 'ESTADO', 'FECHA DE VENCIMIENTO', 'ASIGNADO A'};

        response.labelObject = SObjectType.Task.getLabelPlural();                
        response.icono = 'standard:task';        
        response.title = Label.AV_TaskRelatedLabel;

        for(String label : labels){
            Column col = new Column();
            col.sortable = true;
            col.label = label;
            col.hideDefaultActions = true;

            if(label.equalsIgnoreCase('ORIGEN')){
                col.fieldName = 'AV_Origen__c';
                col.sortBy = 'AV_Origen__c';
            }
            else if(label.equalsIgnoreCase('ASUNTO')){
                col.fieldName = 'subjectLink';
				col.type = 'url';
				CLS_TypeAttributes attributes = new CLS_TypeAttributes();
				CLS_Label clslabel = new CLS_Label();
				Tooltip tooltip = new Tooltip();
				tooltip.fieldName = 'subjectLabel';
				clslabel.fieldName = 'subjectLabel';
				attributes.label = clslabel;
				attributes.tooltip = tooltip;
				col.sortBy = 'subjectLabel';
				col.typeAttributes = attributes;
            }
            else if(label.equalsIgnoreCase('ESTADO')){
                col.fieldName = 'Status';
                col.sortBy = 'Status';
            }
            else if(label.equalsIgnoreCase('FECHA DE VENCIMIENTO')){
                col.fieldName = 'ActivityDate';
                col.sortBy = 'ActivityDate';
                col.type = 'date';
                CLS_TypeAttributes attributes = new CLS_TypeAttributes();
                attributes.day = '2-digit';
                attributes.month = 'short';
                attributes.year = 'numeric';
                col.typeAttributes = attributes;
            }
            
            else if(label.equalsIgnoreCase('ASIGNADO A')){
                col.fieldName = 'ownerLink';
				col.type = 'url';
				CLS_TypeAttributes attributes = new CLS_TypeAttributes();
				CLS_Label clslabel = new CLS_Label();
				Tooltip tooltip = new Tooltip();
				tooltip.fieldName = 'ownerLabel';
				clslabel.fieldName = 'ownerLabel';
				attributes.label = clslabel;
				attributes.tooltip = tooltip;
				col.sortBy = 'ownerLabel';
				col.typeAttributes = attributes;
            }
           
            listCols.add(col);
            setTaskHeaderIds = getTaskHeaderIds(recordId);
        }

        List<String> listIds = new List<String>();
        for (Id idValue : setTaskHeaderIds) {
            String id = String.valueOf(idValue);
            listIds.add(id);
        }

        response.cols = listCols;
		System.debug('recordId-->'+recordId);
        List<Task> queryTask = new List<Task>();
        if(objectType.equals('Opportunity')){
            queryTask =[SELECT  AV_Origen__c, AV_VerRegistroAsunto__c, ActivityDate, Owner.Name, Id, OwnerId, Subject ,TOLABEL (Status) FROM  Task WHERE AV_Task__c IN: listIds AND AV_ToDelete__c = FALSE AND AV_Task__c != NULL AND RecordType.DeveloperName IN ('AV_Otros','AV_AlertaComercial','AV_MorosidadNormativa','AV_ExperienciaCliente','AV_Onboarding','AV_Priorizador') AND Status IN ('Open','Pendiente no localizado','Gestionada positiva','Gestionada negativa','Gestionado no localizado','No gestionada') ORDER BY ActivityDate ASC];
        }else if (objectType.equals('Account')){
            queryTask = [SELECT  AV_Origen__c, AV_VerRegistroAsunto__c, ActivityDate, Owner.Name, Id, OwnerId, Subject ,TOLABEL (Status) FROM  Task WHERE RecordType.DeveloperName IN ('AV_Otros','AV_AlertaComercial','AV_MorosidadNormativa','AV_ExperienciaCliente','AV_Onboarding','AV_Priorizador') AND (ActivityDate=LAST_N_DAYS:3 OR ActivityDate>=TODAY) AND Status IN ('Open','Pendiente no localizado') AND AV_ToDelete__c = false and WhatId =: recordId];            
        }
        response.data = queryTask;
		System.debug('querryComts->'+queryTask);
        return response;
    }

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
        public List<Task> data;
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
        public Tooltip tooltip;    //Subject
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