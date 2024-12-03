@isTest
public with sharing class CC_Case_Crear_Controller_Test {

    @isTest
    public static void actividadAltaCaso() {

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        Entitlement e = new Entitlement();
        e.Name = 'COPS SLA';
        e.Type = 'Phone Support';
        e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'Entitlement Process COPS' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'cops'].Id;
        insert e;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Subject = 'Caso de prueba';
        caso1.Status = 'Activo';
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c = 'Buzón Comercio Exterior';
        caso1.CC_Canal_Resolucion__c = 'Buzón Comercio Exterior';
        caso1.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso1;


        
        Test.startTest();
        CC_Case_Crear_Controller.crearActividadCasoNuevo(caso1.Id);

        Task t = [SELECT Id FROM Task WHERE WhatId = :caso1.Id LIMIT 1];
        
    	System.assertNotEquals(null, t);
        
        Map<String, Object> retorno = CC_Case_Crear_Controller.obtenerVariablesCOPS(recordTypeCaso, null);
        
        System.assertEquals('OS', retorno.get('recordTypeDeveloperName'));        
        
        Test.stopTest();
        
    }

    @isTest
    public static void esRolSAC() {
/*
        //usuario a usar
        User usuario = new User();
        usuario.Username = 'Name123@testprueba.com';
        usuario.Email = 'email@test.com';
        usuario.LastName = 'Usuario Test';
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        usuario.Alias = 'alias';
        usuario.TimeZoneSidKey = 'GMT';
        usuario.LocaleSidKey = 'es_ES';
        usuario.EmailEncodingKey = 'ISO-8859-1';
        usuario.LanguageLocaleKey = 'en_US';
        usuario.isActive = true;
        usuario.userRoleId = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'].Id;
        insert usuario;

        System.runAs(usuario){ */
            Test.startTest();
            CC_Case_Crear_Controller.RetornoComprobarRol resultado = CC_Case_Crear_Controller.comprobarRol();
            //System.assertEquals(true, resultado.rolSAC, 'No se gestiona correctamente la supervisión del rol de usuarioFalso');
            Test.stopTest();
      //  }

    }

    @isTest
    public static void esRolTMS(){
        User usuario = new User();
        usuario.FirstName = 'Usuario';
        usuario.LastName = '1';    
        usuario.IsActive = true; 	
        usuario.Alias = 'us';
        usuario.Email = 'usuario_test@test.com';
        usuario.EmailEncodingKey = 'ISO-8859-1';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Testamentarías'].Id;
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'TMS_UsuarioCaixabank'].Id;
        usuario.TimeZoneSidKey = 'Europe/Madrid';
        usuario.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com'; 	
        insert usuario;

        System.runAs(usuario){
            Test.startTest();
            CC_Case_Crear_Controller.RetornoComprobarRol resultado = CC_Case_Crear_Controller.comprobarRol();
            System.assertEquals('Testamentarías', resultado.nombreRol);
            Test.stopTest();
        }
    }

    @isTest
    public static void esRolSACH(){
        User usuario2 = new User();
        usuario2.FirstName = 'Usuario';
        usuario2.LastName = '1';    
        usuario2.IsActive = true; 	
        usuario2.Alias = 'us';
        usuario2.Email = 'usuario_test@test.com';
        usuario2.EmailEncodingKey = 'ISO-8859-1';
        usuario2.LanguageLocaleKey = 'es';
        usuario2.LocaleSidKey = 'es_ES';
        usuario2.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'SACH'].Id;
        usuario2.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SACH_Usuario_CaixaBank'].Id;
        usuario2.TimeZoneSidKey = 'Europe/Madrid';
        usuario2.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com'; 	
        insert usuario2;

        System.runAs(usuario2){
            Test.startTest();
            CC_Case_Crear_Controller.RetornoComprobarRol resultado = CC_Case_Crear_Controller.comprobarRol();
            System.assertEquals('SACH', resultado.nombreRol);
            Test.stopTest();
        }
    }

    @isTest
    private static void obtenerTipoContacto() {
        CC_Case_Crear_Controller.obtenerTipoContacto('');
    }

    @isTest
    static void asociarContactoCCEmpleado(){
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Subject = 'Caso de prueba';
        caso1.Status = 'Activo';
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c = 'Soporte Empleados CompraEstrella';
        caso1.CC_Canal_Resolucion__c = 'Soporte Empleados CompraEstrella';
        insert caso1;

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        insert contacto;       

        Test.startTest();
        CC_Case_Crear_Controller.asociarContactoCCEmpleado(caso1.Id, contacto.Id);
        Test.stopTest();

        Case contRecu = [SELECT ContactId FROM case WHERE Id = :caso1.Id];
        System.AssertEquals(contacto.Id, contRecu.ContactId );
    }

    @isTest
    static void buscarRecordTypeId(){
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        insert contacto;
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Test.startTest();
        Id resultado =  CC_Case_Crear_Controller.buscarRecordTypeId(contacto.Id);
        Test.stopTest();
        
        System.assertEquals(recordTypeId, resultado);
    }

    @isTest
    static void clienteCCObligatorioCanalOperativo(){
        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Subject = 'Caso de prueba';
        caso1.Status = 'Activo';
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c = 'Soporte Clientes CompraEstrella';
        caso1.CC_Canal_Resolucion__c = 'Soporte Clientes CompraEstrella';
        caso1.CC_Canal_Operativo__c = 'Cajero';
        insert caso1;

        Test.startTest();
        CC_Case_Crear_Controller.obtenerVariablesCOPS(recordTypeCaso, caso1.Id);
        Test.stopTest();
        
        Case casoRes = [SELECT RecordTypeId FROM Case WHERE Id = :caso1.Id];

        System.assertEquals(recordTypeCaso, casoRes.RecordTypeId);
    }

    @isTest
    public static void testGrupoTrabajo() {
        Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_GrupoTrabajo').getRecordTypeId();
	
		CC_Grupo_Colaborador__c	grupo = new CC_Grupo_Colaborador__c();
        grupo.RecordTypeId = recordTypeGrupoColaborador;
        grupo.name='2N UAFE FAG INDRA ZONA 1';
        grupo.OS_Negocio__c = 'COPS';
        grupo.CC_Canal_de_procedencia__c = 'Buzón UAFE Express';
        insert grupo;

        CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c();
        colaborador.CC_Grupo_Colaborador__c = grupo.Id;
        colaborador.CC_Usuario__c = UserInfo.getUserId();
        insert colaborador;

        System.runAs(new User(Id = UserInfo.getUserId())){
            Test.startTest();
                List<String> resultado = CC_Case_Crear_Controller.obtenerGruposTrabajo('Buzón UAFE Express');
            Test.stopTest();
        
        
            // System.assert(resultado.isEmpty());
            System.assert(resultado.size() == 1);
            System.assertEquals('2N UAFE FAG INDRA ZONA 1',resultado[0]);
        }
    }

    @isTest
    public static void isPerfilSegmentosTest() {

        Boolean isSegmentos = false;
        Boolean resultado;
        Id profileId = userinfo.getProfileId();
        String profileName = [SELECT Id, Name FROM Profile WHERE Id =:profileId LIMIT 1].Name;
        if(profileName == 'SEG_Usuario_CaixaBank'){
            isSegmentos = true;
        }

        System.runAs(new User(Id = UserInfo.getUserId())){
            Test.startTest();
                resultado = CC_Case_Crear_Controller.isPerfilSegmentos();
            Test.stopTest();
        }
        
        System.assertEquals(isSegmentos, resultado, 'La comprobación no coincide');
    }

    @isTest
    public static void obtencionNIFTest() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        Account acc = new Account();
        acc.Name = 'centro';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        acc.CC_Numero_Documento__c = 'K9809899R';
        insert acc;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
                List<String> nif = CC_Case_Crear_Controller.obtencionNIF('45137788D');
            	List<String> nif2 = CC_Case_Crear_Controller.obtencionNIF('K9809899R');
            Test.stopTest();
            
            List<Account> cuenta = [SELECT id, CC_Numero_Documento__c, name FROM Account WHERE CC_Numero_Documento__c = 'K9809899R' LIMIT 1];
                   	
            System.assertEquals('error' , nif[0],'Se ha encontrado el nif');
        }
    }
}