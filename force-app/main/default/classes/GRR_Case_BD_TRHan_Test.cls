@isTest
private class GRR_Case_BD_TRHan_Test {
    
    @TestSetup
    static void setupTestData() {

        User usuario = GRR_TestDataFactory.usuarioPruebasGRR();
        System.runAs(usuario) {

        // Crear RecordType para GRR_Cliente
        Id rtCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente');
        Id rtCuenta = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'GRR_NoCliente_PA');
        
        // Crear cuenta de prueba
        Account testAccount = new Account(
            FirstName = 'GRR',
            LastName = 'Prueba',
            GRR_Historia__c = 'Historia de prueba',
            RecordTypeId = rtCuenta
        );
        insert testAccount;
        
        // Crear caso de prueba
        Case testCase = new Case(
            Subject = 'Caso Test',
            AccountId = testAccount.Id,
            RecordTypeId = rtCliente
        );
        insert testCase;
        
        // Crear adjunto de prueba
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        insert cv;
        
        // Obtener el ContentDocumentId
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        
        // Crear ContentDocumentLink para el caso
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = contentDocumentId;
        cdl.LinkedEntityId = testCase.Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        }
    }
    
    @isTest
    static void testLimpiarAdjuntos() {

        User usuarioGRR = [SELECT Id FROM User WHERE User.FirstName = 'GRR' LIMIT 1];

        System.runAs(usuarioGRR) {
        // Obtener el caso de prueba
        Case testCase = [SELECT Id, AccountId FROM Case LIMIT 1];
        Account testAccount = [SELECT Id, GRR_Historia__c FROM Account WHERE Id = :testCase.AccountId];
        
        // Verificar estado inicial
        System.assertNotEquals('', testAccount.GRR_Historia__c, 'La historia no debería estar vacía inicialmente');
        List<ContentDocumentLink> initialLinks = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testCase.Id];
        System.assert(!initialLinks.isEmpty(), 'Debería haber adjuntos inicialmente');
        
        // Ejecutar el trigger
        Test.startTest();
        delete testCase;
        Test.stopTest();
        
        // Verificar resultados
        Account updatedAccount = [SELECT Id, GRR_Historia__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(null, updatedAccount.GRR_Historia__c, 'La historia debería estar vacía después de eliminar el caso');
        
        List<ContentDocumentLink> finalLinks = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testCase.Id];
        System.assert(finalLinks.isEmpty(), 'No debería haber adjuntos después de eliminar el caso');
        }
    }
}