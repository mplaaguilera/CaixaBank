@isTest
public with sharing class SEG_wsValijaCasosComunes_Test {
    @testSetup
    static void datosIniciales ()
    { 
        // RT utilizados.
        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        Id grColSegmentosId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Id listaValoresId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        cuentaSEG1.SEG_Organizacion__c = 'Banca Corporativa';
        cuentaSEG1.SEG_Zona__c = 'Corporativa';
        cuentaSEG1.CBK_Negocio__c = 'Segmentos';
        insert cuentaSEG1;

        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        insert contactoSEG1;
               
        // Crear MCC.
        CC_MCC__c mccDetalle3 = new CC_MCC__c();
        mccDetalle3.RecordTypeId = recordDet;
        mccDetalle3.Name = 'Detalle';
        mccDetalle3.CC_Tipo_Cliente__c = 'Cliente';
        mccDetalle3.CC_Codigo_Externo__c = 'DE-000003';
        insert mccDetalle3;  

        //Grupo Colaborador con RT Grupo Colaborador
        SEG_Plantilla__c plantilla = new SEG_Plantilla__C();
        plantilla.Name ='Plantilla Col';
        plantilla.SEG_TipoOperativa__c = 'Acuse de recibo';
        plantilla.SEG_PlantillaCastellanoID__c = plantilla.id;
        plantilla.SEG_Activa__c = true;
        insert plantilla;
        
        //Asignamos el RecordType ='Grupo Colaborador'
        CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
        grupoRTGrupoCol.Name='Grupo Colaborador';
        grupoRTGrupoCol.RecordTypeId = grColId;
        insert grupoRTGrupoCol;
        
        //Grupo MCC link Grupo Colaborador
        CC_MCC_Grupo_Colaborador__c  grupoCol = new CC_MCC_Grupo_Colaborador__c();
        grupoCol.Name='Colaborador';
        grupoCol.CC_MCC__c = mccDetalle3.Id; 
        grupoCol.CC_Grupo_Colaborador__c=grupoRTGrupoCol.id;
        grupoCol.SEG_Zona__c = 'Todas';
        grupoCol.SEG_Organizacion__c = 'Todas';
        insert grupoCol;

        // Crear MCC.
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        // Crear MCC.
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto1';
        mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        // Crear MCC.
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo1';
        mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        // Crear MCC.
        Id recordTypeIdDetalle = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
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
        
        // Crear CR's
        SEG_ClasificacionRapida__c regla1 = new SEG_ClasificacionRapida__c();
        regla1.Name = 'CR1';
        regla1.SEG_Tematica__c = mccTematica.Id;
        regla1.SEG_Producto__c = mccProducto.Id;
        regla1.SEG_Motivo__c = mccMotivo.Id;
        regla1.SEG_Detalle__c = mccDetalle.Id;
        regla1.CBK_Negocio__c = 'Segmentos';
        insert regla1;
        
        // Crear grupo colaborador por defecto de Segmentos.
        CC_Grupo_Colaborador__c grupoRTGrupoSeg = new CC_Grupo_Colaborador__c();
        grupoRTGrupoSeg.Name='MCC 0029';
        grupoRTGrupoSeg.RecordTypeId = grColSegmentosId;
        grupoRTGrupoSeg.SEG_GrupoSegmentos__c = true;
        insert grupoRTGrupoSeg;
        
        // Crear usuario colaborador.
        CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c ();
        colaborador.CC_Usuario__c = UserInfo.getUserId();
        colaborador.CC_Grupo_Colaborador__c = grupoRTGrupoSeg.Id;
        insert colaborador;
        
        // Crear grupo colaborador por defecto de Segmentos.
        CC_Grupo_Colaborador__c grupoRTGrupoSeg2 = new CC_Grupo_Colaborador__c();
        grupoRTGrupoSeg2.Name='MCC 0030';
        grupoRTGrupoSeg2.RecordTypeId = grColSegmentosId;
        grupoRTGrupoSeg2.SEG_GrupoSegmentos__c = true;
        insert grupoRTGrupoSeg2;
        
		// Crear casos de los clientes.
        List<Case> listadoCasos = new List<Case>();
        
        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso2.AccountId = cuentaSEG1.Id;
        caso2.ContactId = contactoSEG1.Id;
        caso2.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso2.SEG_Idioma__c = 'es';
        caso2.CC_AcuseRecibo__c ='1';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.Status = 'Activo';
        caso2.Subject = 'test 2';
        caso2.SEG_Organizacion__c = 'Banca Corporativa';
        caso2.OS_Referencia_Valija__c = '0012345';
        caso2.SEG_Zona__c = 'Corporativa';
        caso2.Origin = 'WebService';
        caso2.SEG_Grupo__c = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name='MCC 0029'].Id;
        listadoCasos.add(caso2);

        insert listadoCasos;
                
        // Crear fichero asociado a la cuenta SEG.
        ContentVersion ficheroSFDC = new ContentVersion();
        ficheroSFDC.ContentLocation = 'S';
        ficheroSFDC.Description = 'fichero_SEG_1';
        ficheroSFDC.PathOnClient = 'fichero_SEG_1.txt';
        ficheroSFDC.Title = 'fichero_SEG_1';
        ficheroSFDC.VersionData = Blob.valueOf('test');
        ficheroSFDC.IsMajorVersion = true;
        insert ficheroSFDC;

        ContentVersion ficheroAdjuntado1 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :ficheroSFDC.Id];

        ContentDocumentLink linkFichero = new ContentDocumentLink();
        linkFichero.ContentDocumentId = ficheroAdjuntado1.ContentDocumentId;
        linkFichero.LinkedEntityId = listadoCasos[0].Id;
        linkFichero.ShareType = 'V'; 
        linkFichero.Visibility = 'AllUsers'; 
        
        insert linkFichero;
        
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.Name = 'VALIJA: PROCESOS SEGMENTOS';
        lista.RecordTypeId = listaValoresId;
        lista.CC_Valor__c = 'Todas';
        lista.CC_Activa__c = true;
        insert lista;
        
        CC_Lista_Valores__c lstValores1 = new CC_Lista_Valores__c();
        lstValores1.Name = 'proceso valija';
        lstValores1.CC_Lista__c = lista.id;
        lstValores1.SEG_CRId__c = regla1.id;
        lstValores1.CC_Valor__c = 'Banca Corporativa';
        lstValores1.CC_Activa__c = true;
        insert lstValores1;
        
        CC_Lista_Valores__c lstValores2 = new CC_Lista_Valores__c();
        lstValores2.Name = 'proceso valija else';
        lstValores2.CC_Lista__c = lista.id;
        lstValores2.CC_Activa__c = true;
        insert lstValores2;        
    }
    
    @isTest
    public static void recuperarProcesoValija_Test()
    {        
        Boolean bRecuperarCR = true;
		String org = 'Banca Corporativa';
        CC_Lista_Valores__c lstValor = [SELECT Id, Name, CC_Valor__c FROM CC_Lista_Valores__c WHERE Name = 'proceso valija'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();       
        	Map<String,String> resultado = SEG_wsValijaCasosComunes.recuperarProcesoValija(lstValor.Name, org, bRecuperarCR);
        Test.stopTest();

		System.assert(resultado.get('codigo') == '0');
		System.assert(resultado.get('areaProceso') == lstValor.CC_Valor__c);
        }
    }
    
    @isTest
    public static void recuperarProcesoValijaTodas_Test()
    {        
		String org = 'Instituciones';
        CC_Lista_Valores__c lstValor = [SELECT Id, Name FROM CC_Lista_Valores__c WHERE Name = 'proceso valija else'];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();       
        	Map<String,String> resultado = SEG_wsValijaCasosComunes.recuperarProcesoValija(lstValor.Name, org, false);
        Test.stopTest();

		System.assert(resultado.get('codigo') == '2');
		System.assert(resultado.get('areaProceso') == null);
        }
    }
    
    @isTest
    public static void comprobarValijaIdExistente_Test()
    {        
        Case caso = [SELECT Id, OS_Referencia_Valija__c FROM Case];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();       
        	Boolean result = SEG_wsValijaCasosComunes.comprobarValijaIdExistente(caso.OS_Referencia_Valija__c);
        Test.stopTest();

		System.assert(result == true);
        }
    }
    
    @isTest
    public static void recuperarInformacionCaso_Test()
    {        
        Case caso = [SELECT Id, OS_Referencia_Valija__c FROM Case];

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();       
        	Case resultadoCaso = SEG_wsValijaCasosComunes.recuperarInformacionCaso(caso.id);
        Test.stopTest();

		System.assert(resultadoCaso.id == caso.id);
        }
    }
    
    @isTest
    public static void validarFicherosValija_Test()
    {        
        Integer tipoFichero = 2;
        List<String> lstFile = new List<String>();
        Case caso = [SELECT Id, OS_Referencia_Valija__c FROM Case LIMIT 1];
		ContentVersion file = [SELECT Id FROM ContentVersion LIMIT 1];
        lstFile.add(file.id);
        lstFile.add(caso.id);
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();       
        	Map<String,String> resultado = SEG_wsValijaCasosComunes.validarFicherosValija(caso.id, tipoFichero, caso.OS_Referencia_Valija__c, lstFile);
        Test.stopTest();

		System.assert(resultado.get('error') == '2');
        }
    }
    
    @isTest
    public static void matrizValija_Test()
    {              
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();       
        	Map<String,String> result1 = SEG_wsValijaCasosComunes.matrizProcesosValija();
        	Map<String,String> result2 = SEG_wsValijaCasosComunes.matrizServiciosValija();
        Test.stopTest();

        System.assertNotEquals(result1, null);
        System.assertNotEquals(result2, null);
        }
    }
    
    @isTest
    public static void calcularOperacionValija_Test()
    {        
		SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador datosTrasladoTest = new SEG_trasladoColaboradorWS.SEG_DataTrasladoColaborador();
        datosTrasladoTest.operacionPaqueteria = 'test';  
        datosTrasladoTest.operacionValijaMCC = 'test';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();       
        	Map<String,String> resultado = SEG_wsValijaCasosComunes.calcularOperacionValija(datosTrasladoTest);
        Test.stopTest();

		System.assert(resultado.get('operacionValija') == 'test');
    }
    }
}