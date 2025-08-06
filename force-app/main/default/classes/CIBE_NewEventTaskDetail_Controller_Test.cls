/**********************************************************************************************************************************************************************************************
Name:	  CIBE_NewEventTaskDetail_Controller_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de "CIBE_NewEventTaskDetail_Controller"
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Historial
------------------------
VERSION     USER_STORY              AUTHOR              DATE            Description
1.0         US774293                Bea                 12/02/2024      Init version
1.1                                 Lucía               31/10/2024      Modify disVinculateTaskTest, makePrincipalTest, create getAccountTaskGCFromEventTest

**********************************************************************************************************************************************************************************************/
@isTest
public with sharing class CIBE_NewEventTaskDetail_Controller_Test {
    @TestSetup
    static void makeData(){
        CIBE_TestInitialSetup.setupInitialDataEMP();

        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];

        System.runAs(usrSetup){ 
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account acc = new Account(
                Name = 'Name',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '123',
                AV_Negocio__c = 'CIB',
                OwnerId = usuario.Id
            );
            insert acc;

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

            CIBE_RelaccionadoCita__c rc = new CIBE_RelaccionadoCita__c();
                rc.CIBE_CitaRelaccionada__c = ev1.AV_Task__c;
                rc.CIBE_TareaRelaccionada__c = task.AV_Task__c;
                rc.CIBE_IsMain__c = false;
            insert rc;
        }    
    }

    @IsTest
    static void getAccountTaskTest(){
        
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Account acc = [SELECT Id FROM Account WHERE Name = 'Name' AND CreatedDate = TODAY];
            List<String> accList = new List<String>{acc.Id};
            List<CIBE_NewEventTaskDetail_Controller.TaskWrapper>  wrap =  CIBE_NewEventTaskDetail_Controller.getAccountTask(accList);
            System.assert(!wrap.isEmpty());

        }
        Test.stopTest();
    }


    @IsTest
    static void geCountRelatedTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Event ev1 = [SELECT Id FROM Event WHERE Subject = 'Prueba' AND OwnerId = :usuario.Id LIMIT 1];
            List<AggregateResult> listAR =  CIBE_NewEventTaskDetail_Controller.geCountRelated(ev1.Id);
            System.assert(!listAR.isEmpty());

        }
        Test.stopTest();
    }


    @IsTest
    static void geTaskFromEventTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario){ 
            Event ev1 = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Prueba' AND OwnerId = :usuario.Id LIMIT 1];
            List<CIBE_NewEventTaskDetail_Controller.TaskWrapper> listTaskWr =  CIBE_NewEventTaskDetail_Controller.geTaskFromEvent(ev1.Id);
            System.assert(!listTaskWr.isEmpty());
        }
        Test.stopTest();
    }



    @IsTest
    static void getAccountTaskGCFromEventTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario){ 
            Event ev1 = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Prueba' AND OwnerId = :usuario.Id LIMIT 1];
            Account acc = [SELECT Id FROM Account WHERE Name = 'Name' AND CreatedDate = TODAY];
            List<String> accList = new List<String>{acc.Id};
            List<CIBE_NewEventTaskDetail_Controller.TaskAccWrapper> listTaskWr =  CIBE_NewEventTaskDetail_Controller.getAccountTaskGCFromEvent(ev1.Id, accList);
            System.assert(!listTaskWr.isEmpty());
        }
        Test.stopTest();
    }


    @IsTest
    static void vinculateTaskTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Event ev1 = [SELECT Id, AV_Task__c, AccountId FROM Event WHERE Subject = 'Prueba' AND OwnerId = :usuario.Id LIMIT 1];
            Task task = [SELECT Id, Status FROM Task WHERE OwnerId = :usuario.Id LIMIT 1];
            CIBE_NewEventTaskDetail_Controller.vinculateTask(ev1.Id, task.Id);
            CIBE_RelaccionadoCita__c rc = [SELECT Id FROM  CIBE_RelaccionadoCita__c LIMIT 1];
            System.assertNotEquals(null, rc);

        }
        Test.stopTest();
    }

    @IsTest
    static void disVinculateTaskTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Event ev1 = [SELECT Id, AV_Task__c, AccountId FROM Event WHERE  Subject = 'Prueba' AND OwnerId = :usuario.Id LIMIT 1];
            AV_HeaderCustomActivity__c acthead = [SELECT Id, AV_ExternalID__c, AV_ToDelete__c, OwnerId FROM AV_HeaderCustomActivity__c WHERE  AV_ToDelete__c = false AND OwnerId = :usuario.Id LIMIT 1];
            Task task = [SELECT Id, Status, AV_Task__c, AccountId FROM Task WHERE OwnerId = :usuario.Id LIMIT 1];
            task.AV_Task__c = acthead.Id;
            update task;

            CIBE_NewEventTaskDetail_Controller.disVinculateTask(ev1.Id, task.Id);
            List <CIBE_RelaccionadoCita__c> rc = [SELECT Id FROM  CIBE_RelaccionadoCita__c  WHERE CIBE_CitaRelaccionada__c = :ev1.AV_Task__c and CIBE_TareaRelaccionada__c = :task.AV_Task__c LIMIT 1];
            System.assert(rc.isEmpty());

        }
        Test.stopTest();
    }

    @IsTest
    static void makePrincipalTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        User usuario2 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];
        Test.startTest();
        System.runAs(usuario2){ 
            Event ev1 = [SELECT Id, AV_Task__c FROM Event WHERE OwnerId = :usuario.Id AND Subject = 'Prueba' LIMIT 1];
            AV_HeaderCustomActivity__c acthead = [SELECT Id, AV_ExternalID__c, AV_ToDelete__c, OwnerId FROM AV_HeaderCustomActivity__c WHERE  AV_ToDelete__c = false AND OwnerId = :usuario.Id LIMIT 1];
            Task task = [SELECT Id, Status FROM Task WHERE OwnerId = :usuario.Id LIMIT 1];
            task.AV_Task__c = acthead.Id;
            update task;
            CIBE_NewEventTaskDetail_Controller.makePrincipal(ev1.Id, task.Id);
            CIBE_RelaccionadoCita__c rc = [SELECT Id,  CIBE_IsMain__c FROM  CIBE_RelaccionadoCita__c WHERE CIBE_CitaRelaccionada__c = :ev1.AV_Task__c and CIBE_TareaRelaccionada__c = :task.AV_Task__c];
            System.assertNotEquals(false, rc.CIBE_IsMain__c);

        }
        Test.stopTest();
    }

    @IsTest
    static void updateCheckedTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Task task = [SELECT Id, Status FROM Task WHERE OwnerId = :usuario.Id LIMIT 1];
            CIBE_NewEventTaskDetail_Controller.updateChecked(task.Id);
            Task task2 = [SELECT Id, Status FROM Task WHERE Id = :task.Id LIMIT 1];
            System.assertEquals('Gestionada positiva', task2.Status);

        }
        Test.stopTest();
    }

    @IsTest
    static void updateCanceledTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Task task = [SELECT Id, Status FROM Task WHERE OwnerId = :usuario.Id LIMIT 1];
            CIBE_NewEventTaskDetail_Controller.updateCanceled(task.Id);
            Task task2 = [SELECT Id, Status FROM Task WHERE Id = :task.Id LIMIT 1];
            System.assertEquals('Gestionada negativa', task2.Status);
            

        }
        Test.stopTest();
    }


    @IsTest
    static void getEventTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Event ev1 = [SELECT Id, AV_Task__c FROM Event WHERE OwnerId = :usuario.Id AND Subject = 'Prueba' LIMIT 1];
            List<Event> evnt = CIBE_NewEventTaskDetail_Controller.getEvent(ev1.Id);
            System.assert(!evnt.isEmpty());
        }
        Test.stopTest();
    }

    @IsTest
    static void insertTaskTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
            List<Task> tarea = new List<Task>();
        Account acc = [SELECT Id FROM Account WHERE Name = 'Name' AND recordType.DeveloperName ='CC_Cliente' LIMIT 1];
        RecordType rtTask = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT);

        System.runAs(usuario){ 

            String externalId = String.valueof((Math.random() * 10000000));
            AV_HeaderCustomActivity__c acthead = new AV_HeaderCustomActivity__c(
                AV_ExternalID__c = externalId,
                AV_ToDelete__c = false,
                OwnerId = usuario.Id
            );
            insert acthead;


            Task task  = new Task();
            task.Subject = 'Llamada Saliente Test Update';
            task.OwnerId =usuario.Id;
            task.Status = 'Open';
            task.Priority = 'Normal';
            task.RecordTypeId = rtTask.Id;
            task.WhatId = acc.Id;
            task.AV_Task__c = acthead.Id;
            task.ActivityDate = System.today() + 7;
            tarea.add(task);
            Test.startTest();
            Event ev1 = [SELECT Id, AV_Task__c FROM Event WHERE OwnerId = :usuario.Id AND Subject = 'Prueba' LIMIT 1];
            CIBE_NewEventTaskDetail_Controller.insertTask(tarea, ev1.Id);
            Test.stopTest();

        }

        Event ev1U = [SELECT Id, AV_Task__c FROM Event WHERE OwnerId = :usuario.Id AND Subject = 'Prueba' LIMIT 1];
        // Task tar = [SELECT Id FROM Task WHERE Subject = :tarea[0].Subject AND RecordTypeId =:rtTask.Id AND WhatId =:acc.Id AND ActivityDate =:tarea[0].ActivityDate];
        // System.assert(tar != null);
        Task tareaU = [SELECT Id, AV_Task__c FROM Task WHERE Subject = 'Llamada Saliente Test Update'LIMIT 1];
        CIBE_RelaccionadoCita__c relacionado = [SELECT Id FROM CIBE_RelaccionadoCita__c WHERE CIBE_CitaRelaccionada__c = :ev1U.AV_Task__c  AND CIBE_TareaRelaccionada__c = :tareaU.AV_Task__c];
        System.assert(relacionado != null);

    }
}