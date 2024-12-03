public with sharing class SAC_LCMP_EnvioResolucionCorreoPostal {
    //Test class: SAC_EnvioResolucionCorreoPostal_Test

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECORDTYPEBLACKLIST = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_BlackListEmails').getRecordTypeId();

    private static final Id RECTYPERECLAMACION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
    
    @AuraEnabled
    public static WrappedInfoCartas buscaCartaPrevia(Id caseId, String tipoCarta) {
        Id idCarta;
        
        if(!Schema.sObjectType.SAC_DocumentoEnvio__c.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el documento de envio.' ); }
        List<SAC_DocumentoEnvio__c> carta = [SELECT id, SAC_CP__c, SAC_Direccion__c, SAC_Pais__c, SAC_Poblacion__c, SAC_Provincia__c, SAC_Cuerpo__c FROM SAC_DocumentoEnvio__c WHERE  SAC_Caso__c =:caseId  AND SAC_TipoDocumento__c =:tipoCarta LIMIT 1];
        if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el caso.' ); }
        Case caso = [SELECT SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c FROM Case WHERE Id =: caseId LIMIT 1];
        if(!Schema.sObjectType.ContentVersion.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el content version.' ); }
        List<ContentVersion> cv = [SELECT Id, VersionData, ContentDocumentId FROM ContentVersion WHERE SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion' AND FirstPublishLocationId =: caseId LIMIT 1];
        if(!Schema.sObjectType.ContentDocument.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el content document.' ); }
        List<ContentDocument> cd = [SELECT Id, Title FROM ContentDocument WHERE Id =: cv[0].ContentDocumentId LIMIT 1];

        List<plantillasWrapper> paises = getPickListValuesIntoList();

        if(carta.isEmpty()){
            WrappedInfoCartas myInfo = new WrappedInfoCartas('', caso.SAC_DireccionContacto__c, caso.SAC_CodigoPostalContacto__c, caso.SAC_PoblacionContacto__c, caso.SAC_ProvinciaContacto__c, '', cd[0], cv[0], paises);
            return myInfo;
        }
        else{
            WrappedInfoCartas myInfo = new WrappedInfoCartas(carta[0].Id, carta[0].SAC_Direccion__c, carta[0].SAC_CP__c, carta[0].SAC_Poblacion__c, carta[0].SAC_Provincia__c, carta[0].SAC_Pais__c, cd[0], cv[0], paises);    
            return myInfo;
        }        
    }

    @AuraEnabled
    public static List<plantillasWrapper> getPickListValuesIntoList(){
        List<plantillasWrapper> pickListValuesList= new List<plantillasWrapper>();
         Schema.DescribeFieldResult fieldResult = SAC_DocumentoEnvio__c.SAC_Pais__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            plantillasWrapper wrapper = new plantillasWrapper(pickListVal.getValue(), pickListVal.getLabel());
            pickListValuesList.add(wrapper);
         }
         return pickListValuesList;
     }

    
    //Modificación: US723742 - Raúl Santos - 05/03/2024 - Añadir lógica envio emails blackList
    @AuraEnabled
    public static String finalizarRedaccionCartaPostal(String caseId, String para, String copia, String copiaOculta, String cuerpo, String asunto, String idAdjuntos) {

        Case casoActual = [SELECT Id, SAC_FechaVencimientoSLA__c, SAC_MotivoDemora__c, SAC_ComentarioDemora__c FROM Case WHERE Id = :caseId AND RecordTypeId = :RECTYPERECLAMACION LIMIT 1];
        String emailsInvalidos = '';

        //Añadido comprobar el target date del caseMilestone en lugar del campo SAC_FechaVencimientoSLA__c del caso
        List<CaseMilestone> listaCM = [SELECT Id, TargetDate FROM CaseMilestone WHERE CaseId = :caseId AND MilestoneType.Name = 'SLA Regulatorio'];
        if(/*casoActual.SAC_FechaVencimientoSLA__c*/!listaCM.isEmpty() && listaCM[0].TargetDate != null && listaCM[0].TargetDate < System.now() && casoActual.SAC_MotivoDemora__c == null){
            throw new AuraHandledException( 'El SLA Regulatorio esta sobrepasado, debe informar los motivos de la demora mediante el botón "Resolver Reclamación" antes de continuar.' );
        }else{
            if(String.isNotBlank(para)){
                //Recupero los emails no validos de envio (emails en la blackList)
                List<SAC_MaestroTemas__c> listEmailsNoValidos = [SELECT Name FROM SAC_MaestroTemas__c WHERE RecordTypeId =: RECORDTYPEBLACKLIST AND SAC_Activo__c = true];

                //Compruebo la dirección de envio con las de la blackList
                String emailsNoValidosEncontrados = SAC_Utils.comprobarEmailsBlackList(listEmailsNoValidos, para, '', '');

                //Si la dirección de envio es válida (no está en la blackList), continuo el proceso
                if(emailsNoValidosEncontrados == ''){
                    SAC_LCMP_GestionEmails.enviarEmail(caseId, para, copia, copiaOculta, cuerpo, asunto, idAdjuntos, '');
                }else{
                    //Sino, devuelvo una cadena con los emails no válidos para informar al usuario
                    emailsInvalidos = emailsNoValidosEncontrados;
                }
                
            }
            SAC_LCMP_RedaccionFinal.finalizarRedaccionCartaPostal(caseId);
    
            FeedItem post = new FeedItem();
            post.ParentId = caseId;
            post.Body = 'Envío redacción final carta postal';
            post.Title = 'Fin Redacción';
            if (!Schema.sObjectType.FeedItem.isCreateable()) { throw new AuraHandledException( 'No tienes permisos para realizar esta accion, no puede insertar el FeedItem.' ); }
            Database.insert(post);
        }    
        
        return emailsInvalidos;
    }

    @AuraEnabled
    public static DatosEmailWrapper obtenerDatosEmail(String idCaso, Boolean soloEmail){
        try {
            List<String> body = new List<String>();
            if(!Schema.sObjectType.Case.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el caso.' ); }
            Case caso = [SELECT Id, SAC_DireccionPostalNotificacion__c, AccountId, Account.RecordTypeId, OS_Email__c, Origin, CC_Canal_Respuesta__c,
                        Account.CC_Email__c, SAC_DireccionPostal__c, RecordTypeId, SuppliedEmail, SAC_MotivoInadmision__c, CaseNumber, Subject, Status,
                        OwnerId, CC_Idioma__c, SAC_OrigenConsulta__c, CC_No_Identificado__c, recordType.Name, SAC_Reclamacion__r.OS_Email__c,
                        CC_Oficina_Afectada_Lookup__c, CC_Oficina_Afectada_Lookup__r.CC_Email__c
                        FROM Case WHERE id =: idCaso LIMIT 1];

            EmailTemplate et = null;

            if(!Schema.sObjectType.EmailTemplate.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el Email Template.' ); }
            if(caso.RecordTypeId == RECTYPERECLAMACION){
                et =[SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE Name = 'SAC_Redaccion' LIMIT 1];
            }else {
                et=[SELECT Id, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'SAC_PlantillaSAC'];
            }         
            
            ContentDocument[] documentos = null;
            
            body.add(et.HtmlValue);
            String whoId = UserInfo.getUserId();
            String whatId = caso.Id;
            String stringFinal = '';
            Messaging.SingleEmailMessage renderStored = Messaging.renderStoredEmailTemplate(et.Id, whoId, idCaso);  

            if(String.isNotBlank(caso.CC_Oficina_Afectada_Lookup__r.CC_Email__c)){
                return new DatosEmailWrapper(caso.CC_Oficina_Afectada_Lookup__r.CC_Email__c, renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);
            }
            else{
                return new DatosEmailWrapper('', renderStored.getSubject(), renderStored.getHtmlBody(), '', caso, documentos);
            }
          
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class WrappedInfoCartas{
        @AuraEnabled public String idCarta {get; set;}
        @AuraEnabled public String direccion {get; set;}
        @AuraEnabled public String cp {get; set;}
        @AuraEnabled public String poblacion {get; set;}
        @AuraEnabled public String provincia {get; set;}
        @AuraEnabled public String pais {get; set;}
        @AuraEnabled public ContentDocument documentoRedaccion {get; set;}
        @AuraEnabled public ContentVersion versionRedaccion {get; set;}
        @AuraEnabled public List<plantillasWrapper> opcionesPais{get; set;}
        

        public WrappedInfoCartas(String idM, String direccionM, String cpM, String poblacionM, String provinciaM, String paisM, ContentDocument documentoRedaccionM, ContentVersion versionM, List<plantillasWrapper> opcionesM){
            idCarta = idM;
            direccion = direccionM;
            cp = cpM;
            poblacion = poblacionM;
            provincia = provinciaM;
            pais = paisM;
            documentoRedaccion = documentoRedaccionM;
            versionRedaccion = versionM;
            this.opcionesPais = opcionesM;
        }
    }

    public class plantillasWrapper{

        @AuraEnabled public String idPlantilla{get; set;}
        @AuraEnabled public String nombrePlantilla{get; set;}   
        
        public plantillasWrapper(String id, String nombre){
            idPlantilla = id;
            nombrePlantilla = nombre;
        }
    }

    public class DatosEmailWrapper{
        @AuraEnabled public String para {get; set;}
        @AuraEnabled public String asunto {get; set;}
        @AuraEnabled public String cuerpo {get; set;}
        @AuraEnabled public String copia {get; set;}
        @AuraEnabled public Case caso {get; set;}
        @AuraEnabled public ContentDocument[] adjuntos {get; set;}
        
        public DatosEmailWrapper(String paraM, String asuntoM, String cuerpoM, String copiaM, Case casoM, ContentDocument[] adjuntosM)
        {
            para = paraM;
            asunto = asuntoM;    
            cuerpo = cuerpoM;  
            copia = copiaM;
            caso = casoM;
            adjuntos = adjuntosM;
        }
    }
}