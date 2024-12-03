public without sharing class SAC_LCMP_ListadoEmailsConsulta {
    @AuraEnabled(cacheable=true)
        public static List<EmailMessage> getEmailsConsulta(Id recordId) {
            /*SAC_Interaccion__c interaccion = [SELECT Id,SAC_Reclamacion__c,SAC_IndexedThreadId__c 
                                                FROM SAC_Interaccion__c 
                                                WHERE Id =: recordId LIMIT 1];
*/
            return [SELECT Id, Subject ,relatedToId, CreatedDate, FromAddress, ToAddress
                                            FROM EmailMessage
                                            WHERE relatedToId =: recordId Order By CreatedDate DESC];

            /*String threadId;
            List<EmailMessage> mensajesRelacionados = new List<EmailMessage>();

            if (!mensajes.isEmpty()){
                for (EmailMessage mensaje : mensajes) {
                    if (String.isNotBlank(mensaje.HtmlBody)) {
                        threadId = mensaje.HtmlBody.substringAfter('ref:_').substringBefore(':ref');
                        threadId = ('ref:_' + threadId + ':ref');
                        
                        system.debug('Thread del mensaje'+threadId);
                        system.debug('Thread de la consulta'+interaccion.SAC_IndexedThreadId__c);
                        if(threadId == interaccion.SAC_IndexedThreadId__c){
                            mensajesRelacionados.add(mensaje);
                        }
                    }
                }
            }
        /*    List<EmailMessage> debug = [SELECT Id, Subject ,relatedToId, CreatedDate, FromAddress, HtmlBody FROM EmailMessage WHERE Id in: mensajesRelacionados];
            system.debug('lista email message ' + debug.size());

            for(EmailMessage em : debug){
                system.debug('id ' + em.Id);
                system.debug('asunto ' + em.Subject);
                system.debug('desde ' + em.FromAddress);
                system.debug('related ' + em.relatedToId);
                system.debug('fecha ' + em.CreatedDate);
                system.debug('cuerpo ' + em.HtmlBody);
            }*/
           // return [SELECT Id, Subject ,relatedToId, CreatedDate, FromAddress FROM EmailMessage WHERE Id in: mensajesRelacionados Order By CreatedDate DESC];
        }
 }