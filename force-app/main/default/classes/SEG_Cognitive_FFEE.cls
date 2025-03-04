public with sharing class SEG_Cognitive_FFEE {
    @future(callout=true)
    public static void getCRFFEE(id casoid) {
 
        // Creacion de trazas
        CC_TrazaInt__c oTraza = new CC_TrazaInt__c(); //Creación de la traza para control de WS
        oTraza.Name = 'SEG_Cognitive_FFEE';
        oTraza.CC_FechaInicio__c = datetime.now();
        oTraza.CC_FinOK__c = false;

        //Trazabilidad a nivel de caso con el chatter
        FeedItem feed;

        // Creacion del caso
        Case casoSeg = [SELECT id, SEG_ClasificacionRapida__c, SEG_ClasificacionRapida__r.Name,SEG_Case_Owner__c, Subject,Description,CreatedDate,SEG_Zona__c,SEG_Organizacion__c,CaseNumber, SEG_N_operaciones_del_caso__c, SEG_Email_Generador__c FROM Case WHERE id=:casoid LIMIT 1];
        
        // Inserción de traza
        oTraza.CC_Identificador__c = casoSeg.CaseNumber;

        // Comprobaciones sobre el caso
        if(casoSeg != null && casoSeg.SEG_ClasificacionRapida__c == null && casoSeg.SEG_Case_Owner__c == 'SEG_BO'){ //US583083 - Se añade una comprovación para evitar que Cognitive reclasifique casos que ya se hayan clasificado manualmente.
            DatosEnvio sendCase = new DatosEnvio();
    
           // pkCodSr
           sendCase.pkCodSr=casoSeg.CaseNumber;
            //pkIDSalesforce
            sendCase.pkIdSalesforce = casoSeg.Id;         
           // messageFrom persona que lo ha enviado
           sendCase.messageFrom = casoSeg.SEG_Email_Generador__c;
           // messageSubject
           sendCase.messageSubject = casoSeg.Subject; 
           // messageText hacer prueba con null
            sendCase.messageText = casoSeg.Description?.replaceAll('\r\n|\n|\r',' ');  

            // Adjuntos crear una propia meter el metodo con sus adjuntos
            Integer totalAttachEnviados = 0;
            List<ContentVersion> listFiles = getFilesCase(casoid);
            List<ContenidoAttach> attach = new List<ContenidoAttach>();

            for(ContentVersion cv:listFiles) {
                ContenidoAttach attachmentFile = new ContenidoAttach();
                attachmentFile.name = cv.Title;
                attachmentFile.idAttach = String.valueOf(cv.ContentDocumentId);
                attachmentFile.extension = String.valueOf(cv.FileExtension);
                attachmentFile.size = String.valueOf(cv.ContentSize);
                attach.add(attachmentFile);
                totalAttachEnviados++;
            } 
            sendCase.attachs = attach;

            // TotalAttach calcular yo despues de traer el metodo
            sendCase.totalAttach = String.valueOf(totalAttachEnviados);

            // Serialización del JSON
            String jsonToCognitive = JSON.serialize(sendCase);

            // Inserción en traza
            oTraza.CC_MensajeEntrada__c = String.valueOf(jsonToCognitive);

            // Custom Setting meter el nombre del que cree
            String intSetting = 'SEG_Cognitive_FFEE';
            
            
            try {
                // Crear HEADER
                Map<String,string> mHeaders =  new  Map<String,string>();
                mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

                // Peticion con RequestWapper
                CBK_HttpServiceIntegration.RequestWapper rqwpr = new CBK_HttpServiceIntegration.RequestWapper();
                rqwpr.body = jsonToCognitive;
                rqwpr.intSetting = intSetting;
                rqwpr.method = 'POST';
                rqwpr.mHeaders = mHeaders;
                rqwpr.mUriParams = null;
                rqwpr.mQueryParams = null;
                HttpRequest request = CBK_HttpServiceIntegration.getRequest(rqwpr);
                // Respuesta
                HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);
                
                if (response != null && response.getStatusCode() == 200) {
                    oTraza.CC_MensajeSalida__c = response.getBody();
                    oTraza.CC_FinOK__c = true;
                    
                    ReceiveFromCognitive results = new ReceiveFromCognitive();   
                    results = (ReceiveFromCognitive) System.JSON.deserialize(response.getBody(),ReceiveFromCognitive.class);
                
                }else{
                    feed = new FeedItem();
                    feed.ParentId = casoid; 
                    feed.Type = 'TextPost';
                    feed.Body = 'Cognitive: No se ha podido establecer conexión con Cognitive';
                    oTraza.CC_MensajeSalida__c = response.getBody();
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_MensajeEntrada__c = String.valueOf(request);
                    oTraza.CC_TipoError__c = 'Error de conexión';
                    oTraza.CC_DetalleError__c = 'No se ha podido establecer conexión con Cognitive';
                }

                oTraza.CC_FechaFin__c = datetime.now();
                
            } catch (Exception e) {
                //Traza - Error de Apex
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_TipoError__c = 'Error comunicaciones.';
                oTraza.CC_DetalleError__c = e.getMessage();
            }
        } else if(casoSeg != null){
            // Se inserta en chatter un registro indicando que el caso ya tenía clasificación al contactar con cognitive.
            feed = new FeedItem();
            feed.ParentId = casoid; 
            feed.Type = 'TextPost';
            if(casoSeg.SEG_Case_Owner__c != 'SEG_BO'){
                feed.Body = 'Cognitive: Se ha asignado un propietario previa consulta a Cognitive con lo que no se ha aplicado la CR indicada.'; 
            } else {
                feed.Body = 'Cognitive: El caso ya se encontraba clasificado manualmente por lo que no se ha podido aplicar Cognitive.'; 
            }

            //Traza - No se asigna la clasificación al estar ya indicada manualmente.
            oTraza.CC_FechaFin__c = datetime.now();
            oTraza.CC_FinOK__c = true;
            oTraza.CC_TipoError__c = 'Excepcion de asignacion';
            oTraza.CC_DetalleError__c = 'El caso no ha sido clasificado por cognitive';
        }
        
        if (feed != null) {
            insert feed;
        }
        
        insert oTraza;
    }

    private static List<ContentVersion> getFilesCase(Id casoId) {
        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>([SELECT ContentDocumentId, LinkedEntityId, ContentDocument.FileType, ContentDocument.ContentSize  FROM ContentDocumentLink WHERE LinkedEntityId =: casoId AND LinkedEntity.Type ='Case']);
        Set<Id> contentDocLinkIds = new Set<Id>();
        SEG_Parametros__mdt tamanoMaxCog = SEG_Parametros__mdt.getInstance('SEG_TamanoMaxArchivosCog');
        for (ContentDocumentLink contentLink : contentDocLinkList){
            if(contentLink.ContentDocument.FileType != 'PNG' && contentLink.ContentDocument.FileType != 'JPEG' && contentLink.ContentDocument.FileType != 'JPG'){
                contentDocLinkIds.add(contentLink.ContentDocumentId);
            } else if (contentLink.ContentDocument.ContentSize > 0 && tamanoMaxCog != null && contentLink.ContentDocument.ContentSize <= Integer.valueOf(tamanoMaxCog.SEG_Valor__c)) {
                contentDocLinkIds.add(contentLink.ContentDocumentId);
            }
        }
        List<ContentVersion> listFiles = new List<ContentVersion>();
        if (!contentDocLinkIds.isEmpty()) {
            listFiles = [SELECT Id, ContentDocumentId,Title,FileExtension,Description,VersionData,ContentSize, FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId in:contentDocLinkIds];
        }
        
        return listFiles;
    }

    // Crear datos de clase recibida
    @TestVisible
    private class DatosEnvio {
        public String pkCodSr {get;set;}
        public String pkIdSalesforce {get;set;}
        public String messageFrom {get;set;}
        public String messageSubject {get;set;}
        public String messageText {get;set;}
        public String totalAttach {get;set;}
        public List<ContenidoAttach> attachs{get;set;}
    }

    @TestVisible
    private class ContenidoAttach{
        public String name {get;set;}
        public String idAttach {get;set;}
        public String extension {get;set;}
        public String size {get;set;}
    }

    @TestVisible
    private class ReceiveFromCognitive{
        public String pkCodSr {get;set;}
        public String pkIdSalesforce {get;set;}
        public String status {get;set;}
    }

}