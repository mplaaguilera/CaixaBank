public with sharing class CC_GDPR {

	public class DerechoWrapper {
		@AuraEnabled public String idUrl {get;set;}
		@AuraEnabled public String tipo {get;set;}
		@AuraEnabled public String estado {get;set;}
		@AuraEnabled public String fechaEnvio {get;set;}
		@AuraEnabled public String idCasoUrl {get;set;}
		@AuraEnabled public String numeroCaso {get;set;}
		@AuraEnabled public String documentoCliente {get;set;}
	}

	@AuraEnabled
	public static List<DerechoWrapper> obtenerDerechosDelCliente(Id idCaso) {
		List<DerechoWrapper> derechos = new List<DerechoWrapper>();
		Id idCliente = [SELECT AccountId FROM Case WHERE Id = :idCaso].AccountId;
		if (idCliente != null) {
			String numeroDocumentoCliente = [SELECT CC_Numero_Documento__c FROM Account WHERE Id = :idCliente].CC_Numero_Documento__c;
			for (CC_Derecho__c derechoAux : [SELECT RecordType.Name, CC_Estado__c, CC_FechaEnvioCierre__c, CC_Caso__c,
												CC_Caso__r.CaseNumber, CC_DocumentoCliente__c FROM CC_Derecho__c
												WHERE CC_DocumentoCliente__c = :numeroDocumentoCliente ORDER BY CreatedDate DESC]) {
				DerechoWrapper derecho = new DerechoWrapper();
				derecho.idUrl = '/lightning/r/Case/' + derechoAux.Id + '/view';
				derecho.tipo = derechoAux.RecordType.Name;
				derecho.estado = derechoAux.CC_Estado__c;
				derecho.fechaEnvio = derechoAux.CC_FechaEnvioCierre__c == null ? '' : derechoAux.CC_FechaEnvioCierre__c.format();
				derecho.idCasoUrl = '/lightning/r/Case/' + derechoAux.CC_Caso__c + '/view';
				derecho.numeroCaso = derechoAux.CC_Caso__r.CaseNumber;
				derecho.documentoCliente = derechoAux.CC_DocumentoCliente__c;
				derechos.add(derecho);
			}
		}
		return derechos;
	}

	@AuraEnabled
	public static List<DerechoWrapper> obtenerDerechosDelCaso(Id idCaso) {
		List<DerechoWrapper> derechos = new List<DerechoWrapper>();
		for (CC_Derecho__c derechoAux : [SELECT RecordType.Name, CC_Estado__c, CC_FechaEnvioCierre__c, CC_Caso__c, CC_Caso__r.CaseNumber, CC_DocumentoCliente__c
											FROM CC_Derecho__c WHERE CC_Caso__c = :idCaso ORDER BY CreatedDate DESC]) {
			DerechoWrapper derecho = new DerechoWrapper();
			derecho.idUrl = '/lightning/r/Case/' + derechoAux.Id + '/view';
			derecho.tipo = derechoAux.RecordType.Name;
			derecho.estado = derechoAux.CC_Estado__c;
			derecho.fechaEnvio = derechoAux.CC_FechaEnvioCierre__c == null ? '' : derechoAux.CC_FechaEnvioCierre__c.format();
			derecho.idCasoUrl = '/lightning/r/Case/' + derechoAux.CC_Caso__c + '/view';
			derecho.numeroCaso = derechoAux.CC_Caso__r.CaseNumber;
			derecho.documentoCliente = derechoAux.CC_DocumentoCliente__c;
			derechos.add(derecho);
		}
		return derechos;
	}

	@AuraEnabled(cacheable=true)
	public static Map<Id, String> obtenerRecordTypesDerecho() {
		Map<Id, String> recordTypes = CC_MetodosUtiles.obtenerRecordTypes('CC_Derecho__c');
		for (Id idRecordType : recordTypes.keySet()) {
			if (recordTypes.get(idRecordType) == 'Revocación consentimiento aplicación condiciones personales ctos cotitularidad'
			|| recordTypes.get(idRecordType) == 'Revocación uso biometria') {
				recordTypes.remove(idRecordType);
			}
		}
		return recordTypes;
	}

	public static Map<String,String> formatearCamposPeticion(Map<String, String> camposPeticion) {
		if (String.isNotEmpty(camposPeticion.get('empresa'))) {
			camposPeticion.put('empresa', CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_Empresa', camposPeticion.get('empresa')));
		}
		if (String.isNotEmpty(camposPeticion.get('oficina'))) {
			camposPeticion.put('oficina', CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_Oficina', camposPeticion.get('oficina')));
		}
		if (String.isNotEmpty(camposPeticion.get('tipoDocumento'))) {
			camposPeticion.put('tipoDocumento', CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_TipoDocumento', camposPeticion.get('tipoDocumento')));
		}

		//Prueba tratamiento
		if (String.isNotEmpty(camposPeticion.get('tratamiento'))) {
			String tratamiento;
			for (String listTratamiento : camposPeticion.get('tratamiento').split(';')) {
				tratamiento = CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_Tratamiento', listTratamiento);
				if (tratamiento == '01') {
					camposPeticion.put('tratamiento1', tratamiento);
				} else if (tratamiento == '02') {
					camposPeticion.put('tratamiento2', tratamiento);
				} else if (tratamiento == '03') {
					camposPeticion.put('tratamiento3', tratamiento);
				} else if (tratamiento == '04') {
					camposPeticion.put('tratamiento4', tratamiento);
				} else if (tratamiento == '05') {
					camposPeticion.put('tratamiento5', tratamiento);
				} else if (tratamiento == '06') {
					camposPeticion.put('tratamiento6', tratamiento);
				} else if (tratamiento == '07') {
					camposPeticion.put('tratamiento7', tratamiento);
				} else if (tratamiento == '08') {
					camposPeticion.put('tratamiento8', tratamiento);
				}
			}
			//String tratamiento = CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_Tratamiento', camposPeticion.get('tratamiento'));
		}

		if (String.isEmpty(camposPeticion.get('numperso'))) {
			camposPeticion.put('numperso', '0');
		}
		if (String.isNotEmpty(camposPeticion.get('paisExpedicion'))) {
			camposPeticion.put('paisExpedicion', CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_Pais', camposPeticion.get('paisExpedicion')));
		}
		if (String.isNotEmpty(camposPeticion.get('pais'))) {
			camposPeticion.put('pais', CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_Pais', camposPeticion.get('pais')));
		}
		if (String.isNotEmpty(camposPeticion.get('provincia'))) {
			camposPeticion.put('provincia', CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_Provincia', camposPeticion.get('provincia')));
		}
		if (String.isNotEmpty(camposPeticion.get('derecho'))) {
			camposPeticion.put('derecho', CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_Derecho', camposPeticion.get('derecho')));
		}
		if (String.isNotEmpty(camposPeticion.get('mineriaDatos')) &&
			String.isNotEmpty(camposPeticion.get('telemarketing')) &&
			String.isNotEmpty(camposPeticion.get('mediosElectronicos')) &&
			String.isNotEmpty(camposPeticion.get('publicidadPostal')) &&
			String.isNotEmpty(camposPeticion.get('contactosGestores')) &&
			String.isNotEmpty(camposPeticion.get('cesionTerceros'))) {
			String textoRevocacion = '';
			textoRevocacion += '1.0' + CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_ValorConsentimiento', camposPeticion.get('mineriaDatos'));
			textoRevocacion += '2.1' + CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_ValorConsentimiento', camposPeticion.get('telemarketing'));
			textoRevocacion += '2.2' + CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_ValorConsentimiento', camposPeticion.get('mediosElectronicos'));
			textoRevocacion += '2.3' + CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_ValorConsentimiento', camposPeticion.get('publicidadPostal'));
			textoRevocacion += '2.4' + CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_ValorConsentimiento', camposPeticion.get('contactosGestores'));
			textoRevocacion += '3.0' + CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_ValorConsentimiento', camposPeticion.get('cesionTerceros'));
			camposPeticion.put('textoRevocacion', textoRevocacion);
		}
		if (String.isNotEmpty(camposPeticion.get('tipoPortabilidad'))) {
			camposPeticion.put('tipoPortabilidad', CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_TipoPortabilidad', camposPeticion.get('tipoPortabilidad')));
		}
		if (String.isNotEmpty(camposPeticion.get('tipoLimitacion'))) {
			camposPeticion.put('tipoLimitacion', CC_MetodosUtiles.getDestValueLOVMeta('CC_GDPR_TipoLimitacion', camposPeticion.get('tipoLimitacion')));
		}
		return camposPeticion;
	}

	public static String construirCuerpoPeticion(Map<String, String> camposPeticion, String cuerpoPeticion) {
		camposPeticion = formatearCamposPeticion(camposPeticion);
		cuerpoPeticion = cuerpoPeticion.replace('##canal##', camposPeticion.get('canal'));
		cuerpoPeticion = cuerpoPeticion.replace('##canalComunicacion##', camposPeticion.get('canalComunicacion'));
		cuerpoPeticion = cuerpoPeticion.replace('##codigoPostal##', camposPeticion.get('codigoPostal'));
		cuerpoPeticion = cuerpoPeticion.replace('##localidad##', camposPeticion.get('localidad'));
		cuerpoPeticion = cuerpoPeticion.replace('##nombre##', camposPeticion.get('nombre'));
		cuerpoPeticion = cuerpoPeticion.replace('##nombreVia##', camposPeticion.get('nombreVia'));
		cuerpoPeticion = cuerpoPeticion.replace('##pais##', camposPeticion.get('pais'));
		cuerpoPeticion = cuerpoPeticion.replace('##primerApell##', camposPeticion.get('primerApell'));
		cuerpoPeticion = cuerpoPeticion.replace('##provincia##', camposPeticion.get('provincia'));
		cuerpoPeticion = cuerpoPeticion.replace('##resto##', camposPeticion.get('resto'));
		cuerpoPeticion = cuerpoPeticion.replace('##segundoApell##', camposPeticion.get('segundoApell'));
		cuerpoPeticion = cuerpoPeticion.replace('##derecho##', camposPeticion.get('derecho'));
		cuerpoPeticion = cuerpoPeticion.replace('##identPortabilidad##', camposPeticion.get('identPortabilidad'));
		cuerpoPeticion = cuerpoPeticion.replace('##textoOposicion##', camposPeticion.get('textoOposicion'));
		cuerpoPeticion = cuerpoPeticion.replace('##textoRectificacion##', camposPeticion.get('textoRectificacion'));
		cuerpoPeticion = cuerpoPeticion.replace('##textoRevocacion##', camposPeticion.get('textoRevocacion'));
		cuerpoPeticion = cuerpoPeticion.replace('##tipoPortabilidad##', camposPeticion.get('tipoPortabilidad'));
		cuerpoPeticion = cuerpoPeticion.replace('##tipoLimitacion##', camposPeticion.get('tipoLimitacion'));
		cuerpoPeticion = cuerpoPeticion.replace('##empresa##', camposPeticion.get('empresa'));
		cuerpoPeticion = cuerpoPeticion.replace('##estado##', camposPeticion.get('estado'));
		//cuerpoPeticion = cuerpoPeticion.replace('##indicadorCerrada##', camposPeticion.get('indicadorCerrada'));
		cuerpoPeticion = cuerpoPeticion.replace('##motivo##', camposPeticion.get('motivo'));
		cuerpoPeticion = cuerpoPeticion.replace('##numeroGrabacion##', camposPeticion.get('numeroGrabacion'));
		cuerpoPeticion = cuerpoPeticion.replace('##oficina##', camposPeticion.get('oficina'));
		cuerpoPeticion = cuerpoPeticion.replace('##documento##', camposPeticion.get('documento'));
		cuerpoPeticion = cuerpoPeticion.replace('##numperso##', camposPeticion.get('numperso'));
		cuerpoPeticion = cuerpoPeticion.replace('##paisExpedicion##', camposPeticion.get('paisExpedicion'));
		cuerpoPeticion = cuerpoPeticion.replace('##tipoDocumento##', camposPeticion.get('tipoDocumento'));

		if (camposPeticion.get('tratamiento1') != null) {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento1##', camposPeticion.get('tratamiento1'));
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion1##', 'true');
		} else {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento1##','01');
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion1##', 'false');
		}
		if (camposPeticion.get('tratamiento2') != null) {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento2##', camposPeticion.get('tratamiento2'));
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion2##', 'true');
		} else {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento2##', '02');
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion2##', 'false');
		}
		if (camposPeticion.get('tratamiento3') != null) {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento3##', camposPeticion.get('tratamiento3'));
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion3##', 'true');
		} else {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento3##', '03');
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion3##', 'false');
		}
		if (camposPeticion.get('tratamiento4') != null) {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento4##', camposPeticion.get('tratamiento4'));
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion4##', 'true');
		} else {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento4##', '04');
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion4##', 'false');
		}
		if (camposPeticion.get('tratamiento5') != null) {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento5##', camposPeticion.get('tratamiento5'));
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion5##', 'true');
		} else {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento5##', '05');
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion5##', 'false');
		}
		if (camposPeticion.get('tratamiento6') != null) {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento6##', camposPeticion.get('tratamiento6'));
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion6##', 'true');
		} else {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento6##', '06');
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion6##', 'false');
		}
		if (camposPeticion.get('tratamiento7') != null) {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento7##', camposPeticion.get('tratamiento7'));
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion7##', 'true');
		} else {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento7##', '07');
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion7##', 'false');
		}
		if(camposPeticion.get('tratamiento8') != null){
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento8##', camposPeticion.get('tratamiento8'));
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion8##', 'true');
		} else {
			cuerpoPeticion = cuerpoPeticion.replace('##idTratamiento8##', '08');
			cuerpoPeticion = cuerpoPeticion.replace('##oposicion8##', 'false');
		}
		return cuerpoPeticion;
	}

	public static Map<String,String> parsearCamposRespuesta(String cuerpoRespuesta) {
		Map<String, String> camposRespuesta = new Map<String, String>();

		// Cargar el XML de respuesta
		DOM.Document documentoXML = new DOM.Document();
		documentoXML.load(cuerpoRespuesta);
		DOM.XmlNode raiz = documentoXML.getRootElement();

		// Guardar en un mapa todos los campos del XML de respuesta
		if (raiz.getNodeType() == DOM.XMLNodeType.ELEMENT) {
			if (raiz.getName() == 'Envelope') {
				for (Dom.XMLNode hijo: raiz.getChildElements()) {
					if (hijo.getNodeType() == DOM.XMLNodeType.ELEMENT && hijo.getName() == 'Body') {
						for (Dom.XMLNode hijo2: hijo.getChildElements()) {
							if (hijo2.getName() == 'AltaSolicitudResponse') {
								for (Dom.XMLNode hijo3: hijo2.getChildElements()) {
									if (hijo3.getName() == 'return') {
										for (Dom.XMLNode hijo4: hijo3.getChildElements()) {
											if (hijo4.getNodeType() == DOM.XMLNodeType.ELEMENT) {
												if (hijo4.getName() == 'resultado') {
													camposRespuesta.put('resultado', hijo4.getText());
												}
												if (hijo4.getName() == 'idSolicitud') {
													camposRespuesta.put('idSolicitud', hijo4.getText());
												}
												if (hijo4.getName() == 'errorAlta') {
													for (Dom.XMLNode hijo5: hijo4.getChildElements()) {
														if (hijo5.getNodeType() == DOM.XMLNodeType.ELEMENT) {
															if (hijo5.getName() == 'codigoError') {
																camposRespuesta.put('codigoError', hijo5.getText());
															}
															if (hijo5.getName() == 'descripcionError') {
																camposRespuesta.put('descripcionError', hijo5.getText());
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}

		return camposRespuesta;
	}

	@future(callout=true)
	public static void altaSolicitudFuture(List<Id> derechosId) {
		List<CC_Derecho__c> derechos = new List<CC_Derecho__c>();

		for (CC_Derecho__c derecho : [SELECT CSBD_Opportunity__c,CC_Tratamiento__c, CC_CodigoPostal__c, CC_Localidad__c, CC_Nombre__c,
										CC_NombreVia__c, CC_Pais__c, CC_Apellido1__c, CC_Provincia__c, CC_Resto__c, CC_Apellido2__c,
										RecordType.DeveloperName, RecordType.Name, CC_Empresa__c, CC_Oficina__c, CC_DocumentoCliente__c,
										CC_NumPerso__c, CC_IdentificadorPortabilidad__c, CC_TextoOposicion__c, CC_TextoRectificacion__c,
										CC_TipoPortabilidad__c, CC_TipoLimitacion__c, CC_UtilizarDatosMineria__c, CC_Telemarketing__c,
										CC_MediosElectronicos__c, CC_PublicidadPostal__c, CC_ContactosGestores__c, CC_CesionTerceros__c
										FROM CC_Derecho__c WHERE Id IN :derechosId]) {

			Map<String, String> camposPeticion = new Map<String, String>{
				'canal' => '6', //Call Center
				'canalComunicacion' => '2', //Por teléfono
				'codigoPostal' => derecho.CC_CodigoPostal__c,
				'localidad' => derecho.CC_Localidad__c,
				'nombre' => derecho.CC_Nombre__c,
				'nombreVia' => derecho.CC_NombreVia__c,
				'pais' => derecho.CC_Pais__c,
				'primerApell' => derecho.CC_Apellido1__c,
				'provincia' => derecho.CC_Provincia__c,
				'resto' => derecho.CC_Resto__c ?? '',
				'segundoApell' => derecho.CC_Apellido2__c ?? '',
				'derecho' => derecho.RecordType.Name,
				'identPortabilidad' => derecho.CC_IdentificadorPortabilidad__c ?? '',
				'textoOposicion' => derecho.CC_TextoOposicion__c ?? '',
				'textoRectificacion' => derecho.CC_TextoRectificacion__c ?? '',
				'tipoPortabilidad' => derecho.CC_TipoPortabilidad__c ?? '',
				'tipoLimitacion' => derecho.CC_TipoLimitacion__c ?? '',
				'mineriaDatos' => derecho.CC_UtilizarDatosMineria__c ?? '',
				'telemarketing' => derecho.CC_Telemarketing__c ?? '',
				'mediosElectronicos' => derecho.CC_MediosElectronicos__c ?? '',
				'publicidadPostal' => derecho.CC_PublicidadPostal__c ?? '',
				'contactosGestores' => derecho.CC_ContactosGestores__c ?? '',
				'cesionTerceros' => derecho.CC_CesionTerceros__c ?? '',
				'empresa' => derecho.CC_Empresa__c,
				'motivo' => '02', //Por cuenta de terceros
				'numeroGrabacion' => '0',
				'oficina' => derecho.CC_Oficina__c,
				'documento' => derecho.CC_DocumentoCliente__c,
				'numperso' => derecho.CC_NumPerso__c,
				'paisExpedicion' => 'ESPAÑA',
				'tipoDocumento' => 'NIF',
				'tratamiento' => derecho.CC_Tratamiento__c ?? '',
				'estado' => 'A' //Abierta
			};

			if (derecho.RecordType.DeveloperName == 'CC_Oposicion_comunicaciones_interes_legitimo') {
				camposPeticion.put('estado', derecho.CC_NumPerso__c != null ? 'C' : 'A');
			}

			Map<String, String> camposRespuesta = new Map<String, String>();
			String descripcionError = '';
			String detalleError = '';

			CC_InterfaceSettings__mdt cfgIntegracionGdpr;
			if (derecho.CSBD_Opportunity__c != null) {
				cfgIntegracionGdpr = CC_MetodosUtiles.getInterfazConfigBody('CSBD_Int_GDPR');
			}
			if (cfgIntegracionGdpr == null) {
				cfgIntegracionGdpr = CC_MetodosUtiles.getInterfazConfigBody('CC_Int_GDPR');
			}

			CC_InterfaceSettings__mdt cfgIntegracionGdprBody;
			if (derecho.RecordType.DeveloperName == 'CC_Oposicion') {
				cfgIntegracionGdprBody = CC_MetodosUtiles.getInterfazConfigBody('CC_Int_GDPR_Oposicion');
			} else if (derecho.RecordType.DeveloperName == 'CC_Oposicion_comunicaciones_interes_legitimo') {
				cfgIntegracionGdprBody = CC_MetodosUtiles.getInterfazConfigBody('CC_Int_GDPR_Derecho_Oposicion');
			} else {
				cfgIntegracionGdprBody = cfgIntegracionGdpr;
			}
			String cuerpoPeticion = construirCuerpoPeticion(camposPeticion, cfgIntegracionGdprBody.CC_Body__c);

			HttpRequest peticion = new HttpRequest();
			HTTPResponse respuesta;
			String cuerpoRespuesta = '';
			Datetime fechaEnvio;

			try {
				peticion.setTimeOut(Integer.valueOf(cfgIntegracionGdpr.CC_TimeOut__c));
				peticion.setMethod(cfgIntegracionGdpr.CC_TipoPeticion__c);
				peticion.setHeader('Content-Type', cfgIntegracionGdpr.CC_ContentType__c);
				peticion.setHeader('Content-Length', '' + cuerpoPeticion.length());
				if (!Test.isRunningTest()) {
					peticion.setClientCertificateName(cfgIntegracionGdpr.CC_Certificado__c);
				}

				peticion.setEndpoint(cfgIntegracionGdpr.CC_EndPoint__c);
				peticion.setbody(cuerpoPeticion);
				fechaEnvio = Datetime.now();
				respuesta = new Http().send(peticion);
				cuerpoRespuesta = respuesta.getBody();

				if (respuesta.getStatusCode() != 200) {
					CalloutException errorRespuesta = new CalloutException();
					errorRespuesta.setMessage(respuesta.getBody());
					throw errorRespuesta;
				}
			} catch (Exception e) {
				// Error de comunicaciones
				CBK_Log.error(e, 'CC_GDPR - altaSolicitudFuture - Error de comunicaciones');
				descripcionError = 'Error de comunicaciones';
				detalleError = e.getMessage();
				derecho.CC_Estado__c = 'Erróneo';
				derechos.add(derecho);
			}

			if (descripcionError == '') {
				try {
					camposRespuesta = parsearCamposRespuesta(cuerpoRespuesta);
					if (camposRespuesta.get('resultado') == 'OK') {
						derecho.CC_IdentificadorSolicitud__c = camposRespuesta.get('idSolicitud');
						derecho.CC_Estado__c = 'Enviado';
						derecho.CC_FechaEnvioCierre__c = fechaEnvio;
					} else {
						derecho.CC_Estado__c = 'Erróneo';
					}
					derechos.add(derecho);

				} catch (Exception e) { //Error en el tratamiento de la respuesta
					descripcionError = 'Respuesta inválida';
					detalleError = e.getMessage();
					derecho.CC_Estado__c = 'Erróneo';
					derechos.add(derecho);
				}
			}
		}

		if (!derechos.isEmpty()) {
			update derechos;
		}
	}

	@InvocableMethod(label='Enviar solicitud de derecho a GDPR' description='Enviar solicitud de derecho a GDPR')
	public static void altaSolicitud(List<Id> derechosId) {
		altaSolicitudFuture(derechosId);
	}

	@AuraEnabled
	public static void crearTareaGDPR(List<CC_Derecho__c> derechoEjercido) {
		try {
			// Filtrar derechos con casos válidos y crear Set de IDs
			Set<Id> casosIds = new Set<Id>();
			for (CC_Derecho__c derecho : derechoEjercido) {
				if (derecho.CC_Caso__c != null) {
					casosIds.add(derecho.CC_Caso__c);
				}
			}
			
			if (casosIds.isEmpty()) return;
			
			// Query optimizada con mapa directo
			Map<Id, Case> mapaCasos = new Map<Id, Case>([SELECT Id, CaseNumber, Subject, Account.Name, Contact.Name 
						 FROM Case 
						 WHERE Id IN :casosIds]);

			// Crear tareas directamente sin mapa intermedio
			List<Task> tareas = new List<Task>();
			String recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
			for (CC_Derecho__c derecho : derechoEjercido) {
				Case caso = mapaCasos.get(derecho.CC_Caso__c);
				if (caso != null) {
					// Obtener el nombre del Record Type usando el método existente
					String nombreRecordType = CC_MetodosUtiles.getRecordTypeNameFromId('CC_Derecho__c', derecho.RecordTypeId);
					tareas.add(new Task(
						WhatId = caso.Id,
						Subject = 'GDPR',
						Type = 'GDPR',
						Description = 'Se ha iniciado el proceso de ejercicio de derecho GDPR para el caso ' + caso.CaseNumber + 
									'\nCliente: ' + (caso.Account.Name ?? 'N/A') +
									'\nContacto: ' + (caso.Contact.Name ?? 'N/A') +
									'\nAsunto: ' + (caso.Subject ?? 'N/A') +
									'\nDerecho ejercido: ' + (nombreRecordType ?? 'N/A'),
						Status = 'Completed',
						Priority = 'Normal',
						RecordTypeId = recordTypeId
					));
				}
			}

			if (!tareas.isEmpty()) {
				insert tareas;
			}

		} catch (Exception e) {
			// Log del error pero no fallar la operación principal
			CBK_Log.error(e, 'CC_GDPR - crearTareaGDPR - Error al crear tarea GDPR');
		}
	}
}