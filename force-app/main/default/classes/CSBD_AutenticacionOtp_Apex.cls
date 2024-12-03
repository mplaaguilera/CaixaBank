public with sharing class CSBD_AutenticacionOtp_Apex {

	@AuraEnabled
	public static Map<String, Boolean> getDatos(Id idOportunidad, Id idCliente) {
		return new Map<String, Boolean>{
			'llamadaEnCurso' => llamadaEnCurso(idOportunidad) || tienePermisoAutenticacion(),
			'clienteBloqueado' => clienteBloqueado(idOportunidad, idCliente),
			'usuarioDesarrollador' => ![SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()
										AND PermissionSet.Name = 'CSBD_Desarrollo' LIMIT 1].isEmpty()
		};
	}

	@AuraEnabled(cacheable=true)
	public static Map<String, Boolean> getDatosAsync(String canalEntradaCaso) {
		return new Map<String, Boolean>{
			'autEmergenciaHabilitada' => !([SELECT CC_Activa__c FROM CC_Settings__c WHERE Name = 'CC_VisibilidadBotonEmergenciaAut']?.CC_Activa__c ?? false),
			'canalAutenticable' => canalAutenticable(canalEntradaCaso)
		};

		/*
		//retorno.put('Representante', (caso.CC_Representante__c != null));

		Boolean resultado = false;
		List<String> estadosNoOk = new List<String>{
			'ERROR', 'UNAUTHORIZED', 'TIMEOUT', 'ABORTED', 'EXPIRED', 'NOT_IDENTIFIED', 'IS_MINOR', 'IS_A_COMPANY', 'NOTIFICATIONS_OFF', 'SIN ESTADO'
		};
		if (String.isNotBlank(oportunidad.CSBD_EstadoAutenticacion__c) && !estadosNoOk.includes(oportunidad.CSBD_EstadoAutenticacion__c)) {
			resultado = true;
			//PERMITIR lanzar autenticación (sólo 1 vez más)
			if (oportunidad.CSBD_EstadoAutenticacion__c == 'REJECTED' && (oportunidad.CSBD_IntentosAutenticacion__c == null || oportunidad.CSBD_IntentosAutenticacion__c == 0)){
				resultado = false;
			}
		}
		retorno.put('Resultado', resultado);
		*/
	}

	private static List<CC_Lista_Valores__c> getPreguntas(String listaPreguntas) {
		return [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c
				WHERE RecordType.DeveloperName = 'CC_Valor'
				AND CC_Activa__c = TRUE AND CC_Lista__r.Name = :listaPreguntas];
	}

	@AuraEnabled
	public static Map<String, String> getPreguntasNivel2(Id recordId) {
		Opportunity oportunidad = [SELECT Account.RecordType.DeveloperName, Account.AV_Age__c, Account.PersonMobilePhone,
									CSBD_CasoOrigen__r.CC_Representante__c,
									CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.PersonMobilePhone,
									CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.AV_Age__c,
									CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.AV_NumPerso__c,
									CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.CC_NumPerso__c,
									CSBD_Contact__r.RecordType.DeveloperName, CSBD_Contact__r.CIBE_Telefono1__c,
									Account.AV_NumPerso__c, Account.CC_NumPerso__c,
									CSBD_CasoOrigen__r.CC_MCC_Causa__r.CC_Omitir_preguntas_Nivel_2__c
									FROM Opportunity WHERE Id = :recordId];

		List<CC_Lista_Valores__c> listaPreguntas = [SELECT CC_Valor__c, CC_Orden__c, CC_Servicio__c, CC_Mensajes_Mostrar__c
													FROM CC_Lista_Valores__c WHERE RecordType.Name = 'Valor'
													AND CC_Activa__c = true AND CC_Lista__r.Name = 'Preguntas OTPSMS 2 Nivel'];

		Map<String, String> preguntas = new Map<String, String>();
		List<String> preguntas1 = new List<String>();
		List<String> preguntas2 = new List<String>();
		Boolean error = false;
		String preguntaForzada;
		//Comprobacion de los datos si estan vacios
		//Cuenta representante
		// if (oportunidad.CSBD_CasoOrigen__r.CC_MCC_Causa__r.CC_Omitir_preguntas_Nivel_2__c) {
		// 	preguntas.put('OmitirPreguntas', 'true');
		// } else {
			if (!listaPreguntas.isEmpty()) {
				if (oportunidad.CSBD_CasoOrigen__r.CC_Representante__c != null) {
					if (oportunidad.CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.AV_Age__c == null
					&& oportunidad.CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.PersonMobilePhone == null) {
						error = true;
					} else if (oportunidad.CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.AV_Age__c == null) {
						preguntaForzada = 'telefono';
					} else if (oportunidad.CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.PersonMobilePhone == null) {
						preguntaForzada = 'edad';
					}
				} else if (oportunidad.Account.RecordType.DeveloperName == 'CC_Cliente'
				&& oportunidad.CSBD_Contact__r.RecordType.DeveloperName == 'CIBE_Apoderado') {
					//Cuenta juridica con apoderado
					if (oportunidad.CSBD_Contact__r.CIBE_Telefono1__c == null) {
						error = true;
					}
				} else {
					//Cuenta fisica
					if (oportunidad.Account.AV_Age__c == null
					&& oportunidad.Account.PersonMobilePhone == null) {
						error = true;
					} else if (oportunidad.Account.AV_Age__c == null) {
						preguntaForzada = 'telefono';
					} else if (oportunidad.Account.PersonMobilePhone == null) {
						preguntaForzada = 'edad';
					}
				}
				for (CC_Lista_Valores__c listaPregunta : listaPreguntas) {
					if (listaPregunta.CC_Servicio__c == 'Pregunta 1') {
						for (Integer i = 0; i < listaPregunta.CC_Orden__c; i++) {
							preguntas1.add(listaPregunta.CC_Valor__c);
						}
					} else if (listaPregunta.CC_Servicio__c == 'Pregunta 2') {
						for (Integer i = 0; i < listaPregunta.CC_Orden__c; i++) {
							preguntas2.add(listaPregunta.CC_Valor__c);
						}
					}
				}
			// }
		}

		if (!preguntas1.isEmpty()) {
			Integer preguntaRandom1 = Integer.valueOf((Math.random() * preguntas1.size()));
			if (preguntas1.get(preguntaRandom1).toLowerCase().contains('cuenta')) {
				preguntas.put('pregunta1', preguntas1.get(preguntaRandom1));
				for (CC_Lista_Valores__c valor : listaPreguntas) {
					if (valor.CC_Valor__c == preguntas1.get(preguntaRandom1) && valor.CC_Servicio__c == 'Pregunta 1') {
						preguntas.put('textoAyuda1', valor.CC_Mensajes_Mostrar__c);
						break;
					}
				}
			} else {
				//Si el caso tiene apoderado forzamos la pregunta de telefono
				if (oportunidad.Account.RecordType.DeveloperName == 'CC_Cliente'
				&& oportunidad.CSBD_Contact__r.RecordType.DeveloperName == 'CIBE_Apoderado'
				|| preguntaForzada == 'telefono') {
					for (CC_Lista_Valores__c valor : listaPreguntas) {
						if (valor.CC_Valor__c.toLowerCase().contains('teléfono') && valor.CC_Servicio__c == 'Pregunta 1') {
							preguntas.put('pregunta1', valor.CC_Valor__c);
							preguntas.put('textoAyuda1', valor.CC_Mensajes_Mostrar__c);
						}
					}
				} else if (preguntaForzada == 'edad') {
					for (CC_Lista_Valores__c valor : listaPreguntas) {
						if (valor.CC_Valor__c.toLowerCase().contains('edad') && valor.CC_Servicio__c == 'Pregunta 1') {
							preguntas.put('pregunta1', valor.CC_Valor__c);
							preguntas.put('textoAyuda1', valor.CC_Mensajes_Mostrar__c);
						}
					}
				} else if (oportunidad.Account.RecordType.DeveloperName != 'CC_Cliente'
				|| oportunidad.CSBD_Contact__r.RecordType.DeveloperName != 'CIBE_Apoderado'
				|| String.isNotEmpty(preguntaForzada)) {
					preguntas.put('pregunta1', preguntas1.get(preguntaRandom1));
					for (CC_Lista_Valores__c valor : listaPreguntas) {
						if (valor.CC_Valor__c == preguntas1.get(preguntaRandom1) && valor.CC_Servicio__c == 'Pregunta 1') {
							preguntas.put('textoAyuda1', valor.CC_Mensajes_Mostrar__c);
							break;
						}
					}
				}
			}
		}

		if (!preguntas2.isEmpty()) {
			Integer preguntaRandom2 = Integer.valueOf((Math.random() * preguntas2.size()));
			if (preguntas2.get(preguntaRandom2).toLowerCase().contains('cuenta')) {
				preguntas.put('pregunta2', preguntas2.get(preguntaRandom2));
				for (CC_Lista_Valores__c valor : listaPreguntas) {
					if (valor.CC_Valor__c == preguntas2.get(preguntaRandom2) && valor.CC_Servicio__c == 'Pregunta 2') {
						preguntas.put('textoAyuda2', valor.CC_Mensajes_Mostrar__c);
						break;
					}
				}
			} else {
				//Si el caso tiene apoderado forzamos la pregunta de telefono
				if ((oportunidad.Account.RecordType.DeveloperName == 'CC_Cliente' && oportunidad.CSBD_Contact__r.RecordType.DeveloperName == 'CIBE_Apoderado') || preguntaForzada == 'telefono') {
					for (CC_Lista_Valores__c valor : listaPreguntas) {
						if (valor.CC_Valor__c.toLowerCase().contains('teléfono') && valor.CC_Servicio__c == 'Pregunta 2') {
							preguntas.put('pregunta2', valor.CC_Valor__c);
							preguntas.put('textoAyuda2', valor.CC_Mensajes_Mostrar__c);
						}
					}
				} else if (preguntaForzada == 'edad') {
					for (CC_Lista_Valores__c valor : listaPreguntas) {
						if (valor.CC_Valor__c.toLowerCase().contains('edad') && valor.CC_Servicio__c == 'Pregunta 2') {
							preguntas.put('pregunta2', valor.CC_Valor__c);
							preguntas.put('textoAyuda2', valor.CC_Mensajes_Mostrar__c);
						}
					}
				} else if ((!(oportunidad.Account.RecordType.DeveloperName == 'CC_Cliente' && oportunidad.CSBD_Contact__r.RecordType.DeveloperName == 'CIBE_Apoderado')) || (!String.isEmpty(preguntaForzada))) {
					preguntas.put('pregunta2', preguntas2.get(preguntaRandom2));
					for (CC_Lista_Valores__c valor : listaPreguntas) {
						if (valor.CC_Valor__c == preguntas2.get(preguntaRandom2) && valor.CC_Servicio__c == 'Pregunta 2') {
							preguntas.put('textoAyuda2', valor.CC_Mensajes_Mostrar__c);
							break;
						}
					}
				}
			}
		}
		if (error) {
			preguntas.put('error', 'true');
		}
		return preguntas;
	}


	@AuraEnabled
	public static Map<String, String> segundoNivel(Id recordId, Boolean valido, String nivel, String pregunta1, String pregunta2, String respuesta1, String respuesta2, String validacion1, String validacion2, Boolean enviarSMS) { //Boolean enviarPreguntas
		String resultado = 'OK';
		Opportunity oportunidad = [SELECT AccountId, Account.RecordType.DeveloperName, Account.AV_Age__c, Account.PersonMobilePhone,
									CSBD_CasoOrigen__r.CC_Representante__c,
									CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.PersonMobilePhone,
									CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.AV_Age__c,
									CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.CC_NumPerso__c,
									CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.AV_NumPerso__c,
									CSBD_Contact__r.RecordType.DeveloperName,
									CSBD_Contact__r.CIBE_Telefono1__c, Account.AV_NumPerso__c,
									CSBD_Contact__r.AV_NumPerso__c, Account.CC_NumPerso__c,
									CSBD_Contact__r.CC_NumPerso__c, CSBD_Idioma_Solicitud__c
									FROM Opportunity WHERE Id = :recordId];

		Task llamada = [SELECT CC_Llamada_Id__r.CC_Tipo__c, CC_Llamada_Id__r.CC_DNIS__c FROM Task
						WHERE WhatId = :recordId AND RecordType.DeveloperName = 'CSBD_Task'
						AND CreatedDate = TODAY AND Status = 'Open' AND CC_Llamada_Id__c != null
						ORDER BY CreatedDate DESC LIMIT 1] ?? null;

		//Crear registro
		CC_Comunicaciones__c autenticacion = new CC_Comunicaciones__c();
		autenticacion.RecordTypeId = Schema.SObjectType.CC_Comunicaciones__c.getRecordTypeInfosByDeveloperName().get('CSBD_Autenticacion').getRecordTypeId();
		autenticacion.CSBD_Opportunity__c = recordId;
		autenticacion.CC_Cliente__c = oportunidad.AccountId;
		autenticacion.CC_Nivel__c = nivel;
		Boolean preguntaRespuestaVacia1 = String.isEmpty(pregunta1) || String.isEmpty(respuesta1);
		Boolean preguntaRespuestaVacia2 = String.isEmpty(pregunta2) || String.isEmpty(respuesta2);

		autenticacion.CC_Pregunta_1__c = pregunta1;
		autenticacion.CC_Respuesta_1__c = respuesta1;
		autenticacion.CC_Pregunta_2__c = pregunta2;
		autenticacion.CC_Respuesta_2__c = respuesta2;
		// if (!enviarPreguntas) {
			if (!preguntaRespuestaVacia1) {
				autenticacion.CC_Validacion_1__c = (!String.isEmpty(validacion1) && validacion1 == 'true') ?  'OK' : 'NOK';
			}
			if (!preguntaRespuestaVacia2) {
				autenticacion.CC_Validacion_2__c = (!String.isEmpty(validacion2) && validacion2 == 'true') ?  'OK' : 'NOK';
			}
		// }

		if (nivel != 'Emergencia') {
			autenticacion.CC_Perfil_empleado__c = perfilUsuarioFormat();
			autenticacion.CC_Tipo_Llamada__c = llamada?.CC_Llamada_Id__r?.CC_Tipo__c;
		}

		// if ((valido || enviarPreguntas) && !enviarSMS) {
		if (valido && !enviarSMS) {
			autenticacion.CC_Estado__c = 'Pdte. Envío';
		// } else if (enviarSMS && (valido || enviarPreguntas)) {
		} else if (valido && enviarSMS) {
			autenticacion.CC_Estado__c = 'Aprobado';
			oportunidad.CSBD_EstadoAutenticacion__c  = 'APPROVED';
		} else {
			autenticacion.CC_Estado__c = 'Cerrado';
			autenticacion.CC_Fecha_Validacion__c = Datetime.now();
			autenticacion.CC_Resultado_Validacion__c = 'Identificación NOK';

			String idioma = new Map<String, String>{'Castellano' => 'es', 'Catalán' => 'ca', 'Inglés' => 'en'}.get(oportunidad.CSBD_Idioma_Solicitud__c) ?? 'es';
			resultado = [SELECT CC_Texto_Plantilla__c FROM CC_ConfigNotifCliente__mdt
														WHERE CC_Proceso__c = 'Notificacion OTP KO'
														AND CC_Canal__c = 'Email' AND CC_Idioma__c = :idioma
														AND CC_Activa__c = true LIMIT 1]?.CC_Texto_Plantilla__c ?? 'OK';
		}
		insert autenticacion;

		oportunidad.CSBD_UltimaAutenticacionNivel__c = nivel;
		if (!valido) {
			oportunidad.CSBD_UltimaAutenticacionOk__c = valido;
			oportunidad.CSBD_IntentosAutenticacion__c = 0;
			oportunidad.CSBD_UltimaAutenticacionFecha__c = Datetime.now();
		}
		update oportunidad;

		return new Map<String, String>{'id' => String.valueOf(autenticacion.Id), 'resultado' => resultado};
	}

	@AuraEnabled(cacheable=true)
	public static Map<String, List<CC_Lista_Valores__c>> getPreguntasEmergencia() {
		return new Map<String, List<CC_Lista_Valores__c>>{
			'basicas' => getPreguntas('Preguntas Básicas OTPSMS'),
			'aleatorias' => getPreguntas('Preguntas Aleatorias OTPSMS')
		};
	}

	@AuraEnabled
	public static List<CC_Comunicaciones__c> getAutenticaciones(Id idCliente, Id recordId) {
		return [SELECT Name, CreatedDate, CC_Estado__c, CSBD_EstadoFinal__c, CC_Fecha_Envio__c, CC_Fecha_Validacion__c,
				CC_Resultado_Validacion__c, CC_Mensaje_Error__c, CSBD_Opportunity__c, CSBD_Opportunity__r.CSBD_Identificador__c, CC_Nivel__c
				FROM CC_Comunicaciones__c WHERE RecordType.DeveloperName = 'CSBD_Autenticacion'
				AND CSBD_Opportunity__c != NULL AND CC_Cliente__c != NULL
				AND (CSBD_Opportunity__c = :recordId OR CC_Cliente__c = :idCliente)
				AND CreatedDate = LAST_N_DAYS:365 ORDER BY CreatedDate DESC];
	}

	@AuraEnabled
	public static Boolean clienteBloqueado(Id idOportunidad, Id idCuenta) {
		Boolean bloqueado = false;
		if (!String.isEmpty(idCuenta)) {
			CC_Settings__c params = [SELECT CC_Configuracion_1__c, CC_Configuracion_2__c FROM CC_Settings__c
										WHERE Name = 'CC_Autenticacion_Bloqueos' AND CC_Activa__c = TRUE];

			Datetime fechaBloqueo = Datetime.now().addHours(-Integer.valueOf(params.CC_Configuracion_2__c));
			List<CC_Comunicaciones__c> autenticaciones = [SELECT CC_Estado__c, CC_Nivel__c, CC_Codigo_Error__c, CC_Resultado_Validacion__c
															FROM CC_Comunicaciones__c WHERE RecordType.DeveloperName = 'CSBD_Autenticacion'
															AND CC_Cliente__c = :idCuenta AND CreatedDate > :fechaBloqueo ORDER BY CreatedDate DESC];
			Integer intentos = 0;
			if (!autenticaciones.isEmpty() && autenticaciones[0].CC_Estado__c != 'Aprobado') {
				List<String> valoresPermitidos = new List<String>{
					'Cancelada por agente', 'Error', 'Pendiente', 'En progreso', 'Pdte. Envío', 'Pdte. Validar'
				};
				for (CC_Comunicaciones__c autenticacion : autenticaciones) {
					if (autenticacion.CC_Estado__c == 'Denegado') {
						bloqueado = true;
						break;
					} else if (autenticacion.CC_Estado__c == 'Aprobado') {
						break;
					} else {
						if (autenticacion.CC_Nivel__c == 'Cliente Digital' && !valoresPermitidos.contains(autenticacion.CC_Estado__c)) {
							intentos++;
						} else if (autenticacion.CC_Nivel__c == 'Nivel 2') {
							if ((autenticacion.CC_Estado__c == 'Rechazado' && (autenticacion.CC_Codigo_Error__c == '00008' || autenticacion.CC_Codigo_Error__c == '00005'))
							|| (autenticacion.CC_Estado__c == 'Cerrado' && autenticacion.CC_Resultado_Validacion__c == 'Identificación NOK')) {
								intentos++;
							}
						}
					}
				}
			}
			if (!bloqueado) {
				bloqueado = intentos >= Integer.valueOf(params.CC_Configuracion_1__c); //Supera los intentos permitidos
			}
		}
		return bloqueado;
	}

	private static Boolean llamadaEnCurso(Id idOportunidad) {
		return ![SELECT Id FROM Task WHERE RecordType.DeveloperName = 'CSBD_Task' AND Status = 'Open'
					AND WhatId = :idOportunidad AND CreatedDate = TODAY AND CC_Llamada_Id__c != NULL LIMIT 1].isEmpty();
	}

	private static Boolean tienePermisoAutenticacion() {
		return ![SELECT Id FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId()
					AND PermissionSet.Name = 'CC_Autenticacion' LIMIT 1].isEmpty();
	}

	@AuraEnabled(cacheable=true)
	public static Boolean canalAutenticable(String canal) {
		return String.isNotBlank(canal)
		&& ![SELECT Id FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CC_Autenticacion_Cliente'
				AND CC_Activa__c = TRUE AND CC_Valor__c = :canal LIMIT 1].isEmpty();
	}

	@AuraEnabled
	public static String autenticacionEmergencia(Id idOportunidad, String nivel, Boolean valido) {
		String resultado;
		Opportunity oportunidad = [SELECT AccountId, CSBD_Idioma_Solicitud__c, CSBD_Email_Solicitud__c, CSBD_Contact__c,
									CSBD_Contact__r.Phone, CSBD_CasoOrigen__r.CC_Canal_Procedencia__c, CSBD_CasoOrigen__c
									FROM Opportunity WHERE Id = :idOportunidad];

		String resultadoValidacion = '';
		if (valido && String.isNotBlank(oportunidad.CSBD_Email_Solicitud__c)) {
			if (nivel == 'Emergencia') {
				resultadoValidacion = 'Identificación emergencia';
			}

			if (oportunidad.CSBD_CasoOrigen__c != null) {
				//Envío de correo
				String proceso = oportunidad.CSBD_CasoOrigen__r.CC_Canal_Procedencia__c == 'ImaginBank' ? 'Notificacion OTP Imagin OK' : 'Notificacion OTP OK' ;
				String idioma = new Map<String, String>{'Castellano' => 'es', 'Catalán' => 'ca', 'Inglés' => 'en'}.get(oportunidad.CSBD_Email_Solicitud__c) ?? 'es';

				List<CC_ConfigNotifCliente__mdt> mdts = [SELECT CC_Remitente__c, CC_Plantilla__c FROM CC_ConfigNotifCliente__mdt
															WHERE CC_Proceso__c = :proceso AND CC_Canal__c = 'Email'
															AND CC_Idioma__c = :idioma AND CC_Activa__c = true LIMIT 1];
				if (!mdts.isEmpty()) {
					Id idPlantilla = [SELECT Id FROM EmailTemplate WHERE Name = :mdts[0].CC_Plantilla__c LIMIT 1]?.Id ?? null;
					if (idPlantilla != null) {
						Messaging.SingleEmailMessage correo = Messaging.renderStoredEmailTemplate(idPlantilla, UserInfo.getUserId(), oportunidad.CSBD_CasoOrigen__c);
						correo.setSaveAsActivity(true);
						correo.setWhatId(idOportunidad);
						correo.setTreatTargetObjectAsRecipient(false);
						correo.setToAddresses(new List<String>{oportunidad.CSBD_Email_Solicitud__c});
						correo.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress WHERE Address = :mdts[0].CC_Remitente__c LIMIT 1].Id);
						Messaging.SendEmailResult resultadoEnvio = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{correo}, false)[0];
						if (!resultadoEnvio.isSuccess()) {
							CBK_Log.error(resultadoEnvio.getErrors()[0].getMessage());
						}
					}
					resultado = 'Email';
				}
			}
		} else {
			if (String.isBlank(oportunidad.CSBD_Email_Solicitud__c)
			&& oportunidad.CSBD_Contact__r.Phone == null) {
				resultado = 'Correo no informado';
				resultadoValidacion = '';
			} else if (String.isBlank(oportunidad.CSBD_Email_Solicitud__c)
			&& oportunidad.CSBD_Contact__r.Phone != null) {
				if (nivel == 'Nivel 1') {
					resultado = 'OK';
					resultadoValidacion = 'Identificación manual';
				} else if (nivel == 'Emergencia') {
					resultado = 'OK';
					resultadoValidacion = 'Identificación emergencia';
				}
			} else {
				resultadoValidacion = 'Identificación NOK';
				String procesoKo = oportunidad.CSBD_CasoOrigen__r.CC_Canal_Procedencia__c == 'ImaginBank' ? 'Notificacion OTP Imagin KO' : 'Notificacion OTP KO' ;
				List<CC_ConfigNotifCliente__mdt> mdtsKO = [SELECT CC_Texto_Plantilla__c FROM CC_ConfigNotifCliente__mdt
															WHERE CC_Proceso__c = :procesoKo AND CC_Canal__c = 'Email'
															AND CC_Idioma__c = :oportunidad.CSBD_Idioma_Solicitud__c AND CC_Activa__c = true LIMIT 1];
				if (!mdtsKO.isEmpty()) {
					resultado = mdtsKO[0].CC_Texto_Plantilla__c;
				}
			}
		}

		if (String.isNotBlank(resultadoValidacion)) {
			CC_Comunicaciones__c autenticacion = new CC_Comunicaciones__c();
			autenticacion.RecordTypeId = Schema.SObjectType.CC_Comunicaciones__c.getRecordTypeInfosByDeveloperName().get('CSBD_Autenticacion').getRecordTypeId();
			autenticacion.CSBD_Opportunity__c = idOportunidad;
			autenticacion.CC_Resultado_Validacion__c = resultadoValidacion;
			autenticacion.CC_Cliente__c = oportunidad.AccountId;
			autenticacion.CC_Estado__c = valido ? 'Cerrado' : 'Rechazado';
			autenticacion.CC_Nivel__c = nivel;
			autenticacion.CC_Fecha_Validacion__c = Datetime.now();
			//autenticacion.CC_Fecha_Envio__c = Datetime.now();
			insert autenticacion;

			oportunidad.CSBD_UltimaAutenticacionOk__c = valido;
			oportunidad.CSBD_UltimaAutenticacionNivel__c = nivel;
			oportunidad.CSBD_IntentosAutenticacion__c = 0;
			oportunidad.CSBD_UltimaAutenticacionFecha__c = Datetime.now();
			update oportunidad;
		}
		return resultado;
	}

	@AuraEnabled
	public static Map<String, String> autenticacionClienteDigital(Id idOportunidad, Id idCliente, Id ownerId) {
		String resultado = 'OK';
		CC_Comunicaciones__c autenticacion;

		Task llamadaEnCurso = [SELECT CC_Llamada_Id__r.CC_Tipo__c FROM Task WHERE RecordType.DeveloperName = 'CSBD_Task'
								AND WhatId = :idOportunidad AND Status = 'Open' AND CC_Llamada_Id__r.CC_Tipo__c != NULL
								AND CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT 1] ?? null;

		if (clienteBloqueado(idOportunidad, idCliente)) {
			resultado = 'Cliente bloqueado';
		} else if (llamadaEnCurso == null && !tienePermisoAutenticacion()) {
			resultado = 'NOK';
		} else {
			//Tipo de llamada
			String llamadaEnCursoTipo = [SELECT CC_Llamada_Id__r.CC_Tipo__c FROM Task WHERE RecordType.DeveloperName = 'CSBD_Task'
											AND WhatId = :idOportunidad AND Status = 'Open' AND CC_Llamada_Id__r.CC_Tipo__c != NULL
											AND CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT 1]?.CC_Llamada_Id__r.CC_Tipo__c;

			autenticacion = new CC_Comunicaciones__c();
			autenticacion.RecordTypeId = Schema.SObjectType.CC_Comunicaciones__c.getRecordTypeInfosByDeveloperName().get('CSBD_Autenticacion').getRecordTypeId();
			autenticacion.CSBD_Opportunity__c = idOportunidad;
			autenticacion.CC_Cliente__c = idCliente;
			autenticacion.CC_Nivel__c = 'Cliente Digital';
			autenticacion.CC_Estado__c = 'Pdte. Envío';
			autenticacion.CC_Perfil_empleado__c = perfilUsuarioFormat();
			autenticacion.CC_Tipo_Llamada__c = llamadaEnCurso?.CC_Llamada_Id__r.CC_Tipo__c;
			insert autenticacion;

			Opportunity oportunidad = new Opportunity(Id = idOportunidad);
			oportunidad.CSBD_UltimaAutenticacionNivel__c = 'Cliente Digital';
			oportunidad.CSBD_EstadoAutenticacion__c = 'INPROGRESS';
			update oportunidad;
		}
		return new Map<String, String>{'resultado' => resultado, 'idAutenticacion' => autenticacion?.Id};
	}

	@AuraEnabled
	public static String autenticacionClienteDigitalEnviar(Id recordId, Id autenticacionId) {
		return CC_WS_Autenticacion.CC_WS_Envio_Autenticacion(autenticacionId, recordId);
	}

	@AuraEnabled
	public static String autenticacionClienteDigitalValidar(Id recordId, Id autenticacionId) {
		return CC_WS_Autenticacion.CC_WS_Validacion_Autenticacion(autenticacionId, recordId);
	}

	@AuraEnabled
	public static Boolean n2ValidarOtp(Id recordId, Id idAutenticacion, String codigo) {
		CC_Comunicaciones__c aut = CC_WS_Validacion_OTP.CC_WS_Validacion_OTP(new Set<Id>{idAutenticacion}, codigo)[0];
		return aut.CC_Resultado_Validacion__c == 'OTP validada correctamente';
	}

	@AuraEnabled
	public static void cancelarAutenticacion(Id idOportunidad, Id idAutenticacion) {
		CC_Comunicaciones__c autenticacion = new CC_Comunicaciones__c(Id = idAutenticacion);
		autenticacion.CC_Estado__c = 'Cancelada por agente';
		update autenticacion;

		Opportunity oportunidad = new Opportunity(Id = idOportunidad);
		oportunidad.CSBD_EstadoAutenticacion__c = 'UNAUTHORIZED';
		update oportunidad;
	}

	@AuraEnabled
	public static Map<String, Object> nivel2ValidacionInicial(Id recordId) {
		String resultado = 'OK';

		Opportunity oportunidad = [SELECT CSBD_CasoOrigen__r.CC_MCC_Motivo__r.CC_Motivo_OmitirSMSNivel2__c,
									AccountId, Account.RecordType.DeveloperName, Account.AV_Age__c, Account.PersonMobilePhone,
									Account.PersonBirthdate, Account.AV_NumPerso__c, Account.CC_NumPerso__c,
									CSBD_Contact__r.RecordType.DeveloperName, CSBD_Contact__r.CIBE_Telefono1__c,
									CSBD_Contact__r.AV_NumPerso__c, CSBD_Contact__r.CC_NumPerso__c,
									CSBD_CasoOrigen__r.CC_Representante__c,
									CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.PersonMobilePhone,
									CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.AV_Age__c,
									CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.PersonBirthdate,
									CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.CC_NumPerso__c,
									CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.AV_NumPerso__c
									FROM Opportunity WHERE Id = :recordId];

		CC_Comunicaciones__c autPendienteValidar = [SELECT Id FROM CC_Comunicaciones__c WHERE CC_Nivel__c = 'Nivel 2'
													AND RecordType.DeveloperName = 'CSBD_Autenticacion'
													AND CC_Cliente__c = :oportunidad.AccountId AND CSBD_Opportunity__c = :oportunidad.Id
													AND CC_Estado__c = 'Pdte. Validar' LIMIT 1] ?? null;
		if (autPendienteValidar != null) {
			resultado = 'PENDIENTE VALIDAR';

		} else if (clienteBloqueado(recordId, oportunidad.AccountId)) {
			resultado = 'CLIENTE BLOQUEADO';

		} else if ([SELECT Id FROM Task WHERE RecordType.DeveloperName = 'CSBD_Task' AND WhatId = :recordId
					AND CreatedDate = TODAY AND Status = 'Open' LIMIT 1].isEmpty() && !tienePermisoAutenticacion()) {
			resultado = 'SIN LLAMADAS';

		} else {
			if (oportunidad.CSBD_CasoOrigen__r.CC_Representante__c != null) {
				if (oportunidad.CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.AV_Age__c == null
				&& oportunidad.CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.PersonMobilePhone == null) {
					resultado = 'SIN DATOS';
				}
			//Cuenta juridica con apoderado
			} else if (oportunidad.Account.RecordType.DeveloperName == 'CC_Cliente' && oportunidad.CSBD_Contact__r.RecordType.DeveloperName == 'CIBE_Apoderado') {
				if (oportunidad.CSBD_Contact__r.CIBE_Telefono1__c == null) {
					resultado = 'SIN DATOS';
				}
			//Cuenta fisica
			} else if (oportunidad.Account.AV_Age__c == null && oportunidad.Account.PersonMobilePhone == null) {
				resultado = 'SIN DATOS';
			}
		}

		return new Map<String, Object>{'resultado' => resultado, 'omitirOtp' => nivel2OmitirOtp(oportunidad)};
	}

	@AuraEnabled
	public static CC_Comunicaciones__c nivel2EnviarSolicitudOtp(Id idAutenticacion) {
		return CC_WS_Envio_OTP.CC_WS_Envio_OTP(new Set<Id>{idAutenticacion})[0];
	}

	@AuraEnabled
	public static Map<String, Boolean> validacionRespuestasNivel2(Id recordId, String pregunta1, String pregunta2, String respuesta1, String respuesta2) {
		SavePoint sp = Database.setSavepoint();
		Opportunity opp = [SELECT CSBD_CasoOrigen__r.CC_MCC_Motivo__r.CC_Motivo_OmitirSMSNivel2__c,
							AccountId, Account.RecordType.DeveloperName, Account.AV_Age__c, Account.PersonMobilePhone,
							Account.PersonBirthdate, Account.AV_NumPerso__c, Account.CC_NumPerso__c,
							CSBD_Contact__r.RecordType.DeveloperName, CSBD_Contact__r.CIBE_Telefono1__c,
							CSBD_Contact__r.AV_NumPerso__c, CSBD_Contact__r.CC_NumPerso__c,
							CSBD_CasoOrigen__r.CC_Representante__c,
							CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.PersonMobilePhone,
							CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.PersonBirthdate,
							CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.AV_Age__c,
							CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.CC_NumPerso__c,
							CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.AV_NumPerso__c
							FROM Opportunity WHERE Id = :recordId];

		String numperso = getNumpersoClienteOportunidad(opp);
		Database.releaseSavepoint(sp);
		return new Map<String, Boolean>{
			'respuesta1' => validarRespuesta(opp, pregunta1, limpiarRespuesta(respuesta1), numperso),
			'respuesta2' => validarRespuesta(opp, pregunta2, limpiarRespuesta(respuesta2), numperso)
		};
	}

	private static String limpiarRespuesta(String respuesta) {
		return (respuesta ?? '').replace('+34 ', '').replace('+3400', '').replace('+34', '').replace(' ', '');
	}

	private static String getNumpersoClienteOportunidad(Opportunity opp) {
		if (opp.CSBD_CasoOrigen__r?.CC_Representante__c != null) {
			return opp.CSBD_CasoOrigen__r?.CC_Representante__r.CC_Representante__r?.AV_NumPerso__c != null ? opp.CSBD_CasoOrigen__r?.CC_Representante__r.CC_Representante__r.AV_NumPerso__c : opp.CSBD_CasoOrigen__r?.CC_Representante__r.CC_Representante__r.CC_NumPerso__c != null ? opp.CSBD_CasoOrigen__r?.CC_Representante__r.CC_Representante__r.CC_NumPerso__c : '';
		} else if (opp.Account.RecordType.DeveloperName == 'CC_Cliente' && opp.CSBD_Contact__r.RecordType.DeveloperName == 'CIBE_Apoderado') {
			return opp.CSBD_Contact__r.AV_NumPerso__c ?? (opp.CSBD_Contact__r.CC_NumPerso__c != null ? opp.CSBD_Contact__r.CC_NumPerso__c : '');
		} else {
			return opp.Account.AV_NumPerso__c ?? (opp.Account.CC_NumPerso__c != null ? opp.Account.CC_NumPerso__c : '');
		}
	}

	private static Boolean validarRespuesta(Opportunity opp, String pregunta, String respuesta, String numperso) {
		if (String.isEmpty(pregunta)) {
			return false;
		}
		pregunta = pregunta.toLowerCase();
		if (pregunta.contains('edad')) {
			return validarEdad(opp, respuesta);
		}else if (pregunta.contains('año')){
			return validarNacimiento(opp, respuesta);
		}else if (pregunta.contains('teléfono')) {
			return validarTelefono(opp, respuesta);
		} else if (pregunta.contains('cuenta')) {
			return validarCuenta(numperso, respuesta);
		} else if (pregunta.contains('tarjeta')) {
			return validarTarjeta(numperso, respuesta);
		}
		return false;
	}

	private static Boolean validarNacimiento(Opportunity oportunidad, String respuesta) {
		if (oportunidad.CSBD_CasoOrigen__r.CC_Representante__c != null) {
			String fechaNacimiento = String.valueOf(oportunidad.CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.PersonBirthdate);
			if (String.isBlank(fechaNacimiento)) {
				return false;
			} else {
				return fechaNacimiento.split('-')[0] == respuesta;
			}
		} else {
			String fechaNacimiento = String.valueOf(oportunidad.Account.PersonBirthdate);
			if (String.isBlank(fechaNacimiento)) {
				return false;
			} else {
				return fechaNacimiento.split('-')[0] == respuesta;
			}
		}
	}

	private static Boolean validarEdad(Opportunity oportunidad, String respuesta) {
		if (oportunidad.CSBD_CasoOrigen__r.CC_Representante__c != null) {
			return String.valueOf(oportunidad.CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.AV_Age__c) == respuesta;
		} else {
			return String.valueOf(oportunidad.Account.AV_Age__c) == respuesta;
		}
	}

	private static Boolean validarTelefono(Opportunity oportunidad, String respuesta) {
		if (oportunidad.CSBD_CasoOrigen__r.CC_Representante__c != null) {
			String tlf = oportunidad.CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.PersonMobilePhone;
			if (tlf != null && tlf.startsWith('+34 ')) {
				tlf = tlf.replace(' ', '').right(9);
			}
			return tlf == respuesta || oportunidad.CSBD_CasoOrigen__r.CC_Representante__r.CC_Representante__r.PersonMobilePhone == respuesta;
		} else if (oportunidad.Account.RecordType.DeveloperName == 'CC_Cliente' && oportunidad.CSBD_Contact__r.RecordType.DeveloperName == 'CIBE_Apoderado') {
			return oportunidad.CSBD_Contact__r.CIBE_Telefono1__c == respuesta;
		} else {
			String tlf = oportunidad.Account.PersonMobilePhone;
			if (tlf != null && tlf.startsWith('+34 ')) {
				tlf = tlf.replace(' ', '').right(9);
			}
			return tlf == respuesta || oportunidad.Account.PersonMobilePhone == respuesta;
		}
	}

	private static Boolean validarCuenta(String numPerso, String respuesta) {
		if (String.isEmpty(numPerso)) {
			return false;
		}
		List<String> cuentas = CC_WS_Autenticacion_CuentaCliente.validacionCuenta(numPerso);
		if(!cuentas.isEmpty()){
			for (String cuenta : cuentas) {
				if (cuenta.right(4) == respuesta) {
					return true;
				}
			}
		}
		return false;
	}

	private static Boolean validarTarjeta(String numPerso, String respuesta) {
		if (String.isEmpty(numPerso)) {
			return false;
		}
		List<String> tarjetas = CC_WS_Recuperar_Tarjetas.recuperarTarjetasPorCliente(numPerso);
		if (!tarjetas.isEmpty()){
			for (String tarjeta : tarjetas) {
				if (tarjeta.right(4) == respuesta) {
					return true;
				}
			}
		}
		return false;
	}

	private static Boolean nivel2OmitirOtp(Opportunity oportunidad) {
		Case casoOrigen = oportunidad.CSBD_CasoOrigen__r;
		Task llamada = [SELECT CC_Llamada_Id__r.CC_Tipo__c, CC_Llamada_Id__r.CC_DNIS__c FROM Task
						WHERE RecordType.DeveloperName = 'CSBD_Task' AND Status = 'Open' AND CC_Llamada_Id__c != NULL
						AND WhatId = :oportunidad.Id AND CreatedDate = TODAY ORDER BY CreatedDate DESC LIMIT 1] ?? null;

		if (llamada == null || llamada.CC_Llamada_Id__r.CC_Tipo__c != 'Saliente' || tienePermisoAutenticacion()) {
			//Llamada entrante
			return casoOrigen?.CC_MCC_Motivo__r?.CC_Motivo_OmitirSMSNivel2__c ?? false;

		} else {
			//Llamada saliente
			String telefonoLlamada = limpiarRespuesta(llamada.CC_Llamada_Id__r.CC_DNIS__c);

			if (casoOrigen?.CC_Representante__c != null) {
				//Llamada saliente a representante
				String telfRepresentante = casoOrigen.CC_Representante__r?.CC_Representante__r?.PersonMobilePhone ?? '';
				String telfClienteFormat = telfRepresentante.startsWith('+34 ') ? telfRepresentante.replace(' ', '').right(9) : telfRepresentante;
				return telefonoLlamada == telfRepresentante || telefonoLlamada == telfClienteFormat;

			} else if (oportunidad.Account.RecordType.DeveloperName == 'CC_Cliente'
			&& oportunidad.CSBD_Contact__r.RecordType.DeveloperName == 'CIBE_Apoderado') {
				//Llamada saliente a apoderado
				return telefonoLlamada == oportunidad.CSBD_Contact__r.CIBE_Telefono1__c;

			} else if (casoOrigen?.CC_MCC_Motivo__r?.CC_Motivo_OmitirSMSNivel2__c ?? false) {
				//Llamada saliente a otro y Motivo con "Omitir SMS Nivel 2" MARCADO
				return true;

			} else {
				//Llamada saliente a otro y Motivo con "Omitir SMS Nivel 2" DESMARCADO
				String telfCliente = (oportunidad.Account?.PersonMobilePhone ?? '');
				String telfClienteFormat = telfCliente.startsWith('+34 ') ? telfCliente.replace(' ', '').right(9) : telfCliente;
				return telefonoLlamada == telfCliente || telefonoLlamada == telfClienteFormat;
			}
		}
	}

	@AuraEnabled
	public static void codigoAutenticacionNoRecibido(Id idOportunidad, Id idAutenticacion, String nivel) {
		Boolean nivelClienteDigital = nivel == 'Cliente Digital';

		CC_Comunicaciones__c autenticacion = new CC_Comunicaciones__c(Id = idAutenticacion);
		autenticacion.CC_Estado__c = nivelClienteDigital ? 'Error' : 'OTP No recibida';
		autenticacion.CC_Resultado_Validacion__c = 'OTP no recibida';
		update autenticacion;

		Opportunity oportunidad = new Opportunity(Id = idOportunidad);
		oportunidad.CSBD_EstadoAutenticacion__c = nivelClienteDigital ? 'ERROR' : 'SIN ESTADO';
		update oportunidad;
	}

	private static String perfilUsuarioFormat() {
		//Perfil del empleado
		String perfilUsuario = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
		String perfilUsuarioFormateado;
		CC_Settings__c config = CC_Settings__c.getValues('CC_PerfilesAutentication');
		if (config != null) {
			Map<String, Object> camposConfig = config.getPopulatedFieldsAsMap();
			for (String nombreCampo : camposConfig.keySet()) {
				if (nombreCampo.contains('Configuracion')) {
					String valorCampo = String.valueOf(camposConfig.get(nombreCampo));
					if (String.isNotBlank(valorCampo) && perfilUsuario.contains(valorCampo)) {
						perfilUsuarioFormateado = valorCampo;
						break;
					}
				}
			}
		}
		return perfilUsuarioFormateado;
	}

	@AuraEnabled //Menú de desarrollo del LWC, no disponible para usuarios de negocio
	public static void eliminarAutenticacionesCliente(Id idAccount) {
		Database.delete([SELECT Id FROM CC_Comunicaciones__c WHERE CC_Cliente__c = :idAccount
							AND RecordType.DeveloperName = 'CSBD_Autenticacion'], false);
	}
}