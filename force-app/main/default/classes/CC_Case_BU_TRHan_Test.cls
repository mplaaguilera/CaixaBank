@isTest
public class CC_Case_BU_TRHan_Test {
    @TestSetup
    static void makeData(){
        
        
        
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profile3NId = [SELECT Id FROM Profile WHERE Name = 'CC_Tercer_Nivel_CBKNow_MVP2'].Id;
        Id profileIdAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];
        PermissionSet psIA = [SELECT Id FROM PermissionSet WHERE Name = 'CC_IA_Prompt_User'];

        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileIdAdmin;
        usuario1.FirstName = 'Usuario Admin Prueba';
        usuario1.LastName = 'last211053';
        usuario1.Email = 'aalsdna@kfsb.com';
        usuario1.Username = 'tuser0001@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';

        userList.add(usuario1);
       
        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        //crear usuarios CC

        User usuario2 = new User();
        usuario2.ProfileId = profileId;
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
        usuario3.ProfileId = profileId;
        usuario3.FirstName = 'first3';
        usuario3.LastName = 'last3';
        usuario3.Email = 'tuser0000@amamama.com';
        usuario3.Username = 'tuser003@amamama.com' + System.currentTimeMillis();
        usuario3.CompanyName = 'INDRA';
        usuario3.Title = 'title';
        usuario3.Alias = 'alias';
        usuario3.TimeZoneSidKey = 'Europe/Paris';
        usuario3.EmailEncodingKey = 'UTF-8';
        usuario3.LanguageLocaleKey = 'es';
        usuario3.LocaleSidKey = 'es_ES';
        userList.add(usuario3);
        
            User usuario4 = new User();
            usuario4.ProfileId = profile3NId;
            usuario4.FirstName = 'first 11212';
            usuario4.LastName = 'last1';
            usuario4.Email = 'tuser0004@amamama.com';
            usuario4.Username = 'tuser0004@amamama.com' + System.currentTimeMillis();
            usuario4.CompanyName = 'MST';
            usuario4.Title = 'title';
            usuario4.Alias = 'alias';
            usuario4.TimeZoneSidKey = 'Europe/Paris';
            usuario4.EmailEncodingKey = 'UTF-8';
            usuario4.LanguageLocaleKey = 'es';
            usuario4.LocaleSidKey = 'es_ES';
            usuario4.UserRoleId = rolId.Id;
       		userList.add(usuario4);

        insert userList;

        System.runAs(usuario1){

            User usuario = new User();
            usuario.ProfileId = profileId;
            usuario.FirstName = 'first 11212';
            usuario.LastName = 'last1';
            usuario.Email = 'tuser000@amamama.com';
            usuario.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
            usuario.CompanyName = 'MST';
            usuario.Title = 'title';
            usuario.Alias = 'alias';
            usuario.TimeZoneSidKey = 'Europe/Paris';
            usuario.EmailEncodingKey = 'UTF-8';
            usuario.LanguageLocaleKey = 'es';
            usuario.LocaleSidKey = 'es_ES';
            usuario.UserRoleId = rolId.Id;
            insert usuario;
             String recordTypeDeveloperName = 'CC_Comunicacion_Informativa';
		CC_Lista_Valores__c lovAvisosSobreAgrupadores = new CC_Lista_Valores__c();
        lovAvisosSobreAgrupadores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovAvisosSobreAgrupadores.CC_Activa__c = true;
        lovAvisosSobreAgrupadores.Name = 'Avisos sobre agrupadores';
        insert lovAvisosSobreAgrupadores;
        
        CC_Lista_Valores__c valorUmbralPrimerAviso = new CC_Lista_Valores__c();
        valorUmbralPrimerAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralPrimerAviso.CC_Activa__c = true;
        valorUmbralPrimerAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralPrimerAviso.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', 'CC_Comunicacion_Informativa') + ' - Umbral primer aviso';
        valorUmbralPrimerAviso.CC_Valor__c = '2';
        CC_Lista_Valores__c valorUmbralSiguientesAvisos = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisos.CC_Activa__c = true;
        valorUmbralSiguientesAvisos.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralSiguientesAvisos.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', 'CC_Comunicacion_Informativa') + ' - Umbral siguientes avisos';
        valorUmbralSiguientesAvisos.CC_Valor__c = '50';
        
        List<CC_Lista_Valores__c> valorUmbralInsert = new List<CC_Lista_Valores__c>();
        valorUmbralInsert.add(valorUmbralPrimerAviso);
        valorUmbralInsert.add(valorUmbralSiguientesAvisos);
    	insert valorUmbralInsert;
        
		
        List<CC_Settings__c> listaSettings = new List<CC_Settings__c>();
        CC_Settings__c configuracion = new CC_Settings__c();
        configuracion.CC_Activa__c = true;
        configuracion.Name = 'CC_Agrupador_CI_Asignacion_Casos';
        configuracion.CC_Configuracion_1__c = 'true';
        listaSettings.add(configuracion);           
        CC_Settings__c configuracion1 = new CC_Settings__c();
        configuracion1.CC_Activa__c = true;
        configuracion1.Name = 'CC_Agrupador_CIC_Asignacion_Casos';
        configuracion1.CC_Configuracion_1__c = 'true';
        listaSettings.add(configuracion1);    
        CC_Settings__c configuracion2 = new CC_Settings__c();
        configuracion2.CC_Activa__c = true;
        configuracion2.Name = 'CC_Agrupador_CIM_Asignacion_Casos';
        configuracion2.CC_Configuracion_1__c = 'true';
        listaSettings.add(configuracion2);
        insert listaSettings;
         
        }

        insert new PermissionSetAssignment(AssigneeId = usuario1.Id, PermissionSetId = ps.Id);
        insert new PermissionSetAssignment(AssigneeId = usuario2.Id, PermissionSetId = ps.Id);
        insert new PermissionSetAssignment(AssigneeId = usuario3.Id, PermissionSetId = ps.Id); 
        insert new PermissionSetAssignment(AssigneeId = usuario4.Id, PermissionSetId = ps.Id);
        insert new PermissionSetAssignment(AssigneeId = usuario2.Id, PermissionSetId = psIA.Id);
        
    }
    
    @isTest
    public static void testBU() {  
        //Creación nueva cuenta
        Account cuenta = new Account(Name='Cuenta');
        insert cuenta;
        
        //Creación nuevo contacto asociado a la cuenta anterior
        Contact contacto = new Contact(LastName='Contacto', AccountId=cuenta.Id);
        insert contacto;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc;
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;  
        
        //Creación nuevo caso asociado al contacto anterior
        Case caso = new Case(AccountId=cuenta.Id, ContactId=contacto.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente', Origin = 'Chat', CC_Tipo_Contacto__c = 'Consulta', recordTypeId = recordCaso,
        CC_Canal_Procedencia__c = 'App',CC_MCC_Motivo__c = mcc2.Id,CC_MCC_ProdServ__c = mcc1.Id,CC_MCC_Tematica__c = mcc.Id,
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta', CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución');
        insert caso;
        
        SocialPost socialPost = new SocialPost(
        Name = 'Name',
        ParentId = caso.Id,
        Provider = 'Other');
        insert socialPost;
        
        SocialPersona persona = New SocialPersona();
        persona.Name = 'oscar';
        persona.RealName = 'Oscar';
        persona.Provider='Other';
        persona.ParentId = socialPost.Id;
        insert persona;
        
        caso.CC_Social_Persona__c = persona.Id;
        update caso;
        
        //Creación nueva tarea ABIERTA asociada al caso anterior
        Task tarea = new Task(WhatId=caso.Id, Status='Pendiente');
        insert tarea;
        
        //Intentamos cerrar el caso
        //caso.Status = 'Cerrado';
        //update caso;
        
        /* Verificamos que se el caso sigue en estado 'Activo', puesto que al tener una tarea en estado 'Pendiente' no ha permitido modificarlo a 'Cerrado' */
        //List<Case> casosActivos = [SELECT Id FROM Case WHERE Id = :caso.Id AND Status = 'Activo'];
        //System.assertEquals(casosActivos.size(), 1);
        
        //Modificación de la tarea anterior para cerrarla
        tarea.Status = 'Completado';
        update tarea;

        
        //Intentamos cerrar el caso nuevamente
        caso.Status = 'Cerrado';
        update caso;
        
        /* En esta ocasión el caso sí se cierra al no tener ninguna tarea abierta */
        List<Case> casosCerrados = [SELECT Id FROM Case WHERE Id = :caso.Id AND Status = 'Cerrado'];
        System.assertEquals(casosCerrados.size(), 1);

       
    }
   @isTest
    public static void generarURLLimeSurveyTest(){
        //Creación nueva cuenta
       Account cuenta = new Account();
            cuenta.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
            cuenta.Name = 'Smith';
            cuenta.CC_Numero_Documento__c = '64850344G';
            insert cuenta;
            
            Contact contacto = new Contact();
            contacto.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
            contacto.LastName = 'Smith';
            contacto.CC_Numero_Documento__c = '64850344G';
            contacto.AccountId = cuenta.Id;
        	contacto.CC_Matricula__c = 'U011152';
            insert contacto;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        
        Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'ImaginBank';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;
        
        Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Migración';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Reversión';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdCausa = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Solicita reversión';
        mccCausa.CC_Tipo_Cliente__c = 'Empleado';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        insert mccCausa;
        CC_MCC__c solucion = new CC_MCC__c();
        solucion.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        solucion.Name = 'Actualizar Sistema';
        solucion.CC_Tipo_Cliente__c = 'Empleado';
        solucion.CC_Causa__c = mccCausa.Id;
        solucion.CC_Codigo_Externo__c = 'CA-000002';
        insert solucion;
        
        /*String recordTypeDeveloperName = 'CC_Comunicacion_Informativa';
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
    	insert valorUmbralInsert;*/
        List<CC_Envio_Encuesta__c> listaEncuesta = new List<CC_Envio_Encuesta__c>();
        CC_Envio_Encuesta__c encuesta3 = new CC_Envio_Encuesta__c();
		encuesta3.Name = 'CC_URL_Encuesta';
		encuesta3.CC_Id_Encuesta__c = '687532';
        encuesta3.CC_Tipo_Encuesta__c = 'URL base';
		encuesta3.CC_Link_LimeSurvey__c = 'https://opina.caixabank.com/index.php?r=survey/index&';
        listaEncuesta.add(encuesta3);
        CC_Envio_Encuesta__c encuesta4 = new CC_Envio_Encuesta__c();
		encuesta4.Name = 'CC_TercerNivel';
		encuesta4.CC_Id_Encuesta__c = '687532';
        encuesta4.CC_Tipo_Encuesta__c = 'Chat';
		encuesta4.CC_Link_LimeSurvey__c = 'https://opina.caixabank.com/index.php?r=survey/index&';
        listaEncuesta.add(encuesta4);
        insert listaEncuesta;
        
        Case caso = new Case();
        caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Canal_Operativo__c = 'App Imagin';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.CC_Grupo_Colaborador__c = 'Test';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.CC_MCC_Solucion__c = solucion.Id;
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Origin = 'Chat';      	
        insert caso;
        
        //Creación nueva tarea ABIERTA asociada al caso anterior
        // Task tarea = new Task(WhatId=caso.Id, Status='Open', Type = 'Traslado Tercer Nivel');
        // insert tarea;
    
        //Crear Agrupador incidencia
 		CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia');
        agrupador.CC_Titulo__c = 'Prueba';
        agrupador.CC_Estado__c = 'Activo';
		agrupador.CC_Descripcion__c = 'Prueba TEST';
        agrupador.CC_CanalEntrada__c = 'Twitter';
        agrupador.CC_CanalProcedencia__c = 'ImaginBank';
        agrupador.CC_Fecha_Cierre__c =  Datetime.valueOf(system.now());
        insert agrupador;

        CC_PlantillaAsociada__c plantillaAgrupador = new CC_PlantillaAsociada__c();
        plantillaAgrupador.CC_Agrupador__c = agrupador.Id;
        plantillaAgrupador.CC_Idioma__c = 'es';
        plantillaAgrupador.CC_Tipo_Cliente__c = 'Empleado';
        plantillaAgrupador.CC_CuerpoNotificacion__c = 'Cuerpo email';
        plantillaAgrupador.CC_Revisada__c = true;
        insert plantillaAgrupador;
        
        caso.CC_Agrupador_Id__c = agrupador.Id;
        caso.Status= 'Pendiente Incidencia';
        update caso;

        // tarea.Status = 'Completed';
        // update tarea; 

        //List<ID> listaAgrupadores = new List<ID>();
        //listaAgrupadores.add(agrupador.Id);
    
        Test.startTest();
        caso.Status = 'Cerrado';
        update caso;
        //CC_Agrupador.cierreAgrupador(listaAgrupadores);
        Case c = [SELECT Id, CC_URL_Encuesta_3N__c, Status FROM Case WHERE Id =: caso.Id LIMIT 1];
        Test.stopTest();
 
        System.assertEquals(caso.Status, c.Status, 'No se ha cerrado el caso.');
        System.assertNotEquals(caso.CC_URL_Encuesta_3N__c, c.CC_URL_Encuesta_3N__c, 'No se ha informado el valor del campo de la encuesta 3N.');
        
    }
    @isTest
    public static void estadoCerradoUpdateTest()
    {
        
        Id recordTypeOficina = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        Account oficinaGestora = new Account(
            RecordTypeId = recordTypeOficina, 
            Name = 'Cuenta oficina gestora', 
            CC_Tipo_Centro__c = 'OF',  
            CC_Email__c = 'test@test.com', 
            CC_Numero_Oficina__c = '00001');
        insert oficinaGestora;

        Account cuentaEmpleado = new Account();
        cuentaEmpleado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuentaEmpleado.Name = 'Cuenta Prueba Empleado';
        cuentaEmpleado.CC_OficinaGestoraId__c = oficinaGestora.Id;
        cuentaEmpleado.CC_Numero_Oficina__c = '00001';
        insert cuentaEmpleado;

        Contact contactoEmpleado = new Contact();
        contactoEmpleado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contactoEmpleado.AccountId = cuentaEmpleado.Id;
        contactoEmpleado.FirstName = 'Contacto Prueba Empleado';
        contactoEmpleado.LastName = 'Contacto Prueba Empleado';
        contactoEmpleado.CC_NumPerso__c = '25345550';
        contactoEmpleado.CC_Idioma__c = 'ca';
        contactoEmpleado.Email = 'correo@gmail.com';
        contactoEmpleado.Phone = '973242323';
        contactoEmpleado.CC_Matricula__c = '12345678';
        insert contactoEmpleado;

        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recordCau = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id recordSol = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc;
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;
        
        CC_MCC__c mcc3 = new CC_MCC__c();
        mcc3.RecordTypeId = recordCau;
        mcc3.Name = 'Valoración positiva';
        mcc3.CC_Tipo_Cliente__c = 'Cliente';
        mcc3.CC_Motivo__c = mcc2.Id;
        mcc3.CC_Codigo_Externo__c = 'CA-000001';
        insert mcc3;

        CC_MCC__c mcc4 = new CC_MCC__c();
        mcc4.RecordTypeId = recordSol;
        mcc4.Name = 'Valoración positiva';
        mcc4.CC_Tipo_Cliente__c = 'Cliente';
        mcc4.CC_Causa__c = mcc3.Id;
        mcc4.CC_Codigo_Externo__c = 'SO-000001';
        insert mcc4;
        
        Id rtEmpleado = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        
        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' limit 1];
        Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' limit 1];
        User usuario = [Select id from User where email = 'tuser000@amamama.com' limit 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];
        User sysAdminUser = [SELECT Id FROM User WHERE LastName LIKE 'last211053' AND IsActive=true LIMIT 1];
        if (sysAdminUser != null) {
            System.runAs(sysAdminUser) {
            Case caso = new Case(AccountId = empleado.Id, 
            ContactId = contacto.Id,
            OwnerId = usuario.Id,
            Status = 'Activo',
            CC_Idioma__c = 'es',
            Subject = 'Prueba',
            CC_Tipo_Cliente__c = 'Cliente',
            Origin = 'Email',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
            CC_Resolucion__c = 'Descripcion Resolucion Test',
            CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
            CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            RecordTypeId = rtEmpleado);
            insert caso;
    
            CC_Servicio_Genesys__c servicioGenesys = new CC_Servicio_Genesys__c();
            servicioGenesys.CC_codigo__c = 'IMAGIN_LEADS';
            servicioGenesys.CC_VDN__c = '123456789';
            insert servicioGenesys;
            
            CC_Llamada__c llamada = new CC_Llamada__c();
            llamada.CC_Servicio_Genesys__c = servicioGenesys.Id;
            llamada.CC_Tipo__c = 'Saliente';
            llamada.CC_Case_Consulta__c = caso.Id;
            insert llamada;
            
            Task tarea = new Task();
            tarea.Type = 'Llamada saliente';
            tarea.WhatId = caso.Id;
            tarea.CC_Llamada_Id__c = llamada.Id;
            insert tarea;
            
            Test.startTest();
            caso.Status = 'Cerrado';
            caso.CC_Resolucion__c = 'Descripción resolucion test';
            update caso;
            Test.stopTest();
            
        
        Case casoActualizado = [SELECT Id, CC_Resolucion__c, Status, CC_Llamada_Saliente__c FROM Case WHERE Id = :caso.Id LIMIT 1];
        
       
        
        System.assertEquals(true, casoActualizado.CC_Llamada_Saliente__c);
            }
        }
        
    }
    
    @isTest
    public static void enmascararPANBeforeInsert() {
        
        // Alta de datos para la prueba
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto 1234567898765432';
        caso.Description = '1234 5678 9876 5432 Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles 1234.5678.9876.5432 Solución';
        
        // Ejecución de la prueba
        Test.startTest();
        insert caso;
        Test.stopTest();
        
        // Evaluación del resultado de la prueba
        Case casoInsertado = [SELECT Subject, Description, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c FROM Case WHERE Id = :caso.Id];
        if (casoInsertado != null) {
            System.assertEquals('Asunto 1234XXXXXXXX5432', casoInsertado.Subject);
            System.assertEquals('1234XXXXXXXX5432 Descripción', casoInsertado.Description);
            System.assertEquals('Detalles 1234XXXXXXXX5432 Consulta', casoInsertado.CC_Detalles_Consulta__c);
            System.assertEquals('Detalles 1234XXXXXXXX5432 Solución', casoInsertado.CC_Detalles_Solucion__c);
        }
    }
    
    @isTest
    public static void enmascararPANBeforeUpdate() {
        
        // Alta de datos para la prueba
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        insert caso;
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto 1234567898765432';
        caso.Description = '1234 5678 9876 5432 Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles 1234.5678.9876.5432 Solución';
        
        // Ejecución de la prueba
        Test.startTest();
        update caso;
        Test.stopTest();
        
        // Evaluación del resultado de la prueba
        Case casoActualizado = [SELECT Subject, Description, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c FROM Case WHERE Id = :caso.Id];
        if (casoActualizado != null) {
            System.assertEquals('Asunto 1234XXXXXXXX5432', casoActualizado.Subject);
            System.assertEquals('1234XXXXXXXX5432 Descripción', casoActualizado.Description);
            System.assertEquals('Detalles 1234XXXXXXXX5432 Consulta', casoActualizado.CC_Detalles_Consulta__c);
            System.assertEquals('Detalles 1234XXXXXXXX5432 Solución', casoActualizado.CC_Detalles_Solucion__c);
        }
    }
    
    @isTest
    public static void encryptPANsBU() {
        
        
        // Alta de datos para la prueba
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        insert caso;
        
        
        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        agrupador.CC_Titulo__c = 'Agrupador Test';
        agrupador.CC_Estado__c = 'Rechazado';
        agrupador.CC_Numero_Casos__c = 0;
        insert agrupador;
        
        
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto 1234567898765432';
        caso.Description = '1234 5678 9876 5432 Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles 1234.5678.9876.5432 Solución';
        caso.CC_PAN_Encriptado__c = false;
        caso.CC_PAN__c = '1111 2222 3333 4444';
        caso.CC_Digitos_Tarjeta__c = '1111 2222 3333 4444';
        caso.CC_Agrupador_Id__c = agrupador.Id;
        
        
        // Ejecución de la prueba
        /*Test.startTest();
        update caso;
        Test.stopTest();
        */
        try {
            Test.startTest();
            update caso;
            Test.stopTest();
            // Evaluación del resultado de la prueba
            Case casoActualizado = [SELECT Subject, CC_PAN__c, CC_Digitos_Tarjeta__c FROM Case WHERE Id = :caso.Id];
            if (casoActualizado != null) {
                System.assertNotEquals('1111 2222 3333 4444', casoActualizado.CC_PAN__c);
                System.assertNotEquals('1111 2222 3333 4444', casoActualizado.CC_Digitos_Tarjeta__c);
            }
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('Solo se pueden asociar agrupadores activos.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        
    }

    @isTest
    public static void decryptPANsBU() {
        
        
        // Alta de datos para la prueba
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        insert caso;
        
        
        
        
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto 1234567898765432';
        caso.Description = '1234 5678 9876 5432 Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles 1234.5678.9876.5432 Solución';
        caso.CC_PAN_Encriptado__c = false;
        caso.CC_PAN__c = '1111222233334444';
        caso.CC_Digitos_Tarjeta__c = '1111 2222 3333 4444';
        
        
        update caso;
        Case casov2 = [SELECT Id, CC_PAN__c FROM Case WHERE Id =: caso.Id LIMIT 1];
        Test.startTest();
        String pan = CC_Case_BU_TRHan.decryptPANs(casov2.CC_PAN__c);
        Test.stopTest();

        System.assertEquals(pan, '1111222233334444', 'El metodo de desencriptar el campo PAN ha fallado.');
        
        
    }
    
    @isTest
    public static void reversionImaginBank() {
        // Alta de datos para la prueba
        Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'ImaginBank';
        //mccTematica.CC_Canal_Operativo__c = 'App Imagin';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;
        
        Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Migración';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Reversión';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdCausa = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Solicita reversión';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        insert mccCausa;
        Account cuenta = new Account();
        cuenta.Name = 'Smith';
        cuenta.CC_Numero_Documento__c = '64850344G';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.LastName = 'Smith';
        contacto.CC_Numero_Documento__c = '64850344G';
        contacto.AccountId = cuenta.Id;
        insert contacto;
        
        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c();
        caracteristica.Name = 'Cliente migrado a ImaginBank';
        caracteristica.CC_Prioridad__c = '1 - Alta';
        caracteristica.CC_Descripcion__c = 'Clientes dados de alta en ImaginBank.';
        insert caracteristica;
        
        CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c();
        detalle.CC_Caracteristica__c = caracteristica.Id;
        detalle.CC_Cliente__c = contacto.Id;
        detalle.CC_Cuenta__c = cuenta.Id;
        insert detalle;
        
        Case caso = new Case();
        caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Canal_Operativo__c = 'App Imagin';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        insert caso;
        
        Case caso2 = new Case();
        caso2.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso2.Status = 'Cerrado';
        caso2.CC_Idioma__c = 'es';
        caso2.Subject = 'Asunto';
        caso2.Description = 'Descripción';
        caso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso2.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.CC_MCC_Causa__c = mccCausa.Id;
        caso2.AccountId = cuenta.Id;
        caso2.ContactId = contacto.Id;
        caso2.CC_Estado_Reversion__c = 'Pendiente envío';
        insert caso2;
        
        // Ejecución de la prueba
        Test.startTest();
        List<Case> casos = new List<Case>();
        caso.Status = 'Cerrado';
        caso2.Status = 'Activo';
        casos.add(caso);
        casos.add(caso2);
        update casos;
        
        Test.stopTest();
        
        // Evaluación del resultado de la prueba
        Case casoActualizado = [SELECT CC_Estado_Reversion__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals('Pendiente envío', casoActualizado.CC_Estado_Reversion__c);
    }
    
    @isTest
    public static void obtenerBuzon() {
        // Alta de datos para la prueba
        Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'ImaginBank';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;
        
        Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Migración';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Reversión';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdCausa = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Solicita reversión';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        insert mccCausa;

        Account cuenta = new Account();
        cuenta.Name = 'Smith';
        cuenta.CC_Numero_Documento__c = '64850344G';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.LastName = 'Smith';
        contacto.CC_Numero_Documento__c = '64850344G';
        contacto.AccountId = cuenta.Id;
        insert contacto;
        
        Case caso = new Case();
        caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Accionista';
        insert caso;
        
        // Ejecución de la prueba
        Test.startTest();
        
        caso.Status = 'Cerrado';
        caso.CC_Canal_Procedencia__c = 'Atención al Cliente';
        update caso;
        Test.stopTest();
        
        // Evaluación del resultado de la prueba
        Case casoActualizado = [SELECT CC_Canal_Procedencia__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals('Atención al Cliente', casoActualizado.CC_Canal_Procedencia__c);
    }
    
    @isTest
    public static void calcularSLA(){
        Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'ImaginBank';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;
        
        Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Migración';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Reversión';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdCausa = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Solicita reversión';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        insert mccCausa;
        
        Account cuenta = new Account();
        cuenta.Name = 'Smith';
        cuenta.CC_Numero_Documento__c = '64850344G';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.LastName = 'Smith';
        contacto.CC_Numero_Documento__c = '64850344G';
        contacto.AccountId = cuenta.Id;
        insert contacto;
        
        Case caso = new Case();
        caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Origin = 'Phone';
        caso.CC_Fecha_Traslado_Colaborador__c = Datetime.now().addDays(1);
        caso.CC_Canal_Procedencia__c = 'Accionista';
        caso.CC_Inicio_Pendiente_Cliente__c = Datetime.now().addHours(1);
        caso.CC_Fin_Pendiente_Cliente__c = Datetime.now().addHours(4);
        
        insert caso;
        Test.setCreatedDate(caso.Id, DateTime.newInstance(System.today().year(), System.today().month(), System.today().day() -1, System.now().hour(), 0, 0));
        
        List<Case> casos = new List<Case>();
        Case caso2 = new Case();
        caso2.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso2.Status = 'Activo';
        caso2.CC_Idioma__c = 'es';
        caso2.Subject = 'Asunto';
        caso2.Description = 'Descripción';
        caso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso2.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.CC_MCC_Causa__c = mccCausa.Id;
        caso2.AccountId = cuenta.Id;
        caso2.ContactId = contacto.Id;
        caso2.Origin = 'Phone';
        caso2.CC_Fecha_Traslado_Colaborador__c = Datetime.now().addDays(8);
        caso2.CC_Canal_Procedencia__c = 'Atención al Cliente';
        caso2.CC_Inicio_Pendiente_Cliente__c = Datetime.now().addHours(1);
        caso2.CC_Fin_Pendiente_Cliente__c = Datetime.now().addHours(6);
        casos.add(caso2);
                

        insert casos;
        
        
        List<CC_Lista_Valores__c> horariosInsertar = new List<CC_Lista_Valores__c>();
        
        CC_Lista_Valores__c horario = new CC_Lista_Valores__c();
        horario.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        horario.Name = 'Calendario_servicios';
        horario.CC_Activa__c = true;
        insert horario;
        
        CC_Lista_Valores__c horarioAccionista = new CC_Lista_Valores__c();
        horarioAccionista.Name = 'Accionista';
        horarioAccionista.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioAccionista.CC_Valor__c = '9';
        horarioAccionista.CC_Valor2__c = '23';
        horarioAccionista.CC_Valor_SFDC__c = 'L-J';
        horarioAccionista.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioAccionista);
        
        CC_Lista_Valores__c horarioAccionista2 = new CC_Lista_Valores__c();
        horarioAccionista2.Name = 'Accionista';
        horarioAccionista2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioAccionista2.CC_Valor__c = '9:30';
        horarioAccionista2.CC_Valor2__c = '19';
        horarioAccionista2.CC_Valor_SFDC__c = 'V';
        horarioAccionista2.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioAccionista2);
        
        CC_Lista_Valores__c horarioImaginBank = new CC_Lista_Valores__c();
        horarioImaginBank.Name = 'ImaginBank';
        horarioImaginBank.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioImaginBank.CC_Valor__c = '9:30';
        horarioImaginBank.CC_Valor2__c = '19';
        horarioImaginBank.CC_Valor_SFDC__c = 'L-J';
        horarioImaginBank.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioImaginBank);
        
        CC_Lista_Valores__c horarioImaginBank2 = new CC_Lista_Valores__c();
        horarioImaginBank2.Name = 'ImaginBank';
        horarioImaginBank2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioImaginBank2.CC_Valor__c = '9:30';
        horarioImaginBank2.CC_Valor2__c = '19';
        horarioImaginBank2.CC_Valor_SFDC__c = 'V';
        horarioImaginBank2.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioImaginBank2);
        insert horariosInsertar;
        
        
        List<CC_Lista_Valores__c> festivosInsertar = new List<CC_Lista_Valores__c>();
        
        CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
        festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        festivos.Name = 'Festivos nacionales';
        festivos.CC_Activa__c = true;
        insert festivos;
        
        CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
        festivo1.Name = 'Festivo';
        festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        festivo1.CC_Valor__c = '11';
        festivo1.CC_Valor2__c = '11';
        festivo1.CC_Lista__c = festivos.Id;
        festivo1.CC_Activa__c = true;
        festivosInsertar.add(festivo1);
        
        CC_Lista_Valores__c festivo2 = new CC_Lista_Valores__c();
        festivo2.Name = 'Festivo2';
        festivo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        festivo2.CC_Valor__c = '10';
        festivo2.CC_Valor2__c = '10';
        festivo2.CC_Lista__c = festivos.Id;
        festivo2.CC_Activa__c = true;
        festivosInsertar.add(festivo2);
        insert festivosInsertar;
        
        Test.startTest();
        caso.Status = 'Pendiente Colaborador';
        caso2.Status = 'Pendiente Interno';
        
        casos.clear();
        casos.add(caso);
        casos.add(caso2);
        update casos;
        
        Test.stopTest();

        System.assertEquals(caso.Status, 'Pendiente Colaborador', 'La asignación del nuevo estado no ha funcionado.');
        System.assertEquals(caso2.Status, 'Pendiente Interno', 'La asignación del nuevo estado no ha funcionado.');

    }

    @isTest
    public static void calcularSLASegundaParte(){
        Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'ImaginBank';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;
        
        Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Migración';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Reversión';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;
        
        Id recordTypeIdCausa = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Solicita reversión';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        insert mccCausa;
        
        Account cuenta = new Account();
        cuenta.Name = 'Smith';
        cuenta.CC_Numero_Documento__c = '64850344G';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.LastName = 'Smith';
        contacto.CC_Numero_Documento__c = '64850344G';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Case caso3 = new Case();
        caso3.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        caso3.Status = 'Activo';
        caso3.CC_Idioma__c = 'es';
        caso3.Subject = 'Asunto';
        caso3.Description = 'Descripción';
        caso3.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso3.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso3.CC_MCC_Tematica__c = mccTematica.Id;
        caso3.CC_MCC_ProdServ__c = mccProducto.Id;
        caso3.CC_MCC_Motivo__c = mccMotivo.Id;
        caso3.CC_MCC_Causa__c = mccCausa.Id;
        caso3.AccountId = cuenta.Id;
        caso3.ContactId = contacto.Id;
        caso3.Origin = 'Phone';
        caso3.CC_Fecha_Traslado_Colaborador__c = Datetime.now().addDays(2);
        caso3.CC_Canal_Procedencia__c = 'ImaginBank';
        caso3.CC_Inicio_Pendiente_Cliente__c = Datetime.now().addHours(22);
        caso3.CC_Fin_Pendiente_Cliente__c = Datetime.now().addHours(23);
        insert caso3;

        List<CC_Lista_Valores__c> horariosInsertar = new List<CC_Lista_Valores__c>();
        
        CC_Lista_Valores__c horario = new CC_Lista_Valores__c();
        horario.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        horario.Name = 'Calendario_servicios';
        horario.CC_Activa__c = true;
        insert horario;
        
        CC_Lista_Valores__c horarioAccionista = new CC_Lista_Valores__c();
        horarioAccionista.Name = 'Accionista';
        horarioAccionista.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioAccionista.CC_Valor__c = '9';
        horarioAccionista.CC_Valor2__c = '23';
        horarioAccionista.CC_Valor_SFDC__c = 'L-J';
        horarioAccionista.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioAccionista);
        
        CC_Lista_Valores__c horarioAccionista2 = new CC_Lista_Valores__c();
        horarioAccionista2.Name = 'Accionista';
        horarioAccionista2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioAccionista2.CC_Valor__c = '9:30';
        horarioAccionista2.CC_Valor2__c = '19';
        horarioAccionista2.CC_Valor_SFDC__c = 'V';
        horarioAccionista2.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioAccionista2);
        
        CC_Lista_Valores__c horarioImaginBank = new CC_Lista_Valores__c();
        horarioImaginBank.Name = 'ImaginBank';
        horarioImaginBank.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioImaginBank.CC_Valor__c = '9:30';
        horarioImaginBank.CC_Valor2__c = '19';
        horarioImaginBank.CC_Valor_SFDC__c = 'L-J';
        horarioImaginBank.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioImaginBank);
        
        CC_Lista_Valores__c horarioImaginBank2 = new CC_Lista_Valores__c();
        horarioImaginBank2.Name = 'ImaginBank';
        horarioImaginBank2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioImaginBank2.CC_Valor__c = '9:30';
        horarioImaginBank2.CC_Valor2__c = '19';
        horarioImaginBank2.CC_Valor_SFDC__c = 'V';
        horarioImaginBank2.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioImaginBank2);
        insert horariosInsertar;
        
        
        List<CC_Lista_Valores__c> festivosInsertar = new List<CC_Lista_Valores__c>();
        
        CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
        festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        festivos.Name = 'Festivos nacionales';
        festivos.CC_Activa__c = true;
        insert festivos;
        
        CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
        festivo1.Name = 'Festivo';
        festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        festivo1.CC_Valor__c = '11';
        festivo1.CC_Valor2__c = '11';
        festivo1.CC_Lista__c = festivos.Id;
        festivo1.CC_Activa__c = true;
        festivosInsertar.add(festivo1);
        
        CC_Lista_Valores__c festivo2 = new CC_Lista_Valores__c();
        festivo2.Name = 'Festivo2';
        festivo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        festivo2.CC_Valor__c = '10';
        festivo2.CC_Valor2__c = '10';
        festivo2.CC_Lista__c = festivos.Id;
        festivo2.CC_Activa__c = true;
        festivosInsertar.add(festivo2);
        insert festivosInsertar;

        Test.startTest();
        caso3.Status = 'Pendiente Incidencia'; 
        update caso3;
        
        Test.stopTest();

        System.assertEquals(caso3.Status, 'Pendiente Incidencia', 'La asignación del nuevo estado no ha funcionado.');

    }
    
    @isTest
    public static void asignacionTRZ(){
        
        // if (caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.CC_Fecha_Reapertura__c == null && caso.CC_Fecha_Limite_Resolucion__c != null) {
            
            // Alta de datos para la prueba
            Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            CC_MCC__c mccTematica = new CC_MCC__c();
            mccTematica.Name = 'ImaginBank';
            mccTematica.CC_Tipo_Cliente__c = 'Cliente';
            mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccTematica.RecordTypeId = recordTypeIdTematica;
            mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        	mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
            insert mccTematica;
            
            Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            CC_MCC__c mccProducto = new CC_MCC__c();
            mccProducto.Name = 'Migración';
            mccProducto.CC_Tipo_Cliente__c = 'Cliente';
            mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccProducto.RecordTypeId = recordTypeIdProducto;
            mccProducto.CC_Tematica__c = mccTematica.Id;
            mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
            insert mccProducto; 
            
            Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Reversión';
            mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccMotivo.RecordTypeId = recordTypeIdMotivo;
            mccMotivo.CC_Tematica__c = mccTematica.Id;
            mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
            insert mccMotivo;

            Id recordTypeIdTematicaAM = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            CC_MCC__c mccTematicaAM = new CC_MCC__c();
            mccTematicaAM.Name = 'ImaginBank';
            mccTematicaAM.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
            mccTematicaAM.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccTematicaAM.RecordTypeId = recordTypeIdTematicaAM;
            mccTematicaAM.CC_Codigo_Externo__c = 'TE-000002';
            insert mccTematicaAM;
            
            Id recordTypeIdProductoAM = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            CC_MCC__c mccProductoAM = new CC_MCC__c();
            mccProductoAM.Name = 'Migración';
            mccProductoAM.CC_Tipo_Cliente__c ='Cliente (CAM)/Empleado (CAM)';
            mccProductoAM.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccProductoAM.RecordTypeId = recordTypeIdProductoAM;
            mccProductoAM.CC_Tematica__c = mccTematicaAM.Id;
            mccProductoAM.CC_Codigo_Externo__c = 'PR-000002'; 
            insert mccProductoAM; 
            
            Id recordTypeIdMotivoAM = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            CC_MCC__c mccMotivoAM = new CC_MCC__c();
            mccMotivoAM.Name = 'Reversión';
            mccMotivoAM.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
            mccMotivoAM.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccMotivoAM.RecordTypeId = recordTypeIdMotivoAM;
            mccMotivoAM.CC_Tematica__c = mccTematicaAM.Id;
            mccMotivoAM.CC_Producto_Servicio__c = mccProductoAM.Id;
            mccMotivoAM.CC_Codigo_Externo__c = 'MO-000002';
            insert mccMotivoAM;
            
            Account cuenta = new Account();
            cuenta.recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cuenta.Name = 'Smith';
            cuenta.CC_Numero_Documento__c = '64850344G';
            insert cuenta;
            
            Contact contacto = new Contact();
            contacto.recordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            contacto.LastName = 'Smith';
            contacto.CC_Numero_Documento__c = '64850344G';
            contacto.AccountId = cuenta.Id;
            insert contacto;

            List<Case> casosAsignacionTRZ = new List<Case>();
            
            Case casoAsignacionTRZ = new Case();
            casoAsignacionTRZ.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            casoAsignacionTRZ.Status = 'Activo';
            casoAsignacionTRZ.CC_Idioma__c = 'es';
            casoAsignacionTRZ.Subject = 'Asunto';
            casoAsignacionTRZ.Description = 'Descripción';
            casoAsignacionTRZ.CC_Detalles_Consulta__c = 'Detalles Consulta';
            casoAsignacionTRZ.CC_Detalles_Solucion__c = 'Detalles Solución';
            casoAsignacionTRZ.AccountId = cuenta.Id;
            casoAsignacionTRZ.ContactId = contacto.Id;
            casoAsignacionTRZ.CC_MCC_Tematica__c = mccTematica.Id;
            casoAsignacionTRZ.CC_MCC_ProdServ__c = mccProducto.Id;
            casoAsignacionTRZ.CC_MCC_Motivo__c = mccMotivo.Id;
            casoAsignacionTRZ.Origin = 'Phone';
            casoAsignacionTRZ.CC_Fecha_Traslado_Colaborador__c = Datetime.now().addDays(2);
            casoAsignacionTRZ.CC_Canal_Procedencia__c = 'ImaginBank';
            casoAsignacionTRZ.CC_Inicio_Pendiente_Cliente__c = Datetime.now().addHours(22);
            casoAsignacionTRZ.CC_Fin_Pendiente_Cliente__c = Datetime.now().addHours(23);
            casosAsignacionTRZ.add(casoAsignacionTRZ);

            
            Case casoAsignacionTRZ2 = new Case();
            casoAsignacionTRZ2.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
            casoAsignacionTRZ2.Status = 'Activo';
            casoAsignacionTRZ2.CC_Idioma__c = 'es';
            casoAsignacionTRZ2.Subject = 'Asunto';
            casoAsignacionTRZ2.Description = 'Descripción';
            casoAsignacionTRZ2.CC_Detalles_Consulta__c = 'Detalles Consulta';
            casoAsignacionTRZ2.CC_Detalles_Solucion__c = 'Detalles Solución';
            casoAsignacionTRZ2.AccountId = cuenta.Id;
            casoAsignacionTRZ2.ContactId = contacto.Id;
            casoAsignacionTRZ2.CC_MCC_Tematica__c = mccTematicaAM.Id;
            casoAsignacionTRZ2.CC_MCC_ProdServ__c = mccProductoAM.Id;
            casoAsignacionTRZ2.CC_MCC_Motivo__c = mccMotivoAM.Id;
            casoAsignacionTRZ2.Origin = 'Email';
            casoAsignacionTRZ2.CC_Fecha_Traslado_Colaborador__c = Datetime.now().addDays(2);
            casoAsignacionTRZ2.CC_Canal_Procedencia__c = 'Buzón Carteras';
            casoAsignacionTRZ2.CC_Inicio_Pendiente_Cliente__c = Datetime.now().addHours(22);
            casoAsignacionTRZ2.CC_Fin_Pendiente_Cliente__c = Datetime.now().addHours(23);
            
            casosAsignacionTRZ.add(casoAsignacionTRZ2);
            
            insert casosAsignacionTRZ; 
            casosAsignacionTRZ.clear();
            casoAsignacionTRZ.OwnerId = [SELECT ID FROM User WHERE Email = 'tuser000@amamama.com' AND FirstName = 'first 11212' LIMIT 1].Id;
            casoAsignacionTRZ.CC_Fecha_Limite_Resolucion__c = System.now();
            casoAsignacionTRZ.Status = 'Cerrado';

            casoAsignacionTRZ2.OwnerId = [SELECT ID FROM User WHERE Email = 'tuser000@amamama.com' AND FirstName = 'first 11212' LIMIT 1].Id;
            casoAsignacionTRZ2.CC_Fecha_Limite_Resolucion__c = System.now();
            casoAsignacionTRZ2.Status = 'Cerrado';

            casosAsignacionTRZ.add(casoAsignacionTRZ);
            casosAsignacionTRZ.add(casoAsignacionTRZ2);

            update casosAsignacionTRZ;
            
            System.assertEquals('Cerrada',[SELECT CC_Tramo_TRZ__c FROM Case WHERE Id = :casoAsignacionTRZ.Id LIMIT 1].CC_Tramo_TRZ__c);
        }
    
    	@isTest
        public static void calcularSLAFormularioConsultasOperativasBI(){

            List<CC_Lista_Valores__c> festivosInsertar = new List<CC_Lista_Valores__c>();
        
            CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
            festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            festivos.Name = 'Festivos nacionales';
            festivos.CC_Activa__c = true;
            insert festivos;
            
            CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
            festivo1.Name = 'Reyes';
            festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo1.CC_Valor__c = '06';
            festivo1.CC_Valor2__c = '01';
            festivo1.CC_Lista__c = festivos.Id;
            festivo1.CC_Activa__c = true;
            festivosInsertar.add(festivo1);
            
            CC_Lista_Valores__c festivo2 = new CC_Lista_Valores__c();
            festivo2.Name = 'Random';
            festivo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo2.CC_Valor__c = String.valueOf(Datetime.now().addDays(1).day());
            festivo2.CC_Valor2__c = String.valueOf(Datetime.now().addDays(1).month());
            festivo2.CC_Lista__c = festivos.Id;
            festivo2.CC_Activa__c = true;
            festivosInsertar.add(festivo2);

            CC_Lista_Valores__c festivo3 = new CC_Lista_Valores__c();
            festivo3.Name = 'New year';
            festivo3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo3.CC_Valor__c = '1';
            festivo3.CC_Valor2__c = '1';
            festivo3.CC_Lista__c = festivos.Id;
            festivo3.CC_Activa__c = true;
            festivosInsertar.add(festivo3);


            insert festivosInsertar;
            
            
            
            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            listadoCasos.add(caso);

            Case caso2 = new Case();
            caso2.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso2.Status = 'Activo';
            caso2.CC_Idioma__c = 'es';
            caso2.Subject = 'Asunto';
            caso2.Description = 'Descripción';
            caso2.Origin = 'Email';
            caso2.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso2.CC_Canal_Resolucion__c = 'RRHH';
            listadoCasos.add(caso2);

            Case caso3 = new Case();
            caso3.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso3.Status = 'Activo';
            caso3.CC_Idioma__c = 'es';
            caso3.Subject = 'Asunto';
            caso3.Description = 'Descripción';
            caso3.Origin = 'Email';
            caso3.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso3.CC_Canal_Resolucion__c = 'RRHH';
            listadoCasos.add(caso3);

            Case caso4 = new Case();
            caso4.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso4.Status = 'Activo';
            caso4.CC_Idioma__c = 'es';
            caso4.Subject = 'Asunto';
            caso4.Description = 'Descripción';
            caso4.Origin = 'Email';
            caso4.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso4.CC_Canal_Resolucion__c = 'RRHH';
            listadoCasos.add(caso4);
            List<Case> preCasos = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c = 'Formulario Consultas Operativas'];
            Test.startTest();
            insert listadoCasos;
            Test.stopTest();
            List<Case> casosInsertados = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c = 'Formulario Consultas Operativas'];
            Test.setCreatedDate(casosInsertados[1].Id, DateTime.newInstance(2022, 1, 5, 20, 30, 00));

            System.assertNotEquals(preCasos.size(), casosInsertados.size(), 'La inserción de casos no ha tenido en cuenta el SLA de los dias festivos.');
        }

        @isTest
        public static void calcularSLADiaFestivoFormularioConsultasOperativasBI(){
            List<CC_Lista_Valores__c> festivosInsertar = new List<CC_Lista_Valores__c>();
        
            CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
            festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            festivos.Name = 'Festivos nacionales';
            festivos.CC_Activa__c = true;
            insert festivos;
            
            CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
            festivo1.Name = 'Reyes';
            festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo1.CC_Valor__c = String.valueOf(Datetime.now().day());
            festivo1.CC_Valor2__c = String.valueOf(Datetime.now().month());
            festivo1.CC_Lista__c = festivos.Id;
            festivo1.CC_Activa__c = true;
            festivosInsertar.add(festivo1);

            insert festivosInsertar;
            
            
            
            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'AsuntoTest1234';
            caso.Description = 'Descripción';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            listadoCasos.add(caso);
            
            List<Case> preCasos = [SELECT Id FROM Case WHERE Subject = 'AsuntoTest1234'];
            Test.startTest();
            List<Database.SaveResult> resultadosCierreCaso =   Database.insert(listadoCasos, false);
            //System.debug('res test insert ' + resultadosCierreCaso);
            Test.stopTest();
            List<Case> casosInsertados = [SELECT Id FROM Case WHERE Subject = 'AsuntoTest1234'];
            Test.setCreatedDate(casosInsertados[0].Id, DateTime.newInstance(2022, 1, 5, 20, 30, 00));

            System.assertNotEquals(preCasos.size(), casosInsertados.size(), 'La inserción de casos no ha tenido en cuenta el SLA de los dias festivos.');


        }

        @isTest
        public static void encryptPANs(){
            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            caso.CC_PAN__c = '35778451826574';
            caso.CC_PAN_Encriptado__c = false;
            

            Case caso2 = new Case();
            caso2.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso2.Status = 'Activo';
            caso2.CC_Idioma__c = 'es';
            caso2.Subject = 'Asunto';
            caso2.Description = 'Descripción';
            caso2.Origin = 'Email';
            caso2.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso2.CC_Canal_Resolucion__c = 'RRHH';
            caso2.CC_Digitos_Tarjeta__c = '35778451826574';
            caso2.CC_DigitosTarjeta_Encriptado__c = false;

            Test.startTest();
            insert caso;
            insert caso2;
            Test.stopTest();

            Case c = [SELECT Id, CC_DigitosTarjeta_Encriptado__c FROM Case WHERE Id =: caso2.Id];

            System.assertNotEquals(caso2.CC_DigitosTarjeta_Encriptado__c, c.CC_DigitosTarjeta_Encriptado__c, 'La encriptación de los dígitos de la cuenta ha fallado.');


        }

        @isTest
        public static void horaSLAConsultasOperativasPausa(){


            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;

            Test.startTest();
            caso.Status = 'Pendiente Colaborador';
            update caso;
            Test.stopTest();

            System.assertNotEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);

        }

        @isTest
        public static void horaSLAConsultasOperativasRenaudar(){


            CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
            festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            festivos.Name = 'Festivos nacionales';
            festivos.CC_Activa__c = true;
            insert festivos;
            
            CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
            festivo1.Name = 'Reyes';
            festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo1.CC_Valor__c = String.valueOf(Datetime.now().day());
            festivo1.CC_Valor2__c = String.valueOf(Datetime.now().month());
            festivo1.CC_Lista__c = festivos.Id;
            festivo1.CC_Activa__c = true;
            insert festivo1;

            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;

            caso.Status = 'Pendiente Colaborador';
            update caso;

            Test.startTest();
            caso.Status = 'Activo';
            update caso;
            Test.stopTest();

            System.assertEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);

        }

        @isTest
        public static void horaSLAConsultasOperativasRenaudarPdteInterno() {
            CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
            festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            festivos.Name = 'Festivos nacionales';
            festivos.CC_Activa__c = true;
            insert festivos;
            
            CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
            festivo1.Name = 'Reyes';
            festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo1.CC_Valor__c = String.valueOf(Datetime.now().day());
            festivo1.CC_Valor2__c = String.valueOf(Datetime.now().month());
            festivo1.CC_Lista__c = festivos.Id;
            festivo1.CC_Activa__c = true;
            insert festivo1;

            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;

            caso.Status = 'Pendiente Interno';
            update caso;

            Test.startTest();
            caso.Status = 'Activo';
            update caso;
            Test.stopTest();
            System.assertNotEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);
        }

        @isTest
        public static void horaSLAConsultasOperativasRenaudarPdteCliente(){


            CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
            festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            festivos.Name = 'Festivos nacionales';
            festivos.CC_Activa__c = true;
            insert festivos;
            
            CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
            festivo1.Name = 'Reyes';
            festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo1.CC_Valor__c = String.valueOf(Datetime.now().day());
            festivo1.CC_Valor2__c = String.valueOf(Datetime.now().month());
            festivo1.CC_Lista__c = festivos.Id;
            festivo1.CC_Activa__c = true;
            insert festivo1;

            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;

            caso.Status = 'Pendiente Cliente';
            update caso;

            Test.startTest();
            caso.Status = 'Activo';
            update caso;
            Test.stopTest();

            System.assertEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);

        }

        @isTest
        public static void horaSLAConsultasOperativasRenaudarPdteIncidencia(){


            CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
            festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            festivos.Name = 'Festivos nacionales';
            festivos.CC_Activa__c = true;
            insert festivos;
            
            CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
            festivo1.Name = 'Reyes';
            festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo1.CC_Valor__c = '01';
            festivo1.CC_Valor2__c = '01';
            festivo1.CC_Lista__c = festivos.Id;
            festivo1.CC_Activa__c = true;
            insert festivo1;

            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;

            caso.Status = 'Pendiente Incidencia';
            update caso;

            Test.startTest();
            caso.Status = 'Activo';
            update caso;
            Test.stopTest();

            System.assertEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);

        }

        @isTest
        public static void cambioPendienteIncidencia(){


            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;
            caso.Status = 'Pendiente Incidencia';
            update caso;
            Test.startTest();
            caso.Status = 'Activo';
            update caso;
            Test.stopTest();

            System.assertNotEquals(null, [SELECT CC_Fin_Pendiente_Incidencia__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_Fin_Pendiente_Incidencia__c);

        }

        @isTest
        public static void cambioPendienteInterno(){
            
            List<Case> listadoCasos = new List<Case>();
            User usuario = [Select id from User where email = 'tuser0004@amamama.com' limit 1];
            
            Account cuenta = new Account();
            cuenta.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
            cuenta.Name = 'Smith';
            cuenta.CC_Numero_Documento__c = '64850344G';
            insert cuenta;
            
            Contact contacto = new Contact();
            contacto.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
            contacto.LastName = 'Smith';
            contacto.CC_Numero_Documento__c = '64850344G';
            contacto.AccountId = cuenta.Id;
        	contacto.CC_Matricula__c = 'U011152';
            insert contacto;
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        
        Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'ImaginBank';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;
        
        Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Migración';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Reversión';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Id recordTypeIdCausa = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Solicita reversión';
        mccCausa.CC_Tipo_Cliente__c = 'Empleado';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        insert mccCausa;
        CC_MCC__c solucion = new CC_MCC__c();
        solucion.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        solucion.Name = 'Actualizar Sistema';
        solucion.CC_Tipo_Cliente__c = 'Empleado';
        solucion.CC_Causa__c = mccCausa.Id;
        solucion.CC_Codigo_Externo__c = 'CA-000002';
        insert solucion;
        
            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            caso.CC_MCC_Tematica__c = mccTematica.Id;
        	caso.CC_MCC_ProdServ__c = mccProducto.Id;
        	caso.CC_MCC_Motivo__c = mccMotivo.Id;
	        caso.CC_MCC_Causa__c = mccCausa.Id;
        	caso.CC_MCC_Solucion__c = solucion.Id;
        	caso.AccountId = cuenta.Id;
        	caso.ContactId = contacto.Id;
            insert caso;
            caso.Status = 'Pendiente Interno';
            update caso;
           
            Task tarea = new Task();
            tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
            tarea.Subject = 'Tarea para ver si se actualiza el campo última actualización';
            tarea.Status = 'Open';
            tarea.type = 'Traslado Tercer Nivel';
            tarea.WhatId = caso.id;
            insert tarea; 

            Test.startTest();
            caso.Status = 'Activo';
            update caso;
            
            
            tarea.Status = 'Completed';
            update tarea;
            
            caso.CC_Resolucion__c = '.';
            caso.CC_Detalles_Consulta__c = '.';
            caso.Status = 'Cerrado';
            update caso; 	
            Test.stopTest();
            
			//Con el cambio de la incidencia IN1041803 ahora el cambiar de pendiente interno a Activo ya no debe de rellenar la fecha fin
            System.assertEquals(null, [SELECT CC_Fin_Pendiente_Interno__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_Fin_Pendiente_Interno__c);


        }

        @isTest
        public static void cambioPendienteCliente(){

            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;
            caso.Status = 'Pendiente Cliente';
            update caso;

            Test.startTest();
            caso.Status = 'Activo';
            update caso;
            Test.stopTest();


            System.assertNotEquals(null, [SELECT CC_Fin_Pendiente_Cliente__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_Fin_Pendiente_Cliente__c);
        }
    
    @isTest
        public static void testcambioPropietarioColaConsultasOperativas(){

            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            caso.CC_Cola_Procedencia__c = 'CC_ConsForm_Tarjetas_Comercios';
            insert caso;
            
            Test.startTest();
            caso.Status = 'Pendiente Cliente';
            update caso;
            Test.stopTest();

			Case casoUpdate = [Select id, OwnerId from Case where id = :caso.Id limit 1];
            List<Group> colas = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_ConsForm_Tarjetas_Comercios']; 
            System.assertEquals(colas.get(0).Id, casoUpdate.OwnerId);
        }
    
    @isTest
        public static void testenvioCorreoConsultasOperativasAsignarPropietario(){

            List<Case> listadoCasos = new List<Case>();
            List<Group> colas = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_ConsForm_Tarjetas_Comercios']; 
            Case caso = new Case();
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            caso.CC_Cola_Procedencia__c = 'CC_ConsForm_Tarjetas_Comercios';
            caso.OwnerId = colas.get(0).Id;
            insert caso;
            
            Test.startTest();
            caso.OwnerId = [SELECT ID FROM User WHERE Email = 'tuser000@amamama.com' AND FirstName = 'first 11212' LIMIT 1].Id;//caso.OwnerId = UserInfo.getUserId();
            update caso;
            Test.stopTest();

			Case casoUpdate = [Select id, CC_Correo_Asignacion_Enviado__c from Case where id = :caso.Id limit 1];
            
            System.assert(casoUpdate != null, 'Comprobamos el caso.');
        }

        @isTest
        public static void testPruebaRobot(){


            Id recordTypeIdTematica = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            CC_MCC__c mccTematica = new CC_MCC__c();
            mccTematica.Name = 'Contactos erróneos';
            mccTematica.CC_Tipo_Cliente__c = 'Cliente';
            mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccTematica.RecordTypeId = recordTypeIdTematica;
            mccTematica.CC_Codigo_Externo__c = 'TE-000120';
        	mccTematica.CC_Canal_Operativo__c = 'Sin canal';
            insert mccTematica;
            
            Id recordTypeIdProducto = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            CC_MCC__c mccProducto = new CC_MCC__c();
            mccProducto.Name = 'Pruebas Salesforce';
            mccProducto.CC_Tipo_Cliente__c = 'Cliente';
            mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccProducto.RecordTypeId = recordTypeIdProducto;
            mccProducto.CC_Tematica__c = mccTematica.Id;
            mccProducto.CC_Codigo_Externo__c = 'PR-001318'; 
            insert mccProducto; 
            
            Id recordTypeIdMotivo = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Contacto de prueba';
            mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccMotivo.RecordTypeId = recordTypeIdMotivo;
            mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo.CC_Codigo_Externo__c = 'MO-012087';
            insert mccMotivo;

            Id recordTypeIdCausa = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
            CC_MCC__c mccCausa = new CC_MCC__c();
            mccCausa.Name = 'Pruebas/Validaciones';
            mccCausa.CC_Tipo_Cliente__c = 'Cliente';
            mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccCausa.RecordTypeId = recordTypeIdCausa;
            mccCausa.CC_Motivo__c = mccMotivo.Id;
            mccCausa.CC_Codigo_Externo__c = 'CA-015680'; 
            insert mccCausa; 
            
            Id recordTypeIdSolucion = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
            CC_MCC__c mccSolucion = new CC_MCC__c();
            mccSolucion.Name = 'No aplica';
            mccSolucion.CC_Tipo_Cliente__c = 'Cliente';
            mccSolucion.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccSolucion.RecordTypeId = recordTypeIdSolucion;
            mccSolucion.CC_Causa__c = mccCausa.Id;
            mccSolucion.CC_Codigo_Externo__c = 'SO-033729';
            insert mccSolucion;

            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case(); 
            caso.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Prueba Robot';
            caso.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'ImaginBank';
            
            Test.startTest();
            insert caso;
            Test.stopTest();

			Case casoRobot = [Select id, Status from Case where id = :caso.Id limit 1];
            
            System.assertEquals( 'Rechazado' , casoRobot.Status);
        }
        @isTest
    public static void casoGestionIA() {

        User usuarioGestor = [SELECT Id FROM User WHERE IsActive = true AND Email = 'tuser000@amamama.com' AND firstname = 'first2'];

        System.runAs(usuarioGestor) {
            Account cuenta = new Account();
            cuenta.Name = 'PRUEBA TEST';
            cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
            insert(cuenta);
    
            Contact contacto = new Contact();
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
            contacto.FirstName = 'Test';
            contacto.LastName = 'Prueba';
            contacto.Email = 'mp@test.com';
            contacto.AccountId = cuenta.Id;
            insert(contacto);
    
            Id casoClienteRt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Case casoCliente = new Case();
            casoCliente.RecordTypeId = casoClienteRt;
            casoCliente.Subject = 'Caso cliente IA';
            casoCliente.Origin = 'Phone';
            casoCliente.CC_Canal_Respuesta__c = 'Phone';
            casoCliente.CC_Tipo_Cliente__c = 'Cliente';
            casoCliente.CC_No_Identificado__c = true;
            casoCliente.CC_Canal_Procedencia__c = 'CaixaBankNow';
            casoCliente.AccountId = cuenta.id;
            
        Test.startTest();
        insert casoCliente;
        Test.stopTest();

        // Verificar que el caso tiene el ID de la extensión asignado
        Case casoInsertado = [SELECT Id, CBK_Case_Extension_Id__c FROM Case WHERE Id = :casoCliente.Id];
        System.assertNotEquals(null, casoInsertado.CBK_Case_Extension_Id__c, 'El caso no tiene el ID de la extensión asignado.');
        }
    }
    
    }