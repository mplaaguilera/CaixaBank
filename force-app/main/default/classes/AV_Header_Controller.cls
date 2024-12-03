/**********************************************************************************************************************
Name:	  AV_Header_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC AV_Header_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Init    		Ángel Medina 		14/06/2022		Init version. Copy the CIBE_Header_Controller class from CIBE
1.1		    Fix PMD Errors	Daniel Rodriguez	25/10/2023	    Add queries WITH SECURITY_ENFORCED 
1.2		    US562059        Luis Fernández   	24/11/2023	    Changed getAccountInfo in order to retrieve more fields and a ordered response
1.3         PPM100492394    Ángel Medina        30/09/2024      Changed getAccountInfo add fields in query
***********************************************************************************************************************/
public with sharing class AV_Header_Controller {
    @AuraEnabled(cacheable=true)
	public static Map<String,String> getAccountInfo(Id recordId,String clientNumper ) {
		String nameRecord = '';
		String filterObject = (recordId != null ) ? recordId.getSObjectType().getDescribe().getName() : null;
		String accName = ''; 
		String accRtDevName = ''; 
		String accId = '';
		String clientNumperToSend = '';
		String contactPlate = '';
		String accNumDocument = '';
        String eventType;
        String eventDateTime;
        String eventInitTime;
        String eventEndTime;
		List<Account> accClientList;
        List<Account> accClientListOffice;
		if(recordId != null){

			if(filterObject.equals(AV_AppConstants.OBJECT_NAME_OPPORTUNITY)){
				List<Opportunity> oppList = [SELECT AccountId,Name FROM Opportunity WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
				if(oppList != null && !oppList.isEmpty()){
					recordId = oppList[0].AccountId;
					nameRecord = oppList[0].Name;
				}
			}
			else if(filterObject.equals(AV_AppConstants.OBJECT_NAME_EVENT)){
				List<Event> evtList = [SELECT AccountId,Subject, AV_Tipo__c, ActivityDateTime, Account.Name, Account.RecordType.DeveloperName,StartDateTime,EndDateTime, Description, Location, AV_BranchPhysicalMeet__c  FROM Event WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
				if(evtList != null && !evtList.isEmpty()){
					recordId = evtList[0].AccountId;
					nameRecord = evtList[0].Subject;
					eventType = evtList[0].AV_Tipo__c;
					eventDateTime = evtList[0].ActivityDateTime.format('yyyy-MM-dd');
					eventInitTime = evtList[0].StartDateTime.format('HH:mm');
					eventEndTime = evtList[0].EndDateTime.format('HH:mm');
					accName = evtList[0].Account.Name;
					accRtDevName = evtList[0].Account.RecordType.DeveloperName;
				}
			}else if(filterObject.equals(AV_AppConstants.OBJECT_NAME_TASK)){
				List<Task> tskList = [SELECT AccountId, Subject FROM Task WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
				if(tskList != null && !tskList.isEmpty()){
					recordId = tskList[0].AccountId;
					nameRecord = tskList[0].Subject;
				}
			}
			accClientList = [SELECT Id, Name, RecordType.DeveloperName,AV_NumPerso__c, CC_Numero_Documento__c FROM Account WHERE Id = :recordId WITH SECURITY_ENFORCED];
			if(accClientList != null && !accClientList.isEmpty()){
				accName = accClientList[0].Name;
				accRtDevName = accClientList[0].RecordType.DeveloperName;
				accId = accClientList[0].Id;
				clientNumperToSend = accClientList[0].AV_NumPerso__c;
				accNumDocument = accClientList[0].CC_Numero_Documento__c;
            }
		}else if(clientNumper != null){
			accClientList = [SELECT Id, Name, RecordType.DeveloperName,AV_NumPerso__c, CC_Numero_Documento__c FROM Account WHERE AV_NumPerso__c = :clientNumper WITH SECURITY_ENFORCED];
			if(accClientList != null && !accClientList.isEmpty()){
				accName = accClientList[0].Name;
				accRtDevName = accClientList[0].RecordType.DeveloperName;
				accId = accClientList[0].Id;
				clientNumper = accClientList[0].AV_NumPerso__c;
				accNumDocument = accClientList[0].CC_Numero_Documento__c;
			}
		}
		
		List<Contact> cntGestor = [SELECT AV_EmpleadoIntouch__c,CC_Matricula__c  FROM Contact WHERE AV_UsuarioAsociado__c = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
		return new Map<String,String>{
			'accountName' 	=> accName,
			'rtDevName'   	=> accRtDevName,
			'isIntouch'   	=> (!cntGestor.isEmpty()) ? String.valueOf(cntGestor[0].AV_EmpleadoIntouch__c) : null,
			'nameRecord'  	=> nameRecord,
			'accountId'   	=> accId,
			'contactPlate'	=>  (!cntGestor.isEmpty()) ? String.valueOf(cntGestor[0].CC_Matricula__c) : null,
			'clientNumper'  => clientNumperToSend,
			'numDocument' => accNumDocument,
            'eventType' => eventType,
            'eventDateTime' => eventDateTime,
			'eventInitTime' => eventInitTime,
			'eventEndTime' => eventEndTime        
		};
    }

	public static String getName(Id recordId, String fieldName) {
		String filterObject = recordId.getSObjectType().getDescribe().getName();
		List<sObject> results = Database.query('SELECT ' + String.escapeSingleQuotes(fieldName) + ' FROM ' + String.escapeSingleQuotes(filterObject) + ' WHERE Id = :recordId WITH SECURITY_ENFORCED');
		if(!results.isEmpty()) {
			return String.valueOf(results.get(0).get(fieldName));
		}
        return '';
    }

	@AuraEnabled(cacheable=true)
	public static List<Action> getActions(String actionSetting) {
		List<AV_FlowActions__mdt> actions = [SELECT Id, Label, AV_FlowName__c, AV_Output__c, AV_Order__c,AV_Type__c FROM AV_FlowActions__mdt WHERE AV_Setting__c = :actionSetting ORDER BY AV_Order__c ASC];
		if(actions.isEmpty()) {
			throw new IllegalArgumentException('getActions - No se ha encontrado ninguna flow action con ese setting.');
		}
		List<String> translationNames = new List<String>();
		for(AV_FlowActions__mdt action : actions) {
			translationNames.add(action.label);
		}
		List<Action> result = new List<Action>();
		for(AV_FlowActions__mdt action : actions) {
			Action a = new Action();
			a.id = action.Id;
			a.name = action.AV_FlowName__c;
			a.output = action.AV_Output__c;
			a.label = action.Label;
			a.type = action.AV_Type__c;		
			result.add(a);
		}
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<Object> getFields(Id recordId, String fieldSetName) {
		String filterObject = recordId.getSObjectType().getDescribe().getName();
		Boolean isActivity = (filterObject.equals(AV_AppConstants.OBJECT_NAME_EVENT) || filterObject.equals(AV_AppConstants.OBJECT_NAME_TASK));
		FieldActivity fieldAct = new FieldActivity();
		fieldAct.mapLabelsValue = new Map<String,Object>();
        List<Schema.FieldSetMember> fieldSet = Schema.getGlobalDescribe()
													.get(filterObject)
													.getDescribe()
													.fieldSets
													.getMap()
													.get(fieldSetName)
													.getFields();
		List<Field> result = new List<Field>();
		List<Object> response;
		if(!isActivity){
			response = result;
			for(Schema.FieldSetMember f: fieldSet){
				Field field = new Field();
				field.name = f.getFieldPath();
				result.add(field);
			}
		}else{
			String queryData = 'SELECT ';
			for(Schema.FieldSetMember f: fieldSet){
				queryData += f.getFieldPath()+',';
				if(f.getType() == Schema.DisplayType.REFERENCE){
					queryData += f.getFieldPath().removeEnd('Id')+'.Name,';
				}
			}
			queryData = queryData.removeEnd(AV_AppConstants.COMMA);
			queryData += ' FROM '+filterObject + ' WHERE Id = \''+recordId+'\' LIMIT 1';
			SObject activity;
			if(filterObject.equals(AV_AppConstants.OBJECT_NAME_EVENT)){
				activity = capsulateQueryEvent(queryData);
			}
			if(filterObject.equals(AV_AppConstants.OBJECT_NAME_TASK)){
				activity = capsulateQueryTask(queryData);
			}
			Id accId = (Id) activity.get('WhatId');
			String accName = [SELECT Name FROM Account WHERE Id = :accId WITH SECURITY_ENFORCED LIMIT 1].Name;
			String objectName = AV_AppConstants.OBJECT_NAME_EVENT;
			String fieldApiName = 'AV_Tipo__c';
			Map<String,String> picklistValueSelected = new Map<String,String>();
			DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
			DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldApiName).getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for(Schema.FieldSetMember f: fieldSet){
				Object fechaDef;
				if(f.getType() == Schema.DisplayType.REFERENCE){
					fieldAct.mapLabelsValue.put(
						f.getSObjectField().getDescribe().getLabel(),
						activity.get(f.getFieldPath())+'-'+accName
					);
				}
				else if(f.getType() == Schema.DisplayType.DATETIME){
					Object fecha = activity.get(f.getFieldPath());
					fechaDef = formatDate(fecha);
					fieldAct.mapLabelsValue.put(
						f.getSObjectField().getDescribe().getLabel(),
						fechaDef
					);
				}else {
					fieldAct.mapLabelsValue.put(
						f.getSObjectField().getDescribe().getLabel(),
						activity.get(f.getFieldPath())
					);
				}
				for(Schema.PicklistEntry pickListVal : ple){
					if(String.valueOf(picklistVal.getValue()) == activity.get(f.getFieldPath())){
						picklistValueSelected.put(String.valueOf(pickListVal.getLabel()),String.valueOf(pickListVal.getValue()));
					}
				}
				for(String p: picklistValueSelected.keySet()){
					if(activity.get(f.getFieldPath())== picklistValueSelected.get(p)){
						fieldAct.mapLabelsValue.put(
							f.getSObjectField().getDescribe().getLabel(),
							picklistValueSelected.keySet()
						);
					}
				}
			}
			response = new List<Object>{ fieldAct.mapLabelsValue};
		}
		return response;
    }



	private static Task capsulateQueryTask(String q){//Método para pasar qualityClouds
		return (Task) Database.query(q);
	}

	private static Event capsulateQueryEvent(String q){//Método para pasar qualityClouds
		return (Event) Database.query(q);
	}

	public static Object formatDate(Object fechaObj) {
		Object fechaFormat;
		if (fechaObj != null ) {
			Datetime fechaDatetime = (Datetime) fechaObj;
			String fechaStr = fechaDatetime.format('d/M/yyyy H:mm');
			fechaFormat = (Object)fechaStr;
			return fechaFormat;
		}
		return null; 
	}

	public class Field {
		@AuraEnabled public String name;
		@AuraEnabled public String helpText;
		@AuraEnabled public Boolean isRating;
	}
	
	public class FieldActivity {
		@AuraEnabled public Map<String,Object> mapLabelsValue;
	}

	public class Action {
		@AuraEnabled public String id;
		@AuraEnabled public String label;
		@AuraEnabled public String name;
		@AuraEnabled public String output;
		@AuraEnabled public String type;
	}

	/*
	@AuraEnabled(cacheable=true)
	public static String getDateLoad(Id recordId) {
		List<String> mesesES = new List<String>{'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'};
		Account acc = [SELECT Id, CIBE_FechaRating_SP__c FROM Account WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
		if (acc != null && acc.CIBE_FechaRating_SP__c != null) {
			Integer year = acc.CIBE_FechaRating_SP__c.year();
			Integer month = acc.CIBE_FechaRating_SP__c.month();
			return 'Relativo a: ' + mesesES.get(month-1) + '-' + String.valueOf(year);
		}
		return null;
	}
	*/
	
	@AuraEnabled(cacheable=true)
	public static List<String> getRecordsFieldsHeaderEvent(Id recordId,List<String> labels){
		Event ev= [SELECT StartDateTime, EndDateTime,WhatId,type,CSBD_Evento_Estado__c FROM Event WHERE id =:recordId WITH SECURITY_ENFORCED LIMIT 1];
		return null;
	}
}