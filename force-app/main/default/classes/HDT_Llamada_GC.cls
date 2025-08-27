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
			CC_Id_Cognitivo__c = inputLlamada.cognitivoId,
			CC_IdentCliente__c = '0',  //Sin datos ALF
			CC_Campana_Genesys__c = inputLlamada.nombreCampana,
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
		identificarPorTelefono(llamada, inputLlamada.ani,  servicioGenesys.CC_Canal_Procedencia__c);
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
		HDT_Parametros__c emailRespuesta = HDT_Parametros__c.getInstance('HDT_Llamadas_Salientes_No_Atendidas');
		String nombreServicio = emailRespuesta.HDT_Configuracion_1__c;
		
		finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
		CC_Llamada__c llamada;

		if (String.isBlank(inputLlamada.nombreCampana)) {
			CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c, CC_Encuesta__r.CC_Codigo__c
														FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :nombreServicio LIMIT 1];
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

	/****************************************************************************************** */
	public static Map<String, Object> registrarLlamadaSalienteNoAtendida(CC_Llamada_Input inputLlamada) {
		HDT_Parametros__c emailRespuesta = HDT_Parametros__c.getInstance('HDT_Llamadas_Salientes_No_Atendidas');
		String nombreServicio = emailRespuesta.HDT_Configuracion_1__c;
		//if (emailRespuesta.HDT_Activo__c) {
			finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
			CC_Servicio_Genesys__c servicioGenesys = [SELECT Id FROM CC_Servicio_Genesys__c
														WHERE CC_Codigo__c = :nombreServicio LIMIT 1];
	
			Case caso = [SELECT CC_Canal_Resolucion__c, Subject, CC_Idioma__c, AccountId, ContactId, CC_No_Identificado__c, RecordType.DeveloperName
									FROM Case WHERE Id = :inputLlamada.casoId];

			CC_Llamada__c llamada = new CC_Llamada__c(
				RecordTypeId = Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId(),
				KIN_Genesys_Cloud__c = true,
				KIN_Llamada_Origen__c = true,
				CC_Servicio_Genesys__c = servicioGenesys.Id,
				CC_Tipo__c = 'Saliente',
				CC_Agente__c = inputLlamada.usuario,
				CC_Extension__c = inputLlamada.extension,
				CC_ConnId__c = inputLlamada.connId,
				CC_ConnId_Consulta__c = null,
				CC_DNIS__c = inputLlamada.dnis,
				CC_Idioma__c = codigoIdioma(inputLlamada.idioma),
				CC_Asunto__c = caso.Subject,
				CC_Cuenta__c = caso.AccountId,
				CC_Contacto__c = caso.ContactId,
				CC_Fecha_Inicio__c = System.now(),
				CC_Tipo_Cierre__c = 'Llamada no atendida',
				KIN_Genesys_Cloud_URL_Grabacion__c = inputLlamada.urlGrabacion
			);
			insert llamada;

			crearActividadSaliente(llamada, inputLlamada.casoId, 'Llamada saliente', null);
			
			Integer numeroIntentos = [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id AND Type = 'Llamada saliente'];
			caso.CC_OTP_Intentos__c = numeroIntentos;
			update caso;

			return new Map<String, Object>{'className' => 'HDT_Llamada_GC', 'llamada' => llamada};
		
	}


	public static Map<String, Object> registrarConsulta(CC_Llamada_Input inputConsulta) {
		finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c, CC_Canal_Procedencia__c FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputConsulta.servicio LIMIT 1];
		CC_Llamada__c llamada = [SELECT CC_Idioma__c, CC_Contacto__c, CC_Cuenta__c, CC_Cuenta__r.CC_OficinaGestoraId__c, CC_No_Identificado__c, OwnerId, CC_IdentCliente__c, RecordTypeId
									FROM CC_Llamada__c WHERE Id = :inputConsulta.salesforceParentId];
		Case caso = [SELECT Subject, CC_Idioma__c, AccountId, ContactId, CC_MCC_Motivo__c, CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_Canal_Operativo__c, CC_Canal_Procedencia__c, CC_Tipo_Contacto__c, CC_Causa__c FROM Case WHERE Id = :inputConsulta.casoId];

		if((caso == null && (servicioGenesys.CC_Canal_Procedencia__c == 'CCO' && servicioGenesys.CC_Tipo_Cliente__c == 'Empleado' && servicioGenesys.CC_Tipo__c == 'Tranferencias CCO HDT'))
		|| caso.CC_MCC_Motivo__c == null || caso.CC_MCC_Tematica__c == null || caso.CC_MCC_ProdServ__c == null 
		|| caso.CC_Canal_Operativo__c == null || caso.CC_Canal_Procedencia__c == null
		|| caso.CC_Idioma__c == null || caso.CC_Tipo_Contacto__c == null || caso.CC_Causa__c == null
		|| llamada.CC_Servicio_Genesys__r.CC_Canal_de_Entrada__c == null) {
			throw new AuraHandledException('Debes informar los campos Canal de entrada, Canal de procedencia, Idioma, Tipo de contacto, Canal operativo y MCC para poder transferir el caso.');
		} else if (caso.AccountId == null || caso.ContactId == null 
		|| (caso == null  && (servicioGenesys.CC_Canal_Procedencia__c == 'CCO' && servicioGenesys.CC_Tipo_Cliente__c == 'Empleado' && servicioGenesys.CC_Tipo__c == 'Tranferencias CCO HDT'))){
			throw new AuraHandledException('Debes informar los campos Account, Contacto y Caso para poder transferir el caso.');
		}

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
		
		Map<String, Object> response = new Map<String, Object>();

		// Validar si inputLlamada es nulo o si llamadaId es nulo o vacío
		if (inputLlamada == null || String.isBlank(inputLlamada.llamadaId)) {
			response.put('className', 'HDT_Llamada_GC');
			response.put('error', 'No se encontró un ID de llamada válido');
			return response; // Retorna sin procesar la llamada
		}
		
		Id recordId = String.valueOf(inputLlamada.llamadaId);
		if (String.valueOf(recordId?.getSobjectType()) == 'Case') {
			List<Task> tarea = [SELECT CC_Llamada_Id__c FROM Task
									WHERE WhatId = :inputLlamada.llamadaId AND CC_Llamada_Id__c != null AND RecordType.DeveloperName = 'HDT_Task' AND Status = 'Open'
									ORDER BY CreatedDate DESC LIMIT 1];
			if (!tarea.isEmpty()) {
				inputLlamada.llamadaId = tarea[0].CC_Llamada_Id__c;
			}
		}
		String llamadaId = buscarLlamada(inputLlamada, false);
		if (String.isNotBlank(llamadaId)) {
			tipoCierre = tipoCierre != '' ? tipoCierre : 'Llamada finalizada';
			if (tipoCierre == 'Llamada finalizada') {
				Boolean noAtendida = [SELECT CC_Tipo_Cierre__c FROM CC_Llamada__c WHERE Id = :llamadaId]?.CC_Tipo_Cierre__c == 'Llamada no atendida';
				
				if (noAtendida) {
					tipoCierre = 'Llamada no atendida';
				}
			}
		}
		finalizarLlamadaActividades(new CC_Llamada__c(Id = llamadaId), 'Llamada%', tipoCierre);
		return new Map<String, Object>{'className' => 'HDT_Llamada_GC', 'llamada' => llamadaId};

	}

	public static void finalizarActividades(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
		finalizarActividades(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
	}

	public static void finalizarActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
		Set<Id> llamadaIds = new Set<Id>();
		//Map<Id, Integer> oppDuracionMapa = new Map<Id, Integer>();

		if (!llamadas.isEmpty()) {
			List<Task> actividades = [SELECT CC_Fecha_Inicio__c, WhatId FROM Task WHERE CC_Llamada_Id__c IN :CC_MetodosUtiles.listaCampo(llamadas, 'Id')
										AND Status = 'Open' AND Type LIKE :tipoActividad AND RecordType.DeveloperName = 'HDT_Task'];
			if (!actividades.isEmpty()) {
				for (Task actividad : actividades) {
					actividad.CC_Fecha_Fin__c = System.now();
					actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
					actividad.Status = 'Completed';
				}
				update actividades;
			}
		}

	}



	public static Map<String, Object> iniciarLlamadaSalienteClickToDial(CC_Llamada_Input inputLlamada) {
		
		List<CC_Llamada__c> llamadasAnteriores = [SELECT Id FROM CC_Llamada__c WHERE OwnerId = :UserInfo.getUserId()
													AND CC_Fecha_Fin__c = null AND Id != :inputLlamada.llamadaId];
		if (!llamadasAnteriores.isEmpty()) {
			for (CC_Llamada__c llamadaAnterior : llamadasAnteriores) {
				llamadaAnterior.CC_Fecha_Fin__c = System.now();
				llamadaAnterior.CC_Tipo_Cierre__c = 'Llamada finalizada';
			}
			update llamadasAnteriores;

			finalizarActividades(llamadasAnteriores, 'Llamada%', 'Llamada finalizada');
			finalizarActividades(llamadasAnteriores, 'Consulta%', 'Consulta cancelada');
		}

		Datetime ahora = System.now();
		CC_Llamada__c llamada = new CC_Llamada__c(Id = inputLlamada.llamadaId);
		llamada.CC_ConnId__c = inputLlamada.connId;
		llamada.KIN_Genesys_Cloud_URL_Grabacion__c = inputLlamada.urlGrabacion;
		llamada.CC_Fecha_Inicio__c = ahora;
		llamada.CC_Tipo_Cierre__c = null;
		update llamada;
		Id idTarea = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id LIMIT 1]?.Id;
		if (idTarea != null) {
			Task tarea = new Task(Id = idTarea);
			tarea.CC_Fecha_Inicio__c = ahora;
			tarea.CC_Tipo_Cierre__c = null;
			update tarea;
		}

		Case caso = [SELECT CC_Canal_Resolucion__c, Subject, CC_Idioma__c, AccountId, ContactId, CC_No_Identificado__c, RecordType.DeveloperName
								FROM Case WHERE Id = :inputLlamada.casoId];

		return new Map<String, Object>{'className' => 'HDT_Llamada_GC', 'llamada' => llamada, 'caso' => caso};

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
		
		CC_Settings__c settings = CC_Settings__c.getValues('CC_Colas_HDT_CCO_Activas');

		CC_Llamada__c consulta = [SELECT CC_ConnId_Consulta__c, CC_Llamada_Padre__c, CC_Case_Consulta__c,
									OwnerId, CC_Servicio_Genesys__r.Name, CC_Servicio_Genesys__r.CC_Tipo__c, CC_Cuenta__r.Name, CC_Cuenta__r.Phone,
									CC_Servicio_Genesys__r.CC_Tipo_Cliente__c, CC_Case_Consulta__r.ContactId, CC_Cuenta__c, CC_Contacto__c, CC_ANI__c, 
									CC_Servicio_Genesys__r.CC_Activo_Salesforce__c, CC_Servicio_Genesys__r.CC_Canal_Procedencia__c, RecordTypeId,
									Id, CC_Asunto__c, CC_Idioma__c, CC_Representante__c, CC_IdentCliente__c, CC_Canal_del_Empleado__c, CC_Id_Cognitivo__c,
									CC_Cuenta__r.PersonMobilePhone, CC_Servicio_Genesys__r.CC_Canal_de_Entrada__c, CC_Servicio_Genesys__r.CC_Grupo__c,
									CC_Servicio_Genesys__r.CBK_Negocio__c
									FROM CC_Llamada__c WHERE (RecordType.DeveloperName = 'HDT_Empleado' OR RecordType.DeveloperName = 'CC_Empleado')
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
			} else if(settings.CC_Activa__c && (consulta.CC_Servicio_Genesys__r.CC_Canal_Procedencia__c == 'CCO' && consulta.CC_Servicio_Genesys__r.CC_Tipo_Cliente__c == 'Empleado' && consulta.CC_Servicio_Genesys__r.CC_Tipo__c == 'Tranferencias CCO HDT')) {
				finalizarLlamadaActividades(llamadaCliente, 'Llamada%', 'Llamada finalizada');
				CC_Transferir_HDT_CCO transfer = new CC_Transferir_HDT_CCO(consulta.CC_Case_Consulta__c, idNuevoOwner, consulta, 'HDT');
                Case caso = transfer.transferEmpleado();
			}
			else {
				actualizarCaso(consulta.CC_Case_Consulta__c, idNuevoOwner);
			}
		}

		//Cierre de la llamada con el cliente
		finalizarLlamadaActividades(llamadaCliente, 'Llamada%', 'Llamada finalizada');
	}

	
	/* Nuevo para IOP Abril 25*/
	public static Case crearVincularCasoMasiva(CC_Llamada__c llamada,String agrupadorId ) {
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Canal_de_Entrada__c, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c
													FROM CC_Servicio_Genesys__c WHERE Id = :llamada.CC_Servicio_Genesys__c];
		Case caso = crearCasoMasiva(llamada, servicioGenesys,agrupadorId);
		vincularCaso(caso, llamada, servicioGenesys);

		return [SELECT CaseNumber, Status, Owner.Name, CreatedDate, Subject FROM Case WHERE Id = :caso.Id];
	}

	public static Case crearCasoMasiva(CC_Llamada__c llamada, CC_Servicio_Genesys__c servicioGenesys, String agrupadorId) {
		
		// Buscamos los valores por defecto
        List<CC_Lista_Valores__c> valorValidacion = [SELECT Name, CC_Valor__c,CC_Valor2__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'HDT_Mensajes_Parametrizables_Empleados' AND Name = 'Asociar casos a masivas desde llamadas' LIMIT 1];
		List<CC_Lista_Valores__c> valorActivos = [SELECT Name, CC_Valor__c,CC_Valor2__c,CSBD_Valor4__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'HDT_Mensajes_Parametrizables_Empleados' AND Name = 'Tipo de Activos asociados a Cuenta desde llamada' LIMIT 1];
    
		String estadoActivo = '';
		Id miasset;
		List<String> familias = new List<String>();

		if (!valorActivos.isEmpty()) {
			familias.add(valorActivos[0].CC_Valor__c);
			familias.add(valorActivos[0].CC_Valor2__c);
			estadoActivo = valorActivos[0].CSBD_Valor4__c;
		}

		// Buscamos los activos que tiene asociado el contacto
        List<Asset> valorAssetContacto = [SELECT Id,Name,CC_Familia_Activo__c,HDT_Estado_CI__c 
								  FROM Asset 
								  WHERE HDT_Estado_CI__c = :estadoActivo AND HDT_Asignado_a__c  = :llamada.CC_Contacto__r.CC_Matricula__c AND CC_Familia_Activo__c IN :familias AND CC_Inactivo__c = false
								  LIMIT 1];

		if (!valorAssetContacto.isEmpty())  {		
				miasset = valorAssetContacto[0].Id;
		}

		String 	miAsunto = '';
		String detallesConsulta = '';
		String descripcionMasiva = '';
		Id tematica;
		Id producto;
		Id motivo;
		Id causa;
		

		if (!valorValidacion.isEmpty())  {
			for (CC_Lista_Valores__c valor : valorValidacion) {
				miAsunto = valor.CC_Valor__c; 
    			detallesConsulta = valor.CC_Valor2__c;
			}
		}
		// Buscamos los datos del agrupador de la masiva
        List<CC_Agrupador__c> valorAgrupador = [SELECT Id,CC_Titulo__c,CC_Descripcion__c,CC_Tematica_Id__c,CC_Producto_Servicio__c,CC_Causa__c,CC_Motivo__c
		FROM CC_Agrupador__c WHERE Id = :agrupadorId LIMIT 1];
		
		if (!valorAgrupador.isEmpty())  {
				miAsunto = miAsunto + ' ' + valorAgrupador[0].CC_Titulo__c;
				descripcionMasiva = valorAgrupador[0].CC_Descripcion__c;
				tematica = valorAgrupador[0].CC_Tematica_Id__c;
				producto = valorAgrupador[0].CC_Producto_Servicio__c;
				motivo = valorAgrupador[0].CC_Motivo__c;
				causa = valorAgrupador[0].CC_Causa__c;
		}

		Case caso = new Case(
			RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado'),
			CC_Tipo_Cliente__c = 'Empleado',
			Subject = miAsunto,
			CC_MCC_Tematica__c = tematica,
			CC_MCC_ProdServ__c = producto,
			CC_MCC_Motivo__c = motivo,
			CC_MCC_Causa__c = causa,
			AssetId = miasset,
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
			CC_Status_Autorizacion__c = llamada.CC_Status_Autorizacion__c,
			HDT_Desborde__c = true		// Usamos este campo para recoger que el caso viene desde el botón de Masiva para omitir el envio de notificación.
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

		insert caso;

		
		
		Case micasonuevo = [SELECT CC_Detalles_Consulta__c,CaseNumber, Status, Owner.Name, CreatedDate, Subject FROM Case WHERE Id = :caso.Id];

		String detallesAdquiridos = '\n' + '\n' + detallesConsulta + '\n';
		detallesAdquiridos =  micasonuevo.CC_Detalles_Consulta__c + '\n' + detallesAdquiridos + '\n';

		//detallesAdquiridos = detallesAdquiridos + descripcionMasiva.replaceAll('<br>', '\n');
		detallesAdquiridos = detallesAdquiridos + descripcionMasiva.replaceAll('<br>', '\n').replaceAll('</?p>', '\n');

		
		micasonuevo.CC_Detalles_Consulta__c = detallesAdquiridos;
		update micasonuevo;

		return caso;
	}


	/*Fin -  Nuevo para IOP Abril 25*/
	public static void crearVincularCasoDesborde(CC_Llamada__c llamada) {
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Canal_de_Entrada__c, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c
													FROM CC_Servicio_Genesys__c WHERE Id = :llamada.CC_Servicio_Genesys__c];
		Case caso = crearCaso(llamada, servicioGenesys);
		vincularCaso(caso, llamada, servicioGenesys);
		//return [SELECT CaseNumber, Status, Owner.Name, CreatedDate, Subject,RecordType.DeveloperName FROM Case WHERE Id = :caso.Id];
	}

	public static Case crearVincularCaso(CC_Llamada__c llamada) {
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Canal_de_Entrada__c, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c
													FROM CC_Servicio_Genesys__c WHERE Id = :llamada.CC_Servicio_Genesys__c];
		Case caso = crearCaso(llamada, servicioGenesys);
		vincularCaso(caso, llamada, servicioGenesys);
		return [SELECT CaseNumber, Status, Owner.Name, CreatedDate, Subject,RecordType.DeveloperName FROM Case WHERE Id = :caso.Id];
	}

	public static Case crearCaso(CC_Llamada__c llamada, CC_Servicio_Genesys__c servicioGenesys) {
		//Buscamos si tiene asset asociados la cuenta
		List<CC_Lista_Valores__c> valorActivos = [SELECT Name, CC_Valor__c,CC_Valor2__c,CSBD_Valor4__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'HDT_Mensajes_Parametrizables_Empleados' AND Name = 'Tipo de Activos asociados a Cuenta desde llamada' LIMIT 1];
		List<CC_Lista_Valores__c> valorActivos2 = [SELECT Name, CC_Valor__c,CC_Valor2__c,CSBD_Valor4__c FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'HDT_Mensajes_Parametrizables_Empleados' AND Name = 'Mensaje para las llamadas de desborde al crear el caso' LIMIT 1];
    
		String mensajeDesborde = '';

		if (!valorActivos2.isEmpty()) {
			mensajeDesborde = valorActivos2[0].CC_Valor__c;
		}

		String estadoActivo = '';
		Id miasset;
		List<String> familias = new List<String>();

		if (!valorActivos.isEmpty()) {
			familias.add(valorActivos[0].CC_Valor__c);
			familias.add(valorActivos[0].CC_Valor2__c);
			estadoActivo = valorActivos[0].CSBD_Valor4__c;
		}

		// Buscamos los activos que tiene asociado el contacto
        List<Asset> valorAssetContacto = [SELECT Id,Name,CC_Familia_Activo__c,HDT_Estado_CI__c 
								  FROM Asset 
								  WHERE HDT_Estado_CI__c = :estadoActivo AND HDT_Asignado_a__c  = :llamada.CC_Contacto__r.CC_Matricula__c AND CC_Familia_Activo__c IN :familias AND CC_Inactivo__c = false
								  LIMIT 1];

		if (!valorAssetContacto.isEmpty())  {		
				miasset = valorAssetContacto[0].Id;
		}

		Case caso = new Case(
			RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado'),
			CC_Tipo_Cliente__c = 'Empleado',
			AssetId = miasset,
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


		//Moficaciones para la US : US1133185 : Creación de caso en la API de agente de desborde 
		// Obtener el Id de la cola por nombre
		Group cola = [
			SELECT Id 
			FROM Group 
			WHERE Name = 'Agente de desborde HDT' AND Type = 'Queue' 
			LIMIT 1
		];

		if (llamada.HDT_Desborde__c) {
			caso.CC_Tipo_Contacto__c = 'Incidencia';
			caso.Origin = 'Agente de desborde';
			caso.Subject = mensajeDesborde;
			caso.OwnerId = cola.Id; // Asignar la cola como propietario
			//llamada.HDT_Desborde_Gestionado__c = true;
			caso.HDT_Desborde__c = true;
			//update llamada;
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

	private static CC_Canal_Com__c buscarEmpleadoPorTelefono(String canalProcedencia, String telefono) {
		List<String> lstEDGMatriculas = new List<String>();
		String matriculaPorCanalProcedencia = '';
		for(CC_Lista_Valores__c listaValor : [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c WHERE RecordType.DeveloperName = 'CC_Valor' AND CC_Lista__r.Name = 'HDT - Matricula por Canal de Procedencia']){
			if(canalProcedencia != null && canalProcedencia != '' && listaValor.Name == canalProcedencia) {
				matriculaPorCanalProcedencia = listaValor.CC_Valor__c;
			}
			if(listaValor.Name.contains('EDG')) {
				lstEDGMatriculas.add(listaValor.CC_Valor__c);	
			}
		}
		telefono = telefono.replace('+34', '');
		List<CC_Canal_Com__c> listCanales = [SELECT CC_ContactoId__c, CC_ContactoId__r.AccountId, CC_ContactoId__r.CC_Matricula__c FROM CC_Canal_Com__c 
												WHERE CC_Telefono__c = :telefono AND CC_ContactoId__r.RecordType.DeveloperName = 'CC_Empleado' 
												AND RecordType.DeveloperName = 'CC_Telefono' AND CC_ContactoId__r.CC_Inactivo__c = false];
		CC_Canal_Com__c empleadoEDG = null;
		CC_Canal_Com__c empleadoMatriculaCorrecta = null;
		for(CC_Canal_Com__c canalComunicacion : listCanales){
			String matricula = canalComunicacion.CC_ContactoId__r.CC_Matricula__c;
			if(matricula != null && matricula != '' && matricula.length() >= 3){
				String matriculaPrefix = matricula.left(3);
				if(matriculaPorCanalProcedencia != null && matriculaPorCanalProcedencia != '' && matriculaPorCanalProcedencia == matriculaPrefix && empleadoMatriculaCorrecta == null){
					empleadoMatriculaCorrecta = canalComunicacion;
				}
				if(!lstEDGMatriculas.isEmpty() && lstEDGMatriculas.contains(matriculaPrefix) && empleadoEDG == null){
					empleadoEDG = canalComunicacion;
				}
			}
		}
		if(empleadoMatriculaCorrecta!=null){
			return empleadoMatriculaCorrecta;
		}else if(empleadoEDG != null){
			return empleadoEDG;
		}
		return null;
	}

	@TestVisible
	private static void identificarPorTelefono(CC_Llamada__c llamada, String telefono, String canalProcedencia) {
		if (!String.isEmpty(telefono)) {
			CC_Canal_Com__c canalComunicacion = buscarEmpleadoPorTelefono(canalProcedencia,telefono);
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

	@testvisible
	private static void finalizarLlamadaActividades(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
		finalizarLlamadasActividades(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
	}

	@testvisible
	private static void finalizarLlamadas(List<CC_Llamada__c> llamadas, String tipoCierre) {
		for (CC_Llamada__c llamada : llamadas) {
			llamada.CC_Fecha_Fin__c = System.now();
			llamada.CC_Tipo_Cierre__c = tipoCierre;
		}
		update llamadas;
	}

	@testvisible
	private static void finalizarLlamadasActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
		if (!llamadas.isEmpty()) {
			finalizarLlamadas(llamadas, tipoCierre);
			finalizarActividadesLlamada(llamadas, tipoActividad, tipoCierre);
		}
	}

	private static void finalizarLlamadasActividadesAbiertas(Id userId) {
		List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c WHERE (RecordType.DeveloperName = 'HDT_Empleado' OR RecordType.DeveloperName = 'CC_Empleado')
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

	@testvisible
	private static Case actualizarCaso(Id casoId, Id propietarioId) {
		Case caso = new Case(Id = casoId);
		caso.OwnerId = propietarioId;
		update caso;
		return caso;
	}

	@testvisible
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

	private static Id crearActividadSaliente(CC_Llamada__c llamada, Id idCaso, String tipoActividad, String detalle) {

		Task actividad = new Task(
			RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId(),
			WhatId = idCaso,
			CC_Llamada_Id__c = llamada.Id,
			WhoId = llamada.CC_Contacto__c,
			Type = tipoActividad,
			Subject = tipoActividad + (detalle != null ? ' (' + detalle + ')' : ''),
			ActivityDate = System.today(),
			CC_Fecha_Inicio__c = System.now(),
			CC_Tipo_Cierre__c = llamada.CC_Tipo_Cierre__c
		);
		insert actividad;
		return actividad.Id;
	}

	@TestVisible
	private static Case contadorLlamadasSalientes(CC_Llamada__c llamada, Case micaso){
		micaso.CC_OTP_Intentos__c = [SELECT COUNT() FROM Task WHERE WhatId = :micaso.Id AND Type = 'Llamada saliente'];
		return micaso;
	}

}