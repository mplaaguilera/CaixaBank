@IsTest
public with sharing class CC_Gestion_Derivar_Fraude_Test {
    @testSetup
    static void setup() {

        User admin = CC_TestDataFactory.insertUserAdmin();
        User operador = CC_TestDataFactory.insertUserOperadorCliente('000001');
        //CC_TestDataFactory.insertarLOVDerivar();
        System.runAs(operador){
            Case testCase = new Case(
                Subject='Test Case',
                recordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente'),
                Origin = 'Email',
                CC_Canal_Procedencia__c = 'Formulario web',
                CC_Tipo_Contacto__c = 'Consulta',
                OwnerId = operador.Id,
                Status = 'Activo'
            );
            insert testCase;
    
            // Crear una tarea de prueba
            Task testTask = new Task(
                Subject = 'Creación caso a Fraude',
                Status = 'Not Started',
                Priority = 'Normal',
                Type = 'Fraude'
                //WhatId = testCase.Id
            );
            insert testTask;
        }
    }
    
    @isTest
    static void testCrearCasoFraudeNoExistingFraudTask() {
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            Test.startTest();
            Case testCase = [SELECT Id FROM Case LIMIT 1];
            Map<String, Object> result = CC_Gestion_Derivar_Fraude.crearCasoFraude(testCase.Id);
            Test.stopTest();
            System.assertEquals(false, result.get('casoYaDerivado'), 'Error en el metodo de crearCasoFraude');
        }
    }
    
    @isTest
    static void testCrearCasoFraudeExistingFraudTask() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Task testTask = [SELECT Id FROM Task WHERE Type = 'Fraude' LIMIT 1];
        testTask.WhatId = testCase.Id;
        update testTask;
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            Test.startTest();
            Map<String, Object> result = CC_Gestion_Derivar_Fraude.crearCasoFraude(testCase.Id);
            Test.stopTest();
            System.assertEquals(true, result.get('casoYaDerivado'), 'Error en el metodo de crear caso Fraude');
        }
    }

    @IsTest
    static void testDevolverCasoCCValidCaseId() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Map<String, Object> respuesta = new Map<String, Object>();
        respuesta.put('casoId', testCase.Id);
        respuesta.put('motivo', 'Test Motivo');
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            Test.startTest();
            CC_Gestion_Derivar_Fraude.devolverCasoCC(respuesta);
            Test.stopTest();
            System.assert((String)respuesta.get('motivo') != '', 'Error en devolverCasoCC');
        }
    }

    @IsTest
    static void testReabrirCasoFraudeValidEvents() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CC_DevolverCaso__e reabrirEvent = new CC_DevolverCaso__e(
            CC_CasoId__c = testCase.Id,
            CC_resolucion3N__c = 'Test Motivo'
        );
        Task testTask = [SELECT Id FROM Task WHERE Type = 'Fraude' LIMIT 1];
        testTask.WhatId = testCase.Id;
        update testTask;
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()){
            List<CC_DevolverCaso__e> reabrirEvents = new List<CC_DevolverCaso__e>{reabrirEvent};
            Test.startTest();
            CC_Gestion_Derivar_Fraude.reabrirCasoFraude(reabrirEvents);
            Test.stopTest();
            System.assert(testTask.Id != null, 'Error en reabrirCasoFraude');
        }
    }
}