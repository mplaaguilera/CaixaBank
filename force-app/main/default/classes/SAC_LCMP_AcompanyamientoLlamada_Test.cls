@isTest
public with sharing class SAC_LCMP_AcompanyamientoLlamada_Test {
    
    @TestSetup
    static void makeData(){
        //Usuario SAC_General
        User usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        SAC_DatabaseDML.insertDML(usuario, false);
        //Database.insert(usuario);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        System.runAs(usuario){
            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');
            camposRecl.put('Status', 'SAC_001');
            camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
            
            Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            SAC_DatabaseDML.insertDML(casoReclamacion, false);
            //Database.insert(casoReclamacion);

            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('Subject', 'TestPret');
            camposPret.put('Status', 'SAC_001');
            camposPret.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposPret.put('SAC_Reclamacion__c', casoReclamacion.id);
            
            Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            SAC_DatabaseDML.insertDML(casoPretension, false);
            //Database.insert(casoPretension);
        }
    }

    @isTest
    static void getInfoInit_Test(){
        Case caso = [SELECT Id FROM Case WHERE Subject ='TestPret' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_AcompanyamientoLlamada.ObjWrapper result = SAC_LCMP_AcompanyamientoLlamada.getInfoInit(caso.Id);
            Test.stopTest();

            System.assertEquals(result.eval, true, 'La obtención de datos ha fallado.');
        }
    }

    @isTest
    static void ejecutarApex_Test(){
        Case caso = [SELECT Id, SAC_AcompanyaLlamada__c FROM Case WHERE Subject ='TestPret' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_AcompanyamientoLlamada.ejecutarApex(caso.Id);
            Test.stopTest();
            Case caso2 = [SELECT Id, SAC_AcompanyaLlamada__c FROM Case WHERE Subject ='TestPret' LIMIT 1];
            System.assertNotEquals(caso.SAC_AcompanyaLlamada__c, caso2.SAC_AcompanyaLlamada__c, 'La modificación del registro ha fallado.');
        }
    }
}