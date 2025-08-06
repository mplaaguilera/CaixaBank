@isTest
public with sharing class SEG_wsRoboticsCasosPost_Test {
    @testSetup
    static void datosIniciales (){ 
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
        //Grupo MCC link Grupo Colaborador
        /*CC_MCC_Grupo_Colaborador__c  grupoCol = new CC_MCC_Grupo_Colaborador__c();
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
        insert plantillagrupo;*/

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
    }
    
    @isTest
    public static void crearCasoPost_1(){
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

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	Map<String,String> datosValidados = SEG_wsRoboticsCasosPost.validarDatosEntradaPOST(datosEntrada);       
        	Map<String,String> resultado = SEG_wsRoboticsCasosPost.crearCasoSalesforce(datosEntrada, datosValidados);
        Test.stopTest();

		System.assert(resultado.get('codigo') == 'OK');
        }
    }
    
    @isTest
    public static void crearCasoPost_2(){
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

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	datosEntrada.cierreCaso = 1;
        	datosEntrada.resultadoCierreCaso = 'cierre';
        	Map<String,String> datosValidados2 = SEG_wsRoboticsCasosPost.validarDatosEntradaPOST(datosEntrada);        
        	Map<String,String> resultado2 = SEG_wsRoboticsCasosPost.crearCasoSalesforce(datosEntrada, datosValidados2);   
        Test.stopTest();
		System.assert(resultado2.get('codigo') == 'OK');
        }
    }
    
    @isTest
    public static void crearCasoPost_3(){
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

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();  
        	datosEntrada.cierreCaso = 1;
        	datosEntrada.resultadoCierreCaso = 'cierre';
        	datosEntrada.cif = '00000';
        	Map<String,String> datosValidados3 = SEG_wsRoboticsCasosPost.validarDatosEntradaPOST(datosEntrada);        
        	Map<String,String> resultado3 = SEG_wsRoboticsCasosPost.crearCasoSalesforce(datosEntrada, datosValidados3);   
        Test.stopTest();
		System.assert(resultado3.get('codigo') == 'OK');
        }
    }
    
    @isTest
    public static void datosEntradaNull(){
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput datosEntrada;
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();        
        	Map<String,String> datosValidados = SEG_wsRoboticsCasosPost.validarDatosEntradaPOST(datosEntrada);
        Test.stopTest();       
        System.assert(datosValidados.get('resultado') == 'NOK');
        System.assert(datosValidados.get('codigo') == '0000');
    }
    }
    
    @isTest
    public static void datosEntradaObligatorio(){
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput datosEntrada = new SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();        
        	Map<String,String> datosValidados = SEG_wsRoboticsCasosPost.validarDatosEntradaPOST(datosEntrada);
        Test.stopTest();       
        System.assert(datosValidados.get('resultado') == 'NOK');
        System.assert(datosValidados.get('codigo') == '0000');
        }
    }
    
    @isTest
    public static void validacionesSimplesCaso(){
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput datosEntrada = new SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostInput();
        datosEntrada.titulo = 'crearCasoPost_1';
        datosEntrada.zona = 'Instituciones Catalunya NO EXISTE';
        datosEntrada.cif = '11111111H';
        datosEntrada.contactoEmailId = '';
        datosEntrada.clasificacionRapida = 'CR1';
        datosEntrada.grupoTrabajo = '';
        datosEntrada.perfilEnvio = '';
        datosEntrada.cierreCaso = 0;
        datosEntrada.resultadoCierreCaso = '';
        datosEntrada.idioma = 'es';
        datosEntrada.acuseRecibo = 0;
        datosEntrada.numeroOperacionesCSO = null;
        datosEntrada.usuarioCSO = '';
        datosEntrada.observaciones = '';
        datosEntrada.fechaValor = null;
        datosEntrada.fechaPlanificacion = null;
        //datosEntrada.accion = '';
        datosEntrada.propietarioCaso = '';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        	Map<String,String> datosValidados1 = SEG_wsRoboticsCasosPost.validarDatosEntradaPOST(datosEntrada);
        
	        datosEntrada.zona = 'Instituciones Norte';
	        datosEntrada.clasificacionRapida = 'CR1 NO EXISTE';
	        Map<String,String> datosValidados2 = SEG_wsRoboticsCasosPost.validarDatosEntradaPOST(datosEntrada);
        
	        datosEntrada.zona = 'Instituciones Norte';
	        datosEntrada.clasificacionRapida = 'CR1';
        	datosEntrada.grupoTrabajo = 'NO EXISTE';
        	datosEntrada.perfilEnvio = 'NO EXISTE';
        	datosEntrada.fechaPlanificacion = Datetime.now().addMonths(-5);
        	datosEntrada.fechaValor = Datetime.now().addMonths(-5);
        	datosEntrada.cierreCaso = 1;
        	datosEntrada.propietarioCaso = 'NO EXISTE';
        	datosEntrada.usuarioCSO = 'NO EXISTE';
            
	        Map<String,String> datosValidados3 = SEG_wsRoboticsCasosPost.validarDatosEntradaPOST(datosEntrada);
        
        	datosEntrada.usuarioCSO = '';
        	datosEntrada.numeroOperacionesCSO = 3;
        	datosEntrada.cif = 'NO EXISTE';
        	datosEntrada.clasificacionRapida = 'NO EXISTE';
        	datosEntrada.cierreCaso = 1;
        	datosEntrada.resultadoCierreCaso = 'cierre';
            
	        Map<String,String> datosValidados4 = SEG_wsRoboticsCasosPost.validarDatosEntradaPOST(datosEntrada);
        
        	datosEntrada.usuarioCSO = 'U01123456';
        	datosEntrada.numeroOperacionesCSO = 0;
            
	        Map<String,String> datosValidados5 = SEG_wsRoboticsCasosPost.validarDatosEntradaPOST(datosEntrada);
                
        	datosEntrada.usuarioCSO = 'U01123456';
        	datosEntrada.numeroOperacionesCSO = 5;
        
        	List<SEG_GruposCSO__c> listaCSO = [SELECT Id FROM SEG_GruposCSO__c WHERE Name = 'grupoCSO'];
        	listaCSO[0].SEG_ActivoCSO__c = false;
        	update listaCSO;
            
	        Map<String,String> datosValidados6 = SEG_wsRoboticsCasosPost.validarDatosEntradaPOST(datosEntrada);
        Test.stopTest();

        System.assert(datosValidados1.get('resultado') == 'NOK');
        System.assert(datosValidados1.get('codigo') == '0010');        
        System.assert(datosValidados2.get('PAKresultado') == 'PAK');
        System.assert(datosValidados3.get('PAKresultado') == 'PAK');
        System.assert(datosValidados4.get('PAKresultado') == 'PAK');
        System.assert(datosValidados5.get('PAKresultado') == 'PAK');
        System.assert(datosValidados6.get('PAKresultado') == 'PAK');
        }
    }
    
    @isTest
    public static void crearCasoHttpPostOK(){
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
       	SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultado = SEG_wsRoboticsCasosPost.crearCasoHttpPost(req);
        Test.stopTest();

		System.assert(resultado.codigo == '0000');
        System.assert(resultado.resultado == 'OK');
        }
    }
    
    @isTest
    public static void validarDatosEntradaCasosHijosPOSTOK()
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
        
       	SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultado = SEG_wsRoboticsCasosPost.crearCasoHttpPost(req);
        
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
        linkFichero.LinkedEntityId = resultado.casoId;
        linkFichero.ShareType = 'V'; 
        linkFichero.Visibility = 'AllUsers';        
        insert linkFichero;
        
        List<String> listaFicheros = new List<String>();
        listaFicheros.add(ficheroSFDC.Id);
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        SEG_wsRoboticsCasosPost.SEG_WS_NewChildCase_PostInput dataInput = new SEG_wsRoboticsCasosPost.SEG_WS_NewChildCase_PostInput();
        dataInput.clasificacionRapida = 'CR1';
        dataInput.listadoDocumentosIds = listaFicheros;
        
        Map<String,String> resultadoValidacion = SEG_wsRoboticsCasosPost.validarDatosEntradaCasosHijosPOST (resultado.casoId, dataInput);
        Map<String,String> resultadoValidacion2 = SEG_wsRoboticsCasosPost.validarDatosEntradaCasosHijosPOST (null, dataInput);
        Map<String,String> resultadoValidacion3 = SEG_wsRoboticsCasosPost.validarDatosEntradaCasosHijosPOST (resultado.casoId, null);
        Map<String,String> resultadoValidacion4 = SEG_wsRoboticsCasosPost.validarDatosEntradaCasosHijosPOST (resultado.casoId + 'ZZ', dataInput);
        
        dataInput.clasificacionRapida = 'CRXXXX';
        Map<String,String> resultadoValidacion5 = SEG_wsRoboticsCasosPost.validarDatosEntradaCasosHijosPOST (resultado.casoId, dataInput);
        
        dataInput.clasificacionRapida = 'CR1';
        listaFicheros.add('XXXXX');
        Map<String,String> resultadoValidacion6 = SEG_wsRoboticsCasosPost.validarDatosEntradaCasosHijosPOST (resultado.casoId, dataInput);
        
        // Quitar link.
        delete linkFichero;
        listaFicheros.clear();
        listaFicheros.add(ficheroSFDC.Id);
        Map<String,String> resultadoValidacion7 = SEG_wsRoboticsCasosPost.validarDatosEntradaCasosHijosPOST (resultado.casoId, dataInput);

        Test.stopTest();

		System.assert(resultado.codigo == '0000');
        System.assert(resultado.resultado == 'OK');
        System.assert(!resultadoValidacion.isEmpty());
        System.assert(resultadoValidacion.get('resultado') =='OK');
        System.assert(!resultadoValidacion2.isEmpty());
        System.assert(resultadoValidacion2.get('resultado')=='NOK');
        System.assert(!resultadoValidacion3.isEmpty());
        System.assert(resultadoValidacion3.get('resultado')=='NOK');
        System.assert(!resultadoValidacion4.isEmpty());
        System.assert(resultadoValidacion4.get('resultado')=='NOK');
        System.assert(!resultadoValidacion5.isEmpty());
        System.assert(resultadoValidacion5.get('resultado')=='OK');
        System.assert(resultadoValidacion5.get('PAKresultado')=='PAK');
        System.assert(!resultadoValidacion6.isEmpty());
        System.assert(resultadoValidacion6.get('resultado')=='OK');
        System.assert(resultadoValidacion6.get('PAKresultado')=='PAK');
        System.assert(!resultadoValidacion7.isEmpty());
        System.assert(resultadoValidacion7.get('resultado')=='OK');
        System.assert(resultadoValidacion7.get('PAKresultado')=='PAK');
    }
    }
    
    @isTest
    public static void crearCasoHijoHttpPostOK()
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
        
       	SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultado = SEG_wsRoboticsCasosPost.crearCasoHttpPost(req);
        
           System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        
        SEG_wsRoboticsCasosPost.SEG_WS_NewChildCase_PostInput dataInput = new SEG_wsRoboticsCasosPost.SEG_WS_NewChildCase_PostInput();
        dataInput.clasificacionRapida = 'CR1';
        dataInput.listadoDocumentosIds = new List<String>();
        
        RestRequest req2 = new RestRequest();
        RestResponse res2 = new RestResponse();
        req2.requestURI = '/v1/segRoboticsCases/' + resultado.casoId + '/createChildCase';
        req2.httpMethod = 'POST';
        req2.requestBody = Blob.valueOf(JSON.serialize(dataInput));
        RestContext.request = req2;
        RestContext.response = res2;
        
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultadoHijo = SEG_wsRoboticsCasosPost.crearCasoHijoHttpPost (resultado.casoId, req2);
        
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultadoHijo2 = SEG_wsRoboticsCasosPost.crearCasoHijoHttpPost (null, req2);
        
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultadoHijo3 = SEG_wsRoboticsCasosPost.crearCasoHijoHttpPost (resultado.casoId, null);
        
        SEG_wsRoboticsCasosPost.SEG_WS_NewCase_PostOutput resultadoHijo4 = SEG_wsRoboticsCasosPost.crearCasoHijoHttpPost (resultadoHijo.casoId, req2);
        Test.stopTest();

		System.assert(resultado.codigo == '0000');
        System.assert(resultado.resultado == 'OK');
        
		System.assert(resultadoHijo.codigo == '0000');
        System.assert(resultadoHijo.resultado == 'OK');
        
		System.assert(resultadoHijo2.codigo != '0000');
        System.assert(resultadoHijo2.resultado != 'OK');
        
		System.assert(resultadoHijo3.codigo != '0000');
        System.assert(resultadoHijo3.resultado != 'OK');
        
		System.assert(resultadoHijo4.codigo != '0000');
        System.assert(resultadoHijo4.resultado != 'OK');
           }
    }

    @isTest
    public static void validarMCCyCR_tematica()
    {        
        Map<String,String> datosMCC = new Map<String,String>();
        Map<String,String> datosCR = new Map<String,String>();

        datosMCC.put('tematicaMCC','tematicaMCC2'); 
        datosCR.put('tematicaMCC','tematicaMCC3'); 

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        Map<String,String> resultado = SEG_wsRoboticsCasosPost.validarMCCyCR(datosMCC,datosCR);
        Test.stopTest();
        
        System.assertNotEquals(resultado,null,'El resultado está vacío');
        }
    }

    @isTest
    public static void validarMCCyCR_producto()
    {        
        Map<String,String> datosMCC = new Map<String,String>();
        Map<String,String> datosCR = new Map<String,String>();

        datosMCC.put('productoMCC','productoMCC2');
        datosCR.put('productoMCC','productoMCC23');
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        Map<String,String> resultado = SEG_wsRoboticsCasosPost.validarMCCyCR(datosMCC,datosCR);
        Test.stopTest();
        
        System.assertNotEquals(resultado,null,'El resultado está vacío');
        }
    }

    @isTest
    public static void validarMCCyCR_motivo()
    {        
        Map<String,String> datosMCC = new Map<String,String>();
        Map<String,String> datosCR = new Map<String,String>();
        
        datosMCC.put('motivoMCC','motivoMCC2');
        datosCR.put('motivoMCC','motivoMCC23'); 

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        Map<String,String> resultado = SEG_wsRoboticsCasosPost.validarMCCyCR(datosMCC,datosCR);
        Test.stopTest();
        
        System.assertNotEquals(resultado,null,'El resultado está vacío');
        }
    }

    @isTest
    public static void validarMCCyCR_detalle()
    {        
        Map<String,String> datosMCC = new Map<String,String>();
        Map<String,String> datosCR = new Map<String,String>();

        datosMCC.put('detalleMCC','detalleMCC2');
        datosCR.put('detalleMCC','detalleMCC23'); 

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        Map<String,String> resultado = SEG_wsRoboticsCasosPost.validarMCCyCR(datosMCC,datosCR);
        Test.stopTest();
        
        System.assertNotEquals(resultado,null,'El resultado está vacío');
        }
    }

    @isTest
    public static void validarMCCyCR_else()
    {        
        Map<String,String> datosMCC = new Map<String,String>();
        Map<String,String> datosCR = new Map<String,String>();

        datosMCC.put('tematicaMCC','tematicaMCC2'); 
        datosMCC.put('productoMCC','productoMCC2');
        datosMCC.put('motivoMCC','motivoMCC2');
        datosMCC.put('detalleMCC','detalleMCC2');

        datosCR.put('tematicaMCC','tematicaMCC2'); 
        datosCR.put('productoMCC','productoMCC2');
        datosCR.put('motivoMCC','motivoMCC2'); 
        datosCR.put('detalleMCC','detalleMCC2'); 

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        Test.startTest();
        Map<String,String> resultado = SEG_wsRoboticsCasosPost.validarMCCyCR(datosMCC,datosCR);
        Test.stopTest();
        
        System.assertNotEquals(resultado,null,'El resultado está vacío');
        }
    }   
}