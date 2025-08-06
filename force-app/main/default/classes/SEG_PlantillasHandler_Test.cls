@IsTest
public class SEG_PlantillasHandler_Test {
	@TestSetup
	public static void crearDatosPrueba()
	{
		Id opSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
		Id autoSegId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
		List<CC_Grupo_Colaborador__c> lstGrupoColaborador = new List<CC_Grupo_Colaborador__c> ();

		//Gestor Operativa Nacional
		CC_Grupo_Colaborador__c grupoGestorOperativaNacional = new CC_Grupo_Colaborador__c();
		grupoGestorOperativaNacional.Name = 'Gestor Operativa Nacional';
		grupoGestorOperativaNacional.RecordTypeId = opSegId;
		lstGrupoColaborador.add(grupoGestorOperativaNacional);

		//Gestor Operativa Internacional
		CC_Grupo_Colaborador__c grupoGestorOperativaInternacional = new CC_Grupo_Colaborador__c();
		grupoGestorOperativaInternacional.Name = 'Gestor Operativa Internacional';
		grupoGestorOperativaInternacional.RecordTypeId = autoSegId;
		lstGrupoColaborador.add(grupoGestorOperativaInternacional);
		insert lstGrupoColaborador;

		Id recordAsig = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Asignacion').getRecordTypeId();
		Id recordTexto = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Texto').getRecordTypeId();

		EmailTemplate emailEs = new EmailTemplate();
		emailEs.DeveloperName = 'Reclamacion_1_1616749645917';
		emailEs.Encoding = 'ISO-8859-1';
		emailEs.FolderId = UserInfo.getUserId();
		emailEs.Subject = '[num_casos]';
		emailEs.IsActive = true;
		emailEs.Name = 'Reclamacion 1º';
		emailEs.TemplateType = 'custom';
		emailEs.TemplateStyle = 'none';
		emailEs.HtmlValue = '<html><head><title></title></head><body style="height: auto; min-height: auto;">1&ordm; reclamaci&oacute;n enviada con la SR de seguimiento&nbsp;{{{Case.CaseNumber}}}<style type="text/css">table {font-family: arial, sans-serif; border-collapse: collapse;width: 100%;}td, th {border: 1px solid #dddddd; text-align: left; padding: 8px;}tr:nth-child(even) { background-color: #dddddd;}</style><table><tr><th>N&uacute;mero Contrato</th><th>Fecha Contrato</th><th>Descripci&oacute;n Contrato</th></tr></table></body></html>';
		System.runAs(new User(Id = UserInfo.getUserId())) {
			insert emailEs;
		}

		SEG_Plantilla__c plantilla = new SEG_Plantilla__c();
		plantilla.Name = 'Acuse de recibo';
		plantilla.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		plantilla.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias';
		plantilla.SEG_TipoOperativa__c = 'Acuse de recibo';
		plantilla.SEG_Activa__c = true;
		plantilla.SEG_PlantillaCastellano__c = 'Firma BO';
		plantilla.SEG_PlantillaCatalan__c = 'Firma CAT';
		plantilla.SEG_PlantillaIngles__c = 'Firma IN';
		plantilla.SEG_PlantillaEuskera__c = 'Firma EUSK';
		plantilla.SEG_PlantillaGalego__c = 'Firma GAL';
		plantilla.SEG_PlantillaCastellanoID__c = emailEs.Id;
		insert plantilla;

		SEG_Plantilla__c plantilla1 = new SEG_Plantilla__c();
		plantilla1.Name = 'Acuse de recibo';
		plantilla1.SEG_Organizacion__c = 'Banca Corporativa;Centro Empresas;Instituciones;Centro Soporte Especialistas;Financiación Estructurada';
		plantilla1.SEG_Zona__c = 'Corporativa;Empresas Barcelona;Empresas Castilla La Mancha;Empresas Cataluña;Empresas Madrid;Empresas Valencia;Instituciones Canarias';
		plantilla1.SEG_TipoOperativa__c = 'Acuse de recibo';
		plantilla1.SEG_Activa__c = true;
		plantilla1.SEG_PlantillaCastellano__c = 'Firma BO';
		plantilla1.SEG_PlantillaCatalan__c = 'Firma CAT';
		plantilla1.SEG_PlantillaIngles__c = 'Firma IN';
		plantilla1.SEG_PlantillaEuskera__c = 'Firma EUSK';
		plantilla1.SEG_PlantillaGalego__c = 'Firma GAL';
		plantilla1.SEG_PlantillaCastellanoID__c = emailEs.Id;
		insert plantilla1;

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

		SEG_ClasificacionRapida__c clasRapida = new SEG_ClasificacionRapida__c();
		clasRapida.Name = 'CR1';
		clasRapida.SEG_Tematica__c = mccTematica.Id;
		clasRapida.SEG_Producto__c = mccProducto.Id;
		clasRapida.SEG_Motivo__c = mccMotivo.Id;
		clasRapida.SEG_Detalle__c = mccDetalle.Id;
        clasRapida.CBK_Negocio__c = 'Segmentos';
		insert clasRapida;

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
        empresaSEG.SEG_Prioridad_Carterizacion_Segmentos__c = true;
		insert empresaSEG;


		//Excepciones       
		List<SEG_ExcepcionesCentro__c> lstExCentro = new List<SEG_ExcepcionesCentro__c>();
		SEG_ExcepcionesCentro__c exCentro = new SEG_ExcepcionesCentro__c();
		exCentro.SEG_Plantilla__c = plantilla.id;
		exCentro.SEG_CentroEmpresa__c = centro.id;
		lstExCentro.add(exCentro);

		SEG_ExcepcionesCentro__c exCentro2 = new SEG_ExcepcionesCentro__c();
		exCentro2.SEG_Plantilla__c = plantilla1.id;
		exCentro2.SEG_CentroEmpresa__c = centro.id;
		lstExCentro.add(exCentro2);
		insert lstExCentro;

		List<SEG_ExcepcionesGrupo__c> lstExGrupo = new List<SEG_ExcepcionesGrupo__c>();
		SEG_ExcepcionesGrupo__c exGrupo = new SEG_ExcepcionesGrupo__c();
		exGrupo.SEG_Plantilla__c = plantilla.id;
		exGrupo.SEG_GrupoTrabajoTexto__c = grupoGestorOperativaNacional.id;
		lstExGrupo.add(exGrupo);

		SEG_ExcepcionesGrupo__c exGrupo2 = new SEG_ExcepcionesGrupo__c();
		exGrupo2.SEG_Plantilla__c = plantilla1.id;
		exGrupo2.SEG_GrupoTrabajoTexto__c = grupoGestorOperativaNacional.id;
		lstExGrupo.add(exGrupo2);
		insert lstExGrupo;

		List<SEG_ExcepcionesGrupoEmpresa__c> lstExGrupoEmpresa = new List<SEG_ExcepcionesGrupoEmpresa__c>();
		SEG_ExcepcionesGrupoEmpresa__c exGrupoEmpresa = new SEG_ExcepcionesGrupoEmpresa__c();
		exGrupoEmpresa.SEG_Plantilla__c = plantilla.id;
		exGrupoEmpresa.SEG_GrupoEmpresa__c = grupoEmpresa.id;
		lstExGrupoEmpresa.add(exGrupoEmpresa);

		SEG_ExcepcionesGrupoEmpresa__c exGrupoEmpresa4 = new SEG_ExcepcionesGrupoEmpresa__c();
		exGrupoEmpresa4.SEG_Plantilla__c = plantilla1.id;
		exGrupoEmpresa4.SEG_GrupoEmpresa__c = grupoEmpresa.id;
		lstExGrupoEmpresa.add(exGrupoEmpresa4);
		insert lstExGrupoEmpresa;

		List<SEG_ExcepcionesEmpresa__c> lstExEmpresa = new List<SEG_ExcepcionesEmpresa__c>();
		SEG_ExcepcionesEmpresa__c exEmpresa = new SEG_ExcepcionesEmpresa__c();
		exEmpresa.SEG_Plantilla__c = plantilla.id;
		exEmpresa.SEG_Empresa__c = empresaSEG.id;
		lstExEmpresa.add(exEmpresa);

		SEG_ExcepcionesEmpresa__c exEmpresa1 = new SEG_ExcepcionesEmpresa__c();
		exEmpresa1.SEG_Plantilla__c = plantilla1.id;
		exEmpresa1.SEG_Empresa__c = empresaSEG.id;
		lstExEmpresa.add(exEmpresa1);
		insert lstExEmpresa;

		List<SEG_ExcepcionesCR__c> lstExCR = new List<SEG_ExcepcionesCR__c>();
		SEG_ExcepcionesCR__c exCR = new SEG_ExcepcionesCR__c();
		exCR.SEG_Plantilla__c = plantilla.id;
		exCR.SEG_ClasificacionRapida__c = clasRapida.id;
		lstExCR.add(exCR);

		SEG_ExcepcionesCR__c exCR6 = new SEG_ExcepcionesCR__c();
		exCR6.SEG_Plantilla__c = plantilla1.id;
		exCR6.SEG_ClasificacionRapida__c = clasRapida.id;
		lstExCR.add(exCR6);
		insert lstExCR;

		// Crear contactos para cuentas SEG.
		Contact contactoSEG1 = new Contact();
		contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		contactoSEG1.LastName = 'Contacto SEG 1';
		contactoSEG1.AccountId = empresaSEG.Id;
		contactoSEG1.Email = 'test@test.com';
		insert contactoSEG1;

		List<Case> lstCase = new List<Case>();
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
		caso1.SEG_Grupo__c = grupoGestorOperativaNacional.Id;
		caso1.SEG_ClasificacionRapida__c = clasRapida.Id;
		lstCase.add(caso1);

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
		caso2.SEG_Grupo__c = grupoGestorOperativaNacional.Id;
		caso2.SEG_ClasificacionRapida__c = clasRapida.Id;
		lstCase.add(caso2);
		insert lstCase;
	}

	@isTest
	private static void test_IndentificarPlantillas() {
		List<Case> lstCase = [Select AccountId, SEG_Organizacion__c, SEG_Zona__c,
		                      CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c,
		                      SEG_Detalle__c, SEG_Grupo__c, SEG_Numero_centro__c, 
							  SEG_Grupo_Empresa__c, SEG_ClasificacionRapida__c,SEG_Resultado__c
		                      From Case];
		List<Contact> lstCont = [SELECT id, Name, CC_Idioma__C, Email FROM Contact];
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {

		Test.startTest();
			SEG_PlantillasHandler.SEG_AcuseRecibo acuseReciboProcess = new SEG_PlantillasHandler.SEG_AcuseRecibo(lstCase[0],'Acuse de recibo',lstCont[0].Id);
			System.enqueueJob(acuseReciboProcess);
		Test.stopTest();

		System.assertNotEquals(acuseReciboProcess,null,'test_IndentificarPlantillas-->acuseReciboProcess');
		}
	}
    
    	@isTest
	private static void test_determinarCuenta() {
		List<Case> lstCase = [Select AccountId, SEG_Organizacion__c, SEG_Zona__c,
		                      CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c,
		                      SEG_Detalle__c, SEG_Grupo__c, SEG_Numero_centro__c, 
							  SEG_Grupo_Empresa__c, SEG_ClasificacionRapida__c,SEG_Resultado__c
		                      From Case];
		List<Contact> lstCont = [SELECT id, Name, CC_Idioma__C, Email FROM Contact];

		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
		Test.startTest();
			SEG_PlantillasHandler.determinarCuenta(lstCase);
		Test.stopTest();

		System.assertNotEquals(lstCase,null,'test_determinarCuenta-->lstCase');
		}
	}

}