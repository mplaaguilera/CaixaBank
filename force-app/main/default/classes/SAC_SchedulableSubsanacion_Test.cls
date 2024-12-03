@isTest
public with sharing class SAC_SchedulableSubsanacion_Test {
    @TestSetup
    static void makeData(){
       
        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC Admin
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];  
            Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);   
        }

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'testRec1');
        camposRecl.put('OwnerId', usuarioGeneral.Id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        Database.insert(reclamacion);
    }

    @isTest
    static void test() {
        Test.startTest();
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'testRec1'];

        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();
        CBK_SCH_PendingProcess__c pendingProcessCaso = new CBK_SCH_PendingProcess__c();
        pendingProcessCaso.recordId__c = reclamacion.Id;
        pendingProcessCaso.Schedule_Time__c = system.now().addDays(10);
        pendingProcessCaso.className__c = 'SAC_SchedulableSubsanacion';
        listaPendingProcess.add(pendingProcessCaso);

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        System.runAs(usuario){
            reclamacion.Status = 'SAC_006';
            reclamacion.SAC_StatusAuxiliar__c = reclamacion.Status;
            reclamacion.SAC_TipoConsumidor__c ='si';
            Database.update(reclamacion);
        }

        SAC_SchedulableSubsanacion sch = new SAC_SchedulableSubsanacion();
        sch.work(listaPendingProcess);
        Test.stopTest();

        System.assertNotEquals(null, sch, 'No se ha podido lanzar');
    }
}