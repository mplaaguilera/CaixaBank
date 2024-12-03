@isTest
public with sharing class HDT_LiveAgentTransEvent_AI_TRHan_N_Test {
    @isTest static void testLiveAgentTransEventProcessing() {
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Cliente',
            CC_Idioma__c = 'es',
            RecordTypeId = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('HDT_Empleados').getRecordTypeId(),
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

    }  

}