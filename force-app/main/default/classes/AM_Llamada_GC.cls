public with sharing class AM_Llamada_GC {

	public static Map<String, Object> registrarLlamadaEntrante(CC_Llamada_Input inputLlamada) {
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c, CC_Encuesta__r.CC_Codigo__c
													FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputLlamada.servicio LIMIT 1];
		Case caso = null;
		Case casoVinculado = null;
		CC_Llamada__c llamada = new CC_Llamada__c(
			RecordTypeId = Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId(),
			KIN_Genesys_Cloud__c = true,
			KIN_Llamada_Origen__c = true,
			CC_Tipo__c = String.isBlank(inputLlamada.nombreCampana) ? 'Entrante' : 'Saliente',
			CC_Agente__c = [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()].EmployeeNumber,
			CC_Extension__c = inputLlamada.extension,
			CC_ConnId__c = inputLlamada.connId,
			CC_ANI__c = inputLlamada.ani,
			CC_DNIS__c = inputLlamada.dnis,
			CC_Servicio_Genesys__c = servicioGenesys.Id,
			CC_Idioma__c = codigoIdioma(inputLlamada.idioma),
            // CC_Asunto__c = String.isNotEmpty(inputLlamada.userQuery) ? inputLlamada.userQuery.left(255) : inputLlamada.asunto.left(255),
            CC_Asunto__c = inputLlamada.asunto.left(255),
			CC_Datos_Genesys__c = inputLlamada.datos,
			CC_ConnId_Cognitivo__c = inputLlamada.connIdCognitivo,
			CC_NumPerso__c = inputLlamada.numPerso,
			CC_Llamada_Padre__c = String.isEmpty(inputLlamada.salesforceParentId) ? null : inputLlamada.salesforceParentId,
			CC_No_Identificado__c = false,
			CC_Fecha_Inicio__c = System.now(),
			CC_Id_Cognitivo__c = inputLlamada.cognitivoId,
			CC_IdentCliente__c = '0', //Sin datos ALF
			CC_Campana_Genesys__c = inputLlamada.nombreCampana,
			CC_Perfil__c = inputLlamada.perfil,
			KIN_Genesys_Cloud_URL_Grabacion__c = inputLlamada.urlGrabacion,
			CC_Sentimiento__c = inputLlamada.sentiment,
			CC_Respuesta_Asistente__c = inputLlamada.assistantResponse,
			CC_LlamadoOficina__c = !String.isEmpty(inputLlamada.telefonoUnico)
		);

		if (String.isNotBlank(inputLlamada.statusAuto)) {
			//Validamos que el valor este dentro de la picklist CC_Status_Autorizacion__c
			List<String> valoresPermitidos = new List<String>();
			for (Schema.PicklistEntry picklistEntry : Schema.sObjectType.CC_Llamada__c.fields.CC_Status_Autorizacion__c.getPicklistValues()) {

				valoresPermitidos.add(picklistEntry.getValue());
			}
			if (valoresPermitidos.contains(inputLlamada.statusAuto)) {
				llamada.CC_Status_Autorizacion__c = inputLlamada.statusAuto;
			} else {
				llamada.CC_Status_Autorizacion__c = null;
			}
		}

        if (servicioGenesys.CC_Tipo_Cliente__c == 'Empleado') {
            llamada.RecordTypeId = Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            identificarPorTelefono(llamada, inputLlamada.ani);
            if (String.isEmpty(inputLlamada.casoId) && !String.isEmpty(llamada.CC_Id_Cognitivo__c)) {
                //Buscamos el caso correspondiente al Id de cognitivo. Si no lo encuentra, lo crea con la información de la llamada y el chat obtenido de cognitivo
                caso = CC_WS_Recupera_LogConversacion.CC_WS_Recupera_Conversacion(llamada);
            }
        } else {
            Contact contactoAsociado = identificarPorNumPerso(llamada, inputLlamada.numPerso);
            if (!String.isEmpty(inputLlamada.summary)) {
                llamada.CC_Resumen_AI__c = inputLlamada.summary;
            } else if (llamada.CC_Idioma__c == 'en' || contactoAsociado != null && (contactoAsociado.Account.CC_Empleado_Familiar__c || contactoAsociado.Account.CC_MarcaSenior__c)) {
                llamada.CC_Resumen_AI__c = 'No hay conversación con el asistente';
            } else {
                llamada.CC_Resumen_AI__c = 'Sin Información';
            }
        }
		finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
		insert llamada;

		if (String.isEmpty(inputLlamada.casoId)) {
			if (caso != null) {
				actualizarCaso(caso.Id, UserInfo.getUserId());
				vincularCaso(caso, llamada, servicioGenesys);
			}
			casoVinculado = crearVincularCaso(llamada);
		} else {
			//Cuando se pasa el caso, es que se ha hecho una transferencia ciega y entra como llamada
			crearActividad(llamada.Id, inputLlamada.casoId, 'Llamada transferida', servicioGenesys.Name);
			actualizarCaso(inputLlamada.casoId, UserInfo.getUserId(), servicioGenesys.CC_Canal_Procedencia__c);
		}

		return new Map<String, Object>{
			'className' => CC_Llamada_GC.class.getName(),
			'llamada' => llamada,
			'caso' => casoVinculado,
			'encuestaId' => servicioGenesys.CC_Encuesta__r.CC_Codigo__c,
			'abrirTabId' => llamada.Id
		};
	}

	public static Map<String, Object> registrarLlamadaSaliente(CC_Llamada_Input inputLlamada) {
		finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
		CC_Llamada__c llamada;
		Case caso;

		if (String.isBlank(inputLlamada.nombreCampana)) {
			CC_Servicio_Genesys__c servicioGenesys = [SELECT CC_Tipo_Cliente__c FROM CC_Servicio_Genesys__c
														WHERE CC_Codigo__c = 'AM_GenesysCloudOutboundDefault' LIMIT 1];

			if (String.isNotBlank(inputLlamada.casoId)) {
				caso = [SELECT RecordType.DeveloperName, Subject, CC_Idioma__c, AccountId, ContactId, CC_No_Identificado__c, CC_Canal_Resolucion__c
						FROM Case WHERE Id = :inputLlamada.casoId];
			}
			llamada = new CC_Llamada__c(
				RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'AM_Task'),
				KIN_Genesys_Cloud__c = true,
				KIN_Llamada_Origen__c = true,
				CC_Servicio_Genesys__c = servicioGenesys.Id,
				CC_Tipo__c = 'Saliente',
				CC_Agente__c = [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()].EmployeeNumber,
				CC_Extension__c = inputLlamada.extension,
				CC_ConnId__c = inputLlamada.connId,
				CC_DNIS__c = inputLlamada.dnis,
				CC_Idioma__c = codigoIdioma(inputLlamada.idioma),
				CC_Asunto__c = String.isNotBlank(inputLlamada.asunto) ? inputLlamada.asunto.left(255) : null,
				CC_No_Identificado__c = false,
				CC_Fecha_Inicio__c = System.now(),
				CC_IdentCliente__c = '0', // Sin datos ALF);
				KIN_Genesys_Cloud_URL_Grabacion__c = inputLlamada.urlGrabacion
			);
			insert llamada;

			//Case casoVinculado = crearVincularCaso(llamada);
			crearActividad(llamada.Id, inputLlamada.casoId, 'Llamada saliente', null);
		} else {
			llamada = (CC_Llamada__c)registrarLlamadaEntrante(inputLlamada).get('llamada');
		}
		return new Map<String, Object>{
			'className' => 'AM_Llamada_GC',
			'llamada' => llamada,
			'idioma' => formatoIdiomaGenesys(caso.CC_Idioma__c)
		};
	}

	public static Map<String, Object> registrarEncuesta(CC_Llamada_Input inputLlamada) {
		String nombreEncuesta;
		if (String.isNotBlank(inputLlamada.llamadaId)) {
			String connId = String.valueOf(inputLlamada.connId);
			List<CC_Llamada__c> llamadas = [SELECT CC_Servicio_Genesys__r.CC_Encuesta__r.Name, CC_Tipo__c
											FROM CC_Llamada__c WHERE CC_ConnId__c = :connId ORDER BY CreatedDate DESC LIMIT 1];
			CC_Llamada__c llamada = llamadas[0];

			Id idEncuesta = llamada.CC_Servicio_Genesys__r.CC_Encuesta__c;
			if (String.isNotBlank(idEncuesta)) {
				llamada.CC_Encuesta__c = idEncuesta;
				nombreEncuesta = llamada.CC_Servicio_Genesys__r.CC_Encuesta__r.Name;
				update llamada;

				DateTime dt = DateTime.now();
				Long dateInMilliseconds = dt.getTime();

				AsyncOptions options = new AsyncOptions();
				options.DuplicateSignature = QueueableDuplicateSignature.Builder()
					.addId(UserInfo.getUserId())
					.addString(String.valueOf(dateInMilliseconds))
					.build();

				try {

					CSBD_CrearActividadEncuesta_Job crearActividadEncuestaJob = new CSBD_CrearActividadEncuesta_Job(llamada.Id, 'Encuesta', nombreEncuesta, 'Encuesta enviada');
					System.enqueueJob(crearActividadEncuestaJob);

				} catch (DuplicateMessageException ex) {
					//Exception is thrown if there is already an enqueued job with the same signature
					CBK_Log.error(ex);
				}

			}

		}

		return new Map<String, Object>{
			'className' => 'AM_Llamada_GC',
			'nombreEncuesta' => nombreEncuesta
		};
	}

	public static Map<String, Object> iniciarLlamadaSalienteClickToDial(CC_Llamada_Input inputLlamada) {
		// finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());

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

		Opportunity oportunidad = [SELECT CreatedDate, Name, CSBD_Idioma_Solicitud__c,  CSBD_Horario_Contacto__c, CSBD_Proveedor__c,
									CSBD_SLA_Primera_Respuesta__c, RecordType.DeveloperName, CSBD_PrimerContactoSLA__c
									FROM Opportunity WHERE Id = :inputLlamada.casoId];
		/*
		List<String> recordTypesSla = new List<String>{'CSBD_CMB', 'CSBD_CMN', 'CSBD_Hipoteca', 'CSBD_Prestamo', 'CSBD_PROAutomatica'};
		if (recordTypesSla.contains(oportunidad.Recordtype.DeveloperName)) {
			informarSla(llamada, oportunidad);
		}
		*/

		return new Map<String, Object>{
			'className' => 'AM_Llamada_GC',
			'llamada' => llamada,
			'idioma' => formatoIdiomaGenesys(oportunidad.CSBD_Idioma_Solicitud__c),
			'proveedor' => oportunidad?.CSBD_Proveedor__c == null ? '' : oportunidad.CSBD_Proveedor__c,
			'numLlamadasAnteriores' => llamadasAnteriores.size()
		};
	}

	private static Opportunity informarSla(CC_Llamada__c llamada, Opportunity oportunidad) {
		//Primera actividad de llamada saliente, por lo que hay que calcular el campo CSBD_SLA_Primera_Respuesta__c de la oportunidad vinculada.
		if ([SELECT RecordTypeId, CC_Llamada_Id__c FROM Task WHERE WhatId = :oportunidad.Id AND Type = 'Llamada saliente'].size() == 1 && oportunidad.CSBD_PrimerContactoSLA__c == null && oportunidad.CSBD_SLA_Primera_Respuesta__c == null) {
			// Guardo la fecha de creación de la Oportunidad
			Datetime tiempoOrigen;
			Datetime tiempoFinal = System.now();

			/* ----------------------- RecordType CMN, Préstamo, Hipotecas y PRO Automática----------------------- */
			if (oportunidad.Recordtype.DeveloperName == 'CSBD_CMN' || oportunidad.Recordtype.DeveloperName == 'CSBD_Prestamo' || oportunidad.Recordtype.DeveloperName == 'CSBD_Hipoteca'
			|| oportunidad.Recordtype.DeveloperName == 'CSBD_PROAutomatica' || oportunidad.Recordtype.DeveloperName == 'CSBD_MAC') {
				if((oportunidad.Recordtype.DeveloperName == 'CSBD_Hipoteca' || oportunidad.Recordtype.DeveloperName == 'CSBD_PROAutomatica') && oportunidad.CSBD_HorarioComercial__c == 'NO'){

					List<CC_Lista_Valores__c> lovList = [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c
															WHERE RecordType.DeveloperName = 'CC_Valor'
															AND CC_Lista__r.Name = 'CSBD: Horarios comerciales por tipología'
															AND Name  =: oportunidad.Recordtype.Name
															AND CC_Activa__c = TRUE limit 1];

					if(!lovList.isEmpty()){

						List<BusinessHours> businessHoursList = [SELECT Id, Name FROM BusinessHours WHERE Name =:lovList[0].CC_Valor__c limit 1];

						tiempoOrigen = BusinessHours.nextStartDate(businessHoursList[0].id, oportunidad.CreatedDate);

						}

				}else{
					tiempoOrigen = oportunidad.CreatedDate;
				}
			}

			/* ----------------------- RecordType CMB -----------------------*/
			if (oportunidad.Recordtype.DeveloperName == 'CSBD_CMB') {
				if(String.isNotBlank(oportunidad.CSBD_Horario_Contacto__c)) {
					String rangoFinal = Datetime.now().format('yyyy-MM-dd') + ' ' + oportunidad.CSBD_Horario_Contacto__c.substring(7) + ':00';
					tiempoOrigen = Datetime.valueOf(rangoFinal);

					if(tiempoOrigen < oportunidad.CreatedDate){
						tiempoOrigen = tiempoOrigen.addDays(1);
					}
				}
				else{
					tiempoOrigen = oportunidad.CreatedDate;
				}
			}

			// Se calculan los SLAs
			if(tiempoOrigen >= System.now()) {
				oportunidad.CSBD_SLA_Primera_Respuesta__c = 0;
				oportunidad.CSBD_PrimerContactoSLA__c = tiempoFinal;
			}
			if(tiempoOrigen < System.now()){
				oportunidad.CSBD_SLA_Primera_Respuesta__c = (Integer)(tiempoFinal.getTime() - tiempoOrigen.getTime())/(1000 * 60);
				oportunidad.CSBD_PrimerContactoSLA__c = tiempoFinal;
			}
		}
		return oportunidad;
	}

	@TestVisible
	// private static void identificarPorNumPerso(CC_Llamada__c llamada, String numPerso) {
		private static Contact identificarPorNumPerso(CC_Llamada__c llamada, String numPerso) {
			Contact retorno = null;
		//Realizamos una búsqueda para informar el contacto y la cuenta
		if(llamada != null){
            if (!String.isEmpty(llamada.CC_DNIS__c)) {
				List<Account> cuentas = [SELECT Name, CC_Inactivo__c, CC_Centro_Integrador__c, CC_Tipo_Centro__c FROM Account
											WHERE Phone = :llamada.CC_DNIS__c AND recordType.Developername = 'CC_CentroCaixaBank'
											AND CC_Tipo_Centro__c = 'OF' AND CC_Inactivo__c = FALSE AND CC_Centro_Integrador__c = NULL LIMIT 1];
                if (!cuentas.isEmpty()) {
					llamada.CC_Oficina_Contactada__c = cuentas[0].Id;
                }
            }
        }
		if (!String.isEmpty(numPerso)) {
			Boolean identificarConAlf = false;
			if (!Test.isRunningTest()) {
				List<CC_Identificacion_Telefonia__mdt> mdt = [SELECT Id FROM CC_Identificacion_Telefonia__mdt
																WHERE CC_Identificar_Mediante_ALF__c = TRUE LIMIT 1];
				identificarConAlf = !mdt.isEmpty();
			}

			if (identificarConAlf) {
				//Identificación contra Alfabetico
				List<Contact> contactos = new List<Contact>();
				Map<String, Object> mapaCuentasContactos = CC_IdentCliente_Future.getIdentificacionALF('NP', numPerso);
				List<Account> cuentas = (List<Account>)mapaCuentasContactos.get('CUENTAS');
				List<Account> cuentasAct = new List<Account>();

				if (cuentas.size() == 1) {
					/*if (llamada.CC_Perfil__c == 'EMPLEADOS'){
						cuentas[0].CC_Eapizado_4223__c = true;
						Account cuentaSinNombre = new Account(Id=cuentas[0].Id, CC_Eapizado_4223__c=cuentas[0].CC_Eapizado_4223__c);
						cuentasAct.add(cuentaSinNombre);
					}*/
					if (llamada.CC_Perfil__c != '' && llamada.CC_Perfil__c != null){
						cuentas[0].CC_Perfil__c = llamada.CC_Perfil__c;
						cuentasAct.add(new Account(Id = cuentas[0].Id, CC_Perfil__c = cuentas[0].CC_Perfil__c));
					}

					// Cambio para añadir representantes.
					if (mapaCuentasContactos.containsKey('REPRESENTANTES')) {
						contactos = (List<Contact>)mapaCuentasContactos.get('REPRESENTANTES');
						if (contactos.size() == 1) {
							llamada.CC_Cuenta__c = cuentas[0].Id;
							llamada.CC_Contacto__c = contactos[0].Id;
							llamada.CC_IdentCliente__c = '1'; // Alfabético automático
							retorno = contactos[0];
						}
					} else if (mapaCuentasContactos.containsKey('CONTACTOS')) {
						contactos = (List<Contact>)mapaCuentasContactos.get('CONTACTOS');
						if (contactos.size() == 1) {
							llamada.CC_Cuenta__c = cuentas[0].Id;
							llamada.CC_Contacto__c = contactos[0].Id;
							llamada.CC_IdentCliente__c = '1'; // Alfabético automático
							retorno = contactos[0];
						}
					}
				}
				if (!cuentasAct.isEmpty()) {
					Database.update(cuentasAct, false);
				}
			} else {
				//Identificación contra BD
				List<Contact> contactos = [SELECT AccountId, Account.CC_MarcaSenior__c, Account.CC_Empleado_Familiar__c FROM Contact WHERE CC_NumPerso__c = :numPerso
											AND (RecordType.DeveloperName = 'CC_Cliente' OR Account.RecordType.DeveloperName = 'CC_ClientePA') AND Account.AV_Confidencial__c = false LIMIT 2];
				if (contactos.size() == 1) {
					llamada.CC_Cuenta__c = contactos[0].AccountId;
					llamada.CC_Contacto__c = contactos[0].Id;
					llamada.CC_IdentCliente__c = '0'; //Sin datos ALF
					retorno = contactos[0];
				}
			}
		}
		return retorno;
	}

	private static Id crearActividad(Id llamadaId, Id casoId, String tipoActividad, String asunto, String tipoCierre) {
		Task actividad = crearObjetoActividad(llamadaId, casoId, tipoActividad, asunto, tipoCierre);
		insert actividad;
		return actividad.Id;
	}

	private static Id crearActividad(Id llamadaId, Id casoId, String tipoActividad, String asunto) {
		return crearActividad(llamadaId, casoId, tipoActividad, asunto, null);
	}

	private static Task crearObjetoActividad(Id llamadaId, Id whatId, String tipoActividad, String asunto, String tipoCierre) {
		Task actividad = new Task(
			Subject = tipoActividad + (asunto != null ? ' (' + asunto + ')' : ''),
			CC_Llamada_Id__c = llamadaId,
			ActivityDate = System.today(),
			CC_Fecha_Inicio__c = System.now(),
			WhatId = whatId,
			Type = tipoActividad,
			CC_validacion_tarea_manual__c = true,
			RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('AM_Task').getRecordTypeId()
		);
		if (tipoCierre != null) {
			actividad.CC_Fecha_Fin__c = System.now();
			actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
			actividad.Status = 'Completed';
		}
		return actividad;
	}

	public static Map<String, Object> finalizarLlamada(CC_Llamada_Input inputLlamada, String tipoCierre) {
		Id recordId = String.valueOf(inputLlamada.llamadaId);
		if (String.valueOf(recordId?.getSobjectType()) == 'Opportunity') {
			List<Task> tarea = [SELECT CC_Llamada_Id__c FROM Task
									WHERE WhatId = :inputLlamada.llamadaId AND CC_Llamada_Id__c != null AND RecordType.DeveloperName = 'CSBD_Task' AND Status = 'Open'
									ORDER BY CreatedDate DESC LIMIT 1];
			if (!tarea.isEmpty()) {
				inputLlamada.llamadaId = tarea[0].CC_Llamada_Id__c;
			}
		}
		String llamadaId = buscarLlamada(inputLlamada);
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
		return new Map<String, Object>{'className' => 'CSBD_Llamada_GC', 'idLlamada' => llamadaId};
	}

	/** Cuando no nos llega el Id de llamada, lo buscamos por connId, usuario y extensión */
	private static String buscarLlamada(CC_Llamada_Input jsonLlamada) {
		String resultado = jsonLlamada.llamadaId;
		if (String.isEmpty(resultado)) {
			List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c
											WHERE CC_ConnId__c = :jsonLlamada.connId AND CC_Agente__c = :jsonLlamada.usuario
											AND CC_Extension__c = :jsonLlamada.extension AND CC_Fecha_Fin__c = null];
			if (llamadas.size() == 1) {
				resultado = llamadas[0].Id;
			}
		}
		return resultado;
	}

	private static void finalizarLlamadaActividades(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
		finalizarLlamadasActividades(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
	}

	private static void finalizarLlamadasActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
		if (!llamadas.isEmpty()) {
			finalizarLlamadas(llamadas, tipoCierre);
			finalizarActividades(llamadas, tipoActividad, tipoCierre);
		}
	}

	private static void finalizarLlamadas(List<CC_Llamada__c> llamadas, String tipoCierre) {
		for (CC_Llamada__c llamada : llamadas) {
			llamada.CC_Fecha_Fin__c = System.now();
			llamada.CC_Tipo_Cierre__c = tipoCierre;
		}
		update llamadas;
	}

	private static void finalizarLlamadasActividadesAbiertas(Id userId) {

		List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c WHERE CC_Fecha_Fin__c = null AND OwnerId = :userId];
		if (!llamadas.isEmpty()) {
            finalizarLlamadas(llamadas, 'Llamada finalizada');
			finalizarActividades(llamadas, 'Llamada%', 'Llamada finalizada');
			finalizarActividades(llamadas, 'Consulta%', 'Consulta cancelada');
		}
	}

	private static void finalizarActividades(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
		finalizarActividades(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
	}

	private static void finalizarActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
		Set<Id> llamadaIds = new Set<Id>();
		Map<Id, Integer> oppDuracionMapa = new Map<Id, Integer>();

		if (!llamadas.isEmpty()) {
			List<Task> actividades = [SELECT CC_Fecha_Inicio__c, WhatId FROM Task WHERE CC_Llamada_Id__c IN :CC_MetodosUtiles.listaCampo(llamadas, 'Id')
										AND Status = 'Open' AND Type LIKE :tipoActividad AND RecordType.DeveloperName = 'CSBD_Task'];
			if (!actividades.isEmpty()) {
				for (Task actividad : actividades) {
					actividad.CC_Fecha_Fin__c = System.now();
					actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
					actividad.Status = 'Completed';

					Integer duracionMinutos = (Integer)((System.now().getTime() - actividad.CC_Fecha_Inicio__c.getTime()) / (1000 * 60));
					oppDuracionMapa.put(actividad.WhatId, duracionMinutos);
				}
				update actividades;
			}
		}

        //SLA
		List<Opportunity> oportunidadesSla = [SELECT CSBD_SLA_TGT__c FROM Opportunity WHERE OwnerId = :UserInfo.getUserId()
												AND IsClosed = FALSE AND Id IN :oppDuracionMapa.keySet() AND CSBD_SLA_TMO__c = NULL];
		for (Opportunity oppSla : oportunidadesSla) {
			oppSla.CSBD_SLA_TGT__c = (oppSla.CSBD_SLA_TGT__c ?? 0) + oppDuracionMapa.get(oppSla.Id);
		}
		update oportunidadesSla;
	}

	private static String obtenerTipoCierre(String tipoCierre) {
		for (Schema.PicklistEntry tipo : CC_Llamada__c.CC_Tipo_Cierre__c.getDescribe().getPicklistValues()) {
			if (tipo.getValue().equals(tipoCierre)) {
				return tipo.getLabel();
			}
		}
		return tipoCierre;
	}

	private static String formatoIdiomaGenesys(String idioma) {
		if (idioma == 'Catalán') {
			return 'Catalan';
		} else if (idioma == 'Inglés') {
			return 'Ingles';
		} else {
			return 'Castellano';
		}
	}

	@TestVisible
	private static String codigoIdioma(String idioma) {
		return 'Inglés'.equals(idioma) ? 'en' :
			'Catalán'.equals(idioma) ? 'ca' :
			'Valenciano'.equals(idioma) ? 'va' :
			'Euskera'.equals(idioma) ? 'eu' :
			'Gallego'.equals(idioma) ? 'ga' : 'es';
	}

	@TestVisible
	private static void identificarPorTelefono(CC_Llamada__c llamada, String telefono) {

		if (!String.isEmpty(telefono)) {
            telefono = telefono.replace('+3400', '');
            telefono = telefono.replace('+34', '');

			List<CC_Canal_Com__c> telefonos = [SELECT CC_ContactoId__c, CC_ContactoId__r.AccountId FROM CC_Canal_Com__c
												WHERE CC_Telefono__c =:telefono AND RecordType.DeveloperName = 'CC_Telefono'
												AND CC_ContactoId__r.RecordType.DeveloperName = 'CC_Empleado' LIMIT 2];
			if (telefonos.size() == 1 ) {
				llamada.CC_Cuenta__c = telefonos[0].CC_ContactoId__r.AccountId;
				llamada.CC_Contacto__c = telefonos[0].CC_ContactoId__c;
			}
		}
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

	private static void vincularCaso(Case caso, CC_Llamada__c llamada, CC_Servicio_Genesys__c servicioGenesys) {
		String tipoActividad;
		if (llamada.CC_ConnId__c == null) { //Si es una consulta
			tipoActividad = tipoConsulta(servicioGenesys);
		} else {
			tipoActividad = llamada.CC_Tipo__c.equals('Saliente') ? 'Llamada saliente' : 'Llamada entrante';
		}
		crearActividad(llamada.Id, caso.Id, tipoActividad, servicioGenesys.Name);
	}

	public static Case crearVincularCaso(CC_Llamada__c llamada) {
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Canal_de_Entrada__c, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c
													FROM CC_Servicio_Genesys__c WHERE Id = :llamada.CC_Servicio_Genesys__c];
		Case caso = crearCaso(llamada, servicioGenesys);
		vincularCaso(caso, llamada, servicioGenesys);
		return [SELECT Id,CaseNumber, Status, Owner.Name, CreatedDate, Subject FROM Case WHERE Id = :caso.Id];
	}

	private static Case crearCaso(CC_Llamada__c llamada, CC_Servicio_Genesys__c servicioGenesys) {
		String telefonoCaso;
		List<Account> cuenta = new List<Account>();
		if (llamada.CC_Cuenta__c != null) {
			cuenta = [SELECT Phone, PersonMobilePhone, CC_MarcaSenior__c, CC_Empleado_Familiar__c  FROM Account WHERE Id = :llamada.CC_Cuenta__c];
			if (cuenta[0].PersonMobilePhone != null) {
				telefonoCaso = cuenta[0].PersonMobilePhone;
			} else if (cuenta[0].Phone != null) {
				telefonoCaso = cuenta[0].Phone;
			}
		}

		Case caso = new Case(
			Subject = llamada.CC_Asunto__c,
			Origin = servicioGenesys.CC_Canal_de_Entrada__c == 'Telefono' ? 'Phone' : String.isBlank(servicioGenesys.CC_Canal_de_Entrada__c) ? 'Phone' : servicioGenesys.CC_Canal_de_Entrada__c,
			CC_Canal_Respuesta__c = 'Phone',
			CC_Telefono_Contacto__c = llamada.CC_ANI__c,
			OS_Telefono__c = telefonoCaso,
			CC_Canal_Procedencia__c = servicioGenesys.CC_Canal_Procedencia__c,
			CC_Idioma__c = llamada.CC_Idioma__c,
			AccountId = llamada.CC_Cuenta__c,
			ContactId = llamada.CC_Contacto__c,
            CC_Representante__c = llamada.CC_Representante__c,
			CC_IdentCliente__c = llamada.CC_IdentCliente__c,
			Canal_del_Empleado__c = llamada.CC_Canal_del_Empleado__c,
			CC_Id_Cognitivo__c = llamada.CC_Id_Cognitivo__c,
			CC_Status_Autorizacion__c = llamada.CC_Status_Autorizacion__c,
            //KIN_Genesys_Cloud_URL_Grabacion__c = llamada. KIN_Genesys_Cloud_URL_Grabacion__c,
			//Nuevo proyecto GENiaL
			//CC_Resumen_AI__c = llamada.CC_Resumen_AI__c,
			CC_Sentimiento__c = llamada.CC_Sentimiento__c,
			CC_Respuesta_Asistente__c = llamada.CC_Respuesta_Asistente__c
			//CC_Asunto__c = llamada.CC_Asunto_IA__c
			);

			if(!String.isEmpty(llamada.CC_Resumen_AI__c)){
				caso.CC_Resumen_AI__c = llamada.CC_Resumen_AI__c;
			}else if(!cuenta.isEmpty() || llamada.CC_Idioma__c == 'en' && (cuenta[0].CC_Empleado_Familiar__c || cuenta[0].CC_MarcaSenior__c)){
				caso.CC_Resumen_AI__c = 'No hay conversación con el asistente';
			}else{
				caso.CC_Resumen_AI__c = 'Sin Información';
			}

			if (servicioGenesys.CC_Tipo_Cliente__c == 'Cliente') {
				caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
				caso.CC_Tipo_Cliente__c = 'Cliente';
				caso.CC_OTP_Nivel__c = llamada.CC_Status_Autorizacion__c != null ? 'Cliente Digital' : '';
			if (llamada.CC_Cuenta__c != null) {
				caso.CC_Oficina_Afectada_Lookup__c = llamada.CC_Cuenta__r.AV_OficinaPrincipal__c;
			}
		} else if (servicioGenesys.CC_Tipo_Cliente__c == 'Empleado') {
			caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
			caso.CC_Tipo_Cliente__c = 'Empleado';
		} else if (servicioGenesys.CC_Tipo_Cliente__c == 'CSI Bankia') {
			caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_CSI_Bankia');
			caso.CC_Tipo_Cliente__c = 'Empleado';
		}

		//Preparar el contacto intermedio
		if (servicioGenesys.CC_Canal_Procedencia__c == 'Atención al Cliente') {
			caso.CC_Cont_Interm_Delay__c = CC_MetodosUtiles.delayContactoIntermedio('CC_Contacto_Intermedio_AC_ES', 'CC_Contacto_Intermedio_AC');
		}
		insert caso;
		return caso;
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