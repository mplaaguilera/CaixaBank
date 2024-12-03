@isTest
public class SEG_FotoFacturacion_Batch_Test {
	@testSetup
	static void datosIniciales()
	{
		List<User> lstUser = new List<User> ();
		String today = Date.today().format();
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
		User u = new User(Alias = 'groupcso', Email = 'standarduser@testorg.com',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduser@testorg' + today + '.com');
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
		grupoOpSeg.SEG_GrupoSegmentos__c = true;
		grupoOpSeg.Name = 'Grupo de trabajo Operativo';
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
		mccDetalle.CC_Producto_Servicio__c = mccMotivo.Id;
		insert mccDetalle;


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
		caso1.Status = 'Cerrado';
		caso1.SEG_Organizacion__c = 'Banca Corporativa';
		caso1.SEG_Zona__c = 'Corporativa';
		caso1.CC_MCC_Tematica__c = mccTematica.Id;
		caso1.CC_MCC_ProdServ__c = mccProdServ.Id;
		caso1.CC_MCC_Motivo__c = mccMotivo.Id;
		caso1.SEG_Grupo__c = grupoOpSeg.Id;
		listadoCasos.add(caso1);

		Case caso2 = new Case();
		caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		caso2.AccountId = cuentaSEG1.Id;
		caso2.ContactId = contactoSEG1.Id;
		caso2.CC_MailTelfNotif__c = contactoSEG1.Email;
		caso2.SEG_Idioma__c = 'es';
		caso2.CC_AcuseRecibo__c = '1';
		caso2.Status = 'Cerrado';
		caso2.Subject = 'test 2';
		caso2.SEG_Organizacion__c = 'Banca Corporativa';
		caso2.SEG_Zona__c = 'Corporativa';
		caso2.CC_MCC_Tematica__c = mccTematica.Id;
		caso2.CC_MCC_ProdServ__c = mccProdServ.Id;
		caso2.CC_MCC_Motivo__c = mccMotivo2.Id;
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
		servMcc.SEG_ServiciosCSO__c = servCsoMCC.Id;
		insert servMcc;

		SEG_MCCServiciosCSO__c servMcc2 = new SEG_MCCServiciosCSO__c();
		servMcc2.SEG_Activo__c = false;
		servMcc2.SEG_Tematica__c = mccTematica.Id;
		servMcc2.SEG_Producto__c = mccProdServ.Id;
		servMcc2.SEG_Motivo__c = mccMotivo2.Id;
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
	private static void testEnviarFF() {
		String userId = UserInfo.getUserId();
		List<SEG_Fotosdefacturacion__c> lstFF = new List<SEG_Fotosdefacturacion__c> ();
		Case cs1 = [Select Id From Case Where Subject = 'test 1'];
		Case cs2 = [Select Id From Case Where Subject = 'test 2'];
		Case cs3 = [Select Id From Case Where Subject = 'test 3'];
		CC_Caracteristica__c car1 = [Select Id From CC_Caracteristica__c Where Name = 'TestCaracteristica1'];
		CC_Caracteristica__c car2 = [Select Id From CC_Caracteristica__c Where Name = 'TestCaracteristica2'];
		SEG_ServiciosCSO__c srvMCC = [Select Id From SEG_ServiciosCSO__c Where Name = 'Test MCC'];
		SEG_ServiciosCSO__c srvMarca = [Select Id From SEG_ServiciosCSO__c Where Name = 'Test Marca'];
		SEG_ServiciosCSO__c srvGrupo = [Select Id From SEG_ServiciosCSO__c Where Name = 'Test Grupo'];
		SEG_GruposCSO__c grupoCSO = [Select Id From SEG_GruposCSO__c WHERE Name = 'Grupo Test' Limit 1];

		//Grupo Activo pero usuario inactivo
		SEG_Fotosdefacturacion__c ff1 = new SEG_Fotosdefacturacion__c();
		ff1.SEG_Estado__c = 'A determinar';
		ff1.SEG_GrupoCSO__c = grupoCSO.Id;
		ff1.SEG_Operativa__c = 'MCC';
		ff1.SEG_Valor__c = 1;
		ff1.SEG_Usuariogenerador__c = userId;
		ff1.SEG_NumeroSR__c = cs1.Id;
		ff1.SEG_NumerooperacionesCSO__c = 6;
		lstFF.add(ff1);
		SEG_Fotosdefacturacion__c ff2 = new SEG_Fotosdefacturacion__c();
		ff2.SEG_Estado__c = 'Vigente';
		ff2.SEG_GrupoCSO__c = grupoCSO.Id;
		ff2.SEG_Operativa__c = 'MCC';
		ff2.SEG_Valor__c = 1;
		ff2.SEG_Usuariogenerador__c = userId;
		ff2.SEG_NumeroSR__c = cs1.Id;
		ff2.SEG_IDServicio__c = srvMCC.Id;
		ff2.SEG_NumerooperacionesCSO__c = 6;
		lstFF.add(ff2);
		SEG_Fotosdefacturacion__c ff3 = new SEG_Fotosdefacturacion__c();
		ff3.SEG_Estado__c = 'Vigente';
		ff3.SEG_GrupoCSO__c = grupoCSO.Id;
		ff3.SEG_Operativa__c = 'MCC';
		ff3.SEG_Valor__c = 1;
		ff3.SEG_Usuariogenerador__c = userId;
		ff3.SEG_NumeroSR__c = cs3.Id;
		ff3.SEG_NumerooperacionesCSO__c = 6;
		ff3.SEG_IDServicio__c = srvMCC.Id;
		lstFF.add(ff3);
		SEG_Fotosdefacturacion__c ff4 = new SEG_Fotosdefacturacion__c();
		ff4.SEG_Estado__c = 'Vigente';
		ff4.SEG_GrupoCSO__c = grupoCSO.Id;
		ff4.SEG_Operativa__c = 'Grupo';
		ff4.SEG_Valor__c = 1;
		ff4.SEG_Usuariogenerador__c = userId;
		ff4.SEG_NumeroSR__c = cs1.Id;
		ff4.SEG_IDServicio__c = srvGrupo.Id;
		lstFF.add(ff4);
		SEG_Fotosdefacturacion__c ff5 = new SEG_Fotosdefacturacion__c();
		ff5.SEG_Estado__c = 'Cerrado';
		ff5.SEG_GrupoCSO__c = grupoCSO.Id;
		ff5.SEG_Operativa__c = 'Grupo';
		ff5.SEG_Valor__c = 1;
		ff5.SEG_Usuariogenerador__c = userId;
		ff5.SEG_NumeroSR__c = cs1.Id;
		ff5.SEG_IDServicio__c = srvGrupo.Id;
		lstFF.add(ff5);
		SEG_Fotosdefacturacion__c ff6 = new SEG_Fotosdefacturacion__c();
		ff6.SEG_Estado__c = 'Cerrado';
		ff6.SEG_GrupoCSO__c = grupoCSO.Id;
		ff6.SEG_Operativa__c = 'Grupo';
		ff6.SEG_Valor__c = 1;
		ff6.SEG_Usuariogenerador__c = userId;
		ff6.SEG_NumeroSR__c = cs1.Id;
		ff6.SEG_IDServicio__c = srvGrupo.Id;
		lstFF.add(ff6);
		SEG_Fotosdefacturacion__c ff7 = new SEG_Fotosdefacturacion__c();
		ff7.SEG_Estado__c = 'Vigente';
		ff7.SEG_GrupoCSO__c = grupoCSO.Id;
		ff7.SEG_Operativa__c = 'Marca';
		ff7.SEG_Valor__c = 1;
		ff7.SEG_Usuariogenerador__c = userId;
		ff7.SEG_NumeroSR__c = cs1.Id;
		ff7.SEG_Marcadelcaso__c = car1.Id;
		lstFF.add(ff7);
		SEG_Fotosdefacturacion__c ff8 = new SEG_Fotosdefacturacion__c();
		ff8.SEG_Estado__c = 'Vigente';
		ff8.SEG_GrupoCSO__c = grupoCSO.Id;
		ff8.SEG_Operativa__c = 'Marca';
		ff8.SEG_Valor__c = 1;
		ff8.SEG_Usuariogenerador__c = userId;
		ff8.SEG_NumeroSR__c = cs3.Id;
		ff8.SEG_Marcadelcaso__c = car2.Id;
		lstFF.add(ff8);
		insert lstFF;

		Test.startTest();
		SEG_FotoFacturacion_Batch myClass = new SEG_FotoFacturacion_Batch();
		String chron = '0 0 0 1 1 ? 2025';
		String jobId = system.schedule('Test Sched', chron, myClass);
		Id batchId = Database.executeBatch(myClass);
		CronTrigger ct = [select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
		System.assertEquals(chron, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2025-01-01 00:00:00', String.valueOf(ct.NextFireTime));
		Test.stopTest();

		//Test.startTest();
		//SEG_FotoFacturacion_Batch batch = new SEG_FotoFacturacion_Batch();
		//Id batchId = Database.executeBatch(batch);
		//Test.stopTest();

		List<SEG_Fotosdefacturacion__c> lstFFUpd = [Select Id, SEG_Estado__c, SEG_GrupoCSO__c, SEG_IDServicio__c, SEG_Marcadelcaso__c, SEG_Operativa__c, SEG_Descripcion__c,
		                                            SEG_NumerooperacionesCSO__c, SEG_Valor__c, SEG_Usuariogenerador__c, SEG_NumeroSR__c, SEG_NumeroSR__r.Subject,SEG_FechaCierre__c
		                                            From SEG_Fotosdefacturacion__c];

		for (SEG_Fotosdefacturacion__c ff : lstFFUpd) {
			if (ff.Id == ff1.Id) {
				System.assertEquals('A determinar', ff.SEG_Estado__c);
			} else if (ff.Id == ff2.Id) {
				System.assertEquals('Cerrado', ff.SEG_Estado__c);
				System.assert(ff.SEG_FechaCierre__c != null);
			} else if (ff.Id == ff3.Id) {
				System.assertEquals('Vigente', ff.SEG_Estado__c);
			} else if (ff.Id == ff4.Id) {
				System.assertEquals('Cerrado', ff.SEG_Estado__c);
				System.assert(ff.SEG_FechaCierre__c != null);
			} else if (ff.Id == ff5.Id) {
				System.assertEquals('Cerrado', ff.SEG_Estado__c);
			} else if (ff.Id == ff6.Id) {
				System.assertEquals('Cerrado', ff.SEG_Estado__c);
			} else if (ff.Id == ff7.Id) {
				System.assertEquals('Cerrado', ff.SEG_Estado__c);
				System.assert(ff.SEG_FechaCierre__c != null);
			} else if (ff.Id == ff8.Id) {
				System.assertEquals('Vigente', ff.SEG_Estado__c);
			}
		}
	}

}