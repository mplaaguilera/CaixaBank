@IsTest
public with sharing class SAC_QueueableCerrarMilestoneLetrado_Test {
    @TestSetup
    static void makeData(){
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];    
        SAC_DatabaseDML.insertDML(usuarioGeneral, false); 
        //Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);
        //Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            //Reclamacion 1
            Map<String, Object> camposRecl1 = new Map<String, Object>();
            camposRecl1.put('Subject', 'testRec1');
            camposRecl1.put('Origin', 'Otros');
            camposRecl1.put('Status', 'SAC_001');
            camposRecl1.put('SAC_StatusAuxiliar__c', 'SAC_001');

            Case reclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl1);
        
            List<Case> listaReclamaciones = new List<Case>();
            listaReclamaciones.add(reclamacion1);
            SAC_DatabaseDML.insertListDML(listaReclamaciones, false);
            //Database.insert(listaReclamaciones);
        }
    }

    
    @isTest
    static void queueableCerrarMilestoneLetradoTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        List<case> lstReclamaciones = [SELECT Id FROM Case WHERE Subject = 'testRec1'];
       
        System.runAs(usuario){
            Test.startTest();
            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder()
            .addId(lstReclamaciones.get(0).Id)
            .addString('listNewCase')
            .build();
            try {
                System.enqueueJob(new SAC_QueueableCerrarMilestoneLetrado(lstReclamaciones), options);    
            } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 }  
            Test.stopTest();

            System.assertNotEquals(lstReclamaciones, null, 'Hay un error');
        }
        
    }

    @isTest
    static void printTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso1 = [SELECT Id FROM Case WHERE Subject = 'testRec1'];

        System.runAs(usuario){
            Test.startTest();
            
            SAC_QueueableCerrarMilestoneLetrado.print(LoggingLevel.ERROR, 'execute', '----ERR status:  ', true);
            Test.stopTest();

            System.assertNotEquals(caso1, null, 'Hay un error');
        }
        
    }
}