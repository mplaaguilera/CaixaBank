@isTest
public with sharing class SEG_UsuariosCSO_TRHan_Test {
    /**
    * @description   Preparación de los datos.
    */
    @testSetup
    public static void testSetup() 
    {
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
            Profile perfil2 = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol2 = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            User thisUser2 = new User(alias = 'tsegmen', email='testSEGBI@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil2.Id, userroleid = rol2.Id,
                timezonesidkey='America/Los_Angeles',
                username='testSEGBI@acme.com');
            insert thisUser2;
            List<PermissionSetAssignment> listPermissionSetAssignment2 = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment2.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment2.isEmpty()){
                insert listPermissionSetAssignment2;
            }
        }
    }

    //Metodo Test para probar el rellenado automático de los datos de reclamación (SEG_1a_Reclamacion_ejecutada_manualmente__c, SEG_2a_Reclamacion_ejecutada_manualmente__c y SEG_3a_Reclamacion_ejecutada_manualmente__c) en la inserción.
    @isTest
    public static void concatenacionUsuarioGrupoTest(){
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

        Test.startTest();
        System.runAs(usuarioTest) { 
            SEG_GruposCSO__c grupoCSO = new SEG_GruposCSO__c();
            grupoCSO.Name = 'Grupo Test';
            grupoCSO.SEG_ActivoCSO__c = true;
            insert grupoCSO;

            SEG_UsuariosCSO__c usuarioCSO = new SEG_UsuariosCSO__c();
            usuarioCSO.SEG_Usuario__c = usuarioTest.Id;
            usuarioCSO.SEG_GrupoCSO__c = grupoCSO.Id;
            insert usuarioCSO;
        
            SEG_UsuariosCSO__c usuarioCSOInsert = [SELECT Id, SEG_Usuario__c, SEG_GrupoCSO__c, SEG_UsuarioGrupo__c FROM SEG_UsuariosCSO__c LIMIT 1];
            System.assertEquals(String.valueOf(usuarioCSOInsert.SEG_Usuario__c) + String.valueOf(usuarioCSOInsert.SEG_GrupoCSO__c) , usuarioCSOInsert.SEG_UsuarioGrupo__c,'No se han concatenado los campos');

            SEG_GruposCSO__c grupoCSO2 = new SEG_GruposCSO__c();
            grupoCSO2.Name = 'Grupo Test Dos';
            grupoCSO2.SEG_ActivoCSO__c = true;
            insert grupoCSO2;

            usuarioCSO.SEG_GrupoCSO__c = grupoCSO2.Id;
            update usuarioCSO;
        }

        Test.stopTest();

        SEG_UsuariosCSO__c usuarioCSOUpdate = [SELECT Id, SEG_Usuario__c, SEG_GrupoCSO__c, SEG_UsuarioGrupo__c FROM SEG_UsuariosCSO__c LIMIT 1];
        System.assertEquals(String.valueOf(usuarioCSOUpdate.SEG_Usuario__c) + String.valueOf(usuarioCSOUpdate.SEG_GrupoCSO__c) , usuarioCSOUpdate.SEG_UsuarioGrupo__c,'No se han concatenado los campos');
    }
}