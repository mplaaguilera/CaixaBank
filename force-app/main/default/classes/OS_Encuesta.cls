public with sharing class OS_Encuesta {
    public static void enviarEncuesta(List<Id> idCasos) {
        //Comprobar que hay un caso para enviar la encuesta.
        if (!idCasos.isEmpty()) {
            List<Case> casos = [SELECT Origin, CaseNumber, CC_Admin__c, ContactId, CC_Canal_Procedencia__c, CC_Idioma__c, CC_MCC_Tematica__r.OS_No_Enviar_Encuestas__c, CC_Buzon_Salida__c, CC_Tematica__c FROM Case 
                                WHERE Id IN :idCasos 
                                AND ContactId <> null
                                AND CC_MCC_Tematica__r.OS_No_Enviar_Encuestas__c = false 
                                AND CC_MCC_ProdServ__r.OS_No_Enviar_Encuestas__c = false
                                AND CC_MCC_Motivo__r.OS_No_Enviar_Encuestas__c = false
                                AND (Origin = 'Email' OR (Origin = 'Phone' AND CC_Tematica__c LIKE 'UAC%')) 
                                AND CC_Buzon_Salida__c <> null 
                                AND (CC_Idioma__c = 'ca' OR  CC_Idioma__c = 'es')];
            if (!casos.isEmpty()) {
                List<EmailTemplate> plantillas = [SELECT DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE 'OS_Encuesta_Offline' OR DeveloperName LIKE 'OS_Enquesta_Offline' ORDER BY DeveloperName DESC];
                Map<String,EmailTemplate> idiomaPlantilla = new Map<String,EmailTemplate>();
                //Se recuperan los contactos de los casos
                List<Id> idContactos = new List<Id>();
                for (Case caso : casos) {
                    if (!idContactos.contains(caso.ContactId)) {
                        idContactos.add(caso.ContactId);
                    }
                    if (caso.CC_Idioma__c == 'ca') {
                        idiomaPlantilla.put('ca', plantillas[0]);
                    } else {
                        idiomaPlantilla.put('es', plantillas[1]);
                    }
                }
                
                //Se descartan los casos de los contactos con encuesta recibida en los últimos 15 días o respondida en los últimos 90
                for (SurveyInvitation encuestaReciente : [SELECT ParticipantId FROM SurveyInvitation WHERE ParticipantId IN :idContactos AND CreatedDate >= LAST_N_DAYS:15]) {
                    if (!idContactos.isEmpty()) {
                        idContactos.remove(idContactos.indexOf(encuestaReciente.ParticipantId));
                    }
                }
                
                for (SurveyResponse respuestaEncuestaReciente : [SELECT Invitation.ParticipantId FROM SurveyResponse
                                                                WHERE Invitation.ParticipantId IN :idContactos AND Status = 'Completed' AND CreatedDate >= LAST_N_DAYS:90]) {
                    if (!idContactos.isEmpty()) {
                        idContactos.remove(idContactos.indexOf(respuestaEncuestaReciente.Invitation.ParticipantId));
                    }
                }
                
                //Validar que el empleado no sea genérico y comprobar que el contacto tiene correo
                List<String> numEmpleadosGenericos = new List<String>{'98999', '99994', '99995', '99997', '99998', '99999'};
                for (Contact empleado : [SELECT CC_Num_Empleado__c, Email FROM Contact WHERE Id IN :idContactos]) {
                    if (numEmpleadosGenericos.contains(empleado.CC_Num_Empleado__c) || String.isBlank(empleado.Email)) {
                        System.debug('TIENE MAIL');
                        idContactos.remove(idContactos.indexOf(empleado.Id));
                    }
                }

                //Se descartan los casos de los contactos descartados
                for (Integer i = casos.size() - 1; i >= 0; i--) {
                    if (!idContactos.contains(casos[i].ContactId)) {
                        casos.remove(i);
                    }
                }
                
                if (!casos.isEmpty()) {
                    //Crear SurveyInvitation
                    List<SurveyInvitation> surveyInvitations = new List<SurveyInvitation>();
                    List<OS_Encuesta__mdt> listaEncuestas = [SELECT Label, OS_Encuesta__c FROM OS_Encuesta__mdt];
                    
                    Id communityId = [SELECT Id FROM Network WHERE Name = 'Encuestas Contact Center' LIMIT 1].Id;
                    Id surveyId = [SELECT Name FROM Survey WHERE Name = :listaEncuestas[0].OS_Encuesta__c LIMIT 1].Id;
                    
                    for (Case caso : casos) {
                        SurveyInvitation surveyInvitation = new SurveyInvitation();
                        surveyInvitation.CommunityId = communityId;
                        surveyInvitation.SurveyId = surveyId;
                        surveyInvitation.Name = 'Encuesta para el caso ' + caso.CaseNumber;
                        surveyInvitation.OptionsAllowGuestUserResponse = true;
                        surveyInvitation.ParticipantId = caso.ContactId;
                        surveyInvitation.CBK_Caso__c = caso.Id; 
                        surveyInvitations.add(surveyInvitation);
                    }
                    insert surveyInvitations;

                    
                    Set<Id> listaIdInvitaciones = new Set<Id> ();                
                    //Crear SurveySubject
                    List<SurveySubject> surveySubjects = new List<SurveySubject>();
                    for (Integer i = 0; i < casos.size(); i++) {
                        SurveySubject surveySubject = new SurveySubject();
                        surveySubject.SubjectId = casos[i].Id;         
                        surveySubject.ParentId = surveyInvitations[i].Id;
                        surveySubject.Name = 'Encuesta para el caso ' + casos[i].CaseNumber;
                        surveySubjects.add(surveySubject);
                        listaIdInvitaciones.add(surveyInvitations[i].Id);
                    }
                    insert surveySubjects;
                
                    // Obtener todas las SurveyInvitation
                    List<SurveyInvitation>  listSurveyInvitation = [SELECT Id, InvitationLink FROM SurveyInvitation WHERE Id IN :listaIdInvitaciones];			             
                    
                    //Actualizar URL de la encuesta en el caso
                    for (Integer i = 0; i < casos.size(); i++) {
                        String surveyInvitationLink;
                        for(Integer x = 0; x <listSurveyInvitation.size(); x++){
                            if(surveyInvitations[i].Id == listSurveyInvitation[x].Id){
                                surveyInvitationLink = listSurveyInvitation[x].InvitationLink;
                            }
                        }
                        casos[i].CC_Admin__c = true;
                        casos[i].CC_URL_Encuesta_3N__c = surveyInvitationLink;
                    }
                    update casos;
                    
                    List<OS_Canal_Procedencia__mdt> listmdtProcedencia = [SELECT Label, OS_OWA__c FROM OS_Canal_Procedencia__mdt];                
                    List<Task> tareas = new List<Task>();           
                    List<OrgWideEmailAddress> orgwides = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress];
                    
                    for (Case caso : casos) {
                        Id remitenteId;
                        for (OrgWideEmailAddress owa : orgwides) {
                            if (owa.Address.equals(caso.CC_Buzon_Salida__c)) {
                                remitenteId = owa.Id;
                            }
                        }
                    
                        Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
                        correo.setSaveAsActivity(true);
                        correo.setWhatId(caso.Id);                 
                        correo.setTemplateId(idiomaPlantilla.get(caso.CC_Idioma__c).Id);               
                        correo.setTargetObjectId(caso.ContactId);
                        correo.setTreatTargetObjectAsRecipient(true);
                        correo.setOrgWideEmailAddressId(remitenteId);

                         //Omitir validación trigger
                        CSBD_Bypass_Trigger.bypass('OS_EmailMessage_BI_TRHan_ValidarDestinatario');
                        try {
                            List<Messaging.SendEmailResult> result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correo});
                        }
                        finally {
                            CSBD_Bypass_Trigger.undoBypass('OS_EmailMessage_BI_TRHan_ValidarDestinatario');
                        }  
                    
                        Task tarea = new Task();
                        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
                        tarea.ActivityDate = System.today();
                        tarea.Status = 'Completed';
                        tarea.Type = 'Petición Encuesta Offline';
                        tarea.Subject = 'Envío de encuesta';
                        tarea.WhatId = caso.Id;
                        tareas.add(tarea);
                        
                    }
                        
                    insert tareas;
                }
            }
        }
    }
}