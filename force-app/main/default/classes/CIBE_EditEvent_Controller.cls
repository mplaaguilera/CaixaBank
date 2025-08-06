/**********************************************************************************************************************
Name:	  CIBE_EditEvent_Controller
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller para el LWC Cibe_EditEvent
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US530818		Ainhoa Valle	    06/06/2024			Init version
    1.1         PPM100376561    Luis Martinez       23/09/2024          Add CCGG in getInfoCliente
	
***********************************************************************************************************************/
public with sharing class CIBE_EditEvent_Controller {
    private static List<String> recordTypeCIBE = new List<String>{CIBE_AppConstants.CONTACT_APODERADO_RT, CIBE_AppConstants.CONTACT_CONTACTO_COMERCIAL_RT};
    private static CIBE_AppUtilities.SearchRT rtCliente 	= new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
    private static Set<Id> setRtCliente		= getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtCliente});
 
    @AuraEnabled(cacheable=true)
    public static Wrapper getInfoCliente(String id){
        List<Event> eventsInfo = new List<Event>();
        List <EventRelation> lstEventRelation = new List <EventRelation> ();
        List <Contact> lstAsistentesCBX = new List <Contact>();
        List <Contact> lstAsistentesEmp = new List <Contact>();
        List<CBK_Activity_Extension__c> lstCAEToInsert = new List<CBK_Activity_Extension__c>();
        List<CIBE_RelaccionadoCita__c> relacionCita = new List<CIBE_RelaccionadoCita__c>();



        if(Schema.SObjectType.Event.fields.Id.isAccessible()
           && Schema.SObjectType.Event.fields.CSBD_Evento_Estado__c.isAccessible()
           && Schema.SObjectType.Event.fields.Description.isAccessible()) {
            eventsInfo = [SELECT Id, AccountId, Account.Name, RecordType.DeveloperName, Who.Name, OwnerId, Owner.Name, Subject, Description, AV_Tipo__c, StartDateTime, EndDateTime, ActivityDate, Location, CIBE_Confidential__c, CreatedById, AV_Task__c
               FROM Event
               WHERE Id = :id];
               lstEventRelation = [SELECT Id, RelationId, Relation.name, Relation.RecordType.DeveloperName FROM EventRelation WHERE EventId =:id and IsInvitee = true];
               if(!lstEventRelation.IsEmpty()){
                   for(EventRelation evr: lstEventRelation){
                       if(evr.Relation.RecordType.DeveloperName == 'CIBE_Apoderado' || evr.Relation.RecordType.DeveloperName == 'CIBE_ContactoComercial' ){
                           Contact cont = new Contact ();
                           cont.Id = evr.RelationId;
                           cont.FirstName = evr.Relation.Name;
                           lstAsistentesEmp.add(cont);
                       }else if(evr.Relation.RecordType.DeveloperName == 'CC_Empleado'){
                           Contact cont = new Contact ();
                           cont.Id = evr.RelationId;
                           cont.FirstName = evr.Relation.Name;
                           lstAsistentesCBX.add(cont);
                       }
                   }
               }
               lstCAEToInsert = [SELECT Id, CIBE_ComentarioCita__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c=:id LIMIT 1];

               relacionCita = [SELECT Id, CIBE_Account__c, CIBE_GrupoComercial__c FROM CIBE_RelaccionadoCita__c WHERE CIBE_CitaRelaccionada__c=:eventsInfo[0].AV_Task__c LIMIT 1];            
            
            }

        Wrapper w = new Wrapper();
        w.ev = !eventsInfo.isEmpty() ? eventsInfo.get(0) : null;
        w.asistentesCBX = lstAsistentesCBX.IsEmpty() ? null : lstAsistentesCBX;
        w.asistentesEMP = lstAsistentesEmp.IsEmpty() ? null : lstAsistentesEmp;
        w.comentario = !lstCAEToInsert.IsEmpty() && lstCAEToInsert[0] !=null  ? lstCAEToInsert[0].CIBE_ComentarioCita__c : '';
        w.gruposComerciales = !relacionCita.IsEmpty() && relacionCita[0] !=null  ? relacionCita[0].CIBE_GrupoComercial__c : '';
        return w;
    }


    public class Wrapper {
        @AuraEnabled public Event ev {get;set;}
        @AuraEnabled public List<Contact> asistentesCBX {get;set;}
        @AuraEnabled public List<Contact> asistentesEMP {get;set;}
        @AuraEnabled public String comentario {get;set;}
        @AuraEnabled public String gruposComerciales {get;set;}


    }



    @AuraEnabled
    public static List<Event> updateEvent(String evtToUpdate){
        EventWrapper evtwrapper = (EventWrapper) JSON.deserialize(evtToUpdate, EventWrapper.class);
        Event ev = new Event();
        ev.Id = evtwrapper.id;
        ev.RecordTypeId = evtwrapper.recordTypeId;
        ev.AV_Tipo__c = evtwrapper.tipo;
        ev.ActivityDate = Date.valueOf(evtwrapper.activityDate);
        if(evtwrapper.csbdEventoEstado != null){
            ev.CSBD_Evento_Estado__c = evtwrapper.csbdEventoEstado;
        }   
        ev.CIBE_Confidential__c = Boolean.valueOf(evtwrapper.confidential);
        //ev.Description = evtwrapper.description;
        ev.DurationInMinutes = evtwrapper.duration;
        ev.EndDateTime = Datetime.valueOfGmt(evtwrapper.endDateTime + ':00');
        ev.OwnerId = evtwrapper.ownerId;
        ev.Location = evtwrapper.location;
        ev.StartDateTime = Datetime.valueOfGmt(evtwrapper.startDateTime + ':00');
        ev.Subject = evtwrapper.subject;
        ev.WhatId = evtwrapper.whatId;
        if(evtwrapper.whoId != null){
            ev.WhoId = evtwrapper.whoId;
        }

        List<CBK_Activity_Extension__c> lstCAEToInsert = new List<CBK_Activity_Extension__c>();
        lstCAEToInsert = [SELECT Id, AV_ActivityId__c, AV_CommentLastModifiedBy__c, AV_CommentLastModifiedDate__c, CIBE_ComentarioCita__c
        FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c=:evtwrapper.id LIMIT 1];

        if(!lstCAEToInsert.IsEmpty()){
            lstCAEToInsert[0].CIBE_ComentarioCita__c = evtwrapper.description;
            lstCAEToInsert[0].AV_CommentLastModifiedDate__c = System.now();

        }else{
            CBK_Activity_Extension__c cae = new CBK_Activity_Extension__c();
            // cae.AV_CommentLastModifiedBy__c = employeeInfo; 
            cae.AV_CommentLastModifiedDate__c = System.now();
            cae.CIBE_ComentarioCita__c = evtwrapper.description;
            cae.AV_ActivityId__c = evtwrapper.id;
            lstCAEToInsert.add(cae);
        }

        if(Schema.sObjectType.Event.isUpdateable()){
            Database.SaveResult sr = Database.update(ev);
            List<Event> createdEventList = new List<Event>();
            if(sr.isSuccess()){
                createdEventList = [SELECT Id, RecordTypeId, AV_Tipo__c, CreatedById FROM Event WHERE Id = :evtwrapper.id LIMIT 1];
                Database.upsert(lstCAEToInsert,false);

                return createdEventList;
            } else{
                return null;
            } 
        }else{
            return null;
        }

    }


    public class EventWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String recordTypeId { get; set; }
        @AuraEnabled public String tipo { get; set; }
        @AuraEnabled public String csbdEventoEstado { get; set; }
        @AuraEnabled public String activityDate { get; set; }
        @AuraEnabled public String confidential { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public Integer duration { get; set; }
        @AuraEnabled public String endDateTime { get; set; }
        @AuraEnabled public String location { get; set; }
        @AuraEnabled public String ownerId { get; set; }
        @AuraEnabled public String startDateTime { get; set; }
        @AuraEnabled public String subject { get; set; }
        @AuraEnabled public String whatId { get; set; }
        @AuraEnabled public String whoId { get; set; }
        @AuraEnabled public String sobjectype { get; set; }
    }

    @AuraEnabled
    public static List<String> createEventRelation2(String eventId,List<String> attendes, String contactoPrincipal){

        Boolean resultRemove = removeAttendes(eventId);
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
	*
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
	}*/

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
    * @description		 	Get the ID's of the RT's requested by param
    * @param setRT			List of the RT
    */
    public static Set<Id> getIdsRT(Set<CIBE_AppUtilities.SearchRT> setRT){
		
        return CIBE_AppUtilities.getRecordTypeIdsInSet(setRT);
    }

    @AuraEnabled
    public static Boolean removeAttendes(String recordId) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<EventRelation> attendees = [SELECT Id FROM EventRelation WHERE EventId = :recordId AND IsInvitee = true];
            if(!attendees.isEmpty()){
                delete attendees;
            }
            return true;
            
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('Error al eliminar EventRelations: ' + e.getMessage());
            return false;
        }

}

}