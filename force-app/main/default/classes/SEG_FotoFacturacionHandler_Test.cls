@isTest
public with sharing class SEG_FotoFacturacionHandler_Test{
	//User operativo = SEG_Usuarios.usuarioOperativo();
	//User supervisor = SEG_Usuarios.usuarioSupervisor();
	@testSetup
	static void datosIniciales()
	{
		List<User> lstUser = new List<User> ();
		String today = Date.today().format();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		User u = new User(Alias = 'groupcso', Email = 'standarduser@testorg.com',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduser@testorg' + today + '.com',
						  SEG_Tipo_usuario_SEG__c = '	CSO');
		lstUser.add(u);

		User u1 = new User(Alias = 'stand34', Email = 'nogroupcso@testorg.com',
		                   EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                   LocaleSidKey = 'en_US', ProfileId = p.Id,
		                   TimeZoneSidKey = 'America/Los_Angeles', UserName = 'nogroupcso@testorg' + today + '.com');
		lstUser.add(u1);

		User u2 = new User(Alias = 'activegr', Email = 'activegr@testorg.com',
		                   EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                   LocaleSidKey = 'en_US', ProfileId = p.Id,
		                   TimeZoneSidKey = 'America/Los_Angeles', UserName = 'activegr@testorg' + today + '.com');
		lstUser.add(u2);
		insert lstUser;

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

		//Crear Grupos de trabajo
		Id opSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
		Id opColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
		CC_Grupo_Colaborador__c grupoOpSeg = new CC_Grupo_Colaborador__c();
		grupoOpSeg.RecordTypeId = opSegId;
		grupoOpSeg.Name = 'Grupo de trabajo Operativo';
		grupoOpSeg.SEG_GrupoSegmentos__c = true; 
		insert grupoOpSeg;

		//Creacion de MCCs
		Id recordMotiv = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		Id recordProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
		Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();

		CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.RecordTypeId = recordTem;
		mccTematica.Name = 'Tematica';
		mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
		mccTematica.CC_Codigo_Externo__c = 'DE-000006';
		insert mccTematica;

		CC_MCC__c mccProdServ = new CC_MCC__c();
		mccProdServ.RecordTypeId = recordProdServ;
		mccProdServ.Name = 'ProdSev';
		mccProdServ.CC_Tipo_Cliente__c = 'Segmentos';
		mccProdServ.CC_Codigo_Externo__c = 'DE-000005';
		mccProdServ.CC_Tematica__c = mccTematica.Id;
		insert mccProdServ;

		CC_MCC__c mccMotivo = new CC_MCC__c();
		mccMotivo.RecordTypeId = recordMotiv;
		mccMotivo.Name = 'Motivo';
		mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
		mccMotivo.CC_Codigo_Externo__c = 'DE-000004';
		mccMotivo.CC_Producto_Servicio__c = mccProdServ.Id;
		insert mccMotivo;

		CC_MCC__c mccMotivo2 = new CC_MCC__c();
		mccMotivo2.RecordTypeId = recordMotiv;
		mccMotivo2.Name = 'Motivo2';
		mccMotivo2.CC_Tipo_Cliente__c = 'Segmentos';
		mccMotivo2.CC_Codigo_Externo__c = 'DE-000009';
		mccMotivo2.CC_Producto_Servicio__c = mccProdServ.Id;
		insert mccMotivo2;

		CC_MCC__c mccDetalle = new CC_MCC__c();
		mccDetalle.RecordTypeId = recordDet;
		mccDetalle.Name = 'Detalle';
		mccDetalle.CC_Tipo_Cliente__c = 'Segmentos';
		mccDetalle.CC_Codigo_Externo__c = 'DE-0000043';
		mccDetalle.CC_Motivo__c = mccMotivo.Id;
		insert mccDetalle;

		CC_MCC__c mccDetalle2 = new CC_MCC__c();
		mccDetalle2.RecordTypeId = recordDet;
		mccDetalle2.Name = 'Detalle2';
		mccDetalle2.CC_Tipo_Cliente__c = 'Segmentos';
		mccDetalle2.CC_Codigo_Externo__c = 'DE-0000099';
		mccDetalle2.CC_Motivo__c = mccMotivo2.Id;
		insert mccDetalle2;


		// Crear casos de los clientes.
		List<Case> listadoCasos = new List<Case> ();

		Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.AccountId = cuentaSEG1.Id;
		caso1.ContactId = contactoSEG1.Id;
		caso1.CC_MailTelfNotif__c = contactoSEG1.Email;
		caso1.SEG_Idioma__c = 'en';
		caso1.CC_AcuseRecibo__c = '1';
		caso1.Subject = 'test 1';
		caso1.Status = 'Pendiente';
		caso1.SEG_Organizacion__c = 'Banca Corporativa';
		caso1.SEG_Zona__c = 'Corporativa';
		caso1.CC_MCC_Tematica__c = mccTematica.Id;
		caso1.CC_MCC_ProdServ__c = mccProdServ.Id;
		caso1.CC_MCC_Motivo__c = mccMotivo.Id;
		caso1.SEG_Detalle__c = mccDetalle.Id;
		caso1.SEG_Grupo__c = grupoOpSeg.Id;
		listadoCasos.add(caso1);

		Case caso2 = new Case();
		caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		caso2.AccountId = cuentaSEG1.Id;
		caso2.ContactId = contactoSEG1.Id;
		caso2.CC_MailTelfNotif__c = contactoSEG1.Email;
		caso2.SEG_Idioma__c = 'es';
		caso2.CC_AcuseRecibo__c = '1';
		caso2.Status = 'Activo';
		caso2.Subject = 'test 2';
		caso2.SEG_Organizacion__c = 'Banca Corporativa';
		caso2.SEG_Zona__c = 'Corporativa';
		caso2.CC_MCC_Tematica__c = mccTematica.Id;
		caso2.CC_MCC_ProdServ__c = mccProdServ.Id;
		caso2.CC_MCC_Motivo__c = mccMotivo2.Id;
		caso2.SEG_Detalle__c = mccDetalle2.Id;
		caso2.SEG_Grupo__c = grupoOpSeg.Id;
		listadoCasos.add(caso2);

		Case caso3 = new Case();
		caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso3.AccountId = cuentaSEG1.Id;
		caso3.ContactId = contactoSEG1.Id;
		caso3.CC_MailTelfNotif__c = contactoSEG1.Email;
		caso3.SEG_Idioma__c = 'es';
		caso3.CC_AcuseRecibo__c = '1';
		caso3.Status = 'Activo';
		caso3.Subject = 'test 3';
		caso3.SEG_Organizacion__c = 'Banca Corporativa';
		caso3.SEG_Grupo__c = grupoOpSeg.Id;
		listadoCasos.add(caso3);
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

		userCSO = new SEG_UsuariosCSO__c();
		userCSO.SEG_ActivoCSO__c = false;
		userCSO.SEG_GrupoCSO__c = grupoCSO.Id;
		userCSO.SEG_Usuario__c = u.Id;
		lstUsuario.add(userCSO);

		userCSO = new SEG_UsuariosCSO__c();
		userCSO.SEG_ActivoCSO__c = true;
		userCSO.SEG_GrupoCSO__c = grupoCSO.Id;
		userCSO.SEG_Usuario__c = u2.Id;
		lstUsuario.add(userCSO);
		insert lstUsuario;

		Id recordTypeGrupo = Schema.SObjectType.SEG_ServiciosCSO__c.getRecordTypeInfosByDeveloperName().get('Grupo').getRecordTypeId();
		Id recordTypeMarca = Schema.SObjectType.SEG_ServiciosCSO__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
		Id recordTypeMCC = Schema.SObjectType.SEG_ServiciosCSO__c.getRecordTypeInfosByDeveloperName().get('MCC').getRecordTypeId();

		//Crear Id de Servicio tipo MCC
		SEG_ServiciosCSO__c servCsoMCC = new SEG_ServiciosCSO__c();
		servCsoMCC.SEG_Activo__c = true;
		servCsoMCC.RecordTypeId = recordTypeMCC;
		servCsoMCC.SEG_Organizacion__c = 'Banca Corporativa;Instituciones';
		servCsoMCC.SEG_Zona__c = 'Corporativa';
		servCsoMCC.SEG_TMO__c = 10;
		servCsoMCC.Name = 'Test MCC';
		insert servCsoMCC;

		SEG_MCCServiciosCSO__c servMcc = new SEG_MCCServiciosCSO__c();
		servMcc.SEG_Activo__c = true;
		servMcc.SEG_Tematica__c = mccTematica.Id;
		servMcc.SEG_Producto__c = mccProdServ.Id;
		servMcc.SEG_Motivo__c = mccMotivo.Id;
		//servMcc.SEG_Detalle__c = mccDetalle.Id;
		servMcc.SEG_ServiciosCSO__c = servCsoMCC.Id;
		insert servMcc;

		SEG_MCCServiciosCSO__c servMcc2 = new SEG_MCCServiciosCSO__c();
		servMcc2.SEG_Activo__c = false;
		servMcc2.SEG_Tematica__c = mccTematica.Id;
		servMcc2.SEG_Producto__c = mccProdServ.Id;
		servMcc2.SEG_Motivo__c = mccMotivo2.Id;
		//servMcc2.SEG_Detalle__c = mccDetalle2.Id;
		servMcc2.SEG_ServiciosCSO__c = servCsoMCC.Id;
		insert servMcc2;

		SEG_GruposServiciosCSO__c servGrupoCSO = new SEG_GruposServiciosCSO__c();
		servGrupoCSO.SEG_Activo__c = true;
		servGrupoCSO.SEG_GrupoCSO__c = grupoCSO.Id;
		servGrupoCSO.SEG_ServiciosCSO__c = servCsoMCC.Id;
		insert servGrupoCSO;

		//Crear Id de Servicio tipo Grupo
		SEG_ServiciosCSO__c servCsoGrupo = new SEG_ServiciosCSO__c();
		servCsoGrupo.SEG_Activo__c = true;
		servCsoGrupo.RecordTypeId = recordTypeGrupo;
		servCsoGrupo.SEG_Organizacion__c = 'Banca Corporativa;Instituciones';
		servCsoGrupo.SEG_Zona__c = 'Corporativa';
		servCsoGrupo.SEG_TMO__c = 10;
		servCsoGrupo.Name = 'Test Grupo';
		insert servCsoGrupo;

		servGrupoCSO = new SEG_GruposServiciosCSO__c();
		servGrupoCSO.SEG_Activo__c = true;
		servGrupoCSO.SEG_GrupoCSO__c = grupoCSO.Id;
		servGrupoCSO.SEG_ServiciosCSO__c = servCsoGrupo.Id;
		insert servGrupoCSO;

		SEG_GrupoTrabajoRelacionado__c grupoTrabajo = new SEG_GrupoTrabajoRelacionado__c();
		grupoTrabajo.SEG_Activo__c = true;
		grupoTrabajo.SEG_GrupoTrabajo__c = grupoOpSeg.Id;
		grupoTrabajo.SEG_ServiciosCSO__c = servCsoGrupo.Id;
		insert grupoTrabajo;

		//Crear Id de Servicio Marca
		SEG_ServiciosCSO__c servCsoMarca = new SEG_ServiciosCSO__c();
		servCsoMarca.SEG_Activo__c = true;
		servCsoMarca.RecordTypeId = recordTypeMarca;
		servCsoMarca.SEG_Organizacion__c = 'Banca Corporativa;Instituciones';
		servCsoMarca.SEG_Zona__c = 'Corporativa';
		servCsoMarca.SEG_TMO__c = 10;
		servCsoMarca.Name = 'Test Marca';
		insert servCsoMarca;

		Id recordTypeMarcasCaso = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SEG_Caracteristicacaso').getRecordTypeId();
		List<CC_Caracteristica__c> lstCar = new List<CC_Caracteristica__c> ();
		CC_Caracteristica__c car1 = new CC_Caracteristica__c();
		car1.RecordTypeId = recordTypeMarcasCaso;
		car1.CC_Descripcion__c = 'Caracteristica Test';
		car1.Name = 'TestCaracteristica1';
		insert car1;
		CC_Caracteristica__c car2 = new CC_Caracteristica__c();
		car2.RecordTypeId = recordTypeMarcasCaso;
		car2.CC_Descripcion__c = 'Caracteristica Test2';
		car2.Name = 'TestCaracteristica2';
		insert car2;

		SEG_MarcasCSO__c marcaCSO = new SEG_MarcasCSO__c();
		marcaCSO.SEG_Activo__c = true;
		marcaCSO.SEG_ServiciosCSO__c = servCsoMarca.Id;
		marcaCSO.SEG_Marca__c = car1.Id;
		insert marcaCSO;

		SEG_MarcasCSO__c marcaCSO1 = new SEG_MarcasCSO__c();
		marcaCSO1.SEG_Activo__c = true;
		marcaCSO1.SEG_ServiciosCSO__c = servCsoMarca.Id;
		marcaCSO1.SEG_Marca__c = car2.Id;
		insert marcaCSO1;

		servGrupoCSO = new SEG_GruposServiciosCSO__c();
		servGrupoCSO.SEG_Activo__c = true;
		servGrupoCSO.SEG_GrupoCSO__c = grupoCSO.Id;
		servGrupoCSO.SEG_ServiciosCSO__c = servCsoMarca.Id;
		insert servGrupoCSO;

		grupoTrabajo = new SEG_GrupoTrabajoRelacionado__c();
		grupoTrabajo.SEG_Activo__c = true;
		grupoTrabajo.SEG_GrupoTrabajo__c = grupoOpSeg.Id;
		grupoTrabajo.SEG_ServiciosCSO__c = servCsoMarca.Id;
		insert grupoTrabajo;
	}

	@isTest
	private static void testAddOperaciones() {
		User supervisor = SEG_Usuarios.usuarioSupervisor();

		List<SEG_Operacion__c> lstOp = new List<SEG_Operacion__c> ();
		SEG_Operacion__c op = new SEG_Operacion__c();
		Map<Id, List<SEG_Operacion__c>> caseOperaciones = new Map<Id, List<SEG_Operacion__c>> ();
        CC_MCC__c detalle = [SELECT id FROM CC_MCC__c WHERE Name = 'Detalle' LIMIT 1];
        CC_MCC__c prodServ = [SELECT id FROM CC_MCC__c WHERE Name = 'ProdSev' LIMIT 1];
        CC_MCC__c motivo = [SELECT id FROM CC_MCC__c WHERE Name = 'Motivo' LIMIT 1];
        CC_MCC__c tematica = [SELECT id FROM CC_MCC__c WHERE Name = 'Tematica' LIMIT 1];

		List<User> lstU = [Select Id FROM User WHERE Alias = 'groupcso'];
		User u = lstU.get(0);

		Id recordTypeCSO = Schema.SObjectType.SEG_Operacion__c.getRecordTypeInfosByDeveloperName().get('CSO').getRecordTypeId();
		for (Case cs :[Select Id, Subject From Case]) {
			if (cs.Subject == 'test 1') {
				op = new SEG_Operacion__c();
				op.RecordTypeId = recordTypeCSO;
				op.SEG_N_Operaciones__c = 1;
				op.SEG_SR__c = cs.Id;
				op.SEG_Usuario__c = UserInfo.getUserId();
				caseOperaciones.put(cs.Id, new List<SEG_Operacion__c> { op });
				op = new SEG_Operacion__c();
				op.RecordTypeId = recordTypeCSO;
				op.SEG_N_Operaciones__c = 3;
				op.SEG_SR__c = cs.Id;
				op.SEG_Usuario__c = UserInfo.getUserId();
				caseOperaciones.get(cs.Id).add(op);

			}
			else if (cs.Subject == 'test 2') {
				op = new SEG_Operacion__c();
				op.RecordTypeId = recordTypeCSO;
				op.SEG_N_Operaciones__c = 8;
				op.SEG_SR__c = cs.Id;
				op.SEG_Usuario__c = u.Id;
				caseOperaciones.put(cs.Id, new List<SEG_Operacion__c> { op });
			}
			else {
				op = new SEG_Operacion__c();
				op.RecordTypeId = recordTypeCSO;
				op.SEG_N_Operaciones__c = 8;
				op.SEG_SR__c = cs.Id;
				op.SEG_Usuario__c = u.Id;
				caseOperaciones.put(cs.Id, new List<SEG_Operacion__c> { op });
			}
		}
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {

			Test.startTest();
			List<Id> lstCases = new List<Id> (caseOperaciones.keySet());
			SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(lstCases, SEG_FotoFacturacionHandler.Operativa.MCC, caseOperaciones, detalle.id, prodServ.id, motivo.id, tematica.id);
			System.enqueueJob(ffHandler);
			Test.stopTest();
			List<SEG_Fotosdefacturacion__c> lstFF = [Select Id, SEG_Estado__c, SEG_GrupoCSO__c, SEG_IDServicio__c, SEG_Marcadelcaso__c, SEG_Operativa__c,
													SEG_NumerooperacionesCSO__c, SEG_Valor__c, SEG_Usuariogenerador__c, SEG_NumeroSR__c, SEG_NumeroSR__r.Subject
													From SEG_Fotosdefacturacion__c];
			System.assertEquals(4, lstFF.size());
			for (SEG_Fotosdefacturacion__c ff : lstFF) {
				System.assertEquals('MCC', ff.SEG_Operativa__c);
				if (ff.SEG_NumeroSR__r.Subject == 'test 1') {
					System.assertEquals(UserInfo.getUserId(), ff.SEG_Usuariogenerador__c);
					System.assertEquals('Vigente', ff.SEG_Estado__c);
				} else if (ff.SEG_NumeroSR__r.Subject == 'test 2') {
					System.assertEquals(u.Id, ff.SEG_Usuariogenerador__c);
					System.assertEquals('Revisar', ff.SEG_Estado__c);
				} else {
					System.assertEquals(u.Id, ff.SEG_Usuariogenerador__c);
					System.assertEquals('A determinar', ff.SEG_Estado__c);
					System.assert(ff.SEG_IDServicio__c == null);
				}
			}
		}
	}

	@isTest
	private static void testChangeOwner() {
		User supervisor = SEG_Usuarios.usuarioSupervisor();

		User u = [Select Id FROM User WHERE Alias = 'groupcso' LIMIT 1];
		User u2 = [Select Id FROM User WHERE Alias = 'stand34' LIMIT 1];
		User u3 = [Select Id FROM User WHERE Alias = 'activegr' LIMIT 1];

		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			Test.startTest();
			List<Case> lstcaseUpd = new List<Case> ();
			List<Id> lstcaseId = new List<Id> ();
			for (Case cs :[Select Id, Subject From Case]) {
				lstcaseId.add(cs.Id);
				if (cs.Subject == 'test 1') {
					cs.OwnerId = u3.Id;
					lstcaseUpd.add(cs);
				}
				else if (cs.Subject == 'test 2') {
					cs.OwnerId = u2.Id;
					lstcaseUpd.add(cs);
				}
				else {
					cs.OwnerId = u.Id;
					lstcaseUpd.add(cs);
				}
			}
			update lstcaseUpd;

			//SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(lstcaseId, SEG_FotoFacturacionHandler.Operativa.Grupo);
			//System.enqueueJob(ffHandler);
			Test.stopTest();
			List<SEG_Fotosdefacturacion__c> lstFF = [Select Id, SEG_Estado__c, SEG_GrupoCSO__c, SEG_IDServicio__c, SEG_Marcadelcaso__c, SEG_Operativa__c,
													SEG_NumerooperacionesCSO__c, SEG_Valor__c, SEG_Usuariogenerador__c, SEG_NumeroSR__c, SEG_NumeroSR__r.Subject
													From SEG_Fotosdefacturacion__c];
			System.debug(lstFF);

			System.assertEquals(2, lstFF.size());
			for (SEG_Fotosdefacturacion__c ff : lstFF) {
				System.assertEquals('Grupo', ff.SEG_Operativa__c);
				if (ff.SEG_NumeroSR__r.Subject == 'test 1') {
					System.assertEquals(u3.Id, ff.SEG_Usuariogenerador__c);
					System.assertEquals('Vigente', ff.SEG_Estado__c);
					System.assert(ff.SEG_IDServicio__c != null);
				} else if (ff.SEG_NumeroSR__r.Subject == 'test 3') {
					System.assertEquals(u.Id, ff.SEG_Usuariogenerador__c);
					System.assertEquals('A determinar', ff.SEG_Estado__c);
					System.assert(ff.SEG_IDServicio__c == null);
				}
			}
		}
	}
	@isTest
	private static void testAddMarcas() {
		User supervisor = SEG_Usuarios.usuarioSupervisor();

		List<SEG_Operacion__c> lstOp = new List<SEG_Operacion__c> ();
		SEG_Operacion__c op = new SEG_Operacion__c();
		Map<Id, List<SEG_Operacion__c>> caseOperaciones = new Map<Id, List<SEG_Operacion__c>> ();
		User u = [Select Id FROM User WHERE Alias = 'groupcso' LIMIT 1];
		List<CC_Caracteristica__c> lstcar = [SELECT Id FROM CC_Caracteristica__c];

		Id recordTypeCSO = Schema.SObjectType.SEG_Operacion__c.getRecordTypeInfosByDeveloperName().get('CSO').getRecordTypeId();
		Map<Id, List<SEG_Marcasdeuncaso__c>> caseMarcaCase = new Map<Id, List<SEG_Marcasdeuncaso__c>> ();
		SEG_Marcasdeuncaso__c marcaCase;

		for (Case cs :[SELECT Id,Subject FROM Case]) {
			for(CC_Caracteristica__c car: lstcar){
				if (cs.Subject == 'test 1' || cs.Subject == 'test 2') {
					marcaCase = new SEG_Marcasdeuncaso__c();
					marcaCase.SEG_Caso__c = cs.Id;
					marcaCase.SEG_Caracteristica__c = car.Id;
					marcaCase.SEG_Usuario__c = UserInfo.getUserId();
					if (caseMarcaCase.containsKey(cs.Id)) {
						caseMarcaCase.get(cs.Id).add(marcaCase);
					} else {
						caseMarcaCase.put(cs.Id, new List<SEG_Marcasdeuncaso__c> { marcaCase });
					}

				}
				else {
					marcaCase = new SEG_Marcasdeuncaso__c();
					marcaCase.SEG_Caso__c = cs.Id;
					marcaCase.SEG_Caracteristica__c = car.Id;
					marcaCase.SEG_Usuario__c = u.Id;
					if (caseMarcaCase.containsKey(cs.Id)) {
						caseMarcaCase.get(cs.Id).add(marcaCase);
					} else {
						caseMarcaCase.put(cs.Id, new List<SEG_Marcasdeuncaso__c> { marcaCase });
					}
				}
			}
		}

		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			Test.startTest();
			List<Id> lstCases = new List<Id> (caseMarcaCase.keySet());
			SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(lstCases, SEG_FotoFacturacionHandler.Operativa.Marca, caseMarcaCase);
			System.enqueueJob(ffHandler);
			Test.stopTest();
			List<SEG_Fotosdefacturacion__c> lstFF = [Select Id, SEG_Estado__c, SEG_GrupoCSO__c, SEG_IDServicio__c, SEG_Marcadelcaso__c, SEG_Operativa__c,
													SEG_NumerooperacionesCSO__c, SEG_Valor__c, SEG_Usuariogenerador__c, SEG_NumeroSR__c, SEG_NumeroSR__r.Subject
													From SEG_Fotosdefacturacion__c];

			for (SEG_Fotosdefacturacion__c ff : lstFF) {
				System.assertEquals('Marca', ff.SEG_Operativa__c);
				if (ff.SEG_NumeroSR__r.Subject == 'test 1' || ff.SEG_NumeroSR__r.Subject == 'test 2') {
					System.assertEquals(UserInfo.getUserId(), ff.SEG_Usuariogenerador__c);
				} else {
					System.assertEquals(u.Id, ff.SEG_Usuariogenerador__c);
					System.assertEquals('A determinar', ff.SEG_Estado__c);
					System.assert(ff.SEG_IDServicio__c == null);
				}
			}
		}
	}

	@isTest
	private static void testUpdateFotosMCC() {
		User supervisor = SEG_Usuarios.usuarioSupervisor();

		User u = [Select Id FROM User WHERE Alias = 'groupcso' LIMIT 1];
		User u2 = [Select Id FROM User WHERE Alias = 'stand34' LIMIT 1];
		List<SEG_Fotosdefacturacion__c> lstFF = new List<SEG_Fotosdefacturacion__c> ();
		Case cs1 = [Select Id From Case Where Subject = 'test 1'];
		Case cs2 = [Select Id From Case Where Subject = 'test 2'];
		SEG_ServiciosCSO__c srv = [Select Id From SEG_ServiciosCSO__c Where Name = 'Test MCC'];
		SEG_GruposCSO__c grupoCSO = [Select Id From SEG_GruposCSO__c WHERE Name = 'Grupo Test' Limit 1];

		//Grupo Activo pero usuario inactivo
		SEG_Fotosdefacturacion__c ff1 = new SEG_Fotosdefacturacion__c();
		ff1.SEG_Estado__c = 'A determinar';
		ff1.SEG_GrupoCSO__c = grupoCSO.Id;
		ff1.SEG_Operativa__c = 'MCC';
		ff1.SEG_Valor__c = 1;
		ff1.SEG_Usuariogenerador__c = u.Id;
		ff1.SEG_NumeroSR__c = cs1.Id;
		ff1.SEG_NumerooperacionesCSO__c = 6;
		lstFF.add(ff1);
		SEG_Fotosdefacturacion__c ff2 = new SEG_Fotosdefacturacion__c();
		ff2.SEG_Estado__c = 'Revisar';
		ff2.SEG_GrupoCSO__c = grupoCSO.Id;
		ff2.SEG_Operativa__c = 'MCC';
		ff2.SEG_Valor__c = 1;
		ff2.SEG_Usuariogenerador__c = UserInfo.getUserId();
		ff2.SEG_NumeroSR__c = cs1.Id;
		ff2.SEG_NumerooperacionesCSO__c = 6;
		lstFF.add(ff2);
		SEG_Fotosdefacturacion__c ff3 = new SEG_Fotosdefacturacion__c();
		ff3.SEG_Estado__c = 'Revisar';
		ff3.SEG_GrupoCSO__c = grupoCSO.Id;
		ff3.SEG_Operativa__c = 'MCC';
		ff3.SEG_Valor__c = 1;
		ff3.SEG_Usuariogenerador__c = UserInfo.getUserId();
		ff3.SEG_NumeroSR__c = cs1.Id;
		ff3.SEG_NumerooperacionesCSO__c = 6;
		ff3.SEG_IDServicio__c = srv.Id;
		lstFF.add(ff3);
		SEG_Fotosdefacturacion__c ff4 = new SEG_Fotosdefacturacion__c();
		ff4.SEG_Estado__c = 'Revisar';
		ff4.SEG_GrupoCSO__c = grupoCSO.Id;
		ff4.SEG_Operativa__c = 'MCC';
		ff4.SEG_Valor__c = 1;
		ff4.SEG_Usuariogenerador__c = u2.Id;
		ff4.SEG_NumeroSR__c = cs1.Id;
		ff4.SEG_NumerooperacionesCSO__c = 6;
		lstFF.add(ff4);
		insert lstFF;
		Map<Id, SEG_Fotosdefacturacion__c> mapFFInserted = new Map<Id, SEG_Fotosdefacturacion__c> ([Select Id From SEG_Fotosdefacturacion__c]);
		List<Id> lstFFIds = new List<Id> (mapFFInserted.keySet());

		System.runAs ( supervisor ) {
			Test.startTest();
			SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(SEG_FotoFacturacionHandler.Operativa.MCC, lstFFIds);
			System.enqueueJob(ffHandler);
			Test.stopTest();
			List<SEG_Fotosdefacturacion__c> lstFFUpd = [Select Id, SEG_Estado__c, SEG_GrupoCSO__c, SEG_IDServicio__c, SEG_Marcadelcaso__c, SEG_Operativa__c, SEG_Descripcion__c,
														SEG_NumerooperacionesCSO__c, SEG_Valor__c, SEG_Usuariogenerador__c, SEG_NumeroSR__c, SEG_NumeroSR__r.Subject
														From SEG_Fotosdefacturacion__c];
			for (SEG_Fotosdefacturacion__c ffUpd : lstFFUpd) {
				if (ffUpd.Id == ff1.Id) {
					System.assertEquals('Ignorar', ffUpd.SEG_Estado__c);
				} else if (ffUpd.Id == ff2.Id) {
					System.assertEquals('Ignorar', ffUpd.SEG_Estado__c);
				} else if (ffUpd.Id == ff3.Id) {
					System.assertEquals('Vigente', ffUpd.SEG_Estado__c);
					System.assert(ffUpd.SEG_IDServicio__c != null);
				} else if (ffUpd.Id == ff4.Id) {
					System.assertEquals('Ignorar', ffUpd.SEG_Estado__c);
					System.assert(ffUpd.SEG_IDServicio__c == null);
				}
			}
		}
	}

	@isTest
	private static void testUpdateFotosMarca() {
		User supervisor = SEG_Usuarios.usuarioSupervisor();

		User u = [Select Id FROM User WHERE Alias = 'groupcso' LIMIT 1];
		User u2 = [Select Id FROM User WHERE Alias = 'stand34' LIMIT 1];
		List<SEG_Fotosdefacturacion__c> lstFF = new List<SEG_Fotosdefacturacion__c> ();
		Case cs1 = [Select Id From Case Where Subject = 'test 1'];
		Case cs2 = [Select Id From Case Where Subject = 'test 2'];
		CC_Caracteristica__c car1 = [Select Id From CC_Caracteristica__c Where Name = 'TestCaracteristica1'];
		CC_Caracteristica__c car2 = [Select Id From CC_Caracteristica__c Where Name = 'TestCaracteristica2'];
		SEG_ServiciosCSO__c srv = [Select Id From SEG_ServiciosCSO__c Where Name = 'Test Marca'];
		SEG_GruposCSO__c grupoCSO = [Select Id From SEG_GruposCSO__c WHERE Name = 'Grupo Test' Limit 1];

		//Grupo Activo pero usuario inactivo
		SEG_Fotosdefacturacion__c ff1 = new SEG_Fotosdefacturacion__c();
		ff1.SEG_Estado__c = 'A determinar';
		ff1.SEG_GrupoCSO__c = grupoCSO.Id;
		ff1.SEG_Operativa__c = 'Marca';
		ff1.SEG_Valor__c = 1;
		ff1.SEG_Usuariogenerador__c = u.Id;
		ff1.SEG_NumeroSR__c = cs1.Id;
		ff1.SEG_Marcadelcaso__c = car1.Id;
		lstFF.add(ff1);
		SEG_Fotosdefacturacion__c ff2 = new SEG_Fotosdefacturacion__c();
		ff2.SEG_Estado__c = 'Revisar';
		ff2.SEG_GrupoCSO__c = grupoCSO.Id;
		ff2.SEG_Operativa__c = 'Marca';
		ff2.SEG_Valor__c = 1;
		ff2.SEG_Usuariogenerador__c = UserInfo.getUserId();
		ff2.SEG_NumeroSR__c = cs1.Id;
		ff2.SEG_Marcadelcaso__c = car2.Id;
		lstFF.add(ff2);
		SEG_Fotosdefacturacion__c ff3 = new SEG_Fotosdefacturacion__c();
		ff3.SEG_Estado__c = 'Revisar';
		ff3.SEG_GrupoCSO__c = grupoCSO.Id;
		ff3.SEG_Operativa__c = 'Marca';
		ff3.SEG_Valor__c = 1;
		ff3.SEG_Usuariogenerador__c = UserInfo.getUserId();
		ff3.SEG_NumeroSR__c = cs1.Id;
		ff3.SEG_IDServicio__c = srv.Id;
		ff3.SEG_Marcadelcaso__c = car2.Id;
		lstFF.add(ff3);
		SEG_Fotosdefacturacion__c ff4 = new SEG_Fotosdefacturacion__c();
		ff4.SEG_Estado__c = 'Revisar';
		ff4.SEG_GrupoCSO__c = grupoCSO.Id;
		ff4.SEG_Operativa__c = 'Marca';
		ff4.SEG_Valor__c = 1;
		ff4.SEG_Usuariogenerador__c = u2.Id;
		ff4.SEG_NumeroSR__c = cs1.Id;
		ff4.SEG_Marcadelcaso__c = car2.Id;
		lstFF.add(ff4);

		insert lstFF;
		Map<Id, SEG_Fotosdefacturacion__c> mapFFInserted = new Map<Id, SEG_Fotosdefacturacion__c> ([Select Id From SEG_Fotosdefacturacion__c]);
		List<Id> lstFFIds = new List<Id> (mapFFInserted.keySet());

		System.runAs ( supervisor) {

			Test.startTest();
			SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(SEG_FotoFacturacionHandler.Operativa.Marca, lstFFIds);
			System.enqueueJob(ffHandler);
			Test.stopTest();
			List<SEG_Fotosdefacturacion__c> lstFFUpd = [Select Id, SEG_Estado__c, SEG_GrupoCSO__c, SEG_IDServicio__c, SEG_Marcadelcaso__c, SEG_Operativa__c, SEG_Descripcion__c,
														SEG_NumerooperacionesCSO__c, SEG_Valor__c, SEG_Usuariogenerador__c, SEG_NumeroSR__c, SEG_NumeroSR__r.Subject
														From SEG_Fotosdefacturacion__c];
			for (SEG_Fotosdefacturacion__c ffUpd : lstFFUpd) {
				if (ffUpd.Id == ff1.Id) {
					System.assertEquals('Ignorar', ffUpd.SEG_Estado__c);
					System.assert(ffUpd.SEG_IDServicio__c != null);
				} else if (ffUpd.Id == ff2.Id) {
					System.assertEquals('Vigente', ffUpd.SEG_Estado__c);
					System.assert(ffUpd.SEG_IDServicio__c != null);
				} else if (ffUpd.Id == ff3.Id) {
					System.assertEquals('Vigente', ffUpd.SEG_Estado__c);
					System.assert(ffUpd.SEG_IDServicio__c != null);
				} else if (ffUpd.Id == ff4.Id) {
					System.assertEquals('Ignorar', ffUpd.SEG_Estado__c);
					System.assert(ffUpd.SEG_IDServicio__c == null);
				}
			}
		}
	}

	@isTest
	private static void testUpdateFotosGrupo() {
		User supervisor = SEG_Usuarios.usuarioSupervisor();

		User u = [Select Id FROM User WHERE Alias = 'groupcso' LIMIT 1];
		User u2 = [Select Id FROM User WHERE Alias = 'stand34' LIMIT 1];
		List<SEG_Fotosdefacturacion__c> lstFF = new List<SEG_Fotosdefacturacion__c> ();
		Case cs1 = [Select Id From Case Where Subject = 'test 1'];
		Case cs2 = [Select Id From Case Where Subject = 'test 2'];
		SEG_ServiciosCSO__c srv = [Select Id From SEG_ServiciosCSO__c Where Name = 'Test Grupo'];
		SEG_GruposCSO__c grupoCSO = [Select Id From SEG_GruposCSO__c WHERE Name = 'Grupo Test' Limit 1];

		//Grupo Activo pero usuario inactivo
		SEG_Fotosdefacturacion__c ff1 = new SEG_Fotosdefacturacion__c();
		ff1.SEG_Estado__c = 'A determinar';
		ff1.SEG_GrupoCSO__c = grupoCSO.Id;
		ff1.SEG_Operativa__c = 'Grupo';
		ff1.SEG_Valor__c = 1;
		ff1.SEG_Usuariogenerador__c = u.Id;
		ff1.SEG_NumeroSR__c = cs1.Id;
		lstFF.add(ff1);
		SEG_Fotosdefacturacion__c ff2 = new SEG_Fotosdefacturacion__c();
		ff2.SEG_Estado__c = 'Revisar';
		ff2.SEG_GrupoCSO__c = grupoCSO.Id;
		ff2.SEG_Operativa__c = 'Grupo';
		ff2.SEG_Valor__c = 1;
		ff2.SEG_Usuariogenerador__c = UserInfo.getUserId();
		ff2.SEG_NumeroSR__c = cs1.Id;
		lstFF.add(ff2);
		SEG_Fotosdefacturacion__c ff3 = new SEG_Fotosdefacturacion__c();
		ff3.SEG_Estado__c = 'Revisar';
		ff3.SEG_GrupoCSO__c = grupoCSO.Id;
		ff3.SEG_Operativa__c = 'Grupo';
		ff3.SEG_Valor__c = 1;
		ff3.SEG_Usuariogenerador__c = UserInfo.getUserId();
		ff3.SEG_NumeroSR__c = cs1.Id;
		ff3.SEG_IDServicio__c = srv.Id;
		lstFF.add(ff3);
		SEG_Fotosdefacturacion__c ff4 = new SEG_Fotosdefacturacion__c();
		ff4.SEG_Estado__c = 'Revisar';
		ff4.SEG_GrupoCSO__c = grupoCSO.Id;
		ff4.SEG_Operativa__c = 'Grupo';
		ff4.SEG_Valor__c = 1;
		ff4.SEG_Usuariogenerador__c = u2.Id;
		ff4.SEG_NumeroSR__c = cs1.Id;
		lstFF.add(ff4);
		insert lstFF;
		Map<Id, SEG_Fotosdefacturacion__c> mapFFInserted = new Map<Id, SEG_Fotosdefacturacion__c> ([Select Id From SEG_Fotosdefacturacion__c]);
		List<Id> lstFFIds = new List<Id> (mapFFInserted.keySet());

		System.runAs ( supervisor) {
			Test.startTest();
			SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(SEG_FotoFacturacionHandler.Operativa.Grupo, lstFFIds);
			System.enqueueJob(ffHandler);
			Test.stopTest();
			List<SEG_Fotosdefacturacion__c> lstFFUpd = [Select Id, SEG_Estado__c, SEG_GrupoCSO__c, SEG_IDServicio__c, SEG_Marcadelcaso__c, SEG_Operativa__c, SEG_Descripcion__c,
														SEG_NumerooperacionesCSO__c, SEG_Valor__c, SEG_Usuariogenerador__c, SEG_NumeroSR__c, SEG_NumeroSR__r.Subject
														From SEG_Fotosdefacturacion__c];
			for (SEG_Fotosdefacturacion__c ffUpd : lstFFUpd) {
				if (ffUpd.Id == ff1.Id) {
					System.assertEquals('Ignorar', ffUpd.SEG_Estado__c);
					System.assert(ffUpd.SEG_IDServicio__c != null);
				} else if (ffUpd.Id == ff2.Id) {
					System.assertEquals('Vigente', ffUpd.SEG_Estado__c);
					System.assert(ffUpd.SEG_IDServicio__c != null);
				} else if (ffUpd.Id == ff3.Id) {
					System.assertEquals('Vigente', ffUpd.SEG_Estado__c);
					System.assert(ffUpd.SEG_IDServicio__c != null);
				} else if (ffUpd.Id == ff4.Id) {
					System.assertEquals('Ignorar', ffUpd.SEG_Estado__c);
					System.assert(ffUpd.SEG_IDServicio__c == null);
				}
			}
		}
	}
}