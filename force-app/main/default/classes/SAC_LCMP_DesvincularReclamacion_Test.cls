/*****************************************************************
 * Name: SAC_LCMP_DesvincularReclamacion_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_DesvincularReclamacion
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US233793         Carlos Solis   16/06/21     Creación
 * 1.1            US563153         Carlos Gómez   26/04/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_DesvincularReclamacion_Test {
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


        List<Case> listaReclamaciones = new List<Case>();
        List<Case> listaPretConsultas = new List<Case>();

        System.runAs(usuarioGeneral){

            //Reclamacion 1
            Map<String, Object> camposRecl1 = new Map<String, Object>();
            camposRecl1.put('Subject', 'testRec');
            camposRecl1.put('Origin', 'Backoffice');
            camposRecl1.put('Status', 'SAC_005');
            camposRecl1.put('SAC_StatusAuxiliar__c', 'SAC_005');
            
            Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl1);
            listaReclamaciones.add(casoReclamacion);

            //Reclamacion 2
            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject', 'testRec2');
            camposRecl2.put('Origin', 'Backoffice');
            camposRecl2.put('Status', 'SAC_005');
            camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_005');
            camposRecl2.put('CC_CasoRelacionado__c', casoReclamacion.Id);

            Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
            listaReclamaciones.add(casoReclamacion2);

            Map<String, Object> camposReclVinc = new Map<String, Object>();
            camposReclVinc.clear();
            camposReclVinc.put('Subject', 'ComplementariaVinculada');
            camposReclVinc.put('Origin', 'Otros');
            camposReclVinc.put('Status', 'SAC_003');
            camposReclVinc.put('SAC_TipoConsumidor__c', 'No');
            camposReclVinc.put('SAC_Naturaleza__c', 'SAC_007');
            camposReclVinc.put('CC_Importe_Abonado__c', 5.0);
            camposReclVinc.put('OwnerId', usuarioGeneral.id);
            Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion', camposReclVinc);
            listaReclamaciones.add(casoReclamacion3);

            SAC_DatabaseDML.insertListDML(listaReclamaciones, false); 
            //Database.insert(listaReclamaciones);

            //Pretension
            Map<String, Object> camposPret = new Map<String, Object>();
            camposPret.put('Subject', 'TestPret');
            camposPret.put('Origin', 'Backoffice');
            camposPret.put('Status', 'SAC_005');
            camposPret.put('SAC_StatusAuxiliar__c', 'SAC_005');
            camposPret.put('SAC_Reclamacion__c', casoReclamacion2.Id);

            Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
            listaPretConsultas.add(casoPretension);

            Map<String, Object> camposConsulta = new Map<String, Object>();
            camposConsulta.put('Subject', 'Consulta');
            camposConsulta.put('Origin', 'Backoffice');
            camposConsulta.put('SAC_Reclamacion__c', casoReclamacion.Id);
            
            Case consulta = SAC_TestDataFactory.crearCaso('Consulta',camposConsulta);
            listaPretConsultas.add(consulta);

            SAC_DatabaseDML.insertListDML(listaPretConsultas, false); 
            //Database.insert(listaPretConsultas);


            //Id recTypeTareas = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
            //CC_Grupo_Colaborador__c cops = new CC_Grupo_Colaborador__c(Name = 'DXC', SAC_DeveloperName__c ='DXC Zaragoza', RecordTypeId = recTypeTareas);
            //Database.insert(cops);
        }
    }
 
    @isTest
    static void validarDesvincularComplementariaTest(){
        Test.startTest(); 
        Case complementaria = [SELECT Id FROM Case WHERE subject = 'ComplementariaVinculada'];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario){        
            Boolean testResultado = SAC_LCMP_DesvincularReclamacion.validarDesvincularComplementaria(complementaria.Id);  
            Assert.areEqual(true, testResultado, 'No se ha realizado la comprobación correctamente.');
        }
        Test.stopTest();
    }


    @isTest
    static void reclamacionesVinculadasTest() {
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case caso = [SELECT id, CaseNumber, Subject, CreatedDate, Priority, RecordTypeId, CC_CasoRelacionado__c FROM Case WHERE Subject ='TestRec2'];
        List<Case> casosRelacionados = new List<Case>();

        System.runAs(usuarioGeneral){
            Test.startTest();
            casosRelacionados = SAC_LCMP_DesvincularReclamacion.reclamacionesVinculadas(caso.Id);
            Test.stopTest();
        }
        System.assertNotEquals(null, casosRelacionados, 'No se han encontrado casos relacionados');
    }

    @isTest
    static void desvincularReclamacion() {
        Case caso = [SELECT id, CaseNumber, Subject, CreatedDate, Priority, RecordTypeId, CC_CasoRelacionado__c FROM Case WHERE Subject ='TestRec2'];
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_DesvincularReclamacion.desvincularReclamacion(caso.Id);
            Test.stopTest();
        }   
        caso = [SELECT id, CaseNumber, Subject, CreatedDate, Priority, RecordTypeId, CC_CasoRelacionado__c FROM Case WHERE Subject ='TestRec2'];
        System.assertEquals(null, CASO.CC_CasoRelacionado__c, 'No se ha podido desvincular la reclamación');
    }

    @isTest
    static void consultasVinculadasTest() {
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case caso = [SELECT id, CaseNumber, Subject, CreatedDate, Priority, RecordTypeId, CC_CasoRelacionado__c FROM Case WHERE Subject ='Consulta'];
        List<Case> casosRelacionados = new List<Case>();
        System.runAs(usuarioGeneral){
            Test.startTest();
            casosRelacionados = SAC_LCMP_DesvincularReclamacion.consultasVinculadas(caso.Id);
            Test.stopTest();
        }
        System.assertNotEquals(null, casosRelacionados, 'No se han encontrado casos relacionados');
    }

    @isTest
    static void desvincularConsulta() {
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case caso = [SELECT id, CaseNumber, Subject, CreatedDate, Priority, RecordTypeId, CC_CasoRelacionado__c FROM Case WHERE Subject ='Consulta'];

        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_DesvincularReclamacion.desvincularConsulta(caso.Id);
            Test.stopTest();
        }
        caso = [SELECT id, CaseNumber, Subject, CreatedDate, Priority, RecordTypeId, CC_CasoRelacionado__c FROM Case WHERE Subject ='Consulta'];
        System.assertEquals(null, CASO.CC_CasoRelacionado__c, 'No se ha podido desvincular la consulta');
    }
}