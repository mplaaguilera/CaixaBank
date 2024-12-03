public with sharing class HDT_LiveAgent_Controller {
    
    @AuraEnabled
    public static String getValues(String chatId) {
        return [SELECT CC_Idioma__c FROM LiveChatTranscript WHERE Id = :chatId].CC_Idioma__c ;
    }
    
    @AuraEnabled(cacheable=true) 
    public static List<CC_FAQ__c> getMensajesChat(String sCodigoMsj, String idioma, List<String> oGlobalIds, String sOrigen, String sAreaChat) {
        return CC_LiveAgent_FAQ_Controller.getMensaje(sCodigoMsj, idioma, oGlobalIds, sOrigen, sAreaChat);
    }
    
    @AuraEnabled
    public static void ActivityNoSoportada(Id recordId, String comentario, String subject, String cognitiveId, String transcriptId) {
        // Crear Tarea
        Date todaysDate = system.today();
        Task task = new Task();
        task.ActivityDate = todaysDate;
        task.Subject = subject;
        task.Type = 'No soportada';
        task.Status = 'Completed';
        task.Description = comentario;
        task.WhatId = recordId;
        task.CC_Chat_Cognitivo_Id__c = cognitiveId;
        task.CC_LiveChatTranscript_Id__c = transcriptId;
        //insert task;
        HDT_Activity.crearActividad(task);
    }
}