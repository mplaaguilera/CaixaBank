/**********************************************************************************************************************
Name:      CIBE_NewEventController
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora para el componente CIBE_NewEvent, cibe_NewEventReportDetail, cibe_newEventTab
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY       AUTHOR           DATE                Description
    1.0                             Alvaro, Lucia                        Init version
    1.1             US774293        Bea, Ali         16/01/2024
    1.2             US859365        Luis             19/03/2024
    1.3             PPM100376561    Luis             11/09/2024                          
***********************************************************************************************************************/

public without sharing class CIBE_NewEventController {

    private static List<String> recordTypeCIBE = new List<String>{CIBE_AppConstants.CONTACT_APODERADO_RT, CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT};
    private static CIBE_AppUtilities.SearchRT rtCliente 	= new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
    private static Set<Id> setRtCliente		= getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtCliente});

    
    @AuraEnabled 
    public static List<AV_LookupSearchResult> searchEmployees(String searchTerm) {
        Integer maxResults = 10;
        searchTerm += '*';
        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<List<SObject>> searchResults = new List<List<SObject>>();
        
            searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                RETURNING
                    User(Id, Name, AV_NumeroOficinaEmpresa__c 
                    WHERE IsActive=true and Profile.Name = 'CIBE_Gestor'
                    AND Id IN (SELECT AV_UsuarioAsociado__c FROM Contact)
                    )
                LIMIT :maxResults
            ];
        User[] listUser = (List<User>) searchResults[0];
        for (User u : listUser) {
            results.add(
                new AV_LookupSearchResult(
                    u.Id,
                    AV_AppConstants.OBJECT_NAME_USER,
                    'standard:user',
                    u.Name,
                    u.AV_NumeroOficinaEmpresa__c
                    )
                    );
                }
        results.sort();
        
        return results;
    }

    @AuraEnabled(cacheable = true)
    public static List<Contact> getContactosApoderados(String accountId){
        List<Contact> contactosApoderados = new List<Contact>();

        if(Schema.SObjectType.Contact.fields.Id.isAccessible()
        && Schema.SObjectType.Contact.fields.Name.isAccessible()){
            contactosApoderados = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName = :CIBE_AppConstants.CONTACT_APODERADO_RT AND AccountId = :accountId];
        }

        return contactosApoderados;
    }

    @AuraEnabled(cacheable = true)
    public static List<AccountContactRelation> getContactoPrincipal(String accountId, List<String> lstAccountId){
        List<AccountContactRelation > contacts = new List<AccountContactRelation>();
        Set<Id> contactUnico = new Set<Id>();
        List<String> recordTypeC = new List<String>{CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT,CIBE_AppConstants.CONTACT_APODERADO_RT};
        if((lstAccountId.IsEmpty() && accountId!=null) || (!lstAccountId.IsEmpty() && !lstAccountId.contains(accountId))){
            lstAccountId.add(accountId);
        }

        if(Schema.SObjectType.AccountContactRelation.fields.Id.isAccessible() && !lstAccountId.IsEmpty() ){
            for(AccountContactRelation acr: [SELECT Id, Contact.Id, Contact.Name, Contact.FirstName, Contact.LastName, Contact.CIBE_Cargo__c, toLabel(Contact.CC_Idioma__c), Contact.Email, Contact.Phone, Contact.Fax, Contact.Description, 
            Contact.CIBE_Confidencial__c, Contact.CIBE_ContactoInfoComercial__c, Contact.RecordType.DeveloperName, Contact.CIBE_Carrec__c, Contact.CIBE_FechaVencimiento__c, Contact.AccountId,Contact.Account.Name
            FROM AccountContactRelation 
            WHERE AccountId IN :lstAccountId AND Contact.RecordType.DeveloperName IN: recordTypeC]){
                if(contactUnico == null){
                    contactUnico.add(acr.Contact.Id);
                }
                if(!contactUnico.contains(acr.Contact.Id)){
                    contacts.add(acr);
                    contactUnico.add(acr.Contact.Id);
                }
            }
        }
        return contacts;
    }
    /**
     * Return AV_LookupSearchResult List 
     * @param List<AccountContactRelation> contacts
     * @return List<AV_LookupSearchResult>
     */
    @AuraEnabled(cacheable = true)
    public static List<AV_LookupSearchResult> getAssistEMP(List<AccountContactRelation> contacts) {
        List<AV_LookupSearchResult> lstContactPrincipal	= new List<AV_LookupSearchResult>();
        if(!contacts.isEmpty()){
            for(AccountContactRelation acr:contacts){
                lstContactPrincipal.add(new AV_LookupSearchResult(
                    acr.contactId,
                    AV_AppConstants.OBJECT_NAME_USER,
                    'standard:contact',
                    acr.Contact.Name,
                    acr.Contact.Account.Name
                    )
                );
            }
        }
        return lstContactPrincipal;

    }


    /**
    * @description		 	Get the ID's of the RT's requested by param
    * @param setRT			List of the RT
    */
    public static Set<Id> getIdsRT(Set<CIBE_AppUtilities.SearchRT> setRT){
		
        return CIBE_AppUtilities.getRecordTypeIdsInSet(setRT);
    }

    /**
     * Search in all fields Product2 that are AV_PF recordtype and has not Level and has an External id and are visible
     * @param String searchTerm 
     * @param List<String> ids to do not return search on the query
     * @return List<AV_LookupSearchResult>
     */
    @AuraEnabled
    public static List<AV_LookupSearchResult> searchProduct(String searchTerm, String recordId) {
        String methodName = 'searchProduct';
        Integer maxResults = 10;
        searchTerm += '*';
        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<List<SObject>> searchResults = new List<List<SObject>>();

        Set<String> pfEMP  = new Set<String>();
        
        Set<String> prod = new Set<String>();
        List<Opportunity> productOpp = [SELECT Id, AV_PF__c, AV_PF__r.Name, RecordType.DeveloperName  FROM Opportunity WHERE AccountId = :recordId AND RecordType.DeveloperName  LIKE 'CIBE_%'];

        if(!productOpp.isEmpty()){
            for (Opportunity product : productOpp) {
                prod.add(product.AV_PF__c);
            }
        }

        List<AV_ProductExperience__c> productosEMP = [SELECT Id, AV_ProductoFicha__c, AV_ProductoFicha__r.Name, AV_ExternalID__c  FROM AV_ProductExperience__c
                                                        WHERE AV_ExternalID__c  LIKE 'EMP%' AND  AV_ProductoFicha__r.AV_Nivel__c = null and AV_ProductoFicha__r.AV_ExternalID__c != null];

        if(!productosEMP.isEmpty()){
            for (AV_ProductExperience__c pEMP : productosEMP) {
                pfEMP.add(pEMP.AV_ProductoFicha__c);
            }
        }

        searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
            Product2(Id, Name, AV_ExternalID__c WHERE Id IN :pfEMP)
            LIMIT :maxResults
        ];

        String productIcon = 'standard:product';
        Product2[] listProduct = (List<Product2>) searchResults[0];
        for (Product2 p : listProduct) {
            results.add(
                new AV_LookupSearchResult(
                    p.Id,'Product2',productIcon,p.Name,'Codigo • ' + p.AV_ExternalID__c
                )
            );
        }
        results.sort();
        return results;
    }

    /**
     * It inserts on the database the event with the information specified on the lwc
     * @param String evt Pre-made Event object 
     * @return A string that its OK if the insert is succesfuls and a error message if is not succesful
     */
    @AuraEnabled
    public static Map<String,Object> createEvent(Event evt,String est) {
        String separador = '{|}';
        Savepoint sp = Database.setSavepoint();
        String methodName = 'createEvent';
        Map<String,Object> response = new Map<String,Object>();

        evt.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
        evt.RecordTypeId = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT,CIBE_AppConstants.EVENT_CLIENTE_RT).Id;
        evt.CSBD_Evento_Estado__c = est;
        List<CBK_Activity_Extension__c> lstCAEToInsert = new List<CBK_Activity_Extension__c>();
        CBK_Activity_Extension__c cae = new CBK_Activity_Extension__c();
            // cae.AV_CommentLastModifiedBy__c = employeeInfo; 
            cae.AV_CommentLastModifiedDate__c = System.now();
            cae.CIBE_ComentarioCita__c = evt.Description;
        evt.Description = '';

        Database.SaveResult sr = Database.insert(evt,false);

        if(sr.isSuccess()){
            Event newEvent = [SELECT Id, AV_Task__c, AV_Tipo__c, CreatedById, OwnerId, RecordTypeId, FinServ__NextSteps__c, WhatId, ActivityDate, IsRecurrence, IsRecurrence2, AV_ExternalID__c, Subject,
                            AV_BranchPhysicalMeet__c,Location, StartDateTime, EndDateTime, Description,isPrivate
                            FROM Event WHERE Id = :sr.getId()  LIMIT 1];
                            
            String newEventTaskHeader = newEvent.AV_Task__c;
            response.put('newEventIdWithHeader',(sr.getId()+separador+newEventTaskHeader));
            response.put('newEvent', newEvent);

            cae.AV_ActivityId__c = evt.Id;
            lstCAEToInsert.add(cae);

            Database.insert(lstCAEToInsert,false);
        }else{
            Database.Error err = sr.getErrors()[0];
            response.put('errorResult',('Fail-'+err.getMessage())); 
            AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());

            Database.rollback( sp );
        }
    
        return response;
    }

     //meter el contacto 
    @AuraEnabled
    public static List<String> createEventRelation2(String eventId,List<String> attendes, String contactoPrincipal){
        List<EventRelation> evtRelList = new List<EventRelation>();
        List<EventRelation> evnR = [SELECT Id FROM EventRelation WHERE RelationId = :contactoPrincipal AND EventId = :eventId ];
        String methodName = 'createEventRelation';
        List<String> result = new List<String>();

        if(attendes != null && !attendes.isEmpty()){
            for(String att : attendes){
                EventRelation evRel = new EventRelation();
                evRel.RelationId = att;
                evRel.EventId = eventId;
                evRel.isWhat = false;
                evRel.isParent = false;
                evRel.isInvitee = true;
                evtRelList.add(evRel);          
            }
        }

        if(!evnR.isEmpty()){
            for (EventRelation conP : evnR) {
                conP.isInvitee = true;
                evtRelList.add(conP); 
            }
        }else if(contactoPrincipal!=null && !contactoPrincipal.containsIgnoreCase('sinContacto')){
            EventRelation evRel = new EventRelation();
                evRel.RelationId = contactoPrincipal;
                evRel.EventId = eventId;
                evRel.isWhat = false;
                evRel.isParent = false;
                evRel.isInvitee = true;
                evtRelList.add(evRel);          
        }
        if(!evtRelList.isEmpty()){
            List<Database.UpsertResult> srList = Database.Upsert(evtRelList,false);
            updateAccessList(eventId);
            for(Database.UpsertResult sr : srList){
                if(!sr.isSuccess()){
                    if(!result.isEmpty()){
                        result.clear();
                    }
                    result.add('Fail');
                    for(Database.Error err : sr.getErrors()){
                        result.add(err.getMessage());
                        AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
                    }
                    break;
                }else{
                    result.add(sr.getId());
                }
            }
        }
        return result;
    }
    
    /**
	* @description		Videollamada Teams with RT Con Cliente
	* @param  listNews  list of new Event records
	*/
    @AuraEnabled
	public static void callApiTeams(Event evt, List<String> attendes, String contactoPrincipal){
		Map<String,User> mapUser = new Map<String,User>();
        if((setRtCliente).contains(evt.RecordTypeId) && evt.AV_Tipo__c == CIBE_AppConstants.VIDEOLLAMADA_TIPO) {
			List<User> listEmp  = new List<User>();
			if(
				Schema.SObjectType.User.fields.AV_ExternalID__c.isAccessible() &&
				Schema.SObjectType.User.fields.AV_AzureId__c.isAccessible() &&
				Schema.SObjectType.User.fields.FederationIdentifier.isAccessible()
			) {
				listEmp  = [SELECT Id, AV_ExternalID__c, AV_AzureId__c, FederationIdentifier FROM User WHERE Id = :evt.CreatedById LIMIT 1];
			}
			if (listEmp != null && !listEmp.isEmpty()) {
				for(User emp : listEmp) { 
					mapUser.put(emp.Id,emp);
				}
			}
            if (mapUser != null) {
                if( !String.Isblank(mapUser.get(evt.CreatedById)?.FederationIdentifier) ||
                    !String.Isblank(mapUser.get(evt.CreatedById)?.AV_AzureId__c) ){
                        String jsonString = JSON.serialize(evt);
                        if(!Test.isRunningTest()){
                            System.enqueueJob(new CIBE_TeamsGCFQueueable(jsonString, evt, mapUser.get(evt.CreatedById)?.FederationIdentifier , mapUser.get(evt.CreatedById)?.AV_AzureId__c, attendes, contactoPrincipal));
                        }
                }else{
                    createEventRelation2(evt.Id, attendes, contactoPrincipal);
                }
			}
		}else{
            createEventRelation2(evt.Id, attendes, contactoPrincipal);
        }
	}

    @AuraEnabled
    public static void updateAccessList(String recordId) {
        List<EventRelation> attendees = new List<EventRelation>();
        Event ev = new Event(); 
        if(
        Schema.SObjectType.EventRelation.fields.Id.isAccessible() &&
        Schema.SObjectType.EventRelation.fields.EventId.isAccessible() &&
        Schema.SObjectType.EventRelation.fields.RelationId.isAccessible() &&
        Schema.SObjectType.EventRelation.fields.IsInvitee.isAccessible()
        ) {
            attendees = [SELECT Id, EventId, RelationId, IsInvitee FROM EventRelation WHERE EventId = :recordId AND IsInvitee = true];
        }

        Set<String> userIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        for(EventRelation attende : attendees) {
            if(String.isNotBlank(attende.RelationId)) {
                if(((String)attende.RelationId).startsWith('005')) {
                    userIds.add(attende.RelationId);
                } else {
                    contactIds.add(attende.RelationId);
                }
            } 
        }

        List<Id> users = new List<Id>();
        if(Schema.SObjectType.User.fields.Id.isAccessible()) {
            for(User u : [SELECT Id FROM User WHERE Id IN :userIds]) {
                users.add(u.Id);
            }
        }
        
        if(Schema.SObjectType.Contact.fields.Id.isAccessible() &&
            Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible()) {
            for(Contact c : [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE Id IN :contactIds]) {
                if(String.isNotBlank(c.AV_UsuarioAsociado__c) && !users.contains(c.AV_UsuarioAsociado__c)) {
                    users.add(c.AV_UsuarioAsociado__c);
                }
            }
        }

        if(Schema.SObjectType.Event.fields.Id.isAccessible() &&
        Schema.SObjectType.Event.fields.OwnerId.isAccessible() &&
        Schema.SObjectType.Event.fields.AV_Task__c.isAccessible()) {
            List<String> access = new List<String>();
            for(Id userId : users) {
                if(!access.contains(userId)) {
                    access.add(userId);
                }
            }

            try {
                ev = [SELECT Id, OwnerId, AV_Task__c FROM Event WHERE Id = :recordId LIMIT 1];
			}catch(Exception e) {
				CBK_Log.error(e);
			}

            if(ev!=null && !access.contains(ev.OwnerId)) {
                access.add(ev.OwnerId);
            }

            if(ev!=null && String.isNotBlank(ev.AV_Task__c)) {
                List<AV_HeaderCustomActivity__c> header = new List<AV_HeaderCustomActivity__c>();
                if(Schema.SObjectType.AV_HeaderCustomActivity__c.fields.Id.isAccessible() &&
                    Schema.SObjectType.AV_HeaderCustomActivity__c.fields.CIBE_ConfidentialEvent__c.isAccessible()) {
                    header = [SELECT Id, CIBE_ConfidentialEvent__c FROM AV_HeaderCustomActivity__c WHERE Id = :ev.AV_Task__c];
                }

                if(!header.isEmpty() && ev != null) {
                    header.get(0).CIBE_ConfidentialEvent__c = String.join(access, ',');
                    update header;
                }
            }
        }
    }

    /**
     * Create and update the opportunities edited on the component. It deletes too the checkOnOff tasks related to the updated opportunities.
     * Deletes the AV_CustomActivityOpportunity__c records too
     * @param Map<String,Map<String,Object>> opposToInsertOrUpdate => Object that contains updated and inserted oppos
     * @param String accoundId Id from the event client that is being created
     * @CreatedOpportunitiesWrapper Wrapped response
     */

    @AuraEnabled
    public static CreatedOpportunitiesWrapper createOrUpdateOpportunities(Map<String,Map<String,Object>> opposToInsertOrUpdate,String accountId, String dateIni, Boolean agil){
        String methodName = 'createOrUpdateOpportunities';
        CreatedOpportunitiesWrapper response = new CreatedOpportunitiesWrapper();
        Savepoint sp = Database.setSavepoint();
        Id iniciativaRt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY,'CIBE_IniciativaEmpleadoEMP').Id;
        
        List<Map<String,Object>> wrappedOppsToInsert = new List<Map<String,Object>>();
        List<Opportunity> opposToInsert = new List<Opportunity>();      
        List<Opportunity> opposToUpdate = new List<Opportunity>();
        Map<String,String> tskToHeaderMap = new Map<String,String>();
        Map<String,Object> mapAux = new Map<String,Object>();
        String auxId;
        List<Map<String,Object>> editableOpps = new List<Map<String,Object>>();
        for(String objId : opposToInsertOrUpdate.keySet()){
            auxId = (String)opposToInsertOrUpdate.get(objId).get('id');
            if(auxId.contains('idProvisional') ){
                wrappedOppsToInsert.add(opposToInsertOrUpdate.get(objId));
            }else{
                // añadimos a la lista las oportunidades con Id
                editableOpps.add(opposToInsertOrUpdate.get(objId));
            }
        }

        if(!wrappedOppsToInsert.isEmpty()){
            opposToInsert = unWrappOppos(wrappedOppsToInsert,iniciativaRt,accountId, dateIni, agil);
        }
        if(!editableOpps.isEmpty()){
            // pasa la lista de editable con las oportunidades con Id
            opposToUpdate = unWrappOppos(editableOpps,iniciativaRt,accountId, dateIni, agil);
        }

        //Buscamos las tareas del checkonOff para borrarlas y guardarlas para el back
        Set<Id> relatedCaoId = new Set<Id>();
        Map<String,List<Id>> opportunityToHeaders = new Map<String,List<Id>>();

        if(!opposToInsert.isEmpty()){

            List<Database.SaveResult> srListInsert = Database.insert(opposToInsert,false);
            
            Integer indexOfWrap = 0;
            for(Database.SaveResult sr : srListInsert){
                if(sr.isSuccess()){
                    if(indexOfWrap < srListInsert.size()){
                        wrappedOppsToInsert[indexOfWrap++].put('id',sr.getId());
                    }
                }else{
                    response.errorList = new List<String>();
                    Database.rollback(sp);
                    for(Database.Error err : sr.getErrors()){
                        String errorStr =  'Error insert: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
                        response.errorList.add(errorStr);
                        AV_LogDebug.printLogDebug(methodName,errorStr);
                    }

                    return response;
                }
            }
        }
        
        if(!opposToUpdate.isEmpty()){
            // update opposToUpdate;
            CIBE_NewEventControllerWO.updateOpportunityWO(opposToUpdate);
        }
        response.editedOpportunities = opposToInsertOrUpdate;
        return response;
    }

    @AuraEnabled
    public static CreatedTasksWrapper createOrUpdateTasks(Map<String,Map<String,Object>> tasksToInsertOrUpdate,String accountId){
        String methodName = 'createOrUpdateTasks';
        CreatedTasksWrapper response = new CreatedTasksWrapper();
        Map<String, Database.SaveResult> mapTask = new Map<String, Database.SaveResult>();
        String header;

        Savepoint sp = Database.setSavepoint();

        Id iniciativaRt = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK ,CIBE_AppConstants.TASK_OTROS_EMP_RT).Id;
        
        List<Map<String,Object>> wrappedTasksToInsert = new List<Map<String,Object>>();
        List<Map<String,Object>> wrappedTasksToUpdate = new List<Map<String,Object>>();

        List<Task> tasksToInsert = new List<Task>();      
        List<Task> tasksToUpdate = new List<Task>();
        Map<String,Task> tasksUpdatedMap = new Map<String,Task>();
        Map<String,String> tskToHeaderMap = new Map<String,String>();
        
        List<Map<String,Object>> editableTask = new List<Map<String,Object>>();
        for(String objId : tasksToInsertOrUpdate.keySet()){
            if(objId.contains('idProvisional')){
                wrappedTasksToInsert.add(tasksToInsertOrUpdate.get(objId));
            }else{
                wrappedTasksToUpdate.add(tasksToInsertOrUpdate.get(objId));
                if( (Boolean) (tasksToInsertOrUpdate.get(objId).get('isEditable'))){
                    editableTask.add(tasksToInsertOrUpdate.get(objId));
                }
            }
        }

        if(!wrappedTasksToInsert.isEmpty()){
            tasksToInsert = unWrappTasks(wrappedTasksToInsert,iniciativaRt,accountId);
        }

        if(!editableTask.isEmpty()){
            tasksToUpdate = unWrappTasks(editableTask,iniciativaRt,accountId);
            for(Task task :  tasksToUpdate){
                tasksUpdatedMap.put(task.Id,task);
            }
        }

        //Buscamos las tareas del checkonOff para borrarlas y guardarlas para el back
        Set<Id> relatedRCId = new Set<Id>();
        Map<String,List<Id>> taskToHeaders = new Map<String,List<Id>>();

        if(!tasksToInsert.isEmpty()){
            for(Task task: tasksToInsert){
				task.recordTypeId = iniciativaRt;
            }
        
            List<Database.SaveResult> srListInsert = Database.insert(tasksToInsert,false);
            
            Integer indexOfWrap = 0;
            for(Database.SaveResult sr : srListInsert){
                if(sr.isSuccess()){
                    if(indexOfWrap < srListInsert.size()){
                        wrappedTasksToInsert[indexOfWrap++].put('id',sr.getId());
                        response.errorList = new List<String>();
                    }
                    mapTask.put(sr.getId(), sr);
                }else{
                    response.errorList = new List<String>();
                    Database.rollback(sp);
                    for(Database.Error err : sr.getErrors()){
                        String errorStr =  'Error insert: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields();
                        response.errorList.add(errorStr);
                        AV_LogDebug.printLogDebug(methodName,errorStr);
                    }
                    return response;
                }
            }

            Map<String, Task> tareaMap = new Map<String, Task>();
                
            for(Task tarea :[SELECT Id, AV_Task__c FROM  Task where Id = :mapTask.keySet()]){
                tareaMap.put(tarea.Id, tarea);
            }

            for (Id variable : tareaMap.keySet()) {
                for (Database.SaveResult sr : srListInsert) {
                    if(variable.equals(sr.getId())){
                        header = tareaMap.get(variable).AV_Task__c;
                    }
                }

                if(header != null){
                    for (Map<String,Object> wrappedInsert : wrappedTasksToInsert) {
                        if(variable.equals(wrappedInsert.get('id'))){
                            wrappedInsert.put('headerId', header);
                        }
                    }
                }
                
            }
        }

        if(!tasksToUpdate.isEmpty()){
            update tasksToUpdate;
        }
        response.editedTasks = tasksToInsertOrUpdate;
        return response;
            
    }

    /**
     * Delete the create event and the attendes events (The ones that come from EventRelationship records) if a backreport is needed
    @param List<String> recordsToDelete Id's of the record to delete
    @return Wheter Ok or message error if the delete is succesfull or not
    */

    @AuraEnabled
    public static String backupEventsAndAttendes(List<String> recordsToDelete,String jsonEventToBackReport,Id newRecordFromTaskToDel){

        String methodName = 'backupEventsAndAttendes';
        String result = 'OK';
        if(!recordsToDelete.isEmpty()){

            List<Database.DeleteResult> delRes = Database.delete(recordsToDelete,false);
            
            for(Database.DeleteResult dr : delRes){
            if(!dr.isSuccess()){
                for(Database.Error err : dr.getErrors()){
                    AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
                }

                return 'NOK';
                }   
            }
        }
    
        if(jsonEventToBackReport != null){
            Event evtToRestore= (Event) JSON.deserialize(jsonEventToBackReport,Event.Class);
            Database.SaveResult sru = Database.update(evtToRestore,false);
            if(!sru.isSuccess()){
                Database.Error err = sru.getErrors()[0];
                AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
                return 'NOK';
                }
            }

        if(newRecordFromTaskToDel != null){
            Database.DeleteResult  dr = Database.delete(newRecordFromTaskToDel);
            if(!dr.isSuccess()){
                Database.Error err = dr.getErrors()[0];
                AV_LogDebug.printLogDebug(methodName, 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
                return 'NOK';
                }
            }

        return result;
     }


    /** 
    * Private method that return wrapped opportunities to Opportunity record
    * @param oppoWrappedList 
    * @param accounItd
    */
    private static List<Opportunity> unWrappOppos(List<Map<String,Object>> oppoWrappedList,Id iniciativaRt,String accountId, String dateIni, Boolean agil){
        List<Opportunity> opposToInsert = new List<Opportunity>();
        for(Map<String,Object> wrappedOppo : oppoWrappedList){
            Opportunity nextOpp = new Opportunity();
            if( (((String) wrappedOppo.get('id')).contains('idProvisional'))){
                //nueva Opp con RT == iniciativaRt
                nextOpp.RecordTypeId = iniciativaRt;
            }else{
                nextOpp.Id =(Id) wrappedOppo.get('id');
            }
            nextOpp.StageName = (String) wrappedOppo.get('newPath');

            nextOpp.Name = (String) wrappedOppo.get('Name');
            if(wrappedOppo.get('ProdId')!=null){
                nextOpp.AV_PF__c = (String) wrappedOppo.get('ProdId');
            }

            nextOpp.AccountId = wrappedOppo.get('accountId')!=null ? (String)wrappedOppo.get('accountId') : accountId;
            nextOpp.AV_OrigenApp__c = '';
            nextOpp.CloseDate = (Date) parseDate( (String) wrappedOppo.get('fechaCierre'));

            String estado = (String) wrappedOppo.get('stageName');
            Date fechaProxGest = (Date) parseDate( (String) wrappedOppo.get('fechaProxGest'));
            Date fechaCierre = (Date) parseDate( (String) wrappedOppo.get('fechaCierre'));

            if(estado == CIBE_AppConstants.OPPORTUNITY_STATUS_VENCIDO){
                
                nextOpp.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO;
                String dt = dateIni.substring(0, 10);
                nextOpp.AV_FechaProximoRecordatorio__c = parseDate(dt);
                nextOpp.CloseDate =  parseDate(dt);            
            }

            if(nextOpp.StageName != CIBE_AppConstants.OPPORTUNITY_STATUS_CERRPOSI && nextOpp.StageName != CIBE_AppConstants.OPPORTUNITY_STATUS_CERRNEGA ){
                nextOpp.CloseDate = (Date) parseDate( (String) wrappedOppo.get('fechaCierre'));
            }

            if(agil == true){
                nextOpp.CIBE_Visto__c = 'SI';
            }
            
            if(fechaProxGest > fechaCierre){
                nextOpp.AV_FechaProximoRecordatorio__c = (Date) parseDate( (String) wrappedOppo.get('fechaCierre'));
            }else{
                nextOpp.AV_FechaProximoRecordatorio__c = (Date) parseDate( (String) wrappedOppo.get('fechaProxGest'));
            }
            
            if(wrappedOppo.get('agendado') != null){
                if((Boolean) wrappedOppo.get('agendado')){
                    nextOpp.AV_IncludeInPrioritizingCustomers__c = false;
                }else if(nextOpp.StageName == AV_AppConstants.OPP_STATUS_ENGESTION && !( (Boolean) wrappedOppo.get('agendado'))){
                    nextOpp.AV_IncludeInPrioritizingCustomers__c = true;
                }else{
                    nextOpp.AV_IncludeInPrioritizingCustomers__c = false;
                    
                }
            }else{
                nextOpp.AV_IncludeInPrioritizingCustomers__c = false;
            }

            if( (String) wrappedOppo.get('probabilidad') != null ){
                nextOpp.CIBE_ProbabilidadExito__c = (String) wrappedOppo.get('probabilidad');
            }

            if( (String) wrappedOppo.get('comentario') != ''){
                nextOpp.AV_Comentarios__c =  (String) wrappedOppo.get('comentario');
            }
            // if(wrappedOppo.get('divisa') != '' ){
            //     nextOpp.CIBE_Divisa__c = (String) wrappedOppo.get('divisa'); //Double.valueOf(wrappedOppo.get('divisa'));
            // }
            if( wrappedOppo.get('importe') != '')   {
                String importe = (String) wrappedOppo.get('importe');
                if(importe.contains('.')){
                    importe = importe.replace('.', '');
                }
                nextOpp.CIBE_AmountDivisa__c = Double.valueOf(importe); 
            }
            if( wrappedOppo.get('impactoBalance') != ''){
                nextOpp.CIBE_Impacto_Balance_Cierre_Anio__c = Double.valueOf(wrappedOppo.get('impactoBalance'));
            }
            if(wrappedOppo.get('impactoComisiones') != '') {
                nextOpp.CIBE_ComisionesDivisa__c = Double.valueOf(wrappedOppo.get('impactoComisiones'));
            }
            if(wrappedOppo.get('entidad') != '') {
                nextOpp.AV_Entidad__c = (String) wrappedOppo.get('entidad');
            }
            if(wrappedOppo.get('vencimiento') != null) {
                nextOpp.AV_FechaVencimiento__c = (Date) parseDate( (String) wrappedOppo.get('vencimiento'));
            }
            if(wrappedOppo.get('precio') != '') {
                nextOpp.CIBE_ImporteOtraEntidad__c = Double.valueOf(wrappedOppo.get('precio')); 
            } 
            if(wrappedOppo.get('margen') != '') {
                nextOpp.CIBE_Margen__c = Double.valueOf(wrappedOppo.get('margen')); 
            }
            if(wrappedOppo.get('confidencial') != null) {
                nextOpp.AV_ClienteConfidencial__c =  (Boolean) wrappedOppo.get('confidencial');
            }
            if(wrappedOppo.get('esg') != null) {
                nextOpp.CIBE_ESG__c = (Boolean) wrappedOppo.get('esg');
            }
            if((String) wrappedOppo.get('state') != null) {
                nextOpp.CIBE_CerradoNegativo__c = (String) wrappedOppo.get('state');
            }
            opposToInsert.add(nextOpp);
        }
        return opposToInsert;
    }

    /** 
    * Private method that return wrapped tasks to Task record
    * @param taskWrappedList 
    * @param accounItd
    */
    private static List<Task> unWrappTasks(List<Map<String,Object>> taskWrappedList,Id rt,String accountId){

        List<Task> taskToInsert = new List<Task>();
        
        for(Map<String,Object> wrappedTask : taskWrappedList){
            Task nextTask = new Task();
            nextTask.Status = (String) wrappedTask.get('status') == 'Pendiente' ? 'Open' : (String) wrappedTask.get('status');
            nextTask.Subject = (String) wrappedTask.get('subject');
            //nextTask.RecordTypeId = (String) wrappedTask.get('rt');
            nextTask.WhatId = (String) wrappedTask.get('accountId') != null ? (String) wrappedTask.get('accountId'): accountId;
            nextTask.ActivityDate = (Date) parseDate( (String) wrappedTask.get('tareaDate'));
            nextTask.AV_Tipo__c = (String) wrappedTask.get('tipo');
            if((String) wrappedTask.get('personaContacto') != null){
                nextTask.whoId = (String) wrappedTask.get('personaContacto');
            }
            
            if( !(((String) wrappedTask.get('id')).contains('idProvisional'))){
                nextTask.Id =(Id) wrappedTask.get('id');
                nextTask.RecordTypeId = rt; //(Id) wrappedTask.get('rt');
            }else{
                nextTask.RecordTypeId = rt;
            }
            if( (String) wrappedTask.get('comentario') != null  || (String) wrappedTask.get('comentario') != ''){
                nextTask.Description = (String) wrappedTask.get('comentario');
            }
            taskToInsert.add(nextTask);
        }

        return taskToInsert;
    }

    /**
     * Private method for convert a Date string that comes from javascript
    *to the one that Event fields need 
    @param String Date to parse
    @return Parsed Date
      */
    
    private static Date parseDate(String dateString){
        String[] dateToArray;
        Integer year,month,day;

        if(dateString!=null && dateString.contains('-')){
            dateToArray = dateString.split('-');
            year = Integer.valueOf(dateToArray[0]);
            month = Integer.valueOf(dateToArray[1]);
            day = Integer.valueOf(dateToArray[2]);
            return date.newInstance(year,month,day);
        }
        return null;
    }


    /**
      * Inner class that unites all the information needed for continue with the report when it comes to insert and update opportunities
      * editedOpportunities => Json that relate the id of the opportunity with another object that contains opportunity in field:value structure after being updated
      * errorList => List that contains the errors. Method will exit aftwr the first error and it will contains that transaction error messages
      * taskToRestoreBack => If they exist, it save a copy from the deleted checkOnOff tasks in order to restor them back if report fail later
      * caoToRestoreBack => Same as the tasks
      * taskOpposRelation => Map that relates the checkOnOff tasks external id with is AV_Task__c in order to re-build AV_CustomActivityOpportunity__c if a reportback is needed
      */

    public class CreatedOpportunitiesWrapper{
        @AuraEnabled
        public  Map<String,Map<String,Object>> editedOpportunities;
        @AuraEnabled
        public List<String> errorList;
        @AuraEnabled
        public List<Task> taskToRestoreBack = new List<Task>();
        @AuraEnabled
        public List<AV_CustomActivityOpportunity__c> caoToRestoreBack = new List<AV_CustomActivityOpportunity__c>();
        @AuraEnabled
        public Map<String,String> taskOpposRelation = new Map<String,String>();
        @AuraEnabled
        public Map<String,List<String>> checkOnOffOpposId = new Map<String,List<String>>();
        @AuraEnabled
        public BackCheckOnOff bckCOF = new BackCheckOnOff();//OBJECTO BACK PARA EL EL GUARDADO DESDE REPORTE DE EVENTOS, NO DEL ALTA. 
        }
    
    public class CreatedTasksWrapper{
        @AuraEnabled
        public  Map<String,Map<String,Object>> editedTasks;
        @AuraEnabled
        public List<String> errorList;
        @AuraEnabled
        public List<Task> taskToRestoreBack = new List<Task>();
        @AuraEnabled
        public List<CIBE_RelaccionadoCita__c> RCToRestoreBack = new List<CIBE_RelaccionadoCita__c>();
        @AuraEnabled
        public Map<String,String> taskOpposRelation = new Map<String,String>();
        @AuraEnabled
        public Map<String,List<String>> checkOnOffTasksId = new Map<String,List<String>>();
        @AuraEnabled
        public BackCheckOnOff bckCOF = new BackCheckOnOff();//OBJECTO BACK PARA EL EL GUARDADO DESDE REPORTE DE EVENTOS, NO DEL ALTA. 
    }
    // BackCheckOnOff Opportunities
    public class BackCheckOnOff{
        @AuraEnabled
        public List<String> createdIdsToDelete = new List<String>();//CHECK ON OFF CREADOS PARA BORRAR
        @AuraEnabled
        public List<String> createdCaosToDelete = new List<String>();//CAO DE LAS CHECK ON OFF PARA BORRAR
        @AuraEnabled
        public List<Task> updatedTasksToRestore = new List<Task>();//LISTA SIN UPDATEAR DE LAS TAREAS
        @AuraEnabled
        public List<Task> taskToRestoreBack = new List<Task>();//TAREAS A RESTAURAR
        @AuraEnabled
        public List<AV_CustomActivityOpportunity__c> caoToRestoreBack = new List<AV_CustomActivityOpportunity__c>();//CAOS A RESTAURAR
        @AuraEnabled
        public Map<String,String> taskOpposRelation = new Map<String,String>();//RELACIONES PARA RELACIONAR LAS CAOS CON LAS TAREAS
    }

    @AuraEnabled(cacheable=true)
    public static List<AV_LookupSearchResult> searchUserCXB(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';
        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<List<SObject>> searchResults = new List<List<SObject>>();
        String contactIcon = 'standard:contact';
        
        if(!selectedIds.isEmpty()){
            searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                RETURNING
                    Contact(Id, Name, CC_Matricula__c,CC_EmpleadoGestorId__c, Email WHERE Id NOT IN :selectedIds AND RecordType.DeveloperName = :CIBE_AppConstants.EMPLOYEE_RT)
                LIMIT :5
            ];
        }
        else{
            searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                RETURNING
                    Contact(Id, Name, CC_Matricula__c,CC_EmpleadoGestorId__c, Email WHERE RecordType.DeveloperName = :CIBE_AppConstants.EMPLOYEE_RT)
                LIMIT :5
            ];
        }
        
        Contact[] listContacts = (List<Contact>) searchResults[0];

        for (Contact c : listContacts) {
            results.add(
                new AV_LookupSearchResult(
                    c.Id,
                    'Contact',
                    contactIcon,
                    c.Name,
                    c.Email
                )
            );
        }
        results.sort();
        return results;
    }

    @AuraEnabled(cacheable=true)
    public static List<AV_LookupSearchResult> searchUserEMP(String searchTerm, List<String> selectedIds, String cliente) {
        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<List<SObject>> searchResults = new List<List<SObject>>();
        String contactIcon = 'standard:contact';
        List<Contact> cnt = new List<Contact>();
        List<AccountContactRelation> contacto = new List<AccountContactRelation>();
        if(!selectedIds.isEmpty()){
            // cnt = [SELECT Id, Name, CC_Matricula__c FROM Contact WHERE Id NOT IN :selectedIds AND RecordType.DeveloperName IN :recordTypeCIBE AND AccountId =:cliente ];
            contacto = [SELECT Id, ContactId, Contact.Name, Contact.FirstName, Contact.LastName, Contact.CC_Matricula__c, Contact.AccountId,Contact.Account.Name
            FROM AccountContactRelation 
            WHERE AccountId = :cliente AND Contact.RecordType.DeveloperName IN: recordTypeCIBE AND ContactId NOT IN :selectedIds];
        } else{

            // cnt = [SELECT Id, Name, CC_Matricula__c FROM Contact WHERE RecordType.DeveloperName IN :recordTypeCIBE AND AccountId =:cliente ];
            contacto = [SELECT Id, ContactId, Contact.Name, Contact.FirstName, Contact.LastName, Contact.CC_Matricula__c, Contact.AccountId,Contact.Account.Name
            FROM AccountContactRelation 
            WHERE AccountId = :cliente AND Contact.RecordType.DeveloperName IN: recordTypeCIBE ];
        }

        for (AccountContactRelation c : contacto) {
            if(c.Contact.Name.containsIgnoreCase(searchTerm)){
                results.add(
                    new AV_LookupSearchResult(
                        c.ContactId,
                        'Contact',
                        contactIcon,
                        c.Contact.Name,
                        c.Contact.Account.Name
                        // c.Contact.CC_Matricula__c != null  ? 'Matrícula • ' + c.Contact.CC_Matricula__c :  'Matrícula • '
                    )
                );
            }
        }
        results.sort();
        return results;
    }

    @AuraEnabled(cacheable=true)
    public static List<AV_LookupSearchResult> searchUserTeamCXB(String recordId) {
        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<List<SObject>> searchResults = new List<List<SObject>>();
        String contactIcon = 'standard:contact';
        Set<String> userId = new Set<String>();

        List<Contact> listResult = new  List<Contact>();
        List<AccountTeamMember> equipoCXB = [SELECT Id, UserId FROM AccountTeamMember WHERE AccountId = :recordId];

        if(!equipoCXB.isEmpty()){
            for (AccountTeamMember cxb : equipoCXB) {
                userId.add(cxb.UserId);
            }
        }

        if(
            Schema.SObjectType.Contact.fields.Id.isAccessible() &&
            Schema.SObjectType.Contact.fields.Name.isAccessible() &&
            Schema.SObjectType.Contact.fields.CC_Matricula__c.isAccessible() &&
            Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible()
            ) {
                listResult = [SELECT Id, Name, CC_Matricula__c  FROM Contact WHERE RecordType.DeveloperName = :CIBE_AppConstants.EMPLOYEE_RT AND AV_UsuarioAsociado__c IN :userId]; 
            }
            searchResults.add(listResult);

        Contact[] listContacts = (List<Contact>) searchResults[0];

        for (Contact c : listContacts) {
            results.add(
                new AV_LookupSearchResult(
                    c.Id,
                    'Contact',
                    contactIcon,
                    c.Name,
                    c.CC_Matricula__c != null  ? 'Matrícula • ' + c.CC_Matricula__c :  'Matrícula • '
                )
            );
        }
        results.sort();
        return results;
    }

    public static void updateEventWithURL(String eventId,List<String> attendes, String contactoPrincipal, String joinUrl){
        if(!String.IsBlank(joinUrl) &&!String.IsBlank(eventId) && eventId!=null){
            Event upEvt = [SELECT Id, Description FROM Event WHERE Id=:eventId LIMIT 1];
            String comentario = 'Enlace a la reunión de Teams: ';
            upEvt.Id = eventId;
            if(String.IsBlank(upEvt.Description) || (upEvt.Description!=null && !upEvt.Description.containsIgnoreCase(comentario))){
                comentario += joinUrl; 
                comentario = String.IsBlank(upEvt.Description) ? comentario : upEvt.Description+'. '+comentario;
                upEvt.Description = comentario;
                Update upEvt;
            }else if(upEvt.Description!=null && upEvt.Description.containsIgnoreCase(comentario)){
                String cambioURL = upEvt.Description.substringAfter(comentario);
                upEvt.Description = upEvt.Description.replace(cambioURL,joinUrl);
                Update upEvt;
            }
        }
        createEventRelation2(eventId, attendes, contactoPrincipal);
    }

    @AuraEnabled
    public static List<Opportunity> getOpp(String recordId){
        List<Opportunity> opp = new List<Opportunity>();
        if(recordId != null){
            opp = [SELECT Id, CIBE_Margen__c, CIBE_ImporteOtraEntidad__c, AV_FechaVencimiento__c, CIBE_ESG__c, AV_ClienteConfidencial__c, Name, CloseDate, StageName, AccountId, OwnerId, CIBE_AmountDivisa__c, AV_FechaProximoRecordatorio__c, CIBE_Divisa__c, CIBE_Impacto_Balance_Cierre_Anio__c, AV_Comentarios__c, CIBE_ComisionesDivisa__c FROM Opportunity WHERE Id = :recordId];
        }

        return opp;
    }

    @AuraEnabled(cacheable=true)
    public static List<AV_LookupSearchResult> getGrupoComercial( String recordId) {
        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<FinServ__AccountAccountRelation__c> relationGC = new List<FinServ__AccountAccountRelation__c>();
        List<FinServ__AccountAccountRelation__c> relationsClients = new List<FinServ__AccountAccountRelation__c>();
        String accIcon = 'standard:account';
        String acc = 'Account';
        
        if(!String.IsBlank(recordId)){
            relationGC =     [SELECT Id, FinServ__Account__c, FinServ__Account__r.name, FinServ__RelatedAccount__c, FinServ__RelatedAccount__r.Name
                            FROM FinServ__AccountAccountRelation__c 
                            WHERE FinServ__Role__r.Name = 'Child'
                            AND FinServ__RelatedAccount__c != null
                            AND FinServ__Account__c = :recordId
                            AND FinServ__RelatedAccount__r.RecordType.DeveloperName = 'CIBE_GrupoComercial'
                            AND AV_ToDelete__c = false
                            LIMIT 1];

            if(!relationGC.isEmpty() && relationGC[0].FinServ__RelatedAccount__c!=null){
                String aux = relationGC[0].FinServ__RelatedAccount__c;

                relationsClients =     [SELECT Id, FinServ__Account__c, FinServ__Account__r.name, FinServ__RelatedAccount__c, FinServ__RelatedAccount__r.Name
                                        FROM FinServ__AccountAccountRelation__c 
                                        WHERE FinServ__Role__r.Name = 'Parent'
                                        AND FinServ__Account__c =:aux
                                        AND RecordType.DeveloperName = 'CIBE_GrupoComercial'
                                        AND FinServ__RelatedAccount__c != null
                                        AND AV_ToDelete__c = false];
            }
        }
        
        for (FinServ__AccountAccountRelation__c rc : relationsClients) {
            String identify = String.isNotBlank(rc.Id) ?  rc.Id : null;
            String identifyCl = String.isNotBlank(rc.FinServ__RelatedAccount__c) ? '/'+ rc.FinServ__RelatedAccount__c : null;
            if(rc.FinServ__RelatedAccount__c != recordId ){
                results.add(new AV_LookupSearchResult(identify, acc, identifyCl, rc.FinServ__Account__r.name, rc.FinServ__RelatedAccount__r.Name));

            }
        }

        results.sort();
        return results;
    }

    /**
	 * @description		 Sync Events via cita previa API
	 * @param   listNews    list of new Event records
	 * @param   listOlds    list of old event records
	 */
	@AuraEnabled
	public static void syncEvents(Event newEvent){
        CIBE_AppUtilities.SearchRT rtCliente 	= new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
        CIBE_AppUtilities.SearchRT rtGestor	    = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_GESTOR_RT);
        CIBE_AppUtilities.SearchRT rtClienteCIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT,CIBE_AppConstants.EVENT_CLIENTE_CIB_RT);
        CIBE_AppUtilities.SearchRT rtGestorCIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT,CIBE_AppConstants.EVENT_GESTOR_CIB_RT);

        Set<Id> setRtGestorAll 	= getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtGestor, rtGestorCIB});
        Set<Id> setRtClienteAll 	= getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtClienteCIB, rtCliente});
		
		String methodName = 'syncEvents';
		List<Event> eventsToProcess = new List<Event>();
		
		Boolean hasBulkApi = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		if(!hasBulkApi && !System.isFuture() && !System.isBatch() && !System.isQueueable()){
			//Check the new data
            boolean isRtGestorNoOutlook = (setRtGestorAll).contains(newEvent.RecordTypeId) && (!newEvent.IsRecurrence && !newEvent.IsRecurrence2); 
            boolean isRtClienteNoOutlook = (setRtClienteAll).contains(newEvent.RecordTypeId) && newEvent.AV_Tipo__c != CIBE_AppConstants.VIDEOLLAMADA_TIPO;

            if(isRtGestorNoOutlook || isRtClienteNoOutlook){
                eventsToProcess.add(newEvent);
            }
        }

			if(eventsToProcess!=null && !eventsToProcess.isEmpty()){
				String jsonString = json.serialize(eventsToProcess);
                if(!Test.isRunningTest()){
					CIBE_CitaPrevia_SyncEvents.insertOrUpdateEvent(jsonString, false);
                }
			}
		}

    /**
     * @description     Updates the event adding the GC.
     * @param evento        Event about to be update
     * @param gruposComerciales   gruposComerciales added when the event was managed
     */
    @AuraEnabled
    public static void updateEventGC(String evento, String gruposComerciales) {
        String methodName = 'updateEventGC';
        gruposComerciales = string.isBlank(gruposComerciales) || gruposComerciales == null ? '' : gruposComerciales;
        if(evento!=null && Schema.sObjectType.Event.isUpdateable()){

            Event evt = new Event();
            evt.Id = evento;
            evt.FinServ__NextSteps__c = gruposComerciales;

            Database.SaveResult updateEvent = Database.update(evt, false);
            boolean hasError = false;
            List<Object> objs = new List<Object>();
            Map<String, String> msjs = new Map<String, String>();
                
            if(!updateEvent.isSuccess() && !updateEvent.getErrors().isEmpty()) {
                msjs.put(evento, ((String)updateEvent.getErrors()[0].getMessage()));
                objs.add(evento);
                hasError = true;
            }
            
            if(hasError) {
                CBK_Log.error(msjs, objs);
            }
        }
    }

    @AuraEnabled
    public static void processAsistentes (Event evt, List<Map<String,Object>> asistentes, String contactoPrincipal){
        List<Contact> asistentesSinRegistrar = new List<Contact>();
        List<Contact> asistentesReg = new List<Contact>();
        Set<String> sinRegistrarEnviarCorreo = new Set<String>();
        List<String> attendes = new List<String>();
        
        Id taskId = [SELECT AV_Task__c FROM Event where id =:evt.Id ][0].AV_Task__c;
        
        for(Map<String,Object> cont: asistentes){
            if((((String) cont.get('id')).contains('Idprovisional'))){
                Contact cntToInsert = new Contact();
                cntToInsert.email = (String) cont.get('email');
                cntToInsert.lastname = (String) cont.get('email');
                cntToInsert.CIBE_AsistenteNoRegistrado__c = true;
                asistentesSinRegistrar.add(cntToInsert);
                sinRegistrarEnviarCorreo.add((String) cont.get('email'));
            }
            else if(cont.get('id') != null && (((String) cont.get('id')).contains('003'))){
                attendes.add((String) cont.get('id'));
            }
        }
        
        if(!asistentesSinRegistrar.isEmpty()){
            insert asistentesSinRegistrar;
                        
            for(Contact cont :asistentesSinRegistrar){
                if(sinRegistrarEnviarCorreo.contains(cont.email)){
                    attendes.add(cont.Id);
                }
            }
        }
        callApiTeams(evt, attendes, contactoPrincipal);
    }  
}