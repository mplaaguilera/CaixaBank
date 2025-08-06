/**********************************************************************************************************************
 Name:	  CIBE_CustomActivityOppTriggerHelper_Test
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Helper para Trigger de CIBE_CustomActivityOppTriggerHelper 
-----------------------------------------------------------------------------------------------------------------------
Historial
--------------------------------------------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0     	US889424		Lucía	  	        20/06/2024			Init version 

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_CustomActivityOppTriggerHelper_Test {

    @TestSetup
    static void makeData(){
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        
        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);


        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User managerUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];

        System.runAs(usrSetup){
            Contact c = [SELECT Id FROM Contact WHERE CC_Matricula__c = 'U0000001' AND ownerId =: managerUser.id];
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account accTest = new Account(
                    Name = 'Test Name',
                    RecordTypeId = rt.Id,
                    AV_NumPerso__c = '000',
                    AV_Negocio__c = 'EMP'
                );
            insert accTest;

            DateTime activityDate = Date.today();
            RecordType rtEvent = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
            Event event = new Event();
            event.Subject = 'Prueba 001';
            event.WhatId = accTest.Id;
            event.AV_Tipo__c = 'VLD';
            event.OwnerId = managerUser.Id;
            
            
            String externalId = String.valueof((Math.random() * 10000000));
            AV_HeaderCustomActivity__c acthead = new AV_HeaderCustomActivity__c(
                AV_ExternalID__c = externalId,
                AV_ToDelete__c = true,
                OwnerId = managerUser.Id
            );
            insert acthead;
            
            String randomExternalId = String.valueof((Math.random() * 10000000));
            event.AV_ExternalID__c = randomExternalId;
            event.RecordTypeId = rtEvent.Id;
            event.DurationInMinutes= 60;
            event.AV_Task__c=acthead.id;
            event.ActivityDateTime = activityDate;
            event.StartDateTime = activityDate;
            event.EndDateTime = activityDate.addMinutes(60);
            event.CSBD_Evento_Estado__c = CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            event.AV_OrigenApp__c = CIBE_AppConstants.SALESFORCE_ORIGENAPP;
            event.Description = 'Prueba';
            insert event;

            RecordType rtOpp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            Opportunity opp = new Opportunity();
            opp.AccountId = accTest.Id;
            opp.Name = 'Alerta Comercial prueba 001';
            opp.StageName = 'CIBE_Vencido';
            opp.RecordTypeId = rtOpp.Id;
            opp.CloseDate = System.today();
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial 1';
            opp.OwnerId = managerUser.Id;
            opp.AV_Gestor__c = c.Id;
            opp.AV_IncludeInPrioritizingCustomers__c = true;
            opp.AV_PF__c = prodPF.Id;
            opp.CIBE_PriceApprove__c = 'Pendiente aprobación';
            opp.CIBE_ApprovalRisk__c = 'Pendiente aprobación';
            opp.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';


            insert opp;


            RecordType rtTsk = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
            Task tarea  = new Task();
            tarea.Subject = 'Llamada Saliente prueba 001';
            tarea.OwnerId = managerUser.Id;
            tarea.Status = 'Pendiente no localizado';
            tarea.Priority = 'Normal';

            String externalId2 = String.valueof((Math.random() * 10000000));
            AV_HeaderCustomActivity__c acthead2 = new AV_HeaderCustomActivity__c(
                AV_ExternalID__c = externalId2,
                AV_ToDelete__c = true,
                OwnerId = managerUser.Id
            );
            insert acthead2;

            tarea.AV_OrigenApp__c = ' ';
            tarea.AV_ExternalID__c = '01928363';
            tarea.RecordTypeId = rtTsk.Id;
            tarea.ActivityDate = System.today()-1;
            tarea.AV_ToDelete__c = false;
            tarea.AV_Task__c = acthead.id;
            insert tarea;


        }
    }

    @isTest
    static void updateCommentsHistoryVinculatedTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Name'];
        Test.startTest();
        Event evento = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Prueba 001'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial prueba 001'];
        Task tsk = [SELECT Id, AV_Task__c FROM Task WHERE Subject = 'Llamada Saliente prueba 001'];

        AV_CustomActivityOpportunity__c tareaOpp= new AV_CustomActivityOpportunity__c();
        tareaOpp.Name = 'Llamada Saliente - Alerta Comercial Test opp2';
        tareaOpp.AV_Opportunity__c = opp.Id;
        tareaOpp.AV_Task__c = evento.AV_Task__c;
        tareaOpp.OwnerId = usuario.Id;
        insert tareaOpp;

        AV_CustomActivityOpportunity__c tareaOpp2 = new AV_CustomActivityOpportunity__c();
        tareaOpp2.Name = 'Llamada Saliente - Alerta Comercial Test tsk2';
        tareaOpp2.AV_Opportunity__c = opp.Id;
        tareaOpp2.AV_Task__c = tsk.AV_Task__c;
        tareaOpp2.OwnerId = usuario.Id;
        insert tareaOpp2;

        System.runAs(usuario){

            List<AV_CustomActivityOpportunity__c> relacionado = [SELECT Id, AV_Task__c, Name FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :evento.AV_Task__c and AV_Opportunity__c = :opp.Id];
            System.assert(!relacionado.isEmpty());
            List<AV_CommentsHistory__c> commt = [SELECT Id FROM AV_CommentsHistory__c WHERE AV_Event__c = :evento.AV_Task__c AND AV_Opportunity__c = :opp.Id];
            System.assert(!commt.isEmpty());

            List<AV_CustomActivityOpportunity__c> relacionado2 = [SELECT Id, AV_Task__c, Name FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :tsk.AV_Task__c and AV_Opportunity__c = :opp.Id];
            System.assert(!relacionado2.isEmpty());
            List<AV_CommentsHistory__c> commt2 = [SELECT Id FROM AV_CommentsHistory__c WHERE AV_Task__c = :tsk.AV_Task__c AND AV_Opportunity__c = :opp.Id];
            System.assert(!commt2.isEmpty());
        }


        Test.stopTest();
    }
  
    @isTest
    static void deleteCommentsHistoryVinculatedTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Name'];
        Test.startTest();
        Event evento = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Prueba 001'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial prueba 001'];
        Task tsk = [SELECT Id, AV_Task__c FROM Task WHERE Subject = 'Llamada Saliente prueba 001'];

        AV_CustomActivityOpportunity__c tareaOpp= new AV_CustomActivityOpportunity__c();
        tareaOpp.Name = 'Llamada Saliente - Alerta Comercial Test opp2';
        tareaOpp.AV_Opportunity__c = opp.Id;
        tareaOpp.AV_Task__c = evento.AV_Task__c;
        tareaOpp.OwnerId = usuario.Id;
        insert tareaOpp;

        AV_CustomActivityOpportunity__c tareaOpp2 = new AV_CustomActivityOpportunity__c();
        tareaOpp2.Name = 'Llamada Saliente - Alerta Comercial Test tsk2';
        tareaOpp2.AV_Opportunity__c = opp.Id;
        tareaOpp2.AV_Task__c = tsk.AV_Task__c;
        tareaOpp2.OwnerId = usuario.Id;
        insert tareaOpp2;

        System.runAs(usuario){

            List<AV_CustomActivityOpportunity__c> relacionado = [SELECT Id, AV_Task__c, Name FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :evento.AV_Task__c and AV_Opportunity__c = :opp.Id];
            System.assert(!relacionado.isEmpty());
            List<AV_CommentsHistory__c> commt = [SELECT Id FROM AV_CommentsHistory__c WHERE AV_Event__c = :evento.AV_Task__c AND AV_Opportunity__c = :opp.Id];
            System.assert(!commt.isEmpty());
            delete relacionado;

            List<AV_CustomActivityOpportunity__c> relacionado2 = [SELECT Id, AV_Task__c, Name FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :evento.AV_Task__c and AV_Opportunity__c = :opp.Id];
            System.assert(relacionado2.isEmpty());
            List<AV_CommentsHistory__c> commt2 = [SELECT Id FROM AV_CommentsHistory__c WHERE AV_Event__c = :evento.AV_Task__c AND AV_Opportunity__c = :opp.Id];
            System.assert(commt2.isEmpty());



            List<AV_CustomActivityOpportunity__c> relacionadoTsk = [SELECT Id, AV_Task__c, Name FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :tsk.AV_Task__c and AV_Opportunity__c = :opp.Id];
            System.assert(!relacionadoTsk.isEmpty());
            List<AV_CommentsHistory__c> commtTsk = [SELECT Id FROM AV_CommentsHistory__c WHERE AV_Task__c = :tsk.AV_Task__c AND AV_Opportunity__c = :opp.Id];
            System.assert(!commtTsk.isEmpty());
            delete relacionadoTsk;

            List<AV_CustomActivityOpportunity__c> relacionadoTsk2 = [SELECT Id, AV_Task__c, Name FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :tsk.AV_Task__c and AV_Opportunity__c = :opp.Id];
            System.assert(relacionadoTsk2.isEmpty());
            List<AV_CommentsHistory__c> commtTsk2= [SELECT Id FROM AV_CommentsHistory__c WHERE AV_Task__c = :tsk.AV_Task__c AND AV_Opportunity__c = :opp.Id];
            System.assert(commtTsk2.isEmpty());
        }


        Test.stopTest();
    }
  

    @isTest
    static void deleteCommentsHistoryVinculatedTest2(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Name'];
        Event evento = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Prueba 001'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial prueba 001'];

        AV_CustomActivityOpportunity__c tareaOpp= new AV_CustomActivityOpportunity__c();
            tareaOpp.Name = 'Llamada Saliente - Alerta Comercial Test opp2';
            tareaOpp.AV_Opportunity__c = opp.Id;
            tareaOpp.AV_Task__c = evento.AV_Task__c;
            tareaOpp.OwnerId = usuario.Id;
        insert tareaOpp;

        System.runAs(usuario){
            List<AV_CustomActivityOpportunity__c> relacionado = [SELECT Id, AV_Task__c, Name FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :evento.AV_Task__c and AV_Opportunity__c = :opp.Id];
            System.assert(!relacionado.isEmpty());
            List<AV_CommentsHistory__c> commt = [SELECT Id FROM AV_CommentsHistory__c WHERE AV_Event__c = :evento.AV_Task__c AND AV_Opportunity__c = :opp.Id];
            System.assert(!commt.isEmpty());
            commt[0].OwnerId = usrSetup.Id;
            update commt;
            delete relacionado;

            List<AV_CustomActivityOpportunity__c> relacionado2 = [SELECT Id, AV_Task__c, Name FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :evento.AV_Task__c and AV_Opportunity__c = :opp.Id];
            System.assert(relacionado2.isEmpty());
            List<AV_CommentsHistory__c> commt2 = [SELECT Id FROM AV_CommentsHistory__c WHERE AV_Event__c = :evento.AV_Task__c AND AV_Opportunity__c = :opp.Id];
            System.assert(commt2.isEmpty());
        }

        Test.stopTest();
    }
  
}