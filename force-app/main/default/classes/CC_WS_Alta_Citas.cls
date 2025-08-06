public with sharing class CC_WS_Alta_Citas {
    public static Map<String, Object> altaCita(String numOficina, String numPer, String fechaSeleccionada, String franjaSeleccionada, String asunto, String recordId, String tipoCita) {
        Map<String, Object> resultado = new Map<String, Object>();

        Case casoAltaCita = [SELECT Id, CC_Idioma__c, ContactId, Contact.Email, OwnerId, Account.Name, CaseNumber FROM Case WHERE Id = :recordId LIMIT 1];
        CC_Lista_Valores__c listaValorTareaCita = [SELECT Id, CC_Activa__c, CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE Name = 'Texto cita o tarea existe' LIMIT 1];
        Boolean existenTareasCitas = CC_Activity.identificarTareasCitasExistentes( casoAltaCita, listaValorTareaCita);

        if (String.isBlank(numPer)) {
            CBK_Log.error('Numperso no informado');
        }else if(!existenTareasCitas){
            try {
                CC_Settings__c configuracion = CC_Settings__c.getValues('CC_Configuracion_Cita_Rapida');
                //Blob digest = Crypto.generateDigest('SHA-256', Blob.valueOf(numPer + 'asesorVentas1'));//se quita por la US1169531
                Blob digest = Crypto.generateDigest('SHA-512', Blob.valueOf(numPer));
                String branchHashId = EncodingUtil.convertToHex(digest);
                Map<String, String> requestHeaders = getRequestHeaders();
                
                asunto = (tipoCita == String.valueOf(42) ? ' Cita presencial' : ' Cita telefónica') + ' - ' + asunto;
                Map<String, String> bodyRequest = new Map<String, String>();
                bodyRequest.put('branchId', numOficina);
                bodyRequest.put('reasonId', '999');
                bodyRequest.put('reasonText', asunto);
                bodyRequest.put('waitingRoomDate', fechaSeleccionada);
                bodyRequest.put('device', configuracion.CC_Configuracion_6__c);
                bodyRequest.put('slotStartTime', franjaSeleccionada.substring(0, 5));
                bodyRequest.put('reservationType', configuracion.CC_Configuracion_2__c);
                //bodyRequest.put('customerInternalId', numPer); //se quita por la US1169531
                bodyRequest.put('customerInternalHashId', branchHashId);
                String jsonBody = JSON.serialize(bodyRequest);

                CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
                integracion.intSetting = 'CC_Alta_Cita';
                integracion.mHeaders = requestHeaders;
                integracion.body = jsonBody;
                
                HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);

                HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, 'CC_WS_Alta_Citas', integracion.intSetting);
                
                if(response.getStatusCode() != 200 && response.getStatusCode() != 201) {
                    Map<String, Object> parsedError = new Map<String, Object>();
                    String detail = 'El servidor de Agendar Citas ha devuelto un error';
                    if (String.isNotBlank(response.getBody())) {
                        parsedError = (Map<String, Object>) JSON.deserializeUntyped(response.getbody());
                        detail = parsedError.containsKey('detail') ? (String) parsedError.get('detail') : 'El servidor de Agendar Citas ha devuelto un error';
                    }
                    CC_TrazaInt__c traza = CC_TrazaInt.generarTraza('CC_WS_Alta_Citas', request.getEndpoint(), String.valueOf(response.getStatusCode()), String.valueOf(request), detail, response.getBody(), false);
                    throw new AltaCitaCustomException(detail);
                } else {
                    String fechaConvertida = String.valueOf(Date.valueOf(fechaSeleccionada).day()) + '-' + 
                                            String.valueOf(Date.valueOf(fechaSeleccionada).month()) + '-' + 
                                            String.valueOf(Date.valueOf(fechaSeleccionada).year());
                    String mensaje = '';
                    Map<String, String> textosMap = new Map<String, String>();
                    List<CC_Lista_Valores__c> textos = [SELECT Name, CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'Textos operativa Derivar' AND CC_Activa__c = true];
                    for(CC_Lista_Valores__c texto : textos) {
                        textosMap.put(texto.Name, texto.CC_Mensajes_Mostrar__c);
                    }
                    if(tipoCita == '42') {
                        mensaje = textosMap.get('Toast cita rapida presencial').replace('XX:XX', franjaSeleccionada.substring(0, 5));
                        mensaje = mensaje.replace('XX', fechaConvertida);
                    } else {
                        mensaje = textosMap.get('Toast cita rapida telefonica').replace('XX:XX', franjaSeleccionada.substring(0, 5));
                        mensaje = mensaje.replace('XX', fechaConvertida);
                    }
                    resultado.put('mensaje', mensaje);
                    //Case casoAltaCita = [SELECT Id, CC_Idioma__c, ContactId, Contact.Email, OwnerId, Account.Name, CaseNumber FROM Case WHERE Id = :recordId LIMIT 1];
                    CC_Settings__c envioCorreoActivo = CC_Settings__c.getValues('CC_Configuracion_Cita_Rapida');

                    try {
                        crearTarea(casoAltaCita, asunto, fechaConvertida, franjaSeleccionada, tipoCita);
                        if(Boolean.valueOf(envioCorreoActivo.CC_Configuracion_1__c)) {
                            try {
                                enviarCorreo(casoAltaCita.CC_Idioma__c, recordId, casoAltaCita.ContactId, casoAltaCita.Contact.Email, fechaSeleccionada, franjaSeleccionada, asunto, tipoCita, casoAltaCita.Account.Name, casoAltaCita.caseNumber);
                                resultado.put('resultado', 'OK');
                            } catch (Exception e) {
                                resultado.put('resultado', 'KO');
                                resultado.put('resultadoMensaje', 'Ha habido un problema al enviar el correo');
                                CBK_Log.error(e);
                            }
                        } else {
                            resultado.put('resultado', 'OK');
                        }
                    } catch (Exception e) {
                        resultado.put('resultado', 'KO');
                        resultado.put('resultadoMensaje', 'Ha habido un problema al crear la tarea');
                        resultado.put('error', e);
                        CBK_Log.error(e);
                    }
                }
            } catch (Exception e) {
                resultado.put('resultado', 'KO');
                resultado.put('resultadoMensaje', 'Ha habido un problema con la integración');
                resultado.put('error', e);
                CBK_Log.error(e);
                throw new AuraException(e.getMessage());
            }
        }else{
            resultado.put('textoTareaCitaCreada', listaValorTareaCita.CC_Mensajes_Mostrar__c);
            resultado.put('existeTareaCitaCreada', true);
        }
        return resultado;
    }

    @AuraEnabled
    public static Map<String, Object> crearAltaCita(String numOficina, String numPer, String fechaSeleccionada, String franjaSeleccionada, String asunto, String recordId, String tipoCita) {
        return altaCita(numOficina, numPer, fechaSeleccionada, franjaSeleccionada, asunto, recordId, tipoCita);
    }

    private static void enviarCorreo(String idioma, String recordId, String contactId, String emailContact, String fechaSeleccionada, String franjaSeleccionada, String asunto, String tipoCita, String nombreCliente, String caseNumber) {
        Id idBuzonSalida = getBuzonSalidaId();
        List<Messaging.SingleEmailMessage> correos = new List<Messaging.SingleEmailMessage>();
        EmailTemplate plantilla = new EmailTemplate();

        if (idBuzonSalida == null) {
            throw new AuraHandledException('El buzón de salida no está configurado');
        }

        if(idioma == 'ca') {
            plantilla = [SELECT Subject, Id, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Plantilla_Cita_Rapida_ca' LIMIT 1];
        } else if(idioma == 'en') {
            plantilla = [SELECT Subject, Id, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Plantilla_Cita_Rapida_en' LIMIT 1];
        } else {
            plantilla = [SELECT Subject, Id, HTMLValue FROM EmailTemplate WHERE DeveloperName = 'Plantilla_Cita_Rapida_es' LIMIT 1];
        }

        if(fechaSeleccionada != null) {
            plantilla.HTMLValue = plantilla.HTMLValue.replace('(Fecha)', fechaSeleccionada);
        }
        if(franjaSeleccionada != null) {
            plantilla.HTMLValue = plantilla.HTMLValue.replace('(Hora)', franjaSeleccionada);
        }

        if(caseNumber != null) {
            plantilla.HTMLValue = plantilla.HTMLValue.replace('(caseNumber)', caseNumber);
        }

        if(tipoCita != null) {
            plantilla.HTMLValue = plantilla.HTMLValue.replace('(Tipo de cita)', tipoCita == String.valueOf(42) ? ' Cita presencial' : ' Cita telefónica');
        }
       
        if (emailContact != null) {
            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(plantilla.Id, UserInfo.getUserId(), recordId);
            Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
            String asuntoCorreo = renderStored.getSubject();
            asuntoCorreo += ' ' + (tipoCita == String.valueOf(42) ? ' Cita presencial' : ' Cita telefónica') + ' - ' + nombreCliente;
            correo.Subject = asuntoCorreo;
            correo.setHtmlBody(plantilla.HTMLValue);
            correo.setSaveAsActivity(true);
            correo.setWhatId(recordId);
            correo.setTargetObjectId(contactId);
            correo.setToAddresses(new List<String>{emailContact});
            correo.setOrgWideEmailAddressId(idBuzonSalida);
            correos.add(correo);
        }

        if (!correos.isEmpty()) {
            if (!Test.isRunningTest()) {
                Messaging.sendEmail(correos, false);
            } else {
                EmailMessage correoOrigen = new EmailMessage();
                correoOrigen.Subject = 'Prueba de envío de correo';     
                correoOrigen.CC_Procedencia__c = 'Responder Cliente';
                correoOrigen.FromAddress = 'prueba@ibm.com';
                correoOrigen.ToAddress = 'prueba@ibm.com';
                correoOrigen.Incoming = true;
                correoOrigen.ParentId = recordId;
                correoOrigen.RelatedToId = recordId;
                correoOrigen.Headers = '[{"value": "","name": "X-SFDC-Original-RCPT"}]';
                correoOrigen.HtmlBody = 'Cuerpo<br/>';
                insert correoOrigen;
            }
        }
    }

    private static void crearTarea(Case caso, String asunto, String fecha, String franja, String tipoCita) {
        String cita = tipoCita == String.valueOf(42) ? ' Cita presencial' : ' Cita telefónica';
        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        tarea.Subject = 'Cita gestor solicitada correctamente';
        tarea.Description = 'Se ha generado la cita correctamente.' + '\n' + '\n';
        tarea.Description += 'Asunto: ' + asunto + '\n';
        tarea.Description += 'Tipo de cita: ' + cita + '\n';
        tarea.Description += 'Fecha: ' + fecha + '\n';
        tarea.Description += 'Hora: ' + franja + '\n';
        tarea.Status = 'Completed';
        tarea.Priority = 'Normal';
        tarea.ActivityDate = date.today();
        tarea.WhatId = caso.Id;
        tarea.OwnerId = caso.OwnerId;
        tarea.Type = 'Cita rápida gestor';
        insert tarea;
        CBK_Activity_Extension__c tareaExtension = new CBK_Activity_Extension__c();
        tareaExtension.CC_Tipo_de_cita__c = tipoCita == String.valueOf(42) ? 'Cita presencial' : 'Cita telefónica';
        tareaExtension.AV_ActivityId__c = tarea.Id;
        insert tareaExtension;
    }
    
    private static Id getBuzonSalidaId() {
        String buzonDefecto = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE Label = 'Atención Cliente - ESP' AND CC_Activo__c = TRUE LIMIT 1]?.CC_Direccion_Correo__c;
        return [SELECT Id FROM OrgWideEmailAddress WHERE Address = :buzonDefecto LIMIT 1]?.Id;
    }

    private static Map<String, String> getRequestHeaders() {
		/* Ejemplo de headers:
			· Content-Type: application/json;charset=UTF-8
			· x-api-actor-simulated: CCSF 	(solo para previos)
			· HTTP-HEADER-ACTOR: CBCCSF 	(solo para previos)
		*/
		//Map<String, String> headers = new Map<String, String>{'HTTP-HEADER-ACTOR' => 'CBCCSF'};
        Map<String, String> headers = new Map<String, String>{'Content-Type' => 'application/json;charset=UTF-8'};
		if ([SELECT IsSandbox FROM Organization].IsSandbox) {
			for (CC_Lista_Valores__c lov : [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c
											WHERE CC_Lista__r.Name = 'Request headers específicos del sandbox'
											AND CC_Lista__r.CC_Activa__c = TRUE AND CC_Activa__c = TRUE]) {
				headers.put(lov.Name, lov.CC_Valor__c);
			}
		}
		return headers;
	}

    class AltaCitaCustomException extends Exception {}
}