@RestResource(urlMapping='/AltaLlamadaHdtDesborde/*')
global with sharing class HDT_WS_AltaLlamada_Desborde extends CBK_HttpServiceIntegration_Abstract {

	@HttpPost
	global static Output altaLlamadaHdtDesborde() {
		Datetime fechaRecepcion = Datetime.now();
		RestRequest request = RestContext.request;
		Output output = new Output();

		try {
			String requestBody = RestContext.request.requestBody.toString();
			Input input = (Input)JSON.deserialize(requestBody, Input.class);

			CC_Llamada__c llamadaDesborde = altaLlamadaHdtDesborde(input);
			output.requestId = input.requestId;
			output.resultado = 'OK';
			output.idLlamada = llamadaDesborde.Id;
			handleWebServiceResponse(request, fechaRecepcion, output, 200);

		} catch (Exception e) {
			output.resultado = 'KO';
			output.error = e.getMessage();
			CBK_Log.error(e);
			handleWebServiceResponse(request, fechaRecepcion, output, 500);
		}
		return output;
	}

	public class Input {
		public String requestId {get;set;}
		public String servicio {get;set;}
		public String connId {get;set;}
		public String ani {get;set;}
		public String dnis {get;set;}
		public String numPerso {get;set;}
		public String asunto {get;set;}
		public String idioma {get;set;}
		public String agente {get;set;}
		public String datos {get;set;}
		public String canalEmpleado {get;set;}
		public String fechaInicio {get;set;}
		public String fechaFin {get;set;}
		public String urlGrabacion {get;set;}
		public String connIdCognitivo {get;set;}
		public String cognitivoId {get;set;}
		public String nombreCampana {get;set;}
		public String perfil {get;set;}
	}

	global class Output {
		public String requestId {get;set;}
		public String resultado {get;set;}
		public String idLlamada {set;}
		public String error {get;set;}
	}

	private static CC_Llamada__c altaLlamadaHdtDesborde(Input input) {
		if (String.isBlank(input.requestId)
		|| String.isBlank(input.connId)
		|| String.isBlank(input.servicio)
		|| String.isBlank(input.ani)
		|| String.isBlank(input.fechaInicio)
		|| String.isBlank(input.fechaFin)
		|| String.isBlank(input.urlGrabacion)) {
			throw new DefaultException('Error: "requestId", "connId", "servicio", "ani", "fechaInicio", "fechaFin" y "urlGrabacion" son obligatorios');
		} else if (!formatoFechaValido(input.fechaInicio) || !formatoFechaValido(input.fechaFin)) {
			throw new DefaultException('Error: El formato válido para las fechas es "yyyy-MM-dd HH:mm:ss"');
		} else {
			List<CC_Servicio_Genesys__c> servicioGenesys = [SELECT Id FROM CC_Servicio_Genesys__c WHERE CBK_Negocio__c = 'HDT'
															AND CC_Codigo__c = :input.servicio LIMIT 1];
			if (servicioGenesys.isEmpty()) {
				throw new DefaultException('Error: servicio no registrado en Salesforce');
			} else {
				CC_Llamada__c llamadaDesborde = new CC_Llamada__c();
				try {
					llamadaDesborde.RecordTypeId = Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
					llamadaDesborde.KIN_Genesys_Cloud__c = true;
					llamadaDesborde.KIN_Llamada_Origen__c = true;
					//llamadaDesborde.KIN_Genesys_Cloud_URL_Grabacion__c = urlGrabacion(input.connId);
					llamadaDesborde.KIN_Genesys_Cloud_URL_Grabacion__c = input.urlGrabacion;
					llamadaDesborde.CC_Tipo__c = 'Entrante';
					llamadaDesborde.HDT_Desborde__c = true;
					llamadaDesborde.CC_Agente__c = input.agente;
					llamadaDesborde.CC_ConnId__c = input.connId;
					llamadaDesborde.CC_ANI__c = input.ani;
					llamadaDesborde.CC_DNIS__c = input.dnis;
					llamadaDesborde.CC_Servicio_Genesys__c = servicioGenesys[0].Id;
					llamadaDesborde.CC_Idioma__c = codigoIdioma(input.idioma);
					llamadaDesborde.CC_Asunto__c = input?.asunto.left(255);
					llamadaDesborde.CC_Datos_Genesys__c = input.datos;
					llamadaDesborde.CC_ConnId_Cognitivo__c = input.connIdCognitivo;
					llamadaDesborde.CC_NumPerso__c = input.numPerso;
					llamadaDesborde.CC_No_Identificado__c = false;
					llamadaDesborde.CC_Canal_del_Empleado__c = input.canalEmpleado?.normalizeSpace();
					llamadaDesborde.CC_Id_Cognitivo__c = input.cognitivoId;
					llamadaDesborde.CC_IdentCliente__c = '0';  //Sin datos ALF
					llamadaDesborde.CC_Campana_Genesys__c = input.nombreCampana;
					llamadaDesborde.CC_Perfil__c = input.perfil;
					llamadaDesborde.CC_Fecha_Inicio__c = Datetime.valueOf(input.fechaInicio.normalizeSpace());
					llamadaDesborde.CC_Fecha_Fin__c = Datetime.valueOf(input.fechaFin.normalizeSpace());

					identificarPorTelefono(llamadaDesborde, input.ani);
					/*
					if (String.isEmpty(input.casoId) && !String.isEmpty(llamadaDesborde.CC_Id_Cognitivo__c)) {
						//Buscamos el caso correspondiente al Id de cognitivo. Si no lo encuentra, lo crea con la información de la llamada y el chat obtenido de cognitivo
						caso = CC_WS_Recupera_LogConversacion.CC_WS_Recupera_Conversacion(llamadaDesborde);
					}
					*/
					insert llamadaDesborde;
				} catch (Exception e) {
					CBK_Log.error(e);
					throw new DefaultException('ExceptionType: ' + e.getTypeName() + ' - ExceptionMessage: ' + e.getMessage() + ' - Line: ' + e.getStackTraceString().substringBetween('Class.', '\nClass.'));
				}
				return llamadaDesborde;
			}
		}
	}

	private static void identificarPorTelefono(CC_Llamada__c llamada, String telefono) {
		if (String.isNotBlank(telefono)) {
			List<CC_Canal_Com__c> telefonos = [SELECT CC_ContactoId__c, CC_ContactoId__r.AccountId, CC_ContactoId__r.CC_Matricula__c FROM CC_Canal_Com__c
												WHERE CC_ContactoId__r.RecordType.DeveloperName = 'CC_Empleado'
												AND RecordType.DeveloperName = 'CC_Telefono'
												AND CC_Telefono__c = :(telefono.replace('+34', '').normalizeSpace()) LIMIT 2];
            if (!telefonos.isEmpty()) {
                if (telefonos.size() == 1) {
                    llamada.CC_Cuenta__c = telefonos[0].CC_ContactoId__r.AccountId;
                    llamada.CC_Contacto__c = telefonos[0].CC_ContactoId__c;
                    }
                    else{
                        Boolean encontrado =false;
                        for (CC_Canal_Com__c tel : telefonos) {
							if(!encontrado){

								if (!tel.CC_ContactoId__r.CC_Matricula__c.left(3).equals('U01')) {
									llamada.CC_Cuenta__c = tel.CC_ContactoId__r.AccountId;
									llamada.CC_Contacto__c = tel.CC_ContactoId__c;
									encontrado=true;
								}
								else{
									llamada.CC_Cuenta__c = tel.CC_ContactoId__r.AccountId;
									llamada.CC_Contacto__c = tel.CC_ContactoId__c;
								}
							}
                        }

                }

            }
		}
	}

	private static String codigoIdioma(String idioma) {
		return 'Inglés'.equals(idioma) ? 'en' : ('Catalán'.equals(idioma) ? 'ca' : 'es');
	}

	private static String urlGrabacion(String connId) {
		if (String.isBlank(connId)) {
			return null;
		} else {
			String url = 'https://apps.mypurecloud.ie/directory/#/engage/admin/interactions/';
			return url + connId;
		}
	}

	private static Boolean formatoFechaValido(String fecha) {
		return Pattern.matches('^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}$', fecha.normalizeSpace());
	}

	public static void handleWebServiceResponse(RestRequest request, Datetime fechaRecepcion, Output output, Integer codigo) {
		RestResponse response = RestContext.response;
		response.statusCode = codigo;
		response.addHeader('Content-Type', 'application/json');
		response.responseBody = Blob.valueOf(JSON.serializePretty(output));
		request.requestURI = '/AltaLlamadaHdtDesborde/*';
		register(request, response, fechaRecepcion, Datetime.now(), 'AltaLlamadaHdtDesborde', null);
	}

	private class DefaultException extends Exception {}
}