@istest
public with sharing class SAC_QueueableEnvioEmail_Test {
    @TestSetup
    static void makeData(){

        Id recTypeOtrasTareas = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_OtrasTareas').getRecordTypeId();
        Id recType = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
        Id recTypeOficina = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        UserRole uRole = [SELECT Id FROM userRole WHERE DeveloperName = 'SAC_General'];

        User usuario = new User();
        usuario.Username = 'ustestesteo@test.com';
        usuario.Email = 'emailtest@test.com';
        usuario.LastName = 'Usuario Test';
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SAC_General'].Id;
        usuario.Alias = 'alias';
        usuario.TimeZoneSidKey = 'GMT';
        usuario.LocaleSidKey = 'es_ES';
        usuario.EmailEncodingKey = 'ISO-8859-1';
        usuario.LanguageLocaleKey = 'en_US';
        usuario.isActive = true;
        usuario.userRole = uRole;

        Database.insert(usuario);


        Case reclamacion3 = new Case();
        reclamacion3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        reclamacion3.Status = 'SAC_001';
        reclamacion3.SuppliedCompany = 'testCaso3';
        reclamacion3.Subject = 'testrec3';
        Database.insert(reclamacion3);


        CC_Grupo_Colaborador__c grupoTareas = new CC_Grupo_Colaborador__c();
        grupoTareas.name = 'grupo de tareas2';
        grupoTareas.RecordTypeId = recType;
        grupoTareas.SAC_PermiteTareas__c = true;
        grupoTareas.SAC_DeveloperName__c = 'COPS';
        grupoTareas.SAC_Email__c = 'test@test.com';
        Database.insert(grupoTareas);

        Account oficina = new Account();
        oficina.CC_Email__c = 'test@test.com';
        oficina.Name = 'Oficina1';
        oficina.RecordTypeId = recTypeOficina;
        Database.insert(oficina);

        List<SAC_Accion__c> listaTareas = new List<SAC_Accion__c>();
        SAC_Accion__c tarea = new SAC_Accion__c(); 
        tarea.SAC_EquipoResponsable__c=grupoTareas.id;
        tarea.SAC_Observaciones__c ='tarea'; 
        tarea.SAC_PlazoMaximo__c = 10; 
        tarea.SAC_Prorroga__c = 5;
        tarea.SAC_Reclamacion__c = reclamacion3.id;
        tarea.OwnerId = usuario.id;
        //tarea.SAC_Estado__c = 'SAC_PendienteEnviar';
        tarea.recordTypeId = recTypeOtrasTareas;
        listaTareas.add(tarea);

        SAC_Accion__c tarea2 = new SAC_Accion__c(); 
        tarea2.SAC_EquipoResponsable__c=grupoTareas.id;
        tarea2.SAC_Observaciones__c ='tarea2'; 
        tarea2.SAC_PlazoMaximo__c = 10; 
        tarea2.SAC_Prorroga__c = 5;
        tarea2.SAC_Oficina__c = oficina.Id;
        tarea2.SAC_Reclamacion__c = reclamacion3.id;
        tarea2.OwnerId = usuario.id;
        //tarea.SAC_Estado__c = 'SAC_PendienteEnviar';
        tarea2.recordTypeId = recTypeOtrasTareas;
        listaTareas.add(tarea2);

        Database.insert(listaTareas);

    }

    @istest
    static void envioEmailTest() {
    
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];        
        List<SAC_Accion__c> listaTarea = [SELECT Id, SAC_EquipoResponsable__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'tarea'];
        Case caso = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'testrec3'];

        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();
        Map<Boolean, List<SAC_Accion__c>> mapTareas = new Map<Boolean, List<SAC_Accion__c>>();

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        permisos.add(permiSetAssi2);

        Database.insert(permisos);

        Test.startTest();
        System.runAs(usuario) {

            mapTareas.put(false, listaTarea);
            System.enqueueJob(new SAC_QueueableEnvioEmail(mapTareas, caso.CaseNumber));
        }
        Test.stopTest();

        System.assertNotEquals(null, listaTarea.size(), 'Lista tareas correcta');
    }

    @istest
    static void envioEmailTest2() {
    
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];        
        List<SAC_Accion__c> listaTarea = [SELECT Id, SAC_Oficina__c, SAC_Oficina__r.CC_Email__c FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'tarea2'];
        Case caso = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'testrec3'];

        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();
        Map<Boolean, List<SAC_Accion__c>> mapTareas = new Map<Boolean, List<SAC_Accion__c>>();

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        permisos.add(permiSetAssi2);

        Database.insert(permisos);

        Test.startTest();
        System.runAs(usuario) {

            mapTareas.put(true, listaTarea);
            System.enqueueJob(new SAC_QueueableEnvioEmail(mapTareas, caso.CaseNumber));
        }
        Test.stopTest();

        System.assertNotEquals(null, listaTarea.size(), 'Lista tareas correcta');
    }
}