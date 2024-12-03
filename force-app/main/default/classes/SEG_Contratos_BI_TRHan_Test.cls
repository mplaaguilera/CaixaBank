@isTest
public with sharing class SEG_Contratos_BI_TRHan_Test {

	@testSetup
	static void datosIniciales()
	{
		// Creación cuentas a tratar.  
		Account cuentaSEG1 = new Account();
		cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		cuentaSEG1.Name = 'Empresa segmentos';
		cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
		cuentaSEG1.CC_Numero_Documento__c = '11111111H';
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
		caso2.Subject = 'casoSEG';
        caso2.CC_MCC_Tematica__c = mccTematicaSEG.Id;
        caso2.CC_MCC_ProdServ__c = mccProductoSEG.Id;
        caso2.CC_MCC_Motivo__c = mccMotivoSEG.Id;
        caso2.SEG_ClasificacionRapida__c = regla3.Id;
		listadoCasos.add(caso2);

		insert listadoCasos;
        
        //Crear contratos
        SEG_Contratos__c contrato1 = new SEG_Contratos__c();
        contrato1.Name = 'Number1';
        contrato1.SEG_NombreCliente__c = contactoSEG1.Id;
        contrato1.SEG_NombreCuenta__c = cuentaSEG1.Id;
        contrato1.SEG_SR_Seguimiento__c=caso2.Id;
        contrato1.SEG_Estado__c = 'No firmado';
        contrato1.SEG_Fecha_1_Reclamacion__c = date.Today();
		insert contrato1;
        
        CC_Caracteristica__c car = new CC_Caracteristica__c();
        car.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
        car.Name = 'Reclamaciones Agotadas';
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
		List<Case> caso = [SELECT id FROM Case WHERE Subject = 'casoSEG' LIMIT 1];

		List<SEG_ClasificacionRapida__c> cr = [SELECT id,Name, SEG_Tematica__c, SEG_Producto__c,SEG_Motivo__c,SEG_Detalle__c,SEG_ReclamacionesContratos__c,
													   SEG_CRContratos__c,CBK_Negocio__c 
												FROM SEG_ClasificacionRapida__c WHERE Name = 'CR3' LIMIT 1];

        SEG_Contratos__c contrato2 = new SEG_Contratos__c();
        contrato2.Name = 'Number2';
        contrato2.SEG_NombreCliente__c = contacto[0].Id;
        contrato2.SEG_NombreCuenta__c = cuenta[0].Id;
        contrato2.SEG_SR_Seguimiento__c=caso[0].Id;
        contrato2.SEG_Estado__c = 'No firmado';
        contrato2.SEG_Fecha_2_Reclamacion__c = date.Today();

        System.runAs (new User(Id = UserInfo.getUserId())) {

		Test.startTest();
        	insert contrato2;
		Test.stopTest();
		List<SEG_Contratos__c> contratos = [SELECT Id, OwnerId FROM SEG_Contratos__c WHERE Name = 'Number2'];
		system.assert(contratos[0] != null , 'El caso no se ha insertado correctamente');
        }
    }

    @isTest
    static void envioGestor(){
        List<Account> cuenta = [SELECT id,RecordTypeId, Name, SEG_DominioMail__c,CC_Numero_Documento__c FROM Account LIMIT 1];
		List<Contact> contacto = [SELECT id, RecordTypeId, LastName, AccountId, Email FROM contact LIMIT 1];
		List<Case> caso = [SELECT id FROM Case WHERE Subject = 'casoSEG' LIMIT 1];

		List<SEG_ClasificacionRapida__c> cr = [SELECT id,Name, SEG_Tematica__c, SEG_Producto__c,SEG_Motivo__c,SEG_Detalle__c,SEG_ReclamacionesContratos__c,
													   SEG_CRContratos__c,CBK_Negocio__c 
												FROM SEG_ClasificacionRapida__c WHERE Name = 'CR3' LIMIT 1];

        SEG_Contratos__c contrato2 = new SEG_Contratos__c();
        contrato2.Name = 'Number2';
        contrato2.SEG_NombreCliente__c = contacto[0].Id;
        contrato2.SEG_NombreCuenta__c = cuenta[0].Id;
        contrato2.SEG_SR_Seguimiento__c=caso[0].Id;
        contrato2.SEG_Estado__c = 'No reclamar';
        contrato2.SEG_Fecha_2_Reclamacion__c = date.Today();
        contrato2.SEG_1a_Reclamacion_ejecutada_manualmente__c=true;
        contrato2.SEG_2a_Reclamacion_ejecutada_manualmente__c=true;
        contrato2.SEG_3a_Reclamacion_ejecutada_manualmente__c=true;

        Test.startTest();
            System.runAs(new User(Id = UserInfo.getUserId())) { 
                insert  contrato2;
            }
        Test.stopTest();

		SEG_Contratos__c contrato2Insert = [SELECT SEG_Fecha_Firma__c,SEG_1a_Reclamacion_ejecutada_manualmente__c,SEG_Fecha_1a_Reclamacion_Proceso__c,SEG_2a_Reclamacion_ejecutada_manualmente__c,SEG_Fecha_2a_Reclamacion_Proceso__c, SEG_Fecha_3a_Reclamacion_Proceso__c, SEG_Fecha_Parada_Reclamacion__c FROM SEG_Contratos__c WHERE Name = 'Number2' LIMIT 1];
 
        System.assert(contrato2Insert.SEG_Fecha_1a_Reclamacion_Proceso__c != null);
        System.assert(contrato2Insert.SEG_Fecha_2a_Reclamacion_Proceso__c != null);
        System.assert(contrato2Insert.SEG_Fecha_3a_Reclamacion_Proceso__c != null);
        System.assert(contrato2Insert.SEG_Fecha_Parada_Reclamacion__c != null);
    }
}