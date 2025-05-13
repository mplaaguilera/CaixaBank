@isTest
public with sharing class HDT_AppUtilities_Test {
    @testSetup
    static void setupData() {
        // Crear casos de prueba
        List<Case> casos = new List<Case>{
            new Case(Subject = 'Caso de prueba 1'),
            new Case(Subject = 'Caso de prueba 2')
        };
        insert casos;

        // Obtener los IDs de los casos creados
        Id caso1Id = casos[0].Id;
        Id caso2Id = casos[1].Id;

        ContentVersion contentVersion1 = new ContentVersion();
        contentVersion1.ContentLocation = 'S';
        contentVersion1.PathOnClient = 'DocumentoPrueba.txt';
        contentVersion1.Origin = 'H';
        contentVersion1.Title = 'Pinguino';
        contentVersion1.VersionData = Blob.valueOf('Test Content3');
        insert contentVersion1;
        
        ContentVersion cVers = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion1.Id];
        
        List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
        ContentDocumentLink cdl1 = new ContentDocumentLink(
            LinkedEntityId = caso1Id,
            ContentDocumentId = cVers.ContentDocumentId,
            ShareType = 'V'
        );
       insert cdl1;


    }

    @isTest
    static void testObtenerAdjuntosCasosBase64() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        // Obtener los casos creados en el testSetup
        List<Case> casos = [SELECT Id FROM Case];
        List<Id> caseIds = new List<Id>();
        for (Case c : casos) {
            caseIds.add(c.Id);
        }

        // Llamar a la función que estamos probando
        Test.startTest();
        Map<Id, List<Map<String, String>>> resultado = HDT_AppUtilities.obtenerAdjuntosBase64PorCasos(caseIds);
        Test.stopTest();

        // Validar que el mapa no sea nulo
        System.assertNotEquals(null, resultado, 'El resultado no debe ser nulo');

        // Validar que al menos el primer caso tiene adjuntos
        System.assert(resultado.containsKey(casos[0].Id), 'El caso 1 debe estar en el resultado');
        System.assertEquals(1, resultado.get(casos[0].Id).size(), 'El caso 1 debe tener un adjunto');

        // Validar que el caso 2 no tiene adjuntos
        System.assert(!resultado.containsKey(casos[1].Id), 'El caso 2 no debe estar en el resultado porque no tiene adjuntos');
        }
    }

    @isTest
    static void testObtenerAdjuntosCasosBase64CasosSinAdjuntos() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

            // Crear un caso sin adjuntos
            Case casoSinAdjunto = new Case(Status = 'Nuevo', Subject = 'Caso sin adjuntos');
            insert casoSinAdjunto;

            // Llamar a la función con un caso que no tiene adjuntos
            List<Id> caseIds = new List<Id>{ casoSinAdjunto.Id };

            Test.startTest();
            Map<Id, List<Map<String, String>>> resultado = HDT_AppUtilities.obtenerAdjuntosBase64PorCasos(caseIds);
            Test.stopTest();

            // Validar que el resultado no contenga el caso sin adjuntos
            System.assertEquals(0, resultado.size(), 'El mapa debe estar vacío porque el caso no tiene adjuntos');
        }
    }

    @IsTest
    static void testDisplayErrorsDelete() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        // Create some records to delete
        List<Case> recordsToDelete = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            recordsToDelete.add(new Case(Subject='Record ' + i));
        }
        insert recordsToDelete;
        
        // Delete the records
        List<Database.DeleteResult> deleteResults = Database.delete(recordsToDelete);
        // Verify that the records were deleted successfully
         List<Case> deletedRecords = [SELECT Id FROM Case WHERE Id IN :recordsToDelete];
        System.assertEquals(0, deletedRecords.size(), 'The records were not deleted successfully');
   
        Test.startTest();
       
            HDT_AppUtilities.displayErrorsDelete('testDisplayErrorsDelete', deleteResults);
            
        Test.stopTest();
        }
    }


    /**
     * Comprobación de un insert de caso success.
    */
    @isTest
    private static void displayErrorSuccessTest() {
        
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        String methodName = 'displayErrorTest';
        List<Case> lstCaso = new List<Case>();
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        
        Contact contacto = new Contact(LastName = 'Test', CC_Numero_Documento__c = '36592162J', CC_Sexo__c = 'V');
        insert contacto;
        
        //Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.ContactId = contacto.Id;
        caso.RecordTypeId = rtCaso;
        lstCaso.add(caso);
        
        List<Database.SaveResult> listInsertResult = Database.insert(lstCaso,false);
        HDT_AppUtilities.displayErrors(methodName, listInsertResult);
        
        for (Database.SaveResult sr : listInsertResult) {
        	system.assert(sr.isSuccess(), 'Inserción correcta');
        }
    }
    }
    
    /**
     * Comprobación de un insert de caso pintando los errores.
    */
    @isTest
    private static void displayErrorTest() {

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
        String methodName = 'displayErrorTest';
        List<Case> lstCaso = new List<Case>();
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        
        Contact contacto = new Contact(LastName = 'Test', CC_Numero_Documento__c = '36592162J', CC_Sexo__c = 'V');
        insert contacto;
        
        //Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.RecordTypeId = rtCaso;
        caso.Origin = 'Fallo';
        caso.CC_Canal_Procedencia__c = 'Fallo';
        lstCaso.add(caso);
        
        try{
         	List<Database.SaveResult> listInsertResult = Database.insert(lstCaso,false);
        	HDT_AppUtilities.displayErrors(methodName, listInsertResult);  
            for (Database.SaveResult sr : listInsertResult) {
        		system.assert(!sr.isSuccess(), 'Inserción Fallida');
        	}
        }catch(Exception e){
            system.assert(e.getMessage() != null, 'Error');
        }
        }
    }
    
}