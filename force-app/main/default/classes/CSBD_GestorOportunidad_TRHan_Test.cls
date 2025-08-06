@isTest
public class CSBD_GestorOportunidad_TRHan_Test {

	@TestSetup
	private static void altaDatosPrueba() {
		User userAdmin = CSBD_TestDataFactory.usuarioAdministrador();
		System.runAs(userAdmin) {
			insert new Pricebook2(Name = 'CSBD Price Book', Description = 'CSBD Price Book', IsActive = true);

			if ([SELECT COUNT() FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CSBD_Prestamos_I'] == 0) {
				insert new Group(Name = 'Now In Sales - Préstamos I', DeveloperName = 'CSBD_Prestamos_I', Type = 'Queue');
			}

			CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
			listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
			listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
			insert listaValores;

			CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
			valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
			valor.CC_Lista__c = listaValores.Id;
			valor.Name = 'Consumo';
			valor.CC_Valor__c = '1';
			insert valor;

			Id idRecordTypeReglaAsignacion = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Regla_asignacion_oportunidad').getRecordTypeId();
			CC_Lista_Valores__c reglaAsignacion = new CC_Lista_Valores__c();
			reglaAsignacion.RecordTypeId = idRecordTypeReglaAsignacion;
			reglaAsignacion.Name = 'Oportunidades - Consumos I';
			reglaAsignacion.CSBD_Cola_Oportunidad__c = 'CSBD_Prestamos_I';
			reglaAsignacion.CSBD_Tipo_de_oportunidad__c = 'Consumo';
			reglaAsignacion.CC_Orden__c = 1;
			reglaAsignacion.CC_Activa__c = true;
			CC_Lista_Valores__c reglaAsignacion2 = new CC_Lista_Valores__c();
			reglaAsignacion2.RecordTypeId = idRecordTypeReglaAsignacion;
			reglaAsignacion2.Name = 'Oportunidades - Hipotecas';
			reglaAsignacion2.CSBD_Cola_Oportunidad__c = 'CSBD_Hipotecas';
			reglaAsignacion2.CSBD_Tipo_de_oportunidad__c = 'CMB;CMN;Hipoteca';
			reglaAsignacion2.CC_Orden__c = 3;
			reglaAsignacion2.CC_Activa__c = true;
			insert new List<CC_Lista_Valores__c>{reglaAsignacion, reglaAsignacion2};
		}
	}

	private static Account crearCuentaContacto(String nif) {
		Account cuenta = new Account();
		cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		cuenta.Name = 'test@test.com';
		cuenta.CC_Numero_Documento__c = nif;
		cuenta.Phone = '666666666';
		insert cuenta;
		Contact contacto = new Contact();
		contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		contacto.Email = 'test@test.com';
		contacto.Phone = '666666666';
		contacto.FirstName = 'Nombre';
		contacto.LastName = 'Apellido';
		contacto.AccountId = cuenta.Id;
		contacto.CSBD_Limite_Prestamos_Oficinas__c = 20000;
		insert contacto;
		return cuenta;
	}

	@isTest
	private static void gestorOportunidadInsert() {
		Account cuenta = crearCuentaContacto('53456777P');
		User userAdmin = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
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

		System.runAs (userAdmin) {
			Test.startTest();
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
			CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad}, 'Pendiente de asignar');
			Test.stopTest();

			CSBD_Gestor_Oportunidad__c gestorOpp = [SELECT OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c
													WHERE CSBD_Oportunidad__c = :oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];
			System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Prestamos_I' LIMIT 1].Id, gestorOpp.OwnerId, 'El propietario no es el grupo de Consumo I');
			System.assertEquals('Activo', gestorOpp.CSBD_Estado__c, 'El estado no es activo');
		}
	}

	@isTest
	private static void gestorOportunidadUpdate() {
		Account cuenta = crearCuentaContacto('53456777P');

		System.runAs((User)[SELECT Id FROM User WHERE FirstName = 'AdminCSBD']) {
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
				'AccountId' => cuenta.Id,
				'CSBD_Contact__c' => [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id,
				'CSBD_Now_NIF__c' => cuenta.CC_Numero_Documento__c,
				'CSBD_Horario_Contacto__c' => 'Mañana',
				'CSBD_Idioma_Solicitud__c' => 'Castellano',
				'CSBD_Familia_Producto__c' => 'Cuentas',
				'CSBD_Empresa_Proveedora__c' => 'CaixaBank',
				'CSBD_Importe_Producto_Principal__c' => 200
			});

			Test.startTest();
			CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad}, 'Fuera horario comercial');
			CSBD_Gestor_Oportunidad__c gestorOportunidad = [SELECT Id FROM CSBD_Gestor_Oportunidad__c
															WHERE CSBD_Oportunidad__c = :oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];
			gestorOportunidad.CSBD_Estado__c = 'Pendiente de asignar';
			update gestorOportunidad;
			Test.stopTest();

			CSBD_Gestor_Oportunidad__c gestorOpp = [SELECT OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c
													WHERE CSBD_Oportunidad__c = :oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];
			System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Prestamos_I' LIMIT 1].Id, gestorOpp.OwnerId, 'El propietario no es el grupo de Consumo I');
			System.assertEquals('Activo', gestorOpp.CSBD_Estado__c, 'El estado no es activo');
		}
	}

	@isTest
	private static void gestorOportunidadInsert2() {
		Account cuenta = crearCuentaContacto('53456777P');
		User userAdmin = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
		Map<String, Object> campos = new Map<String, Object>();
		campos.put('Name', 'oportunidad de prueba2');
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

		System.runAs (userAdmin) {
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
			Test.startTest();
			CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad}, '');
			Test.stopTest();

			CSBD_Gestor_Oportunidad__c gestorOportunidad = [SELECT OwnerId, CSBD_Estado__c FROM CSBD_Gestor_Oportunidad__c
															WHERE CSBD_Oportunidad__c = :oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];
			System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Prestamos_I' LIMIT 1].Id, gestorOportunidad.OwnerId, 'El propietario no es el grupo de Consumo I');
			System.assertEquals('Activo', gestorOportunidad.CSBD_Estado__c, 'El estado no es activo');
		}
	}

	@isTest
	private static void gestorOportunidadSincronizar() {
		Account cuenta = crearCuentaContacto('53456777P');
		User userAdmin = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
		Map<String, Object> campos = new Map<String, Object>();
		campos.put('Name', 'oportunidad de prueba3');
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

		System.runAs(userAdmin) {
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);

			Test.startTest();
			CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad}, '');
			List<CSBD_Gestor_Oportunidad__c> gestoresOpp = [SELECT CSBD_Oportunidad__c, OwnerId,
															CSBD_Hora_inicio_contacto__c, CSBD_Hora_fin_contacto__c
															FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c = :oportunidad.Id
															ORDER BY CreatedDate DESC LIMIT 1];
			CSBD_GestorOportunidad.sincronizarGestorOportunidad(new List<Opportunity>{oportunidad}, gestoresOpp, '');
			Test.stopTest();

			System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Prestamos_I' LIMIT 1].Id, gestoresOpp[0].OwnerId, 'El propietario no es el grupo de Consumo I');
		}
	}

	@isTest
	private static void gestorOportunidadDesactivar() {
		Account cuenta = crearCuentaContacto('53456777P');
		User userAdmin = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
		Map<String, Object> campos = new Map<String, Object>();
		campos.put('Name', 'oportunidad de prueba4');
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

		System.runAs(userAdmin) {
			Test.startTest();
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
			CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad}, '');
			CSBD_GestorOportunidad.desactivarGestorOportunidad(oportunidad.Id);
			Test.stopTest();

			CSBD_Gestor_Oportunidad__c gestorOportunidad = [SELECT OwnerId FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c =: oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];
			System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Prestamos_I' LIMIT 1].Id, gestorOportunidad.OwnerId, 'El propietario no es el grupo de Consumo I');
		}
	}

	@isTest
	private static void gestorOportunidadActivar() {
		Account cuenta = crearCuentaContacto('53456777P');
		User userAdmin = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];

		Map<String, Object> campos = new Map<String, Object>();
		campos.put('Name', 'oportunidad de prueba4');
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

		System.runAs (userAdmin) {
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
			Test.startTest();
			CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad});
			CSBD_GestorOportunidad.activarGestorOportunidad(oportunidad.Id);
			Test.stopTest();

			CSBD_Gestor_Oportunidad__c gestorOportunidad = [SELECT OwnerId FROM CSBD_Gestor_Oportunidad__c
															WHERE CSBD_Oportunidad__c = :oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];
			System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Prestamos_I' LIMIT 1].Id, gestorOportunidad.OwnerId, 'El propietario no es el grupo de Consumo I');
		}
	}

	@isTest
	private static void gestorOportunidadPrioridad() {
		Contact contacto = (Contact)CSBD_TestDataFactory.crearCuentaContacto('53456777P').get('contacto');

		System.runAs((User)[SELECT Id FROM User WHERE FirstName = 'AdminCSBD']) {
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', new Map<String, Object>{
				'AccountId' => contacto.AccountId,
				'CSBD_Contact__c' => contacto.Id,
				'CSBD_Horario_Contacto__c' => 'Mañana',
				'CSBD_Idioma_Solicitud__c' => 'Castellano',
				'CSBD_Familia_Producto__c' => 'Hipotecas',
				'CSBD_Empresa_Proveedora__c' => 'CaixaBank',
				'CSBD_Importe_Producto_Principal__c' => 200
			});

			Test.startTest();
			CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{oportunidad});
			CSBD_GestorOportunidad.activarGestorOportunidad(oportunidad.Id);
			Test.stopTest();

			CSBD_Gestor_Oportunidad__c gestorOportunidad = [SELECT OwnerId, CSBD_OC_Prioridad__c FROM CSBD_Gestor_Oportunidad__c
															WHERE CSBD_Oportunidad__c = :oportunidad.Id ORDER BY CreatedDate DESC LIMIT 1];

			System.assertEquals([SELECT Id FROM Group WHERE DeveloperName = 'CSBD_Hipotecas' LIMIT 1].Id, gestorOportunidad.OwnerId, 'El propietario no es el grupo de hipotecas');
			System.assert(gestorOportunidad.CSBD_OC_Prioridad__c != null, 'La prioridad no puede ser null');
		}
	}
}