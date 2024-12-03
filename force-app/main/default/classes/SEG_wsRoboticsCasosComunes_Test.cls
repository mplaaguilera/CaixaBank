@isTest
public with sharing class SEG_wsRoboticsCasosComunes_Test {
    @testSetup
    static void datosIniciales ()
    { 
        // RT utilizados.
        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        Id grColSegmentosId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        
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
        
        // Crear canal de comunicación.
        List<CC_Canal_Com__c> canales = new List<CC_Canal_Com__c>();
		CC_Canal_Com__c canal1 = new CC_Canal_Com__c();
        canal1.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        canal1.CC_CuentaId__c = cuentaSEG1.Id;
        canal1.CC_ContactoId__c = contactoSEG1.Id;
        canal1.CC_Email__c = 'test1@test.es';
        canales.add(canal1);
        
		CC_Canal_Com__c canal2 = new CC_Canal_Com__c();
        canal2.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        canal2.CC_CuentaId__c = cuentaSEG1.Id;
        canal2.CC_ContactoId__c = contactoSEG1.Id;
        canal2.CC_Email__c = 'test2@test.es';
        canales.add(canal2);
        
        insert canales;
        
        // Crear oficina para la búsqueda.
        Account oficinaSEG1 = new Account();
        oficinaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        oficinaSEG1.Name = 'Oficina 00001';
        oficinaSEG1.CC_Numero_Oficina_Empresa__c = '001-00001';
        oficinaSEG1.SEG_Organizacion__c = 'Banca Corporativa';
        oficinaSEG1.SEG_Zona__c = 'Corporativa';
        oficinaSEG1.CBK_Negocio__c = 'Segmentos';
        insert oficinaSEG1;
        
        // Empleado.
        Contact empleado1 = new Contact();
        empleado1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        empleado1.LastName = 'Empleado SEG 1';
        empleado1.AccountId = oficinaSEG1.Id;
        empleado1.Email = 'test@test.com';
        insert empleado1;
        
        // Crear canal de comunicación.
        List<CC_Canal_Com__c> canalesOficina = new List<CC_Canal_Com__c>();
		CC_Canal_Com__c canalEmpleado1 = new CC_Canal_Com__c();
        canalEmpleado1.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        canalEmpleado1.CC_CuentaId__c = oficinaSEG1.Id;
        canalEmpleado1.CC_ContactoId__c = empleado1.Id;
        canalEmpleado1.CC_Email__c = 'test1@test.es';
        canalesOficina.add(canalEmpleado1);
        
		CC_Canal_Com__c canalEmpleado2 = new CC_Canal_Com__c();
        canalEmpleado2.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        canalEmpleado2.CC_CuentaId__c = oficinaSEG1.Id;
        canalEmpleado2.CC_ContactoId__c = empleado1.Id;
        canalEmpleado2.CC_Email__c = 'test2@test.es';
        canalesOficina.add(canalEmpleado2);
        
        insert canalesOficina;
        
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

        // Crear MCC.
        CC_MCC__c mccTematica2 = new CC_MCC__c();
		mccTematica2.Name = 'Tematica2';
        mccTematica2.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica2.RecordTypeId = recordTypeIdTematica;
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        insert mccTematica2;
        
        // Crear MCC.
        CC_MCC__c mccProducto2 = new CC_MCC__c();
        mccProducto2.Name = 'Producto2';
        mccProducto2.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto2.RecordTypeId = recordTypeIdProducto;
        mccProducto2.CC_Tematica__c = mccTematica2.Id;
        mccProducto2.CC_Codigo_Externo__c = 'PR-000002'; 
        insert mccProducto2; 
        
        // Crear MCC.
       	CC_MCC__c mccMotivo2 = new CC_MCC__c();
        mccMotivo2.Name = 'Motivo2';
        mccMotivo2.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo2.RecordTypeId = recordTypeIdMotivo;
        mccMotivo2.CC_Tematica__c = mccTematica2.Id;
        mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
        mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
        insert mccMotivo2;

        // Crear MCC.
       	CC_MCC__c mccDetalle2 = new CC_MCC__c();
        mccDetalle2.Name = 'Detalle2';
        mccDetalle2.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalle2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalle2.RecordTypeId = recordTypeIdDetalle;
        mccDetalle2.CC_Tematica__c = mccTematica2.Id;
        mccDetalle2.CC_Producto_Servicio__c = mccProducto2.Id;
        mccDetalle2.CC_Motivo__c = mccMotivo2.Id;
        mccDetalle2.CC_Codigo_Externo__c = 'DE-000002';
        insert mccDetalle2;

        // Crear CR's
        SEG_ClasificacionRapida__c regla1 = new SEG_ClasificacionRapida__c();
        regla1.Name = 'CR1';
        regla1.SEG_Tematica__c = mccTematica.Id;
        regla1.SEG_Producto__c = mccProducto.Id;
        regla1.SEG_Motivo__c = mccMotivo.Id;
        regla1.SEG_Detalle__c = mccDetalle.Id;
        regla1.CBK_Negocio__c = 'Segmentos';
        insert regla1;

        SEG_ClasificacionRapida__c regla2 = new SEG_ClasificacionRapida__c();
        regla2.Name = 'CR2';
        regla2.SEG_Tematica__c = mccTematica2.Id;
        regla2.SEG_Producto__c = mccProducto2.Id;
        regla2.SEG_Motivo__c = mccMotivo2.Id;
        regla2.SEG_Detalle__c = mccDetalle2.Id;
        regla2.CBK_Negocio__c = 'Segmentos';
        insert regla2;
        
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
        
        // Crear grupo CSO.
        SEG_GruposCSO__c grupoCSO = new SEG_GruposCSO__c();
        grupoCSO.name = 'grupoCSO';
		grupoCSO.SEG_ActivoCSO__c = true;
        insert grupoCSO;

        // Actualizar el employeeNumber del usuario de ejecución.
		User usuario = new User();
		usuario.Id = UserInfo.getUserId();
		usuario.EmployeeNumber = 'U01123456';
		update usuario;

        // Asignar usuario al grupo CSO.
		SEG_UsuariosCSO__c usuarioCSO = new SEG_UsuariosCSO__c();
		usuarioCSO.SEG_ActivoCSO__c = true;
		usuarioCSO.SEG_GrupoCSO__c = grupoCSO.Id;
        usuarioCSO.SEG_Usuario__c = UserInfo.getUserId();
        insert usuarioCSO;
        
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
        
        Task createTask = new Task(
            RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('SEG_Task').getRecordTypeId()
            ,Type = 'Recibido de Webservice'
            ,TaskSubtype = 'Task'
            ,Subject = 'Recibido de Webservice' 
            ,ActivityDate = System.today()
            ,Status = 'Completed'
            ,Description = 'WEBSERVICE '
            ,WhatId = listadoCasos[0].Id
            ,Priority = 'Normal'
        );
        insert createTask;
        
        ContentDocumentLink linkFichero2 = new ContentDocumentLink();
        linkFichero2.ContentDocumentId = ficheroAdjuntado1.ContentDocumentId;
        linkFichero2.LinkedEntityId = createTask.Id;
        linkFichero2.ShareType = 'V'; 
        linkFichero2.Visibility = 'AllUsers'; 
        
        insert linkFichero2;
    }
    
    @isTest
    public static void identificarClienteContacto()
    {        
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 1'];
        CC_Canal_Com__c canal = [SELECT Id FROM CC_Canal_Com__c WHERE CC_ContactoId__c = :contacto.Id AND CC_Email__c = 'test1@test.es'];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	Map<String,String> resultado = SEG_wsRoboticsCasosComunes.identificarClienteContacto('11111111H',contacto.Id);
        	Map<String,String> resultado2 = SEG_wsRoboticsCasosComunes.identificarClienteContacto('11111111H',canal.Id);
        Test.stopTest();

		System.assert(resultado.get('codigo') == '0');
        System.assert(resultado.get('clienteId') != '');
        System.assert(resultado.get('contactoId') != '');
        
		System.assert(resultado2.get('codigo') == '0');
        System.assert(resultado2.get('clienteId') != '');
        System.assert(resultado2.get('contactoId') != '');
        }
    }    

    @isTest
    public static void identificarClienteSinContacto()
    {        
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto SEG 1'];
        CC_Canal_Com__c canal = [SELECT Id FROM CC_Canal_Com__c WHERE CC_ContactoId__c = :contacto.Id AND CC_Email__c = 'test1@test.es'];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	Map<String,String> resultado = SEG_wsRoboticsCasosComunes.identificarClienteContacto('11111111H','');
        	Map<String,String> resultado2 = SEG_wsRoboticsCasosComunes.identificarClienteContacto('11111111H',canal.Id);
        Test.stopTest();

		System.assert(resultado.get('codigo') == '0');
        System.assert(resultado.get('clienteId') != '');
        System.assert(resultado.get('contactoId') != '');
        
		System.assert(resultado2.get('codigo') == '0');
        System.assert(resultado2.get('clienteId') != '');
        System.assert(resultado2.get('contactoId') != '');
        }
    }    
    
    @isTest
    public static void determinarMCCporCR()
    {               
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	Map<String,String> resultado = SEG_wsRoboticsCasosComunes.determinarMCCporCR('CR1');
	        Map<String,String> resultado2 = SEG_wsRoboticsCasosComunes.determinarMCCporCR('CR_NOEXISTE');
        Test.stopTest();

		System.assert(resultado.get('codigo') == '0');
        System.assert(resultado.get('CRId') != '');
        
		System.assert(resultado2.get('codigo') != '0');
        System.assert(resultado2.get('CRId') == '');
        }
    } 

    @isTest
    public static void obtenerRelacionZonaOrganizacion()
    {               
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	Map<String,String> resultado = SEG_wsRoboticsCasosComunes.obtenerRelacionZonaOrganizacion(Account.SEG_Zona__c);
        Test.stopTest();

		System.assert(!resultado.isEmpty());
        }
    } 
    
    @isTest
    public static void recuperarDatosOrganizacionZona()
    {             
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {  
        Test.startTest();
        	SEG_Buzon__mdt resultado = SEG_wsRoboticsCasosComunes.recuperarDatosOrganizacionZona('Banca Corporativa', 'Corporativa ZZ');
        Test.stopTest();

		System.assert(resultado != null);
        }
    } 
    
    @isTest
    public static void buscarGrupoPorNombre()
    {               
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	String resultado = SEG_wsRoboticsCasosComunes.buscarGrupoPorNombre('MCC 0029');
        Test.stopTest();

		System.assert(resultado != '');
        }
    }
    
    @isTest
    public static void recuperarBuzonSalida()
    {           
        List<SEG_Buzon__mdt> listaBuzones = [SELECT Id, DeveloperName FROM SEG_Buzon__mdt];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	String resultado = SEG_wsRoboticsCasosComunes.recuperarBuzonSalida(listaBuzones[0].DeveloperName);
        Test.stopTest();

		System.assert(resultado != '');
        }
    }
    
    @isTest
    public static void recuperarPropietarioCaso()
    {           
        String grupoId = SEG_wsRoboticsCasosComunes.buscarGrupoPorNombre('MCC 0029');

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	Map<String,String> resultado = SEG_wsRoboticsCasosComunes.recuperarPropietarioCaso(grupoId,'U01XXXXX');
        	Map<String,String> resultado2 = SEG_wsRoboticsCasosComunes.recuperarPropietarioCaso(grupoId,'U01123456');
        Test.stopTest();

		System.assert(resultado.get('codigo') == '1');
        System.assert(resultado2.get('codigo') == '0');
        }
    }
    
    @isTest
    public static void validarUsuarioCSO()
    {           
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	Map<String,String> resultado = SEG_wsRoboticsCasosComunes.validarUsuarioCSO('');
        	Map<String,String> resultado2 = SEG_wsRoboticsCasosComunes.validarUsuarioCSO('U01123456');
        Test.stopTest();

		System.assert(resultado.get('codigo') == '1');
        System.assert(resultado2.get('codigo') == '0');
        }
    }
    
    @isTest
    public static void identificarCentroCaixa()
    {        
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Empleado SEG 1'];
        CC_Canal_Com__c canal = [SELECT Id FROM CC_Canal_Com__c WHERE CC_ContactoId__c = :contacto.Id AND CC_Email__c = 'test1@test.es'];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	Map<String,String> resultado = SEG_wsRoboticsCasosComunes.identificarCentroCaixa('00001',contacto.Id);
        	Map<String,String> resultado2 = SEG_wsRoboticsCasosComunes.identificarCentroCaixa('00001',canal.Id);
        Test.stopTest();

		System.assert(resultado.get('codigo') == '0');
        System.assert(resultado.get('clienteId') != '');
        System.assert(resultado.get('contactoId') != '');
        
		System.assert(resultado2.get('codigo') == '0');
        System.assert(resultado2.get('clienteId') != '');
        }
    } 
    /*
    @isTest
    public static void recuperarColaboradorExterno()
    {                
        //String grupoId = SEG_wsRoboticsCasosComunes.buscarGrupoPorNombre('Grupo Colaborador');
		
        CC_Grupo_Colaborador__c grupoColaborador = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name ='Grupo Colaborador' LIMIT 1];
        
        CC_MCC__c mccGrupo = [SELECT Id FROM CC_MCC__c WHERE CC_Codigo_Externo__c = 'DE-000003' LIMIT 1];
        Set<String> mccSet = new Set<String>();
        mccSet.add(mccGrupo.Id);
        
        Test.startTest();
        	Map<String,String> resultado = SEG_wsRoboticsCasosComunes.recuperarColaboradorExterno('ORG','ZONA',grupoColaborador.Id, mccSet, '00001');

        Test.stopTest();

		System.assert(resultado.get('esExterno') == 'Y');
    } */
    
    @isTest
    public static void recuperarInformacionCaso()
    {                
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	Case resultado = SEG_wsRoboticsCasosComunes.recuperarInformacionCaso(listaCasos[0].Id);
        Test.stopTest();

		System.assert(resultado != null);
        }
    } 
    
    @isTest
    public static void recuperarConfiguracionNuevoEstado()
    {              
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {          
        Test.startTest();
        	Map<String,String> resultado = SEG_wsRoboticsCasosComunes.recuperarConfiguracionNuevoEstado('Cerrado');
        Test.stopTest();

		System.assert(resultado.get('encontrado') == 'Y');
        }
    } 
    
    @isTest
    public static void obtenerTipoObjeto()
    {                
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	String resultado = SEG_wsRoboticsCasosComunes.obtenerTipoObjeto(listaCasos[0].Id);
        Test.stopTest();

		System.assert(resultado == 'Case');
        }
    } 

    @isTest
    public static void validarDatos_test(){     
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        Map<String,String> resultado = SEG_wsRoboticsCasosComunes.validarDatosMCC (null,'test1','test2','test3');
        Map<String,String> resultado1 = SEG_wsRoboticsCasosComunes.validarDatosMCC ('test1',null,'test2','test3');
        Map<String,String> resultado2 = SEG_wsRoboticsCasosComunes.validarDatosMCC ('test1','test2',null,'test3');
        Map<String,String> resultado3 = SEG_wsRoboticsCasosComunes.validarDatosMCC ('test1','test22','test2','test3');
        Map<String,String> resultado4 = SEG_wsRoboticsCasosComunes.validarDatosMCC ('test1','test2','test3',null);
        Map<String,String> resultado5 = SEG_wsRoboticsCasosComunes.validarDatosMCC ('test1','test2',null,null);
        Map<String,String> resultado6 = SEG_wsRoboticsCasosComunes.validarDatosMCC ('test1',null,null,null);
        Test.stopTest();
        
        System.assert(resultado != null);
        System.assert(resultado1 != null);
        System.assert(resultado2 != null);
        System.assert(resultado3 != null);
        System.assert(resultado4 != null);
        System.assert(resultado5 != null);
        System.assert(resultado6 != null);
        }
    }

    @isTest
    public static void crearRegistroOperacionCSO_test (){  
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

        List<Case> caso = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        Id user = UserInfo.getUserId();

        Test.startTest();
            SEG_wsRoboticsCasosComunes.crearRegistroOperacionCSO(caso[0].id, user , 2);
        Test.stopTest();

        SEG_Operacion__c resultado = [SELECT Id, SEG_Usuario__c FROM SEG_Operacion__c LIMIT 1];
        
        System.assertEquals(resultado.SEG_Usuario__c,user );

        }
    }
}