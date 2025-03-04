/*****************************************************************
 * Name: SAC_LCMP_CaseParaContactCenter_Test
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_CaseParaContactCenter
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US213189         Marcela Neira        03/05/21     Creación
 * 1.1            US563153         Jose Carlos Blanco  	18/04/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@istest
public with sharing class SAC_LCMP_CaseParaContactCenter_Test {
    @TestSetup
    static void makeData() {
        
        
        List<User> usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(2);
        usuarios[0].Username = 'usergeneral@test.com';
        usuarios[1].Username = 'usuarioNoPropietario@test.com';
        SAC_DatabaseDML.insertListDML(usuarios, false);
        //Database.insert(usuarios);
       
        
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Caso Reclamación');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('Description', ' ');
        camposRecl.put('OwnerId', usuarios[0].id);
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false);
        //Database.insert(casoReclamacion);

        
        //Reclamacion con ParentId
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'Caso parent Id');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('OwnerId', usuarios[0].id);
        camposRecl2.put('ParentId', casoReclamacion.id);
        
        Case casoConParent = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        SAC_DatabaseDML.insertDML(casoConParent, false);
       //Database.insert(casoConParent);


        //Reclamacion sin ParentId
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'Caso sin parent Id');
        camposRecl3.put('Origin', 'Backoffice');
        camposRecl3.put('OwnerId', usuarios[1].id);
        
        Case casoSinParent = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);
        SAC_DatabaseDML.insertDML(casoSinParent, false);
        //Database.insert(casoSinParent);
    }
    @isTest
    static void crearCasoTest(){

        User usuarioGeneral = [SELECT id From User Where Username = 'usergeneral@test.com' AND isActive = true Limit 1];
        Case casoParaTest = [SELECT id, Status, OwnerId, Origin, RecordTypeId FROM Case WHERE Subject = 'Caso Reclamación'];

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);    
        SAC_DatabaseDML.insertDML(psa, false);   
        //Database.insert(psa);
        

        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_CaseParaContactCenter.crearCase(casoParaTest.id);  
            Test.stopTest();          
        }
		
        String casoParaTest2 = [SELECT id, status FROM Case WHERE id =: casoParaTest.id].Status;        
        system.assertNotEquals(casoParaTest2, casoParaTest.id, 'El estado sigue igual');

    }

    @isTest
    static void noEsPropietarioDelCaso(){
        
        User usuarioGeneral = [SELECT id From User Where Username = 'usuarioNoPropietario@test.com' AND isActive = true Limit 1];
        Case casoParaTest = [SELECT id, Status, OwnerId, RecordTypeId FROM Case WHERE Subject = 'Caso Reclamación'];
        Boolean respuesta;

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);
        SAC_DatabaseDML.insertDML(psa, false);          
        //Database.insert(psa);
        

        System.runAs(usuarioGeneral){
            Test.startTest();
            respuesta =  SAC_LCMP_CaseParaContactCenter.mostrarBoton(usuarioGeneral.id, casoParaTest.id);  
            Test.stopTest();          
        }

        system.assertEquals(true, respuesta, 'No se tiene que mostrar el botón');
    }

    @isTest
    static void siEsPropietarioDelCasoYDerivado(){
        
        User usuarioGeneral = [SELECT id From User Where Username = 'usergeneral@test.com' AND isActive = true Limit 1];
        Case casoParaTest = [SELECT id, Status, OwnerId, RecordTypeId FROM Case WHERE Subject = 'Caso Reclamación'];
        Boolean respuesta;

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);
        SAC_DatabaseDML.insertDML(psa, false);       
        //Database.insert(psa);
        

        System.runAs(usuarioGeneral){
            Test.startTest();
            respuesta =  SAC_LCMP_CaseParaContactCenter.mostrarBoton(usuarioGeneral.id, casoParaTest.id);  
            Test.stopTest();          
        }

        system.assertEquals(true, respuesta, 'No se tiene que mostrar el botón');
    }

    @isTest
    static void siEsPropietarioDelCasoYNoDerivado(){
        
        User usuarioGeneral = [SELECT id From User Where Username = 'usuarioNoPropietario@test.com' AND isActive = true Limit 1];
        Case casoParaTest = [SELECT id, Status, OwnerId, RecordTypeId FROM Case WHERE Subject = 'Caso sin parent Id'];
        Boolean respuesta;

        PermissionSet ps = [select id from PermissionSet where  PermissionSet.Label ='SAC_General'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuarioGeneral.id);
        SAC_DatabaseDML.insertDML(psa, false);       
        //Database.insert(psa);
        

        System.runAs(usuarioGeneral){
            Test.startTest();
            respuesta =  SAC_LCMP_CaseParaContactCenter.mostrarBoton(usuarioGeneral.id, casoParaTest.id);  
            Test.stopTest();          
        }
        system.assertEquals(false, respuesta, 'Si se tiene que mostrar el botón');
    }
}