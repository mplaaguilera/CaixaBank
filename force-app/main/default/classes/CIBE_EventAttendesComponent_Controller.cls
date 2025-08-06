public with sharing class CIBE_EventAttendesComponent_Controller {

    private static List<String> recordTypeCIBE = new List<String>{CIBE_AppConstants.CONTACT_APODERADO_RT, CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT};



    @AuraEnabled(cacheable=true)
    public static List<Event> getEvent(String recordId){
        
        List<Event> evnt = [SELECT Id, AV_Tipo__c, AccountId FROM Event WHERE Id = :recordId];

        return evnt;
    }

	@AuraEnabled(cacheable=true)
    public static List<AttendeeWrapper> returnAttendeesCaixabank(String recordId) {
        Event evt = [SELECT Id, AV_Task__c FROM Event WHERE Id = :recordId];
        List<AttendeeWrapper> response = new List<AttendeeWrapper>();
        if(String.isNotBlank(evt.AV_Task__c)) {
            List<CIBE_RelaccionadoCita__c> evtExtension = [SELECT id, CIBE_CitaRelaccionada__c,CIBE_Contacto__c,
                                                           CIBE_Contacto__r.name, CIBE_Contacto__r.Account.name,
                                                            CIBE_Contacto__r.AV_DescFuncion__c
                                                           FROM CIBE_RelaccionadoCita__c
                                                           WHERE CIBE_CitaRelaccionada__c = :evt.AV_Task__c AND CIBE_TipoAsistente__c = 'Asistentes Caixabank'];
            Set<String> contactIds = new Set<String>();
            for(CIBE_RelaccionadoCita__c evtExt: evtExtension){
                contactIds.add(evtExt.CIBE_Contacto__c);
            }
                       
            List<EventRelation> attendees = [SELECT Id, EventId, Event.AV_Task__c, RelationId, Status, IsInvitee 
                                             FROM EventRelation WHERE EventId = :evt.id AND RelationId = :contactIds];
            Map<String, EventRelation> eventRelationMap = new Map<String, EventRelation>();
            for(EventRelation att: attendees){
                eventRelationMap.put(att.RelationId, att);
            }

            
            if(!evtExtension.isEmpty()){
                response = fillAttendeeWrapper(eventRelationMap, evtExtension, 'Asistentes Caixabank');
            }

        }

        return response;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AttendeeWrapper> returnAttendeesCliente(String recordId) {
        Event evt = [SELECT Id, AV_Task__c FROM Event WHERE Id = :recordId];
        List<AttendeeWrapper> response = new List<AttendeeWrapper>();
        if(String.isNotBlank(evt.AV_Task__c)) {
            List<CIBE_RelaccionadoCita__c> evtExtension = [SELECT id, CIBE_CitaRelaccionada__c,CIBE_Contacto__c, CIBE_Contacto__r.name,
                                                           CIBE_Contacto__r.firstname, CIBE_Contacto__r.lastname, CIBE_Contacto__r.CIBE_Cargo__c,
                                                           CIBE_Contacto__r.CC_Idioma__c, CIBE_Contacto__r.email,CIBE_Contacto__r.phone,
                                                           CIBE_Contacto__r.CIBE_Confidencial__c, CIBE_Email__c
                                                           FROM CIBE_RelaccionadoCita__c
                                                           WHERE CIBE_CitaRelaccionada__c = :evt.AV_Task__c AND CIBE_TipoAsistente__c = 'Asistentes clientes'];
            Set<String> contactIds = new Set<String>();
            for(CIBE_RelaccionadoCita__c evtExt: evtExtension){
                contactIds.add(evtExt.CIBE_Contacto__c);
            }

            
            List<EventRelation> attendees = [SELECT Id, EventId, Event.AV_Task__c, RelationId, Status, IsInvitee 
                                             FROM EventRelation WHERE EventId = :evt.id AND RelationId =:contactIds];
            Map<String, EventRelation> eventRelationMap = new Map<String, EventRelation>();
            for(EventRelation att: attendees){
                eventRelationMap.put(att.RelationId, att);
            }

            
            if(!evtExtension.isEmpty()){
                response = fillAttendeeWrapper(eventRelationMap, evtExtension, 'Asistentes clientes');
            }
        }
        return response;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<AttendeeWrapper> returnAttendeesSinRegistrar(String recordId) {
        Event evt = [SELECT Id, AV_Task__c FROM Event WHERE Id = :recordId];
        List<AttendeeWrapper> response = new List<AttendeeWrapper>();
        if(String.isNotBlank(evt.AV_Task__c)) {
            List<CIBE_RelaccionadoCita__c> evtExtension = [SELECT id, CIBE_CitaRelaccionada__c,CIBE_Contacto__c, CIBE_Contacto__r.name,
                                                           CIBE_Contacto__r.firstname, CIBE_Contacto__r.lastname, CIBE_Contacto__r.CIBE_Cargo__c,
                                                           CIBE_Contacto__r.CC_Idioma__c, CIBE_Contacto__r.email,CIBE_Contacto__r.phone,
                                                           CIBE_Contacto__r.CIBE_Confidencial__c, CIBE_Email__c
                                                           FROM CIBE_RelaccionadoCita__c
                                                           WHERE CIBE_CitaRelaccionada__c = :evt.AV_Task__c AND CIBE_TipoAsistente__c = 'Asistentes sin registrar'];
            Set<String> contactIds = new Set<String>();
            for(CIBE_RelaccionadoCita__c evtExt: evtExtension){
                contactIds.add(evtExt.CIBE_Contacto__c);
            }

            
            List<EventRelation> attendees = [SELECT Id, EventId, Event.AV_Task__c, RelationId, Status, IsInvitee 
                                             FROM EventRelation WHERE EventId = :evt.id AND RelationId =:contactIds];
            Map<String, EventRelation> eventRelationMap = new Map<String, EventRelation>();
            for(EventRelation att: attendees){
                eventRelationMap.put(att.RelationId, att);
            }

            
            if(!evtExtension.isEmpty()){
                response = fillAttendeeWrapper(eventRelationMap, evtExtension, 'Asistentes sin registrar');
            }
        }
        return response;
    }

    public static List<AttendeeWrapper> fillAttendeeWrapper(Map<String, EventRelation> eventRelMap, List<CIBE_RelaccionadoCita__c>  relCitaList, String eventType) {
    	List<AttendeeWrapper> response = new List<AttendeeWrapper>();
        for(CIBE_RelaccionadoCita__c relCita: relCitaList){
            System.debug(relCitaList);
            AttendeeWrapper wrap = new AttendeeWrapper();
            wrap.id = relCita.CIBE_Contacto__c;
            wrap.junctionId = relCita.Id;

            if(eventType == 'Asistentes Caixabank'){
                wrap.nombreEmpleado = relCita.CIBE_Contacto__r.name;
                wrap.empleadoId = '/' +  relCita.CIBE_Contacto__c;
                wrap.funcion 		= relCita.CIBE_Contacto__r.AV_DescFuncion__c;
                wrap.centro 		= relCita.CIBE_Contacto__r.Account.name;
                
            }
            else if(eventType == 'Asistentes clientes'){
                System.debug('entra');
                wrap.nombre 		= relCita.CIBE_Contacto__r.firstname;
                wrap.nombreId 		= '/' +  relCita.CIBE_Contacto__c;
                wrap.apellido 		= relCita.CIBE_Contacto__r.lastname;
                wrap.cargo 			= relCita.CIBE_Contacto__r.CIBE_Cargo__c;
                wrap.idioma 		= relCita.CIBE_Contacto__r.CC_Idioma__c;
                wrap.email 			= relCita.CIBE_Contacto__r.email;
                wrap.telefono 		= relCita.CIBE_Contacto__r.phone;
                wrap.confidencial	= relCita.CIBE_Contacto__r.CIBE_Confidencial__c;
            
            }else if(eventType == 'Asistentes sin registrar'){
                wrap.email 		= relCita.CIBE_Email__c;
                if(relCita.CIBE_Contacto__c != null){
                    wrap.nombre 		= relCita.CIBE_Contacto__r.firstname;
                    wrap.apellido 		= relCita.CIBE_Contacto__r.lastname;
                    wrap.cargo 			= relCita.CIBE_Contacto__r.CIBE_Cargo__c;
                    wrap.idioma 		= relCita.CIBE_Contacto__r.CC_Idioma__c;
                    wrap.telefono 		= relCita.CIBE_Contacto__r.phone;
                    wrap.confidencial	= relCita.CIBE_Contacto__r.CIBE_Confidencial__c;
                }
            }
            
            wrap.estado = eventRelMap.containsKey(relCita.CIBE_Contacto__c) ? eventRelMap.get(relCita.CIBE_Contacto__c).Status : 'No enviado';
            response.add(wrap);
            System.debug(response);
        }
        return response;

       
    
    }
    
    @AuraEnabled
    public static void processAsistentes (String evt, List<Map<String,Object>> asistentes){
        	
        List<Contact> asistentesSinRegistrar = new List<Contact>();
        List<Contact> asistentesReg = new List<Contact>();
        Set<String> sinRegistrarEnviarCorreo = new Set<String>();
        List<String> attendes = new List<String>();
        List<CIBE_RelaccionadoCita__c> junctionEventList = new List<CIBE_RelaccionadoCita__c>();
        
        Id taskId = [SELECT AV_Task__c, AV_Tipo__c FROM Event where id = :evt ][0].AV_Task__c;
        Event evento = [SELECT Id, RecordTypeId, AV_Tipo__c, OwnerId, Subject, EndDateTime, StartDateTime, AV_Task__c FROM Event WHERE Id = :evt];
        
        for(Map<String,Object> cont: asistentes){
            CIBE_RelaccionadoCita__c junctionEvent = new CIBE_RelaccionadoCita__c();
            if((((String) cont.get('id')).contains('Idprovisional'))){
                Contact cntToInsert = new Contact();
                cntToInsert.email = (String) cont.get('email');
                cntToInsert.lastname = (String) cont.get('email');
                cntToInsert.CIBE_AsistenteNoRegistrado__c = true;
                asistentesSinRegistrar.add(cntToInsert);
                if((Boolean) cont.get('enviarCita')){
                    sinRegistrarEnviarCorreo.add((String) cont.get('email'));
                }
            }else if(cont.get('id') != null && cont.get('tipoAsistente') == 'Cliente'){
                junctionEvent.CIBE_CitaRelaccionada__c = taskId;
                junctionEvent.CIBE_Contacto__c = (String) cont.get('id');
                junctionEvent.CIBE_TipoAsistente__c = 'Asistentes clientes';
                junctionEventList.add(junctionEvent);
                
                if(cont.get('enviarCita') == true){
                    attendes.add((String) cont.get('id'));
                }
                
                
            }else if(cont.get('id') != null && cont.get('tipoAsistente') == 'CaixaBank'){
                junctionEvent.CIBE_CitaRelaccionada__c = taskId;
                junctionEvent.CIBE_Contacto__c = (String) cont.get('id') ;
                junctionEvent.CIBE_TipoAsistente__c = 'Asistentes CaixaBank';
                junctionEventList.add(junctionEvent);
                
                
                if(cont.get('enviarCita') == true){
                    attendes.add((String) cont.get('id'));
                }
            }
        }
        
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

        if(!attendes.isEmpty() && !Test.isRunningTest()){
            CIBE_NewEventCIBController.callApiTeams(evento, attendes, null);
        }
    }
    
    public class AttendeeWrapper {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String nombreEmpleado {get;set;}
        @AuraEnabled public String empleadoId {get;set;}
        @AuraEnabled public String funcion {get;set;}
        @AuraEnabled public String centro {get;set;}
        @AuraEnabled public String estado {get;set;}
        @AuraEnabled public String nombre {get;set;}
        @AuraEnabled public String nombreId {get;set;}
        @AuraEnabled public String apellido {get;set;}
        @AuraEnabled public String cargo {get;set;}
        @AuraEnabled public String idioma {get;set;}
        @AuraEnabled public String email {get;set;}
        @AuraEnabled public String telefono {get;set;}
        @AuraEnabled public Boolean confidencial {get;set;}
        @AuraEnabled public String junctionId {get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static List<AV_LookupSearchResult> searchUserClientes(String searchTerm, List<String> selectedIds, String recordId, String evnId) {
        Event evt = [SELECT Id, AV_Task__c FROM Event WHERE Id = :evnId];
        searchTerm += '*';
        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<List<SObject>> searchResults = new List<List<SObject>>();
        String contactIcon = 'standard:contact';

          List<CIBE_RelaccionadoCita__c> evtExtension = [SELECT id, CIBE_CitaRelaccionada__c,CIBE_Contacto__c,
                                                        CIBE_Contacto__r.name, CIBE_Contacto__r.Account.name,
                                                        CIBE_Contacto__r.AV_DescFuncion__c
                                                        FROM CIBE_RelaccionadoCita__c
                                                        WHERE CIBE_CitaRelaccionada__c = :evt.AV_Task__c AND (CIBE_TipoAsistente__c = 'Asistentes Caixabank' OR CIBE_TipoAsistente__c = 'Asistentes sin registrar' OR CIBE_TipoAsistente__c = 'Asistentes clientes') ];
        Set<String> contactIds = new Set<String>();
        for(CIBE_RelaccionadoCita__c evtExt: evtExtension){
            contactIds.add(evtExt.CIBE_Contacto__c);
        }   
        
        Set<String> contactId = new Set<String>();

        List<AccountContactRelation > contacts = [SELECT Id, ContactId, Contact.FirstName, Contact.LastName FROM AccountContactRelation WHERE AccountId = :recordId ];

        if(!contacts.isEmpty()){
            for (AccountContactRelation c : contacts) {
                contactId.add(c.ContactId);
            }
        }    
        
        if(!selectedIds.isEmpty()){
            searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                RETURNING
                    Contact(Id, Name, Email, CC_Matricula__c,CC_EmpleadoGestorId__c WHERE Id NOT IN :selectedIds AND RecordType.DeveloperName = :recordTypeCIBE AND Id IN :contactId  AND Id NOT IN :contactIds)
                LIMIT :5
            ];
        }
        else{
            searchResults = [
                FIND :searchTerm
                IN ALL FIELDS
                RETURNING
                    Contact(Id, Name, Email, CC_Matricula__c,CC_EmpleadoGestorId__c WHERE  RecordType.DeveloperName = :recordTypeCIBE AND Id IN :contactId  AND Id NOT IN :contactIds )
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

    @AuraEnabled
    public static void deleteAttende(String junctionId, String eventId){
        Id ownerId = [SELECT Id, OwnerId FROM Event WHERE id = :eventId].OwnerId;

        if(ownerId == UserInfo.getUserId()){
            CIBE_RelaccionadoCita__c relacionToDelete = [SELECT ID, CIBE_Contacto__c FROM CIBE_RelaccionadoCita__c WHERE Id =:junctionId Limit 1];
            String contactId = relacionToDelete.CIBE_Contacto__c;
    
            delete relacionToDelete;
    
            if(contactId != null){
                List<EventRelation> evtRelationToDelete = [SELECT id FROM EventRelation WHERE RelationId = :contactId AND eventId = :eventId];
                if(!evtRelationToDelete.isEmpty()){
                    delete evtRelationToDelete;
                }
                    
            }
        }
    }
}