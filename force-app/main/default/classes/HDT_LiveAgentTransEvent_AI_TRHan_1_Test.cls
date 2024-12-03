/**
 * @description       : 
 * @author            : Adrian Mariscal
 * @group             : 
 * @last modified on  : 04-25-2022
 * @last modified by  : Adrian Mariscal
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0                                  Initial Version
 * 2.0   04-25-2022   Adrian Mariscal   Añadido test para las tareas de pausa
**/
@isTest
public class HDT_LiveAgentTransEvent_AI_TRHan_1_Test {
    @TestSetup
    static void makeData(){
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript LiveChatTranscript = new LiveChatTranscript(
            RecordTypeId = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('HDT_Empleados').getRecordTypeId(),
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Cliente',
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            CC_Id_Cognitive__c='testAIEvent',
            CC_NumPerso__c = '10559714',
            CC_NumPerso2__c = '10559714',
            CC_Tipo__c = 'Agente',
            CC_Espacio__c = 'liniaObertaWSLOEP',
            CC_Categoria__c = 'LineaAbiertaLOEP',
            CC_Aplicacion__c = 'LiniaObertaAppP',
            CC_SRId__c = '9-FHVRD'
        );
        insert LiveChatTranscript;

        
    }
    @isTest
    static void testLeaveAgentWithTask(){        
        LiveChatTranscript liveChatTranscript  = [SELECT Id,CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c FROM LiveChatTranscript];
      
        Task task = new Task();
        task.Status = 'Completed';
        task.Priority = 'Normal';
        task.WhatId = liveChatTranscript.CaseId;
        task.OwnerId = liveChatTranscript.OwnerId;
        task.CC_Categoria__c = liveChatTranscript.CC_Categoria__c;
        task.CC_Espacio__c = liveChatTranscript.CC_Espacio__c;
        task.CC_Chat_Cognitivo_Id__c = liveChatTranscript.CC_Id_Cognitive__c;
        task.CC_LiveChatTranscript_Id__c = liveChatTranscript.Id;
        task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
        task.Type = 'Fin';
        task.Subject = 'Chat finalizado por agente';
        
        insert task;

        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'LeaveAgent',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        Test.startTest();
        insert liveChatTranscriptEvent;
        Test.stopTest();
        
        List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin' LIMIT 1];
        System.assertEquals(tasks.size(), 1);
        System.assertEquals(tasks.get(0).Id, task.Id);
    }

    @isTest
    static void testLeaveAgentWithoutTask(){        
        LiveChatTranscript liveChatTranscript  = [SELECT Id,CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c FROM LiveChatTranscript];
        
        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'LeaveAgent',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        Test.startTest();
        insert liveChatTranscriptEvent;
        Test.stopTest();
        
        List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin'];
        System.assertEquals(tasks.size(), 1);
    }

    @isTest
    static void testEndAgentWithTask(){        
        LiveChatTranscript liveChatTranscript  = [SELECT Id,CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c FROM LiveChatTranscript];
      
        Task task = new Task();
        task.Status = 'Completed';
        task.Priority = 'Normal';
        task.WhatId = liveChatTranscript.CaseId;
        task.OwnerId = liveChatTranscript.OwnerId;
        task.CC_Categoria__c = liveChatTranscript.CC_Categoria__c;
        task.CC_Espacio__c = liveChatTranscript.CC_Espacio__c;
        task.CC_Chat_Cognitivo_Id__c = liveChatTranscript.CC_Id_Cognitive__c;
        task.CC_LiveChatTranscript_Id__c = liveChatTranscript.Id;
        task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
        task.Type = 'Fin';
        task.Subject = 'Chat finalizado por agente';
        
        insert task;

        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'EndAgent',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        Test.startTest();
        insert liveChatTranscriptEvent;
        Test.stopTest();
        
        List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin' LIMIT 1];
        System.assertEquals(tasks.size(), 1);
        System.assertEquals(tasks.get(0).Id, task.Id);
    }

    @isTest
    static void testEndAgentWithoutTask(){        
        LiveChatTranscript liveChatTranscript  = [SELECT Id,CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c FROM LiveChatTranscript];
        
        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'EndAgent',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        Test.startTest();
        insert liveChatTranscriptEvent;
        Test.stopTest();
        
        List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin' LIMIT 1];
        System.assertEquals(tasks.size(), 1);
    }

    @isTest
    static void testEndVisitorWithTask(){        
        LiveChatTranscript liveChatTranscript  = [SELECT Id,CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c FROM LiveChatTranscript];
      
        Task task = new Task();
        task.Status = 'Completed';
        task.Priority = 'Normal';
        task.WhatId = liveChatTranscript.CaseId;
        task.OwnerId = liveChatTranscript.OwnerId;
        task.CC_Categoria__c = liveChatTranscript.CC_Categoria__c;
        task.CC_Espacio__c = liveChatTranscript.CC_Espacio__c;
        task.CC_Chat_Cognitivo_Id__c = liveChatTranscript.CC_Id_Cognitive__c;
        task.CC_LiveChatTranscript_Id__c = liveChatTranscript.Id;
        task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
        task.Type = 'Fin';  
        task.Subject = 'Chat finalizado por empleado';
        
        insert task;

        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'EndVisitor',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        Test.startTest();
        insert liveChatTranscriptEvent;
        Test.stopTest();
        
        List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin' LIMIT 1];
        System.assertEquals(tasks.size(), 1);
        System.assertEquals(tasks.get(0).Id, task.Id);
    }

    @isTest
    static void testEndVisitorWithoutTask(){        
        LiveChatTranscript liveChatTranscript  = [SELECT Id,CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c FROM LiveChatTranscript];
        
        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'EndVisitor',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        Test.startTest();
        insert liveChatTranscriptEvent;
        Test.stopTest();
        
        List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin'];
        System.assertEquals(tasks.size(), 1);
    }

    @isTest
    static void testLeaveVisitorTask(){        
        LiveChatTranscript liveChatTranscript  = [SELECT Id,CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c FROM LiveChatTranscript];
      
        Task task = new Task();
        task.Status = 'Completed';
        task.Priority = 'Normal';
        task.WhatId = liveChatTranscript.CaseId;
        task.OwnerId = liveChatTranscript.OwnerId;
        task.CC_Categoria__c = liveChatTranscript.CC_Categoria__c;
        task.CC_Espacio__c = liveChatTranscript.CC_Espacio__c;
        task.CC_Chat_Cognitivo_Id__c = liveChatTranscript.CC_Id_Cognitive__c;
        task.CC_LiveChatTranscript_Id__c = liveChatTranscript.Id;
        task.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
        task.Type = 'Fin';   
        task.Subject = 'Chat finalizado por empleado';
        
        insert task;

        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'LeaveVisitor',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        Test.startTest();
        insert liveChatTranscriptEvent;
        Test.stopTest();
        
        List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin' LIMIT 1];
        System.assertEquals(tasks.size(), 1);
        System.assertEquals(tasks.get(0).Id, task.Id);
    }

    @isTest
    static void testLeaveVisitorWithoutTask(){        
        LiveChatTranscript liveChatTranscript  = [SELECT Id,CaseId,OwnerId,CC_Categoria__c,CC_Espacio__c,CC_Id_Cognitive__c FROM LiveChatTranscript];
        
        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'LeaveVisitor',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        Test.startTest();
        insert liveChatTranscriptEvent;
        Test.stopTest();
        
        List<Task> tasks = [SELECT Id FROM Task WHERE CC_LiveChatTranscript_Id__c =: liveChatTranscript.Id AND Type =: 'Fin'];
        System.assertEquals(tasks.size(), 1);
    }

    @isTest
    static void testPauseTaskLeaveAgent(){
        LiveChatTranscript liveChatTranscript = [SELECT Id,CaseId FROM LiveChatTranscript];
        Case caso = new Case();
        insert caso;

        Id taskId = HDT_LiveAgent_BotonesController.CreateActivityPausa(caso.Id,'testAIEvent',liveChatTranscript.id,23);

        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'LeaveAgent',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        insert liveChatTranscriptEvent;
        
        Task taskAssert = [SELECT Status FROM Task WHERE Id = :taskId];
        System.assertEquals('Completed', taskAssert.Status);
    }

    @isTest
    static void testPauseTaskEndAgent(){
        LiveChatTranscript liveChatTranscript = [SELECT Id,CaseId FROM LiveChatTranscript];
        Case caso = new Case();
        insert caso;
        
        Id taskId = HDT_LiveAgent_BotonesController.CreateActivityPausa(caso.Id,'testAIEvent',liveChatTranscript.id,23);

        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'EndAgent',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        insert liveChatTranscriptEvent;
        
        Task taskAssert = [SELECT Status FROM Task WHERE Id = :taskId];
        System.assertEquals('Completed', taskAssert.Status);
    }

    @isTest
    static void testPauseTaskEndVisitor(){
        LiveChatTranscript liveChatTranscript = [SELECT Id,CaseId FROM LiveChatTranscript];
        Case caso = new Case();
        insert caso;
        
        Id taskId = HDT_LiveAgent_BotonesController.CreateActivityPausa(caso.Id,'testAIEvent',liveChatTranscript.id,23);

        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'EndVisitor',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        insert liveChatTranscriptEvent;
        
        Task taskAssert = [SELECT Status FROM Task WHERE Id = :taskId];
        System.assertEquals('Completed', taskAssert.Status);
    }

    @isTest
    static void testPauseTaskLeaveVisitor(){
        LiveChatTranscript liveChatTranscript = [SELECT Id,CaseId FROM LiveChatTranscript];
        Case caso = new Case();
        insert caso;
        
        Id taskId = HDT_LiveAgent_BotonesController.CreateActivityPausa(caso.Id,'testAIEvent',liveChatTranscript.id,23);

        LiveChatTranscriptEvent liveChatTranscriptEvent = new LiveChatTranscriptEvent(
            Type = 'LeaveVisitor',
            LiveChatTranscriptId = liveChatTranscript.Id,
            time = system.now()
        );
        insert liveChatTranscriptEvent;
        
        Task taskAssert = [SELECT Status FROM Task WHERE Id = :taskId];
        System.assertEquals('Completed', taskAssert.Status);
    }
}