@isTest
public with sharing class CC_Conversation_BI_TRHan_Test {

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
            
            // Ejecutar el trigger handler
            Test.startTest();
                insert conversation;
                insert conversationWithoutTranscript;
            Test.stopTest();

            // Verificar que el campo CC_Transcript_Result__c se actualizó correctamente
            conversation = [SELECT CC_Transcript_Result__c FROM unblusuite__Conversation__c WHERE Id = :conversation.Id];
            System.assertEquals(true, conversation.CC_Transcript_Result__c, 'El campo CC_Transcript_Result__c debería ser true.');

            // Verificar que la segunda conversación no se actualizó
            conversationWithoutTranscript = [SELECT CC_Transcript_Result__c FROM unblusuite__Conversation__c WHERE Id = :conversationWithoutTranscript.Id];
            System.assertEquals(false, conversationWithoutTranscript.CC_Transcript_Result__c, 'El campo CC_Transcript_Result__c debería seguir siendo false.');
        }
    }
}