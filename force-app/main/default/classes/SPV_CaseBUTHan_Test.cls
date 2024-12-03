@isTest
public with sharing class SPV_CaseBUTHan_Test {

    @TestSetup
    static void makeData(){

        
        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            Database.insert(usuarioGeneral);
        }
        Test.stopTest();

        Group colaPteAsignar = [SELECT id FROM Group WHERE DeveloperName = 'SPV_PendienteAsignar'];

        //Reclamacion
        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'TestRec PteAsignar');
        camposReclamacion.put('Origin', 'Backoffice');
        camposReclamacion.put('Status', 'SAC_001');
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposReclamacion.put('OwnerId', colaPteAsignar.Id);

        Case reclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        Database.insert(reclamacion);
      
    }


    @isTest
    static void actualizarCaso_test(){
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        User usuario2 = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT id, Subject, OwnerId, Status FROM Case WHERE Subject = 'TestRec PteAsignar'  LIMIT 1];

        System.runAs(usuario){
            reclamacion.OwnerId = usuario2.Id;
            reclamacion.Subject = 'Cambiado';
            Database.update(reclamacion);
        }

        Case nuevaReclamacion = [SELECT id, Subject, OwnerId, Status FROM Case WHERE Subject = 'Cambiado' LIMIT 1];

        Assert.areEqual('Cambiado', nuevaReclamacion.Subject, 'No se ha actualizado el caso correctamente');
        Test.stopTest();
    }
}