@isTest
public with sharing class CC_LiveAgent_ControllerTest {
    
    @testSetup
    static void testSetup() {
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        LiveChatVisitor liveChatVisitor2 = new LiveChatVisitor();
        insert liveChatVisitor2;
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
        Case caso2 = new Case();
        caso2.CC_Idioma__c = 'ca';
        caso2.Subject = 'Prueba';
        caso2.CC_Tipo_Cliente__c = 'Cliente';
        caso2.Status = 'Activo';
        caso2.Origin = 'Comentarios Stores';
		caso2.CC_Tipo_Contacto__c = 'Consulta';
        caso2.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso2;
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Bienvenida__c = false, 
            CC_Nickname__c = 'Cliente 1', 
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            CaseId = caso.Id
        );
        insert liveChatTranscript;
        
        LiveChatTranscript liveChatTranscript2 = new LiveChatTranscript(
            CC_Bienvenida__c = false, 
            CC_Nickname__c = 'Cliente 2', 
            CC_Idioma__c = 'ca',
            LiveChatVisitorId = liveChatVisitor2.Id,
            CaseId = caso2.Id
        );
        insert liveChatTranscript2;
    }
    
/*    @isTest
    static void getMotivoNoSoportadaCAT() {
        CC_FAQ__c newNoSopCat = new CC_FAQ__c();
        newNoSopCat.CC_Respuesta_Mensaje_Automatico_ca__c = 'Hola, com estàs?';
        newNoSopCat.CC_Mensaje_Agente_ca__c = '<auto>';
        newNoSopCat.CC_Procedencia_Mensaje_Automatico__c = 'No soportada';
        newNoSopCat.CC_Origen__c = 'App';
        newNoSopCat.CC_Nombre__c = 'No soportada 02';
        newNoSopCat.Name = 'No soportada 02';
        insert newNoSopCat;
        
        List<CC_FAQ__c> pickListValuesList = new List<CC_FAQ__c>();
        String idioma = 'ca';
        String origen = 'App';
        pickListValuesList = CC_LiveAgent_Controller.getMotivoNoSoportada(idioma, origen);
        System.assertEquals(pickListValuesList.size(), 1);
    }
    
    @isTest
    static void getMotivoNoSoportadaES() {     
        CC_FAQ__c newNoSopEs = new CC_FAQ__c();
        newNoSopEs.CC_Respuesta_Mensaje_Automatico_es__c = 'Hola, com estàs?';
        newNoSopEs.CC_Mensaje_Agente_es__c = '<auto>';
        newNoSopEs.CC_Procedencia_Mensaje_Automatico__c = 'No soportada';
        newNoSopEs.CC_Origen__c = 'App';
        newNoSopEs.CC_Nombre__c = 'No Soportada 01';
        newNoSopEs.Name = 'No Soportada 01';
        insert newNoSopEs;       
        
        List<CC_FAQ__c> pickListValuesList = new List<CC_FAQ__c>();
        String idioma = 'es';
        String origen = 'App';
        pickListValuesList = CC_LiveAgent_Controller.getMotivoNoSoportada(idioma, origen);
        System.assertEquals(pickListValuesList.size(), 1);
    }*/
    
    @isTest
    static void getMotivoNoSoportadaES(){     
        CC_FAQ__c newNoSopEs = new CC_FAQ__c();
        newNoSopEs.CC_Respuesta_Mensaje_Automatico_es__c = 'Hola, com estàs?';
        newNoSopEs.CC_Mensaje_Agente_es__c = '<auto>';
        newNoSopEs.CC_Procedencia_Mensaje_Automatico__c = 'No soportada';
        newNoSopEs.CC_Origen__c = 'App';
        newNoSopEs.CC_Nombre__c = 'No Soportada 01';
        newNoSopEs.Name = 'No Soportada 01';
        newNoSopEs.CC_AreaMensaje__c = 'Cliente';
        newNoSopEs.CC_IdiomaMsj__c = 'es';
        insert newNoSopEs;       
        
        List<CC_FAQ__c> pickListValuesList = new List<CC_FAQ__c>();
       	pickListValuesList = CC_LiveAgent_Controller.getMensajesChat('No soportada', 'es', null, 'App', 'Cliente');
        System.assertEquals(pickListValuesList.size(), 1);        
    }

    
    @isTest
    static void ActivityNoSoportada() {
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Prueba';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
        Id recordId = caso.Id;
        String comentario = 'Tarea No Soportada';
        String subject = 'No Soportada';
        String cognitiveId = 'IdCognitive__XXX';
        CC_LiveAgent_Controller.ActivityNoSoportada(recordId, comentario, subject, cognitiveId, null);
        Id taskRecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
      	Task taskTest = [SELECT Id, Description FROM Task WHERE Subject = 'No Soportada' AND RecordTypeId =: taskRecordTypeId];
        System.assertEquals(comentario, taskTest.Description);
    }
    
	@isTest
    static void getValues() {
        String result;
        Id liveChatTranscript = [SELECT Id FROM LiveChatTranscript LIMIT 1].Id; 
        result = CC_LiveAgent_Controller.getValues(liveChatTranscript);
        System.assertNotEquals(result, null);
    }
}