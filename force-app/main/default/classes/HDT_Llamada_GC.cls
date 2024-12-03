public with sharing class HDT_Llamada_GC {

	public static Map<String, Object> registrarLlamadaEntrante(CC_Llamada_Input inputLlamada) {

		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c, CC_Encuesta__r.CC_Codigo__c
													FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputLlamada.servicio LIMIT 1];
		Case caso = null;
		Case casoVinculado;
		String agente = inputLlamada?.usuario;
		if (String.isBlank(agente)) {
			agente = [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()].EmployeeNumber;
		}

		CC_Llamada__c llamada = new CC_Llamada__c(
			KIN_Genesys_Cloud__c = true,
			KIN_Llamada_Origen__c = true,
			CC_Tipo__c = String.isBlank(inputLlamada.nombreCampana) ? 'Entrante' : 'Saliente',
			CC_Agente__c = agente,
			CC_ConnId__c = inputLlamada.connId,
			//CC_ConnId_Consulta__c = null,
			CC_ANI__c = inputLlamada.ani,
			CC_DNIS__c = inputLlamada.dnis,
			CC_Servicio_Genesys__c = servicioGenesys.Id,
			CC_Idioma__c = codigoIdioma(inputLlamada.idioma),
			CC_Asunto__c = inputLlamada.asunto.left(255),
			CC_Datos_Genesys__c = inputLlamada.datos,
			CC_ConnId_Cognitivo__c = inputLlamada.connIdCognitivo,
			CC_NumPerso__c = inputLlamada.numPerso,
			CC_Llamada_Padre__c = String.isEmpty(inputLlamada.salesforceParentId) ? null : inputLlamada.salesforceParentId,
			CC_No_Identificado__c = false,
			CC_Fecha_Inicio__c = System.now(),
			CC_Fecha_Fin__c = null,
			//CC_Cuenta__c = null,
			//CC_Contacto__c = null,
			CC_Id_Cognitivo__c = inputLlamada.cognitivoId,
			CC_IdentCliente__c = '0',  //Sin datos ALF
			//CC_Campana_Genesys__c = (inputLlamada.nombreCampana == null ? null: inputLlamada.nombreCampana)
			CC_Campana_Genesys__c = inputLlamada.nombreCampana,
			//CC_Status_Autorizacion__c = inputLlamada.statusAuto,
			CC_Perfil__c = inputLlamada.perfil,
			KIN_Genesys_Cloud_URL_Grabacion__c = inputLlamada.urlGrabacion
			);
			
			List<String> valoresPermitidosCanalEmpleado = new List<String>();
			for (Schema.PicklistEntry picklistEntry : CC_Llamada__c.CC_Canal_del_Empleado__c.getDescribe().getPicklistValues()) {
				valoresPermitidosCanalEmpleado.add(picklistEntry.getValue());
			}
			if (valoresPermitidosCanalEmpleado.contains(inputLlamada.canalEmpleado)) {
				llamada.CC_Canal_del_Empleado__c = inputLlamada.canalEmpleado;
			} else {
				llamada.CC_Canal_del_Empleado__c = null;
			}


		//Validamos que el valor este dentro de la picklist CC_Status_Autorizacion__c
		List<String> valoresPermitidos = new List<String>();
		for (Schema.PicklistEntry picklistEntry : CC_Llamada__c.CC_Status_Autorizacion__c.getDescribe().getPicklistValues()) {
			valoresPermitidos.add(picklistEntry.getValue());
		}

		if (valoresPermitidos.contains(inputLlamada.statusAuto)) {
			llamada.CC_Status_Autorizacion__c = inputLlamada.statusAuto;
		} else {
			llamada.CC_Status_Autorizacion__c = null;
		}

		if (servicioGenesys.CC_Codigo__c == 'INC_TEC_DESPLIEGUES') {
			llamada.CC_Canal_del_Empleado__c = 'Despliegues';
		} else if (servicioGenesys.CC_Codigo__c == 'INC_TEC_DESPLIEGUES2') {
			llamada.CC_Canal_del_Empleado__c = 'Despliegues2';
		} else if (servicioGenesys.CC_Codigo__c == 'CSI_HDT_DESBORDE') {
			//Cuando llega una llamada por desborde de CSI, se debe indicar siempre como canal de empleado CSI
			llamada.CC_Canal_del_Empleado__c = 'CSI';
		}

		llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'HDT_Empleado');
		identificarPorTelefono(llamada, inputLlamada.ani);
		if (String.isEmpty(inputLlamada.casoId) && !String.isEmpty(llamada.CC_Id_Cognitivo__c)) {
			//Buscamos el caso correspondiente al Id de cognitivo. Si no lo encuentra, lo crea con la información de la llamada y el chat obtenido de cognitivo
			caso = CC_WS_Recupera_LogConversacion.CC_WS_Recupera_Conversacion(llamada);
		}

		finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
		insert llamada;

		if (String.isEmpty(inputLlamada.casoId)) {
			if (caso != null) {
				actualizarCaso(caso.Id, UserInfo.getUserId());
				vincularCaso(caso, llamada, servicioGenesys);
			}
			//casoVinculado = crearVincularCaso(llamada);
		} else {
			//Cuando se pasa el caso, es que se ha hecho una transferencia ciega y entra como llamada
			crearActividad(llamada.Id, inputLlamada.casoId, 'Llamada transferida', servicioGenesys.Name);
			actualizarCaso(inputLlamada.casoId, UserInfo.getUserId(), servicioGenesys.CC_Canal_Procedencia__c);
		}
		return new Map<String, Object>{
			'className' => 'HDT_Llamada_GC',
			'llamada' => llamada,
			'caso' => casoVinculado,
			'abrirTabId' => llamada.Id,
			'encuestaId' => servicioGenesys.CC_Encuesta__r.CC_Codigo__c
		};
	}

	public static Map<String, Object> registrarLlamadaSaliente(CC_Llamada_Input inputLlamada) {
		finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
		CC_Llamada__c llamada;

		if (String.isBlank(inputLlamada.nombreCampana)) {
			CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c, CC_Encuesta__r.CC_Codigo__c
														FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = 'HDT_GenesysCloudOutboundDefault' LIMIT 1];
			if (String.isNotBlank(inputLlamada.casoId)) {
				Case caso = [SELECT CC_Canal_Resolucion__c, Subject, CC_Idioma__c, AccountId, ContactId, CC_No_Identificado__c, RecordType.DeveloperName
								FROM Case WHERE Id = :inputLlamada.casoId];
			}
			String agente = inputLlamada?.usuario;
			if (String.isBlank(agente)) {
				agente = [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()].EmployeeNumber;
			}
			llamada = new CC_Llamada__c(
				KIN_Genesys_Cloud__c = true,
				KIN_Llamada_Origen__c = true,
				RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'HDT_Empleado'),
				CC_Servicio_Genesys__c = servicioGenesys.Id,
				CC_Tipo__c = 'Saliente',
				CC_Agente__c = agente,
				CC_ConnId__c = inputLlamada.connId,
				//CC_ConnId_Consulta__c = null,
				CC_DNIS__c = inputLlamada.dnis,
				CC_Idioma__c = codigoIdioma(inputLlamada.idioma),
				CC_Asunto__c = String.isNotBlank(inputLlamada.asunto) ? inputLlamada.asunto.left(255) : null,
				CC_No_Identificado__c = false,
				CC_Fecha_Inicio__c = System.now(),
				// CC_Servicio_Llamada_Saliente__c  = caso.CC_Canal_Resolucion__c,
				CC_IdentCliente__c = '0', // Sin datos ALF);
				KIN_Genesys_Cloud_URL_Grabacion__c = inputLlamada.urlGrabacion
				// CC_Campana_Genesys__c =  inputLlamada.nombreCampana
			);
			insert llamada;

			//Case casoVinculado = crearVincularCaso(llamada);
			crearActividad(llamada.Id, inputLlamada.casoId, 'Llamada saliente', null);
		} else {
			llamada = (CC_Llamada__c)registrarLlamadaEntrante(inputLlamada).get('llamada');
		}
		return new Map<String, Object>{'className' => 'HDT_Llamada_GC', 'llamada' => llamada};
	}

	public static Map<String, Object> registrarConsulta(CC_Llamada_Input inputConsulta) {
		finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputConsulta.servicio LIMIT 1];
		CC_Llamada__c llamada = [SELECT CC_Idioma__c, CC_Contacto__c, CC_Cuenta__c, CC_Cuenta__r.CC_OficinaGestoraId__c, CC_No_Identificado__c, OwnerId, CC_IdentCliente__c, RecordTypeId
									FROM CC_Llamada__c WHERE Id = :inputConsulta.salesforceParentId];
		Case caso = [SELECT Subject, CC_Idioma__c, AccountId, ContactId FROM Case WHERE Id = :inputConsulta.casoId];
		String agente = inputConsulta?.usuario;
		if (String.isBlank(agente)) {
			agente = [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()].EmployeeNumber;
		}
		CC_Llamada__c consulta = new CC_Llamada__c(
			RecordTypeId = llamada.RecordTypeId,
			KIN_Genesys_Cloud__c = true,
			KIN_Consulta__c = true,
			CC_Tipo__c = 'Entrante',
			CC_Agente__c = agente,
			//CC_ConnId__c = null,
			CC_ConnId_Consulta__c = inputConsulta.connId,
			CC_ANI__c = inputConsulta.ani,
			CC_DNIS__c = inputConsulta.dnis,
			CC_Servicio_Genesys__c = servicioGenesys.Id,
			CC_Asunto__c = caso.Subject,
			CC_Case_Consulta__c = caso.Id,
			CC_Llamada_Padre__c = llamada.Id,
			CC_Idioma__c = codigoIdioma(inputConsulta.idioma),
			CC_Contacto__c = llamada.CC_Contacto__c,
			CC_Cuenta__c = llamada.CC_Cuenta__c,
			CC_No_Identificado__c = llamada.CC_No_Identificado__c,
			CC_Fecha_Inicio__c = System.now(),
			CC_IdentCliente__c = llamada.CC_IdentCliente__c,
			KIN_Genesys_Cloud_URL_Grabacion__c = inputConsulta.urlGrabacion
		);
		insert consulta;

		crearActividad(consulta.Id, caso.Id, tipoConsulta(servicioGenesys), servicioGenesys.Name);
		return new Map<String, Object>{'className' => 'HDT_Llamada_GC', 'llamada' => consulta, 'caso' => caso};
	}

	/*
	public static Map<String, Object> registrarConsultaExterna(CC_Llamada_Input inputConsulta) {
		finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c
													FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputConsulta.servicio LIMIT 1];
		String agente = inputConsulta?.usuario;
		if (String.isBlank(agente)) {
			agente = [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()].EmployeeNumber;
		}
		CC_Llamada__c consultaExterna = new CC_Llamada__c(
			KIN_Genesys_Cloud__c = true,
			KIN_Consulta__c = true,
			RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'HDT_Empleado'),
			CC_Tipo__c = 'Entrante',
			CC_Agente__c = agente,
			CC_ConnId__c = null,
			CC_ConnId_Consulta__c = inputConsulta.connId,
			CC_ANI__c = inputConsulta.ani,
			CC_DNIS__c = inputConsulta.dnis,
			CC_Servicio_Genesys__c = servicioGenesys.Id,
			CC_Idioma__c = codigoIdioma(inputConsulta.idioma),
			CC_Fecha_Inicio__c = System.now(),
			CC_IdentCliente__c = '0' // Sin datos ALF
		);
		insert consultaExterna;
		return new Map<String, Object>{'className' => 'HDT_Llamada_GC', 'llamada' => consultaExterna};
	}
	*/

	public static Id registrarConsultaNoAtendida(CC_Llamada_Input inputLlamada, CC_Llamada_Input inputConsulta) {
		if (String.isNotBlank(inputConsulta.servicio)) {
			CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c
														FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputConsulta.servicio LIMIT 1];
			String tipoActividad = tipoConsulta(servicioGenesys);
			return crearActividad(inputLlamada.llamadaId, inputConsulta.casoId, tipoActividad, servicioGenesys.Name, 'Consulta no atendida', System.now(), System.now());
		} else if (String.isNotBlank(inputConsulta.empleadoTelefono)) {
			return crearActividadEmpleado(inputConsulta.salesforceParentId, inputConsulta.casoId, inputConsulta.empleadoId, inputConsulta.empleadoTelefono, 'Consulta no atendida', 'Consulta externa a empleado no atendida');
		} else {
			IllegalArgumentException excepcion = new IllegalArgumentException();
			excepcion.setMessage('No se puede registrar una consulta no atendida sin servicio/empleado.');
			throw excepcion;
		}
	}

	/*
	public static void registrarEncuesta(CC_Llamada_Input inputLlamada) {
		String llamadaId = buscarLlamada(inputLlamada, false);
		if (!String.isBlank(llamadaId)) {
			CC_Llamada__c llamada = [SELECT CC_Servicio_Genesys__r.CC_Encuesta__r.Name, CC_Tipo__c FROM CC_Llamada__c WHERE Id = :llamadaId];
			llamada.CC_Encuesta__c = llamada.CC_Servicio_Genesys__r.CC_Encuesta__c;

			//Recuperamos el nombre de la encuesta para la tarea
			String nombreEncuesta = llamada.CC_Servicio_Genesys__r.CC_Encuesta__r.Name;

			if (llamada.CC_Encuesta__c == null && llamada.CC_Tipo__c == 'Saliente') {
				List<AggregateResult> casoIds = [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :llamadaId GROUP BY WhatId];
				if (!casoIds.isEmpty()) {
					Id casoId = String.valueOf(casoIds[0].get('WhatId'));
					if (casoId != null) {
						CC_Servicio_Genesys__c servicioGen = CC_Servicio_Genesys.obtenerServicioEncuestaDesdeCaso(casoId);
						if (servicioGen != null) {
							//Relacionamos la llamada con la encuesta
							llamada.CC_Encuesta__c = servicioGen.CC_Encuesta__c;
							//Recuperamos el nombre de la encuesta para la tarea
							nombreEncuesta = servicioGen.CC_Encuesta__r.Name;
						}
					}
				}
			}
			update llamada;

			crearActividadCasos(llamadaId, 'Encuesta', nombreEncuesta, 'Encuesta enviada');
		}
	}
	*/

	private static String buscarLlamada(CC_Llamada_Input jsonLlamada, Boolean esConsulta) {
		String resultado = jsonLlamada.llamadaId;
		if (String.isEmpty(resultado)) {
			String agente = jsonLlamada?.usuario;
			if (String.isBlank(agente)) {
				agente = [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()].EmployeeNumber;
			}
			Map<String, Object> queryBinds = new Map<String, Object>{
				'recordTypeLlamada' => 'HDT_Empleado',
				'interactionId' => jsonLlamada.connId,
				'agente' => agente,
				'esConsulta' => esConsulta
			};
			String queryString = 'SELECT Id FROM CC_Llamada__c WHERE RecordType.DeveloperName = :recordTypeLlamada';
			queryString += ' AND ' + (esConsulta ? 'CC_ConnId_Consulta__c' : 'CC_ConnId__c') + ' = :interactionId';
			queryString += ' AND CC_Agente__c = :agente AND KIN_Consulta__c = :esConsulta AND CC_Fecha_Fin__c = NULL LIMIT 2';

			List<CC_Llamada__c> llamadas = Database.queryWithBinds(queryString, queryBinds, AccessLevel.USER_MODE);
			if (llamadas.size() == 1) {
				resultado = llamadas[0].Id;
			}
		}
		return resultado;
	}

	public static Map<String, Object> finalizarLlamada(CC_Llamada_Input inputLlamada, String tipoCierre) {
		String llamadaId = buscarLlamada(inputLlamada, false);
		if (String.isNotBlank(llamadaId)) {
			finalizarLlamadaActividades(new CC_Llamada__c(Id = llamadaId), 'Llamada%', tipoCierre != '' ? tipoCierre : 'Llamada finalizada');
		}
		return new Map<String, Object>{'className' => 'HDT_Llamada_GC', 'llamada' => llamadaId};
	}

	public static Boolean finalizarConsulta(CC_Llamada_Input inputConsulta, String tipoCierre) {
		String consultaId = buscarLlamada(inputConsulta, true);
		if (String.isNotBlank(consultaId)) {
			finalizarLlamadaActividades(new CC_Llamada__c(Id = consultaId), 'Consulta%', tipoCierre);
			return true;
		} else {
			return false;
		}
	}

	public static void finalizarConsultaExterna(CC_Llamada_Input inputConsulta, String tipoCierre) {
		if (String.isNotBlank(inputConsulta.servicio)) {
			CC_Servicio_Genesys__c servicioGenesys = [SELECT CC_Tipo__c, CC_Activo_Salesforce__c FROM CC_Servicio_Genesys__c
														WHERE CC_Codigo__c = :inputConsulta.servicio LIMIT 1];
			if (!servicioGenesys.CC_Activo_Salesforce__c) {
				crearActividad(inputConsulta.salesforceParentId, inputConsulta.casoId, servicioGenesys.CC_Tipo__c.equals('Empleado') ? 'Consulta externa a empleado' : 'Consulta externa', inputConsulta.servicio, tipoCierre, System.now(), System.now());
			}
		} else if (String.isNotBlank(inputConsulta.empleadoTelefono)) {
			crearActividadEmpleado(inputConsulta.salesforceParentId, inputConsulta.casoId, inputConsulta.empleadoId, inputConsulta.empleadoTelefono, tipoCierre, 'Consulta externa a empleado');
		} else {
			IllegalArgumentException excepcion = new IllegalArgumentException();
			excepcion.setMessage('No se puede finalizar una consulta externa sin servicio/empleado.');
			throw excepcion;
		}
	}

	public static Boolean cancelarConsulta(CC_Llamada_Input inputConsulta) {
		String consultaId = buscarLlamada(inputConsulta, true);
		if (String.isNotBlank(consultaId)) {
			finalizarLlamadaActividades(new CC_Llamada__c(Id = consultaId), 'Consulta%', 'Consulta cancelada');
			return true;
		} else {
			return false;
		}
	}

	public static void completarConsulta(String connIdConsulta, Id idNuevoOwner) {
		CC_Llamada__c consulta = [SELECT CC_ConnId_Consulta__c, CC_Llamada_Padre__c, CC_Case_Consulta__c,
									OwnerId, CC_Servicio_Genesys__r.Name, CC_Servicio_Genesys__r.CC_Tipo__c,
									CC_Servicio_Genesys__r.CC_Activo_Salesforce__c, CC_Servicio_Genesys__r.CC_Canal_Procedencia__c
									FROM CC_Llamada__c WHERE RecordType.DeveloperName = 'HDT_Empleado'
									AND CC_ConnId_Consulta__c = :connIdConsulta AND CC_Fecha_Fin__c = NULL
									AND OwnerId = :idNuevoOwner AND KIN_Consulta__c = TRUE];
		consulta.CC_ConnId__c = consulta.CC_ConnId_Consulta__c;
		update consulta;
		finalizarActividadesLlamada(consulta, 'Consulta%', 'Consulta completada');

		CC_Llamada__c llamadaCliente = [SELECT CC_Servicio_Genesys__r.Name FROM CC_Llamada__c WHERE Id = :consulta.CC_Llamada_Padre__c];
		crearActividad(consulta.Id, consulta.CC_Case_Consulta__c, 'Llamada transferida', llamadaCliente != null ? llamadaCliente.CC_Servicio_Genesys__r.Name : 'externo', 'Llamada transferida', System.now(), System.now());

		if (consulta.CC_Servicio_Genesys__r.CC_Tipo__c.equals('Tercer nivel')) {
			traspasarTercerNivel(consulta.CC_Case_Consulta__c, idNuevoOwner, consulta.CC_Servicio_Genesys__r.Name, consulta.Id);
		} else if (consulta.CC_Case_Consulta__c != null) {
			if (consulta.CC_Servicio_Genesys__r.CC_Tipo__c.equals('Servicio')) {
				//El canal de resolución sólo se actualiza para transferencias entre servicios normales
				actualizarCaso(consulta.CC_Case_Consulta__c, idNuevoOwner, consulta.CC_Servicio_Genesys__r.CC_Canal_Procedencia__c);
			} else {
				actualizarCaso(consulta.CC_Case_Consulta__c, idNuevoOwner);
			}
		}

		//Cierre de la llamada con el cliente
		finalizarLlamadaActividades(llamadaCliente, 'Llamada%', 'Llamada finalizada');
	}

	/*
	public static Contact getEmpleadoGestor(Id llamadaId) {
		List<CC_Llamada__c> llamadas = [SELECT CC_Cuenta__r.AV_EAPGestor__c FROM CC_Llamada__c WHERE Id = :llamadaId AND CC_Cuenta__r.AV_EAPGestor__c != NULL];
		if (!llamadas.isEmpty()) {
			List<Contact> contactos = [SELECT Name, (SELECT CC_Telefono__c FROM Canales_Comunicacion__r
														WHERE RecordType.DeveloperName = 'CC_Telefono' ORDER BY CC_Clase_Com__c DESC)
										FROM Contact WHERE Id = :llamadas[0].CC_Cuenta__r.AV_EAPGestor__c];
			return contactos.isEmpty() ? null : contactos[0];
		}
		return null;
	}
	*/

	public static Case crearVincularCaso(CC_Llamada__c llamada) {
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Canal_de_Entrada__c, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c
													FROM CC_Servicio_Genesys__c WHERE Id = :llamada.CC_Servicio_Genesys__c];
		Case caso = crearCaso(llamada, servicioGenesys);
		vincularCaso(caso, llamada, servicioGenesys);
		return [SELECT CaseNumber, Status, Owner.Name, CreatedDate, Subject FROM Case WHERE Id = :caso.Id];
	}

	public static Case crearCaso(CC_Llamada__c llamada, CC_Servicio_Genesys__c servicioGenesys) {
		Case caso = new Case(
			RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado'),
			CC_Tipo_Cliente__c = 'Empleado',
			Subject = llamada.CC_Asunto__c,
			Origin = servicioGenesys.CC_Canal_de_Entrada__c == 'Telefono' ? 'Phone' : String.isBlank(servicioGenesys.CC_Canal_de_Entrada__c) ? 'Phone' : servicioGenesys.CC_Canal_de_Entrada__c,
			CC_Canal_Respuesta__c = 'Phone',
			CC_Telefono_Contacto__c = llamada.CC_ANI__c,
			CC_No_Identificado__c = llamada.CC_No_Identificado__c,
			CC_Canal_Procedencia__c = servicioGenesys.CC_Canal_Procedencia__c,
			CC_Idioma__c = llamada.CC_Idioma__c,
			AccountId = llamada.CC_Cuenta__c,
			ContactId = llamada.CC_Contacto__c,
			CC_IdentCliente__c = llamada.CC_IdentCliente__c,
			CC_Id_Cognitivo__c = llamada.CC_Id_Cognitivo__c,
			CC_Status_Autorizacion__c = llamada.CC_Status_Autorizacion__c
			);
			
		List<String> valoresPermitidos = new List<String>();
		for (Schema.PicklistEntry picklistEntry : Case.Canal_del_Empleado__c.getDescribe().getPicklistValues()) {
			valoresPermitidos.add(picklistEntry.getValue());
		}
		if (valoresPermitidos.contains(llamada.CC_Canal_del_Empleado__c)) {
			caso.Canal_del_Empleado__c = llamada.CC_Canal_del_Empleado__c;
		} else {
			caso.Canal_del_Empleado__c = null;
		}


		if (llamada.HDT_Desborde__c) {
			llamada.HDT_Desborde_Gestionado__c = true;
			caso.HDT_Desborde__c = true;
			update llamada;
		}

		insert caso;
		return caso;
	}

	private static void vincularCaso(Case caso, CC_Llamada__c llamada, CC_Servicio_Genesys__c servicioGenesys) {
		String tipoActividad;
		String tipoCierre;
		String asunto;

		if (llamada.CC_ConnId__c == null) { //Si es una consulta
			tipoActividad = tipoConsulta(servicioGenesys);
		} else {
			tipoActividad = llamada.CC_Tipo__c.equals('Saliente') ? 'Llamada saliente' : 'Llamada entrante';
		}
		asunto = tipoActividad;
		if (llamada.HDT_Desborde__c) {
			asunto += ' con desborde';
			tipoCierre = 'Llamada finalizada';
		}
		if (String.isNotBlank(servicioGenesys.Name)) {
			asunto += ' (' + servicioGenesys.Name + ')';
		}

		crearActividadFuture(llamada.Id, caso.Id, tipoActividad, asunto, tipoCierre, llamada.CC_Fecha_Inicio__c, llamada.CC_Fecha_Fin__c);
	}

	private static CC_Canal_Com__c buscarEmpleadoPorTelefono(String telefono) {
		telefono = telefono.replace('+34', '');
		List<CC_Canal_Com__c> listCanales = [SELECT CC_ContactoId__c, CC_ContactoId__r.AccountId FROM CC_Canal_Com__c WHERE CC_Telefono__c = :telefono
												AND CC_ContactoId__r.RecordType.DeveloperName = 'CC_Empleado' AND RecordType.DeveloperName = 'CC_Telefono' LIMIT 2];
		if (listCanales.size() == 1) {
			return listCanales[0];
		}
		return null;
	}

	@TestVisible
	private static void identificarPorTelefono(CC_Llamada__c llamada, String telefono) {
		if (!String.isEmpty(telefono)) {
			CC_Canal_Com__c canalComunicacion = buscarEmpleadoPorTelefono(telefono);
			if (canalComunicacion != null) {
				llamada.CC_Cuenta__c = canalComunicacion.CC_ContactoId__r.AccountId;
				llamada.CC_Contacto__c = canalComunicacion.CC_ContactoId__c;
			}
		}
	}

	private static String obtenerTipoCierre(String tipoCierre) {
		for (Schema.PicklistEntry tipo : CC_Llamada__c.CC_Tipo_Cierre__c.getDescribe().getPicklistValues()) {
			if (tipo.getValue().equals(tipoCierre)) {
				return tipo.getLabel();
			}
		}
		return tipoCierre;
	}

	private static void finalizarActividadesLlamada(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
		finalizarActividadesLlamada(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
	}

	private static void finalizarActividadesLlamada(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
		List<Id> llamadaIds = new List<Id>();
		for (CC_Llamada__c llamada : llamadas) {
			llamadaIds.add(llamada.Id);
		}

		if (llamadaIds.isEmpty()) {
			return;
		}

		List<Task> actividades = [SELECT Id FROM Task WHERE CC_Llamada_Id__c IN :llamadaIds AND Status = 'Open'
									AND Type LIKE :tipoActividad AND RecordType.DeveloperName = 'HDT_Task'];
		for (Task actividad : actividades) {
			actividad.CC_Fecha_Fin__c = System.now();
			actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
			actividad.Status = 'Completed';
		}
		update actividades;
	}

	//Metodo nuevo para la optimización de código: Nerea Sanchez-Bermejo, Octubre 2021
	private static void finalizarActividadesNew(List<CC_Llamada__c> llamadas) {
		if (!llamadas.isEmpty()) {
			List<Id> llamadaIds = new List<Id>();
			for (CC_Llamada__c llamada : llamadas) {
				llamadaIds.add(llamada.Id);
			}

			List<Task> actividadesActualizar = new List<Task>();
			for (Task actividad : [SELECT Type FROM Task WHERE CC_Llamada_Id__c IN :llamadaIds
									AND Status = 'Open' AND RecordType.DeveloperName = 'HDT_Task']) {
				if (actividad.Type.startsWith('Consulta')) {
					actividad.CC_Tipo_Cierre__c = obtenerTipoCierre('Consulta cancelada');
				} else if (actividad.Type.startsWith('Llamada')) {
					actividad.CC_Tipo_Cierre__c = obtenerTipoCierre('Llamada finalizada');
				}
				actividad.CC_Fecha_Fin__c = System.now();
				actividad.Status = 'Completed';
				actividadesActualizar.add(actividad);
			}
			update actividadesActualizar;
		}
	}

	private static void finalizarLlamadaActividades(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
		finalizarLlamadasActividades(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
	}

	private static void finalizarLlamadas(List<CC_Llamada__c> llamadas, String tipoCierre) {
		for (CC_Llamada__c llamada : llamadas) {
			llamada.CC_Fecha_Fin__c = System.now();
			llamada.CC_Tipo_Cierre__c = tipoCierre;
		}
		update llamadas;
	}

	private static void finalizarLlamadasActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
		if (!llamadas.isEmpty()) {
			finalizarLlamadas(llamadas, tipoCierre);
			finalizarActividadesLlamada(llamadas, tipoActividad, tipoCierre);
		}
	}

	private static void finalizarLlamadasActividadesAbiertas(Id userId) {
		List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c WHERE RecordType.DeveloperName = 'HDT_Empleado'
										AND CC_Fecha_Fin__c = NULL AND OwnerId = :userId];
		finalizarLlamadas(llamadas, 'Llamada finalizada');
		finalizarActividadesNew(llamadas);
	}

	private static Task crearObjetoActividad(Id llamadaId, Id whatId, String tipoActividad, String asunto, String tipoCierre, Datetime fechaInicio, Datetime fechaFin) {
		Task actividad = new Task(
			// Subject = tipoActividad + (asunto != null ? ' (' + asunto + ')' : ''),
			Subject = String.isNotBlank(asunto) ? asunto : tipoActividad,
			CC_Llamada_Id__c = llamadaId,
			ActivityDate = System.today(),
			CC_Fecha_Inicio__c = fechaInicio != null ? fechaInicio : System.now(),
			WhatId = whatId,
			Type = tipoActividad,
			RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task')
		);
		if (tipoCierre != null) {
			actividad.CC_Fecha_Fin__c = fechaFin;
			actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
			actividad.Status = 'Completed';
		}
		return actividad;
	}

	private static Id crearActividad(Id llamadaId, Id casoId, String tipoActividad, String asunto, String tipoCierre, Datetime fechaInicio, Datetime fechaFin) {
		Task actividad = crearObjetoActividad(llamadaId, casoId, tipoActividad, asunto, tipoCierre, fechaInicio, fechaFin);
		insert actividad;
		return actividad.Id;
	}

	private static Id crearActividad(Id llamadaId, Id casoId, String tipoActividad, String asunto) {
		return crearActividad(llamadaId, casoId, tipoActividad, asunto, null, null, null);
	}

	@future
	private static void crearActividadFuture(Id llamadaId, Id casoId, String tipoActividad, String asunto, String tipoCierre, Datetime fechaInicio, Datetime fechaFin) {
		crearActividad(llamadaId, casoId, tipoActividad, asunto, tipoCierre, fechaInicio, fechaFin);
	}

	@future
	private static void crearActividadCasos(Id llamadaId, String tipoActividad, String detalle, String tipoCierre) {
		List<Task> actividades = new List<Task>();
		for (AggregateResult resultado : [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :llamadaId GROUP BY WhatId]) {
			Id casoId = String.valueOf(resultado.get('WhatId'));
			Task actividad = crearObjetoActividad(llamadaId, casoId, tipoActividad, detalle, tipoCierre, System.now(), System.now());
			actividades.add(actividad);
		}
		insert actividades;
	}

	private static Id crearActividadEmpleado(Id llamadaId, Id casoId, String empleadoId, String empleadoTelefono, String tipoCierre, String tipoActividad) {
		Task actividad = new Task(
			ActivityDate = System.today(),
			CC_Fecha_Inicio__c = System.now(),
			CC_Llamada_Id__c = llamadaId,
			Type = tipoActividad,
			RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task')
		);

		List<Case> caso = [SELECT Id FROM Case WHERE Id = :casoId];
		if (caso.size() == 1) {
			actividad.WhatId = casoId;
		}

		Contact empleado = null;
		if (String.isNotBlank(empleadoId)) {
			empleado = [SELECT Name FROM Contact WHERE Id = :empleadoId];
		} else { // Si no tenemos el ID, el widget nos proporciona empleadoTelefono
			List<CC_Canal_Com__c> listaCanales = [SELECT CC_ContactoId__r.Id, CC_ContactoId__r.Name FROM CC_Canal_Com__c WHERE CC_Telefono__c = :empleadoTelefono];
			if (listaCanales.size() == 1) {
				empleado = listaCanales[0].CC_ContactoId__r;
			}
		}

		if (empleado != null) {
			actividad.Subject = tipoActividad + ' (' + empleado.Name + ')';
			actividad.CC_Empleado_Gestor__c = empleado.Id;
		} else {
			actividad.Subject = tipoActividad + ' (' + empleadoTelefono + ')';
		}

		if (tipoCierre != null) {
			actividad.CC_Fecha_Fin__c = System.now();
			actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
			actividad.Status = 'Completed';
		}
		insert actividad;
		return actividad.Id;
	}

	@TestVisible
	private static String codigoIdioma(String idioma) {
		return 'Inglés'.equals(idioma) ? 'en' : ('Catalán'.equals(idioma) ? 'ca' : 'es');
	}

	private static Case actualizarCaso(Id casoId, Id propietarioId) {
		Case caso = new Case(Id = casoId);
		caso.OwnerId = propietarioId;
		update caso;
		return caso;
	}

	private static Case actualizarCaso(Id casoId, Id propietarioId, String canalResolucion) {
		Case caso = new Case(Id = casoId);
		caso.CC_Canal_Resolucion__c = canalResolucion;
		caso.OwnerId = propietarioId;
		update caso;
		return caso;
	}

	private static void traspasarTercerNivel(Id casoId, Id propietarioId, String grupo3n, Id llamadaId) {
		Case caso = new Case(Id = casoId);
		caso.Status = 'Activo';
		caso.CC_En_Tercer_Nivel__c = true;
		caso.CC_Grupo_3N__c = grupo3n;
		caso.OwnerId = propietarioId;
		update caso;
		HDT_EmailSendController.createActivityTraslados(caso.Id, null, 'Traslado a ' + grupo3n + ' de Tercer Nivel', 'Traslado Tercer Nivel', grupo3n, llamadaId);
	}


	private static String tipoConsulta(CC_Servicio_Genesys__c servicioGenesys) {
		String tipoActividad = 'Consulta';
		if (!servicioGenesys.CC_Activo_Salesforce__c) {
			tipoActividad = 'Consulta externa';
		}

		if (servicioGenesys.CC_Tipo__c.equals('Tercer nivel')) {
			tipoActividad = tipoActividad + ' a tercer nivel';
		} else if (servicioGenesys.CC_Tipo__c.equals('Segundo nivel')) {
			tipoActividad = tipoActividad + ' a segundo nivel';
		}
		return tipoActividad;
	}
}