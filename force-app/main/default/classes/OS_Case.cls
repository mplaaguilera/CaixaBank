public with sharing class OS_Case {

    public static Case duplicarCaso(Case casoPadre) {

        try {
            //clonar caso
            Case casoHijo = casoPadre.clone(false, true, false, false);
            casoHijo.ParentId = casoPadre.Id;
            insert casoHijo;

            //clonar correos electrónicos
            List<EmailMessage> correosCrear = new List<EmailMessage>();
            for (EmailMessage correo : [SELECT Headers, Incoming, FromName, FromAddress,
                                        ToAddress, CcAddress, Subject, TextBody, HtmlBody, Status, CC_Interno__c
                                        FROM EmailMessage WHERE ParentId = :casoPadre.Id]) {
                EmailMessage correoCopia = correo.clone(false, true, false, false);
                correoCopia.ParentId = casoHijo.Id;
                correosCrear.add(correoCopia);
            }
            insert correosCrear;
            
            //clonar tareas
            List<Task> tareasCrear = new List<Task>();

            for (Task tarea : [SELECT RecordTypeId, OwnerId, Subject, Type, Status, Description, AccountId, ActivityDate,
                                    CompletedDateTime, CC_Grupo_Colaborador_Id__c, CC_Tipo_Cierre__c, CC_Fecha_Inicio__c,
                                    CC_Fecha_Fin__c, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c, CC_Llamada_Id__c
                                FROM Task WHERE WhatId = :casoPadre.Id
                                AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task')]) {
                Task tareaCopia = tarea.clone(false, true, false, false);
                tareaCopia.WhatId = casoHijo.Id;
                tareasCrear.add(tareaCopia);
            }
            
            //nueva actividad de caso duplicado en el nuevo caso hijo 
            Task nuevaTarea = new Task();
            nuevaTarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
            nuevaTarea.WhatId = casoHijo.Id;
            nuevaTarea.Type = 'Duplicar caso';
            nuevaTarea.Subject = 'Duplicar caso';
            nuevaTarea.Status = 'Completed';
            nuevaTarea.ActivityDate = System.today();
            nuevaTarea.CC_Fecha_Inicio__c = System.now();
            nuevaTarea.CC_Fecha_Fin__c = System.now();
            nuevaTarea.Description = 'Caso principal: ' + casoPadre.CaseNumber;
            tareasCrear.add(nuevaTarea);

            insert tareasCrear;

            /* casoPadre.OS_Tiene_Casos_Relacionados__c = true;
            update casoPadre; */

            return casoHijo;

        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static void accionesCambioCanalProcedencia(Id idCaso, String canalProcedenciaAnterior) {
        Case caso = [SELECT CC_Cola_Procedencia__c, CC_Canal_Procedencia__c, OS_Canal_Procedencia_Anterior__c FROM Case WHERE Id = :idCaso];
        
        if (!String.isBlank(canalProcedenciaAnterior)) {
            caso.OS_Canal_Procedencia_Anterior__c = canalProcedenciaAnterior;
        }

        List<OS_Canal_Procedencia__mdt> colasProcedencia = [SELECT OS_Cola_Procedencia__c, OS_Canal_Procedencia__c FROM OS_Canal_Procedencia__mdt
                                                            WHERE OS_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c LIMIT 1];
        if (!colasProcedencia.isEmpty()) {
            caso.CC_Cola_Procedencia__c = colasProcedencia[0].OS_Cola_Procedencia__c;

        }
        update caso;

        //Crear actividad para dejar traza del cambio de procedencia
        OS_Activity.crearActividad(
            idCaso,
            'Canal de procedencia modificado',
            'Canal de procedencia modificado de ' + canalProcedenciaAnterior + ' a ' + caso.CC_Canal_Procedencia__c + '.'
        );
    }

    public static Case reapertura(Id idCaso) {
        //Reapertura caso (el estado pasa a Activo y se registra el motivo de reapertura en una nueva actividad)

        Case caso = [SELECT Status FROM Case WHERE Id = :idCaso];
        if (caso.Status != 'Activo') {
            caso.Status = 'Activo';
            caso.CC_Fecha_Reapertura__c = Datetime.valueOf(System.now());
            update caso;

            Task tareaReapertura = new Task();
            tareaReapertura.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
            tareaReapertura.WhatId = idCaso;
            tareaReapertura.Type = 'Reapertura por respuesta de cliente';
            tareaReapertura.Status = 'Completed';
            tareaReapertura.Subject = 'Reapertura por respuesta de cliente';
            tareaReapertura.Description = 'Reapertura por respuesta de cliente';
            tareaReapertura.ActivityDate = System.today();
            tareaReapertura.CC_Fecha_Inicio__c = System.now();
            insert tareaReapertura;
        }
        return caso;
    }
    /**
     * @description método para cerrar el caso después de la operativa responderCliente
     * @param caso
     * @return
     */
    public static Case responderCerrar(Case caso){
        if (caso.Status == 'Activo') {
            caso.Status = 'Cerrado';
            caso.OS_Cerrado_Operativa__c = false;
        }
        return caso;
    }

    public static void actualizarTelefonoEmailCaso(List<Case> listCasos) {

        Set<Id> setContactId = new Set<Id>();
        Map<Id, Contact> mapIdContacts = new Map<Id, Contact>();

        for(Case caso: listCasos){
            setContactId.add(caso.ContactId);
        }
        List<Contact> listaContactosCaso = [SELECT Id, Phone, Email FROM Contact WHERE Id = :setContactId];
        for(Contact contacto: listaContactosCaso){
            mapIdContacts.put(contacto.Id, contacto);
        }
        for(Case caso: listCasos){
            if(caso.ContactId == null){
                caso.OS_Telefono__c = null;
                caso.OS_Email__c = null;
            }
            else if(mapIdContacts.containsKey(caso.ContactId)){
                caso.OS_Telefono__c = mapIdContacts.get(caso.ContactId).Phone;
                caso.OS_Email__c = mapIdContacts.get(caso.ContactId).Email;
            }
        }
    }

    public static void actualizarTelefonosAccount(List<Case> listCasos) {

        Set<Id> setAccountID = new Set<Id>();
        Map<Id,Account> mapAccounts = new Map<Id,Account>();
        List<Case> listCasosSinAcc = new List<Case>();

        for(Case caso : listCasos){
            if(caso.AccountId != null){ 
                setAccountID.add(caso.AccountId);
            }else{
                listCasosSinAcc.add(caso);
            }
        }
        if(!setAccountID.isEmpty()){
            List<Account> listAccount = [SELECT Id, PersonMobilePhone, Phone FROM Account WHERE Id IN : setAccountID];
            if(!listAccount.isEmpty()){
                for(Account acc : listAccount){
                    mapAccounts.put(acc.Id,acc);
                }
                for(Case caso : listCasos){
                    if(mapAccounts.containsKey(caso.AccountId)){
                    caso.OS_Account_Mobile__c = mapAccounts.get(caso.AccountId).PersonMobilePhone;
                    caso.OS_Account_Phone__c = mapAccounts.get(caso.AccountId).Phone;
                    }
                }
            }
        }
        if(!listCasosSinAcc.isEmpty()){
            for(Case casoNoAcc : listCasosSinAcc ){
                casoNoAcc.OS_Account_Mobile__c = null;
                casoNoAcc.OS_Account_phone__c = null;
            }
        }
    }

    public static Id crearActividadRetipificacion(Id idCaso, String tematicaAnterior, String productoAnterior, String motivoAnterior) {
        Case caso = [SELECT CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name FROM Case WHERE Id = :idCaso LIMIT 1];

        if (motivoAnterior != null && motivoAnterior != '') {
            //Crear actividad
            String descripcion = 'Se ha retipificado el caso.\n\n';
            descripcion += 'Clasificación anterior:\n· Temática: '+ tematicaAnterior + '\n· Producto/Servicio: '+ productoAnterior + '\n· Motivo: '+ motivoAnterior + '\n\n';
            descripcion += 'Clasificación nueva:\n· Temática: '+ caso.CC_MCC_Tematica__r.Name + '\n· Producto/Servicio: '+ caso.CC_MCC_ProdServ__r.Name + '\n· Motivo: '+ caso.CC_MCC_Motivo__r.Name + '\n';

			return OS_Activity.crearActividad(idCaso, 'Reclasificación', 'Reclasificación del caso', descripcion, null).Id;
        } else {
            return null;
        }
    }

    @future(callout=true)
    public static void envioCorreoTrasladoRemitidoAutomatico(Set<Id> casosIds, Set<Id> MCCIds){
        
        System.debug('caso.Id: ' + casosIds);
        System.debug('mcc.Id: ' + MCCIds);

        //Traslados a colaborador automáticos que entran por EmailService
        List<Case> casos = [SELECT Id, CC_Buzon_Salida__c, CC_MCC_Motivo__c, CC_Referencia_Correo_Saliente__c FROM Case WHERE Id=: casosIds];

        List<CC_MCC_Grupo_Colaborador__c> listaMotivosGrupos = [SELECT CC_Grupo_Colaborador__c, CC_MCC__c  FROM CC_MCC_Grupo_Colaborador__c WHERE CC_MCC__c IN : MCCIds];
        List<CC_MCC_Plantilla__c> listaMotivosPlantilla = [SELECT CC_MCC__c, CC_MCC_Plantilla_DeveloperName__c  FROM CC_MCC_Plantilla__c WHERE CC_MCC__c IN : MCCIds];
                  
        if (!listaMotivosGrupos.isEmpty() && !listaMotivosPlantilla.isEmpty()){
                        
            Map<Id, Id> idMotivoGrupo = new Map<Id, Id>();
            for (CC_MCC_Grupo_Colaborador__c grupoMotivo : listaMotivosGrupos) {
                idMotivoGrupo.put(grupoMotivo.CC_MCC__c, grupoMotivo.CC_Grupo_Colaborador__c);
            }
                   
            Map<Id,List<String>> mapDestinatariosPara = new Map<Id,List<String>>();                                
            Map<Id,List<String>> mapDestinatariosCC = new Map<Id,List<String>>();                                
                          
            List<CC_Grupo_Colaborador_Contact__c> colaboradores = [SELECT CC_Para_CC__c, CC_Email__c, CC_Grupo_Colaborador__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Grupo_Colaborador__c = :idMotivoGrupo.values()];
            
            if (!colaboradores.isEmpty()){
                for (CC_Grupo_Colaborador_Contact__c colaborador : colaboradores) {
                                
                    if (colaborador.CC_Para_CC__c == 'Para') {
                        List<String> destinatariosPara = mapDestinatariosPara.containsKey(colaborador.CC_Grupo_Colaborador__c) && !mapDestinatariosPara.get(colaborador.CC_Grupo_Colaborador__c).isEmpty() ? mapDestinatariosPara.get(colaborador.CC_Grupo_Colaborador__c) : new List<String>();
                        if (!destinatariosPara.contains(colaborador.CC_Email__c)){
                            destinatariosPara.add(colaborador.CC_Email__c);
                        }
                        mapDestinatariosPara.put(colaborador.CC_Grupo_Colaborador__c, destinatariosPara);
                    } else if (colaborador.CC_Para_CC__c == 'CC') {
                        List<String> destinatariosCC = mapDestinatariosCC.containsKey(colaborador.CC_Grupo_Colaborador__c) && !mapDestinatariosCC.get(colaborador.CC_Grupo_Colaborador__c).isEmpty() ? mapDestinatariosCC.get(colaborador.CC_Grupo_Colaborador__c) : new List<String>();
                        if (!destinatariosCC.contains(colaborador.CC_Email__c)){
                            destinatariosCC.add(colaborador.CC_Email__c);
                        }
                        mapDestinatariosCC.put(colaborador.CC_Grupo_Colaborador__c, destinatariosCC);
                    }
                }
                                
                Map<Id, String> idMotivoPlantilla = new Map<Id, String>();                    
                for (CC_MCC_Plantilla__c plantillaMotivo : listaMotivosPlantilla) {
                    idMotivoPlantilla.put(plantillaMotivo.CC_MCC__c, plantillaMotivo.CC_MCC_Plantilla_DeveloperName__c);
                }
                    
                Map<String,String> mapPlantillaAsunto = new Map<String,String>();                                
                Map<String,String> mapPlantillaCuerpo = new Map<String,String>();     
                            
                List<EmailTemplate> plantillas = [SELECT Id, HtmlValue, Subject, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :idMotivoPlantilla.values()];
                for (EmailTemplate plantilla : plantillas) {
                    mapPlantillaAsunto.put(plantilla.DeveloperName, plantilla.Subject);
                    mapPlantillaCuerpo.put(plantilla.DeveloperName, plantilla.HtmlValue);
                }
                                
                //OrgWideEmailAddress
                Map<String,Id> mapOwa = new Map<String,Id>();
                List<OrgWideEmailAddress> owas = [SELECT Id, Address FROM OrgWideEmailAddress];
                for (OrgWideEmailAddress owa : owas) {
                    mapOwa.put(owa.Address, owa.Id);
                }
                                    
                List<Id> idsCasos = new List<Id>();
                List<Messaging.SingleEmailMessage> correosInsertar = new List<Messaging.SingleEmailMessage>();
                for (Case caso : casos) {
                    idsCasos.add(caso.Id);
                }
                                    
                Map<Id,Id> idEmailCaso = new Map<Id,Id>();
                Map<Id,List<ContentDocumentLink>> mapCasoContentDocLink = new Map<Id,List<ContentDocumentLink>>();
                Map<Id,ContentVersion> mapIdContentDocContentVersion = new Map<Id,ContentVersion>();
                List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
                Map<Id,Id> idsContents = new Map<Id,Id>();
                Set<Id> idsEmails = new Set<Id>();
                
                List<EmailMessage> correosVinculadosCaso = [SELECT Id, ParentId FROM EmailMessage WHERE ParentId IN :idsCasos];
                if (!correosVinculadosCaso.isEmpty()) {
                        for (EmailMessage correo : correosVinculadosCaso) {
                            idEmailCaso.put(correo.Id,correo.ParentId);
                            idsEmails.add(correo.Id);
                        }                           
                        if (!idsEmails.isEmpty()){
                            listaContentDocumentLink = [SELECT ContentDocumentId, ShareType, Id, contentdocument.Title, ContentDocument.FileType, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :idEmailCaso.keySet()];
                            if (!listaContentDocumentLink.isEmpty()) {
                                for (ContentDocumentLink cdl : listaContentDocumentLink) {
                                    if (!mapCasoContentDocLink.containsKey(idEmailCaso.get(cdl.LinkedEntityId))) {
                                        mapCasoContentDocLink.put(idEmailCaso.get(cdl.LinkedEntityId), new List<ContentDocumentLink>{cdl});
                                    } else {
                                        List<ContentDocumentLink> listaCdlCaso = mapCasoContentDocLink.get(idEmailCaso.get(cdl.LinkedEntityId));
                                        listaCdlCaso.add(cdl);
                                        mapCasoContentDocLink.put(idEmailCaso.get(cdl.LinkedEntityId), listaCdlCaso);
                                    }                            
                                    idsContents.put(cdl.Id, cdl.ContentDocumentId);                            
                                }
                                for (ContentVersion cv : [SELECT Title, VersionData, FileExtension, ContentDocumentId FROM ContentVersion
                                WHERE ContentDocumentId IN :idsContents.values()]) {
                                    mapIdContentDocContentVersion.put(cv.ContentDocumentId,cv);
                                }
                            }
                        }
                    }  
            
                for (Case caso : casos) {
                    caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente(caso.Id); 
                    String buzonSalida = caso.CC_Buzon_Salida__c;
                    if (buzonSalida != null) {     
                        //Para COPS la frase previa es siempre la misma
                        String textoCuerpo = mapPlantillaCuerpo.get(idMotivoPlantilla.get(caso.CC_MCC_Motivo__c));
                        textoCuerpo += '<br/><br/><font color="gray">';
                        textoCuerpo += 'Por favor, mantenga las siguientes referencias al responder a este correo electrónico: #@' + caso.CC_Referencia_Correo_Saliente__c + '#.';
                        textoCuerpo += '</font>';     

                        //Añado histórico de correos
                        textoCuerpo += '<br/>__________<br/><br/>';
                        textoCuerpo += CC_Case.historicoCorreosClienteCops(caso.Id, true);

                        //Creamos correo saliente
                        Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
                        correo.setOrgWideEmailAddressId(mapOwa.get(buzonSalida));
                        correo.setToAddresses(mapDestinatariosPara.get(idMotivoGrupo.get(caso.CC_MCC_Motivo__c)));
                        correo.setCcAddresses(mapDestinatariosCC.get(idMotivoGrupo.get(caso.CC_MCC_Motivo__c)));
                        correo.setTreatBodiesAsTemplate(true);
                        correo.setSubject(mapPlantillaAsunto.get(idMotivoPlantilla.get(caso.CC_MCC_Motivo__c)));
                        correo.setHtmlBody(textoCuerpo);
                        correo.setTreatTargetObjectAsRecipient(false);
                        correo.setWhatId(caso.Id);
                        correo.setSaveAsActivity(true);
                        
                        List<ContentDocumentLink> listaAdjuntosVinculadosCaso = mapCasoContentDocLink.get(caso.Id) == null ? new List<ContentDocumentLink>() : mapCasoContentDocLink.get(caso.Id);
                        if(!listaAdjuntosVinculadosCaso.isEmpty() || listaAdjuntosVinculadosCaso.size() == 0){      
                            List<Messaging.EmailFileAttachment> listEmailAttachment = new List<Messaging.EmailFileAttachment>();                       
                            for (ContentDocumentLink cdl : listaAdjuntosVinculadosCaso) {
                                ContentVersion cVersion = mapIdContentDocContentVersion.get(idsContents.get(cdl.Id));
                                //Rellenar contenido del adjunto
                                Blob bfile = cVersion.VersionData;
                                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();                        
                                efa.setFileName(cVersion.Title);
                                if (!cVersion.Title.contains('.'+cVersion.FileExtension)) {                        
                                    efa.setFileName(cVersion.Title + '.' + cVersion.FileExtension);
                                }
                                efa.setBody(bfile);
                                listEmailAttachment.add(efa);
                                
                            }
                            correo.setFileAttachments(listEmailAttachment);
                        }       
                        correosInsertar.add(correo);  
                    }    
                    caso.CC_Ultima_Interaccion__c = 'Traslado pendiente'; 
                }   
                Update casos;                                     
                        
                CSBD_Bypass_Trigger.bypass('OS_EmailMessage_BI_TRHan_ValidarDestinatario');
                try {
                List<Messaging.SendEmailResult> resultadoEnvio = Messaging.sendEmail(correosInsertar);
                for (Messaging.SendEmailResult result : resultadoEnvio) {
                    if (!result.success) {
                            CBK_log.debug('No se pudo enviar el correo: ' + result.errors[0].message);
                    } 
                }    
            }
                finally {
                    CSBD_Bypass_Trigger.undoBypass('OS_EmailMessage_BI_TRHan_ValidarDestinatario');
                }  
            }
        }              
    } 

    @future(callout=true)
    public static void trasladoColaboradorAutomatico(Id casoId, Id idGrupoColaborador, Id idPlantillaCorreo, String textoCuerpo, String textoAsunto, Set<Id> setIdContentDocumentLink) {
        
        //Traslados a colaborador de casos valija -- llama CC_ContentDocumentLink_AI_TRHan
        Case caso = [SELECT Id, Status, CC_Fecha_Traslado_Colaborador__c,CC_Grupo_Colaborador__c, CC_Referencia_Correo_Saliente__c, CC_Ultima_Interaccion__c  
                        FROM Case WHERE Id=:casoId];

        if (String.isNotBlank(idGrupoColaborador) && String.isNotBlank(idPlantillaCorreo)) {
            //Caso
            caso.Status = 'Pendiente Colaborador';
            caso.CC_Fecha_Traslado_Colaborador__c = Datetime.valueOf(System.now());
            caso.CC_Grupo_Colaborador__c = idGrupoColaborador;
            caso.CC_Referencia_Correo_Saliente__c = CC_EmailMessage.generarReferenciaCorreoSaliente(caso.Id); 
            caso.CC_Ultima_Interaccion__c = 'Traslado pendiente'; 

            //Tarea
            Task tarea = new Task();
            tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
            tarea.WhatId = caso.Id;
            tarea.Type = 'Traslado Colaborador';
            tarea.Subject = 'Traslado Colaborador';
            tarea.Status = 'Open';
            tarea.ActivityDate = System.today();
            tarea.Description = 'Traslado a colaborador automático';
            tarea.CC_Referencia_Correo_Saliente__c = caso.CC_Referencia_Correo_Saliente__c;
            tarea.CC_Grupo_Colaborador_Id__c = idGrupoColaborador;
            CC_Configuracion_Reclamaciones_Auto.informarFechasReclamacionesAuto(tarea);
            insert tarea;
            
            //Correo
            String buzonSalida = [SELECT CC_Buzon_Salida__c FROM Case WHERE Id = :caso.Id].CC_Buzon_Salida__c;
            
            List<String> destinatariosPara = new List<String>();                                
            List<String> destinatariosCC = new List<String>(); 
            for (CC_Grupo_Colaborador_Contact__c colaborador : [SELECT CC_Para_CC__c, CC_Email__c FROM CC_Grupo_Colaborador_Contact__c
                                                                WHERE CC_Grupo_Colaborador__c = :idGrupoColaborador]) {
                if (colaborador.CC_Para_CC__c == 'Para') {
                    destinatariosPara.add(colaborador.CC_Email__c);
                } else if (colaborador.CC_Para_CC__c == 'CC') {
                    destinatariosCC.add(colaborador.CC_Email__c);
                }
            }
            Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
            correo.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE Address = :buzonSalida LIMIT 1].Id);
            correo.setToAddresses(destinatariosPara);
            correo.setCcAddresses(destinatariosCC);
            correo.setTreatBodiesAsTemplate(true);
            correo.setSubject(textoAsunto);
            correo.setHtmlBody(textoCuerpo);
            correo.setTreatTargetObjectAsRecipient(false);
            correo.setWhatId(caso.Id);
            correo.setSaveAsActivity(true);

            //Adjuntos valija
            Set<Id> setContentDocumentIDs = new Set<Id>();                    
            List<ContentDocumentLink>  listaContentDocumentLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE Id IN :setIdContentDocumentLink];
            for (ContentDocumentLink cDocumentLink : listaContentDocumentLink) {
                setContentDocumentIDs.add(cDocumentLink.ContentDocumentId);
            }

            List<Messaging.EmailFileAttachment> listEmailAttachment = new List<Messaging.EmailFileAttachment>();
            for (ContentVersion cVersion : [SELECT Title, VersionData, FileExtension FROM ContentVersion
                                                WHERE ContentDocumentId IN :setContentDocumentIDs]) {
                    //Rellenar contenido del adjunto
                    Blob bfile = cVersion.VersionData;
                    Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();                        
                    efa.setFileName(cVersion.Title);
                    if (!cVersion.Title.contains('.'+cVersion.FileExtension)) {                        
                        efa.setFileName(cVersion.Title + '.' + cVersion.FileExtension);
                    }
                    efa.setBody(bfile);
                    listEmailAttachment.add(efa);
            }
            correo.setFileAttachments(listEmailAttachment);
            //Omitir validación trigger
            CSBD_Bypass_Trigger.bypass('OS_EmailMessage_BI_TRHan_ValidarDestinatario');
            try {
            List<Messaging.SendEmailResult> resultadoEnvio = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correo});
            if (!resultadoEnvio[0].success) {
                    CBK_log.debug('No se pudo enviar el correo: ' + resultadoEnvio[0].errors[0].message);
                }
            }
            finally {
                CSBD_Bypass_Trigger.undoBypass('OS_EmailMessage_BI_TRHan_ValidarDestinatario');
            }
            caso.CC_Referencia_Correo_Saliente__c = null;
            update caso;
        }
    }

    @future(callout=true)
    public static void actualizarFechaFinSLAMilestone(Set<Id> caseIds) {
        Map<Id, Datetime> caseIdTargetDate = new Map<Id, Datetime>();
        List<CaseMilestone> milestonesEnCurso = [SELECT CompletionDate, TargetDate, CaseId FROM CaseMilestone WHERE CaseId = :caseIds AND CompletionDate = null];
        for(CaseMilestone milestone: milestonesEnCurso) {
            caseIdTargetDate.put(milestone.CaseId, milestone.TargetDate);
        }
        
        List<Case> casosActualizarFechaFinSLA = [SELECT Id, OS_Fecha_Fin_Entitlement__c FROM Case WHERE Id =: caseIds];
        List<Case> casosUpdate = new List<Case>();
        for(Case caso: casosActualizarFechaFinSLA) {
            if(caseIdTargetDate.containsKey(caso.Id)) {
                Datetime fechaFinEntitlementMilestone = caseIdTargetDate.get(caso.Id);
                if(fechaFinEntitlementMilestone != caso.OS_Fecha_Fin_Entitlement__c) {
                    caso.OS_Fecha_Fin_Entitlement__c = fechaFinEntitlementMilestone;
                    casosUpdate.add(caso);
                } 
            }
        }
        Update casosUpdate;
    }
    @future(callout=true)
    public static void completarMilestonesCasoManual(Set<Id> caseIds) {
        //Casos actualizar campo OS_SLA_Completado__c
        Set<Id> casosSLACompletado = new Set<Id>();
        //Completa los milestones abiertos de los casos indicados
        List<CaseMilestone> milestonesEnCurso = [SELECT CompletionDate, TargetDate, CaseId FROM CaseMilestone WHERE CaseId IN :caseIds AND CompletionDate = null];
        if(!milestonesEnCurso.isEmpty()) {
            for(CaseMilestone milestone : milestonesEnCurso) {
                milestone.CompletionDate = System.now();
                if(milestone.CompletionDate < milestone.TargetDate) {
                    casosSLACompletado.add(milestone.CaseId);
                }
            }
            Update milestonesEnCurso;
            
            if(!casosSLACompletado.isEmpty()) {
                List<Case> casosUpdate = [SELECT Id, OS_SLA_Completado__c FROM Case WHERE Id = :casosSLACompletado];
                for(Case caso : casosUpdate) {
                    caso.OS_SLA_Completado__c = 'Completed';
                }
                Update casosUpdate;
            } 
        }  
    }
}