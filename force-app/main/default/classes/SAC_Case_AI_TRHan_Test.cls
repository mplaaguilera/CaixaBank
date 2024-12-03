/*****************************************************************
 * Name: SAC_Case_AI_TRHan_Test
 * Copyright © 2019  CaixaBank
 *
 * Propósito: Testear la clase SAC_Case_AI_TRHan
 *
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US498472         Jose Carlos Blanco   10/01/23     Creación
 * 1.1            US563153         Jose Carlos Blanco   08/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@isTest
public with sharing class SAC_Case_AI_TRHan_Test {
    @TestSetup
    static void makeData(){
        
        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
        Database.insert(cuenta);

        //Test.startTest();

        List<Case> listaRecOrigenEmail = SAC_TestDataFactory.crearReclamacion(1);
        listaRecOrigenEmail[0].Subject = 'TestRec';
        listaRecOrigenEmail[0].Origin = 'Email';
        listaRecOrigenEmail[0].SlaStartDate = system.today();
        listaRecOrigenEmail[0].SAC_FechaRecepcion__c = system.today();
        listaRecOrigenEmail[0].AccountId = cuenta.Id;
        Database.insert(listaRecOrigenEmail);
        
        List<Case> listaConsultas = SAC_TestDataFactory.crearConsulta(1);
        listaConsultas[0].SlaStartDate = system.today();
        listaConsultas[0].SAC_FechaRecepcion__c = system.today();
        listaConsultas[0].AccountId = cuenta.Id;
        Database.insert(listaConsultas);

        List<Case> listaPretensiones = SAC_TestDataFactory.crearPretension(1,listaRecOrigenEmail[0].id);
        listaPretensiones[0].SAC_FechaRecepcion__c = system.today();
        Database.insert(listaPretensiones);

        List<User> usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
        usuarioGeneral[0].Username = 'ustestesteo@test.com';       
        Database.insert(usuarioGeneral);

        //Test.stopTest();

    }
    @isTest
    static void crearThreadId() {  
        List<Case> listaRecOrigenEmail = [SELECT Id, RecordTypeId FROM Case WHERE Origin = 'Email'];
        Map<ID, Case> mapaCasos = new Map<ID, Case>([SELECT id, RecordTypeId FROM Case WHERE Subject = 'TestRec']);    

        
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        PermissionSet ps = [select id from PermissionSet where PermissionSet.Label ='SAC_General'];
        List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSetId = :ps.Id AND AssigneeId =: usuario.Id];
        if(psas.isEmpty()){
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = usuario.Id);
            Database.insert(psa);
        }

        System.RunAs(usuario){   
            Test.startTest();
            List<Case> listaRecOrigenEmail2 = SAC_TestDataFactory.crearReclamacion(1);
            listaRecOrigenEmail2[0].Subject = 'TestRec2';
            listaRecOrigenEmail2[0].Origin = 'Email';
            listaRecOrigenEmail2[0].SlaStartDate = system.today();
            listaRecOrigenEmail2[0].SAC_FechaRecepcion__c = system.today();
            Database.insert(listaRecOrigenEmail2);
            Test.stopTest();
        }

        List<Case> listaResult = [SELECT Status FROM Case WHERE Subject = 'TestRec2'];

        system.assertEquals('SAC_001', listaResult[0].Status, 'No se ha podido insertar el caso');
    }  
}