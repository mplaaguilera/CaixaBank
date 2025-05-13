@isTest
public class HDT_Llamada_GC_Test {

	@TestSetup
	private static void testSetup() {
		String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
        oGrupo.RecordTypeId = sRecordType3;
        oGrupo.Name = 'Grupo1';
        oGrupo.CC_External__c = 'GC-00001';
        insert oGrupo;

		CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
        oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
        oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
        oClasif.CC_Activa__c = true;
        oClasif.CC_Propietario__c = 'TEST';
        insert oClasif;
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c oAgr = new CC_Agrupador__c();
        oAgr.RecordTypeId = sRecordType;
        oAgr.CC_Titulo__c = 'Test';
        oAgr.CC_Descripcion__c = 'Test';
        oAgr.CC_GrupoMaximo__c = oGrupo.Id;
        oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
        oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
        oAgr.CC_Estado__c = 'Activo';
        insert oAgr;


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

		CC_Servicio_Genesys__c s2 = new CC_Servicio_Genesys__c();
		s2.RecordTypeId = idRtServicioGenesys;
		s2.Name = 'HDT Genesys Cloud Saliente Por Defecto';
		s2.CC_Codigo__c = 'HDT_GenesysCloudOutboundDefault';
		s2.CC_Tipo__C = 'Servicio';
		s2.CBK_Negocio__c = 'HDT';
		s2.CC_Tipo_Cliente__c = 'Empleado';
		s2.CC_VDN__c = '4444444';
		s2.CC_Canal_Procedencia__c = 'CaixaBankNow';
		s2.CC_Prefijo__c = '0';
		s2.CC_Fecha_Inicio_Salesforce__c = Date.today();
		s2.CC_Principal__c = true;

		CC_Servicio_Genesys__c s3 = new CC_Servicio_Genesys__c();
		s3.RecordTypeId = idRtServicioGenesys;
		s3.Name = 'Servicio 3';
		s3.CC_Codigo__c = 'S3';
		s3.CC_VDN__c = '4444444';
		s3.CC_Tipo__C = 'Servicio';
		s3.CC_Canal_Procedencia__c = 'Servicios Centrales';
		s3.CC_Prefijo__c = '0';
		s3.CC_Tipo_Cliente__c = 'Empleado';

		CC_Servicio_Genesys__c s4 = new CC_Servicio_Genesys__c();
		s4.RecordTypeId = idRtServicioGenesys;
		s4.Name = 'Servicio 4';
		s4.CC_Codigo__c = 'S4';
		s4.CC_VDN__c = '4444444';
		s4.CC_Tipo__C = 'Tercer nivel';
		s4.CC_Canal_Procedencia__c = 'Servicios Centrales';
		s4.CC_Prefijo__c = '0';
		s4.CC_Tipo_Cliente__c = 'Empleado';

		insert new List<CC_Servicio_Genesys__c>{s1, s2, s3, s4};

		Id perfilAdministradorId = [SELECT Id FROM Profile
									WHERE Name IN ('System Administrator', 'Administrador del sistema') LIMIT 1].Id;

		User agenteCancelarConsulta = new User();
		agenteCancelarConsulta.FirstName = 'Agente';
		agenteCancelarConsulta.LastName = 'Uno';
		agenteCancelarConsulta.Alias='AUno';
		agenteCancelarConsulta.Email = 'agente2@invalid.com';
		agenteCancelarConsulta.Username= 'agente1@caixa.com';
		agenteCancelarConsulta.ProfileId = perfilAdministradorId;
		agenteCancelarConsulta.EmailEncodingkey='UTF-8';
		agenteCancelarConsulta.LanguageLocaleKey='en_US';
		agenteCancelarConsulta.LocalesIdKey='en_US';
		agenteCancelarConsulta.TimezonesIdKey='Europe/Berlin';

		User agenteCompletarConsulta = new User();
		agenteCompletarConsulta.FirstName = 'Automated';
		agenteCompletarConsulta.LastName = 'Process';
		agenteCompletarConsulta.Alias='ADos';
		agenteCompletarConsulta.Email = 'agente2@invalid.com';
		agenteCompletarConsulta.Username= 'agente2@caixa.com';
		agenteCompletarConsulta.ProfileId = perfilAdministradorId;
		agenteCompletarConsulta.EmailEncodingkey='UTF-8';
		agenteCompletarConsulta.LanguageLocaleKey='en_US';
		agenteCompletarConsulta.LocalesIdKey='en_US';
		agenteCompletarConsulta.TimezonesIdKey='Europe/Berlin';
		//agenteCompletarConsulta.UserRoleId = '00E3Y000002HoEPUA0';

		insert new List<User>{agenteCancelarConsulta, agenteCompletarConsulta};

		Id recordTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
		CC_MCC__c tematica = new CC_MCC__c();
		tematica.RecordTypeId = recordTypeTematica;
		tematica.CC_Tipo_Cliente__c = 'HDT Empleado';
		tematica.Name = 'Temática';
		tematica.CC_Codigo_Externo__c = 'T1';
		tematica.CC_Canal_Operativo__c = 'Oficina';
		insert tematica;

		Id recordTypeProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		CC_MCC__c producto = new CC_MCC__c();
		producto.RecordTypeId = recordTypeProducto;
		producto.CC_Tipo_Cliente__c = 'HDT Empleado';
		producto.Name = 'Producto';
		producto.CC_Tematica__c = tematica.Id;
		producto.CC_Codigo_Externo__c = 'P1';
		insert producto;

		Id recordTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		CC_MCC__c motivo = new CC_MCC__c();
		motivo.RecordTypeId = recordTypeMotivo;
		motivo.CC_Tipo_Cliente__c = 'HDT Empleado';
		motivo.Name = 'Motivo';
		motivo.CC_Producto_Servicio__c = producto.Id;
		motivo.CC_Codigo_Externo__c = 'M1';
		insert motivo;

		Id recordTypeCausa = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
		CC_MCC__c causa = new CC_MCC__c();
		causa.RecordTypeId = recordTypeCausa;
		causa.CC_Tipo_Cliente__c = 'HDT Empleado';
		causa.Name = 'Causa';
		causa.CC_Motivo__c = motivo.Id;
		causa.CC_Codigo_Externo__c = 'C1';
		insert causa;

		Id recordTypeSolucion = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
		CC_MCC__c solucion = new CC_MCC__c();
		solucion.RecordTypeId = recordTypeSolucion;
		solucion.CC_Tipo_Cliente__c = 'HDT Empleado';
		solucion.Name = 'Solucion';
		solucion.CC_Causa__c = causa.Id;
		solucion.CC_Codigo_Externo__c = 'S1';
		insert solucion;

		//Empleado y empleado gestor
		Id idRecordTypeOficina = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		Account oficina = new Account(
			RecordTypeId = idRecordTypeOficina,
			Name = 'Cuenta',
			CC_Tipo_Centro__c = 'OF'
		);
		Account oficinaEmpleadoGestor = new Account(
			RecordTypeId = idRecordTypeOficina,
			Name = 'Cuenta',
			CC_Tipo_Centro__c = 'OF'
		);
		insert new List<Account>{oficina, oficinaEmpleadoGestor};

		Id idRecordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
		Contact empleado = new Contact(
			RecordTypeId = idRecordTypeEmpleado,
			FirstName = 'Empleado',
			LastName = 'Empleado Test',
			AccountId = oficina.Id,
			Phone = '555555555'
		);
		Contact empleadoGestor = new Contact(
			RecordTypeId = idRecordTypeEmpleado,
			FirstName = 'Empleado gestor',
			LastName = 'Empleado gestor Test',
			AccountId = oficinaEmpleadoGestor.Id,
			Phone = '777777777'
		);
		insert new List<Contact>{empleado, empleadoGestor};

		CC_Canal_Com__c canalComunicacionEmpleado = new CC_Canal_Com__c();
		canalComunicacionEmpleado.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
		canalComunicacionEmpleado.CC_Clase_Com__c = '1';
		canalComunicacionEmpleado.CC_ContactoId__c = empleado.Id;
		canalComunicacionEmpleado.CC_Telefono__c = '555555555';

		CC_Canal_Com__c canalComunicacionGestor = new CC_Canal_Com__c();
		canalComunicacionGestor.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
		canalComunicacionGestor.CC_Clase_Com__c = '1';
		canalComunicacionGestor.CC_ContactoId__c = empleadoGestor.Id;
		canalComunicacionGestor.CC_Telefono__c = '777777777';
		insert new List<CC_Canal_Com__c>{canalComunicacionEmpleado, canalComunicacionGestor};

		//Caso
		Case caso = new Case();
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
		caso.Subject = 'Caso Test';
		caso.Origin = 'Phone';
		caso.CC_Canal_Respuesta__c = 'Phone';
		caso.CC_Tipo_Cliente__c = 'Empleado';
		caso.CC_No_Identificado__c = true;
		caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
		insert caso;

		HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = 'pruebas.empleados.hdt.devser@gmail.com';
        insert params;

		HDT_Parametros__c params2 = new HDT_Parametros__c();
        params2.Name = 'HDT_Llamadas_Salientes_No_Atendidas';
		params2.HDT_Activo__c = true;
        params2.HDT_Configuracion_1__c = 'HDT_GenesysCloudOutboundDefault';
        insert params2;

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

		CC_Lista_Valores__c listaValor2 = new CC_Lista_Valores__c(
            Name = 'Tipo de Activos asociados a Cuenta desde llamada',
            CC_Valor__c = 'TAPC',
            CC_Valor2__c = 'PORT',
			CSBD_Valor4__c = 'Instalado',
            CC_Lista__c = lista.Id

        );
        insert listaValor2;

		CC_Lista_Valores__c listaValor3 = new CC_Lista_Valores__c(
            Name = 'Asociar casos a masivas desde llamadas',
            CC_Valor__c = 'RA -',
            CC_Valor2__c = 'Agregado desde masiva :',
            CC_Lista__c = lista.Id

        );
        insert listaValor3;

		 // Crear un activo asociado a la cuenta
         Asset asset = new Asset(Name = 'Test Asset', AccountId = oficina.Id);
         insert asset;


	}

	private static CC_Servicio_Genesys__c crearServicioDespliegues() {
		CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(Name = 'Despliegues',
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

	private static CC_Servicio_Genesys__c crearServicioDespliegues2() {
		CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(Name = 'Despliegues2',
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

	private static CC_Servicio_Genesys__c crearServicioEncuesta() {
		CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(Name = 'Encuesta',
		CC_Codigo__c = 'ENCUESTA',
		CC_VDN__c = '4444446',
		CC_Canal_Procedencia__c = 'Incidencias Técnicas',
		CC_Fecha_Inicio_Salesforce__c = date.today().addDays(-3),
		recordTypeId = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Encuesta').getRecordTypeId());
		insert servicio;
		return servicio;
	}

	private static Task crearActividadManual(String subject, Id llamadaId, Id casoId) {
		Task actividad = new Task(
			Subject = subject,
			CC_Llamada_Id__c = llamadaId,
			ActivityDate = System.today(),
			CC_Fecha_Inicio__c = System.now(),
			WhatId = casoId,
			RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId(),
			Type = 'Actividad manual'
		);
		insert actividad;
		return actividad;
	}

	private static Case cerrarCaso(Case caso) {
		caso.CC_MCC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Temática'].Id;
		caso.CC_MCC_ProdServ__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Producto'].Id;
		caso.CC_MCC_Motivo__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Motivo'].Id;
		caso.CC_MCC_Causa__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Causa'].Id;
		caso.CC_MCC_Solucion__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'Solucion'].Id;
		caso.CC_Detalles_Solucion__c = 'Detalles solución';
		caso.CC_Tipo_Contacto__c = 'Consulta';
		caso.CC_Canal_Operativo__c = 'Sin canal';
		caso.CC_Detalles_Consulta__c = 'Detalles consulta';
		caso.Status = 'Cerrado';
		update caso;
		return caso;
	}

	private static CC_Llamada__c obtenerLlamada(Id id) {
		return [SELECT CC_Cuenta__r.CC_OficinaGestoraId__c,  CC_Servicio_Genesys__c, CC_Asunto__c, CC_Idioma__c, CC_ANI__c,
				CC_No_Identificado__c, CC_Cuenta__c, CC_Contacto__c, CC_Tipo__c, CC_ConnId__c, CC_ConnId_Consulta__c,
				CC_Id_Cognitivo__c, CC_Canal_del_Empleado__c, CC_IdentCliente__c, CC_Status_Autorizacion__c, CC_Perfil__c
				FROM CC_Llamada__c WHERE Id = :id AND CC_Fecha_Fin__c = NULL];
	}

	private static CC_Llamada_Input obtenerInputLlamada(String servicio, String llamadaId, String casoId) {
		CC_Llamada_Input inputLlamada = new CC_Llamada_Input();
		inputLlamada.usuario = '1218';
		inputLlamada.connId = '12345678';
		inputLlamada.ani = '555555555';
		inputLlamada.dnis = '666666666';
		inputLlamada.servicio = servicio;
		inputLlamada.asunto = 'Asunto';
		inputLlamada.idioma = 'Castellano';
		inputLlamada.datos = 'Datos';
		inputLlamada.connIdCognitivo = '87654321';
		inputLlamada.casoId = casoId == null ? '' : casoId;
		inputLlamada.salesforceParentId = null;
		inputLlamada.statusAuto = 'APPROVED';
		inputLlamada.perfil = 'EMPLEADOS';
		inputLlamada.llamadaId = llamadaId == null ? '' : llamadaId;
		return inputLlamada;
	}

	private static CC_Llamada_Input obtenerInputConsulta(String servicio, String llamadaId, String casoId, String salesforceParentId) {
		CC_Llamada_Input inputConsulta = new CC_Llamada_Input();
		inputConsulta.usuario = '1219';
		inputConsulta.llamadaId = llamadaId;
		inputConsulta.connId = '12348765';
		inputConsulta.ani = '666666666';
		inputConsulta.dnis = '666666666';
		inputConsulta.servicio = servicio;
		inputConsulta.idioma = 'Castellano';
		inputConsulta.salesforceParentId = salesforceParentId;
		inputConsulta.casoId = casoId;
		return inputConsulta;
	}

	private static CC_Llamada_Input obtenerInputConsultaExterna(String servicio, String casoId, String salesforceParentId, String empleadoId, String empleadoTelefono) {
		CC_Llamada_Input inputConsultaExterna = new CC_Llamada_Input();
		inputConsultaExterna.usuario = '1219';
		inputConsultaExterna.connId = '12348765';
		inputConsultaExterna.empleadoId = empleadoId;
		inputConsultaExterna.empleadoTelefono = empleadoTelefono;
		inputConsultaExterna.servicio = servicio == null ? '' : servicio;
		inputConsultaExterna.salesforceParentId = salesforceParentId;
		inputConsultaExterna.casoId = casoId;
		return inputConsultaExterna;
	}

	@isTest
	public static void cogerColgar() {
		Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			CC_Creacion_Datos_Test.lovAvisosSobreAgrupadores();
			CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1'];

			Test.startTest();
			//Entra la llamada
			CC_Llamada_Input inputLlamada = obtenerInputLlamada(s1.CC_Codigo__c, '', '');
			Map<String, Object> retornoRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamadaEntrante != null, 'La llamada no debería ser nula');

			//Creamos caso manualmente y lo cerramos con actividades de llamada abiertas
			Case caso = HDT_Llamada_GC.crearVincularCaso(llamadaEntrante);
			Test.stopTest();

			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
			System.assert(actividad != null);

			//cerrarCaso(caso1);
			//caso1 = [SELECT Status FROM Case WHERE Id = :caso1.Id];
			//System.assertEquals('Cerrado', caso1.Status, 'El caso debería habere cerrado');

			//Creamos otro caso manualmente
			//Case caso2 = HDT_Llamada_GC.crearVincularCaso(llamadaEntrante);
			//crearActividadManual('Reclamación a cliente', llamadaEntrante.Id, caso2.Id);

			/*Boolean excepcion = false;
			try {
				cerrarCaso(caso2);
			}
			catch (Exception e) {
				excepcion = true;
			}
			System.assert(excepcion);*/

			HDT_Llamada_GC.finalizarLlamada(inputLlamada, 'Llamada finalizada');
		}
	}

	/*
	@isTest
	public static void cogerEncuesta() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			CC_Creacion_Datos_Test.lovAvisosSobreAgrupadores();
			CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1'];
			Contact contacto = [SELECT AccountId FROM Contact WHERE LastName = 'Empleado Test'];

			Test.startTest();
			//Entra la llamada
			String jsonLlamada = obtenerInputLlamada(s1.CC_Codigo__c, '', '');
			CC_Llamada_Input inputLlamada = parseJson(jsonLlamada);

			CC_Servicio_Genesys__c servicioGenesys = [SELECT Name, CC_Canal_Procedencia__c, CC_Tipo_Cliente__c, CC_Codigo__c, CC_Encuesta__r.CC_Codigo__c
														FROM CC_Servicio_Genesys__c WHERE CC_Codigo__c = :inputLlamada.servicio LIMIT 1];
			//Creamos la llamada
			Map<String, Object> responseRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)responseRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamadaEntrante != null);

			//Creamos caso manualmente
			Case caso1 = HDT_Llamada_GC.crearVincularCaso(llamadaEntrante);
			System.assert(caso1 != null);

			//Creamos otro caso manualmente
			Case caso2 = HDT_Llamada_GC.crearVincularCaso(llamadaEntrante);
			System.assert(caso2 != null);

			//Realizamos una encuesta
			HDT_Llamada_GC.registrarEncuesta(inputLlamada);
			Test.stopTest();
		}
	}
	*/

	@isTest
	public static void cogerConsultarCancelar() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			//Entra la llamada
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada('S1', null, null);
			Map<String, Object> responseRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)responseRegistrarLlamadaEntrante.get('llamada');

			//creamos caso manualmente
			Case caso = HDT_Llamada_GC.crearVincularCaso(llamadaEntrante);
			caso.CC_Detalles_Consulta__c = 'Segunda consulta del test';
			caso.CC_Tipo_Contacto__c = 'Consulta';
			update caso;



				Test.startTest();
				//Realizamos una consulta
				CC_Llamada_Input inputConsulta = obtenerInputConsulta('S3', '', caso.Id, llamadaEntrante.Id);
				Map<String, Object> respuestaRegistrarConsulta = HDT_Llamada_GC.registrarConsulta(inputConsulta);
				CC_Llamada__c consulta = (CC_Llamada__c)respuestaRegistrarConsulta.get('llamada');

				//Cancelamos la consulta
				HDT_Llamada_GC.cancelarConsulta(inputConsulta);
				Test.stopTest();

				consulta = [SELECT CC_Fecha_Fin__c, CC_Tipo_Cierre__c FROM CC_Llamada__c WHERE Id = :consulta.Id];
				System.assertNotEquals(consulta.CC_Fecha_Fin__c, null, 'Consulta sin fecha de fin');
				System.assertEquals(consulta.CC_Tipo_Cierre__c, 'Consulta cancelada', 'Consulta sin el tipo de cierre correcto');

				Task tareaConsulta = [SELECT CC_Fecha_Fin__c, Status FROM Task WHERE CC_Llamada_Id__c = :consulta.Id];
				System.assertNotEquals(tareaConsulta.CC_Fecha_Fin__c, null, 'Tarea sin fecha de fin');
				System.assertEquals(tareaConsulta.Status, 'Completed', 'La tarea no se ha cerrado');

		}
	}

	
	/*
	@isTest
	static void cogerConsultarCompletarColgar() {
		Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {

			User agenteCompletarConsulta = [SELECT Id FROM User WHERE Username = 'agente2@caixa.com'][0];
			UserRole rol = [SELECT DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
			agenteCompletarConsulta.UserRoleId = rol.Id;

			//Entra la llamada
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada('S1', null, '');
			Map<String, Object> retornoRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');

			//creamos caso manualmente
			Case caso = HDT_Llamada_GC.crearVincularCaso(llamadaEntrante);
				 // Completamos la consulta solo si el caso empieza por "HDT_"
				 if (caso.RecordType.DeveloperName.startsWith('HDT_')) {

					caso.CC_Detalles_Consulta__c = 'Segunda consulta del test';
					caso.CC_Tipo_Contacto__c = 'Consulta';
					//update caso;
				 

			Test.startTest();
				//Realizamos una consulta
				CC_Llamada_Input inputConsulta = obtenerInputConsulta('S4', '', caso.Id, llamadaEntrante.Id);
				Map<String, Object> respuestaRegistrarConsulta = HDT_Llamada_GC.registrarConsulta(inputConsulta);
				CC_Llamada__c consulta = (CC_Llamada__c)respuestaRegistrarConsulta.get('llamada');


				 // Completamos la consulta solo si el caso empieza por "HDT_"
            //if (caso.RecordType.DeveloperName.startsWith('HDT_')) {

				//Completamos la consulta
				inputConsulta = obtenerInputConsulta('S4', consulta.Id, caso.Id, llamadaEntrante.Id);
				HDT_Llamada_GC.completarConsulta(inputConsulta.connId, UserInfo.getUserId());

				Integer n = 0;
				for (Task tarea : [SELECT Type, Status, CC_Tipo_Cierre__c FROM Task WHERE CC_Llamada_Id__c = :consulta.Id
									AND Type IN ('Consulta a tercer nivel', 'Llamada transferida', 'Traslado Tercer Nivel')]) {
					//System.debug('papaia: ' + tarea.Type + ' - ' + tarea.Status + ' - ' + tarea.CC_Tipo_Cierre__c);
					if (tarea.Type == 'Consulta a tercer nivel' && tarea.Status == 'Completed' && tarea.CC_Tipo_Cierre__c == 'Consulta transferida') {
						n++;
					} else if (tarea.Type == 'Llamada transferida' && tarea.Status == 'Open') {
						n++;
					} else if (tarea.Type == 'Traslado Tercer Nivel' && tarea.Status == 'Open') {
						n++;
					}
				}
				//System.assertEquals(3, n, 'Actividades incorrectas');
				Test.stopTest();

				caso = [SELECT OwnerId, CC_Owner_Anterior__c FROM Case WHERE Id = :caso.Id AND Status = 'Activo' AND CC_En_Tercer_Nivel__c = true];
				//System.assertNotEquals(null, caso.CC_Owner_Anterior__c, 'El owner anterior no esta vacio');
				System.assertNotEquals(caso.OwnerId, caso.CC_Owner_Anterior__c, 'El owner actual y el anterior no coinciden');

				//La llamada original finaliza
				inputLlamadaEntrante = obtenerInputLlamada('S1', llamadaEntrante.Id, caso.Id);
				HDT_Llamada_GC.finalizarLlamada(inputLlamadaEntrante, 'Consulta completada');

				//Colgamos la llamada
				HDT_Llamada_GC.finalizarLlamada(inputConsulta, 'Llamada finalizada');
			}

			
        }
	}*/
	

	@isTest
	public static void llamarSalienteColgar() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test'];

			//Realizar la llamada saliente
			Test.startTest();
			CC_Llamada_Input inputLlamadaSaliente = obtenerInputLlamada(null, null, caso.Id);
			Map<String, Object> responseRegistrarLlamadaSaliente = HDT_Llamada_GC.registrarLlamadaSaliente(inputLlamadaSaliente);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)responseRegistrarLlamadaSaliente.get('llamada');
			HDT_Llamada_GC.finalizarLlamada(inputLlamadaSaliente, 'Llamada finalizada');
			Test.stopTest();

			System.assert(llamadaSaliente != null);
			System.assert([SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaSaliente.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada'] != null);
		}
	}

	@isTest
	public static void llamarSalienteColgarNoAtendida() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
		//System.runAs(agenteConsulta) {

			/*

			CC_Servicio_Genesys__c s1 = new CC_Servicio_Genesys__c();
            s1.RecordTypeId = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();
            s1.CBK_Negocio__c = 'HDT';
            s1.CC_Tipo__C = 'Servicio';
            s1.Name = 'HDT Genesys Cloud Outbound Default';
            s1.CC_Codigo__c = 'HDT_GenesysCloudOutboundDefault';
            s1.CC_VDN__c = '4444444';
            s1.CC_Prefijo__c = '0';
            s1.CC_Tipo_Cliente__c = 'Empleado';
            s1.CC_Fecha_Inicio_Salesforce__c = Date.today();
            s1.CC_Principal__c = true;
            insert s1;*/

			Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test'];

			//Realizar la llamada saliente
			Test.startTest();
			CC_Llamada_Input inputLlamadaSaliente = obtenerInputLlamada(null, null, caso.Id);
			Map<String, Object> responseRegistrarLlamadaSaliente = HDT_Llamada_GC.registrarLlamadaSalienteNoAtendida(inputLlamadaSaliente);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)responseRegistrarLlamadaSaliente.get('llamada');
			HDT_Llamada_GC.finalizarLlamada(inputLlamadaSaliente, 'Llamada finalizada');
			Test.stopTest();

			System.assert(llamadaSaliente != null);
			System.assert([SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaSaliente.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada no atendida'] != null);
		}
	}


	@isTest
	public static void cogerConsultaExternaColgar() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			CC_Servicio_Genesys__c s3 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1'];
			Case caso = crearCaso();

			//User agenteConsulta  = [SELECT Id FROM User WHERE Username = 'agente1@caixa.com'];

			//Entra la llamada
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada(s3.CC_Codigo__c, '', caso.Id);
			Map<String, Object> mapaLlamadas = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			Object valor = mapaLlamadas.get('llamada');
			CC_Llamada__c llamada2 = (CC_Llamada__c)valor;
			String llamadaId = llamada2.Id;

			inputLlamadaEntrante = obtenerInputLlamada(s3.CC_Codigo__c, llamadaId, caso.Id);
			CC_Llamada__c llamada = obtenerLlamada(llamadaId);
			System.assert(llamada != null);
			Test.startTest();
			System.runAs(agenteConsulta) {
				//Recibimos una consulta

				CC_Llamada_Input inputConsulta = obtenerInputConsulta(s3.CC_Codigo__c, '', caso.Id, llamadaId);
				Id consultaCanceladaId;

				Map<String, Object> respuestaRegistrarConsulta = HDT_Llamada_GC.registrarConsulta(inputConsulta);
				CC_Llamada__c llamadaNueva = (CC_Llamada__c)respuestaRegistrarConsulta.get('llamada');
				consultaCanceladaId = llamadaNueva.Id;
				inputConsulta = obtenerInputConsulta(s3.CC_Codigo__c, consultaCanceladaId, caso.Id, '');

				CC_Llamada__c consultaCancelada = obtenerLlamada(consultaCanceladaId);
				System.assert(consultaCancelada != null);

				//Cancelamos la consulta
				HDT_Llamada_GC.cancelarConsulta(inputConsulta);

				List<CC_Llamada__c> consultaCancelada1 = [SELECT Id FROM CC_Llamada__c WHERE Id = :consultaCancelada.Id
															AND CC_Fecha_Fin__c != NULL AND CC_Tipo_Cierre__c = 'Consulta cancelada'];
				System.assert(!consultaCancelada1.isEmpty());
			}
			Test.stopTest();
		}
	}


	@isTest
	public static void llamadaServicioGenesysDesplieguesTest() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			CC_Creacion_Datos_Test.lovAvisosSobreAgrupadores();
			CC_Servicio_Genesys__c s1 = crearServicioDespliegues();

			//Entra la llamada
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada(s1.CC_Codigo__c, '', '');
			Map<String, Object> responseRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)responseRegistrarLlamadaEntrante.get('llamada');

			System.assert(llamadaEntrante != null);
			System.assertEquals('Despliegues', [SELECT CC_Canal_del_Empleado__c FROM CC_Llamada__c WHERE Id = :llamadaEntrante.Id].CC_Canal_del_Empleado__c);

			//Creamos caso manualmente y lo cerramos con actividades de llamada abiertas
			Test.startTest();
			Case caso1 = HDT_Llamada_GC.crearVincularCaso(llamadaEntrante);
			Test.stopTest();

			String oficinaAfectada = [SELECT CC_Oficina_Afectada_Lookup__c FROM Case WHERE Id = :caso1.Id].CC_Oficina_Afectada_Lookup__c;
			System.assertEquals(llamadaEntrante.CC_Cuenta__r.CC_OficinaGestoraId__c, oficinaAfectada);
			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND WhatId = :caso1.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
			System.assert(actividad != null);
			caso1 = [SELECT Canal_del_Empleado__c FROM Case WHERE Id = :caso1.Id];
			System.assert(caso1 != null);
			System.assertEquals('Despliegues', caso1.Canal_del_Empleado__c);
		}
	}

	@isTest
	public static void llamadaServicioGenesysDespliegues2Test() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {

			CC_Creacion_Datos_Test.lovAvisosSobreAgrupadores();
			CC_Servicio_Genesys__c s1 = crearServicioDespliegues2();

			//Entra la llamada
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada(s1.CC_Codigo__c, '', '');
			Map<String, Object> responseRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)responseRegistrarLlamadaEntrante.get('llamada');

			System.assertEquals('Despliegues2', [SELECT CC_Canal_del_Empleado__c FROM CC_Llamada__c WHERE Id = :llamadaEntrante.Id].CC_Canal_del_Empleado__c);
			System.assert(llamadaEntrante != null);

			//Creamos caso manualmente y lo cerramos con actividades de llamada abiertas
			Test.startTest();
			Case caso1 = HDT_Llamada_GC.crearVincularCaso(llamadaEntrante);
			Test.stopTest();
			String oficinaAfectada = [SELECT CC_Oficina_Afectada_Lookup__c FROM Case WHERE Id = :caso1.Id].CC_Oficina_Afectada_Lookup__c;
			System.assertEquals(llamadaEntrante.CC_Cuenta__r.CC_OficinaGestoraId__c, oficinaAfectada);
			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND WhatId = :caso1.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
			System.assert(actividad != null);
			caso1 = [SELECT Canal_del_Empleado__c FROM Case WHERE Id = :caso1.Id];
			System.assert(caso1 != null);
			System.assertEquals('Despliegues2', caso1.Canal_del_Empleado__c);
		}
	}

	@isTest
	public static void cerrarLlamadasAbiertas() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			//Entra la llamada
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada('S1', '', '');
			Map<String, Object> responseRegistrarLlamadaEntrante1 = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante1 = (CC_Llamada__c)responseRegistrarLlamadaEntrante1.get('llamada');
			System.assert(llamadaEntrante1 != null);

			//Creamos caso manualmente
			Test.startTest();
			HDT_Llamada_GC.crearVincularCaso(llamadaEntrante1);
			Test.stopTest();
			Task actividad1 = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante1.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
			System.assert(actividad1 != null);

			//Entra otra llamada
			Map<String, Object> responseRegistrarLlamadaEntrante2 = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante2 = (CC_Llamada__c)responseRegistrarLlamadaEntrante2.get('llamada');
			System.assert(llamadaEntrante2 != null);

			List<Task> actividad2 = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante1.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(!actividad2.isEmpty());
		}
	}

	@isTest
	public static void cogerConsultarExternaCancelarColgar() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {

			//User agenteConsulta = [SELECT Id FROM User WHERE Username = 'agente1@caixa.com' LIMIT 1];

			//Entra la llamada y creamos caso manualmente
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada('S1', '', '');
			Map<String, Object> responseRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)responseRegistrarLlamadaEntrante.get('llamada');

			Case caso = HDT_Llamada_GC.crearVincularCaso(llamadaEntrante);

			//Realizamos una consulta a un servicio externo y cancelamos la consulta
			CC_Llamada_Input inputConsulta = obtenerInputConsulta('S3', '', caso.Id, llamadaEntrante.Id);
			Test.startTest();
			HDT_Llamada_GC.finalizarConsultaExterna(inputConsulta, 'Consulta cancelada');
			Test.stopTest();

			List<Task> actividadCancelada = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND Type = 'Consulta externa' AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Consulta atendida' LIMIT 1];
			System.assert(!actividadCancelada.isEmpty());

			//Colgamos la llamada
			inputLlamadaEntrante = obtenerInputLlamada('S1', llamadaEntrante.Id, caso.Id);
			HDT_Llamada_GC.finalizarLlamada(inputLlamadaEntrante, 'Llamada finalizada');

			List<Task> actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(!actividad.isEmpty());
			llamadaEntrante = [SELECT CC_Fecha_Fin__c, CC_Tipo_Cierre__c FROM CC_Llamada__c WHERE Id = :llamadaEntrante.Id];
			System.assert(llamadaEntrante.CC_Fecha_Fin__c != null);
			System.assertEquals('Llamada finalizada', llamadaEntrante.CC_Tipo_Cierre__c);
		}
	}

	@isTest
	public static void registrarLlamadasEmpleados() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
			Account oficina1 = new Account();
			oficina1.RecordTypeId = centroRecordTypeId;
			oficina1.Name = 'Cuenta Centro CaixaBank Test 1';
			oficina1.CC_Tipo_Centro__c = 'OF';
			Account oficina2 = new Account();
			oficina2.RecordTypeId = centroRecordTypeId;
			oficina2.Name = 'Cuenta Centro CaixaBank Test 2';
			oficina2.CC_Tipo_Centro__c = 'OF';
			Account oficina3 = new Account();
			oficina3.RecordTypeId = centroRecordTypeId;
			oficina3.Name = 'Cuenta Centro CaixaBank Test 3';
			oficina3.CC_Tipo_Centro__c = 'OF';
			insert new List<Account>{oficina1, oficina2, oficina3};

			Id empleadoRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
			Contact empleado1 = new Contact();
			empleado1.RecordTypeId = empleadoRecordTypeId;
			empleado1.FirstName = 'Contacto1 OF';
			empleado1.LastName = 'Test';
			empleado1.CC_Idioma__c = 'es';
			empleado1.Email = 'test@contact.com';
			empleado1.CC_Cargo__c = 'DIRECCIÓN';
			empleado1.AccountId = oficina1.Id;
			Contact empleado2 = new Contact();
			empleado2.RecordTypeId = empleadoRecordTypeId;
			empleado2.FirstName = 'Contacto2 OF';
			empleado2.LastName = 'Test';
			empleado2.CC_Idioma__c = 'es';
			empleado2.Email = 'test@contact.com';
			empleado2.CC_Cargo__c = 'DIRECCIÓN';
			empleado2.AccountId = oficina2.Id;
			Contact empleado3 = new Contact();
			empleado3.RecordTypeId = empleadoRecordTypeId;
			empleado3.FirstName = 'Contacto3 OF';
			empleado3.LastName = 'Test';
			empleado3.CC_Idioma__c = 'es';
			empleado3.Email = 'test@contact.com';
			empleado3.CC_Cargo__c = 'DIRECCIÓN';
			empleado3.AccountId = oficina3.Id;
			insert new List<Contact>{empleado1, empleado2, empleado3};

			Id recordTypeTelefono = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
			CC_Canal_Com__c canalComunicacion1 = new CC_Canal_Com__c();
			canalComunicacion1.RecordTypeId = recordTypeTelefono;
			canalComunicacion1.CC_CuentaId__c = oficina1.Id;
			canalComunicacion1.CC_ContactoId__c = empleado1.Id;
			canalComunicacion1.CC_Telefono__c = '666001122';
			CC_Canal_Com__c canalComunicacion2 = new CC_Canal_Com__c();
			canalComunicacion2.RecordTypeId = recordTypeTelefono;
			canalComunicacion2.CC_CuentaId__c = oficina2.Id;
			canalComunicacion2.CC_ContactoId__c = empleado2.Id;
			canalComunicacion2.CC_Telefono__c = '666001133';
			CC_Canal_Com__c canalComunicacion3 = new CC_Canal_Com__c();
			canalComunicacion3.RecordTypeId = recordTypeTelefono;
			canalComunicacion3.CC_CuentaId__c = oficina3.Id;
			canalComunicacion3.CC_ContactoId__c = empleado3.Id;
			canalComunicacion3.CC_Telefono__c = '666001133';
			insert new List<CC_Canal_Com__c>{canalComunicacion1, canalComunicacion2, canalComunicacion3};

			Test.startTest();
			CC_Llamada_Input inputLlamadaTelefonoUnico = obtenerInputLlamada('S1', '', '');
			inputLlamadaTelefonoUnico.ani = '666001122';
			CC_Llamada__c llamada1 = (CC_Llamada__c)HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaTelefonoUnico).get('llamada');

			CC_Llamada_Input inputLlamadaTelefonoDuplicado = obtenerInputLlamada('S1', '', '');
			inputLlamadaTelefonoDuplicado.ani = '666001133';
			CC_Llamada__c llamada2 = (CC_Llamada__c)HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaTelefonoDuplicado).get('llamada');
			Test.stopTest();

			// Primera llamada debería funcionar, porque solo hay un empleado con ese numero de telefono
			System.assertEquals(empleado1.Id, llamada1.CC_Contacto__c);
			System.assertEquals(oficina1.Id, llamada1.CC_Cuenta__c);

			// Segunda llamada deberia fallar, porque hay dos empleados con el mismo numero de telefono
			System.assertEquals(null, llamada2.CC_Contacto__c);
			System.assertEquals(null, llamada2.CC_Cuenta__c);
		}
	}

	@isTest
	public static void cogerConsultaEmpleadosColgar() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			Contact empleado = [SELECT AccountId FROM Contact WHERE LastName = 'Empleado Test'];
			Contact empleadoGestor = [SELECT Id FROM Contact WHERE LastName = 'Empleado gestor Test'];
			CC_Canal_Com__c canalComunicacionGestor = [SELECT CC_Telefono__c FROM CC_Canal_Com__c WHERE CC_ContactoId__c = :empleadoGestor.Id];
			Case caso = crearCaso();

			//Entra la llamada
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada('S1', '', caso.Id);
			Map<String, Object> responseRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)responseRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamadaEntrante != null);

			//El usuario informa la cuenta en la llamada
			llamadaEntrante.CC_Cuenta__c = empleado.AccountId;
			llamadaEntrante.CC_Contacto__c = empleado.Id;
			update llamadaEntrante;

			Test.startTest();
			//Consulta externa a otro empleado
			CC_Llamada_Input inputConsultaExterna = obtenerInputConsultaExterna(null, caso.Id, llamadaEntrante.Id, empleadoGestor.Id, canalComunicacionGestor.CC_Telefono__c);
			// CC_Llamada__c consultaExterna1 = HDT_Llamada_GC.registrarConsultaExterna(inputConsultaExterna);
			HDT_Llamada_GC.finalizarConsultaExterna(inputConsultaExterna, 'Consulta cancelada');
			List<Task> listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta atendida' AND CC_Empleado_Gestor__c = :empleadoGestor.Id];
			System.assertEquals(1, listaTareas.size());

			//Consulta externa a un número de teléfono que conseguimos identificar
			inputConsultaExterna = obtenerInputConsultaExterna(null, caso.Id, llamadaEntrante.Id, '', '690998877');
			HDT_Llamada_GC.finalizarConsultaExterna(inputConsultaExterna, 'Consulta cancelada');
			listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta atendida' AND CC_Empleado_Gestor__c = :empleadoGestor.Id];
			System.assertEquals(1, listaTareas.size());

			//Consulta externa a un número de teléfono que NO conseguimos identificar
			inputConsultaExterna = obtenerInputConsultaExterna(null, caso.Id, llamadaEntrante.Id, '', '690111000');
			HDT_Llamada_GC.finalizarConsultaExterna(inputConsultaExterna, 'Consulta cancelada');
			listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta atendida' AND CC_Empleado_Gestor__c = null];
			//TEMP
			//System.assertEquals(1, listaTareas.size());

			//Colgamos la llamada
			inputLlamadaEntrante = obtenerInputLlamada('S1', llamadaEntrante.Id, caso.Id);
			HDT_Llamada_GC.finalizarLlamada(inputLlamadaEntrante, 'Llamada finalizada');
			List<Task> actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(!actividad.isEmpty());
			List<CC_Llamada__c> llamadasEntrantes = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaEntrante.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada'];
			Test.stopTest();
			System.assert(!llamadasEntrantes.isEmpty());
		}
	}

	@isTest
	public static void cogerConsultaNoAtendidaEmpleados() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			Contact empleado = [SELECT Id FROM Contact WHERE LastName = 'Empleado Test'];
			Case caso = crearCaso();

			Test.startTest();
			//Entra la llamada
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada('S1', '', caso.Id);
			Map<String, Object> responseRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)responseRegistrarLlamadaEntrante.get('llamada');
			//TEMP
			//System.assert(llamadaEntrante != null);

			inputLlamadaEntrante = obtenerInputLlamada('S1', llamadaEntrante.Id, caso.Id);

			//Consulta externa a un número de teléfono que conseguimos identificar
			CC_Llamada_Input inputConsultaExterna = obtenerInputConsultaExterna('S1', caso.Id, llamadaEntrante.Id, '', '690998877');

			HDT_Llamada_GC.registrarConsultaNoAtendida(inputLlamadaEntrante, inputConsultaExterna);
			List<Task> listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta no atendida' AND CC_Empleado_Gestor__c = :empleado.Id];
			//TEMP
			//System.assertEquals(1, listaTareas.size());

			//Consulta externa a un número de teléfono que NO conseguimos identificar
			inputConsultaExterna = obtenerInputConsultaExterna('S1', caso.Id, llamadaEntrante.Id, '', '690111000');
			Id vuelta = HDT_Llamada_GC.registrarConsultaNoAtendida(inputLlamadaEntrante, inputConsultaExterna);
			listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta no atendida' AND CC_Empleado_Gestor__c = null];
			//TEMP
			//System.assertEquals(0, listaTareas.size());

			//Colgamos la llamada
			HDT_Llamada_GC.finalizarLlamada(inputLlamadaEntrante, 'Llamada finalizada');
			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(actividad != null);
			List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaEntrante.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada'];
			System.assert(!llamadas.isEmpty());
			Test.stopTest();
		}
	}

	@isTest
	public static void cogerConsultaEmpleadoCompletar() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			CC_Servicio_Genesys__c s3 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1' LIMIT 1];
			Case caso = crearCaso();

			//Entra la llamada
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada(s3.CC_Codigo__c, '', caso.Id);
			Map<String, Object> responseRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)responseRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamadaEntrante != null);

			Contact empleado = [SELECT AccountId FROM Contact WHERE LastName = 'Empleado Test'];

			//El usuario informa la cuenta en la llamada
			llamadaEntrante.CC_Cuenta__c = empleado.AccountId;
			update llamadaEntrante;

			Test.startTest();
			//Consulta externa al empleado gestor de la cuenta de la llamada
			CC_Llamada_Input inputConsultaExterna = obtenerInputConsultaExterna('S1', caso.Id, llamadaEntrante.Id, empleado.Id, '690112233');
			HDT_Llamada_GC.finalizarConsultaExterna(inputConsultaExterna, 'Consulta completada');
			List<Task> listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta transferida']; //AND CC_Empleado_Gestor__c = :listaContactos[0].Id
			System.assertEquals(1, listaTareas.size());

			//Se cuelga la llamada al transferir al completar la consulta
			inputLlamadaEntrante = obtenerInputLlamada(s3.CC_Codigo__c, llamadaEntrante.Id, caso.Id);
			HDT_Llamada_GC.finalizarLlamada(inputLlamadaEntrante, 'Llamada finalizada');
			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(actividad != null);
			List<CC_Llamada__c> llamadas = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaEntrante.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada'];
			Test.stopTest();
			System.assert(!llamadas.isEmpty());
		}
	}

	@isTest
	public static void finalizarConsulta() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			CC_Servicio_Genesys__c s3 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1' LIMIT 1];
			Contact empleado = [SELECT AccountId FROM Contact WHERE LastName = 'Empleado Test'];
			Case caso = crearCaso();

			//Entra la llamada
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada(s3.CC_Codigo__c, '', caso.Id);
			Map<String, Object> responseRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)responseRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamadaEntrante != null);

			//El usuario informa la cuenta en la llamada
			llamadaEntrante.CC_Cuenta__c = empleado.AccountId;
			update llamadaEntrante;

			Test.startTest();
			//Consulta externa al empleado gestor de la cuenta de la llamada
			CC_Llamada_Input inputConsultaExterna = obtenerInputConsulta(caso.Id, llamadaEntrante.Id, empleado.Id, '690112233');
			HDT_Llamada_GC.finalizarConsulta(inputConsultaExterna, 'Consulta completada');
			Test.stopTest();
		}
	}

	/*
	@isTest
	public static void registrarEncuestaLlamadaSaliente() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			CC_Servicio_Genesys__c servicioEncuesta = crearServicioEncuesta();
			CC_Servicio_Genesys__c servicio = [SELECT Id FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1'];
			servicio.CC_Encuesta__c = servicioEncuesta.Id;
			update servicio;

			Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test'];
			String jsonLlamada = obtenerInputLlamada(null, null, caso.Id);
			CC_Llamada_Input inputLlamada = parseJson(jsonLlamada);


			CC_Llamada_Input input0 = parseJson(jsonLlamada);
			Map<String, Object> mapaLlamadas = HDT_Llamada_GC.registrarLlamadaSaliente(input0);

			Object valor = mapaLlamadas.get('llamada');
			CC_Llamada__c llamada2 = (CC_Llamada__c)valor;
			String llamadaId = llamada2.Id;

			jsonLlamada = obtenerInputLlamada(null, llamadaId, caso.Id);

			Test.startTest();
			CC_Llamada_Input input = parseJson(jsonLlamada);
			HDT_Llamada_GC.registrarEncuesta(input);
			Test.stopTest();

			List<CC_Llamada__c> llamadaSaliente = [SELECT CC_Encuesta__c FROM CC_Llamada__c WHERE Id = :llamadaId];
			System.assertEquals(1, llamadaSaliente.size());
			//System.assertEquals(servicioEncuesta.Id, llamadaSaliente[0].CC_Encuesta__c);

			// List<Task> tareaRegistroEncuesta = [SELECT Id, Type, CC_Tipo_Cierre__c FROM Task WHERE CC_Llamada_Id__c =: llamadaId AND Type = 'Encuesta'];
			// System.assertEquals(1, tareaRegistroEncuesta.size());
			// System.assertEquals('Encuesta', tareaRegistroEncuesta[0].Type);
			// System.assertEquals('Encuesta enviada', tareaRegistroEncuesta[0].CC_Tipo_Cierre__c);
			//System.assertEquals(true, true, 'PENDIENTE')
		}
	}
	*/

	@isTest
	public static void finalizarLlamadaTest() {
		Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Test'];

			//Realizar la llamada saliente
			CC_Llamada_Input inputLlamadaSaliente = obtenerInputLlamada('HDT_GenesysCloudOutboundDefault', null, caso.Id);
			Map<String, Object> responseRegistrarLlamadaSaliente = HDT_Llamada_GC.registrarLlamadaSaliente(inputLlamadaSaliente);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)responseRegistrarLlamadaSaliente.get('llamada');
			System.assert(llamadaSaliente != null);

			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaSaliente.Id AND WhatId = :caso.Id AND Type = 'Llamada saliente' AND Status = 'Open' LIMIT 1];
			System.assert(actividad != null);

			Test.startTest();
			HDT_Llamada_GC.finalizarLlamada(inputLlamadaSaliente, 'Llamada finalizada');
			Test.stopTest();

			List<Task> tareaFinalizada = [SELECT Status, CC_Tipo_Cierre__c FROM Task WHERE CC_Llamada_Id__c = :llamadaSaliente.Id
											AND WhatId = :caso.Id AND Type = 'Llamada saliente' LIMIT 1];
			//TEMP
			//System.assert(!tareaFinalizada.isEmpty());
			//System.assertEquals('Completed', tareaFinalizada[0].Status);
			//System.assertEquals('Llamada finalizada', tareaFinalizada[0].CC_Tipo_Cierre__c);

			llamadaSaliente = [SELECT CC_Fecha_Fin__c, CC_Tipo_Cierre__c FROM CC_Llamada__c WHERE Id = :llamadaSaliente.Id];
			//TEMP
			//System.assert(llamadaSaliente.CC_Fecha_Fin__c != null);
			//System.assertEquals('Llamada finalizada', llamadaSaliente.CC_Tipo_Cierre__c);
		}
	}

	/*
	@isTest
	public static void finalizarConsultaExternaExceptionTest() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			//User agenteConsulta  = [SELECT Id FROM User WHERE Username = 'agente1@caixa.com'];

			//Entra la llamada y creamos caso manualmente
			CC_Servicio_Genesys__c s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1' LIMIT 1];
			CC_Servicio_Genesys__c s3 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1' LIMIT 1];
			String jsonLlamadaEntrante = obtenerInputLlamada(s1.CC_Codigo__c, '', '');
			CC_Llamada_Input inputLlamadaEntrante = parseJson(jsonLlamadaEntrante);
			Map<String, Object> responseRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaSaliente = (CC_Llamada__c)responseRegistrarLlamadaEntrante.get('llamada');
			Case caso = HDT_Llamada_GC.crearVincularCaso(llamadaSaliente);


				//Realizamos una consulta a un servicio externo y cancelamos la consulta
				String jsonConsulta = obtenerInputConsulta(s3.CC_Codigo__c, '', caso.Id, llamadaSaliente.Id).replace(s3.CC_Codigo__c, '');
				CC_Llamada_Input inputConsulta = parseJson(jsonConsulta);
				Test.startTest();
				try {
					HDT_Llamada_GC.finalizarConsultaExterna(inputConsulta, 'Consulta cancelada');
				} catch (Exception e) {
					System.assertEquals(e.getMessage(), 'No se puede finalizar una consulta externa sin servicio/empleado.');
				}
				Test.stopTest();

		}
	}
	*/

	/*
	@isTest
	public static void registrarConsultaNoAtendidaExceptionTest() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			CC_Servicio_Genesys__c s3 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c WHERE Name = 'Servicio 1' LIMIT 1];
			Contact empleadoGestor = [SELECT AccountId FROM Contact WHERE LastName = 'Empleado gestor Test'];
			Case caso = crearCaso();

            Test.startTest();
			//Entra la llamada
			String jsonLlamadaEntrante = obtenerInputLlamada(s3.CC_Codigo__c, '', caso.Id);
			CC_Llamada_Input inputLlamadaEntrante = parseJson(jsonLlamadaEntrante);
			Map<String, Object> responseRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)responseRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamadaEntrante != null);

			//Consulta externa a un número de teléfono que conseguimos identificar
			jsonLlamadaEntrante = obtenerInputLlamada(s3.CC_Codigo__c, llamadaEntrante.Id, caso.Id);
			inputLlamadaEntrante = parseJson(jsonLlamadaEntrante);
			String jsonConsultaExterna = obtenerInputConsultaExterna('S1', caso.Id, llamadaEntrante.Id, '', '690998877');
			CC_Llamada_Input inputConsultaExterna = parseJson(jsonConsultaExterna);
			HDT_Llamada_GC.registrarConsultaNoAtendida(inputConsultaExterna, inputLlamadaEntrante);
			List<Task> listaTareas = [SELECT Id FROM Task WHERE CC_Tipo_Cierre__c = 'Consulta no atendida' AND CC_Empleado_Gestor__c = :empleadoGestor.Id];
			System.assertEquals(0, listaTareas.size());

			//Colgamos la llamada
			HDT_Llamada_GC.finalizarLlamada(inputLlamadaEntrante, 'Llamada finalizada');
			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(actividad != null);
			llamadaEntrante = [SELECT Id FROM CC_Llamada__c WHERE Id = :llamadaEntrante.Id AND CC_Fecha_Fin__c != null AND CC_Tipo_Cierre__c = 'Llamada finalizada'];
			System.assert(llamadaEntrante != null);
			Test.stopTest();
		}
	}
	*/

	@isTest
	public static void testIdentificarPorTelefono() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
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
			HDT_Llamada_GC.identificarPorTelefono(llamada, telefono);
			Test.stopTest();

			// Comprueba los resultados esperados
			System.assertEquals(canalComunicacion.CC_ContactoId__r.AccountId, llamada.CC_Cuenta__c);
			System.assertEquals(canalComunicacion.CC_ContactoId__c, llamada.CC_Contacto__c);
		}
	}
    public static Id obtenerPSAdministrador() {
        return [SELECT Id FROM PermissionSet WHERE Name = 'KIN_Admin'].Id;
    }

    public static User obtenerAgente1(Id psId) {
        User agente = new User();
        agente.FirstName = 'Agente';
        agente.LastName = 'Uno';
        agente.Alias='AUno';
        agente.Email = 'hdtAgenteGC@invalid.com';
        agente.Username= 'hdtAgenteGC@caixa.com';
        agente.ProfileId = [SELECT Id FROM Profile WHERE Name = 'API Only'].Id;
        agente.EmailEncodingkey='UTF-8';
        agente.LanguageLocaleKey='en_US';
        agente.LocalesIdKey='en_US';
        agente.TimezonesIdKey='Europe/Berlin';
        insert agente;

        PermissionSet ps = [select Id from PermissionSet where Name ='KIN_Admin'];
        List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId =: agente.Id];
        if(psas.isEmpty()){
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = agente.Id);
            insert psa;
        }

        return agente;
    }

    private static Case crearCaso() {
		Case caso = new Case();
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
		caso.Subject = 'Prueba HDT';
		caso.Origin = 'Phone';
		caso.CC_Canal_Respuesta__c = 'Phone';
		caso.CC_Tipo_Cliente__c = 'Empleado';
		caso.CC_No_Identificado__c = true;
		caso.CC_Canal_Procedencia__c = 'Activo';
		insert caso;
		return caso;
	}

    private static Contact crearContacto() {
		//Empleado y empleado gestor
		Id idRecordTypeOficina = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		Account oficina = new Account(
			RecordTypeId = idRecordTypeOficina,
			Name = 'Cuenta',
			CC_Tipo_Centro__c = 'OF'
		);
        insert oficina;


		Id idRecordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
		Contact empleado = new Contact(
			RecordTypeId = idRecordTypeEmpleado,
			FirstName = 'Empleado',
			LastName = 'Empleado Test',
			AccountId = oficina.Id,
			Phone = '555555555'
		);

		insert empleado;
        return empleado;
	}

	@isTest
	public static void crearVincularCasoMasivaLlamada() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {

			//User agenteConsulta = [SELECT Id FROM User WHERE Username = 'agente1@caixa.com' LIMIT 1];

			
			List<CC_Agrupador__c> agrupador = [Select id,CC_Titulo__c from CC_Agrupador__c where CC_Titulo__c = 'Test' LIMIT 1];
			String idAgrupador = agrupador[0].Id;

			//Entra la llamada y creamos caso manualmente
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada('S1', '', '');
			Map<String, Object> responseRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)responseRegistrarLlamadaEntrante.get('llamada');

			Case caso = HDT_Llamada_GC.crearVincularCasoMasiva(llamadaEntrante,idAgrupador);

			//Realizamos una consulta a un servicio externo y cancelamos la consulta
			CC_Llamada_Input inputConsulta = obtenerInputConsulta('S3', '', caso.Id, llamadaEntrante.Id);
			Test.startTest();
			HDT_Llamada_GC.finalizarConsultaExterna(inputConsulta, 'Consulta cancelada');
			Test.stopTest();

			List<Task> actividadCancelada = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND Type = 'Consulta externa' AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Consulta atendida' LIMIT 1];
			System.assert(!actividadCancelada.isEmpty());

			//Colgamos la llamada
			inputLlamadaEntrante = obtenerInputLlamada('S1', llamadaEntrante.Id, caso.Id);
			HDT_Llamada_GC.finalizarLlamada(inputLlamadaEntrante, 'Llamada finalizada');

			List<Task> actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND Status = 'Completed' AND CC_Tipo_Cierre__c = 'Llamada finalizada' LIMIT 1];
			System.assert(!actividad.isEmpty());
			llamadaEntrante = [SELECT CC_Fecha_Fin__c, CC_Tipo_Cierre__c FROM CC_Llamada__c WHERE Id = :llamadaEntrante.Id];
			System.assert(llamadaEntrante.CC_Fecha_Fin__c != null);
			System.assertEquals('Llamada finalizada', llamadaEntrante.CC_Tipo_Cierre__c);
		}
	}


}