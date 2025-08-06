@isTest
public with sharing class SEG_GruposServiciosCSO_TRHan_Test {
    @testSetup
    static void testSetup() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
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

        Id recordTypeGrupo = Schema.SObjectType.SEG_ServiciosCSO__c.getRecordTypeInfosByDeveloperName().get('Grupo').getRecordTypeId();

        // CRear grupo CSO Y SEVRICIO CSO
        SEG_GruposCSO__c grupoCSO = new SEG_GruposCSO__c();
		grupoCSO.Name = 'Grupo Test';
		grupoCSO.SEG_ActivoCSO__c = true;
		insert grupoCSO;

		SEG_ServiciosCSO__c servCsoGrupo = new SEG_ServiciosCSO__c();
		servCsoGrupo.SEG_Activo__c = true;
		servCsoGrupo.RecordTypeId = recordTypeGrupo;
		servCsoGrupo.SEG_Organizacion__c = 'Banca Corporativa;Instituciones';
		servCsoGrupo.SEG_Zona__c = 'Corporativa';
		servCsoGrupo.SEG_TMO__c = 10;
		servCsoGrupo.Name = 'Test Grupo';
		insert servCsoGrupo;

        SEG_ServiciosCSO__c servCsoGrupo2 = new SEG_ServiciosCSO__c();
		servCsoGrupo2.SEG_Activo__c = true;
		servCsoGrupo2.RecordTypeId = recordTypeGrupo;
		servCsoGrupo2.SEG_Organizacion__c = 'Banca Corporativa;Instituciones';
		servCsoGrupo2.SEG_Zona__c = 'Corporativa';
		servCsoGrupo2.SEG_TMO__c = 10;
		servCsoGrupo2.Name = 'Test Grupo 2';
		insert servCsoGrupo2;

    }
        
    @IsTest
    static void testActivacionGrupo() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];

        Test.startTest();
        System.runAs(usuarioTest) { 
            // Crear datos de prueba
            List<SEG_GruposServiciosCSO__c> lstGruposServicios = new List<SEG_GruposServiciosCSO__c>();
            SEG_GruposServiciosCSO__c grupo1 = new SEG_GruposServiciosCSO__c(SEG_Activo__c = true);
            SEG_GruposServiciosCSO__c grupo2 = new SEG_GruposServiciosCSO__c(SEG_Activo__c = false);
            lstGruposServicios.add(grupo1);
            lstGruposServicios.add(grupo2);

            // Insertar datos de prueba
            insert lstGruposServicios;

            List<SEG_GruposServiciosCSO__c> gruposInsertados = new List<SEG_GruposServiciosCSO__c>();

            // Verificar que los campos SEG\_FechaActivacion\_\_c y SEG\_FechaDesactivacion\_\_c se han actualizado correctamente
            for (SEG_GruposServiciosCSO__c grupo : [SELECT SEG_Activo__c, SEG_FechaActivacion__c, SEG_FechaDesactivacion__c FROM SEG_GruposServiciosCSO__c WHERE Id IN :lstGruposServicios]) {
                if (grupo.SEG_Activo__c) {
                    System.assertNotEquals(null, grupo.SEG_FechaActivacion__c, 'La fecha de activación no es la esperada');
                    System.assertEquals(null, grupo.SEG_FechaDesactivacion__c, 'La fecha de desactivación no es la esperada');
                    grupo.SEG_Activo__c = false;
                } else {
                    System.assertEquals(null, grupo.SEG_FechaActivacion__c, 'La fecha de activación no es la esperada');
                    System.assertNotEquals(null, grupo.SEG_FechaDesactivacion__c, 'La fecha de desactivación no es la esperada');
                    grupo.SEG_Activo__c = true;
                }
                gruposInsertados.add(grupo);
            }

            update gruposInsertados;

            // Verificar que los campos SEG\_FechaActivacion\_\_c y SEG\_FechaDesactivacion\_\_c se han actualizado correctamente
            for (SEG_GruposServiciosCSO__c grupo : [SELECT SEG_Activo__c, SEG_FechaActivacion__c, SEG_FechaDesactivacion__c FROM SEG_GruposServiciosCSO__c WHERE Id IN :lstGruposServicios]) {
                if (grupo.SEG_Activo__c) {
                    System.assertNotEquals(null, grupo.SEG_FechaActivacion__c, 'La fecha de activación no es la esperada');
                } else {
                    System.assertNotEquals(null, grupo.SEG_FechaDesactivacion__c, 'La fecha de desactivación no es la esperada');
                }
            }
        }
    }

    @IsTest
    static void grupoServicioCSO() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];

        // Query para traer datos
        SEG_GruposCSO__c grupo = [SELECT Id, Name FROM SEG_GruposCSO__c LIMIT 1];
        SEG_ServiciosCSO__c servicio1 = [SELECT Id, Name FROM SEG_ServiciosCSO__c WHERE Name = 'Test Grupo' LIMIT 1];
        SEG_ServiciosCSO__c servicio2 = [SELECT Id, Name FROM SEG_ServiciosCSO__c WHERE Name = 'Test Grupo 2' LIMIT 1];

        Test.startTest();
        System.runAs(usuarioTest) { 
            // Crear datos de prueba
            SEG_GruposServiciosCSO__c grupo1 = new SEG_GruposServiciosCSO__c();
            grupo1.SEG_GrupoCSO__c = grupo.Id;
            grupo1.SEG_ServiciosCSO__c = servicio1.Id;
            // Insertar datos de prueba
            insert grupo1;

            // Verificar que los campos SEG_GrupoCSO__c se han actualizado correctamente
            System.assertNotEquals(grupo1.SEG_GruposServiciosCSO__c , String.valueof(grupo1.SEG_GrupoCSO__c) + String.valueof(grupo1.SEG_ServiciosCSO__c), 'No se ha concatenado correctamente grupo y servicio');

            grupo1.SEG_ServiciosCSO__c = servicio2.Id;
            update grupo1;

            // Verificar que los campos SEG_GrupoCSO__c se han actualizado correctamente
            SEG_GruposServiciosCSO__c grupoUpdate = [SELECT Id, SEG_GruposServiciosCSO__c, SEG_GrupoCSO__c, SEG_ServiciosCSO__c FROM SEG_GruposServiciosCSO__c WHERE Id = :grupo1.Id LIMIT 1];
            System.assertEquals(grupoUpdate.SEG_GruposServiciosCSO__c , String.valueof(grupoUpdate.SEG_GrupoCSO__c) + String.valueof(grupoUpdate.SEG_ServiciosCSO__c), 'No se ha concatenado correcta,ente grupo y servicio');
        }
    }
}