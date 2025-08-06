public with sharing class SPV_LCMP_GestionEmailsConsultas {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    
    /*****************************************************************
     * Proposito: Método para devolver toda la información necesaria para poder hacer uso del cmp envio emails custom
     *
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US945746     Raúl Santos     23/07/24         Creación
    *****************************************************************/
    @AuraEnabled
    public static InfoConsulta obtenerInformacion(Id record){

        if(!Schema.sObjectType.Case.isAccessible() || !Schema.sObjectType.SAC_Interaccion__c.isAccessible() || !Schema.sObjectType.EmailTemplate.isAccessible() || !Schema.sObjectType.CC_Grupo_Colaborador__c.isAccessible()){ throw new AuraHandledException( 'Fallo al acutalizar.' ); }

        SAC_Interaccion__c interaccion = [SELECT Id, SAC_IndexedThreadId__c, SAC_Oficina__c, SAC_Reclamacion__c, SPV_TareaRelacionada__r.SAC_Reclamacion__c, SAC_GrupoColaborador__c, SAC_DNI__c, SAC_Reclamante__c, SAC_Respuesta__c     //Obtener el caso relacionado
                                    FROM SAC_Interaccion__c
                                    WHERE Id =: record];

        EmailTemplate et = [SELECT Id, Name, TimesUsed, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName ='SPV_PlantillaReclamacionConsulta' LIMIT 1]; //Obtener asunto y cuerpo del mail, aparece sin formatear y hay que hacerlo por codigo

        CC_Grupo_Colaborador__c grupo = [SELECT Id, SAC_Email__c, SAC_Email2__c, SAC_Email3__c, SAC_DeveloperName__c FROM CC_Grupo_Colaborador__c WHERE Id =: interaccion.SAC_GrupoColaborador__c];  //Obtener el para del email

        Case reclamacion = [SELECT Id, Origin, OS_Email__c, SAC_DireccionPostal__c, CC_Canal_Respuesta__c, SuppliedEmail, Account.CC_Email__c, RecordTypeId,
                             Status, CaseNumber, RecordType.Name, AccountId, CC_Idioma__c, Account.RecordTypeId, SAC_Reclamacion__c, SAC_Reclamacion__r.CC_Canal_Respuesta__c
                                FROM Case WHERE RecordTypeId =: RECTYPERECLAMACION AND Id IN (:interaccion.SAC_Reclamacion__c, :interaccion.SPV_TareaRelacionada__r.SAC_Reclamacion__c)];

        List<String> body = new List<String>();
        body.add(et.HtmlValue);
        String whoId = UserInfo.getUserId();

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

        InfoConsulta result = new InfoConsulta(para, renderStored.getSubject(), renderStored.getHtmlBody(),'', interaccion, reclamacion, noEsOficina);

        return result;
    }

    public class InfoConsulta{

        @AuraEnabled public String paraEmail{get; set;}
        @AuraEnabled public String asuntoEmail{get; set;}
        @AuraEnabled public String cuerpoEmail{get; set;}
        @AuraEnabled public String adjuntosEmail{get; set;} 
        @AuraEnabled public Case casoRelacionado{get; set;}
        @AuraEnabled public SAC_Interaccion__c consulta{get; set;}
        @AuraEnabled public Boolean noEsOficinas{get; set;}
        
        
        public InfoConsulta(String para, String asunto, String cuerpo, String adjuntos, SAC_Interaccion__c consultaM, Case caso, Boolean oficinas){
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