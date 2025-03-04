/*****************************************************************
 * Name: SAC_LCMP_ConsultasTareas_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_ConsultasTareas
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US380275         Marcela Neira        02/06/22     Creación Clase
 * 1.1            US563153         Jose Carlos Blanco  	20/04/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@istest
public with sharing class SAC_LCMP_ConsultasTareas_Test {

    @TestSetup
    static void makeData(){

        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        SAC_DatabaseDML.insertDML(cuenta, false);
        //Database.insert(cuenta);

        User homeOficinas = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        homeOficinas.ProfileId = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank'].Id;
        SAC_DatabaseDML.insertDML(homeOficinas, false);      
        //Database.insert(homeOficinas);
        
        Contact contacto = SAC_TestDataFactory.crearContacto(1,null)[0];
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId(); 
        contacto.AV_UsuarioAsociado__c = homeOficinas.Id;
        SAC_DatabaseDML.insertDML(contacto, false);     
        //Database.insert(contacto);

        SAC_Accion__c tareas = new SAC_Accion__c(
            RecordTypeId = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_OtrasTareas').getRecordTypeId(), 
            SAC_Oficina__c = cuenta.Id);
    }

    @istest
    static void getActionConsultaOfficeTest() {

        User homeOficinas = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(homeOficinas){
            Test.startTest();
            SAC_LCMP_ConsultasTareas.AsuntosWrapper result = SAC_LCMP_ConsultasTareas.getActionConsultaOffice();
            Test.stopTest();    

            System.assertNotEquals(null, result, 'No se han encontrado tareas/Consultas para Usuario home oficinas');
        }       
       
    }
    @istest
    static void getURLHomeOficinasTest(){

        User homeOficinas = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(homeOficinas){
            Test.startTest();
            String result = SAC_LCMP_ConsultasTareas.getURLHomeOficinas();
            Test.stopTest();

            System.assertNotEquals(null, result, 'No ha funcionado el método');
        }
    }  
}