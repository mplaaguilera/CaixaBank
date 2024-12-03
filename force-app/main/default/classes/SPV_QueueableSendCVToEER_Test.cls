@isTest
public class SPV_QueueableSendCVToEER_Test {
    
    @testSetup
    static void setupData() {
        // User
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        insert usuarioAdmin;
        // Account
        Account acc = new Account(
            Name = 'cuentaTest',
            CC_Tipo_Centro__c = 'DT',
            CC_NumPerso__c = '123456789'
        );
        insert acc;
        // ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Test Document',
            FirstPublishLocationId = acc.Id,
            VersionData = Blob.valueOf('Sample data'),
            PathOnClient = 'TestDocument.pdf'
        );
        insert cv;
        
    }
    @IsTest
    static void testExecute() {
        // User
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
		// Account
        Account acc = [SELECT Id FROM Account WHERE CC_NumPerso__c = '123456789' LIMIT 1];
        // ContentVersion        
        List<ContentVersion> lstCV = [SELECT Id, FirstPublishLocationId, Title, FileType, VersionData FROM ContentVersion WHERE FirstPublishLocationId = :acc.Id LIMIT 1];
        
        Test.startTest();
        System.runAs(usuario){
            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                .addId(acc.Id)
                .addString('MyQueueable')
                .build();
            Test.setMock(HttpCalloutMock.class, new MockPostDocumentResponse());
            System.enqueueJob(new SPV_QueueableSendCVToEER(lstCV), options);
        }
        Test.stopTest();
        
        ContentVersion cv = [SELECT Id, SAC_IdEER__c FROM ContentVersion WHERE Id IN: lstCV];
        System.assertNotEquals(null, cv.SAC_IdEER__c, 'El campo SAC_IdEER__c debería haberse actualizado');
    } 
    
    private class MockPostDocumentResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"documentoDetail":{"metadata":{"documentId":"123456"}}}');
            return res;
        }
    }
}