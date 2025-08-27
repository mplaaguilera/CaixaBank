@isTest
public with sharing class CC_CaseTransferTest {

    @testSetup
    static void setupTestData() {
        Test.startTest();
        User admin = CC_Testdatafactory.insertUserAdmin();
        System.runAs(admin) {
            Group queueHDT = new Group(Name = 'HDT_N2', Type = 'Queue');
            insert queueHDT;

            Group queueCCO = new Group(Name = 'CC_N2_CSI_CCO_Empl_Bankia', Type = 'Queue');
            insert queueCCO;

            Profile p = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_Caixabank_Empleados' LIMIT 1];
            UserRole rol = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center' LIMIT 1];
            PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes' LIMIT 1];
            PermissionSet psOperadorEmpleado = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO' LIMIT 1];
            PermissionSet psOperadorHDT = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_Operador' LIMIT 1];

            
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

            User testUser = new User(
                Alias = 'testus',
                Email = 'testuser@example.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                UserRoleId = rol.Id,
                TimeZoneSidKey = 'GMT',
                UserName = 'testuser@testing.example.com'
            );
            insert testUser;
            insert new List<PermissionSetAssignment> {
                new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = psOperadorEmpleado.Id),
                new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = psClasses.Id),
                new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = psOperadorHDT.Id)
            };
            Account cuentaEmpleado = new Account();
        cuentaEmpleado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuentaEmpleado.Name = 'Cuenta Prueba Empleado';
        cuentaEmpleado.CC_Numero_Oficina__c = '222';
        cuentaEmpleado.CC_Email__c = 'test@gmail.com';
        insert cuentaEmpleado;

        Contact contactoEmpleado = new Contact();
        contactoEmpleado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contactoEmpleado.AccountId = cuentaEmpleado.Id;
        contactoEmpleado.FirstName = 'Contacto';
        contactoEmpleado.LastName = 'Prueba Empleado';
        contactoEmpleado.CC_NumPerso__c = '25345550';
        contactoEmpleado.CC_Idioma__c = 'ca';
        contactoEmpleado.Email = 'correo@gmail.com';
        contactoEmpleado.Phone = '973242323';
        contactoEmpleado.MobilePhone = '973242323';
        contactoEmpleado.CC_Matricula__c = '12345678';
        contactoEmpleado.CC_Cargo__c = 'Empleado';
        insert contactoEmpleado;

        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        tematica.Name = 'Tematica';
        tematica.CC_Tipo_Cliente__c = 'Empleado';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        tematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert tematica;

        CC_MCC__c producto = new CC_MCC__c();
        producto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        producto.Name = 'Producto';
        producto.CC_Detalle__c = 'CaixaBank';
        producto.CC_Tipo_Cliente__c = 'Empleado';
        producto.CC_Tematica__c = tematica.Id;
        producto.CC_Codigo_Externo__c = 'PR-000001';
        insert producto;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
        motivo.Name = 'Motivo';
        motivo.CC_Tipo_Cliente__c = 'Empleado';
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MO-000001';
        insert motivo;

        CC_MCC__c causa = new CC_MCC__c();
        causa.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
        causa.Name = 'Valoración positiva';
        causa.CC_Tipo_Cliente__c = 'Empleado';
        causa.CC_Motivo__c = motivo.Id;
        causa.CC_Codigo_Externo__c = 'CA-000001';
        insert causa;

        CC_MCC__c solucion = new CC_MCC__c();
        solucion.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
        solucion.Name = 'Valoración positiva';
        solucion.CC_Tipo_Cliente__c = 'Empleado';
        solucion.CC_Causa__c = causa.Id;
        solucion.CC_Codigo_Externo__c = 'SO-000001';
        insert solucion;

        Case originalCCOCase = new Case(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado'),
            AccountId = cuentaEmpleado.Id,
            ContactId = contactoEmpleado.Id,
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            CC_MCC_Causa__c = causa.Id,
            CC_MCC_Solucion__c = solucion.Id,
            Status = 'Activo',
            Subject = 'Test Transfer CCO to HDT',
            Description = 'This is a test case from CCO.',
            CC_Detalles_Solucion__c = 'Solution details for CCO case.',
            OwnerId = testUser.Id,
            CC_Detalles_Consulta__c = 'Test',
            Origin = 'Phone',
            CC_Canal_procedencia__c = 'CCO'
        );
        insert originalCCOCase;

        List<CC_Settings__c> settingsList = new List<CC_Settings__c>();
        CC_Settings__c settings = new CC_Settings__c();
        settings.CC_Activa__c = true;
        settings.Name = 'CC_Colas_HDT_CCO_Activas';
        settings.CC_Configuracion_1__c = 'HDT';
        settings.CC_Configuracion_2__c = 'CCO';
        settingsList.add(settings);

        
        CC_Settings__c settings2 = new CC_Settings__c();
        settings2.CC_Activa__c = true;
        settings2.Name = 'CC_Colas_Transferencia_HDT_CCO';
        settings2.CC_Configuracion_1__c = 'CC_N2_CSI_CCO_Empl_Bankia';
        settings2.CC_Configuracion_2__c = 'HDT_Cola_2N';
        settingsList.add(settings2);

        CC_Settings__c settings3 = new CC_Settings__c();
        settings3.CC_Activa__c = true;
        settings3.Name = 'CC_Transferencia_Casos_HDT_CCO';
        settings3.CC_Configuracion_1__c = 'Upsert';
        settingsList.add(settings3);
        insert settingsList;

        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};

        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = owa[0].Address;
        params.HDT_Configuracion_2__c = owa[0].Address;
        insert params;
        }
        Test.stopTest();
    }

    @isTest
    public static void testTransferCaseFromCCOtoHDT() {
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1];
        Case originalCCOCase = [SELECT Id FROM Case WHERE Subject = 'Test Transfer CCO to HDT' LIMIT 1];

        /*ContentDocument cd = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cd.Id,
            LinkedEntityId = originalCCOCase.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;*/

        CC_CaseTransfer.TransferResult result;
        System.runAs(testUser) {
            result = CC_CaseTransfer.transferCaseToHDT(originalCCOCase.Id);
        }

        List<Case> newCase = [SELECT Id, RecordTypeId, Status, Subject, OwnerId, CC_CasoRelacionado__c, CaseNumber FROM Case WHERE CC_CasoRelacionado__c = :originalCCOCase.Id]; 

        System.assertNotEquals(null, newCase[0].Id, 'New Case ID should not be null.');

        Test.stopTest();

    }

    @isTest
    public static void testTransferCaseInvalidStatus() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1];

        Case originalCase = new Case(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado'),
            Status = 'Cerrado',
            Subject = 'Test Invalid Status',
            Description = 'This is a test case.',
            CC_Detalles_Solucion__c = 'Solution details.',
            OwnerId = testUser.Id
        );
        insert originalCase;

        CC_CaseTransfer.TransferResult result;
        System.runAs(testUser) {
            Test.startTest();
                result = CC_CaseTransfer.transferCaseToHDT(originalCase.Id);
            Test.stopTest();
        }

        System.assertEquals(false, result.isSuccess, 'Transfer should fail due to invalid status.');
        System.assert(result.message.contains('El caso debe estar en estado Activo, Pendiente Incidencia o Pendiente Colaborador para ser transferido.'), 'Correct error message.');
    }

    @isTest
    public static void testTransferCaseWithTasks() {
        Test.startTest();

        User testUser = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1];
        System.runAs(testUser) {

            List<Case> casos = new List<Case>();

            CC_MCC__c tematica = [SELECT Id FROM CC_MCC__c WHERE Name = 'Tematica' LIMIT 1];
            CC_MCC__c producto = [SELECT Id FROM CC_MCC__c WHERE Name = 'Producto' LIMIT 1];
            CC_MCC__c motivo = [SELECT Id FROM CC_MCC__c WHERE Name = 'Motivo' LIMIT 1];
            Account cuentaEmpleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' LIMIT 1];
            Contact contactoEmpleado = [SELECT Id FROM Contact WHERE LastName = 'Prueba Empleado' LIMIT 1];

            Case originalCCOCase = new Case(
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado'),
                AccountId = cuentaEmpleado.Id,
                ContactId = contactoEmpleado.Id,
                CC_MCC_Tematica__c = tematica.Id,
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivo.Id,
                Status = 'Activo',
                Subject = 'Test Transfer CCO to HDT',
                Description = 'This is a test case from CCO.',
                CC_Detalles_Solucion__c = 'Solution details for CCO case.',
                OwnerId = testUser.Id,
                CC_Detalles_Consulta__c = 'Test',
                Origin = 'Phone',
                CC_Canal_procedencia__c = 'CCO'
            );
            casos.add(originalCCOCase);

            Case caseTransfer = new Case(
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado'),
                AccountId = cuentaEmpleado.Id,
                ContactId = contactoEmpleado.Id,
                CC_MCC_Tematica__c = tematica.Id,
                CC_MCC_ProdServ__c = producto.Id,
                CC_MCC_Motivo__c = motivo.Id,
                Status = 'Cerrado',
                Subject = 'Test Transfer CCO to HDT',
                Description = 'This is a test case from CCO.',
                CC_Detalles_Solucion__c = 'Solution details for CCO case.',
                OwnerId = testUser.Id,
                CC_Detalles_Consulta__c = 'Test',
                Origin = 'Phone'            
            );
            casos.add(caseTransfer);
            insert casos;

            List<Case> casosCerrados = [SELECT Id, Status FROM Case WHERE Status = 'Cerrado'];
            originalCCOCase.CC_CasoRelacionado__c = casosCerrados[0].Id;
            originalCCOCase.Status = 'Rechazado';

            update originalCCOCase;

            List<Case> casosResult = [SELECT Id, Status FROM Case WHERE Status = 'Activo'];

            Case caseTransferResult = [SELECT Id, Status FROM Case WHERE Id = :casosResult[0].Id];
            System.assertEquals('Activo', caseTransferResult.Status, 'El caso debe estar activo.');
    
            Test.stopTest(); 

        }


    }

}