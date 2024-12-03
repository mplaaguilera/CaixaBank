@isTest
public with sharing class SPV_MCC_Buscador_Controller_Test {
    @TestSetup
    static void makeData(){
        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        usuarioAdmin.Username = 'useraadmin@test.com.testdata';
        Database.insert(usuarioAdmin);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            usuarioGeneral.Username = 'userageneral@test.com.testdata';
            Database.insert(usuarioGeneral);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            Database.insert(permiSetAssiAdmin);
        }
        Test.stopTest();


    Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPV_Reclamacion').getRecordTypeId();
    Case caso = new Case();
    caso.Subject = 'testCase2';
    caso.RecordTypeId = recordTypeCaso;
    caso.Status = 'SAC_001';
    Database.insert(caso);


    }
    
    @isTest
    public static void formaParteFamiliaTest() {
        User usuario = [SELECT id FROM User WHERE Username ='useraadmin@test.com.testdata' AND isActive = true Limit 1];
        Case caso = [SELECT id, OwnerId FROM Case WHERE Subject = 'testCase2' Limit 1 ];
        caso.OwnerId = usuario.id;
        Database.update(caso);
        System.debug(' comparar ids ' + caso.OwnerId + ' ' + usuario.id);
        Boolean resultado; 

        System.runAs(usuario){
        Test.startTest();
        resultado = SPV_MCC_Buscador_Controller.compruebaPermisoSPV(caso.Id, usuario.Id);
        Test.stopTest();
        }

        System.assertNotEquals(resultado, false, 'La comprobación de si el usuario forma parte de la familia ha fallado');
    }
}