@isTest
public with sharing class SEG_Case_AI_TRHan_Test {

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
		contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
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

        Id grupoOpSegId = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'GrupoColabSeg';
        grupoColab.SEG_Tipologia__c = 'BO';
        grupoColab.RecordTypeId = grupoOpSegId;
		insert grupoColab;

        SEG_Gestor_Grupo__c gestorDeGrupo = new SEG_Gestor_Grupo__c();
        gestorDeGrupo.SEG_GrupoOperativa__c = grupoColab.id;
        gestorDeGrupo.SEG_EmpleadoGestor__c = contactoSEG1.id;
        insert gestorDeGrupo;

        CC_Caracteristica__c car = new CC_Caracteristica__c();
        car.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
        car.CC_Descripcion__c = 'SEG TEST';
        car.OS_Negocio__c = 'SEGMENTOS';
		insert car;
        
        SEG_Marca_de_un_cliente__c marcaCliente = new SEG_Marca_de_un_cliente__c();
        marcaCliente.SEG_Caracteristica__c = car.id;
        marcaCliente.SEG_Cliente__c = cuentaSEG1.Id;
        insert marcaCliente;
	}
    
	@IsTest
	static void mainEntryTest(){
		List<Account> cuenta = [SELECT id,RecordTypeId, Name, SEG_DominioMail__c,CC_Numero_Documento__c FROM Account LIMIT 1];
		List<Contact> contacto = [SELECT id, RecordTypeId, LastName, AccountId, Email FROM contact LIMIT 1];
		List<Case> caso = [SELECT id FROM Case LIMIT 1];

		List<SEG_ClasificacionRapida__c> cr = [SELECT id,Name, SEG_Tematica__c, SEG_Producto__c,SEG_Motivo__c,SEG_Detalle__c,SEG_ReclamacionesContratos__c,
													   SEG_CRContratos__c,CBK_Negocio__c 
												FROM SEG_ClasificacionRapida__c WHERE Name = 'CR3' LIMIT 1];

        Case caso3 = new Case();
		caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		caso3.AccountId = cuenta[0].Id;
		caso3.ContactId = contacto[0].Id;
		caso3.CC_MailTelfNotif__c = contacto[0].Email;
		caso3.SEG_ClasificacionRapida__c = cr[0].id;
		caso3.SEG_Organizacion__c = 'Banca Corporativa';
		caso3.SEG_Idioma__c = 'en';
		caso3.CC_AcuseRecibo__c = '1';
		caso3.Subject = 'ActivoVFR';
		caso3.Status = 'Pendiente';
		caso3.SEG_SROrigen__c = caso[0].id;

		Test.startTest();
			insert caso3; 	
		Test.stopTest();
		List<Case> casos = [SELECT Id, OwnerId ,subject FROM Case WHERE subject = 'ActivoVFR'];
		system.assert(casos[0] != null , 'El caso no se ha insertado correctamente');
	}  
    
    @IsTest
	static void grupoAnteriorTest(){

		User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
		List<Account> cuenta = [SELECT id,RecordTypeId, Name, SEG_DominioMail__c,CC_Numero_Documento__c FROM Account LIMIT 1];
		List<Contact> contacto = [SELECT id, RecordTypeId, LastName, AccountId, Email FROM contact LIMIT 1];
		List<Case> caso = [SELECT id FROM Case LIMIT 1];
        List<CC_Grupo_Colaborador__c> grupo = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name = 'GrupoColabSeg' LIMIT 1];

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
        caso3.SEG_Grupo__c = grupo[0].Id;
		caso3.Subject = 'ActivoVFR';
		caso3.Status = 'Pendiente';
		caso3.SEG_SROrigen__c = caso[0].id;

		System.runAs (  new User(Id = UserInfo.getUserId()) ) {
			Test.startTest();
				insert caso3; 	
			Test.stopTest();
		}
		List<Case> casos = [SELECT Id, OwnerId ,subject FROM Case WHERE subject = 'ActivoVFR'];
		system.assert(casos[0] != null , 'El caso no se ha insertado correctamente');
	}  
}