public with sharing class GRR_EmailService implements Messaging.InboundEmailHandler {

    /**
	 * Lectura del email para crear/actualizar el caso relacionado de GRR.
	 * @param email  email enviado
     * @param envelope  inforamción asociada con el email de entrada
	 */
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        try {

            Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
            CBK_log.auditemail(email);

            //Miramos si el correo entrante tiene una semilla que coincide con alguna actividad de un caso ya existente
            String referencia = GRR_EmailService_Utils.referenciaCorreo(email);
            List<Task> tareaOrigen = new List<Task>();
            if (String.isNotBlank(referencia)) {
                //El correo es una respuesta a un correo saliente previo, se busca dicho correo
                tareaOrigen = [SELECT WhatId, Type FROM Task WHERE CC_Referencia_Correo_Saliente__c = :referencia
                                AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task') WITH SECURITY_ENFORCED LIMIT 1];
            }

            if (!tareaOrigen.isEmpty()) {
                if (tareaOrigen[0].Type == 'Traslado Colaborador') {
                    //Respuesta entrante de grupo colaborador
                    GRR_EmailService_Utils.respuestaTrasladoColaborador(email, tareaOrigen[0].WhatId, envelope.toAddress);
                } else if (tareaOrigen[0].Type == 'Remitir Colaborador') {
                    //Respuesta entrante de remisión del caso a grupo colaborador
                    GRR_EmailService_Utils.respuestaRemitirColaborador(email, tareaOrigen[0].WhatId, envelope.toAddress);
                } else if (tareaOrigen[0].Type == 'Responder a Cliente') {
                    //Respuesta entrante de cliente
                    GRR_EmailService_Utils.respuestaResponderCliente(email, tareaOrigen[0].WhatId, envelope.toAddress);
                } else if (tareaOrigen[0].Type == 'Solicitud Información') {
                    //Respuesta entrante de solicitud de información de cliente
                    GRR_EmailService_Utils.respuestaSolicitudInfo(email, tareaOrigen[0].WhatId, envelope.toAddress);
                } else{
					//Respuesta genérica
                    GRR_EmailService_Utils.respuestaGenerica(email, tareaOrigen[0].WhatId, envelope.toAddress, tareaOrigen[0]);
                }
            } else {
                //El correo ha llegado sin referencia o ésta no apunta a ninguna tarea, se crea nuevo caso

                //Identificación del cliente si hay una sola cuenta y contacto con el email remitente
                Id accountId = null;
                Id contactId = null;

                Map<Account, List<Contact>> mapaCuentasContactos = GRR_Identificacion_Auto.identificarCliente('Email', email.fromAddress);
                //El formato del resultado de la identificación automática es <Account, List<Contact>>

                if (mapaCuentasContactos.size() == 1 && mapaCuentasContactos.values()[0].size() == 1) {
                    Contact contactoIdentificado = mapaCuentasContactos.values()[0][0];
                    accountId = contactoIdentificado.AccountId;
                    contactId = contactoIdentificado.Id;
                }

                //Creación de Caso
                Map<String, Object> campos = new Map<String, Object>();
                campos.put('Origin', 'Automático');
                campos.put('Subject', email.Subject);
                campos.put('Description', String.isNotBlank(email.plainTextBody) ? email.plainTextBody.left(32000) : email.htmlBody.stripHtmlTags().left(32000));
                campos.put('AccountId', accountId);
                campos.put('ContactId', contactId);
                campos.put('CC_MailTelfNotif__c', email.fromAddress);

                Case caso = GRR_Case.crearCaso('GRR_Cliente', campos);
                GRR_EmailService_Utils.gestionAdjuntos(email, caso, envelope.toAddress);

                //Asignar canal de procedencia + owner del caso
                List<GRR_Correos_Buzones_Entrada__mdt> lstCorreoDependencia = [SELECT GRR_Email_Redireccion_Buzon__c, GRR_Cola_Procedencia__c, GRR_Canal_Procedencia__c, GRR_RecordType_DeveloperName_defecto__c
                                                                                FROM GRR_Correos_Buzones_Entrada__mdt WITH SECURITY_ENFORCED];

                List<GRR_Correos_Buzones_Entrada__mdt> correoDependencia = new List<GRR_Correos_Buzones_Entrada__mdt>();
                GRR_Correos_Buzones_Entrada__mdt correoDependenciaServiciosCentrales = new GRR_Correos_Buzones_Entrada__mdt();

                for (GRR_Correos_Buzones_Entrada__mdt correo : lstCorreoDependencia) {
                    if (correo.GRR_Email_Redireccion_Buzon__c != null && (envelope.toAddress).contains(correo.GRR_Email_Redireccion_Buzon__c)) {
                        correoDependencia.add(correo);
                    } else if (correo.GRR_Canal_Procedencia__c != null && (correo.GRR_Canal_Procedencia__c).contains('Servicios Centrales')){
                        correoDependenciaServiciosCentrales = correo;
                    }
                }
                
                if (!correoDependencia.isEmpty()) {
                    caso.CC_Canal_Procedencia__c = correoDependencia[0].GRR_Canal_Procedencia__c;
                    List<Group> colas = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :correoDependencia[0].GRR_Cola_Procedencia__c WITH SECURITY_ENFORCED LIMIT 1];
                    if (!colas.isEmpty()) {
                        caso.OwnerId = colas[0].Id;
                    }
                } else {
                    caso.CC_Canal_Procedencia__c = correoDependenciaServiciosCentrales.GRR_Canal_Procedencia__c;
                    List<Group> colaServiciosCentrales = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :correoDependenciaServiciosCentrales.GRR_Cola_Procedencia__c WITH SECURITY_ENFORCED LIMIT 1];
                    if (!colaServiciosCentrales.isEmpty()) {
                        caso.OwnerId = colaServiciosCentrales[0].Id;
                    }
                }

                update caso;

                result.success = true;
            }
            return result;

        } catch (Exception e) {
            CBK_EmailExceptions_TRHan.handledEmailServiceException(e, email);
            throw e;
        }
    }
}