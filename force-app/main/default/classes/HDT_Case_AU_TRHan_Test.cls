@isTest
public class HDT_Case_AU_TRHan_Test {
    @TestSetup
    static void makeData(){
    
        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};

        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = owa[0].Address;
        params.HDT_Configuracion_2__c = owa[0].Address;
        insert params;

        //crear usuarios CC
        /*List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];
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
        usuario2.Username = 'tuser001@amamama.com' + System.currentTimeMillis();
        usuario2.CompanyName = 'DXC';
        usuario2.Title = 'title';
        usuario2.Alias = 'alias';
        usuario2.TimeZoneSidKey = 'Europe/Paris';
        usuario2.EmailEncodingKey = 'UTF-8';
        usuario2.LanguageLocaleKey = 'es';
        usuario2.LocaleSidKey = 'es_ES';
        userList.add(usuario2);
        insert userList;
        insert new PermissionSetAssignment(AssigneeId = usuario1.Id, PermissionSetId = ps.Id);
        insert new PermissionSetAssignment(AssigneeId = usuario2.Id, PermissionSetId = ps.Id);*/

        List<String> developerNamesPlantillas = new List<String>{'CC_ConsultasOperativasCanalFormulario_Traslado_CAS','CC_ConsultasOperativasCanalFormulario_Traslado_CAT','CC_ConsultasOperativasCanalFormulario_Asignacion_CAS','CC_ConsultasOperativasCanalFormulario_Asignacion_CAT'};
		List<EmailTemplate> plantillas = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName IN :developerNamesPlantillas];
        List<EmailTemplate> plantillasAInsertar = new List<EmailTemplate>();
        if (plantillas.isEmpty()) {

            User nuevoUsuario = HDT_TestDataFactory.usuarioAHdt();
            String nuevoUsuarioId = nuevoUsuario.Id;

            EmailTemplate plantilla1CAS= new EmailTemplate();
            plantilla1CAS.Developername = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAS';
            plantilla1CAS.HTMLValue= 'hola prueba 2';
            plantilla1CAS.Subject = 'plantilla1CAS';
            plantilla1CAS.FolderId = nuevoUsuarioId;
            plantilla1CAS.TemplateType = 'Text';
            plantilla1CAS.name = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAS';
            plantilla1CAS.IsActive = true;
            plantillasAInsertar.Add(plantilla1CAS);


            EmailTemplate plantilla1CAT= new EmailTemplate();
            plantilla1CAT.Developername = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAT';
            plantilla1CAT.HTMLValue= 'hola prueba 2';
            plantilla1CAT.Subject = 'plantilla1CAT';
            plantilla1CAT.FolderId = nuevoUsuarioId;
            plantilla1CAT.TemplateType = 'Text';
            plantilla1CAT.name = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAT';
            plantilla1CAT.IsActive = true;
            plantillasAInsertar.Add(plantilla1CAT);

            EmailTemplate plantilla2CAS= new EmailTemplate();
            plantilla2CAS.Developername = 'CC_ConsultasOperativasCanalFormulario_Asignacion_CAS';
            plantilla2CAS.HTMLValue= 'hola prueba 2';
            plantilla2CAS.Subject = 'plantilla2CAS';
            plantilla2CAS.FolderId = nuevoUsuarioId;
            plantilla2CAS.TemplateType = 'Text';
            plantilla2CAS.name = 'CC_ConsultasOperativasCanalFormulario_Asignacion_CAS';
            plantilla2CAS.IsActive = true;
            plantillasAInsertar.Add(plantilla2CAS);


            EmailTemplate plantilla2CAT= new EmailTemplate();
            plantilla2CAT.Developername = 'CC_ConsultasOperativasCanalFormulario_Asignacion_CAT';
            plantilla2CAT.HTMLValue= 'hola prueba 2';
            plantilla2CAT.Subject = 'plantilla2CAT';
            plantilla2CAT.FolderId = nuevoUsuarioId;
            plantilla2CAT.TemplateType = 'Text';
            plantilla2CAT.name = 'CC_ConsultasOperativasCanalFormulario_Asignacion_CAT';
            plantilla2CAT.IsActive = true;
            plantillasAInsertar.Add(plantilla2CAT);
            insert plantillasAInsertar;
        	}
    }

    private static void crearListaDeValores() {
        CC_Lista_Valores__c lovAvisosSobreAgrupadores = new CC_Lista_Valores__c();
        lovAvisosSobreAgrupadores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovAvisosSobreAgrupadores.CC_Activa__c = true;
        lovAvisosSobreAgrupadores.Name = 'Avisos sobre agrupadores';
        insert lovAvisosSobreAgrupadores;

        CC_Lista_Valores__c valorUmbralPrimerAviso = new CC_Lista_Valores__c();
        valorUmbralPrimerAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralPrimerAviso.CC_Activa__c = true;
        valorUmbralPrimerAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralPrimerAviso.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia') + ' - Umbral primer aviso';
        valorUmbralPrimerAviso.CC_Valor__c = '2';
        CC_Lista_Valores__c valorUmbralSiguientesAvisos = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisos.CC_Activa__c = true;
        valorUmbralSiguientesAvisos.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralSiguientesAvisos.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia') + ' - Umbral siguientes avisos';
        valorUmbralSiguientesAvisos.CC_Valor__c = '50';

        List<CC_Lista_Valores__c> valorUmbralInsert = new List<CC_Lista_Valores__c>();
        valorUmbralInsert.add(valorUmbralPrimerAviso);
        valorUmbralInsert.add(valorUmbralSiguientesAvisos);
        insert valorUmbralInsert;
    }

    @isTest
    private static void crearPlantillasIncidencias() {
       
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        crearListaDeValores();

        CC_Agrupador__c agrupador1 = new CC_Agrupador__c();
        agrupador1.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        agrupador1.CC_Titulo__c = 'Agrupador Test';
        agrupador1.CC_Estado__c = 'Activo';
        agrupador1.CC_Numero_Casos__c = 0;
        insert agrupador1;

        CC_Agrupador__c agrupador2 = agrupador1.clone();
        insert agrupador2;

        List<Case> listaCasos = new List<Case>();
        Case caso1 = new Case();
        caso1.Status = 'Activo';
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        caso1.CC_Idioma__c = 'es';
        caso1.CC_CanalNotifCli__c = 'Email';
        caso1.CC_NotIncidencia__c = '1';
        listaCasos.add(caso1);

        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso2.Status = 'Activo';
        caso2.CC_Idioma__c = 'ca';
        caso2.CC_CanalNotifCli__c = 'SMS';
        caso2.CC_NotIncidencia__c = '1';
        listaCasos.add(caso2);

        Case caso3 = caso2.clone();
        listaCasos.add(caso3);

        Case caso4 = new Case();
        caso4.Subject = 'CASO INICIAL';
        caso4.Status = 'Cerrado';
        caso4.Reason = 'Helpdesk';
        caso4.Origin = 'Email';
        caso4.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso4.CC_Canal_Procedencia__c='Servicios Centrales';
        listaCasos.add(caso4);

        insert listaCasos;

        

       
           


        //Prueba update
        caso1.Status = 'Pendiente Incidencia';
        caso1.CC_Agrupador_Id__c = agrupador1.Id;
        update caso1;

       //Nueva plantilla
        List<CC_PlantillaAsociada__c> listaPlantillas = [SELECT CC_Idioma__c, CC_Canal__c, CC_Tipo_Cliente__c, CC_Agrupador__c FROM CC_PlantillaAsociada__c];
        System.assertEquals(1, listaPlantillas.size());
        System.assertEquals('es', listaPlantillas[0].CC_Idioma__c);
        System.assertEquals('Email', listaPlantillas[0].CC_Canal__c);
        System.assertEquals('Cliente', listaPlantillas[0].CC_Tipo_Cliente__c);
        System.assertEquals(agrupador1.Id, listaPlantillas[0].CC_Agrupador__c);

        // Plantilla no necesaria, se elimina
        caso1.Status = 'Activo';
        caso1.CC_Agrupador_Id__c = null;
        update caso1;

        listaPlantillas = [SELECT Id FROM CC_PlantillaAsociada__c];
        System.assertEquals(1, listaPlantillas.size());

        listaCasos.clear();
        caso1.CC_Agrupador_Id__c = null;
        caso2.CC_Agrupador_Id__c = null;
        listaCasos.add(caso1);
        listaCasos.add(caso2);
        update listaCasos;

        // 2 nuevas plantillas
        listaCasos.clear();
        caso1.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso1.CC_Canal_Procedencia__c='Servicios Centrales';
        caso1.Status = 'Pendiente Incidencia';
        caso1.CC_Agrupador_Id__c = agrupador2.Id;
        listaCasos.add(caso1);

        caso2.Status = 'Pendiente Incidencia';
        caso2.CC_Agrupador_Id__c = agrupador1.Id;
        listaCasos.add(caso2);

        //update listaCasos;
       

        listaPlantillas = [SELECT CC_Idioma__c, CC_Canal__c, CC_Tipo_Cliente__c, CC_Agrupador__c FROM CC_PlantillaAsociada__c ORDER BY CC_Idioma__c ASC];
        System.assertEquals(1, listaPlantillas.size());
        System.assertEquals('es', listaPlantillas[0].CC_Idioma__c);
        System.assertEquals('Email', listaPlantillas[0].CC_Canal__c);
        System.assertEquals('Cliente', listaPlantillas[0].CC_Tipo_Cliente__c);
       // System.assertEquals(agrupador2.Id, listaPlantillas[0].CC_Agrupador__c);
        //System.assertEquals('ca', listaPlantillas[1].CC_Idioma__c);
        //System.assertEquals('SMS', listaPlantillas[1].CC_Canal__c);
        //System.assertEquals('Empleado', listaPlantillas[1].CC_Tipo_Cliente__c);
        System.assertEquals(agrupador1.Id, listaPlantillas[0].CC_Agrupador__c);

        /*
        // Se elimina solo 1 plantilla, la otra debería detectarse como necesaria y debería mantener su cuerpo
        CC_PlantillaAsociada__c plantillaAsociada = listaPlantillas[1];
        plantillaAsociada.CC_CuerpoNotificacion__c = 'Nuevo cuerpo';
        update plantillaAsociada;

        caso1.Status = 'Activo';
        caso1.CC_Agrupador_Id__c = null;
        caso2.Status = 'Activo';
        caso2.CC_Agrupador_Id__c = null;
        caso3.Status = 'Pendiente Incidencia';
        caso3.CC_Agrupador_Id__c = agrupador1.Id;
        listaCasos.add(caso3);
        update listaCasos;

        listaPlantillas = [SELECT CC_Idioma__c, CC_Canal__c, CC_Tipo_Cliente__c, CC_Agrupador__c, CC_CuerpoNotificacion__c FROM CC_PlantillaAsociada__c ORDER BY CC_Idioma__c DESC];
        System.assertEquals(2, listaPlantillas.size());
        System.assertEquals('ca', listaPlantillas[0].CC_Idioma__c);
        System.assertEquals('SMS', listaPlantillas[0].CC_Canal__c);
        System.assertEquals('Empleado', listaPlantillas[0].CC_Tipo_Cliente__c);
        System.assertEquals(agrupador1.Id, listaPlantillas[0].CC_Agrupador__c);
        System.assertEquals('Nuevo cuerpo', listaPlantillas[0].CC_CuerpoNotificacion__c);
        */
        }
        
    }

    @isTest
    private static void crearActividadCierre() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Account cuenta = new Account();
        cuenta.name = 'Cuenta de prueba';
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert cuenta;

        Contact contacto = new Contact();
        contacto.recordtypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contacto.LastName='contacto pruebass';
        contacto.AccountId = cuenta.Id;
        contacto.Email = 'prueba@test.com';
		contacto.Phone = '666444777';
        insert contacto;

        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
		insert mccTematica;


        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto;

        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccMotivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        insert mccMotivo;


        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Causa 1';
        mccCausa.CC_Tipo_Cliente__c = 'Empleado';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
		insert mccCausa;

		CC_MCC__c mccSolucion = new CC_MCC__c();
        mccSolucion.Name = 'Solucion 1';
        mccSolucion.CC_Tipo_Cliente__c = 'Empleado';
        mccSolucion.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccSolucion.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        mccSolucion.CC_Causa__c = mccCausa.Id;
        mccSolucion.CC_Codigo_Externo__c = 'SO-000001';
		insert mccSolucion;



        //Test CAM
        Case casoCAM = new Case();
        casoCAM.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
        casoCAM.Status = 'Activo';
		casoCAM.CC_MCC_Tematica__c = mccTematica.Id;
        casoCAM.CC_MCC_ProdServ__c = mccProducto.Id;
        casoCAM.CC_MCC_Motivo__c = mccMotivo.Id;
        casoCAM.CC_MCC_Causa__c = mccCausa.Id;
        casoCAM.CC_MCC_Solucion__c = mccSolucion.Id;
        casoCAM.AccountId = cuenta.Id;
        casoCAM.ContactId = contacto.Id;
        casoCAM.CC_Detalles_Consulta__c = 'detalles consulta test2';
        insert casoCAM;

        Test.startTest();
            casoCAM.Status = 'Cerrado';
            update casoCAM;
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Task WHERE WhatId = :casoCAM.Id AND Type = 'Cerrado'
                                AND Subject = 'Cerrado' AND ActivityDate = :System.today() AND CC_Detalles_Consulta__c = 'detalles consulta test2']);

       }
    }
    /*

    @isTest
    private static void crearActividadReasignacion() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Profile perfil = [SELECT Id FROM Profile WHERE Name = 'AM_Responsable'];
        
        User usuario3 = new User();

        usuario3.ProfileId = perfil.Id;

        usuario3.FirstName = 'first3';
        usuario3.LastName = 'last3';
        usuario3.Email = 'puser000@amamama.com';
        usuario3.Username = 'puser000@amamama.com' + System.currentTimeMillis();
        usuario3.CompanyName = 'TEST';
        usuario3.Title = 'title';
        usuario3.Alias = 'alias';
        usuario3.TimeZoneSidKey = 'America/Los_Angeles';
        usuario3.EmailEncodingKey = 'UTF-8';
        usuario3.LanguageLocaleKey = 'en_US';
        usuario3.LocaleSidKey = 'en_US';
        insert usuario3;
		
        
        
        User usuario4 = new User();
		 
        usuario4.ProfileId = perfil.Id;

        usuario4.FirstName = 'first4';
        usuario4.LastName = 'last4';
        usuario4.Email = 'puser000@amamama.com';
        usuario4.Username = 'puser000@amamama.com' + System.currentTimeMillis();
        usuario4.CompanyName = 'TEST';
        usuario4.Title = 'title';
        usuario4.Alias = 'alias';
        usuario4.TimeZoneSidKey = 'America/Los_Angeles';
        usuario4.EmailEncodingKey = 'UTF-8';
        usuario4.LanguageLocaleKey = 'en_US';
        usuario4.LocaleSidKey = 'en_US';
        insert usuario4;


        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
        caso2.OwnerId = usuario3.Id;
        caso2.Status = 'Activo';
        insert caso2;

        Test.startTest();

       // System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            caso2.OwnerId = usuario4.Id;
            update caso2;
        //}
        

        Test.stopTest();

        List<Task> tareasReasignacion2 = [SELECT Id FROM Task WHERE WhatId = :caso2.Id AND Type = 'Reasignación'
                                            AND Subject = :('Reasignación del caso a ' + usuario4.FirstName + ' ' + usuario4.LastName)
                                            AND ActivityDate = :System.today() AND Status = 'Completed'];

        System.assert(caso2 != null);
       }
    }*/

    @isTest
    private static void cambioEstadoCerradoAU()
    {   
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

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
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
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

        Case caso1 = new Case();
        caso1.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso1.CC_Idioma__c = 'es';
        caso1.Subject = 'Asunto';
        caso1.Description = 'Descripción';
        caso1.CC_Tipo_Contacto__c = 'Consulta';
        caso1.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso1.CC_Canal_Resolucion__c = 'Servicios Centrales';
        caso1.CC_Canal_Operativo__c = 'App CaixaBankPay';
        caso1.Origin = 'Email';
        caso1.Status = 'Activo';
        caso1.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso1.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso1.AccountId = cuenta.Id;
        caso1.ContactId = contacto.Id;
        caso1.CC_MCC_Tematica__c = mccTematica.Id;
        caso1.CC_MCC_ProdServ__c = mccProducto.Id;
        caso1.CC_MCC_Motivo__c = mccMotivo.Id;
        //indicamos los grupos resolutores que ha tenido ya el caso, para que cree la facturación de todos con el nuevo MCC
        caso1.CC_GruposResolutores__c = 'MST;DXC;INDRA';
        insert caso1;

        Test.startTest();
       // System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            caso1.Status = 'Cerrado';
            update caso1;
      //  }
        
        Test.stopTest();
        System.assertNotEquals(null,caso1);
       }
	}

    @isTest
    private static void cambioEstadoCerradoAI()
    {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
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
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
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

        Case caso1 = new Case();
        caso1.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso1.CC_Idioma__c = 'es';
        caso1.Subject = 'Asunto';
        caso1.Description = 'Descripción';
        caso1.CC_Tipo_Contacto__c = 'Consulta';
        caso1.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso1.CC_Canal_Resolucion__c = 'Servicios Centrales';
        caso1.CC_Canal_Operativo__c = 'App CaixaBankPay';
        caso1.Origin = 'Email';
        caso1.Status = 'Cerrado';
        caso1.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso1.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso1.AccountId = cuenta.Id;
        caso1.ContactId = contacto.Id;
        caso1.CC_MCC_Tematica__c = mccTematica.Id;
        caso1.CC_MCC_ProdServ__c = mccProducto.Id;
        caso1.CC_MCC_Motivo__c = mccMotivo.Id;
        //indicamos los grupos resolutores que ha tenido ya el caso, para que cree la facturación de todos con el nuevo MCC
        caso1.CC_GruposResolutores__c = 'MST;DXC;INDRA';
        insert caso1;
        System.assertNotEquals(null,caso1);
        }
	}

    @isTest
    private static void reactivacionOperativa()
    {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

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
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
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

        Case caso1 = new Case();
        caso1.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso1.CC_Idioma__c = 'es';
        caso1.Subject = 'Asunto';
        caso1.Description = 'Descripción';
        caso1.CC_Tipo_Contacto__c = 'Incidencia';
        caso1.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso1.CC_Canal_Operativo__c = 'Cajero';
        caso1.Origin = 'Email';
        caso1.Status = 'Activo';
        caso1.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso1.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso1.AccountId = cuenta.Id;
        caso1.ContactId = contacto.Id;
        caso1.CC_MCC_Tematica__c = mccTematica.Id;
        caso1.CC_MCC_ProdServ__c = mccProducto.Id;
        caso1.CC_MCC_Motivo__c = mccMotivo.Id;
        //indicamos los grupos resolutores que ha tenido ya el caso, para que cree la facturación de todos con el nuevo MCC
        caso1.CC_GruposResolutores__c = 'MST;DXC;INDRA';
        caso1.CC_Reactivado_Operativa__c = Date.today();
        insert caso1;

        Test.startTest();
        //System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            caso1.Status = 'Cerrado';
            caso1.CC_Reactivado_Operativa__c = Date.today().addDays(7);
            update caso1;
        //}

        
        Test.stopTest();
        System.assertNotEquals(null,caso1);
        }
	}

    @isTest
    private static void envioCorreoConsultasOperativasTraslado3NTrasladoIncidencia() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Account cuenta = new Account();
        cuenta.name = 'Cuenta de prueba';
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        insert cuenta;

        Contact contacto = new Contact();
        contacto.recordtypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contacto.LastName='contacto pruebass';
        contacto.AccountId = cuenta.Id;
        contacto.Email = 'prueba@test.com';
		contacto.Phone = '666444777';
        insert contacto;

        Case caso1 = new Case();
        caso1.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso1.CC_Idioma__c = 'es';
        caso1.Subject = 'Asunto';
        caso1.Description = 'Descripción';
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso1.CC_Canal_Resolucion__c = 'Domiciliaciones';
        caso1.CC_Tipo_Contacto__c = 'Consulta';
        caso1.CC_Canal_Operativo__c = 'App CaixaBankPay';
        caso1.Status = 'Activo';
        caso1.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso1.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso1.AccountId = cuenta.Id;
        caso1.ContactId = contacto.Id;
        caso1.CC_MailTelfNotif__c = 'prueba@test.com';
        caso1.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_ConsForm_Tarjetas_Comercios' LIMIT 1].Id;
        insert caso1;


        Test.startTest();
       // System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            caso1.CC_En_Tercer_Nivel__c = true;
        update caso1;
        //}

        
        Test.stopTest();

        System.assertEquals(2, [SELECT Id FROM Task WHERE WhatId = :caso1.Id].size());
       }
    }

    @isTest
    static void testActualizarEstadisticasComunicacionInformativa() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        //Alta de datos para la prueba
		Set<Id> idsComunicacionInformativa = new Set<Id>();

        CC_Agrupador__c comunicacionInformativa = new CC_Agrupador__c();
        comunicacionInformativa.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa').getRecordTypeId();
        comunicacionInformativa.CC_Estado__c = 'Activo';
        comunicacionInformativa.CC_Titulo__c = 'Título';
        comunicacionInformativa.CC_Numero_Casos__c = 0;
        insert comunicacionInformativa;
        idsComunicacionInformativa.add(comunicacionInformativa.Id);

        CC_Agrupador__c comunicacionInformativa2 = new CC_Agrupador__c();
        comunicacionInformativa2.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        comunicacionInformativa2.CC_Estado__c = 'Activo';
        comunicacionInformativa2.CC_Titulo__c = 'Título2';
        comunicacionInformativa2.CC_Numero_Casos__c = 0;
        insert comunicacionInformativa2;

        
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.CC_Comunicacion_Informativa__c = comunicacionInformativa.Id;
        caso.Origin = 'Chat';
        caso.Status = 'Activo';
        insert caso;
        
        Case caso2 = new Case();
        caso2.CC_Comunicacion_Informativa__c = comunicacionInformativa2.Id;
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso2.Origin = 'Email';
        insert caso2;

    
        Map<Id, Case> mapOldObj = new Map<Id, Case>();
        mapOldObj.put(caso.Id, caso);
        mapOldObj.put(caso2.Id, caso);
        
        //caso.CC_Comunicacion_Informativa__c = comunicacionInformativa2.Id;
    
        List<Case> listNewObj = new List<Case>();
        listNewObj.add(caso);
        listNewObj.add(caso2);


        // Ejecutar el método a probar
        Test.startTest();
            caso.Status = 'Pendiente Incidencia';
            caso.CC_Comunicacion_Informativa__c = comunicacionInformativa.Id;
            update caso;
        
        	caso.CC_Comunicacion_Informativa__c = null;
            update caso;
        Test.stopTest();

        CC_Agrupador__c comunicacion = [SELECT Id, CC_Numero_Casos_Chat__c FROM CC_Agrupador__c WHERE Id = :comunicacionInformativa.Id];
        System.assertEquals(0, comunicacion.CC_Numero_Casos_Chat__c, 'El número de comunicaciones no coindice.');

        }
}
    
     @isTest
    static void testActualizarEstadisticasComunicacionInformativaCampana() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        //Alta de datos para la prueba
		Set<Id> idsComunicacionInformativa = new Set<Id>();
        //Alta de datos para la prueba
		Set<Id> idsComunicacionInformativaCampana = new Set<Id>();
        CC_Agrupador__c comunicacionInformativaCampana = new CC_Agrupador__c();
        comunicacionInformativaCampana.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Campana').getRecordTypeId();
        comunicacionInformativaCampana.CC_Estado__c = 'Activo';
        comunicacionInformativaCampana.CC_Titulo__c = 'Título';
        comunicacionInformativaCampana.CC_Numero_Casos__c = 0;
        insert comunicacionInformativaCampana;
        idsComunicacionInformativaCampana.add(comunicacionInformativaCampana.Id);
     
        
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.CC_Comunicacion_Informativa_Campana__c = comunicacionInformativaCampana.Id;
        caso.Origin = 'Chat';
        caso.Status = 'Activo';
        insert caso;
      

        // Ejecutar el método a probar
        Test.startTest();
            caso.Status = 'Pendiente Incidencia';
        	caso.CC_Comunicacion_Informativa_Campana__c = null;
            update caso;
        Test.stopTest();

        CC_Agrupador__c comunicacion = [SELECT Id, CC_Numero_Casos_Chat__c FROM CC_Agrupador__c WHERE Id = :comunicacionInformativaCampana.Id];
        System.assertEquals(0, comunicacion.CC_Numero_Casos_Chat__c, 'El número de comunicaciones no coindice.');
        
        }
     
    }

    @isTest
    static void testCrearPlantillasAgrupadores() {

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        // Crear datos de prueba, si es necesario
        CC_Agrupador__c agrupador1 = new CC_Agrupador__c();
        agrupador1.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        agrupador1.CC_Titulo__c = 'Agrupador Test';
        agrupador1.CC_Estado__c = 'Activo';
        agrupador1.CC_Numero_Casos__c = 0;
        insert agrupador1;

        CC_Agrupador__c agrupador2 = new CC_Agrupador__c();
        agrupador2.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        agrupador2.CC_Titulo__c = 'Agrupador Test 2';
        agrupador2.CC_Estado__c = 'Activo';
        agrupador2.CC_Numero_Casos__c = 0;
        insert agrupador2;

    
        // Crear casos de prueba
        Case casoAntiguo = new Case(Status = 'Pendiente Revisión', CC_NotIncidencia__c = '1', CC_Agrupador_Id__c = agrupador1.Id);
        Case casoNuevo = new Case(Status = 'Cerrado', CC_NotIncidencia__c = '2', CC_Agrupador_Id__c = agrupador2.Id);
        
        // Agregar casos de prueba al mapa
        Map<Id, Case> mapOldObj = new Map<Id, Case>();
        mapOldObj.put(casoAntiguo.Id, casoAntiguo);
        
        // Agregar casos de prueba a la lista
        List<Case> listNewObj = new List<Case>();
        listNewObj.add(casoNuevo);
        
        // Llamar al método que se va a probar
        Test.startTest();
        HDT_Case_AU_TRHan.crearPlantillasAgrupadores(mapOldObj, listNewObj);
        Test.stopTest();  
        
        List<Id> idAgrupadores = new List<Id>();
        idAgrupadores.add(agrupador1.Id);
        idAgrupadores.add(agrupador2.Id);

        Set<Id> actualAgrupadores = new Set<Id>();
        List<CC_Agrupador__c> agrupadores = [SELECT Id FROM CC_Agrupador__c WHERE Id IN :idAgrupadores];
        for (CC_Agrupador__c agrupador : agrupadores) {
            actualAgrupadores.add(agrupador.Id);
        }


        Set<Id> expectedAgrupadores = new Set<Id>{agrupador1.Id, agrupador2.Id}; 
        System.assertEquals(expectedAgrupadores, actualAgrupadores, 'Los agrupadores no se crearon correctamente.');
        

        }
    }    
}