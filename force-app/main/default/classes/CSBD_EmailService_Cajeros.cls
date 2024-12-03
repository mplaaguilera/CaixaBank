public with sharing class CSBD_EmailService_Cajeros implements Messaging.InboundEmailHandler {

	public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope envelope) {

		String messageId =null;
        String parentMessageId = null;
		
        try{
            if (!Test.isRunningTest()) {CBK_log.auditemail(email,envelope);}

			Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
			result.success = true;
			String cuerpo = '';

			//Se dan 20 caracteres de margen ya que se ha observado que con los 32000 teóricos a veces hay problemas
			if (String.isNotBlank(email.plainTextBody)) {
				cuerpo = email.plainTextBody.left(131052);
			} else if (String.isNotBlank(email.htmlBody)) {
				cuerpo = email.htmlBody.stripHtmlTags().left(131052);
			}
			Map<String, String> datos = parsearCuerpo(cuerpo);

			CSBD_WS_AltaOportunidad_Input.Solicitud solicitud = new CSBD_WS_AltaOportunidad_Input.Solicitud();			
			solicitud.buzonCajeros = true;

			if (email.subject.contains('Solicitud Desistimiento')) {
				solicitud.tipoSolicitud = 'desistimiento';

				//solicitud.referencia_usuario = datos.get('referencia_usuario');

				solicitud.usuclo = datos.get('USUCLO');
				solicitud.nombreProducto = datos.get('PRODUCTO');
				solicitud.nombre = datos.get('NOMBRE');
				solicitud.horarioContacto = datos.get('HORARIO_CONTACTO');
				solicitud.fechaContratacion = datos.get('FECHA_CONTRATACION');
				solicitud.telefono = datos.get('TELEFONO');
				solicitud.emailCliente = datos.get('EMAIL');
				solicitud.descripMotivo = datos.get('MOTIVO');
				solicitud.contrato = datos.get('CONTRATO');
				solicitud.canal = datos.get('CANAL');
				solicitud.nif = datos.get('NIF');
			} else {
				solicitud.tipoSolicitud = 'cmn';
				solicitud.tipoEnvio = datos.get('TipoEnvio');
				solicitud.idCampanya = datos.get('CodigoCampanya');
				solicitud.idProducto = datos.get('NombreProducto');
				solicitud.tipoCampanya = datos.get('TipoCampanya');
				solicitud.nif = datos.get('NIF/CIF');
				solicitud.numperso = datos.get('NumPersona');
				solicitud.nombre = datos.get('NombrePersona');
				solicitud.apellidos = datos.get('Apellido1_pers_contacto');
				solicitud.apellidos_2 = datos.get('Apellido2_pers_contacto');
				solicitud.idioma = datos.get('Idioma');
				solicitud.sexo = datos.get('Sexo');
				solicitud.codigoEmpleadoASF = datos.get('CodigoEmpleadoASF');
				solicitud.telefonoALF = datos.get('TelefonoAlf');
				solicitud.numOficina = datos.get('CodigoOficinaAdmin');
				solicitud.emailCliente = datos.get('EmailAlf');
				solicitud.telefonoContacto = datos.get('TelefonoContacto');
				solicitud.telefono = datos.get('TelefonoContacto');
				solicitud.horarioContacto = datos.get('HorarioContacto');
				solicitud.emailContacto = datos.get('EmailContacto');
				solicitud.canal = datos.get('CanalContacto');
				solicitud.diaPeticion = datos.get('DiaPeticion');
				solicitud.hora = datos.get('HoraPeticion');
				solicitud.comentarios = datos.get('Comentarios');
				solicitud.numTarjeta = datos.get('Num.Tarjeta');
				solicitud.oficinaCajero = datos.get('OficinaCajero');
				solicitud.leyenda = datos.get('Leyenda');
			}
			
			CSBD_WS_AltaOportunidad_Input entradaOportunidad = new CSBD_WS_AltaOportunidad_Input();
			entradaOportunidad.solicitudes = new List<CSBD_WS_AltaOportunidad_Input.Solicitud>{solicitud};			
			CSBD_WS_AltaOportunidad_Output resultado = CSBD_WS_AltaOportunidad.gestionEntradaOportunidad(entradaOportunidad, 'Buzón Cajeros');
			if (!resultado.respuestas.isEmpty() && String.isNotBlank(resultado.respuestas[0].opportunityId)) {
				Id idOportunidadCreada = resultado.respuestas[0].opportunityId; 
			
				//Creación del correo
				EmailMessage correo = new EmailMessage();
				correo.Headers = JSON.serialize(email.headers);
				correo.Incoming = true;
				correo.CC_Aplicacion__c = 'CSBD';
				correo.MessageDate = Datetime.now();
				correo.Status = '1'; //0: New, 1: Read, 2: Replied, 3: Sent, 4: Forwarded, 5: Draft
				correo.RelatedToId = idOportunidadCreada;
				correo.CSBD_Oportunidad_Id__c = idOportunidadCreada;
				correo.FromAddress = email.fromAddress;
				correo.FromName = email.fromName;
				correo.ToAddress = String.join(email.toAddresses, ', ');
				if (email.ccAddresses != null) {
					correo.CcAddress = String.join(email.ccAddresses, ', '); 
				}
				correo.Subject  = email.subject; 
				correo.HtmlBody = email.htmlBody;
				correo.TextBody = email.plainTextBody;
				insert correo;
                
                //Inserción id de email message
                messageId = correo.Id;
                parentMessageId = correo.RelatedToId;

				//Creación de la tarea
				Map<String, String> camposTarea = new Map<String, String>();
				camposTarea.put('TaskSubtype', 'Email');
				Task tarea = CSBD_Activity.crearActividad(idOportunidadCreada, 'Correo - Entrante', 'Completed', email.Subject, cuerpo.left(31980), camposTarea);
			}	
			
			CBK_Log.ResultWrapper wResult = new CBK_Log.ResultWrapper();
            wResult.Status = 'OK';
            wResult.Detail = 'Envio correcto';
            wResult.CaseId = parentMessageId;
            wResult.EmailMessageId = messageId;
            CBK_Log.auditemailResult(wResult, email);

            return result;
		}
		catch (Exception e){
            
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
	
	private static Map<String, String> parsearCuerpo(String cuerpo) {
		Map<String, String> resultado = new Map<String, String>();
		for (String linea : cuerpo.normalizeSpace().split('\\[')) {
			if (String.isNotBlank(linea)) {
				List<String> claveValor = linea.split('\\]', 2);
				String clave = claveValor[0].normalizeSpace();
				String valor = claveValor[1].normalizeSpace();
				resultado.put(claveValor[0].normalizeSpace().normalizeSpace(), claveValor[1].normalizeSpace());
			}
		}
		return resultado;
	}
}