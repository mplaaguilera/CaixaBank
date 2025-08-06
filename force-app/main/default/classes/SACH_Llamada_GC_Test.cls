@isTest
public class SACH_Llamada_GC_Test {

	@TestSetup
	private static void testSetup() {

		User usuarioAdmin = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator', 'Administrador del sistema')
								AND IsActive = TRUE LIMIT 1];
		System.runAs(usuarioAdmin) {
			Id perfilAdministradorId = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'Administrador del sistema') LIMIT 1].Id;

			User adminKinton = new User();
			adminKinton.LastName = 'Administrador Kinton';
			adminKinton.Alias = 'AUno';
			adminKinton.Email = 'ccAgenteGC@invalid.com';
			adminKinton.UserName = 'ccAgenteGC_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
			adminKinton.ProfileId = [SELECT Id FROM Profile WHERE Name = 'API Only'].Id;
			adminKinton.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
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
			agenteCancelarConsulta.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
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
			agenteCompletarConsulta.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
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
		s1.Name = 'Servicio 1';
		s1.CC_Codigo__c = 'S1';
		s1.CC_VDN__c = '4444444';
		s1.CC_Tipo__C = 'Servicio';
		s1.CC_Canal_Procedencia__c = 'CaixaBankNow';
		s1.CC_Prefijo__c = '0';
		s1.CC_Tipo_Cliente__c = 'Cliente';

		CC_Servicio_Genesys__c s2 = new CC_Servicio_Genesys__c();
		s2.RecordTypeId = idRtServicioGenesys;
		s2.Name = 'SACH GenesysCloudOutboundDefault';
		s2.CC_Codigo__c = 'SACH_GenesysCloudOutboundDefault';
		s2.CC_Tipo__C = 'Servicio';
		s2.CBK_Negocio__c = 'SACH';
		s2.CC_Tipo_Cliente__c = 'Cliente';
		s2.CC_VDN__c = '4444444';
		s2.CC_Canal_Procedencia__c = 'CaixaBankNow';
		s2.CC_Prefijo__c = '0';
		s2.CC_Fecha_Inicio_Salesforce__c = Date.today();
		s2.CC_Principal__c = true;
		insert new List<CC_Servicio_Genesys__c>{s1, s2};

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
			Account oficinaGestora = new Account();
			oficinaGestora.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
			oficinaGestora.CC_Numero_Empresa__c = '001';
			oficinaGestora.CC_Numero_Oficina__c = '00001';
			oficinaGestora.CC_Numero_Oficina_Empresa__c = '001-00001';
			oficinaGestora.Name = 'Oficina gestora Test';
			oficinaGestora.CC_Tipo_Centro__c = 'OF';
			oficinaGestora.CC_Email__c = 'test@test.com';
			insert oficinaGestora;

			Contact empleadoGestor = new Contact();
			empleadoGestor.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
			empleadoGestor.LastName = 'Empleado gestor Test';
			empleadoGestor.AccountId = oficinaGestora.Id;
			insert empleadoGestor;

			Account cuenta = new Account();
			cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			cuenta.Name = 'Cuenta Test';
			cuenta.CC_NumPerso__c = '666';
			cuenta.CC_OficinaGestoraId__c = oficinaGestora.Id;
			cuenta.AV_OficinaPrincipal__c = oficinaGestora.Id;
			cuenta.AV_EAPGestor__c = empleadoGestor.Id;
			insert cuenta;

			Contact contacto = new Contact();
			contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			contacto.AccountId = cuenta.Id;
			contacto.FirstName = 'Contacto';
			contacto.LastName = 'Contacto Test';
			contacto.CC_NumPerso__c = '666';
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
			insert casoCliente;
		}
	}

	private static CC_Llamada_Input obtenerInputLlamada(String servicio, String llamadaId, String casoId, String numPerso, String ani) {
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
		//inputLlamada.connIdCognitivo = '87654321';
		inputLlamada.casoId = casoId;
		inputLlamada.statusAuto = 'APPROVED';
		inputLlamada.perfil = 'EMPLEADOS';
		inputLlamada.llamadaId = llamadaId;
		return inputLlamada;
	}

	@isTest
	public static void cogerColgar() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

        System.runAs(adminKinton) {
            Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Test'];
            CC_Creacion_Datos_Test.lovAvisosSobreAgrupadores();
			CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1'];
			contacto = [SELECT Account.CC_NumPerso__c, AccountId FROM Contact WHERE Id = :contacto.Id];

			Test.startTest();
			//Entra la llamada
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(s1.CC_Codigo__c, '', '', contacto.Account.CC_NumPerso__c, null);
			CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c, CC_Encuesta__r.CC_Codigo__c
														FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputLlamada.servicio LIMIT 1];
			Map<String, Object> retornoRegistrarLlamadaEntrante = SACH_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');
			Id llamada = llamadaEntrante.Id;
			//system.assert(entrada != null);
			System.assert(llamadaEntrante.Id != null);

			//Creamos caso manualmente y lo cerramos con actividades de llamada abiertas
			Case caso1 = SACH_Llamada_GC.crearVincularCaso(llamadaEntrante);
			//String oficinaAfectada = [SELECT CC_Oficina_Afectada_Lookup__c FROM Case WHERE Id = :caso1.Id].CC_Oficina_Afectada_Lookup__c;
			//System.assertEquals(llamadax.CC_Cuenta__r.CC_OficinaGestoraId__c, oficinaAfectada);
			Test.stopTest();
			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada AND WhatId =: caso1.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];

			//Colgamos la llamada
            inputLlamada.llamadaId = llamada;
			SACH_Llamada_GC.finalizarLlamada(inputLlamada, 'Llamada finalizada');

			//actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			//System.assert(actividad != null);

			/*
			Id llamada2;
			llamada2 = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamada AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(llamada2 != null);*/
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
			Map<String, Object> retornoRegistrarLlamadaSaliente = SACH_Llamada_GC.registrarLlamadaSaliente(inputLlamadaSaliente);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)retornoRegistrarLlamadaSaliente.get('llamada');

			//Colgamos la llamada
			CC_Llamada_Input inputFinalizarLlamada = obtenerInputLlamada(null, llamadaSaliente.Id, caso.Id, null, null);
			SACH_Llamada_GC.finalizarLlamada(inputFinalizarLlamada, 'Llamada finalizada');
			Test.stopTest();

			System.assert(![SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaSaliente.Id AND WhatId = :caso.Id
							AND Type = 'Llamada saliente' AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1].isEmpty());
			System.assert(![SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaSaliente.Id
							AND CC_Fecha_Fin__c != NULL AND CC_Tipo_Cierre__c = 'Llamada finalizada'].isEmpty());
		}
	}

	@isTest
	public static void cerrarLlamadasAbiertas() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

		System.runAs(adminKinton) {
			CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1'];

			//Entra la llamada
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada(s1.CC_Codigo__c, '', '', '', null);
			Map<String, Object> respuestaRegistrarLlamadaEntrante = SACH_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamada = (CC_Llamada__c)respuestaRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamada != null);

			//Creamos caso manualmente
			Test.startTest();
			SACH_Llamada_GC.crearVincularCaso(llamada);
			Test.stopTest();
			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
			System.assert(actividad != null);

			//<...y por lo que sea no la finalizamos...>

			//Entra otra llamada
			SACH_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);

			actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamada.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(actividad != null);
			llamada = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamada.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(llamada != null);
		}
	}

	@isTest
	public static void finalizarLlamadaTest() {
        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];

		System.runAs(adminKinton) {
			CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1' LIMIT 1];
			// Case caso = crearCaso();
			Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso cliente Test'];

			//Realizar la llamada saliente
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(null, null, caso.Id, null, null);
			Map<String, Object> retornoRegistrarLlamadaEntrante = SACH_Llamada_GC.registrarLlamadaSaliente(inputLlamada);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamadaSaliente != null);
			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaSaliente.Id AND WhatId = :caso.Id AND Type = 'Llamada saliente' AND Status = 'Open' LIMIT 1];
			System.assert(actividad != null);
			Test.startTest();
			//Colgamos la llamada
			inputLlamada = obtenerInputLlamada(null, null, caso.Id, null, null);
			SACH_Llamada_GC.finalizarLlamada(inputLlamada, 'Llamada finalizada');
			actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaSaliente.Id AND WhatId = :caso.Id AND
							Type = 'Llamada saliente' AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(actividad != null);
			llamadaSaliente = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaSaliente.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(llamadaSaliente != null);
			Test.stopTest();
		}
	}
}