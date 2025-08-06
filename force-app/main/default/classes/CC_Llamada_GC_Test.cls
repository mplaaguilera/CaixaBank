@isTest
public class CC_Llamada_GC_Test {

	@TestSetup
	private static void testSetup() {
Test.startTest();
		User usuarioAdmin = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator', 'Administrador del sistema')
								AND IsActive = TRUE LIMIT 1];
		System.runAs(usuarioAdmin) {
			Id perfilAdministradorId = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'Administrador del sistema') LIMIT 1].Id;
			Id roleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'LIMIT 1].Id;
			User adminKinton = new User();
			adminKinton.LastName = 'Administrador Kinton';
			adminKinton.Alias = 'AUno';
			adminKinton.Email = 'ccAgenteGC@invalid.com';
			adminKinton.UserName = 'ccAgenteGC_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
			adminKinton.ProfileId = [SELECT Id FROM Profile WHERE Name = 'API Only'].Id;
			adminKinton.UserRoleId = roleId;
			adminKinton.EmailEncodingkey = 'UTF-8';
			adminKinton.LanguageLocaleKey = 'en_US';
			adminKinton.LocalesIdKey = 'en_US';
			adminKinton.TimezonesIdKey = 'Europe/Madrid';

			User agenteCancelarConsulta = new User();
			agenteCancelarConsulta.LastName = 'Agente 1';
			agenteCancelarConsulta.Alias = 'AUno';
			agenteCancelarConsulta.Email = 'agente1@invalid.com';
			agenteCancelarConsulta.UserName = 'agente1_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
			agenteCancelarConsulta.ProfileId = perfilAdministradorId;
			agenteCancelarConsulta.UserRoleId = roleId;
			agenteCancelarConsulta.EmailEncodingkey = 'UTF-8';
			agenteCancelarConsulta.LanguageLocaleKey = 'en_US';
			agenteCancelarConsulta.LocalesIdKey = 'en_US';
			agenteCancelarConsulta.TimezonesIdKey = 'Europe/Madrid';

			User agenteCompletarConsulta = new User();
			agenteCompletarConsulta.LastName = 'Agente 2';
			agenteCompletarConsulta.Alias = 'ADos';
			agenteCompletarConsulta.Email = 'agente2@invalid.com';
			agenteCompletarConsulta.UserName = 'agente2_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
			agenteCompletarConsulta.ProfileId = perfilAdministradorId;
			agenteCompletarConsulta.UserRoleId = roleId;
			agenteCompletarConsulta.EmailEncodingkey = 'UTF-8';
			agenteCompletarConsulta.LanguageLocaleKey = 'en_US';
			agenteCompletarConsulta.LocalesIdKey = 'en_US';
			agenteCompletarConsulta.TimezonesIdKey ='Europe/Madrid';

			insert new List<User>{adminKinton, agenteCancelarConsulta, agenteCompletarConsulta};

			PermissionSet psKinAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'KIN_Admin'];
			insert new PermissionSetAssignment(PermissionSetId = psKinAdmin.Id, AssigneeId = adminKinton.Id);
		}

		Id idRtServicioGenesys = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();
		CC_Servicio_Genesys__c s1 = new CC_Servicio_Genesys__c();
		s1.RecordTypeId = idRtServicioGenesys;
		s1.CBK_Negocio__c = 'CC';
		s1.Name = 'Servicio 1';
		s1.CC_Codigo__c = 'S1';
		s1.CC_VDN__c = '4444444';
		s1.CC_Tipo__C = 'Servicio';
		s1.CC_Canal_Procedencia__c = 'CaixaBankNow';
		s1.CC_Prefijo__c = '0';
		s1.CC_Tipo_Cliente__c = 'Cliente';
        s1.CC_Fecha_Inicio_Salesforce__c = Date.newInstance(2023, 11, 3);
		CC_Servicio_Genesys__c s2 = new CC_Servicio_Genesys__c();
		s2.RecordTypeId = idRtServicioGenesys;
		s2.CBK_Negocio__c = 'CC';
		s2.Name = 'Servicio 2';
		s2.CC_Codigo__c = 'S2';
		s2.CC_VDN__c = '4444444';
		s2.CC_Tipo__C = 'Tercer nivel';
		s2.CC_Canal_Procedencia__c = 'ImaginBank';
		s2.CC_Prefijo__c = '0';
		s2.CC_Fecha_Inicio_Salesforce__c = date.today();
		s2.CC_Tipo_Cliente__c = 'Cliente';
		CC_Servicio_Genesys__c s3 = new CC_Servicio_Genesys__c();
		s3.RecordTypeId = idRtServicioGenesys;
		s3.CBK_Negocio__c = 'CC';
		s3.Name = 'Servicio 3';
		s3.CC_Codigo__c = 'S3';
		s3.CC_VDN__c = '4444444';
		s3.CC_Tipo__C = 'Servicio';
		s3.CC_Canal_Procedencia__c = 'RRHH';
		s3.CC_Prefijo__c = '0';
		s3.CC_Fecha_Inicio_Salesforce__c = Date.today().addDays(1);
		s3.CC_Tipo_Cliente__c = 'Empleado';
		CC_Servicio_Genesys__c s4 = new CC_Servicio_Genesys__c();
		s4.RecordTypeId = idRtServicioGenesys;
		s4.CBK_Negocio__c = 'CC';
		s4.Name = 'CC GenesysCloudOutboundDefault';
		s4.CC_Codigo__c = 'CC_GenesysCloudOutboundDefault';
		s4.CC_Tipo__C = 'Servicio';
		s4.CC_Tipo_Cliente__c = 'Cliente';
		s4.CC_VDN__c = '4444444';
		s4.CC_Canal_Procedencia__c = 'CaixaBankNow';
		s4.CC_Prefijo__c = '0';
		s4.CC_Fecha_Inicio_Salesforce__c = Date.today();
		s4.CC_Principal__c = true;
		CC_Servicio_Genesys__c s5 = new CC_Servicio_Genesys__c();
		s5.RecordTypeId = idRtServicioGenesys;
		s5.CBK_Negocio__c = 'CC';
		s5.Name = 'Servicio 5';
		s5.CC_Codigo__c = 'S5';
		s5.CC_VDN__c = '4444444';
		s5.CC_Tipo__C = 'Empleado';
		//s5.CC_Canal_Procedencia__c = 'CCO CSI';
		s5.CC_Canal_Procedencia__c = 'ImaginBank';
		s5.CC_Prefijo__c = '0';
		s5.CC_Fecha_Inicio_Salesforce__c = date.today().addDays(1);
		s5.CC_Tipo_Cliente__c = 'CSI Bankia';
		insert new List<CC_Servicio_Genesys__c>{s1, s2, s3, s4, s5};

		CC_MCC__c tematica = new CC_MCC__c();
		tematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
		tematica.CC_Tipo_Cliente__c = 'Cliente';
		tematica.Name = 'Temática';
		tematica.CC_Codigo_Externo__c = 'T1';
		tematica.CC_Canal_Operativo__c = 'Oficina';
		insert tematica;

		CC_MCC__c producto = new CC_MCC__c();
		producto.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		producto.CC_Tipo_Cliente__c = 'Cliente';
		producto.Name = 'Producto';
		producto.CC_Tematica__c = tematica.Id;
		producto.CC_Codigo_Externo__c = 'P1';
		insert producto;

		CC_MCC__c motivo = new CC_MCC__c();
		motivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		motivo.CC_Tipo_Cliente__c = 'Cliente';
		motivo.Name = 'Motivo';
		motivo.CC_Producto_Servicio__c = producto.Id;
		motivo.CC_Codigo_Externo__c = 'M1';
		insert motivo;

		CC_MCC__c causa = new CC_MCC__c();
		causa.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
		causa.CC_Tipo_Cliente__c = 'Cliente';
		causa.Name = 'Causa';
		causa.CC_Motivo__c = motivo.Id;
		causa.CC_Codigo_Externo__c = 'C1';
		insert causa;

		CC_MCC__c solucion = new CC_MCC__c();
		solucion.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
		solucion.CC_Tipo_Cliente__c = 'Cliente';
		solucion.Name = 'Solucion';
		solucion.CC_Causa__c = causa.Id;
		solucion.CC_Codigo_Externo__c = 'S1';
		insert solucion;

        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];
        System.runAs(adminKinton) {
            List<Account> listaCuentas = new List<Account>();

			Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();


			listaCuentas.add(new Account(RecordTypeId = centroRecordTypeId, Name = 'Cuenta Centro CaixaBank Test 1', CC_Tipo_Centro__c = 'OF'));
			listaCuentas.add(new Account(RecordTypeId = centroRecordTypeId, Name = 'Cuenta Centro CaixaBank Test 2', CC_Tipo_Centro__c = 'OF'));
			listaCuentas.add(new Account(RecordTypeId = centroRecordTypeId, Name = 'Cuenta Centro CaixaBank Test 3', CC_Tipo_Centro__c = 'OF'));
            listaCuentas.add(new Account(
				RecordTypeId = centroRecordTypeId,
				CC_Numero_Empresa__c = '001',
				CC_Numero_Oficina__c = '00001',
				CC_Numero_Oficina_Empresa__c = '001-00001',
				Name = 'Oficina gestora Test',
				CC_Tipo_Centro__c = 'OF',
				CC_Email__c = 'test@test.com'
			));
			insert listaCuentas;

			List<Contact> listaContactos = new List<Contact>();
			Id empleadoRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
			listaContactos.add(new Contact(RecordTypeId = empleadoRecordTypeId,FirstName = 'Contacto1 OF',LastName = 'Test',CC_Idioma__c = 'es',
			Email = 'test@contact.com',CC_Cargo__c = 'DIRECCIÓN', AccountId=listaCuentas[0].Id));
			listaContactos.add(new Contact(RecordTypeId = empleadoRecordTypeId,FirstName = 'Contacto2 OF',LastName = 'Test',CC_Idioma__c = 'es',
			Email = 'test@contact.com',CC_Cargo__c = 'DIRECCIÓN', AccountId=listaCuentas[1].Id));
			listaContactos.add(new Contact(RecordTypeId = empleadoRecordTypeId,FirstName = 'Contacto3 OF',LastName = 'Test',CC_Idioma__c = 'es',
			Email = 'test@contact.com',CC_Cargo__c = 'DIRECCIÓN', AccountId=listaCuentas[2].Id));
            listaContactos.add(new Contact(RecordTypeId = empleadoRecordTypeId,FirstName = 'Contacto4 OF',LastName = 'Empleado gestor Test',CC_Idioma__c = 'es',
			Email = 'test@contact.com', AccountId=listaCuentas[3].Id));
            insert listaContactos;

			Account cuenta = new Account();
			cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			cuenta.Name = 'Cuenta Test';
			cuenta.CC_NumPerso__c = '666';
			cuenta.CC_OficinaGestoraId__c = listaCuentas[3].Id;
			cuenta.AV_OficinaPrincipal__c = listaCuentas[3].Id;
			cuenta.AV_EAPGestor__c = listaContactos[3].Id;
			insert cuenta;

			Contact contacto = new Contact();
			contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			contacto.FirstName = 'Contacto';
			contacto.LastName = 'Contacto Test';
			contacto.AccountId = cuenta.Id;
			insert contacto;

			Case casoCliente = new Case();
			casoCliente.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			casoCliente.Subject = 'Caso cliente Test';
			casoCliente.Origin = 'Phone';
			casoCliente.CC_Canal_Respuesta__c = 'Phone';
			casoCliente.CC_Tipo_Cliente__c = 'Cliente';
			casoCliente.CC_No_Identificado__c = true;
			casoCliente.CC_Canal_Procedencia__c = 'CaixaBankNow';
			casoCliente.CC_MCC_Tematica__c = tematica.Id;
			casoCliente.CC_MCC_ProdServ__c = producto.Id;
			casoCliente.CC_MCC_Motivo__c = motivo.Id;
			casoCliente.CC_MCC_Causa__c = causa.Id;
			casoCliente.CC_MCC_Solucion__c = solucion.Id;
            casoCliente.AccountId = cuenta.Id;
            casoCliente.ContactId = contacto.Id;

			Case casoEmpleado = new Case();
			casoEmpleado.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
			casoEmpleado.Subject = 'Caso empleado Test';
			casoEmpleado.Origin = 'Phone';
			casoEmpleado.CC_Canal_Respuesta__c = 'Phone';
			casoEmpleado.CC_Tipo_Cliente__c = 'Empleado';
			casoEmpleado.CC_No_Identificado__c = true;
			casoEmpleado.CC_Canal_Procedencia__c = 'RRHH';
			casoEmpleado.CC_Canal_Resolucion__c = 'RRHH';
			insert new List<Case>{casoCliente, casoEmpleado};

            CC_Servicio_Genesys__c svcEncuesta = new CC_Servicio_Genesys__c();
			svcEncuesta.RecordTypeId = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Encuesta').getRecordTypeId();
			svcEncuesta.Name = 'Servicio Encuesta';
			svcEncuesta.CC_Codigo__c = 'Servicio Encuesta';
			svcEncuesta.CC_VDN__c = '555555555';
            svcEncuesta.CC_Canal_Procedencia__c = 'CaixabankNow';
            svcEncuesta.CC_Fecha_Inicio_Salesforce__c = Date.newInstance(2023, 11, 3);
			insert svcEncuesta;


			List<CC_Canal_Com__c> listaCanales = new List<CC_Canal_Com__c>();
			Id recordTypeTelefono = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
			listaCanales.add(new CC_Canal_Com__c(CC_Telefono__c='666001122', CC_ContactoId__c=listaContactos[0].Id, CC_CuentaId__c=listaCuentas[0].Id, RecordTypeId = recordTypeTelefono));
			listaCanales.add(new CC_Canal_Com__c(CC_Telefono__c='666001133', CC_ContactoId__c=listaContactos[1].Id, CC_CuentaId__c=listaCuentas[1].Id, RecordTypeId = recordTypeTelefono));
			listaCanales.add(new CC_Canal_Com__c(CC_Telefono__c='666001133', CC_ContactoId__c=listaContactos[2].Id, CC_CuentaId__c=listaCuentas[2].Id, RecordTypeId = recordTypeTelefono));
			insert listaCanales;
Test.stopTest();
		}
	}

	public static CC_Servicio_Genesys__c crearServicioDespliegues() {
		CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(
			Name = 'Despliegues',
			CBK_Negocio__c = 'CC',
		CC_Codigo__c = 'INC_TEC_DESPLIEGUES',
		CC_VDN__c = '4444444',
		CC_Tipo__C = 'Servicio',
		CC_Canal_Procedencia__c = 'Incidencias Técnicas',
		CC_Prefijo__c = '0',
		CC_Fecha_Inicio_Salesforce__c = date.today().addDays(1),
		CC_Tipo_Cliente__c = 'Empleado');
		insert servicio;
		return servicio;
	}

	public static CC_Servicio_Genesys__c crearServicioDespliegues2() {
		CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(
			Name = 'Despliegues2',
			CBK_Negocio__c = 'CC',
		CC_Codigo__c = 'INC_TEC_DESPLIEGUES2',
		CC_VDN__c = '4444444',
		CC_Tipo__C = 'Servicio',
		CC_Canal_Procedencia__c = 'Incidencias Técnicas',
		CC_Prefijo__c = '0',
		CC_Fecha_Inicio_Salesforce__c = date.today().addDays(1),
		CC_Tipo_Cliente__c = 'Empleado');
		insert servicio;
		return servicio;
	}


	public static CC_Servicio_Genesys__c crearServicioEmpleado() {
		CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(
			Name = 'Servicio 4',
			CBK_Negocio__c = 'CC',
		CC_Codigo__c = 'S4',
		CC_VDN__c = '4444444',
		CC_Tipo__C = 'Servicio',
		CC_Canal_Procedencia__c = 'Activo',
		CC_Prefijo__c = '0',
		CC_Fecha_Inicio_Salesforce__c = date.today().addDays(1),
			CC_Tipo_Cliente__c = 'Empleado'
		);
		insert servicio;
		return servicio;
	}

	public static CC_Llamada__c obtenerLlamada(Id id) {
		return [SELECT CC_Cuenta__r.CC_OficinaGestoraId__c, CC_Servicio_Genesys__c, CC_Asunto__c, CC_Idioma__c,
				CC_ANI__c, CC_No_Identificado__c, CC_Cuenta__c, CC_Contacto__c, CC_Tipo__c, CC_ConnId__c,
				CC_ConnId_Consulta__c, CC_Id_Cognitivo__c, CC_Canal_del_Empleado__c, CC_IdentCliente__c,
				CC_Status_Autorizacion__c, CC_Perfil__c, CC_Resumen_AI__c, CC_Sentimiento__c, CC_Respuesta_Asistente__c, CC_Asunto_IA__c FROM CC_Llamada__c WHERE Id = :id AND CC_Fecha_Fin__c = NULL];
	}

	public static CC_Llamada_Input obtenerInputLlamada(String servicio, String llamadaId, String casoId, String numPerso, String ani) {
		CC_Llamada_Input inputLlamada = new CC_Llamada_Input();
		inputLlamada.usuario = '1218';
		inputLlamada.extension = '1118';
		inputLlamada.connId = '12345678';
		inputLlamada.ani = String.isNotBlank(ani) ? ani : '666666666';
		inputLlamada.dnis = '666666666';
		inputLlamada.servicio = servicio;
		inputLlamada.asunto = 'Asunto"';
		inputLlamada.numPerso = numPerso;
		inputLlamada.idioma = 'Castellano';
		inputLlamada.datos = 'Datos';
		inputLlamada.casoId = casoId;
		inputLlamada.statusAuto = 'APPROVED';
		inputLlamada.perfil = 'EMPLEADOS';
		inputLlamada.llamadaId = llamadaId;
		return inputLlamada;
	}

    public static CC_Llamada_Input obtenerInputLlamadaSaliente(String servicio, String llamadaId, String casoId, String numPerso, String ani) {
		CC_Llamada_Input inputLlamada = new CC_Llamada_Input();
		inputLlamada.usuario = '1218';
		inputLlamada.extension = '1118';
		inputLlamada.connId = '12345678';
		inputLlamada.ani = String.isNotBlank(ani) ? ani : '666666666';
		inputLlamada.dnis = '666666666';
		inputLlamada.servicio = servicio;
		inputLlamada.asunto = 'Asunto"';
		inputLlamada.numPerso = numPerso;
		inputLlamada.idioma = 'Castellano';
		inputLlamada.datos = 'Datos';
		inputLlamada.casoId = casoId;
		inputLlamada.statusAuto = 'APPROVED';
		inputLlamada.perfil = 'EMPLEADOS';
		inputLlamada.llamadaId = llamadaId;
        inputLlamada.llamadaId = llamadaId;
		return inputLlamada;
	}
    
    

	public static CC_Llamada_Input obtenerInputConsulta(String servicio, String llamadaId, String casoId, String salesforceParentId) {
		CC_Llamada_Input inputConsulta = new CC_Llamada_Input();
		inputConsulta.usuario = '1219';
		inputConsulta.extension = '1119';
		inputConsulta.llamadaId = '' + llamadaId;
		inputConsulta.connId = '12348765"';
		inputConsulta.ani = '666666666';
		inputConsulta.dnis = '666666666';
		inputConsulta.servicio = servicio;
		inputConsulta.idioma = 'Castellano';
		inputConsulta.salesforceParentId = salesforceParentId;
		inputConsulta.casoId = casoId;
		return inputConsulta;
	}

	public static CC_Llamada_Input obtenerJsonConsultaExterna(String casoId, String salesforceParentId, String empleadoId, String empleadoTelefono) {
		CC_Llamada_Input inputConsultaExterna = new CC_Llamada_Input();
		inputConsultaExterna.usuario = '1219';
		inputConsultaExterna.extension = '1119';
		inputConsultaExterna.connId = '12348765';
		inputConsultaExterna.empleadoId = empleadoId;
		inputConsultaExterna.empleadoTelefono = empleadoTelefono;
		inputConsultaExterna.salesforceParentId = salesforceParentId;
		inputConsultaExterna.casoId = casoId;
		return inputConsultaExterna;
	}

	@isTest
	public static void cogerColgar() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

        System.runAs(adminKinton) {
			Contact contacto = [SELECT Account.CC_NumPerso__c, AccountId FROM Contact WHERE LastName = 'Contacto Test'];
            CC_Creacion_Datos_Test.lovAvisosSobreAgrupadores();
			CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1'];

			Test.startTest();
			//Entra la llamada
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(s1.CC_Codigo__c, '', '', contacto.Account.CC_NumPerso__c, null);
			CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c, CC_Encuesta__r.CC_Codigo__c
														FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputLlamada.servicio LIMIT 1];
			Map<String, Object> retornoRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');
			Id llamada = llamadaEntrante.Id;
			System.assert(llamadaEntrante.Id != null);

			//Creamos caso manualmente y lo cerramos con actividades de llamada abiertas
			Case caso1 = CC_Llamada_GC.crearVincularCaso(llamadaEntrante);
			Test.stopTest();
			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada AND WhatId=:caso1.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
			System.assert(actividad != null);

			//Colgamos la llamada
			CC_Llamada_GC.finalizarLlamada(inputLlamada, 'Llamada finalizada');

		}
	}

	@isTest
	public static void cogerConsultarCancelar() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

		System.runAs(adminKinton) {

			CC_Llamada_Input inputLlamada = obtenerInputLlamada('s1', null, '', '', null);
			Map<String, Object> respuestaRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)respuestaRegistrarLlamadaEntrante.get('llamada');
			Case caso = (Case)respuestaRegistrarLlamadaEntrante.get('caso');

			Test.startTest();

				CC_Llamada_Input inputLlamada2 = obtenerInputConsulta('s2', '', caso.Id, llamadaEntrante.Id);

				//Id consultaCanceladaId = llamadax.Id;
				Map<String, Object> respuestaRegistrarConsulta = CC_Llamada_GC.registrarConsulta(inputLlamada2);
				CC_Llamada__c consulta = (CC_Llamada__c)respuestaRegistrarConsulta.get('llamada');

				//Cancelamos la consulta
				CC_Llamada_GC.cancelarConsulta(inputLlamada2);
				consulta = [SELECT CC_Fecha_Fin__c, CC_Tipo_Cierre__c FROM CC_Llamada__c WHERE Id = :consulta.Id];
				System.assertNotEquals(null, consulta.CC_Fecha_Fin__c, 'Consulta sin fecha de fin');
				System.assertEquals('Consulta cancelada', consulta.CC_Tipo_Cierre__c, 'Consulta sin el tipo de cierre correcto');
			
			Test.stopTest();
		}
	}

	@isTest
	static void cogerConsultarCompletarColgar() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];
		System.runAs(adminKinton) {
			//Entra la llamada
			CC_Llamada_Input inputLlamada = obtenerInputLlamada('S1', null, '', '', null);
			Map<String, Object> respuestaRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamada = (CC_Llamada__c)respuestaRegistrarLlamadaEntrante.get('llamada');
			Case caso = (Case)respuestaRegistrarLlamadaEntrante.get('caso');

			Test.startTest();
			User agenteCompletarConsulta = [SELECT Id FROM User WHERE LastName = 'Agente 2'];
			System.RunAs(agenteCompletarConsulta) {
				//Realizamos una consulta
				CC_Llamada_Input inputConsulta = obtenerInputConsulta('S2', '', caso.Id, llamada.Id);
				Map<String, Object> respuestaRegistrarConsulta = CC_Llamada_GC.registrarConsulta(inputConsulta);
				CC_Llamada__c consulta = (CC_Llamada__c)respuestaRegistrarConsulta.get('llamada');

				CC_Llamada_Input inputCompletarConsulta = obtenerInputConsulta('S2', consulta.Id, caso.Id, llamada.Id);
				CC_Llamada__c consultaCompletada = [SELECT Id FROM CC_Llamada__c WHERE Id = :consulta.Id AND CC_Fecha_Fin__c = NULL];
				Task actividadCompletada = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :consultaCompletada.Id AND Type = 'Consulta a tercer nivel' AND Status = 'Open' LIMIT 1];

				//Completamos la consulta
				CC_Llamada_GC.completarConsulta(inputCompletarConsulta.connId, UserInfo.getUserId());

				Integer n = 0;
				for (Task t : [SELECT Type, Status, CC_Tipo_Cierre__c FROM Task WHERE CC_Llamada_Id__c = :consultaCompletada.Id
				AND Type IN ('Consulta a tercer nivel', 'Llamada transferida', 'Traslado Tercer Nivel')]) {
					if (t.Type == 'Consulta a tercer nivel' && t.Status == 'Completed' && t.CC_Tipo_Cierre__c == 'Consulta transferida') {
						n++;
					} else if (t.Type == 'Llamada transferida' && t.Status == 'Open') {
						n++;
					} else if (t.Type == 'Traslado Tercer Nivel' && t.Status == 'Open') {
						n++;
					}
				}
				System.assertEquals(2/*  */, n, 'Actividades incorrectas');

				caso = [SELECT OwnerId, CC_Owner_Anterior__c FROM Case WHERE Id = :caso.Id AND Status = 'Activo' AND CC_En_Tercer_Nivel__c = true];
				System.assertNotEquals(null, caso.CC_Owner_Anterior__c, 'El owner anterior no esta vacio');
				System.assertNotEquals(caso.OwnerId, caso.CC_Owner_Anterior__c, 'El owner actual y el anterior no coinciden');
			}
			Test.stopTest();
		}
	}

	@isTest
	static void actualizarCasoTestS5() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];
		System.runAs(adminKinton) {
			//Entra la llamada
			Case caso = [SELECT Id from Case WHERE CC_Canal_Procedencia__c = 'CaixaBankNow' LIMIT 1];
			CC_Llamada_Input inputLlamada = obtenerInputLlamada('S5', null, caso.Id, '', null);
			Map<String, Object> respuestaRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamada = (CC_Llamada__c)respuestaRegistrarLlamadaEntrante.get('llamada');
			Test.startTest();
			User agenteCompletarConsulta = [SELECT Id FROM User WHERE LastName = 'Agente 2'];
			System.RunAs(agenteCompletarConsulta) {
				//Realizamos una consulta
				CC_Llamada_Input inputConsulta = obtenerInputConsulta('S5', '', caso.Id.toString(), llamada.Id);
				Map<String, Object> respuestaRegistrarConsulta = CC_Llamada_GC.registrarConsulta(inputConsulta);
				CC_Llamada__c consulta = (CC_Llamada__c)respuestaRegistrarConsulta.get('llamada');

				CC_Llamada_Input inputCompletarConsulta = obtenerInputConsulta('S5', consulta.Id, caso.Id, llamada.Id);
				CC_Llamada__c consultaCompletada = [SELECT Id FROM CC_Llamada__c WHERE Id = :consulta.Id AND CC_Fecha_Fin__c = NULL];
				Task actividadCompletada = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :consultaCompletada.Id AND Status = 'Open' LIMIT 1];
				//Completamos la consulta
				CC_Llamada_GC.completarConsulta(inputCompletarConsulta.connId, UserInfo.getUserId());
				Case casobis = [SELECT Id, OwnerId from Case WHERE CC_Canal_Procedencia__c = 'CaixaBankNow' LIMIT 1];
				System.assertEquals(casobis.OwnerId, UserInfo.getUserId());
			}
			Test.stopTest();
		}
	}

	@isTest
	public static void llamarSalienteColgar() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];
        System.runAs(adminKinton) {
			Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso cliente Test'];

			Test.startTest();
			//Realizar la llamada saliente
			CC_Llamada_Input inputLlamadaSaliente = obtenerInputLlamada(null, null, caso.Id, null, null);
			Map<String, Object> retornoRegistrarLlamadaSaliente = CC_Llamada_GC.registrarLlamadaSaliente(inputLlamadaSaliente);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)retornoRegistrarLlamadaSaliente.get('llamada');

			//Colgamos la llamada
			CC_Llamada_Input inputFinalizarLlamada = obtenerInputLlamada(null, llamadaSaliente.Id, caso.Id, null, null);
			CC_Llamada_GC.finalizarLlamada(inputFinalizarLlamada, 'Llamada finalizada');
			Test.stopTest();

			System.assert(![SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaSaliente.Id AND WhatId = :caso.Id
							AND Type = 'Llamada saliente' AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1].isEmpty());
			System.assert(![SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaSaliente.Id
							AND CC_Fecha_Fin__c != NULL AND CC_Tipo_Cierre__c = 'Llamada finalizada'].isEmpty());
		}
	}

	@isTest
	public static void llamadaServicioGenesysDesplieguesTest() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

		System.runAs(adminKinton) {
			CC_Creacion_Datos_Test.lovAvisosSobreAgrupadores();
			CC_Servicio_Genesys__c s1 = crearServicioDespliegues();
			Contact contacto = [SELECT Account.CC_NumPerso__c FROM Contact WHERE LastName = 'Contacto Test'];
			//contacto = [SELECT Account.CC_NumPerso__c FROM Contact WHERE Id = :contacto.Id];

			//Entra la llamada
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(s1.CC_Codigo__c, '', '', contacto.Account.CC_NumPerso__c, null);

			Test.startTest();
			Map<String, Object> respuestaRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			Test.stopTest();
			CC_Llamada__c llamada = (CC_Llamada__c)respuestaRegistrarLlamadaEntrante.get('llamada');

			System.assertEquals('Despliegues', [SELECT CC_Canal_del_Empleado__c FROM CC_Llamada__c WHERE Id = :llamada.Id].CC_Canal_del_Empleado__c);

		}
	}

	@isTest
	public static void llamadaServicioGenesysDespliegues2Test() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

		System.runAs(adminKinton) {
			CC_Servicio_Genesys__c s1 = crearServicioDespliegues2();
			Contact contacto = [SELECT Account.CC_NumPerso__c FROM Contact WHERE LastName = 'Contacto Test'];
			//Entra la llamada
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(s1.CC_Codigo__c, '', '', contacto.Account.CC_NumPerso__c, null);
			Test.startTest();
			Map<String, Object> respuestaRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			Test.stopTest();
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)respuestaRegistrarLlamadaEntrante.get('llamada');

			System.assertEquals('Despliegues2', [SELECT CC_Canal_del_Empleado__c FROM CC_Llamada__c WHERE Id = :llamadaEntrante.Id].CC_Canal_del_Empleado__c);
			System.assert(llamadaEntrante != null);
		}
	}
	//------------------
	@isTest
	public static void llamadaServicioGenesysDesplieguesTestDENIED() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

		System.runAs(adminKinton) {
			CC_Creacion_Datos_Test.lovAvisosSobreAgrupadores();
			CC_Servicio_Genesys__c s1 = crearServicioDespliegues();
			Contact contacto = [SELECT Account.CC_NumPerso__c FROM Contact WHERE LastName = 'Contacto Test'];
			//contacto = [SELECT Account.CC_NumPerso__c FROM Contact WHERE Id = :contacto.Id];

			//Entra la llamada
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(s1.CC_Codigo__c, '', '', contacto.Account.CC_NumPerso__c, null);
			inputLlamada.statusAuto = 'DENIED';
			Test.startTest();
			Map<String, Object> respuestaRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			Test.stopTest();
			CC_Llamada__c llamada = (CC_Llamada__c)respuestaRegistrarLlamadaEntrante.get('llamada');

			System.assertEquals('Despliegues', [SELECT CC_Canal_del_Empleado__c FROM CC_Llamada__c WHERE Id = :llamada.Id].CC_Canal_del_Empleado__c);

		}
	}
	//------------------
	@isTest
	public static void cerrarLlamadasAbiertas() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

		System.runAs(adminKinton) {
			CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1'];

			//Entra la llamada
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada(s1.CC_Codigo__c, '', '', '', null);
			Map<String, Object> respuestaRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamada = (CC_Llamada__c)respuestaRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamada != null);

			//Creamos caso manualmente
			Test.startTest();
			CC_Llamada_GC.crearVincularCaso(llamada);
			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
			System.assert(actividad != null);

			//<...y por lo que sea no la finalizamos...>

			//Entra otra llamada
			CC_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			Test.stopTest();

			actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(actividad != null);
			llamada = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamada.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(llamada != null);
		}
	}

	@isTest
	public static void registrarLlamadasEmpleados() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

        System.runAs(adminKinton) {
            CC_Servicio_Genesys__c servicio = crearServicioEmpleado();

			CC_Llamada_Input inputLlamadaTelefonoUnico = obtenerInputLlamada(servicio.CC_Codigo__c, '', '', '666', '666001122');
			Test.startTest();
			CC_Llamada_GC.registrarLlamadaEntrante(inputLlamadaTelefonoUnico);
			CC_Llamada_Input inputLlamadaTelefonoDuplicado = obtenerInputLlamada(servicio.CC_Codigo__c, '', '', '777', '666001133');
			CC_Llamada_GC.registrarLlamadaEntrante(inputLlamadaTelefonoDuplicado);

			Test.stopTest();
			List<CC_Llamada__c> listaLlamadas = [SELECT CC_Cuenta__c, CC_Contacto__c FROM CC_Llamada__c ORDER BY CC_DNIS__c ASC];
            List<Contact> listaContactos = [SELECT Id FROM Contact WHERE FirstName = 'Contacto1 OF' AND Recordtype.Developername = 'CC_Empleado'];
            List<Account> listaCuentas = [SELECT Id FROM Account WHERE Name = 'Cuenta Centro CaixaBank Test 1' AND Recordtype.Developername = 'CC_CentroCaixaBank' AND CC_Tipo_Centro__c = 'OF'];
			// Primera llamada deberia funcionar, porque solo hay un empleado con ese numero de telefono
			System.assertEquals(listaContactos[0].Id, listaLlamadas[0].CC_Contacto__c);
			System.assertEquals(listaCuentas[0].Id, listaLlamadas[0].CC_Cuenta__c);
			// Segunda llamada deberia fallar, porque hay dos empleados con el mismo numero de telefono
			System.assertEquals(null, listaLlamadas[1].CC_Contacto__c);
			System.assertEquals(null, listaLlamadas[1].CC_Cuenta__c);
		}
	}

	private class MockHttpResponse implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			System.assertEquals('https://PASOfile-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3', req.getEndpoint());
			System.assertEquals('GET', req.getMethod());
			System.assertEquals('keep-alive', req.getHeader('Connection'));
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('{"example":"test"}');
			res.setStatusCode(200);
			return res;
		}
	}

	@isTest
	public static void cogerConsultaEmpleadosColgar() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];
		System.runAs(adminKinton) {
			//Entra la llamada
			CC_Servicio_Genesys__c s3 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 3' LIMIT 1];
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(s3.CC_Codigo__c, '', null, '', null);
			Map<String, Object> respuestaRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamada = (CC_Llamada__c)respuestaRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamada != null);

			//El usuario informa la cuenta en la llamada
			llamada.CC_Cuenta__c = [SELECT Id FROM Account WHERE Name = 'Oficina gestora Test'].Id;
			update llamada;

			Test.startTest();
			CC_Llamada_GC.finalizarLlamada(inputLlamada, 'Llamada finalizada');
			Test.stopTest();

			List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamada.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(!llamadas.isEmpty());
		}
	}

	@isTest
	public static void cogerConsultaNoAtendidaEmpleados() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

		System.runAs(adminKinton) {
			CC_Servicio_Genesys__c s3 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 3' LIMIT 1];
			Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso empleado Test'];

			Test.startTest();
			//Entra la llamada
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(s3.CC_Codigo__c, '', caso.Id, '', null);
			Map<String, Object> retornoRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');
			inputLlamada = obtenerInputLlamada(s3.CC_Codigo__c, llamadaEntrante.Id, caso.Id, '', null);
			System.assert(llamadaEntrante != null);

			//Consulta externa a un número de teléfono que conseguimos identificar
			CC_Llamada_Input inputConsulta = obtenerJsonConsultaExterna(caso.Id, llamadaEntrante.Id, '', '690998877');
			CC_Llamada_GC.registrarConsultaNoAtendida(inputLlamada, inputConsulta);

			//Consulta externa a un número de teléfono que NO conseguimos identificar
			inputConsulta = obtenerJsonConsultaExterna(caso.Id, llamadaEntrante.Id, '', '690111000');
			Id vuelta = CC_Llamada_GC.registrarConsultaNoAtendida(inputLlamada, inputConsulta);
			//Colgamos la llamada
			CC_Llamada_GC.finalizarLlamada(inputLlamada, 'Llamada finalizada');
			Test.stopTest();

			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			llamadaEntrante = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaEntrante.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada'];
			System.assert(llamadaEntrante != null);
		}
	}

	@isTest
	public static void cogerConsultaEmpleadoCompletar() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

		System.runAs(adminKinton) {
			CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1' LIMIT 1];

			//Entra la llamada
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(s1.CC_Codigo__c, '', null, '', null);
			Map<String, Object> retornoRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamadaEntrante != null);

			//El usuario informa la cuenta en la llamada
			llamadaEntrante.CC_Cuenta__c = [SELECT Id FROM Account WHERE Name = 'Cuenta Test'].Id;
			update llamadaEntrante;
			Test.startTest();
			// Widget recupera el nombre del empleado gestor de la llamada para mostrarselo como opción al usuario
			// Contact empleadoGestor = CC_OpenCTI.obtenerEmpleadoGestor(llamadaEntrante.Id);
			// System.assertEquals(empleadoGestor.Id, [SELECT Id FROM Contact WHERE LastName = 'Empleado gestor Test'].Id);

			//Se cuelga la llamada al transferir al completar la consulta
			inputLlamada = obtenerInputLlamada(s1.CC_Codigo__c, llamadaEntrante.Id, null, '', null);
			CC_Llamada_GC.finalizarLlamada(inputLlamada, 'Llamada finalizada');
			llamadaEntrante = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaEntrante.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(llamadaEntrante != null);
			Test.stopTest();
		}
	}

	@isTest
	public static void finalizarConsulta() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

		System.runAs(adminKinton) {
			CC_Servicio_Genesys__c s3 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 3' LIMIT 1];
			Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso cliente Test'];

			//Entra la llamada
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(s3.CC_Codigo__c, '', null, '', null);
			Map<String, Object> retornoRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamadaEntrante != null);

			//Consulta externa al empleado gestor de la cuenta de la llamada
			CC_Llamada_Input inputConsultaExterna = obtenerInputConsulta(caso.Id, llamadaEntrante.Id, null, null);
			Test.startTest();
			CC_Llamada_GC.finalizarConsulta(inputConsultaExterna, 'Consulta completada');
			Test.stopTest();
		}
	}
	@isTest
	public static void informarLlamadaEnCursoTest() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];
		System.runAs(adminKinton) {
			CC_Llamada_GC.registrarLlamadaEntrante(obtenerInputLlamada('S1', '', '', '', null));
			Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso cliente Test' LIMIT 1];

			Test.startTest();
			Task tarea = new Task();
			tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
			tarea.WhatId = caso.Id;
			insert tarea;	//Dispara CC_Llamada_GC.informarLlamadaEnCurso() mediante Process Builder
			Test.stopTest();

			System.assertEquals(caso.Id, [SELECT WhatId FROM Task WHERE Id = :tarea.Id].WhatId);
		}
	}

	@isTest
	public static void finalizarLlamadaTest() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

		System.runAs(adminKinton) {
			CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1' LIMIT 1];
			Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso cliente Test'];

			//Realizar la llamada saliente
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(null, null, caso.Id, null, null);
			Map<String, Object> retornoRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaSaliente(inputLlamada);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamadaSaliente != null);
			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaSaliente.Id AND WhatId = :caso.Id AND Type = 'Llamada saliente' AND Status = 'Open' LIMIT 1];
			System.assert(actividad != null);
			inputLlamada = obtenerInputLlamada(null, null, caso.Id, null, null);

			Test.startTest();
			//Colgamos la llamada
			CC_Llamada_GC.finalizarLlamada(inputLlamada, 'Llamada finalizada');
			Test.stopTest();

			actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaSaliente.Id AND WhatId = :caso.Id AND
							Type = 'Llamada saliente' AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(actividad != null);
			llamadaSaliente = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaSaliente.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(llamadaSaliente != null);
		}
	}

	@isTest
	public static void registrarConsultaNoAtendidaExceptionTest() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

		System.runAs(adminKinton) {
			CC_Servicio_Genesys__c s3 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 3' LIMIT 1];
			//Case caso = crearCaso();
			Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso cliente Test'];

			//Entra la llamada
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(s3.CC_Codigo__c, '', null, '', null);
			Test.startTest();
			Map<String, Object> retornoRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamadaEntrante != null);

			inputLlamada = obtenerInputLlamada(s3.CC_Codigo__c, llamadaEntrante.Id, caso.Id, '', null);

			//Consulta externa a un número de teléfono que conseguimos identificar
			CC_Llamada_Input inputConsultaExterna = obtenerJsonConsultaExterna(caso.Id, llamadaEntrante.Id, '', '690998877');
			CC_Llamada_GC.registrarConsultaNoAtendida(inputConsultaExterna, inputLlamada);
			Id idEmpleadoGestor = [SELECT Id FROM Contact WHERE LastName = 'Empleado gestor Test'].Id;
			List<Task> listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta no atendida' AND CC_Empleado_Gestor__c = :idEmpleadoGestor];
			System.assertEquals(0, listaTareas.size());

			//Colgamos la llamada
			CC_Llamada_GC.finalizarLlamada(inputLlamada, 'Llamada finalizada');
			Test.stopTest();
			llamadaEntrante = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaEntrante.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(llamadaEntrante != null);
		}
	}

	@isTest
	public static void testHayCasosAbiertosCuenta() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];
		System.runAs(adminKinton) {		

			List<Case> listaCasos = [SELECT AccountId FROM Case WHERE Subject = 'Caso cliente Test'];

			Test.startTest();
			Boolean resultado = CC_Llamada_GC.hayCasosAbiertosCuenta(listaCasos[0].AccountId);
			Test.stopTest();

			// Comprueba el resultado esperado
			System.assertEquals(true, resultado);
		}
	}

	@isTest
	public static void testIdentificarPorTelefono() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

		System.runAs(adminKinton) {
			// Crea los datos de prueba necesarios
			CC_Llamada__c llamada = new CC_Llamada__c();
			String telefono = '123456789'; // Asigna un número de teléfono válido aquí

			// Crea un objeto ficticio de CC_Canal_Com__c para simular la búsqueda de empleado por teléfono
			CC_Canal_Com__c canalComunicacion = new CC_Canal_Com__c();
			// Asigna los campos necesarios para el objeto ficticio de CC_Canal_Com__c
			// ...

			// Inserta el objeto ficticio de CC_Canal_Com__c en la base de datos de prueba
			insert canalComunicacion;

			// Llama al método que se va a probar
			Test.startTest();
			CC_Llamada_GC.identificarPorTelefono(llamada, telefono);
			Test.stopTest();

			// Comprueba los resultados esperados
			System.assertEquals(canalComunicacion.CC_ContactoId__r.AccountId, llamada.CC_Cuenta__c);
			System.assertEquals(canalComunicacion.CC_ContactoId__c, llamada.CC_Contacto__c);
		}
	}

	@isTest
	public static void registrarEncuesta() {
		User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];
		System.runAs(adminKinton) {

			Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso cliente Test'];

			
            CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1' LIMIT 1];
            CC_Servicio_Genesys__c encuesta = [SELECT Id FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio Encuesta' LIMIT 1];
			s1.CC_Encuesta__c = encuesta.Id;
			update s1;
			//Realizar la llamada saliente
			CC_Llamada_Input inputLlamadaSaliente = obtenerInputLlamada(null, null, caso.Id, null, null);
			Map<String, Object> retornoRegistrarLlamadaSaliente = CC_Llamada_GC.registrarLlamadaSaliente(inputLlamadaSaliente);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)retornoRegistrarLlamadaSaliente.get('llamada');

			//Colgamos la llamada
			CC_Llamada_Input inputFinalizarLlamada = obtenerInputLlamada(null, llamadaSaliente.Id, caso.Id, null, null);
			CC_Llamada_GC.finalizarLlamada(inputFinalizarLlamada, 'Llamada finalizada');
            Test.startTest();
            Map<String, Object> nombreEncuesta = CC_Llamada_GC.registrarEncuesta(inputFinalizarLlamada);
			Test.stopTest();
            
			System.assertEquals('Servicio Encuesta',nombreEncuesta.get('nombreEncuesta'), 'No se ha encontrado la encuesta');
		}
	}
}