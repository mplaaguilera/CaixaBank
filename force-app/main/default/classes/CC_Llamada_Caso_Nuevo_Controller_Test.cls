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

        /*
        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'Aplicaciones Oficina \\ TEST';
        oClasif.CC_Nivel_1__c = 'Aplicaciones Oficina';
        oClasif.CC_Clave_Primaria_Externa__c = 'Aplicaciones Oficina \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;

        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Estado__c = 'Activo';
        oAgr.CC_Publica__C = true;
        oAgr.CC_Estado__c = 'Activo';
        insert oAgr;*/

		



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

	/*
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

		system.debug('Entrando en 11111');
		System.runAs(supervisor){
			system.debug('Entrando en 2222222');
			Test.startTest();
			system.debug('Entrando en 333333' + llamadaEntrante.Id);

			CC_Llamada_Caso_Nuevo_Controller.Retorno elementosWrapper = CC_Llamada_Caso_Nuevo_Controller.Retorno.devolverMensaje(llamadaEntrante.Id);
			system.debug('Entrando en 55555' + elementosWrapper);
			Boolean cerrada = CC_Llamada_Caso_Nuevo_Controller.getLlamada(llamadaEntrante.Id);
			Boolean cuentaAsociada = CC_Llamada_Caso_Nuevo_Controller.cuentaAsociada(llamadaEntrante.Id);
			Case casoNuevo = CC_Llamada_Caso_Nuevo_Controller.crearCasoLlamada(llamadaEntrante.Id, 'Prueba');
			Test.stopTest();
				system.debug('Entrando en 444444');
			Id casoWrapper = elementosWrapper.getCaso.Id;
			String urlWrapper = elementosWrapper.getMensaje;

			String hostnameEntero = String.valueOf(System.Url.getOrgDomainUrl());
			String hostnameSubstring1 = hostnameEntero.remove('Url:[delegate=');
			String hostnameLimpio = hostnameSubstring1.remove(']');
			String url = hostnameLimpio + '/lightning/r/Case/' + caso.Id + '/view';
			System.assertEquals(url, urlWrapper, 'URL incorrecta');
			System.assertEquals(caso.Id, casoWrapper, 'Caso incorrecto');
		}
	}*/

    @isTest
	public static void test2() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};

        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = owa[0].Address;
        params.HDT_Configuracion_2__c = owa[0].Address;
        insert params;
		
         // Inicialización de datos.        
		Id recorTypeLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId(); 
		CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
		lista.Name = 'HDT - Aviso Comunicaciones Informativas';
		lista.CC_Activa__c = true;
		lista.RecordTypeId = recorTypeLista;
		insert lista;

		//Id listaPadre = [SELECT id FROM CC_Lista_Valores__c WHERE Name = 'HDT_Mensajes_Parametrizables_Empleados' limit 1].Id;
        // Crear un registro de CC_Lista_Valores__c para simular un resultado válido
        CC_Lista_Valores__c listaValor = new CC_Lista_Valores__c(
            Name = 'Comunicación Informativa de Caso - Umbral de tiempo',
            CC_Valor__c = '15',
            CC_Valor2__c = 'Validacion1',
            CC_Lista__c = lista.Id

        );
        insert listaValor;

        CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'Aplicaciones Oficina \\ TEST';
        oClasif.CC_Nivel_1__c = 'Aplicaciones Oficina';
        oClasif.CC_Clave_Primaria_Externa__c = 'Aplicaciones Oficina \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;

        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Estado__c = 'Activo';
        oAgr.CC_Publica__C = true;
        oAgr.CC_Estado__c = 'Activo';
        insert oAgr;
        
        String idAgrupador = oAgr.Id;

/*
        List<CC_Agrupador__c> agrupadores = [SELECT id FROM CC_Agrupador__c WHERE CC_Titulo__c = 'Test'];
        String idAgrupador = agrupadores[0].Id;*/

        Id idRtServicioGenesys = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();

        CC_Servicio_Genesys__c s1 = new CC_Servicio_Genesys__c();
		s1.RecordTypeId = idRtServicioGenesys;
		s1.Name = 'Servicio 1';
		s1.CC_Codigo__c = 'S1';
		s1.CBK_Negocio__c = 'HDT';
		s1.CC_VDN__c = '4444444';
		s1.CC_Tipo__C = 'Servicio';
		s1.CC_Canal_Procedencia__c = 'Servicios Centrales';
		s1.CC_Prefijo__c = '0';
		s1.CC_Tipo_Cliente__c = 'Empleado';
        s1.CC_Fecha_Inicio_Salesforce__c = Date.newInstance(2023, 11, 3);
        insert s1;


		CC_Llamada_Input inputLlamada = obtenerInputLlamada('s1', null, '', '', null);
		Map<String, Object> respuestaRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
		CC_Llamada__c llamadaEntrante = (CC_Llamada__c)respuestaRegistrarLlamadaEntrante.get('llamada');
		Case caso = (Case)respuestaRegistrarLlamadaEntrante.get('caso');

		User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE
							AND UserRole.Name = 'Contact Center' AND LastName = 'last11'
							AND Email = 'tuser000@amamama.com' LIMIT 1];

		//System.runAs(supervisor){
       
			Test.startTest();
			CC_Llamada_Caso_Nuevo_Controller.Retorno elementosWrapper = CC_Llamada_Caso_Nuevo_Controller.Retorno.devolverMensaje(llamadaEntrante.Id);
			Boolean cerrada = CC_Llamada_Caso_Nuevo_Controller.getLlamada(llamadaEntrante.Id);
			Boolean cuentaAsociada = CC_Llamada_Caso_Nuevo_Controller.cuentaAsociada(llamadaEntrante.Id);

			Case casoNuevo = CC_Llamada_Caso_Nuevo_Controller.crearCasoLlamadaMasiva(llamadaEntrante.Id, idAgrupador);
			Case casoNuevo2 = CC_Llamada_Caso_Nuevo_Controller.crearCasoLlamada(llamadaEntrante.Id, 'Prueba1');
			
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




    @isTest
    static void testGetAgrupadores() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

       
        Test.startTest();
        List<CC_Agrupador__c> result = CC_Llamada_Caso_Nuevo_Controller.getAgrupadores();
        Test.stopTest();

        // Validar que los resultados no están vacíos
        //System.assertNotEquals(0, result.size(), 'Debe haber registros devueltos');

        // Validar que los registros cumplen con las condiciones
        for (CC_Agrupador__c agrupador : result) {
           // System.assertEquals('Activo', agrupador.CC_Estado__c, 'El estado debe ser Activo');
            System.assertEquals(true, agrupador.CC_Publica__C, 'Debe ser público');
        }

        }
    }

}