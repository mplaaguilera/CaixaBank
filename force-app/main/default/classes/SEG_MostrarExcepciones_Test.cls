@isTest
public class SEG_MostrarExcepciones_Test {
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
	}    
    
    @isTest
    public static void excepcionTexto_Test()
    {
        Id exTextoId = Schema.getGlobalDescribe().get('SEG_Excepciones__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Texto').getRecordTypeId();
        Id exContratoId = Schema.getGlobalDescribe().get('SEG_Excepciones__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Contratos').getRecordTypeId();
        SEG_Contratos__c contrato = [Select Id,SEG_SR_Seguimiento__c from SEG_Contratos__c where Name = 'Number1' LIMIT 1];


        SEG_Excepciones__c ex = new SEG_Excepciones__c();
        ex.RecordTypeId = exTextoId;
        ex.SEG_Texto__c = 'Excepciones Casos';
        insert ex;
        
        SEG_Excepciones__c exContract = new SEG_Excepciones__c(); 
        exContract.RecordTypeId = exContratoId;
        exContract.SEG_Texto__c = 'Excepciones Contratos';
        insert exContract;
        
        SEG_Excepciones_Caso__c exCase = new SEG_Excepciones_Caso__c();
        exCase.SEG_ExcepcionesContrato__c = exContract.id;
        exCase.SEG_Excepciones__c = ex.id;
        exCase.SEG_Contratos__c=contrato.Id;
        exCase.SEG_Case__c =contrato.SEG_SR_Seguimiento__c;
        insert exCase;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        List<String> excepcionTexto = SEG_MostrarExcepciones.getExcepciones(exCase.Id);      
        Test.stopTest();

        System.assertNotEquals(null , excepcionTexto, 'excepcionTexto viene vacío');
        }
    }
    
    @isTest
    public static void excepcionContrato_Test()
    {
        Id exTextoId = Schema.getGlobalDescribe().get('SEG_Excepciones__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Texto').getRecordTypeId();
        Id exContratoId = Schema.getGlobalDescribe().get('SEG_Excepciones__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Contratos').getRecordTypeId();
        SEG_Contratos__c contrato = [Select Id,SEG_SR_Seguimiento__c from SEG_Contratos__c where Name = 'Number1' LIMIT 1];

        SEG_Excepciones__c ex = new SEG_Excepciones__c();
        ex.RecordTypeId = exTextoId;
        insert ex;
        
        SEG_Excepciones__c exContract = new SEG_Excepciones__c();
        exContract.RecordTypeId = exContratoId;
        exContract.SEG_Texto__c = 'Excepciones Contratos';
        insert exContract;
        
        SEG_Excepciones_Caso__c exCase = new SEG_Excepciones_Caso__c();
        exCase.SEG_ExcepcionesContrato__c = exContract.id;
        exCase.SEG_Excepciones__c = ex.id;
        exCase.SEG_Contratos__c=contrato.Id;
        insert exCase;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        List<String> excepcionContrato = SEG_MostrarExcepciones.getExcepciones(exCase.Id);      
        Test.stopTest();

        System.assertNotEquals(null , excepcionContrato, 'excepcionContrato viene vacío');
        }
    }
    
    
    @isTest
    public static void sinTextoExcepcion_Test()
    {
        Id exTextoId = Schema.getGlobalDescribe().get('SEG_Excepciones__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Texto').getRecordTypeId();
        Id exContratoId = Schema.getGlobalDescribe().get('SEG_Excepciones__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Contratos').getRecordTypeId();
		/*
        SEG_Excepciones__c ex = new SEG_Excepciones__c();
        ex.RecordTypeId = exTextoId;
        insert ex;
         
        SEG_Excepciones__c exContract = new SEG_Excepciones__c();
        exContract.RecordTypeId = exContratoId;
        insert exContract;
        */
        SEG_Excepciones_Caso__c exCase = new SEG_Excepciones_Caso__c();
        //exCase.SEG_ExcepcionesContrato__c = exContract.id;
        //exCase.SEG_Excepciones__c = ex.id;
        insert exCase;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        List<String> sinTextoExcepcion = SEG_MostrarExcepciones.getExcepciones(exCase.Id);      
        Test.stopTest();

        System.assertNotEquals(null , sinTextoExcepcion, 'sinTextoExcepcion viene vacío');
        }
    }

    
   @isTest
    public static void excepcionCase_Test()
    {
		
        Id exTextoId = Schema.getGlobalDescribe().get('SEG_Excepciones__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Texto').getRecordTypeId();
        Id exContratoId = Schema.getGlobalDescribe().get('SEG_Excepciones__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Contratos').getRecordTypeId();

	    SEG_Contratos__c contrato = [Select Id,SEG_SR_Seguimiento__c from SEG_Contratos__c where Name = 'Number1' LIMIT 1];
        
        SEG_Excepciones__c ex = new SEG_Excepciones__c();
        ex.RecordTypeId = exTextoId;
        ex.SEG_Texto__c = 'Excepciones Casos';
        insert ex;
        
        SEG_Excepciones__c exContract = new SEG_Excepciones__c(); 
        exContract.RecordTypeId = exContratoId;
        exContract.SEG_Texto__c = 'Excepciones Contratos';
        insert exContract;
        
        SEG_Excepciones_Caso__c exCase1 = new SEG_Excepciones_Caso__c();
        exCase1.SEG_Excepciones__c = ex.id;
        exCase1.SEG_Case__c =contrato.SEG_SR_Seguimiento__c;
        exCase1.SEG_PopUp__c='Pendiente';
        insert exCase1;

        SEG_Excepciones_Caso__c exCase2 = new SEG_Excepciones_Caso__c();
        exCase2.SEG_ExcepcionesContrato__c = exContract.id;
        exCase2.SEG_Contratos__c =contrato.Id;
        exCase2.SEG_PopUp__c='Pendiente';
        insert exCase2;
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        Test.startTest();
        List<String> excepcionCase = SEG_MostrarExcepciones.getExcepcionesCase(contrato.SEG_SR_Seguimiento__c,'Otros');      
        Test.stopTest();

        System.assertNotEquals(null , excepcionCase, 'excepcionCase viene vacío');
        }
    }
    
    
}