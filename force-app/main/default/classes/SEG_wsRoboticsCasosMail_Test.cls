@isTest
public with sharing class SEG_wsRoboticsCasosMail_Test {
    
    @testSetup
    static void datosIniciales ()
    { 
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
        empleado1.LastName = 'Contacto SEG 1';
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
        
        // Crear MCC
        CC_MCC__c mccDetalle3 = new CC_MCC__c();
        mccDetalle3.RecordTypeId = recordDet;
        mccDetalle3.Name = 'Detalle';
        mccDetalle3.CC_Tipo_Cliente__c = 'Cliente';
        mccDetalle3.CC_Codigo_Externo__c = 'DE-000003';
        insert mccDetalle3;

        // Crear las plantillas para la comunicación.
        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = UserInfo.getUserId();
        template1.Name = 'Plantilla Test';
        template1.DeveloperName = 'Plantilla_Test';
        template1.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template1;
        }
        
        List<SEG_Plantilla__c> listaPlantillas = new List<SEG_Plantilla__c>();
        // Plantilla OK.
        SEG_Plantilla__c plantilla = new SEG_Plantilla__C();
        plantilla.Name ='Plantilla OK';
        plantilla.SEG_TipoOperativa__c = 'Firma';
        plantilla.SEG_PlantillaCastellanoID__c = template1.Id;
        plantilla.SEG_Activa__c = true;
        listaPlantillas.add(plantilla);
        
        SEG_Plantilla__c plantilla2 = new SEG_Plantilla__C();
        plantilla2.Name ='Plantilla KO';
        plantilla2.SEG_TipoOperativa__c = 'Firma';
        plantilla2.SEG_PlantillaCastellanoID__c='00X5r000000LZZTEAS';
        plantilla2.SEG_Activa__c = true;
        listaPlantillas.add(plantilla2);
        
        insert listaPlantillas;
        
        //Asignamos el RecordType ='Grupo Colaborador'
        CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
        grupoRTGrupoCol.Name='Grupo Colaborador';
        grupoRTGrupoCol.RecordTypeId = grColId;
        grupoRTGrupoCol.SEG_GrupoSegmentos__c = true;
        insert grupoRTGrupoCol;
        //Grupo MCC link Grupo Colaborador
        CC_MCC_Grupo_Colaborador__c  grupoCol = new CC_MCC_Grupo_Colaborador__c();
        grupoCol.Name='Colaborador';
        grupoCol.CC_MCC__c = mccDetalle3.Id; 
        grupoCol.CC_Grupo_Colaborador__c=grupoRTGrupoCol.id;
        grupoCol.SEG_Zona__c = 'Todas';
        grupoCol.SEG_Organizacion__c = 'Todas';
        insert grupoCol;
        //Creamos una plantilla para usar en RT = 'Grupo Colaborador'
        CC_Grupo_Colaborador_Plantilla__c plantillagrupo = new CC_Grupo_Colaborador_Plantilla__c();
        plantillagrupo.CC_Operativa__c= 'Trasladar';
        plantillagrupo.SEG_Plantilla__c=plantilla.id;
        plantillagrupo.CC_Grupo_Colaborador__c = grupoRTGrupoCol.id;
        insert plantillagrupo;

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

        CC_MCC__c mccTematica2 = new CC_MCC__c();
		mccTematica2.Name = 'Tematica2';
        mccTematica2.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica2.RecordTypeId = recordTypeIdTematica;
        mccTematica2.CC_Codigo_Externo__c = 'TE-000002';
        insert mccTematica2;
        
        CC_MCC__c mccProducto2 = new CC_MCC__c();
        mccProducto2.Name = 'Producto2';
        mccProducto2.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto2.RecordTypeId = recordTypeIdProducto;
        mccProducto2.CC_Tematica__c = mccTematica2.Id;
        mccProducto2.CC_Codigo_Externo__c = 'PR-000002'; 
        insert mccProducto2; 
        
       	CC_MCC__c mccMotivo2 = new CC_MCC__c();
        mccMotivo2.Name = 'Motivo2';
        mccMotivo2.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo2.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo2.RecordTypeId = recordTypeIdMotivo;
        mccMotivo2.CC_Tematica__c = mccTematica2.Id;
        mccMotivo2.CC_Producto_Servicio__c = mccProducto2.Id;
        mccMotivo2.CC_Codigo_Externo__c = 'MO-000002';
        insert mccMotivo2;

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

		User usuario = new User();
		usuario.Id = UserInfo.getUserId();
		usuario.EmployeeNumber = 'U01123456';
		update usuario;

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
    public static void enviarComunicacionOK()
    {
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        List<SEG_Plantilla__c> listaPlantillas = [SELECT Id FROM SEG_Plantilla__c WHERE Name = 'Plantilla OK'];
        ContentVersion ficheroAdjuntado1 = [SELECT Id FROM ContentVersion WHERE Title = 'fichero_SEG_1'];
        
        List<String> listaFicheros = new List<String>();
        listaFicheros.add(ficheroAdjuntado1.Id);
        
        SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostInput datosEntrada = new SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostInput();
        datosEntrada.casoId = listaCasos[0].Id;
        datosEntrada.asunto = 'prueba';
        datosEntrada.cuerpo = 'prueba';
        datosEntrada.plantillaId = listaPlantillas[0].Id;
        datosEntrada.notas = 'notas';
        datosEntrada.destinatarios = 'test@test.es';
        datosEntrada.destinatariosCC = 'test1@test1.es,test2@test2.es';
        datosEntrada.destinatariosCCO = 'testcc1@test1.es,testcc2@test2.es';
        datosEntrada.listadoDocumentosIds = listaFicheros;        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsCases/comunicacionCliente/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostOutput resultado = SEG_wsRoboticsCasosMail.enviarComunciacionCaso();
        Test.stopTest();

        System.assert(resultado.resultado == 'OK');
        }
    }
    
    @isTest
    public static void enviarComunicacionKO()
    {
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        List<SEG_Plantilla__c> listaPlantillas = [SELECT Id FROM SEG_Plantilla__c WHERE Name = 'Plantilla KO'];
        ContentVersion ficheroAdjuntado1 = [SELECT Id FROM ContentVersion WHERE Title = 'fichero_SEG_1'];
        
        List<String> listaFicheros = new List<String>();
        listaFicheros.add(ficheroAdjuntado1.Id);
        
        SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostInput datosEntrada = new SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostInput();
        datosEntrada.casoId = listaCasos[0].Id;
        datosEntrada.asunto = 'prueba';
        datosEntrada.cuerpo = 'prueba';
        datosEntrada.plantillaId = listaPlantillas[0].Id;
        datosEntrada.notas = 'notas';
        datosEntrada.destinatarios = 'test@test.es';
        datosEntrada.destinatariosCC = 'test1@test1.es,test2@test2.es';
        datosEntrada.destinatariosCCO = 'testcc1@test1.es,testcc2@test2.es';
        datosEntrada.listadoDocumentosIds = listaFicheros;        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsCases/comunicacionCliente/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostOutput resultado = SEG_wsRoboticsCasosMail.enviarComunciacionCaso();
        Test.stopTest();

		System.assert(resultado.codigo != '0000');
        System.assert(resultado.resultado != 'OK');
        }
    }
    
    
    @isTest
    public static void enviarComunicacionDatosKO()
    {
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        List<SEG_Plantilla__c> listaPlantillas = [SELECT Id FROM SEG_Plantilla__c WHERE Name = 'Plantilla KO'];
        ContentVersion ficheroAdjuntado1 = [SELECT Id FROM ContentVersion WHERE Title = 'fichero_SEG_1'];
        
        List<String> listaFicheros = new List<String>();
        listaFicheros.add(ficheroAdjuntado1.Id);
        
        SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostInput datosEntrada = new SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostInput();
        datosEntrada.casoId = listaCasos[0].Id;
        datosEntrada.asunto = 'prueba';
        datosEntrada.cuerpo = 'prueba';
        datosEntrada.plantillaId = listaPlantillas[0].Id;
        datosEntrada.notas = 'notas';
        datosEntrada.destinatarios = 'test@test.es';
        datosEntrada.destinatariosCC = 'test1@test1.es,test2@test2.es';
        datosEntrada.destinatariosCCO = 'testcc1@test1.es,testcc2@test2.es';
        datosEntrada.listadoDocumentosIds = listaFicheros;        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsCases/comunicacionCliente/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostOutput resultado = SEG_wsRoboticsCasosMail.enviarComunciacionCaso();

        	datosEntrada.casoId = null;
        	req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        	SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostOutput resultado2 = SEG_wsRoboticsCasosMail.enviarComunciacionCaso();
        
        	datosEntrada.casoId = listaCasos[0].Id;
        	req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        	SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostOutput resultado3 = SEG_wsRoboticsCasosMail.enviarComunciacionCaso();
        
        	datosEntrada.casoId = listaCasos[0].Id;
        	datosEntrada.plantillaId = '00X5r000000LZZTEAS';
        	req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        	SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostOutput resultado4 = SEG_wsRoboticsCasosMail.enviarComunciacionCaso();
        
        	req.requestURI = '/v1/segRoboticsCases/comunicacionCliente/ERROR_URI/';
        	req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        	SEG_wsRoboticsCasosMail.SEG_WS_NewCaseMail_PostOutput resultado5 = SEG_wsRoboticsCasosMail.enviarComunciacionCaso();
        Test.stopTest();

		System.assert(resultado.codigo == '0000');
        System.assert(resultado.resultado != 'OK');
		System.assert(resultado2.codigo == '0000');
        System.assert(resultado2.resultado != 'OK');
		System.assert(resultado3.codigo != '0000');
        System.assert(resultado3.resultado != 'OK');
		System.assert(resultado4.codigo != '0000');
        System.assert(resultado4.resultado != 'OK');
		System.assert(resultado5.codigo != '0000');
        System.assert(resultado5.resultado != 'OK');
        }
    }
}