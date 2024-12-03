public with sharing class OS_CorreosElectronicos_Controller {
    
    @AuraEnabled(cacheable = true)
    public static List<CorreoElectronico> recuperarCampos (Id caseId, String campo, String orden){
        
        switch on campo {
            when 'nameUrl' {
                campo = 'Subject';
            }
            when 'de' {
                campo = 'FromAddress';
            }
            when 'para' {
                campo = 'ToAddress';
            }
            when 'fecha' {
                campo = 'MessageDate';
            }
            when 'estado' {
                campo = 'Status';
            }
            when 'HasAttachment' {
                campo = 'HasAttachment';
            }
                       
        }
        List<EmailMessage> correosElectronicos = new List<EmailMessage>();
        List<EmailMessage> listaCorreos = new List<EmailMessage>();
        Map<Id,Boolean> mapaTieneAdjuntos = new Map<Id,Boolean>();

        if (campo == 'HasAttachment') {
            correosElectronicos = Database.query('SELECT Id, HasAttachment , Subject, FromAddress, ToAddress, MessageDate, toLabel(Status) FROM EmailMessage WHERE ParentId = :caseId');

            Set<Id> idsCorreos = new Set<Id>();
            
            for (EmailMessage eMessage : correosElectronicos) {
                idsCorreos.add(eMessage.Id);
                mapaTieneAdjuntos.put(eMessage.Id, false);
            }
                
            for (ContentDocumentLink cdl : [SELECT LinkedEntityId, ContentDocumentId  FROM ContentDocumentLink WHERE LinkedEntityId IN :idsCorreos]) {
                mapaTieneAdjuntos.put(cdl.LinkedEntityId,true);                                
            }
            if (orden == 'desc') {
                //Primero los que tienen adjuntos
                for (EmailMessage eMessage : correosElectronicos) {
                    if (mapaTieneAdjuntos.get(eMessage.Id)) {
                        listaCorreos.add(eMessage);
                    }       
                }

                //luego los que no tienen
                for (EmailMessage eMessage : correosElectronicos) {
                    if (!mapaTieneAdjuntos.get(eMessage.Id)) {
                        listaCorreos.add(eMessage);
                    }       
                }
            } else {
                //primero los que no tienen adjuntos
                for (EmailMessage eMessage : correosElectronicos) {
                    if (!mapaTieneAdjuntos.get(eMessage.Id)) {
                        listaCorreos.add(eMessage);
                    }       
                }

                //luego los que tienen 
                for (EmailMessage eMessage : correosElectronicos) {
                    if (mapaTieneAdjuntos.get(eMessage.Id)) {
                        listaCorreos.add(eMessage);
                    }       
                }
            }

            correosElectronicos.clear();
            correosElectronicos = listaCorreos;


        } else{
            listaCorreos = Database.query('SELECT Id, HasAttachment , Subject, FromAddress, ToAddress, MessageDate, toLabel(Status) FROM EmailMessage WHERE ParentId = :caseId ORDER BY ' +String.escapeSingleQuotes(campo)+' '+String.escapeSingleQuotes(orden));  
            
            Set<Id> idsCorreos = new Set<Id>();
            
            for (EmailMessage eMessage : listaCorreos) {
                idsCorreos.add(eMessage.Id);
                mapaTieneAdjuntos.put(eMessage.Id, false);
            }
                
            for (ContentDocumentLink cdl : [SELECT LinkedEntityId, ContentDocumentId  FROM ContentDocumentLink WHERE LinkedEntityId IN :idsCorreos]) {
                mapaTieneAdjuntos.put(cdl.LinkedEntityId,true);                                
            }
            correosElectronicos = listaCorreos;

        }
        
        List<CorreoElectronico> correos = new List<CorreoElectronico>();
        if (!correosElectronicos.isEmpty()) {
            for (EmailMessage eMessage : correosElectronicos) {
                CorreoElectronico correo = new CorreoElectronico();
                correo.Id = eMessage.Id;
                correo.asunto = eMessage.Subject;
                correo.de = eMessage.FromAddress;
                correo.para = eMessage.ToAddress;
                correo.fecha = eMessage.MessageDate.format();
                correo.nameUrl = '/'+eMessage.Id;
                correo.estado = eMessage.Status;
                
                if (mapaTieneAdjuntos.get(eMessage.Id)) {
                    correo.iconoAdjuntos = 'utility:attach';
                    correo.HasAttachment= ' ';
                }
                
                correos.add(correo);
            }
        }
        
        return correos;
    }


    public class CorreoElectronico {
        @AuraEnabled public Id Id{get;set;}
        @AuraEnabled public String asunto{get;set;}
        @AuraEnabled public String de{get;set;}
        @AuraEnabled public String para{get;set;}
        @AuraEnabled public String fecha{get;set;}
        @AuraEnabled public String estado{get;set;}
        @AuraEnabled public String HasAttachment{get;set;}        
        @AuraEnabled public String iconoAdjuntos{get;set;}     
        @AuraEnabled public String nameUrl{get;set;}
    }
}