@isTest
public class CSBD_Llamada_GC_Test {

	@TestSetup
	private static void testSetup() {

		User usuarioAdmin = [SELECT Id FROM User WHERE Profile.Name LIKE 'System Administrator' AND IsActive = TRUE LIMIT 1];
		User gestorCsbd;

		System.runAs(usuarioAdmin) {

			CSBD_LlamadaSettings__c llamadaSettings = new CSBD_LlamadaSettings__c();
			llamadaSettings.CSBD_EntranteCrearSiempreOportunidad__c = true;
			insert llamadaSettings;

            User gestor = new User();
            gestor.LastName = 'Gestor CSBD Test';
            gestor.Alias = 'gestor';
            gestor.Email = 'gestorcsbd@caixabank.com.invalid';
            gestor.Username = 'gestorcsbd_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
            gestor.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSBD Gestor'].Id;
            gestor.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'CSBD_Generico'].Id;
            gestor.EmailEncodingkey = 'ISO-8859-1';
            gestor.LanguageLocaleKey = 'es';
            gestor.LocalesIdKey = 'es';
            gestor.TimezonesIdKey = 'Europe/Madrid';
            insert gestor;

            PermissionSet psGestorCsbd = [SELECT Id FROM PermissionSet WHERE Name = 'CSBD_PS_Gestor'];
            insert new PermissionSetAssignment(PermissionSetId = psGestorCsbd.id, AssigneeId = gestor.Id);

			gestorCsbd = gestor;

			Id idRtServicioGenesys = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();
			CC_Servicio_Genesys__c s1 = new CC_Servicio_Genesys__c();
			s1.RecordTypeId = idRtServicioGenesys;
			s1.CBK_Negocio__c = 'CSBD';
			s1.CC_Tipo__C = 'Servicio';
			s1.Name = 'Servicio entrante';
			s1.CC_Codigo__c = 'S1';
			s1.CC_VDN__c = '4444444';
			s1.CC_Prefijo__c = '0';
			s1.CC_Tipo_Cliente__c = 'Cliente';
			s1.CC_Fecha_Inicio_Salesforce__c = Date.today();
			s1.CC_Principal__c = true;
			CC_Servicio_Genesys__c s2 = new CC_Servicio_Genesys__c();
			s2.RecordTypeId = idRtServicioGenesys;
			s2.CBK_Negocio__c = 'CSBD';
			s2.CC_Tipo__C = 'Servicio';
			s2.Name = 'NIS Genesys Cloud Saliente Por Defecto';
			s2.CC_Codigo__c = 'NIS_GenesysCloudOutboundDefault';
			s2.CC_VDN__c = '4444444';
			s2.CC_Prefijo__c = '0';
			s2.CC_Tipo_Cliente__c = 'Cliente';
			s2.CC_Fecha_Inicio_Salesforce__c = Date.today();
			s2.CC_Principal__c = true;
			insert new List<CC_Servicio_Genesys__c>{s1, s2};

			Account oficinaGestora = new Account();
			oficinaGestora.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
			oficinaGestora.CC_Numero_Empresa__c = '001';
			oficinaGestora.CC_Numero_Oficina__c = '00001';
			oficinaGestora.CC_Numero_Oficina_Empresa__c = '001-00001';
			oficinaGestora.Name = 'Oficina gestora Test';
			oficinaGestora.CC_Tipo_Centro__c = 'OF';
			oficinaGestora.CC_Email__c = 'test@test.com';

			Account cuenta = new Account();
			cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			cuenta.Name = 'Cuenta Test';
			cuenta.CC_NumPerso__c = 'TestNumPer54321';
			cuenta.CC_OficinaGestoraId__c = oficinaGestora.Id;
			cuenta.AV_OficinaPrincipal__c = oficinaGestora.Id;

			insert new List<Account>{oficinaGestora, cuenta};

			Contact c = new Contact();
            c.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
            c.Email = 'test@test.com';
            c.LastName = 'test@test.com';
            c.AccountId = cuenta.Id;
            c.CC_NumPerso__c = 'TestNumPer54321';
            c.CC_Numero_Documento__c = '12312312K';
            insert c;

            CC_Servicio_Genesys__c svcEncuesta = new CC_Servicio_Genesys__c();
			svcEncuesta.RecordTypeId = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Encuesta').getRecordTypeId();
			svcEncuesta.Name = 'Servicio Encuesta';
			svcEncuesta.CC_Codigo__c = 'Servicio Encuesta';
			svcEncuesta.CC_VDN__c = '555555555';
            svcEncuesta.CC_Canal_Procedencia__c = 'CaixabankNow';
            svcEncuesta.CC_Fecha_Inicio_Salesforce__c = Date.newInstance(2023, 11, 3);
			insert svcEncuesta;

            CC_Lista_Valores__c listaValores4 = new CC_Lista_Valores__c();
			listaValores4.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
			listaValores4.Name = 'CSBD: Horarios comerciales por tipología SLA';
			listaValores4.CC_Activa__c = true;
			insert listaValores4;

            CC_Lista_Valores__c valor4 = new CC_Lista_Valores__c();
            valor4.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor4.CC_Lista__c = listaValores4.Id;
            valor4.CC_Valor__c = 'CSBD: Horario comercial Hipoteca SLA';
            valor4.Name = 'CSBD_Hipoteca';
            insert valor4;

        }

		System.runAs(gestorCsbd) {
			Map<String, Object> camposOportunidad = new Map<String, Object>{'CSBD_Titulo__c' => 'Oportunidad Test'};
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_CMB', camposOportunidad);
		}

        System.runAs(gestorCsbd) {
			Map<String, Object> camposOportunidad = new Map<String, Object>{'CSBD_Titulo__c' => 'Oportunidad Test 2'};
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', camposOportunidad);
		}
	}

	private static CC_Llamada_Input obtenerInputLlamada(String servicio, String llamadaId, String casoId) {
		CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = 'Usuario test';
        input.connId = 'pruebaConId123456789Test';
        input.ani = '555555555';
        input.dnis = '666666666';
        input.servicio = servicio;
        input.asunto = 'Asunto';
        input.numperso = '666';
        input.idioma = 'Castellano';
        input.datos = 'Datos';
        input.connIdCognitivo = '87654321';
        input.casoId = casoId;
        input.salesforceParentId = null;
        input.statusAuto = 'APPROVED';
        input.perfil = 'EMPLEADOS';
        input.llamadaId = llamadaId;
        input.extension = 'Test';
        input.numPerso = 'TestNumPer54321';
        return input;
	}

	@isTest
	public static void cogerColgar() {
        User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];

		System.runAs(gestorCsbd) {
			CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = 'S1'];

			Test.startTest();
			//Entra la llamada
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(s1.CC_Codigo__c, '', '');
			Map<String, Object> retornoRegistrarLlamadaEntrante = CSBD_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamadaEntrante != null, 'La llamada no debería ser nula');

			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
			System.assert(actividad != null, 'La actividad no debería ser nula');
			inputLlamada.llamadaId = llamadaEntrante.Id;
			CSBD_Llamada_GC.finalizarLlamada(inputLlamada, 'Llamada finalizada');
			Test.stopTest();
		}
	}

	@isTest
	public static void llamarSalienteColgar() {
        User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];

		System.runAs(gestorCsbd) {
			Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];

			Test.startTest();
			//Realizar la llamada saliente
			CC_Llamada_Input inputLlamadaSaliente = obtenerInputLlamada(null, null, oportunidad.Id);
			Map<String, Object> responseRegistrarLlamadaSaliente = CSBD_Llamada_GC.registrarLlamadaSaliente(inputLlamadaSaliente);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)responseRegistrarLlamadaSaliente.get('llamada');

			inputLlamadaSaliente.llamadaId = llamadaSaliente.Id;
			CSBD_Llamada_GC.finalizarLlamada(inputLlamadaSaliente, 'Llamada finalizada');
			Test.stopTest();

			System.assert([SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaSaliente.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada'] != null, 'La llamada no debería ser nula');
		}
	}

	@isTest
	public static void iniciarLlamadaSalienteClickToDial() {
		User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];
		System.runAs(gestorCsbd) {
			Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];

			Test.startTest();
			CC_Llamada_Input inputLlamadaSaliente = obtenerInputLlamada(null, null, oportunidad.Id);
			Map<String, Object> responseRegistrarLlamadaSaliente = CSBD_Llamada_GC.registrarLlamadaSaliente(inputLlamadaSaliente);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)responseRegistrarLlamadaSaliente.get('llamada');
			inputLlamadaSaliente.llamadaId = llamadaSaliente.Id;
			Map<String, Object> responseIniciarLlamadaSalienteClickToDial = CSBD_Llamada_GC.iniciarLlamadaSalienteClickToDial(inputLlamadaSaliente);
			Test.stopTest();

			System.assert(responseIniciarLlamadaSalienteClickToDial.containsKey('llamada'), 'Debería retornarse la llamada creada');
		}
	}


    @isTest
	public static void llamarSalienteColgar2() {
        User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];

		System.runAs(gestorCsbd) {
			Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];
			oportunidad.CSBD_Horario_Contacto__c = '23:50 - 23:59';
            update oportunidad;
			Test.startTest();
			//Realizar la llamada saliente
			CC_Llamada_Input inputLlamadaSaliente = obtenerInputLlamada(null, null, oportunidad.Id);
			Map<String, Object> responseRegistrarLlamadaSaliente = CSBD_Llamada_GC.registrarLlamadaSaliente(inputLlamadaSaliente);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)responseRegistrarLlamadaSaliente.get('llamada');

			inputLlamadaSaliente.llamadaId = llamadaSaliente.Id;
			CSBD_Llamada_GC.finalizarLlamada(inputLlamadaSaliente, 'Llamada finalizada');
			Test.stopTest();

			System.assert([SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaSaliente.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada'] != null, 'La llamada no debería ser nula');
		}
	}


	@isTest
	public static void cerrarLlamadasAbiertas() {
        User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];
		System.runAs(gestorCsbd) {
			//Entra la llamada
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada('S1', '', '');
			Map<String, Object> responseRegistrarLlamadaEntrante1 = CSBD_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante1 = (CC_Llamada__c)responseRegistrarLlamadaEntrante1.get('llamada');

            Test.startTest();
			//Entra otra llamada
			Map<String, Object> responseRegistrarLlamadaEntrante2 = CSBD_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante2 = (CC_Llamada__c)responseRegistrarLlamadaEntrante2.get('llamada');
            Test.stopTest();

			List<Task> actividad2 = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante1.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(!actividad2.isEmpty(), 'La actividad no debería ser nula');
		}
	}

	@isTest
	public static void finalizarLlamada() {
        User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];
		System.runAs(gestorCsbd) {
            Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];
            oportunidad.CSBD_Horario_Contacto__c = '23:50 - 23:59';
            oportunidad.CSBD_Idioma_Solicitud__c = 'Catalán';
            update oportunidad;

			//Realizar la llamada saliente
			CC_Llamada_Input inputLlamadaSaliente = obtenerInputLlamada('KIN_GenesysCloudOutboundDefault', '', oportunidad.Id);
			Map<String, Object> responseRegistrarLlamadaSaliente = CSBD_Llamada_GC.registrarLlamadaSaliente(inputLlamadaSaliente);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)responseRegistrarLlamadaSaliente.get('llamada');
			inputLlamadaSaliente.llamadaId = llamadaSaliente.Id;
			Map<String, Object> responseIniciarLlamadaSalienteClickToDial = CSBD_Llamada_GC.iniciarLlamadaSalienteClickToDial(inputLlamadaSaliente);

			List<Task> tarea1 = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaSaliente.Id
									AND WhatId = :oportunidad.Id AND Type = 'Llamada saliente'
									AND Status = 'Open' LIMIT 1];
			Test.startTest();
			inputLlamadaSaliente.llamadaId = llamadaSaliente.Id;
			CSBD_Llamada_GC.finalizarLlamada(inputLlamadaSaliente, 'Llamada finalizada');
			Test.stopTest();

			List<Task> tarea2 = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaSaliente.Id
									AND WhatId = :oportunidad.Id AND Type = 'Llamada saliente'
									AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];

			System.assert(!tarea1.isEmpty(), 'La tarea no debería ser nula');
			System.assert(!tarea2.isEmpty(), 'La tarea no debería ser nula');

			llamadaSaliente = [SELECT CC_Fecha_Fin__c, CC_Tipo_Cierre__c FROM CC_Llamada__c WHERE Id = :llamadaSaliente.Id];
			System.assert(llamadaSaliente.CC_Fecha_Fin__c != null, 'La fecha de fin no debería ser nula');
			System.assertEquals('Llamada finalizada', llamadaSaliente.CC_Tipo_Cierre__c, 'El tipo de cierre no debería ser nulo');




            Opportunity oportunidad2 = [SELECT CreatedDate, CSBD_Horario_Contacto__c, CSBD_SLA_Primera_Respuesta__c, CSBD_PrimerContactoSLA__c, CSBD_SLA_TGT__c
										FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];
            String rangoFinal = Datetime.now().format('yyyy-MM-dd') + ' ' + oportunidad2.CSBD_Horario_Contacto__c.substring(7) + ':00';
            Datetime tiempoOrigen = Datetime.valueOf(rangoFinal);

            if(tiempoOrigen >= System.now()) {
                System.assert(oportunidad2.CSBD_SLA_Primera_Respuesta__c == 0, 'La primera respuesta no debería ser nula');
                System.assert(oportunidad2.CSBD_PrimerContactoSLA__c != null, 'El primer contacto no debería ser nulo');
                System.assert(oportunidad2.CSBD_SLA_TGT__c != null, 'El TGT no debería ser nulo');
            }
            if(tiempoOrigen < System.now()){
                System.assert(oportunidad2.CSBD_SLA_Primera_Respuesta__c != null, 'La primera respuesta no debería ser nula');
                System.assert(oportunidad2.CSBD_PrimerContactoSLA__c != null, 'El primer contacto no debería ser nulo');
                System.assert(oportunidad2.CSBD_SLA_TGT__c != null, 'El TGT no debería ser nulo');
            }

		}
	}

    @isTest
	public static void finalizarLlamada2() {
        User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];
		System.runAs(gestorCsbd) {
            Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test 2'];
            oportunidad.CSBD_Horario_Contacto__c = '23:50 - 23:59';
            update oportunidad;

			//Realizar la llamada saliente
			CC_Llamada_Input inputLlamadaSaliente = obtenerInputLlamada('KIN_GenesysCloudOutboundDefault', '', oportunidad.Id);
			Map<String, Object> responseRegistrarLlamadaSaliente = CSBD_Llamada_GC.registrarLlamadaSaliente(inputLlamadaSaliente);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)responseRegistrarLlamadaSaliente.get('llamada');
			inputLlamadaSaliente.llamadaId = llamadaSaliente.Id;
			Map<String, Object> responseIniciarLlamadaSalienteClickToDial = CSBD_Llamada_GC.iniciarLlamadaSalienteClickToDial(inputLlamadaSaliente);

			List<Task> tarea1 = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaSaliente.Id
									AND WhatId = :oportunidad.Id AND Type = 'Llamada saliente'
									AND Status = 'Open' LIMIT 1];
			Test.startTest();
			inputLlamadaSaliente.llamadaId = llamadaSaliente.Id;
			CSBD_Llamada_GC.finalizarLlamada(inputLlamadaSaliente, 'Llamada finalizada');
			Test.stopTest();

			List<Task> tarea2 = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaSaliente.Id
									AND WhatId = :oportunidad.Id AND Type = 'Llamada saliente'
									AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];

			System.assert(!tarea1.isEmpty(), 'La tarea no debería ser nula');
			System.assert(!tarea2.isEmpty(), 'La tarea no debería ser nula');

			llamadaSaliente = [SELECT CC_Fecha_Fin__c, CC_Tipo_Cierre__c FROM CC_Llamada__c WHERE Id = :llamadaSaliente.Id];
			System.assert(llamadaSaliente.CC_Fecha_Fin__c != null, 'La fecha de fin no debería ser nula');
			System.assertEquals('Llamada finalizada', llamadaSaliente.CC_Tipo_Cierre__c, 'El tipo de cierre no debería ser nulo');




            Opportunity oportunidad2 = [SELECT Id,CreatedDate,CSBD_Horario_Contacto__c,CSBD_SLA_Primera_Respuesta__c,CSBD_PrimerContactoSLA__c,CSBD_SLA_TGT__c FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test 2'];

            if(oportunidad2.CreatedDate >= System.now()) {
                System.assert(oportunidad2.CSBD_SLA_Primera_Respuesta__c == 0, 'La primera respuesta no debería ser nula');
                System.assert(oportunidad2.CSBD_PrimerContactoSLA__c != null, 'El primer contacto no debería ser nulo');
                System.assert(oportunidad2.CSBD_SLA_TGT__c != null, 'El TGT no debería ser nulo');
            }
            if(oportunidad2.CreatedDate < System.now()){
                System.assert(oportunidad2.CSBD_SLA_Primera_Respuesta__c != null, 'La primera respuesta no debería ser nula');
                System.assert(oportunidad2.CSBD_PrimerContactoSLA__c != null, 'El primer contacto no debería ser nulo');
                System.assert(oportunidad2.CSBD_SLA_TGT__c != null, 'El TGT no debería ser nulo');
            }

		}
	}

    @isTest
	public static void finalizarLlamadaIngles() {
        User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];
		System.runAs(gestorCsbd) {
            Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test 2'];
            oportunidad.CSBD_Horario_Contacto__c = '23:50 - 23:59';
            oportunidad.CSBD_Idioma_Solicitud__c = 'Inglés';
            update oportunidad;

			//Realizar la llamada saliente
			CC_Llamada_Input inputLlamadaSaliente = obtenerInputLlamada('KIN_GenesysCloudOutboundDefault', '', oportunidad.Id);
			Map<String, Object> responseRegistrarLlamadaSaliente = CSBD_Llamada_GC.registrarLlamadaSaliente(inputLlamadaSaliente);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)responseRegistrarLlamadaSaliente.get('llamada');
			inputLlamadaSaliente.llamadaId = llamadaSaliente.Id;
			Map<String, Object> responseIniciarLlamadaSalienteClickToDial = CSBD_Llamada_GC.iniciarLlamadaSalienteClickToDial(inputLlamadaSaliente);

			List<Task> tarea1 = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaSaliente.Id
									AND WhatId = :oportunidad.Id AND Type = 'Llamada saliente'
									AND Status = 'Open' LIMIT 1];
			Test.startTest();
			inputLlamadaSaliente.llamadaId = llamadaSaliente.Id;
			CSBD_Llamada_GC.finalizarLlamada(inputLlamadaSaliente, 'Llamada finalizada');
			Test.stopTest();

			List<Task> tarea2 = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaSaliente.Id
									AND WhatId = :oportunidad.Id AND Type = 'Llamada saliente'
									AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];

			System.assert(!tarea1.isEmpty(), 'La tarea no debería ser nula');
			System.assert(!tarea2.isEmpty(), 'La tarea no debería ser nula');

			llamadaSaliente = [SELECT CC_Fecha_Fin__c, CC_Tipo_Cierre__c FROM CC_Llamada__c WHERE Id = :llamadaSaliente.Id];
			System.assert(llamadaSaliente.CC_Fecha_Fin__c != null, 'La fecha de fin no debería ser nula');
			System.assertEquals('Llamada finalizada', llamadaSaliente.CC_Tipo_Cierre__c, 'El tipo de cierre no debería ser nulo');




            Opportunity oportunidad2 = [SELECT Id,CreatedDate,CSBD_Horario_Contacto__c,CSBD_SLA_Primera_Respuesta__c,CSBD_PrimerContactoSLA__c,CSBD_SLA_TGT__c FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test 2'];

            if(oportunidad2.CreatedDate >= System.now()) {
                System.assert(oportunidad2.CSBD_SLA_Primera_Respuesta__c == 0, 'La primera respuesta no debería ser nula');
                System.assert(oportunidad2.CSBD_PrimerContactoSLA__c != null, 'El primer contacto no debería ser nulo');
                System.assert(oportunidad2.CSBD_SLA_TGT__c != null, 'El TGT no debería ser nulo');
            }
            if(oportunidad2.CreatedDate < System.now()){
                System.assert(oportunidad2.CSBD_SLA_Primera_Respuesta__c != null, 'La primera respuesta no debería ser nula');
                System.assert(oportunidad2.CSBD_PrimerContactoSLA__c != null, 'El primer contacto no debería ser nulo');
                System.assert(oportunidad2.CSBD_SLA_TGT__c != null, 'El TGT no debería ser nulo');
            }

		}
	}

    @isTest
	public static void finalizarLlamadaSinId() {
        User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];

		System.runAs(gestorCsbd) {
			CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = 'S1'];

			Test.startTest();
			//Entra la llamada
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(s1.CC_Codigo__c, '', '');
			Map<String, Object> retornoRegistrarLlamadaEntrante = CSBD_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');
            llamadaEntrante.CC_ConnId__c = 'pruebaConId123456789Test';
            llamadaEntrante.CC_Agente__c = 'Usuario test';
            llamadaEntrante.CC_Extension__c = 'Test';
            llamadaEntrante.CC_Fecha_Fin__c = null;
            update llamadaEntrante;
			System.assert(llamadaEntrante != null, 'La llamada no debería ser nula');

			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
			System.assert(actividad != null, 'La actividad no debería ser nula');

			inputLlamada.llamadaId = null;
			CSBD_Llamada_GC.finalizarLlamada(inputLlamada, 'Llamada finalizada');
			Test.stopTest();
		}
	}

    @isTest
	public static void finalizarLlamadaOportunidad() {
        User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];
        Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];

		System.runAs(gestorCsbd) {
			CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = 'S1'];

			Test.startTest();
			//Entra la llamada
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(s1.CC_Codigo__c, '', '');
			Map<String, Object> retornoRegistrarLlamadaEntrante = CSBD_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');
            update llamadaEntrante;
			System.assert(llamadaEntrante != null, 'La llamada no debería ser nula');

			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
			System.assert(actividad != null, 'La actividad no debería ser nula');

            Id idRtTask = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSBD_Task').getRecordTypeId();
            Task tarea = new Task();
            tarea.RecordTypeId = idRtTask;
            tarea.WhatId = oportunidad.Id;
            tarea.CC_Llamada_Id__c = llamadaEntrante.Id;
            tarea.Status = 'Open';
            insert tarea;

			inputLlamada.llamadaId = oportunidad.id;
			CSBD_Llamada_GC.finalizarLlamada(inputLlamada, 'Llamada finalizada');
			Test.stopTest();
		}
	}

    @isTest
	public static void registrarEncuestaTest() {
		User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];
		System.runAs(gestorCsbd) {

            Opportunity oportunidad = [SELECT Id FROM Opportunity WHERE CSBD_Titulo__c = 'Oportunidad Test'];
            CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = 'NIS_GenesysCloudOutboundDefault'];
            CC_Servicio_Genesys__c encuesta = [SELECT Id FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio Encuesta' LIMIT 1];
			s1.CC_Encuesta__c = encuesta.Id;
			update s1;

            CC_Llamada_Input inputLlamadaSaliente = obtenerInputLlamada(s1.CC_Codigo__c, '', oportunidad.Id);
			Map<String, Object> responseRegistrarLlamadaSaliente = CSBD_Llamada_GC.registrarLlamadaSaliente(inputLlamadaSaliente);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)responseRegistrarLlamadaSaliente.get('llamada');
			inputLlamadaSaliente.llamadaId = llamadaSaliente.Id;
			Map<String, Object> responseIniciarLlamadaSalienteClickToDial = CSBD_Llamada_GC.iniciarLlamadaSalienteClickToDial(inputLlamadaSaliente);

            CC_Llamada_Input inputFinalizarLlamada = obtenerInputLlamada(null, llamadaSaliente.Id, oportunidad.Id);
			CSBD_Llamada_GC.finalizarLlamada(inputFinalizarLlamada, 'Llamada finalizada');

            Test.startTest();
			Map<String, Object> nombreEncuesta = CSBD_Llamada_GC.registrarEncuesta(inputFinalizarLlamada);
			Test.stopTest();

			System.assertEquals('Servicio Encuesta',nombreEncuesta.get('nombreEncuesta'), 'No se ha encontrado la encuesta');
		}
	}

	@isTest
    public static void slaHorarioComercialTest() {
		System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
			CC_Servicio_Genesys__c svcGenesysSalida = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = 'NIS_GenesysCloudOutboundDefault' LIMIT 1];
			svcGenesysSalida.CC_Encuesta__c = [SELECT Id FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio Encuesta' LIMIT 1].Id;
			update svcGenesysSalida;

			System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
				Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', new Map<String, Object>{
					'CSBD_Horario_Contacto__c' => 'NO'
				});

				Date hoy = System.today();
				Date domingp = hoy.toStartOfWeek();
				if (domingp == hoy) {
					domingp = domingp.addDays(-7);
				}

				domingp = domingp.addDays(-1);
				Test.setCreatedDate(oportunidad.Id, domingp);
				
				Test.startTest();
				CC_Llamada_Input inputLlamadaSaliente = obtenerInputLlamada(svcGenesysSalida.CC_Codigo__c, '', oportunidad.Id);
				Map<String, Object> responseRegistrarLlamadaSaliente = CSBD_Llamada_GC.registrarLlamadaSaliente(inputLlamadaSaliente);
				CC_Llamada__c llamadaSaliente = (CC_Llamada__c)responseRegistrarLlamadaSaliente.get('llamada');
				inputLlamadaSaliente.llamadaId = llamadaSaliente.Id;
				Map<String, Object> responseIniciarLlamadaSalienteClickToDial = CSBD_Llamada_GC.iniciarLlamadaSalienteClickToDial(inputLlamadaSaliente);

				CC_Llamada_Input inputFinalizarLlamada = obtenerInputLlamada(null, llamadaSaliente.Id, oportunidad.Id);
				CSBD_Llamada_GC.finalizarLlamada(inputFinalizarLlamada, 'Llamada finalizada');
				Test.stopTest();

				oportunidad = [SELECT CSBD_SLA_Primera_Respuesta__c FROM Opportunity WHERE Id = :oportunidad.Id];
				System.assert(oportunidad.CSBD_SLA_Primera_Respuesta__c != null, 'No se ha calculado correctamente el SLA (valor: ' + oportunidad.CSBD_SLA_Primera_Respuesta__c + ')');
			}
		}
	}
}