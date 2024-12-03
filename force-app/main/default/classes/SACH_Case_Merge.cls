public without sharing class SACH_Case_Merge {
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
            Case casoOrigen = [SELECT CaseNumber, Subject FROM Case WHERE Id = :masterCaseId WITH SECURITY_ENFORCED];
            Case casoDestino = [SELECT CaseNumber, Subject, Status, IsClosed, RecordType.DeveloperName FROM Case WHERE id = :idCasoSelected WITH SECURITY_ENFORCED];

            //Validamos que el caso que vamos a fusionar sea de SACH
            if (casoDestino.RecordType.DeveloperName.startsWith('SACH_')) {
                    casoDestino.Status = 'Activo';
            } else {
                return 'Solo es posible fusionar con casos de SACH.';
            }

            //Buscamos los correos asociados a los casos con los que vamos a fusionar el caso master
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
                Database.insert(correosCasosModificar);

                if (!Schema.sObjectType.EmailMessage.isDeletable()) {
                    return null;
                }
                Database.delete(correosCasosFusionados);
            }

            //TAREAS CERRADAS
            List<Task> listaTareasCerradas = [SELECT Type FROM Task WHERE WhatId = :casoOrigen.Id AND Status != 'Open'
                                                WITH SECURITY_ENFORCED ORDER BY CreatedDate ASC];
            if (!listaTareasCerradas.isEmpty()) {
                for (Task tarea : listaTareasCerradas) {
                    tarea.WhatId = casoDestino.Id;
                }
                if (!Schema.sObjectType.Task.fields.WhatId.isUpdateable()) {
                    return null;
                }
                Database.update(listaTareasCerradas);
            }

            List<ContentDocumentLink> listaAdjuntosVinculadosCaso = [SELECT LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink
                                                                        WHERE LinkedEntityId = :casoOrigen.Id WITH SECURITY_ENFORCED];
            if (!listaAdjuntosVinculadosCaso.isEmpty()) {
                List<ContentDocumentLink> listaArchivosCasoMaster = new List<ContentDocumentLink>();
                for (ContentDocumentLink cdl : listaAdjuntosVinculadosCaso) {
                    ContentDocumentLink nuevoCdl = cdl.clone();
                    nuevoCdl.LinkedEntityId = casoDestino.Id;
                    listaArchivosCasoMaster.add(nuevoCdl);
                }
                Database.delete(listaAdjuntosVinculadosCaso);

                if (!Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()) {
                    return null;
                }
                Database.insert(listaArchivosCasoMaster);
            }

            Map<String, Object> campos = new Map<String, Object>();
            campos.put('WhatId', casoDestino.Id);
            campos.put('Type', 'Fusión de casos');
            campos.put('Subject', 'Fusión de casos');
            campos.put('Description', 'Fusión del caso ' + casoOrigen.CaseNumber + ' con el caso ' + casoDestino.CaseNumber);
            campos.put('ActivityDate', System.today());
            campos.put('Status', 'Completed');
            insert SACH_Activity.crearTarea('SACH_Task', campos);

            if (casoDestino.IsClosed) {
                SACH_Case.reapertura(casoDestino.Id, 'Reactivado automáticamente por fusión de casos');
            } else if (casoDestino.Status == 'Pendiente Colaborador') {
                SACH_Activity.finalizarActividadCaso(casoDestino.Id, 'Traslado Colaborador', null, null);
            }
            Database.delete(casoOrigen);
            return resultado;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}