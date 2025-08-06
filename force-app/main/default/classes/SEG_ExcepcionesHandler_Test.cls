@IsTest
public class SEG_ExcepcionesHandler_Test extends SEG_Usuarios{
	//User operativo = SEG_Usuarios.usuarioOperativo();
	//User supervisor = SEG_Usuarios.usuarioSupervisor();
	@TestSetup
	public static void crearDatosPrueba()
	{
		User supervisor = SEG_Usuarios.usuarioSupervisor();

		Id opSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
		Id autoSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
		List<CC_Grupo_Colaborador__c> lstGrupoColaborador = new List<CC_Grupo_Colaborador__c> ();

		//Gestor Operativa Nacional
		CC_Grupo_Colaborador__c grupoGestorOperativaNacional = new CC_Grupo_Colaborador__c();
		grupoGestorOperativaNacional.Name = 'Gestor Operativa Nacional';
		grupoGestorOperativaNacional.RecordTypeId = autoSegId;
		lstGrupoColaborador.add(grupoGestorOperativaNacional);

		//Gestor Operativa Internacional
		CC_Grupo_Colaborador__c grupoGestorOperativaInternacional = new CC_Grupo_Colaborador__c();
		grupoGestorOperativaInternacional.Name = 'Gestor Operativa Internacional';
		grupoGestorOperativaInternacional.RecordTypeId = autoSegId;
		lstGrupoColaborador.add(grupoGestorOperativaInternacional);
		insert lstGrupoColaborador;

		Id recordAsig = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Asignacion').getRecordTypeId();
		Id recordTexto = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Texto').getRecordTypeId();
		Id recordContrato = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Contratos').getRecordTypeId();

		List<SEG_Excepciones__c> lstEx = new List<SEG_Excepciones__c>();
		SEG_Excepciones__c excepcion = new SEG_Excepciones__c();
		excepcion.RecordTypeId = recordAsig;
		excepcion.SEG_FechaActivacion__c  = Date.today().addDays(-2);
		excepcion.SEG_Organizacion__c = 'Banca Corporativa';
		excepcion.SEG_Zona__c = 'Corporativa';
		excepcion.SEG_Grupoasignado__c = grupoGestorOperativaInternacional.Id;
		lstEx.add(excepcion);

		SEG_Excepciones__c excepcion2 = new SEG_Excepciones__c();
		excepcion2.RecordTypeId = recordAsig;
		excepcion2.SEG_FechaActivacion__c  = Date.today().addDays(-2);
		excepcion2.SEG_Organizacion__c = 'Banca Corporativa';
		excepcion2.SEG_Zona__c = 'Corporativa';
		excepcion2.SEG_Grupoasignado__c = grupoGestorOperativaNacional.Id;
		lstEx.add(excepcion2);

		SEG_Excepciones__c excepcion3 = new SEG_Excepciones__c();
		excepcion3.RecordTypeId = recordTexto;
		excepcion3.SEG_FechaActivacion__c  = Date.today().addDays(-2);
		excepcion3.SEG_Organizacion__c = 'Banca Corporativa';
		excepcion3.SEG_Zona__c = 'Corporativa';
		excepcion3.SEG_Grupoasignado__c = grupoGestorOperativaNacional.Id;
		lstEx.add(excepcion3);

		SEG_Excepciones__c excepcion4 = new SEG_Excepciones__c();
		excepcion4.RecordTypeId = recordTexto;
		excepcion4.SEG_FechaActivacion__c  = Date.today().addDays(-2);
		excepcion4.SEG_Organizacion__c = 'Banca Corporativa';
		excepcion4.SEG_Zona__c = 'Corporativa';
		excepcion4.SEG_Grupoasignado__c = grupoGestorOperativaNacional.Id;
		lstEx.add(excepcion4);

		SEG_Excepciones__c excepcion5 = new SEG_Excepciones__c();
		excepcion5.RecordTypeId = recordAsig;
		excepcion5.SEG_FechaActivacion__c  = Date.today().addDays(-2);
		excepcion5.SEG_Organizacion__c = 'Banca Corporativa';
		excepcion5.SEG_Zona__c = 'Corporativa';
		excepcion5.SEG_Grupoasignado__c = grupoGestorOperativaNacional.Id;
		lstEx.add(excepcion5);

		SEG_Excepciones__c excepcion6 = new SEG_Excepciones__c();
		excepcion6.RecordTypeId = recordAsig;
		excepcion6.SEG_FechaActivacion__c  = Date.today().addDays(-2);
		excepcion6.SEG_Organizacion__c = 'Banca Corporativa';
		excepcion6.SEG_Zona__c = 'Corporativa';
		excepcion6.SEG_Grupoasignado__c = grupoGestorOperativaNacional.Id;
		lstEx.add(excepcion6);

		SEG_Excepciones__c excepcion7 = new SEG_Excepciones__c();
		excepcion6.RecordTypeId = recordContrato;
		excepcion6.SEG_FechaActivacion__c  = Date.today().addDays(-2);
		excepcion6.SEG_Organizacion__c = 'Banca Corporativa';
		excepcion6.SEG_Zona__c = 'Corporativa';
		excepcion6.SEG_Grupoasignado__c = grupoGestorOperativaNacional.Id;
		lstEx.add(excepcion7);

		insert lstEx;

		Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
		CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
		mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
		mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
		mccTematica.RecordTypeId = recordTypeIdTematica;
		mccTematica.CC_Codigo_Externo__c = 'TE-000001';
		insert mccTematica;

		Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
		CC_MCC__c mccProducto = new CC_MCC__c();
		mccProducto.Name = 'Producto1';
		mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
		mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
		mccProducto.RecordTypeId = recordTypeIdProducto;
		mccProducto.CC_Tematica__c = mccTematica.Id;
		mccProducto.CC_Codigo_Externo__c = 'PR-000001';
		insert mccProducto;

		Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
		CC_MCC__c mccMotivo = new CC_MCC__c();
		mccMotivo.Name = 'Motivo1';
		mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
		mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
		mccMotivo.RecordTypeId = recordTypeIdMotivo;
		mccMotivo.CC_Tematica__c = mccTematica.Id;
		mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
		mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
		insert mccMotivo;

		Id recordTypeIdDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
		CC_MCC__c mccDetalle = new CC_MCC__c();
		mccDetalle.Name = 'Detalle1';
		mccDetalle.CC_Tipo_Cliente__c = 'Segmentos';
		mccDetalle.CC_Fecha_Vigencia_Inicio__c = date.today();
		mccDetalle.RecordTypeId = recordTypeIdDetalle;
		mccDetalle.CC_Tematica__c = mccTematica.Id;
		mccDetalle.CC_Producto_Servicio__c = mccProducto.Id;
		mccDetalle.CC_Motivo__c = mccMotivo.Id;
		mccDetalle.CC_Codigo_Externo__c = 'DE-000001';
		insert mccDetalle;

		/*SEG_ClasificacionRapida__c clasRapida = new SEG_ClasificacionRapida__c();
		clasRapida.Name = 'CR1';
		clasRapida.SEG_Tematica__c = mccTematica.Id;
		clasRapida.SEG_Producto__c = mccProducto.Id;
		clasRapida.SEG_Motivo__c = mccMotivo.Id;
		clasRapida.SEG_Detalle__c = mccDetalle.Id;
		insert clasRapida;*/

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
		empresaSEG.CC_Numero_Documento__c = '11111111H';
		empresaSEG.ParentId = grupoEmpresa.Id;
		empresaSEG.SEG_Oficina_Gestora_Segmentos__c = centro.Id;
		insert empresaSEG;


		//Excepciones       
		List<SEG_Excepciones_Centro__c> lstExCentro = new List<SEG_Excepciones_Centro__c>();
		SEG_Excepciones_Centro__c exCentro = new SEG_Excepciones_Centro__c();
		exCentro.SEG_Excepciones__c = excepcion.id;
		exCentro.SEG_CentroEmpresa__c = centro.id;
		exCentro.SEG_Activo__c = true;
		lstExCentro.add(exCentro);

		SEG_Excepciones_Centro__c exCentro3 = new SEG_Excepciones_Centro__c();
		exCentro3.SEG_Excepciones__c = excepcion3.id;
		exCentro3.SEG_CentroEmpresa__c = centro.id;
		exCentro3.SEG_Activo__c = true;
		lstExCentro.add(exCentro3);
		insert lstExCentro;

		
		/*SEG_Excepciones_Grupo__c exGrupo = new SEG_Excepciones_Grupo__c();
		exGrupo.SEG_Excepciones__c = excepcion.id;
		exGrupo.SEG_GrupoTrabajo__c = grupoGestorOperativaNacional.id;
		exGrupo.SEG_Activo__c = true;
		insert exGrupo;

		SEG_Excepciones_Grupo__c exGrupo2 = new SEG_Excepciones_Grupo__c();
		exGrupo2.SEG_Excepciones__c = excepcion2.id;
		exGrupo2.SEG_GrupoTrabajo__c = grupoGestorOperativaNacional.id;
		exGrupo2.SEG_Activo__c = true;
		lstExGrupo.add(exGrupo2);
		insert exGrupo2;*/

		List<SEG_Excepciones_Grupo_Empresa__c> lstExGrupoEmpresa = new List<SEG_Excepciones_Grupo_Empresa__c>();
		SEG_Excepciones_Grupo_Empresa__c exGrupoEmpresa = new SEG_Excepciones_Grupo_Empresa__c();
		exGrupoEmpresa.SEG_Excepciones__c = excepcion.id;
		exGrupoEmpresa.SEG_GrupoEmpresa__c = grupoEmpresa.id;
		exGrupoEmpresa.SEG_Activo__c = true;
		lstExGrupoEmpresa.add(exGrupoEmpresa);

		SEG_Excepciones_Grupo_Empresa__c exGrupoEmpresa4 = new SEG_Excepciones_Grupo_Empresa__c();
		exGrupoEmpresa4.SEG_Excepciones__c = excepcion4.id;
		exGrupoEmpresa4.SEG_GrupoEmpresa__c = grupoEmpresa.id;
		exGrupoEmpresa4.SEG_Activo__c = true;
		lstExGrupoEmpresa.add(exGrupoEmpresa4);
		insert lstExGrupoEmpresa;

		List<SEG_Excepciones_Empresa__c> lstExEmpresa = new List<SEG_Excepciones_Empresa__c>();
		SEG_Excepciones_Empresa__c exEmpresa = new SEG_Excepciones_Empresa__c();
		exEmpresa.SEG_Excepciones__c = excepcion.id;
		exEmpresa.Empresa__c = empresaSEG.id;
		exEmpresa.SEG_Activo__c = true;
		lstExEmpresa.add(exEmpresa);

		SEG_Excepciones_Empresa__c exEmpresa5 = new SEG_Excepciones_Empresa__c();
		exEmpresa5.SEG_Excepciones__c = excepcion5.id;
		exEmpresa5.Empresa__c = empresaSEG.id;
		exEmpresa5.SEG_Activo__c = true;
		lstExEmpresa.add(exEmpresa5);
		insert lstExEmpresa;

		List<SEG_Excepciones_CR__c> lstExCR = new List<SEG_Excepciones_CR__c>();
		SEG_Excepciones_CR__c exCR = new SEG_Excepciones_CR__c();
		exCR.SEG_Excepciones__c = excepcion.id;
		//exCR.SEG_ClasificacionRapida__c = clasRapida.id;
		exCR.SEG_Activo__c = true;
		lstExCR.add(exCR);

		SEG_Excepciones_CR__c exCR6 = new SEG_Excepciones_CR__c();
		exCR6.SEG_Excepciones__c = excepcion6.id;
		//exCR6.SEG_ClasificacionRapida__c = clasRapida.id;
		exCR6.SEG_Activo__c = true;
		lstExCR.add(exCR6);
		insert lstExCR;

		// Crear contactos para cuentas SEG.
		Contact contactoSEG1 = new Contact();
		contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		contactoSEG1.LastName = 'Contacto SEG 1';
		contactoSEG1.AccountId = empresaSEG.Id;
		contactoSEG1.Email = 'test@test.com';
		insert contactoSEG1;

		
		Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.AccountId = empresaSEG.Id;
		caso1.ContactId = contactoSEG1.Id;
		caso1.CC_MailTelfNotif__c = contactoSEG1.Email;
		caso1.SEG_Idioma__c = 'en';
		caso1.CC_AcuseRecibo__c = '1';
		caso1.Subject = 'test 1';
		caso1.Status = 'Pendiente';
		caso1.SEG_Organizacion__c = 'Banca Corporativa';
		caso1.SEG_Zona__c = 'Corporativa';
		caso1.CC_MCC_Tematica__c = mccTematica.Id;
		caso1.CC_MCC_ProdServ__c = mccProducto.Id;
		caso1.CC_MCC_Motivo__c = mccMotivo.Id;
		caso1.SEG_Detalle__c = mccDetalle.Id;
		//caso1.SEG_Grupo__c = grupoGestorOperativaNacional.Id;
		//caso1.SEG_ClasificacionRapida__c = clasRapida.Id;
		insert caso1;

		Case caso2 = new Case();
		caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso2.AccountId = empresaSEG.Id;
		caso2.ContactId = contactoSEG1.Id;
		caso2.CC_MailTelfNotif__c = contactoSEG1.Email;
		caso2.SEG_Idioma__c = 'en';
		caso2.CC_AcuseRecibo__c = '1';
		caso2.Subject = 'test 2';
		caso2.Status = 'Pendiente';
		caso2.SEG_Organizacion__c = 'Banca Corporativa';
		caso2.SEG_Zona__c = 'Corporativa';
		caso2.CC_MCC_Tematica__c = mccTematica.Id;
		caso2.CC_MCC_ProdServ__c = mccProducto.Id;
		caso2.CC_MCC_Motivo__c = mccMotivo.Id;
		caso2.SEG_Detalle__c = mccDetalle.Id;
		//caso2.SEG_Grupo__c = grupoGestorOperativaNacional.Id;
		//caso2.SEG_ClasificacionRapida__c = clasRapida.Id;
		insert caso2;

		Case caso3 = new Case();
		caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		caso3.AccountId = empresaSEG.Id;
		caso3.ContactId = contactoSEG1.Id;
		caso3.CC_MailTelfNotif__c = contactoSEG1.Email;
		caso3.SEG_Idioma__c = 'en';
		caso3.CC_AcuseRecibo__c = '1';
		caso3.Subject = 'test 2';
		caso3.Status = 'Pendiente';
		caso3.SEG_Organizacion__c = 'Banca Corporativa';
		caso3.SEG_Zona__c = 'Corporativa';
		caso3.CC_MCC_Tematica__c = mccTematica.Id;
		caso3.CC_MCC_ProdServ__c = mccProducto.Id;
		caso3.CC_MCC_Motivo__c = mccMotivo.Id;
		caso3.SEG_Detalle__c = mccDetalle.Id;
		//caso2.SEG_Grupo__c = grupoGestorOperativaNacional.Id;
		//caso2.SEG_ClasificacionRapida__c = clasRapida.Id;
		insert caso3;

        SEG_Contratos__c contrato1 = new SEG_Contratos__c();
        contrato1.Name = 'Number1';
        contrato1.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato1.SEG_NombreCuenta__c = empresaSEG.Id;
        contrato1.SEG_SR_Seguimiento__c = caso3.Id;
        contrato1.SEG_Estado__c = 'No firmado';
        contrato1.SEG_Fecha_1_Reclamacion__c = date.Today();
        insert contrato1;

	}
	@isTest
	private static void getAllExcepciones_test() {
		User supervisor = SEG_Usuarios.usuarioSupervisor();

		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			
			Map<Id,Case> mapCase = new Map<Id, Case>([SELECT Id FROM Case]);
			Map<Id,SEG_Contratos__c> mapContrato = new Map<Id, SEG_Contratos__c>([SELECT Id FROM SEG_Contratos__c]);

			List<Id> idsCasos = new List<Id>(mapCase.keyset());
			List<Id> idsContratos = new List<Id>(mapContrato.keyset());

			Test.startTest();
				Map<Id,List<SEG_Excepciones__c>> ids = SEG_ExcepcionesHandler.getAllExcepciones(idsCasos, idsContratos);
			Test.stopTest();

			System.assertNotEquals(ids,null,'SEG_Desmarcado_Segmentos_Batch_Test');
		}
	}

	@isTest
	private static void calcularExcepcionesCasosYContratos_test() {
		User supervisor = SEG_Usuarios.usuarioSupervisor();

		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			
			Map<Id,Case> mapCase = new Map<Id, Case>([SELECT Id FROM Case]);
			Map<Id,SEG_Contratos__c> mapContrato = new Map<Id, SEG_Contratos__c>([SELECT Id FROM SEG_Contratos__c]);

			List<Id> idsCasos = new List<Id>(mapCase.keyset());
			List<Id> idsContratos = new List<Id>(mapContrato.keyset());

			Test.startTest();
			Map<String,Object> result = SEG_ExcepcionesHandler.calcularExcepcionesCasosYContratos(0,idsCasos, false,idsContratos);
			Test.stopTest();

			System.assertNotEquals(result,null,'No se han calculado las excepciones');
		}
	}

}