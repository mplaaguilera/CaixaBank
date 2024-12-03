@isTest
public with sharing class CC_AjusteEstadoCasosBatch_Test {
    @TestSetup
    static void makeData(){
        //crear usuarios CC
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Analísta y 2º nivel MVP2'].Id;
        UserRole roleId = [SELECT Id FROM UserRole WHERE Name = 'Contact Center' LIMIT 1];
        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileId;
        usuario1.UserRoleId = roleId.Id;
        usuario1.FirstName = 'Usuario Prueba';
        usuario1.LastName = 'last1';
        usuario1.Email = 'tuser000@amamama.com';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        insert usuario1;

        System.runAs(usuario1){
            Case cs = new Case(
                Origin = 'Email',
                Status = 'Pendiente Cliente',
                CC_Idioma__c = 'es',
                CC_Canal_Respuesta__c = 'Email',
                CC_Grupo_3N__c = 'Grupo 3N',
                CC_Canal_Procedencia__c = 'Formulario web',
                Subject = 'testMetodo',
                RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId()
            );
            insert cs;

            
            cs.CC_Detalles_Solucion__c = 'test';
            update cs;
        
            
            Task t = new Task( Type = 'Solicitud Información'
                            ,Subject = 'Solicitud Información' 
                            ,ActivityDate = System.today() 
                            ,Status = 'Completed' 
                            ,WhatId = cs.Id ,
                            CC_Fecha_Inicio__c = Datetime.now() 
                            ,Priority = 'Normal');
            insert t;
        }
    }

    @isTest
    public static void tstMet() {
        List<Case> lstPrev = [SELECT Id, Status, LastModifiedDate FROM Case WHERE Subject = 'testMetodo' LIMIT 1];
        User usuario1 = [SELECT Id FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        Test.startTest();
        CC_AjusteEstadoCasosBatch myClass = new CC_AjusteEstadoCasosBatch();
        Id batchId = Database.executeBatch(myClass);
        Test.stopTest();

        Case lstPost = [SELECT Id, Status FROM Case WHERE Subject = 'testMetodo' LIMIT 1];
        System.runAs(usuario1){
            System.assertNotEquals(lstPrev[0].Status, lstPost.Status, 'El batch no se ha ejecutado correctamente');
            System.assertEquals(lstPost.Status, 'Activo','El batch no se ha ejecutado correctamente');
        }
    }
}