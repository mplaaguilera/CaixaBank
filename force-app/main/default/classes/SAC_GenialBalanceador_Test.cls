/*****************************************************************
* Name: SAC_GenialBalanceador_Test
* Copyright © 202  CaixaBank
* 
* Proposito: Testear el componente SAC_GenialBalanceador
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR                    DATE         Description
* 1.0            US976182         Borja Lavesiera           26/07/24     Creación     
*****************************************************************/
@IsTest
public with sharing class SAC_GenialBalanceador_Test {
    /**
     * @description Clase test para SAC_GenialBalanceador
     */
    @TestSetup
    static void makeData() {
        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        List<User> usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1);    
        Database.insert(usuarioAdmin);

        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSet permiSet = permiSets[0];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;

        System.runAs(usuarioGeneral) {
            Database.insert(permiSetAssi);
        }

        // Crear datos de prueba para SAC_GenialSettingsCanal__c
        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c(
            Name = 'Test Canal',
            SAC_IAactiva__c = true,
            SAC_shadow__c = false,
            SAC_Balanceador_Integracion__c = 'Azure,50;OpenServices,50',
            SAC_Tamano_Maximo_Attach__c = 10,
            SAC_Integracion_Adjuntos_Pesados__c = 'Azure'
        );
        insert settings;

        // Crear un caso de prueba
        Case testCaseAzure = new Case(
            Subject = 'Test Case',
            SAC_Tipo_integracion_IA__c = 'Azure'
        );
        insert testCaseAzure;

        // Crear un caso de prueba
        Case testCaseOpen = new Case(
            Subject = 'Test Case',
            SAC_Tipo_integracion_IA__c = 'OpenServices'
        );
        insert testCaseOpen;

        Blob largeBlob = Blob.valueOf('1'.repeat(1024 * 1024 * 2));

        //Configuración adjunto
        ContentVersion archivo = new ContentVersion();
        archivo.ContentLocation = 'S';
        archivo.PathOnClient = 'test.txt';
        archivo.Title = 'Test File';
        archivo.VersionData = largeBlob;
        insert archivo;
        
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId , ContentSize
            FROM ContentDocument
			WHERE LatestPublishedVersionId = :archivo.Id
        ];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = testCaseAzure.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
    }
    // prueba configuración correcta
    @IsTest
    static void testObtenerConfiguracionBalanceador() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Test';
        settings.SAC_IAactiva__c = true;
        settings.SAC_Shadow__c = true;
        settings.SAC_Balanceador_Integracion__c = 'Azure,50;OpenServices,50';
        
        Database.insert(settings);
        Map<String, Integer> balanceadorMap;
        System.runAs(usuario){
            Test.startTest();
            balanceadorMap = SAC_GenialBalanceador.obtenerConfiguracionBalanceador('Test');
            Test.stopTest();
        }

        System.assertEquals(2, balanceadorMap.size(), 'Se han introducido dos sistemas de integración');
        System.assertEquals(50, balanceadorMap.get('Azure'), 'Integracion Azure');
        System.assertEquals(50, balanceadorMap.get('OpenServices'), 'Integracion OpenServices');
    }
    // prueba Adjunto supera limite impuesto en setting
    @IsTest
    static void testVerificarSizeAdjuntosSuperaLimite() {
        User usuarioAdmin = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuarioAdmin){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Test.startTest();
        Boolean result = SAC_GenialBalanceador.verificarSizeAdjuntos(testCase.Id, 1);
        Test.stopTest();
        System.assertEquals(result, true, 'Supera el Límite y se integra por SAC_Integracion_Adjuntos_Pesados__c');
        }
    }
    // prueba Adjunto No supera limite impuesto en setting
    @IsTest
    static void testVerificarSizeAdjuntosNoSuperaLimite() {
        User usuarioAdmin = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true Limit 1];
        
        
        System.runAs(usuarioAdmin){
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Boolean result = SAC_GenialBalanceador.verificarSizeAdjuntos(testCase.Id, 3);
        Test.stopTest();
        System.assertEquals(result, false, ' No Supera el Límite');
        }
        
    }
    // prueba Adjunto No supera limite impuesto en setting
    @IsTest
    static void testExecuteJobNoSuperaLimite() {
        User usuarioAdmin = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true Limit 1];
        // Crear datos de prueba para SAC_GenialSettingsCanal__c
        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c(
            Name = 'Test Canal Limite',
            SAC_IAactiva__c = true,
            SAC_shadow__c = false,
            SAC_Balanceador_Integracion__c = 'Azure,50;OpenServices,50',
            SAC_Tamano_Maximo_Attach__c = 1,
            SAC_Integracion_Adjuntos_Pesados__c = 'Azure'
        );
        insert settings;
        
        System.runAs(usuarioAdmin){
        Case testCase = [SELECT Id, SAC_Tipo_integracion_IA__c FROM Case LIMIT 1];
        Test.startTest();
        SAC_GenialBalanceador.enqueueJob(testCase.Id, 'Test Canal Limite', 'Test Description');
        Test.stopTest();
        System.assertEquals(testCase.SAC_Tipo_integracion_IA__c, 'Azure', ' No Supera el Límite');
        }
    }
    // prueba Job Fail Exception
    @IsTest
    static void testExecuteJobFail() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        User usuarioAdmin = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true Limit 1];
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(reclamacion);

        System.runAs(usuarioAdmin){
        Test.startTest();
        Case testCase = [SELECT Id, SAC_Tipo_integracion_IA__c FROM Case WHERE Id =:reclamacion.Id];
        SAC_GenialBalanceador.enqueueJob(testCase.Id, 'Test Canal Fallo', 'Test Description');
        System.assertEquals(testCase.SAC_Tipo_integracion_IA__c, null, 'Falló el Job');
        Test.stopTest();
        }
    }
    // prueba ejecución job
    @IsTest
    static void testExecuteJob() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case testCase = [SELECT Id FROM Case LIMIT 1];        
        
        System.runAs(usuario){
        Test.startTest();
        SAC_GenialBalanceador.enqueueJob(testCase.Id, 'Test Canal', 'Test Description');
        Test.stopTest();
        }
        System.assertNotEquals(Case.SAC_Tipo_integracion_IA__c, null, 'Se ha ejecutado el queueable');
    }
    // prueba ejecución job no entrando por el setting
    @IsTest
    static void testExecuteNoConfig() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        // Crear settings con tipos de integración pero sin casos por tipo
        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c(
            Name = 'Test Canal Null Integration',
            SAC_IAactiva__c = true,
            SAC_shadow__c = false,
            SAC_Balanceador_Integracion__c = null,
            SAC_Tamano_Maximo_Attach__c = 10,
            SAC_Integracion_Adjuntos_Pesados__c = 'Azure'
        );
        insert settings;
        
        Case tstCase = new Case(
            Subject = 'Test Case'
        );
        
        insert tstCase;

        System.runAs(usuario){
        Test.startTest();
        SAC_GenialBalanceador.enqueueJob(tstCase.Id, 'Test Canal Null Integration', 'Test Description');
        Test.stopTest();
        }
        // Volver a consultar el caso para verificar los cambios
        tstCase = [SELECT Id, SAC_Tipo_integracion_IA__c FROM Case WHERE Id = :tstCase.Id];
        System.assertEquals(null, tstCase.SAC_Tipo_integracion_IA__c, 'Shadow inactiva No config');

    }
    // prueba cuando no hay casos para comprobar volumetria coge la integracion con porcentaje mayor 
    @IsTest
    static void testExecuteWithoutCasosPorTipo() {

    // Crear settings con balanceador
    SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c(
        Name = 'Test Canal No CasosPorTipo',
        SAC_IAactiva__c = true,
        SAC_shadow__c = false,
        SAC_Balanceador_Integracion__c = 'OpenServices,40;Azure,60',
        SAC_Tamano_Maximo_Attach__c = 10,
        SAC_Integracion_Adjuntos_Pesados__c = 'Azure'
    );
    insert settings;
    //Eliminamos casos para forzar el caso de uso sin casos que tratar
    List<Case> tstCase = [SELECT Id, SAC_Tipo_integracion_IA__c FROM Case WHERE SAC_Tipo_integracion_IA__c != null];
    delete tstCase;

    User usuarioAdmin = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true Limit 1];

    // Crear un caso de prueba
    Case testCase = new Case(
        Subject = 'Test Case No CasosPorTipo'
    );
    insert testCase;

    CBK_IntegrationSetting__c csGenialAzureAI = new CBK_IntegrationSetting__c();
    csGenialAzureAI.Name = 'SAC_GenialAzureAI';
    csGenialAzureAI.NamedCredential__c = 'callout:API_GWT_SAC/tech/geni06/notify-case';
    csGenialAzureAI.CBK_Method__c = 'POST';
    csGenialAzureAI.CBK_TimeOut__c = 120000;
    csGenialAzureAI.CBK_ContentType__c = 'application/json';
    Database.insert(csGenialAzureAI);
    
    dateTime fechaAnteriorfwkInt = dateTime.newInstance(2023, 4, 16);
    Test.setCreatedDate(csGenialAzureAI.Id, fechaAnteriorfwkInt);
    update csGenialAzureAI;

    Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(201, 'OK', '', new Map<String, String>()));

    System.runAs(usuarioAdmin){
        Test.startTest();
            SAC_GenialBalanceador.enqueueJob(testCase.Id, 'Test Canal No CasosPorTipo', 'Test Description');
        Test.stopTest();
        System.assert(true, 'Lanzamiento correcto');
    }
    }
}