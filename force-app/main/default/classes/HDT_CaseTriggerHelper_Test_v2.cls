@isTest
public with sharing class HDT_CaseTriggerHelper_Test_v2 {
     @testSetup
    static void setupTestData() {

        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};

        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = owa[0].Address;
        params.HDT_Configuracion_2__c = owa[0].Address;
        insert params;


        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'Cuenta Prueba';
        //cuenta.CC_OficinaGestoraId__c = oficinaGestora.Id;
        cuenta.CC_Numero_Oficina__c = '00001';
       insert cuenta;

       Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Test';
        contacto.LastName = 'Contacto Prueba';
        contacto.CC_NumPerso__c = '25345569';
        contacto.CC_Idioma__c = 'ca';
        contacto.Email = 'correo@gmail.com';
        contacto.Phone = '973242323';
        insert contacto;


        // 📌 CREAR CASO SIMULADO
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'User', Email = 'test@example.com');
        insert testContact;

        insert new Case(
            Status = 'Abierto',
            CC_Notif_Cont_Inter__c = true,
            ContactId = testContact.Id,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId()
        );

        /*
        // Crear un caso asociado a la cuenta
        Case caso = new Case(Status = 'Abierto', AccountId = cuenta.Id, RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId());
        insert caso;*/



         // Crear un activo asociado a la cuenta
         Asset asset = new Asset(Name = 'Test Asset', AccountId = cuenta.Id);
         insert asset;


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

         // 🔹 Creación del Caso en un solo paso
         Case caso = new Case(
            AccountId = cuenta.Id,
            ContactId = testContact.Id,
            Status = 'Activo',
            CC_Idioma__c = 'es',
            Subject = 'PruebaCierreHDT2n',
            Origin = 'Phone',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Servicios Centrales',
            CC_Canal_Resolucion__c = 'Servicios Centrales',
            CC_MCC_Tematica__c = mcc.Id,
            CC_MCC_ProdServ__c = mcc1.Id,
            CC_MCC_Motivo__c = mcc2.Id,
            CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
            CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId()
        );
        insert caso;

        // 🔹 Creación del Caso en un solo paso
        Case caso2 = new Case(
            Status = 'Activo',
            CC_Idioma__c = 'es',
            Subject = 'PruebaCierreHDT2n',
            Origin = 'Phone',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Servicios Centrales',
            CC_Canal_Resolucion__c = 'Servicios Centrales',
            CC_MCC_Tematica__c = mcc.Id,
            CC_MCC_ProdServ__c = mcc1.Id,
            CC_MCC_Motivo__c = mcc2.Id,
            CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
            CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId()
        );
        insert caso2;



        CC_Lista_Valores__c lovAvisosSobreAgrupadores2 = new CC_Lista_Valores__c();
        lovAvisosSobreAgrupadores2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovAvisosSobreAgrupadores2.CC_Activa__c = true;
        lovAvisosSobreAgrupadores2.Name = 'HDT - Aviso Comunicaciones Informativas';
        insert lovAvisosSobreAgrupadores2;

        CC_Lista_Valores__c valorUmbralSiguientesAvisosx = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisosx.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisosx.CC_Activa__c = true;
        valorUmbralSiguientesAvisosx.CC_Lista__c = lovAvisosSobreAgrupadores2.Id;
        valorUmbralSiguientesAvisosx.Name = 'Comunicación Informativa de Caso - Umbral de tiempo';
        valorUmbralSiguientesAvisosx.CC_Valor__c = '15';

        CC_Lista_Valores__c valorUmbralSiguientesAvisosx1 = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisosx1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisosx1.CC_Activa__c = true;
        valorUmbralSiguientesAvisosx1.CC_Lista__c = lovAvisosSobreAgrupadores2.Id;
        valorUmbralSiguientesAvisosx1.Name = 'Comunicación Informativa de Caso - Umbral Envio de Emails';
        valorUmbralSiguientesAvisosx1.CC_Valor__c = '15';

        CC_Lista_Valores__c valorUmbralSiguientesAvisosx2 = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisosx2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisosx2.CC_Activa__c = true;
        valorUmbralSiguientesAvisosx2.CC_Lista__c = lovAvisosSobreAgrupadores2.Id;
        valorUmbralSiguientesAvisosx2.Name = 'Comunicación Informativa de Caso - Umbral primer aviso';
        valorUmbralSiguientesAvisosx2.CC_Valor__c = '1';

        List<CC_Lista_Valores__c> valorUmbralInsertx = new List<CC_Lista_Valores__c>();
        valorUmbralInsertx.add(valorUmbralSiguientesAvisosx);
        valorUmbralInsertx.add(valorUmbralSiguientesAvisosx1);
        valorUmbralInsertx.add(valorUmbralSiguientesAvisosx2);
        
        insert valorUmbralInsertx;

        CC_Lista_Valores__c lovAvisosSobreAgrupadores3 = new CC_Lista_Valores__c();
        lovAvisosSobreAgrupadores3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovAvisosSobreAgrupadores3.CC_Activa__c = true;
        lovAvisosSobreAgrupadores3.Name = ' HDT - Envío de Encuesta 2N - Canales de resolución';
        insert lovAvisosSobreAgrupadores3;

        // Crear EmailMessages de prueba
        List<EmailMessage> emailMessages = new List<EmailMessage>();

        for (Integer i = 0; i < 3; i++) {
            EmailMessage email = new EmailMessage();
            email.SAC_EnvioRedaccion__c = 'TestType';
            email.Subject = 'Correo de prueba ' + i;
            email.TextBody = 'Cuerpo del mensaje ' + i;
            emailMessages.add(email);
        }

        insert emailMessages;

        // Simular fechas de creación (importante para la consulta con CreatedDate)
        DateTime testTime = System.now().addMinutes(-10); // Hace 10 minutos

        for (EmailMessage email : emailMessages) {
            Test.setCreatedDate(email.Id, testTime);
        }
    }


    @isTest
    private static void cierreCasoHDT2N() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            
            // 🔹 Inserta valores en HDT_Parametros__c en un solo paso
            List<HDT_Parametros__c> valores1 = new List<HDT_Parametros__c>{
                new HDT_Parametros__c(Name = 'HDT_Envio_Encuesta_2N', HDT_Configuracion_1__c = '659497', HDT_Configuracion_2__c = 'Encuesta Test'),
                new HDT_Parametros__c(Name = 'HDT_Envio_Encuesta_2N_EdG', HDT_Configuracion_1__c = '261467', HDT_Configuracion_2__c = 'Encuesta Test')
            };
            insert valores1;
            
            // 🔹 Obtener todos los IDs en una sola consulta
            Map<String, Id> idsMap = new Map<String, Id>();
            for (CC_Lista_Valores__c lv : [
                SELECT Id, Name FROM CC_Lista_Valores__c WHERE Name IN ('HDT - Envío de Encuesta 2N - Canales de resolución', 'Servicios Centrales', 'EDG-MICROBANK')
            ]) {
                idsMap.put(lv.Name, lv.Id);
            }
            
            // 🔹 Insertar valores de CC_Lista_Valores__c
            List<CC_Lista_Valores__c> valorUmbralIns1 = new List<CC_Lista_Valores__c>{
                new CC_Lista_Valores__c(Name = 'Servicios Centrales', CC_Activa__c = true, CC_Valor__c = 'No EDG', CC_Lista__c = idsMap.get('HDT - Envío de Encuesta 2N - Canales de resolución')),
                new CC_Lista_Valores__c(Name = 'EDG-MICROBANK', CC_Activa__c = true, CC_Valor__c = 'EDG', CC_Lista__c = idsMap.get('HDT - Envío de Encuesta 2N - Canales de resolución'))
            };
            insert valorUmbralIns1;
    
            // 🔹 Obtener los IDs necesarios en consultas separadas y guardarlos en un solo mapa
            Map<String, Id> referencias = new Map<String, Id>();
    
            Account cliente = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' LIMIT 1];
            referencias.put('Cuenta Prueba', cliente.Id);
            
            Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' LIMIT 1];
            referencias.put('Contacto Prueba', contacto.Id);
    
            for (CC_MCC__c mcc : [SELECT Id, Name FROM CC_MCC__c WHERE Name IN ('App\'s', 'APP CaixaBank', 'Valoración positiva')]) {
                referencias.put(mcc.Name, mcc.Id);
            }
    
            // 🔹 Creación del Caso en un solo paso
            Case caso = new Case(
                AccountId = referencias.get('Cuenta Prueba'),
                ContactId = referencias.get('Contacto Prueba'),
                Status = 'Activo',
                CC_Idioma__c = 'es',
                Subject = 'PruebaCierreHDT2n',
                Origin = 'Phone',
                CC_Tipo_Contacto__c = 'Consulta',
                CC_Canal_Procedencia__c = 'Servicios Centrales',
                CC_Canal_Resolucion__c = 'Servicios Centrales',
                CC_MCC_Tematica__c = referencias.get('App\'s'),
                CC_MCC_ProdServ__c = referencias.get('APP CaixaBank'),
                CC_MCC_Motivo__c = referencias.get('Valoración positiva'),
                CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
                CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId()
            );
            insert caso;
    
            // 🔹 Actualización del caso
            caso.CC_Notif_Cont_Inter__c = true;
            caso.Status = 'Cerrado';
    
            Test.startTest();
                update caso;
                Integer numEmails = Limits.getEmailInvocations();
            Test.stopTest();
    
            System.assertEquals(1, numEmails, 'Debería haber enviado un email');
        }
    }

    @isTest
    static void testAsociarAssetACuentaNuevoAsset() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        // Obtener los registros creados en setup
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Asset asset = [SELECT Id FROM Asset WHERE AccountId = :acc.Id LIMIT 1];
        Case caso = [SELECT Id, AccountId, AssetId,Status FROM Case WHERE AccountId = :acc.Id LIMIT 1];

        // Simular actualización de AccountId en el caso
        Map<Id, Case> oldMap = new Map<Id, Case>{caso.Id => new Case(Id = caso.Id, AccountId = null)};

        caso.AccountId = acc.Id;
        
        Test.startTest();
            HDT_CaseTriggerHelper.asociarAssetaCuenta(new List<Case>{caso}, oldMap);
        Test.stopTest();

        // Verificar que el caso ahora tiene un Asset asociado
        Case updatedCaso = [SELECT AssetId FROM Case WHERE Id = :caso.Id];
        System.assertNotEquals(null, updatedCaso.AssetId, 'El AssetId debería haberse asignado');
        }
    }


    @isTest
    static void testEliminarAssetCuandoSeEliminaAccountId() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        // Obtener el caso con cuenta
        Case caso = [SELECT Id, AccountId, AssetId,Status FROM Case WHERE AccountId != null LIMIT 1];

        // Simular que el caso tenía una cuenta pero ahora se elimina
        Map<Id, Case> oldMap = new Map<Id, Case>{caso.Id => new Case(Id = caso.Id, AccountId = caso.AccountId)};
        caso.AccountId = null;

        Test.startTest();
            HDT_CaseTriggerHelper.asociarAssetaCuenta(new List<Case>{caso}, oldMap);
        Test.stopTest();

        // Verificar que el AssetId fue eliminado
        Case updatedCaso = [SELECT AssetId FROM Case WHERE Id = :caso.Id];
        System.assertEquals(null, updatedCaso.AssetId, 'El AssetId debería haber sido eliminado');
        }
    }

    @isTest
    static void testSinCambiosNoActualizaNada() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        // Obtener el caso existente
        Case caso = [SELECT Id, AccountId,Status,AssetId FROM Case WHERE AccountId != null LIMIT 1];

        // Simular que el AccountId no cambia
        Map<Id, Case> oldMap = new Map<Id, Case>{caso.Id => new Case(Id = caso.Id, AccountId = caso.AccountId)};

        Test.startTest();
            HDT_CaseTriggerHelper.asociarAssetaCuenta(new List<Case>{caso}, oldMap);
        Test.stopTest();

        // Verificar que el AssetId sigue igual
        Case updatedCaso = [SELECT AccountId,AssetId,Status FROM Case WHERE Id = :caso.Id];
        System.assertEquals(caso.AssetId, updatedCaso.AssetId, 'No debería haberse modificado el AssetId');
        }
    }



}