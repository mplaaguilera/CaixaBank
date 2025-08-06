@isTest
public with sharing class CC_DeleteReadOnly_Batch_Test {
      @TestSetup
    static void makeData(){

       // Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileIdAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        PermissionSet psSupervisor = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS'];
        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];


        List<User> userList = new List<User>();
       /* User usuario1 = new User();
        //usuario1.ProfileId = profileIdAdmin;
        usuario1.ProfileId = profileId;
        usuario1.FirstName = 'Usuario Supervisor';
        usuario1.LastName = 'last211053';
        usuario1.Email = 'aalsdna@kfsb.com';
        usuario1.Username = 'tuser0001@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        usuario1.UserRoleId = rolId.Id;

        userList.add(usuario1);*/
        
        User usuario2 = new User();
        usuario2.ProfileId = profileIdAdmin;
        usuario2.FirstName = 'Usuario Admin';
        usuario2.LastName = 'last211053Admin';
        usuario2.Email = 'aalsdna@kfsb.com';
        usuario2.Username = 'tuser0001@amamama.com' + System.currentTimeMillis();
        usuario2.CompanyName = 'MST';
        usuario2.Title = 'title';
        usuario2.Alias = 'alias';
        usuario2.TimeZoneSidKey = 'Europe/Paris';
        usuario2.EmailEncodingKey = 'UTF-8';
        usuario2.LanguageLocaleKey = 'es';
        usuario2.LocaleSidKey = 'es_ES';
        usuario2.UserRoleId = rolId.Id;
        userList.add(usuario2);
        
        insert userList;
       // insert new PermissionSetAssignment(AssigneeId = usuario1.id, PermissionSetId = psSupervisor.Id);
        insert new PermissionSetAssignment(AssigneeId = usuario2.id, PermissionSetId = psSupervisor.Id);
        
         System.runAs(usuario2){
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();
        Contact contacto = CC_Llamada_Test.crearContacto();
        contacto = [SELECT Account.CC_NumPerso__c FROM Contact WHERE Id = :contacto.Id];
        String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(s1.CC_Codigo__c, '', '', contacto.Account.CC_NumPerso__c);
        Id llamadaId = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamada);
        CC_Llamada__c llamada = CC_Llamada_Test.obtenerLlamada(llamadaId);
		List<Case> caso1 = [SELECT Id, RecordType.DeveloperName FROM case where ContactId = :contacto.Id ];
        Task tarea = crearActividadManual('Llamada entrante', llamada.Id, caso1[0].Id);
         }
        
    }
    @isTest 
    static void testDeleteReadOnlyBatch() {
        User sysAdminUser = [SELECT Id FROM User WHERE LastName LIKE 'last211053Admin' AND IsActive=true LIMIT 1];
        System.runAs(sysAdminUser){
         Test.StartTest();
        List<CC_Llamada__c> llamadaList = [SELECT Id, CC_Tipo_Cierre__c, RecordType.DeveloperName, owner.name FROM CC_Llamada__c];
        List<Case> caso2 = [SELECT Id, status, RecordType.DeveloperName, owner.name FROM case ];
          List<CC_Servicio_Genesys__c> s1 = [SELECT CC_Codigo__c FROM CC_Servicio_Genesys__c];
        List<Contact> contacto = [SELECT id, Account.cc_numperso__c FROM Contact];      
        String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(s1[0].CC_Codigo__c, llamadaList[0].Id, caso2[0].Id, contacto[0].Account.CC_NumPerso__c);
        CC_OpenCTI.finalizarLlamada(jsonLlamada, 'Llamada no atendida');
        CC_DeleteReadOnly_Batch batch = new CC_DeleteReadOnly_Batch();
		Database.executeBatch(batch);
        Test.stopTest();
        llamadaList = [SELECT Id, CC_Tipo_Cierre__c, RecordType.DeveloperName, owner.name FROM CC_Llamada__c];
        assert.areEqual(0, llamadaList.size(), 'El batch hizo todo OK');
        }
            
    }
     public static Task crearActividadManual(String subject, Id llamadaId, Id casoId) {
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
		Task actividad = new Task(
            Subject = subject,
            CC_Llamada_Id__c = llamadaId,
            ActivityDate = System.today(),
            CC_Fecha_Inicio__c = System.now(),
            WhatId = casoId,
            RecordTypeId = taskRecordTypeId,
            Type = 'Llamada entrante',
            CC_validacion_tarea_manual__c = true
        );
        insert actividad;
		return actividad;
    }
}