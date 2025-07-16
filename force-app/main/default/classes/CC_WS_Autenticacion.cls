public with sharing class CC_WS_Autenticacion {

	public class DefaultException extends Exception {}

	public static String CC_WS_Envio_Autenticacion(Id autenticacionId, Id recordId) {
		return CC_WS_Envio_Autenticacion(autenticacionId, recordId, 'ClienteDigital');
	}

	public static String CC_WS_Envio_Autenticacion(Id autenticacionId, Id recordId, String tipoAutenticacion) {
		System.debug('::: tipoAutenticacion: ' + tipoAutenticacion);
		String resultado = 'OK';

		if (String.isNotBlank(autenticacionId) && String.isNotBlank(recordId)) {
			String tipoObjeto = recordId.getSObjectType().getDescribe().getName();

			Map<String, Object> retorno = getDatos(recordId, autenticacionId, tipoAutenticacion);
			Map<String, Object> datos = (Map<String, Object>)retorno.get('datos');
			Case caso = (Case)retorno.get('caso');
			Opportunity oportunidad = (Opportunity)retorno.get('oportunidad');

			Datetime fechaCaducidad = Datetime.valueOf(datos.get('fechaCaducidad'));
			String body = '{"operationKey": "' + String.valueOf(datos.get('operationKey')) + '",';
			body += '"taskData":{"telephone": "' + String.valueOf(datos.get('telefono')) + '","language": "' + String.valueOf(datos.get('idioma')) + '", "casoId":"' + String.valueOf(datos.get('casoId')) + '", "casoUso":"' + String.valueOf(datos.get('casoUso')) + '"},';
			body += '"expirationDate": "' + String.valueOf(fechaCaducidad.date()) + '",';
			body += '"expirationTime": "' + String.valueOf(fechaCaducidad.time()).substring(0, 5) + '",';
			body += '"customerInternalId": "' + CC_MetodosUtiles.encriptarSHA('SHA-512', String.valueOf(datos.get('numperso'))).toLowerCase() + '",';
			body += '"personType": "' + String.valueOf(datos.get('tipoPersona')) + '", "appName": "' + String.valueOf(datos.get('app')) + '",';
			if (tipoAutenticacion == 'ClienteDigital') {
				body += '"visualizationData": {"tickets": [{"datum": "' + String.valueOf(datos.get('telefono')) + '","ticketvalue": "' + String.valueOf(datos.get('ticketvalue')) + '"}]},';
			}
			body += '"customerId" : "' + String.valueOf(datos.get('documento')) + '"}';

			CC_TrazaInt__c traza = new CC_TrazaInt__c();
			traza.Name = 'CC_WS_Envio_Autenticacion';
			traza.CC_Identificador__c = autenticacionId + ' - ' + datos.get('numperso');
			traza.CC_FechaInicio__c = Datetime.now();
			traza.CC_MensajeEntrada__c = body;

			HttpResponse response;
			try {
				CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
				integracion.method = 'POST';
				integracion.intSetting = 'CC_Autenticacion_Robusta';
				integracion.body = body;
				integracion.mHeaders = getRequestHeaders();
				HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);
				response = CBK_HttpServiceIntegration.callHttpService(request, autenticacionId, 'CC_Autenticacion_Robusta');

				response.setStatusCode(200); //DPK comentar

				CC_Comunicaciones__c autenticacion = new CC_Comunicaciones__c(Id = autenticacionId);
				autenticacion.CC_Fecha_Envio__c = Datetime.now();
				traza.CC_FechaFin__c = Datetime.now();
				traza.CC_MensajeSalida__c = response.getBody();

				System.debug('::: response.getBody(): ' + response.getBody());

				if (response.getStatusCode() != 200) { //KO

					if (tipoObjeto == 'Case') {
						resultado = 'KO';
						caso.CC_Status_Autorizacion__c = 'ERROR';
					} else if (tipoObjeto == 'Opportunity') {
						oportunidad.CSBD_EstadoAutenticacion__c = 'ERROR';
						resultado = response.getStatus() + ' (' + response.getStatusCode() + ')';
					}
					autenticacion.CC_Estado__c = 'Error';
					autenticacion.CC_Mensaje_Error__c = resultado;

					traza.CC_FinOK__c = true;

				} else { //OK
					Map<String, Object> mapRespuesta = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
					Map<String, Map<String, String>> infoEstadosEnvio = getInfoEstadosEnvio();
                    String estadoEnvio = JSON.serialize(mapRespuesta.get('status')).replaceAll('"', '');
                    //String estadoEnvio = 'INPROGRESS';
					if (infoEstadosEnvio.containsKey(estadoEnvio)) {
						if (tipoObjeto == 'Case') {
							caso.CC_Status_Autorizacion__c = esValorPicklist('Case', 'CC_Status_Autorizacion__c', estadoEnvio) ? estadoEnvio : null;
						} else if (tipoObjeto == 'Opportunity') {
							oportunidad.CSBD_EstadoAutenticacion__c = esValorPicklist('Opportunity', 'CSBD_EstadoAutenticacion__c', estadoEnvio) ? estadoEnvio : null;
						}
						autenticacion.CC_Estado__c = infoEstadosEnvio.get(estadoEnvio).get('CC_Estado__c');
						autenticacion.CC_Detalle__c = infoEstadosEnvio.get(estadoEnvio).get('CC_Detalle__c');
						traza.CC_FinOK__c = true;
					} else {
						autenticacion.CC_Estado__c = 'Error';
						traza.CC_FinOK__c = false;
					}
					autenticacion.CC_AuthorizationId__c = JSON.serialize(mapRespuesta.get('authorizationId')).replaceAll('"', '');
				}

				update autenticacion;

				if (tipoObjeto == 'Case') {
					caso.CC_OTP_Nivel__c = 'Cliente Digital';
					update caso;
				} else if (tipoObjeto == 'Opportunity') {
					oportunidad.CSBD_UltimaAutenticacionNivel__c = 'Cliente Digital';
					update oportunidad;
				}
			} catch (Exception e) {
				CBK_Log.error(e);
				traza.CC_FinOK__c = false;
				traza.CC_TipoError__c = String.valueOf(response?.getStatusCode());
				traza.CC_DetalleError__c = response?.getStatus();
				throw new DefaultException(e.getMessage() + '. ' + e.getStackTraceString());
			} finally {
				insert traza;
			}
		}
		return resultado;
	}

	private static Map<String, Object> getDatos(Id recordId, Id autenticacionId, String tipoAutenticacion) {
		Map<String, Object> datos;
		Case caso;
		Opportunity oportunidad;

		//Account, representant y teléfono
		String tipoObjeto = recordId.getSObjectType().getDescribe().getName();
		if (tipoObjeto == 'Case') {
			caso = [SELECT Id, CC_MCC_Motivo__c, Account.RecordType.DeveloperName, Account.CC_NumPerso__c, Account.CC_Numero_Documento__c, Account.AV_NumPerso__c,
					Contact.CC_NumPerso__c, Contact.CC_Numero_Documento__c, Contact.AV_NumPerso__c, Contact.CIBE_NumPerso__c, Contact.RecordType.DeveloperName,
					CC_Representante__r.RecordType.DeveloperName,
					CC_Representante__r.CC_Representante__r.CC_NumPerso__c,CC_Representante__r.CC_Representante__r.CC_Numero_Documento__c,
					CC_Telefono_Contacto__c, CC_Idioma__c, Account.AV_Segmento__c, CC_Representante__r.CC_Representante__r.AV_NumPerso__c FROM Case WHERE Id = :recordId];

    	// Usar el método CC_OTP.recuperarNumperso para obtener el numperso
    	String numper = CC_OTP.recuperarNumperso(caso);

			datos = new Map<String, Object>{
				'accountRecordType' => caso.Account?.RecordType.DeveloperName,
				'accountDoc' => caso.Account?.CC_Numero_Documento__c,
				// 'accountNumperso' => !String.isEmpty(caso.Account?.AV_NumPerso__c) ? caso.Account?.AV_NumPerso__c : caso.Account?.CC_NumPerso__c,
				'accountNumperso' => numper,
				// 'contactNumperso' => !String.isEmpty(caso.Contact?.CIBE_NumPerso__c) ? caso.Contact?.CIBE_NumPerso__c : !String.isEmpty(caso.Contact?.AV_NumPerso__c) ? caso.Contact?.AV_NumPerso__c : caso.Contact?.CC_NumPerso__c,
				'contactNumperso' => numper,
                'contactRecordType' => caso.Contact?.RecordType.DeveloperName,
				'contactDoc' => caso.Contact?.CC_Numero_Documento__c,
				'representanteRecordType' => caso.CC_Representante__r?.RecordType.DeveloperName,
				'representanteNumperso' => numper,
				'representanteDocumento' => caso.CC_Representante__r?.CC_Representante__r?.CC_Numero_Documento__c,
				'telefono' => caso.CC_Telefono_Contacto__c,
				'idioma' => caso.CC_Idioma__c == 'en' ? 'en' : caso.CC_Idioma__c == 'ca' ? 'ca' : 'es',
				'casoId' => caso.Id,
				'casoUso' => caso.CC_MCC_Motivo__c,
				'app' => 'CBCCSF',
				'segmento'=> caso.Account?.AV_Segmento__c
			};

		} else if (tipoObjeto == 'Opportunity') {
			oportunidad = [SELECT Id, Account.RecordType.DeveloperName, Account.CC_NumPerso__c, Account.CC_Numero_Documento__c,
							CSBD_Contact__r.CC_NumPerso__c, CSBD_Contact__r.CC_Numero_Documento__c, CSBD_Contact__r.RecordType.DeveloperName,
							CSBD_CasoOrigen__r.CC_Representante__r.RecordType.DeveloperName,
							CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.CC_NumPerso__c,
							CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.CC_Numero_Documento__c,
							CSBD_Telefono_Solicitud__c FROM Opportunity WHERE Id = :recordId];

			datos = new Map<String, Object>{
				'accountRecordType' => oportunidad.Account?.RecordType.DeveloperName,
				'accountDoc' => oportunidad.Account?.CC_Numero_Documento__c,
				'accountNumperso' => oportunidad.Account?.CC_NumPerso__c,
				'contactNumperso' => oportunidad.Account?.CC_NumPerso__c,
				'contactDoc' => oportunidad.CSBD_Contact__r?.CC_Numero_Documento__c,
				'contactRecordType' => oportunidad.CSBD_Contact__r.RecordType.DeveloperName,
				'representanteRecordType' => oportunidad?.CSBD_CasoOrigen__r.CC_Representante__r?.RecordType.DeveloperName,
				'representanteNumperso' => oportunidad.CSBD_CasoOrigen__r?.CC_Representante__r?.CC_Representante__r?.CC_NumPerso__c,
				'representanteDocumento' => oportunidad.CSBD_CasoOrigen__r?.CC_Representante__r?.CC_Representante__r?.CC_Numero_Documento__c,
				'telefono' => oportunidad.CSBD_Telefono_Solicitud__c,
				'idioma' => 'es',
				'casoId' => oportunidad.Id,
				'casoUso' => '',
				'app' => 'CSBD',
				'segmento'=> ''
			};
		}

		//operationKey y ticketvalue
		CC_Settings__c configuracion = [SELECT CC_Configuracion_1__c, CC_Configuracion_2__c, CC_Configuracion_3__c, CC_Configuracion_4__c, CC_Configuracion_6__c
										FROM CC_Settings__c WHERE Name = 'CC_Integracion_ClienteDigital' LIMIT 1];
		String operationKey;
		String ticketvalue;
		if (tipoAutenticacion == 'Nivel2') {
			datos.put('operationKey', configuracion.CC_Configuracion_6__c);
		} else if ([SELECT CC_Tipo_Llamada__c FROM CC_Comunicaciones__c WHERE Id = :autenticacionId]?.CC_Tipo_Llamada__c == 'Saliente') {
			datos.put('operationKey', configuracion.CC_Configuracion_2__c);
			datos.put('ticketvalue', configuracion.CC_Configuracion_4__c);
		} else { //Entrante
			datos.put('operationKey', configuracion.CC_Configuracion_1__c);
			datos.put('ticketvalue', configuracion.CC_Configuracion_3__c);
		}

		//Fecha de caducidad
		String tiempoCaducidad = [SELECT CC_Valor__c FROM CC_Lista_Valores__c
									WHERE CC_Lista__r.Name = 'CC Parametrizacion de horarios'
									AND Name = 'Minutos caducidad autenticacion']?.CC_Valor__c ?? '0';
		datos.put('fechaCaducidad', Datetime.now().addMinutes(Integer.valueOf(tiempoCaducidad)));

		//personType y customerInternalId
		if (datos.get('representanteRecordType') != null) { //PENDIENTE
			datos.put('tipoPersona', 'FISICA');
			datos.put('numperso', datos.get('representanteNumperso'));
			datos.put('documento', datos.get('representanteDocumento'));
		} else if (datos.get('accountRecordType') == 'CC_Cliente' && datos.get('contactRecordType') == 'CIBE_Apoderado' && datos.get('segmento') != 'RPF') {
			datos.put('tipoPersona', 'JURIDICA');
			datos.put('numperso', String.valueOf(datos.get('contactNumperso')));
			datos.put('documento', datos.get('contactDoc'));
		} else if (datos.get('accountRecordType') == 'CC_Cliente' && datos.get('contactRecordType') == 'CC_Cliente' && datos.get('segmento') == 'RPF') {
			datos.put('tipoPersona', 'JURIDICA');
			datos.put('numperso', String.valueOf(datos.get('contactNumperso')));
			datos.put('documento', datos.get('accountDoc'));
		} else {
			datos.put('tipoPersona', 'FISICA');
			datos.put('numperso', datos.get('accountNumperso'));
			datos.put('documento', datos.get('accountDoc'));

		}

		return new Map<String, Object>{
			'datos' => datos, 'caso' => caso, 'oportunidad' => oportunidad
		};
	}

	private static Map<String, Map<String, String>> getInfoEstadosEnvio() {
		return new Map<String, Map<String, String>>{
			'PENDING' => new Map<String, String>{'CC_Estado__c' => 'Pendiente', 'CC_Detalle__c' => 'PENDING: La autorización esta pendiente'},
			'INPROGRESS' => new Map<String, String>{'CC_Estado__c' => 'En progreso', 'CC_Detalle__c' => 'La autorización está en progreso'},
			'REJECTED' => new Map<String, String>{'CC_Estado__c' => 'Rechazado', 'CC_Detalle__c' => 'La autorización ha sido cancelada (no se puede reutilizar)'},
			'EXPIRED' => new Map<String, String>{'CC_Estado__c' => 'Expirado', 'CC_Detalle__c' => 'La autorización ha expirado el tiempo de lifetime (5 min)'},
			'ERROR' => new Map<String, String>{'CC_Estado__c' => 'Error', 'CC_Detalle__c' => 'La autorización ha sufrido un error en el proceso'},
			'APPROVED' => new Map<String, String>{'CC_Estado__c' => 'Aprobado', 'CC_Detalle__c' => 'La autorización ha finalizado correctamente'},
			'UNAUTHORIZED' => new Map<String, String>{'CC_Estado__c' => 'No autorizado', 'CC_Detalle__c' => 'Cliente no ha superado la autorización si se le ha pedido'},
			'DENIED' => new Map<String, String>{'CC_Estado__c' => 'Denegado', 'CC_Detalle__c' => 'Argos indica riesgo alto y no deja autorizar la operación'}
		};
	}

	public static String CC_WS_Validacion_Autenticacion(Id idAutenticacion, Id recordId) {
		if (String.isBlank(idAutenticacion)) {
			return 'KO';
		}

		Case caso;
		Opportunity oportunidad;
		String tipoObjeto = recordId.getSObjectType().getDescribe().getName();

		String resultado = 'KO';
		CC_Comunicaciones__c autenticacion = [SELECT CC_AuthorizationId__c FROM CC_Comunicaciones__c
												WHERE Id = :idAutenticacion];

		String sSalida = '';
		autenticacion.CC_Fecha_Validacion__c = Datetime.now();

		try {
			CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
			integracion.body = null;
			integracion.intSetting = 'CC_Autenticacion_Robusta_Estado';
			integracion.method = 'GET';
			integracion.mHeaders = getRequestHeaders();
			HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);
			request.setEndpoint(request.getEndpoint().replace('{authorizationId}', autenticacion.CC_AuthorizationId__c ?? ''));

			//HttpResponse responseConsulta = httpConsulta.send(requestConsulta);

			HttpResponse responseConsulta = CBK_HttpServiceIntegration.callHttpService(request, idAutenticacion, 'CC_Autenticacion_Robusta_Estado');
			responseConsulta.setStatusCode(200);//DPK comentar
			String body =  '{"authorizationId":"SK_0120240216093456720001004000000000CBCCSF000000000000000DEFzd4i5Di9AQVO5CL9Ieq","status":"APPROVED"}';
			responseConsulta.setBody(body);//DPK comentar

			if (tipoObjeto == 'Case') {
				caso = new Case(Id = recordId);
			} else if (tipoObjeto == 'Opportunity') {
				oportunidad = new Opportunity(Id = recordId);
			}

			if (responseConsulta.getStatusCode() != 200) {
				resultado = responseConsulta.getStatus() + ' (' + responseConsulta.getStatusCode() + ')';

				autenticacion.CC_Estado__c = 'Error';
				autenticacion.CC_Mensaje_Error__c = resultado;
				if (tipoObjeto == 'Case') {
					caso.CC_Status_Autorizacion__c = 'ERROR';
					resultado = resultado + '(ERROR)';
				} else if (tipoObjeto == 'Opportunity') {
					oportunidad.CSBD_EstadoAutenticacion__c = 'ERROR';
				}
			} else {
				Map<String, Object> mapRespuesta = (Map<String, Object>)JSON.deserializeUntyped(responseConsulta.getBody());
				String statusConsulta = JSON.serialize(mapRespuesta.get('status')).replaceAll('"', '');

				// List<Object> listaConsulta = (List<Object>) JSON.deserializeUntyped(String.valueOf(responseConsulta.getBody()));
				// Map<String, Object> mapRespuestaConsulta = (Map<String, Object>) listaConsulta[0];
				// String statusConsulta = JSON.serialize(mapRespuestaConsulta.get('status'));
				// //JSON.serialize(mapRespuestaConsulta.get('status'));
				Map<String, Map<String, String>> infoEstadosValidacion = getInfoEstadosValidacion();
				String statusAux = esValorPicklist('Case', 'CC_Status_Autorizacion__c', statusConsulta) ? statusConsulta : 'SIN ESTADO';
				if (infoEstadosValidacion.containsKey(statusConsulta)) {
					autenticacion.CC_Estado__c = infoEstadosValidacion.get(statusConsulta).get('CC_Estado__c');
					if (autenticacion.CC_Estado__c == 'Aprobado') {
						if (tipoObjeto == 'Case') {
							caso.CC_OTP_Valido__c = true;
						} else if (tipoObjeto == 'Opportunity') {
							oportunidad.CSBD_UltimaAutenticacionOk__c = true;
						}
					}
					autenticacion.CC_Detalle__c = infoEstadosValidacion.get(statusConsulta).get('CC_Detalle__c');

					if (tipoObjeto == 'Case') {
						caso.CC_Status_Autorizacion__c = statusAux;
					} else if (tipoObjeto == 'Opportunity') {
						oportunidad.CSBD_EstadoAutenticacion__c = statusAux;
					}
					resultado = infoEstadosValidacion.get(statusConsulta).get('CC_Detalle__c');
					if (statusAux == 'ERROR') {
						resultado = resultado + '(ERROR)';
					}
				} else {
					resultado = 'Estado desconocido';
				}
			}
		} catch (Exception e) {
			CBK_Log.error(e);
			throw new DefaultException(e.getMessage() + '. ' + e.getStackTraceString());
		}

		update autenticacion;
		if (tipoObjeto == 'Case') {
			update caso;
		} else if (tipoObjeto == 'Opportunity') {
			update oportunidad;
		}

		return resultado;
	}

	private static Map<String, Map<String, String>> getInfoEstadosValidacion() {
		return new Map<String, Map<String, String>>{
			'PENDING' => new Map<String, String>{'CC_Estado__c' => 'Pendiente', 'CC_Detalle__c' => 'La autorización está pendiente (pendiente cliente)'},
			'INPROGRESS' => new Map<String, String>{'CC_Estado__c'=>'En progreso', 'CC_Detalle__c'=>'La autorización está en progreso (pendiente cliente)'},
			'REJECTED' => new Map<String, String>{'CC_Estado__c'=>'Rechazado', 'CC_Detalle__c'=>'La autorización ha sido rechazada por el cliente'},
			'EXPIRED' => new Map<String, String>{'CC_Estado__c'=>'Expirado', 'CC_Detalle__c'=>'La autorización ha expirado (se permite un nuevo intento)'},
			'ERROR' => new Map<String, String>{'CC_Estado__c'=>'Error', 'CC_Detalle__c'=>'La autorización ha sufrido un error en el proceso (se permite un nuevo intento)'},
			'APPROVED' => new Map<String, String>{'CC_Estado__c'=>'Aprobado', 'CC_Detalle__c'=>'La autorización ha sido aprobada por el cliente'},
			'UNAUTHORIZED' => new Map<String, String>{'CC_Estado__c'=>'No autorizado', 'CC_Detalle__c'=>'Cliente no ha superado la autorización si se le ha pedido (se permite nuevo intento)'},
			'DENIED' => new Map<String, String>{'CC_Estado__c'=>'Denegado', 'CC_Detalle__c'=>'Se identifica riesgo alto de fraude (NO se permite nuevo intento)'}
		};
	}

	private static Boolean esValorPicklist(String objeto, String campoPicklist, String valor) {
		Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(objeto).getDescribe();
		for (Schema.PicklistEntry entry : objDescribe.fields.getMap().get(campoPicklist).getDescribe().getPicklistValues()) {
			if (entry.getValue() == valor) {
				return true;
			}
		}
		return false;
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
        // system.debug('DPK headers' + headers);
		return headers;
	}
}