@isTest
public with sharing class SACH_AppUtilities_Test {

    /**
     * Comprobación de un insert de caso success.
    */
    @isTest
    private static void displayErrorSuccessTest() {
        
        String methodName = 'displayErrorTest';
        List<Case> lstCaso = new List<Case>();
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        
        Contact contacto = new Contact(LastName = 'Test', CC_Numero_Documento__c = '36592162J', CC_Sexo__c = 'V');
        insert contacto;
        
        //Preparación de los datos
        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.ContactId = contacto.Id;
        caso.RecordTypeId = rtCaso;
        lstCaso.add(caso);
        
        List<Database.SaveResult> listInsertResult = Database.insert(lstCaso,false);
        SACH_AppUtilities.displayErrors(methodName, listInsertResult);
        
        for (Database.SaveResult sr : listInsertResult) {
        	system.assert(sr.isSuccess(), 'Inserción correcta');
        }
    }
    
    /**
     * Comprobación de un insert de caso pintando los errores.
    */
    @isTest
    private static void displayErrorTest() {
        
        String methodName = 'displayErrorTest';
        List<Case> lstCaso = new List<Case>();
        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('SACH_Cliente').getRecordTypeId();
        
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
        	SACH_AppUtilities.displayErrors(methodName, listInsertResult);  
            for (Database.SaveResult sr : listInsertResult) {
        		system.assert(!sr.isSuccess(), 'Inserción Fallida');
        	}
        }catch(Exception e){
            system.assert(e.getMessage() != null, 'Error');
        }
    }
    
}