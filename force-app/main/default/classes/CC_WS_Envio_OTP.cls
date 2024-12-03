public with sharing class CC_WS_Envio_OTP {

	//@future(callout=true)
	public static List<CC_Comunicaciones__c> CC_WS_Envio_OTP(Set<Id> idAutenticaciones) {
		List<CC_Comunicaciones__c> autenticaciones = [SELECT CC_Case__c, CC_Case__r.CC_Idioma__c, //Name, CC_Case__r.CC_NumPerso__c
														CC_Case__r.Account.CC_NumPerso__c, CC_Case__r.Account.AV_NumPerso__c,
														CSBD_Opportunity__c, CSBD_Opportunity__r.CSBD_Idioma_Solicitud__c,
														CSBD_Opportunity__r.Account.CC_NumPerso__c, CSBD_Opportunity__r.Account.AV_NumPerso__c
														FROM CC_Comunicaciones__c WHERE Id IN :idAutenticaciones]; //AND RecordType.DeveloperName = 'CC_OTPSMS'];

		CC_InterfaceSettings__mdt cfgIntegracion = CC_MetodosUtiles.getInterfazConfigBody('CC_Envio_OTP');
		if (cfgIntegracion != null) {
			List<CC_TrazaInt__c> trazas = new List<CC_TrazaInt__c>();
			List<Case> casos = new List<Case>();
            List<Opportunity> oportunidades = new List<Opportunity>();

			for (CC_Comunicaciones__c autenticacion : autenticaciones) {
				CC_TrazaInt__c traza = new CC_TrazaInt__c(Name = 'CC_Envio_OTP', CC_Identificador__c = autenticacion.Id);

                Id recordId = autenticacion.CC_Case__c ?? autenticacion.CSBD_Opportunity__c;
                String tipoObjeto = recordId.getSObjectType().getDescribe().getName();

				//Comprobar que tenemos el numperso informado para poder realizar el envío
				String numperso = autenticacion.CC_Case__r.Account.CC_NumPerso__c;
				numperso = numperso ?? autenticacion.CC_Case__r.Account.AV_NumPerso__c;
				numperso = numperso ?? autenticacion.CSBD_Opportunity__r.Account.CC_NumPerso__c;
				numperso = numperso ?? autenticacion.CSBD_Opportunity__r.Account.AV_NumPerso__c;
                if (String.isBlank(numperso)) { //Sin NUMPERSO informado
					traza.CC_FinOK__c = false;
					traza.CC_TipoError__c = 'Datos entrada no informados.';
					traza.CC_DetalleError__c = 'NUMPERSO no informado. Comunicación: ' + autenticacion.Id;
				} else {
					try {
						String requestBody = getRequestBody(cfgIntegracion, autenticacion, numperso);
						if (cfgIntegracion.CC_TrazaEntrada__c) {
							traza.CC_MensajeEntrada__c = requestBody;
						}

						traza.CC_FechaInicio__c = Datetime.now();
						HttpResponse httpResponse = new Http().send(getRequest(cfgIntegracion, requestBody));
						traza.CC_FechaFin__c = Datetime.now();

						// httpResponse.setStatusCode(200);//DPK comentar
						// httpResponse.setBody('{"ticket":"20240828123912408   00000007BCCOTP01","KeyBlock":{"publicClusterKey":"","publicIndexKey":""},"PhoneBlock":{"prefix":34,"phoneNumber":0,"phoneNumberO":"*****0346"}}');//DPK comentar
						// Parse the JSON httpResponse

						Boolean responseOk = httpResponse.getStatusCode() == 200;
                        traza.CC_FinOK__c = responseOk;
						if ((cfgIntegracion.CC_TrazaSalida__c || Test.isRunningTest())) {
							traza.CC_MensajeSalida__c = httpResponse.getBody();
						}

                        if (tipoObjeto == 'Case') {
                            Case caso = new Case(Id = recordId);
                            caso.CC_Status_Autorizacion__c = responseOk ? 'INPROGRESS' : 'ERROR';
                            casos.add(caso);
                        } else if (tipoObjeto == 'Opportunity') {
                            Opportunity oportunidad = new Opportunity(Id = recordId);
                            oportunidad.CSBD_EstadoAutenticacion__c = responseOk ? 'INPROGRESS' : 'ERROR';
                            oportunidades.add(oportunidad);
                        }

						System.debug('autenticacion.CC_Fecha_Envio__c = Datetime.now()');
						autenticacion.CC_Fecha_Envio__c = System.now();
						autenticacion.CC_Respuesta_OTP__c = (httpResponse.getBody() ?? '').left(255);
						if (responseOk) {
							autenticacion.CC_Estado__c = 'Pdte. Validar';
							autenticacion.CC_Codigo_Error__c = '00000';
							autenticacion.CC_Ticket__c = getResponseTicket(httpResponse.getBody());
						} else {
							Map<String, String> errores = getResponseErrores(httpResponse.getBody());
							autenticacion.CC_Estado__c = 'Error';
							autenticacion.CC_Resultado_Validacion__c = 'OTP errónea';
                            autenticacion.CC_Codigo_Error__c = errores.get('errorCode');
                            autenticacion.CC_Mensaje_Error__c = (errores.get('errorMessage') ?? '').left(255);

							traza.CC_TipoError__c = 'Error petición.';
							traza.CC_DetalleError__c = httpResponse.getStatus() + ' (' + httpResponse.getStatusCode() + ')';
						}
					} catch (Exception e) {
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

	private static String getRequestBody(CC_InterfaceSettings__mdt cfgIntegracion, CC_Comunicaciones__c autenticacion, String numperso) {
		String eventDataClave = autenticacion.Id;
		Datetime ahora = System.now();
		eventDataClave += String.valueOf(ahora.year()) + ahora.month() + ahora.day();
		eventDataClave += ahora.hour()+ ahora.minute() + ahora.second() + ahora.millisecond();

		String idioma = autenticacion.CC_Case__r.CC_Idioma__c ?? autenticacion.CSBD_Opportunity__r.CSBD_Idioma_Solicitud__c;
		String eventDataIdioma = 'IDI00001003' + (idioma == 'es' ? '002' : idioma == 'ca' ? '001' : '003');

		//eventDataNumperso = eventDataNumperso + decimalToHex(decimal.valueOf(autenticacion.CC_Case__r.Account.CC_NumPerso__c));
		String eventDataNumperso = 'PER00002008' + decimalToHex(decimal.valueOf(numperso)).leftPad(8, '0');

		String requestBody = cfgIntegracion.CC_Body__c;
		requestBody = requestBody.replace('##dateTime##', getTimestamp());
		requestBody = requestBody.replace('##eventData##', 'CLAU0O01050' + eventDataClave.leftPad(50, ' ') + eventDataIdioma + eventDataNumperso + '99999999');
		requestBody = requestBody.replace('##personId##', numperso);
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
		Map<String, String> headers = getRequestHeaders();
		for (String header : headers.keySet()) {
			httpRequest.setHeader(header, headers.get(header));
		}

		httpRequest.setBody(body);
		return httpRequest;
	}

	private static Decimal modulus(Decimal dividend, Decimal divisor) {
		Decimal d = dividend.divide(divisor, 0, RoundingMode.FLOOR);
		return dividend - (d * divisor);
	}

	private static String decimalToHex(Decimal d) {
		String digits = '0123456789abcdef';
		String hex = '';
		while (d > 0) {
			Decimal digit = modulus(d, 16); // rightmost digit
			hex = digits.substring(digit.intValue(), digit.intValue() + 1) + hex; // string concatenation
			d = d.divide(16, 0, RoundingMode.FLOOR);
		}
		return hex;
	}

	private static String getResponseTicket(String httpRequestBody) {
        System.JSONParser parserSR = System.JSON.createParser(httpRequestBody);
        while (parserSR.nextToken() != null){
			if ((parserSR.getCurrentToken() == JSONToken.FIELD_NAME) && (parserSR.getText() == 'ticket')) {
				parserSR.nextToken();
				return parserSR.getText();
			}
		}
        return '';
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
		if (String.isNotBlank(errores.get('errorCode')) || String.isNotBlank(errores.get('errorMessage'))) {
			return errores;
		}

        parserSR = System.JSON.createParser(httpRequestBody);
        while (parserSR.nextToken() != null) {
            if ((parserSR.getCurrentToken() == JSONToken.FIELD_NAME) && (parserSR.getText() == 'code')) {
                parserSR.nextToken();
                errores.put('errorCode', parserSR.getText());
            }
            if ((parserSR.getCurrentToken() == JSONToken.FIELD_NAME) && (parserSR.getText() == 'summary')) {
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