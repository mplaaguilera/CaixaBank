@isTest
public with sharing class SEG_Filtros_Excepciones_BU_TRHan_Test {
        
    @testSetup
    static void testSetup() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            
            User thisUser = new User(
                alias = 'tsegmen',
                email = 'testSEGBI@acme.com',
                emailencodingkey = 'UTF-8',
                lastname = 'Smith',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                profileid = [SELECT Id FROM Profile WHERE Name= 'System administrator'].Id,
                userroleid = [SELECT Id FROM UserRole WHERE Name = 'Segmentos + FFEE'].Id,
                timezonesidkey ='America/Los_Angeles',
                Username = uniqueName + '@test' + orgId + '.org'
            );
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT PermissionSetGroupId, PermissionSetId, PermissionSet.Name
                                                                FROM PermissionSetGroupComponent
                                                                WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]) {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()) {
                insert listPermissionSetAssignment;
            }
        }
    }
    
    @isTest
    public static void testInsertActivoTrue() {

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI@acme.com' LIMIT 1];

        // Crear un registro de prueba con SEG_Activo__c igual a true
        SEG_Filtros_Excepciones__c excepcion = new SEG_Filtros_Excepciones__c(
            SEG_Activo__c = true
        );

        System.runAs(usuarioTest) {
            Test.startTest();
            
            // Insertar el registro
            insert excepcion;
            Test.stopTest();
            
            // verificar que la fecha de activación sea igual a la fecha actual
            SEG_Filtros_Excepciones__c excepcionRes = [SELECT Id, SEG_FechaActivacion__c FROM SEG_Filtros_Excepciones__c WHERE Id = :excepcion.Id LIMIT 1];
            System.assertNotEquals(null, excepcionRes.SEG_FechaActivacion__c, 'La fecha de activación no coincide con la fecha actual');
        }
    }

    @isTest
    public static void testInsertActivoFalse() {

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI@acme.com' LIMIT 1];

        // Crear un registro de prueba con SEG_Activo__c igual a false
        SEG_Filtros_Excepciones__c excepcion = new SEG_Filtros_Excepciones__c(
            SEG_Activo__c = false
        );

        System.runAs(usuarioTest) {
            Test.startTest();
            
            // Insertar el registro
            insert excepcion;
            Test.stopTest();
            
            // verificar que la fecha de desactivación sea igual a la fecha actual
            SEG_Filtros_Excepciones__c excepcionRes = [SELECT Id, SEG_FechaDesactivacion__c FROM SEG_Filtros_Excepciones__c WHERE Id = :excepcion.Id LIMIT 1];
            System.assertNotEquals(null, excepcionRes.SEG_FechaDesactivacion__c, 'La fecha de desactivación no coincide con la fecha actual');
        }
    }

    @isTest
    public static void testUpdateTrue() {

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI@acme.com' LIMIT 1];

        // Crear un registro de prueba con SEG_Activo__c igual a false
        SEG_Filtros_Excepciones__c excepcion = new SEG_Filtros_Excepciones__c(
            SEG_Activo__c = false
        );
        
        insert excepcion;
        
        System.runAs(usuarioTest) {
            Test.startTest();
            // Actualizar el registro
            excepcion.SEG_Activo__c = true;

            // Insertar el registro
            update excepcion;
            Test.stopTest();
            
            // verificar que la fecha de activación sea igual a la fecha actual
            SEG_Filtros_Excepciones__c excepcionRes = [SELECT Id, SEG_FechaActivacion__c FROM SEG_Filtros_Excepciones__c WHERE Id = :excepcion.Id LIMIT 1];
            System.assertNotEquals(null, excepcionRes.SEG_FechaActivacion__c, 'La fecha de activación no coincide con la fecha actual');
        }
    }
    
    @isTest
    public static void testUpdateFalse() {

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI@acme.com' LIMIT 1];

        // Crear un registro de prueba con SEG_Activo__c igual a false
        SEG_Filtros_Excepciones__c excepcion = new SEG_Filtros_Excepciones__c(
            SEG_Activo__c = true
        );
        
        insert excepcion;
        
        System.runAs(usuarioTest) {
            Test.startTest();
            // Actualizar el registro
            excepcion.SEG_Activo__c = false;
			
            // Updatear el registro
            update excepcion;
            Test.stopTest();
            
            // verificar que la fecha de desactivación sea igual a la fecha actual
            SEG_Filtros_Excepciones__c excepcionRes = [SELECT Id, SEG_FechaDesactivacion__c FROM SEG_Filtros_Excepciones__c WHERE Id = :excepcion.Id LIMIT 1];
            System.assertNotEquals(null, excepcionRes.SEG_FechaDesactivacion__c, 'La fecha de desactivación no coincide con la fecha actual');
        }
    }
}