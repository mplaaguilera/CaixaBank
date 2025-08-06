public without sharing class GRR_Case_Merge {
    /**
     * @description método para fusionar los correos, actividades, adjuntos de los casos.
     * @param masterCaseId
     * @param idCasoSelected
     * @return String
     */
    @AuraEnabled
    public static String fusionarCaso(String masterCaseId, String idCasoSelected) {
        try {
            String resultado = 'Ok';
            Case casoOrigen = [SELECT CaseNumber, Subject , RecordTypeId, GRR_UR_Relacionada__c, AccountId, ContactId, OwnerId FROM Case WHERE Id = :masterCaseId WITH SECURITY_ENFORCED LIMIT 1];
            Case casoDestino = [SELECT CaseNumber, Subject, Status, IsClosed, RecordTypeId, GRR_UR_Relacionada__c, AccountId, ContactId, OwnerId FROM Case WHERE Id = :idCasoSelected WITH SECURITY_ENFORCED LIMIT 1];
            
            //Validación Record Type GRR
            Id grrCasoRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente');
            if ((casoDestino.RecordTypeId != grrCasoRecordTypeId) || (casoOrigen.RecordTypeId != grrCasoRecordTypeId)) {
                return 'Ambos casos deben ser de GRR.';
            }

            //Validación propietario
            if (casoOrigen.OwnerId != casoDestino.OwnerId) {
                return 'Debe ser el propietario de ambos casos de la fusión.';
            }

            
            //Buscamos los registros de carga asociados al caso origen para asociarlos al caso destino 
            List<GRR_RegistroCarga__c> listaRegistrosVinculadosCaso = [SELECT Id, GRR_Caso__c FROM GRR_RegistroCarga__c WHERE GRR_Caso__c = :casoOrigen.Id WITH SECURITY_ENFORCED];

            if (!listaRegistrosVinculadosCaso.isEmpty()) {
                List<GRR_RegistroCarga__c> listaRegistrosUpdate = new List<GRR_RegistroCarga__c>();

                for (GRR_RegistroCarga__c registroCarga : listaRegistrosVinculadosCaso) {
                    registroCarga.GRR_Caso__c = casoDestino.Id;
                    listaRegistrosUpdate.add(registroCarga);
                }
                if (!Schema.sObjectType.GRR_RegistroCarga__c.fields.GRR_Caso__c.isUpdateable()) {
                    return null;
                }
                Database.update(listaRegistrosUpdate, false);
            }


            //Buscamos los correos asociados al caso origen para asociarlos al caso destino
            List<EmailMessage> correosCasosFusionados = [SELECT Subject, htmlbody, textbody, RelatedToId, ParentId, CC_Grupo_Colab__c, CC_Interno__c,
                                                            CC_Procedencia__c, CC_Rechazado__c, CcAddress, BccAddress, CreatedDate, Fromaddress, FromName,
                                                            HasAttachment, Headers, Incoming, MessageDate, LastModifiedDate, LastModifiedById,
                                                            ReplyToEmailMessageId, Status, SystemModstamp, ToAddress, EmailTemplateId, OS_Email_Fusionado__c
                                                            FROM EmailMessage WHERE parentId = :casoOrigen.Id WITH SECURITY_ENFORCED];

            List<EmailMessage> correosCasosModificar = new List<EmailMessage>();
            List<Id> idsCorreoVinculadosAdjuntos = new List<Id>();
            if (!correosCasosFusionados.isEmpty()) {
                //Iteramos por primera vez la lista para crear los nuevos correos vinculados al caso master
                for (EmailMessage eMessage : correosCasosFusionados) {
                    EmailMessage clonEmailMessage = eMessage.clone(false, true, true, false);
                    clonEmailMessage.RelatedToId = casoDestino.Id;
                    clonEmailMessage.ParentId = casoDestino.Id;
                    clonEmailMessage.OS_Email_Fusionado__c = true;
                    correosCasosModificar.add(clonEmailMessage);
                    idsCorreoVinculadosAdjuntos.add(eMessage.Id);
                }
                if (!Schema.sObjectType.EmailMessage.fields.ParentId.isCreateable()) {
                    return null;
                }
                Database.insert(correosCasosModificar, false);

                if (!Schema.sObjectType.EmailMessage.isDeletable()) {
                    return null;
                }
                Database.delete(correosCasosFusionados, false);
            }

            //Buscamos las tareas completadas asociadas al caso origen para asociarlas al caso destino 
            List<Task> listaTareasCerradas = [SELECT Type FROM Task WHERE WhatId = :casoOrigen.Id AND Status != 'Open'
                                                WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];
            if (!listaTareasCerradas.isEmpty()) {
                for (Task tarea : listaTareasCerradas) {
                    tarea.WhatId = casoDestino.Id;
                }
                if (!Schema.sObjectType.Task.fields.WhatId.isUpdateable()) {
                    return null;
                }
                Database.update(listaTareasCerradas, false);
            }

            //Buscamos los archivos asociados al caso origen para asociarlos al caso destino 
            List<ContentDocumentLink> listaAdjuntosVinculadosCaso = [SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink
                                                                        WHERE LinkedEntityId = :casoOrigen.Id WITH SECURITY_ENFORCED];
            if (!listaAdjuntosVinculadosCaso.isEmpty()) {
                List<ContentDocumentLink> listaArchivosCasoMaster = new List<ContentDocumentLink>();
                List<ContentDocumentLink> listaArchivosEliminar = new List<ContentDocumentLink>();
                for (ContentDocumentLink cdl : listaAdjuntosVinculadosCaso) {
                    if(cdl.LinkedEntityId == casoOrigen.Id){
                        ContentDocumentLink nuevoCdl = cdl.clone();
                        nuevoCdl.LinkedEntityId = casoDestino.Id;
                        listaArchivosCasoMaster.add(nuevoCdl);
                        listaArchivosEliminar.add(cdl);
                    }
                }
                
                Database.delete(listaArchivosEliminar, false);

                if (!Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()) {
                    return null;
                }
                Database.insert(listaArchivosCasoMaster, false);
            }
            
            
            //Buscamos los participantes GRR asociados al caso origen para asociarlos al caso destino 
			List<GRR_Participante__c> listaParticipantesVinculadosCaso = [SELECT Id, GRR_Case_Participante__c, GRR_Cliente_Participante__c, GRR_Contacto_Participante__c, GRR_Informacion__c, RecordTypeId, GRR_Rol__c FROM GRR_Participante__c WHERE GRR_Case_Participante__c = :casoOrigen.Id WITH SECURITY_ENFORCED];
            
            if (!listaParticipantesVinculadosCaso.isEmpty()) {
                List<GRR_Participante__c> listaParticipantesClonados = new List<GRR_Participante__c>();

                for (GRR_Participante__c participante : listaParticipantesVinculadosCaso) {
                    GRR_Participante__c nuevoParticipante = participante.clone();
                    nuevoParticipante.GRR_Case_Participante__c = casoDestino.Id;
                    listaParticipantesClonados.add(nuevoParticipante);
                }
                Database.insert(listaParticipantesClonados, false);

                Database.delete(listaParticipantesVinculadosCaso, false);
            }
            
            
            //Creación de la tarea de Fusión
            Map<String, Object> campos = new Map<String, Object>();
            campos.put('WhatId', casoDestino.Id);
            campos.put('Type', 'Fusión de casos');
            campos.put('Subject', 'Fusión de casos');
            campos.put('Description', 'Fusión del caso ' + casoOrigen.CaseNumber + ' con el caso ' + casoDestino.CaseNumber);
            campos.put('ActivityDate', System.today());
            campos.put('Status', 'Completed');
            insert GRR_Activity.crearTarea('GRR_Task', campos);

            //Modificación campos del caso destino, si aplica
            Boolean updateCaso = false;
            if (casoDestino.IsClosed) {
                GRR_Case.reapertura(casoDestino.Id, 'Reactivado automáticamente por fusión de casos');
            } else if (casoDestino.Status == 'Pendiente Colaborador') {
                GRR_Activity.finalizarActividadCaso(casoDestino.Id, 'Traslado Colaborador', null, null);
                casoDestino.Status = 'Activo';
                casoDestino.CC_Fecha_Reapertura__c = Datetime.valueOf(System.now());
                updateCaso = true;
            }  else if (casoDestino.Status == 'Pendiente Cliente') {
                GRR_Activity.finalizarActividadCaso(casoDestino.Id, 'Solicitud Información', null, null);
                casoDestino.Status = 'Activo';
                casoDestino.CC_Fecha_Reapertura__c = Datetime.valueOf(System.now());
                updateCaso = true;
            }

            if((casoDestino.AccountId == null) && (casoDestino.ContactId == null)){
                casoDestino.AccountId = casoOrigen.AccountId;
                casoDestino.ContactId = casoOrigen.ContactId;
                updateCaso = true;
            }
            
            if(updateCaso){
                Database.update(casoDestino, false);
            }
            
            Database.delete(casoOrigen, false);
            return resultado;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}