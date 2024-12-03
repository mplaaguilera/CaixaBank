/**********************************************************************************************************************
Name:	  AV_TabManagementTask_Controller
Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC av_TabNotLocated
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			Init    		Sandra Gómez 	    15/02/2021		Init version added updateTask method
	1.1			Init    		Jashanpreet		    15/02/2021		Added updateTaskReminder method
	1.1			Init    		Víctor Santiago	    16/02/2021		Added getRecordType method
	1.1			Init    		Jashanpreet		    17/02/2021		Added getManagementHistory method
	1.1			Init    		Jashanpreet		    19/02/2021		Added getPickListValuesByRecordTypeId method
	1.5			Init    		Víctor Santiago	    24/02/2021		Added labels on update methods, added getTaskStatus method
	1.6			Bug				Sandra Gómez 		16/03/2021		Remove validation fecha in method updateTaskNotLocated
	1.7			Bug				Víctor Santiago		13/04/2021		All update methods now check if comment is blank before overwriting it
	1.8			Bug				Víctor Santiago		14/04/2021		All update methods now check if comment is blank before updating it
	1.9			FIX				David Rufo			15/07/2021		Fix problems with check on/off priorizador
	2.0			US254520		Víctor Santiago		27/07/2021		New param picklistDevName and query filter in getPickListValuesByRecordTypeId.
																	Method created: insertOrUpdateActivityExt, getExperienciaClienteData
																	Wrapper class created: ExpClienteDataWrapper
																	updateTask modification: added 3 last params, added exp. cliente filter.
	2.1			US288303		Daniel Rodriguez	05/11/2021		Update and duplicate the insertOrUpdateActivityExt method for improvements in the task closing flow of the second survey
																	Update getResponseHGM method to insert new insertOrUpdateActivityExt method.
	2.2			DE54207			Víctor Santiago		22/11/2021		Added exp. cliente filter to getExperienciaClienteData
	2.3			US268502		Daniel Rodríguez	31/01/2022		Add updateTaskReportOpp method 
	2.4		    AV_Query IT	    Daniel Rodríguez	07/02/2022	    Change AV_Query to SOQL for User and Account
	2.5 		USUS321965		Luis Fernandez		21/03/2022		Added "OwnerId" selectField to  updtateTask task query
																	Added conditional to updateTask
	3.1			US457715		Eduardo González	19/10/2022		Modify without sharing class
																	Add condition sinGestorEAP in method updateTask
    3.2			US418597		Luis Fernández		 09/11/2022		Added insertEventRelated() and reLinkOppToEvent to insert event related tasks 
	3.3         US224264        Elisabeth Rodríguez  11/11/2022     Added dontCreateEvent parameter to updateTask method
	3.4         US505964        Patricia Solano  	 05/01/2023     Modify method getResponseHGM to change AV_Valor1__c to AV_SurveyValue__c
	3.5         US517394        Patricia Solano  	 03/02/2023     Modify method getResponseHGM to remove the part before to character : 
	3.6         US517394        Patricia Solano  	 08/02/2023     Change AV_Query to SOQL
	3.7			DE72163			Sandra Gómez		 15/02/2023		Add onClick Persona de Contacto
	3.8			US539076		Vladislav Lityagin	 21/02/2023		Removed insertEventRelated, reLinkOppToEvent and dontCreateEvent parameter
	3.9			DE72361			Patricia Solano 	 23/03/2023		Modify method getResponseHGM to change the condition according to task recordtype
	4.0         US308354        Elisabeth R          01/03/2023     Added getIsIntouch method
	4.1			US584558		Patricia Villacañas	 09/05/2023		Added center parameter in method getResponseHGM_fw
	4.2			US610044		Luis Fernández		 19/06/2023		Added AV_SalesforceReport to AV_OrigenApp in every update from updateTask 
***********************************************************************************************************************/
public without sharing class AV_TabManagementTask_Controller {
	
    @AuraEnabled
	public static String updateTask(String id, String estado, String tipo, Date fecha, String comentario, String acciones, String motivo, String valoracion, String contacto , Datetime activityDateTime) {
		String methodName = 'updateTask';
		User sinGestorEAP = [SELECT ID FROM USER WHERE Alias = 'AV-TF9' LIMIT 1];
        
		Task tarea = [SELECT Id, AccountId,Subject,Status, AV_Tipo__c, AV_Center__c,Description, ActivityDate, RecordType.DeveloperName, AV_ExternalID__c, LastModifiedDate,OwnerId,AV_Task__c FROM Task Where Id =: id LIMIT 1 ];
		if( tarea.id != null){			
		 if( tarea.ownerId != UserInfo.getUserId() && tarea.ownerId != sinGestorEAP.Id){
			return Label.AV_CMP_DiffUserOwner;
			}		
		}
			tarea.Status=estado;
			tarea.AV_Tipo__c=tipo;
		tarea.AV_OrigenApp__c = 'AV_SalesforceReport';
		if('AV_Otros'.equals(tarea.RecordType.DeveloperName) && (AV_AppConstants.GESTIONADO_POSITIVO_ESTADO.equals(estado) || AV_AppConstants.GESTIONADO_NEGATIVA_ESTADO.equals(estado))){
			tarea.ActivityDate = fecha;
			if (String.isNotBlank(comentario)) {
				tarea.Description = String.isNotBlank(tarea.Description) ? tarea.Description  + '\n' + fecha.format() + ' - ' + comentario : fecha.format() + ' - ' + comentario;
			}
			if(String.isNotBlank(contacto)) {
				tarea.WhoId = contacto;
			}
		}
		else if ('AV_ExperienciaCliente'.equals(tarea.RecordType.DeveloperName)) {
			
			String actExtSr = insertOrUpdateActivityExt(id, acciones, motivo, valoracion);
			if (!'OK'.equals(actExtSr)) {
				return actExtSr;
			}
			if (String.isNotBlank(comentario)) {
				tarea.Description = String.isNotBlank(tarea.Description) ? tarea.Description  + '\n' + fecha.format() + ' - ' + comentario : fecha.format() + ' - ' + comentario;
			}
			if(String.isNotBlank(contacto)) {
				tarea.WhoId = contacto;
			}
		}
        else if(fecha <= Date.today()){
			if (String.isNotBlank(comentario)) {
				tarea.Description = String.isNotBlank(tarea.Description) ? tarea.Description  + '\n' + fecha.format() + ' - ' + comentario : fecha.format() + ' - ' + comentario;
			}
			if(String.isNotBlank(contacto)) {
				tarea.WhoId = contacto;
			}
		}
        else{
			return Label.AV_ErrorGTDueDate;
		}
        
        //Save the data
        Database.SaveResult sr = Database.update(tarea, false);
        if(!sr.isSuccess()) {	    
            for(Database.Error err : sr.getErrors()) {
                AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
                return err.getMessage();
            }
        }
	
        return 'OK';
	}

	@AuraEnabled
	public static String updateTaskReportOpp(String id, String asunto, String tipo, String comentario, Date fecha, String empleado, String cliente, String contacto) {
		String methodName = 'updateTask';
		Task tarea = [SELECT Id, Status, AV_Tipo__c, OwnerId, Subject, Description, WhatId, AccountId, ActivityDate, RecordType.DeveloperName, AV_ExternalID__c, LastModifiedDate FROM Task WHERE Id = :id LIMIT 1];
		if('AV_Otros'.equals(tarea.RecordType.DeveloperName) && (AV_AppConstants.GESTIONADO_POSITIVO_ESTADO.equals(tarea.Status) || AV_AppConstants.GESTIONADO_NEGATIVA_ESTADO.equals(tarea.Status))){
			tarea.AV_Tipo__c=tipo;
			tarea.ActivityDate = fecha;
			tarea.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT;
			if (String.isNotBlank(contacto)) {tarea.WhoId = contacto;}
			if (String.isNotBlank(asunto)) {tarea.Subject = asunto;}
			if (String.isNotBlank(cliente)) {tarea.WhatId = cliente;}
			if (String.isNotBlank(empleado)) {tarea.ownerId = empleado;}
			if (String.isNotBlank(comentario)) {tarea.Description = String.isNotBlank(tarea.Description) ? tarea.Description  + '\n' + fecha.format() + ' - ' + comentario : fecha.format() + ' - ' + comentario;}
		}
	
        //Save the data
        Database.SaveResult sr = Database.update(tarea, false);
        if(!sr.isSuccess()) {	    
            for(Database.Error err : sr.getErrors()) {AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
                return err.getMessage();}
        }
        return 'OK';
	}

	
	@AuraEnabled
	public static String insertOrUpdateActivityExt(String taskId, String acciones, String motivo, String valoracion) {
		String result = 'OK';
		String methodName = 'insertOrUpdateActivityExt';
		Database.SaveResult sr;

		CBK_Activity_Extension__c actExt;
		List<CBK_Activity_Extension__c> actExtList = [SELECT AV_ActivityId__c,
		 AV_AccionesARealizar__c, AV_MotivoCierreExperienciaCliente__c, AV_ValoracionGestion__c
		 FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :taskId LIMIT 1];
		 
		if(!actExtList.isEmpty()){
			actExt = actExtList[0];
		}	
			if (actExt == null) {
				actExt = new CBK_Activity_Extension__c();
				actExt.AV_ActivityId__c = taskId;
				actExt.AV_AccionesARealizar__c = String.isNotEmpty(acciones) ? acciones : null;
				actExt.AV_MotivoCierreExperienciaCliente__c = String.isNotEmpty(motivo) ? motivo : null;
				actExt.AV_ValoracionGestion__c = String.isNotEmpty(valoracion) ? valoracion : null;
				sr = Database.insert(actExt, false);
			} else {
				actExt.AV_AccionesARealizar__c = String.isNotEmpty(acciones) ? acciones : null;
				actExt.AV_MotivoCierreExperienciaCliente__c = String.isNotEmpty(motivo) ? motivo : null;
				actExt.AV_ValoracionGestion__c = String.isNotEmpty(valoracion) ? valoracion : null;
				sr = Database.update(actExt, false);
			}
		

		if (!sr.isSuccess()) {
			for(Database.Error err : sr.getErrors()) {
                AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
                result = err.getMessage();
            }
		}
		
		return result;
	}

	@AuraEnabled
	public static String insertOrUpdateActivityExt(String taskId,  String jsonEncuesta, String estadoEncuenta) {
		String result = 'OK';
		String methodName = 'insertOrUpdateActivityExt';
		Database.SaveResult sr;
		CBK_Activity_Extension__c actExt = [SELECT AV_ActivityId__c, AV_AccionesARealizar__c, AV_MotivoCierreExperienciaCliente__c, AV_ValoracionGestion__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :taskId LIMIT 1];
			if (actExt == null) {
				actExt = new CBK_Activity_Extension__c();
				actExt.AV_ActivityId__c = taskId;
				actExt.AV_ReasignarCartera_JSONAPI__c = String.isNotEmpty(jsonEncuesta) ? jsonEncuesta : null;
				actExt.AV_StatusCodeAPI__c = String.isNotEmpty(estadoEncuenta) ? estadoEncuenta : null;
				sr = Database.insert(actExt, false);
			} else {
				actExt.AV_ReasignarCartera_JSONAPI__c = String.isNotEmpty(jsonEncuesta) ? jsonEncuesta : null;
				actExt.AV_StatusCodeAPI__c = String.isNotEmpty(estadoEncuenta) ? estadoEncuenta : null;
				sr = Database.update(actExt, false);
			}
		

		if (!sr.isSuccess()) {
			for(Database.Error err : sr.getErrors()) {
                AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
                result = err.getMessage();
            }
		}
		
		return result;
	}

	@AuraEnabled
	public static String updateTaskNotLocated(String id, String estado, String tipo, Date fecha, String comentario) {
		Task tarea = [SELECT Id, Status, AV_Tipo__c, Description, ActivityDate FROM Task WHERE Id = :id LIMIT 1];
		tarea.Status=estado;
		tarea.AV_Tipo__c=tipo;
		if (String.isNotBlank(comentario)) {
			tarea.Description = String.isNotBlank(tarea.Description) ? tarea.Description  + '\n' + fecha.format() + ' - ' + comentario : fecha.format() + ' - ' + comentario;
		}
		Database.SaveResult sr = Database.update(tarea, false);
		if(!sr.isSuccess()) {	    
			for(Database.Error err : sr.getErrors()) {
				AV_LogDebug.printLogDebug('updateTask', 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
				return err.getMessage();
			}
		}
		return 'OK';
	}

	@AuraEnabled
	public static String updateTaskReminder(String id, Datetime reminderDateTime, String comentario) {

		if(reminderDateTime > Datetime.now()){
			Task tarea = [SELECT Id, Status, AV_Tipo__c, ActivityDate, Description, IsReminderSet, ReminderDateTime,RecordType.DeveloperName FROM Task WHERE Id = :id LIMIT 1];
			tarea.Id=id;
			tarea.Status=AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL;
			tarea.IsReminderSet=true;
			Date fecha =  date.newinstance(reminderDateTime.year(), reminderDateTime.month(), reminderDateTime.day());
            if('AV_Otros'.equals(tarea.RecordType.DeveloperName) && tarea.ActivityDate < fecha){
                tarea.ActivityDate = fecha;
            }
			if (String.isNotBlank(comentario)) {
				tarea.Description = String.isNotBlank(tarea.Description) ? tarea.Description  + '\n' + reminderDateTime.date().format() + ' - ' + comentario : reminderDateTime.date().format() + ' - ' + comentario;
			}
			tarea.ReminderDateTime=reminderDateTime;
			Database.SaveResult sr = Database.update(tarea, false);
			if(!sr.isSuccess()) {	    
				for(Database.Error err : sr.getErrors()) {
					AV_LogDebug.printLogDebug('updateTask', 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
					return err.getMessage();
				}
			}
			return 'OK';
		}else{
			return Label.AV_ErrorLTTodaysTime;
		}
		
	}

	@AuraEnabled
	public static String getRecordType(String id){
		String recordType;
			if (id.charAt(2) == 84) { 
					Task tarea = [SELECT RecordType.DeveloperName FROM Task WHERE Id = :id LIMIT 1];
				recordType = tarea.RecordType.DeveloperName;
			} else {
				Event evt = [SELECT RecordType.DeveloperName FROM Event WHERE Id = :id LIMIT 1];
				recordType = evt.RecordType.DeveloperName;
			}
			return recordType;
	}

	@AuraEnabled
	public static List<DataTableWrapper> getManagementHistory(String id){
		try {
			List<AV_ManagementHistory__c> data = [SELECT Id,AV_ActivityId__c,AV_Comment__c,AV_Date__c,AV_Reminder__c, toLabel(AV_Type__c), toLabel(AV_Status__c) FROM AV_ManagementHistory__c WHERE AV_ActivityId__c = :id ORDER BY CreatedDate DESC];
			List<DataTableWrapper> response = new List<DataTableWrapper>();
			Integer cont=0;
			for (AV_ManagementHistory__c d : data) {
				DataTableWrapper obj = new DataTableWrapper();
				obj.comment = d.AV_Comment__c;
				obj.status = d.AV_Status__c;
				obj.dateManagement = d.AV_Date__c;
				obj.reminder = d.AV_Reminder__c;
				obj.type = d.AV_Type__c;
				if (cont == 0) {
					obj.t1='slds-icon-custom-custom16 slds-text-color_default';
					cont++;
				} else {
					obj.t1='';
				}
				response.add(obj);
			}
			return response;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@TestVisible private class DataTableWrapper {
        @AuraEnabled
        public String comment {get;set;}

        @AuraEnabled
        public String status {get;set;}

        @AuraEnabled
        public Date dateManagement {get;set;}

        @AuraEnabled
        public Datetime reminder {get;set;}

        @AuraEnabled
        public String type {get;set;}

		@AuraEnabled
        public String t1 {get;set;}
    }

	@AuraEnabled
	public static List<Map<String, String>> getPickListValuesByRecordTypeId(string objectName, string recordId,string fieldApiName, String picklistDevName) {
		// query to custom metada type --> Picklist List Value By Record Type
		// api name de picklist in List
		// String recordTypeName = getRecordType(recordId);
		AV_PicklistListValuesByRecordType__mdt picklistValues = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, AV_ListSalesProcess__c, AV_ObjectLabel__c, AV_RecordTypeLabel__c FROM AV_PicklistListValuesByRecordType__mdt WHERE AV_ObjectLabel__c = :objectName AND DeveloperName = :picklistDevName LIMIT 1];
		List<String> pickValues = new List<String>();
		pickValues = picklistValues.AV_ListSalesProcess__c.split(';');
		List<Map<String, String>> listPicklist = new List<Map<String, String>>();
        // Get the describe for the object
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        // Get the field dynamically
        DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldApiName).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for(Schema.PicklistEntry pickListVal : ple){
			for(String val:pickValues){
				if (val == String.valueOf(pickListVal.getLabel())) {
					listPicklist.add(new Map<String, String>{'label' => String.valueOf(pickListVal.getLabel()), 'value' => String.valueOf(pickListVal.getValue())});
				}
			}
        }
        return listPicklist;
	}

	@AuraEnabled
	public static Task getTaskStatus(String id){
		try {
			Task tarea = [SELECT Status, ActivityDate, IsClosed, AV_OrigenApp__c FROM Task WHERE Id = :id LIMIT 1];
			return tarea;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Boolean showAssignPurse(String taskId){
		List<CBK_Activity_Extension__c> lstTarea = [SELECT AV_StatusCodeAPI__c FROM CBK_Activity_Extension__c WHERE AV_ReasignarCartera_Id_Task__c = :taskId AND AV_StatusCodeAPI__c != null LIMIT 1];
		if(!lstTarea.isEmpty()){
			return !'200'.equalsIgnoreCase(lstTarea[0].AV_StatusCodeAPI__c);
		}else{
		    return true;
		} 
	}
		
		
	@AuraEnabled
	public static ExpClienteDataWrapper getExperienciaClienteData(String id) {
		Task tarea = [SELECT Id, AV_Tipo__c FROM Task WHERE Id = :id AND RecordType.DeveloperName = :'AV_ExperienciaCliente' LIMIT 1];
		AV_ManagementHistory__c historial = [SELECT Id, AV_Comment__c, AV_Date__c FROM AV_ManagementHistory__c WHERE AV_ActivityId__c = :id ORDER BY CreatedDate DESC LIMIT 1];
		CBK_Activity_Extension__c actExt = [SELECT Id, AV_MotivoCierreExperienciaCliente__c, AV_AccionesARealizar__c, AV_ValoracionGestion__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :id LIMIT 1];

		ExpClienteDataWrapper wrapper;
		if (tarea != null && historial != null && actExt != null) {
			wrapper = new ExpClienteDataWrapper();
			wrapper.fechaGestion = historial.AV_Date__c != null ? historial.AV_Date__c : null;
			wrapper.tipo = String.isNotEmpty(tarea.AV_Tipo__c) ? tarea.AV_Tipo__c : null;
			wrapper.comment = String.isNotEmpty(historial.AV_Comment__c) ? historial.AV_Comment__c : null;
			wrapper.motivo = String.isNotEmpty(actExt.AV_MotivoCierreExperienciaCliente__c) ? actExt.AV_MotivoCierreExperienciaCliente__c : null;
			wrapper.acciones = String.isNotEmpty(actExt.AV_AccionesARealizar__c) ? actExt.AV_AccionesARealizar__c : null;
			wrapper.valoracion = String.isNotEmpty(actExt.AV_ValoracionGestion__c) ? actExt.AV_ValoracionGestion__c : null;
		}
		
		return wrapper;
	}

	public class ExpClienteDataWrapper {
		@AuraEnabled
		public Date fechaGestion {get;set;}

		@AuraEnabled
		public String tipo {get;set;}
		
		@AuraEnabled
		public String motivo {get;set;}
		
		@AuraEnabled
		public String acciones {get;set;}
		
		@AuraEnabled
		public String comment {get;set;}
		
		@AuraEnabled
		public String valoracion {get;set;}
	}
	
	@AuraEnabled
	//@Future(callout=true)
	public static void getResponseHGM(String id, Date managementDateTask) {
		String methodName = 'getResponseHGM';
        String result = null;

        
		AV_HGM_Integration.CustomerData datacliente = new AV_HGM_Integration.CustomerData();
		if (String.isNotBlank(id) && managementDateTask != null) {

            String idCliente = null;
            Datetime createdDateTask = null;
            String numper = null;
            String typeSurvey = null;
			String tokenValue = null;
			
			Task tarea = [SELECT Id, AccountId, CreatedDate, AV_SurveyValue__c, AV_Valor5__c, CC_Empleado_Gestor__c, Account.RecordType.DeveloperName,Account.AV_NumPerso__c FROM Task WHERE Id =: id];
			if (tarea != null) {
				idCliente = tarea.AccountId;
				createdDateTask = tarea.CreatedDate;
				typeSurvey = String.valueOf(tarea.AV_SurveyValue__c);
				tokenValue = tarea.AV_Valor5__c;
			}
			
			
            if (String.isNotBlank(idCliente) && String.isNotBlank(typeSurvey)  && createdDateTask != null) {
				if (tarea.Account.RecordType.DeveloperName.equalsIgnoreCase(AV_AppConstants.ACCOUNT_PA_RT)) {

					Account cliente = [SELECT Id, AV_NumPerso__c, FirstName, LastName, PersonEmail, PersonMobilePhone, AV_Idioma__c FROM Account WHERE Id = :idCliente];
					if (cliente != null) {
						datacliente.firstname = cliente.FirstName;
						datacliente.lastname = cliente.LastName;
						datacliente.email = cliente.PersonEmail;
						datacliente.prefix = null;
						datacliente.phone = null;
						numper = cliente.AV_NumPerso__c;
						datacliente.language='es'; //Default spanish
						if (String.isNotBlank(cliente.AV_Idioma__c) && '001'.equalsIgnoreCase(cliente.AV_Idioma__c)){
							datacliente.language='ca'; //catalan
						} 
						else if (String.isNotBlank(cliente.AV_Idioma__c) && '010'.equalsIgnoreCase(cliente.AV_Idioma__c)){
							datacliente.language='en'; //english
						}
					}
				} else if (tarea.Account.RecordType.DeveloperName.equalsIgnoreCase(AV_AppConstants.ACCOUNT_ENT_RT)) {
					
					Contact contact = [SELECT Id, AV_NumPerso__c ,FirstName, LastName, Email, Phone, CC_Idioma__c FROM Contact WHERE Id = :tarea.CC_Empleado_Gestor__c];

					if (contact != null){
						datacliente.firstname = contact.FirstName;
						datacliente.lastname = contact.LastName;
						datacliente.email = contact.Email;
						datacliente.prefix = null;
						datacliente.phone = null;
						numper = contact.AV_NumPerso__c;
						datacliente.language='es'; //Default spanish
                        if (String.isNotBlank(contact.CC_Idioma__c) && '001'.equalsIgnoreCase(contact.CC_Idioma__c)){
                            datacliente.language = 'ca'; //catalan
                        } 
                        else if (String.isNotBlank(contact.CC_Idioma__c) && '010'.equalsIgnoreCase(contact.CC_Idioma__c)){
                            datacliente.language = 'en'; //english
                    	}
					}
				}
				// revome content before the characters ': '
				if (tokenValue != null && tokenValue != '') {
					if (tokenValue.contains(':')) {
						Integer charToCut = tokenValue.indexOf(':') + 1;
						if (charToCut != -1) {
							tokenValue = tokenValue.substring(charToCut).replaceAll( '\\s+', '');
						} 
					}
				}
				datacliente.attributes=new List<String> ();
				datacliente.attributes.add(String.valueOf(createdDateTask));
				if (tarea.Account.RecordType.DeveloperName.equalsIgnoreCase(AV_AppConstants.ACCOUNT_ENT_RT)) {
					datacliente.attributes.add(tarea.Account.AV_NumPerso__c);
				}else {
					datacliente.attributes.add(String.valueOf(managementDateTask));
				}
				datacliente.attributes.add(null);
				datacliente.attributes.add(tokenValue);

				//numper != null &&
				if ( datacliente != null && typeSurvey != null) {
					AV_TabManagementTask_Controller.getResponseHGM_fw(id,JSON.serialize(datacliente),numper,typeSurvey);
				}
			}
		}
	}

	@AuraEnabled
	@Future(callout=true)
	public static void getResponseHGM_fw(String tareaId, String dataString, String numper, String typeSurvey) { 
		String methodName = 'getResponseHGM_fw';
        String result = null;
		AV_HGM_Integration.CustomerData datacliente = null;
		Task tarea = [SELECT Id, AV_Center__c FROM Task WHERE Id =: tareaId];
		String center = tarea.AV_Center__c;
		if (typeSurvey != null) {
			String triggerId = typeSurvey;
			datacliente = (AV_HGM_Integration.CustomerData) JSON.deserialize(dataString, AV_HGM_Integration.CustomerData.class);
			if (String.isNotBlank(triggerId) && datacliente!=null) {
				AV_HGM_Integration.SurveyResponse hgmSR = AV_HGM_Integration.getSurveyId_fw(triggerId);
				if('200'.equalsIgnoreCase(hgmSR.statusCode)){
					Integer surveyId = hgmSR.data.surveyId;
					if (surveyId != null){
						AV_HGM_Integration.CustomerResponse hgmCR = AV_HGM_Integration.getHGMCustomer_fw(numper, surveyId, datacliente, center);
						if('200'.equalsIgnoreCase(hgmCR.statusCode) && hgmCR.errorMessage==null && schema.SObjectType.CBK_Activity_Extension__c.isCreateable()){
							AV_LogDebug.printLogDebug(methodName, '1er if  - error: ' + hgmCR.errorMessage);
							result = 'OK';
							insertOrUpdateActivityExt(tareaId, null, '200');
						}else if('200'.equalsIgnoreCase(hgmCR.statusCode) && hgmCR.errorMessage!=null && schema.SObjectType.CBK_Activity_Extension__c.isCreateable()){
							AV_LogDebug.printLogDebug(methodName, 'else if - error: ' + hgmCR.errorMessage);
							insertOrUpdateActivityExt(tareaId, JSON.serialize(hgmCR), hgmCR.errorCode);
							result = JSON.serialize(hgmCR);
						}else{ 
							AV_LogDebug.printLogDebug(methodName, 'else final - error: ' + hgmCR.errorMessage);
							insertOrUpdateActivityExt(tareaId, JSON.serialize(hgmCR.errorMessage), hgmCR.statusCode);
							result = JSON.serialize(hgmCR);
						}
					}
				} else {
					result = JSON.serialize(hgmSR);
				}
			}
		}
		AV_LogDebug.printLogDebug(methodName, 'result: ' + result);
	}

	@AuraEnabled
	public static List<AV_LookupSearchResult> getContact(String searchTerm, List<String> selectedIds, String accountId){
		String methodName = 'getContact';
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		if(!selectedIds.isEmpty()){
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

	private static List<Contact> capsulateQuery(String q, List<String> listIds, String accountId) {
		return (List<Contact>) Database.query(q);
	}

	@AuraEnabled
	public static Task getContactTask(String idRecords){
		Task results = [Select id, WhoId, Who.Name, WhatId,AccountId from Task where id = :idRecords limit 1];
		return results;
	}

	@AuraEnabled
	public static Boolean acccountCliente(String accountId){
		Boolean result = false;
		Account acc = [Select RecordType.DeveloperName from Account where Id = :accountId limit 1];
		if (acc.RecordType.DeveloperName == 'CC_Cliente'){
			result = true;
		}
		return result;
	}


	@AuraEnabled
	public static Boolean getIsIntouch(String userExternalId){
		Boolean result = false;
		List<Contact> lstIsIntouchContact = [SELECT Id,AV_EmpleadoIntouch__c FROM Contact WHERE CC_Matricula__c =: userExternalId AND RecordType.DeveloperName =: AV_AppConstants.EMPLOYEE_RT LIMIT 1];
		if(!lstIsIntouchContact.isEmpty()){
			if(lstIsIntouchContact[0].AV_EmpleadoIntouch__c == true){
				result = true;
			}else{
				result = false;
			}
		}
		return result;
	}


}