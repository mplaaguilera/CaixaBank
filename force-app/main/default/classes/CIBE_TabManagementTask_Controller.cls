/**********************************************************************************************************************
Name:	  CIBE_TabManagementTask_Controller
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller for the LWC cibe_TaskTabs
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US420186    	Jose Maria	  	    20/10/2021		Init version copy retail methods 
	1.1			US456255 		Alicia				30/11/2022		Edit: updateTask, getRecordType, getTaskStatus, getExperienciaClienteData, getPickListValuesByRecordTypeId, insertOrUpdateActivityExt
	1.2			DE77150 		Lucia				29/06/2023		MOdificado el metodo validateHGM
	1.3         US540119        Alexandre Perez		18/07/2023		Adapted to new NPS endPoint using fw
	1.4			US585878		Bea					28/09/2023		Added  getNoGestionable method
***********************************************************************************************************************/
public without sharing class CIBE_TabManagementTask_Controller {
    

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
	public static String getRecordType(String id){
		String recordType;
		// try {
			if (id.charAt(2) == 84) { // ASCII(T) = 84
				
				Task tarea = [SELECT RecordType.DeveloperName FROM Task WHERE Id = :id LIMIT 1];
				recordType = tarea.RecordType.DeveloperName;
			} else {
				
				Event evt = [SELECT RecordType.DeveloperName FROM Event WHERE Id = :id LIMIT 1];
				recordType = evt.RecordType.DeveloperName;
			}
			return recordType;
		// } catch (Exception e) {
			// throw new AuraHandledException(e.getMessage());
		// }	
	}
    
    @AuraEnabled
	public static Boolean showAssignPurse(String taskId){

		CBK_Activity_Extension__c tarea = [SELECT AV_StatusCodeAPI__c FROM CBK_Activity_Extension__c WHERE AV_ReasignarCartera_Id_Task__c = :taskId AND AV_StatusCodeAPI__c != null];
		// CBK_Activity_Extension__c tarea=(CBK_Activity_Extension__c)new AV_Query('CBK_Activity_Extension__c')
		// 							.selectFields('AV_StatusCodeAPI__c')
		// 							.addConditionEq('AV_ReasignarCartera_Id_Task__c', taskId)
		// 							.addConditionNotEq('AV_StatusCodeAPI__c',null)
		// 							.fetch();
		if(tarea != null) {
			return !'200'.equalsIgnoreCase(tarea.AV_StatusCodeAPI__c);
		}
		else {
			return true;
		}
	}


	private class DataTableWrapper {
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
	public static List<DataTableWrapper> getManagementHistory(String id){
		try {
			// String query = 'SELECT Id, AV_ActivityId__c, AV_Comment__c, AV_Date__c, AV_Reminder__c, TOLABEL(AV_Type__c), TOLABEL(AV_Status__c), ';
			// query += ' FROM AV_ManagementHistory__c ';
			// query += ' WHERE AV_ActivityId__c = :id ORDER BY CreatedDate DESC '; 
			//List<AV_ManagementHistory__c> data = (List<AV_ManagementHistory__c>) Database.query(query);


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

	@AuraEnabled
	public static List<Map<String, String>> getPickListValuesByRecordTypeId(string objectName, string recordId,string fieldApiName, String picklistDevName) {
		// query to custom metada type --> Picklist List Value By Record Type
		// api name de picklist in List
		String recordTypeName = getRecordType(recordId);

		List<AV_PicklistListValuesByRecordType__mdt> picklistValues = [SELECT id, AV_ListSalesProcess__c, DeveloperName, AV_ObjectLabel__c
																			FROM AV_PicklistListValuesByRecordType__mdt 
																			WHERE DeveloperName=:picklistDevName AND AV_ObjectLabel__c =:objectName];
		List<String> pickValues = new List<String>();
		pickValues = picklistValues[0].AV_ListSalesProcess__c.split(';');
		
		if(pickValues.isEmpty()) {
			throw new IllegalArgumentException('No se ha encontrado ningun valor en el picklist.');
		}

        // Get the describe for the object
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
		
        // Get the field dynamically
        DescribeFieldResult fieldResult = objResult.fields.getMap().get(fieldApiName).getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
		// loop to Schema picklist 
		List<Map<String, String>> listPicklist = new List<Map<String, String>>();
        for(Schema.PicklistEntry pickListVal : ple){
			for(String val : pickValues){
				if (val == String.valueOf(pickListVal.getValue())) {
					listPicklist.add(
						new Map<String, String>{
							'label' => String.valueOf(pickListVal.getLabel()), 
							'value' => String.valueOf(pickListVal.getValue())});
				}
			}
        }
        return listPicklist;
	}

	@AuraEnabled
	public static String updateTaskNotLocated(String id, String estado, String tipo, Date fecha, String comentario) {
		Task tarea = [SELECT Id, Status, AV_Tipo__c, Description, ActivityDate FROM Task WHERE Id = :id];
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
			Task tarea = [SELECT Id, Status, AV_Tipo__c, ActivityDate, Description, IsReminderSet, ReminderDateTime,RecordType.DeveloperName FROM Task WHERE Id = :id];
			tarea.Id=id;
			tarea.Status=CIBE_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL;
			tarea.IsReminderSet=true;
			Date fecha =  date.newinstance(reminderDateTime.year(), reminderDateTime.month(), reminderDateTime.day());
            if(('CIBE_OtrosCIB'.equals(tarea.RecordType.DeveloperName) || 'CIBE_OtrosEMP'.equals(tarea.RecordType.DeveloperName)) && tarea.ActivityDate < fecha){
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
	public static String updateTask(String id, String estado, String tipo, Date fecha, String comentario, String acciones, String motivo, String valoracion,String contacto , Datetime activityDateTime, Boolean dontCreateEvent) {
		String methodName = 'updateTask';
		User sinGestorEAP = [SELECT ID FROM USER WHERE Alias = 'AV-TF9' LIMIT 1];
        List<String> eventRelatedTypes = new List<String>{
			CIBE_AppConstants.LLAMADA_TIPO,
			CIBE_AppConstants.CITA_OFICINA_TIPO,
			CIBE_AppConstants.CITA_TELEFONICA_TIPO,
			CIBE_AppConstants.VIDEOLLAMADA_TIPO,
			CIBE_AppConstants.VISITA_TIPO
		};
		
		Task tarea = [SELECT Id, AccountId,Subject,Status, AV_Tipo__c, AV_Center__c,Description, ActivityDate, RecordType.DeveloperName, AV_ExternalID__c, LastModifiedDate,OwnerId,AV_Task__c FROM Task WHERE Id = :id LIMIT 1 ];

		if( tarea.id != null){			
		 if( tarea.ownerId != UserInfo.getUserId() && tarea.ownerId != sinGestorEAP.Id){
			return Label.AV_CMP_DiffUserOwner;
			}		
		}
		if('CIBE_OtrosCIB'.equals(tarea.RecordType.DeveloperName) && (CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO.equals(estado) || CIBE_AppConstants.GESTIONADO_NEGATIVA_ESTADO.equals(estado))){
			tarea.Status=estado;
			
			tarea.AV_Tipo__c=tipo;
			tarea.ActivityDate = fecha;
			if (String.isNotBlank(comentario)) {
				tarea.Description = String.isNotBlank(tarea.Description) ? tarea.Description  + '\n' + fecha.format() + ' - ' + comentario : fecha.format() + ' - ' + comentario;
			}
			if(String.isNotBlank(contacto)) {
				tarea.WhoId = contacto;
			}
		}
		else if('CIBE_OtrosEMP'.equals(tarea.RecordType.DeveloperName) && (CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO.equals(estado) || CIBE_AppConstants.GESTIONADO_NEGATIVA_ESTADO.equals(estado))){
			tarea.Status=estado;
			
			tarea.AV_Tipo__c=tipo;
			tarea.ActivityDate = fecha;
			if (String.isNotBlank(comentario)) {
				tarea.Description = String.isNotBlank(tarea.Description) ? tarea.Description  + '\n' + fecha.format() + ' - ' + comentario : fecha.format() + ' - ' + comentario;
			}
			if(String.isNotBlank(contacto)) {
				tarea.WhoId = contacto;
			}
		}
		else if ('CIBE_ExperienciaClienteCIB'.equals(tarea.RecordType.DeveloperName)) {
			tarea.Status=estado;
			tarea.AV_Tipo__c=tipo;
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
		else if ('CIBE_ExperienciaClienteEMP'.equals(tarea.RecordType.DeveloperName)) {
			tarea.Status=estado;
			tarea.AV_Tipo__c=tipo;
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
			tarea.Status=estado;
			tarea.AV_Tipo__c=tipo;
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

		if(dontCreateEvent!=null && !dontCreateEvent){

			if(eventRelatedTypes.contains(tipo)){
				return insertEventRelated(tarea, activityDateTime);
			}
		}
	
        return 'OK';
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
				Contact(Id, Name, CC_CargoRepresentante__c WHERE Id NOT IN :selectedIds AND RecordType.DeveloperName='CC_Representante' and AccountId = :AccountId)
				LIMIT 10];
			}
			else{
			searchResults = [
			FIND :searchTerm
			IN ALL FIELDS
			RETURNING
				Contact(Id, Name, CC_CargoRepresentante__c WHERE RecordType.DeveloperName='CC_Representante' and AccountId = :accountId)
			LIMIT 10];
		}
		String userIcon = 'standard:contact';
		Contact otros =[SELECT Id, Name FROM Contact WHERE CC_Matricula__c = '000000000' LIMIT 1];
		Contact[] listUsers = (List<Contact>) searchResults[0];
		for (Contact u : listUsers) {
			results.add(new AV_LookupSearchResult(u.Id,'Contact',userIcon,u.Name,u.CC_CargoRepresentante__c));
		}
		results.sort();
		results.add(
				new AV_LookupSearchResult(
					otros.Id,
					'Contact',
					userIcon,
					otros.Name,
					''
				)
			);
		return results;
	}

	@AuraEnabled
	public static Task getContactTask(String idRecords){
		Task results = [SELECT id, WhoId, Who.Name, WhatId,AccountId FROM Task WHERE id = :idRecords limit 1];
		return results;
	}

	@AuraEnabled
	public static Boolean acccountCliente(String accountId){
		Boolean result = false;
		Account acc = [SELECT RecordType.DeveloperName FROM Account WHERE Id = :accountId limit 1];
		if (acc.RecordType.DeveloperName == 'CC_Cliente'){
			result = true;
		}
		return result;
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
	public static ExpClienteDataWrapper getExperienciaClienteData(String id) {

		List<AV_ManagementHistory__c> historial = new List<AV_ManagementHistory__c>();
		List<CBK_Activity_Extension__c> actExt = new List<CBK_Activity_Extension__c>();

		Task tarea = [SELECT Id, AV_Tipo__c FROM Task WHERE Id = :id AND 
						(RecordType.DeveloperName =: CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT OR
						RecordType.DeveloperName =: CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT) ];

		historial = [SELECT Id, AV_Comment__c, AV_Date__c, CreatedDate
											FROM AV_ManagementHistory__c WHERE AV_ActivityId__c = :id ORDER BY CreatedDate DESC LIMIT 1];	

		actExt = [SELECT Id, AV_MotivoCierreExperienciaCliente__c, AV_AccionesARealizar__c, AV_ValoracionGestion__c 
												FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c = :id LIMIT 1];

		ExpClienteDataWrapper wrapper= new ExpClienteDataWrapper();
		if (tarea != null && !historial.isEmpty()  && !actExt.isEmpty()) {
			wrapper.fechaGestion = historial[0].AV_Date__c != null ? historial[0].AV_Date__c : null;
			wrapper.tipo = String.isNotEmpty(tarea.AV_Tipo__c) ? tarea.AV_Tipo__c : null;
			wrapper.comment = String.isNotEmpty(historial[0].AV_Comment__c) ? historial[0].AV_Comment__c : null;
			wrapper.motivo = String.isNotEmpty(actExt[0].AV_MotivoCierreExperienciaCliente__c) ? actExt[0].AV_MotivoCierreExperienciaCliente__c : null;
			wrapper.acciones = String.isNotEmpty(actExt[0].AV_AccionesARealizar__c) ? actExt[0].AV_AccionesARealizar__c : null;
			wrapper.valoracion = String.isNotEmpty(actExt[0].AV_ValoracionGestion__c) ? actExt[0].AV_ValoracionGestion__c : null;
		}
		System.debug('@@ wrapper');
		System.debug(wrapper);
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

	/**
	 * Create the event related to the task
	 * @param task Task to get new event information
	 * @param activityDateTime activityDateTime of new event
	 */
	private static String insertEventRelated(Task tarea,Datetime activityDateTime){
		Event eventRelated = new Event();
		eventRelated.Subject = tarea.Subject;
		eventRelated.WhatId = tarea.AccountId;
		eventRelated.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT).Id;
		eventRelated.AV_Tipo__c = tarea.AV_Tipo__c;
		eventRelated.ActivityDate = tarea.ActivityDate;
		eventRelated.CSBD_Evento_Estado__c = CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO;
		eventRelated.StartDateTime = activityDateTime;
		if(eventRelated.AV_Tipo__c  == CIBE_AppConstants.LLAMADA_TIPO ){
			eventRelated.EndDateTime = eventRelated.StartDateTime.addMinutes(5);
			
		}else if(eventRelated.AV_Tipo__c ==  CIBE_AppConstants.CITA_TELEFONICA_TIPO
		|| eventRelated.AV_Tipo__c ==  CIBE_AppConstants.VIDEOLLAMADA_TIPO  ){
			eventRelated.EndDateTime = eventRelated.StartDateTime.addMinutes(15);
		}else if(eventRelated.AV_Tipo__c == CIBE_AppConstants.CITA_OFICINA_TIPO 
				 || eventRelated.AV_Tipo__c == CIBE_AppConstants.VISITA_TIPO){
					eventRelated.EndDateTime = eventRelated.StartDateTime.addMinutes(30);
					eventRelated.AV_BranchPhysicalMeet__c = tarea.AV_Center__c;
					eventRelated.Location = tarea.AV_Center__c;
				 }

        eventRelated.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;

		Database.SaveResult sr = Database.insert(eventRelated,true);
		// return 'NOK';
		if(!sr.isSuccess()) {
			return 'WARNEVENT';
		} 
			
		return reLinkOppToEvent(sr.getId(),tarea.AV_Task__c) ;
		// return activityDateTime;
	}

		/**
	 * Get all the Oppos linked to the reported task and re-link them to the related Event
	 * @param eventRelatedId The Id of the recently inserted Event
	 * @param taskHeader Id of the AV_HeaderCustomActivity__c object stored in AV_Task__C field from reported task
	 */
	private static String reLinkOppToEvent(Id eventRelatedId, String taskHeader){
		Event headerField = [SELECT AV_Task__c FROM Event WHERE Id =: eventRelatedId LIMIT 1];
		List<AV_CustomActivityOpportunity__c> linkedOpps =[SELECT AV_Opportunity__c,AV_IsMain__C FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :taskHeader];
		List<AV_CustomActivityOpportunity__c> relatedOpp = new List<AV_CustomActivityOpportunity__c>();
		for(AV_CustomActivityOpportunity__c oppRelated : linkedOpps){
			
			relatedOpp.add( new AV_CustomActivityOpportunity__c(
				AV_Opportunity__c = oppRelated.AV_Opportunity__c,
				AV_Task__c = headerField.AV_Task__C,
				AV_IsMain__c = oppRelated.AV_IsMain__C
			));
		}

		List<Database.SaveResult> sr = Database.insert(relatedOpp,true);
		for(Database.SaveResult result : sr){
			if(!result.isSuccess()){
				return 'WARNEVENT';
			}
		}
		return 'OK';
	}

	/**
	 * Valida los datos 
	 * @param eventRelatedId The Id of the recently inserted Event
	 * @param taskHeader Id of the AV_HeaderCustomActivity__c object stored in AV_Task__C field from reported task
	 */
	@AuraEnabled
	public static String validateHGM(String id, Date managementDateTask) { 
		String methodName = 'validateHGM';
		AV_HGM_Integration.CustomerData datacliente = new AV_HGM_Integration.CustomerData(); 
		//Añadir CRUD.
		String numper = null;
		String typeSurvey = null;
		Boolean isError = false;
		String respuesta ='OK';
		String avNumper = null;
		String tokenValue = null;
		List<Task> tarea = new List<Task>();
		system.debug('HGM ' + id + ' ' + managementDateTask);
		if (String.isNotBlank(id) && managementDateTask != null) { 
					tarea =	[SELECT Id,CC_Empleado_Gestor__c, AccountId,CreatedDate, AV_SurveyValue__c, AV_Valor5__c, Account.RecordType.Developername, Account.AV_NumPerso__c,
							Account.FirstName, Account.LastName, Account.PersonEmail, Account.PersonMobilePhone, Account.AV_Idioma__c,CC_Empleado_Gestor__r.CIBE_NumPerso__c,
							CC_Empleado_Gestor__r.FirstName, CC_Empleado_Gestor__r.LastName, CC_Empleado_Gestor__r.Email, CC_Empleado_Gestor__r.Phone, CC_Empleado_Gestor__r.CC_Idioma__c
							FROM Task
							WHERE Id=:id AND (AccountId!=null OR CC_Empleado_Gestor__c !=null) AND AV_SurveyValue__c !=null];
				if (tarea.size()>0) {
					datacliente.prefix = null;
					datacliente.phone = null;
					datacliente.language = 'es'; //Default spanish
					datacliente.attributes = new List<String> ();
					typeSurvey = String.valueOf(tarea[0].AV_SurveyValue__c);
					//Adaptacion DE77636
					avNumper = !string.isBlank(tarea[0].Account.AV_NumPerso__c) ? tarea[0].Account.AV_NumPerso__c : '';
					tokenValue =  !string.isBlank(tarea[0].AV_Valor5__c) ? tarea[0].AV_Valor5__c : '';

					// revome content before the characters ': '
					if (!String.isBlank(tokenValue) && tokenValue.contains('Token: ')) {
						tokenValue = tokenValue.remove('Token: ');
						system.debug('tokenValue: '+tokenValue);
					}
					if(tarea[0].Account.RecordType.DeveloperName.equalsIgnoreCase(CIBE_AppConstants.ACCOUNT_CLIENTE_PA_RT)){
						List <Account> cuenta =	[SELECT Id,AV_NumPerso__c,FirstName, LastName, PersonEmail, PersonMobilePhone, AV_Idioma__c, Name FROM Account WHERE Id=:tarea[0].AccountId];
						if(!cuenta.isEmpty()){
							datacliente.firstname = !string.isBlank(cuenta[0].FirstName) ? cuenta[0].FirstName : cuenta[0].Name;
							datacliente.lastname = !string.isBlank(cuenta[0].LastName) ? cuenta[0].LastName : cuenta[0].Name;
							datacliente.email = cuenta[0].PersonEmail;
							numper = cuenta[0].AV_NumPerso__c;
						}

						// Idioma
						if (String.isNotBlank(cuenta[0].AV_Idioma__c) && '001'.equalsIgnoreCase(cuenta[0].AV_Idioma__c)){
							datacliente.language = 'ca';	//catalan
						} 
						else if (String.isNotBlank(cuenta[0].AV_Idioma__c) && '010'.equalsIgnoreCase(cuenta[0].AV_Idioma__c)){
							datacliente.language = 'en';	//english
						}
					}else if(tarea[0].Account.RecordType.DeveloperName.equalsIgnoreCase(CIBE_AppConstants.ACCOUNT_CLIENTE_RT)){ 
						List <Contact> contac =	[SELECT Id,CC_NumPerso__c, CIBE_NumPerso__c,FirstName, LastName, Email, Phone, CC_Idioma__c, Account.AV_NumPerso__c	FROM Contact WHERE Id=:tarea[0].CC_Empleado_Gestor__c];
						if(!contac.isEmpty()){
							datacliente.firstname = contac[0].FirstName;
							datacliente.lastname = contac[0].LastName;
							datacliente.email = contac[0].Email;
							numper = !string.isBlank(contac[0].CIBE_NumPerso__c) ? contac[0].CIBE_NumPerso__c : contac[0].CC_NumPerso__c;
                            // Idioma
                            if (String.isNotBlank(contac[0].CC_Idioma__c) && '001'.equalsIgnoreCase(contac[0].CC_Idioma__c)){
                                datacliente.language = 'ca';	//catalan
                            } 
                            else if (String.isNotBlank(contac[0].CC_Idioma__c) && '010'.equalsIgnoreCase(contac[0].CC_Idioma__c)){
                                datacliente.language = 'en';	//english
                            }
                        }
					}
					if(tarea[0].CreatedDate != null){
						datacliente.attributes.add(String.valueOf(tarea[0].CreatedDate));
					}else{
						isError = true;
					}
					//Adaptacion DE77636
					if(tarea[0].Account.RecordType.DeveloperName.equalsIgnoreCase(CIBE_AppConstants.ACCOUNT_CLIENTE_RT)){
						datacliente.attributes.add(avNumper);
					}else if(managementDateTask != null){
						datacliente.attributes.add(String.valueOf(managementDateTask));
					}
					if(datacliente.firstname == null || datacliente.lastname == null || numper == null){
						isError = true;
					}
					if(isError){
						respuesta = LABEL.CIBE_CMP_isErrorHGM;
					}
					datacliente.attributes.add(null);
					datacliente.attributes.add(tokenValue);
					if(datacliente?.firstname !=null && !isError && typeSurvey!=null){
						AV_TabManagementTask_Controller.getResponseHGM_fw(tarea[0].Id,JSON.serialize(datacliente),numper,typeSurvey);
					}
				}else{
					respuesta = LABEL.CIBE_CMP_ErrorSurveyHGM;
				}
		}else{
			respuesta = LABEL.CIBE_CMP_ErrorValidateHGM;
		}
		return respuesta;
	}

	/**
	 * Recupera el valor de AV_NoGestionable para mostrar o no el contenido del componente cibe_TaskTabs
	 * @param Task Id
	 */
	@AuraEnabled(cacheable=true)
	public static Boolean getNoGestionable(String recordId) { 
		List<Task> listaTareas = new List<Task>();
		Boolean isNoGestionable;
		listaTareas = [SELECT Id, AV_NoGestionable__c FROM Task WHERE Id = :recordId];
		for(Task task : listaTareas){
			isNoGestionable = task.AV_NoGestionable__c;
		}		
		return isNoGestionable;
	}
}