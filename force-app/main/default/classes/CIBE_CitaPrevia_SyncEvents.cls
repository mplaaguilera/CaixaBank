/**********************************************************************************************************************
Name: CIBE_CitaPrevia_SyncEvents 
Copyright © 2022  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase para sincronizar eventos CIBE via API de Cita Previa
------------------------------------------------------------------------------------------------
Historial
------------------------------------------------------------------------------------------------
VERSION		USER_STORY		AUTHOR				DATE				Description
1.0					        Luis Martínez		10/10/2022			Init version
1.1			US540629        Jose Maria  		07/03/2023			Numper to GCF
1.2			                Alex Campos  		10/05/2023			Absorción de errores CBK_Log
------------------------------------------------------------------------------------------------
***********************************************************************************************************************/
public with sharing class CIBE_CitaPrevia_SyncEvents {

    public static final String SUFFIX_EXTERNALID 	= 'Evt-';

    @future(callout=true)
    public static void insertOrUpdateEvent(String jsonString, Boolean isUpdate){
        String methodName = 'insertOrUpdateEvent';
        Integer limiteQ = 1;
        CIBE_AppUtilities.SearchRT rtGestor = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_GESTOR_RT);
        Set<Id> setRtGestor	= CIBE_EventTriggerHelper.getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtGestor});
        
        List<Event> eventList = new List<Event>();
        try {
            eventList = (List<Event>) JSON.deserialize(jsonString, List<Event>.class);
            CBK_Log.debug('SyncEvents', 'List<Event> eventList', eventList);
        } catch(Exception ex) {
            CBK_Log.error('SyncEvents', jsonString);
        }
        
        Set<Id> idsAccount = new Set<Id>();
        List<String> listRTAcc = new List<String>{'CC_Cliente','CC_ClientePA','CC_CentroCaixabank'};
        Set<Id> idsContactPerson = new Set<Id>();
        Set<String> idsOwner = new Set<String>();
        Map<Id,Event> mapRecurrentEvents = new Map<Id,Event>();
        Map<String,Event> mapEventsHeaders = new Map<String,Event>();
        for(Event e : eventList) {
            if (e.IsRecurrence2){
                mapRecurrentEvents.put(e.Id, e);
            }
            if(String.isNotBlank(e.WhatId)) {
                idsAccount.add(e.WhatId);
            }
            if(String.isNotBlank(e.WhoId)) {
                idsContactPerson.add(e.WhoId);
            }
            idsOwner.add(e.OwnerId);
            if(String.isNotBlank(e.AV_ExternalId__c)) {
                mapEventsHeaders.put(e.AV_ExternalId__c, e);
            }
        }

        Map<Id,User> mapEmployee = new Map<Id,User>();
        if(User.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.User.fields.AV_ExternalID__c.isAccessible() &&
            Schema.SObjectType.User.fields.AV_NumeroOficinaEmpresa__c.isAccessible() &&
            Schema.SObjectType.User.fields.Username.isAccessible()) {
            limiteQ = idsOwner.size();
            mapEmployee = new Map<Id,User>([SELECT Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c, Username FROM User WHERE Id IN :idsOwner AND IsActive = true Limit :limiteQ]);		
        }

        Map<Id, Contact> mapContactPerson = new Map<Id, Contact>();
        if(Contact.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.Contact.fields.CIBE_NumPerso__c.isAccessible()) {
            limiteQ = idsContactPerson.size();
            mapContactPerson = new Map<Id, Contact>([SELECT Id, Name, CIBE_NumPerso__c FROM Contact WHERE Id IN :idsContactPerson Limit :limiteQ]);
        }

        Map<Id,Account> mapCustomer = new Map<Id,Account>();
        if(Account.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.Account.fields.AV_NumPerso__c.isAccessible() &&
            Schema.SObjectType.Account.fields.Name.isAccessible() &&
            Schema.SObjectType.Account.fields.FirstName.isAccessible()&&
            Schema.SObjectType.Account.fields.LastName.isAccessible()) {
            limiteQ = idsAccount.size();
            mapCustomer = new Map<Id,Account>([SELECT Id, Name, AV_NumPerso__c, FirstName, LastName FROM Account WHERE Id IN :idsAccount AND Recordtype.DeveloperName IN : listRTAcc Limit :limiteQ]);
        }
        
        Map<String, String> mapEventIds = new Map<String, String>();
        if(mapRecurrentEvents != null && !mapRecurrentEvents.isEmpty()){
            mapEventIds = getExternalIdRecurrentEvent(mapRecurrentEvents);
        }

        Map<String, AV_HeaderCustomActivity__c> mapHeaderTask = new Map<String, AV_HeaderCustomActivity__c>();
        if(mapEventsHeaders != null && !mapEventsHeaders.isEmpty()){
            if(AV_HeaderCustomActivity__c.SObjectType.getDescribe().isAccessible()){
                limiteQ = mapEventsHeaders.size();
                for(AV_HeaderCustomActivity__c aux : [SELECT Id, AV_ExternalId__c, AV_UrlTeams__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalId__c IN :mapEventsHeaders.keySet() Limit :limiteQ]) {
                    mapHeaderTask.put(aux.AV_ExternalID__c, aux);
                }
            }
        }

        List<Event> eventToUpdate = new List<Event>();
        List<CBK_Activity_Extension__c> crmTareas = new List<CBK_Activity_Extension__c>();
        List<AV_HeaderCustomActivity__c> customHeaders = new List<AV_HeaderCustomActivity__c>();
        for(Event e : eventList) {
            try {
                AV_HeaderCustomActivity__c headerTask = null;
                if(mapHeaderTask.containsKey(e.AV_ExternalID__c)) {
                    headerTask = mapHeaderTask.get(e.AV_ExternalID__c);
                }
                
                String externalID = e.AV_ExternalID__c;
                if (e.IsRecurrence2){
                    externalID = mapEventIds.get(e.Id);
                }

                CIBE_CitaPrevia_Integration.Event parms = new CIBE_CitaPrevia_Integration.Event ();
                parms = buildBodyRequest(e, mapCustomer?.get(e.WhatId), mapEmployee?.get(e.OwnerId), headerTask, mapContactPerson?.get(e.WhoId));
                system.debug('parms 1 '+ parms);
                CBK_Log.debug('SyncEvents', 'CIBE_CitaPrevia_Integration.Event parms', new List<Object>{ parms });

                if((isUpdate && String.isNotBlank(externalID) && !externalID.startsWith(SUFFIX_EXTERNALID)) || (e.IsRecurrence2 && String.isNotBlank(externalID))) {
                    CIBE_CitaPrevia_Integration.MoCntResponse res = new CIBE_CitaPrevia_Integration.MoCntResponse();
                    if (!mapEmployee.get(e.OwnerId).Username.contains('gcf-integration')) {
                        res =  CIBE_CitaPrevia_Integration.moCnt(
                            parms,String.isNotBlank(mapEmployee.get(e.OwnerId).AV_ExternalID__c) ? mapEmployee.get(e.OwnerId).AV_ExternalID__c : '000000',
                            externalID
                        );
                    } else {
                        res =  CIBE_CitaPrevia_Integration.moCnt(
                            parms,String.isNotBlank(e.AV_CodigoGestorAsignado__c) ? e.AV_CodigoGestorAsignado__c : '000000',
                            externalID
                        );
                    }
                    //CBK_Log.debug('SyncEvents', 'CIBE_CitaPrevia_Integration.MoCntResponse res', new List<Object>{ res });
                    saveResponseAPI(crmTareas, e, JSON.serialize(res));
                    }else {
                    CIBE_CitaPrevia_Integration.InsCntResponse res = new CIBE_CitaPrevia_Integration.InsCntResponse();
                    if (!mapEmployee.get(e.OwnerId).Username.contains('gcf-integration')) {
                        res = CIBE_CitaPrevia_Integration.intCnt(parms,String.isNotBlank(mapEmployee.get(e.OwnerId).AV_ExternalID__c) ? mapEmployee.get(e.OwnerId).AV_ExternalID__c : '000000');
                    }else {
                        res = CIBE_CitaPrevia_Integration.intCnt(parms,String.isNotBlank(e.AV_CodigoGestorAsignado__c) ? e.AV_CodigoGestorAsignado__c : '000000');
                    }
                    
                    //CBK_Log.debug('SyncEvents', 'CIBE_CitaPrevia_Integration.InsCntResponse res', new List<Object>{ res });
                    saveResponseAPI(crmTareas, e, JSON.serialize(res));

                    if('201'.equalsIgnoreCase(res.StatusCode)){
                        Event eUpt = new Event();
                        eUpt.Id = e.Id;
                        if (!e.IsRecurrence2 && e.AV_ExternalID__c != res.eventPremiumId){
                            eUpt.AV_ExternalID__c = res.eventPremiumId;
                        }
                        if (eUpt.AV_origenApp__c != CIBE_AppConstants.OUTLOOK_ORIGENAPP) {
                            eUpt.AV_origenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
                        }
                        eventToUpdate.add(eUpt);
                        
                        if (setRtGestor.contains(e.RecordTypeId) && e.IsRecurrence2) {
                            AV_HeaderCustomActivity__c headerCustomAct = createRecurrentEventHeader(e, res.eventPremiumId);
                            if (headerCustomAct != null) {
                                customHeaders.add(headerCustomAct);
                            }
                        }
                    }
                }
            } catch(AV_ApplicationException ae) {
                saveResponseAPI(crmTareas, e, ae.getMessage());
                CBK_Log.error('SyncEvents', ae, ae.getMessage());
            } catch(Exception ae2) {
                String message = ('Line: ' + ae2.getLineNumber() + ' - ' + ae2.getMessage());
                CBK_Log.error('SyncEvents', ae2, message);
            }
        }

        if(!eventToUpdate.isEmpty()) {
            List<Database.SaveResult> listResult = Database.update(eventToUpdate, false);

            boolean hasError = false;
            List<Object> objs = new List<Object>();
            Map<String, String> msjs = new Map<String, String>();
            for (Integer i = 0; i < eventToUpdate.size(); i++) {
                Database.SaveResult dr = listResult[i];
                if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                    msjs.put(eventToUpdate[i].Id, ((String)dr.getErrors()[0].getMessage()));
                    objs.add(eventToUpdate[i]);
                    hasError = true;
                }
            }
            
            if(hasError) {
                CBK_Log.error(msjs, objs);
            }
        }
        
        if(!crmTareas.isEmpty()) {
            List<CBK_Activity_Extension__c> crmTaskToUpdate = checkCrmTaskOverride(crmTareas);
            if(!crmTaskToUpdate.isEmpty()) {
                List<Database.SaveResult> listResult = Database.update(crmTaskToUpdate, false);
                
            boolean hasError = false;
            List<Object> objs = new List<Object>();
            Map<String, String> msjs = new Map<String, String>();
            for (Integer i = 0; i < crmTaskToUpdate.size(); i++) {
                Database.SaveResult dr = listResult[i];
                if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                    msjs.put(crmTaskToUpdate[i].Id, ((String)dr.getErrors()[0].getMessage()));
                    objs.add(crmTaskToUpdate[i]);
                    hasError = true;
                    }
                }
                
                if(hasError) {
                    CBK_Log.error(msjs, objs);
                }
            }
    
            List<Database.UpsertResult> listResult2 = Database.upsert(crmTareas, false);

            boolean hasError = false;
            List<Object> objs = new List<Object>();
            Map<String, String> msjs = new Map<String, String>();
            for (Integer i = 0; i < crmTareas.size(); i++) {
                Database.UpsertResult dr = listResult2[i];
                if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                    msjs.put(crmTareas[i].Id, ((String)dr.getErrors()[0].getMessage()));
                    objs.add(crmTareas[i]);
                    hasError = true;
                }
            }
            
            if(hasError) {
                CBK_Log.error(msjs, objs);
            }
        }

        if (!customHeaders.isEmpty()) {
            List<Database.SaveResult> listResult = Database.insert(customHeaders, false);

            boolean hasError = false;
            List<Object> objs = new List<Object>();
            Map<String, String> msjs = new Map<String, String>();
            for (Integer i = 0; i < customHeaders.size(); i++) {
                Database.SaveResult dr = listResult[i];
                if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
                    msjs.put(customHeaders[i].Id, ((String)dr.getErrors()[0].getMessage()));
                    objs.add(customHeaders[i]);
                    hasError = true;
                }
            }
            
            if(hasError) {
                CBK_Log.error(msjs, objs);
            }
        }
    }
    
    /**
     * Get the external ID for recurrent events
     */
    public static Map<String, String> getExternalIdRecurrentEvent(Map<Id,Event> mapRecurrentEvents) {
        Datetime startDate = null;
        Datetime endDate = null;
        Map<String, String> mapEventIds = new Map<String, String>();
        if (mapRecurrentEvents.keySet() != null && !mapRecurrentEvents.isEmpty() && mapRecurrentEvents.size()>0) {
            for(Event e : mapRecurrentEvents.values()) {
                if(startDate == null ) {startDate = e.CreatedDate;}
                if(startDate != null && startDate > e.CreatedDate) {startDate = e.CreatedDate;}
                if(endDate == null ) {endDate = e.CreatedDate;}
                if(endDate != null && endDate < e.CreatedDate) {endDate = e.CreatedDate;}
            }
            
            List<AV_HeaderCustomActivity__c> listRecurrentEvent = new List<AV_HeaderCustomActivity__c>();
            if(startDate != null && endDate != null) {
                if(
                    AV_HeaderCustomActivity__c.SObjectType.getDescribe().isAccessible() &&
                    Schema.SObjectType.AV_HeaderCustomActivity__c.fields.AV_ExternalID__c.isAccessible() &&
                    Schema.SObjectType.AV_HeaderCustomActivity__c.fields.IDTask__c.isAccessible()
                ) {
                    listRecurrentEvent  = [SELECT Id, IDTask__c, AV_ExternalID__c FROM AV_HeaderCustomActivity__c WHERE IDTask__c IN :mapRecurrentEvents.keySet() AND CreatedDate > :startDate.addHours(-1) AND CreatedDate < :endDate.addHours(1)];
                }
            }

            if(!listRecurrentEvent.isEmpty()){
                for (AV_HeaderCustomActivity__c data : listRecurrentEvent){
                    mapEventIds.put(data.IDTask__c, data.AV_ExternalID__c);
                }
            }
        }
        return mapEventIds;
    }

    /**
     * Create header-event only for recurrent event
     */
    public static AV_HeaderCustomActivity__c createRecurrentEventHeader(Event e, String externalId) {
        AV_HeaderCustomActivity__c headerCustomAct = new AV_HeaderCustomActivity__c();
        if (String.isNotBlank(e.Subject) && e.Subject.length() < 80) {
            headerCustomAct.Name = e.Subject;
        } else {
            headerCustomAct.Name = externalId;
        }
        headerCustomAct.AV_ExternalID__c = externalId;
        headerCustomAct.IDTask__c = e.Id;
        return headerCustomAct;                                      
    }

	/**
	 * Create header-task only for recurrent event
	 */

    public static List<CBK_Activity_Extension__c> checkCrmTaskOverride(List<CBK_Activity_Extension__c> crmTareas){
		Map<String, CBK_Activity_Extension__c> mapCrmTareas = new Map<String, CBK_Activity_Extension__c>();
		for (CBK_Activity_Extension__c aux : crmTareas){
			if (String.isNotBlank(aux.AV_ReasignarCartera_Id_Task__c)){
				mapCrmTareas.put(aux.AV_ReasignarCartera_Id_Task__c, aux);
			}
			else if (String.isNotBlank(aux.AV_ActivityId__c)){
				mapCrmTareas.put(aux.AV_ActivityId__c, aux);
			}
		}

        List<CBK_Activity_Extension__c> crmTaskListExist = new List<CBK_Activity_Extension__c>();
        if(!mapCrmTareas.isEmpty() && CBK_Activity_Extension__c.SObjectType.getDescribe().isAccessible() &&
            Schema.SObjectType.CBK_Activity_Extension__c.fields.Name.isAccessible() &&
            Schema.SObjectType.CBK_Activity_Extension__c.fields.AV_ActivityId__c.isAccessible()&&
            Schema.SObjectType.CBK_Activity_Extension__c.fields.AV_ReasignarCartera_Id_Task__c.isAccessible() &&
            Schema.SObjectType.CBK_Activity_Extension__c.fields.AV_ReasignarCartera_Id_Cliente__c.isAccessible()&&
            Schema.SObjectType.CBK_Activity_Extension__c.fields.AV_Reasignar_cartera_Owner__c.isAccessible() &&
            Schema.SObjectType.CBK_Activity_Extension__c.fields.AV_ReasignarCartera_JSONAPI__c.isAccessible()
        ) {
            crmTaskListExist = [SELECT  Id, 
                                        Name, 
                                        AV_ActivityId__c, 
                                        AV_ReasignarCartera_Id_Task__c, 
                                        AV_ReasignarCartera_Id_Cliente__c, 
                                        AV_Reasignar_cartera_Owner__c, 
                                        AV_ReasignarCartera_JSONAPI__c 
                                FROM CBK_Activity_Extension__c 
                                WHERE AV_ReasignarCartera_Id_Task__c IN :mapCrmTareas.keySet() OR AV_ActivityId__c IN :mapCrmTareas.keySet()];
        }

		List<CBK_Activity_Extension__c> crmTaskToUpdate = new List<CBK_Activity_Extension__c>();
            for (CBK_Activity_Extension__c crmTaskOld : crmTaskListExist){
            if (String.isNotBlank(crmTaskOld.AV_ReasignarCartera_Id_Task__c) && mapCrmTareas.get(crmTaskOld.AV_ReasignarCartera_Id_Task__c) != null) {
                    CBK_Activity_Extension__c crmTaskNew = mapCrmTareas.get(crmTaskOld.AV_ReasignarCartera_Id_Task__c);
                    crmTaskNew.Id = crmTaskOld.Id;
                    crmTaskNew.AV_ActivityId__c = crmTaskOld.AV_ActivityId__c;
                    crmTaskNew.AV_ReasignarCartera_Id_Task__c = crmTaskOld.AV_ReasignarCartera_Id_Task__c;
                    crmTaskNew.AV_ReasignarCartera_Id_Cliente__c = crmTaskOld.AV_ReasignarCartera_Id_Cliente__c;
                    crmTaskNew.AV_Reasignar_cartera_Owner__c = crmTaskOld.AV_Reasignar_cartera_Owner__c;
                    crmTaskNew.AV_ReasignarCartera_JSONAPI__c = crmTaskOld.AV_ReasignarCartera_JSONAPI__c;
                    crmTaskToUpdate.add(crmTaskNew);
            } else if(String.isNotBlank(crmTaskOld.AV_ActivityId__c) && mapCrmTareas.get(crmTaskOld.AV_ActivityId__c) != null) {
                CBK_Activity_Extension__c crmTaskNew = mapCrmTareas.get(crmTaskOld.AV_ActivityId__c);
                    crmTaskNew.Id = crmTaskOld.Id;
                    crmTaskNew.AV_ActivityId__c = crmTaskOld.AV_ActivityId__c;
                    crmTaskNew.AV_ReasignarCartera_Id_Task__c = crmTaskOld.AV_ReasignarCartera_Id_Task__c;
                    crmTaskNew.AV_ReasignarCartera_Id_Cliente__c = crmTaskOld.AV_ReasignarCartera_Id_Cliente__c;
                    crmTaskNew.AV_Reasignar_cartera_Owner__c = crmTaskOld.AV_Reasignar_cartera_Owner__c;
                    crmTaskNew.AV_ReasignarCartera_JSONAPI__c = crmTaskOld.AV_ReasignarCartera_JSONAPI__c;
                    crmTaskToUpdate.add(crmTaskNew);
                }
            }
		return crmTaskToUpdate;
	}
    
    /**
     * Save response API
     */
    public static void saveResponseAPI(List<CBK_Activity_Extension__c> crmTareas, Event evt, String respTxt){
        CBK_Activity_Extension__c crmTarea = new CBK_Activity_Extension__c();
        crmTarea.Name = evt.Id;
        crmTarea.AV_ActivityId__c = evt.Id;
        crmTarea.AV_ReasignarCartera_Id_Task__c = evt.Id;
        crmTarea.AV_ReasignarCartera_Id_Cliente__c = evt.WhatId;
        crmTarea.AV_Reasignar_cartera_Owner__c = evt.OwnerId;
        crmTarea.AV_ReasignarCartera_JSONAPI__c = respTxt;
        crmTareas.add(crmTarea);
    } 

    /**
     * Build the request to send to API (Cita Previa)
     */
    public static CIBE_CitaPrevia_Integration.Event buildBodyRequest(Event event, Account customer, User employee, AV_HeaderCustomActivity__c headerTask, Contact contactPerson) {
        if(event == null || (String.isNotBlank(event.Description) && event.Description.length() > 2000)) { throw new AV_ApplicationException('Event with more than 2000 characters in description field.'); }
        if(customer == null || String.isBlank(customer.AV_NumPerso__c) || String.isBlank(customer.Name)) { throw new AV_ApplicationException('Client must have Name and AV_NumPerso__c.'); }
        if(employee == null || String.isBlank(employee.AV_NumeroOficinaEmpresa__c)) { throw new AV_ApplicationException('Employee must have AV_ExternalID__c and AV_NumeroOficinaEmpresa__c.'); }
        
        CIBE_CitaPrevia_Integration.Event parms = new CIBE_CitaPrevia_Integration.Event();
        parms.salesforceEventId = event.Id;
        parms.subject = event.Subject;
        parms.employeeEvent = String.isNotBlank(employee.AV_ExternalID__c) ? employee.AV_ExternalID__c : '';
        parms.branchPhysicalMeet = String.isNotBlank(event.AV_BranchPhysicalMeet__c) ? event.AV_BranchPhysicalMeet__c : '';
        parms.meetingPlace = event.Location;
        parms.dateReplacement = event.StartDateTime.format('yyyy-MM-dd');
        parms.startTime = event.StartDateTime.format('HH:mm');
        parms.endTime = event.EndDateTime.format('HH:mm');
        parms.previousWarning = 'M30';
        parms.comment = event.Description;
        parms.isPrivate = event.isPrivate;
        parms.isDigitalCustomer = false;
        parms.customer.customerId = Integer.valueOf(customer.AV_NumPerso__c);
        parms.customer.name = customer.Name;
        parms.branchId = Integer.valueOf(employee.AV_NumeroOficinaEmpresa__c.contains('-') ? employee.AV_NumeroOficinaEmpresa__c.substringAfter('-') : employee.AV_NumeroOficinaEmpresa__c);
        
        //type
        String strRecordName = Schema.SObjectType.Event.getRecordTypeInfosById().get(event.RecordTypeId).getDeveloperName();
        if((strRecordName.equals(CIBE_AppConstants.EVENT_CLIENTE_RT)) && (CIBE_AppConstants.LLAMADA_TIPO.equalsIgnoreCase(event.AV_Tipo__c) || CIBE_AppConstants.LLAMADA_TLF_TIPO.equalsIgnoreCase(event.AV_Tipo__c))){
            parms.type = 'L';
        } else if(strRecordName.equals(CIBE_AppConstants.EVENT_CLIENTE_RT)) {
            parms.type = 'C';
        } else if(strRecordName.equals(CIBE_AppConstants.EVENT_GESTOR_RT)) {
            parms.type = 'O';
        }

        //remoteMeeting
        if(CIBE_AppConstants.LLAMADA_TIPO.equalsIgnoreCase(event.AV_Tipo__c) || CIBE_AppConstants.CITA_TELEFONICA_TIPO.equalsIgnoreCase(event.AV_Tipo__c) || CIBE_AppConstants.LLAMADA_TLF_TIPO.equalsIgnoreCase(event.AV_Tipo__c)){
            parms.remoteMeeting = 'L';
        } else if(CIBE_AppConstants.VIDEOLLAMADA_TIPO.equalsIgnoreCase(event.AV_Tipo__c)) {
            parms.remoteMeeting = 'V';
        }
        parms.meetingRequester = 'G';

        //status
        if(CIBE_AppConstants.EVENT_STATUS_PENDIENTE.equalsIgnoreCase(event.CSBD_Evento_Estado__c)) {
            parms.status = 'N';
        }else{
            parms.status = 'R';
        }

        //locationType
        if(CIBE_AppConstants.CITA_OFICINA_TIPO.equalsIgnoreCase(event.AV_Tipo__c) || CIBE_AppConstants.VISITA_TIPO.equalsIgnoreCase(event.AV_Tipo__c) || 	
            CIBE_AppConstants.ENTREVISTA_CENTRO_TIPO.equalsIgnoreCase(event.AV_Tipo__c) || CIBE_AppConstants.VISITA_CENTRO_TIPO.equalsIgnoreCase(event.AV_Tipo__c)) {
            parms.locationType = 'P';
        } else {
            parms.locationType = 'R';
        }

        //physicalMeeting
        if(parms.locationType.equals('P') && (CIBE_AppConstants.VISITA_TIPO.equalsIgnoreCase(event.AV_Tipo__c) || CIBE_AppConstants.VISITA_CENTRO_TIPO.equalsIgnoreCase(event.AV_Tipo__c))){
            parms.physicalMeeting = 'D'; //Domicilio cliente
        } else if(parms.locationType.equals('P')) {
            parms.physicalMeeting = 'C'; //Centro caixa
        } else {
            parms.physicalMeeting = 'O'; //Otros
        }

        if (headerTask != null) {
            parms.urlVideocall = headerTask.AV_UrlTeams__c;
        }

        if (contactPerson != null) {
            parms.legalRepresentativeId = contactPerson.CIBE_NumPerso__c;
            parms.legalRepresentativeName = contactPerson.Name;
        }
        
        List<String> matriculasAtt = mapMatriculaAtt(event);
        if (matriculasAtt != null) {
            parms.MandatoryAssistance = matriculasAtt;
        }

        return parms;
    }

    /**
     * Map ExternalID of attendeess
     */
    public static List<String> mapMatriculaAtt(Event evt){
        List<String> matriculasAtt = new List<String>();
        List<String> matriVal = new List<String>();
        Set<String> userIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        if(evt.OwnerId != null){
            userIds.add(evt.OwnerId);
        }
        if(AcceptedEventRelation.SObjectType.getDescribe().isAccessible()) {
            for(AcceptedEventRelation aAttende : [SELECT Id, EventId, RelationId FROM AcceptedEventRelation WHERE EventId = :evt.Id ]) {
                if(String.isNotBlank(aAttende.RelationId)) {
                    if(((String)aAttende.RelationId).startsWith('005')) {
                        userIds.add(aAttende.RelationId);
                    } else {
                        contactIds.add(aAttende.RelationId);
                    }
                } 
            }            
            for(UndecidedEventRelation uAttende : [SELECT Id, EventId, RelationId FROM UndecidedEventRelation WHERE EventId = :evt.Id ]) {
                if(String.isNotBlank(uAttende.RelationId)) {
                    if(((String)uAttende.RelationId).startsWith('005')) {
                        userIds.add(uAttende.RelationId);
                    } else {
                        contactIds.add(uAttende.RelationId);
                    }
                } 
            }
            if(Contact.SObjectType.getDescribe().isAccessible()) {
                for(Contact contacto : [SELECT Id, Name, AV_UsuarioAsociado__c, AV_UsuarioAsociado__r.AV_ExternalId__c FROM Contact WHERE (Id IN :contactIds OR AV_UsuarioAsociado__c IN :userIds)]) {
                    if(String.isNotBlank(contacto.AV_UsuarioAsociado__c) && String.isNotBlank(contacto.AV_UsuarioAsociado__r.AV_ExternalId__c) &&
                        !matriculasAtt.contains(contacto.AV_UsuarioAsociado__r.AV_ExternalId__c) ) {
                        matriculasAtt.add( contacto.AV_UsuarioAsociado__r.AV_ExternalId__c);
                    }
                }
            }
        }
        matriVal = validateMatriculaAtt(matriculasAtt);
        return !matriVal.isEmpty() ? matriVal : null;
    }
    
    /**
     * Validate Matricula Attendee
     */
    public static List<String> validateMatriculaAtt(List<String> lstMat){
        List<String> matriculasAtt = new List<String>();
        if(!lstMat.isEmpty()) {
            for(String mat : lstMat) {
                if(mat.length() == 8) {
                    matriculasAtt.add(mat);
                } 
            }            
        }
        return !matriculasAtt.isEmpty() ? matriculasAtt : null;
    }  
}