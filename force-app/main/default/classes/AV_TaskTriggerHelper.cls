/**********************************************************************************************************************
Name:	  AV_TaskTriggerHelper
Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Task.
------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	        AUTHOR		   		DATE				Description
1.0			US124210		    Jashanpreet	   	    08/10/2020		    Init version
2.0			US104665			Esperanza Conde		21/10/2020			Logic completeValueDateReal
3.0			US117509			Eric Vázquez		30/10/2020			Add method validate to delete Task
4.0         US129093            Jashanpreet         11/11/2020          oppo reminder
4.1			US117509			Eric Vázquez		26/11/2020			fix method validate to delete Task
4.2			US117509			Eric Vázquez		03/12/2020			fix message when delete task
4.3			FIX					Jashanpreet			04/12/2020			added recordType control to validateForbiddenWords Method
5.0			App FSC				Jashanpreet			07/12/2020			Delete soql queries to get RecordTypeIds
5.1			App FSC				David Rufo			09/12/2020			Include a general check of the Record Types: "checkGeneralRT"
5.2			App FSC				Carolina Alonso		14/12/2020			Modify validateDeleteTask change header-task search from Id by AV_ExternalID__c
5.3			App FSC				Jashanpreet 		14/12/2020			Changed error message to field
5.4			US147562			Sandra Gómez		14/01/2020			Added new method createCRMTask
5.5			FIX-IOP Marzo		Carolina Alonso		09/03/2021			Comment method oppoReminder. Conflicts with the new reporting
5.6			DE46491/DE46686		Sandra Gómez		02/06/2021			Change method processOwnerGestores
5.7			US237376			Víctor Santiago		28/06/2021			Added timestamp to generate a more robust ExternalID.
5.8			FIX					David Rufo			30/06/2021			FIX issue with the delete validation data
5.9			FIX Owners			Sandra Gómez		24/08/2021			Fix process Owners Gestor 
6.0			DE52465			    Sandra Gómez		30/09/2021			insertOrUpdateCodigoGestorAsignado and refactor EAP/Gestor
6.1			DE53797			    Daniel Rodríguez	09/11/2021			Fix validateDeleteTask validate Record Types that can be removed
6.2			US286825 			Daniel Rodríguez	13/01/2022			Add Method updateNextManagementDateOpp for unification of expiration dates of opportunities with date of event or task
6.3			US293288 			Víctor Santiago		10/02/2022			Add Method createManagementHistory
6.4		    AV_Query IT	        Daniel Rodríguez	07/02/2022	        Change AV_Query to SOQL for User and Account
6.5			US339508			Luis Fernández		29/03/2022			Add Method UpdateCentro to link the Task with Owner Office.
6.6 		US310702			Luis Fernández		14/04/2022			Added method changeOwner
Modify UserGFC in processOwmerGestoresEAP method
6.7			US353735			Sandra Gómez		20/04/2022			Added method deleteUpdateTasksGCF
6.8			US332485			Luis Fernández 		28/04/2022			Modify updateCentro method
6.9								Jose María Perez	09/05/2022			Add Scoring Task
7.0			US385253			Víctor Santiago 	17/06/2022			Added updateTareaOpp and fixed QC warnings
7.1			Fix			        Patricia Solano     08/08/2022		    Removed scoreTaskAftDelete, scoreTaskAftUpdate, scoreTaskAftInsert and calculateScoreTask Methods
7.2			USXXXXX				Luis Fernández 		11/08/2022			Addes "InsertOrUpdateCenterAndRt" method
7.3			DE63589				Sandra Gómez		01/09/2022			Add new method updateGCF
7.4			US457715			Eduardo González 	19/10/2022			Add Method updateSinGestor
7.5			DE70201				Sandra Gómez		03/01/2023			Change updateGCF LastmodifiedbyId
7.6			Fix Queueable		Sandra Gómez		04/01/2023			Change method deleteRecordsRelatedWithTask call queueable
7.7         US500108            Elisabeth R.        09/01/2023          Changed updateGCF method
7.8 		US481618			Ángel Medina		09/01/2023			Add new method recordChannel
7.9			US464358			Luis Fernández		13/02/2023			Add new method notifyExperienciaClienteTask and ExecuteNotification
8.0			US610044			Luis Fernández		19/06/2023			Added new method checkOfficeTaskUpdate to do not let update tasks with "Task Office" value in AV_Tipo__C field unless it is a report update
8.1			US546892			Sandra Gómez		12/09/2023			Add method checkReportClient and change method updateNextManagementDateOpp to no call with origen report client
8.2			Fix					Sandra Gómez		13/11/2023			Change method updateNextManagementDateOpp and checkReportClient to bypass and checkOfficeTaskUpdate to change label and add origen report client
8.3			US756725			Luis Fernández		17/11/2023			Added  new method validationTaskRules to bypass some of the Task Validation Rules
8.4			DE86213				Sandra Gómez		24/11/2023			Change method recordChannel duplicity list
8.5			DE76223				Humberto Vilchez	22/12/2023			Change method updateNextManagementDateOpp to fix UNABLE_TO_LOCK_ROW error
8.6			US599658			Humberto Vilchez	26/12/2023			Change method updateTareaOpp to fix UNABLE_TO_LOCK_ROW error
8.7			Fix error			Daniel Rodriguez    15/01/2024			Fix method validationRulesTask to fix Attempt to de-reference a null object
8.8                             Oscar Moreno        16/01/2024          Comment updateTareaOpp and recordChannel methods
8.9                             Oscar Moreno        13/02/2024          Modify  validationRulesTask method to control nulls
9.0			US839375			Ángel Medina		18/04/2024			Modify method updateNextManagementDateOpp  to update stagename opportunity
9.1								Ángel Medina		04/07/2024			Modify method validationRulesTask method to control Attempt to de-reference a null object
9.2			PPM100265161   		Sandra Gómez		11/10/2024		 	Change method updateGCF and checkReportClient to add filter DATAPIPELINES_ORIGENAPP
9.3			PPM100265161		Ángel Medina		18/10/2024			Delete methods updateTareaOpp,validateRecordChannel and validateForbiddenWords
***********************************************************************************************************************/
public with sharing class AV_TaskTriggerHelper {
	
	private static final String SUFFIX_EXTERNALID 	= 'Task-';
	private static final String ERROR_MESSAGE		= Label.AV_deleteToTask;
	private static final String ERROR_MESSAGE_USER	= Label.AV_deleteToTaskUser;    
	
	/**
	* @description		 	Check the record types
	* @param listNews  	list of new records
	*/
	public static List<Task> checkGeneralRT(List<Task> listNews){
		Set<Id> setIdsRt = getAllRT();
		
		List<Task> listData = new List<Task>();
		for(Task tNew : listNews){
			if((setIdsRt).contains(tNew.RecordTypeId)){
				listData.add(tNew);
			}
		}
		return listData;
	}
	
	/**
	* @description		 	Get all the ID's of the RT
	*/
	public static Set<Id> getAllRT(){
		Schema.DescribeSObjectResult objDescribe = Task.SObjectType.getDescribe();
		List<Schema.RecordTypeInfo> recordTypeObj = objDescribe.getRecordTypeInfos();
		Set<Id> setIdsRt = New Set<Id>();
		
		for (Schema.RecordTypeInfo rt: recordTypeObj){
			if (rt.getDeveloperName().left(3)=='AV_') {
				setIdsRt.add(rt.getRecordTypeId());
			}
		}
		return setIdsRt;
	}
	
	/**
	* @description		 	Get the ID's of the RT's requested by param
	* @param setRT			List of the RT
	*/
	public static Set<Id> getIdsRT(Set<String> setRT){
		return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
	}
	
	/**
	 * @description		 Procces owners of Tasks where field codigoGestor has changed
	 * @param  listNews  list of new Task records
	 * @param mapOlds map of old Task records
	 */
	public static void processOwnerGestores(List<Task> listNews, Map<Id, Task> mapOlds){
		Set<Id> setIdsRt = getAllRT();
		List<Task> lstTasks = new List<Task>();
		List<Task> lstTasksSinEap = new List<Task>();
		Set<String> codigosGestores = new Set<String>();
		Map<String,String> mapExternalIdUser = new Map<String,String>();
		List<String> listExternalId = new List<String>();
		User userGcf;
		
		//New tasks
		if(mapOlds == null ||  mapOlds.isEmpty()){
			for(Task tNew : listNews){
				if((setIdsRt).contains(tNew.RecordTypeId) && String.isNotBlank(tNew.AV_CodigoGestorAsignado__c)){
					lstTasks.add(tNew);
					codigosGestores.add(tNew.AV_CodigoGestorAsignado__c);
				} 
			}
		}
		//Old tasks
		else{
			for(Task tNew : listNews){
				if((setIdsRt).contains(tNew.RecordTypeId) && String.isNotBlank(tNew.AV_CodigoGestorAsignado__c)
						&& tNew.AV_CodigoGestorAsignado__c != mapOlds.get(tNew.Id).AV_CodigoGestorAsignado__c){
					lstTasks.add(tNew);
					codigosGestores.add(tNew.AV_CodigoGestorAsignado__c);
				} 
				else if((setIdsRt).contains(tNew.RecordTypeId) && String.isBlank(tNew.AV_CodigoGestorAsignado__c)
						&& tNew.AV_CodigoGestorAsignado__c != mapOlds.get(tNew.Id).AV_CodigoGestorAsignado__c){
					lstTasksSinEap.add(tNew);
				}
			}
		}
			
		if(lstTasksSinEap!=null && !lstTasksSinEap.isEmpty()) {
			userGcf = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		
			if (userGcf!=null){
				for(Task a : lstTasksSinEap){
					a.OwnerId = userGcf.Id;
				}
			}
		}
		
		//Update owner task for employees
		if(codigosGestores!=null && !codigosGestores.isEmpty()) {
			Map<String, Id> mapGestoresUsers = new Map<String, Id>();
			List<User> listGestoresUsers = [Select Id, AV_ExternalID__c From User Where AV_ExternalID__c in :codigosGestores and IsActive = true];
			userGcf = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		
			if(listGestoresUsers != null && !listGestoresUsers.isEmpty()){
				for(User u : listGestoresUsers){
					if(String.isNotBlank(u.AV_ExternalID__c)){
						mapGestoresUsers.put(u.AV_ExternalID__c, u.Id);
					}
				}
			}
			for(Task a : lstTasks){
				if(mapGestoresUsers.get(a.AV_CodigoGestorAsignado__c) != null) {
					a.OwnerId = mapGestoresUsers.get(a.AV_CodigoGestorAsignado__c);
				}else{
					a.OwnerId = userGcf.Id;
				}
			}
		}
	}
	
	/**
	 * @description		 Process the change of a Task Owner if Owner has no contact
	 * @param  listNews  list of new Task records
	 * @param mapOlds map of old Task records
	 */
	public static void changeOwner(List<Task> listNews, Map<Id, Task> mapOlds) {
		Set<Id> tskOwners = new Set<Id>();
		List<Task> tskToProcess = new List<Task>();
		User userGcf = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9' limit 1];//Invocamos al usuario para owners sin EAP
		if(mapOlds != null && !mapOlds.isEmpty()){//Existent task
			for(Task tsk: listNews){
				if(tsk.OwnerId != mapOlds.get(tsk.Id).OwnerId){
					tskToProcess.add(tsk);
					tskOwners.add(tsk.OwnerId);
				}
			}
		}else{//New task
			for (Task tsk : listNews) {
				tskToProcess.add(tsk);
				tskOwners.add(tsk.OwnerId);
			}
		}
		List<User> ownerWithNoEap = [SELECT ID FROM USER 
									WHERE id NOT IN (
											SELECT AV_UsuarioAsociado__c 
											FROM contact 
											WHERE AV_UsuarioAsociado__c in :tskOwners)
									AND id IN :tskOwners];//Retrieve users who are not in contact table 
		  Set<Id> idOwnerWithNoEap = new Set<Id>();
		  if(ownerWithNoEap!= null && !ownerWithNoEap.isEmpty()){
			  for(User u : ownerWithNoEap){
				  idOwnerWithNoEap.add(u.id);
				}
			}
		  for(Task tsk : tskToProcess){			  
			if(idOwnerWithNoEap.contains(tsk.OwnerId)){
				tsk.OwnerId= userGcf.Id;
			}
		}	
	}

	/**
	* @description		 Create minimum data of the header custom activity
	* @param  listNews  list of new Task records
	*/
	public static void headerCustomActivity(List<Task> listNews){
		Set<Id> setIdsRt = getAllRT();
		List<AV_HeaderCustomActivity__c> listHeaderTask = new List<AV_HeaderCustomActivity__c>();
		
		
		//Create minimum data of the header custom activity
		for(Task auxTask : listNews){
			if((setIdsRt).contains(auxTask.RecordTypeId)){
				if(String.isBlank(auxTask.AV_ExternalID__c)){
					
					String externalId = SUFFIX_EXTERNALID + '$OPP$#' + (Math.round(Math.random()*1000000) + Datetime.now().getTime());
					
					if(String.isNotBlank(auxTask.AV_AssociatedOpportunityId__c )){
						externalId = externalId.replace('$OPP$', auxTask.AV_AssociatedOpportunityId__c);
					} else {
						externalId = externalId.replace('$OPP$', '');
					}
					auxTask.AV_ExternalID__c = externalId;
				}
				AV_HeaderCustomActivity__c headerCustomAct = new AV_HeaderCustomActivity__c();
				if(String.isNotBlank(auxTask.Subject) && auxTask.Subject.length()<80){
					headerCustomAct.Name = auxTask.Subject;
				} else {
					headerCustomAct.Name = auxTask.AV_ExternalID__c;
				}
				headerCustomAct.AV_ExternalID__c = auxTask.AV_ExternalID__c;
				listHeaderTask.add(headerCustomAct);
			}
		}
		
		//Insert data && update the field "AV_Task__c"
		if (listHeaderTask!=null && !listHeaderTask.isEmpty()){
			try{
				AV_LogDebug.printLogDebug('process', 'insert listHeaderTask: ' + listHeaderTask.size());
				List<Database.SaveResult> srs = Database.insert(listHeaderTask, false);
				for(Database.SaveResult sr : srs){
					if(!sr.isSuccess()) {
						for(Database.Error err : sr.getErrors()) {
							AV_LogDebug.printLogDebug('headerCustomActivity', 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
						}
					}
				}
			}catch(Exception e){
				AV_LogDebug.printException('process 1', e);
			}
			try{
				//Map where the key is the external ID
				Map<String, AV_HeaderCustomActivity__c> mapHeaderTask = new Map<String, AV_HeaderCustomActivity__c>();
				for(AV_HeaderCustomActivity__c auxHeaderTask : listHeaderTask){
					mapHeaderTask.put(auxHeaderTask.AV_ExternalID__c, auxHeaderTask);
				}
				//Update field "AV_Task__c"
				for(Task auxTask : listNews){
					AV_HeaderCustomActivity__c auxHeaderTask = mapHeaderTask.get(auxTask.AV_ExternalID__c);
					if (auxHeaderTask!=null){
						auxTask.AV_Task__c = auxHeaderTask.Id;
					}
				}
			}catch(Exception e){
				AV_LogDebug.printException('process 2', e);
			}
		}
	}
	
	/**
	* @description		 Onboarding task when is "positive closed" connect with the API': carterizacion y cita previa
	* @param  listNews  list of new Task records
	* @param  mapOlds	 data old status of the task's
	*/
	public static void validateTaskOnboardingPositiveClosed(List<Task> listNews, Map<Id, Task> mapOlds){
		
		String methodName = 'validateTaskOnboardingPositiveClosed';
		Set<String> setLabelsRts = new Set<String>{'AV_Onboarding'};
			Set<Id> setIdsRt = getIdsRT(setLabelsRts);
		List<Task> taskToProcess = new List<Task>();
		
		User userLog = AV_AppUtilities.getUserInfo();
		Boolean isApiOnly = 'API Only'.equalsIgnoreCase(userLog.AV_ProfileName__c);
		
		if(!isApiOnly){
			if(mapOlds == null ||  mapOlds.isEmpty()) {
				for(Task tarea : listNews){
					if((setIdsRt).contains(tarea.RecordTypeId)  && tarea.Status == AV_AppConstants.GESTIONADO_POSITIVO_ESTADO){
						taskToProcess.add(tarea);
					}
				}	
			}else{
				for(Task tarea : listNews){
					if((setIdsRt).contains(tarea.RecordTypeId)  && tarea.Status == AV_AppConstants.GESTIONADO_POSITIVO_ESTADO 
					   && mapOlds.get(tarea.Id).Status != AV_AppConstants.GESTIONADO_POSITIVO_ESTADO){
						   taskToProcess.add(tarea);
					   }
				}
			}
			if(taskToProcess.size() > 0){
				String jsonString = json.serialize(taskToProcess);
				AV_ReasignarCartera.assignBook(jsonString);
			}
		}else{
			AV_LogDebug.printLogDebug(methodName, ' No se llama a la api, tarea actualizada por GCF');
		}
	}
	
	/**
	* @description		 
	* @param  listOlds  list of old Opportunity records
	*/
	public static void validateDeleteTask(List<Task> listOlds){
		if(listOlds!=null && !listOlds.isEmpty()){
			Set<String> setLabelsRts = new Set<String>{'AV_Otros'};
				Set<Id> setIdsRts = getIdsRT(setLabelsRts);
			Set<String> setIdsTask = new Set<String>();
			Set<Id> setIdsHeaderTask = new Set<Id>();
			User currentUser  = [Select Name, AV_ProfileName__c From User Where Id = :UserInfo.getUserId()];
			
			String profileCu = currentUser.AV_ProfileName__c;
			
			for(Task tskId : listOlds){
				//Validate Record Types that can be removed
				if(!setIdsRts.contains(tskId.RecordTypeId) && profileCu == 'AV_Usuario_CaixaBank'){
					tskId.addError(ERROR_MESSAGE_USER);
				}
				if (String.isNotBlank(tskId.AV_ExternalID__c)){
					setIdsTask.add(tskId.AV_ExternalID__c);
				}
			}
			List<AV_HeaderCustomActivity__c> listHeaderTask = [SELECT Id, AV_ExternalID__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c IN :setIdsTask];
		
			if(!listHeaderTask.isEmpty()){
				for(AV_HeaderCustomActivity__c htask : listHeaderTask){
					setIdsHeaderTask.add(htask.Id);
				}
			}
			List<AV_CustomActivityOpportunity__c> listTaskAndOpp = [SELECT Id, AV_Task__r.AV_ExternalID__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :setIdsHeaderTask];
		
			Set<String> extTaskOpp = new Set<String>();
			for(AV_CustomActivityOpportunity__c aux : listTaskAndOpp){
				if (String.isNotBlank(aux.AV_Task__r.AV_ExternalID__c)){
					extTaskOpp.add(aux.AV_Task__r.AV_ExternalID__c);
				}
			}
			
			for(Task tsk : listOlds){
				if((setIdsRts).contains(tsk.RecordTypeId) && !extTaskOpp.isEmpty()){
					String externalId = tsk.AV_ExternalID__c;
					if (String.isNotBlank(externalId) && extTaskOpp.contains(externalId)){
						tsk.addError(ERROR_MESSAGE);
					}
				}
			}
		}
	}
	
	/**
	* @description		 Create a CRM Tarea if task has Description
	* @param  listNews  list of new Task records
	* @param  mapOlds 	map of old Task records
	*/
	public static void createCRMTask(List<Task> listNews, Map<Id, Task> mapOlds) {
		List<Task> lstToProcess = new List<Task>();
		Set<String> setTaskIds = new Set<String>();
		
		if(mapOlds == null) {
			for(Task ta : listNews) {
				if(String.isNotBlank(ta.Description)) {
					lstToProcess.add(ta);
					setTaskIds.add(ta.Id);
				}
			}
		} else {
			for(Task ta : listNews) {
				if(String.isNotBlank(ta.Description) && ta.Description != mapOlds.get(ta.Id).Description) {
					lstToProcess.add(ta);
					setTaskIds.add(ta.Id);
				}
			}
		}
		
		if(!lstToProcess.isEmpty()) {
			List<CBK_Activity_Extension__c> lstCRMTasksToUpdate = new List<CBK_Activity_Extension__c>();
			List<CBK_Activity_Extension__c> lstCRMTasksToInsert = new List<CBK_Activity_Extension__c>();
			User currentUser  = [Select Name, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId()];
			
			String employeeInfo = currentUser.Name;
			if(String.isNotBlank(currentUser.AV_NumeroOficinaEmpresa__c) && currentUser.AV_NumeroOficinaEmpresa__c.contains('-')) {
				employeeInfo += ' (ofi ' + currentUser.AV_NumeroOficinaEmpresa__c.split('-').get(1) + ')';
			}
			
			if(mapOlds == null) {
				for(Task auxTa : lstToProcess) {
					CBK_Activity_Extension__c crmTask = new CBK_Activity_Extension__c(AV_ActivityId__c = auxTa.Id, AV_ExternalID__c = auxTa.AV_ExternalID__c, AV_CommentLastModifiedBy__c = employeeInfo, AV_CommentLastModifiedDate__c = System.now(), OwnerId = auxTa.OwnerId);
					lstCRMTasksToInsert.add(crmTask);
				}
			} else {
				List<CBK_Activity_Extension__c> lstCRMTasks = [SELECT Id, AV_ActivityId__c, AV_ExternalID__c, AV_CommentLastModifiedBy__c, AV_CommentLastModifiedDate__c FROM CBK_Activity_Extension__c 
				WHERE AV_ActivityId__c IN :setTaskIds];
				
				Map<String, CBK_Activity_Extension__c> mapCRMTask = new Map<String, CBK_Activity_Extension__c>();
				for(CBK_Activity_Extension__c auxCRMTask : lstCRMTasks) {
					mapCRMTask.put(auxCRMTask.AV_ActivityId__c, auxCRMTask);
				}
				for(Task auxTa : lstToProcess) {
					CBK_Activity_Extension__c crmTask;
					if(!mapCRMTask.containsKey(auxTa.Id)) {
						crmTask = new CBK_Activity_Extension__c(AV_ActivityId__c = auxTa.Id, AV_ExternalID__c = auxTa.AV_ExternalID__c ,AV_CommentLastModifiedBy__c = employeeInfo, AV_CommentLastModifiedDate__c = System.now());
						lstCRMTasksToInsert.add(crmTask);
					} else {
						crmTask = new CBK_Activity_Extension__c(Id = mapCRMTask.get(auxTa.Id).Id, AV_ExternalID__c = auxTa.AV_ExternalID__c, AV_CommentLastModifiedBy__c = employeeInfo, AV_CommentLastModifiedDate__c = System.now());
						lstCRMTasksToUpdate.add(crmTask);
					}
				}
			}
			if(!lstCRMTasksToInsert.isEmpty()) {
				Database.insert(lstCRMTasksToInsert, false);
			}
			if(!lstCRMTasksToUpdate.isEmpty()) {
				Database.update(lstCRMTasksToUpdate, false);
			}
		}
	}
	
	/**
	* @description		 Insert or Update AV_CodigoGestorAsignado__c in Tasks
	* @param  listNews  list of new Task records
	* @param  mapOlds 	map of old Task records
	*/
	public static void insertOrUpdateCodigoGestorAsignado(List<Task> listNews, Map<Id, Task> mapOlds){
		Set<Id> setIdsRt = getAllRT();
		List<Task> lstTasks = new List<Task>();
		List<String> listIdOwner= new List<String>();
		Map<String,String> mapUserMatri= new Map<String,String>();
		
		if(mapOlds == null ||  mapOlds.isEmpty()) {
			for(Task tNew : listNews){
				if((setIdsRt).contains(tNew.RecordTypeId) && String.isBlank(tNew.AV_CodigoGestorAsignado__c) 
				   && String.isNotBlank(tNew.OwnerId)){
					   lstTasks.add(tNew);
					   listIdOwner.add(tNew.OwnerId);
				   } 
			}
		} else {
			for(Task tNew : listNews){
				if((setIdsRt).contains(tNew.RecordTypeId) && tNew.OwnerId != mapOlds.get(tNew.Id).OwnerId){
					lstTasks.add(tNew);
					listIdOwner.add(tNew.OwnerId);
				} 
			}
		}
		
		if (lstTasks != null) {
			List<Contact> listEmployees= [Select Id, CC_Matricula__c, AV_UsuarioAsociado__c From Contact Where AV_UsuarioAsociado__c in :listIdOwner];
			
			if(listEmployees != null && !listEmployees.isEmpty()){
				for(Contact c : listEmployees){
					mapUserMatri.put(c.AV_UsuarioAsociado__c, c.CC_Matricula__c);
				}
			}
			for(Task a : lstTasks){
				if(mapUserMatri.get(a.OwnerId) != null) {
					a.AV_CodigoGestorAsignado__c = mapUserMatri.get(a.OwnerId);
				}
			}
		}
	}
	
	/**
	* @description		 Update updateNextManagementDateOpp of opportunity
	* @param  listNews  list of new Task records
	* @param  mapOlds   map of old records
	*/
	public static void updateNextManagementDateOpp(List<Task> listNews, Map<Id, Task> mapOlds, Map<String, Task> mapToByPassTask){
		String methodName = 'updateNextManagementDateOpp';
		Set<String> setLabelsRtsTask = new Set<String>{'AV_Otros'};
		Set<String> setLabelsRtsEvent = new Set<String>{'AV_EventosConCliente'};
		Set<Id> setIdsRtsTask = getIdsRT(setLabelsRtsTask);
		Set<Id> setIdsRtsEvent = getIdsRT(setLabelsRtsEvent);
		List<Task> lstTasks = new List<Task>();
		Set<Id> setIdsHeaderTask = new Set<Id>();
		Set<String> setIdsTask = new Set<String>();
		List<String> listOppOrigen = new List<String>();
		Set<Id> setOpp = new Set<Id>();
		Set<Id> setTaskEventExId = new Set<Id>();
		Map<Id,List<String>> mapOppTask = new Map<Id,List<String>>();
		List<Opportunity> listOppUpdate = new List<Opportunity>();
		Map<id,Opportunity> mapOppUpdate = new Map<id,Opportunity>();
		Map<String,List<String>> mapTaskOpp = new Map<String,List<String>>();
		List<String> ids= new List<String>();
		Date dateOppNew = null;
		if(mapOlds != null && !mapOlds.isEmpty() ) {
			for(Task tNew : listNews){
				Task taskOld = mapOlds.get(tNew.id);	
				if(((setIdsRtsTask).contains(tNew.RecordTypeId) && (taskOld.ActivityDate != tNew.ActivityDate) && tNew.AV_ExternalID__c != null && (tNew.Status == AV_AppConstants.TASK_STATUS_PENDIENTE || tNew.Status == AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL)) && tNew.AV_OrigenApp__c != AV_AppConstants.CLIENT_REPORT_ORIGENAPP){
					setIdsTask.add(tNew.AV_ExternalID__c);
				} 
			}

			if(!setIdsTask.isEmpty()){
				List<AV_HeaderCustomActivity__c> listHeaderTask = [Select Id, AV_ExternalID__c from AV_HeaderCustomActivity__c where AV_ExternalID__c in :setIdsTask];
				if(!listHeaderTask.isEmpty()){
					for(AV_HeaderCustomActivity__c htask : listHeaderTask){
						setIdsHeaderTask.add(htask.Id);
					}
				}
				List<AV_CustomActivityOpportunity__c> listTaskAndOpp = [Select Id, AV_Task__r.AV_ExternalID__c, AV_Opportunity__c from AV_CustomActivityOpportunity__c where AV_Opportunity__c != null and AV_Task__c in :setIdsHeaderTask];
				if(!listTaskAndOpp.isEmpty()){ 
					for(AV_CustomActivityOpportunity__c taskOpp : listTaskAndOpp){
						setOpp.add(taskOpp.AV_Opportunity__c);
					}
				}

				if(!setOpp.isEmpty()){
					List<AV_CustomActivityOpportunity__c> listTaskAndOppRelated = [Select Id, AV_Task__r.AV_ExternalID__c, AV_Opportunity__c from AV_CustomActivityOpportunity__c where AV_Opportunity__c in :setOpp];
					if(!listTaskAndOppRelated.isEmpty()){  
						for(AV_CustomActivityOpportunity__c taskOppRelated : listTaskAndOppRelated){
							if(mapOppTask.containsKey(taskOppRelated.AV_Opportunity__c)) {
								mapOppTask.get(taskOppRelated.AV_Opportunity__c).add(taskOppRelated.AV_Task__r.AV_ExternalID__c);
							} else {
								mapOppTask.put(taskOppRelated.AV_Opportunity__c, new List<String> { taskOppRelated.AV_Task__r.AV_ExternalID__c });
							}
							if(mapTaskOpp.containsKey(taskOppRelated.AV_Task__r.AV_ExternalID__c)) {
								mapTaskOpp.get(taskOppRelated.AV_Task__r.AV_ExternalID__c).add(taskOppRelated.AV_Opportunity__c);
							} else {
								mapTaskOpp.put(taskOppRelated.AV_Task__r.AV_ExternalID__c, new List<String> {taskOppRelated.AV_Opportunity__c});
							}
							ids.add(taskOppRelated.AV_Task__r.AV_ExternalID__c);
							if (mapToByPassTask.containsKey(taskOppRelated.AV_Task__r.AV_ExternalID__c)) {
								listOppOrigen.add(taskOppRelated.AV_Opportunity__c);
							}
						}
					}
				}       
				
				if(!mapOppTask.isEmpty()){ 
					Set<String> statusTask = new Set<String>{AV_AppConstants.TASK_STATUS_PENDIENTE, AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL};
						Set<String> statusEvent = new Set<String>{AV_AppConstants.EVENT_STATUS_PENDIENTE};
							Map<String,Date> mapOppFecha = new Map<String,Date>();
					List<Task> listTaskAndOppRelated = [Select Id, AV_ExternalID__c, ActivityDate from Task where Status in :statusTask and RecordtypeId in :setIdsRtsTask and AV_ExternalID__c in :ids and ActivityDate >= TODAY order by ActivityDate ASC];
					AV_LogDebug.printLogDebug(methodName, 'listTaskAndOppRelated: '+listTaskAndOppRelated.size());
					for(Task ta:listTaskAndOppRelated) {
						if (mapTaskOpp.get(ta.AV_ExternalID__c)!=null) {
							for(String oppId:mapTaskOpp.get(ta.AV_ExternalID__c)) {
								if (mapOppFecha.get(oppId) == null){
									mapOppFecha.put(oppId,ta.ActivityDate);
								}else if (mapOppFecha.get(oppId) > ta.ActivityDate) {
									mapOppFecha.put(oppId,ta.ActivityDate);
								}
							}
						}
					}
					List<Event> listEventAndOppRelated = [Select Id, AV_ExternalID__c, ActivityDate from Event where CSBD_Evento_Estado__c in :statusEvent and RecordtypeId in :setIdsRtsEvent and AV_ExternalID__c in :ids and ActivityDate >= TODAY order by ActivityDate ASC limit 1];
					AV_LogDebug.printLogDebug(methodName, 'listEventAndOppRelated: '+listEventAndOppRelated.size());
					for(Event e:listEventAndOppRelated) {
						if (mapTaskOpp.get(e.AV_ExternalID__c)!=null) {
							for(String oppId:mapTaskOpp.get(e.AV_ExternalID__c)) {
								if (mapOppFecha.get(oppId) == null) {
									mapOppFecha.put(oppId,e.ActivityDate);
								}else if (mapOppFecha.get(oppId) > e.ActivityDate) {
									mapOppFecha.put(oppId,e.ActivityDate);
								}
							}
						}
					}

					if(mapOppFecha != null) {
    					Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, StageName, AV_FechaProximoRecordatorio__c FROM Opportunity WHERE Id IN :mapOppTask.keySet()]);

						for (Id idOpp : mapOppTask.keySet()){
							if (mapOppFecha.get(idOpp) != null) {
								Opportunity oppUpdate;
								Opportunity currentOpp = oppMap.get(idOpp);

								if(listOppOrigen.contains(idOpp)) {
									oppUpdate = new Opportunity(Id= idOpp, AV_FechaProximoRecordatorio__c = mapOppFecha.get(idOpp), AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP);
								} else {
									oppUpdate = new Opportunity(Id= idOpp, AV_FechaProximoRecordatorio__c = mapOppFecha.get(idOpp));
								}
								if(currentOpp != null){
									if(currentOpp.AV_FechaProximoRecordatorio__c != mapOppFecha.get(idOpp) && currentOpp.StageName == AV_AppConstants.OPP_STATUS_VENCIDO){
										oppUpdate.StageName = AV_AppConstants.OPP_STATUS_ENGESTION;
									}
								}
								listOppUpdate.add(oppUpdate);
								mapOppUpdate.put(oppUpdate.Id, oppUpdate);
							}	
						}
					}
				}

				if(!listOppUpdate.isEmpty()){

					List<Database.SaveResult> listUpdateResult = Database.update(listOppUpdate, false);					

					for (Database.SaveResult sr : listUpdateResult) {
						if (sr.isSuccess()) {
							if(mapOppUpdate.get(sr.getId()) != null){
								mapOppUpdate.remove(sr.getId());
							}
						}
					}

					if (!mapOppUpdate.isEmpty() ) {
						List<Database.SaveResult> listUpdateErrorResult = Database.update(mapOppUpdate.values(), false);
					}

				}
			}
		}
	}
	
	/**
	* @description		 Create a management history for all tasks
	* @param  listNews  list of new Task records
	* @param  mapOlds 	map of old Task records
	*/
	public static void createManagementHistory(List<Task> listNews, Map<Id, Task> mapOlds) {
		List<Task> lstToProcess = new List<Task>();
		
		for(Task ta : listNews) {
			lstToProcess.add(ta);
		}
		
		if(!lstToProcess.isEmpty()) {
			List<AV_ManagementHistory__c> histList = new List<AV_ManagementHistory__c>();
			for(Task auxTa : lstToProcess) {
				AV_ManagementHistory__c mh = new AV_ManagementHistory__c(
					AV_ActivityId__c = auxTa.Id,
					AV_Status__c = auxTa.Status,
					AV_Type__c = auxTa.AV_Tipo__c,
					AV_Comment__c = auxTa.Description,
					AV_ExternalID__c = auxTa.AV_ExternalID__c,
					AV_Date__c = Date.today(),
					OwnerId = auxTa.OwnerId
				);
				if (auxTa.IsReminderSet && auxTa.ReminderDateTime != null) {
					mh.AV_Reminder__c = auxTa.ReminderDateTime;
				}
				histList.add(mh);
			}
			if (!histList.isEmpty()) {
				Database.insert(histList, false);
			}
		}
	}
	
	/**
	* @description		 Change Centro task
	* @param  listNews  list of new Task records
	* @param  mapOlds 	map of old Task records
	*/
	public static void updateCentro(List<Task> listData, Map<Id, Task> mapOldObj){
		Map<Id,String> mapOwnerOffice = new Map<Id,String>();
		Set<Id> owners = new Set<Id>();
		List<Task> taskToProcess = new List<Task>();
		User userGFC = [SELECT ID FROM USER WHERE Alias = 'AV-TF9' and IsActive = TRUE LIMIT 1];
		
		Set<Id> rtsToUpdate = new Set<Id>{AV_AppUtilities.getRecordType('Task','AV_Otros').Id,
			AV_AppUtilities.getRecordType('Task','AV_Onboarding').Id};									
				String offiNumber='';
		if(mapOldObj != null && !mapOldObj.isEmpty()){//Updating tasks
			for(Task tsk : listData){
				if(tsk.OwnerId != mapOldObj.get(tsk.Id).OwnerId){
					owners.add(tsk.OwnerId);
					taskToProcess.add(tsk);				
				}			
			}
		}else{// New Tasks
			for(Task tsk : listData){
				if(rtsToUpdate.contains(tsk.RecordTypeId)){
					owners.add(tsk.OwnerId);
					taskToProcess.add(tsk);				
				}			
			}
			
		}
		List<User> ownerOffice = [SELECT ID, AV_NumeroOficinaEmpresa__c from USER WHERE ID in :owners];
		for(User owner : OwnerOffice){
			mapOwnerOffice.put(owner.Id,owner.AV_NumeroOficinaEmpresa__c);
		}
		for(Task tsk : taskToProcess){
			if(tsk.OwnerId != UserGFC.id){
				offiNumber= mapOwnerOffice.get(tsk.OwnerId);
				tsk.AV_Center__C = (offiNumber != null)?offiNumber.substring(offiNumber.length()-5):null;
			}		
		}
	} 
	
	
	/**
	 *Process the value of the field "AV_CenterRtIndex__c", which should  
	 * get filled at the inserts and updates that changes the fields AV_Center__c or RecordTypeId from tasks. 
	 * The field always has the value "AV_Center__c"+'-'+"RecordTypeId"
	 */

	public static void insertOrUpdateCenterAndRt(List<Task> listNews, Map<Id, Task> mapOlds ){
		if(mapOlds == null || mapOlds.isEmpty() ){//Insert
			for(Task tsk : listNews){
				tsk.AV_CenterRtIndex__c = tsk.AV_Center__C+'-'+tsk.RecordTypeId;
			}
		}else{
			for(Task tsk : listNews){
				if( (tsk.AV_Center__c != mapOlds.get(tsk.Id).AV_Center__c) 
					||
					(tsk.RecordTypeId != mapOlds.get(tsk.Id).RecordTypeId) ){
						tsk.AV_CenterRtIndex__c = tsk.AV_Center__C+'-'+tsk.RecordTypeId;

					}
			}
		}
	}

	/**
	* @description      Validation to GCF not change  
	* @param  listNews  list of new Task records
	* @param  mapOlds   map of old Task records
	*/
	public static void updateGCF(List<Task> listNews, Map<Id, Task> mapOlds ){
		List<String> listIdUserApiOnly = new List<String>();
		Map<String,AV_ManagementHistory__c> activityIdManagementHistoryMap = New Map<String,AV_ManagementHistory__c>();
		List<String> taskIdList = new List<String>();
		List<User> userApiOnly = [Select Id from User where Profile.Name='API Only'];
		for(User us : userApiOnly) {
			listIdUserApiOnly.add(us.Id);
		}
		if (listIdUserApiOnly.contains(UserInfo.getUserId())) {
			if(mapOlds != null){
				for(Task t : listNews){ 
					taskIdList.add(t.Id);
				}
				List<AV_ManagementHistory__c> managementHistoryList = [SELECT Id, AV_ActivityId__c, AV_Date__c FROM AV_ManagementHistory__c WHERE AV_ActivityId__c IN: taskIdList];
				if (managementHistoryList != null && !managementHistoryList.isEmpty()) {
					for(AV_ManagementHistory__c mh : managementHistoryList){
						activityIdManagementHistoryMap.put(mh.AV_ActivityId__c, mh);
					}
				}
				for(Task tsk : listNews) {
					if(tsk.AV_OrigenApp__c != AV_AppConstants.OPP_ORIGEN_UPDATE_WALLET && tsk.AV_OrigenApp__c != AV_AppConstants.DATAPIPELINES_ORIGENAPP){
						if ((!(tsk.Status == AV_AppConstants.TASK_STATUS_PENDIENTE ||  (tsk.Status == AV_AppConstants.NO_GESTIONADA && (activityIdManagementHistoryMap.get(tsk.Id)) == null)) && mapOlds.get(tsk.Id).AV_ToDelete__c != tsk.AV_ToDelete__c && tsk.AV_ToDelete__c == true)) {
							tsk.AV_ToDelete__c = mapOlds.get(tsk.Id).AV_ToDelete__c;
						}
						if ((mapOlds.get(tsk.Id).Status != tsk.Status || mapOlds.get(tsk.Id).AV_Tipo__c != tsk.AV_Tipo__c || mapOlds.get(tsk.Id).Description != tsk.Description) && (mapOlds.get(tsk.Id).Status == AV_AppConstants.GESTIONADO_POSITIVO_ESTADO || mapOlds.get(tsk.Id).Status == AV_AppConstants.GESTIONADO_NEGATIVA_ESTADO)) {
							tsk.Status = mapOlds.get(tsk.Id).Status;
							tsk.AV_Tipo__c = mapOlds.get(tsk.Id).AV_Tipo__c;
							tsk.Description = mapOlds.get(tsk.Id).Description;
						}
						if ((mapOlds.get(tsk.Id).AV_Center__c != tsk.AV_Center__c || mapOlds.get(tsk.Id).AV_CodigoGestorAsignado__c != tsk.AV_CodigoGestorAsignado__c) && !listIdUserApiOnly.contains(mapOlds.get(tsk.Id).LastModifiedById)) {
							tsk.AV_Center__c = mapOlds.get(tsk.Id).AV_Center__c;
							tsk.AV_CodigoGestorAsignado__c = mapOlds.get(tsk.Id).AV_CodigoGestorAsignado__c;
						}
					}
				}
			}
		}
	}
    
	/**
	* @description     	Cambio Owner SinGestor
	* @param  listNews  list of new Task records
	* @param  mapOlds   map of old Task records
	*/
    public static void updateSinGestor(List<Task> listNews, Map<Id, Task> mapOlds ){
       List <Contact> cntactUser = [SELECT Id, CC_Matricula__c FROM Contact WHERE AV_Usuarioasociado__c = :UserInfo.getUserId()];
       if(!cntactUser.isEmpty() || cntactUser == null){
        	User usersinGestor = [Select Id, Name From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9'];
        	for(Task tsk :listNews){
            	if(tsk.OwnerId == usersinGestor.Id && tsk.Status != mapOlds.get(tsk.Id).Status){
                	tsk.OwnerId = UserInfo.getUserId();
                    tsk.AV_CodigoGestorAsignado__c = cntactUser[0].CC_Matricula__c;
           	 	}        
       		}
       }
	}    

	/**
	* @description     	Delete Object related with task
	* @param  deletedTaskList  list of delete Task records
	*/
	public static void deleteRecordsRelatedWithTask(List<Task> deletedTaskList){
		Map<Id, Task> mapIdsTask = new Map<Id, Task>(deletedTaskList);
		List<AV_ManagementHistory__c> managementHistoryList = [Select Id From AV_ManagementHistory__c Where AV_ActivityId__c in :mapIdsTask.keySet()];
		List<CBK_Activity_Extension__c> taskExtensionList = [Select Id From CBK_Activity_Extension__c Where AV_ActivityId__c in :mapIdsTask.keySet()];
		Set<String> listExternalIdsHeaderTask = new Set<String>();
		Set<String> listIdsHeaderTask = new Set<String>();
        for (Task t : deletedTaskList){
            if (String.isNotBlank(t.AV_Task__c)){
                listIdsHeaderTask.add(t.AV_Task__c);
            }
            else if (String.isNotBlank(t.AV_ExternalID__c)){
                listExternalIdsHeaderTask.add(t.AV_ExternalID__c);
            }
        }
		List<AV_CustomActivityOpportunity__c> taskOppList = [Select Id From AV_CustomActivityOpportunity__c Where (AV_Task__c IN :listIdsHeaderTask OR AV_Task__r.AV_ExternalID__c IN :listExternalIdsHeaderTask) OR (AV_Task__c IN :listIdsHeaderTask AND AV_Task__r.AV_ExternalID__c IN :listExternalIdsHeaderTask)];
		List<AV_HeaderCustomActivity__c> listHeaderTask = [SELECT Id FROM AV_HeaderCustomActivity__c WHERE (Id IN :listIdsHeaderTask OR AV_ExternalID__c IN :listExternalIdsHeaderTask) OR (Id IN :listIdsHeaderTask AND AV_ExternalID__c IN :listExternalIdsHeaderTask)];
		if((!managementHistoryList.isEmpty() || !taskExtensionList.isEmpty() || !taskOppList.isEmpty() || !listHeaderTask.isEmpty())) {
			System.enqueueJob(new AV_DeleteRelatedTaskQueueable(managementHistoryList,taskExtensionList,taskOppList,listHeaderTask));
		}	
	}


	/**
	 * Notify the owners of inserted Experiencia Clientes tasks and make an instance in the bbdd in order to 
	 * send a custom notify to the owner trough the CBK_SchedulableProcess framework.
	 * Notification will set to two days before tasks activity Date
	 * 	* @param  listNews  list of new Task records
	 *  * @param  mapOlds   map of old Task records
	 */
	public static void notifyExperienciaCliTask(List<Task> listTask,Map<Id, Task> mapOlds,Boolean isUpdate){
        String method = 'notifyExperienciaCliTask';
		Boolean scheduleCSExist = CBK_ScheduleControls__c.getValues('ScheduleInfo') != null;
		if(scheduleCSExist){
			String scheduleClass = 'AV_NotifyExpCliTaskSchedulable';
			RecordType rtExpTask = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKEXPCLIENT_RT);
			Map<Id,Task> taskToReScheduleMap = new Map<Id,Task>();
			List<CBK_SCH_PendingProcess__c> launchSchedule = new List<CBK_SCH_PendingProcess__c>();
			List<Task> tskToNotify = new List<Task>();
			Boolean changeOwner;
			Boolean changeDueDate;
			for(Task t :listTask){
				if(t.RecordTypeId.equals(rtExpTask.Id)){
					if(!isUpdate){
						tskToNotify.add(t);
						Date m = t.ActivityDate.addDays(-2);
						CBK_SCH_PendingProcess__c sn = new CBK_SCH_PendingProcess__c();
						sn.RecordId__c = t.Id;
						sn.Schedule_Time__c = (Datetime) m;
						sn.Queued__c = false;
						sn.ClassName__c = scheduleClass;
						sn.Param1__c = t.OwnerId;
						sn.Param2__c = String.valueOf(t.ActivityDate);
						launchSchedule.add(sn);
					}else if(isUpdate){
						changeOwner = !t.OwnerId.equals(mapOlds.get(t.Id).OwnerId);
						changeDueDate = t.ActivityDate != mapOlds.get(t.Id).ActivityDate;		
						if(changeOwner){
							taskToReScheduleMap.put(t.Id,t);
							tskToNotify.add(t);
						}
						
						if(!changeOwner && changeDueDate){
							taskToReScheduleMap.put(t.Id,t);
						}
					}			
				}
			}
			if(tskToNotify!=null && !tskToNotify.isEmpty()){
				executeNotification(tskToNotify);
			}
			if(launchSchedule != null && !launchSchedule.isEmpty()){
				CBK_ScheduleProcess_Controller.createRecordSchProcess(launchSchedule);
			}
			if(isUpdate && taskToReScheduleMap != null && !taskToReScheduleMap.isEmpty()){
				List<CBK_SCH_PendingProcess__c> launchReSchedule = [SELECT Id,RecordId__c,Queued__c,QueuedDate__c 
					FROM CBK_SCH_PendingProcess__C WHERE
					RecordId__c IN :taskToReScheduleMap.keySet() AND ClassName__c = :scheduleClass];
					Map<Id,CBK_SCH_PendingProcess__c> pendingProcessTaskMap = new Map<Id,CBK_SCH_PendingProcess__c>();
				for(CBK_SCH_PendingProcess__C sch : launchReSchedule){
					pendingProcessTaskMap.put(sch.RecordId__c,sch);
				}
				launchReSchedule.clear();
						for(Id tId : taskToReScheduleMap.keySet()){
							Task taskToProcess = taskToReScheduleMap.get(tId);
							CBK_SCH_PendingProcess__c sch = pendingProcessTaskMap.get(tId);
							if (sch != null) {
					sch.Param1__c = taskToProcess.OwnerId;
					sch.Param2__c = String.valueOf(taskToProcess.ActivityDate);
					Boolean changeOwnerUpdt = !mapOlds.get(tId).OwnerId.equals(taskToProcess.OwnerId);
					Date m = taskToProcess.ActivityDate;
					sch.Schedule_Time__c = (Datetime) m.addDays(-2);
					Long timeDif = AV_AppUtilities.calculateTimeDifferences(System.now(),taskToProcess.ActivityDate);
								if((timeDif > 48 && sch.Queued__c == true) || (changeOwnerUpdt && sch.Queued__c == true)){
						sch.Queued__c = false;
						sch.QueuedDate__c = null;
					}
					launchReSchedule.add(sch);
							} else {
								Date m = taskToProcess.ActivityDate.addDays(-2);
								CBK_SCH_PendingProcess__c sn = new CBK_SCH_PendingProcess__c();
								sn.RecordId__c = taskToProcess.Id;
								sn.Schedule_Time__c = (Datetime) m;
								sn.Queued__c = false;
								sn.ClassName__c = scheduleClass;
								sn.Param1__c = taskToProcess.OwnerId;
								sn.Param2__c = String.valueOf(taskToProcess.ActivityDate);
								launchReSchedule.add(sn);
							}
						}
						if (launchReSchedule!= null&& !launchReSchedule.isEmpty()) {
							Database.upsert(launchReSchedule,false);
						}
			}
		}
	}
	
	/**
	 * Given a list of taks 
	 */
	public static void executeNotification(List<Task> tskToNotify){//INSERT
		CustomNotificationType nt = [SELECT ID,DeveloperName FROM CustomNotificationType WHERE DeveloperName = :AV_AppConstants.TASKNOTIFICATION];
		String methodName = 'executeNotification';
		Messaging.CustomNotification cn = new Messaging.CustomNotification();
		String title = 'Nueva Tarea de Experiencia Cliente';
		String body =  'Se le ha asignado una nueva tarea de Experiencia Cliente';
		for(Task t : tskToNotify){
			cn.setTargetId(t.Id);
			cn.setNotificationTypeId(nt.Id);
			cn.setTitle(title);
			cn.setBody(body);
			try { 
				cn.send(new Set<String>{t.OwnerId});
			}catch(Exception e){
				AV_LogDebug.printLogError(methodName, e.getMessage());
			}
		}
	}

	/**
	 * Create and send a custom notification from a single task and a single owner. This method is meant to 
	 * be called from the schedulable
	 * @param string targetId
	 * @param String taskId
	 */
	public static void executeNotification(String targetId, String taskId){//UPDATE
		String methodName = 'executeNotification';
		CustomNotificationType nt = [SELECT ID,DeveloperName FROM CustomNotificationType WHERE DeveloperName = :AV_AppConstants.TASKNOTIFICATION];
		Messaging.CustomNotification cn = new Messaging.CustomNotification();
		String title = 'Tarea de Experiencia Cliente vence en menos de 48 horas';
		String body = 'Tarea a punto de vencer';
		cn.setTargetId(taskId);
		cn.setNotificationTypeId(nt.Id);
		cn.setTitle(title);
		cn.setBody(body);
		try { 
			cn.send(new Set<String>{targetId});
		}catch(Exception e){
			AV_LogDebug.printLogError(methodName, e.getMessage());
		}
	}

	/**
	 * Do not let update the task if the value of AV_Tipo__C is "Office Task" and it doesnt come from report.
	 * @param  listNews  list of new Task records
	 * @param  mapOlds   map of old Task records
	 */
	public static void checkOfficeTaskUpdate(List<Task> listTask,Map<Id, Task> mapOlds){
		if(listTask != null && !listTask.isEmpty()){
			for (Task t : listTask) {
				if(t.AV_Tipo__c != null && !String.isEmpty(t.AV_Tipo__c)){
					if (t.AV_Tipo__c 
				!= mapOlds.get(t.id).AV_Tipo__c && 
				t.AV_Tipo__c.equals(AV_AppConstants.TASKOFFICETYPE)) {
					if (!AV_AppConstants.OPP_ORIGEN_SF_REPORT.equals(t.AV_OrigenApp__c) && !AV_AppConstants.CLIENT_REPORT_ORIGENAPP.equals(t.AV_OrigenApp__c)) {
						t.addError('Este tipo de tarea solo puede ser informado desde el reporte.');
					}
				}
				if(t.AV_OrigenApp__c != null && String.isNotBlank(t.AV_OrigenApp__c) && !t.AV_OrigenApp__c.equals(mapOlds.get(t.Id).AV_OrigenApp__c) && t.AV_OrigenApp__c == AV_AppConstants.OPP_ORIGEN_SF_REPORT){
					t.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT.equals(mapOlds.get(t.Id).AV_OrigenApp__c) ? '' : mapOlds.get(t.Id).AV_OrigenApp__c;
				}
				}
			}
		}
	}

	/**
	* @description     OrigenApp value gets reset after.
	* @param  listNew  list of new Task records
	* @param  mapOld   map of old Task records.
	*/
	public static Map<String, Task> checkReportClient(List<Task> listNew, Map<Id,Task> mapOld) {
		Map<String, Task> mapReturnToAfter = new Map<String, Task>();
		Set<String> originsToByPass = new Set<String>{
			AV_AppConstants.CLIENT_REPORT_ORIGENAPP,
			AV_AppConstants.OPP_ORIGEN_BACK_REPORT
		};
		for (Task o : listNew) {
			if(o.AV_OrigenApp__c != null && String.isNotBlank(o.AV_OrigenApp__c) && !o.AV_OrigenApp__c.equals(mapOld.get(o.Id).AV_OrigenApp__c) && originsToByPass.contains(o.AV_OrigenApp__c)){
				o.AV_OrigenApp__c = originsToByPass.contains(mapOld.get(o.Id).AV_OrigenApp__c) ? '' : mapOld.get(o.Id).AV_OrigenApp__c;
				mapReturnToAfter.put(o.AV_ExternalID__c,o);
			}
			if(o.AV_OrigenApp__c != null && String.isNotBlank(o.AV_OrigenApp__c) && !o.AV_OrigenApp__c.equals(mapOld.get(o.Id).AV_OrigenApp__c) && o.AV_OrigenApp__c == AV_AppConstants.OPP_ORIGEN_UPDATE_WALLET){
				o.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_UPDATE_WALLET.equals(mapOld.get(o.Id).AV_OrigenApp__c) ? '' : mapOld.get(o.Id).AV_OrigenApp__c;
			}
			if(o.AV_OrigenApp__c != null && String.isNotBlank(o.AV_OrigenApp__c) && !o.AV_OrigenApp__c.equals(mapOld.get(o.Id).AV_OrigenApp__c) && o.AV_OrigenApp__c == AV_AppConstants.DATAPIPELINES_ORIGENAPP){
				o.AV_OrigenApp__c = AV_AppConstants.DATAPIPELINES_ORIGENAPP.equals(mapOld.get(o.Id).AV_OrigenApp__c) ? '' : mapOld.get(o.Id).AV_OrigenApp__c;
			}
		}
		return mapReturnToAfter;
	}

	public static void validationRulesTask(List<Task> listNew, Map<Id,Task> mapOld){
		List<Task> taskToValidate = new List<Task>();
		Set<String> validOrigins = new Set<String>{
			AV_AppConstants.CLIENT_REPORT_ORIGENAPP,
			AV_AppConstants.OPP_ORIGEN_BACK_REPORT
		};

		for(Task t : listNew){
			if(t.AV_OrigenApp__c == null || String.isBlank(t.AV_OrigenApp__c) || (!(validOrigins.contains(t.AV_OrigenApp__c)))){
				taskToValidate.add(t);
			}
		}

		if(!taskToValidate.isEmpty() && taskToValidate != null){
			Set<String> taskRetailRt = new Set<String>{
				AV_AppConstants.TASKINICIATIVA_RT,
				AV_AppConstants.TASKALERTACOM_RT,
				AV_AppConstants.TASKAVISOS_RT,
				AV_AppConstants.TASKCONTACTGCF_RT,
				AV_AppConstants.TASKEXPCLIENT_RT,
				AV_AppConstants.TASKONBOARDING_RT,
				AV_AppConstants.TASKPRIORIZADOR_RT,
				AV_AppConstants.TASKCPENDIENTE_RT
			};
			Map<Id,RecordType> rtIdToDevName = new Map<Id,RecordType>([SELECT Id FROM RecordType WHERE DeveloperName IN :taskRetailRt]);
			Set<String> closedStatusTasks = new Set<String>{
						AV_AppConstants.GESTIONADO_POSITIVO_ESTADO,
						AV_AppConstants.GESTIONADO_NEGATIVA_ESTADO,
						AV_AppConstants.NO_GESTIONADA,
						AV_AppConstants.GESTIONADO_NO_LOCALIZADO,
						AV_AppConstants.TASK_DESACTIVADA
			};

			User currentUserProfile = [SELECT AV_ProfileName__c FROM USER 	WHERE ID = :UserInfo.getUserId() LIMIT 1];
			Boolean isUsuarioCaixabank = false;
			
			if(currentUserProfile != null && currentUserProfile.AV_ProfileName__c != null){
				isUsuarioCaixabank = currentUserProfile.AV_ProfileName__c.equals(AV_AppConstants.AV_PROFILE);
			}
			
			Boolean hasByPassValidationRulesAv = FeatureManagement.checkPermission('AV_ByPassValidationRules');
			Boolean hasByPassValidationRulesCbk = FeatureManagement.checkPermission('CBK_BypassValidationRules');
			Boolean hasByPassAvoidBulkApi = FeatureManagement.checkPermission('AV_AvoidBulkApi');
			Boolean isInsert = (mapOld == null);
			for(Task t : taskToValidate){
				Task oldTask = (!isInsert) ? mapOld.get(t.Id) : null;
				Boolean changedStatus = (!isInsert) ? (oldTask != null && oldTask.Status != null && !(t.Status.equals(oldTask.Status))) : null;
				Boolean isInRetailRt = rtIdToDevName.containsKey(t.RecordTypeId);

				if(!isInsert){
					if(changedStatus && isInRetailRt && !hasByPassValidationRulesAv && !hasByPassValidationRulesCbk && closedStatusTasks.contains(oldTask.Status) && isUsuarioCaixabank && !hasByPassAvoidBulkApi){
						t.addError('No se permite cambiar al estado seleccionado.');
					}
				}			
			}
		}
	}
}