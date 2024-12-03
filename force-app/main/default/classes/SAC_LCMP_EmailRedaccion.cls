public with sharing class SAC_LCMP_EmailRedaccion {
    
    @AuraEnabled
    public static DatosEmailWrapper obtenerDatosEmail(String idCaso){
        try {
            List<String> body = new List<String>();
            Case caso = [SELECT Id, OS_Email__c, CaseNumber, Subject, Status, OwnerId FROM Case WHERE id =: idCaso LIMIT 1];
            //String asunto = 'Respuesta a su reclamación ' + caso.CaseNumber;
            EmailTemplate et=[SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE Name = 'SAC_Redaccion' LIMIT 1]; 
            
            body.add(et.HtmlValue);
            String whoId = UserInfo.getUserId();
            String whatId = caso.Id;
            // String stringFinal = '';
            // List<Messaging.RenderEmailTemplateBodyResult> resList = Messaging.renderEmailTemplate(whoId, whatId, body);

            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(et.Id, whoId, caso.id);  

            // if(!resList.isEmpty()){
            //     stringFinal = resList[0].getMergedBody();
            // }
            ContentVersion[] adjuntos = SAC_LCMP_GestionEmails.obtieneAdjuntos(idCaso);

            DatosEmailWrapper informacion = new DatosEmailWrapper(caso.OS_Email__c, renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, UserInfo.getSessionId(), adjuntos);
            return informacion;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class DatosEmailWrapper{
        /*****************************************************************
         * Name: DatosEmailWrapper
         * Copyright © 2021  CaixaBank
         * 
         * Proposito: Clase Wrapper para mandar contenido formateado del controlador Apex al controlador JS para el correcto funcionamiento
         *  del componente aura SAC_EmailRedaccion.
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0                     Luis Mesa     04/10/21      Creación Clase
        *****************************************************************/
        
                @AuraEnabled public String para {get; set;}
                @AuraEnabled public String asunto {get; set;}
                @AuraEnabled public String cuerpo {get; set;}
                @AuraEnabled public String copia {get; set;}
                @AuraEnabled public Case caso {get; set;}
                @AuraEnabled public String sesion {get; set;}
                @AuraEnabled public ContentVersion[] adjuntos {get; set;}
                
                public DatosEmailWrapper(String paraM, String asuntoM, String cuerpoM, String copiaM, Case casoM, String sesionM, ContentVersion[] adjuntosM)
                {
        /*****************************************************************
         * Proposito: Método constructor de la clase Wrapper
         * 
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0                     Luis Mesa    04/10/21       Creación Método
        *****************************************************************/
                    para = paraM;
                    asunto = asuntoM;     
                    cuerpo = cuerpoM;   
                    copia = copiaM;
                    caso = casoM;
                    sesion = sesionM;
                    adjuntos = adjuntosM;
                }
                
            }
        

}