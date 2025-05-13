public with sharing class SAC_LCMP_GestionEmailsConsultas {
    
    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();

    @AuraEnabled
    public static WrappedInfo obtenerInformacion(Id record){
        /*****************************************************************
         * Proposito: Método para devolver toda la información necesaria para poder hacer uso del cmp envio emails custom, sustituyendo el estándar
         * ***************************************************************
         * Historial
         * -------
         * VERSION        USER_STORY       AUTHOR         DATE         Description
         * 1.0            NaN              Luis Mesa     25/03/22      Creación Método
        *****************************************************************/
        if(!Case.SObjectType.getDescribe().isAccessible() || !SAC_Interaccion__c.SObjectType.getDescribe().isAccessible() || !EmailTemplate.SObjectType.getDescribe().isAccessible() || !CC_Grupo_Colaborador__c.SObjectType.getDescribe().isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }

        SAC_Interaccion__c interaccion = [SELECT Id, SAC_IndexedThreadId__c, SAC_Oficina__c, SAC_Reclamacion__c, SAC_GrupoColaborador__c, SAC_DNI__c, SAC_Reclamante__c, SAC_Respuesta__c     //Obtener el caso relacionado
                                    FROM SAC_Interaccion__c
                                    WHERE Id =: record];

        CC_Grupo_Colaborador__c grupo = [SELECT Id, SAC_Email__c, SAC_Email2__c, SAC_Email3__c, SAC_DeveloperName__c, SAC_PlantillaInteraccionId__c FROM CC_Grupo_Colaborador__c WHERE Id =: interaccion.SAC_GrupoColaborador__c];  //Obtener el para del email

        List<Case> reclamacionList = [SELECT Id, Origin, OS_Email__c, SAC_DireccionPostal__c, CC_Canal_Respuesta__c, SuppliedEmail, Account.CC_Email__c, RecordTypeId,
                             Status, CaseNumber, RecordType.Name, AccountId, CC_Idioma__c, Account.RecordTypeId, SAC_Reclamacion__c, SAC_Reclamacion__r.CC_Canal_Respuesta__c
                                FROM Case WHERE RecordTypeId =: RECTYPERECLAMACION AND Id =: interaccion.SAC_Reclamacion__c];

        // ASUNTO HARCODEADO
        // String para = 'SAC Consulta Reclamación: ' + reclamacion.CaseNumber;
        // if(String.isNotBlank(interaccion.SAC_DNI__c)){
        //     para += ' - DNI: ' + interaccion.SAC_DNI__c;
        // }
        // if(String.isNotBlank(interaccion.SAC_Reclamante__c)){
        //     para += ' , Reclamante: ' + interaccion.SAC_Reclamante__c;
        // }

        /*String variableCuerpo1 = '';
        if(!String.isBlank(interaccion.SAC_Respuesta__c)){
            variableCuerpo1 = interaccion.SAC_Respuesta__c;
        }
        String variableCuerpo2 = '';
        if(!String.isBlank(interaccion.SAC_IndexedThreadId__c)){
            variableCuerpo2 = interaccion.SAC_IndexedThreadId__c;
        }
        String cuerpo = et.HtmlValue.replace('{!SAC_Interaccion__c.SAC_Respuesta__c}', variableCuerpo1);
        cuerpo = cuerpo.replace('{!SAC_Interaccion__c.SAC_IndexedThreadId__c}', variableCuerpo2);
        cuerpo = cuerpo.replace(']]>','');*/

        List<String> body = new List<String>();
        EmailTemplate et = new EmailTemplate();
        String whoId;
        String whatId;
        String cuerpo;
        if(grupo.SAC_PlantillaInteraccionId__c != null) {
            et = [SELECT Id, Name, TimesUsed, Subject, HtmlValue FROM EmailTemplate WHERE Id =: grupo.SAC_PlantillaInteraccionId__c LIMIT 1]; //Obtener asunto y cuerpo del mail, aparece sin formatear y hay que hacerlo por codigo
            body.add(et.HtmlValue);
            whoId = UserInfo.getUserId();
            whatId = record;
            cuerpo = '';
        } else {
            et = [SELECT Id, Name, TimesUsed, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName ='SAC_PlantillaReclamacionConsulta' LIMIT 1]; //Obtener asunto y cuerpo del mail, aparece sin formatear y hay que hacerlo por codigo
            body.add(et.HtmlValue);
            whoId = UserInfo.getUserId();
            whatId = record;
            cuerpo = '';
        }

        // List<Messaging.RenderEmailTemplateBodyResult> resList = Messaging.renderEmailTemplate(whoId, whatId, body);
        // if(!resList.isEmpty()){
        //     cuerpo = resList[0].getMergedBody();
        // }

        Boolean noEsOficina = (grupo.SAC_DeveloperName__c == 'OFICINA') ? false : true;

        
        Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(et.Id, whoId, record);              
        
        String para = ''; 
        if(!String.isBlank(grupo.SAC_Email__c)){
            para = para + grupo.SAC_Email__c;
        }
        if(!String.isBlank(grupo.SAC_Email2__c)){
            para = para + ';' + grupo.SAC_Email2__c;
        }
        if(!String.isBlank(grupo.SAC_Email3__c)){
            para = para + ';' +  grupo.SAC_Email3__c;
        }

        WrappedInfo result;
        
        if(!reclamacionList.isEmpty()){
            result= new WrappedInfo(para, renderStored.getSubject(),  renderStored.getHtmlBody(),'', interaccion, reclamacionList[0], noEsOficina);
        }

         
        //System.debug(result);
        return result;
    }

    public class WrappedInfo{

        @AuraEnabled public String paraEmail{get; set;}
        @AuraEnabled public String asuntoEmail{get; set;}
        @AuraEnabled public String cuerpoEmail{get; set;}
        @AuraEnabled public String adjuntosEmail{get; set;} 
        @AuraEnabled public Case casoRelacionado{get; set;}
        @AuraEnabled public SAC_Interaccion__c consulta{get; set;}
        @AuraEnabled public Boolean noEsOficinas{get; set;}
        
        
        public WrappedInfo(String para, String asunto, String cuerpo, String adjuntos, SAC_Interaccion__c consultaM, Case caso, Boolean oficinas){
            this.paraEmail = para;
            this.asuntoEmail = asunto;
            this.cuerpoEmail = cuerpo;
            this.adjuntosEmail = adjuntos;
            this.casoRelacionado = caso;
            this.noEsOficinas = oficinas;
            this.consulta = consultaM;
        }
    }
    
}