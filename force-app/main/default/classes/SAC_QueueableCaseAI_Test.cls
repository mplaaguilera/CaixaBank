@isTest
public with sharing class SAC_QueueableCaseAI_Test {
    @TestSetup
    static void makeData(){
        //usuario a usar
        List<User> usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
        Database.insert(usuario);

        //Clasificación rápida   
        Map<String, Object> camposClasR = new Map<String, Object>();
        camposClasR.put('Name', 'CRTest');
        camposClasR.put('SAC_Target__c', 'SAC_Reclamacion');
        camposClasR.put('SEG_Inactiva__c', false);
        camposClasR.put('OS_EstadoCaso__c', 'Rechazado');
        camposClasR.put('SAC_MotivoRechazo__c', 'Spam');
        camposClasR.put('SAC_MotivoDescarte__c', 'SAC_Otros');
        
        SEG_ClasificacionRapida__c clasR = SAC_TestDataFactory.crearClasificacionRapida(camposClasR);
        Database.insert(clasR);
        
        //Reglas de clasificación
        Map<String, Object> camposReglas = new Map<String, Object>();
        camposReglas.put('Name', 'RCTest');
        camposReglas.put('SEG_Inactiva__c', false);
        camposReglas.put('OS_Logica_Multivalor__c', 'OR');
        camposReglas.put('OS_OrdenEjecucion__c', 1);
        camposReglas.put('SEG_ClasificacionRapida__c', clasR.Id);
        
        SEG_Regladeclasificacion__c reglas = SAC_TestDataFactory.crearReglasClasificacion(clasR.Id, camposReglas);
        Database.insert(reglas);

        //Casos
        List<Case> listaCasos = new List<Case>();
        Map<String, Object> mapaCamposCaso = new Map<String, Object>();
        mapaCamposCaso.put('Subject', 'TestRec');
        mapaCamposCaso.put('Origin', 'Email');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('Description', 'TestRec');
        mapaCamposCaso.put('SAC_StatusAuxiliar__c', 'SAC_001');
        mapaCamposCaso.put('SuppliedEmail', 'test07032024931@test1.com.invalid');
        mapaCamposCaso.put('OS_ReglaUtilizada__c', reglas.Id);
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Consulta', mapaCamposCaso);
        listaCasos.add(casoReclamacion);
        Database.insert(listaCasos);
    }

    @isTest
    static void ejecucion() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        List<Case> listaCasos = [SELECT Id, SAC_CasoRelacionado__c, Origin, OS_ReglaUtilizada__c, Status, SuppliedEmail FROM Case WHERE Subject = 'TestRec'];
        Map<Id, Case> mapaDatosCasosActualizar = new Map<Id, Case>();
        List<Case> listaCasosReglaClasif = new List<Case>();
        listaCasosReglaClasif.addAll(listaCasos);

        PermissionSet ps = [SELECT id FROM PermissionSet WHERE PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.id);
        Database.insert(psa);

        Test.startTest();
        System.runAs(usuario) {
            System.enqueueJob(new SAC_QueueableCaseAI(listaCasos, listaCasosReglaClasif, mapaDatosCasosActualizar));
        }
        Test.stopTest();

        List<Case> listaCasosResult = [SELECT Id, SAC_CasoRelacionado__c, Origin, OS_ReglaUtilizada__c, Status FROM Case WHERE Subject = 'TestRec'];

        System.assertEquals('Rechazado', listaCasosResult[0].Status, 'No se han aplicado los cambios');
    }
}