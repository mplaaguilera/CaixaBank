@isTest
public with sharing class FRA_Llamada_Casos_Controller_Test {
    @testSetup
    public static void testSetup(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User usuario = new User();
            usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'FRA_Usuario_Caixabank'].Id;
            usuario.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'FRA'].Id;
            usuario.FirstName = 'Fraude';
            usuario.LastName = 'Prueba';
            usuario.Alias = uniqueName.substring(18, 23);
            usuario.Email = uniqueName + '@test' + orgId + '.org';
            usuario.Username = uniqueName + '@test' + orgId + '.org';
            usuario.EmailEncodingKey = 'UTF-8';
            usuario.LanguageLocaleKey = 'es';
            usuario.LocaleSidKey = 'es_ES';
            usuario.TimezonesIdKey = 'Europe/Madrid';
            insert usuario;
    
            List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
            for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('FRA_PS_Operador')]) {
                PermissionSetAssignment psAssignment = new PermissionSetAssignment();
                psAssignment.AssigneeId = usuario.Id;
                psAssignment.PermissionSetId = ps.Id;
                psAssignments.add(psAssignment);
            }
            insert psAssignments;
        }
    }
    
    @isTest
    public static void testGetCasos() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario){
            Case caso = new Case();
            caso.Subject = 'Caso de prueba FRA';
            caso.RecordTypeId= CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'Teléfono FRAUDE Banca Internacional';
            caso.Status = 'Activo';
            insert caso;
            
            CC_Llamada__c llamada = new CC_Llamada__c();
            llamada.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'FRA_Cliente');
            llamada.CC_Tipo__c = 'Entrante';
            insert llamada;
    
            Task tarea = new Task();
            tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task');
            tarea.CC_Llamada_Id__c = llamada.Id;
            tarea.WhatId = caso.Id;
            insert tarea;

            Test.startTest();
            List<Case> casos = FRA_Llamada_Casos_Controller.getCasos(llamada.Id);
            System.assertEquals(1, casos.size());
            Test.stopTest();
        }
    }
}