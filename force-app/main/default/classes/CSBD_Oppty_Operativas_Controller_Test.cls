@IsTest
public class CSBD_Oppty_Operativas_Controller_Test { //Nombre abreviado porque Apex tiene un límite de carácteres

	@TestSetup
	private static void altaDatosPrueba() {
		System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
			Pricebook2 pricebook = new Pricebook2(Name = 'CSBD Price Book', Description = 'CSBD Price Book Test', IsActive = true);

			CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
			listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
			listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';

			insert new List<SObject>{pricebook, listaValores};

			CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
			valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
			valor.CC_Lista__c = listaValores.Id;
			valor.Name = 'Consumo';
			valor.CC_Valor__c = '1';

			CC_Lista_Valores__c reglaAsignacion = new CC_Lista_Valores__c();
			reglaAsignacion.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_Regla_asignacion_oportunidad').getRecordTypeId();
			reglaAsignacion.Name = 'Oportunidades - Consumos I';
			reglaAsignacion.CSBD_Cola_Oportunidad__c = 'CSBD_Prestamos_I';
			reglaAsignacion.CSBD_Tipo_de_oportunidad__c = 'Consumo';
			reglaAsignacion.CC_Orden__c = 1;
			reglaAsignacion.CC_Activa__c = true;

			CBK_IntegrationSetting__c integrationSetting = new CBK_IntegrationSetting__c();
			integrationSetting.Name = 'CSBD_WS_Adobe';
			integrationSetting.NamedCredential__c = 'callout:CSBD_WS_CredentialAdobe/{PARAMS_1}/{PARAMS_2}/{PARAMS_3}/{PARAMS_4}';

			insert new List<SObject>{valor, reglaAsignacion, integrationSetting};

			if ([SELECT Count() FROM Group WHERE DeveloperName = 'CSBD_Prestamos_I' LIMIT 1] == 0) {
				insert new Group(Name = 'Now In Sales - Préstamos I', DeveloperName = 'CSBD_Prestamos_I', Type = 'Queue');
			}
		}
	}

	@IsTest
	private static void subdirectoriosPlantillasTest() {
		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			Test.startTest();
			List<Folder> carpetas = CSBD_Opportunity_Operativas_Controller.subdirectorios('CSBD_Operativas');
			List<EmailTemplate> plantillas = CSBD_Opportunity_Operativas_Controller.plantillas('CSBD_Operativas_SolInfo_ESP_Formal');
			Test.stopTest();

			System.assert(carpetas != null, 'Problema recuperando lista de subdirectorios');
			System.assert(plantillas != null, 'Problema recuperando lista de plantillas');
		}
	}

	@IsTest
	private static void plantillaCuerpoTest() {
		System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
			User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
			System.runAs(usuarioGestor) {
				EmailTemplate plantilla = new EmailTemplate();
				plantilla.DeveloperName = 'CSBD_Plantilla_Test';
				plantilla.Name = 'CSBD Plantilla Test';
				plantilla.TemplateType = 'custom';
				plantilla.FolderId = usuarioGestor.Id; //Indica que la plantilla se crea en la carpeta personal del usuario
				plantilla.Subject = 'CSBD Plantilla Test';
				plantilla.HtmlValue = '<b>CSBD</b> <i>Plantilla</i> <u>Test</u>';
				insert plantilla;
			}

			System.runAs(usuarioGestor) {
				Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');

				Test.startTest();
				String cuerpoPlantillaHTML = CSBD_Opportunity_Operativas_Controller.plantillaCuerpo('CSBD_Plantilla_Test', false, prestamo.Id);
				String cuerpoPlantillaTextoPlano = CSBD_Opportunity_Operativas_Controller.plantillaCuerpo('CSBD_Plantilla_Test', true, prestamo.Id);
				Test.stopTest();

				//Evaluación del resultado de la prueba
				System.assertEquals('<b>CSBD</b> <i>Plantilla</i> <u>Test</u>', cuerpoPlantillaHTML, 'HTML incorrecto');
				System.assertEquals('CSBD Plantilla Test', cuerpoPlantillaTextoPlano, 'Texto plano incorrecto');
			}
		}
	}

	@IsTest
	private static void prepararOportunidadParaEnvioCorreoTest() {
		User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
		System.runAs(usuarioGestor) {
			EmailTemplate plantilla = new EmailTemplate();
			plantilla.DeveloperName = 'CSBD_Plantilla_Test';
			plantilla.Name = 'CSBD Plantilla Test';
			plantilla.TemplateType = 'custom';
			plantilla.FolderId = usuarioGestor.Id; //Indica que la plantilla se crea en la carpeta personal del usuario
			plantilla.Subject = 'CSBD Plantilla Test';
			plantilla.HtmlValue = '<b>CSBD</b> <i>Plantilla</i> <u>Test</u>';
			insert plantilla;

			Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{'CSBD_Telefono_Solicitud__c' => '623456789'});

			Test.startTest();
			CSBD_Opportunity_Operativas_Controller.prepararOportunidadParaEnvioCorreo(prestamo.Id, 'CSBD_Plantilla_Test', true, true);
			prestamo = [SELECT CSBD_Plantilla_Correo__c, CSBD_Referencia_Correo_Saliente__c FROM Opportunity WHERE Id = :prestamo.Id];
			Test.stopTest();

			System.assertEquals('CSBD_Plantilla_Test', prestamo.CSBD_Plantilla_Correo__c, 'Plantilla incorrecta');
			System.assertEquals(17, prestamo.CSBD_Referencia_Correo_Saliente__c.length(), 'Referencia de correo incorrecta');
		}
	}

	@IsTest
	public static void numeroOportunidadesAnterioresTest() {
		Account cuenta;
		System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
			cuenta = (Account)(CSBD_TestDataFactory.crearCuentaContacto('12345678N')).get('cuenta');
		}

		User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
		PermissionSetAssignment psAdmin = new PermissionSetAssignment();
		psAdmin.PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'CSBD_PS_Administrador'].Id;
		psAdmin.AssigneeId = usuarioGestor.Id;
		insert psAdmin; //Para poder editar oportunidades cerradas

		System.runAs(usuarioGestor) {
			List<Opportunity> hipotecas = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', new List<Map<String, Object>>{
				new Map<String, Object>{'AccountId' => cuenta.Id},
				new Map<String, Object>{'AccountId' => cuenta.Id},
				new Map<String, Object>{'AccountId' => cuenta.Id},
				new Map<String, Object>{'AccountId' => cuenta.Id}
			});
			/*
			prestamos[0] = CSBD_Opportunity.cerrarOportunidad(prestamos[0].Id, 'Perdida', 'Resolución perdida');
			prestamos[1] = CSBD_Opportunity.cerrarOportunidad(prestamos[1].Id, 'Perdida', 'Resolución perdida');
			prestamos[2] = CSBD_Opportunity.cerrarOportunidad(prestamos[2].Id, 'Perdida', 'Resolución perdida');
			prestamos[3] = CSBD_Opportunity.cerrarOportunidad(prestamos[3].Id, 'Perdida', 'Resolución perdida');
			*/

			hipotecas = CSBD_Opportunity.cerrarOportunidad(hipotecas, 'Perdida', 'Resolución perdida');

			Date hoy = System.today();
			hipotecas[0].CloseDate = hoy.addDays(-360);
			hipotecas[1].CloseDate = hoy.addDays(-25);
			hipotecas[2].CloseDate = hoy.addDays(-25);
			update new List<Opportunity>{hipotecas[0], hipotecas[1], hipotecas[2]};

			Test.startTest();
			Map<String, String> oppsAnteriores = CSBD_Opportunity_Operativas_Controller.numeroOportunidadesAnteriores(cuenta.Id, 'CSBD_Hipoteca');
			Test.stopTest();

			System.assertEquals('Hipotecas recientes', oppsAnteriores.get('titulo'), 'Título incorrecto');
			System.assertEquals('Solicitados en los últimos 365 días: 4\nDenegados últimos 365 días: 4\nDenegados últimos 30 días: 3', oppsAnteriores.get('mensaje'), 'Mensaje incorrecto');
		}
	}

	@IsTest
	public static void cerrarReactivarOportunidadTest() {
		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');

			Test.startTest();
			prestamo = CSBD_Opportunity_Operativas_Controller.cerrarOportunidad(prestamo.Id, 'Formalizada', 'Tarjeta crédito');
			System.assertEquals('Cerrada', prestamo.CSBD_Estado__c, 'Problema cerrando la oportunidad');

			prestamo = CSBD_Opportunity_Operativas_Controller.reactivarOportunidad(prestamo.Id, 'Solicitud');
			System.assertEquals('Solicitud', prestamo.StageName, 'Etapa de ventas incorrecta');
			System.assertEquals('Activa', prestamo.CSBD_Estado__c, 'Estado incorrecto');

			prestamo = CSBD_Opportunity_Operativas_Controller.cerrarOportunidad(prestamo.Id, 'Formalizada', 'Tarjeta crédito', '{}');
			System.assertEquals('Cerrada', prestamo.CSBD_Estado__c, 'Problema cerrando la oportunidad');
			Test.stopTest();
		}
	}

	@IsTest
	private static void recordTypesOportunidadCsbdTest() {
		List<Map<String, String>> recordTypes = new List<Map<String, String>>();
		for (RecordType recordType: [SELECT DeveloperName, Name FROM RecordType
										WHERE SobjectType = 'Opportunity' AND DeveloperName LIKE 'CSBD_%']) {
			Map<String, String> rt = new Map<String, String>();
			rt.put('Name', recordType.Name);
			rt.put('DeveloperName', recordType.DeveloperName);
			recordTypes.add(rt);
		}

		User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
		System.runAs(usuarioGestor) {
			Test.startTest();
			List<Map<String, String>> retorno = CSBD_Opportunity_Operativas_Controller.recordTypesOportunidadCSBD();
			Test.stopTest();

			System.assertEquals(recordTypes, retorno, 'Lista de record types de oportunidades CSBD incorrecta');
		}
	}

	@IsTest
	private static void pluralRecordTypeNameTest() {
		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			System.assertEquals('Hipotecas', CSBD_Opportunity_Operativas_Controller.pluralRecordTypeName('CSBD_Hipoteca'), 'Plural incorrecto');
			System.assertEquals('CMN', CSBD_Opportunity_Operativas_Controller.pluralRecordTypeName('CSBD_CMN'), 'Plural incorrecto');
			System.assertEquals('Acciones comerciales', CSBD_Opportunity_Operativas_Controller.pluralRecordTypeName('CSBD_Accion_Comercial'), 'Plural incorrecto');
		}
	}

	@IsTest
	private static void enviarNotificacinPushSMSTest() {
		Account cuenta;
		System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
			cuenta = (Account)(CSBD_TestDataFactory.crearCuentaContacto('12345678N')).get('cuenta');
		}

		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
				'AccountId' => cuenta.Id, 'CSBD_Contact__c' => [SELECT Id FROM Contact WHERE AccountId = :cuenta.Id].Id, 'CSBD_Now_NIF__c' => cuenta.CC_Numero_Documento__c
			});

			Test.startTest();
			CSBD_Opportunity_Operativas_Controller.enviarNotificacinPushSMS(prestamo.Id, cuenta.Phone, 'cuerpo sms');
			Test.stopTest();

			String estadoTarea = [SELECT Status FROM Task WHERE WhatId = :prestamo.Id AND Type = 'Notificación - Salida' LIMIT 1]?.Status ?? null;
			System.assertEquals('Completed', estadoTarea, 'Estado incorrecto');
		}
	}

	/*
	@IsTest
	private static void programarCitaTest() {
		User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
		System.runAs(usuarioGestor) {
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');

			Test.startTest();
			Datetime comienzoCita = Datetime.newInstance(Date.newInstance(2020, 1, 23), Time.newInstance(9, 0, 0, 0));
			CSBD_Opportunity_Operativas_Controller.programarCita(oportunidad.Id, false, false, usuarioGestor.Id, comienzoCita);
			Test.stopTest();

			System.assertEquals(1, [SELECT Count() FROM Event WHERE DurationInMinutes = 60 LIMIT 2], 'Debería haber 1 cita programada');
		}
	}
	*/

	@IsTest
	private static void programarDesprogramarCitaTest() {
		Contact contacto;
		System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
			contacto = (Contact)(CSBD_TestDataFactory.crearCuentaContacto('12345678N')).get('contacto');
		}

		User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
		System.runAs(usuarioGestor) {
			Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
				'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id, 'CSBD_Now_NIF__c' => contacto.Account.CC_Numero_Documento__c
			});

			Test.startTest();
			CSBD_Opportunity_Operativas_Controller.programarCita(prestamo.Id, false, false, prestamo.OwnerId, System.now().addHours(1));
			prestamo.OwnerId = usuarioGestor.Id;
			update prestamo;

			Event citaDesprogramada = CSBD_Opportunity_Operativas_Controller.desprogramarCita(prestamo.Id);
			Test.stopTest();

			System.assertEquals('Cancelado', citaDesprogramada.CSBD_Evento_Estado__c, 'No se ha desprogramado la cita');
		}
	}

	@IsTest
	private static void actualizarDatosRiesgoContactoTest() {
		System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
			Contact contacto = (Contact)(CSBD_TestDataFactory.crearCuentaContacto('12345678N')).get('contacto');

			System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
				Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
					'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id, 'CSBD_Now_NIF__c' => contacto.Account.CC_Numero_Documento__c
				});

				Test.startTest();
				CSBD_Opportunity_Operativas_Controller.actualizarDatosRiesgoContacto(prestamo.Id);
				Test.stopTest();

				contacto = [SELECT CSBD_Actualizacion_Datos_Riesgo__c FROM Contact WHERE Id = :contacto.Id];
				System.assertEquals(false, contacto.CSBD_Actualizacion_Datos_Riesgo__c, 'Actualización de datos de riesgo incorrecta');
			}
		}
	}

	@IsTest
	private static void duplicarOportunidadTest() {
		System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
			Contact contacto = (Contact)(CSBD_TestDataFactory.crearCuentaContacto('12345678N')).get('contacto');

			System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
				Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
					'AccountId' => contacto.AccountId, 'CSBD_Contact__c' => contacto.Id
				});

				Test.startTest();
				Opportunity prestamoNuevo = CSBD_Opportunity_Operativas_Controller.duplicarOportunidad(prestamo, 'CSBD_Prestamo', 'CaixaBank');
				System.assertEquals(prestamo.Id, [SELECT CSBD_Parent_Id__c FROM Opportunity WHERE Id = :prestamoNuevo.Id].CSBD_Parent_Id__c, 'No existe oportunidad hija');

				try { //Probar excepción
					CSBD_Opportunity_Operativas_Controller.duplicarOportunidad(prestamo, 'recordTypeInexistente', 'CaixaBank');
				} catch (Exception e) {
					System.assertEquals('System.AuraHandledException', e.getTypeName(), 'Tipo incorrecto de excepción');
				}
				Test.stopTest();
			}
		}
	}

	@IsTest
	private static void solicitarAltaBajaOmnichannelTest() {
		System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
			Contact contacto = (Contact)(CSBD_TestDataFactory.crearCuentaContacto('12345678N')).get('contacto');

			System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
				Map<String, Object> campos = new Map<String, Object>();
				campos.put('Name', 'oportunidad de prueba');
				campos.put('CSBD_Estado__c', 'Activa');
				campos.put('StageName', 'Solicitud');
				campos.put('AccountId', contacto.AccountId);
				campos.put('CSBD_Contact__c', contacto.Id);
				campos.put('CSBD_Horario_Contacto__c', 'Mañana');
				campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
				campos.put('CSBD_Familia_Producto__c', 'Cuentas');
				campos.put('CSBD_Empresa_Proveedora__c', 'CaixaBank');
				Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);

				Test.startTest();
				CSBD_Opportunity_Operativas_Controller.solicitarAltaOmnichannel(oportunidad.Id);
				List<CSBD_Gestor_Oportunidad__c> gestorOpp = [SELECT Id FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c = :oportunidad.Id
																AND CSBD_Estado__c != 'Inactivo' LIMIT 1];
				System.assert(!gestorOpp.isEmpty(), 'No hay ningún registro de CSBD_Gestor_Oportunidad__c');

				CSBD_Opportunity_Operativas_Controller.solicitarBajaOmnichannel(oportunidad.Id);
				gestorOpp = [SELECT Id FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c = :oportunidad.Id AND CSBD_Estado__c = 'Inactivo' LIMIT 1];
				System.assert(!gestorOpp.isEmpty(), 'No hay ningún registro de CSBD_Gestor_Oportunidad__c');
				Test.stopTest();
			}
		}
	}

	@IsTest
	private static void actualizarOwnerOportunidadTest() {
		System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
			User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
			System.runAs(usuarioGestor) {
				Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');
				CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{prestamo}, 'Pendiente de asignar');

				CSBD_Gestor_Oportunidad__c gestorOportunidad = [SELECT Id FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c = :prestamo.Id ORDER BY CreatedDate DESC LIMIT 1];
				gestorOportunidad.OwnerId = usuarioGestor.Id;
				gestorOportunidad.CSBD_Estado__c = 'Activo';
				update gestorOportunidad;

				Test.startTest();
				CSBD_Opportunity_Operativas_Controller.actualizarOwnerOportunidad(prestamo.Id, prestamo.OwnerId);
				Test.stopTest();

				gestorOportunidad = [SELECT OwnerId FROM CSBD_Gestor_Oportunidad__c WHERE CSBD_Oportunidad__c = :prestamo.Id ORDER BY CreatedDate DESC LIMIT 1];
				System.assertEquals(gestorOportunidad.OwnerId, [SELECT OwnerId FROM Opportunity WHERE Id = :prestamo.Id].OwnerId, 'Owner incorrecto');
			}
		}
	}

	@IsTest
	private static void actualizarOwnerOportunidadTest2() {
		User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
		User usuarioGestor2 = CSBD_TestDataFactory.usuarioGestor();

		System.runAs(usuarioGestor) {
			Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');

			CSBD_Gestor_Oportunidad__c gestorOpp = CSBD_GestorOportunidad.insertarGestorOportunidad(new List<Opportunity>{prestamo}, 'Pendiente de asignar')[0];

			gestorOpp.OwnerId = usuarioGestor.Id;
			gestorOpp.CSBD_Estado__c = 'Activo';
			update gestorOpp;

			Test.startTest();
			Boolean resultado = CSBD_Opportunity_Operativas_Controller.actualizarOwnerOportunidad(prestamo.Id, usuarioGestor2.Id);
			Test.stopTest();

			System.assertEquals(true, resultado, 'Resultado incorrecto');
		}
	}

	@IsTest
	private static void trasladoImaginBankTest() {
		Contact contacto;
		User usuarioAdministrador = CSBD_TestDataFactory.usuarioAdministrador();
		System.runAs(usuarioAdministrador) {
			contacto = (Contact)(CSBD_TestDataFactory.crearCuentaContacto('12345678N')).get('contacto');
		}

		System.runAs(usuarioAdministrador) {
			CC_Lista_Valores__c listaValoresTraslado = new CC_Lista_Valores__c();
			listaValoresTraslado.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
			listaValoresTraslado.Name = 'CSBD: Traspaso Imagin - Destinatarios';
			insert listaValoresTraslado;
			CC_Lista_Valores__c valorTraslado = new CC_Lista_Valores__c();
			valorTraslado.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
			valorTraslado.CC_Lista__c = listaValoresTraslado.Id;
			valorTraslado.Name = 'CMB';
			valorTraslado.CC_Valor__c = 'test@test.com';
			insert valorTraslado;

			User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
			System.runAs(usuarioGestor) {
				EmailTemplate plantilla = new EmailTemplate();
				plantilla.DeveloperName = 'CSBD_Traspaso_CMB_Imagin';
				plantilla.isActive = true;
				plantilla.Name = 'CSBD Traspaso CMB Imagin';
				plantilla.TemplateType = 'custom';
				plantilla.FolderId = usuarioGestor.Id; //Indica que la plantilla se crea en la carpeta personal del usuario
				plantilla.Subject = 'CSBD Traspaso CMB Imagin';
				plantilla.HtmlValue = '<b>CSBD</b> <i>Plantilla</i> <u>Test</u>';
				insert plantilla;

				Opportunity cmb = CSBD_Opportunity.crearOportunidad('CSBD_CMB', new Map<String, Object>{
					'AccountId' => contacto.AccountId,
					'CSBD_Now_NIF__c' => contacto.Account.CC_Numero_Documento__c,
					'CSBD_Email_Solicitud__c' => 'test2@test.com',
					'CSBD_Empresa_Proveedora__c' => 'imaginBank',
					'CSBD_Contact__c' => contacto.Id
				});

				Test.startTest();
				CSBD_Opportunity_Operativas_Controller.trasladoImaginBank(cmb.Id, 'Rechazada', 'Traspasada a Imagin');
				Test.stopTest();

				System.assert([SELECT Count() FROM EmailMessage WHERE CSBD_Oportunidad_Id__c = :cmb.Id LIMIT 1] > 0, 'No se ha enviado ningún email');
			}
		}
	}

	@IsTest
	private static void agendarCancelarFirmaApexTest() {
		System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
			Account cuenta = (Account)CSBD_TestDataFactory.crearCuentaContacto('12345678N').get('cuenta');

			User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
			System.runAs(usuarioGestor) {
				Datetime fecha = System.now();
				Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
					'AccountId' => cuenta.Id, 'OwnerId' => usuarioGestor.Id
				});

				Test.startTest();
				Event nuevoEvento1 = CSBD_Opportunity_Operativas_Controller.agendarFirmaApex(prestamo.Id, true, fecha);
				Opportunity prestamoActualizado = [SELECT CSBD_Fecha_Firma__c, CSBD_Firma_segura__c FROM Opportunity WHERE Id = :prestamo.Id];
				System.assertEquals(prestamoActualizado.CSBD_Fecha_Firma__c, fecha, 'No se ha actualizado la oportunidad correctamente');
				System.assertEquals(prestamoActualizado.CSBD_Firma_segura__c, true, 'No se ha actualizado la oportunidad correctamente');
				System.assertEquals([SELECT Id FROM Event WHERE Id = :nuevoEvento1.Id].isEmpty(), false, 'No se ha creado el evento correctamente');

				Event nuevoEvento2 = CSBD_Opportunity_Operativas_Controller.cancelarFirmaApex(prestamo.Id);
				prestamoActualizado = [SELECT CSBD_Fecha_Firma__c, CSBD_Firma_segura__c FROM Opportunity WHERE Id = :prestamo.Id];
				System.assertEquals(prestamoActualizado.CSBD_Fecha_Firma__c, null, 'No se ha actualizado la oportunidad correctamente');
				System.assertEquals(prestamoActualizado.CSBD_Firma_segura__c, false, 'No se ha actualizado la oportunidad correctamente');
				System.assertEquals([SELECT CSBD_Evento_Estado__c FROM Event WHERE Id = :nuevoEvento2.Id][0].CSBD_Evento_Estado__c, 'Cancelado', 'No se ha actualizado el evento correctamente');
				Test.stopTest();
			}
		}
	}

	@IsTest
	private static void agendarCancelarFirmaApexKoTest() {
		System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
			Account cuenta = (Account)CSBD_TestDataFactory.crearCuentaContacto('12345678N').get('cuenta');

			System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
				Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{'AccountId' => cuenta.Id});
				Test.startTest();
				try {
					CSBD_Opportunity_Operativas_Controller.agendarFirmaApex(prestamo.Id, true, System.now());
				} catch (Exception e) {
					System.assertEquals('System.AuraHandledException', e.getTypeName(), 'Tipo incorrecto de excepción');
				}
				Test.stopTest();
			}
		}
	}

	@IsTest
	private static void checkPSResponsableTest() {
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

		User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

		PermissionSetAssignment psa = new PermissionSetAssignment();
		psa.AssigneeId = usuarioGestor.Id;
		psa.PermissionSetId = psMock.Id;
		insert psa;

		System.runAs(usuarioGestor) {
			Test.startTest();
			Map<String, Boolean> responsable = CSBD_Opportunity_Operativas_Controller.checkPSResponsable();
			Test.stopTest();

			System.assertEquals(responsable.get('esResponsable'), !cpResponsable.isEmpty(), 'No tiene el custom permission Responsable');
		}
	}

	@IsTest
	private static void checkCDPTest() {
		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			Opportunity opp = CSBD_Opportunity.crearOportunidad('CSBD_PROAutomatica');
			Test.startTest();
			System.assertEquals(true, CSBD_Opportunity_Operativas_Controller.checkCDP(opp.Id), 'No tiene record type PRO Autimática');
			Test.stopTest();
		}
	}

	@IsTest
	private static void ampliarVencimientoTest() {
		Account cuenta;
		System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
			cuenta = (Account)CSBD_TestDataFactory.crearCuentaContacto('12345678N').get('cuenta');
		}
		User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
		System.runAs(usuarioGestor) {
			Datetime fechaActual = System.now();
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
				'AccountId' => cuenta.Id, 'CSBD_Fecha_vencimiento_alta__c' => fechaActual
			});

			Test.startTest();
			CSBD_Opportunity_Operativas_Controller.ampliarVencimiento(oportunidad.Id, fechaActual);
			Test.stopTest();

			Opportunity opp = [SELECT CSBD_Fecha_vencimiento_alta__c FROM Opportunity WHERE Id = :oportunidad.Id LIMIT 1];
			System.assertEquals(fechaActual.addMonths(1), opp.CSBD_Fecha_vencimiento_alta__c, 'Fecha de vencimiento incorrecta');
		}
	}

	@IsTest
	private static void obtenerOportunidadesHijasAbiertasTest() {
		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			Opportunity cmn = CSBD_Opportunity.crearOportunidad('CSBD_CMN');
			Opportunity hija1 = CSBD_Opportunity.crearOportunidad('CSBD_Accion_Comercial', new Map<String, Object>{'CSBD_Parent_Id__c' => cmn.Id});
			Opportunity hija2 = CSBD_Opportunity.crearOportunidad('CSBD_Accion_Comercial', new Map<String, Object>{'CSBD_Parent_Id__c' => cmn.Id});

			Test.startTest();
			System.assert(CSBD_Opportunity_Operativas_Controller.obtenerOportunidadesHijas(cmn.Id), 'El CMN debería tener acciones comerciales hijas');
			CSBD_Opportunity.cerrarOportunidad(hija1.Id, 'Rechazada', 'Resolución de prueba');
			System.assert(CSBD_Opportunity_Operativas_Controller.obtenerOportunidadesHijas(cmn.Id), 'El CMN debería tener acciones comerciales hijas');
			CSBD_Opportunity.cerrarOportunidad(hija2.Id, 'Rechazada', 'Resolución de prueba');
			System.assert(!CSBD_Opportunity_Operativas_Controller.obtenerOportunidadesHijas(cmn.Id), 'El CMN no debería tener acciones comerciales hijas');
			Test.stopTest();
		}
	}

	@IsTest
	private static void obtenerResolucionesTest() {
		User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

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
		System.runAs(usuarioGestor) {
			insert valor;

			Test.startTest();
			List<String> resoluciones = CSBD_Opportunity_Operativas_Controller.obtenerResoluciones('Alta Cliente', 'Hipoteca', 'Formalizada');
			Test.stopTest();

			System.assertEquals(resoluciones[0], 'Resolución Test', 'Resolución incorrecta');
		}
	}

	@IsTest
	private static void crearTareaGestorTest() {
		User usuarioAdministrador = CSBD_TestDataFactory.usuarioAdministrador();
		User usuarioGestorCsbd;
		User usuarioGestorAV;
		System.runAs(usuarioAdministrador) {
			List<User> gestores = CSBD_TestDataFactory.usuarioGestor(new List<Map<String, Object>>{
				new Map<String, Object>(),
				new Map<String, Object>{'AV_ExternalID__c' => 'U0123456789'}
			});
			usuarioGestorCsbd = gestores[0];
			usuarioGestorAV = gestores[1];

			Id idPermissionSetAV = [SELECT Id FROM PermissionSet WHERE Name = 'AV_NowIn' LIMIT 1]?.Id ?? null;
			if (idPermissionSetAV != null) {
				insert new PermissionSetAssignment(AssigneeId = usuarioGestorCsbd.Id, PermissionSetId = idPermissionSetAV);
			}
		}

		System.runAs(usuarioAdministrador) {
			Map<String, SObject> cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('12345678N', new Map<String, Object>{
				'RecordTypeId' => Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId(),
				'Email' => 'test@test.com',
				'FirstName' => 'Nombre',
				'LastName' => 'Apellido'
			});
			Contact contacto = (Contact)cuentaContacto.get('contacto');

			Product2 product = new Product2();
			product.Name = 'Producto de prueba';
			product.IsActive = true;
			product.AV_ExternalID__c = '123456';
			insert product;

			System.runAs(usuarioGestorCsbd) {
				Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
					'AccountId' => contacto.AccountId, 'AV_PF__c' => product.Id
				});

				Test.startTest();
				Opportunity oportunidadAV = CSBD_Opportunity_Operativas_Controller.crearTareaGestor(oportunidad.Id, 'U0123456789', contacto.Id, 'Test');
				Test.stopTest();

				System.assertEquals(usuarioGestorAV.Id, oportunidadAV.OwnerId, 'El propietario de la oportunidad debería ser el gestor AV');
			}
		}
	}

	@IsTest
	private static void crearTareaGestorTestSinGestorTest() {
		User usuarioAdministrador = CSBD_TestDataFactory.usuarioAdministrador();
		User usuarioGestorCsbd;
		System.runAs(usuarioAdministrador) {
			usuarioGestorCsbd = CSBD_TestDataFactory.usuarioGestor();

			Id idPermissionSetAV = [SELECT Id FROM PermissionSet WHERE Name = 'AV_NowIn' LIMIT 1]?.Id ?? null;
			if (idPermissionSetAV != null) {
				insert new PermissionSetAssignment(PermissionSetId = idPermissionSetAV, AssigneeId = usuarioGestorCsbd.Id);
			}
		}

		System.runAs(usuarioAdministrador) {
			Product2 producto = new Product2();
			producto.Name = 'Producto Test';
			producto.IsActive = true;
			producto.AV_ExternalID__c = '123456';
			insert producto;

			Contact contactoGenerico = (Contact)CSBD_TestDataFactory.crearEmpleadoOficina(
				'00615', new Map<String, Object>{'CC_Matricula__c' => '000000'}
			).get('empleado');

			/*
			Contact contacto = (Contact)CSBD_TestDataFactory.crearCuentaContacto('12345678N', new Map<String, Object>{
				'RecordTypeId' => Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId(),
				'CC_Matricula__c' => '000000'
			}).get('contacto');
			*/
			Contact empleado = (Contact)CSBD_TestDataFactory.crearEmpleadoOficina().get('empleado');

			System.runAs(usuarioGestorCsbd) {
				Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
					'AccountId' => contactoGenerico.AccountId, 'AV_PF__c' => producto.Id
				});

				Test.startTest();
				CSBD_Opportunity_Operativas_Controller.crearTareaGestor(prestamo.Id, '', '', 'Test');
				Test.stopTest();

				Integer oportunidadesGestor = [SELECT Count() FROM Opportunity WHERE Name = 'Rema Gestor - CSBD' LIMIT 2];
				System.assertEquals(1, oportunidadesGestor, 'Debería haber 1 oportunidad con el nombre Rema Gestor - CSBD');
			}
		}
	}

	@IsTest
	private static void convertirOportunidadTest() {
		User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
		Account cuenta;
		System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
			cuenta = (Account)CSBD_TestDataFactory.crearCuentaContacto('67560901B').get('cuenta');
		}
		System.runAs(usuarioGestor) {
			Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{'AccountId' => cuenta.Id});

			Test.startTest();
			Opportunity oportunidadDuplicada = CSBD_Opportunity_Operativas_Controller.convertirOportunidad(prestamo, 'CSBD_Prestamo');
			Test.stopTest();

			oportunidadDuplicada = [SELECT CSBD_Parent_Id__c FROM Opportunity WHERE Id = :oportunidadDuplicada.Id];
			System.assertEquals(prestamo.Id, oportunidadDuplicada.CSBD_Parent_Id__c, 'No existe una oportunidad hija');
		}
	}

	@IsTest
	private static void convertirOportunidadTestKo() {
		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
			Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');

			Test.startTest();
			try {
				CSBD_Opportunity_Operativas_Controller.convertirOportunidad(prestamo, 'recordTypeInexistente');
			} catch (Exception e) {
				System.assertEquals('System.AuraHandledException', e.getTypeName(), 'Tipo incorrecto de excepción');
			}
			Test.stopTest();
		}
	}

	@IsTest
	private static void obtenerEntidadesTest() {
		User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

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
			System.assertEquals(resoluciones[0], 'Entidad prueba', 'Resolución incorrecta');
		}
	}
}