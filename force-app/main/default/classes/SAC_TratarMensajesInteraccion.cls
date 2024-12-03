/***********************************************************************
 * Name: SAC_TratarMensajesInteraccion
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase para operaciones con Interaccion
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219270         Esteve Llaó    02/07/2021   Creación
*************************************************************************/
public without sharing class SAC_TratarMensajesInteraccion {

    /*********************************************************************
     * Proposito: Procesa los emails para copiar los datos en el campo
     * Pregunta del objeto interaccion.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US219270         Esteve Llaó    02/07/2021   Creación
    *********************************************************************/    
    
    public static void pegarInteraccionMessage(List<EmailMessage> mensajes){
        Map<Id,String> mapaEmail = new Map<Id, String>();
        Map<Id,String> emailSubject = new Map<Id,String>();
               
        for (EmailMessage emailCopy : mensajes) {
            mapaEmail.put(emailCopy.relatedToId,emailCopy.HtmlBody);  
            emailSubject.put(emailCopy.relatedToId, emailCopy.Subject);
        } 

        if(!mapaEmail.isEmpty()){
            List<SAC_Interaccion__c> listaOwners = [SELECT id,OwnerId,SAC_Pregunta__c,SAC_Estado__c, SAC_Titulo__c 
                FROM SAC_Interaccion__c 
                WHERE Id in : mapaEmail.keySet()];

            if(!listaOwners.isEmpty()){
                for (SAC_Interaccion__c interaccion : listaOwners){
                    interaccion.SAC_Estado__c = 'SAC_PendienteRespuesta';
    
                    if (String.isBlank(interaccion.SAC_Titulo__c)) {
                        interaccion.SAC_Titulo__c = emailSubject.get(interaccion.id);
                    }
    
                    if (String.isBlank(interaccion.SAC_Pregunta__c) && mapaEmail.containsKey(interaccion.id) && String.isNotBlank(mapaEmail.get(interaccion.id))) {
                        interaccion.SAC_Pregunta__c = mapaEmail.get(interaccion.id).left(32000).stripHtmlTags();
                    }
                }
                update listaOwners;
            }
            
        }
        
    }  
}