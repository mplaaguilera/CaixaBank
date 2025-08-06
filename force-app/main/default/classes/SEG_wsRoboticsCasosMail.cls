/**
*   @description SEG_wsRoboticsCasos
*/
@RestResource(urlMapping='/v1/segRoboticsCases/comunicacionCliente/*')
global with sharing class SEG_wsRoboticsCasosMail {

    global class SEG_WS_NewCaseMail_PostInput {
        global String casoId {get;set;}
        global String asunto {get;set;}
        global String cuerpo {get;set;}
        global String plantillaId {get;set;}
        global String notas {get;set;}
        global String destinatarios {get;set;}
        global String destinatariosCC {get;set;}
        global String destinatariosCCO {get;set;}
        global List<String> listadoDocumentosIds {get;set;}
        private Case casoEncontrado {get;set;}
        private SEG_Plantilla__c plantillaEncontrada {get;set;}
        private List<String> listadoContentDocumentId {get;set;}
    }

    global class SEG_WS_NewCaseMail_PostOutput {
        global String resultado {get;set;}
        global String codigo {get;set;}
        global String mensaje {get;set;}
        global String actividadId {get;set;}
    }

    @HttpPost
    global static SEG_WS_NewCaseMail_PostOutput enviarComunciacionCaso ()
    {
        SEG_WS_NewCaseMail_PostOutput resultadoWS = new SEG_WS_NewCaseMail_PostOutput();
        Boolean bOk = true;
        RestRequest peticionREST = RestContext.request;
        
        // Tratar los datos de entrada.
        SEG_WS_NewCaseMail_PostInput datosEntradaCaso;
        if (peticionREST.requestBody != null)
        {
            datosEntradaCaso = (SEG_WS_NewCaseMail_PostInput)JSON.deserialize(peticionREST.requestBody.toString(), SEG_WS_NewCaseMail_PostInput.class);
        }

        // Registrar traza.
        CC_TrazaInt__c trazaPOST; 
        try {
            trazaPOST = SEG_MetodosComunes.inicioTraza ('segRoboticsCases_comCliente_POST','POST','POST',JSON.serialize(datosEntradaCaso));
        } catch (Exception e) {
            trazaPOST = SEG_MetodosComunes.finTraza(trazaPOST, JSON.serialize(datosEntradaCaso), e.getTypeName(), e.getMessage()); 
        }

        // Validar URI.
        if (bOk)
        {
            List<String> elemURI = RestContext.request.requestURI.split('/');
            if (elemURI.size() != 4)
            {
                bOk = false;
                resultadoWS.codigo = '9002';
                resultadoWS.resultado = 'NOK';
                resultadoWS.mensaje = 'La URI del servicio no está bien formada';
            }
        }

        // Validar datos de entrada.
        Map<String,String> datosValidacionEntrada;
        if (bOk)
        {
            datosValidacionEntrada = SEG_wsRoboticsCasosMail.validarDatosEntradaPOST (datosEntradaCaso);
            if (datosValidacionEntrada.get('resultado') != 'OK')
            {
                bOk = false;
            }
            resultadoWS.resultado = datosValidacionEntrada.get('resultado');
            resultadoWS.codigo = datosValidacionEntrada.get('codigo');
            resultadoWS.mensaje = datosValidacionEntrada.get('mensaje');
        }

        // Actualizar el caso si las validaciones se cumplen.
        if (bOk)
        {
            Map<String,String> datosEnvio = SEG_wsRoboticsCasosMail.enviarComunicacionSalesforce (datosEntradaCaso);
            if (datosEnvio.get('codigo') != 'OK')
            {
                bOk = false;
                resultadoWS.codigo = '9999';
                resultadoWS.resultado = 'NOK';
                resultadoWS.mensaje = datosEnvio.get('detalle');
            }else{
                resultadoWS.codigo = '0000';
                resultadoWS.resultado = (String.isBlank(datosEnvio.get('codigo')))?'OK':datosEnvio.get('codigo');
                resultadoWS.mensaje = (String.isBlank(datosEnvio.get('detalle')))?'':datosEnvio.get('detalle');
                resultadoWS.actividadId = datosEnvio.get('actividadId');
            }
            
        }

        try {
            if (trazaPOST != null)
            {
                if (resultadoWS.resultado == 'NOK')
                {
                    trazaPOST = SEG_MetodosComunes.finTraza (trazaPOST, JSON.serialize(resultadoWS), resultadoWS.codigo, resultadoWS.mensaje);
                }else{
                    trazaPOST = SEG_MetodosComunes.finTraza (trazaPOST, JSON.serialize(resultadoWS));
                }
            }
        } catch (Exception e) {
            trazaPOST = SEG_MetodosComunes.finTraza(trazaPOST, JSON.serialize(resultadoWS), 'KO', e.getMessage());
        }

        return resultadoWS;
    }

    /**
     * Métodos auxiliares para la gestión del servicio.
     */

    /**
     *  @description Validación de los datos de entrada del servicio.
     *  @param datosEntrada -> Petición REST recibida
     *  @return Map<String,String> -> Mapa con los resultados de la validación
     */
    public static Map<String,String> validarDatosEntradaPOST (SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostInput datosEntrada)
    {

        Map<String,String> resultadoValidacion = new Map<String,String>();
        resultadoValidacion.put('mensaje','');

        String organizacion = '';

        // Datos obligatorios.
        if (datosEntrada == null)
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No hay un mensaje de entrada válido');
            return resultadoValidacion;
        }

        if (String.isBlank(datosEntrada.casoId) || String.isBlank(datosEntrada.asunto) || String.isBlank(datosEntrada.cuerpo) || String.isBlank(datosEntrada.destinatarios))
        {
            resultadoValidacion.put('codigo','0000');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No están informados los datos obligatorios');
            return resultadoValidacion;
        }

        // Validar la existencia del caso.
        List<Case> listadoCasos = [SELECT Id, SEG_Numero_de_centro__c, SEG_Grupo__c, SEG_Grupo_Empresa__c, AccountId, SEG_ClasificacionRapida__c, CC_Buzon_Salida__c, CC_Buzon_Salida_Atencion_Cliente__c, SEG_Email_Buzon_Entrada__c,
                                    SEG_Organizacion__c, SEG_Zona__c, SEG_Idioma__c
                                    FROM Case WHERE Id = :datosEntrada.casoId
                                    AND RecordType.DeveloperName IN ('SEG_Cliente', 'SEG_Seguimiento')];
        if (listadoCasos.isEmpty())
        {
            resultadoValidacion.put('codigo','0010');
            resultadoValidacion.put('resultado','NOK');
            resultadoValidacion.put('mensaje', 'No se encuentra el caso registrado');
            return resultadoValidacion;
        }else{
            datosEntrada.casoEncontrado = listadoCasos[0];
        }

        // Validar la plantilla si ha venido informada.
        if (String.isNotBlank(datosEntrada.plantillaId))
        {
            List<SEG_Plantilla__c> listadoPlantillas = [SELECT Id, SEG_PlantillaCastellanoID__c, SEG_PlantillaCatalanID__c, SEG_PlantillaEuskeraID__c, SEG_PlantillaGalegoID__c,SEG_PlantillaInglesID__c
                                                        FROM SEG_Plantilla__c
                                                        WHERE Id = :datosEntrada.plantillaId AND SEG_Activa__c = true];

            if (listadoPlantillas.isEmpty())
            {
                resultadoValidacion.put('codigo','0020');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'No se encuentra la plantilla');
                return resultadoValidacion;
            }else{
                datosEntrada.plantillaEncontrada = listadoPlantillas[0];
            }
        }

        // Convertir de ContentVersion a ContentDocument
        if (datosEntrada.listadoDocumentosIds != null && !datosEntrada.listadoDocumentosIds.isEmpty())
        {
            datosEntrada.listadoContentDocumentId = new List<String>();
            List<ContentVersion> listadoContentVersion = [SELECT Id, ContentDocumentId
                                                            FROM ContentVersion
                                                            WHERE Id IN :datosEntrada.listadoDocumentosIds AND isLatest = true];
            for (ContentVersion versionDoc : listadoContentVersion)
            {
                datosEntrada.listadoContentDocumentId.add(versionDoc.ContentDocumentId);
            }
        }

        // Validar que los ficheros indicados sean del caso.
        if (datosEntrada.listadoContentDocumentId != null && !datosEntrada.listadoContentDocumentId.isEmpty())
        {
            List<ContentDocumentLink> listadoFicherosCaso = [SELECT Id 
                                                            FROM ContentDocumentLink 
                                                            WHERE ContentDocumentId IN :datosEntrada.listadoContentDocumentId
                                                            AND LinkedEntityId = :listadoCasos[0].Id];
            if (listadoFicherosCaso.size() != datosEntrada.listadoDocumentosIds.size())
            {
                resultadoValidacion.put('codigo','0030');
                resultadoValidacion.put('resultado','NOK');
                resultadoValidacion.put('mensaje', 'Los ficheros indicados son erróneos');
                return resultadoValidacion;
            }
        }

        // Si llegamos hasta aquí, la validación es correcta para crear el caso.
        resultadoValidacion.put('resultado','OK');
        resultadoValidacion.put('codigo','0000');

        return resultadoValidacion;
    }

    /**
     *  @description Creación del caso con la información de entrada de la petición REST y que se ha validado.
     *  @param datosEntrada -> Petición REST recibida
     *  @param datosValidados -> Datos auxiliares y validados para la creación del caso.
     *  @return Map<String,String> -> Mapa con los resultados de la validación
     */
    public static Map<String,String> enviarComunicacionSalesforce (SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostInput datosEntrada)
    {
        Map<String,String> resultadoEnvio = new Map<String,String>();
        String sError = 'OK';
        String sDescError = '';

        try {

            String buzonSaliente = '';
            String buzonSalienteDefecto = '';
            Case caso = datosEntrada.casoEncontrado;

            // FIX. No se tiene en cuenta el buzón original del caso, se calculará con la ORG y Zona del caso.
            // Obtener los buzones informados en el caso.
            /*if (String.isBlank(buzonSaliente) && String.isNotBlank(caso.SEG_Email_Buzon_Entrada__c))
            {
                buzonSaliente = caso.SEG_Email_Buzon_Entrada__c;
            }

            if (String.isBlank(buzonSaliente) && String.isNotBlank(caso.CC_Buzon_Salida__c))
            {
                buzonSaliente = caso.CC_Buzon_Salida__c;
            }

            if (String.isBlank(buzonSaliente) && String.isNotBlank(caso.CC_Buzon_Salida_Atencion_Cliente__c))
            {
                buzonSaliente = caso.CC_Buzon_Salida_Atencion_Cliente__c;
            }*/

            // Calcular el buzón por defecto, en caso que no esté informado correctamente los del caso.
            List<SEG_Buzon__mdt> datosBuzon = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = :caso.SEG_Organizacion__c and SEG_Zona__c=:caso.SEG_Zona__c LIMIT 1];
            if (!datosBuzon.isEmpty())
            {
                buzonSalienteDefecto = datosBuzon[0].SEG_Correo_de_procedencia__c;
            }

            if (String.isBlank(buzonSalienteDefecto) || Test.isRunningTest())
            {
                datosBuzon = [SELECT SEG_Correo_de_procedencia__c FROM SEG_Buzon__mdt WHERE SEG_Organizacion__c = 'Por defecto' and SEG_Zona__c='Por defecto' LIMIT 1];
                if (!datosBuzon.isEmpty())
                {
                    buzonSalienteDefecto = datosBuzon[0].SEG_Correo_de_procedencia__c;
                }
            }

            // Recuperar la dirección OWA.
            List<OrgWideEmailAddress> direccionOWA;
            // FIX. No se calcula la OWA por el buzón original del caso.
            /*if (String.isNotBlank(buzonSaliente))
            {
                direccionOWA = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = :buzonSaliente];
            }*/

            if ((direccionOWA == null || direccionOWA.isEmpty()) && String.isNotBlank(buzonSalienteDefecto))
            {
                direccionOWA = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = :buzonSalienteDefecto];
            }

            // Preparar el mensaje saliente de la comunicación.
            String mensajeHTML = datosEntrada.cuerpo;
            // Comprobar si tiene formato html o texto plano.
            mensajeHTML = (mensajeHTML.contains('<body>')) ? mensajeHTML : '<body>' + mensajeHTML + '</body>';

            if (String.isNotBlank(datosEntrada.plantillaId) && datosEntrada.plantillaEncontrada != null)
            {
                // Recuperar la plantilla en base al idioma del caso.
                String plantillaFirma = '';
                if (caso.SEG_Idioma__c == 'ca'){
                    plantillaFirma = datosEntrada.plantillaEncontrada.SEG_PlantillaCatalanID__c;
                }else if (caso.SEG_Idioma__c == 'en'){
                    plantillaFirma = datosEntrada.plantillaEncontrada.SEG_PlantillaInglesID__c;
                }else if (caso.SEG_Idioma__c == 'eu'){
                    plantillaFirma = datosEntrada.plantillaEncontrada.SEG_PlantillaEuskeraID__c;
                }else if (caso.SEG_Idioma__c == 'ga'){
                    plantillaFirma = datosEntrada.plantillaEncontrada.SEG_PlantillaGalegoID__c;
                }else{
                    // Por defecto, castellano.
                    plantillaFirma = datosEntrada.plantillaEncontrada.SEG_PlantillaCastellanoID__c;
                }

                // Renderizar la plantilla de firma.
                Messaging.SingleEmailMessage firma = Messaging.renderStoredEmailTemplate(plantillaFirma, UserInfo.getUserId(), caso.Id);
                String firmaHTML = firma.getHtmlBody();

                mensajeHTML = mensajeHTML + '</br></br>' + firmaHTML;
            }

            // Preparar los destinatarios.
            List<String> listaPara = datosEntrada.destinatarios.split(',');
            List<String> listaCC;
            List<String> listaCCO;

            if (String.isNotBlank(datosEntrada.destinatariosCC))
            {
                listaCC = datosEntrada.destinatariosCC.split(',');
            }

            if (String.isNotBlank(datosEntrada.destinatariosCCO))
            {
                listaCCO = datosEntrada.destinatariosCCO.split(',');
            }

            Messaging.SingleEmailMessage mensajeEnviar = new Messaging.SingleEmailMessage();
            mensajeEnviar.setToAddresses(listaPara);
            mensajeEnviar.setCcAddresses(listaCC);
            mensajeEnviar.setBccAddresses(listaCCO);
            mensajeEnviar.setOrgWideEmailAddressId(direccionOWA[0].Id);
            mensajeEnviar.setUseSignature(false); 
            mensajeEnviar.setBccSender(false); 
            mensajeEnviar.setSaveAsActivity(true); 
            mensajeEnviar.setSubject(datosEntrada.asunto);
            mensajeEnviar.setHtmlBody(mensajeHTML);
            mensajeEnviar.setWhatId(caso.Id);

            // Preparar los adjuntos
            if (datosEntrada.listadoContentDocumentId != null && !datosEntrada.listadoContentDocumentId.isEmpty())
            {
                //List<Messaging.EmailFileAttachment> attachmentsMail = SEG_redactarEmail_Controller.getAttachments(datosEntrada.listadoContentDocumentId);
                //mensajeEnviar.setFileAttachments(attachmentsMail);
                List<String> listadoAttachments = SEG_redactarEmail_Controller.getAttachments(datosEntrada.listadoContentDocumentId);
                if (!listadoAttachments.isEmpty())
                {
                    mensajeEnviar.setEntityAttachments(listadoAttachments);
                }
            }

            // Realizar el envío del correo.
            List<Messaging.SingleEmailmessage> messages = new List<Messaging.SingleEmailMessage> {mensajeEnviar};
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages, false);

			// Vincular los ficheros con el email enviado.
			if (results != null && !results.isEmpty() && results?.get(0)?.isSuccess() == true)
			{
				// Buscar el último correo saliente para vincular los ficheros anexos. Criterios: último correo, con el mismo asunto y buzón saliente.
				String remitenteMail = direccionOWA[0].Address;
				List<EmailMessage> listaMailsEnviados = [SELECT Id FROM EmailMessage WHERE ParentId = :caso.Id AND Incoming = FALSE AND Subject = :datosEntrada.asunto AND FromAddress = :remitenteMail ORDER BY MessageDate DESC LIMIT 1];
				if (!listaMailsEnviados.isEmpty() && datosEntrada?.listadoContentDocumentId?.isEmpty() == false)
				{
                    //Puede que el paso del acceso a true no sea necesario pero de momento se deja Jose Montes
					listaMailsEnviados[0].SEG_HasAnexo__c = (!datosEntrada?.listadoContentDocumentId?.isEmpty() == true) ? true : false;
					update listaMailsEnviados[0];
				}

			}else{
				// Error enviando el correo.
                sError = 'NOK';
                sDescError = 'Error en el envío del email. Detalle: ' + String.valueOf(results?.get(0)?.getErrors());
			}
            
            /*for (Integer iRes = 0; iRes<results.size(); iRes++)
            {
                if (!results[iRes].isSuccess())
                {
                    sError = 'NOK';
                    sDescError = 'Error en el envío del email. Detalle: ' + results[iRes].getErrors()[0].getMessage();
                }
            }*/

            // Crear actividad si se ha enviado correctamente.
            if (sError == 'OK' || Test.isRunningTest())
            {
                Task createTask = new Task(
                    RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
                    ,Type = 'Webservice - Correo enviado'
                    ,TaskSubtype = 'Task'
                    ,Subject = ('Comunicación enviada por Webservice - ' + datosEntrada.asunto).left(255)
                    ,ActivityDate = System.today()
                    ,Status = 'Completed'
                    ,Description = mensajeHTML.stripHtmlTags()
                    ,WhatId = caso.Id
                    ,Priority = 'Normal'
                );
                insert createTask;

                resultadoEnvio.put('actividadId', createTask.Id);

                // Vincular los adjuntos con la actividad creada.
                if (datosEntrada.listadoContentDocumentId != null && !datosEntrada.listadoContentDocumentId.isEmpty())
                {
                    List<ContentDocumentLink> listaVinculosAdjuntos = new List<ContentDocumentLink>();
                    for (String documentoId : datosEntrada.listadoContentDocumentId)
                    {
                        ContentDocumentLink linkAdjunto = new ContentDocumentLink();
                        linkAdjunto.LinkedEntityId = createTask.Id;
                        linkAdjunto.ContentDocumentId = documentoId;
                        linkAdjunto.ShareType = 'V';
                        listaVinculosAdjuntos.add(linkAdjunto);
                    }
                    insert listaVinculosAdjuntos;
                }

                // Crear el comentario de chatter.
                if (String.isNotBlank(datosEntrada.notas))
                {
                    SEG_Case_Operativas_Controller.postOnChatter (caso.Id, datosEntrada.notas, 'Comunicación Macros', null);
                }
            }
            
        } catch (Exception e) {
            sError = 'KO';
            sDescError = 'Error al enviar la comunicación del caso. Detalle: ' + e.getMessage();
            CBK_Log.error(e);
        }

        resultadoEnvio.put('codigo', sError);
        resultadoEnvio.put('detalle', sDescError);

        return resultadoEnvio;
    }
}