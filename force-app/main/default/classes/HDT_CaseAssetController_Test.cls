@IsTest
public with sharing class HDT_CaseAssetController_Test {

    @testSetup static void setup()
    {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'HDT_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        UserRole rolCC = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'HDT'];
        PermissionSet psOperador = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_Operador'];
        PermissionSet psSupervisor = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_Analista_2N'];
        List<Account> lstAccounts = new List<Account>();
        List<Contact> lstContacts = new List<Contact>();

        User usuarioAdmin = new User();        
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = rolCC.Id;
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        insert usuarioAdmin;

        System.runAs(usuarioAdmin)
        {
            // Inicialización de datos.        
            Id recorTypeLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId(); 
            CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
            lista.Name = 'HDT_Mensajes_Parametrizables_Empleados';
            lista.CC_Activa__c = true;
            lista.RecordTypeId = recorTypeLista;
            insert lista;

            Contact contacto = new Contact();
            contacto.LastName = 'Test';
            contacto.CC_Numero_Documento__c = '36592162J';
            contacto.CC_Sexo__c = 'V';
            insert contacto;

            Id recordTypeOficina = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            Account oficinaGestora = new Account(RecordTypeId = recordTypeOficina, Name = 'Cuenta oficina gestora', CC_Tipo_Centro__c = 'OF',  CC_Email__c = 'test@test.com', CC_Numero_Oficina__c = '00001');
            insert oficinaGestora;

            Account cuenta = new Account();
            cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
            cuenta.Name = 'Cuenta Prueba';
            cuenta.CC_OficinaGestoraId__c = oficinaGestora.Id;
            cuenta.CC_Numero_Oficina__c = '00001';
            insert cuenta;
        }
    }


    @IsTest
    static void testIsAssetActiveActivo() {

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Account cuenta3 = [SELECT Id, PersonContactId FROM Account WHERE Name = 'Cuenta Prueba' LIMIT 1];

            Asset casoAsset = new Asset();
            casoAsset.Name = 'Pablo';
            casoAsset.AccountId = cuenta3.Id;
            insert casoAsset;

            Case caso = new Case();
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCliente;
            caso.AssetId = casoAsset.Id;
            caso.CC_Oficina__c = cuenta3.Id;
            insert caso;

            Boolean resultado = false;
            // Ejecutar el método isAssetActive y verificar que el resultado es false (el activo no está inactivo)
            Test.startTest(); 
            resultado = HDT_CaseAssetController.isAssetActive(caso.Id);
            Test.stopTest();
            System.assertEquals(false, resultado, 'El activo debería estar activo (no inactivo)');
        }
    }

    @IsTest
    static void testIsAssetActiveInActivo() {

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Account cuenta3 = [SELECT Id, PersonContactId FROM Account WHERE Name = 'Cuenta Prueba' LIMIT 1];

        Asset casoAsset = new Asset();
        casoAsset.Name = 'Pablo';
        casoAsset.CC_Inactivo__c = True;
        casoAsset.AccountId = cuenta3.Id;

        insert casoAsset;

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCliente;
        caso.AssetId = casoAsset.Id;
        caso.CC_Oficina__c = cuenta3.Id;
        insert caso;

        Boolean resultado = false;
            // Ejecutar el método isAssetActive y verificar que el resultado es false (el activo no está inactivo)
            Test.startTest();
            
                resultado = HDT_CaseAssetController.isAssetActive(caso.Id);
            Test.stopTest();

            System.assertEquals(true, resultado, 'El activo debería estar activo (no inactivo)');
        }
    }

    @IsTest
    static void testIsAssetActiveActivoSec() {

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Account cuenta3 = [SELECT Id, PersonContactId FROM Account WHERE Name = 'Cuenta Prueba' LIMIT 1];

            Asset casoAsset = new Asset();
            casoAsset.Name = 'Luis';
            casoAsset.AccountId = cuenta3.Id;
            insert casoAsset;

            Case caso = new Case();
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCliente;
            caso.HDT_Activo_Secundario__c = casoAsset.Id;
            caso.CC_Oficina__c = cuenta3.Id;
            insert caso;

            Boolean resultado = false;
            // Ejecutar el método isAssetActive y verificar que el resultado es false (el activo no está inactivo)
            Test.startTest(); 
                resultado = HDT_CaseAssetController.isSegundoAssetActive(caso.Id);
            Test.stopTest();
            System.assertEquals(false, resultado, 'El activo debería estar activo (no inactivo)');
        }
    }

    @IsTest
    static void testIsAssetActiveActivoSecIn() {

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            Account cuenta3 = [SELECT Id, PersonContactId FROM Account WHERE Name = 'Cuenta Prueba' LIMIT 1];

            Asset casoAsset = new Asset();
            casoAsset.Name = 'Luis';
            casoAsset.CC_Inactivo__c = True;
            casoAsset.AccountId = cuenta3.Id;
            insert casoAsset;

            Case caso = new Case();
            caso.Status = 'Activo';
            caso.RecordTypeId = rtCliente;
            caso.HDT_Activo_Secundario__c = casoAsset.Id;
            caso.CC_Oficina__c = cuenta3.Id;
            insert caso;

            Boolean resultado = false;
            // Ejecutar el método isAssetActive y verificar que el resultado es false (el activo no está inactivo)
            Test.startTest(); 
                resultado = HDT_CaseAssetController.isSegundoAssetActive(caso.Id);
            Test.stopTest();
            System.assertEquals(true, resultado, 'El activo debería estar activo (no inactivo)');
        }
    }

    @IsTest
    static void testMensajeValidacionPreguntasValidacionNoVacia() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {


        Id listaPadre = [SELECT id FROM CC_Lista_Valores__c WHERE Name = 'HDT_Mensajes_Parametrizables_Empleados' limit 1].Id;
        // Crear un registro de CC_Lista_Valores__c para simular un resultado válido
        CC_Lista_Valores__c listaValor = new CC_Lista_Valores__c(
            Name = 'Test Validación',
            CC_Valor__c = 'Valor1',
            CC_Valor2__c = 'Validacion1',
            CC_Lista__c = listaPadre

        );
        insert listaValor;

        // Ejecutar el método con una validación no vacía que coincida
        Test.startTest();
        CC_Lista_Valores__c resultado = HDT_CaseAssetController.mensajeValidacionPreguntas('Validacion1');
        Test.stopTest();

        // Verificar que el resultado es el esperado
        System.assertNotEquals(null, resultado, 'Debería devolver un resultado');
        System.assertEquals('Valor1', resultado.CC_Valor__c, 'El valor debería ser Valor1');
    
        }
    }


}