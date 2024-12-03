public class SACH_EmailService implements Messaging.InboundEmailHandler {

    /**
	 * Lectura del email para crear/actualizar el caso relacionado de SACH.
	 * @param email  email enviado
     * @param envelope  inforamción asociada con el email de entrada
	 */
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        // Trazabilidad para registrar la entrada del correo.
        try{
            CBK_Log.auditemail(email,envelope);
        }catch (Exception e){
            // Método sobrecargado para registrar errores en con el objeto Messaging.InboundEmail.
            CBK_Log.error(e,'Error registrando entrada correo',email);
        }
 
        Messaging.InboundEmailResult resultEmailService = new Messaging.InboundEmailresult();
        resultEmailService.success = false;
        
        String messageId =null;
        String parentMessageId = null;

        try {
            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            CBK_log.auditemail(email);

            //Miramos si el correo entrante tiene una semilla que coincide con alguna actividad de un caso ya existente
            String referencia = SACH_EmailService_Utils.referenciaCorreo(email);
            List<Task> tareaOrigen = new List<Task>();
            if (String.isNotBlank(referencia)) {
                //El correo es una respuesta a un correo saliente previo, se busca dicho correo
                tareaOrigen = [SELECT WhatId, Type FROM Task WHERE CC_Referencia_Correo_Saliente__c = :referencia
                                AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task') WITH SECURITY_ENFORCED LIMIT 1];
            }

            if (!tareaOrigen.isEmpty()) {
                if (tareaOrigen[0].Type == 'Traslado Colaborador') {
                    //Respuesta entrante de grupo colaborador
                    EmailMessage emailmessage = SACH_EmailService_Utils.respuestaTrasladoColaborador(email, tareaOrigen[0].WhatId, envelope.toAddress);
                    messageId = emailmessage.id;
                    parentMessageId = emailmessage.ParentId;
                } else if (tareaOrigen[0].Type == 'Remitir Colaborador') {
                    //Respuesta entrante de remisión del caso a grupo colaborador
                    EmailMessage emailmessage = SACH_EmailService_Utils.respuestaRemitirColaborador(email, tareaOrigen[0].WhatId, envelope.toAddress);
                    messageId = emailmessage.id;
                    parentMessageId = emailmessage.ParentId;
                } else{
					//Respuesta genérica
                    EmailMessage emailmessage = SACH_EmailService_Utils.respuestaGenerica(email, tareaOrigen[0].WhatId, envelope.toAddress, tareaOrigen[0]);
                    messageId = emailmessage.id;
                    parentMessageId = emailmessage.ParentId;
                }
            } else {
                //El correo ha llegado sin referencia o ésta no apunta a ninguna tarea, se crea nuevo caso

                //Identificación del cliente si hay una sola cuenta y contacto con el email remitente
                Id accountId = null;
                Id contactId = null;

                Map<Account, List<Contact>> mapaCuentasContactos = SACH_Identificacion_Auto.identificarCliente('Email', email.fromAddress); // Duplicamos "OS_Identificacion_Auto" para CAM para incluir colaboradores
                //El formato del resultado de la identificación automática es <Account, List<Contact>>

                if (mapaCuentasContactos.size() == 1 && mapaCuentasContactos.values()[0].size() == 1) {
                    Contact contactoIdentificado = mapaCuentasContactos.values()[0][0];
                    accountId = contactoIdentificado.AccountId;
                    contactId = contactoIdentificado.Id;
                }

                String canalProcedencia;

                //Creación de Caso
                Map<String, Object> campos = new Map<String, Object>();
                campos.put('Origin', 'Email');
                campos.put('Subject', email.Subject);
                campos.put('Description', String.isNotBlank(email.plainTextBody) ? email.plainTextBody.left(32000) : email.htmlBody.stripHtmlTags().left(32000));
                campos.put('AccountId', accountId);
                campos.put('ContactId', contactId);
                campos.put('CC_MailTelfNotif__c', email.fromAddress);
                campos.put('CC_Canal_Procedencia__c', canalProcedencia);

                List<SACH_Correos_Buzones_Entrada__mdt> correoDependencia = [SELECT SACH_Email_Redireccion_Buzon__c, SACH_Cola_Procedencia__c, SACH_Canal_Procedencia__c, SACH_RecordType_DeveloperName_defecto__c
                                                                                FROM SACH_Correos_Buzones_Entrada__mdt WHERE SACH_Email_Redireccion_Buzon__c = :envelope.toAddress WITH SECURITY_ENFORCED LIMIT 1];
                if (!correoDependencia.isEmpty()) {
                    canalProcedencia = correoDependencia[0].SACH_Canal_Procedencia__c;
                    List<Group> colas = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :correoDependencia[0].SACH_Cola_Procedencia__c WITH SECURITY_ENFORCED];
                    if (!colas.isEmpty()) {
                        campos.put('OwnerId', colas[0].Id);
                    }
                }

                Case caso = SACH_Case.crearCaso('SACH_Cliente', campos);
                SACH_EmailService_Utils.gestionAdjuntos(email, caso, envelope.toAddress);
                result.success = true;
            }

            // Retornamos los valores del Email
            CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
            wResult.Status = 'OK';
            wResult.Detail = 'Envio correcto';
            wResult.CaseId = parentMessageId;
            wResult.EmailMessageId = messageId;
            CBK_Log.auditemailResult(wResult, email);

            return result;

        } catch (Exception e) {

           CBK_Log.error(e, 'Error en el envio de email', email);
            //Trazabilidad Emailservice y emailmessage COE
            CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
            wResult.Status = 'KO';
            wResult.Detail = e.getMessage()?.left(255);
            wResult.CaseId = parentMessageId;
            wResult.EmailMessageId = messageId;
            CBK_Log.auditemailResult(wResult, email);
            return null;
        }
    }
}