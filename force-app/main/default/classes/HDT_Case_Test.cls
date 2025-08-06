@isTest
public with sharing class HDT_Case_Test {

    @TestSetup
    static void makeData() {

        //crear usuarios CC
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_Operador'];
        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        usuario1.FirstName = 'first 1';
        usuario1.LastName = 'last1';
        usuario1.Email = 'tuser000@amamama.com';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        userList.add(usuario1);

        User usuario2 = new User();
        usuario2.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        usuario2.FirstName = 'first2';
        usuario2.LastName = 'last2';
        usuario2.Email = 'tuser000@amamama.com';
        usuario2.Username = 'tuser002@amamama.com' + System.currentTimeMillis();
        usuario2.CompanyName = 'DXC';
        usuario2.Title = 'title';
        usuario2.Alias = 'alias';
        usuario2.TimeZoneSidKey = 'Europe/Paris';
        usuario2.EmailEncodingKey = 'UTF-8';
        usuario2.LanguageLocaleKey = 'es';
        usuario2.LocaleSidKey = 'es_ES';
        userList.add(usuario2);

        User usuario3 = new User();
        usuario3.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        usuario3.FirstName = 'first3';
        usuario3.LastName = 'last3';
        usuario3.Email = 'tuser000@amamama.com';
        usuario3.Username = 'tuser003@amamama.com' + System.currentTimeMillis();
        usuario3.CompanyName = 'INDRA';
        usuario3.Title = 'title';
        usuario3.Alias = 'alias';
        usuario3.TimeZoneSidKey = 'Europe/Paris';
        usuario3.EmailEncodingKey = 'UTF-8';
        usuario3.LanguageLocaleKey = 'es';
        usuario3.LocaleSidKey = 'es_ES';
        userList.add(usuario3);
        insert userList;
        insert new PermissionSetAssignment(AssigneeId = usuario1.Id, PermissionSetId = ps.Id);
        insert new PermissionSetAssignment(AssigneeId = usuario2.Id, PermissionSetId = ps.Id);
        insert new PermissionSetAssignment(AssigneeId = usuario3.Id, PermissionSetId = ps.Id);

    }

    @isTest
    static void testCrearCaso() {
        // Crear un nuevo caso sin campos adicionales
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Case caso = new Case();
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
      
        Case caso1 = HDT_Case.crearCaso('HDT_Empleado');
       // System.assertEquals('HDT_Empleado', caso1.RecordType.DeveloperName);
        
        // Crear un nuevo caso con campos adicionales
        Map<String, Object> campos = new Map<String, Object>{
            'Subject' => 'Prueba de caso',
            'Description' => 'Este es un caso de prueba'
        };

        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            Case caso2 = HDT_Case.crearCaso('CC_Empleado', campos);
            System.assertEquals(null, caso2.RecordType.DeveloperName);
            System.assertEquals('Prueba de caso', caso2.Subject);
            System.assertEquals('Este es un caso de prueba', caso2.Description);
            //System.assertEquals('Valor personalizado', caso2.Id);
        }

        
       }
    }


    @isTest
    public static void testReapertura() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
        
            

        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.Status = 'Cerrado';
        caso.CC_Detalles_Consulta__c = 'blabla';
        caso.CC_Detalles_Solucion__c = 'blabla';
        insert caso;

        Test.startTest();
       // System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            HDT_Case.reapertura(caso.Id, 'Actividad de reapertura Test');
       // }

        
        Test.stopTest();

        caso = [SELECT Status FROM Case WHERE Id = :caso.Id];
        System.assertEquals(caso.Status, 'Activo');
        System.assertEquals(0, [SELECT Count() FROM Task WHERE WhatId = :caso.Id AND Type = 'Reapertura']);
        }
    }

    @isTest
    public static void testHistoricoCorreosCliente() {
        //Marc Pla, 18 de julio de 2019
        //Comprueba que se devuelve el histórico de correos de un caso
        //teniendo en cuenta si son o no internos

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
        //Preparación de los datos
        Case caso = new Case();
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.Subject = 'Caso Test';
        insert caso;

        Task actividadCorreo1 = new Task();
        actividadCorreo1.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        actividadCorreo1.WhatId = caso.Id;

        Task actividadCorreo2 = new Task();
        actividadCorreo2.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        actividadCorreo2.WhatId = caso.Id;

        Task actividadCorreo3 = new Task();
        actividadCorreo3.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        actividadCorreo3.WhatId = caso.Id;

        insert new List<Task>{actividadCorreo1, actividadCorreo2, actividadCorreo3};

        EmailMessage correo1 = new EmailMessage();
        correo1.ParentId = caso.Id;
        correo1.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo1.ActivityId = actividadCorreo1.Id;
        correo1.Incoming = true;
        correo1.CC_Interno__c = false;
        correo1.CcAddress = 'to@test.com';
        correo1.MessageDate = System.now();
        correo1.ToAddress = 'to@test.com';
        correo1.Subject = 'Correo no interno 1 Test';
        correo1.HtmlBody = 'Correo no interno 1 Test';

        EmailMessage correo2 = new EmailMessage();
        correo2.ParentId = caso.Id;
        correo2.ActivityId = actividadCorreo2.Id;
        correo2.Incoming = true;
        correo1.CcAddress = 'to@test.com';
        correo2.CC_Interno__c = false;
        correo2.MessageDate = System.now();
        correo2.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo2.ToAddress = 'to@test.com';
        correo2.Subject = 'Correo  no interno 2 Test';
        correo2.HtmlBody = 'Correo no interno 2 Test';

        EmailMessage correo3 = new EmailMessage();
        correo3.ParentId = caso.Id;
        correo1.CcAddress = 'to@test.com';
        correo3.ActivityId = actividadCorreo3.Id;
        correo3.Incoming = false;
        correo3.CC_Interno__c = true;
        correo3.MessageDate = System.now();
        correo3.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo3.ToAddress = 'to@test.com';
        correo3.Subject = 'Correo interno 3 Test';
        correo3.HtmlBody = 'Correo interno 3 Test';

        insert new List<EmailMessage>{correo1, correo2, correo3};
        //Ejecución de la prueba
        Test.startTest();
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {

        String historicoConInternos = HDT_Case.historicoCorreosCliente(caso.Id, true);
        //System.assert(!historicoConInternos.contains('Correo interno 3 Test'));
        String historicoSinInternos = HDT_Case.historicoCorreosCliente(caso.Id, false);
        System.assert(!historicoSinInternos.contains('Correo interno 3 Test'));
        }
        Test.stopTest();
        }
    }

    @isTest
    public static void testHistoricoCorreosClienteCops() {
        //Nerea Sanchez, 12 de noviembre de 2021
        //Comprueba que se devuelve el histórico de correos de un caso de Cops
        //teniendo en cuenta si son o no internos

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        //Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        insert caso;

        Task actividadCorreo1 = new Task();
        actividadCorreo1.WhatId = caso.Id;

        Task actividadCorreo2 = new Task();
        actividadCorreo2.WhatId = caso.Id;


        Task actividadCorreo3 = new Task();
        actividadCorreo3.WhatId = caso.Id;

        insert new List<Task>{actividadCorreo1, actividadCorreo2, actividadCorreo3};

        EmailMessage correo1 = new EmailMessage();
        correo1.ParentId = caso.Id;
        correo1.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo1.ActivityId = actividadCorreo1.Id;
        correo1.Incoming = true;
        correo1.CC_Interno__c = false;
        correo1.MessageDate = System.now();
        correo1.ToAddress = 'to@test.com';
        correo1.Subject = 'Correo no interno 1 Test';
        correo1.HtmlBody = 'Correo no interno 1 Test';

        EmailMessage correo2 = new EmailMessage();
        correo2.ParentId = caso.Id;
        correo2.ActivityId = actividadCorreo2.Id;
        correo2.Incoming = true;
        correo2.CC_Interno__c = true;
        correo2.MessageDate = System.now();
        correo2.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo2.ToAddress = 'to@test.com';
        correo2.Subject = 'Correo interno 2 Test';
        correo2.HtmlBody = 'Correo interno 2 Test';

        EmailMessage correo3 = new EmailMessage();
        correo3.ParentId = caso.Id;
        correo3.ActivityId = actividadCorreo3.Id;
        correo3.Incoming = false;
        correo3.CC_Interno__c = false;
        correo3.MessageDate = System.now();
        correo3.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo3.ToAddress = 'to@test.com';
        correo3.Subject = 'Correo no interno 3 Test';
        correo3.TextBody = 'Correo no interno 3 Test';

        insert new List<EmailMessage>{correo1, correo2, correo3};

        //Ejecución de la prueba
        Test.startTest();
        String historicoConInternos = '';
        String historicoSinInternosConTextoPlano = '';

        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            historicoConInternos = HDT_Case.historicoCorreosClienteCops(caso.Id, true);
            historicoSinInternosConTextoPlano = HDT_Case.historicoCorreosClienteCops(caso.Id, false);
        }

       
        Test.stopTest();

        //Evaluar resultado de la prueba
        //El histórico con internos debe contenter los 3 correos
        Boolean okHistoricoConInternos = historicoConInternos.contains('Correo no interno 1 Test');
        okHistoricoConInternos &= historicoConInternos.contains('Correo interno 2 Test');
        okHistoricoConInternos &= historicoConInternos.contains('Correo no interno 3 Test');
        System.assert(okHistoricoConInternos);

        //El histórico sin internos debe contenter los 2 no internos y no contener el interno
        Boolean okHistoricoSinInternos = historicoSinInternosConTextoPlano.contains('Correo no interno 1 Test');
        okHistoricoSinInternos &= !historicoSinInternosConTextoPlano.contains('Correo interno 2 Test');
        okHistoricoSinInternos &= historicoSinInternosConTextoPlano.contains('Correo no interno 3 Test');
        System.assert(okHistoricoSinInternos);
        }
    }

    @isTest
    public static void testCorreoInicialCliente() {

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
        //Comprueba que la información devuelta es del primer correo recibido
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        insert caso;

        Task actividadCorreo1 = new Task();
        actividadCorreo1.WhatId = caso.Id;
        insert actividadCorreo1;

        EmailMessage correo1 = new EmailMessage();
        correo1.ParentId = caso.Id;
        correo1.ActivityId = actividadCorreo1.Id;
        correo1.Incoming = true;
        correo1.MessageDate = Datetime.newInstance(2019, 7,  17, 12, 0, 0); //Miércoles
        correo1.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo1.ToAddress = 'to@test.com';
        correo1.Subject = 'Correo Test';
        correo1.HtmlBody = 'Correo Test';
        insert correo1;

        Task actividadCorreo2 = new Task();
        actividadCorreo2.WhatId = caso.Id;
        insert actividadCorreo2;

        EmailMessage correo2 = new EmailMessage();
        correo2.ParentId = caso.Id;
        correo2.ActivityId = actividadCorreo2.Id;
        correo2.Incoming = true;
        correo2.MessageDate = Datetime.newInstance(2019, 7,  18, 12, 0, 0); //Jueves
        correo2.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo2.ToAddress = 'to@test.com';
        correo2.Subject = 'Correo Test';
        correo2.HtmlBody = 'Correo Test';
        insert correo2;

        Test.startTest();
        String correoInicialCliente = '';
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            correoInicialCliente = HDT_Case.correoInicialCliente(caso.Id);
        }


        
        Test.stopTest();

        System.assert(correoInicialCliente.contains('Miércoles, 17 de Julio de 2019 12:00'));
        }
    }

    @isTest
    public static void testCrearActividadRetipificacion() {

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Tipo_Cliente__c = 'Empleado';
        tematica.Name = 'Temática Test';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        tematica.CC_Canal_Operativo__c = 'App CaixaBankPay';
        insert tematica;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.CC_Tipo_Cliente__c = 'Empleado';
        productoServicio.Name = 'Producto/Servicio Test';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tipo_Cliente__c = 'Empleado';
        motivo.Name = 'Motivo Test';
        motivo.CC_Producto_Servicio__c = productoServicio.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado');
        caso.Subject = 'Caso Test';
        caso.CC_Canal_Operativo__c = 'App CaixaBankPay';
        caso.CC_MCC_Tematica__c = tematica.Id;
        caso.CC_MCC_ProdServ__c = productoServicio.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;
        insert caso;

        Test.startTest();
        //System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            HDT_Case.crearActividadRetipificacion(caso.Id, 'tematicaAnterior', 'productoAnterior', 'motivoAnterior');
        //}


        
        Test.stopTest();

        Task actividadRetipificacion = [SELECT Status, Subject FROM Task WHERE WhatId = :caso.Id AND Type = 'Reclasificación' LIMIT 1];

        System.assertEquals('Completed', actividadRetipificacion.Status);
        System.assertEquals('Reclasificación del caso', actividadRetipificacion.Subject);
        }
    }
    
    @isTest
    public static void testRecuperarDatosCaso() {
        
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {


        Contact testContacto = new Contact();
        testContacto.FirstName = 'José María';
        testContacto.LastName = 'Martín Bernal';
        insert testContacto;
                
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.ContactId = testContacto.Id;
        insert caso;
        
        Test.startTest();
        Case resultadoLLamada;
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            resultadoLLamada = HDT_Case.getDatosCaso(caso.Id);
        }

       
        Test.stopTest();
        
        System.assertEquals('Caso Test', resultadoLLamada.Subject);
        System.assertEquals('José María Martín Bernal', resultadoLLamada.Contact.Name);
        }
    }

    /*@isTest
    private static void creacionRelacionCatalogoFacturacionCasoCambiosOwner() 
    {
        List<User> userList = [SELECT Id, CompanyName FROM User WHERE Email = 'tuser000@amamama.com'];

        Account cuenta = new Account();
        cuenta.Name = 'Smith';
        cuenta.CC_Numero_Documento__c = '64850344G';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.LastName = 'Smith';
        contacto.CC_Numero_Documento__c = '64850344G';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'ImaginBank';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today().addMonths(-3);
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Migración';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today().addMonths(-3);
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Reversión';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today().addMonths(-3);
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
       	CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Solicita reversión';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today().addMonths(-3);
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        insert mccCausa;

        Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
       	CC_MCC__c mccSolucion= new CC_MCC__c();
        mccSolucion.Name = 'Solicita reversión';
        mccSolucion.CC_Tipo_Cliente__c = 'Cliente';
        mccSolucion.CC_Fecha_Vigencia_Inicio__c = date.today().addMonths(-3);
        mccSolucion.RecordTypeId = recordTypeIdSolucion;
        mccSolucion.CC_Causa__c = mccCausa.Id;
        mccSolucion.CC_Codigo_Externo__c = 'SO-000001';
        insert mccSolucion;

         
        List<CBK_CatalogoFacturacion__c> catalogoFacturacionList = new List<CBK_CatalogoFacturacion__c>();
        CBK_CatalogoFacturacion__c catalogoMST = new CBK_CatalogoFacturacion__c();
        catalogoMST.recordtypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogoMST.CC_Margen__c = 0.1;
        catalogoMST.CC_Negocio__c = 'CC';
        catalogoMST.CC_Canal_de_Entrada__c = 'Email';
        catalogoMST.CC_Canal_Operativo__c = 'App CaixaBankPay';
        catalogoMST.CC_Fecha_Inicio_Vigencia__c = Datetime.now().addMonths(-1).addDays(1);
        catalogoMST.CC_Grupo_Facturacion__c = 'MST'; 
        catalogoMST.CC_Precio_Unitario__c = 1;
        catalogoMST.CC_Producto__c = mccProducto.Id;
        catalogoMST.CC_Tematica__c = mccTematica.Id;
        catalogoFacturacionList.add(catalogoMST);

        CBK_CatalogoFacturacion__c catalogoDXC = new CBK_CatalogoFacturacion__c();
        catalogoDXC.recordtypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogoDXC.CC_Margen__c = 0.2;
        catalogoDXC.CC_Negocio__c = 'CC';
        catalogoDXC.CC_Canal_de_Entrada__c = 'Email';
        catalogoDXC.CC_Canal_Operativo__c = 'App CaixaBankPay';
        catalogoDXC.CC_Fecha_Inicio_Vigencia__c = Datetime.now().addMonths(-1);
        catalogoDXC.CC_Grupo_Facturacion__c = 'DXC'; 
        catalogoDXC.CC_Precio_Unitario__c = 1;
        catalogoDXC.CC_Producto__c = mccProducto.Id;
        catalogoDXC.CC_Tematica__c = mccTematica.Id;
        catalogoFacturacionList.add(catalogoDXC);

        insert catalogoFacturacionList;

        Case casoN = new Case();
        casoN.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        casoN.CC_Idioma__c = 'es';
        casoN.Subject = 'Asunto';
        casoN.Description = 'Descripción';
        casoN.CC_Tipo_Contacto__c = 'Consulta';
        casoN.CC_Canal_Procedencia__c = 'Accionista';
        casoN.CC_Canal_Resolucion__c = 'Accionista';
        casoN.CC_Canal_Operativo__c = 'App CaixaBankPay';
        casoN.Origin = 'Email';
        casoN.Status = 'Activo';
        casoN.CC_Detalles_Consulta__c = 'Detalles Consulta';
        casoN.CC_Detalles_Solucion__c = 'Detalles Solución';
        casoN.CC_MCC_Tematica__c = mccTematica.Id;
        casoN.CC_MCC_ProdServ__c = mccProducto.Id;
        casoN.CC_MCC_Motivo__c = mccMotivo.Id;
        casoN.CC_MCC_Causa__c = mccCausa.Id;
        casoN.CC_MCC_Solucion__c = mccSolucion.Id;
        casoN.AccountId = cuenta.Id;
        casoN.ContactId = contacto.Id;
        casoN.OwnerId = userList[0].Id;
        insert casoN;

        //Cambiamos el owner del caso por uno que tenga distinto company
        casoN.OwnerId = userList[1].Id;
        update casoN;

        casoN.OwnerId = userList[0].Id;

        Test.startTest();
            update casoN;
        Test.stopTest();

        List<CC_Facturacion_Caso__c> facturacionCasoCreate = [SELECT Id, CC_Caso__c, CC_Proveedor__c, CC_Catalogo_Facturacion__c FROM CC_Facturacion_Caso__c WHERE CC_Caso__c = :casoN.Id];
        List<Case> casoFacturando = [SELECT Id, CC_GruposResolutores__c, CC_Grupo_Resolutor__c FROM Case WHERE Id = :casoN.Id];
        //System.assertEquals(2, facturacionCasoCreate.size(), 'se generan dos registros, uno por cada company');
        System.assertEquals(1, casoFacturando.size());
        List<String> proveedores = casoFacturando[0].CC_GruposResolutores__c.split(';');
        System.assertEquals(2, proveedores.size(), 'se factura a 2 proveedores');
        System.assertEquals(1, casoFacturando.size(), 'el proveedor está almacenado en el caso');
        System.assertEquals(userList[0].CompanyName, casoFacturando[0].CC_Grupo_Resolutor__c, 'el proveedor actual aparece en el campo CC_Grupo_Resolutor__c');
        System.assert((casoFacturando[0].CC_GruposResolutores__c).contains(userList[0].CompanyName), 'el proveedor está almacenado en el caso');
        System.assert((casoFacturando[0].CC_GruposResolutores__c).contains(userList[1].CompanyName), 'el proveedor está almacenado en el caso');
    }

    @isTest
    private static void creacionRelacionCatalogoFacturacionCasoCambioMCC() 
    {
        List<User> userList = [SELECT Id, CompanyName FROM User WHERE Email = 'tuser000@amamama.com'];

        Account cuenta = new Account();
        cuenta.Name = 'Smith';
        cuenta.CC_Numero_Documento__c = '64850344G';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.LastName = 'Smith';
        contacto.CC_Numero_Documento__c = '64850344G';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'ImaginBank';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today().addMonths(-3);
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Migración';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today().addMonths(-3);
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto;
        
        CC_MCC__c mccProducto1 = new CC_MCC__c();
        mccProducto1.Name = 'Migración';
        mccProducto1.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto1.CC_Fecha_Vigencia_Inicio__c = date.today().addMonths(-3);
        mccProducto1.RecordTypeId = recordTypeIdProducto;
        mccProducto1.CC_Tematica__c = mccTematica.Id;
        mccProducto1.CC_Codigo_Externo__c = 'PR-000002'; 
        insert mccProducto1;
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Reversión';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today().addMonths(-3);
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        CC_MCC__c mccMotivo1 = new CC_MCC__c();
        mccMotivo1.Name = 'Reversión';
        mccMotivo1.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo1.CC_Fecha_Vigencia_Inicio__c = date.today().addMonths(-3);
        mccMotivo1.RecordTypeId = recordTypeIdMotivo;
        mccMotivo1.CC_Tematica__c = mccTematica.Id;
        mccMotivo1.CC_Producto_Servicio__c = mccProducto1.Id;
        mccMotivo1.CC_Codigo_Externo__c = 'MO-000002';
        insert mccMotivo1;
         
        List<CBK_CatalogoFacturacion__c> catalogoFacturacionList = new List<CBK_CatalogoFacturacion__c>();
        CBK_CatalogoFacturacion__c catalogoMST = new CBK_CatalogoFacturacion__c();
        catalogoMST.recordtypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogoMST.CC_Margen__c = 0.1;
        catalogoMST.CC_Negocio__c = 'CC';
        catalogoMST.CC_Canal_de_Entrada__c = 'Email';
        catalogoMST.CC_Canal_Operativo__c = 'App CaixaBankPay';
        catalogoMST.CC_Fecha_Inicio_Vigencia__c = Datetime.now().addMonths(-1);
        catalogoMST.CC_Grupo_Facturacion__c = 'MST'; 
        catalogoMST.CC_Precio_Unitario__c = 1;
        catalogoMST.CC_Producto__c = mccProducto.Id;
        catalogoMST.CC_Tematica__c = mccTematica.Id;
        catalogoFacturacionList.add(catalogoMST);

        CBK_CatalogoFacturacion__c catalogoDXC = new CBK_CatalogoFacturacion__c();
        catalogoDXC.recordtypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogoDXC.CC_Margen__c = 0.2;
        catalogoDXC.CC_Negocio__c = 'CC';
        catalogoDXC.CC_Canal_de_Entrada__c = 'Email';
        catalogoDXC.CC_Canal_Operativo__c = 'App CaixaBankPay';
        catalogoDXC.CC_Fecha_Inicio_Vigencia__c = Datetime.now().addMonths(-1);
        catalogoDXC.CC_Grupo_Facturacion__c = 'DXC'; 
        catalogoDXC.CC_Precio_Unitario__c = 1;
        catalogoDXC.CC_Producto__c = mccProducto.Id;
        catalogoDXC.CC_Tematica__c = mccTematica.Id;
        catalogoFacturacionList.add(catalogoDXC);

        CBK_CatalogoFacturacion__c catalogoINDRA = new CBK_CatalogoFacturacion__c();
        catalogoINDRA.recordtypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogoINDRA.CC_Margen__c = 0.2;
        catalogoINDRA.CC_Negocio__c = 'CC';
        catalogoINDRA.CC_Canal_de_Entrada__c = 'Email';
        catalogoINDRA.CC_Canal_Operativo__c = 'App CaixaBankPay';
        catalogoINDRA.CC_Fecha_Inicio_Vigencia__c = Datetime.now().addMonths(-1);
        catalogoINDRA.CC_Grupo_Facturacion__c = 'INDRA'; 
        catalogoINDRA.CC_Precio_Unitario__c = 1;
        catalogoINDRA.CC_Producto__c = mccProducto.Id;
        catalogoINDRA.CC_Tematica__c = mccTematica.Id;
        catalogoFacturacionList.add(catalogoINDRA);

        CBK_CatalogoFacturacion__c catalogoMST1 = new CBK_CatalogoFacturacion__c();
        catalogoMST1.recordtypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogoMST1.CC_Margen__c = 0.1;
        catalogoMST1.CC_Negocio__c = 'CC';
        catalogoMST1.CC_Canal_de_Entrada__c = 'Email';
        catalogoMST1.CC_Canal_Operativo__c = 'App CaixaBankPay';
        catalogoMST1.CC_Fecha_Inicio_Vigencia__c = Datetime.now().addMonths(-1);
        catalogoMST1.CC_Grupo_Facturacion__c = 'MST'; 
        catalogoMST1.CC_Precio_Unitario__c = 1;
        catalogoMST1.CC_Producto__c = mccProducto1.Id;
        catalogoMST1.CC_Tematica__c = mccTematica.Id;
        catalogoFacturacionList.add(catalogoMST1);

        CBK_CatalogoFacturacion__c catalogoDXC1 = new CBK_CatalogoFacturacion__c();
        catalogoDXC1.recordtypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogoDXC1.CC_Margen__c = 0.2;
        catalogoDXC1.CC_Negocio__c = 'CC';
        catalogoDXC1.CC_Canal_de_Entrada__c = 'Email';
        catalogoDXC1.CC_Canal_Operativo__c = 'App CaixaBankPay';
        catalogoDXC1.CC_Fecha_Inicio_Vigencia__c = Datetime.now().addMonths(-1);
        catalogoDXC1.CC_Grupo_Facturacion__c = 'DXC'; 
        catalogoDXC1.CC_Precio_Unitario__c = 1;
        catalogoDXC1.CC_Producto__c = mccProducto1.Id;
        catalogoDXC1.CC_Tematica__c = mccTematica.Id;
        catalogoFacturacionList.add(catalogoDXC1);

        insert catalogoFacturacionList;

        Case casoN = new Case();
        casoN.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        casoN.CC_Idioma__c = 'es';
        casoN.Subject = 'Asunto';
        casoN.Description = 'Descripción';
        casoN.CC_Tipo_Contacto__c = 'Consulta';
        casoN.CC_Canal_Procedencia__c = 'Accionista';
        casoN.CC_Canal_Resolucion__c = 'Accionista';
        casoN.CC_Canal_Operativo__c = 'App CaixaBankPay';
        casoN.Origin = 'Email';
        casoN.Status = 'Activo';
        casoN.CC_Detalles_Consulta__c = 'Detalles Consulta';
        casoN.CC_Detalles_Solucion__c = 'Detalles Solución';
        casoN.AccountId = cuenta.Id;
        casoN.ContactId = contacto.Id;
        casoN.CC_MCC_Tematica__c = mccTematica.Id;
        casoN.CC_MCC_ProdServ__c = mccProducto.Id;
        casoN.CC_MCC_Motivo__c = mccMotivo.Id;
        //indicamos los grupos resolutores que ha tenido ya el caso, para que cree la facturación de todos con el nuevo MCC
        casoN.CC_GruposResolutores__c = 'MST;DXC;INDRA';
        insert casoN;

        List<CC_Facturacion_Caso__c> facturacionCasoCrear = new List<CC_Facturacion_Caso__c>();
        CC_Facturacion_Caso__c facturacionMST = new CC_Facturacion_Caso__c();
        facturacionMST.CC_Caso__c = casoN.Id;
        facturacionMST.CC_Proveedor__c = 'MST';
        facturacionMST.CC_Catalogo_Facturacion__c = catalogoMST.Id;
        facturacionCasoCrear.add(facturacionMST);

        CC_Facturacion_Caso__c facturacionDXC = new CC_Facturacion_Caso__c();
        facturacionDXC.CC_Caso__c = casoN.Id;
        facturacionDXC.CC_Proveedor__c = 'DXC';
        facturacionDXC.CC_Catalogo_Facturacion__c = catalogoDXC.Id;
        facturacionCasoCrear.add(facturacionDXC);

        CC_Facturacion_Caso__c facturacionINDRA = new CC_Facturacion_Caso__c();
        facturacionINDRA.CC_Caso__c = casoN.Id;
        facturacionINDRA.CC_Proveedor__c = 'INDRA';
        facturacionINDRA.CC_Catalogo_Facturacion__c = catalogoINDRA.Id;
        facturacionCasoCrear.add(facturacionINDRA);

        insert facturacionCasoCrear;

        List<CC_Facturacion_Caso__c> facturacionCasoCreate = [SELECT Id, CC_Caso__c, CC_Proveedor__c, CC_Catalogo_Facturacion__c, CC_Catalogo_Facturacion__r.CC_Producto__c 
                                                                FROM CC_Facturacion_Caso__c WHERE CC_Caso__c = :casoN.Id];
        System.assertEquals(3, facturacionCasoCreate.size(), 'se crean 3 registros por los proveedores que cumplen la clasificacion');                                                    
        
        //actualizamos el mcc del caso para que se genere la nueva facturación
        casoN.CC_MCC_ProdServ__c = mccProducto1.Id;
        casoN.CC_MCC_Motivo__c = mccMotivo1.Id;
        
        Test.startTest();
            update casoN;
        Test.stopTest();

        List<CC_Facturacion_Caso__c> facturacionCasoUpdate = [SELECT Id, CC_Caso__c, CC_Proveedor__c, CC_Catalogo_Facturacion__c, CC_Catalogo_Facturacion__r.CC_Producto__c 
                                                                FROM CC_Facturacion_Caso__c WHERE CC_Caso__c = :casoN.Id];
        List<Case> casoFacturando = [SELECT Id, CC_GruposResolutores__c, CC_MCC_ProdServ__c  FROM Case WHERE Id = :casoN.Id];
        //System.assertEquals(2, facturacionCasoUpdate.size(), 'se han actualizado dos registros y eliminado uno, porque ya no cumple las condiciones');
        System.assertEquals(1, casoFacturando.size());
        List<String> proveedores = casoFacturando[0].CC_GruposResolutores__c.split(';');
        System.assertEquals(3, proveedores.size());

        for (CC_Facturacion_Caso__c facturando : facturacionCasoUpdate)
        {
            for (CBK_CatalogoFacturacion__c catalogo : catalogoFacturacionList)
            {
                if (facturando.CC_Proveedor__c == catalogo.CC_Grupo_Facturacion__c && catalogo.CC_Producto__c == facturando.CC_Catalogo_Facturacion__r.CC_Producto__c)
                {
                    System.assertEquals(catalogo.Id, facturando.CC_Catalogo_Facturacion__c, 'se le ha facturado al proveedor');
                }
            }   
            System.assert((casoFacturando[0].CC_GruposResolutores__c).contains(facturando.CC_Proveedor__c), 'el proveedor está almacenado en el caso');
        }
    }*/

    /*
    @isTest
    public static void vincularCasoOrigen() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
        mccTematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;

        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
        mccProducto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto;

        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
        mccMotivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente desiste';
        insert mccMotivo;

        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Causa 1';
        mccCausa.CC_Tipo_Cliente__c = 'Empleado';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
        mccCausa.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        insert mccCausa;

        CC_MCC__c mccSolucion = new CC_MCC__c();
        mccSolucion.Name = 'Solucion 1';
        mccSolucion.CC_Tipo_Cliente__c = 'Empleado';
        mccSolucion.CC_Fecha_Vigencia_Inicio__c = Date.today().addDays(-1);
        mccSolucion.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucion.CC_Causa__c = mccCausa.Id;
        mccSolucion.CC_Codigo_Externo__c = 'SO-000001';
        mccSolucion.CC_Motivo_NOK__c = 'Cliente anula la solicitud;Cliente no localizado por FEDEX;Error KYC;Recibe por error la tarjeta de otro cliente';
        insert mccSolucion;

        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.Name = 'Cuenta Cliente Test 1';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contacto.LastName = 'Contacto Cliente Test 1';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        insert contacto;

        Case caso1 = new Case();
        caso1.recordtypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso1.Subject = 'Caso de prueba TF7 Empleado';
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso1.CC_Tipo_Contacto__c = 'Consulta';
        caso1.CC_Canal_Operativo__c = 'Cajero';
        caso1.CC_MCC_Tematica__c = mccTematica.Id;
        caso1.CC_MCC_ProdServ__c = mccProducto.Id;
        caso1.CC_MCC_Motivo__c = mccMotivo.Id;
        caso1.CC_MCC_Causa__c = mccCausa.Id;
        caso1.CC_MCC_Solucion__c = mccSolucion.Id;
        caso1.AccountId = cuenta.Id;
        caso1.ContactId = contacto.Id;

        Case caso2 = new Case();
        caso2.recordtypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso2.Subject = 'Caso de prueba TF7 Empleado';
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso2.CC_Tipo_Contacto__c = 'Consulta';
        caso2.CC_Canal_Operativo__c = 'Cajero';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.CC_MCC_Causa__c = mccCausa.Id;
        caso2.CC_MCC_Solucion__c = mccSolucion.Id;
        caso2.AccountId = cuenta.Id;
        caso2.ContactId = contacto.Id;

        Case caso3 = new Case();
        caso3.recordtypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso3.Subject = 'Caso de prueba TF7 Empleado';
        caso3.Origin = 'Email';
        caso3.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso3.CC_Tipo_Contacto__c = 'Consulta';
        caso3.CC_Canal_Operativo__c = 'Cajero';
        caso3.CC_MCC_Tematica__c = mccTematica.Id;
        caso3.CC_MCC_ProdServ__c = mccProducto.Id;
        caso3.CC_MCC_Motivo__c = mccMotivo.Id;
        caso3.CC_MCC_Causa__c = mccCausa.Id;
        caso3.CC_MCC_Solucion__c = mccSolucion.Id;
        caso3.AccountId = cuenta.Id;
        caso3.ContactId = contacto.Id;

        insert new List<Case>{caso1, caso2, caso3};

        Test.startTest();
        HDT_Case.vincularCasoOrigenAux(new List<Id>{caso2.Id});
        //HDT_Case.vincularCasoOrigenAux(new List<Id>{caso3.Id});
        Test.stopTest();

        System.assertEquals(
            caso1.Id,
            [SELECT CC_Caso_Origen__c FROM Case WHERE Id = :caso2.Id].CC_Caso_Origen__c,
            'El caso origen y el de seguimiento no han quedado vinculados'
        );

        }
    }*/
    
}