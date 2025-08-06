public with sharing class TMS_EmailService implements Messaging.InboundEmailHandler {

    /**
	 * Lectura del email para crear/actualizar el caso relacionado de SACH.
	 * @param email  email enviado
     * @param envelope  inforamción asociada con el email de entrada
	 */
    
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Id messageId =null;
        Id parentMessageId = null;
        Id idCaso = null;

        try {

            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            CBK_log.auditemail(email);
            //Miramos si el correo entrante tiene una semilla que coincide con alguna actividad de un caso ya existente
            String referencia = TMS_EmailService_Utils.referenciaCorreo(email);
            List<Task> tareaOrigen = new List<Task>();
            if (String.isNotBlank(referencia)) {
                //El correo es una respuesta a un correo saliente previo, se busca dicho correo
                Id tareaRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('TMS_Tarea').getRecordTypeId();
                tareaOrigen = [SELECT WhatId, Type FROM Task WHERE CC_Referencia_Correo_Saliente__c = :referencia
                                AND RecordTypeId = :tareaRTId WITH SECURITY_ENFORCED LIMIT 1];
            }

            EmailMessage correoEntrante = new EmailMessage();
            if (!tareaOrigen.isEmpty()){
                Case caso = [SELECT Status, ContactId, IsClosed FROM Case WHERE Id = :tareaOrigen[0].WhatId];
                correoEntrante = TMS_EmailService_Utils.gestionAdjuntos(email, caso, envelope.toAddress);
                TMS_EmailService_Utils.finalizarActividadCaso(caso.Id, 'Envio correo', null, null, email);
                parentMessageId=idCaso;
                messageId=correoEntrante.Id;
            }
            else { 
                //Para los emails que vengan sin semilla se quiere enviar una respuesta automática. Se quieren guardar estos emails en una lista.
                Id colaEntrante = null;
            	List<Group> colas = new List<Group>();
            	List<Group> colaGenerica = [SELECT Id, Name, DeveloperName, Type FROM Group WHERE DeveloperName = 'TMS_Testamentarias' AND Type = 'Queue' LIMIT 1];
                    if(!colaGenerica.isEmpty()) {
                        colaEntrante = colaGenerica[0].Id;
                    }
                
                String body = '';

                if (String.isNotBlank(email.plainTextBody)) {
                    body = email.plainTextBody.left(131072);
                } else if (String.isNotBlank(email.htmlBody)) {
                    body = email.htmlBody.stripHtmlTags().left(131072);
                }
                
                List<OrgWideEmailAddress> owa = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'TMS - No Reply' LIMIT 1];

                Case caso = new Case();
                caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'TMS_Expediente');
                caso.Origin = 'Email';
                caso.Subject = email.Subject.left(255);
                caso.Description = body.left(32000);
                caso.OwnerId = colaEntrante;
                if(!owa.isEmpty()){
                    caso.CC_Buzon_Salida__c = owa[0].Address;
                }
                caso.Status ='Rechazado email';
                
                insert caso;
                idCaso= caso.Id;
                parentMessageId=idCaso;
                correoEntrante = TMS_EmailService_Utils.gestionAdjuntos(email, caso, envelope.toAddress);

                messageId=correoEntrante.Id;
                
                Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
                EmailTemplate plantilla = new EmailTemplate();
                if (!Test.isRunningTest()) {
                    plantilla = [SELECT Id, Subject, HTMLValue FROM EmailTemplate WHERE Folder.DeveloperName = 'TMS_Operativas' AND Name = 'Respuesta automática' LIMIT 1];
                } else {
                    plantilla = [SELECT Id, Subject, HTMLValue FROM EmailTemplate WHERE Name = 'Respuesta automática' LIMIT 1];
                }
                
                correo.setTreatTargetObjectAsRecipient(false);
                correo.setHtmlBody(plantilla.HTMLValue);
                correo.setSubject(plantilla.Subject);
                correo.setSaveAsActivity(true);
                correo.setWhatId(idCaso);
                correo.setToAddresses(new List<String>{email.fromAddress});
                if(!owa.isEmpty()){
                    correo.setOrgWideEmailAddressId(owa[0].Id);
                }
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correo});
                
                
            }

                CBK_Log.ResultWrapper resultado = new CBK_Log.ResultWrapper();
                resultado.CaseId=idCaso;
                resultado.EmailMessageId=correoEntrante.Id;
                resultado.Status='OK';
                resultado.Detail='Correo enviado correctamente';

                
                CBK_Log.auditemailResult(resultado, email);
                
                
                return result;
            


        } catch (Exception e) {
            CBK_Log.error(e, 'Error en el envio de email', email);

            CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
            wResult.Status = 'KO';
            wResult.Detail = e.getMessage()?.left(255);
            wResult.CaseId = parentMessageId;
            wResult.EmailMessageId = messageId;
            CBK_Log.auditemailResult(wResult, email);
            throw e;
        }
    }
   
}