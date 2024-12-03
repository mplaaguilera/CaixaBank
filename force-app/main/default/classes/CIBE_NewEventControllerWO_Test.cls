/**********************************************************************************************************************************************************************************************
Name:	  CIBE_NewEventControllerWO_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de "CIBE_NewEventControllerWO"
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Historial
------------------------
VERSION     USER_STORY              AUTHOR              DATE            Description
1.0                                 Álvaro y Lucía                      Init version
1.1         US774293                Bea                 12/02/2024      Se añade el test vinculateTasksToTheNewEvent_Test.

**********************************************************************************************************************************************************************************************/

@IsTest
public with sharing class CIBE_NewEventControllerWO_Test {


    @TestSetup
    static void makeData(){
        CIBE_TestInitialSetup.setupInitialDataEMP();
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];

        System.runAs(usrSetup) {
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account acc = new Account(
                Name = 'Name',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '123',
                AV_Negocio__c = 'CIB',
                OwnerId = usuario.Id
            );
            insert acc;
            CIBE_TestHelper.createEvent(usuario, System.now(), acc);

            String externalId = String.valueof((Math.random() * 10000000));
            AV_HeaderCustomActivity__c acthead = new AV_HeaderCustomActivity__c(
                AV_ExternalID__c = externalId,
                AV_ToDelete__c = false,
                OwnerId = usuario.Id
            );
            insert acthead;
            
            RecordType rtTask = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT);
            Task task  = new Task();
            task.Subject = 'Llamada Saliente';
            task.OwnerId =usuario.Id;
            task.Status = 'Open';
            task.Priority = 'Normal';
            task.RecordTypeId = rtTask.Id;
            task.WhatId = acc.Id;
            task.AV_Task__c = acthead.Id;
            insert task;
            CIBE_TestHelper.createEvent(usuario, System.now(), acc);
            Event ev1 = CIBE_TestHelper.createEvent(usuario, System.now(), acc);
                ev1.Subject = 'Prueba';
            update ev1;

        }    
    }

    @isTest
    static void vinculateOpposToTheNewEventTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Event evtCreated = [SELECT Id,AV_Task__c FROM Event WHERE Subject = 'Call' LIMIT 1];
            String response = CIBE_NewEventControllerWO.vinculateOpposToTheNewEvent( new List<AV_CustomActivityOpportunity__c>{
                new AV_CustomActivityOpportunity__c()
            },evtCreated.Id);

            System.assertEquals('OK', response);
        }
        Test.stopTest();
    }

    @isTest
    static void vinculateTasksToTheNewEventTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Event ev1 = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Prueba'];
            Task task = [SELECT Id, Subject, Status, RecordTypeId, AV_Task__c FROM Task WHERE Subject = 'Llamada Saliente' LIMIT 1];
            List<CIBE_RelaccionadoCita__c> listRC = new List<CIBE_RelaccionadoCita__c>{
                new CIBE_RelaccionadoCita__c(
                    CIBE_CitaRelaccionada__c = ev1.AV_Task__c,
                    CIBE_TareaRelaccionada__c = task.AV_Task__c,
                    CIBE_IsMain__c = false
                )
            };
            String response = CIBE_NewEventControllerWO.vinculateTasksToTheNewEvent(listRC);
            System.assertEquals('OK', response);
        }
        Test.stopTest();
    }


    @isTest
    static void updateOpportunityWOTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            List<Opportunity> oppList = new List<Opportunity>();
            Account acc = [SELECT Id FROM Account WHERE Name = 'Name'];
            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.Name = 'Alerta Comercial Test update 1';
            opp.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_VENCIDO;
            opp.RecordTypeId = rt.Id;
            opp.CloseDate = System.today() + 5;
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial Test update';
            opp.AV_PF__c = prodPF.Id;
            insert opp;
            oppList.add(opp);
            CIBE_NewEventControllerWO.updateOpportunityWO(oppList);
            List<Opportunity> opp1 = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Alerta Comercial Test update 1'];
            System.assertEquals(CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO, opp1[0].StageName);
        }
        Test.stopTest();
    }


    @isTest
    static void updateOpportunityWOTest2(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            List<Opportunity> oppList = new List<Opportunity>();
            Account acc = [SELECT Id FROM Account WHERE Name = 'Name'];
            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.Name = 'Alerta Comercial Test update 2';
            opp.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_VENCIDO;
            opp.RecordTypeId = rt.Id;
            opp.CloseDate = System.today() + 5;
            opp.AV_PF__c = prodPF.Id;
            insert opp;
            oppList.add(opp);
            CIBE_NewEventControllerWO.updateOpportunityWO(oppList);
            List<Opportunity> opp1 = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Alerta Comercial Test update 2'];
            System.assertEquals(CIBE_AppConstants.OPPORTUNITY_STATUS_VENCIDO, opp1[0].StageName);
        }
        Test.stopTest();
    }

}