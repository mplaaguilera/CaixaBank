@isTest
public with sharing class CBK_Framework_Batch_Object_Test {

    @testSetup
	static void initialData() {  
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Sistemática Comercial'];
            User thisUser = new User(alias = 'user2', email='testSEGBI2@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                username='testSEGBI2xx@acme.com');
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
    static void testExecuteBatchBuilder() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI2xx@acme.com' LIMIT 1];

        System.runAs (testUser) {

        // Crear datos de prueba
        CBK_Framework_Batch__c batchParams = new CBK_Framework_Batch__c(
            UsuarioContexto__c = 'OT',
            Tipo__c = 'Puntual',
            Priority__c = 1,
            BatchSize__c = 100,
            params__c = '{"key1":"value1"}', // Asegurarse de que esto sea un JSON válido
            Notif__c = true,
            Proyecto__c = 'TestProject',
            Email_Notif__c = 'test@example.com'
        );

        // Crear un builder y configurar valores
        CBK_Framework_Batch_Object.BatchProcessConfigBuilder builder = new CBK_Framework_Batch_Object.BatchProcessConfigBuilder()
            .setClassName('TestClassName')
            .setTipo(batchParams.Tipo__c)
            .setUsuariodecontexto(batchParams.UsuarioContexto__c)
            .setProximaEjecucion(DateTime.now())
            .setPriority(batchParams.Priority__c)
            .setBatchSize(batchParams.BatchSize__c)
            .setParametros(batchParams.params__c)
            .setNotificarErrores(batchParams.Notif__c)
            .setProyecto(batchParams.Proyecto__c)
            .setEmaildenotificacion(batchParams.Email_Notif__c);

        Test.startTest();
        Id batchProcessId = CBK_Framework_Batch_Object.executeBatchBuilder(builder);
        Test.stopTest();

        // Verificar que el batch process ID no es nulo
        System.assertNotEquals(null, batchProcessId, 'Batch process ID should not be null');

        // Verificar que el registro CBK_Framework_Batch__c fue creado
        CBK_Framework_Batch__c jobDef = [SELECT Id, Name, Class_Name__c, UsuarioContexto__c, Priority__c, BatchSize__c, params__c,Tipo__c FROM CBK_Framework_Batch__c WHERE Id = :batchProcessId];
        System.assertNotEquals(null, jobDef, 'Batch job definition should have been created');
        System.assertEquals('TestClassName', jobDef.Class_Name__c, 'Class name should match');
        System.assertEquals('OT', jobDef.UsuarioContexto__c, 'Usuario de contexto should match');
        System.assertEquals(1, jobDef.Priority__c, 'Priority should match');
        System.assertEquals(100, jobDef.BatchSize__c, 'Batch size should match');
        System.assertEquals('Puntual', jobDef.Tipo__c, 'Batch size should match');
        }
    }

    @isTest
    static void testExecuteBatchBuilderSinPrioridad() {
        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI2xx@acme.com' LIMIT 1];

        System.runAs (testUser) {

        // Crear datos de prueba
        CBK_Framework_Batch__c batchParams = new CBK_Framework_Batch__c(
            UsuarioContexto__c = 'OT',
            Tipo__c = 'Puntual',
            Priority__c = 0,
            BatchSize__c = 100,
            params__c = '{"key1":"value1"}', // Asegurarse de que esto sea un JSON válido
            Notif__c = true,
            Proyecto__c = 'TestProject',
            Email_Notif__c = 'test@example.com'
        );

        // Crear un builder y configurar valores
        CBK_Framework_Batch_Object.BatchProcessConfigBuilder builder = new CBK_Framework_Batch_Object.BatchProcessConfigBuilder()
            .setClassName('CBK_MonitorJobs_Batch')
            .setTipo(batchParams.Tipo__c)
            .setUsuariodecontexto(batchParams.UsuarioContexto__c)
            .setProximaEjecucion(DateTime.now())
            .setPriority(batchParams.Priority__c)
            .setBatchSize(batchParams.BatchSize__c)
            .setParametros(batchParams.params__c)
            .setNotificarErrores(batchParams.Notif__c)
            .setProyecto(batchParams.Proyecto__c)
            .setEmaildenotificacion(batchParams.Email_Notif__c);

        Test.startTest();
            Id batchProcessId = CBK_Framework_Batch_Object.executeBatchBuilder(builder);
        Test.stopTest();

        // Verificar que el batch process ID no es nulo
        System.assertNotEquals(null, batchProcessId, 'Batch process ID should not be null');

        // Verificar que el registro CBK_Framework_Batch__c fue creado
        CBK_Framework_Batch__c jobDef = [SELECT Id, Name, Class_Name__c, UsuarioContexto__c, Priority__c, BatchSize__c, params__c FROM CBK_Framework_Batch__c WHERE Id = :batchProcessId];
        System.assertNotEquals(null, jobDef, 'Batch job definition should have been created');
        System.assertEquals('CBK_MonitorJobs_Batch', jobDef.Class_Name__c, 'Class name should match');
        System.assertEquals('OT', jobDef.UsuarioContexto__c, 'Usuario de contexto should match');
        System.assertEquals(0, jobDef.Priority__c, 'Priority should match');
        System.assertEquals(100, jobDef.BatchSize__c, 'Batch size should match');
        }
    }
    
}