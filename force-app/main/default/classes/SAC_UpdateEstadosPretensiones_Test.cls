@isTest
public with sharing class SAC_UpdateEstadosPretensiones_Test {
    
    @TestSetup
    static void makeData() {
        //Usuario SAC General
		User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);      
        //Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);    
        //Database.insert(permiSetAssi);

        List<Case> reclamaciones = new List<Case>();
        List<Case> pretensiones = new List<Case>();

        System.runAs(usuarioGeneral){
            //Reclamacion
            Map<String, Object> camposRecl1 = new Map<String, Object>();
            camposRecl1.put('Subject', 'TestRec');
            camposRecl1.put('Status', 'SAC_001');
            camposRecl1.put('Origin', 'Backoffice');
            camposRecl1.put('SAC_TipoConsumidor__c', 'Si');

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl1);
            reclamaciones.add(reclamacion);

            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'TestRec2');
            camposRecl2.put('Status', 'SAC_002');
            camposRecl2.put('Origin', 'Backoffice');
            camposRecl2.put('SAC_TipoConsumidor__c', 'Si');

            Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
            reclamaciones.add(reclamacion2);

            Map<String, Object> camposRecl3 = new Map<String, Object>();
            camposRecl3.put('Subject', 'TestRec3');
            camposRecl3.put('Status', 'SAC_005');
            camposRecl3.put('Origin', 'Backoffice');
            camposRecl3.put('SAC_TipoConsumidor__c', 'Si');

            Case reclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);
            reclamaciones.add(reclamacion3);

            SAC_DatabaseDML.insertListDML(reclamaciones, false);  
            //Database.insert(reclamaciones);  

            //Pretension
            Map<String, Object> camposPret1 = new Map<String, Object>();
            camposPret1.put('Origin', 'Backoffice');
            camposPret1.put('SAC_Reclamacion__c', reclamacion.Id);
            camposPret1.put('Status', 'SAC_001');
            camposPret1.put('SuppliedCompany', 'prueba');

            Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret1);
            pretensiones.add(casoPretension);

            Map<String, Object> camposPret2 = new Map<String, Object>();
            camposPret2.put('Origin', 'Backoffice');
            camposPret2.put('SAC_Reclamacion__c', reclamacion2.Id);
            camposPret2.put('Status', 'SAC_003');
            camposPret2.put('SuppliedCompany', 'prueba4');

            Case casoPretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);
            pretensiones.add(casoPretension2);

            Map<String, Object> camposPret3 = new Map<String, Object>();
            camposPret3.put('Origin', 'Backoffice');
            camposPret3.put('SAC_Reclamacion__c', reclamacion.Id);
            camposPret3.put('Status', 'SAC_001');
            camposPret3.put('SuppliedCompany', 'prueba2');

            Case casoPretension3 = SAC_TestDataFactory.crearCaso('Pretension',camposPret3);
            pretensiones.add(casoPretension3);

            Map<String, Object> camposPret4 = new Map<String, Object>();
            camposPret4.put('Origin', 'Backoffice');
            camposPret4.put('SAC_Reclamacion__c', reclamacion2.Id);
            camposPret4.put('Status', 'SAC_002');
            camposPret4.put('SuppliedCompany', 'prueba3');

            Case casoPretension4 = SAC_TestDataFactory.crearCaso('Pretension',camposPret4);
            pretensiones.add(casoPretension4);


            Map<String, Object> camposPret5 = new Map<String, Object>();
            camposPret5.put('Origin', 'Backoffice');
            camposPret5.put('SAC_Reclamacion__c', reclamacion3.Id);
            camposPret5.put('Status', 'SAC_005');
            camposPret5.put('SuppliedCompany', 'prueba5');

            Case casoPretension5 = SAC_TestDataFactory.crearCaso('Pretension',camposPret5);
            pretensiones.add(casoPretension5);

            SAC_DatabaseDML.insertListDML(pretensiones, false); 
            //Database.insert(pretensiones); 
        }
        
    }

    @isTest
    static void testUpdatePretensionStatus(){

        List<Case> casosPrueba = [SELECT Id, Status, Subject FROM Case WHERE Subject = 'TestRec' OR Subject = 'TestRec2'];
        List<Case> pretensionesv1 = [SELECT Id, Subject, Status FROM Case WHERE SuppliedCompany = 'prueba' OR SuppliedCompany = 'prueba3'];
        casosPrueba[0].Status = 'SAC_006';
        casosPrueba[0].SAC_StatusAuxiliar__c = 'SAC_006';
        casosPrueba[1].Status = 'SAC_006';
        casosPrueba[1].SAC_StatusAuxiliar__c = 'SAC_006';

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            Test.StartTest();
            SAC_DatabaseDML.updateListDML(casosPrueba, false); 
            //Database.update(casosPrueba);
            Test.stopTest();
        }
        List<Case> pretensionesv2 = [SELECT Id, Subject, Status FROM Case WHERE SuppliedCompany = 'prueba' OR SuppliedCompany = 'prueba3']; 

        system.assertEquals(pretensionesv2[0].Status, 'SAC_006','No se ha podido actualizar el estado de la Pretension desde el trigger al actualizar la Reclamacion. Falla parte 1');
        system.assertEquals(pretensionesv2[1].Status, 'SAC_006','No se ha podido actualizar el estado de la Pretension desde el trigger al actualizar la Reclamacion. Falla parte 2');
        system.assertEquals(pretensionesv2[0].Status, pretensionesv2[1].Status,'No se ha podido actualizar el estado de la Pretension desde el trigger al actualizar la Reclamacion. Falla parte 3');


    }
    @isTest
    static void testUpdatePretensionStatus2(){

        List<Case> casosPrueba = [SELECT Id, Status, Subject FROM Case WHERE Subject = 'TestRec3'];
        List<Case> pretensionesv1 = [SELECT Id, Subject, Status FROM Case WHERE SuppliedCompany = 'prueba5'];
        casosPrueba[0].Status = 'SAC_001';
        casosPrueba[0].SAC_StatusAuxiliar__c = 'SAC_001';

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            Test.StartTest();
            SAC_DatabaseDML.updateListDML(casosPrueba, false); 
            //Database.update(casosPrueba);
            Test.stopTest();
        }
        List<Case> pretensionesv2 = [SELECT Id, Subject, Status FROM Case WHERE SuppliedCompany = 'prueba5']; 

        system.assertNotEquals(pretensionesv2[0].Status, pretensionesv1[0].Status,'No se ha podido actualizar el estado de la Pretension desde el trigger al actualizar la Reclamacion. Falla parte 1');
    }

}