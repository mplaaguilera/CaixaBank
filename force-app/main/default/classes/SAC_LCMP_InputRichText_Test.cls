@isTest
public with sharing class SAC_LCMP_InputRichText_Test {
    
    @TestSetup
    static void makeData(){

        Test.startTest();
        //Usuario Admin
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SAC_DatabaseDML.insertDML(usuarioAdmin, true);
        Test.stopTest();

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Test Reclamacion CV Test');
        camposRecl.put('OwnerId', usuarioAdmin.id);

        Case reclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        SAC_DatabaseDML.insertDML(reclamacion1, false);

        ContentVersion contentVersionInsert = SAC_TestDataFactory.crearContentVersion(reclamacion1);
        SAC_DatabaseDML.insertDML(contentVersionInsert, true);
    }

    @isTest
    static void creacionThreadIDTest(){
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Reclamacion CV Test' LIMIT 1];
        ContentVersion cv = [SELECT Id, SAC_BloqueoTotalVisibilidad__c FROM ContentVersion WHERE FirstPublishLocationId = :caso.Id LIMIT 1];
        Boolean bloqueInicial = cv.SAC_BloqueoTotalVisibilidad__c;

        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_InputRichText.actualizarCV(cv.Id);
            Assert.areEqual(bloqueInicial, cv.SAC_BloqueoTotalVisibilidad__c, 'No se ha actualizado el campo SAC_BloqueoTotalVisibilidad__c.');
            Test.stopTest();
        }   
    }
}