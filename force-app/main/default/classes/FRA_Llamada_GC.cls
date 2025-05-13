public with sharing class FRA_Llamada_GC {

	public static Map<String, Object> registrarLlamadaEntrante(CC_Llamada_Input inputLlamada) {
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c
												  FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :identificarCodigoCola(inputLlamada.servicio) LIMIT 1];
		Case casoVinculado;
		Boolean llamadaEmpleado = false;
		Boolean llamadaCC = !String.isEmpty(inputLlamada.asunto) ? true : false;

		CC_Llamada__c llamada = new CC_Llamada__c(
			KIN_Genesys_Cloud__c = true,
			KIN_Llamada_Origen__c = true,
			CC_Tipo__c = String.isBlank(inputLlamada.nombreCampana) ? 'Entrante' : 'Saliente',
			CC_ConnId__c = inputLlamada.connId,
			CC_ANI__c = inputLlamada.ani,
			CC_DNIS__c = inputLlamada.dnis,
			CC_Servicio_Genesys__c = servicioGenesys.Id,
			CC_Idioma__c = identificarIdiomaCola(inputLlamada.servicio),
			CC_Asunto__c = 'Llamada Entrante',
			CC_No_Identificado__c = false,
			CC_Fecha_Inicio__c = System.now(),
			CC_IdentCliente__c = '0',  //Sin datos ALF
			KIN_Genesys_Cloud_URL_Grabacion__c = inputLlamada.urlGrabacion,
			RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'FRA_Cliente')
		);

		// if (!esCallCenter(inputLlamada.servicio)) {
			//llamadaEmpleado = identificarPorTelefono(llamada, inputLlamada.ani, llamadaCC);
			Map<String, Object> resultado = identificarPorTelefono(llamada, inputLlamada.ani, llamadaCC);
			llamadaEmpleado = (Boolean)resultado.get('Empleado');
			Case casoContactCenter = (Case)resultado.get('Caso');

		// }


        finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
		insert llamada;
		casoVinculado = crearVincularCaso(llamada, llamadaEmpleado, llamadaCC,casoContactCenter);		
		return new Map<String, Object>{'llamada' => llamada, 'caso' => casoVinculado, 'encuestaId' => null};
	}

	public static Map<String, Object> registrarLlamadaSaliente(CC_Llamada_Input inputLlamada) {
		finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
		CC_Llamada__c llamada;
		if (!String.isEmpty(inputLlamada.casoId)) {
            Case caso = [SELECT CC_Canal_Procedencia__c, CC_Canal_Resolucion__c, Subject, CC_Idioma__c, AccountId, ContactId, CC_No_Identificado__c, RecordType.DeveloperName, CC_Oficina__c, CC_ContactoRelacionado__c
                		 FROM Case WHERE Id = :inputLlamada.casoId];
            CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c
                									  FROM CC_Servicio_Genesys__c WHERE CC_Canal_Procedencia__c = :caso.CC_Canal_Procedencia__c LIMIT 1];

            llamada = new CC_Llamada__c (
				KIN_Genesys_Cloud__c = true,
				KIN_Llamada_Origen__c = true,	
				CC_Tipo__c = 'Saliente',
				CC_Servicio_Genesys__c = servicioGenesys.Id,
				CC_ConnId__c = inputLlamada.connId,
				CC_DNIS__c = inputLlamada.dnis,
				CC_Idioma__c = caso.CC_Idioma__c,
				CC_Asunto__c = 'Llamada Saliente caso',
				CC_Cuenta__c = caso.AccountId != null ? caso.AccountId : caso.CC_Oficina__c,
				CC_Contacto__c = caso.ContactId != null ? caso.ContactId : caso.CC_ContactoRelacionado__c,
				CC_No_Identificado__c = caso.CC_No_Identificado__c,
				CC_Fecha_Inicio__c = System.now(),
				CC_Servicio_Llamada_Saliente__c  = caso.CC_Canal_Resolucion__c,
				RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'FRA_Cliente'),
				KIN_Genesys_Cloud_URL_Grabacion__c = inputLlamada.urlGrabacion,
				CC_IdentCliente__c = '0' // Sin datos ALF);
            );

            insert llamada;
            crearActividad(llamada.Id, inputLlamada.casoId, 'Llamada saliente', null, null);
        } else {
			if (!String.isEmpty(inputLlamada.servicio)) {
				CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c
				FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :identificarCodigoCola(inputLlamada.servicio) LIMIT 1];
				
				llamada = new CC_Llamada__c(
					KIN_Genesys_Cloud__c = true,
					KIN_Llamada_Origen__c = true,
					CC_Tipo__c = 'Saliente',
					CC_ConnId__c = inputLlamada.connId,
					CC_ANI__c = '',
					CC_DNIS__c = inputLlamada.dnis,
					CC_Servicio_Genesys__c = servicioGenesys.Id,
					CC_Idioma__c = identificarIdiomaCola(inputLlamada.servicio),
					CC_Asunto__c = 'Llamada Saliente',
					CC_No_Identificado__c = false,
					CC_Fecha_Inicio__c = System.now()
				);
		
				llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'FRA_Cliente');
				insert llamada;
				crearActividad(llamada.Id, inputLlamada.casoId, 'Llamada saliente', null, null);
			} else {
				llamada = new CC_Llamada__c(
					KIN_Genesys_Cloud__c = true,
					KIN_Llamada_Origen__c = true,
					CC_Tipo__c = 'Saliente',
					CC_ConnId__c = inputLlamada.connId,
					CC_ANI__c = '',
					CC_DNIS__c = inputLlamada.dnis,
					CC_Asunto__c = 'Llamada Saliente',
					CC_No_Identificado__c = false,
					CC_Fecha_Inicio__c = System.now()
				);
		
				llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'FRA_Cliente');
				insert llamada;
				crearActividad(llamada.Id, inputLlamada.casoId, 'Llamada saliente', null, null);
			}
		}
		return new Map<String, Object>{'llamada' => llamada};
	}

	public static Map<String, Object> registrarConsulta(CC_Llamada_Input inputConsulta, String servicioGen) {
		finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c 
												  FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :identificarCodigoCola(inputConsulta.servicio) LIMIT 1];
		CC_Llamada__c llamada = [SELECT CC_Idioma__c, CC_Contacto__c, CC_Cuenta__c, CC_Cuenta__r.CC_OficinaGestoraId__c, CC_No_Identificado__c, OwnerId, CC_IdentCliente__c, RecordTypeId
								 FROM CC_Llamada__c WHERE Id = :inputConsulta.salesforceParentId];
		Case caso = [SELECT Subject, CC_Idioma__c, AccountId, ContactId FROM Case WHERE Id = :inputConsulta.casoId];
	
        if(String.isNotBlank(servicioGen)){
            caso.FRA_Servicio_Contact_Center__c = servicioGen;
			caso.CC_Canal_Contacto__c='FRA_Call Center';
        	update caso;
        }
	
		CC_Llamada__c consulta = new CC_Llamada__c (
			RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'FRA_Cliente'),
			KIN_Genesys_Cloud__c = true,
			KIN_Consulta__c = true,
			CC_Tipo__c = 'Entrante',
			CC_Agente__c = [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()].EmployeeNumber,
			CC_ConnId__c = null,
			CC_ConnId_Consulta__c = inputConsulta.connId,
			CC_ANI__c = inputConsulta.ani,
			CC_DNIS__c = inputConsulta.dnis,
			CC_Servicio_Genesys__c = servicioGenesys.Id,
			CC_Asunto__c = caso.Subject,
			CC_Case_Consulta__c = caso.Id,
			CC_Llamada_Padre__c = llamada.Id,
			CC_Idioma__c = identificarIdiomaCola(inputConsulta.servicio),
			CC_Contacto__c = llamada.CC_Contacto__c,
			CC_Cuenta__c = llamada.CC_Cuenta__c,
			CC_No_Identificado__c = llamada.CC_No_Identificado__c,
			CC_Fecha_Inicio__c = System.now(),
			CC_IdentCliente__c = llamada.CC_IdentCliente__c
		);
		
		insert consulta;

		crearActividad(consulta.Id, caso.Id, 'Consulta', servicioGenesys.Name, null);
		return new Map<String, Object>{'llamada' => consulta, 'caso' => caso};
	}

	public static Map<String, Object> registrarblindTransfer(CC_Llamada_Input inputConsulta, String servicioGen) {
		finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c, CC_Canal_Procedencia__c 
												  FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :identificarCodigoCola(inputConsulta.servicio) LIMIT 1];
		CC_Llamada__c llamada = [SELECT CC_Idioma__c, CC_Contacto__c, CC_Cuenta__c, CC_Cuenta__r.CC_OficinaGestoraId__c, CC_No_Identificado__c, OwnerId, CC_IdentCliente__c, RecordTypeId
								 FROM CC_Llamada__c WHERE Id = :inputConsulta.salesforceParentId];
		Case caso = [SELECT Subject, CC_Idioma__c, AccountId, ContactId FROM Case WHERE Id = :inputConsulta.casoId];
	
        if(String.isNotBlank(servicioGen)){
            caso.FRA_Servicio_Contact_Center__c = servicioGen;
			caso.CC_Canal_Contacto__c='FRA_Call Center'; 
        	update caso;
        }
	
		CC_Llamada__c consulta = new CC_Llamada__c (
			RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'FRA_Cliente'),
			KIN_Genesys_Cloud__c = true,
			KIN_Consulta__c = true,
			CC_Tipo__c = 'Entrante',
			CC_Agente__c = [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()].EmployeeNumber,
			CC_ConnId__c = null,
			CC_ConnId_Consulta__c = inputConsulta.connId,
			CC_ANI__c = inputConsulta.ani,
			CC_DNIS__c = inputConsulta.dnis,
			CC_Servicio_Genesys__c = servicioGenesys.Id,
			CC_Asunto__c = caso.Subject,
			CC_Case_Consulta__c = caso.Id,
			CC_Llamada_Padre__c = llamada.Id,
			CC_Idioma__c = identificarIdiomaCola(inputConsulta.servicio),
			CC_Contacto__c = llamada.CC_Contacto__c,
			CC_Cuenta__c = llamada.CC_Cuenta__c,
			CC_No_Identificado__c = llamada.CC_No_Identificado__c,
			CC_Fecha_Inicio__c = System.now(),
			CC_IdentCliente__c = llamada.CC_IdentCliente__c
		);
		insert consulta;
		crearActividad(consulta.Id, caso.Id, 'Llamada transferencia Ciega', servicioGenesys.Name, null);
		actualizarCaso(caso.Id, UserInfo.getUserId(), servicioGenesys.CC_Canal_Procedencia__c);
		return new Map<String, Object>{'llamada' => consulta, 'caso' => caso};
	}

	/** Cuando no nos llega el Id de llamada, lo buscamos por connId, usuario y extensión */
	public static String buscarLlamada(CC_Llamada_Input jsonLlamada, Boolean esConsulta) {
		String resultado = jsonLlamada.llamadaId;
		if (String.isEmpty(resultado)) {
			Map<String, Object> queryBinds = new Map<String, Object> {
				'recordTypesLlamada' => new List<String>{'FRA_Cliente'},
				'interactionId' => jsonLlamada.connId,
				'numeroEmpleado' => [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()].EmployeeNumber,
				'esConsulta' => esConsulta
			};
			String queryString = 'SELECT Id FROM CC_Llamada__c WHERE RecordType.DeveloperName IN :recordTypesLlamada';
			queryString += ' AND ' + (esConsulta ? 'CC_ConnId_Consulta__c' : 'CC_ConnId__c') + ' = :interactionId';
			queryString += ' AND CC_Agente__c = :numeroEmpleado AND KIN_Consulta__c = :esConsulta AND CC_Fecha_Fin__c = NULL';

			List<CC_Llamada__c> llamadas = Database.queryWithBinds(queryString, queryBinds, AccessLevel.USER_MODE);
			if (llamadas.size() == 1) {
				resultado = llamadas[0].Id;
			}
		}
		return resultado;
	}

	public static void registrarACW(CC_Llamada_Input inputLlamada) {
		finalizarLlamadasActividadesAbiertas(UserInfo.getUserId());
	}

	public static void finalizarLlamada(CC_Llamada_Input inputLlamada, String tipoCierre) {
		String llamadaId = buscarLlamada(inputLlamada, false);
		if (String.isNotBlank(llamadaId)) {
			finalizarLlamadaActividades(new CC_Llamada__c(Id = llamadaId), 'Llamada%', tipoCierre != '' ? tipoCierre : 'Llamada finalizada');
		}
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
		crearActividad(inputConsulta.salesforceParentId, inputConsulta.casoId, 'Llamada transferida', 'externo', 'Llamada transferida');
		String llamadaId = buscarLlamada(inputConsulta, false);
		if (String.isNotBlank(llamadaId)) {
			finalizarLlamadaActividades(new CC_Llamada__c(Id = llamadaId), 'Llamada%', 'Llamada finalizada');
		}
	}

	public static void iniciarTransferenciaCiega(CC_Llamada_Input inputConsulta, String tipoCierre) {
		crearActividad(inputConsulta.salesforceParentId, inputConsulta.casoId, 'Llamada transferencia Ciega', 'Iniciada', 'Llamada transferida');
	}

	public static void completarConsulta(String connIdConsulta, Id idNuevoOwner) {
		CC_Llamada__c consulta = [SELECT CC_ConnId_Consulta__c, CC_Llamada_Padre__c, CC_Case_Consulta__c,
								  CC_Servicio_Genesys__r.CC_Canal_Procedencia__c
								  FROM CC_Llamada__c WHERE RecordType.DeveloperName = 'FRA_Cliente'
								  AND CC_ConnId_Consulta__c = :connIdConsulta AND CC_Fecha_Fin__c = NULL
								  AND OwnerId = :idNuevoOwner AND KIN_Consulta__c = TRUE];
		consulta.CC_ConnId__c = consulta.CC_ConnId_Consulta__c;
		update consulta;
		finalizarActividadesLlamada(consulta, 'Consulta%', 'Consulta completada');
		// finalizarActividades(consulta, 'Consulta%', 'Consulta completada');

		CC_Llamada__c llamadaCliente = [SELECT CC_Servicio_Genesys__r.Name FROM CC_Llamada__c WHERE Id = :consulta.CC_Llamada_Padre__c];
		
		crearActividad(consulta.Id, consulta.CC_Case_Consulta__c, 'Llamada transferida', llamadaCliente != null ? llamadaCliente.CC_Servicio_Genesys__r.Name : 'externo', 'Llamada transferida');
		actualizarCaso(consulta.CC_Case_Consulta__c, idNuevoOwner, consulta.CC_Servicio_Genesys__r.CC_Canal_Procedencia__c);
		//Cierre de la llamada con el cliente
		finalizarLlamadaActividades(llamadaCliente, 'Llamada%', 'Llamada finalizada');
	}

	public static Case crearVincularCaso(CC_Llamada__c llamada, Boolean llamadaEmpleado, Boolean llamadaCC,Case casoContactCenter) {
		CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Canal_de_Entrada__c,CC_Activo_Salesforce__c, CC_Tipo__c, CC_Tipo_Cliente__c
													FROM CC_Servicio_Genesys__c WHERE Id = :llamada.CC_Servicio_Genesys__c];
		Case caso = crearCaso(llamada, servicioGenesys, llamadaEmpleado, llamadaCC,casoContactCenter);
		vincularCaso(caso, llamada, servicioGenesys);
		return [SELECT CaseNumber, Status, Owner.Name, CreatedDate, Subject FROM Case WHERE Id = :caso.Id];
	}

	public static Case crearCaso(CC_Llamada__c llamada, CC_Servicio_Genesys__c servicioGenesys, Boolean llamadaEmpleado, Boolean llamadaCC,Case casoContactCenter) {
		Case caso = new Case(
			RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente'),
			//Subject = llamada.CC_Asunto__c,
            //Origin = servicioGenesys.CC_Canal_de_Entrada__c == 'Telefono' ? 'Phone' : String.isBlank(servicioGenesys.CC_Canal_de_Entrada__c) ? 'Phone' : servicioGenesys.CC_Canal_de_Entrada__c,
			FRA_Origen_Creacion__c = 'Llamada',
			CC_Canal_Respuesta__c = 'Phone',
			CC_Telefono_Contacto__c = llamada.CC_ANI__c,
			CC_No_Identificado__c = llamada.CC_No_Identificado__c,
			CC_Canal_Procedencia__c = servicioGenesys.CC_Canal_Procedencia__c,
			CC_Canal_Resolucion__c = servicioGenesys.CC_Canal_Procedencia__c,
			//CC_Idioma__c = llamada.CC_Idioma__c,
			CC_IdentCliente__c = llamada.CC_IdentCliente__c,
			Subject = casoContactCenter.Subject,
			Description = casoContactCenter.Description,
			CC_Idioma__c = casoContactCenter.CC_Idioma__c,
			CC_Tipo_Contacto__c = casoContactCenter.CC_Tipo_Contacto__c,
			Origin = casoContactCenter.Origin,
			CC_Detalles_Consulta__c = casoContactCenter.CC_Detalles_Consulta__c,
			CC_Detalles_Solucion__c = casoContactCenter.CC_Detalles_Solucion__c,
			CC_ContactoRelacionado__c = casoContactCenter.CC_ContactoRelacionado__c,
			CC_Oficina__c = casoContactCenter.CC_Oficina__c,
			CC_CasoRelacionado__c = casoContactCenter.Id,
			Comments = casoContactCenter.Comments
		);

		// Si es un empleado pone el Contacto y la Cuenta en Contacto relacionado y Oficina
		if(llamadaEmpleado) {
			caso.CC_ContactoRelacionado__c = llamada.CC_Contacto__c != null ? llamada.CC_Contacto__c : null ;
			caso.CC_Oficina__c = llamada.CC_Cuenta__c != null ? llamada.CC_Cuenta__c : null;
			caso.CC_Canal_Contacto__c='FRA_Oficina';
		}else {
			caso.ContactId = llamada.CC_Contacto__c != null ? llamada.CC_Contacto__c : null;
			caso.AccountId = llamada.CC_Cuenta__c != null ? llamada.CC_Cuenta__c : null;	
			if(llamadaCC){
				caso.CC_Canal_Contacto__c='FRA_Call Center';
			}else{
				caso.CC_Canal_Contacto__c = caso.CC_Canal_Procedencia__c =='Teléfono FRAUDE Tarjetas Consumer' ? 'FRA_Cliente Consumer' : 'FRA_Cliente cbk';		
			}
		}
	
		if (servicioGenesys.CC_Tipo_Cliente__c == 'Cliente')
        {
			caso.CC_Tipo_Cliente__c = 'Cliente';
		} else {
			caso.CC_Tipo_Cliente__c = 'Empleado';
		}

		insert caso;
        return caso;
	}

	private static Case buscarCasoCC (String connId) {
		Case casoCC = new Case();
		if(!String.isEmpty(connId)){
		Id caso = [SELECT WhatId FROM Task WHERE RecordType.DeveloperName = 'CC_Task' and CC_Llamada_Id__r.CC_ConnId__c = :connId]?.WhatId;
		//casoCC = [SELECT Id, AccountId, ContactId FROM Case WHERE Id = :caso LIMIT 1];
		casoCC = [SELECT Id, AccountId, ContactId,Subject,Description,CC_Idioma__c,CC_Tipo_Contacto__c,Origin,CC_Detalles_Consulta__c,CC_Detalles_Solucion__c,
				  CC_ContactoRelacionado__c,CC_Oficina__c,CaseNumber,Comments,CC_CasoRelacionado__c
		 		  FROM Case WHERE Id = :caso LIMIT 1];
		}
		return casoCC;
	}

	public static void vincularCaso(Case caso, CC_Llamada__c llamada, CC_Servicio_Genesys__c servicioGenesys) {
		String tipoActividad;
		if (llamada.CC_ConnId__c == null) { //Si es una consulta
			tipoActividad = 'Consulta';
		} else {
			tipoActividad = llamada.CC_Tipo__c.equals('Saliente') ? 'Llamada saliente' : 'Llamada entrante';
		}
		crearActividadFuture(llamada.Id, caso.Id, tipoActividad, servicioGenesys.Name);
	}

	// Devuelve true si es empleado
	//public static Boolean identificarPorTelefono(CC_Llamada__c llamada, String telefono, Boolean llamadaCC) {
	public static Map<String, Object> identificarPorTelefono(CC_Llamada__c llamada, String telefono, Boolean llamadaCC) {
		Case casoCC = null;
		Boolean empleado = false;
		List<String> telefonos = new List<String>();
		telefonos.add(telefono.replace('+34', ''));
		telefonos.add(telefono.replace('+34', '34 '));
		
		if(llamadaCC){
			casoCC = buscarCasoCC(llamada.CC_ConnId__c);
			llamada.CC_Cuenta__c = casoCC.AccountId != null ? casoCC.AccountId : null;
			llamada.CC_Contacto__c = casoCC.ContactId != null ? casoCC.ContactId : null;
		}

		if(!String.isEmpty(telefono) && ((!llamadaCC) || (llamadaCC && (casoCC.AccountId == null || casoCC.ContactId == null)))){
			//Busca los canales de comunicación por el teléfono
				List<CC_Canal_Com__c> oCanales = [SELECT CC_ContactoId__c, CC_CuentaId__c, CC_ContactoId__r.RecordType.DeveloperName FROM CC_Canal_Com__c 
													WHERE CC_Telefono__c IN :telefonos AND RecordType.DeveloperName = 'CC_Telefono'];
			Set<String> oIDs = new Set<String>();
        	for (CC_Canal_Com__c oCanal : oCanales) {
            	if (oCanal.CC_CuentaId__c != null) {
					oIDs.add(oCanal.CC_CuentaId__c);
				}
        	}
			//Busca las cuentas de RT CC_Cliente y CC_ClientePA que se encuentra en la consulta anterior
			List<Account> oCuentas = [SELECT Id, Name, RecordType.DeveloperName FROM Account 
									  WHERE Id = :oIDs AND (RecordType.DeveloperName = 'CC_Cliente' OR RecordType.DeveloperName = 'CC_ClientePA' OR RecordType.DeveloperName = 'CC_CentroCaixaBank')];
			if (!oCuentas.isEmpty()) {
				Id accountCuenta = oCuentas[0].Id;
				llamada.CC_Cuenta__c = accountCuenta;
				String cuentaRT = oCuentas[0].RecordType.DeveloperName;
				if (cuentaRT == 'CC_CentroCaixaBank') {
					empleado = true;
				}
				Id contactCanal = oCanales[0].CC_ContactoId__c;
				llamada.CC_Contacto__c = contactCanal;
			}
		}
		//return empleado;
		return new Map<String, Object>{
			'Empleado' => empleado,
			'Caso' => casoCC
		};
	}

	private static String obtenerTipoCierre(String tipoCierre) {
		for (Schema.PicklistEntry tipo : CC_Llamada__c.CC_Tipo_Cierre__c.getDescribe().getPicklistValues()) {
			if (tipo.getValue().equals(tipoCierre)) {
				return tipo.getLabel();
			}
		}
		return tipoCierre;
	}
	public static void finalizarActividadesLlamada(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
		finalizarActividadesLlamada(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
	}
	
	public static void finalizarActividadesLlamada(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
		if (llamadas.isEmpty()) {
			return;
		}
		List<Task> tareas = [SELECT Id FROM Task WHERE CC_Llamada_Id__c IN :CC_MetodosUtiles.listaCampo(llamadas, 'Id')
								AND Status = 'Open' AND Type LIKE :tipoActividad AND RecordType.DeveloperName = 'FRA_Task'];
		for (Task actividad : tareas) {
			actividad.CC_Fecha_Fin__c = System.now();
			actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
			actividad.Status = 'Completed';
		}
		update tareas;
	}

	private static void finalizarActividades(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
		finalizarActividades(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
	}

	private static void finalizarActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
		List<Id> llamadaIds = new List<Id>();
		for (CC_Llamada__c llamada : llamadas) {
			llamadaIds.add(llamada.Id);
		}

		if (llamadaIds.isEmpty()) {
			return;
		}

		List<Task> actividades = [SELECT Id FROM Task WHERE CC_Llamada_Id__c IN :llamadaIds AND Status = 'Open' AND Type LIKE :tipoActividad
		AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task')];

		for (Task actividad : actividades) {
			actividad.CC_Fecha_Fin__c = System.now();
			actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
			actividad.Status = 'Completed';
		}

		if (!actividades.isEmpty()) {
			update actividades;
		}
	}

	public static void finalizarActividadesNew(List<CC_Llamada__c> llamadas) {
		if (!llamadas.isEmpty()) {
			List<Task> actividadesActualizar = new List<Task>();

			List<Id> llamadaIds = new List<Id>();
			for (CC_Llamada__c llamada : llamadas) {
				llamadaIds.add(llamada.Id);
			}

			for (Task actividad : [SELECT Type FROM Task WHERE CC_Llamada_Id__c IN :llamadaIds AND Status = 'Open'
								   AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task')]) {
				actividad.CC_Fecha_Fin__c = System.now();
				actividad.CC_Tipo_Cierre__c = obtenerTipoCierre('Llamada finalizada');
				actividad.Status = 'Completed';
				actividadesActualizar.add(actividad);
			}
			if (!actividadesActualizar.isEmpty()) {
				update actividadesActualizar;
			}
		}
	}

	public static void finalizarLlamadaActividades(CC_Llamada__c llamada, String tipoActividad, String tipoCierre) {
		finalizarLlamadasActividades(new List<CC_Llamada__c>{llamada}, tipoActividad, tipoCierre);
	}

	public static void finalizarLlamadas(List<CC_Llamada__c> llamadas, String tipoCierre) {
		for (CC_Llamada__c llamada : llamadas) {
			llamada.CC_Fecha_Fin__c = System.now();
			llamada.CC_Tipo_Cierre__c = tipoCierre;
		}

		if (!llamadas.isEmpty()) {
			update llamadas;
		}
	}

	private static void finalizarLlamadasActividades(List<CC_Llamada__c> llamadas, String tipoActividad, String tipoCierre) {
		if (!llamadas.isEmpty()) {
			finalizarLlamadas(llamadas, tipoCierre);
			finalizarActividades(llamadas, tipoActividad, tipoCierre);
		}
	}

	private static void finalizarLlamadasActividadesAbiertas(Id userId) {
		List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c WHERE RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'FRA_Cliente') AND CC_Fecha_Fin__c = NULL AND OwnerId = :userId];
		finalizarLlamadas(llamadas, 'Llamada finalizada');
		finalizarActividadesNew(llamadas);
	}

	public static Task crearObjetoActividad(Id llamadaId, Id casoId, String tipoActividad, String detalle, String tipoCierre) {
		Task actividad = new Task(
			RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task'),
			Subject = tipoActividad + (detalle != null ? ' (' + detalle + ')' : ''),
			CC_Llamada_Id__c = llamadaId,
			ActivityDate = System.today(),
			CC_Fecha_Inicio__c = System.now(),
			WhatId = casoId,
			Type = tipoActividad
		);

		if (tipoCierre != null) {
			actividad.CC_Fecha_Fin__c = System.now();
			actividad.CC_Tipo_Cierre__c = obtenerTipoCierre(tipoCierre);
			actividad.Status = 'Completed';
		}
		return actividad;
	}

	public static Id crearActividad(Id llamadaId, Id casoId, String tipoActividad, String detalle, String tipoCierre) {
		Task actividad = crearObjetoActividad(llamadaId, casoId, tipoActividad, detalle, tipoCierre);
		insert actividad;
		return actividad.Id;
	}

	@future
	private static void crearActividadFuture(Id llamadaId, Id casoId, String tipoActividad, String telefono) {
		crearActividad(llamadaId, casoId, tipoActividad, telefono, null);
	}

	public static String identificarIdiomaCola(String codigo) {
		return codigo.endsWithIgnoreCase('ING') ? 'en' : (codigo.endsWithIgnoreCase('CAT') ? 'ca' : (codigo.endsWithIgnoreCase('CAS') ? 'es' : 'es'));
	}

	private static Boolean esCallCenter(String codigo) {
		return codigo.contains('_CC_') ? true : false;
	}

	private static String identificarCodigoCola(String codigo) {
		List<String> parts = codigo.split('_ISOC_');
	    return parts.size()>=2 ? parts[parts.size()-2] : codigo;
	}

	public static void actualizarCaso(Id casoId, Id propietarioId, String canalResolucion) {
		Case caso = new Case(
		Id = casoId,
		CC_Canal_Resolucion__c = canalResolucion,
		OwnerId = propietarioId
		);
		update caso;
	}
}