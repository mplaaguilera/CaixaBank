@isTest
public with sharing class SEG_wsRoboticsBusquedaCasos_Test {
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
        cuentaSEG1.CBK_Negocio__c = 'Segmentos';
        insert cuentaSEG1;

        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        insert contactoSEG1;
        
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
        grupoRTGrupoCol.SEG_GrupoSegmentos__c = true;
        insert grupoRTGrupoCol;

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001'; 
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto1';
        mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
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

        Case caso1 = new Case();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.AccountId = cuentaSEG1.Id;
        caso1.ContactId = contactoSEG1.Id;
        caso1.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso1.SEG_Idioma__c = 'en';
        caso1.CC_AcuseRecibo__c ='1';
        caso1.Subject = 'test 1';
        /*caso1.CC_MCC_Tematica__c = mccTematica.Id;
        caso1.CC_MCC_ProdServ__c = mccProducto.Id;
        caso1.CC_MCC_Motivo__c = mccMotivo.Id;*/
        caso1.Status = 'Pendiente';
        listadoCasos.add(caso1);
        
        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso2.AccountId = cuentaSEG1.Id;
        caso2.ContactId = contactoSEG1.Id;
        caso2.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso2.SEG_Idioma__c = 'es';
        caso2.CC_AcuseRecibo__c ='1';
        //caso2.ParentId = caso1.Id;
        //caso2.CC_MCC_Tematica__c = mccTematica.Id;
        //caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        //caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.Status = 'Activo';
        caso2.Subject = 'test 2';
        caso2.SEG_Organizacion__c = 'Banca Corporativa';
        caso2.SEG_Zona__c = 'Corporativa';
        caso2.Origin = 'WebService';
        caso2.SEG_Grupo__c = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name='MCC 0029'].Id;
        caso2.SEG_ClasificacionRapida__c = [SELECT Id FROM SEG_ClasificacionRapida__c WHERE Name = 'CR1'].Id;
        listadoCasos.add(caso2);
        
        Case caso3 = new Case();
        caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso3.AccountId = cuentaSEG1.Id;
        caso3.ContactId = contactoSEG1.Id;
        caso3.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso3.SEG_Idioma__c = 'es';
        caso3.CC_AcuseRecibo__c ='1';
        //caso3.ParentId = caso1.Id;
        caso3.CC_MCC_Tematica__c = mccTematica.Id;
        caso3.CC_MCC_ProdServ__c = mccProducto.Id;
        caso3.CC_MCC_Motivo__c = mccMotivo.Id;
        caso3.Status = 'Cerrado';
        caso3.CC_Detalles_Solucion__c = 'solución';
        caso3.Subject = 'test 3';
        caso3.SEG_Organizacion__c = 'Banca Corporativa';
        caso3.SEG_Zona__c = 'Corporativa';
        caso3.Origin = 'WebService';
        listadoCasos.add(caso3);
        
        Case caso4 = new Case();
        caso4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso4.AccountId = cuentaSEG1.Id;
        caso4.ContactId = contactoSEG1.Id;
        caso4.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso4.SEG_Idioma__c = 'es';
        caso4.CC_AcuseRecibo__c ='1';
        //caso2.ParentId = caso1.Id;
        caso4.CC_MCC_Tematica__c = mccTematica.Id;
        caso4.CC_MCC_ProdServ__c = mccProducto.Id;
        caso4.CC_MCC_Motivo__c = mccMotivo.Id;
        caso4.Status = 'Activo';
        caso4.Subject = 'test 4';
        caso4.SEG_Organizacion__c = 'Banca Corporativa';
        caso4.SEG_Zona__c = 'Corporativa';
        caso4.Origin = 'WebService';
        listadoCasos.add(caso4);

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
        linkFichero.LinkedEntityId = listadoCasos[1].Id;
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
            ,WhatId = listadoCasos[1].Id
            ,Priority = 'Normal'
        );
        insert createTask;
        
        ContentDocumentLink linkFichero2 = new ContentDocumentLink();
        linkFichero2.ContentDocumentId = ficheroAdjuntado1.ContentDocumentId;
        linkFichero2.LinkedEntityId = createTask.Id;
        linkFichero2.ShareType = 'V'; 
        linkFichero2.Visibility = 'AllUsers'; 
        
        insert linkFichero2;
        
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SEG_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        // Crear mail al caso 2.
        EmailMessage mail = new EmailMessage();
        mail.Subject = 'test';
        mail.TextBody = 'test';
        mail.Incoming = true;
        mail.ParentId = listadoCasos[1].Id;
        mail.Headers = '[{"value": "' + headerValueStr + '", "name": "X-SFDC-Original-RCPT"}]';
        insert mail;
    }
    
    @isTest
    public static void buscarCasos_TodosFiltros()
    {
		Map<String,String> filtros = new Map<String,String>();
        filtros.put('Grupo', 'MCC 0029');
        filtros.put('Grupo Contiene','0029');
        filtros.put('Grupo Distinto','0000');
        filtros.put('Grupo No Contiene','0000');
        filtros.put('Zona','Corporativa');
        filtros.put('CIF', '11111111H');
        filtros.put('Estado','Activo');
        filtros.put('Subestado','Pendiente');
        filtros.put('CR','CR1');
        //filtros.put('Propietario','U01XXXXXX');
        filtros.put('Fecha Apertura Desde','2000-01-01');
        filtros.put('Fecha Apertura Hasta','2999-01-01');
        filtros.put('Fecha Cierre Desde','2000-01-01');
        filtros.put('Fecha Cierre Hasta','2999-01-01');
        
        SEG_wsRoboticsBusquedaCasos.SEG_WS_SearchCase_PostIntput datosEntrada = new SEG_wsRoboticsBusquedaCasos.SEG_WS_SearchCase_PostIntput();
        datosEntrada.recuperarCorreo = 1;
        datosEntrada.filtros = filtros;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsSearchCases/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
			SEG_wsRoboticsBusquedaCasos.SEG_WS_SearchCase_PostOutput resultado = SEG_wsRoboticsBusquedaCasos.buscarCasos();
        Test.stopTest();

		System.assert(resultado.resultado == 'OK');
        System.assert(resultado.codigo == '0000');
        }
    }
    
    @isTest
    public static void buscarCasos_CasoEncontrado()
    {
		Map<String,String> filtros = new Map<String,String>();
        filtros.put('Grupo', 'MCC 0029');
        filtros.put('Zona','Corporativa');
        filtros.put('CIF', '11111111H');
        filtros.put('CR','CR1');
        filtros.put('Fecha Apertura Desde','2000-01-01');
        filtros.put('Fecha Apertura Hasta','2999-01-01');
        
        SEG_wsRoboticsBusquedaCasos.SEG_WS_SearchCase_PostIntput datosEntrada = new SEG_wsRoboticsBusquedaCasos.SEG_WS_SearchCase_PostIntput();
        datosEntrada.recuperarCorreo = 1;
        datosEntrada.filtros = filtros;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsSearchCases/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
			SEG_wsRoboticsBusquedaCasos.SEG_WS_SearchCase_PostOutput resultado = SEG_wsRoboticsBusquedaCasos.buscarCasos();
        Test.stopTest();

		System.assert(resultado.resultado == 'OK');
        System.assert(resultado.codigo == '0000');
        }
    }
    
    @isTest
    public static void buscarCasos_ErrorPropietario()
    {
		Map<String,String> filtros = new Map<String,String>();
        filtros.put('Grupo', 'MCC 0029');
        filtros.put('Grupo Contiene','0029');
        filtros.put('Grupo Distinto','0000');
        filtros.put('Grupo No Contiene','0000');
        filtros.put('Zona','Corporativa');
        filtros.put('CIF', '11111111H');
        filtros.put('Estado','Activo');
        filtros.put('Subestado','Pendiente');
        filtros.put('CR','CR1');
        filtros.put('Propietario','U01XXXXXX');
        filtros.put('Fecha Apertura Desde','2000-01-01');
        filtros.put('Fecha Apertura Hasta','2999-01-01');
        filtros.put('Fecha Cierre Desde','2000-01-01');
        filtros.put('Fecha Cierre Hasta','2999-01-01');
        
        SEG_wsRoboticsBusquedaCasos.SEG_WS_SearchCase_PostIntput datosEntrada = new SEG_wsRoboticsBusquedaCasos.SEG_WS_SearchCase_PostIntput();
        datosEntrada.recuperarCorreo = 1;
        datosEntrada.filtros = filtros;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsSearchCases/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
			SEG_wsRoboticsBusquedaCasos.SEG_WS_SearchCase_PostOutput resultado = SEG_wsRoboticsBusquedaCasos.buscarCasos();
        Test.stopTest();

		System.assert(resultado.resultado != 'OK');
        System.assert(resultado.codigo != '0000');
        }
    }
    
    @isTest
    public static void buscarCasos_URIKO()
    {
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsSearchCases/URI_KO/';
        req.httpMethod = 'POST';
        req.requestBody = null;
        RestContext.request = req;
        RestContext.response = res;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
			SEG_wsRoboticsBusquedaCasos.SEG_WS_SearchCase_PostOutput resultado = SEG_wsRoboticsBusquedaCasos.buscarCasos();
        Test.stopTest();

		System.assert(resultado.resultado != 'OK');
        System.assert(resultado.codigo == '9002');
    }
    }
    
    @isTest
    public static void buscarCasos_DatosNull()
    {                
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsSearchCases/';
        req.httpMethod = 'POST';
        req.requestBody = null;
        RestContext.request = req;
        RestContext.response = res;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
			SEG_wsRoboticsBusquedaCasos.SEG_WS_SearchCase_PostOutput resultado = SEG_wsRoboticsBusquedaCasos.buscarCasos();
        Test.stopTest();

		System.assert(resultado.resultado != 'OK');
        System.assert(resultado.codigo == '0000');
        }
    }
}