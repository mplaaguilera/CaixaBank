@isTest
public with sharing class SEG_Caracteristica_TRHan_Test {
    @testSetup
    static void testSetup() {
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
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

    @isTest
    public static void eligePicklistTest(){
 
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

        Test.startTest();
        System.runAs(usuarioTest) { 
            CC_Caracteristica__c car = new CC_Caracteristica__c();
            car.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();
            car.CC_Descripcion__c = 'SEG TEST';
            insert car;
        }
        Test.stopTest();
        CC_Caracteristica__c carTrasInsert = [SELECT Id, OS_Negocio__c FROM CC_Caracteristica__c LIMIT 1];
        System.assertEquals('SEGMENTOS' , carTrasInsert.OS_Negocio__c,'El caso no se ha insertado correctamente');
    }
}