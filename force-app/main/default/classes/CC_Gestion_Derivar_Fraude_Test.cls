@IsTest
public with sharing class CC_Gestion_Derivar_Fraude_Test {
    @testSetup
    static void setup() {
        
        User admin = CC_TestDataFactory.insertUserAdmin();
        User operador = CC_TestDataFactory.insertUserOperadorCliente('000001');
        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');


        System.runAs(admin){

            // //CC_TestDataFactory.insertarMCCsDerivar(operador);
            // List<CC_Settings__c> settingsList = new List<CC_Settings__c>{
            //     new CC_Settings__c(Name = 'CC_Agrupador_CI_Asignacion_Casos', CC_Activa__c = true),
            //     new CC_Settings__c(Name = 'CC_Agrupador_CIC_Asignacion_Casos', CC_Activa__c = true),
            //     new CC_Settings__c(Name = 'CC_Agrupador_CIM_Asignacion_Casos', CC_Activa__c = true)
            // };
            // insert settingsList;

            // CC_Lista_Valores__c listaAvisos = new CC_Lista_Valores__c(
            //     Name = 'Avisos sobre agrupadores',
            //     recordTypeId = lov,
            //     CC_Activa__c = true
            // );
            // insert listaAvisos;
        
            // CC_Lista_Valores__c valorAviso = new CC_Lista_Valores__c(
            //     Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', 'CC_Comunicacion_Informativa') + ' - Umbral primer aviso',
            //     CC_Lista__c = listaAvisos.Id,
            //     recordTypeId = lovValue,
            //     CC_Valor__c = '1',
            //     CC_Activa__c = true
            // );
            // insert valorAviso;

            // // Crear una tarea de prueba
            // Task testTask = new Task(
            //     Subject = 'Creación caso a Fraude',
            //     Status = 'Not Started',
            //     Priority = 'Normal',
            //     Type = 'Fraude'
            //     //WhatId = testCase.Id
            // );
            // insert testTask;

            Map<String, Object> cuentaCaixa = new Map<String, Object>
            {
                'LastName' => 'Cliente prueba',
                'CC_NumPerso__c' => '0000015',
                'CC_Numero_Documento__c' => '45729937B',
                'AV_Cliente__c' => true
            };
            // Account cuentaCaixa = new Account(
            //     LastName = 'Cliente prueba',
            //     CC_NumPerso__c = '0000015',
            //     CC_Numero_Documento__c = '45729937B',
            //     AV_Cliente__c = true
            // );
            // insert cuentaCaixa;

            Account cuenta = CC_TestDataFactory.insertAccount(cuentaCaixa);
            System.debug(JSON.serializePretty(cuenta));

            // Map<String, Object> contactoCaixa = new Map<String, Object>
            // {
            //     'FirstName' => 'ContactoPrueba',
            //     'LastName' => ''
            // };
            // Contact contacto = CC_TestDataFactory.insertContacts(contactoCaixa);
            // System.debug(JSON.serializePretty(contacto));

            // Map<String, String> MCC = new Map<String, String>
            // {
            //     'Name' => 'Test',
            //     'CC_Tipo_Cliente__c' => 'Cliente',
            //     'CC_Codigo_Externo__c' => '1',
            //     'CC_Ambito_Tareas_Caixa__c' => 'Caso a Fraude',
            //     'CC_Ambito_Tareas_Imagin__c' => 'Caso a Fraude',
            //     'CC_AmbitoTareas__c' => '',
            //     'CC_Canal_Operativo__c' => 'Cajero'
            // };
            // List<CC_MCC__c> MCCS = CC_TestDataFactory.insertCustomMCC(MCC, operador);
            // System.debug(JSON.serializePretty(MCCS));

            // Map<String, Object> params = new Map<String, Object>();
            // // params.put('tematicaId', CC_TestDataFactory.getMCC('CSTE-000001').Id);
            // // params.put('productoId', CC_TestDataFactory.getMCC('CSPR-000001').Id);
            // // params.put('motivoId', CC_TestDataFactory.getMCC('CSMO-000001').Id);
            // params.put('accountId', cuenta.Id);
            // params.put('description', 'Descripción de prueba');
            // params.put('motivoText', 'Texto del motivo de prueba');
            // Case testCase = CC_TestDataFactory.insertCase(params);

            // Case casoPrueba = new Case(
            //     Description = 'description',
            //     Subject = 'description',
            //     Origin = 'Email',
            //     Status = 'Activo',
            //     accountId = cuenta.Id,
            //     CC_Idioma__c = 'es',
            //     CC_Canal_Respuesta__c = 'Email',
            //     CC_Grupo_3N__c = 'Grupo 3N',
            //     CC_Tipo_Contacto__c = 'Consulta',
            //     CC_Canal_Procedencia__c = 'Formulario web',
            //     CC_Detalles_Consulta__c = 'Caso de Contact Center',
            //     CC_OTP_Nivel__c = 'Nivel 2',
            //     CC_Status_Autorizacion__c = 'APPROVED',
            //     CC_OTP_Valido__c = true,
            //     RecordTypeId = recordTypeCaso
            // );
            // insert casoPrueba;
            //System.debug(JSON.serializePretty(testCase));

        }
    }
    
    @isTest
    static void testCrearCasoFraudeNoExistingFraudTask() {
        Map<String, Object> cuentaCaixa = new Map<String, Object>
        {
            'LastName' => 'Cliente prueba',
            'CC_NumPerso__c' => '0000015',
            'CC_Numero_Documento__c' => '45729937B',
            'AV_Cliente__c' => true
        };
        Account cuenta = CC_TestDataFactory.insertAccount(cuentaCaixa);
        Map<String, Object> params = new Map<String, Object>();
        // params.put('tematicaId', CC_TestDataFactory.getMCC('CSTE-000001').Id);
        // params.put('productoId', CC_TestDataFactory.getMCC('CSPR-000001').Id);
        // params.put('motivoId', CC_TestDataFactory.getMCC('CSMO-000001').Id);
        params.put('accountId', cuenta.Id);
        params.put('description', 'Descripción de prueba');
        params.put('motivoText', 'Texto del motivo de prueba');
        Case caso = CC_TestDataFactory.insertCase(params);

        Id rtCasoCC = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        Case testCase = [SELECT Id, OwnerId, ContactId, Subject, Description, CC_Idioma__c, CC_Tipo_Contacto__c, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c, AccountId, Comments, CC_ContactoRelacionado__c, CC_Oficina__c, CC_MCC_Tematica__r.Name, CC_MCC_Motivo__c
                        FROM Case WHERE RecordTypeId = :rtCasoCC LIMIT 1];
                        System.debug('testCase: ' + JSON.serializePretty(testCase));
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Test.startTest();
            Map<String, Object> result = CC_Gestion_Derivar_Fraude.crearCasoFraude(testCase.Id);
            Test.stopTest();
            System.assertEquals(false, result.get('casoYaDerivado'), 'Error en el metodo de crearCasoFraude');
        }
    }
    
    @isTest
    static void testCrearCasoFraudeExistingFraudTask() {
        Map<String, Object> cuentaCaixa = new Map<String, Object>
        {
            'LastName' => 'Cliente prueba',
            'CC_NumPerso__c' => '0000015',
            'CC_Numero_Documento__c' => '45729937B',
            'AV_Cliente__c' => true
        };
        Account cuenta = CC_TestDataFactory.insertAccount(cuentaCaixa);
        Map<String, Object> params = new Map<String, Object>();
        // params.put('tematicaId', CC_TestDataFactory.getMCC('CSTE-000001').Id);
        // params.put('productoId', CC_TestDataFactory.getMCC('CSPR-000001').Id);
        // params.put('motivoId', CC_TestDataFactory.getMCC('CSMO-000001').Id);
        params.put('accountId', cuenta.Id);
        params.put('description', 'Descripción de prueba');
        params.put('motivoText', 'Texto del motivo de prueba');
        Case caso = CC_TestDataFactory.insertCase(params);

        Task testTask = new Task(
            Subject = 'Creación caso a Fraude',
            Status = 'Not Started',
            Priority = 'Normal',
            Type = 'Fraude',
            WhatId = caso.Id
        );
        insert testTask;

        Case testCase = [SELECT Id FROM Case LIMIT 1];

        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Test.startTest();
            Map<String, Object> result = CC_Gestion_Derivar_Fraude.crearCasoFraude(testCase.Id);
            Test.stopTest();
            System.assertEquals(true, result.get('casoYaDerivado'), 'Error en el metodo de crear caso Fraude');
        }
    }

    @IsTest
    static void testDevolverCasoCCValidCaseId() {
        Map<String, Object> cuentaCaixa = new Map<String, Object>
        {
            'LastName' => 'Cliente prueba',
            'CC_NumPerso__c' => '0000015',
            'CC_Numero_Documento__c' => '45729937B',
            'AV_Cliente__c' => true
        };
        Account cuenta = CC_TestDataFactory.insertAccount(cuentaCaixa);
        Map<String, Object> params = new Map<String, Object>();
        // params.put('tematicaId', CC_TestDataFactory.getMCC('CSTE-000001').Id);
        // params.put('productoId', CC_TestDataFactory.getMCC('CSPR-000001').Id);
        // params.put('motivoId', CC_TestDataFactory.getMCC('CSMO-000001').Id);
        params.put('accountId', cuenta.Id);
        params.put('description', 'Descripción de prueba');
        params.put('motivoText', 'Texto del motivo de prueba');
        Case caso = CC_TestDataFactory.insertCase(params);

        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Map<String, Object> respuesta = new Map<String, Object>();
        respuesta.put('casoId', testCase.Id);
        respuesta.put('motivo', 'Test Motivo');
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Test.startTest();
            CC_Gestion_Derivar_Fraude.devolverCasoCC(respuesta);
            Test.stopTest();
            System.assert((String)respuesta.get('motivo') != '', 'Error en devolverCasoCC');
        }
    }

    @IsTest
    static void testReabrirCasoFraudeValidEvents() {
        Map<String, Object> cuentaCaixa = new Map<String, Object>
        {
            'LastName' => 'Cliente prueba',
            'CC_NumPerso__c' => '0000015',
            'CC_Numero_Documento__c' => '45729937B',
            'AV_Cliente__c' => true
        };
        Account cuenta = CC_TestDataFactory.insertAccount(cuentaCaixa);
        Map<String, Object> params = new Map<String, Object>();
        // params.put('tematicaId', CC_TestDataFactory.getMCC('CSTE-000001').Id);
        // params.put('productoId', CC_TestDataFactory.getMCC('CSPR-000001').Id);
        // params.put('motivoId', CC_TestDataFactory.getMCC('CSMO-000001').Id);
        params.put('accountId', cuenta.Id);
        params.put('description', 'Descripción de prueba');
        params.put('motivoText', 'Texto del motivo de prueba');
        Case caso = CC_TestDataFactory.insertCase(params);

        Task testTask = new Task(
            Subject = 'Creación caso a Fraude',
            Status = 'Not Started',
            Priority = 'Normal',
            Type = 'Fraude',
            WhatId = caso.Id
        );
        insert testTask;

        Case testCase = [SELECT Id FROM Case LIMIT 1];
        CC_DevolverCaso__e reabrirEvent = new CC_DevolverCaso__e(
            CC_CasoId__c = testCase.Id,
            CC_resolucion3N__c = 'Test Motivo'
        );
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            List<CC_DevolverCaso__e> reabrirEvents = new List<CC_DevolverCaso__e>{reabrirEvent};
            Test.startTest();
            CC_Gestion_Derivar_Fraude.reabrirCasoFraude(reabrirEvents);
            Test.stopTest();
            System.assert(testTask.Id != null, 'Error en reabrirCasoFraude');
        }
    }
}