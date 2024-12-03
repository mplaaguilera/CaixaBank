@isTest
public with sharing class SEG_wsRoboticsCasosPut_v2_Test {
    @testSetup
    static void datosIniciales ()
    { 
        Id recordDet = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
        Id grColId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        Id grColSegmentosId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        Id recordTypeSEG = Schema.SObjectType.SEG_Auditoria__c.getRecordTypeInfosByDeveloperName().get('SEG_Auditorias').getRecordTypeId(); 


        

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
        grupoRTGrupoCol.RecordTypeId = grColSegmentosId;
        grupoRTGrupoCol.OS_Negocio__c = 'SEGMENTOS';
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
        regla1.SEG_CRAuditoria__c = true;
        regla1.CBK_Negocio__c = 'Segmentos';
        insert regla1;

        SEG_ClasificacionRapida__c regla2 = new SEG_ClasificacionRapida__c();
        regla2.Name = 'CR2';
        regla2.SEG_Tematica__c = mccTematica2.Id;
        regla2.SEG_Producto__c = mccProducto2.Id;
        regla2.SEG_Motivo__c = mccMotivo2.Id;
        regla2.SEG_Detalle__c = mccDetalle2.Id;
        regla2.SEG_CRAuditoria__c = true;
        regla2.CBK_Negocio__c = 'Segmentos';
        insert regla2;
        
        // Crear grupo colaborador por defecto de Segmentos.
        CC_Grupo_Colaborador__c grupoRTGrupoSeg = new CC_Grupo_Colaborador__c();
        grupoRTGrupoSeg.Name='MCC 0029';
        grupoRTGrupoSeg.RecordTypeId = grColSegmentosId;
        grupoRTGrupoSeg.OS_Negocio__c = 'SEGMENTOS';
        grupoRTGrupoSeg.SEG_GrupoSegmentos__c = true;
        insert grupoRTGrupoSeg;
        
        // Crear grupo colaborador por defecto de Segmentos.
        CC_Grupo_Colaborador__c grupoRTGrupoSeg2 = new CC_Grupo_Colaborador__c();
        grupoRTGrupoSeg2.Name='MCC 0030';
        grupoRTGrupoSeg2.RecordTypeId = grColSegmentosId;
        grupoRTGrupoSeg2.OS_Negocio__c = 'SEGMENTOS';
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
        caso1.SEG_SRAuditoria__c = true;
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
        caso2.SEG_SRAuditoria__c = true;
        caso2.SEG_ClasificacionRapida__c = regla1.Id;
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.Status = 'Activo';
        caso2.Subject = 'test 2';
        caso2.SEG_Organizacion__c = 'Banca Corporativa';
        caso2.SEG_Zona__c = 'Corporativa';
        caso2.Origin = 'WebService';
        caso2.OwnerId=usuario.Id;
        caso2.SEG_Grupo__c = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name='MCC 0029'].Id;
        caso2.SEG_N_operaciones_del_caso__c = 1;
        listadoCasos.add(caso2);
        
        Case caso3 = new Case();
        caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso3.AccountId = cuentaSEG1.Id;
        caso3.ContactId = contactoSEG1.Id;
        caso3.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso3.SEG_Idioma__c = 'es';
        caso3.CC_AcuseRecibo__c ='1';
        caso3.SEG_SRAuditoria__c = true;
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

        Case caso5 = new Case();
        caso5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso5.AccountId = cuentaSEG1.Id;
        caso5.ContactId = contactoSEG1.Id;
        caso5.CC_MailTelfNotif__c = contactoSEG1.Email;
        caso5.SEG_Idioma__c = 'es';
        caso5.CC_AcuseRecibo__c ='1';
        caso5.SEG_SRAuditoria__c = true;
        //caso5.ParentId = caso1.Id;
        caso5.CC_MCC_Tematica__c = mccTematica.Id;
        caso5.CC_MCC_ProdServ__c = mccProducto.Id;
        caso5.CC_MCC_Motivo__c = mccMotivo.Id;
        caso5.Status = 'a';
        caso5.CC_Detalles_Solucion__c = 'solución';
        caso5.Subject = 'test 5';
        caso5.SEG_Organizacion__c = 'Banca Corporativa';
        caso5.SEG_Zona__c = 'Corporativa';
        caso5.Origin = 'WebService';
        listadoCasos.add(caso5);

        insert listadoCasos;

        List<Seg_auditoria__c> listaAudit = new List<Seg_auditoria__c>();
        Seg_auditoria__c segauditoriacObj = new Seg_auditoria__c (
			SEG_NumeroSR__c = caso2.Id, 
			SEG_Resultado__c = 'test auditoria',
            SEG_NIF__c = '11111111H',
            SEG_FechaAuditoria__c= System.today(),
            RecordTypeId = recordTypeSEG
		);
        listaAudit.add(segauditoriacObj);
        segauditoriacObj = new Seg_auditoria__c (
			SEG_NumeroSR__c = caso1.Id, 
			SEG_Resultado__c = 'test auditoria',
            SEG_NIF__c = '11111111I',
            SEG_FechaAuditoria__c= System.today(),
            RecordTypeId = recordTypeSEG
		);
        listaAudit.add(segauditoriacObj);

        segauditoriacObj = new Seg_auditoria__c (
			SEG_NumeroSR__c = caso3.Id, 
			SEG_Resultado__c = 'test auditoria',
            SEG_NIF__c = '11111111J',
            SEG_FechaAuditoria__c= System.today(),
            RecordTypeId = recordTypeSEG
		);
        listaAudit.add(segauditoriacObj);
        segauditoriacObj = new Seg_auditoria__c (
			SEG_NumeroSR__c = caso5.Id, 
			SEG_Resultado__c = 'test auditoria',
            SEG_NIF__c = '11111111K',
            SEG_FechaAuditoria__c= System.today(),
            RecordTypeId = recordTypeSEG
		);
        listaAudit.add(segauditoriacObj);
        insert listaAudit;

    }
    
    @isTest
    public static void constructorOut ()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutOutput dataRes = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutOutput();
        dataRes.codigo = 'codigo';
        dataRes.mensaje = 'mensaje';
        dataRes.resultado = 'resultado';
        
        // Sin Assert.
        System.assert(dataRes != null);
    }
    
    @isTest
    public static void actualizarCasoPut_1()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();
        datosEntrada.numeroOperacionesCSO = 4;
        datosEntrada.usuarioCSO = 'U01123456';
        datosEntrada.estado = 'Cerrado';
        datosEntrada.resultadoCierreCaso = 'cerrado';
        datosEntrada.asunto = 'asunto';
        datosEntrada.cuerpo = 'cuerpo';
        datosEntrada.grupoTrabajo = 'MCC 0030';
        datosEntrada.propietarioCaso = '';
        datosEntrada.fechaPlanificacion = Datetime.now().addMonths(5);
        datosEntrada.fechaValor = Datetime.now().addMonths(5);
        datosEntrada.estadoAuditoria = 'OK';
        datosEntrada.motivoErrorAuditoria = '';
        datosEntrada.cifAuditoria = '11111111H';
        datosEntrada.fechaAuditoria = String.valueOf(System.today().month()).leftPad(2,'0') + '/' + String.valueOf(System.today().year());//System.today();
        datosEntrada.clasificacionRapida = 'CR1';
        datosEntrada.mccTematica = 'Tematica1';
        datosEntrada.mccProducto = 'Producto1';
        datosEntrada.mccMotivo = 'Motivo1';
        datosEntrada.mccDetalle = 'Detalle1';
        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];

        Test.startTest();
        
        	Map<String,String> datosValidados = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);  
        	
        	Map<String,String> resultado = SEG_wsRoboticsCasosPut_v2.actualizarCasoSalesforce(datosEntrada, datosValidados);

        Test.stopTest();

        System.assert(resultado != null);
		//System.assert(resultado.get('codigo') == 'OK');
    }
    
    @isTest
    public static void actualizarCasoPut_2_SOLOMCC()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();
        datosEntrada.numeroOperacionesCSO = 4;
        datosEntrada.usuarioCSO = 'U01123456';
        //datosEntrada.estado = 'Cerrado';
        datosEntrada.resultadoCierreCaso = 'cerrado';
        datosEntrada.asunto = 'asunto';
        datosEntrada.cuerpo = 'cuerpo';
        datosEntrada.grupoTrabajo = 'MCC 0030';
        datosEntrada.propietarioCaso = '';
        datosEntrada.fechaPlanificacion = Datetime.now().addMonths(5);
        datosEntrada.fechaValor = Datetime.now().addMonths(5);
        datosEntrada.estadoAuditoria = 'OK';
        datosEntrada.motivoErrorAuditoria = '';
        datosEntrada.cifAuditoria = '11111111H';
        datosEntrada.fechaAuditoria = String.valueOf(System.today().month()).leftPad(2,'0') + '/' + String.valueOf(System.today().year());//System.today();
        datosEntrada.clasificacionRapida = '';
        datosEntrada.mccTematica = 'Tematica2';
        datosEntrada.mccProducto = 'Producto2';
        datosEntrada.mccMotivo = 'Motivo2';
        datosEntrada.mccDetalle = 'Detalle2';
        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];

        Test.startTest();
        
        	Map<String,String> datosValidados = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);  
        	
        	Map<String,String> resultado = SEG_wsRoboticsCasosPut_v2.actualizarCasoSalesforce(datosEntrada, datosValidados);

        Test.stopTest();

        System.assert(resultado != null);
		//System.assert(resultado.get('codigo') == 'OK');
    } 
    
    @isTest
    public static void actualizarCasoPut_3_SOLOCR()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();
        datosEntrada.numeroOperacionesCSO = 4;
        datosEntrada.usuarioCSO = 'U01123456';
        //datosEntrada.estado = 'Cerrado';
        datosEntrada.resultadoCierreCaso = 'cerrado';
        datosEntrada.asunto = 'asunto';
        datosEntrada.cuerpo = 'cuerpo';
        datosEntrada.grupoTrabajo = 'MCC 0030';
        datosEntrada.propietarioCaso = '';
        datosEntrada.fechaPlanificacion = Datetime.now().addMonths(5);
        datosEntrada.fechaValor = Datetime.now().addMonths(5);
        datosEntrada.estadoAuditoria = 'OK';
        datosEntrada.motivoErrorAuditoria = '';
        datosEntrada.cifAuditoria = '11111111H';
        datosEntrada.fechaAuditoria = String.valueOf(System.today().month()).leftPad(2,'0') + '/' + String.valueOf(System.today().year());//System.today();
        datosEntrada.clasificacionRapida = 'CR2';
        datosEntrada.mccTematica = '';
        datosEntrada.mccProducto = '';
        datosEntrada.mccMotivo = '';
        datosEntrada.mccDetalle = '';
        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];

        Test.startTest();
        
        	Map<String,String> datosValidados = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);  
        	
        	Map<String,String> resultado = SEG_wsRoboticsCasosPut_v2.actualizarCasoSalesforce(datosEntrada, datosValidados);

        Test.stopTest();

        System.assert(resultado != null);
		//System.assert(resultado.get('codigo') == 'OK');
    } 
    
    @isTest
    public static void datosEntradaNull()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada;
        Test.startTest();        
        	Map<String,String> datosValidados = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, null);
        
        	datosEntrada = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();
	        Map<String,String> datosValidados2 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, null);
        Test.stopTest();       
        System.assert(datosValidados.get('resultado') == 'NOK');
        System.assert(datosValidados.get('codigo') == '0000');
        System.assert(datosValidados2.get('resultado') == 'NOK');
        System.assert(datosValidados2.get('codigo') == '0001');
    }
    
    @isTest
    public static void actualizarCasoPut_validacionesCSOKO()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();
        datosEntrada.numeroOperacionesCSO = 4;
        datosEntrada.usuarioCSO = '';
        //datosEntrada.estado = 'Cerrado';
        datosEntrada.resultadoCierreCaso = 'cerrado';
        datosEntrada.asunto = 'asunto';
        datosEntrada.cuerpo = 'cuerpo';
        datosEntrada.grupoTrabajo = 'MCC 0030';
        datosEntrada.propietarioCaso = '';
        datosEntrada.fechaPlanificacion = Datetime.now().addMonths(5);
        datosEntrada.fechaValor = Datetime.now().addMonths(5);
        datosEntrada.estadoAuditoria = 'OK';
        datosEntrada.motivoErrorAuditoria = '';
        datosEntrada.cifAuditoria = '11111111H';
        datosEntrada.fechaAuditoria = String.valueOf(System.today().month()).leftPad(2,'0') + '/' + String.valueOf(System.today().year());//System.today();
        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        List<Case> listaCasos2 = [SELECT Id FROM Case WHERE Subject = 'test 1'];
        List<Case> listaCasos3 = [SELECT Id FROM Case WHERE Subject = 'test 3'];
        List<Case> listaCasos4 = [SELECT Id FROM Case WHERE Subject = 'test 5'];

        Test.startTest();

        
        
        	Map<String,String> datosValidados = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);
      
        	datosEntrada.usuarioCSO = 'U01123456';
        	datosEntrada.numeroOperacionesCSO = null;
        	Map<String,String> datosValidados2 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);
        	
        	datosEntrada.usuarioCSO = 'U01123456';
        	datosEntrada.numeroOperacionesCSO = 0;
        	Map<String,String> datosValidados3 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);
        	
        	datosEntrada.usuarioCSO = 'U01123456';
        	datosEntrada.numeroOperacionesCSO = 3;
            datosEntrada.estado = 'Activo';
            datosEntrada.resultadoCierreCaso = '';
            datosEntrada.cifAuditoria = '11111111I';
        	Map<String,String> datosValidados4 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos2[0].Id);
        
            
            datosEntrada.estado = '';
            datosEntrada.resultadoCierreCaso = '';
            datosEntrada.cifAuditoria = '11111111J';
          	Map<String,String> datosValidados5 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos3[0].Id);

          
            datosEntrada.usuarioCSO = 'U01123456';
        	datosEntrada.numeroOperacionesCSO = 3;
            datosEntrada.estado = 'a';
            datosEntrada.resultadoCierreCaso = '';
            datosEntrada.cifAuditoria = '11111111K';
        	Map<String,String> datosValidados7 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos4[0].Id);
        
        Test.stopTest();

        System.assert(datosValidados.get('resultado') == 'NOK');
       
        System.assert(datosValidados2.get('resultado') == 'NOK');
       
        System.assert(datosValidados3.get('resultado') == 'NOK');
        System.assert(datosValidados4.get('resultado') == 'NOK');
        System.assert(datosValidados5.get('resultado') == 'NOK');
        System.assert(datosValidados7.get('resultado') == 'NOK');
        
    }
    
    @isTest
    public static void actualizarCasoPut_validacionesAuditoriaControlesKO()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();
        datosEntrada.numeroOperacionesCSO = 4;
        datosEntrada.usuarioCSO = 'U01123456';
        //datosEntrada.estado = 'Cerrado';
        datosEntrada.resultadoCierreCaso = 'cerrado';
        datosEntrada.asunto = 'asunto';
        datosEntrada.cuerpo = 'cuerpo';
        datosEntrada.grupoTrabajo = '';
        datosEntrada.propietarioCaso = '';
        datosEntrada.fechaPlanificacion = Datetime.now().addMonths(5);
        datosEntrada.fechaValor = Datetime.now().addMonths(5);
        datosEntrada.estadoAuditoria = 'NOK';
        datosEntrada.motivoErrorAuditoria = '';
        datosEntrada.cifAuditoria = '11111111Y';
        datosEntrada.fechaAuditoria = String.valueOf(System.today().month()).leftPad(2,'0') + '/' + String.valueOf(System.today().year());//System.today();
        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];

        Test.startTest();
        
            Map<String,String> datosValidados = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);
            datosEntrada.cifAuditoria='11111111Y';
            datosEntrada.estadoAuditoria = 'OK';
	        Map<String,String> datosValidados3 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);
        	datosEntrada.cifAuditoria = '11111111H';
        	datosEntrada.estadoAuditoria = 'OK';
	        Map<String,String> datosValidados2 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);

        Test.stopTest();

		System.assert(datosValidados.get('resultado') == 'NOK');
        System.assert(datosValidados3.get('resultado') == 'PAK');
        System.assert(datosValidados2.get('resultado') == 'OK');
    }
    
    @isTest
    public static void actualizarCasoPut_validacionesPropietarioKO()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();
        datosEntrada.numeroOperacionesCSO = 4;
        datosEntrada.usuarioCSO = 'U01123456';
        //datosEntrada.estado = 'Cerrado';
        datosEntrada.resultadoCierreCaso = 'cerrado';
        datosEntrada.asunto = 'asunto';
        datosEntrada.cuerpo = 'cuerpo';
        datosEntrada.grupoTrabajo = '';
        datosEntrada.propietarioCaso = 'NO EXISTE';
        datosEntrada.fechaPlanificacion = Datetime.now().addMonths(5);
        datosEntrada.fechaValor = Datetime.now().addMonths(5);
        datosEntrada.estadoAuditoria = 'OK';
        datosEntrada.motivoErrorAuditoria = '';
        datosEntrada.cifAuditoria = '11111111H';
        datosEntrada.fechaAuditoria = String.valueOf(System.today().month()).leftPad(2,'0') + '/' + String.valueOf(System.today().year());//System.today();
        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];
        List<Case> listaCasos2 = [SELECT Id FROM Case WHERE Subject = 'test 4'];

        Test.startTest();
        
        	Map<String,String> datosValidados = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos2[0].Id);
        
	        Map<String,String> datosValidados2 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);
        
        	datosEntrada.propietarioCaso = 'U01123456';
	        Map<String,String> datosValidados3 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);

        Test.stopTest();

		System.assert(datosValidados.get('resultado') == 'NOK');
        System.assert(datosValidados2.get('resultado') == 'NOK');
        System.assert(datosValidados3.get('resultado') == 'NOK');
    }
    
    @isTest
    public static void actualizarCasoPut_validacionesFechasKO()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();
        datosEntrada.numeroOperacionesCSO = 4;
        datosEntrada.usuarioCSO = 'U01123456';
        //datosEntrada.estado = 'Cerrado';
        datosEntrada.resultadoCierreCaso = 'cerrado';
        datosEntrada.asunto = 'asunto';
        datosEntrada.cuerpo = 'cuerpo';
        datosEntrada.grupoTrabajo = 'MCC 0030';
        datosEntrada.propietarioCaso = '';
        datosEntrada.fechaPlanificacion = Datetime.now().addMonths(-5);
        datosEntrada.fechaValor = Datetime.now().addMonths(5);
        datosEntrada.estadoAuditoria = 'OK';
        datosEntrada.motivoErrorAuditoria = '';
        datosEntrada.cifAuditoria = '11111111H';
        datosEntrada.fechaAuditoria = String.valueOf(System.today().month()).leftPad(2,'0') + '/' + String.valueOf(System.today().year());//System.today();
        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];

        Test.startTest();
        
        	Map<String,String> datosValidados = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);
        
            datosEntrada.fechaPlanificacion = null;
            datosEntrada.fechaValor = Datetime.now().addMonths(-5);
        	Map<String,String> datosValidados2 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);

        Test.stopTest();

		System.assert(datosValidados.get('resultado') == 'NOK');
        System.assert(datosValidados2.get('resultado') == 'NOK');
    }
    
    @isTest
    public static void actualizarCasoPut_validacionesGrupoKO()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();
        datosEntrada.numeroOperacionesCSO = 4;
        datosEntrada.usuarioCSO = 'U01123456';
        //datosEntrada.estado = 'Cerrado';
        datosEntrada.resultadoCierreCaso = 'cerrado';
        datosEntrada.asunto = 'asunto';
        datosEntrada.cuerpo = 'cuerpo';
        datosEntrada.grupoTrabajo = 'MCC 0029 NO EXISTE';
        datosEntrada.propietarioCaso = '';
        datosEntrada.fechaPlanificacion = Datetime.now().addMonths(5);
        datosEntrada.fechaValor = Datetime.now().addMonths(5);
        datosEntrada.estadoAuditoria = 'OK';
        datosEntrada.motivoErrorAuditoria = '';
        datosEntrada.cifAuditoria = '11111111H';
        datosEntrada.fechaAuditoria = String.valueOf(System.today().month()).leftPad(2,'0') + '/' + String.valueOf(System.today().year());//System.today();
        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];

        Test.startTest();
        
        	Map<String,String> datosValidados = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);
        
        	datosEntrada.grupoTrabajo = 'MCC 0030';
        	datosEntrada.propietarioCaso = 'NO EXISTE';
        	Map<String,String> datosValidados2 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);

        Test.stopTest();

		System.assert(datosValidados.get('resultado') == 'NOK');
        System.assert(datosValidados2.get('resultado') == 'NOK');
    }
    
    @isTest
    public static void actualizarCasoPut_validacionesEstadoKO()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();
        datosEntrada.numeroOperacionesCSO = 4;
        datosEntrada.usuarioCSO = 'U01123456';
        datosEntrada.estado = 'NO EXISTE';
        datosEntrada.resultadoCierreCaso = 'cerrado';
        datosEntrada.asunto = 'asunto';
        datosEntrada.cuerpo = 'cuerpo';
        datosEntrada.grupoTrabajo = 'MCC 0029';
        datosEntrada.propietarioCaso = '';
        datosEntrada.fechaPlanificacion = Datetime.now().addMonths(5);
        datosEntrada.fechaValor = Datetime.now().addMonths(5);
        datosEntrada.estadoAuditoria = 'OK';
        datosEntrada.motivoErrorAuditoria = '';
        datosEntrada.cifAuditoria = '11111111H';
        datosEntrada.fechaAuditoria = String.valueOf(System.today().month()).leftPad(2,'0') + '/' + String.valueOf(System.today().year());//System.today();
        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];

        Test.startTest();
        
        	Map<String,String> datosValidados = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);
        
            datosEntrada.estado = 'Cerrado';
            datosEntrada.resultadoCierreCaso = '';
        	Map<String,String> datosValidados2 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);
        
            datosEntrada.estado = 'Activo';
            datosEntrada.resultadoCierreCaso = '';
        	Map<String,String> datosValidados3 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);

        Test.stopTest();

		System.assert(datosValidados.get('resultado') == 'NOK');
        System.assert(datosValidados2.get('resultado') == 'NOK');
        System.assert(datosValidados3.get('resultado') == 'NOK');
    }
    
    @isTest
    public static void actualizarCasoPut_validacionesNULLKO()
    {        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];

        Test.startTest();
        
        	Map<String,String> datosValidados = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(null, listaCasos[0].Id);

        Test.stopTest();

		System.assert(datosValidados.get('resultado') == 'NOK');
    }
    
    @isTest
    public static void actualizarCasoPut_MCCyCR_KO()
    {
        SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();
        datosEntrada.clasificacionRapida = 'CR2';
        datosEntrada.mccTematica = 'Tematica1';
        datosEntrada.mccProducto = 'Producto1';
        datosEntrada.mccMotivo = 'Motivo1';
        datosEntrada.mccDetalle = 'Detalle1';
        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];

        Test.startTest();
        
        	Map<String,String> datosValidados = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);  
        
            datosEntrada.clasificacionRapida = 'CRNOEXISTE';
            datosEntrada.mccTematica = '';
            datosEntrada.mccProducto = '';
            datosEntrada.mccMotivo = '';
            datosEntrada.mccDetalle = '';
        	Map<String,String> datosValidados2 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);  
        
            datosEntrada.clasificacionRapida = '';
            datosEntrada.mccTematica = 'INVENTADO';
            datosEntrada.mccProducto = 'INVENTADO';
            datosEntrada.mccMotivo = 'INVENTADO';
            datosEntrada.mccDetalle = 'INVENTADO';
        	Map<String,String> datosValidados3 = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);  

        Test.stopTest();

		System.assert(datosValidados.get('resultado') == 'NOK');
        System.assert(datosValidados2.get('resultado') == 'NOK');
        System.assert(datosValidados3.get('resultado') == 'NOK');
    }

    @isTest
    public static void actualizarCasoPutMCCyCROK()
    {
        User usuarioTest =[SELECT Id FROM User WHERE EmployeeNumber ='U01123456'];
        System.runAs (usuarioTest) {
            SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput datosEntrada = new SEG_wsRoboticsCasosPut_v2.SEG_WS_NewCase_PutInput();
            datosEntrada.clasificacionRapida = 'CR1';
            datosEntrada.mccTematica = 'Tematica1';
            datosEntrada.mccProducto = 'Producto1';
            datosEntrada.mccMotivo = 'Motivo1';
            datosEntrada.mccDetalle = 'Detalle1';
            
            List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 2'];

            Test.startTest();
            
                Map<String,String> datosValidados = SEG_wsRoboticsCasosPut_v2.validarDatosEntradaPUT(datosEntrada, listaCasos[0].Id);  
            
                
                
            Test.stopTest();
            System.assert(datosValidados.get('resultado') == 'OK');
        }

    }
}