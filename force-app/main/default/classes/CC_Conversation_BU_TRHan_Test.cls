@isTest
public with sharing class CC_Conversation_BU_TRHan_Test {

    @istest
    static void test() {
        // Crear Caracteristica principal
        User admin = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1];
        System.runAs(admin) {
            // Crear una conversación con un transcript
            unblusuite__Conversation__c conversation = new unblusuite__Conversation__c(
                Name = 'Test Conversation',
                unblusuite__Transcript__c = 'This is a test transcript.',
                CC_Transcript_Result__c = false
            );
            
            // Crear una segunda conversación sin transcript
            unblusuite__Conversation__c conversationWithoutTranscript = new unblusuite__Conversation__c(
                Name = 'Test Conversation Without Transcript',
                CC_Transcript_Result__c = false
            );

            insert conversation;
            insert conversationWithoutTranscript;
            
            // Ejecutar el trigger handler
            Test.startTest();
                conversation.unblusuite__Transcript__c = null;
            	conversation.CC_Transcript_Result__c = true;
                update conversation;
                conversationWithoutTranscript.unblusuite__Transcript__c = 'test transcript'; // Simular que no tiene transcript
                update conversationWithoutTranscript;
            Test.stopTest();

            // Verificar que el campo CC_Transcript_Result__c se actualizó correctamente
            conversation = [SELECT CC_Transcript_Result__c FROM unblusuite__Conversation__c WHERE Id = :conversation.Id];
            System.assertEquals(false, conversation.CC_Transcript_Result__c, 'El campo CC_Transcript_Result__c debería ser false.');
            // Verificar que la segunda conversación no se actualizó
            conversationWithoutTranscript = [SELECT CC_Transcript_Result__c FROM unblusuite__Conversation__c WHERE Id = :conversationWithoutTranscript.Id];
            System.assertEquals(true, conversationWithoutTranscript.CC_Transcript_Result__c, 'El campo CC_Transcript_Result__c debería seguir siendo true.');
        }
    }
}