// Clase test de CSBD_Opportunity_Operativas_Controller
// Nombre no convencional porque Apex tiene un límite de carácteres
@IsTest
public class CSBD_Oppty_Operativas_Controller_Test {

	@TestSetup
	private static void altaDatosPrueba() {
		User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        
        User usuarioGestor2 = CSBD_Usuarios.usuarioDerivarGestor();
		usuarioGestor2.AV_ExternalID__c = 'U0123456789';
		update usuarioGestor2;
        
        User userAdmin = CSBD_Usuarios.usuarioAdministrador();
        
		CSBD_TestDataFactory.crearCuentaContacto('12345678N');
		// Account cuenta = crearCuentaContacto('12345678N');

		// AccountShare acshare = new AccountShare();
		// acshare.AccountId = cuenta.Id;
		// acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
		// acshare.AccountAccessLevel = 'Edit';
		// acshare.OpportunityAccessLevel = 'Edit';
		// acshare.CaseAccessLevel = 'Edit';
		// insert acshare;

		//CSBD: Traspaso Imagin - Destinatarios
		CC_Lista_Valores__c listaValoresTraslado = new CC_Lista_Valores__c();
		listaValoresTraslado.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
		listaValoresTraslado.Name = 'CSBD: Traspaso Imagin - Destinatarios';
		listaValoresTraslado.CC_Activa__c = true;
		System.runAs(usuarioGestor){
			insert listaValoresTraslado;
		}

		CC_Lista_Valores__c valorTraslado = new CC_Lista_Valores__c();
		valorTraslado.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
		valorTraslado.CC_Lista__c = listaValoresTraslado.Id;
		valorTraslado.Name = 'CMB';
		valorTraslado.CC_Valor__c = 'test@test.com';
		valorTraslado.CC_Activa__c = true;
		System.runAs(usuarioGestor){
			insert valorTraslado;
		}

		//Alta de las parametrizaciones que necesita el trigger BI de oportunidades
		CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
		listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
		listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
		listaValores.CC_Activa__c = true;
		System.runAs(usuarioGestor){
			insert listaValores;
		}

		CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
		valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
		valor.CC_Lista__c = listaValores.Id;
		valor.Name = 'Préstamo';
		valor.CC_Valor__c = '1';
		valor.CC_Activa__c = true;
		System.runAs(usuarioGestor){
			insert valor;
		}

		Pricebook2 listaPrecios = new Pricebook2(Name = 'CSBD Price Book', Description = 'CSBD Price Book', IsActive = true );
		System.runAs(usuarioGestor){
			insert listaPrecios;
		}

		List<Group> colaPrestamos = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CSBD_Prestamos_I'];

		if(colaPrestamos.isEmpty()) {
			Group nuevaColaPrestamos = new Group(Name='Now In Sales - Préstamos I', DeveloperName = 'CSBD_Prestamos_I', Type='Queue');
			insert nuevaColaPrestamos;
		}

		CC_Lista_Valores__c reglaAsignacion = new CC_Lista_Valores__c();
		reglaAsignacion.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Regla_asignacion_oportunidad').getRecordTypeId();
		reglaAsignacion.Name = 'Oportunidades - Préstamos I';
		reglaAsignacion.CSBD_Cola_Oportunidad__c = 'CSBD_Prestamos_I';
		reglaAsignacion.CSBD_Tipo_de_oportunidad__c = 'Préstamo';
		reglaAsignacion.CC_Orden__c = 1;
		reglaAsignacion.CC_Activa__c = true;
		System.runAs(usuarioGestor) {
			insert reglaAsignacion;
		}

		CBK_IntegrationSetting__c integrationSetting = new CBK_IntegrationSetting__c();
		integrationSetting.Name = 'CSBD_WS_Adobe';
		integrationSetting.NamedCredential__c = 'callout:CSBD_WS_CredentialAdobe/{PARAMS_1}/{PARAMS_2}/{PARAMS_3}/{PARAMS_4}';
		insert integrationSetting;

		//List<CSBD_Criterios_asignacion_oportunidad__mdt> criterios = [SELECT CSBD_Cola_Asignada__c, CSBD_Criterio_1__c, CSBD_Criterio_2__c FROM CSBD_Criterios_asignacion_oportunidad__mdt];
	}

	private static Account crearCuentaContacto(String nif) {
		Account cuenta = new Account();
		cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
		cuenta.Name = 'test@test.com';
		cuenta.CC_Numero_Documento__c = nif;
		cuenta.Phone = '666666666';
		insert cuenta;

		Contact contacto = new Contact();
		contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
		contacto.Email = 'test@test.com';
		contacto.Phone = '666666666';
		contacto.FirstName = 'Nombre';
		contacto.LastName = 'Apellido';
		contacto.CSBD_Limite_Prestamos_Oficinas__c = 20000;
		contacto.AccountId = cuenta.Id;
		insert contacto;

		return cuenta;
	}

	private static Opportunity crearOportunidadPrestamo(Account cuenta) {
		Map<String, Object> campos = new Map<String, Object>();
		campos.put('Name', 'oportunidad de prueba');
		campos.put('CSBD_Estado__c', 'Activa');
		campos.put('StageName', 'Solicitud');
		campos.put('AccountId', cuenta.Id);
		campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
		campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);

		return CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
	}

	private static void crearPublicGroup(String nombreGrupo, User user) {//crea un public group con el nombre que recibe e incluye al usuario que se le pasa
		Group newGroup = new Group();
		newGroup.Name = nombreGrupo;
		insert(newGroup);

		GroupMember gpm = new GroupMember();
		gpm.GroupId = newGroup.Id;
		gpm.UserOrGroupId = user.Id;
		Database.insert(gpm);

		return ;
	}

	@IsTest
	public static void subdirectorios() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		//Ejecución de la prueba
		System.runAs(usuarioGestor){
			Test.startTest();
			List<Folder> carpetas = CSBD_Opportunity_Operativas_Controller.subdirectorios('CSBD_Operativas');
			Test.stopTest();

			System.assert(carpetas != null);
		}
	}

	@IsTest
	public static void plantillas() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		//Ejecución de la prueba
		System.runAs(usuarioGestor){
			Test.startTest();
			List<EmailTemplate> plantillas = CSBD_Opportunity_Operativas_Controller.plantillas('CSBD_Operativas_SolInfo_ESP_Formal');
			Test.stopTest();

			System.assert(plantillas != null);
		}
	}

	@IsTest
	public static void plantillaCuerpo() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

		//Alta de datos para la prueba Email Template
		EmailTemplate plantilla = new EmailTemplate();
		plantilla.DeveloperName = 'CSBD_Plantilla_Test';
		plantilla.Name = 'CSBD Plantilla Test';
		plantilla.TemplateType = 'custom';
		plantilla.FolderId = usuarioGestor.Id; //Indica que la plantilla se crea en la carpeta personal del usuario
		plantilla.Subject = 'CSBD Plantilla Test';
		plantilla.HtmlValue = '<b>CSBD</b> <i>Plantilla</i> <u>Test</u>';
		System.runAs(usuarioGestor){
			insert plantilla;
		}

		//Template
		EmailTemplate plantillaCreada = [SELECT Id, DeveloperName, Name, FolderId, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'CSBD_Plantilla_Test'];

		//Opportunity
		Opportunity prestamo = crearOportunidadPrestamo(cuenta);

		System.runAs(usuarioGestor){
			//Ejecución de la prueba
			Test.startTest();
			String cuerpoPlantillaHTML = CSBD_Opportunity_Operativas_Controller.plantillaCuerpo('CSBD_Plantilla_Test', false, prestamo.Id);
			String cuerpoPlantillaTextoPlano = CSBD_Opportunity_Operativas_Controller.plantillaCuerpo('CSBD_Plantilla_Test', true, prestamo.Id);
			Test.stopTest();

			//Evaluación del resultado de la prueba
			System.assertEquals('<b>CSBD</b> <i>Plantilla</i> <u>Test</u>', cuerpoPlantillaHTML);
			System.assertEquals('CSBD Plantilla Test', cuerpoPlantillaTextoPlano);
		}
	}

	@IsTest
	public static void prepararOportunidadParaEnvioCorreo() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		//Alta de datos para la prueba
		EmailTemplate plantilla = new EmailTemplate();
		plantilla.DeveloperName = 'CSBD_Plantilla_Test';
		plantilla.Name = 'CSBD Plantilla Test';
		plantilla.TemplateType = 'custom';
		plantilla.FolderId = usuarioGestor.Id; //Indica que la plantilla se crea en la carpeta personal del usuario
		plantilla.Subject = 'CSBD Plantilla Test';
		plantilla.HtmlValue = '<b>CSBD</b> <i>Plantilla</i> <u>Test</u>';
		System.runAs(usuarioGestor){
			insert plantilla;
		}

		Opportunity oportunidad = new Opportunity();
		oportunidad.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
		oportunidad.Name = 'Opportunity Test';
		oportunidad.StageName = 'Solicitud';
		oportunidad.CSBD_Telefono_Solicitud__c = '623456789';
		insert oportunidad;

		OpportunityShare oppshare = new OpportunityShare();
		oppshare.UserOrGroupId = usuarioGestor.Id;
		oppshare.OpportunityId = oportunidad.Id;
		oppshare.OpportunityAccessLevel = 'Edit';
		insert oppshare;

		System.runAs ( usuarioGestor ) {
			oportunidad.OwnerId = usuarioGestor.Id;
			update oportunidad;

			//Ejecución de la prueba
			Test.startTest();
			CSBD_Opportunity_Operativas_Controller.prepararOportunidadParaEnvioCorreo(oportunidad.Id, 'CSBD_Plantilla_Test', true, true);
			oportunidad = [SELECT CSBD_Plantilla_Correo__c, CSBD_Referencia_Correo_Saliente__c FROM Opportunity WHERE Id = :oportunidad.Id];
			Test.stopTest();

			//Evaluación del resultado de la prueba
			System.assertEquals('CSBD_Plantilla_Test', oportunidad.CSBD_Plantilla_Correo__c);
			System.assertEquals(17, oportunidad.CSBD_Referencia_Correo_Saliente__c.length());
		}
	}

	@IsTest
	public static void numeroOportunidadesAnteriores() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
		Contact contacto = [SELECT Id FROM Contact WHERE AccountId =: cuenta.Id];

		Opportunity oportunidad1 = new Opportunity();
		oportunidad1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Prestamo');
		oportunidad1.Name = 'Opportunity 1 Test';
		oportunidad1.StageName = 'Perdida';
		oportunidad1.AccountId = cuenta.Id;
		oportunidad1.CSBD_Contact__c = contacto.Id;
		insert oportunidad1;

		//Corrección de la fecha de cierre que inicializa el trigger CC_Opportunity_BI_TRHan
		oportunidad1.CloseDate = System.today().addDays(-360);
		update oportunidad1;

		Opportunity oportunidad2 = new Opportunity();
		oportunidad2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Prestamo');
		oportunidad2.Name = 'Opportunity 2 Test';
		oportunidad2.StageName = 'Perdida';
		oportunidad2.AccountId = cuenta.Id;
		oportunidad2.CSBD_Contact__c = contacto.Id;
		insert oportunidad2;

		//Corrección de la fecha de cierre que inicializa el trigger CC_Opportunity_BI_TRHan
		oportunidad2.CloseDate = System.today().addDays(-25);
		update oportunidad2;

		Opportunity oportunidad3 = new Opportunity();
		oportunidad3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Prestamo');
		oportunidad3.Name = 'Opportunity 3 Test';
		oportunidad3.StageName = 'Perdida';
		oportunidad3.AccountId = cuenta.Id;
		oportunidad3.CSBD_Contact__c = contacto.Id;
		insert oportunidad3;

		//Corrección de la fecha de cierre que inicializa el trigger CC_Opportunity_BI_TRHan
		oportunidad3.CloseDate = System.today().addDays(-25);
		update oportunidad3;

		Opportunity nuevaOportunidad = new Opportunity();
		nuevaOportunidad.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Prestamo');
		nuevaOportunidad.Name = 'Opportunity Nueva Test';
		nuevaOportunidad.StageName = 'Perdida';
		nuevaOportunidad.AccountId = cuenta.Id;
		nuevaOportunidad.CSBD_Contact__c = contacto.Id;
		insert nuevaOportunidad;

		//Ejecución de la prueba
		System.runAs ( usuarioGestor ) {
			Test.startTest();
			Map<String, String> oportunidadesAnteriores = CSBD_Opportunity_Operativas_Controller.numeroOportunidadesAnteriores(cuenta.Id, CC_MetodosUtiles.getRecordTypeDeveloperNameFromId('Opportunity', nuevaOportunidad.RecordTypeId));
			Test.stopTest();

			System.assertEquals('Préstamos recientes', oportunidadesAnteriores.get('titulo'));
			System.assertEquals('Solicitados en los últimos 365 días: 3\nDenegados últimos 365 días: 3\nDenegados últimos 30 días: 2', oportunidadesAnteriores.get('mensaje'));
		}
	}

	@IsTest
	public static void cerrarOportunidad() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		//Alta de datos para la prueba
		Opportunity oportunidad = new Opportunity();
		oportunidad.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
		oportunidad.Name = 'Opportunity Test';
		oportunidad.StageName = 'Solicitud';
		oportunidad.CloseDate = System.today().addDays(15);
		insert oportunidad;

		OpportunityShare oppshare = new OpportunityShare();
		oppshare.UserOrGroupId = usuarioGestor.Id;
		oppshare.OpportunityId = oportunidad.Id;
		oppshare.OpportunityAccessLevel = 'Edit';
		insert oppshare;

		//Ejecución de la prueba
		System.runAs ( usuarioGestor ) {
			oportunidad.OwnerId = usuarioGestor.Id;
			oportunidad.Amount = 1;
			update oportunidad;

			Test.startTest();
			Opportunity oportunidadCerrada = CSBD_Opportunity_Operativas_Controller.cerrarOportunidad(oportunidad.Id, 'Formalizada', 'Tarjeta crédito');
			Test.stopTest();

			System.assertEquals('Cerrada', oportunidadCerrada.CSBD_Estado__c);
		}
	}

	@IsTest
	public static void reactivarOportunidad() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		//Alta de datos para la prueba
		Opportunity oportunidad = new Opportunity();
		oportunidad.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
		oportunidad.Name = 'Opportunity Test';
		oportunidad.StageName = 'Formalizada';
		oportunidad.CSBD_Estado__c = 'Cerrada';
		insert oportunidad;

		OpportunityShare oppshare = new OpportunityShare();
		oppshare.UserOrGroupId = usuarioGestor.Id;
		oppshare.OpportunityId = oportunidad.Id;
		oppshare.OpportunityAccessLevel = 'Edit';
		insert oppshare;

		//Ejecución de la prueba
		System.runAs ( usuarioGestor ) {
			oportunidad.OwnerId = usuarioGestor.Id;
			update oportunidad;

			Test.startTest();
			Opportunity oportunidadReactivada = CSBD_Opportunity_Operativas_Controller.reactivarOportunidad(oportunidad.Id, 'Solicitud');
			Test.stopTest();

			System.assertEquals('Solicitud', oportunidadReactivada.StageName);
			System.assertEquals('Activa', oportunidadReactivada.CSBD_Estado__c);
		}
	}

	@IsTest
	public static void programarCita() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Account cuenta = [SELECT Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

		Opportunity oportunidad = new Opportunity();
		oportunidad.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
		oportunidad.Name = 'Opportunity Test';
		oportunidad.StageName = 'Solicitud';
		oportunidad.AccountId = cuenta.Id;
		insert oportunidad;

		Date dia = Date.newInstance(2020, 1, 23);
		Datetime comienzoCita = Datetime.newInstance(dia, Time.newInstance(9, 0, 0, 0));

		System.runAs ( usuarioGestor ) {
			Test.startTest();
			CSBD_Opportunity_Operativas_Controller.programarCita(oportunidad.Id, false, false, usuarioGestor.Id, comienzoCita);
			Test.stopTest();

			List<Event> citas1Hora  = [SELECT Id FROM Event WHERE DurationInMinutes = 60];
			System.assertEquals(1, citas1Hora.size());
		}
	}

	@IsTest
	public static void recordTypesOportunidadCSBD() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		List<Map<String, String>> recordTypes = new List<Map<String, String>>();
		for (RecordType recordType: [SELECT DeveloperName, Name FROM RecordType
										WHERE SobjectType = 'Opportunity' AND DeveloperName LIKE 'CSBD_%']) {
			Map<String, String> rt = new Map<String, String>();
			rt.put('Name', recordType.Name);
			rt.put('DeveloperName', recordType.DeveloperName);
			recordTypes.add(rt);
		}
		System.runAs ( usuarioGestor ) {
			Test.startTest();
			List<Map<String, String>> retorno = CSBD_Opportunity_Operativas_Controller.recordTypesOportunidadCSBD();
			Test.stopTest();

			System.assertEquals(recordTypes, retorno, 'Lista de record types de oportunidades CSBD incorrecta');
		}
	}

	@IsTest
	public static void pluralRecordTypeName() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		System.runAs ( usuarioGestor ) {
			System.assertEquals('Préstamos', CSBD_Opportunity_Operativas_Controller.pluralRecordTypeName('CSBD_Prestamo'), 'Plural incorrecto');
			System.assertEquals('CMN', CSBD_Opportunity_Operativas_Controller.pluralRecordTypeName('CSBD_CMN'), 'Plural incorrecto');
			System.assertEquals('Acciones comerciales', CSBD_Opportunity_Operativas_Controller.pluralRecordTypeName('CSBD_Accion_Comercial'), 'Plural incorrecto');
		}
	}

	@IsTest
	public static void enviarNotificacinPushSMS() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
		
        Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c, Phone FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
       	cuenta.Phone = '123456789';
		update cuenta;

		System.runAs ( usuarioGestor ) {
			Opportunity prestamo = crearOportunidadPrestamo(cuenta);
			Test.startTest();
			CSBD_Opportunity_Operativas_Controller.enviarNotificacinPushSMS(prestamo.Id, cuenta.Phone, 'cuerpo sms');
			Test.stopTest();

			List<Task> actividadesSMS = [SELECT Status FROM Task
										WHERE WhatId = :prestamo.Id AND Type = 'Notificación - Salida'];
			System.assertEquals(actividadesSMS[0].Status, 'Completed');
		}
	}

	@IsTest
	public static void desprogramarCita() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
		Opportunity prestamo = crearOportunidadPrestamo(cuenta);

		OpportunityShare oppshare = new OpportunityShare();
		oppshare.UserOrGroupId = usuarioGestor.Id;
		oppshare.OpportunityId = prestamo.Id;
		oppshare.OpportunityAccessLevel = 'Edit';
		insert oppshare;

		System.runAs ( usuarioGestor ) {
			prestamo.OwnerId = usuarioGestor.Id;
			update prestamo;

			Test.startTest();
			CSBD_Opportunity_Operativas_Controller.programarCita(prestamo.Id, false, false, prestamo.OwnerId, System.now().addHours(1));
			Event citaDesprogramada = CSBD_Opportunity_Operativas_Controller.desprogramarCita(prestamo.Id);
			Test.stopTest();

			System.assertEquals('Cancelado', citaDesprogramada.CSBD_Evento_Estado__c, 'No se ha desprogramado la cita');
		}
	}

	@IsTest
	public static void actualizarDatosRiesgoContacto() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
		Opportunity prestamo = crearOportunidadPrestamo(cuenta);

		System.runAs ( usuarioGestor ) {
			Test.startTest();
			CSBD_Opportunity_Operativas_Controller.actualizarDatosRiesgoContacto(prestamo.Id);
			Test.stopTest();

			Contact contacto = [SELECT CSBD_Tramo_Riesgo__c, CSBD_Actualizacion_Datos_Riesgo__c, CSBD_Ultima_Actualizacion_SIR__c FROM Contact WHERE Id = :prestamo.CSBD_Contact__c];
			System.assertEquals(false, contacto.CSBD_Actualizacion_Datos_Riesgo__c);
		}
	}

	@IsTest
	public static void duplicarOportunidad() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
		Opportunity prestamo = crearOportunidadPrestamo(cuenta);

		System.runAs ( usuarioGestor ) {
			Test.startTest();
			Opportunity oportunidadDuplicada = CSBD_Opportunity_Operativas_Controller.duplicarOportunidad(prestamo, 'CSBD_Prestamo', 'CaixaBank');
			oportunidadDuplicada = [SELECT CSBD_Parent_Id__c FROM Opportunity WHERE Id = :oportunidadDuplicada.Id];
			System.assertEquals(prestamo.id, oportunidadDuplicada.CSBD_Parent_Id__c, 'No existe una oportunidad hija');

			//Probar excepción
			try {
				CSBD_Opportunity_Operativas_Controller.duplicarOportunidad(prestamo, 'recordTypeInexistente', 'CaixaBank');
			} catch (Exception e) {
				System.assertEquals('System.AuraHandledException', e.getTypeName(), 'Tipo incorrecto de excepción');
			}
			Test.stopTest();
		}
	}

	@IsTest
	public static void getMotivosPendienteInterno() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		System.runAs ( usuarioGestor ) {
			Test.startTest();
			List<OT_Picklist.Item> motivosPendienteInterno = CSBD_Opportunity_Operativas_Controller.getMotivosPendienteInterno();
			Test.stopTest();

			System.assertEquals(
				OT_Picklist.picklistCampo('Opportunity', 'CSBD_Motivo_Pendiente_Interno__c').size(),
				motivosPendienteInterno.size(),
				'La lista de motivos pendiente interno no coincide.'
			);
		}
	}

	@IsTest
	public static void etapasProcesoVentas() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		System.runAs ( usuarioGestor) {
			Test.startTest();
			List<OT_Picklist> etapasProcesoVentas = CSBD_Opportunity_Operativas_Controller.etapasProcesoVentas(null, null);
			Test.stopTest();

			System.assert(etapasProcesoVentas != null, 'La lista de etapas de ventas no debe ser nula');
		}
	}

	@IsTest
	public static void comprobarPublic() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Boolean check = false;
		Set<String> groupsNames= new Set<String>();

		crearPublicGroup('CSBD Administrador', usuarioGestor);

		System.runAs(usuarioGestor) {
			List<GroupMember> publicGroups = [SELECT Group.Name FROM GroupMember WHERE UserOrGroupId =: usuarioGestor.Id];

			if(!publicGroups.isEmpty()){
				for(GroupMember gruposPublicos : publicGroups){
					groupsNames.add(gruposPublicos.Group.Name);
				}
				if(groupsNames.contains('CSBD Administrador')){
					check = true;
				}
			}

			Test.startTest();
			Boolean comprobado = CSBD_Opportunity_Operativas_Controller.comprobarPublicGroup();
			Test.stopTest();

			System.assert(comprobado == check, 'No concuerdan las comprobaciones de pertenencia al public group');
		}
	}

	@IsTest
	private static void solicitarAltaOmnichannel_Test() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

		Map<String, Object> campos = new Map<String, Object>();
		campos.put('Name', 'oportunidad de prueba');
		campos.put('CSBD_Estado__c', 'Activa');
		campos.put('StageName', 'Solicitud');
		campos.put('AccountId', cuenta.Id);
		campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
		campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
		campos.put('CSBD_Horario_Contacto__c', 'Mañana');
		campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
		campos.put('CSBD_Familia_Producto__c', 'Cuentas');
		campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank');
		Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);

		System.runAs ( usuarioGestor ) {
			Test.startTest();
			CSBD_Opportunity_Operativas_Controller.solicitarAltaOmnichannel(oportunidad.Id);
			Test.stopTest();

			List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id AND CSBD_Estado__c != 'Inactivo'];
			System.assert(!gestorOportunidad.isEmpty());
		}
	}

	@IsTest
	private static void solicitarBajaOmnichannel_Test() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

		Map<String, Object> campos = new Map<String, Object>();
		campos.put('Name', 'oportunidad de prueba');
		campos.put('CSBD_Estado__c', 'Activa');
		campos.put('StageName', 'Solicitud');
		campos.put('AccountId', cuenta.Id);
		campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
		campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
		campos.put('CSBD_Horario_Contacto__c', 'Mañana');
		campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
		campos.put('CSBD_Familia_Producto__c', 'Cuentas');
		campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank');
		Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);

		System.runAs ( usuarioGestor ) {
			Test.startTest();
			CSBD_Opportunity_Operativas_Controller.solicitarAltaOmnichannel(oportunidad.Id);
			CSBD_Opportunity_Operativas_Controller.solicitarBajaOmnichannel(oportunidad.Id);
			Test.stopTest();

			List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT Id, OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id AND CSBD_Estado__c = 'Inactivo'];
			System.assert(!gestorOportunidad.isEmpty());
		}
	}

	@IsTest
	private static void actualizarOwnerOportunidad_Test() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Account cuenta = [SELECT Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

		
		System.runAs(usuarioGestor) {
            
            Map<String, Object> campos = new Map<String, Object>();
			campos.put('Name', 'oportunidad de prueba');
			campos.put('CSBD_Estado__c', 'Activa');
			campos.put('StageName', 'Solicitud');
			campos.put('AccountId', cuenta.Id);
			campos.put('CSBD_Contact__c', [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id);
			campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
			campos.put('CSBD_Horario_Contacto__c', 'Mañana');
			campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
			campos.put('CSBD_Familia_Producto__c', 'Cuentas');
			campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank');
			campos.put('CSBD_Importe_Producto_Principal__c', 200);
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
			CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad}, 'Pendiente de asignar');

			List<CSBD_Gestor_Oportunidad__c> gestorOportunidadCambiarOwnerUsuario = [SELECT OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];
            
			gestorOportunidadCambiarOwnerUsuario[0].OwnerId = usuarioGestor.Id;
			update gestorOportunidadCambiarOwnerUsuario;

			Test.startTest();
			CSBD_Opportunity_Operativas_Controller.actualizarOwnerOportunidad(oportunidad.Id, oportunidad.OwnerId);
			Test.stopTest();

			List<CSBD_Gestor_Oportunidad__c> gestorOportunidad = [SELECT OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];
			List<Opportunity> oportunidadActualizada = [SELECT OwnerId FROM Opportunity WHERE Id = :oportunidad.Id];
			System.assertEquals(gestorOportunidad[0].OwnerId, oportunidadActualizada[0].OwnerId);
		}
	}

	@IsTest
	private static void trasladoImagin_Test(){
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
		Contact contacto1 = [SELECT Id FROM Contact WHERE AccountId =: cuenta.Id];

		EmailTemplate plantilla = new EmailTemplate();
		plantilla.DeveloperName = 'CSBD_Traspaso_CMB_Imagin';
		plantilla.isActive = true;
		plantilla.Name = 'CSBD Traspaso CMB Imagin';
		plantilla.TemplateType = 'custom';
		plantilla.FolderId = usuarioGestor.Id; //Indica que la plantilla se crea en la carpeta personal del usuario
		plantilla.Subject = 'CSBD Traspaso CMB Imagin';
		plantilla.HtmlValue = '<b>CSBD</b> <i>Plantilla</i> <u>Test</u>';
		System.runAs(usuarioGestor){
			insert plantilla;
		}

		Map<String, Object> campos = new Map<String, Object>();
		campos.put('AccountId', cuenta.Id);
		campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
		campos.put('CSBD_Email_Solicitud__c', 'test2@test.com');
		campos.put('CSBD_Empresa_Proveedora__c', 'imaginBank');
		campos.put('CSBD_Contact__c',contacto1.Id);
		Opportunity oportunidadTrasladoImagin = CSBD_Opportunity.crearOportunidad('CSBD_CMB', campos);
		oportunidadTrasladoImagin.OwnerId = usuarioGestor.Id;
		update oportunidadTrasladoImagin;

		System.runAs(usuarioGestor) {
			Test.startTest();
				CSBD_Opportunity_Operativas_Controller.trasladoImaginBank(oportunidadTrasladoImagin.Id, 'Rechazada', 'Traspasada a Imagin');
			Test.stopTest();

			System.Assert([SELECT Count() FROM EmailMessage WHERE CSBD_Oportunidad_Id__c =: oportunidadTrasladoImagin.Id]>0, 'No se ha enviado ningún email');
		}
	}


	@IsTest
	public static void agendarFirmaApexTest() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
		Opportunity prestamo = crearOportunidadPrestamo(cuenta);
		prestamo.OwnerId = usuarioGestor.Id;
		update prestamo;
		Opportunity prestamo2 = crearOportunidadPrestamo(cuenta);
		datetime fecha = System.now();

		System.runAs ( usuarioGestor ) {
			Test.startTest();
			Event nuevoEvento = CSBD_Opportunity_Operativas_Controller.agendarFirmaApex(prestamo.id, true, fecha);
			Opportunity prestamoActualizado = [SELECT Id, CSBD_Fecha_Firma__c, CSBD_Firma_segura__c from Opportunity where Id =:prestamo.id];
			System.assertEquals(prestamoActualizado.CSBD_Fecha_Firma__c, fecha, 'No se ha actualizado la oportunidad correctamente');
			System.assertEquals(prestamoActualizado.CSBD_Firma_segura__c, true, 'No se ha actualizado la oportunidad correctamente');
			System.assertEquals([SELECT Id FROM Event WHERE Id = :nuevoEvento.Id].isEmpty(), false, 'No se ha creado el evento correctamente');

			 //Probar excepción
			try {
				CSBD_Opportunity_Operativas_Controller.agendarFirmaApex(prestamo2.Id, true, fecha);
			} catch (Exception e) {
				System.assertEquals('System.AuraHandledException', e.getTypeName(), 'Tipo incorrecto de excepción');
			}
			Test.stopTest();
		}
	}

	@IsTest
	public static void cancelarFirmaApexTest() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
		Opportunity prestamo = crearOportunidadPrestamo(cuenta);
		prestamo.OwnerId = usuarioGestor.Id;
		update prestamo;
		datetime fecha = System.now();

		System.runAs ( usuarioGestor ) {
			Test.startTest();
			Event nuevoEvento1 = CSBD_Opportunity_Operativas_Controller.agendarFirmaApex(prestamo.id, true, fecha);
			Event nuevoEvento = CSBD_Opportunity_Operativas_Controller.cancelarFirmaApex(prestamo.id);
			Opportunity prestamoActualizado = [SELECT Id, CSBD_Fecha_Firma__c, CSBD_Firma_segura__c from Opportunity where Id =:prestamo.id];
			System.assertEquals(prestamoActualizado.CSBD_Fecha_Firma__c, null, 'No se ha actualizado la oportunidad correctamente');
			System.assertEquals(prestamoActualizado.CSBD_Firma_segura__c, false, 'No se ha actualizado la oportunidad correctamente');
			System.assertEquals([SELECT Id,CSBD_Evento_Estado__c FROM Event WHERE Id = :nuevoEvento.Id][0].CSBD_Evento_Estado__c, 'Cancelado', 'No se ha actualizado el evento correctamente');
			Test.stopTest();
		}
	}

	@IsTest
	public static void checkPSResponsableTest() {
		PermissionSet psMock = new PermissionSet();
		psMock.Label = 'mockPs';
		psMock.Name = 'mockPs';
		insert psMock;

		List<CustomPermission> cpResponsable = [SELECT Id FROM CustomPermission
												WHERE DeveloperName = 'CSBD_Responsable' LIMIT 1];
		if (!cpResponsable.isEmpty()) {
			SetupEntityAccess sea = new SetupEntityAccess();
			sea.ParentId = psMock.Id;
			sea.SetupEntityId = cpResponsable[0].Id;
			insert sea;
		}

		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		PermissionSetAssignment psa = new PermissionSetAssignment();
		psa.AssigneeId = usuarioGestor.Id;
		psa.PermissionSetId = psMock.Id;
		insert psa;

		System.runAs(usuarioGestor) {
			Test.startTest();
			Map<String, Boolean> responsable = CSBD_Opportunity_Operativas_Controller.checkPSResponsable();
			if (!cpResponsable.isEmpty()) {
				System.assertEquals(responsable.get('esResponsable'), true, 'No tiene el custom permission Responsable');
			} else {
				System.assertEquals(responsable.get('esResponsable'), false, 'No se está comprpbando correctamente el custom permission');
			}
			Test.stopTest();
		}
	}

	@IsTest
	public static void checkCDPTest() {
		Account cuenta = [SELECT CC_Numero_Documento__c FROM Account LIMIT 1];
		Contact contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id LIMIT 1];

		Map<String, Object> campos = new Map<String, Object>();
		campos.put('Name', 'oportunidad de prueba');
		campos.put('CSBD_Estado__c', 'Activa');
		campos.put('StageName', 'Solicitud');
		campos.put('AccountId', cuenta.Id);
		campos.put('CSBD_Contact__c', contacto.Id);
		campos.put('CSBD_Now_NIF__c', cuenta.CC_Numero_Documento__c);
		Opportunity opp = CSBD_Opportunity.crearOportunidad('CSBD_PROAutomatica', campos);

		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
		System.runAs(usuarioGestor) {
			Test.startTest();
			Boolean cdpRT = CSBD_Opportunity_Operativas_Controller.checkCDP(opp.Id);
			System.assertEquals(cdpRT, true, 'No tiene record type PRO Autimática');
			Test.stopTest();
		}
	}

	@IsTest
	public static void ampliarVencimiento() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Account cuenta = [SELECT Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
		Datetime fechaActual = System.Now();

		System.runAs ( usuarioGestor ) {
			Opportunity oportunidad = new Opportunity();
			oportunidad.RecordTypeId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
			oportunidad.Name = 'Opportunity Test';
			oportunidad.StageName = 'Solicitud';
			oportunidad.AccountId = cuenta.Id;
			oportunidad.CSBD_Fecha_vencimiento_alta__c = fechaActual;
			insert oportunidad;

			Test.startTest();
			CSBD_Opportunity_Operativas_Controller.ampliarVencimiento(oportunidad.Id, fechaActual);
			Test.stopTest();
			Opportunity opp = [SELECT id, CSBD_Fecha_vencimiento_alta__c FROM Opportunity WHERE id = :oportunidad.Id LIMIT 1];
			System.assertEquals(fechaActual.addMonths(1), opp.CSBD_Fecha_vencimiento_alta__c);
		}
	}

	@IsTest
	private static void obtenerOportunidadesHijasAbiertasTest() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
		RecordType  accionComercialRT = [SELECT Id  FROM RecordType  WHERE DeveloperName   = 'CSBD_Accion_Comercial'];
		Account cuenta1 = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];

		Opportunity oportunidadTest = new Opportunity();
		oportunidadTest.Name='test';
		oportunidadTest.stageName='Solicitud';
		oportunidadTest.OwnerId = usuarioGestor.Id;
		insert oportunidadTest;

		Opportunity oportunidadTest1 = new Opportunity();
		oportunidadTest1.Name='test';
		oportunidadTest1.stageName='Solicitud';
		oportunidadTest1.CSBD_Parent_Id__c=oportunidadTest.Id;
		oportunidadTest1.RecordtypeId = accionComercialRT.Id;
		oportunidadTest1.AccountId=cuenta1.Id;
		oportunidadTest1.OwnerId = usuarioGestor.Id;
		insert oportunidadTest1;

		Opportunity oportunidadTest2 = new Opportunity();
		oportunidadTest2.Name='test';
		oportunidadTest2.stageName='Rechazada';
		oportunidadTest2.CSBD_Parent_Id__c=oportunidadTest1.Id;
		oportunidadTest2.RecordtypeId = accionComercialRT.Id;
		oportunidadTest2.AccountId=cuenta1.Id;
		oportunidadTest2.OwnerId = usuarioGestor.Id;
		insert oportunidadTest2;

		System.runAs(usuarioGestor) {
			Test.startTest();
			Boolean oportunidadesHijasAbiertas= CSBD_Opportunity_Operativas_Controller.obtenerOportunidadesHijas(oportunidadTest.Id);
			Boolean oportunidadesHijasAbiertas2= CSBD_Opportunity_Operativas_Controller.obtenerOportunidadesHijas(oportunidadTest1.Id);
			system.assert(oportunidadesHijasAbiertas==true, 'No hay oportunidades hijas abiertas');
			system.assert(oportunidadesHijasAbiertas2==false, 'Hay oportunidades hijas abiertas');
			Test.stopTest();
		}
	}



	@IsTest
	public static void obtenerResolucionesTest() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        
		CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
		listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Resoluciones').getRecordTypeId();
		listaValores.Name = 'Resolución Test';
		listaValores.CSBD_Tipo_de_oportunidad__c = 'Hipoteca';
		listaValores.CSBD_Etapa_Resolucion__c = 'Formalizada';
		listaValores.CC_Activa__c = true;
		System.runAs(usuarioGestor){
			insert listaValores;
		}

		CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
		valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
		valor.CC_Lista__c = listaValores.Id;
		valor.Name = 'Alta Cliente';
		valor.CC_Activa__c = true;
		System.runAs(usuarioGestor){
			insert valor;
		}

		System.runAs ( usuarioGestor ) {
			Test.startTest();
			List<String> resoluciones = CSBD_Opportunity_Operativas_Controller.obtenerResoluciones('Alta Cliente', 'Hipoteca', 'Formalizada');
			Test.stopTest();

			System.assertEquals(resoluciones[0], 'Resolución Test');
		}
	}

	@IsTest
	public static void crearTareaGestorTest() {
        
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorDerivar' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        List<Account> cuenta = [SELECT Id, Name, CC_Numero_Documento__c, Phone FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
        Contact contacto = [SELECT Id FROM Contact WHERE AccountId =: cuenta[0].Id];
        
        Product2 product = new Product2();
        product.Name = 'Producto de prueba';
        product.IsActive = true; 
        product.AV_ExternalID__c = '123456';
        insert product;
       
		Opportunity oportunidad = new Opportunity();
        oportunidad.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
		oportunidad.Name = 'Opportunity Test';
		oportunidad.StageName = 'Solicitud';
        oportunidad.OwnerId = usuarioGestor.Id;
        oportunidad.AccountId = cuenta[0].Id;
        oportunidad.AV_PF__c = product.id;
		insert oportunidad;
        
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta[0].Id;
        update contacto;
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Id = :oportunidad.Id   LIMIT 2]; 
        
		System.runAs(usuarioGestor) {
			Test.startTest();
            CSBD_Opportunity_Operativas_Controller.crearTareaGestor(oportunidad.Id, 'U0123456789',contacto.id, 'Test');
			Test.stopTest();
        }
                    
        List<Opportunity> oportunidadGestor = [SELECT Id FROM Opportunity WHERE Name = 'Rema Gestor - CSBD' LIMIT 2];
		System.assertEquals(oportunidadGestor.size(), 1);
		
	}
   
		@IsTest
    	public static void crearTareaGestorTestSinGestor() {
        
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorDerivar' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        List<Account> cuenta = [SELECT Id, Name, CC_Numero_Documento__c, Phone FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
        Contact contacto = [SELECT Id FROM Contact WHERE AccountId =: cuenta[0].Id];
		User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND Profile.Name = 'System Administrator' LIMIT 1];
      
			Product2 product = new Product2();
        	product.Name = 'Producto de prueba';
        	product.IsActive = true; 
        	product.AV_ExternalID__c = '123456';
        	insert product;
            
		Opportunity oportunidad = new Opportunity();
        oportunidad.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Prestamo').getRecordTypeId();
		oportunidad.Name = 'Opportunity Test';
		oportunidad.StageName = 'Solicitud';
        oportunidad.OwnerId = usuarioGestor.Id;
        oportunidad.AccountId = cuenta[0].Id;
        oportunidad.AV_PF__c = product.id;
		insert oportunidad;
       //Contacto y user genéricos
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta[0].Id;
        contacto.CC_Matricula__c = '000000';
        update contacto;
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Id = :oportunidad.Id   LIMIT 2]; 
            
         System.runAs(usuarioAdmin) {
            User gestor = new User();
            gestor.FirstName = 'GestorCSBD';
            gestor.LastName = '1';
            gestor.IsActive = true;
            gestor.Alias = 'Gestor';
            gestor.Email = 'usuario_test@test.com';
            gestor.EmailEncodingKey = 'ISO-8859-1';
            gestor.LanguageLocaleKey = 'es';
            gestor.LocaleSidKey = 'es_ES';
            gestor.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CSBD Genérico'].Id;
            gestor.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSBD Gestor'].Id;
            gestor.TimeZoneSidKey = 'Europe/Madrid';
            gestor.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
        	gestor.AV_ExternalID__c = '000000';
            insert gestor;
         }
      
        		
		System.runAs(usuarioGestor) {
			Test.startTest();
            CSBD_Opportunity_Operativas_Controller.crearTareaGestor(oportunidad.Id, '','', 'Test');
			Test.stopTest();
        }
                    
        List<Opportunity> oportunidadGestor = [SELECT Id FROM Opportunity WHERE Name = 'Rema Gestor - CSBD' LIMIT 2];
		System.assertEquals(oportunidadGestor.size(), 1);
		
	}

	@IsTest
	public static void convertirOportunidadTest() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

		Account cuenta = [SELECT Id, Name, CC_Numero_Documento__c FROM Account WHERE CC_Numero_Documento__c = '12345678N'];
		Opportunity prestamo = crearOportunidadPrestamo(cuenta);

		System.runAs ( usuarioGestor ) {
			Test.startTest();
			Opportunity oportunidadDuplicada = CSBD_Opportunity_Operativas_Controller.convertirOportunidad(prestamo, 'CSBD_Prestamo');
			oportunidadDuplicada = [SELECT CSBD_Parent_Id__c FROM Opportunity WHERE Id = :oportunidadDuplicada.Id];
			System.assertEquals(prestamo.id, oportunidadDuplicada.CSBD_Parent_Id__c, 'No existe una oportunidad hija');

			//Probar excepción
			try {
				CSBD_Opportunity_Operativas_Controller.convertirOportunidad(prestamo, 'recordTypeInexistente');
			} catch (Exception e) {
				System.assertEquals('System.AuraHandledException', e.getTypeName(), 'Tipo incorrecto de excepción');
			}
			Test.stopTest();
		}
	}

	@IsTest
	public static void obtenerEntidadesTest() {
		User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        
		CC_Lista_Valores__c listaValoresEntidades = new CC_Lista_Valores__c();
		listaValoresEntidades.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
		listaValoresEntidades.Name = 'CSBD: Entidades competencia';
		listaValoresEntidades.CC_Activa__c = true;
		System.runAs(usuarioGestor){
			insert listaValoresEntidades;
		}
        
        CC_Lista_Valores__c valorEntidad = new CC_Lista_Valores__c();
		valorEntidad.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
		valorEntidad.CC_Lista__c = listaValoresEntidades.Id;
		valorEntidad.Name = 'Entidad prueba';
		valorEntidad.CC_Activa__c = true;
		System.runAs(usuarioGestor){
			insert valorEntidad;
		}

		System.runAs ( usuarioGestor ) {
			Test.startTest();
			List<String> resoluciones = CSBD_Opportunity_Operativas_Controller.obtenerEntidades();
			Test.stopTest();
			System.assertEquals(resoluciones[0], 'Entidad prueba');
		}
	}
}