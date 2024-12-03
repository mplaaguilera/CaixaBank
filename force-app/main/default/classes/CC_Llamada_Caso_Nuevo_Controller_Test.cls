@isTest
public with sharing class CC_Llamada_Caso_Nuevo_Controller_Test {
	@TestSetup
	 static void testSetup() {
		Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
		Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];
		PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
		PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Tercer_Nivel_CBKNow'];
		PermissionSet psSupervisor = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS'];
		PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];

		//Id idAnteriorPropietario = [SELECT Id FROM User where email = 'tuser000@amamamaaaa.com' LIMIT 1].Id;

		Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;

		List<User> userList = new List<User>();

		User usuarioAdmin = new User();
		usuarioAdmin.profileId = profileAdmin;
		usuarioAdmin.UserRoleId = roleCC;
		usuarioAdmin.FirstName = '';
		usuarioAdmin.LastName = 'Administrador de sistema';
		usuarioAdmin.Email = 'tuser000@amamama.com';
		usuarioAdmin.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
		usuarioAdmin.CompanyName = 'MST';
		usuarioAdmin.Title = 'title';
		usuarioAdmin.Alias = 'alias';
		usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
		usuarioAdmin.EmailEncodingKey = 'UTF-8';
		usuarioAdmin.LanguageLocaleKey = 'es';
		usuarioAdmin.LocaleSidKey = 'es_ES';
		userList.add(usuarioAdmin);

		User supervisor = new User();
		supervisor.ProfileId = profileId;
		supervisor.FirstName = 'Supervisor';
		supervisor.LastName = 'last11';
		supervisor.Email = 'tuser000@amamama.com';
		supervisor.Username = 'tuser000@supervisor.com' + System.currentTimeMillis();
		supervisor.CompanyName = 'MST';
		supervisor.Title = 'title';
		supervisor.Alias = 'alias';
		supervisor.TimeZoneSidKey = 'Europe/Paris';
		supervisor.EmailEncodingKey = 'UTF-8';
		supervisor.LanguageLocaleKey = 'es';
		supervisor.LocaleSidKey = 'es_ES';
		supervisor.UserRoleId = roleCC;
		userList.add(supervisor);


		insert userList;

		insert new PermissionSetAssignment(AssigneeId = usuarioAdmin.Id, PermissionSetId = ps.Id);
		insert new PermissionSetAssignment(AssigneeId = usuarioAdmin.Id, PermissionSetId = ps2.Id);
		insert new PermissionSetAssignment(AssigneeId = usuarioAdmin.Id, PermissionSetId = ps3.Id);
		insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psClasses.Id);
		insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psSupervisor.Id);
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
		inputLlamada.casoId = casoId;
		inputLlamada.statusAuto = 'APPROVED';
		inputLlamada.perfil = 'EMPLEADOS';
		inputLlamada.llamadaId = llamadaId;
		return inputLlamada;
	}

	@isTest
	public static void test() {
		CC_Servicio_Genesys__c s1 = new CC_Servicio_Genesys__c();
		s1.RecordTypeId = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();
		s1.CBK_Negocio__c = 'CC';
		s1.Name = 'Servicio 1';
		s1.CC_Codigo__c = 'S1';
		s1.CC_VDN__c = '4444444';
		s1.CC_Tipo__C = 'Servicio';
		s1.CC_Canal_Procedencia__c = 'CaixaBankNow';
		s1.CC_Prefijo__c = '0';
		s1.CC_Tipo_Cliente__c = 'Cliente';
		s1.CC_Fecha_Inicio_Salesforce__c = Date.newInstance(2023, 11, 3);
		insert s1;

		CC_Llamada_Input inputLlamada = obtenerInputLlamada('s1', null, '', '', null);
		Map<String, Object> respuestaRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
		CC_Llamada__c llamadaEntrante = (CC_Llamada__c)respuestaRegistrarLlamadaEntrante.get('llamada');
		Case caso = (Case)respuestaRegistrarLlamadaEntrante.get('caso');

		User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE
							AND UserRole.Name = 'Contact Center' AND LastName = 'last11'
							AND Email = 'tuser000@amamama.com' LIMIT 1];

		System.runAs(supervisor){
			Test.startTest();
			CC_Llamada_Caso_Nuevo_Controller.Retorno elementosWrapper = CC_Llamada_Caso_Nuevo_Controller.Retorno.devolverMensaje(llamadaEntrante.Id);
			Boolean cerrada = CC_Llamada_Caso_Nuevo_Controller.getLlamada(llamadaEntrante.Id);
			Boolean cuentaAsociada = CC_Llamada_Caso_Nuevo_Controller.cuentaAsociada(llamadaEntrante.Id);
			Case casoNuevo = CC_Llamada_Caso_Nuevo_Controller.crearCasoLlamada(llamadaEntrante.Id, 'Prueba');
			Test.stopTest();

			Id casoWrapper = elementosWrapper.getCaso.Id;
			String urlWrapper = elementosWrapper.getMensaje;

			String hostnameEntero = String.valueOf(System.Url.getOrgDomainUrl());
			String hostnameSubstring1 = hostnameEntero.remove('Url:[delegate=');
			String hostnameLimpio = hostnameSubstring1.remove(']');
			String url = hostnameLimpio + '/lightning/r/Case/' + caso.Id + '/view';
			System.assertEquals(url, urlWrapper, 'URL incorrecta');
			System.assertEquals(caso.Id, casoWrapper, 'Caso incorrecto');
		}
	}
}