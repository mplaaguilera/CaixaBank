@isTest
public with sharing class GRR_AppUtilities_Test {

    @isTest
    public static void testDisplayErrorsSuccess() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            
            String methodName = 'displayErrorTest';
            List<Case> lstCaso = new List<Case>();
            Id rtCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente');
            Case caso = new Case();
            caso.Subject = 'Caso Test';
            caso.RecordTypeId = rtCaso;
            lstCaso.add(caso);
            
            List<Database.SaveResult> listInsertResult = Database.insert(lstCaso,false);
            GRR_AppUtilities.displayErrors(methodName, listInsertResult);
            for (Database.SaveResult sr : listInsertResult) {
                system.assert(sr.isSuccess(), 'Inserción correcta');
            }   

            Test.stopTest();
        }
    }

    @isTest
    public static void testDisplayErrors() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            
            String methodName = 'displayErrorTest';
            List<Case> lstCaso = new List<Case>();
            Id rtCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente');
            Case caso = new Case();
            caso.Subject = 'Caso Test';
            caso.RecordTypeId = rtCaso;
            caso.Origin = 'Fallo';
            caso.CC_Canal_Procedencia__c = 'Fallo';
            lstCaso.add(caso);
            
            try{
                 List<Database.SaveResult> listInsertResult = Database.insert(lstCaso,false);
                GRR_AppUtilities.displayErrors(methodName, listInsertResult);  
                for (Database.SaveResult sr : listInsertResult) {
                    system.assert(!sr.isSuccess(), 'Inserción Fallida');
                }
            }catch(Exception e){
                system.assert(e.getMessage() != null, 'Error');
            }    

            Test.stopTest();
        }
    }

    @isTest
    public static void testDisplayErrorsDelete() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            
            List<Case> recordsToDelete = new List<Case>();
            for (Integer i = 0; i < 5; i++) {
                recordsToDelete.add(new Case(Subject='Record ' + i));
            }
            insert recordsToDelete;
    
            List<Database.DeleteResult> deleteResults = Database.delete(recordsToDelete);
            List<Case> deletedRecords = [SELECT Id FROM Case WHERE Id IN :recordsToDelete];
            System.assertEquals(0, deletedRecords.size());
            GRR_AppUtilities.displayErrorsDelete('testDisplayErrorsDelete', deleteResults);

            Test.stopTest();
        }
    }

}