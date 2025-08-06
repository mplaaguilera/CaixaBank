@isTest
public with sharing class OS_WS_AltaCasoValija_Test {
    
    @TestSetup
    static void makeData(){
        User usuarioAdmin = OS_Usuarios.usuarioAdmin();
        User usuarioOperador = OS_Usuarios.usuarioOperador();
    }
	
    @isTest
    public static void test() {
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Profile.Name = 'System Administrator' LIMIT 1];

        Id businessHoursId;
        BusinessHours[] stdBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Default' AND IsActive = true];
        businessHoursId = stdBusinessHours[0].Id;
        if(stdBusinessHours.isEmpty()){
            businessHoursId = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1].Id;
        } 
        
        EmailTemplate plantilla = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'OS_Servicio_Bastanteo' LIMIT 1];
        if (plantilla == null) {
            plantilla = new EmailTemplate();
            plantilla.FolderId = usuarioAdmin.Id;
            plantilla.Name = 'Test Plantilla';
            plantilla.DeveloperName = 'OS_Servicio_Bastanteo';
            plantilla.TemplateType = 'Text';
            plantilla.Subject = 'Test Subject';
            plantilla.HtmlValue = 'Body Subject';
            plantilla.IsActive = true;
            System.runAs (usuarioAdmin) {  
            	insert plantilla;
        	}
        }
             
		
        Account cuenta1 = new Account();
        cuenta1.Name = 'Cuenta Test Cliente';
        cuenta1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert cuenta1;
        
		Id recordTypeContacto = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
		Contact contacto = new Contact();
        contacto.RecordTypeId = recordTypeContacto;
        contacto.Email = 'servicio.bastanteo@caixabank.com';    
        contacto.LastName = 'Pruebas';
        contacto.AccountId = cuenta1.Id;
        insert contacto;
        
        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();

        CC_Grupo_Colaborador__c grupoColaborador  = new CC_Grupo_Colaborador__c();
        grupoColaborador.RecordTypeId = recordTypeGrupoColaborador;
        grupoColaborador.Name = 'Servicio bastanteo';
        grupoColaborador.OS_Negocio__c = 'COPS';
        insert grupoColaborador;
        
        CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c();
        colaborador.CC_Contacto__c = contacto.Id;
        colaborador.CC_Grupo_Colaborador__c=grupoColaborador.Id;
		insert colaborador;   
        
        CC_Grupo_Colaborador_Plantilla__c grupoPlantilla = new CC_Grupo_Colaborador_Plantilla__c();
        grupoPlantilla.CC_Grupo_Colaborador__c = grupoColaborador.Id;
        grupoPlantilla.CC_Plantilla_DeveloperName__c = 'OS_Servicio_Bastanteo';
        grupoPlantilla.CC_Operativa__c = 'Trasladar';
        insert grupoPlantilla;
        
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'account temp';
        cuenta.CC_Numero_Oficina__c = '09000';
        insert cuenta;
        
        Contact empleado = new Contact();
        empleado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        empleado.FirstName = 'CC_Empleado';
        empleado.LastName = 'CC_Empleado';
        empleado.AccountId = cuenta.Id;
        empleado.CC_Num_Empleado__c = '12345';
        insert empleado;
        
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.OS_Horario__c = businessHoursId;
        mccTematica.OS_Departamento__c = 'UAC';
        mccTematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TEC-000001';
		mccTematica.OS_Buzon_Salida__c = [SELECT DisplayName FROM OrgWideEmailAddress WHERE DISPLAYNAME = 'Buzón de pruebas COPS' OR DISPLAYNAME = 'Buzón KYC Renewal' OR DISPLAYNAME = 'Buzón Service Desk' OR DISPLAYNAME = 'Buzón Comercio Exterior' OR DISPLAYNAME = 'Buzón Export Online' OR DISPLAYNAME = 'Buzón International Support'OR DISPLAYNAME = 'Buzón Contact Center International' LIMIT 1].DisplayName;
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PRC-000001'; 
        insert mccProducto; 
        
        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'Apertura sin autorización';
        motivo.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        motivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
        motivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tematica__c = mccTematica.Id;
        motivo.CC_Producto_Servicio__c = mccProducto.Id;
        motivo.CC_Codigo_Externo__c = 'MOC-000001';
        insert motivo;
        
        CC_MCC__c motivo2 = new CC_MCC__c();
        motivo2.Name = 'Pruebas bastanteo';
        motivo2.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        motivo2.CC_Fecha_Vigencia_Inicio__c = Date.today();
        motivo2.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo2.CC_Tematica__c = mccTematica.Id;
        motivo2.CC_Producto_Servicio__c = mccProducto.Id;
        motivo2.CC_Codigo_Externo__c = 'MOC-000002';
        insert motivo2;
        
        //Lista de valores para clasificación automática
        CC_Lista_Valores__c clasificacionesAutomaticas = new CC_Lista_Valores__c();
        clasificacionesAutomaticas.Name = 'COPS: Clasificaciones automáticas para valija digital';
        clasificacionesAutomaticas.CC_Activa__c = true;
        clasificacionesAutomaticas.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        insert clasificacionesAutomaticas;

        CC_Lista_Valores__c clasificacionAutomatica2 = new CC_Lista_Valores__c();
        clasificacionAutomatica2.Name = 'Bastanteo Analizar';
        clasificacionAutomatica2.CC_Activa__c = true;
        clasificacionAutomatica2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        clasificacionAutomatica2.CC_Lista__c = clasificacionesAutomaticas.Id;
        clasificacionAutomatica2.CC_Valor__c = motivo2.Id;
        insert clasificacionAutomatica2;
        
        System.runAs (usuarioAdmin) {       
            Test.startTest();
            OS_WS_AltaCasoValija.Output output = OS_WS_AltaCasoValija.altaCasoValija();
            Test.stopTest();

            System.assertEquals('OK', output.resultado);

            Case c = [SELECT CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c FROM Case WHERE Id = :output.caseId];
            System.assertNotEquals(null, c.CC_MCC_Tematica__c);
            System.assertNotEquals(null, c.CC_MCC_ProdServ__c);
            System.assertNotEquals(null, c.CC_MCC_Motivo__c);
        }
    }

    @isTest
    public static void test2() {
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Profile.Name = 'System Administrator' LIMIT 1];

        Id businessHoursId;
        BusinessHours[] stdBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Default' AND IsActive = true];
        businessHoursId = stdBusinessHours[0].Id;
        if(stdBusinessHours.isEmpty()){
            businessHoursId = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1].Id;
        } 
        
        EmailTemplate plantilla = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'OS_Servicio_Bastanteo' LIMIT 1];
        if (plantilla == null) {
            plantilla = new EmailTemplate();
            plantilla.FolderId = usuarioAdmin.Id;
            plantilla.Name = 'Test Plantilla';
            plantilla.DeveloperName = 'OS_Servicio_Bastanteo';
            plantilla.TemplateType = 'Text';
            plantilla.Subject = 'Test Subject';
            plantilla.HtmlValue = 'Body Subject';
            plantilla.IsActive = true;
            System.runAs (usuarioAdmin) {  
            	insert plantilla;
        	}
        }
		
        Account cuenta1 = new Account();
        cuenta1.Name = 'Cuenta Test Cliente';
        cuenta1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert cuenta1;
        
		Id recordTypeContacto = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
		Contact contacto = new Contact();
        contacto.RecordTypeId = recordTypeContacto;
        contacto.Email = 'servicio.bastanteo@caixabank.com';    
        contacto.LastName = 'Pruebas';
        contacto.AccountId = cuenta1.Id;
        insert contacto;
        
        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();

        CC_Grupo_Colaborador__c grupoColaborador  = new CC_Grupo_Colaborador__c();
        grupoColaborador.RecordTypeId = recordTypeGrupoColaborador;
        grupoColaborador.Name = 'Servicio bastanteo';
        grupoColaborador.OS_Negocio__c = 'COPS';
        insert grupoColaborador;
        
        CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c();
        colaborador.CC_Contacto__c = contacto.Id;
        colaborador.CC_Grupo_Colaborador__c=grupoColaborador.Id;
		insert colaborador;   
        
        CC_Grupo_Colaborador_Plantilla__c grupoPlantilla = new CC_Grupo_Colaborador_Plantilla__c();
        grupoPlantilla.CC_Grupo_Colaborador__c = grupoColaborador.Id;
        grupoPlantilla.CC_Plantilla_DeveloperName__c = 'OS_Servicio_Bastanteo';
        grupoPlantilla.CC_Operativa__c = 'Trasladar';
        insert grupoPlantilla;
        
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'account temp';
        cuenta.CC_Numero_Oficina__c = '09000';
        cuenta.CC_Email__c = 'destino.email@prueba.com';
        insert cuenta;
        
        Contact empleado = new Contact();
        empleado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        empleado.FirstName = 'CC_Empleado';
        empleado.LastName = 'CC_Empleado';
        empleado.AccountId = cuenta.Id;
        empleado.CC_Num_Empleado__c = '12345';
        insert empleado;
        
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.OS_Horario__c = businessHoursId;
        mccTematica.OS_Departamento__c = 'UAC';
        mccTematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TEC-000001';
		mccTematica.OS_Buzon_Salida__c = [SELECT DisplayName FROM OrgWideEmailAddress WHERE DISPLAYNAME = 'Buzón de pruebas COPS' OR DISPLAYNAME = 'Buzón KYC Renewal' OR DISPLAYNAME = 'Buzón Service Desk' OR DISPLAYNAME = 'Buzón Comercio Exterior' OR DISPLAYNAME = 'Buzón Export Online' OR DISPLAYNAME = 'Buzón International Support'OR DISPLAYNAME = 'Buzón Contact Center International' LIMIT 1].DisplayName;
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PRC-000001'; 
        insert mccProducto; 
        
        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'Apertura sin autorización';
        motivo.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        motivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
        motivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tematica__c = mccTematica.Id;
        motivo.CC_Producto_Servicio__c = mccProducto.Id;
        motivo.CC_Codigo_Externo__c = 'MOC-000001';
        insert motivo;
        
        CC_MCC__c motivo2 = new CC_MCC__c();
        motivo2.Name = 'Pruebas bastanteo';
        motivo2.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        motivo2.CC_Fecha_Vigencia_Inicio__c = Date.today();
        motivo2.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo2.CC_Tematica__c = mccTematica.Id;
        motivo2.CC_Producto_Servicio__c = mccProducto.Id;
        motivo2.CC_Codigo_Externo__c = 'MOC-000002';
        insert motivo2;
        
        //Lista de valores para clasificación automática
        CC_Lista_Valores__c clasificacionesAutomaticas = new CC_Lista_Valores__c();
        clasificacionesAutomaticas.Name = 'COPS: Clasificaciones automáticas para valija digital';
        clasificacionesAutomaticas.CC_Activa__c = true;
        clasificacionesAutomaticas.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        insert clasificacionesAutomaticas;

        CC_Lista_Valores__c clasificacionAutomatica2 = new CC_Lista_Valores__c();
        clasificacionAutomatica2.Name = 'Bastanteo Analizar';
        clasificacionAutomatica2.CC_Activa__c = true;
        clasificacionAutomatica2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        clasificacionAutomatica2.CC_Lista__c = clasificacionesAutomaticas.Id;
        clasificacionAutomatica2.CC_Valor__c = motivo2.Id;
        insert clasificacionAutomatica2;
        
        OS_WS_AltaCasoValija.Input input = new OS_WS_AltaCasoValija.Input();
        OS_WS_AltaCasoValija.Input inputMock = OS_WS_AltaCasoValija.generarMockCOPS(input);
        Map<String,Integer> reintentos = new Map<String,Integer>();
        inputMock.officeNum = null;
        
        System.runAs (usuarioAdmin) {       
            Test.startTest();
            OS_WS_AltaCasoValija.Output output = OS_WS_AltaCasoValija.gestionPeticionCOPS(inputMock, reintentos);
            Test.stopTest();

            System.assertNotEquals(output, null, 'No se ha generado la variable');
        }
    }

    /*@isTest
    private static void acuseReciboValijaDigital() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
        
        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'account prueba';
        cuenta.CC_Email__c = 'destino.email@prueba.com';
        insert cuenta;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = usuarioOperador.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        System.runAs (usuarioOperador) {
            Case caso = new Case();
            caso.CC_Oficina__c = cuenta.Id;
            caso.AccountId = cuenta.Id;
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCaso;
            caso.Subject = 'pruebaValijaDigital';
            caso.Origin = 'Valija digital';
            caso.CC_Tipo_Contacto__c ='Otros';
            caso.CC_Canal_Procedencia__c = 'Valija digital';
            caso.Description = 'Prueba';
            caso.OS_Referencia_Valija__c = '14092023-00000000001';

            Test.startTest();   
            List<EmailMessage> emBefore = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];
            insert caso;
            List<EmailMessage> emAfter = [SELECT Id FROM EmailMessage WHERE CreatedDate = TODAY];
            System.assertNotEquals(emBefore.size(), emAfter.size(), 'El acuse no se ha enviado.' );
            Test.stopTest();
        }
    }*/
    
    @isTest
    public static void testLockRow() {
        User usuarioAdmin = [SELECT Id FROM User WHERE FirstName = 'AdministradorOS' AND Profile.Name = 'System Administrator' LIMIT 1];

        Id businessHoursId;
        BusinessHours[] stdBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Default' AND IsActive = true];
        businessHoursId = stdBusinessHours[0].Id;
        if(stdBusinessHours.isEmpty()){
            businessHoursId = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1].Id;
        } 
        
        EmailTemplate plantilla = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'OS_Servicio_Bastanteo' LIMIT 1];
        if (plantilla == null) {
            plantilla = new EmailTemplate();
            plantilla.FolderId = usuarioAdmin.Id;
            plantilla.Name = 'Test Plantilla';
            plantilla.DeveloperName = 'OS_Servicio_Bastanteo';
            plantilla.TemplateType = 'Text';
            plantilla.Subject = 'Test Subject';
            plantilla.HtmlValue = 'Body Subject';
            plantilla.IsActive = true;
            System.runAs (usuarioAdmin) {  
            	insert plantilla;
        	}
        }
		
        Account cuenta1 = new Account();
        cuenta1.Name = 'Cuenta Test Cliente';
        cuenta1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert cuenta1;
        
		Id recordTypeContacto = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
		Contact contacto = new Contact();
        contacto.RecordTypeId = recordTypeContacto;
        contacto.Email = 'servicio.bastanteo@caixabank.com';    
        contacto.LastName = 'Pruebas';
        contacto.AccountId = cuenta1.Id;
        insert contacto;
        
        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();

        CC_Grupo_Colaborador__c grupoColaborador  = new CC_Grupo_Colaborador__c();
        grupoColaborador.RecordTypeId = recordTypeGrupoColaborador;
        grupoColaborador.Name = 'Servicio bastanteo';
        grupoColaborador.OS_Negocio__c = 'COPS';
        insert grupoColaborador;
        
        CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c();
        colaborador.CC_Contacto__c = contacto.Id;
        colaborador.CC_Grupo_Colaborador__c=grupoColaborador.Id;
		insert colaborador;   
        
        CC_Grupo_Colaborador_Plantilla__c grupoPlantilla = new CC_Grupo_Colaborador_Plantilla__c();
        grupoPlantilla.CC_Grupo_Colaborador__c = grupoColaborador.Id;
        grupoPlantilla.CC_Plantilla_DeveloperName__c = 'OS_Servicio_Bastanteo';
        grupoPlantilla.CC_Operativa__c = 'Trasladar';
        insert grupoPlantilla;
        
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'account temp';
        cuenta.CC_Numero_Oficina__c = '09000';
        cuenta.CC_Email__c = 'destino.email@prueba.com';
        insert cuenta;
        
        Contact empleado = new Contact();
        empleado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        empleado.FirstName = 'CC_Empleado';
        empleado.LastName = 'CC_Empleado';
        empleado.AccountId = cuenta.Id;
        empleado.CC_Num_Empleado__c = '12345';
        insert empleado;
        
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.OS_Horario__c = businessHoursId;
        mccTematica.OS_Departamento__c = 'UAC';
        mccTematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TEC-000001';
		mccTematica.OS_Buzon_Salida__c = [SELECT DisplayName FROM OrgWideEmailAddress WHERE DISPLAYNAME = 'Buzón de pruebas COPS' OR DISPLAYNAME = 'Buzón KYC Renewal' OR DISPLAYNAME = 'Buzón Service Desk' OR DISPLAYNAME = 'Buzón Comercio Exterior' OR DISPLAYNAME = 'Buzón Export Online' OR DISPLAYNAME = 'Buzón International Support'OR DISPLAYNAME = 'Buzón Contact Center International' LIMIT 1].DisplayName;
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PRC-000001'; 
        insert mccProducto; 
        
        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'Apertura sin autorización';
        motivo.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        motivo.CC_Fecha_Vigencia_Inicio__c = Date.today();
        motivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tematica__c = mccTematica.Id;
        motivo.CC_Producto_Servicio__c = mccProducto.Id;
        motivo.CC_Codigo_Externo__c = 'MOC-000001';
        insert motivo;
        
        CC_MCC__c motivo2 = new CC_MCC__c();
        motivo2.Name = 'Pruebas bastanteo';
        motivo2.CC_Tipo_Cliente__c = 'Empleado (COPS)';
        motivo2.CC_Fecha_Vigencia_Inicio__c = Date.today();
        motivo2.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo2.CC_Tematica__c = mccTematica.Id;
        motivo2.CC_Producto_Servicio__c = mccProducto.Id;
        motivo2.CC_Codigo_Externo__c = 'MOC-000002';
        insert motivo2;
        
        //Lista de valores para clasificación automática
        CC_Lista_Valores__c clasificacionesAutomaticas = new CC_Lista_Valores__c();
        clasificacionesAutomaticas.Name = 'COPS: Clasificaciones automáticas para valija digital';
        clasificacionesAutomaticas.CC_Activa__c = true;
        clasificacionesAutomaticas.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        insert clasificacionesAutomaticas;

        CC_Lista_Valores__c clasificacionAutomatica2 = new CC_Lista_Valores__c();
        clasificacionAutomatica2.Name = 'Bastanteo Analizar';
        clasificacionAutomatica2.CC_Activa__c = true;
        clasificacionAutomatica2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        clasificacionAutomatica2.CC_Lista__c = clasificacionesAutomaticas.Id;
        clasificacionAutomatica2.CC_Valor__c = motivo2.Id;
        insert clasificacionAutomatica2;
        
        OS_WS_AltaCasoValija.Input input = new OS_WS_AltaCasoValija.Input();
        OS_WS_AltaCasoValija.Input inputMock = OS_WS_AltaCasoValija.generarMockCOPS(input);
        Map<String,Integer> reintentos = new Map<String,Integer>();
        inputMock.idValija = '00000000';
        
        System.runAs (usuarioAdmin) {       
            Test.startTest();
            OS_WS_AltaCasoValija.Output output = OS_WS_AltaCasoValija.gestionPeticionCOPS(inputMock, reintentos);
            Test.stopTest();

            System.assertEquals(output.codigo, '9999');
        }
    }
}