public inherited sharing class CSBD_Opportunity {

	public class DefaultException extends Exception {}

	public static List<Opportunity> crearOportunidad(String recordTypeDeveloperName, List<Map<String, Object>> listaCampos) {
		Id idRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
		List<Opportunity> oportunidades = new List<Opportunity>();
		for (Map<String, Object> campos : listaCampos) {
			Opportunity oportunidad = new Opportunity();
			oportunidad.RecordTypeId = idRecordType;
			oportunidad.Name = 'temp'; //Se sobreescribe en el trigger AI
			oportunidad.CSBD_Estado__c = String.isNotBlank((String)campos.get('CSBD_Estado__c')) ? (String)campos.get('CSBD_Estado__c') : 'Nueva';
			oportunidad.StageName = String.isNotBlank((String)campos.get('StageName')) ? (String)campos.get('StageName') : 'Solicitud';
			oportunidad.CloseDate = System.today().addDays(diasFechaCierre(idRecordType));
			for (String campo : campos.keySet()) {
				oportunidad.put(campo, campos.get(campo));
			}
			oportunidades.add(oportunidad);
		}
		insert oportunidades;
		return oportunidades;
	}

	public static Opportunity crearOportunidad(String recordTypeDeveloperName, Map<String, Object> campos) {
		return crearOportunidad(recordTypeDeveloperName, new List<Map<String, Object>>{campos})[0];
	}

	public static Opportunity crearOportunidad(String recordTypeDeveloperName) {
		return crearOportunidad(recordTypeDeveloperName, new List<Map<String, Object>>{new Map<String, Object>()})[0];
	}

	public static void actualizarPropietarioOportunidadOmnichannel(Map<Id, Id> oportunidadIdOwnerId) {
		if (!oportunidadIdOwnerId.isEmpty()) {
			try {
				List<Opportunity> oportunidades = new List<Opportunity>();
				for (Id idOportunidad : oportunidadIdOwnerId.keySet()) {
					oportunidades.add(new Opportunity(Id = idOportunidad, OwnerId = oportunidadIdOwnerId.get(idOportunidad)));
				}
				CSBD_Bypass_Trigger.bypass('CC_Opportunity_AU_TRHan_Omnichannel'); //Omite lógica omnichannel del trigger AU
				update oportunidades;
				CSBD_Activity.crearActividadReasignacion(oportunidadIdOwnerId.keySet(), 'Reasignación automática', 'Oportunidad reasignada mediante Omnichannel.');
			} catch (Exception e) {
				CBK_Log.error(e);
			} finally {
				CSBD_Bypass_Trigger.undoBypass('CC_Opportunity_AU_TRHan_Omnichannel');
			}
		}

		/*
		List<Opportunity> oportunidadesActualizarOwner = [SELECT Id, OwnerId FROM Opportunity WHERE Id =: oportunidadIdOwnerId.keySet()];
		if(!oportunidadesActualizarOwner.isEmpty()) {
			for(Opportunity oportunidad: oportunidadesActualizarOwner) {
				oportunidad.OwnerId = oportunidadIdOwnerId.get(oportunidad.Id);
			}
			//Se omite lógica omnichannel del trigger AU
			//(Solo los cambios de propietario MANUALES se deben enviar a omnichannel para su baja)
			CSBD_Bypass_Trigger.bypass('CC_Opportunity_AU_TRHan_Omnichannel');
			try {
				update oportunidadesActualizarOwner;
				//Creamos actividad de reasignación
				CSBD_Activity.crearActividadReasignacion(oportunidadIdOwnerId.keySet(), 'Reasignación automática', 'Oportunidad reasignada mediante Omnichannel.');
			}
			finally {
				CSBD_Bypass_Trigger.undoBypass('CC_Opportunity_AU_TRHan_Omnichannel');
			}
		}
		*/
	}

	public static void indicarAltaBajaOmnichannelOportunidad(Set<Id> oportunidadesIdsAlta) {
		indicarAltaBajaOmnichannelOportunidad(oportunidadesIdsAlta, new Set<Id>());
	}

	public static void indicarAltaBajaOmnichannelOportunidad(Set<Id> oportunidadesIdsAlta, Set<Id> oportunidadesIdsBaja) {
		List<Opportunity> oportunidadesActualizar = [SELECT CSBD_Alta_omnichannel__c FROM Opportunity
														WHERE (CSBD_Alta_omnichannel__c = FALSE AND Id IN :oportunidadesIdsAlta)
														OR (CSBD_Alta_omnichannel__c = true AND Id IN :oportunidadesIdsBaja)];
		if (!oportunidadesActualizar.isEmpty()) {
			for (Opportunity oportunidad : oportunidadesActualizar) {
				if (oportunidad.CSBD_Alta_omnichannel__c) {
					oportunidad.CSBD_Alta_omnichannel__c = false;
				} else {
					oportunidad.CSBD_Alta_omnichannel__c = true;
				}
			}
			update oportunidadesActualizar;
		}
	}

	public static Integer diasFechaCierre(Id recordTypeId) {
		String recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(recordTypeId).getName();
		try {
			return Integer.valueOf(CC_Listas_Valores.lookupValue('CSBD: Días cierre oportunidad por defecto', recordType));
		} catch (Exception e) {
			return 3;
		}
	}

	public static Integer diasFechaCierre(String recordTypeName) {
		try {
			return Integer.valueOf(CC_Listas_Valores.lookupValue('CSBD: Días cierre oportunidad por defecto', recordTypeName));
		} catch (Exception e) {
			return 3;
		}
	}

	public static String historicoCorreosOportunidad(Id idOpportunity) {
		String resultado = '';
		List<EmailMessage> correos = new List<EmailMessage>();
		correos = [SELECT MessageDate, FromAddress, ToAddress, CcAddress, Subject, HtmlBody
					FROM EmailMessage WHERE CSBD_Oportunidad_Id__c = :idOpportunity ORDER BY CreatedDate DESC];
		for (Integer i = 0; i < correos.size(); i++) {
			EmailMessage correo = correos[i];
			if (correo.HtmlBody != '' && correo.HtmlBody != null) {
				resultado += '<font color="gray">De: ' + correo.FromAddress + '<br/>';
				resultado += 'Enviado el: ' + formatearFecha(correo.MessageDate) + '<br/>';
				resultado += 'Para: ' + correo.ToAddress + '<br/>';
				if (correo.CcAddress != null) {
					resultado += 'Con copia a:' + correo.CcAddress + '<br/>';
				}
				resultado += 'Asunto: ' + correo.Subject + '</font><br/><br/>' + correo.HtmlBody;
				if (i < correos.size() - 1) {
					//Si no es el último correo incluye un separador
					resultado += '<br/>__________<br/><br/>';
				}
			}
		}
		return resultado;
	}

	private static String formatearFecha(Datetime fecha) {
		List<String> diasEN = new List<String>{'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
		List<String> diasES = new List<String>{'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'};

		List<String> mesesEN = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
		List<String> mesesES = new List<String>{'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'};

		String retorno = diasES.get(diasEN.indexOf(fecha.format('EEE'))) + ', ' + fecha.day() + ' de ';
		retorno += mesesES.get(mesesEN.indexOf(fecha.format('MMM'))) + ' de ' + fecha.year() + ' ' + fecha.format('HH:mm');
		return retorno;
	}

	public static String obtenerReferenciaCorreo(Id idOportunidad) {
		return String.valueOf(idOportunidad).right(3) + DateTime.now().format('YYYYMMddHHmmss');
	}

	public static Opportunity cerrarOportunidad(Id idOportunidad, String nombreEtapaVentas, String resolucion) {
		return cerrarOportunidad(new List<Id>{idOportunidad}, nombreEtapaVentas, resolucion, null)[0];
	}

	public static Opportunity cerrarOportunidad(Id idOportunidad, String nombreEtapaVentas, String resolucion, Map<String, Object> campos) {
		return cerrarOportunidad(new List<Id>{idOportunidad}, nombreEtapaVentas, resolucion, campos)[0];
	}

	public static List<Opportunity> cerrarOportunidad(List<Id> idOportunidades, String nombreEtapaVentas, String resolucion, Map<String, Object> campos) {
		List<Opportunity> oportunidades = [SELECT RecordType.DeveloperName, CSBD_Estado__c, CSBD_Identificador__c,
											CSBD_Alta_omnichannel__c, CSBD_Empresa_Proveedora__c, CSBD_Resolucion__c,
											CSBD_Contact__c, CSBD_DeliveryInternalName__c, CSBD_CampaignId__c, CSBD_JourneyActionId__c,
											CSBD_MessageProfileId__c, CSBD_Now_NUMPERSO__c, CSBD_Motivo_MAC__c FROM Opportunity WHERE Id IN :idOportunidades];
		return cerrarOportunidad(oportunidades, nombreEtapaVentas, resolucion, campos);
	}

	public static List<Opportunity> cerrarOportunidad(List<Opportunity> oportunidades, String nombreEtapaVentas, String resolucion) {
		return cerrarOportunidad(oportunidades, nombreEtapaVentas, resolucion, null);
	}

	public static List<Opportunity> cerrarOportunidad(List<Opportunity> oportunidades, String nombreEtapaVentas, String resolucion, Map<String, Object> campos) {
		if (nombreEtapaVentas != 'Formalizada' && nombreEtapaVentas != 'Perdida' && nombreEtapaVentas != 'Rechazada') {
			throw new DefaultException('No es posible cerrar una oportunidad si la etapa de ventas no es final (' + nombreEtapaVentas + ').');
		}

		Set<Id> idOportunidadesPendienteCliente = new Set<Id>();
		List<Id> idOportunidadesDesistimiento = new List<Id>();
		Set<Id> idBajasGestorOportunidad = new Set<Id>();
		List<Opportunity> oportunidadesTraspasadas = new List<Opportunity>();

		for (Opportunity oportunidad : oportunidades) {
			if (oportunidad.RecordType.DeveloperName == 'CSBD_MAC' && String.isBlank(oportunidad.CSBD_Motivo_MAC__c)) {
				throw new DefaultException('No es posible cerrar una oportunidad CSCC si el campo "Motivo CSCC" no está informado.');
			}

			if (oportunidad.CSBD_Estado__c == 'Pendiente Cliente') {
				idOportunidadesPendienteCliente.add(oportunidad.Id);
			}
			oportunidad.StageName = nombreEtapaVentas;
			oportunidad.CSBD_Resolucion__c = resolucion;
			oportunidad.CloseDate = System.today();
			oportunidad.CSBD_Estado__c = nombreEtapaVentas != 'Rechazada' ? 'Cerrada' : 'Rechazada';
			if (nombreEtapaVentas == 'Perdida' || nombreEtapaVentas == 'Rechazada') {
				oportunidad.Loss_Reason__c = resolucion;
			}
			//Campos adicionales
			if (campos != null) {
				for (String campo : campos.keySet()) {
					oportunidad.put(campo, campos.get(campo));
				}
			}
			if (oportunidad.RecordType.DeveloperName == 'CSBD_Desistimiento'
			|| oportunidad.RecordType.DeveloperName == 'CSBD_DesistimientoPAI') {
				idOportunidadesDesistimiento.add(oportunidad.Id);
			} else if (oportunidad.RecordType.DeveloperName == 'CSBD_PROAutomatica'
			&& (nombreEtapaVentas == 'Formalizada' || nombreEtapaVentas == 'Perdida')
			&& oportunidad.CSBD_Now_NUMPERSO__c != null && oportunidad.CSBD_Now_NUMPERSO__c != '') {
				CSBD_Adobe_Campaign.enviarFuture(JSON.serialize(oportunidad));
			}

			//Oportunidades a dar de baja en omnichannel
			if (oportunidad.CSBD_Alta_omnichannel__c && (oportunidad.CSBD_Estado__c == 'Rechazada' || oportunidad.CSBD_Estado__c == 'Cerrada')) {
				idBajasGestorOportunidad.add(oportunidad.Id);
			}
			if (oportunidad.CSBD_Resolucion__c == 'Traspasada a Imagin' && oportunidad.CSBD_Empresa_Proveedora__c == 'imaginBank') {
				oportunidadesTraspasadas.add(oportunidad);
			}
		}
		update oportunidades;

		//Damos de baja en en GestorOportunidad (el trigger no se vuelve a ejecutar)
		if (!idBajasGestorOportunidad.isEmpty()) {
			CSBD_GestorOportunidad.desactivarGestorOportunidad(idBajasGestorOportunidad);
		}

		//Cierre de las tareas "Pendiente Cliente"
		if (!idOportunidadesPendienteCliente.isEmpty()) {
			List<Task> tareasPendienteCliente = [SELECT Id FROM Task WHERE WhatId IN :idOportunidadesPendienteCliente
													AND Type = 'Pendiente Cliente' AND Status = 'Open'];
			for (Task tareaPendienteCliente : tareasPendienteCliente) {
				tareaPendienteCliente.Status = 'Completed';
				tareaPendienteCliente.CC_Fecha_Fin__c = System.now();
			}
			update tareasPendienteCliente;
		}

		//Creación de tareas
		List<Task> tareasInsert = new List<Task>();
		for (Opportunity oportunidad : oportunidades) {
			tareasInsert.add(CSBD_Activity.crearActividadReturn(
				new Task(), oportunidad.Id, oportunidad.CSBD_Estado__c, 'Completed', oportunidad.CSBD_Estado__c, null, null
			));
		}
		insert tareasInsert;

		//Envio email traslado Imagin
		if (!oportunidadesTraspasadas.isEmpty()) {
			traspasarOportunidadesImagin(oportunidadesTraspasadas);
		}
		//Automatismos desistimientos
		if (!idOportunidadesDesistimiento.isEmpty()) {
			CSBD_Desistimiento.cerrarDesistimiento(idOportunidadesDesistimiento);
		}
		return oportunidades;
	}

	public static void traspasarOportunidadesImagin(List<Opportunity> oportunidadesTraspasadas) {
		List<String> destinatarios = new List<String>();
		for (CC_Lista_Valores__c destinatario : [SELECT CC_Valor__c FROM CC_Lista_Valores__c
													WHERE CC_Lista__r.Name = 'CSBD: Traspaso Imagin - Destinatarios'
													AND Name = 'CMB' AND CC_Activa__c = TRUE LIMIT 1]) {
			destinatarios.add(destinatario.CC_Valor__c);
		}
		Id idBuzonSalida = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'CSBD - CaixaBank Informa'].Id;
		Id idPlantilla = [SELECT Id FROM EmailTemplate WHERE Name = 'CSBD Traspaso CMB Imagin' LIMIT 1].Id;
		List<Messaging.SingleEmailMessage> envioEmails = new List<Messaging.SingleEmailMessage>();

		for (Opportunity oportunidad : oportunidadesTraspasadas) {
			Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
			CSBD_MetodosComunes.enviarCorreoReturnCorreo(correo, oportunidad.Id, oportunidad.CSBD_Contact__c, idBuzonSalida, idPlantilla, destinatarios);
			envioEmails.add(correo);
		}
		if (!envioEmails.isEmpty()) {
			Messaging.sendEmail(envioEmails);
		}
	}

	public static Opportunity reactivarOportunidad(Id idOportunidad) {
		return reactivarOportunidad(idOportunidad, null, false);
	}

	public static Opportunity reactivarOportunidad(Id idOportunidad, Boolean tomarPropiedad) {
		return reactivarOportunidad(idOportunidad, null, tomarPropiedad);
	}

	public static Opportunity reactivarOportunidad(Id idOportunidad, String nombreEtapaVentas) {
		return reactivarOportunidad(idOportunidad, nombreEtapaVentas, true);
	}

	public static Opportunity reactivarOportunidad(Id idOportunidad, String nombreEtapaVentas, Boolean tomarPropiedad) {
		//No quitar campos de esta consulta, los usa el modal de reactivación al leer la oportunidad devuelta
		List<Opportunity> oportunidades = [SELECT CSBD_Identificador__c, CSBD_Estado__c, CSBD_Ultima_Etapa_Ventas__c, (SELECT StageName, CSBD_Ultima_Etapa_Ventas__c FROM CSBD_Oportunidades_Hijas__r WHERE StageName = 'Rechazada')
												FROM Opportunity WHERE Id = :idOportunidad];

		List<Opportunity> actualizarOportunidades = new List<Opportunity>();

        for(Opportunity oportunidad : oportunidades) {
			actualizarOportunidades.add(reactivarOportunidad(oportunidad, nombreEtapaVentas, tomarPropiedad, true));

			for(Opportunity oportunidadHija: oportunidad.CSBD_Oportunidades_Hijas__r){
				actualizarOportunidades.add(reactivarOportunidad(oportunidadHija, nombreEtapaVentas, tomarPropiedad, false));
			}
        }

		if(!actualizarOportunidades.isEmpty()){
			update actualizarOportunidades;
		}

		CSBD_Activity.crearActividad(idOportunidad, 'Reactivación', 'Completed', 'Reactivación', '', null);
		return actualizarOportunidades[0];
	}

	public static Opportunity reactivarOportunidad(Opportunity oportunidad, String nombreEtapaVentas, Boolean tomarPropiedad, Boolean padre){
		if (tomarPropiedad) {
			oportunidad.OwnerId = UserInfo.getUserId();
		}

		if (nombreEtapaVentas != null && padre) {
			oportunidad.StageName = nombreEtapaVentas;
		} else if (oportunidad.CSBD_Ultima_Etapa_Ventas__c != null && oportunidad.CSBD_Ultima_Etapa_Ventas__c != 'Rechazada') {
			oportunidad.StageName = oportunidad.CSBD_Ultima_Etapa_Ventas__c;
		} else {
			oportunidad.StageName = 'Solicitud';
		}

		oportunidad.CSBD_Estado__c = 'Activa';
		oportunidad.CSBD_Resolucion__c = '';
		oportunidad.Loss_Reason__c = '';

		return oportunidad;
	}

	public static EmailTemplate prepararOportunidadParaEnvioCorreo(Id idOportunidad, String developerNamePlantilla, Boolean informarReferenciaCorreo, Boolean pendienteCliente) {
		EmailTemplate plantilla = [SELECT Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = :developerNamePlantilla];
		if (informarReferenciaCorreo) {
			String referencia = CSBD_Opportunity.obtenerReferenciaCorreo(idOportunidad);
			Opportunity oportunidad = new Opportunity(Id = idOportunidad);
			oportunidad.CSBD_Referencia_Correo_Saliente__c = referencia;
			oportunidad.CSBD_Dejar_Pendiente_Cliente__c = pendienteCliente;
			oportunidad.CSBD_Plantilla_Correo__c = developerNamePlantilla;
			update oportunidad;

			plantilla.HtmlValue += '<br/><br/><span style="font-family: \'Arial\'; font-size: 12px; color: gray;">';
			plantilla.HtmlValue += 'Por favor, mantenga la siguiente referencia al responder a este correo electrónico: #@' + referencia + '#.';
			plantilla.HtmlValue += '</span>';
		}
		plantilla.HtmlValue += CSBD_EmailMessage.historicoCorreosOportunidad(idOportunidad);
		return plantilla;
	}

	public static List<Opportunity> actualizarNombreOportunidades(List<Opportunity> oportunidades) {
		Map<Id, Schema.RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
		for (Opportunity oportunidad : oportunidades) {
			String recordTypeName = recordTypeInfos.get(oportunidad.RecordTypeId).getName();
			oportunidad.Name = oportunidad.CSBD_Identificador__c + ' - ' + recordTypeName;
		}
		return oportunidades;
	}

	public static Opportunity pendienteInterno(Id idOportunidad, String motivoPendienteInterno) {
		Opportunity oportunidad = new Opportunity(Id = idOportunidad);
		oportunidad.CSBD_Estado__c = 'Pendiente Interno';
		oportunidad.CSBD_Motivo_Pendiente_Interno__c = motivoPendienteInterno;
		update oportunidad;
		return oportunidad;
	}

	public static String asignacionIWD(String idOportunidad, String interactionId) {
		return null;
	}

	public static Opportunity duplicarOportunidad(Opportunity oportunidadOrigen, String recordTypeDeveloperName, String empresa) {
		//Clonar e insertar nueva oportunidad
		Opportunity oportunidadDestino = oportunidadOrigen.clone(false, true, false, false);
		oportunidadDestino.CSBD_Parent_Id__c = oportunidadOrigen.Id;
		oportunidadDestino.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', recordTypeDeveloperName);
		oportunidadDestino.CSBD_Estado__c = 'Activa';
		oportunidadDestino.StageName = 'Solicitud';
		oportunidadDestino.Loss_Reason__c = null;
		oportunidadDestino.CSBD_Resolucion__c = null;
		oportunidadDestino.CSBD_Empresa_Proveedora__c = empresa;
		oportunidadDestino.CSBD_Fecha_Firma__c = null;
		insert oportunidadDestino;

		//Nueva actividad de oportunidad clonada en la nueva oportunidad hija
		CSBD_Activity.crearActividad(
			oportunidadDestino.Id,
			'Clonar oportunidad',
			'Completed',
			'Clonar oportunidad',
			'Oportunidad padre: ' + oportunidadOrigen.CSBD_Identificador__c
		);
		return oportunidadDestino;
	}

	public static void oportunidadPendienteCliente(Map<Id, Id> mapaOportunidadesCorreosPendCliente) {
		List<Opportunity> oportunidades = [SELECT CSBD_Estado__c, CSBD_Referencia_Correo_Saliente__c, CSBD_Dejar_Pendiente_Cliente__c
											FROM Opportunity WHERE Id IN :mapaOportunidadesCorreosPendCliente.keySet()];
		for (Opportunity oportunidad : oportunidades) {
			if (oportunidad.CSBD_Estado__c == 'Activa' && oportunidad.CSBD_Dejar_Pendiente_Cliente__c) {
				Map<String, String> camposTarea = new Map<String, String>();
				camposTarea.put('CC_Referencia_Correo_Saliente__c', oportunidad.CSBD_Referencia_Correo_Saliente__c);
				camposTarea.put('CSBD_Email_Pendiente_Cliente__c', mapaOportunidadesCorreosPendCliente.get(oportunidad.Id));
				Task tarea = CSBD_Activity.crearActividad(oportunidad.Id, 'Pendiente Cliente', 'Open', 'Pendiente Cliente', null, camposTarea);
				oportunidad.CSBD_Estado__c = 'Pendiente Cliente';
				oportunidad.CSBD_Reactivada_Respuesta_Recibida__c = false;
			}
		}
		update oportunidades;
	}

	public static void oportunidadFinPendienteCliente(Id idOportunidad) {
		Opportunity oportunidad = [SELECT CSBD_Estado__c FROM Opportunity WHERE Id = :idOportunidad];
		if (oportunidad.CSBD_Estado__c == 'Pendiente Cliente') {
			CSBD_Activity.cerrarActividadPendienteCliente(oportunidad.Id);
			oportunidad.CSBD_Estado__c = 'Activa';
			oportunidad.CSBD_Reactivada_Respuesta_Recibida__c = true;
			update oportunidad;
		}
	}

	public static Event programarCita(Id idOportunidad, Boolean asignacionAuto, Id idPropietario, Datetime startDateTime) {
		return programarCita(idOportunidad, asignacionAuto, false, idPropietario, startDateTime, startDateTime.addMinutes(30));
	}

	public static Event programarCita(Id idOportunidad, Boolean asignacionAuto, Boolean comprobarContacto, Id idPropietario, Datetime startDateTime) {
		return programarCita(idOportunidad, asignacionAuto, comprobarContacto, idPropietario, startDateTime, startDateTime.addMinutes(30));
	}

	private static Event programarCita(Id idOportunidad, Boolean asignacionAuto, Boolean comprobarContacto, Id idPropietario, Datetime startDateTime, Datetime endDateTime) {
		Opportunity oportunidadAsociada = [SELECT Name, RecordType.DeveloperName FROM Opportunity WHERE Id = :idOportunidad];

		Event nuevoEvento = new Event();
		nuevoEvento.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Event', 'CSBD_Cita_Cliente');
		nuevoEvento.Type = 'Cita con cliente';
		nuevoEvento.WhatId = idOportunidad;
		nuevoEvento.Subject = 'Cita - ' + oportunidadAsociada.Name;
		nuevoEvento.StartDateTime = startDateTime;
		nuevoEvento.EndDateTime = endDateTime;
		nuevoEvento.CSBD_Evento_Estado__c = 'Pendiente';

		Opportunity oportunidad = new Opportunity(Id = idOportunidad);
		oportunidad.CSBD_Estado__c = 'Pendiente Cita';
		oportunidad.CSBD_Fecha_Cita__c = startDateTime;

		if (!String.isBlank(idPropietario)) {
			oportunidad.OwnerId = idPropietario;
			nuevoEvento.OwnerId = idPropietario;
		} else {
			//Se marca el evento como pendiente de asignación automática externa -- se enviará a omnichannel en la reactivación
			oportunidad.CSBD_Asignacion_Auto_Pendiente__c = true;
			oportunidad.OwnerId = [SELECT Id FROM User WHERE UserName LIKE 'csbd_generico@cc-caixabank.com%'].Id;
			nuevoEvento.OwnerId = [SELECT Id FROM Calendar WHERE Name = 'Citas pendientes de reasignar' LIMIT 1].Id;
		}
		if (comprobarContacto) {
			nuevoEvento.CC_Detalles_Consulta__c = 'Contactado';
			if (oportunidadAsociada.RecordType.DeveloperName != 'CSBD_Hipoteca') {
				oportunidad.CSBD_Motivo_Pendiente_Interno__c = 'Contactado';
			}
		} else {
			nuevoEvento.CC_Detalles_Consulta__c = 'No Contactado';
			if (oportunidadAsociada.RecordType.DeveloperName != 'CSBD_Hipoteca') {
				oportunidad.CSBD_Motivo_Pendiente_Interno__c = 'No Contactado';
			}
		}
		insert nuevoEvento;
		update oportunidad;

		//Cambio de PB a FW - Ejecución de citas pendientes: Inserto registros en CBK_SCH_PendingProcess__c para programar acciones
		//Programar cita en CSBD_Fecha_Cita__c
		CBK_SCH_PendingProcess__c pendingProcessCita = new CBK_SCH_PendingProcess__c();
		pendingProcessCita.RecordId__c = oportunidad.Id;
		pendingProcessCita.Schedule_Time__c = oportunidad.CSBD_Fecha_Cita__c;
		pendingProcessCita.ClassName__c = 'CBK_SCH_CSBD_SchedulePendienteCita';
		insert pendingProcessCita;

		//la llamada a omnichannel para el alta se añade en finalizarCita() cuando esta se cumple
		return nuevoEvento;
	}

	public static Event finalizarCita(List<FinalizarClienteInput> finalizaciones, Boolean cancelacionManual) {
		Map<Id, FinalizarClienteInput> mapaFinalizaciones = new Map<Id, FinalizarClienteInput>();
		for (FinalizarClienteInput finalizacion : finalizaciones) {
			if (cancelacionManual && finalizacion.nuevoEstado != 'Completado' && finalizacion.nuevoEstado != 'Cancelado') {
				throw new DefaultException('Debe indicar un tipo de finalización.');
			} else if (cancelacionManual && finalizacion.nuevoEstado == 'Cancelado' && String.isBlank(finalizacion.motivoCancelado)) {
				throw new DefaultException('Debe especificar un motivo para cancelar la cita.');
			}
			mapaFinalizaciones.put(finalizacion.idOportunidad, finalizacion);
		}

		//Actualizar eventos de las oportunidades
		List<Event> eventosPendientes = [SELECT WhatId, StartDateTime FROM Event WHERE RecordType.DeveloperName = 'CSBD_Cita_Cliente'
											AND WhatId IN :mapaFinalizaciones.keySet() AND CSBD_Evento_Estado__c = 'Pendiente'
											ORDER BY StartDateTime DESC];
		for (Event evento : eventosPendientes) {
			evento.CSBD_Evento_Estado__c = mapaFinalizaciones.get(evento.WhatId).nuevoEstado;
			if (mapaFinalizaciones.get(evento.WhatId).nuevoEstado == 'Completado') {
				evento.CC_Tipo_Cierre__c = 'Completado';
			} else {
				evento.CC_Tipo_Cierre__c = mapaFinalizaciones.get(evento.WhatId).motivoCancelado;
			}
		}
		update eventosPendientes;

		List<CSBD_Gestor_Oportunidad__c> gestoresOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c, CSBD_Oportunidad__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c  IN :mapaFinalizaciones.keySet()];
		Map<Id, CSBD_Gestor_Oportunidad__c> mapaGestoresOportunidad = new Map<Id, CSBD_Gestor_Oportunidad__c>();

		if(!gestoresOportunidad.isEmpty()) {
			for (CSBD_Gestor_Oportunidad__c gestor : gestoresOportunidad) {
			mapaGestoresOportunidad.put(gestor.CSBD_Oportunidad__c, gestor);}
		}

		//Actualizar oportunidades
		List<Opportunity> oportunidadesAltaOmnichannel = new List<Opportunity>();

		Set<Id> oportunidadesIds = new Set<Id>();

		List<Opportunity> oportunidades = [SELECT Name, CSBD_Asignacion_Auto_Pendiente__c, CSBD_Empresa_Proveedora__c,
											CSBD_Idioma_Solicitud__c, RecordtypeId, RecordType.Name, CSBD_Turno_Contacto__c,
											CSBD_Familia_Producto__c, CSBD_Skill__c, CSBD_Horario_Contacto__c,
											CSBD_Alta_omnichannel__c, CSBD_OC_Canal_Entrada__c, CSBD_OC_Prioridad__c,OwnerId
											FROM Opportunity WHERE Id IN :mapaFinalizaciones.keySet()];

		List<CSBD_Gestor_Oportunidad__c> gestoresOportunidadActualizar = new List<CSBD_Gestor_Oportunidad__c>();

		for (Opportunity oportunidad : oportunidades) {
			//La cita tiene lugar
			if (!cancelacionManual) {
				oportunidad.CSBD_Fecha_ultimacita__c = System.now();
				if (oportunidad.CSBD_Asignacion_Auto_Pendiente__c) {
					oportunidadesAltaOmnichannel.add(oportunidad);
					oportunidadesIds.add(oportunidad.Id);
				} else {
					CSBD_Gestor_Oportunidad__c gestor = mapaGestoresOportunidad.get(oportunidad.Id);
					if (gestor != null) {
						gestor.OwnerId = oportunidad.OwnerId;
						gestor.CSBD_Estado__c = 'Activo';
						gestoresOportunidadActualizar.add(gestor);
					}
				}
			}
			oportunidad.CSBD_Estado__c = 'Activa';
			oportunidad.CSBD_Fecha_Cita__c = null;
			oportunidad.CSBD_Asignacion_Auto_Pendiente__c = false;
		}
		update gestoresOportunidadActualizar;
		update oportunidades;

		//Para las oportunidades para las que ha tenido lugar la cita y se había solicitado reasignación automática en su reapertura -- alta omnichannel
		if (!oportunidadesAltaOmnichannel.isEmpty()) {
			CSBD_GestorOportunidad.activarGestorOportunidad(oportunidadesAltaOmnichannel, oportunidadesIds, 'Pendiente de asignar'); //el estado no se debe recalcular, pendiente asignar!!!!!
		}

		//Para el caso de la cancelación manual se retorna el evento actualizado
		//(en este caso la lista solo tendrá una oportunidad)
		return eventosPendientes.isEmpty() ? null : eventosPendientes[0];
	}

	public static Event finalizarCita(Id idOportunidad, String nuevoEstado, String motivoCancelado, Boolean cancelacionManual) {
		FinalizarClienteInput finalizacion = new FinalizarClienteInput();
		finalizacion.idOportunidad = idOportunidad;
		finalizacion.nuevoEstado = nuevoEstado;
		finalizacion.motivoCancelado = motivoCancelado;
		return finalizarCita(new List<FinalizarClienteInput>{finalizacion}, true);
	}

	public static void finalizarCita(List<FinalizarClienteInput> input) {
		finalizarCita(input, false);
	}

	public class FinalizarClienteInput {
		public Id idOportunidad;
		public String nuevoEstado;
		public String motivoCancelado;
	}

	public static Event agendarFirma(Id idOportunidad, Boolean tipoFirma, Datetime startDateTime) {
		return agendarFirma(idOportunidad, tipoFirma, startDateTime, startDateTime.addMinutes(60));
	}

	public static Event agendarFirma(Id idOportunidad, Boolean tipoFirma, Datetime startDateTime, Datetime endDateTime) {
		Opportunity oportunidadAsociada = [SELECT Name, OwnerId FROM Opportunity WHERE Id = :idOportunidad];

		Event nuevoEvento = new Event();
		nuevoEvento.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('CSBD_Firma_Cliente').getRecordTypeId();
		nuevoEvento.Type = 'Firma Cliente';
		nuevoEvento.WhatId = idOportunidad;
		nuevoEvento.Subject = 'Firma - ' + oportunidadAsociada.Name;
		nuevoEvento.StartDateTime = startDateTime;
		nuevoEvento.EndDateTime = endDateTime;
		nuevoEvento.CSBD_Evento_Estado__c = 'Pendiente';
		nuevoEvento.OwnerId = oportunidadAsociada.OwnerId;
		insert nuevoEvento;

		oportunidadAsociada.CSBD_Fecha_Firma__c = startDateTime;
		oportunidadAsociada.CSBD_Firma_segura__c = tipoFirma;
		update oportunidadAsociada;

		return nuevoEvento;
	}

	public static Event cancelarFirma(Id idOportunidad) {
		Opportunity oportunidad = [SELECT CSBD_Fecha_Firma__c FROM Opportunity WHERE Id = :idOportunidad];

		//Actualizar eventos de las oportunidades
		List<Event> eventosPendientes = [SELECT Id FROM Event WHERE RecordType.DeveloperName = 'CSBD_Firma_Cliente'
											AND WhatId = :idOportunidad AND CSBD_Evento_Estado__c = 'Pendiente'
											AND StartDateTime = :oportunidad.CSBD_Fecha_Firma__c];
		for (Event evento : eventosPendientes) {
			evento.CSBD_Evento_Estado__c = 'Cancelado';
			evento.CC_Tipo_Cierre__c = 'Cancelado';
		}
		update eventosPendientes;

		//Actualizamos fecha oportunidad
		oportunidad.CSBD_Fecha_Firma__c = null;
		oportunidad.CSBD_Firma_segura__c = false;
		update oportunidad;

		return eventosPendientes.isEmpty() ? null : eventosPendientes[0];
	}

	@future(callout=true)
	public static void enviarEmailIntouch(Map<Id, String> mapIdReferencia, Map<Id, String> mapIdPlantilla, Set<Id> createdByIdSet) {
		if (!mapIdReferencia.isEmpty() && !mapIdPlantilla.isEmpty()) {
			List<OrgWideEmailAddress> buzonRemitenteCaixa = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: 'CSBD - CaixaBank Informa'];
			Map<String, String> masterLabelNombrePlantilla = new Map<String, String>();
			for (CSBD_Plantillas_Correo__mdt plantillaMdt: [SELECT MasterLabel, CSBD_Nombre_Plantilla__c FROM CSBD_Plantillas_Correo__mdt
															WHERE MasterLabel = :mapIdPlantilla.values() AND CSBD_Idioma__c = 'Castellano']) {
				masterLabelNombrePlantilla.put(plantillaMdt.MasterLabel, plantillaMdt.CSBD_Nombre_Plantilla__c);
			}
			Map<String, EmailTemplate> nombreIdPlantilla = new Map<String, EmailTemplate>();
			for (EmailTemplate plantilla: [SELECT HtmlValue, Subject, Name FROM EmailTemplate WHERE Name = :masterLabelNombrePlantilla.values()]) {
				nombreIdPlantilla.put(plantilla.Name, plantilla);
			}
			Map<Id, User> idCreadorOportunidad = new Map<Id, User>();
			for (User creadorOportunidad: [SELECT Email FROM User WHERE Id = :createdByIdSet]) {
				idCreadorOportunidad.put(creadorOportunidad.Id, creadorOportunidad);
			}

			List<Messaging.SingleEmailMessage> correos = new List<Messaging.SingleEmailMessage>();

			for (Opportunity oportunidad : [SELECT CreatedById FROM Opportunity WHERE Id IN :mapIdReferencia.keySet()]) {
				String nombrePlantilla = masterLabelNombrePlantilla.get(mapIdPlantilla.get(oportunidad.Id));
				List<string> toAddress = new List<string>();
				toAddress.add(idCreadorOportunidad.get(oportunidad.CreatedById).Email);

				Messaging.SingleEmailMessage correo = new Messaging.SingleEmailMessage();
				correo.setWhatId(oportunidad.Id);
				correo.setOrgWideEmailAddressId(buzonRemitenteCaixa[0].Id);
				correo.setToAddresses(toAddress);

				List<EmailTemplate> plantilla = new List<EmailTemplate>{nombreIdPlantilla.get(nombrePlantilla)};
				if (!plantilla.isEmpty()) {
					plantilla[0].HtmlValue += '<br/><br/><span style="font-family: \'Arial\'; font-size: 12px; color: gray;">';
					plantilla[0].HtmlValue += 'Por favor, mantenga la siguiente referencia al responder a este correo electrónico: #@' + mapIdReferencia.get(oportunidad.Id) + '#.</span>';
					List<Messaging.RenderEmailTemplateBodyResult> htmlBodies = Messaging.renderEmailTemplate(UserInfo.getUserId(), oportunidad.Id, new List<String>{plantilla[0].HtmlValue});
					if (!htmlBodies.isEmpty()) {
						plantilla[0].HtmlValue = htmlBodies[0].getMergedBody();
					}
					correo.setHtmlBody(plantilla[0].HtmlValue);
					correo.setSubject(plantilla[0].Subject);
				}
				correos.add(correo);
			}
			if (!correos.isEmpty()) {
				try {
					Messaging.sendEmail(correos, false);
				} catch (Exception e) {
					CBK_log.error(e);
				}
			}
		}
	}

	public static Opportunity convertirOportunidad(Opportunity oportunidadOrigen, String recordTypeDeveloperName) {
		//Clonar e insertar nueva oportunidad
		Opportunity oportunidadDestino = oportunidadOrigen.clone(false, true, false, false);
		oportunidadDestino.CSBD_Parent_Id__c = oportunidadOrigen.Id;
		oportunidadDestino.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', recordTypeDeveloperName);
		oportunidadDestino.CSBD_Estado__c = 'Activa';
		oportunidadDestino.StageName = 'Solicitud';

		if (oportunidadOrigen.RecordType.DeveloperName == 'CSBD_CMN' || oportunidadOrigen.RecordType.DeveloperName == 'CSBD_CMB') {
			oportunidadDestino.CSBD_Now_Origen__c = 'Call Me CSBD';
		} else {
			oportunidadDestino.CSBD_Now_Origen__c = oportunidadOrigen.RecordType.Name + ' CSBD';
		}
		oportunidadDestino.Loss_Reason__c = null;
		oportunidadDestino.CSBD_Resolucion__c = null;
		oportunidadDestino.CSBD_Fecha_Firma__c = null;
		insert oportunidadDestino;

		if(oportunidadDestino.AccountId != null){
			update crearTitularHipotecas(oportunidadDestino, oportunidadDestino.AccountId);
		}

		//Nueva actividad de oportunidad clonada en la nueva oportunidad hija
		CSBD_Activity.crearActividad(
			oportunidadDestino.Id,
			'Trasladar oportunidad',
			'Completed',
			'Trasladar oportunidad',
			'Oportunidad padre: ' + oportunidadOrigen.CSBD_Identificador__c
		);
		return oportunidadDestino;
	}

	public static List<Opportunity> crearTitularHipotecas(Opportunity oportunidadCrearTitular, Id idsCliente) {
		return crearTitularHipotecas(new List<Opportunity>{oportunidadCrearTitular}, new Set<Id>{idsCliente});
	}

	public static List<Opportunity> crearTitularHipotecas(List<Opportunity> oportunidadesCrearTitular, Set<Id> idsCliente) {
		Map<Id, Account> idClienteMap = new Map<Id, Account>([SELECT Id, FirstName, LastName, CC_Numero_Documento__c, Name, RecordTypeId FROM Account WHERE Id = :idsCliente]);

		// Obtener los RecordTypeIds necesarios
		Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();
		Id recordTypeIdAccountClientePA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
		Id recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();

		List<Account> cuentasTitularInsert = new List<Account>();
		List<Contact> contactosTitularInsert = new List<Contact>();

		Map<Id, Account> idTitularMap = new Map<Id, Account>();
		for(Opportunity oportunidad : oportunidadesCrearTitular) {
			Account cuentaTitulares = new Account();
			cuentaTitulares.RecordTypeId = recordTypeIdAccount;
			cuentaTitulares.Name = 'Cuenta titulares petición ' + oportunidad.CSBD_Identificador__c;
			cuentasTitularInsert.add(cuentaTitulares);
			idTitularMap.put(oportunidad.Id, cuentaTitulares);
		}

		insert cuentasTitularInsert;

		for(Opportunity oportunidad : oportunidadesCrearTitular) {
			Account cliente = idClienteMap.get(oportunidad.AccountId);
			Contact titular1 = new Contact();
			titular1.AccountId = idTitularMap.get(oportunidad.Id).Id;
			titular1.RecordTypeId = recordTypeIdContact;
			titular1.CC_Numero_Documento__c = cliente.CC_Numero_Documento__c;
			
			if(cliente.RecordTypeId == recordTypeIdAccountClientePA) {
				titular1.FirstName = cliente.FirstName;
				titular1.LastName = cliente.LastName;
			} else {
				titular1.LastName = cliente.Name;
			}
			contactosTitularInsert.add(titular1);
		}

		insert contactosTitularInsert;

		for(Opportunity oportunidad : oportunidadesCrearTitular) {
			oportunidad.CSBD_ContactoTitular1__c = contactosTitularInsert[oportunidadesCrearTitular.indexOf(oportunidad)].Id;
		}

		return oportunidadesCrearTitular;
	}
}