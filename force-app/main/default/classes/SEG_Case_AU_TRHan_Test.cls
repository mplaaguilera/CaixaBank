@isTest
public with sharing class SEG_Case_AU_TRHan_Test {
	@testSetup
	static void datosIniciales() {

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
			String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User thisUser = new User(alias = 'user2', email='testSEGBI2@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                Username = uniqueName + '@test' + orgId + '.org');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }

 		Id grupoOpSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
		System.runAs ( supervisor ) {
		// Creación cuentas a tratar.  

		Account cuentaSEG = new Account();
        cuentaSEG.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG.Name = 'test segmentos';
        cuentaSEG.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG.CC_Numero_Documento__c = '111111114';
        insert cuentaSEG;

        Contact contactoSEG = new Contact();
        contactoSEG.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG.FirstName = 'Yaiza';
        contactoSEG.LastName = 'Contacto 2';
        contactoSEG.Email = 'testasdas@test.com';
        contactoSEG.AccountId = cuentaSEG.Id;
        insert contactoSEG;

		Account cuentaSEG1 = new Account();
		cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		cuentaSEG1.Name = 'Empresa segmentos';
		cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
		cuentaSEG1.CC_Numero_Documento__c = '11111111H';
		cuentaSEG1.AV_EAPGestor__c = contactoSEG.Id;
		insert cuentaSEG1;

		// Crear contactos para cuentas SEG
		Contact contactoSEG1 = new Contact();
		contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		contactoSEG1.LastName = 'Contacto SEG 1';
		contactoSEG1.AccountId = cuentaSEG1.Id;
		contactoSEG1.Email = 'test@test.com';
		insert contactoSEG1;
        
        //Crear reclamaciones
        SEG_Reclamaciones__c recl = new SEG_Reclamaciones__c();
        recl.Name = 'Testreclamaciones';
        recl.SEG_Plazo1Reclamacion__c = 1;
        recl.SEG_Plazo2Reclamacion__c = 2;
        recl.SEG_Plazo3Reclamacion__c = 3;
        recl.SEG_PlazoEnvioGestor__c = 4;
        recl.SEG_PlazoLlamada__c = 1;

        insert recl;
        
        Id recordTypeIdDetalle = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        
        //Crear MCC para CR

        CC_MCC__c mccTematicaSEG = new CC_MCC__c();
		mccTematicaSEG.Name = 'Tematica1SEG';
        mccTematicaSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematicaSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematicaSEG.RecordTypeId = recordTypeIdTematica;
        mccTematicaSEG.CC_Codigo_Externo__c = 'TE-000007';
        insert mccTematicaSEG;
        
        CC_MCC__c mccProductoSEG = new CC_MCC__c();
        mccProductoSEG.Name = 'Producto1SEG';
        mccProductoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccProductoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProductoSEG.RecordTypeId = recordTypeIdProducto;
        mccProductoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccProductoSEG.CC_Codigo_Externo__c = 'PR-000007'; 
        insert mccProductoSEG; 
        
       	CC_MCC__c mccMotivoSEG = new CC_MCC__c();
        mccMotivoSEG.Name = 'Motivo1SEG';
        mccMotivoSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivoSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivoSEG.RecordTypeId = recordTypeIdMotivo;
        mccMotivoSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccMotivoSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccMotivoSEG.CC_Codigo_Externo__c = 'MO-000007';
        insert mccMotivoSEG;

       	CC_MCC__c mccDetalleSEG = new CC_MCC__c();
        mccDetalleSEG.Name = 'Detalle1SEG';
        mccDetalleSEG.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalleSEG.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalleSEG.RecordTypeId = recordTypeIdDetalle;
        mccDetalleSEG.CC_Tematica__c = mccTematicaSEG.Id;
        mccDetalleSEG.CC_Producto_Servicio__c = mccProductoSEG.Id;
        mccDetalleSEG.CC_Motivo__c = mccMotivoSEG.Id;
        mccDetalleSEG.CC_Codigo_Externo__c = 'DE-000007';
        insert mccDetalleSEG;
        
        SEG_ClasificacionRapida__c regla3 = new SEG_ClasificacionRapida__c();
        regla3.Name = 'CR3';
        regla3.SEG_Tematica__c = mccTematicaSEG.Id;
        regla3.SEG_Producto__c = mccProductoSEG.Id;
        regla3.SEG_Motivo__c = mccMotivoSEG.Id;
        regla3.SEG_Detalle__c = mccDetalleSEG.Id;
        regla3.SEG_ReclamacionesContratos__c = recl.Id;
        regla3.SEG_CRContratos__c  = true;
        regla3.CBK_Negocio__c = 'Segmentos';
        insert regla3;

		// Crear casos de los clientes.
		List<Case> listadoCasos = new List<Case> ();

		Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.AccountId = cuentaSEG1.Id;
		caso1.ContactId = contactoSEG1.Id;
		caso1.CC_MailTelfNotif__c = contactoSEG1.Email;
		caso1.SEG_Idioma__c = 'en';
		caso1.CC_AcuseRecibo__c = '1';
		caso1.Subject = 'Activo';
		caso1.Status = 'Pendiente';
		caso1.OwnerId = supervisor.Id;
		listadoCasos.add(caso1);
            
        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c(
               SEG_Zona__c = 'Corporativa',
               SEG_Organizacion__C = 'Banca Corporativa',
               Name = 'GrupoSegOp1',
               RecordTypeId = grupoOpSegId       
        );
		insert grupoCol1;

		Case caso2 = new Case();
		caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		caso2.AccountId = cuentaSEG1.Id;
		caso2.ContactId = contactoSEG1.Id;
		caso2.CC_MailTelfNotif__c = contactoSEG1.Email;
		caso2.SEG_Idioma__c = 'es';
		caso2.CC_AcuseRecibo__c = '1';
		caso2.ParentId = caso1.Id;
		caso2.Status = 'Activo';
		caso2.Subject = 'test 2';
        caso2.SEG_Grupo__c = grupoCol1.Id;
        caso2.CC_MCC_Tematica__c = mccTematicaSEG.Id;
        caso2.CC_MCC_ProdServ__c = mccProductoSEG.Id;
        caso2.CC_MCC_Motivo__c = mccMotivoSEG.Id;
        caso2.SEG_ClasificacionRapida__c = regla3.Id;
        caso2.SEG_N_operaciones_del_caso__c = 0;     
		caso2.OwnerId = supervisor.Id;   
		listadoCasos.add(caso2);

		insert listadoCasos;

		SEG_GruposCSO__c grupoCSO = new SEG_GruposCSO__c();
		grupoCSO.Name = 'Grupo Test';
		grupoCSO.SEG_ActivoCSO__c = true;
		insert grupoCSO;

		List<SEG_UsuariosCSO__c> lstUsuario = new List<SEG_UsuariosCSO__c> ();
		SEG_UsuariosCSO__c userCSO = new SEG_UsuariosCSO__c();
		userCSO.SEG_ActivoCSO__c = true;
		userCSO.SEG_GrupoCSO__c = grupoCSO.Id;
		userCSO.SEG_Usuario__c = supervisor.Id;
		lstUsuario.add(userCSO);

		List<SEG_Fotosdefacturacion__c> lstFF = new List<SEG_Fotosdefacturacion__c>();
		SEG_Fotosdefacturacion__c ff1 = new SEG_Fotosdefacturacion__c();
		ff1.SEG_Estado__c = 'A determinar';
		ff1.SEG_GrupoCSO__c = grupoCSO.Id;
		ff1.SEG_Operativa__c = 'Grupo';
		ff1.SEG_Valor__c = 1;
		ff1.SEG_Usuariogenerador__c = supervisor.Id;
		ff1.SEG_NumeroSR__c = caso1.Id;
		lstFF.add(ff1);
		SEG_Fotosdefacturacion__c ff2 = new SEG_Fotosdefacturacion__c();
		ff2.SEG_Estado__c = 'A determinar';
		ff2.SEG_GrupoCSO__c = grupoCSO.Id;
		ff2.SEG_Operativa__c = 'Marca';
		ff2.SEG_Valor__c = 1;
		ff2.SEG_Usuariogenerador__c = supervisor.Id;
		ff2.SEG_NumeroSR__c = caso1.Id;
		lstFF.add(ff2);
		SEG_Fotosdefacturacion__c ff3 = new SEG_Fotosdefacturacion__c();
		ff3.SEG_Estado__c = 'A determinar';
		ff3.SEG_GrupoCSO__c = grupoCSO.Id;
		ff3.SEG_Operativa__c = 'MCC';
		ff3.SEG_Valor__c = 1;
		ff3.SEG_Usuariogenerador__c = supervisor.Id;
		ff3.SEG_NumeroSR__c = caso1.Id;
		lstFF.add(ff3);
		insert lstFF;
        
        //Crear contratos
        List<SEG_Contratos__c> listadoContratos = new List<SEG_Contratos__c>();
        SEG_Contratos__c contrato1 = new SEG_Contratos__c();
        contrato1.Name = 'Number1';
        contrato1.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato1.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato1.SEG_SR_Seguimiento__c=caso2.Id;
        contrato1.SEG_Estado__c = 'No firmado';
        contrato1.SEG_Fecha_1_Reclamacion__c = date.Today();
        listadoContratos.add(contrato1);

        SEG_Contratos__c contrato2 = new SEG_Contratos__c();
        contrato2.Name = 'Number2';
        contrato2.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato2.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato2.SEG_SR_Seguimiento__c=caso2.Id;
        contrato2.SEG_Estado__c = 'No firmado';
        contrato2.SEG_Fecha_2_Reclamacion__c = date.Today();
        listadoContratos.add(contrato2);
        insert listadoContratos;
		}
	}

	@isTest
	public static void actualizarOwner()
	{

		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
		User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
		List<Case> lstcaso = [SELECT Id, OwnerId FROM Case WHERE Subject = 'test 2' LIMIT 1];

		System.runAs ( usuarioTest ) {
			Test.startTest();
			List<Case> listCsUpd = new List<Case> ();
			for (case cs : lstcaso) {
				cs.OwnerId = supervisor.Id;
				listCsUpd.add(cs);
			}
			update listCsUpd;
			Test.stopTest();
		}
		Case casoRes = [SELECT Id, SEG_ClasificacionRapida__c,Status, CC_MCC_Motivo__c FROM Case WHERE Subject = 'test 2'];
        System.assert(casoRes.Status != null);
	}

	@isTest
	public static void actualizarFF()
	{

		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

		List<Case> lstcaso = [SELECT Id, OwnerId FROM Case];

		System.runAs ( supervisor ) {
			Test.startTest();
			List<Case> listCsUpd = new List<Case> ();
			for (case cs : lstcaso) {
				cs.SEG_Organizacion__c = 'Banca Corporativa';
				listCsUpd.add(cs);
			}
			update listCsUpd;
			Test.stopTest();
		}

        Case casoRes = [SELECT Id, SEG_ClasificacionRapida__c,Status, CC_MCC_Motivo__c FROM Case WHERE Subject = 'test 2'];
        System.assert(casoRes.Status != null);
	}

	@isTest
	public static void actualizarNumCentro()
	{

		User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

		List<Case> lstcaso = [SELECT Id, OwnerId FROM Case];
		Account centro = new Account();
		centro.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
		centro.Name = 'Oficina 00001';
		centro.CC_Numero_Oficina_Empresa__c = '001-00001';
		centro.SEG_Organizacion__c = 'Banca Corporativa';
		centro.SEG_Zona__c = 'Corporativa';
		insert centro;

		Account grupoEmpresa = new Account();
		grupoEmpresa.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		grupoEmpresa.Name = 'Oficina 00003';
		grupoEmpresa.CC_Numero_Oficina_Empresa__c = '001-00003';
		grupoEmpresa.SEG_Organizacion__c = 'Banca Corporativa';
		grupoEmpresa.SEG_Zona__c = 'Corporativa';
		grupoEmpresa.CC_Numero_Documento__c = '33333333H';
		insert grupoEmpresa;

		Account empresaSEG = new Account();
		empresaSEG.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		empresaSEG.Name = 'Empresa segmentos';
		empresaSEG.SEG_DominioMail__c = '@cuentaSEG';
		empresaSEG.SEG_Organizacion__c = 'Banca Corporativa';
		empresaSEG.SEG_Zona__c = 'Corporativa';
		empresaSEG.CC_Numero_Documento__c = '22222222H';
		empresaSEG.ParentId = grupoEmpresa.Id;
		empresaSEG.SEG_Oficina_Gestora_Segmentos__c = centro.Id;
		insert empresaSEG;

		System.runAs ( usuarioTest ) {
			Test.startTest();
			List<Case> listCsUpd = new List<Case> ();
			for (case cs : lstcaso) {
				cs.AccountId = empresaSEG.Id;
				listCsUpd.add(cs);
			}
			update listCsUpd;
			Test.stopTest();
		}
        Case casoRes = [SELECT Id, SEG_ClasificacionRapida__c,Status, CC_MCC_Motivo__c FROM Case WHERE Subject = 'test 2'];
        System.assert(casoRes.Status != null);
	}
    
	@isTest
	public static void cerrarCasoSeguimientoTest()
	{

		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        
		System.runAs ( supervisor ) {
        	Test.startTest();
        	caso.SEG_SRAuditoria__c = true;
        	caso.Status = 'Cerrado';
        	caso.CC_Detalles_Consulta__c = 'Caso cerrado';
        	update caso;
			
			
        	Test.stopTest();
		}
        Case casoRes = [SELECT Id, SEG_ClasificacionRapida__c,Status, CC_MCC_Motivo__c FROM Case WHERE Subject = 'test 2'];
        System.assert(casoRes.Status != null);
	}
    
    @isTest
	public static void addFechaPlanificacionTest()
	{

		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        
		System.runAs ( supervisor ) {
        	Test.startTest();
			caso.SEG_Fecha_planificaci_n__c = DateTime.newInstance(2123, 10, 16, 23, 0, 0);
        	update caso; 
			
        	Test.stopTest();
		}
        Case casoRes = [SELECT Id, SEG_Fecha_planificaci_n__c FROM Case WHERE Subject = 'test 2'];
        System.assert(casoRes.SEG_Fecha_planificaci_n__c != null);

	}

	@isTest
	public static void actualizacionContactoSeguimientoTest()
	{

		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

		Case casoSeguimiento = [SELECT Id, ContactId FROM Case WHERE Subject = 'test 2'];
		Contact cambioContacto = [SELECT Id FROM Contact WHERE FirstName = 'Yaiza'];
        
		System.runAs ( supervisor ) {
        	Test.startTest();
			casoSeguimiento.ContactId = cambioContacto.Id;
        	update casoSeguimiento; 
        	Test.stopTest();
		}	
		List<SEG_Contratos__c> contratoSeguimiento = [SELECT Id, SEG_NombreCliente__c FROM SEG_Contratos__c WHERE SEG_SR_Seguimiento__c =: casoSeguimiento.Id];
		for(SEG_Contratos__c contrato:contratoSeguimiento){
			System.assertEquals(cambioContacto.Id, contrato.SEG_NombreCliente__c,'No se ha modificado el contacto del contrato');
		}

	}
    
    @isTest
	public static void conexionTaskConnectAltaTest(){

		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        
		System.runAs ( supervisor ) {
        	Test.startTest();
			caso.SEG_sincronizado_con_TaskConnect__c = true;
            caso.Status = 'Pendiente';
        	update caso; 
			
        	Test.stopTest();
		}
        Case casoRes = [SELECT Id, SEG_sincronizado_con_TaskConnect__c FROM Case WHERE Subject = 'test 2'];
        System.assert(casoRes.SEG_sincronizado_con_TaskConnect__c != false);
	}

	@isTest
	public static void taskConnectModificacionTest(){

		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 2'];
		caso.SEG_sincronizado_con_TaskConnect__c = true;
		update caso; 
        
		System.runAs ( supervisor ) {
        	Test.startTest();
			caso.SEG_Subestado__c = 'Con propietario anterior';
        	update caso; 
			
        	Test.stopTest();
		}
        List<CC_TrazaInt__c> trazaWS = [SELECT Id FROM CC_TrazaInt__c WHERE CreatedDate = TODAY and Name = 'SEG_TaskConnect'];
        System.assertNotEquals(true, trazaWS.isEmpty(), 'No se ha enviado la actualización a Taskconnect');
	}

	@isTest
	public static void taskConnectModPrioridadTest(){

		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 2'];
		caso.SEG_sincronizado_con_TaskConnect__c = true;
		update caso; 
        
		System.runAs ( supervisor ) {
        	Test.startTest();
			caso.Priority = 'Low';
        	update caso; 
			
        	Test.stopTest();
		}
        List<CC_TrazaInt__c> trazaWS = [SELECT Id FROM CC_TrazaInt__c WHERE CreatedDate = TODAY and Name = 'SEG_TaskConnect'];
        System.assertNotEquals(true, trazaWS.isEmpty(), 'No se ha enviado la actualización a Taskconnect');
	}

	@isTest
	public static void taskConnectModSLATest(){

		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 2'];
		caso.SEG_sincronizado_con_TaskConnect__c = true;
		update caso; 
        
		System.runAs ( supervisor ) {
        	Test.startTest();
			caso.SEG_SLA_cliente_case__c = 'Mismo día recepción';
        	update caso; 
			
        	Test.stopTest();
		}
        List<CC_TrazaInt__c> trazaWS = [SELECT Id FROM CC_TrazaInt__c WHERE CreatedDate = TODAY and Name = 'SEG_TaskConnect'];
        System.assertNotEquals(true, trazaWS.isEmpty(), 'No se ha enviado la actualización a Taskconnect');
	}

	@isTest
	public static void taskConnectReaperturaTest(){

		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];

        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 2'];
		caso.SEG_sincronizado_con_TaskConnect__c = true;
		caso.Status = 'Rechazado';
		update caso; 
        
		System.runAs ( supervisor ) {
        	Test.startTest();
			caso.Status = 'Activo';
        	update caso; 
			
        	Test.stopTest();
		}
        List<CC_TrazaInt__c> trazaWS = [SELECT Id FROM CC_TrazaInt__c WHERE CreatedDate = TODAY and Name = 'SEG_TaskConnect'];
        System.assertNotEquals(true, trazaWS.isEmpty(), 'No se ha enviado la actualización a Taskconnect');
	}
    
    @isTest
	public static void actualizarPropietarioGrupoAnteriorTest(){

		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
		User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

        Case caso = [SELECT Id FROM Case WHERE Subject = 'Activo'];
        
		System.runAs ( usuarioTest ) {
        	Test.startTest();
			caso.OwnerId = usuarioTest.Id;
        	update caso; 
			
        	Test.stopTest();
		}
        List<SEG_Grupos_por_caso__c> lstGruposCaso = [SELECT Id FROM SEG_Grupos_por_caso__c];
        System.assert(lstGruposCaso.isEmpty() != true);

	}
    
    @isTest
	public static void trazaChatterTest(){

        Id idContacto;
        Id idCuenta;
        
		User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

        Case caso = [SELECT Id, ContactId, AccountId FROM Case WHERE Subject = 'Activo'];
        idCuenta = caso.AccountId;
        idContacto = caso.ContactId;
        caso.AccountId = null;
        caso.ContactId = null;
        
        update caso;
        
		System.runAs ( usuarioTest ) {
        	Test.startTest();
			caso.OwnerId = usuarioTest.Id;
            caso.AccountId = idCuenta;
        	caso.ContactId = idContacto;
        	update caso; 
			
        	Test.stopTest();
		}        
        List<CaseFeed> caseFeeds = [SELECT Id, ParentId, Type, CreatedById, CreatedDate FROM CaseFeed WHERE ParentId = :caso.Id ORDER BY CreatedDate DESC];
        CaseFeed feedActualizado = caseFeeds[0];
        System.assertEquals(caso.Id, feedActualizado.ParentId, 'El ParentId del feed no es correcto.');
    	System.assertEquals(usuarioTest.Id, feedActualizado.CreatedById, 'El feed no fue creado por el usuario de prueba.');
	}

}