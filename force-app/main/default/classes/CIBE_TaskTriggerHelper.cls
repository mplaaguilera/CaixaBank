/**********************************************************************************************************************
Name:	  CIBE_TaskTriggerHelper
Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Task.
------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	        AUTHOR		   		DATE				Description
1.0			US430953		    Mikel Lezama   	    26/08/2022		    Init version
2.0         US481662            Jose Maria          29/11/2022          Funcionalidad Cartera y Sector añadido al metodo ChangeOwner
***********************************************************************************************************************/

public with sharing class CIBE_TaskTriggerHelper {
    
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
            if (rt.getDeveloperName().left(5)=='CIBE_') {
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

        return CIBE_AppUtilities.getRecordTypeIdsInSet(setRT);
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
		if( User.SObjectType.getDescribe().isAccessible()) {
            userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only'AND Alias = 'AV-TF9' AND IsActive = true LIMIT 1];
        }
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
           
            if (userGcf!=null){
                for(Task a : lstTasksSinEap){
                    a.OwnerId = userGcf.Id;
                }
            }
		}
		
        //Update owner task for employees
		if(codigosGestores!=null && !codigosGestores.isEmpty()) {
			Map<String, Id> mapGestoresUsers = new Map<String, Id>();

            List<User> listGestoresUsers =  new  List<User>();
            if(
                User.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.User.fields.AV_ExternalID__c.isAccessible()
            ) {
               listGestoresUsers = [SELECT Id, AV_ExternalID__c FROM User WHERE AV_ExternalID__c IN :codigosGestores AND IsActive = true];
            }
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
	 * @description		 Change owner to SinGestorEap if new owner has not associted contact
	 * @param  listNews  list of new Task records
	 * @param mapOlds map of old Task records
	 */
	public static void changeOwner(List<Task> listNews, Map<Id, Task> mapOlds) {

        Set<Id> tskIds = new Set<Id>();
		Set<Id> tskOwners = new Set<Id>();
		List<Task> tskToProcess = new List<Task>();
        Map<Id,Id> mapTask = new Map<Id,Id>();

        if(mapOlds != null && !mapOlds.isEmpty()){//update task
			for(Task tsk: listNews){
                mapTask.put(tsk.id, tsk.OwnerId);
                tskIds.add(tsk.id);
				if(String.isNotBlank(tsk.OwnerId) && tsk.OwnerId != mapOlds.get(tsk.Id).OwnerId){
					tskToProcess.add(tsk);
					tskOwners.add(tsk.OwnerId);
				}
			}
		}else{//insert task
			for (Task tsk : listNews) {
                if(String.isNotBlank(tsk.OwnerId)) {
                    tskToProcess.add(tsk);
                    tskOwners.add(tsk.OwnerId);
                }
			}
		}

        if(!tskToProcess.isEmpty() && !tskOwners.isEmpty()) {
            List<Contact> listCont = new List<Contact>();
            if(
				Contact.SObjectType.getDescribe().isAccessible() &&
				Schema.SObjectType.Contact.fields.lastmodifieddate.isAccessible() &&
				Schema.SObjectType.Contact.fields.CIBE_Sector__c.isAccessible()&&
				Schema.SObjectType.Contact.fields.CIBE_Cartera__c.isAccessible()&&
				Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible()
			) {
				listCont= [SELECT Id, lastmodifieddate,CIBE_Sector__c, CIBE_Cartera__c, AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__c IN :tskOwners];
			}

            List<CBK_Activity_Extension__c> listTaskExtension = new List<CBK_Activity_Extension__c>();
            if(Schema.sObjectType.CBK_Activity_Extension__c.isAccessible() &&
            Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_Sector__c.isAccessible()&&
            Schema.SObjectType.CBK_Activity_Extension__c.fields.CIBE_Cartera__c.isAccessible()&&
            Schema.SObjectType.CBK_Activity_Extension__c.fields.AV_ActivityId__c.isAccessible()){
                listTaskExtension = [SELECT Id,CIBE_Sector__c,CIBE_Cartera__c,AV_ActivityId__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c IN :tskIds];
            }
    
            Set<ID> idsContact = new Set<ID>();
            Map<String,Contact> mapUserContact = new Map<String,Contact>();
            List<CBK_Activity_Extension__c> listActExtUpdt = new  List<CBK_Activity_Extension__c>();

            if (!listCont.isEmpty()) {
                for(Contact cnt : listCont){
                    idsContact.add(cnt.AV_UsuarioAsociado__c);
                    mapUserContact.put(cnt.AV_UsuarioAsociado__c,cnt);
                }

                if(!tskIds.isEmpty()) {

                    if(!listTaskExtension.isEmpty()) {
                        for(CBK_Activity_Extension__c cbkActExt : listTaskExtension){                        
                            if(mapTask.containsKey(cbkActExt.AV_ActivityId__c) && mapUserContact.containsKey(mapTask.get(cbkActExt.AV_ActivityId__c)) ){
                                cbkActExt.CIBE_Cartera__c = mapUserContact.get(mapTask.get(cbkActExt.AV_ActivityId__c)).CIBE_Cartera__c;
                                cbkActExt.CIBE_Sector__c = mapUserContact.get(mapTask.get(cbkActExt.AV_ActivityId__c)).CIBE_Sector__c;
                                listActExtUpdt.add(cbkActExt);
                            }
                        }
                        
                    }
                }
            } 

            Map<Id,CBK_Activity_Extension__c> mapActExt = new Map<Id,CBK_Activity_Extension__c>();
			for(CBK_Activity_Extension__c actExt: listTaskExtension){
				mapActExt.put(actExt.AV_ActivityId__c,actExt);
			}


            List<User> userGcf = new List<User>();
            List<User> ownerWithNoEap = new List<User>();
            if(	User.SObjectType.getDescribe().isAccessible() ) {
                //Invocamos al usuario para owners sin EAP
                userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' LIMIT 1];
                //Retrieve users who are not in contact table 
                ownerWithNoEap = [SELECT ID FROM USER WHERE id NOT IN: idsContact AND id IN :tskOwners];
            }

            Set<Id> idOwnerWithNoEap = new Set<Id>();
            if(!ownerWithNoEap.isEmpty()){
                for(User u : ownerWithNoEap){
                    idOwnerWithNoEap.add(u.id);
                }
            }

            for(Task tsk : tskToProcess){			  
                if(idOwnerWithNoEap.contains(tsk.OwnerId)){
                    tsk.OwnerId= userGcf[0].Id;
                    if(mapActExt.containsKey(tsk.id)){
						mapActExt.get(tsk.id).CIBE_Cartera__c = null;
						mapActExt.get(tsk.id).CIBE_Sector__c = null;
						listActExtUpdt.add(mapActExt.get(tsk.id));
					}
                }
            }	

            if(!listActExtUpdt.isEmpty()) {
                if(CBK_Activity_Extension__c.sObjectType.getDescribe().isUpdateable() ){
                    Database.update(listActExtUpdt, false);
                }
            }

        }
	}

    /**
    * @description		 Validate forbidden words in Task field 
    * @param  listNews  list of new Task records
    * @param mapOlds map of old Task records
    */
    public static void validateForbiddenWords(List<Task> listNews, Map<Id, Task> mapOlds) {		

        Set<Id> setIdsRt = getAllRT();
        List<Task> listToProcess = new List<Task>();
        Set<String> setFields = new Set<String>{'Description', 'Subject'};
            if(mapOlds != null) {
                for(Task tas : listNews) {
                    if((setIdsRt).contains(tas.RecordTypeId) && ((String.isNotBlank(tas.Description) && mapOlds.get(tas.Id).Description != tas.Description) ||
                                                                 (String.isNotBlank(tas.Subject) && mapOlds.get(tas.Id).Subject != tas.Subject))) {
                                                                     listToProcess.add(tas);
                                                                 }
                }
            } else {
                for(Task tas : listNews) {
                    if( (setIdsRt).contains(tas.RecordTypeId) && String.isNotBlank(tas.Description) || String.isNotBlank(tas.Subject)) {
                        listToProcess.add(tas);
                    }
                }
            }
        if(!listToProcess.isEmpty()) {
            AV_ForbiddenWords.validateRecords(listToProcess, setFields);
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
                    
                    String externalId = CIBE_AppConstants.SUFFIX_EXTERNALID + '$OPP$#' + (Math.round(Math.random()*1000000) + Datetime.now().getTime());
                    
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
                if(AV_HeaderCustomActivity__c.sObjectType.getDescribe().isCreateable() ){
                    Database.insert(listHeaderTask, false);
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
    /*public static void validateTaskOnboardingPositiveClosed(List<Task> listNews, Map<Id, Task> mapOlds){
        system.debug('validateTaskOnboardingPositiveClosed');

        
        String methodName = 'validateTaskOnboardingPositiveClosed';
        Set<String> setLabelsRts = new Set<String>{'AV_Onboarding'};
        Set<Id> setIdsRt = getIdsRT(setLabelsRts);
        List<Task> taskToProcess = new List<Task>();
        
        User userLog = CIBE_AppUtilities.getUserInfo();
        Boolean isApiOnly = 'API Only'.equalsIgnoreCase(userLog.AV_ProfileName__c);
        
        if(!isApiOnly){
            if(mapOlds == null ||  mapOlds.isEmpty()) {
                for(Task tarea : listNews){
                    if((setIdsRt).contains(tarea.RecordTypeId)  && tarea.Status == CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO){
                        taskToProcess.add(tarea);
                    }
                }	
            }else{
                for(Task tarea : listNews){
                    if((setIdsRt).contains(tarea.RecordTypeId)  && tarea.Status == CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO 
                       && mapOlds.get(tarea.Id).Status != CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO){
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
    */
    /**
    * @description		 
    * @param  listOlds  list of old Opportunity records
    */
    public static void validateDeleteTask(List<Task> listOlds){

        if(listOlds!=null && !listOlds.isEmpty()){
            Set<String> setLabelsRts = new Set<String>{CIBE_AppConstants.TASK_OTROS_CIB_RT, CIBE_AppConstants.TASK_OTROS_EMP_RT};

            Set<Id> setIdsRts = getIdsRT(setLabelsRts);
            Set<String> setIdsTask = new Set<String>();
            Set<Id> setIdsHeaderTask = new Set<Id>();

            User currentUser= new User();
            if(	
                User.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.User.fields.AV_ProfileName__c.isAccessible() &&
                Schema.SObjectType.User.fields.Name.isAccessible()
            ) {
                currentUser  = [SELECT Name, AV_ProfileName__c FROM User WHERE Id = :UserInfo.getUserId()];
            }
            
            String profileCu = currentUser.AV_ProfileName__c;
            
            for(Task tskId : listOlds){
                //Validate Record Types that can be removed
                if(!setIdsRts.contains(tskId.RecordTypeId) && profileCu == 'CIBE_Gestor'){
                    tskId.addError(ERROR_MESSAGE_USER);
                }
                if (String.isNotBlank(tskId.AV_ExternalID__c)){
                    setIdsTask.add(tskId.AV_ExternalID__c);
                }
            }
            List<AV_HeaderCustomActivity__c> listHeaderTask = new List<AV_HeaderCustomActivity__c>();
            if(
                AV_HeaderCustomActivity__c.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.AV_HeaderCustomActivity__c.fields.AV_ExternalID__c.isAccessible()
            ) {
                listHeaderTask= [SELECT Id, AV_ExternalID__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c IN : setIdsTask];
            }

            if(!listHeaderTask.isEmpty()){
                for(AV_HeaderCustomActivity__c htask : listHeaderTask){
                    setIdsHeaderTask.add(htask.Id);
                }
            }

            List<AV_CustomActivityOpportunity__c> listTaskAndOpp = new List<AV_CustomActivityOpportunity__c>();
            if(
                AV_CustomActivityOpportunity__c.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Task__c.isAccessible()
            ) {
                listTaskAndOpp= [SELECT Id, AV_Task__r.AV_ExternalID__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c IN : setIdsHeaderTask];
            }

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

            User currentUser= new User();
            if(	
                User.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.User.fields.AV_NumeroOficinaEmpresa__c.isAccessible() &&
                Schema.SObjectType.User.fields.Name.isAccessible()
            ) {
                currentUser  = [SELECT Name, AV_NumeroOficinaEmpresa__c FROM User WHERE Id = :UserInfo.getUserId()];
            }
            
            String employeeInfo = currentUser.Name;
            if(String.isNotBlank(currentUser.AV_NumeroOficinaEmpresa__c) && currentUser.AV_NumeroOficinaEmpresa__c.contains('-')) {
                employeeInfo += ' (ofi ' + currentUser.AV_NumeroOficinaEmpresa__c.split('-').get(1) + ')';
            }
            
            if(mapOlds == null) {
                for(Task auxTa : lstToProcess) {
                    CBK_Activity_Extension__c crmTask = new CBK_Activity_Extension__c(AV_ActivityId__c = auxTa.Id, AV_CommentLastModifiedBy__c = employeeInfo, AV_CommentLastModifiedDate__c = System.now());
                    lstCRMTasksToInsert.add(crmTask);
                }
            } else {
                List<CBK_Activity_Extension__c> lstCRMTasks = new  List<CBK_Activity_Extension__c>();
                if(
                    CBK_Activity_Extension__c.SObjectType.getDescribe().isAccessible() &&
                    Schema.SObjectType.CBK_Activity_Extension__c.fields.AV_ActivityId__c.isAccessible() &&
                    Schema.SObjectType.CBK_Activity_Extension__c.fields.AV_CommentLastModifiedBy__c.isAccessible()&&
                    Schema.SObjectType.CBK_Activity_Extension__c.fields.AV_CommentLastModifiedDate__c.isAccessible()
                ) {
                    lstCRMTasks =  [SELECT Id, AV_ActivityId__c, AV_CommentLastModifiedBy__c, AV_CommentLastModifiedDate__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c IN: setTaskIds];
                }

                Map<String, CBK_Activity_Extension__c> mapCRMTask = new Map<String, CBK_Activity_Extension__c>();
                for(CBK_Activity_Extension__c auxCRMTask : lstCRMTasks) {
                    mapCRMTask.put(auxCRMTask.AV_ActivityId__c, auxCRMTask);
                }
                for(Task auxTa : lstToProcess) {
                    CBK_Activity_Extension__c crmTask;
                    if(!mapCRMTask.containsKey(auxTa.Id)) {
                        crmTask = new CBK_Activity_Extension__c(AV_ActivityId__c = auxTa.Id, AV_CommentLastModifiedBy__c = employeeInfo, AV_CommentLastModifiedDate__c = System.now());
                        lstCRMTasksToInsert.add(crmTask);
                    } else {
                        crmTask = new CBK_Activity_Extension__c(Id = mapCRMTask.get(auxTa.Id).Id, AV_CommentLastModifiedBy__c = employeeInfo, AV_CommentLastModifiedDate__c = System.now());
                        lstCRMTasksToUpdate.add(crmTask);
                    }
                }
            }
            if(!lstCRMTasksToInsert.isEmpty()) {
                if(CBK_Activity_Extension__c.sObjectType.getDescribe().isCreateable() ){
                    Database.insert(lstCRMTasksToInsert, false);
                }
            }
            if(!lstCRMTasksToUpdate.isEmpty()) {
                if(CBK_Activity_Extension__c.sObjectType.getDescribe().isUpdateable() ){
                    Database.update(lstCRMTasksToUpdate, false);
                }
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
            List<Contact> listEmployees= new List<Contact>();
            if(
                Contact.SObjectType.getDescribe().isAccessible() &&
                Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible() &&
                Schema.SObjectType.Contact.fields.CC_Matricula__c.isAccessible()
            ) {
                listEmployees= [SELECT Id, CC_Matricula__c, AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__c IN :listIdOwner];
            }

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
    public static void updateNextManagementDateOpp(List<Task> listNews, Map<Id, Task> mapOlds){

        String methodName = 'updateNextManagementDateOpp';
        Set<String> setLabelsRtsTask = new Set<String>{CIBE_AppConstants.TASK_OTROS_CIB_RT, CIBE_AppConstants.TASK_OTROS_EMP_RT};
        Set<String> setLabelsRtsEvent = new Set<String>{CIBE_AppConstants.EVENT_CLIENTE_RT};
        Set<Id> setIdsRtsTask = getIdsRT(setLabelsRtsTask);
        Set<Id> setIdsRtsEvent = getIdsRT(setLabelsRtsEvent);
        List<Task> lstTasks = new List<Task>();
        Set<Id> setIdsHeaderTask = new Set<Id>();
        Set<String> setIdsTask = new Set<String>();
        Set<Id> setOpp = new Set<Id>();
        Set<Id> setTaskEventExId = new Set<Id>();
        Map<Id,List<String>> mapOppTask = new Map<Id,List<String>>();
        List<Opportunity> listOppUpdate = new List<Opportunity>();
        Map<String,List<String>> mapTaskOpp = new Map<String,List<String>>();
        List<String> ids= new List<String>();
        Date dateOppNew = null;
        
        if(mapOlds != null && !mapOlds.isEmpty() ) {
            for(Task tNew : listNews){
                Task taskOld = mapOlds.get(tNew.id);
                if((setIdsRtsTask).contains(tNew.RecordTypeId) && (taskOld.ActivityDate != tNew.ActivityDate) && tNew.AV_ExternalID__c != null && (tNew.Status == CIBE_AppConstants.TASK_STATUS_PENDIENTE || tNew.Status == CIBE_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL)){
                    setIdsTask.add(tNew.AV_ExternalID__c);
                } 
            }
            if(!setIdsTask.isEmpty()){
                List<AV_HeaderCustomActivity__c> listHeaderTask = new List<AV_HeaderCustomActivity__c>();
                if(
                    AV_HeaderCustomActivity__c.SObjectType.getDescribe().isAccessible() &&
                    Schema.SObjectType.AV_HeaderCustomActivity__c.fields.AV_ExternalID__c.isAccessible()
                ) {
                    listHeaderTask = [SELECT Id, AV_ExternalID__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c IN :setIdsTask];
                }

                if(!listHeaderTask.isEmpty()){
                    for(AV_HeaderCustomActivity__c htask : listHeaderTask){
                        setIdsHeaderTask.add(htask.Id);
                    }
                }
                List<AV_CustomActivityOpportunity__c> listTaskAndOpp = new List<AV_CustomActivityOpportunity__c> ();
                if(
                    AV_CustomActivityOpportunity__c.SObjectType.getDescribe().isAccessible() &&
                    Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Opportunity__c.isAccessible()&&
                    Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Task__c.isAccessible()
                ) {
                    listTaskAndOpp = [SELECT Id, AV_Task__r.AV_ExternalID__c, AV_Opportunity__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c != null AND AV_Task__c IN :setIdsHeaderTask];
                }
                if(!listTaskAndOpp.isEmpty()){ 
                    for(AV_CustomActivityOpportunity__c taskOpp : listTaskAndOpp){
                        setOpp.add(taskOpp.AV_Opportunity__c);
                    }
                }
                if(!setOpp.isEmpty()){
                    List<AV_CustomActivityOpportunity__c> listTaskAndOppRelated = new List<AV_CustomActivityOpportunity__c>();
                    if(
                        AV_CustomActivityOpportunity__c.SObjectType.getDescribe().isAccessible() &&
                        Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Opportunity__c.isAccessible()&&
                        Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Task__c.isAccessible()
                    ) {
                        listTaskAndOppRelated = [SELECT Id, AV_Task__r.AV_ExternalID__c, AV_Opportunity__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN :setOpp];
                    }
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
                        }
                    }
                }       
                if(!mapOppTask.isEmpty()){ 
                    Set<String> statusTask = new Set<String>{CIBE_AppConstants.TASK_STATUS_PENDIENTE, CIBE_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL};
                    Set<String> statusEvent = new Set<String>{CIBE_AppConstants.EVENT_STATUS_PENDIENTE};
                    Map<String,Date> mapOppFecha = new Map<String,Date>();

                    List<Task> listTaskAndOppRelated = new  List<Task>();
                    if(
                        Task.SObjectType.getDescribe().isAccessible() &&
                        Schema.SObjectType.Task.fields.AV_ExternalID__c.isAccessible() &&
                        Schema.SObjectType.Task.fields.ActivityDate.isAccessible()
                    ) {
                        listTaskAndOppRelated = [SELECT Id, AV_ExternalID__c, ActivityDate FROM Task WHERE Status IN :statusTask AND RecordtypeId IN :setIdsRtsTask AND AV_ExternalID__c IN :ids and ActivityDate >= TODAY order by ActivityDate ASC];
                    }
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
                    List<Event> listEventAndOppRelated = new List<Event>();
                    if(
                        Event.SObjectType.getDescribe().isAccessible() &&
                        Schema.SObjectType.Event.fields.AV_ExternalID__c.isAccessible() &&
                        Schema.SObjectType.Event.fields.ActivityDate.isAccessible()
                    ) {
                        listEventAndOppRelated = [SELECT Id, AV_ExternalID__c, ActivityDate FROM Event WHERE CSBD_Evento_Estado__c IN :statusEvent AND RecordtypeId IN :setIdsRtsEvent AND AV_ExternalID__c IN :ids AND ActivityDate >= TODAY order by ActivityDate ASC limit 1];
                    }
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
                        for (Id idOpp : mapOppTask.keySet()){
                            if (mapOppFecha.get(idOpp) != null) {
                                Opportunity oppUpdate = new Opportunity(Id= idOpp, AV_FechaProximoRecordatorio__c = mapOppFecha.get(idOpp));
                                listOppUpdate.add(oppUpdate);
                            }	
                        }
                    }
                }
                if(!listOppUpdate.isEmpty()){
                    AV_LogDebug.printLogDebug(methodName, 'Oportunidades: ' + listOppUpdate.size());
                    List<Database.SaveResult> listUpdateResult = database.update(listOppUpdate, false);
                    CIBE_AppUtilities.displayErrors(methodName,listUpdateResult);
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
            List<AV_ManagementHistory__c> histList = new List<AV_ManagementHistory__c>();
        if(mapOlds == null ||  mapOlds.isEmpty()){
			for(Task auxTa : listNews){
                AV_ManagementHistory__c mh = new AV_ManagementHistory__c(
                    AV_ActivityId__c = auxTa.Id,
                    AV_Status__c = auxTa.Status,
                    AV_Type__c = auxTa.AV_Tipo__c,
                    AV_Comment__c = auxTa.Description,
                    AV_Date__c = Date.today()
                );
                if (auxTa.IsReminderSet && auxTa.ReminderDateTime != null) {
                    mh.AV_Reminder__c = auxTa.ReminderDateTime;
                }
                histList.add(mh);
            }
		}else{
			for(Task auxTa : listNews){
                if(auxTa.Status != mapOlds.get(auxTa.Id).Status || auxTa.AV_Tipo__c != mapOlds.get(auxTa.Id).AV_Tipo__c || auxTa.Description != mapOlds.get(auxTa.Id).Description || auxTa.IsReminderSet != mapOlds.get(auxTa.Id).IsReminderSet){
                        AV_ManagementHistory__c mh = new AV_ManagementHistory__c(
                        AV_ActivityId__c = auxTa.Id,
                        AV_Status__c = auxTa.Status,
                        AV_Type__c = auxTa.AV_Tipo__c,
                        AV_Comment__c = auxTa.Description,
                        AV_Date__c = Date.today()
                    );
                    if (auxTa.IsReminderSet && auxTa.ReminderDateTime != null) {
                        mh.AV_Reminder__c = auxTa.ReminderDateTime;
                    }
                    histList.add(mh);
                }
			}
		}

            if (!histList.isEmpty()) {
                if(AV_ManagementHistory__c.SObjectType.getDescribe().isCreateable()){
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
        
        Set<Id> rtsToUpdate = new Set<Id>{CIBE_AppUtilities.getRecordType('Task',CIBE_AppConstants.TASK_OTROS_CIB_RT).Id,
        CIBE_AppUtilities.getRecordType('Task',CIBE_AppConstants.TASK_OTROS_EMP_RT).Id,
        CIBE_AppUtilities.getRecordType('Task','AV_Onboarding').Id};									
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

        List<User> ownerOffice = new List<User>();
        if(
            USER.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.USER.fields.AV_NumeroOficinaEmpresa__c.isAccessible()
        ) {
            ownerOffice = [SELECT ID, AV_NumeroOficinaEmpresa__c FROM USER WHERE ID IN :owners];
        }
        List<User> userGFC= new List<User>();
		if(	User.SObjectType.getDescribe().isAccessible() ) {
			userGFC = [SELECT ID FROM USER WHERE Alias = 'AV-TF9' AND IsActive = TRUE LIMIT 1];
		}

        for(User owner : OwnerOffice){
            mapOwnerOffice.put(owner.Id,owner.AV_NumeroOficinaEmpresa__c);
        }
        for(Task tsk : taskToProcess){
            if(tsk.OwnerId != userGFC[0].id){
                offiNumber= mapOwnerOffice.get(tsk.OwnerId);
                tsk.AV_Center__C = (offiNumber != null)?offiNumber.substring(offiNumber.length()-5):null;
            }		
        }
    } 
    
    /**
    * @description      Update Tarea-Oportunidad with Task's ActivityDate and Status
    * @param  listNews  list of new Task records
    * @param  mapOlds 	map of old Task records
    */
    public static void updateTareaOpp(List<Task> listNews, Map<Id, Task> mapOlds) {

        Map<String, Task> changedTasks = new Map<String, Task>();
        Map<Id, AV_HeaderCustomActivity__c> headerMap = new Map<Id, AV_HeaderCustomActivity__c>();
        Task aux;
        if (mapOlds == null && mapOlds.isEmpty()) {
            return;
        }
        for (Task t : listNews) {
            if (t.ActivityDate != mapOlds.get(t.Id).ActivityDate) {
                changedTasks.put(t.AV_ExternalID__c, t);
            }
        }
        if (!changedTasks.isEmpty()) {

            List<AV_HeaderCustomActivity__c> headerList = new List<AV_HeaderCustomActivity__c>();    
            if(
                AV_HeaderCustomActivity__c.SObjectType.getDescribe().isAccessible() &&
	            Schema.SObjectType.AV_HeaderCustomActivity__c.fields.AV_ExternalID__c.isAccessible()
            ) {
                headerList = [
                    SELECT Id, AV_ExternalID__c
                    FROM AV_HeaderCustomActivity__c
                    WHERE AV_ExternalID__c IN :changedTasks.keySet()
                ];
            }

            if (!headerList.isEmpty()) {
                headerMap.putAll(headerList);
                List<AV_CustomActivityOpportunity__c> taskOppList = new List<AV_CustomActivityOpportunity__c>();    
                if(
                    AV_CustomActivityOpportunity__c.SObjectType.getDescribe().isAccessible() &&
                    Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Task__c.isAccessible()
                ) {
                    taskOppList = [
                        SELECT Id, AV_Task__c
                        FROM AV_CustomActivityOpportunity__c
                        WHERE AV_Task__c IN :headerMap.keySet()
                    ];
                }
                if (!taskOppList.isEmpty()) {
                    for (AV_CustomActivityOpportunity__c taskOpp : taskOppList) {
                        aux = changedTasks.get(headerMap.get(taskOpp.AV_Task__c).AV_ExternalID__c);
                        taskOpp.AV_ActivityDate__c = aux.ActivityDate;
                        taskOpp.AV_Status__c = aux.Status;
                    }
                    if(AV_CustomActivityOpportunity__c.sObjectType.getDescribe().isUpdateable()){
                        Database.update(taskOppList);
                    }
                }
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
	* @description    Updates opp's confidentiality according to its related account.
	*/
	//public static void setConfidentiality(List<Task> listNew, Boolean isInsert) {
	public static void setConfidentiality(List<Task> listNew, Boolean isInsert){

		Set<Id> cliIds = new Set<Id>();
		Map<Id, Boolean> cliConfidentiality = new Map<Id, Boolean>();
		Map<Id, Boolean> cliEmployee = new Map<Id, Boolean>();
		for (Task tsk : listNew) {
			cliIds.add(tsk.whatId);
		}
		
        List<Account> clients= new List<Account>();
        if(
            Account.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.Account.fields.AV_Confidencial__c.isAccessible() &&
            Schema.SObjectType.Account.fields.AV_Empleado__c.isAccessible()
        ) {
		    clients = [SELECT Id, AV_Confidencial__c, AV_Empleado__c FROM Account WHERE Id IN :cliIds];
        }
		if (!clients.isEmpty()) {
			for (Account client : clients) {
				if(client.AV_Confidencial__c){
					cliConfidentiality.put(client.Id, client.AV_Confidencial__c);
					cliEmployee.put(client.Id, client.AV_Empleado__c);
				}
			}
			if (isInsert) {
				for (Task tsk : listNew) {
					if(tsk.whatId!=null && cliConfidentiality.containsKey(tsk.whatId)){
						tsk.CIBE_Confidential__c = true;
					}
				}
			} else { 
				for (Task tsk : listNew) {
					if(tsk.whatId!=null){
                        if ((cliConfidentiality.containsKey(tsk.whatId) && tsk.CIBE_Confidential__c != cliConfidentiality.get(tsk.whatId))) {
							tsk.CIBE_Confidential__c = cliConfidentiality.get(tsk.whatId);
						}
					}
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
        
        if(managementHistoryList.size() > 0 || taskExtensionList.size() > 0 || taskOppList.size() > 0 || listHeaderTask.size() > 0) {
            System.enqueueJob(new CIBE_DeleteRelatedTaskQueueable(managementHistoryList,taskExtensionList,taskOppList,listHeaderTask));
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
		List<User> userApiOnly = [SELECT id FROM User WHERE Profile.Name='API Only'];
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
					if ((!(tsk.Status == CIBE_AppConstants.TASK_STATUS_PENDIENTE 
					||  (tsk.Status == CIBE_AppConstants.NO_GESTIONADA && (activityIdManagementHistoryMap.get(tsk.Id)) == null)) && mapOlds.get(tsk.Id).AV_ToDelete__c != tsk.AV_ToDelete__c && tsk.AV_ToDelete__c == true)) {
						tsk.AV_ToDelete__c = mapOlds.get(tsk.Id).AV_ToDelete__c;
					}
					if ((mapOlds.get(tsk.Id).Status != tsk.Status 
					|| mapOlds.get(tsk.Id).AV_Tipo__c != tsk.AV_Tipo__c 
					|| mapOlds.get(tsk.Id).Description != tsk.Description) && (mapOlds.get(tsk.Id).Status == CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO 
					|| mapOlds.get(tsk.Id).Status == CIBE_AppConstants.GESTIONADO_NEGATIVA_ESTADO)) {
						tsk.Status = mapOlds.get(tsk.Id).Status;
						tsk.AV_Tipo__c = mapOlds.get(tsk.Id).AV_Tipo__c;
						tsk.Description = mapOlds.get(tsk.Id).Description;
					}
					if ((mapOlds.get(tsk.Id).AV_Center__c != tsk.AV_Center__c 
					|| mapOlds.get(tsk.Id).AV_CodigoGestorAsignado__c != tsk.AV_CodigoGestorAsignado__c) && !listIdUserApiOnly.contains(mapOlds.get(tsk.Id).LastModifiedById)) {
                        tsk.AV_Center__c = mapOlds.get(tsk.Id).AV_Center__c;
						tsk.AV_CodigoGestorAsignado__c = mapOlds.get(tsk.Id).AV_CodigoGestorAsignado__c;
					}
				}
			}
		}
	}


    /**
	* @description     	Delete deleteRelations objects related With Task
	* @param  deletedTaskList  list of delete Task records
	*/
	public static void deleteRelations(List<Task> deletedTaskList){
        User currentUser  = [SELECT Name, AV_ProfileName__c FROM User WHERE Id = :UserInfo.getUserId()];
		String profileCu = currentUser.AV_ProfileName__c;

        Set<String> setLabelsRtsEMP = new Set<String>{CIBE_AppConstants.TASK_PRIORIZADOS_EMP_RT, CIBE_AppConstants.TASK_AVISOS_EMP_RT, CIBE_AppConstants.TASK_ALERTACOMERCIAL_EMP_RT, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT,  CIBE_AppConstants.TASK_ONBOARDING_EMP_RT, CIBE_AppConstants.TASK_OTROS_EMP_RT};
        Set<Id> setIdsRtsEMP = getIdsRT(setLabelsRtsEMP);

        Set<String> setLabelsRtsCIB = new Set<String>{CIBE_AppConstants.TASK_PRIORIZADOS_CIB_RT, CIBE_AppConstants.TASK_AVISOS_CIB_RT , CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT,  CIBE_AppConstants.TASK_ONBOARDING_CIB_RT, CIBE_AppConstants.TASK_OTROS_CIB_RT};
        Set<Id> setIdsRtsCIB = getIdsRT(setLabelsRtsCIB);

        Set<String> tasks = new Set<String>();

		if(!deletedTaskList.isEmpty() && profileCu == 'CIBE_Gestor'){
            Set<String> tskSet =  new Set<String>();
            List<Task> tskListCIB =  new List<Task>();
			for(Task tsk: deletedTaskList){
				if(setIdsRtsEMP.contains(tsk.RecordTypeId) ){
					tskSet.add(tsk.Id);
				}else if(setIdsRtsCIB.contains(tsk.RecordTypeId) ){
					tskListCIB.add(tsk);
				}
			}


            if(tskSet != null){
                List<Task> tarea = [SELECT Id, AV_Task__c FROM Task WHERE Id IN :tskSet];
    
                if(!tarea.isEmpty()){

                    for (Task header : tarea) {
                        tasks.add(header.AV_Task__c);
                    }


                    List<AV_CustomActivityOpportunity__c> customActi = [SELECT Id, AV_Task__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c IN :tasks];


                    List<CIBE_RelaccionadoCita__c> relacionadoCita = [SELECT Id FROM CIBE_RelaccionadoCita__c  WHERE CIBE_TareaRelaccionada__c  IN :tasks];
    
                    if(!customActi.isEmpty()){
                        List<Database.DeleteResult> srList = Database.delete(customActi,false);	
                        for(Database.deleteResult res : srList) {
                            if(!res.isSuccess()) {
                                for(Database.Error err : res.getErrors()) {
                                    CBK_Log.error(err.getStatusCode() + ': ' + err.getMessage());
                                }
                            }
                        }		
                        
                    }

                    if(!relacionadoCita.isEmpty()){
                        List<Database.DeleteResult> srList2 = Database.delete(relacionadoCita,false);	
                        for(Database.deleteResult res2 : srList2) {
                            if(!res2.isSuccess()) {
                                for(Database.Error err : res2.getErrors()) {
                                    CBK_Log.error(err.getStatusCode() + ': ' + err.getMessage());
                                }
                            }
                        }		
                        
                    }
                }
                
            }
            if(!tskListCIB.isEmpty()){
                CIBE_TaskTriggerHelper.validateDeleteTask(tskListCIB);
                
            }

        }
	}

}