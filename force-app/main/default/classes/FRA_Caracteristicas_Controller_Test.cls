@isTest
public with sharing class FRA_Caracteristicas_Controller_Test {
    
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
		s1.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Banca Internacional';
		s1.CC_Prefijo__c = '0';
		s1.CC_Tipo_Cliente__c = 'Empleado';

        insert new List<CC_Servicio_Genesys__c>{s1};
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

        insert new List<User>{agenteCancelarConsulta};
                            
        Id recordTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
		CC_MCC__c tematica = new CC_MCC__c();
		tematica.RecordTypeId = recordTypeTematica;
		tematica.CC_Tipo_Cliente__c = 'Cliente (FRA)';
		tematica.Name = 'Temática';
		tematica.CC_Codigo_Externo__c = 'T1';
		tematica.CC_Canal_Operativo__c = 'Oficina';
		insert tematica;

		Id recordTypeProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		CC_MCC__c producto = new CC_MCC__c();
		producto.RecordTypeId = recordTypeProducto;
		producto.CC_Tipo_Cliente__c = 'Cliente (FRA)';
		producto.Name = 'Producto';
		producto.CC_Tematica__c = tematica.Id;
		producto.CC_Codigo_Externo__c = 'P1';
		insert producto;

		Id recordTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		CC_MCC__c motivo = new CC_MCC__c();
		motivo.RecordTypeId = recordTypeMotivo;
		motivo.CC_Tipo_Cliente__c = 'Cliente (FRA)';
		motivo.Name = 'Motivo';
		motivo.CC_Producto_Servicio__c = producto.Id;
		motivo.CC_Codigo_Externo__c = 'M1';
		insert motivo;

		Id recordTypeCausa = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
		CC_MCC__c causa = new CC_MCC__c();
		causa.RecordTypeId = recordTypeCausa;
		causa.CC_Tipo_Cliente__c = 'Cliente (FRA)';
		causa.Name = 'Causa';
		causa.CC_Motivo__c = motivo.Id;
		causa.CC_Codigo_Externo__c = 'C1';
		insert causa;

		Id recordTypeSolucion = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
		CC_MCC__c solucion = new CC_MCC__c();
		solucion.RecordTypeId = recordTypeSolucion;
		solucion.CC_Tipo_Cliente__c = 'Cliente (FRA)';
		solucion.Name = 'Solucion';
		solucion.CC_Causa__c = causa.Id;
		solucion.CC_Codigo_Externo__c = 'S1';
		insert solucion;

        //Empleado y empleado gestor
		Id idRecordTypeOficina = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        //Empleado y empleado gestor
		Id idRecordTypeContactoEmpleado = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
       
		Id idRecordTypeClientePersonal = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();

		
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

        // Crear cuenta con otro RecordType
        Account cuentaOtra = new Account(
            Name = 'Cuenta Otra',
            RecordTypeId = idRecordTypeContactoEmpleado
        );

        // Crear cuenta con otro RecordType
        Account cuentaPersonal = new Account(
			LastName = 'asd',
			RecordTypeId = idRecordTypeClientePersonal
		);

       
		insert new List<Account>{oficina, oficinaEmpleadoGestor,cuentaOtra,cuentaPersonal};

		Id idRecordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id idRecordTypeClienteCaso = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Contact clientec = new Contact(
			RecordTypeId = idRecordTypeClienteCaso,
			FirstName = 'Cliente',
			LastName = 'Cliente Test',
			AccountId = oficina.Id,
			Phone = '555555555'
		);

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
		insert new List<Contact>{clientec,empleado, empleadoGestor};

		//Caso
		Case caso = new Case();
		caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FRA_Cliente').getRecordTypeId();
		caso.Subject = 'Caso Test';
		caso.Origin = 'Phone';
		caso.CC_Canal_Respuesta__c = 'Phone';
		caso.CC_Tipo_Cliente__c = 'Empleado';
		caso.CC_No_Identificado__c = true;
		caso.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Banca Internacional';
		insert caso;

        //Caso
		Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FRA_Cliente').getRecordTypeId();
		caso1.Subject = 'Caso Test';
        caso1.AccountId = oficina.Id;
		caso1.Origin = 'Phone';
		caso1.CC_Canal_Respuesta__c = 'Phone';
		caso1.CC_Tipo_Cliente__c = 'Empleado';
		caso1.CC_No_Identificado__c = true;
		caso1.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Banca Internacional';
		insert caso1;

        //Caso
		Case caso2 = new Case();
		caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FRA_Cliente').getRecordTypeId();
		caso2.Subject = 'Caso Test';
        caso2.AccountId = cuentaOtra.Id;
		caso2.Origin = 'Phone';
		caso2.CC_Canal_Respuesta__c = 'Phone';
		caso2.CC_Tipo_Cliente__c = 'Empleado';
		caso2.CC_No_Identificado__c = true;
		caso2.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Banca Internacional';
		insert caso2;

        //Caso
		Case caso3 = new Case();
		caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FRA_Cliente').getRecordTypeId();
		caso3.Subject = 'Caso Test';
        caso3.ContactId = empleado.Id;
		caso3.Origin = 'Phone';
		caso3.CC_Canal_Respuesta__c = 'Phone';
		caso3.CC_Tipo_Cliente__c = 'Empleado';
		caso3.CC_No_Identificado__c = true;
		caso3.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Banca Internacional';
		insert caso3;

        //Caso
		Case caso4 = new Case();
		caso4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FRA_Cliente').getRecordTypeId();
		caso4.Subject = 'Caso Test cliente';
        caso4.ContactId = clientec.Id;
		caso4.Origin = 'Phone';
		caso4.CC_Canal_Respuesta__c = 'Phone';
		caso4.CC_Tipo_Cliente__c = 'Empleado';
		caso4.CC_No_Identificado__c = true;
		caso4.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Banca Internacional';
		insert caso4;

        //Caso
		 Case caso5 = new Case();
		 caso5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FRA_Cliente').getRecordTypeId();
		 caso5.Subject = 'Caso Test';
		 caso5.AccountId = cuentaPersonal.Id;
		 caso5.Origin = 'Phone';
		 caso5.CC_Canal_Respuesta__c = 'Phone';
		 caso5.CC_Tipo_Cliente__c = 'Empleado';
		 caso5.CC_No_Identificado__c = true;
		 caso5.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Banca Internacional';
		 insert caso5;
        
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

		HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = 'pruebas.empleados.hdt.devser@gmail.com';
        insert params;

        CC_Caracteristica__c caracteristica1 = new CC_Caracteristica__c();
		Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'CC_Caracteristica__c' AND DeveloperName = 'CC_Cliente_Cuenta' LIMIT 1].Id;
		caracteristica1.RecordTypeId = recordTypeId; 
        caracteristica1.Name = 'Característica 1';
        caracteristica1.CC_Descripcion__c = 'Esta es la descripción de la primera característica y ocupa más de cincuenta caracteres.';
        caracteristica1.CC_Prioridad__c = '2 - Media';
        caracteristica1.CC_Avisar_agente__c = true;
        caracteristica1.OS_Negocio__c = 'FRA';
        caracteristica1.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-5);
        insert caracteristica1;

        CC_Caracteristica__c caracteristica2 = new CC_Caracteristica__c();
		Id recordTypeId2 = [SELECT Id FROM RecordType WHERE SObjectType = 'CC_Caracteristica__c' AND DeveloperName = 'CC_Cliente_Contacto' LIMIT 1].Id;
		caracteristica2.RecordTypeId = recordTypeId2; 
        caracteristica2.Name = 'Característica 2';
        caracteristica2.CC_Descripcion__c = 'Esta es la descripción de la primera característica y ocupa más de cincuenta caracteres.';
        caracteristica2.CC_Prioridad__c = '2 - Media';
        caracteristica2.CC_Avisar_agente__c = true;
        caracteristica2.OS_Negocio__c = 'FRA';
        caracteristica2.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-5);
        insert caracteristica2;

        CC_Caracteristica_Detalle__c caracteristicaDetalleCentroCaixaBank = new CC_Caracteristica_Detalle__c(
            CC_Centro_CaixaBank__c = oficina.Id,
            CC_Caracteristica__c = caracteristica1.Id
        );
        insert caracteristicaDetalleCentroCaixaBank;

         // Crear características para la cuenta Otra
         CC_Caracteristica_Detalle__c caracteristicaDetalleOtra = new CC_Caracteristica_Detalle__c(
            CC_Cuenta__c = cuentaOtra.Id,
            CC_Caracteristica__c = caracteristica1.Id
        );
        insert caracteristicaDetalleOtra;

        // Crear características para la cuenta Otra
        CC_Caracteristica_Detalle__c caracteristicaDetalleContactoLlamada = new CC_Caracteristica_Detalle__c(
            CC_Empleado__c = empleado.Id,
            CC_Caracteristica__c = caracteristica1.Id
        );
        insert caracteristicaDetalleContactoLlamada;

		
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


    // Prueba para el caso cuando no hay cuenta asociada
    @isTest
    static void testConseguirCaracteristicaCuentaSinCuenta() {
		Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {

        // Crear un caso sin cuenta asociada
        Case casoSinCuenta = new Case(Status = 'New');
        insert casoSinCuenta;

        Test.startTest();
        List<CC_Caracteristica_Detalle__c> caracteristicas = FRA_Caracteristicas_Controller.conseguirCaracteristicaCuenta(casoSinCuenta.Id);
        Test.stopTest();

        // Asegurarse de que la lista está vacía
        System.assertEquals(0, caracteristicas.size(), 'Debe retornar una lista vacía cuando no hay cuenta asociada');
		}
    }

    // Prueba para el caso con recordType 'CC_Cliente'
    @isTest
    static void testConseguirCaracteristicaContactoCaso() {
		Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {

        // Obtener el caso que se creó en el setup
        Case casoCliente = [SELECT Id FROM Case WHERE Contact.RecordType.DeveloperName = 'CC_Empleado' LIMIT 1];

        Test.startTest();
        List<CC_Caracteristica_Detalle__c> caracteristicas = FRA_Caracteristicas_Controller.conseguirCaracteristicaCuenta(casoCliente.Id);
        Test.stopTest();

        // Asegurarse de que se devuelve al menos una característica
        System.assertNotEquals(0, caracteristicas.size(), 'Debe retornar al menos una característica para Cliente');
		}
    }

    // Prueba para el caso con recordType 'CC_Cliente'
    @isTest
    static void testConseguirCaracteristicaContactoCaso2() {
		Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {

        // Obtener el caso que se creó en el setup
        Case casoCliente = [SELECT Id FROM Case WHERE Contact.RecordType.DeveloperName = 'CC_Cliente' LIMIT 1];

        Test.startTest();
        List<CC_Caracteristica_Detalle__c> caracteristicas = FRA_Caracteristicas_Controller.conseguirCaracteristicaContactoCaso(casoCliente.Id);
        Test.stopTest();

        // Asegurarse de que se devuelve al menos una característica
        System.assertEquals(0, caracteristicas.size(), 'Debe retornar al menos una característica para Cliente');
		}
    }

	@isTest
    static void testConseguirCaracteristicaDesdeOpportunity() {
		Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {

	   Case micaso = [SELECT Id FROM Case  WHERE  Subject = 'Caso Test' LIMIT 1];
	  

	   Id idRecordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

	   // Crear un Contacto Empleado
	   Contact empleado = new Contact(
		FirstName = 'Empleado',
		LastName = 'Test',
		RecordTypeId = idRecordTypeEmpleado
		);
		insert empleado;

		CC_Caracteristica__c caracteristica1 = new CC_Caracteristica__c();
		Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'CC_Caracteristica__c' AND DeveloperName = 'CC_Cliente_Cuenta' LIMIT 1].Id;
		caracteristica1.RecordTypeId = recordTypeId; 
        caracteristica1.Name = 'Característica 1';
        caracteristica1.CC_Descripcion__c = 'Esta es la descripción de la primera característica y ocupa más de cincuenta caracteres.';
        caracteristica1.CC_Prioridad__c = '2 - Media';
        caracteristica1.CC_Avisar_agente__c = true;
        caracteristica1.OS_Negocio__c = 'FRA';
        caracteristica1.CC_Fecha_vigencia_inicio__c = Date.today().addDays(-5);
        insert caracteristica1;

		// Crear características para la cuenta Otra
        CC_Caracteristica_Detalle__c caracteristicaDetalleContactoLlamada = new CC_Caracteristica_Detalle__c(
            CC_Empleado__c = empleado.Id,
            CC_Caracteristica__c = caracteristica1.Id
        );
        insert caracteristicaDetalleContactoLlamada;
		
	   // Crear una Oportunidad asociada al Empleado
	   Opportunity opp = new Opportunity(
		Name = 'Test Opp',
		StageName = 'Prospecting',
		CloseDate = System.today(),
		CSBD_Contact__c = empleado.Id
		);
		insert opp;

		 // Obtener un contacto
		 Contact micliente = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Cliente' LIMIT 1];

        // Llamar al método conseguirCaracteristica con la ID de la oportunidad
        Test.startTest();
        List<CC_Caracteristica_Detalle__c> detalles = FRA_Caracteristicas_Controller.conseguirCaracteristica(opp.Id);
		
		List<CC_Caracteristica_Detalle__c> detallesCaso = FRA_Caracteristicas_Controller.conseguirCaracteristica(micaso.Id);

		List<CC_Caracteristica_Detalle__c> detallesContacto = FRA_Caracteristicas_Controller.conseguirCaracteristica(micliente.Id);
   
        Test.stopTest();

        // Verificar que la lista de características no esté vacía y que se hayan devuelto correctamente
        System.assert(!detalles.isEmpty(), 'Debe retornar características para el contacto asociado a la oportunidad');
        System.assertEquals('Característica 1', detalles[0].CC_Caracteristica__r.Name, 'Debe retornar la característica del Empleado');
		}
    }

	@isTest 
	static void testConseguirCaracteristicasFRA(){
		Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		System.runAs(agenteConsulta) {


        Test.startTest();
        List<CC_Caracteristica__c> caracteristicasContacto = FRA_Caracteristicas_Controller.conseguirCaracteristicasFRADeContacto();
        List<CC_Caracteristica__c> caracteristicasCuenta = FRA_Caracteristicas_Controller.conseguirCaracteristicasFRADeCuenta();

        Test.stopTest();

        System.assertEquals(1, caracteristicasContacto.size());
		System.assertEquals(1, caracteristicasCuenta.size());

		}
	}

	@isTest
	static void testAsociarCaracteristicaCuenta(){
		Id psAdministradorId = obtenerPSAdministrador();
		User agenteConsulta  = obtenerAgente1(psAdministradorId);

		Case caso = [SELECT AccountId FROM Case WHERE AccountId != NULL AND RecordType.DeveloperName = 'FRA_Cliente' AND Account.RecordType.DeveloperName ='CC_ClientePA' LIMIT 1];
		CC_Caracteristica__c caracteristica = [ SELECT Id FROM CC_Caracteristica__c WHERE OS_Negocio__c= 'FRA' AND RecordType.DeveloperName ='CC_Cliente_Cuenta' AND CC_Activo__c =true LIMIT 1];

		System.runAs(agenteConsulta) {


		Test.startTest();
		FRA_Caracteristicas_Controller.asociarCaracteristicaCuenta(caso.id , caracteristica.Id);
		Test.stopTest();

		Integer detalle = [SELECT COUNT() FROM CC_Caracteristica_Detalle__c WHERE CC_Caracteristica__r.Id = :caracteristica.Id];
		System.assertEquals(4, detalle, 'Tiene que haber 4 característica');

		}
	}

	@isTest
	static void testAsociarCaracteristicaContacto(){
		Id psAdministradorId = obtenerPSAdministrador();
        User agenteConsulta  = obtenerAgente1(psAdministradorId);

		Case caso = [SELECT AccountId FROM Case WHERE AccountId != NULL AND RecordType.DeveloperName = 'FRA_Cliente' AND Subject= 'Caso Test cliente' LIMIT 1];
		CC_Caracteristica__c caracteristica = [ SELECT Id FROM CC_Caracteristica__c WHERE OS_Negocio__c= 'FRA' AND RecordType.DeveloperName ='CC_Cliente_Contacto' AND CC_Activo__c =true LIMIT 1];

		System.runAs(agenteConsulta) {


        Test.startTest();
        FRA_Caracteristicas_Controller.asociarCaracteristicaContacto(caso.id , caracteristica.Id);
        Test.stopTest();

		Integer detalle = [SELECT COUNT() FROM CC_Caracteristica_Detalle__c WHERE CC_Caracteristica__r.Id = :caracteristica.Id];
        System.assertEquals(1, detalle, 'Tiene que haber 1 característica');

		}
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
			Map<String, Object> retornoRegistrarLlamadaEntrante = FRA_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
			CC_Llamada__c llamadaEntrante = (CC_Llamada__c)retornoRegistrarLlamadaEntrante.get('llamada');
			System.assert(llamadaEntrante != null, 'La llamada no debería ser nula');

			//Creamos caso manualmente y lo cerramos con actividades de llamada abiertas
			Case caso = FRA_Llamada_GC.crearVincularCaso(llamadaEntrante, true);

            // testConseguirCaracteristicaCuentaLlamada_CentroCaixaBank
             // Llamar al método que se está probando
            List<CC_Caracteristica_Detalle__c> caracteristicas = FRA_Caracteristicas_Controller.conseguirCaracteristicaCuentaLlamada(llamadaEntrante.Id);
            List<CC_Caracteristica_Detalle__c> caracteristicas2 = FRA_Caracteristicas_Controller.conseguirCaracteristicaContactoLlamada(llamadaEntrante.Id);
            // Verificar que se recupera la característica esperada
			System.assertEquals(0, caracteristicas.size(), 'No coincide la cantidad de características asociadas a la cuenta');
			System.assertEquals(0, caracteristicas2.size(), 'No coincide la cantidad de características asociadas al contacto');
            
            
			Test.stopTest();

			Task actividad = [SELECT Id FROM Task WHERE CC_Llamada_Id__c = :llamadaEntrante.Id AND Type = 'Llamada entrante' AND Status = 'Open' LIMIT 1];
			System.assert(actividad != null);
			HDT_Llamada_GC.finalizarLlamada(inputLlamada, 'Llamada finalizada');
		} 
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
}