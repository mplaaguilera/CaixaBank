@isTest
public with sharing class SPV_LCMP_PretensionesRelacionTest {
    @TestSetup
    static void makeData(){
    Test.startTest();
    User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
    usuarioAdmin.Username = 'useraadmin@test.com.testdata';
    Database.insert(usuarioAdmin);

    User usuario;
    System.runAs(usuarioAdmin){
        usuario = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
        usuario.Username = 'ustestesteo@test.com';
        Database.insert(usuario);

        PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
        PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
        permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
        permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
        Database.insert(permiSetAssiAdmin);
    }
    Test.stopTest();    
    



     //RECLAMACION 1
     Map<String, Object> camposRecl = new Map<String, Object>();
     camposRecl.put('Subject', 'TestRec');
     camposRecl.put('Origin', 'Backoffice');
     camposRecl.put('Status', 'Alta');
     camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
     camposRecl.put('OwnerId', usuario.Id);

     Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);
     Database.insert(casoReclamacion);

     //PRETENSION 1
     Map<String, Object> camposPrete = new Map<String, Object>();
     camposPrete.put('SuppliedCompany', 'TestPrete');
     camposPrete.put('SAC_Reclamacion__c', casoReclamacion.Id);
     camposPrete.put('SAC_ValidacionMCC__c', false);


     Case casoPrete = SPV_TestDataFactory.crearCaso('Pretension', camposPrete);
     Database.insert(casoPrete);


    }

    @isTest
    static void getPretensionesTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        Case caso = [SELECT id FROM Case WHERE Subject = 'TestRec' limit 1];
        List<Case> result = new List<Case>();


        System.RunAs(usuario){
          result = SPV_LCMP_PretensionesRelacionadas.getPretensiones(caso.id);
        }
        Test.stopTest();
        Assert.areNotEqual(null, result, 'No se ha podido cargar la lista');


    }
    @isTest 
    static void validarPretensionTest(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'useraadmin@test.com.testdata' AND isActive = true Limit 1];
        Case prete = [SELECT id, SAC_Reclamacion__c, SAC_ValidacionMCC__c FROM Case WHERE SuppliedCompany = 'TestPrete' limit 1];


        System.RunAs(usuario){
        SPV_LCMP_PretensionesRelacionadas.validarPretension(prete.id, true);
        SPV_LCMP_PretensionesRelacionadas.validarPretension(prete.id, false);

        }
        Test.stopTest();

        Case result = [SELECT id FROM Case WHERE SuppliedCompany = 'TestPrete' limit 1];
        Assert.areNotEqual(null, result, 'No se ha podido cargar la lista');

    }


}