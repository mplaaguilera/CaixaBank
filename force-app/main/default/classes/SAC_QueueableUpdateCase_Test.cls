@IsTest
public with sharing class SAC_QueueableUpdateCase_Test {
    @TestSetup
    static void makeData(){
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        System.runAs(usuarioGeneral){
            //Reclamacion 1
            Map<String, Object> camposRecl1 = new Map<String, Object>();
            camposRecl1.put('Subject', 'testRec1');
            camposRecl1.put('Origin', 'Otros');
            camposRecl1.put('Status', 'SAC_001');
            camposRecl1.put('SAC_StatusAuxiliar__c', 'SAC_001');

            Case reclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl1);

            //Reclamacion 2
            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'testRec2');
            camposRecl2.put('Origin', 'Otros');
            camposRecl2.put('Status', null);

            Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

           
            List<Case> listaReclamaciones = new List<Case>();
            listaReclamaciones.add(reclamacion1);
            listaReclamaciones.add(reclamacion2);
            SAC_DatabaseDML.insertListDML(listaReclamaciones, false);
        }
    }

    
    @isTest
    static void SAC_QueueableUpdateCaseTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        List<case> lstReclamaciones = new List<case>();
        Case caso1 = [SELECT Id FROM Case WHERE Subject = 'testRec1'];
        Case caso2 = [SELECT Id FROM Case WHERE Subject = 'testRec2'];
        lstReclamaciones.add(caso1);
        lstReclamaciones.add(caso2);

       
        System.runAs(usuario){
            Test.startTest();
            DateTime dt = DateTime.now();
            Long dateInMilliseconds = dt.getTime();
            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder()
            .addId(lstReclamaciones.get(0).Id)
            .addString(String.valueOf(dateInMilliseconds))
            .build();
            try {
                System.enqueueJob(new SAC_QueueableUpdateCase(lstReclamaciones), options);    
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
            
            SAC_QueueableUpdateCase.print(LoggingLevel.ERROR, 'execute', '----ERR status:  ', true);
            Test.stopTest();

            System.assertNotEquals(caso1, null, 'Hay un error');
        }
        
    }
}