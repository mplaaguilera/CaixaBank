@isTest
public with sharing class CC_CaseTransferTest {

    @testSetup
    static void setupTestData() {
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
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado'),
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
            CC_Detalles_Consulta__c = 'Test'
        );
        insert originalCCOCase;

        }
    }

    @isTest
    public static void testTransferCaseFromCCOtoHDT() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1];
        Group queueHDT = [SELECT Id FROM Group WHERE Name = 'HDT_N2' AND Type = 'Queue' LIMIT 1];

        Id hdtRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'HDT_Empleado');
        Case originalCCOCase = [SELECT Id FROM Case WHERE Subject = 'Test Transfer CCO to HDT' LIMIT 1];

        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'testfile.txt',
            VersionData = Blob.valueOf('This is a test file content.'),
            Origin = 'H'
        );
        insert cv;

        ContentDocument cd = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cd.Id,
            LinkedEntityId = originalCCOCase.Id,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
        insert cdl;

        CC_CaseTransfer.TransferResult result;
        System.runAs(testUser) {
            Test.startTest();
                result = CC_CaseTransfer.transferCaseToHDT(originalCCOCase.Id);
            Test.stopTest();
        }
        Case updatedOriginalCase = [SELECT Id, Status, CC_CasoRelacionado__c FROM Case WHERE Id = :originalCCOCase.Id];

        Case newCase = [SELECT Id, RecordTypeId, Status, Subject, OwnerId, CC_CasoRelacionado__c, CaseNumber FROM Case WHERE Id = :result.newCaseId]; 

        system.debug(':::New Case: ' + newCase);

        System.assertEquals(true, result.isSuccess, 'Transfer should be successful.');
        System.assertNotEquals(null, result.newCaseId, 'New Case ID should not be null.');


        System.assertEquals('Cerrado', updatedOriginalCase.Status, 'Original case status should be Closed.');
        System.assertEquals(result.newCaseId, updatedOriginalCase.CC_CasoRelacionado__c, 'Original case should be linked to new case.');

        System.assertEquals(hdtRecordTypeId, newCase.RecordTypeId, 'New case RecordType should be HDT.');
        System.assertEquals('Activo', newCase.Status, 'New case status should be Open.');
        //System.assertEquals(queueHDT.Id, newCase.OwnerId, 'New case should be owned by HDT queue.');
        //System.assertEquals(originalCCOCase.Id, newCase.CC_CasoRelacionado__c, 'New case should be linked to original case.');
        //System.assert(newCase.Subject.contains('Transferencia (' + originalCCOCase.CaseNumber + ')'), 'New case subject should indicate transfer.');

        List<ContentDocumentLink> newCdl = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :newCase.Id];
        //System.assertEquals(1, newCdl.size(), 'Attachment should be copied to new case.');
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
    public static void testUpdateOriginalCaseOnClose() {
        Id ccoRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id hdtRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        User testUser = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1];

        Case originalCase = new Case(
            RecordTypeId = ccoRecordTypeId,
            Status = 'Activo',
            Subject = 'Original Case for Close Test',
            Description = 'Original case description.',
            OwnerId = testUser.Id
        );
        insert originalCase;

        Case newTransferredCase = new Case(
            RecordTypeId = hdtRecordTypeId,
            Status = 'Abierto',
            Subject = 'Transferred Case to Close',
            Description = 'Transferred case description.',
            CC_CasoRelacionado__c = originalCase.Id,
            CC_Detalles_Solucion__c = 'Solved the transferred issue.',
            OwnerId = testUser.Id
        );
        insert newTransferredCase;

        Case oldCaseState = newTransferredCase.clone(true, true, true, true);
        oldCaseState.Status = 'Abierto';
        System.runAs(testUser) {
            Test.startTest();
                newTransferredCase.Status = 'Cerrado';
                CC_CaseTransfer.updateOriginalCaseOnClose(new List<Case>{newTransferredCase});
            Test.stopTest();
        }
        
        Case updatedOriginalCase = [SELECT Id, CC_Resolucion__c, Status FROM Case WHERE Id = :originalCase.Id];
        System.assertNotEquals(null, updatedOriginalCase.CC_Resolucion__c, 'Original case resolution should be updated.');
        System.assert(updatedOriginalCase.CC_Resolucion__c.contains('Solved the transferred issue.'), 'Resolution message should contain solution details.');
    }

    @isTest
    public static void testUpdateOriginalCaseOnCloseNoRelatedCase() {
        Id ccoRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        User testUser = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1];

        Case nonTransferredCase = new Case(
            RecordTypeId = ccoRecordTypeId,
            Status = 'Activo',
            Subject = 'Non-transferred Case',
            Description = 'No related case.',
            OwnerId = testUser.Id
        );
        insert nonTransferredCase;

        Case oldCaseState = nonTransferredCase.clone(true, true, true, true);
        oldCaseState.Status = 'Activo';

        nonTransferredCase.Status = 'Cerrado';
        System.runAs(testUser) {
            Test.startTest();
                nonTransferredCase.Status = 'Cerrado';
                CC_CaseTransfer.updateOriginalCaseOnClose(new List<Case>{nonTransferredCase});
            Test.stopTest();
        }
        Case updatedCase = [SELECT Id, CC_Resolucion__c FROM Case WHERE Id = :nonTransferredCase.Id];
        System.assertEquals(null, updatedCase.CC_Resolucion__c, 'Resolution should not be updated for non-transferred case.');
    }

    @isTest
    public static void testUpdateOriginalCaseOnCloseStatusNotClosed() {
        Id ccoRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Id hdtRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        
        User testUser = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1];

        Case originalCase = new Case(
            RecordTypeId = ccoRecordTypeId,
            Status = 'Activo',
            Subject = 'Original Case for Not Closed Test',
            Description = 'Original case description.',
            OwnerId = testUser.Id
        );
        insert originalCase;

        Case newTransferredCase = new Case(
            RecordTypeId = hdtRecordTypeId,
            Status = 'Activo',
            Subject = 'Transferred Case Not Closed',
            Description = 'Transferred case description.',
            CC_CasoRelacionado__c = originalCase.Id,
            CC_Detalles_Solucion__c = 'Some solution.',
            OwnerId = testUser.Id
        );
        insert newTransferredCase;

        Case oldCaseState = newTransferredCase.clone(true, true, true, true);
        oldCaseState.Status = 'Abierto';
        System.runAs(testUser) {
            Test.startTest();
                CC_CaseTransfer.updateOriginalCaseOnClose(new List<Case>{newTransferredCase});
            Test.stopTest();
        }

        Case updatedOriginalCase = [SELECT Id, CC_Resolucion__c FROM Case WHERE Id = :originalCase.Id];
        System.assertEquals(null, updatedOriginalCase.CC_Resolucion__c, 'Resolution should not be updated if transferred case is not closed.');
    }
}