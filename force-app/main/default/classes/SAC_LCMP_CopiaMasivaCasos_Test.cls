@isTest
public with sharing class SAC_LCMP_CopiaMasivaCasos_Test {
    @TestSetup
    static void makeData(){

        //Usuario SAC General
		User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

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
            camposRecl2.put('Status', 'SAC_001');
            camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_001');

            Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

            List<Case> listaReclamaciones = new List<Case>();
            listaReclamaciones.add(reclamacion1);
            listaReclamaciones.add(reclamacion2);
            Database.insert(listaReclamaciones);

            //Pretension 1
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('Status', 'SAC_001');
            camposPret.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposPret.put('SAC_Reclamacion__c', reclamacion1.Id);

            Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            Database.insert(casoPretension);  
        
            //Copias
            //Reclamacion copia 1
            Map<String, Object> camposReclCop1 = new Map<String, Object>();
            camposReclCop1.put('Subject', 'testRecCopia');
            camposReclCop1.put('Origin', 'Otros');
            camposReclCop1.put('Status', 'SAC_001');
            camposReclCop1.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposReclCop1.put('SAC_CasoRelacionado__c', reclamacion1.Id);
            camposReclCop1.put('SAC_FechaRecepcion__c', system.now());

            Case reclamacionCopia1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposReclCop1);

            //Reclamacion copia 2
            Map<String, Object> camposReclCop2 = new Map<String, Object>();
            camposReclCop2.put('Subject', 'testRecCopia2');
            camposReclCop2.put('Origin', 'Otros');
            camposReclCop2.put('Status', 'SAC_001');
            camposReclCop2.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposReclCop2.put('SAC_CasoRelacionado__c', reclamacion2.Id);
            camposReclCop2.put('SAC_FechaRecepcion__c', system.now());

            Case reclamacionCopia2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposReclCop2);

            List<Case> listaReclamacionesCopia = new List<Case>();
            listaReclamacionesCopia.add(reclamacionCopia1);
            listaReclamacionesCopia.add(reclamacionCopia2);
            Database.insert(listaReclamacionesCopia);

            //ContentVersion
            ContentVersion cv = SAC_TestDataFactory.crearContentVersion(reclamacion1);
            Database.insert(cv);
        }
    }

    @isTest
    static void cargarCopiasTest() {
        Id recordTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recordTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        Case caso = [SELECT id FROM Case WHERE Subject = 'testRec1' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_CopiaMasivaCasos.cargarCopias(caso.Id, 5);
            Test.stopTest();
        }

        List<Case> listaCopias = [SELECT Id, SAC_CasoRelacionado__c FROM Case WHERE (RecordTypeId = :recordTypeReclamacion OR recordTypeId = :recordTypePretension)
                                AND SAC_CasoRelacionado__c <> null];

        System.assertNotEquals(null, listaCopias, 'No se han podido insertar las copias');
    }

    @isTest
    static void finalizarProcesoCopiaTest() {
        List<Case> listaCaso = [SELECT id, RecordTypeId, CaseNumber, CC_Detalles_Solucion__c FROM Case WHERE Subject = 'testRec1' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            System.enqueueJob(new SAC_FinalizarProcesoCopia(listaCaso, false));
            Test.stopTest();
        }

        System.assertEquals(null, listaCaso[0].CC_Detalles_Solucion__c, 'No se han podido finalizar el proceso');
    }

    @isTest
    static void comprobarCOPSTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Boolean esCops = false;

        System.runAs(usuario){
            Test.startTest();
            esCops = SAC_LCMP_CopiaMasivaCasos.comprobarCOPS();
            Test.stopTest();
        }

        System.assertEquals(false, esCops, 'No se han podido comprobar si el usuario pertenece a cops');
    }
}