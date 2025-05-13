public with sharing class CC_WS_Validacion_OTP {

	//@future(callout=true)
	// Hacerlo online como llamada del LC pasandole los datos necesarios
	public static List<CC_Comunicaciones__c> CC_WS_Validacion_OTP(Set<Id> idAutenticaciones, String codigoOtp) {

		List<CC_Comunicaciones__c> autenticaciones = [SELECT CC_Case__c, CC_Case__r.Account.CC_NumPerso__c, //Name, CC_Case__r.CC_NumPerso__c
														CSBD_Opportunity__c, CSBD_Opportunity__r.Account.CC_NumPerso__c,
														CC_Ticket__c, CC_Codigo_OTPSMS__c, CC_Intentos_Validacion_OTP__c,
														CC_Resultado_Validacion__c, CC_Fecha_Validacion__c, CC_Codigo_Error__c, CC_Case__r.Account.RecordType.DeveloperName,
														CC_Case__r.Account.AV_Segmento__c,
														CC_Case__r.Account.AV_NumPerso__c,
														CC_Case__r.Contact.RecordType.DeveloperName,
														CC_Case__r.Contact.CIBE_NumPerso__c,
														CC_Case__r.Contact.AV_NumPerso__c,
														CC_Case__r.Contact.CC_NumPerso__c,
														CC_Case__r.CC_Representante__c,
														CC_Case__r.CC_Representante__r.CC_Representante__r.AV_NumPerso__c,
														CC_Case__r.CC_Representante__r.CC_Representante__r.CC_NumPerso__c
														FROM CC_Comunicaciones__c WHERE Id IN :idAutenticaciones];

		CC_InterfaceSettings__mdt cfgIntegracion = CC_MetodosUtiles.getInterfazConfigBody('CC_Validacion_OTP');
		if (cfgIntegracion != null) {
			List<CC_TrazaInt__c> trazas = new List<CC_TrazaInt__c>();
			List<Case> casos = new List<Case>();
			List<Opportunity> oportunidades = new List<Opportunity>();

			for (CC_Comunicaciones__c autenticacion : autenticaciones) {
				CC_TrazaInt__c traza = new CC_TrazaInt__c(Name = 'CC_Validacion_OTP', CC_Identificador__c = autenticacion.Id);

				Id recordId = autenticacion.CC_Case__c ?? autenticacion.CSBD_Opportunity__c;
				String tipoObjeto = recordId.getSObjectType().getDescribe().getName();
				String numper;

				if (tipoObjeto == 'Case' && autenticacion.CC_Case__c != null) {
					Map<Id, String> idToNumPersoMap = CC_MetodosUtiles.recuperarNumpersoPorComunicaciones(autenticaciones);
					numper = idToNumPersoMap.get(autenticacion.Id);
						
				} else {
						// Si no es un caso, usar el numper directamente de la autenticación
						numper = autenticacion.CC_Case__r.Account.CC_NumPerso__c ?? autenticacion.CSBD_Opportunity__r.Account.CC_NumPerso__c;
				}

				// if (String.isBlank(numperso)) { //Sin NUMPERSO informado
				if (String.isBlank(numper)) { //Sin NUMPERSO informado
					traza.CC_FinOK__c = false;
					traza.CC_TipoError__c = 'Datos entrada no informados.';
					traza.CC_DetalleError__c = 'NUMPERSO no informado. Comunicación: ' + autenticacion.Id;
				} else {
					try {
						// String requestBody = getRequestBody(cfgIntegracion, autenticacion, numperso, codigoOtp);
						String requestBody = getRequestBody(cfgIntegracion, autenticacion, numper, codigoOtp);
						if (cfgIntegracion.CC_TrazaEntrada__c || Test.isRunningTest()) {
							traza.CC_MensajeEntrada__c = requestBody;
						}

						traza.CC_FechaInicio__c = Datetime.now();
						HttpResponse httpResponse = new Http().send(getRequest(cfgIntegracion, requestBody));
						traza.CC_FechaFin__c = Datetime.now();

						// httpResponse.setStatusCode(200); //Comentar ////////////////////////////////////////////////////////

						Boolean responseOk = httpResponse.getStatusCode() == 200;
						traza.CC_FinOK__c = responseOk;
						if ((cfgIntegracion.CC_TrazaSalida__c || Test.isRunningTest())) {
							traza.CC_MensajeSalida__c = httpResponse.getBody();
						}

						if (tipoObjeto == 'Case') {
							Case caso = new Case(Id = recordId);
							caso.CC_Status_Autorizacion__c = responseOk ? 'APPROVED' : 'ERROR';
							casos.add(caso);
						} else if (tipoObjeto == 'Opportunity') {
							Opportunity oportunidad = [SELECT CSBD_IntentosAutenticacion__c FROM Opportunity WHERE Id = :recordId];
							oportunidad.CSBD_UltimaAutenticacionFecha__c = Datetime.now();
							oportunidad.CSBD_UltimaAutenticacionOk__c = responseOk;
							oportunidad.CSBD_EstadoAutenticacion__c = responseOk ? 'APPROVED' : 'ERROR';
							oportunidad.CSBD_IntentosAutenticacion__c = oportunidad.CSBD_IntentosAutenticacion__c + 1;
							oportunidades.add(oportunidad);
						}

						autenticacion.CC_Fecha_Validacion__c = Datetime.now();
						autenticacion.CC_Codigo_OTPSMS__c = codigoOtp;
						autenticacion.CC_Intentos_Validacion_OTP__c = autenticacion.CC_Intentos_Validacion_OTP__c + 1;
						autenticacion.CC_Resultado_Validacion__c = responseOk ? 'OTP validada correctamente' : 'OTP errónea';
						autenticacion.CC_Estado__c = responseOk ? 'Cerrado' : 'Rechazado';
						autenticacion.CC_Respuesta_OTP__c = httpResponse.getBody();
						if (responseOk) {
							autenticacion.CC_Codigo_Error__c = '00000';
						} else {
							Map<String, String> errores = getResponseErrores(httpResponse.getBody());
							autenticacion.CC_Codigo_Error__c = errores.get('errorCode');
							autenticacion.CC_Mensaje_Error__c = errores.get('errorMessage');

							traza.CC_TipoError__c = 'Error petición.';
							traza.CC_DetalleError__c = httpResponse.getStatus() + ' (' + httpResponse.getStatusCode() + ')';
						}
					} catch (Exception e) { //Error comunicaciones
						traza.CC_FinOK__c = false;
						traza.CC_TipoError__c = 'Error comunicaciones.';
						traza.CC_DetalleError__c = e.getMessage();
					}
				}
				trazas.add(traza);
			}

			if (cfgIntegracion.CC_TrazaActiva__c || Test.isRunningTest()) {
				Database.insert(trazas, false);
			}
			Database.update(autenticaciones, false);
			Database.update(casos, false);
			Database.update(oportunidades, false);
		}
		return autenticaciones;
	}

	// private static String getRequestBody(CC_InterfaceSettings__mdt cfgIntegracion, CC_Comunicaciones__c autenticacion, String numperso, String codigoOtp) {
	private static String getRequestBody(CC_InterfaceSettings__mdt cfgIntegracion, CC_Comunicaciones__c autenticacion, String numper, String codigoOtp) {
		String requestBody = cfgIntegracion.CC_Body__c;
		requestBody = requestBody.replace('##dateTime##', getTimestamp());
		requestBody = requestBody.replace('##ticket##', autenticacion.CC_Ticket__c);
		//requestBody = requestBody.replace('##ticket##', '0BCC00000353000'); //Comentar ////////////////////////////////////////////////////////
		requestBody = requestBody.replace('##otpEncrypt##', codigoOtp); //autenticacion.CC_Codigo_OTPSMS__c);
		// requestBody = requestBody.replace('##personId##', numperso);
		requestBody = requestBody.replace('##personId##', numper);
		return requestBody;
	}

	private static String getTimestamp() {
		Datetime ahora = System.now();
		String timestamp = String.valueOf(ahora.year());
		String mes = String.valueOf(ahora.month());
		timestamp += '-' + (mes.length() == 1 ? '0' + mes : mes);
		String dia = String.valueOf(ahora.day());
		timestamp += '-' + (dia.length() == 1 ? '0' + dia : dia);
		String hora = String.valueOf(ahora.hour());
		timestamp += '-' + (hora.length() == 1 ? '0' + hora : hora);
		String minutos = String.valueOf(ahora.minute());
		timestamp += '.' + (minutos.length() == 1 ? '0' + minutos : minutos);
		String segundos = String.valueOf(ahora.second());
		timestamp += '.' + (segundos.length() == 1 ? '0' + segundos : segundos);
		timestamp += '.' + String.valueOf(ahora.millisecond());
		return timestamp;
	}

	private static HttpRequest getRequest(CC_InterfaceSettings__mdt cfgIntegracion, String body) {
		HttpRequest httpRequest = new HttpRequest();
		if (!Test.isRunningTest()) {
			httpRequest.setClientCertificateName(cfgIntegracion.CC_Certificado__c);
		}
		httpRequest.setEndpoint(cfgIntegracion.CC_EndPoint__c);
		httpRequest.setMethod(cfgIntegracion.CC_TipoPeticion__c);
		httpRequest.setBody(body);
		Map<String, String> headers = getRequestHeaders();
		for (String header : headers.keySet()) {
			httpRequest.setHeader(header, headers.get(header));
		}
		return httpRequest;
	}

	private static Map<String, String> getResponseErrores(String httpRequestBody) {
		System.JSONParser parserSR = System.JSON.createParser(httpRequestBody);
		Map<String, String> errores = new Map<String, String>();
		while (parserSR.nextToken() != null) {
			if ((parserSR.getCurrentToken() == JSONToken.FIELD_NAME) && (parserSR.getText() == 'errorCode')) {
				parserSR.nextToken();
				errores.put('errorCode', parserSR.getText());
			}
			if ((parserSR.getCurrentToken() == JSONToken.FIELD_NAME) && (parserSR.getText() == 'errorMessage')) {
				parserSR.nextToken();
				errores.put('errorMessage', parserSR.getText());
			}
		}
		return errores;
	}

	private static Map<String, String> getRequestHeaders() {
		/* Ejemplo de headers:
			· Content-Type: application/json;charset=UTF-8
			· x-api-actor-simulated: CCSF 	(solo para previos)
			· HTTP-HEADER-ACTOR: CBCCSF 	(solo para previos)
		*/
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
}