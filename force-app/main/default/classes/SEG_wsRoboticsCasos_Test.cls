@isTest
public with sharing class SEG_wsRoboticsCasos_Test {
    @testSetup
    static void datosIniciales ()
    { 
        User thisUser;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
                UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
                thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com',
                    emailencodingkey='UTF-8', lastname='Smith',
                    languagelocalekey='en_US',
                    localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                    timezonesidkey='America/Los_Angeles',
                    username='testSEGBI@acme.com');
                insert thisUser;
                List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
                for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]){
                    PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                    nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                    nuevoPermiso.AssigneeId = thisUser.id;
                    listPermissionSetAssignment.add(nuevoPermiso);
                }
                if (listPermissionSetAssignment.isEmpty()){
                    insert listPermissionSetAssignment;
                }
        }
        
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
        grupoRTGrupoSeg.SEG_GrupoSegmentos__c = true;
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
        caso2.SEG_SRAuditoria__c = true;
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
    public static void crearCasoPostOK()
    {
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput datosEntrada = new SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput();
        datosEntrada.titulo = 'crearCasoPost_1';
        datosEntrada.zona = 'Instituciones Norte';
        datosEntrada.cif = '11111111H';
        datosEntrada.contactoEmailId = '';
        datosEntrada.clasificacionRapida = 'CR1';
        datosEntrada.grupoTrabajo = '';
        datosEntrada.perfilEnvio = '';
        datosEntrada.cierreCaso = 0;
        datosEntrada.resultadoCierreCaso = '';
        datosEntrada.idioma = 'es';
        datosEntrada.acuseRecibo = 0;
        datosEntrada.numeroOperacionesCSO = 4;
        datosEntrada.usuarioCSO = 'U01123456';
        datosEntrada.observaciones = '';
        datosEntrada.fechaValor = null;
        datosEntrada.fechaPlanificacion = null;
        //datosEntrada.accion = '';
        datosEntrada.propietarioCaso = '';
        datosEntrada.direccionEmail = 'interno@interno.es';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsCases/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        try{
        	SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultado = SEG_wsRoboticsCasos.crearCaso();
        Test.stopTest();

		System.assert(resultado.codigo == '0000');
        System.assert(resultado.resultado == 'OK');
    } catch (Exception e) {
        Test.stopTest();
        System.assertEquals(e.getMessage(), 'La URI del servicio no está bien formada');
    }
        }
    }

    @isTest
    public static void crearCasoPostKO()
    {
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput datosEntrada = new SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput();
        datosEntrada.titulo = 'crearCasoPost_1';
        datosEntrada.zona = '';
        datosEntrada.cif = '11111111H';
        datosEntrada.contactoEmailId = '';
        datosEntrada.clasificacionRapida = 'CR1';
        datosEntrada.grupoTrabajo = '';
        datosEntrada.perfilEnvio = '';
        datosEntrada.cierreCaso = 0;
        datosEntrada.resultadoCierreCaso = '';
        datosEntrada.idioma = 'es';
        datosEntrada.acuseRecibo = 0;
        datosEntrada.numeroOperacionesCSO = 4;
        datosEntrada.usuarioCSO = 'U01123456';
        datosEntrada.observaciones = '';
        datosEntrada.fechaValor = null;
        datosEntrada.fechaPlanificacion = null;
        //datosEntrada.accion = '';
        datosEntrada.propietarioCaso = '';
        datosEntrada.direccionEmail = 'interno@interno.es';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsCases/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultado = SEG_wsRoboticsCasos.crearCaso();
        Test.stopTest();

        System.assert(resultado.codigo == '0000');
        System.assert(resultado.resultado != 'OK');
        }
    }
    
    @isTest
    public static void actualizarCasoPutOK()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();
        datosEntrada.numeroOperacionesCSO = 4;
        datosEntrada.usuarioCSO = 'U01123456';
        datosEntrada.estado = 'Cerrado';
        datosEntrada.resultadoCierreCaso = 'cerrado';
        datosEntrada.asunto = 'asunto';
        datosEntrada.cuerpo = 'cuerpo';
        datosEntrada.grupoTrabajo = '';
        datosEntrada.propietarioCaso = '';
        datosEntrada.fechaPlanificacion = Datetime.now().addMonths(5);
        datosEntrada.fechaValor = Datetime.now().addMonths(5);
        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsCases/' + listaCasos[0].Id + '/';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutOutput resultado = SEG_wsRoboticsCasos.actualizarCaso();
        Test.stopTest();

        System.assert(resultado.resultado != null);
        System.assertEquals('OK', resultado.resultado);
        System.assertEquals('0000', resultado.codigo);
        System.assertEquals('', resultado.mensaje);      
        }
    }
    
    @isTest
    public static void actualizarCasoPutKO()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();
        datosEntrada.numeroOperacionesCSO = 4;
        datosEntrada.usuarioCSO = 'U01123456';
        datosEntrada.estado = 'Cerrado';
        datosEntrada.resultadoCierreCaso = '';
        datosEntrada.asunto = 'asunto';
        datosEntrada.cuerpo = 'cuerpo';
        datosEntrada.grupoTrabajo = 'MCC 0030';
        datosEntrada.propietarioCaso = '';
        datosEntrada.fechaPlanificacion = Datetime.now().addMonths(5);
        datosEntrada.fechaValor = Datetime.now().addMonths(5);
        datosEntrada.estadoAuditoria = 'OK';
        datosEntrada.motivoErrorAuditoria = '';
        datosEntrada.cifAuditoria = '11111111H';
        datosEntrada.fechaAuditoria = '08/2021';
        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsCases/' + listaCasos[0].Id + '/';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutOutput resultado = SEG_wsRoboticsCasos.actualizarCaso();
        Test.stopTest();

        System.assert(resultado.codigo != '0000');
        System.assert(resultado.resultado != 'OK');
        }
    }

    @isTest
    public static void recuperarCasoGetOK()
    {        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsCases/' + listaCasos[0].Id + '/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	SEG_wsRoboticsCasosGet.SEG_WS_NewCase_GetOutput resultado = SEG_wsRoboticsCasos.getCasoSalesforce();
        Test.stopTest();

        System.assert(resultado.codigo == '0000');
        System.assert(resultado.resultado == 'OK');
        }
    }
   
    @isTest
    public static void recuperarCasoGetOKV2()
    {        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        Map<String,String> datosValidacionEntrada;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v3/v1/segRoboticsCases/' + listaCasos[0].Id + '/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        datosValidacionEntrada = null;
        	SEG_wsRoboticsCasosGet.SEG_WS_NewCase_GetOutput resultado = SEG_wsRoboticsCasos.getCasoSalesforce();
        Test.stopTest();

        System.assert(resultado.codigo == '9002');
        System.assert(resultado.resultado == 'NOK');
        }
    }

    @isTest    
    public static void testValidacionDatosEntradaNOK() {
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        Boolean bOk = true;      
            RestRequest req = new RestRequest();        
            req.requestURI = '/services/apexrest/robocases/invalid';  
            req.httpMethod = 'PUT';       
            SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput input = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();                       
            input.estado = '';        
            input.grupoTrabajo = '';  
            input.usuarioCSO='';
            input.numeroOperacionesCSO =34;     
        req.requestBody = Blob.valueOf(JSON.serialize(input));                   
        RestContext.request = req;
        System.runAs (usuarioTest) {       
        Test.startTest();              
        SEG_wsRoboticsCasosGet.SEG_WS_NewCase_GetOutput resultado = SEG_wsRoboticsCasos.getCasoSalesforce();        
        Test.stopTest();                
        
        System.assertNotEquals(null, resultado.mensaje);        
        System.assertEquals('9002', resultado.codigo);  
        }
    }
  
    
    @isTest
    public static void testURIKO()
    {        
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsCases/error/' + listaCasos[0].Id + '/';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        System.runAs (usuarioTest) {
        Test.startTest();
        
        	SEG_wsRoboticsCasosGet.SEG_WS_NewCase_GetOutput resultado = SEG_wsRoboticsCasos.getCasoSalesforce();
        
	        req.requestURI = '/v1/segRoboticsCases/error/' + listaCasos[0].Id + '/';
	        req.httpMethod = 'PUT';
	        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutOutput resultado2 = SEG_wsRoboticsCasos.actualizarCaso();
        
	        req.requestURI = '/v1/segRoboticsCases/error/' + listaCasos[0].Id + '/';
	        req.httpMethod = 'POST';
        	SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultado3 = SEG_wsRoboticsCasos.crearCaso();

        Test.stopTest();

        System.assert(resultado.codigo != '0000');
        System.assert(resultado.resultado != 'OK');
        System.assert(resultado2.codigo != '0000');
        System.assert(resultado2.resultado != 'OK');
        System.assert(resultado3.codigo != '0000');
        System.assert(resultado3.resultado != 'OK');
        }
    }
    
    @isTest
    public static void crearCasoHijoPostOK()
    {
        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput datosEntrada = new SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput();
        datosEntrada.titulo = 'crearCasoPost_1';
        datosEntrada.zona = 'Instituciones Norte';
        datosEntrada.cif = '11111111H';
        datosEntrada.contactoEmailId = '';
        datosEntrada.clasificacionRapida = 'CR1';
        datosEntrada.grupoTrabajo = '';
        datosEntrada.perfilEnvio = '';
        datosEntrada.cierreCaso = 0;
        datosEntrada.resultadoCierreCaso = '';
        datosEntrada.idioma = 'es';
        datosEntrada.acuseRecibo = 0;
        datosEntrada.numeroOperacionesCSO = 4;
        datosEntrada.usuarioCSO = 'U01123456';
        datosEntrada.observaciones = '';
        datosEntrada.fechaValor = null;
        datosEntrada.fechaPlanificacion = null;
        //datosEntrada.accion = '';
        datosEntrada.propietarioCaso = '';
        datosEntrada.direccionEmail = 'interno@interno.es';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/segRoboticsCases/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;

        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultado = SEG_wsRoboticsCasos.crearCaso();
        
        System.runAs (usuarioTest) {
        Test.startTest();
        
        SEG_wsRoboticsCasosPost.SEG_WS_NewChildCase_PostInput dataInput = new SEG_wsRoboticsCasosPost.SEG_WS_NewChildCase_PostInput();
        dataInput.clasificacionRapida = 'CR1';
        dataInput.listadoDocumentosIds = new List<String>();
        
        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        req2.requestURI = '/v1/segRoboticsCases/' + resultado.casoId + '/createChildCase';
        req2.httpMethod = 'POST';
        req2.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req2;
        RestContext.response = res2;
        
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultado2 = SEG_wsRoboticsCasos.crearCaso();

/*
        SEG_wsRoboticsCasosPost.SEG_WS_NewChildCase_PostInput dataInput2 = new SEG_wsRoboticsCasosPost.SEG_WS_NewChildCase_PostInput();
        dataInput2.clasificacionRapida = 'CR1';
        dataInput2.listadoDocumentosIds = new List<String>();
        RestRequest req3 = new RestRequest();
        RestResponse res3 = new RestResponse();
        req3.requestURI = '/v1/segRoboticsCases/' + resultado.casoId + '/createChildCase';
        req3.httpMethod = 'POST';
        req3.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req3;
        RestContext.response = res3;
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultado3 = SEG_wsRoboticsCasos.crearCaso();*/

        Test.stopTest();
              // Verificar que el resultado sea 'NOK' y que el mensaje contenga el error
        
       // System.assert(resultado3.resultado == 'NOK');
        //System.assert(resultado3.mensaje.contains('Error al finalizar la traza'));


		System.assert(resultado.codigo == '0000');
        System.assert(resultado.resultado == 'OK');
        
		System.assert(resultado2.codigo == '0000');
        System.assert(resultado2.resultado == 'OK');
        }
    }
}