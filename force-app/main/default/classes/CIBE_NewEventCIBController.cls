/**********************************************************************************************************************
 Name:      CIBE_NewEventController
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora para el componente 7
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY       AUTHOR           DATE                Description
    1.0                     
***********************************************************************************************************************/
public without sharing class CIBE_NewEventCIBController {

    private static List<String> recordTypeCIBE = new List<String>{CIBE_AppConstants.CONTACT_APODERADO_RT, CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT};
    private static CIBE_AppUtilities.SearchRT rtCliente 	= new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
    private static CIBE_AppUtilities.SearchRT rtClienteCIB 	= new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_CIB_RT);
    private static Set<Id> setRtCliente		= getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtCliente,rtClienteCIB});
    
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

        if(Contact.SObjectType.getDescribe().isAccessible()
        && Schema.SObjectType.Contact.fields.Id.isAccessible()
        && Schema.SObjectType.Contact.fields.Name.isAccessible()){
            contactosApoderados = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName = :CIBE_AppConstants.CONTACT_APODERADO_RT AND AccountId = :accountId];
        }

        return contactosApoderados;
    }
    
    /**
    * @description		 	Get the ID's of the RT's requested by param
    * @param setRT			List of the RT
    */
    public static Set<Id> getIdsRT(Set<CIBE_AppUtilities.SearchRT> setRT){
		
        return CIBE_AppUtilities.getRecordTypeIdsInSet(setRT);
    }

   

    /**
     * It inserts on the database the event with the information specified on the lwc
     * @param String evt Pre-made Event object 
     * @return A string that its OK if the insert is succesfuls and a error message if is not succesful
     */
    @AuraEnabled
    public static Map<String,Object> createEvent(Event evt) {
        String separador = '{|}';
        Savepoint sp = Database.setSavepoint();
        String methodName = 'createEvent';
        String subjectLabel = System.Label.CIBE_reunionTeamCBK;

        Map<String,Object> response = new Map<String,Object>();
        evt.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
        evt.RecordTypeId = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT,CIBE_AppConstants.EVENT_CLIENTE_CIB_RT).Id;
        if(evt.StartDateTime < System.now()){
            evt.CSBD_Evento_Estado__c = 'Realizada';

        }else{
            evt.CSBD_Evento_Estado__c = 'Planificada';

        }

        Account accRecord = [SELECT Name FROM Account WHERE Id = :evt.WhatId WITH SECURITY_ENFORCED LIMIT 1];
        String accountName = accRecord.Name.trim();
        String evtSubject = subjectLabel.replace('{0}', accountName);
        evt.Subject = evtSubject;
        
        Database.SaveResult sr = Database.insert(evt,false);

        if(sr.isSuccess()){
            Event newEvent = [SELECT Id, AV_Task__c, AV_Tipo__c, OwnerId, Description, RecordTypeId FROM Event WHERE Id = :sr.getId() WITH SECURITY_ENFORCED LIMIT 1];
            String newEventTaskHeader = newEvent.AV_Task__c;
            response.put('newEventIdWithHeader',(sr.getId()+separador+newEventTaskHeader));
            response.put('newEvent', newEvent);
            CBK_Activity_Extension__c actExt = [select id,  CIBE_ComentarioCita__c from CBK_Activity_Extension__c WHERE AV_ActivityId__c = :newEvent.Id];
            actExt.CIBE_ComentarioCita__c = newEvent.Description;
            update actExt;
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
        }

        // if(!evtRelList.isEmpty()){
        //     Database.upsert(evtRelList,false);
        // }

        if(!evtRelList.isEmpty()){
            List<Database.SaveResult> srList = Database.insert(evtRelList,false);

            updateAccessList(eventId);
        

            for(Database.SaveResult sr : srList){
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
				User.SObjectType.getDescribe().isAccessible() &&
				Schema.SObjectType.User.fields.AV_ExternalID__c.isAccessible() &&
				Schema.SObjectType.User.fields.AV_AzureId__c.isAccessible() &&
				Schema.SObjectType.User.fields.FederationIdentifier.isAccessible()
			) {
				listEmp  = [SELECT Id, AV_ExternalID__c, AV_AzureId__c, FederationIdentifier FROM User WHERE Id = :evt.OwnerId LIMIT 1];
			}
			if (listEmp != null && !listEmp.isEmpty()) {
				for(User emp : listEmp) { 
					mapUser.put(emp.Id,emp);
				}
			}
            if (mapUser != null) {
                if( !String.Isblank(mapUser.get(evt.OwnerId)?.FederationIdentifier) ||
                    !String.Isblank(mapUser.get(evt.OwnerId)?.AV_AzureId__c) ){
                        String jsonString = JSON.serialize(evt);
                        if(!Test.isRunningTest()){
                            AsyncOptions options = new AsyncOptions();
                            options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                                            .addId(UserInfo.getUserId())
                                                            .addString('GCF')
                                                            .build();
                            try {
                                System.enqueueJob(new CIBE_TeamsGCFQueueable(jsonString, evt, mapUser.get(evt.OwnerId)?.FederationIdentifier , mapUser.get(evt.OwnerId)?.AV_AzureId__c, attendes, contactoPrincipal), options);
                            } catch (DuplicateMessageException  e) {
                                //Exception is thrown if there is already an enqueued job with the same signature
                                CBK_Log.error(e);
                            }
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
         if(EventRelation.SObjectType.getDescribe().isAccessible()) {
             attendees = [SELECT Id, EventId, RelationId, IsInvitee, Event.AV_Tipo__c FROM EventRelation WHERE EventId = :recordId AND IsInvitee = true];
         }
 
         System.debug(attendees);
 
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
         if(User.SObjectType.getDescribe().isAccessible()) {
             for(User u : [SELECT Id FROM User WHERE Id IN :userIds]) {
                 users.add(u.Id);
             }
         }
         
         if(Contact.SObjectType.getDescribe().isAccessible()) {
             for(Contact c : [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE Id IN :contactIds]) {
                 if(String.isNotBlank(c.AV_UsuarioAsociado__c) && !users.contains(c.AV_UsuarioAsociado__c)) {
                     users.add(c.AV_UsuarioAsociado__c);
                 }
             }
         }
 
         if(Event.SObjectType.getDescribe().isAccessible()) {
             List<String> access = new List<String>();
             for(Id userId : users) {
                 if(!access.contains(userId)) {
                     access.add(userId);
                 }
             }
 
             Event ev = [SELECT Id, OwnerId, AV_Task__c FROM Event WHERE Id = :recordId LIMIT 1];
             if(!access.contains(ev.OwnerId)) {
                 access.add(ev.OwnerId);
             }
 
             if(String.isNotBlank(ev.AV_Task__c)) {
                 List<AV_HeaderCustomActivity__c> header = new List<AV_HeaderCustomActivity__c>();
                 if(AV_HeaderCustomActivity__c.SObjectType.getDescribe().isAccessible()) {
                     header = [SELECT Id, CIBE_ConfidentialEvent__c FROM AV_HeaderCustomActivity__c WHERE Id = :ev.AV_Task__c];
                 }
 
                 if(!header.isEmpty() && ev != null) {
                     header.get(0).CIBE_ConfidentialEvent__c = String.join(access, ',');
                     update header;
                     update ev;
                     
                 }
             }
         }
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
                    Contact(Id, Name, CC_Matricula__c,CC_EmpleadoGestorId__c,Email WHERE RecordType.DeveloperName = :CIBE_AppConstants.EMPLOYEE_RT)
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
    public static List<AV_LookupSearchResult> searchUserClientes(String searchTerm, List<String> selectedIds, String recordId) {
        String methodName = 'searchUserClientes';
		String escrito = searchTerm;
		searchTerm = '*'+searchTerm+'*';
		String userIcon = 'standard:contact';

		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		Set<String> setRecTypDevName = new Set<String>{'CIBE_ContactoComercial','CIBE_Apoderado'};
        Set<String> contactId = new Set<String>();

        List<AccountContactRelation > contacts = [SELECT Id, ContactId, Contact.FirstName, Contact.LastName FROM AccountContactRelation WHERE AccountId = :recordId ];

        if(!contacts.isEmpty()){
            for (AccountContactRelation c : contacts) {
                contactId.add(c.ContactId);
            }
        }                

		if(!selectedIds.isEmpty()){
			List<Contact> searchResultsContact = [SELECT Id, Name, FirstName, LastName, Email 
                                                  FROM Contact WHERE Id IN : contactId AND RecordType.DeveloperName IN : setRecTypDevName AND Id NOT IN :selectedIds];		
				for (Contact cont : searchResultsContact) {
                    if(cont.Name.containsIgnoreCase(escrito)){
                        results.add(new AV_LookupSearchResult(cont.Id,'Contact',userIcon,cont.Name,cont.Email));
                    }
				}
		}else{
			List<Contact> searchResultsContact = [SELECT Id, Name, FirstName, LastName, Email 
                                                  FROM Contact WHERE Id IN : contactId AND RecordType.DeveloperName IN : setRecTypDevName ];
			for(Contact cont: searchResultsContact){
				if(cont.Name.containsIgnoreCase(escrito)){
					results.add(new AV_LookupSearchResult(cont.Id,'Contact',userIcon,cont.Name,cont.Email));
				}
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

        System.debug(equipoCXB);

        if(!equipoCXB.isEmpty()){
            for (AccountTeamMember cxb : equipoCXB) {
                userId.add(cxb.UserId);
            }
        }

        if(
            Contact.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.Contact.fields.Id.isAccessible() &&
            Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible()
            ) {
                
                listResult = [SELECT Id, Name, CC_Matricula__c  FROM Contact WHERE RecordType.DeveloperName = :CIBE_AppConstants.EMPLOYEE_RT AND AV_UsuarioAsociado__c IN :userId];
                
            }
            searchResults.add(listResult);


        Contact[] listContacts = (List<Contact>) searchResults[0];

        System.debug(listContacts);

        for (Contact c : listContacts) {
            results.add(
                new AV_LookupSearchResult(
                    c.Id,
                    'Contact',
                    contactIcon,
                    c.Name,
                    'Matrícula • ' + c.CC_Matricula__c
                )
            );
        }
        results.sort();
        return results;
    }

 
    
    @AuraEnabled
    public static void processAsistentes (Event evt, List<Map<String,Object>> asistentes, String contactoPrincipal){
        System.debug('@@ evt ' + evt);
        System.debug('@@ asistentes ' + asistentes);
        System.debug('@@ contactoPrincipal ' + contactoPrincipal);

        List<Contact> asistentesSinRegistrar = new List<Contact>();
        List<Contact> asistentesReg = new List<Contact>();
        Set<String> sinRegistrarEnviarCorreo = new Set<String>();
        List<String> attendes = new List<String>();
        List<CIBE_RelaccionadoCita__c> junctionEventList = new List<CIBE_RelaccionadoCita__c>();
        
        Id taskId = [SELECT AV_Task__c FROM Event where id =:evt.Id ][0].AV_Task__c;
        
        for(Map<String,Object> cont: asistentes){
            CIBE_RelaccionadoCita__c junctionEvent = new CIBE_RelaccionadoCita__c();
            if((((String) cont.get('id')).contains('Idprovisional'))){
                System.debug('@@ 1 ' + (String) cont.get('email') );

                Contact cntToInsert = new Contact();
                cntToInsert.email = (String) cont.get('email');
                cntToInsert.lastname = (String) cont.get('email');
                cntToInsert.CIBE_AsistenteNoRegistrado__c = true;
                System.debug('@@ cntToInsert: ' +cntToInsert );
                
                asistentesSinRegistrar.add(cntToInsert);
                System.debug('@@ asistentesSinRegistrar: ' +asistentesSinRegistrar );
                if(cont.containsKey('enviarCita') && (Boolean) cont.get('enviarCita')){
                    sinRegistrarEnviarCorreo.add((String) cont.get('email'));
                }
            }else if(cont.get('id') != null && cont.get('tipoAsistente') == 'Cliente'){
                System.debug('@@ 2 ' );

                junctionEvent.CIBE_CitaRelaccionada__c = taskId;
                junctionEvent.CIBE_Contacto__c = (String) cont.get('id');
                junctionEvent.CIBE_TipoAsistente__c = 'Asistentes clientes';
                junctionEventList.add(junctionEvent);
                
                if(cont.get('enviarCita') == true){
                    attendes.add((String) cont.get('id'));
                }
                
                
            }else if(cont.get('id') != null && cont.get('tipoAsistente') == 'CaixaBank'){
                System.debug('@@ 3 ' );

                junctionEvent.CIBE_CitaRelaccionada__c = taskId;
                junctionEvent.CIBE_Contacto__c = (String) cont.get('id') ;
                junctionEvent.CIBE_TipoAsistente__c = 'Asistentes CaixaBank';
                junctionEventList.add(junctionEvent);
                
                
                if(cont.get('enviarCita') == true){
                    attendes.add((String) cont.get('id'));
                }
            }
        }
        System.debug('@@ asistentesSinRegistrar: ' +asistentesSinRegistrar );
        
        if(!asistentesSinRegistrar.isEmpty()){
            insert asistentesSinRegistrar;
                        
            for(Contact cont :asistentesSinRegistrar){
                CIBE_RelaccionadoCita__c junctionEvent = new CIBE_RelaccionadoCita__c();
                junctionEvent.CIBE_CitaRelaccionada__c = taskId;
                junctionEvent.CIBE_Contacto__c = (String) cont.get('id') ;
                junctionEvent.CIBE_TipoAsistente__c = 'Asistentes sin registrar';
                junctionEvent.CIBE_Email__c = (String) cont.get('email');
                junctionEventList.add(junctionEvent);
                
                
                if(sinRegistrarEnviarCorreo.contains(cont.email)){
                    attendes.add(cont.Id);
                }
            }
        }
    
        if(!junctionEventList.isEmpty()){
            insert junctionEventList;
        }
        
        //if(!attendes.isEmpty()){
            callApiTeams(evt, attendes,  contactoPrincipal);
        //}
    }  
    
    public class ContactWrapper{
        @AuraEnabled 
        public String id;
        @AuraEnabled 
        public String name;
        @AuraEnabled 
        public String email;
        @AuraEnabled 
        public String tipoAsistente;
        @AuraEnabled 
        public Boolean enviarCita;
    
    }
    
    
    /** 
    * Private method that return wrapped opportunities to Opportunity record
    * @param oppoWrappedList 
    * @param accounItd
    * takedProducts <Id product, Comment>
    */
    @AuraEnabled
     public static void createProductCIB(List<Map<String,Object>> takedProducts, Event evt){
         Id taskId = [SELECT AV_Task__c FROM Event where id =:evt.Id ][0].AV_Task__c;
         List<CIBE_RelaccionadoCita__c> junctionEventList = new List<CIBE_RelaccionadoCita__c>();
         for(Map<String, Object> prodId: takedProducts){
             CIBE_RelaccionadoCita__c junctionEvent = new CIBE_RelaccionadoCita__c();
             junctionEvent.CIBE_CitaRelaccionada__c = taskId;
             junctionEvent.CIBE_Producto__c = (String) prodId.get('idProducto');
             junctionEvent.CIBE_Comentario__c = (String) prodId.get('comentario');
             junctionEventList.add(junctionEvent);
         }
    
         if(!junctionEventList.isEmpty()){
             insert junctionEventList;
         }
         
     }



     @AuraEnabled(cacheable=true) 
     public static List<OptionsField> getRegardingPicklistValue() {
         List<OptionsField> selectOptions = new List<OptionsField>();
 
         Schema.DescribeFieldResult objFieldDescribe = Event.FinServ__Regarding__c.getDescribe();
         List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
 
         for (Schema.PicklistEntry objPickList : lstPickListValues) {
             OptionsField opField= new OptionsField();
             opField.value=objPickList.getValue();
             opField.label=objPickList.getLabel();
             selectOptions.add(opField);
         }
         return selectOptions;
     }

     public class OptionsField {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }


    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountSinCliente(){
        List<Account> sinCliente = [SELECT Id, Name FROM Account WHERE Name = 'Sin Cliente'];

        return sinCliente;
    }


}