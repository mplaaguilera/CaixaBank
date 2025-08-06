@isTest
public with sharing class CC_WS_Recupera_LogConversacion_Chat_Test {
    @TestSetup
    static void makeData(){
        CBK_IntegrationSetting__c customSetting = new CBK_IntegrationSetting__c();
        customSetting.Name = 'CC_Chat_Contexto_Whatsapp';
        customSetting.NamedCredential__c = 'callout:API_GWT_PRO_CC/tech/gesccc/conversacion/search/{sourceApp}/{sourceConversationId}';
        customSetting.RegistroTrazaIntegracion__c = true;
        insert customSetting;

        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript chatTranscript = new LiveChatTranscript();
        chatTranscript.CC_Tipo__c = 'Chatbot';
        chatTranscript.Status = 'Completed';
        chatTranscript.LiveChatVisitorId = liveChatVisitor.Id;
        insert chatTranscript;

        LiveChatTranscript chatTranscript2 = new LiveChatTranscript();
        chatTranscript2.CC_Tipo__c = 'Agente';
        chatTranscript2.CC_Aplicacion_Origen__c = 'Whatsapp';
        chatTranscript2.CC_Subject__c = 'Test CC_WS_Recupera_LogConversacion_Chat';
        chatTranscript2.Status = 'Completed';
        chatTranscript2.CC_ChatOrigen__c = chatTranscript.Id;
        chatTranscript2.LiveChatVisitorId = liveChatVisitor.Id;
        insert chatTranscript2;
    }
    
    @isTest
    public static void Recupera_LogConversacion_Chat_Test() {
        
        Test.startTest();
        List<LiveChatTranscript> chatTranscript = [SELECT Id FROM LiveChatTranscript WHERE CC_Aplicacion_Origen__c = 'Whatsapp' AND CC_Subject__c = 'Test CC_WS_Recupera_LogConversacion_Chat'];
        if (!chatTranscript.isEmpty()) {
            System.debug('entra a recuperar contexto '+ chatTranscript[0].Id);
            CC_WS_Recupera_LogConversacion_Chat.CC_WS_Recupera_LogConversacion_Chat('NoaWhatsapp', '34625791388_226572751', chatTranscript[0].Id, null);
            System.debug('sale de recuperar contexto');
        }
        Test.stopTest();
        List<LiveChatTranscript> chatLst = [SELECT Id FROM LiveChatTranscript WHERE CC_Nickname__c='53753318' AND CC_Tipo__c='Whatsapp' AND Status='Completed' AND RecordTypeId=:Schema.getGlobalDescribe().get('LiveChatTranscript').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Clientes').getRecordTypeId()];
        System.assertEquals(1, chatLst.size());
    }
}