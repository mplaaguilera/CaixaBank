@isTest
public with sharing class SPV_LCMP_CamposEscaladoAllanamiento_Test {
    
    @TestSetup
    static void makeData(){

        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            Database.insert(usuarioGeneral);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            Database.insert(permiSetAssiAdmin);
        }
        Test.stopTest();
    }

    @isTest
    static void obtenerValoresPicklistTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario1){
            Test.startTest();
            SPV_LCMP_CamposEscaladoAllanamiento.PicklistWrapper valoresPicklist = SPV_LCMP_CamposEscaladoAllanamiento.obtenerValoresPicklist();

            Assert.areNotEqual(null, valoresPicklist, 'No se han recuperado los valores para la picklist');
            Test.stopTest();
        }
    }

}