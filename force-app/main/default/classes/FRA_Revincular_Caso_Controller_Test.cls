@isTest
public with sharing class FRA_Revincular_Caso_Controller_Test {
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
    public static void testgetCaso() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Case caso = new Case();
            caso.Subject = 'CASO INICIAL';
            caso.Status = 'Pendiente Cliente';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c='Teléfono FRAUDE Banca Internacional';
            insert caso;
            Test.startTest();
            Map<String,Object> out = FRA_Revincular_Caso_Controller.getCaso(caso.Id);
            System.assertEquals(5, out.size(), 'Cantidad de outputs');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testEmailMessageTriggerTraslado() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Fraude' LIMIT 1];
        System.runAs(usuario) {
            Case caso1 = new Case();
            caso1.Subject = 'CASO INICIAL';
            caso1.Status = 'Pendiente Cliente';
            caso1.Origin = 'Phone';
            caso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
            caso1.CC_Canal_Procedencia__c='Teléfono FRAUDE Banca Internacional';
            insert caso1;
            
            Task tarea1 = new Task();
            tarea1.WhatId=caso1.Id;
            tarea1.Status='Open';
            tarea1.Type='Solicitud Información';
            tarea1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task');
            insert tarea1;
            Datetime oneMinuteAgo = Datetime.now().addMinutes(-1);
            Test.setCreatedDate(tarea1.Id, oneMinuteAgo);
            
            Case caso2 = new Case();
            caso2.Subject = 'LLAMADA ENTRANTE';
            caso2.Status = 'New';
            caso2.Origin = 'Phone';
            caso2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'FRA_Cliente');
            caso2.CC_Canal_Procedencia__c='Teléfono FRAUDE Banca Internacional';
            insert caso2;
            
            Task tarea2 = new Task();
            tarea2.WhatId=caso2.Id;
            tarea2.Status='Completed';
            tarea2.Type='Solicitud Información';
            tarea2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task');
            insert tarea2;
            Test.setCreatedDate(tarea2.Id, oneMinuteAgo);

            FRA_Revincular_Caso_Controller.mergeCase(caso1.Id,Caso2.Id);
            //Comprobación de resultados
            Case caso = [SELECT Id,CC_Ultima_Interaccion__c,Status,CC_Fecha_Ultima_Interaccion__c,CC_Canal_Procedencia__c
                        FROM Case WHERE Id=:caso1.Id LIMIT 1];
		    Task tarea = [SELECT Id,Status from Task where Id= :tarea1.Id LIMIT 1];
            Test.startTest();
            System.assertEquals('Pendiente Cliente', caso.Status);
            System.assertEquals('Open', tarea.Status);
            Test.stopTest();
        }
	}
}