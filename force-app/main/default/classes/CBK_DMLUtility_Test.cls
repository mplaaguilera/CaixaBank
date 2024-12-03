@isTest
public class CBK_DMLUtility_Test {
    @testSetup
	static void initialData() {  
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Sistemática Comercial'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
            User thisUser = new User(alias = 'user2', email='testSEGBI2@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
            Username = uniqueName + '@test' + orgId + '.org');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('CBK_Framework_Login','CBK_Framework_Admin')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
    }



    @isTest
    static void testInsertOpportunityRecordsWithException() {

        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

       System.runAs (testUser) {
        // Crear una lista de sObjects con datos inválidos para provocar una excepción
        List<sObject> invalidSObjectList = new List<sObject>();
        
        // Crear un objeto Opportunity sin StageName y sin CloseDate, lo que debería provocar un error
        Opportunity invalidOpportunity = new Opportunity(
            Name = 'Test Opportunity' // Se establece el nombre
            // CloseDate y StageName no se establecen para forzar un error
        );
        invalidSObjectList.add(invalidOpportunity);

        // Llamar al método insertRecords y capturar cualquier excepción
        Test.startTest();
            
                try {
                    CBK_DMLUtility.insertRecords(invalidSObjectList);
                } catch (Exception ex ) {
                    System.assertEquals(true, ex.getMessage().contains('REQUIRED_FIELD_MISSING'),  'Se han borrado los dos registros');
                }
            Test.stopTest();
       }
    }

    @isTest
    static void testInsertRecords() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

       System.runAs (testUser) {

        // Crear una lista de registros de prueba para insertar
        List<Account> accountsToInsert = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        };
        
        // Llamar al método insertRecords
            CBK_DMLUtility.insertRecords(accountsToInsert);
            
            // Verificar que los registros se hayan insertado correctamente
            List<Account> lsOpo = [SELECT Id FROM Account];
            System.assertEquals(false, lsOpo.isEmpty(), 'La lista de resultados debería contener un registro.');
    }
    }

    @isTest
    static void testUpdateRecords() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

       System.runAs (testUser) {

        // Crear una lista de registros de prueba para insertar y luego actualizar
        List<Account> accountsToInsert = new List<Account>{
            new Account(Name = 'Test Account 3'),
            new Account(Name = 'Test Account 4')
        };
        insert accountsToInsert;
        
        // Modificar los registros para actualizar
        for (Account acc : accountsToInsert) {
            acc.Name = acc.Name + ' Updated';
        }
        
        // Llamar al método updateRecords
            CBK_DMLUtility.updateRecords(accountsToInsert);
            
            List<Account> lsOpo = [SELECT Id FROM Account WHERE Name =  'Test Account 3 Updated'];
            System.assertEquals(false, lsOpo.isEmpty(), 'La lista de resultados debería contener un registro.');
    }
    }

    @isTest
    static void testDeleteRecords() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

       System.runAs (testUser) {

        // Crear una lista de registros de prueba para insertar y luego eliminar
        List<Account> accountsToInsert = new List<Account>{
            new Account(Name = 'Test Account 5'),
            new Account(Name = 'Test Account 6')
        };
        insert accountsToInsert;
        
        // Llamar al método deleteRecords
            CBK_DMLUtility.deleteRecords(accountsToInsert);
            
            // Verificar que la lista de resultados contenga un error
            List<Account> lsOpo = [SELECT Id FROM Account];
            System.assertEquals(true, lsOpo.isEmpty(), 'La lista de resultados debería estar vacía.');
        }
    }
    
    @isTest
    static void testUpdateRecordsWithErrors() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

        System.runAs (testUser) {
            // Crear una lista de registros de prueba para insertar y luego actualizar
            List<Account> accountsToInsert = new List<Account>{
                new Account(Name = 'Test Account 8'),
                new Account(Name = 'Test Account 9')
            };
            insert accountsToInsert;
            
            // Modificar los registros para actualizar con un registro inválido para provocar un error
            for (Account acc : accountsToInsert) {
                acc.Name = null; // Esto provocará un error porque Name es un campo obligatorio
            }
            
            try {
                CBK_DMLUtility.updateRecords(accountsToInsert);
            } catch (Exception ex ) {
                System.assertEquals(true, ex.getMessage().contains('REQUIRED_FIELD_MISSING'),  'Se han borrado los dos registros');
            }
        }
    }

    @isTest
    static void testDeleteRecordsWithErrors() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

        System.runAs (testUser) {
            // Crear una lista de registros de prueba para insertar y luego eliminar
            List<Account> accountsToInsert = new List<Account>{
                new Account(Name = 'Test Account 10'),
                new Account(Name = 'Test Account 11')
            };
            insert accountsToInsert;
            
            // Eliminar uno de los registros para causar un fallo en la segunda eliminación
            delete accountsToInsert[0];
            
            // Llamar al método deleteRecords
            try {
                CBK_DMLUtility.deleteRecords(accountsToInsert);
            } catch (Exception ex ) {
                System.assertEquals(true, ex.getMessage().contains('ENTITY_IS_DELETED'),  'Se han borrado los dos registros');
            }
        }
    }

    @isTest
    static void testInsertOpportunityRecordsWithExceptionParam() {

        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

       System.runAs (testUser) {

        // Crear una lista de sObjects con datos inválidos para provocar una excepción
        List<sObject> invalidSObjectList = new List<sObject>();
        
        // Crear un objeto Opportunity sin StageName y sin CloseDate, lo que debería provocar un error
        Opportunity invalidOpportunity = new Opportunity(
            Name = 'Test Opportunity' // Se establece el nombre
            // CloseDate y StageName no se establecen para forzar un error
        );
        invalidSObjectList.add(invalidOpportunity);

        // Llamar al método insertRecords y capturar cualquier excepción
        Test.startTest();
        List<Database.SaveResult> results = CBK_DMLUtility.insertRecords(invalidSObjectList, false);
        Test.stopTest();
        
        // Verificar que la lista de resultados contenga un error
        System.assert(results.size() == 1, 'La lista de resultados debería contener un registro.');
       }
    }

    @isTest
    static void testInsertRecordsParam() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

       System.runAs (testUser) {

        // Crear una lista de registros de prueba para insertar
        List<Account> accountsToInsert = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2')
        };
        
        // Llamar al método insertRecords
        List<Database.SaveResult> results = CBK_DMLUtility.insertRecords(accountsToInsert, false);
        
        // Verificar que los registros se hayan insertado correctamente
        for (Database.SaveResult result : results) {
            System.assert(result.isSuccess(), 'El registro debería haberse insertado correctamente.');
        }
    }
    }

    @isTest
    static void testUpdateRecordsParam() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

       System.runAs (testUser) {

        // Crear una lista de registros de prueba para insertar y luego actualizar
        List<Account> accountsToInsert = new List<Account>{
            new Account(Name = 'Test Account 3'),
            new Account(Name = 'Test Account 4')
        };
        insert accountsToInsert;
        
        // Modificar los registros para actualizar
        for (Account acc : accountsToInsert) {
            acc.Name = acc.Name + ' Updated';
        }
        
        // Llamar al método updateRecords
        List<Database.SaveResult> results = CBK_DMLUtility.updateRecords(accountsToInsert, false);
        
        // Verificar que los registros se hayan actualizado correctamente
        for (Database.SaveResult result : results) {
            System.assert(result.isSuccess(), 'El registro debería haberse actualizado correctamente.');
        }
    }
    }

    @isTest
    static void testDeleteRecordsParam() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

       System.runAs (testUser) {

        // Crear una lista de registros de prueba para insertar y luego eliminar
        List<Account> accountsToInsert = new List<Account>{
            new Account(Name = 'Test Account 5'),
            new Account(Name = 'Test Account 6')
        };
        insert accountsToInsert;
        
        // Llamar al método deleteRecords
        List<Database.DeleteResult> results = CBK_DMLUtility.deleteRecords(accountsToInsert, false);
        
        // Verificar que la lista de resultados contenga un error
        System.assert(results.size() == 2, 'La lista de resultados debería contener un registro.');
        }
    }
    
    @isTest
    static void testUpdateRecordsWithErrorsParam() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

        System.runAs (testUser) {
        // Crear una lista de registros de prueba para insertar y luego actualizar
        List<Account> accountsToInsert = new List<Account>{
            new Account(Name = 'Test Account 8'),
            new Account(Name = 'Test Account 9')
        };
        insert accountsToInsert;
        
        // Modificar los registros para actualizar con un registro inválido para provocar un error
        for (Account acc : accountsToInsert) {
            acc.Name = null; // Esto provocará un error porque Name es un campo obligatorio
        }
        
        // Llamar al método updateRecords
            List<Database.SaveResult> results = CBK_DMLUtility.updateRecords(accountsToInsert, false);
        
        // Verificar que los registros hayan fallado
        for (Database.SaveResult result : results) {
            System.assert(!result.isSuccess(), 'El registro debería haber fallado.');
        }
        }
    }

    @isTest
    static void testDeleteRecordsWithErrorsParam() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

        System.runAs (testUser) {
        // Crear una lista de registros de prueba para insertar y luego eliminar
        List<Account> accountsToInsert = new List<Account>{
            new Account(Name = 'Test Account 10'),
            new Account(Name = 'Test Account 11')
        };
        insert accountsToInsert;
        
         // Eliminar uno de los registros para causar un fallo en la segunda eliminación
         delete accountsToInsert[0];
            
            // Llamar al método deleteRecords
            List<Database.DeleteResult> results = CBK_DMLUtility.deleteRecords(accountsToInsert, false);

            System.assert(results[1].isSuccess(), 'El segundo registro debería haberse eliminado correctamente.');
        }
    }
}