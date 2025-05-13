@IsTest
public class CSBD_DetectarOportunidadesSimilaresTest {

	@TestSetup
	public static void testSetup() {
		User usuarioAdministrador = CSBD_TestDataFactory.usuarioAdministrador();

		System.runAs(usuarioAdministrador) {
			 // Crear configuración personalizada
			CSBD_IdentificarOppsPHDSetting__c setting = new CSBD_IdentificarOppsPHDSetting__c();
			setting.CSBD_Dias__c = 90;
			setting.CSBD_Stages__c = 'Rechazada';
			setting.CSBD_EnvioCorreo__c = true;
			setting.CSBD_PlantillaCorreoPHD__c = 'PlantillaPrueba';
			setting.CSBD_PlantillaCorreoFacilitea__c = 'PlantillaFaciliteaPrueba';
			insert setting;

			// Plantilla para PHD
			EmailTemplate plantillaPHD = new EmailTemplate();
			plantillaPHD.DeveloperName = 'PlantillaPrueba';
			plantillaPHD.Name = 'Plantilla Prueba PHD';
			plantillaPHD.TemplateType = 'custom';
			plantillaPHD.FolderId = usuarioAdministrador.Id;
			plantillaPHD.Subject = 'Prueba PHD';
			plantillaPHD.HtmlValue = '<p>Test</p>';
			plantillaPHD.IsActive = true;
			// Plantilla para Facilitea
			EmailTemplate plantillaFacilitea = new EmailTemplate();
			plantillaFacilitea.DeveloperName = 'PlantillaFaciliteaPrueba';
			plantillaFacilitea.Name = 'Plantilla Prueba Facilitea';
			plantillaFacilitea.TemplateType = 'custom';
			plantillaFacilitea.FolderId = usuarioAdministrador.Id;
			plantillaFacilitea.Subject = 'Prueba Facilitea';
			plantillaFacilitea.HtmlValue = '<p>Test</p>';
			plantillaFacilitea.IsActive = true;
			insert new List<EmailTemplate>{plantillaPHD, plantillaFacilitea};

			Map<String, Object> cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('12345678A', new Map<String, Object>{
				'FirstName' => 'TestPHD',
				'LastName' => 'Test',
				'Email' => 'test@test.com',
				'CC_Numero_Documento__c' => '12345678A'
			});

			CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', new Map<String, Object>{
				'AccountId' => ((Account)cuentaContacto.get('cuenta')).Id,
				'CSBD_Contact__c' => ((Contact)cuentaContacto.get('contacto')).Id,
				'CSBD_Now_NIF__c' => '12345678A',
				'CSBD_Canal__c' => 'Plataformas Hipotecarias Digitales',
				'CSBD_Now_Origen__c' => 'Plataformas Hipotecarias Digitales',
				'StageName' => 'Solicitud'
			});
		}
	}

	@IsTest
	private static void testBuscarOportunidadSimilaresPHD() {
		User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];

		System.runAs(usuarioAdministrador) {
			Test.startTest();
			CSBD_DetectarOportunidadesSimilares detector = new CSBD_DetectarOportunidadesSimilares(new List<String>{'12345678A'}, 'TEST-123', 'Origen Test');
			Map<String, Object> resultado = detector.buscarOportunidadSimilares();
			Test.stopTest();
			// Verificar resultados
			System.assert(resultado.get('success'), 'La búsqueda debería ser exitosa');
			System.assert(resultado.get('existLead'), 'Debería encontrar una oportunidad existente');
		}
	}

	@IsTest
	private static void testBuscarOportunidadSimilaresFacilitea() {
		User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];

		System.runAs(usuarioAdministrador) {
			// crear contacto
			Contact contacto = new Contact();
			contacto.FirstName = 'TestFacilitea';
			contacto.LastName = 'Test';
			contacto.Email = 'test@test.com';
			contacto.CC_Numero_Documento__c = '12345678B';
			insert contacto;
			// Crear oportunidad PHD
			Map<String, Object> campos = new Map<String, Object>();
			campos.put('CSBD_Contact__c', contacto.Id);
			campos.put('CSBD_Now_NIF__c', '12345678B');
			campos.put('CSBD_Now_Origen__c', 'faciliteacasa');
			campos.put('CSBD_Canal__c', 'faciliteacasa');
			campos.put('StageName', 'Perdida');
			Opportunity hipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);
			// Ejecutar búsqueda
			Test.startTest();
			CSBD_DetectarOportunidadesSimilares detector = new CSBD_DetectarOportunidadesSimilares(new List<String>{'12345678B'}, 'TEST-123', 'Origen Test');
			Map<String, Object> resultado = detector.buscarOportunidadSimilares();
			Test.stopTest();
			// Verificar resultados
			System.assert(resultado.get('success'), 'La búsqueda debería ser exitosa');
			System.assert(resultado.get('existLead'), 'Debería encontrar una oportunidad existente');
		}
	}


	@IsTest
	private static void testBuscarOportunidadSimilaresSinDocumento() {
		User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
		System.runAs(usuarioAdministrador) {
			// Probar con documentId nulo
			Test.startTest();
			CSBD_DetectarOportunidadesSimilares detector = new CSBD_DetectarOportunidadesSimilares(null, 'TEST-123', 'Origen Test');
			Map<String, Object> resultado = detector.buscarOportunidadSimilares();
			Test.stopTest();

			// Verificar resultados
			System.assert(!resultado.get('success'), 'La búsqueda debería fallar');
			System.assertEquals(CSBD_DetectarOportunidadesSimilares.ERROR_DOCUMENT_ID_REQUEST_PRESCRIBER_ID, resultado.get('error'), 'Debería mostrar el mensaje de error correcto');
		}
	}

	@IsTest
	private static void testBuscarOppimilaresContactoNoExiste() {
		User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];

		System.runAs(usuarioAdministrador) {
			// Probar con documentId nulo
			CSBD_DetectarOportunidadesSimilares detector = CSBD_DetectarOportunidadesSimilares.getInstance(new List<String>{'1234'}, 'TEST-123', 'Origen Test');
			Map<String, Object> resultado = detector.buscarOportunidadSimilares();

			// Verificar resultados
			System.assert(resultado.get('success'), 'La búsqueda debería estar bien');
			System.assert(!resultado.get('existLead'), 'No debe encontrar lead');
		}

	}

	@IsTest
	private static void testSeleccionPrioridad() {
		User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
		System.runAs(usuarioAdministrador) {
			// crear contacto
			Contact contacto = [SELECT Id FROM Contact WHERE CC_Numero_Documento__c = '12345678A'];

			//crear opp facilitea
			Map<String, Object> campos2 = new Map<String, Object>();
			campos2.put('CSBD_Contact__c', contacto.Id);
			campos2.put('CSBD_Now_NIF__c', '12345678A');
			campos2.put('CSBD_Canal__c', 'faciliteacasa');
			campos2.put('CSBD_Now_Origen__c', 'faciliteacasa');
			campos2.put('StageName', 'Solicitud');
			Opportunity hipoteca2 = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos2);

			Test.startTest();
			CSBD_DetectarOportunidadesSimilares detector = new CSBD_DetectarOportunidadesSimilares(new List<String>{'12345678A'}, 'TEST-123', 'Origen Test');
			Map<String, Object> resultado = detector.buscarOportunidadSimilares();
			Test.stopTest();

			System.assert(resultado.get('success'), 'La búsqueda debería ser exitosa');
			System.assertNotEquals(null, resultado.get('opportunityId'), 'Debería encontrar una oportunidad');
		}
	}

	@IsTest
	private static void testSeleccionPrioridadOppCerrada() {
		User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];

		System.runAs(usuarioAdministrador) {
			// crear contacto
			Contact contacto = [SELECT Id FROM Contact WHERE CC_Numero_Documento__c = '12345678A'];
			// Crear oportunidad PHD
			Opportunity oppCreada = [SELECT Id FROM Opportunity WHERE CSBD_Now_NIF__c = '12345678A' LIMIT 1];
			CSBD_Opportunity.cerrarOportunidad(oppCreada.Id, 'Perdida', 'Test');

			//crear opp
			Map<String, Object> campos = new Map<String, Object>();
			campos.put('CSBD_Contact__c', contacto.Id);
			campos.put('CSBD_Now_NIF__c', '12345678A');
			campos.put('CSBD_Canal__c', 'Plataformas Hipotecarias Digitales');
			campos.put('CSBD_Now_Origen__c', 'Plataformas Hipotecarias Digitales');
			campos.put('StageName', 'Solicitud');
			Opportunity hipoteca2 = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);

			Test.startTest();
			CSBD_DetectarOportunidadesSimilares detector = new CSBD_DetectarOportunidadesSimilares(new List<String>{'12345678A'}, 'TEST-123', 'Origen Test');
			Map<String, Object> resultado = detector.buscarOportunidadSimilares();
			Test.stopTest();

			System.assert(resultado.get('success'), 'La búsqueda debería ser exitosa');
			System.assertNotEquals(null, resultado.get('opportunityId'), 'Debería encontrar una oportunidad');
		}
	}

	@IsTest
	private static void testSinPlantillaPHD() {
		User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];

		System.runAs(usuarioAdministrador) {
			CSBD_IdentificarOppsPHDSetting__c setting = [
				SELECT Id
				FROM CSBD_IdentificarOppsPHDSetting__c
				LIMIT 1
			];
			setting.CSBD_PlantillaCorreoPHD__c = 'NoExiste';
			update setting;
  // Ejecutar búsqueda
			Test.startTest();
			CSBD_DetectarOportunidadesSimilares detector = CSBD_DetectarOportunidadesSimilares.getInstance(new List<String>{'12345678A'}, 'TEST-123', 'Origen Test');
			Map<String, Object> resultado = detector.buscarOportunidadSimilares();
			Test.stopTest();

			System.assert(resultado.get('success'), 'La búsqueda debería ser exitosa');

		}
	}

	@IsTest
	private static void testSinPlantillasConfigurada() {
		User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];

		System.runAs(usuarioAdministrador) {
			CSBD_IdentificarOppsPHDSetting__c setting = [SELECT Id FROM CSBD_IdentificarOppsPHDSetting__c LIMIT 1];
			setting.CSBD_PlantillaCorreoPHD__c = '';
			setting.CSBD_PlantillaCorreoFacilitea__c = '';
			update setting;

			// Ejecutar búsqueda
			Test.startTest();
			CSBD_DetectarOportunidadesSimilares detector = CSBD_DetectarOportunidadesSimilares.getInstance(new List<String>{'12345678A'}, 'TEST-123', 'Origen Test');
			Map<String, Object> resultado = detector.buscarOportunidadSimilares();
			Test.stopTest();

			System.assert(resultado.get('success'), 'La búsqueda debería ser exitosa');
		}
	}
}