@isTest
public with sharing class SAC_CaseControllerVF_Test {
    @TestSetup
    static void makeData(){

        //Usuario SAC General
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

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            SAC_DatabaseDML.insertDML(reclamacion, false); 
            //Database.insert(reclamacion);

            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('SuppliedCompany', 'TestPret');
            camposPret.put('Status', 'SAC_001');
            camposPret.put('SAC_Reclamacion__c', reclamacion.Id);
            camposPret.put('SAC_Redaccion__c', 'Lorem ipsum test redaccion');
            camposPret.put('SAC_RedaccionFinal__c', true);
            camposPret.put('SAC_SentidoResolucion__c', 'SAC_001');

            Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);


            Map<String, Object> camposPret2 = new Map<String, Object>();
            camposPret2.put('SuppliedCompany', 'TestPret2');
            camposPret2.put('Status', 'SAC_001');
            camposPret2.put('SAC_Reclamacion__c', reclamacion.Id);
            camposPret2.put('SAC_Redaccion__c', 'Lorem ipsum test redaccion 2');
            camposPret2.put('SAC_RedaccionFinal__c', true);
            camposPret2.put('SAC_SentidoResolucion__c', 'SAC_001');

            Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);

            List<Case> pretensiones = new List<Case>();
            pretensiones.add(pretension);
            pretensiones.add(pretension2);
            SAC_DatabaseDML.insertListDML(pretensiones, false);
            //Database.insert(pretensiones);
        }
    }

    @isTest
    static void caseControllerVF_Test(){
        Case c = [SELECT Id FROM Case WHERE Subject = 'TestRec'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        
        System.runAs(usuario){
            PageReference pageRef = new PageReference('/apex/SAC_DescargaRedaccionPretensiones?id=' + c.Id);
            Test.setCurrentPage(pageRef);
            Test.startTest();
            SAC_CaseControllerVF vf = new SAC_CaseControllerVF();
            String resultado1 = vf.getReclamacion();
            String resultado2 = vf.getPretensiones();
            Test.stopTest();
            system.assertNotEquals(null, resultado1, 'No se ha podido obtener información de la reclamación.');
            system.assertNotEquals(null, resultado2, 'No se ha podido obtener información de las pretensiones hijas.');
        }
    }
}