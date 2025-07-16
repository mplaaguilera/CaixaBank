public with sharing class CSBD_Llamada_GC {

	public static Map<String, Object> registrarLlamadaEntrante(CC_Llamada_Input inputLlamada) {
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c, CSBD_Empresa_Proveedora__c,
													CSBD_Familia_Producto__c, CSBD_Producto__c, CSBD_Now_Codigo_Producto__c, CSBD_Canal__c,
													CSBD_Now_Origen__c, CC_Encuesta__r.CC_Codigo__c
													FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputLlamada.servicio LIMIT 1];
		CC_Llamada__c llamada = new CC_Llamada__c(
			RecordTypeId = Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosByDeveloperName().get('CSBD_Cliente').getRecordTypeId(),
			KIN_Genesys_Cloud__c = true,
			KIN_Llamada_Origen__c = true,
			CC_Servicio_Genesys__c = servicioGenesys.Id,
			CC_Tipo__c = String.isBlank(inputLlamada.nombreCampana) ? 'Entrante': 'Saliente',
			CC_Agente__c = inputLlamada.usuario,
			CC_Extension__c = inputLlamada.extension,
			CC_ConnId__c = inputLlamada.connId,
			CC_ANI__c = inputLlamada.ani,
			CC_DNIS__c = inputLlamada.dnis,
			CC_Idioma__c = codigoIdioma(inputLlamada.idioma),
			CC_Asunto__c = inputLlamada.asunto.left(255),
			CC_Datos_Genesys__c = inputLlamada.datos,
			CC_ConnId_Cognitivo__c = inputLlamada.connIdCognitivo,
			CC_NumPerso__c = inputLlamada.numPerso,
			CC_Llamada_Padre__c = String.isEmpty(inputLlamada.salesforceParentId) ? null : inputLlamada.salesforceParentId,
			CC_No_Identificado__c = false,
			CC_Fecha_Inicio__c = System.now(),
			//CC_Canal_del_Empleado__c = inputLlamada.canalEmpleado,
			CC_Id_Cognitivo__c = inputLlamada.cognitivoId,
			CC_IdentCliente__c = '0',  //Sin datos ALF
			CC_Campana_Genesys__c = inputLlamada.nombreCampana,
			KIN_Genesys_Cloud_URL_Grabacion__c = inputLlamada.urlGrabacion
		);

		identificarPorNumPerso(llamada, inputLlamada.numPerso);
		finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
		insert llamada;

		Boolean crearNuevaOportunidad = true;
		Opportunity oportunidad;

		CSBD_LlamadaSettings__c llamadaSettings = CSBD_LlamadaSettings__c.getOrgDefaults();
		Boolean crearSiempreOportunidad = llamadaSettings?.CSBD_EntranteCrearSiempreOportunidad__c ?? false;
		if (!crearSiempreOportunidad) {
			crearNuevaOportunidad = false;
		}

		if (crearNuevaOportunidad) {
			// Se crea una nueva oportunidad
			oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Llamada_Servicio', new Map<String, Object>{
				'CSBD_Empresa_Proveedora__c' => servicioGenesys.CSBD_Empresa_Proveedora__c,
				'CSBD_Familia_Producto__c' => servicioGenesys.CSBD_Familia_Producto__c,
				'CSBD_Producto__c' => servicioGenesys.CSBD_Producto__c,
				'CSBD_Telefono_Solicitud__c' => llamada.CC_ANI__c,
				'CSBD_Now_Codigo_Producto__c' => servicioGenesys.CSBD_Now_Codigo_Producto__c,
				'CSBD_Canal__c' => servicioGenesys.CSBD_Canal__c,
				'CSBD_Now_Origen__c' => servicioGenesys.CSBD_Now_Origen__c,
				'CSBD_Estado__c' => 'Activa',
				'AccountId' => llamada.CC_Cuenta__c,
				'CSBD_Contact__c' => llamada.CC_Contacto__c,
				'CSBD_Idioma_Solicitud__c' => inputLlamada.idioma,
				'OwnerId' => UserInfo.getUserId(),
				'CSBD_Turno_Contacto__c' => llamada.CC_Fecha_Inicio__c.hour() < 15 ? 'Mañana': 'Tarde'
			});
		} else {
			oportunidad = CSBD_WS_GetGestorRoutingLlamada.calcularOportunidad(inputLlamada.ani);
			if (oportunidad != null) { //Se reutiliza la oportunidad existente
				oportunidad = [SELECT CSBD_Empresa_Proveedora__c, CSBD_Familia_Producto__c, CSBD_Producto__c,
								CSBD_Telefono_Solicitud__c, CSBD_Now_Codigo_Producto__c, CSBD_Canal__c, CSBD_Now_Origen__c,
								CSBD_Estado__c, AccountId, CSBD_Contact__c, CSBD_Idioma_Solicitud__c, OwnerId,
								CSBD_Turno_Contacto__c, CSBD_Identificador__c FROM Opportunity WHERE Id = :oportunidad.Id];
				if (oportunidad.OwnerId != UserInfo.getUserId()) {
					oportunidad.OwnerId = UserInfo.getUserId();
					update oportunidad;
				}
			}
		}

		Id idTask = crearActividad(llamada, oportunidad.Id, 'Llamada entrante', servicioGenesys.Name);

		return new Map<String, Object>{
			'className' => 'CSBD_Llamada_GC',
			'llamada' => llamada,
			'caso' => oportunidad,
			'abrirTabId' => oportunidad.Id,
			'encuestaId' => servicioGenesys.CC_Encuesta__r.CC_Codigo__c
		};
	}

	public static Map<String, Object> registrarLlamadaSaliente(CC_Llamada_Input inputLlamada) {
		finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Id FROM CC_Servicio_Genesys__c
													WHERE CC_Codigo__c = 'NIS_GenesysCloudOutboundDefault' LIMIT 1];

		Opportunity oportunidad = [SELECT CreatedDate, Name, CSBD_Idioma_Solicitud__c, AccountId, CSBD_Horario_Contacto__c, CSBD_Contact__c, CSBD_HorarioComercial__c,
									RecordTypeId, CSBD_Fecha_ultimacita__c, CSBD_Fecha_Cita__c, CSBD_Proveedor__c, CSBD_SLA_Primera_Respuesta__c, Recordtype.DeveloperName, Recordtype.Name, CSBD_PrimerContactoSLA__c, IsClosed,
									CSBD_Llamadas_Salientes__c
									FROM Opportunity WHERE Id = :inputLlamada.casoId];

        CC_Llamada__c llamada = new CC_Llamada__c(
			RecordTypeId = Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosByDeveloperName().get('CSBD_Cliente').getRecordTypeId(),
			KIN_Genesys_Cloud__c = true,
			KIN_Llamada_Origen__c = true,
			CC_Servicio_Genesys__c = servicioGenesys.Id,
			CC_Tipo__c = 'Saliente',
			CC_Agente__c = inputLlamada.usuario,
			CC_Extension__c = inputLlamada.extension,
			CC_ConnId__c = inputLlamada.connId,
			CC_ConnId_Consulta__c = null,
			CC_DNIS__c = inputLlamada.dnis,
			CC_Idioma__c = codigoIdioma(oportunidad.CSBD_Idioma_Solicitud__c),
			CC_Asunto__c = oportunidad.Name,
			CC_Cuenta__c = oportunidad.AccountId,
			CC_Contacto__c = oportunidad.CSBD_Contact__c,
			CC_Fecha_Inicio__c = System.now(),
			CC_Tipo_Cierre__c = 'Llamada no atendida',
			KIN_Genesys_Cloud_URL_Grabacion__c = inputLlamada.urlGrabacion
		);
        insert llamada;
       	crearActividad(llamada, inputLlamada.casoId, 'Llamada saliente', null);

		/* if(oportunidad.Recordtype.DeveloperName == 'CSBD_CMB' || oportunidad.Recordtype.DeveloperName == 'CSBD_CMN' || oportunidad.Recordtype.DeveloperName == 'CSBD_Hipoteca'
		|| oportunidad.Recordtype.DeveloperName == 'CSBD_Prestamo' || oportunidad.Recordtype.DeveloperName == 'CSBD_PROAutomatica') {
			informarSla(llamada, oportunidad);
		} */

		List<String> recordTypesSla = new List<String>{'CSBD_CMB', 'CSBD_CMN', 'CSBD_Hipoteca', 'CSBD_Prestamo', 'CSBD_PROAutomatica', 'CSBD_MAC'};
		List<Opportunity> actualizarOpp = new List<Opportunity>();
		if (recordTypesSla.contains(oportunidad.Recordtype.DeveloperName)) {
			Opportunity oppSLA = informarSla(llamada, oportunidad);
			actualizarOpp.add(oppSLA);
		}

		if(!oportunidad.IsClosed){
			Opportunity oppContador = contadorLlamadasSalientes(llamada, oportunidad);
			if(!actualizarOpp.contains(oppContador)){
				actualizarOpp.add(oppContador);
			}
		}
		update actualizarOpp;
		return new Map<String, Object>{
			'className' => 'CSBD_Llamada_GC',
			'llamada' => llamada,
			'idioma' => formatoIdiomaGenesys(oportunidad.CSBD_Idioma_Solicitud__c),
			'proveedor' => oportunidad?.CSBD_Proveedor__c == null ? '' : oportunidad.CSBD_Proveedor__c
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
			'className' => 'CSBD_Llamada_GC',
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
			'className' => 'CSBD_Llamada_GC',
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
				oportunidad.CSBD_SLA_Primera_Respuesta__c = (Integer)(tiempoFinal.getTime() - tiempoOrigen.getTime())/(1000);
				oportunidad.CSBD_PrimerContactoSLA__c = tiempoFinal;
			}
		}
		return oportunidad;
	}

	/*
	public static Opportunity informarSla(CC_Llamada__c llamada, Opportunity oportunidad) {
		//Primera actividad de llamada saliente, por lo que hay que calcular el campo CSBD_SLA_Primera_Respuesta__c de la oportunidad vinculada.
		//if ([SELECT RecordTypeId, CC_Llamada_Id__c FROM Task WHERE WhatId = :oportunidad.Id AND Type = 'Llamada saliente'].size() == 1 && oportunidad.CSBD_PrimerContactoSLA__c == null && oportunidad.CSBD_SLA_Primera_Respuesta__c == null) {
		if (([SELECT COUNT() FROM Task WHERE WhatId = :oportunidad.Id AND Type = 'Llamada saliente'] == 1
		&& oportunidad.CSBD_PrimerContactoSLA__c == null && oportunidad.CSBD_SLA_Primera_Respuesta__c == null)
		|| oportunidad.CSBD_PrimerContactoSLA__c == null && oportunidad.CSBD_SLA_Primera_Respuesta__c == null) {
			// Guardo la fecha de creación de la Oportunidad
			Datetime tiempoOrigen;
			Datetime tiempoFinal = System.now();
			List<BusinessHours> businessHoursList = new List<BusinessHours>();

			//RecordType CMN, Préstamo, Hipotecas y PRO Automática
			if (oportunidad.Recordtype.DeveloperName == 'CSBD_CMN' || oportunidad.Recordtype.DeveloperName == 'CSBD_Prestamo' || oportunidad.Recordtype.DeveloperName == 'CSBD_Hipoteca'
			|| oportunidad.Recordtype.DeveloperName == 'CSBD_PROAutomatica' || oportunidad.Recordtype.DeveloperName == 'CSBD_MAC') {
				if(oportunidad.Recordtype.DeveloperName == 'CSBD_Hipoteca' || oportunidad.Recordtype.DeveloperName == 'CSBD_PROAutomatica'){

					List<CC_Lista_Valores__c> lovList = [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c
															WHERE RecordType.DeveloperName = 'CC_Valor'
															AND CC_Lista__r.Name = 'CSBD: Horarios comerciales por tipología SLA'
															AND Name  =: oportunidad.Recordtype.DeveloperName
															AND CC_Activa__c = TRUE limit 1];

					if(!lovList.isEmpty()){
						businessHoursList = [SELECT Id, Name FROM BusinessHours WHERE Name =:lovList[0].CC_Valor__c limit 1];
						tiempoOrigen = BusinessHours.nextStartDate(businessHoursList[0].id, oportunidad.CreatedDate);
					}

				}else{
					tiempoOrigen = oportunidad.CreatedDate;
				}
			}

			//RecordType CMB
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
				if(oportunidad.Recordtype.DeveloperName == 'CSBD_Hipoteca' || oportunidad.Recordtype.DeveloperName == 'CSBD_PROAutomatica') {

					if(!businessHoursList.isEmpty()) {
						oportunidad.CSBD_SLA_Primera_Respuesta__c = (Integer)(BusinessHours.diff(businessHoursList[0].id, tiempoOrigen, tiempoFinal))/(1000);
					}
				} else {
					oportunidad.CSBD_SLA_Primera_Respuesta__c = (Integer)(tiempoFinal.getTime() - tiempoOrigen.getTime())/(1000);
				}

				oportunidad.CSBD_PrimerContactoSLA__c = tiempoFinal;
			}
		}
		return oportunidad;
	}
	*/

	private static void identificarPorNumPerso(CC_Llamada__c llamada, String numPerso) {
		//Realizamos una búsqueda para informar el contacto y la cuenta
		if (!String.isEmpty(numPerso)) {
			Boolean identificarConAlf = false;
			if (!Test.isRunningTest()) {
				List<CSBD_Identificacion_ALF__mdt> mdt = [SELECT Id FROM CSBD_Identificacion_ALF__mdt
															WHERE CSBD_Identificacion_ALF_Activa__c = TRUE LIMIT 1];
				identificarConAlf = !mdt.isEmpty();
			}

			if (identificarConAlf) {
				List<Contact> contactos = new List<Contact>();
				Map<String, Object> mapaCuentasContactos = CC_IdentCliente_Future.getIdentificacionALF('NP', numPerso);
				List<Account> cuentas = (List<Account>)mapaCuentasContactos.get('CUENTAS');
				if (cuentas.size() == 1) {
					// Cambio para añadir representantes.
					if (mapaCuentasContactos.containsKey('REPRESENTANTES')) {
						contactos = (List<Contact>)mapaCuentasContactos.get('REPRESENTANTES');
						if (contactos.size() == 1) {
							llamada.CC_Cuenta__c = cuentas[0].Id;
							llamada.CC_Contacto__c = contactos[0].Id;
							llamada.CC_IdentCliente__c = '1'; // Alfabético automático
						}
					} else if (mapaCuentasContactos.containsKey('CONTACTOS')) {
						contactos = (List<Contact>)mapaCuentasContactos.get('CONTACTOS');
						if (contactos.size() == 1) {
							llamada.CC_Cuenta__c = cuentas[0].Id;
							llamada.CC_Contacto__c = contactos[0].Id;
							llamada.CC_IdentCliente__c = '1'; // Alfabético automático
						}
					}
				}
			} else {
				//Identificación contra BD
				List<Contact> contactos = [SELECT AccountId FROM Contact WHERE CC_NumPerso__c = :numPerso
											AND (RecordType.DeveloperName = 'CC_Cliente' OR Account.RecordType.DeveloperName = 'CC_ClientePA') LIMIT 2];
				if (contactos.size() == 1) {
					llamada.CC_Cuenta__c = contactos[0].AccountId;
					llamada.CC_Contacto__c = contactos[0].Id;
					llamada.CC_IdentCliente__c = '0'; //Sin datos ALF
				}
			}
		}
	}

	private static Id crearActividad(CC_Llamada__c llamada, Id idOportunidad, String tipoActividad, String detalle) {
		// CC_Llamada__c llamada = [SELECT CC_Contacto__c, CC_Tipo_Cierre__c FROM CC_Llamada__c WHERE Id = :llamada.Id];
		Task actividad = new Task(
			RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSBD_Task').getRecordTypeId(),
			WhatId = idOportunidad,
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
											AND CC_Extension__c = :jsonLlamada.extension AND CC_Fecha_Fin__c = NULL LIMIT 2];
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

					Integer duracionMinutos = (Integer)((CBK_UtilsDate.nowSYS().getTime() - actividad.CC_Fecha_Inicio__c.getTime()) / (1000));
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

	private static String codigoIdioma(String idioma) {
		return 'Inglés'.equals(idioma) ? 'en' : ('Catalán'.equals(idioma) ? 'ca' : 'es');
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

	private static Opportunity contadorLlamadasSalientes(CC_Llamada__c llamada, Opportunity oportunidad){
		oportunidad.CSBD_Llamadas_Salientes__c = [SELECT COUNT() FROM Task WHERE WhatId = :oportunidad.Id AND Type = 'Llamada saliente'];
		return oportunidad;
	}
}