@isTest
public with sharing class HDT_Llamada_BU_TRHan_Test {
    @TestSetup
	private static void testSetup() {

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

    public static Id obtenerPSAdministrador() {
        return [SELECT Id FROM PermissionSet WHERE Name = 'KIN_Admin'].Id;
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

    @isTest
	public static void cogerConsultarCancelar() {
		 Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {
			Contact empleado = [SELECT AccountId FROM Contact WHERE LastName = 'Empleado Test'];
			Contact empleado2 = [SELECT AccountId FROM Contact WHERE LastName = 'Empleado gestor Test'];

			
			//Entra la llamada
			CC_Llamada_Input inputLlamadaEntrante = obtenerInputLlamada('S1', null, null);
			Map<String, Object> responseRegistrarLlamadaEntrante = HDT_Llamada_GC.registrarLlamadaEntrante(inputLlamadaEntrante);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)responseRegistrarLlamadaEntrante.get('llamada');

			//creamos caso manualmente
			Case caso = HDT_Llamada_GC.crearVincularCaso(llamadaEntrante);
			caso.CC_Detalles_Consulta__c = 'Segunda consulta del test';
			caso.CC_Tipo_Contacto__c = 'Consulta';
			update caso;

				//Realizamos una consulta
				CC_Llamada_Input inputConsulta = obtenerInputConsulta('S3', '', caso.Id, llamadaEntrante.Id);
				Map<String, Object> respuestaRegistrarConsulta = HDT_Llamada_GC.registrarConsulta(inputConsulta);
				CC_Llamada__c consulta = (CC_Llamada__c)respuestaRegistrarConsulta.get('llamada');
				//El usuario informa la cuenta en la llamada
				llamadaEntrante.CC_Cuenta__c = empleado.AccountId;
				llamadaEntrante.CC_Contacto__c = empleado.Id;
				update llamadaEntrante;
				
				 // Crea un mapa de objetos CC_Llamada__c antiguos
				 Map<Id, CC_Llamada__c> mapOldObj = new Map<Id, CC_Llamada__c>();
				 mapOldObj.put(llamadaEntrante.Id, llamadaEntrante);

				 Test.startTest();

				 llamadaEntrante.CC_Contacto__c = empleado2.Id;
				 update llamadaEntrante;

				//Comprobamos
				HDT_Llamada_BU_TRHan.personAccountBU(new List<CC_Llamada__c>{llamadaEntrante}, mapOldObj);

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
   

}