@isTest
public with sharing class HDT_AppUtilities_Test {

    @IsTest
    static void testDisplayErrorsDelete() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

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
        
        System.runAs(new User(Id = UserInfo.getUserId())) {

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

        System.runAs(new User(Id = UserInfo.getUserId())) {

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