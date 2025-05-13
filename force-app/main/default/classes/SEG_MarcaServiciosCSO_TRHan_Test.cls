@IsTest
public class SEG_MarcaServiciosCSO_TRHan_Test {
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

        Id recordTypeMarca = Schema.SObjectType.SEG_ServiciosCSO__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();

        SEG_MarcasCSO__c marcaCSO = new SEG_MarcasCSO__c();
		marcaCSO.SEG_Activo__c = true;
		insert marcaCSO;

        // Servicios
        SEG_ServiciosCSO__c servCsoMarca = new SEG_ServiciosCSO__c();
		servCsoMarca.SEG_Activo__c = true;
		servCsoMarca.RecordTypeId = recordTypeMarca;
		servCsoMarca.SEG_Organizacion__c = 'Banca Corporativa;Instituciones';
		servCsoMarca.SEG_Zona__c = 'Corporativa';
		servCsoMarca.SEG_TMO__c = 10;
		servCsoMarca.Name = 'Test Grupo';
		insert servCsoMarca;

        SEG_ServiciosCSO__c servCsoMarca2 = new SEG_ServiciosCSO__c();
		servCsoMarca2.SEG_Activo__c = true;
		servCsoMarca2.RecordTypeId = recordTypeMarca;
		servCsoMarca2.SEG_Organizacion__c = 'Banca Corporativa;Instituciones';
		servCsoMarca2.SEG_Zona__c = 'Corporativa';
		servCsoMarca2.SEG_TMO__c = 10;
		servCsoMarca2.Name = 'Test Grupo 2';
		insert servCsoMarca2;
    }

    @IsTest
    static void testActivacionMarca() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];

        Test.startTest();
        System.runAs(usuarioTest) { 

        // Crear datos de prueba
        List<SEG_MarcasCSO__c> lstMarcas = new List<SEG_MarcasCSO__c>();
        SEG_MarcasCSO__c marca1 = new SEG_MarcasCSO__c(SEG_Activo__c = true);
        SEG_MarcasCSO__c marca2 = new SEG_MarcasCSO__c(SEG_Activo__c = false);
        lstMarcas.add(marca1);
        lstMarcas.add(marca2);

        // Insertar datos de prueba
        insert lstMarcas;

        List<SEG_MarcasCSO__c> marcasInsertados = new List<SEG_MarcasCSO__c>();

        // Verificar que los campos SEG_FechaActivacion__c y SEG_FechaDesactivacion__c se han actualizado correctamente
        for (SEG_MarcasCSO__c marca : [SELECT SEG_Activo__c,SEG_FechaActivacion__c, SEG_FechaDesactivacion__c FROM SEG_MarcasCSO__c WHERE Id IN :lstMarcas]) {
            if (marca.SEG_Activo__c) {
                System.assertNotEquals(null, marca.SEG_FechaActivacion__c, 'La fecha de activación no es la esperada');
                System.assertEquals(null, marca.SEG_FechaDesactivacion__c, 'La fecha de desactivación no es la esperada');
                marca.SEG_Activo__c = false;
            } else {
                System.assertEquals(null, marca.SEG_FechaActivacion__c, 'La fecha de activación no es la esperada');
                System.assertNotEquals(null, marca.SEG_FechaDesactivacion__c, 'La fecha de desactivación no es la esperada');
                marca.SEG_Activo__c = true;
            }
            marcasInsertados.add(marca);
        }

        update marcasInsertados;

        // Verificar que los campos SEG\_FechaActivacion\_\_c y SEG\_FechaDesactivacion\_\_c se han actualizado correctamente
        for (SEG_MarcasCSO__c marca : [SELECT SEG_Activo__c, SEG_FechaActivacion__c, SEG_FechaDesactivacion__c FROM SEG_MarcasCSO__c WHERE Id IN :lstMarcas]) {
            if (marca.SEG_Activo__c) {
                System.assertNotEquals(null, marca.SEG_FechaActivacion__c, 'La fecha de activación no es la esperada');
            } else {
                System.assertNotEquals(null, marca.SEG_FechaDesactivacion__c, 'La fecha de desactivación no es la esperada');
            }
        }
    }
    }
    @IsTest
    static void marcaServicioCSO() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];

        // Query para traer datos
        SEG_MarcasCSO__c marca = [SELECT Id FROM SEG_MarcasCSO__c LIMIT 1];
        SEG_ServiciosCSO__c servicio1 = [SELECT Id, Name FROM SEG_ServiciosCSO__c WHERE Name = 'Test Grupo' LIMIT 1];
        SEG_ServiciosCSO__c servicio2 = [SELECT Id, Name FROM SEG_ServiciosCSO__c WHERE Name = 'Test Grupo 2' LIMIT 1];

        Test.startTest();
        System.runAs(usuarioTest) { 
            // Crear datos de prueba
            SEG_MarcasCSO__c marcaTest = new SEG_MarcasCSO__c();
            marcaTest.SEG_ServiciosCSO__c = servicio1.Id;
            // Insertar datos de prueba
            insert marcaTest;

            // Verificar que los campos SEG_GrupoCSO__c se han insertado correctamente
            System.assertNotEquals(marcaTest.SEG_Marca__c , String.valueof(marcaTest.SEG_MarcasCSO__c) + String.valueof(marcaTest.SEG_ServiciosCSO__c), 'No se ha concatenado correctamente marca y servicio');

            marcaTest.SEG_ServiciosCSO__c = servicio2.Id;
            update marcaTest;

            // Verificar que los campos SEG_GrupoCSO__c se han actualizado correctamente
            SEG_MarcasCSO__c marcaUpdate = [SELECT Id, SEG_MarcasCSO__c, SEG_Marca__c, SEG_ServiciosCSO__c FROM SEG_MarcasCSO__c WHERE Id = :marcaTest.Id LIMIT 1];
            System.assertNotEquals(marcaUpdate.SEG_Marca__c , String.valueof(marcaUpdate.SEG_MarcasCSO__c) + String.valueof(marcaUpdate.SEG_ServiciosCSO__c), 'No se ha concatenado correcta,ente marca y servicio');
        }
    }
}