@isTest
public with sharing class SEG_Case_BI_TRHan_Test extends SEG_Usuarios{
//User operativo = SEG_Usuarios.usuarioOperativo();
//User supervisor = SEG_Usuarios.usuarioSupervisor();

    @testSetup
	static void makeData(){
		// Creación cuentas a tratar.
		Account cuentaSEG1 = new Account();
		cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		cuentaSEG1.Name = 'Empresa segmentos';
		cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
		cuentaSEG1.CC_Numero_Documento__c = '11111111H';
		insert cuentaSEG1;

		// Crear contactos para cuentas SEG.
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
        
        Id recordTypeIdDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        
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
		mccMotivoSEG.SEG_SLACliente__c = 'Máximo 2h después recepción';
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
		listadoCasos.add(caso1);

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
        caso2.CC_MCC_Tematica__c = mccTematicaSEG.Id;
        caso2.CC_MCC_ProdServ__c = mccProductoSEG.Id;
        caso2.CC_MCC_Motivo__c = mccMotivoSEG.Id;
        caso2.SEG_ClasificacionRapida__c = regla3.Id;
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
		userCSO.SEG_Usuario__c = UserInfo.getUserId();
		lstUsuario.add(userCSO);

		List<SEG_Fotosdefacturacion__c> lstFF = new List<SEG_Fotosdefacturacion__c>();
		SEG_Fotosdefacturacion__c ff1 = new SEG_Fotosdefacturacion__c();
		ff1.SEG_Estado__c = 'A determinar';
		ff1.SEG_GrupoCSO__c = grupoCSO.Id;
		ff1.SEG_Operativa__c = 'Grupo';
		ff1.SEG_Valor__c = 1;
		ff1.SEG_Usuariogenerador__c = UserInfo.getUserId();
		ff1.SEG_NumeroSR__c = caso1.Id;
		lstFF.add(ff1);
		SEG_Fotosdefacturacion__c ff2 = new SEG_Fotosdefacturacion__c();
		ff2.SEG_Estado__c = 'A determinar';
		ff2.SEG_GrupoCSO__c = grupoCSO.Id;
		ff2.SEG_Operativa__c = 'Marca';
		ff2.SEG_Valor__c = 1;
		ff2.SEG_Usuariogenerador__c = UserInfo.getUserId();
		ff2.SEG_NumeroSR__c = caso1.Id;
		lstFF.add(ff2);
		SEG_Fotosdefacturacion__c ff3 = new SEG_Fotosdefacturacion__c();
		ff3.SEG_Estado__c = 'A determinar';
		ff3.SEG_GrupoCSO__c = grupoCSO.Id;
		ff3.SEG_Operativa__c = 'MCC';
		ff3.SEG_Valor__c = 1;
		ff3.SEG_Usuariogenerador__c = UserInfo.getUserId();
		ff3.SEG_NumeroSR__c = caso1.Id;
		lstFF.add(ff3);
		insert lstFF;
        
        //Crear contratos
        SEG_Contratos__c contrato1 = new SEG_Contratos__c();
        contrato1.Name = 'Number1';
        contrato1.SEG_NombreCliente__c = contactoSEG1.Id;
        //contrato1.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato1.SEG_SR_Seguimiento__c=caso2.Id;
        contrato1.SEG_Estado__c = 'No firmado';
        contrato1.SEG_Fecha_1_Reclamacion__c = date.Today();
        insert contrato1;

        SEG_Contratos__c contrato2 = new SEG_Contratos__c();
        contrato2.Name = 'Number2';
        contrato2.SEG_NombreCliente__c = contactoSEG1.Id;
        //contrato2.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato2.SEG_SR_Seguimiento__c=caso2.Id;
        contrato2.SEG_Estado__c = 'No firmado';
        contrato2.SEG_Fecha_2_Reclamacion__c = date.Today();
        insert contrato2;

		Id grupoOpSegId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
		//Grupo Colaborador
        CC_Grupo_Colaborador__c grupoCol1 = new CC_Grupo_Colaborador__c();
        grupoCol1.Name = 'MCC 0029';
        grupoCol1.RecordTypeId = grupoOpSegId;
        grupoCol1.SEG_GrupoSegmentos__c = true;
        grupoCol1.SEG_NotaGrupoPlantillaEN__c = 'notaGrupoEN';
        grupoCol1.SEG_NotaGrupoPlantillaES__c = 'notaGrupoES';
        grupoCol1.SEG_NotaGrupoPlantillaCAT__c = 'notaGrupoCAT';
        grupoCol1.SEG_NotaGrupoPlantillaEU__c = 'notaGrupoEU';
        grupoCol1.SEG_NotaGrupoPlantillaGL__c = 'notaGrupoGA';
        insert grupoCol1;

		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            User thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                username='testSEGBI@acme.com');
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

	}
/*
    @isTest
	public static void actualizarFF(){
		List<Case> lstcaso = [SELECT Id, OwnerId FROM Case];

		Test.startTest();
		List<Case> listCsUpd = new List<Case> ();
		for (case cs : lstcaso) {
			cs.SEG_Organizacion__c = 'Banca Corporativa';
			listCsUpd.add(cs);
		}
		update listCsUpd;
		Test.stopTest();
	}*/

	@IsTest
	static void mainEntryTest(){
		User supervisor = SEG_Usuarios.usuarioSupervisor();
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {

			List<Account> cuenta = [SELECT id,RecordTypeId, Name, SEG_DominioMail__c,CC_Numero_Documento__c FROM Account LIMIT 1];
			List<Contact> contacto = [SELECT id, RecordTypeId, LastName, AccountId, Email FROM contact LIMIT 1];

			List<SEG_ClasificacionRapida__c> cr = [SELECT id,Name, SEG_Tematica__c, SEG_Producto__c,SEG_Motivo__c,SEG_Detalle__c,SEG_ReclamacionesContratos__c,
														SEG_CRContratos__c,CBK_Negocio__c 
													FROM SEG_ClasificacionRapida__c WHERE Name = 'CR3' LIMIT 1];

			Case caso3 = new Case();
			caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
			caso3.AccountId = cuenta[0].Id;
			caso3.ContactId = contacto[0].Id;
			caso3.CC_MailTelfNotif__c = contacto[0].Email;
			caso3.SEG_ClasificacionRapida__c = cr[0].id;
			caso3.SEG_Organizacion__c = 'Banca Corporativa';
			caso3.SEG_Idioma__c = 'en';
			caso3.CC_AcuseRecibo__c = '1';
			caso3.Subject = 'Activo32';
			caso3.Status = 'Pendiente';
			caso3.OwnerId = supervisor.Id;


			Test.startTest();
					insert caso3; 	
			Test.stopTest();
			
			List<Case> casos = [SELECT Id, OwnerId ,subject FROM Case WHERE subject = 'Activo32'];
			system.assert(casos[0] != null , 'El caso no se ha insertado correctamente');

		}
	}

	@IsTest
	static void noAccountTest(){
		User supervisor = SEG_Usuarios.usuarioSupervisor();

		System.runAs ( new User(Id = UserInfo.getUserId()) ) {

			List<Account> cuenta = [SELECT id,RecordTypeId, Name, SEG_DominioMail__c,CC_Numero_Documento__c FROM Account LIMIT 1];
			List<Contact> contacto = [SELECT id, RecordTypeId, LastName, AccountId, Email FROM contact LIMIT 1];

			List<SEG_ClasificacionRapida__c> cr = [SELECT id,Name, SEG_Tematica__c, SEG_Producto__c,SEG_Motivo__c,SEG_Detalle__c,SEG_ReclamacionesContratos__c,
														SEG_CRContratos__c,CBK_Negocio__c 
													FROM SEG_ClasificacionRapida__c WHERE Name = 'CR3' LIMIT 1];

			Case caso3 = new Case();
			caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
			caso3.AccountId = null;
			caso3.ContactId = contacto[0].Id;
			caso3.CC_MailTelfNotif__c = contacto[0].Email;
			caso3.SEG_ClasificacionRapida__c = cr[0].id;
			caso3.SEG_Organizacion__c = 'Banca Corporativa';
			caso3.SEG_Idioma__c = 'en';
			caso3.CC_AcuseRecibo__c = '1';
			caso3.Subject = 'Activo32';
			caso3.Status = 'Pendiente';	
			caso3.OwnerId = supervisor.Id;	

			Test.startTest(); 
					insert caso3; 	
			Test.stopTest();

			List<Case> casos = [SELECT Id, OwnerId ,subject FROM Case WHERE subject = 'Activo32'];
			system.assert(casos[0] != null , 'El caso no se ha insertado correctamente');

		}
	}

	@IsTest
	static void grupoColabTest(){
		User supervisor = SEG_Usuarios.usuarioSupervisor();

		System.runAs ( new User(Id = UserInfo.getUserId()) ) {

			List<Account> cuenta = [SELECT id,RecordTypeId, Name, SEG_DominioMail__c,CC_Numero_Documento__c FROM Account LIMIT 1];
			List<Contact> contacto = [SELECT id, RecordTypeId, LastName, AccountId, Email FROM contact LIMIT 1];

			List<SEG_ClasificacionRapida__c> cr = [SELECT id,Name, SEG_Tematica__c, SEG_Producto__c,SEG_Motivo__c,SEG_Detalle__c,SEG_ReclamacionesContratos__c,
														SEG_CRContratos__c,CBK_Negocio__c 
													FROM SEG_ClasificacionRapida__c WHERE Name = 'CR3' LIMIT 1];
			
			List<CC_Grupo_Colaborador__c>  grupoColab = [SELECT id, name FROM CC_Grupo_Colaborador__c WHERE name = 'MCC 0029'];

			Case caso3 = new Case();
			caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
			caso3.AccountId = cuenta[0].Id;
			caso3.ContactId = contacto[0].Id;
			caso3.CC_MailTelfNotif__c = contacto[0].Email;
			caso3.SEG_ClasificacionRapida__c = cr[0].id;
			caso3.SEG_Organizacion__c = 'Banca Corporativa';
			caso3.SEG_Idioma__c = 'en';
			caso3.SEG_Grupo__c = grupoColab[0].id;
			caso3.CC_AcuseRecibo__c = '1';
			caso3.Subject = 'Activo32';
			caso3.Status = 'Pendiente';
			caso3.OwnerId = supervisor.Id;
		
			

			Test.startTest(); 
					insert caso3; 	
			Test.stopTest();

			List<Case> casos = [SELECT Id, OwnerId ,subject FROM Case WHERE subject = 'Activo32'];
			system.assert(casos[0] != null , 'El caso no se ha insertado correctamente');

		}
	}

	@isTest
    public static void rellenarClienteCabeceraInsert_test(){
 
        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        Case caso2 = caso;        
        caso2.subject = 'rellenarClienteCabeceraInsert_test';
        caso2.Id = null;
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        Test.startTest();   
            
            System.runAs(usuarioTest) {           
                insert caso2;
            }    

        Test.stopTest();

        Case casoRes = [SELECT Account.Name, SEG_Cliente_de_la_cabecera__c FROM Case WHERE Subject = 'rellenarClienteCabeceraInsert_test'];
        System.assertEquals(casoRes.Account.Name, casoRes.SEG_Cliente_de_la_cabecera__c, 'No se ha modificado el nombre del cliente de la cabecera');
        
    }

	@isTest
    public static void rellenarBuzonZonaInsert_test(){
 
        Case caso = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        Case caso2 = caso;        
        caso2.subject = 'rellenarBuzonZonaInsert_test';
        caso2.Id = null;
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        Test.startTest();   
            
            System.runAs(usuarioTest) {           
                insert caso2;
            }    

        Test.stopTest();

        Case casoRes = [SELECT Account.Name, SEG_Buz_n_de_la_zona__c FROM Case WHERE Subject = 'rellenarBuzonZonaInsert_test'];
        System.assertEquals(casoRes.Account.Name, casoRes.SEG_Buz_n_de_la_zona__c, 'No se ha modificado el buzon de la zona de la cabecera');
    
	}

	@isTest
    public static void asignarSLATest(){
 
        User supervisor = SEG_Usuarios.usuarioSupervisor();

		System.runAs ( new User(Id = UserInfo.getUserId()) ) {

			List<Account> cuenta = [SELECT id,RecordTypeId, Name, SEG_DominioMail__c,CC_Numero_Documento__c FROM Account LIMIT 1];
			List<Contact> contacto = [SELECT id, RecordTypeId, LastName, AccountId, Email FROM contact LIMIT 1];
			Case caso2 = [SELECT Id, CreatedDate FROM Case WHERE Subject = 'test 2'];

			List<SEG_ClasificacionRapida__c> cr = [SELECT id,Name, SEG_Tematica__c, SEG_Producto__c,SEG_Motivo__c,SEG_Detalle__c,SEG_ReclamacionesContratos__c,
														SEG_CRContratos__c,CBK_Negocio__c 
													FROM SEG_ClasificacionRapida__c WHERE Name = 'CR3' LIMIT 1];
			
			List<CC_Grupo_Colaborador__c>  grupoColab = [SELECT id, name FROM CC_Grupo_Colaborador__c WHERE name = 'MCC 0029'];

			Case caso3 = new Case();
			caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
			caso3.AccountId = cuenta[0].Id;
			caso3.ContactId = contacto[0].Id;
			caso3.CC_MailTelfNotif__c = contacto[0].Email;
			caso3.SEG_ClasificacionRapida__c = cr[0].id;
			caso3.SEG_Organizacion__c = 'Banca Corporativa';
			caso3.SEG_Idioma__c = 'en';
			caso3.SEG_Grupo__c = grupoColab[0].id;
			caso3.CC_AcuseRecibo__c = '1';
			caso3.Subject = 'Activo32';
			caso3.Status = 'Pendiente';
			caso3.OwnerId = supervisor.Id;
			caso3.ParentId = caso2.Id;

			Test.startTest(); 
					insert caso3; 	
			Test.stopTest();

			List<Case> casos = [SELECT Id, OwnerId ,subject, SEG_Fecha_inicio_SLA__c FROM Case WHERE subject = 'Activo32'];
			system.assertEquals(caso2.CreatedDate, casos[0].SEG_Fecha_inicio_SLA__c , 'El SLAs del Caso Hijo no se ha modificado correctamente');

		}
	}

	@isTest
    public static void biSRContratosTest(){
 
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        //Creamos el caso 
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso.Subject = 'Prueba primer caso';
        caso.Status = 'Pendiente';
        caso.SEG_Organizacion__c = 'Banca Corporativa';
        caso.SEG_Zona__c = 'Corporativa';
        caso.OwnerId = usuarioTest.Id;

		Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso2.Subject = 'Prueba segundo caso';
        caso2.Status = 'Pendiente';
        caso2.SEG_Organizacion__c = 'Banca Corporativa';
        caso2.SEG_Zona__c = 'Corporativa';
        caso2.OwnerId = usuarioTest.Id;
        
        Test.startTest();
            System.runAs(usuarioTest) { 
                insert caso;
				insert caso2;
            }
        Test.stopTest();

        Case casoUpdates = [SELECT SEG_SRContratos__c,SEG_Check_Contratos__c FROM Case WHERE Subject = 'Prueba primer caso' LIMIT 1];
		Case casoUpdates2 = [SELECT SEG_SRContratos__c FROM Case WHERE Subject = 'Prueba segundo caso' LIMIT 1];

        System.assertEquals('Contratos',casoUpdates.SEG_SRContratos__c);
        System.assertEquals(true,casoUpdates.SEG_Check_Contratos__c);
		System.assertEquals(null,casoUpdates2.SEG_SRContratos__c);

    }
	
}