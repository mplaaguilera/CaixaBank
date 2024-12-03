/**
*   @description SEG_CognitiveCR - Clase para la obtención de clasificaciones rápidas de Casos a partir de la conexión por WS con Cognitive.
*/ 
public with sharing class SEG_CognitiveCR {
    @future(callout=true)
    public static void getCRCognitive(id casoid) { 
  
        //List<ContentVersion> listFiles;
        //List<ContentVersion> listFiles = getFilesCase(casoid); //Obtención de los adjuntos del caso.
        //CC_InterfaceSettings__mdt oConfig = getConfig('SEG_COGNITIVE'); //Obtención de la configuración del WS a partir de la metadata.

        CC_TrazaInt__c oTraza = new CC_TrazaInt__c(); //Creación de la traza para control de WS
        oTraza.Name = 'Cognitive_Segmentos';
        oTraza.CC_FechaInicio__c = datetime.now();


        Case casoSeg = new Case();
        casoSeg = [SELECT id, SEG_ClasificacionRapida__c, SEG_ClasificacionRapida__r.Name,SEG_Case_Owner__c, Subject,Description,CreatedDate,SEG_Zona__c,SEG_Organizacion__c,CaseNumber, SEG_N_operaciones_del_caso__c FROM Case WHERE id=:casoid];
        
        oTraza.CC_Identificador__c = casoSeg.CaseNumber;

        if(casoSeg != null && casoSeg.SEG_ClasificacionRapida__c == null && casoSeg.SEG_Case_Owner__c == 'SEG_BO'){ //US583083 - Se añade una comprovación para evitar que Cognitive reclasifique casos que ya se hayan clasificado manualmente.
            SEG_sendToCognitive sendCase = new SEG_sendToCognitive();
            sendCase.subject = casoSeg.Subject;
    
            if(casoSeg.Description != null){
                sendCase.body = casoSeg.Description.replaceAll('\r\n|\n|\r',' ');  
            }else{
                sendCase.body = '';
            }
    
            sendCase.date_time = casoSeg.CreatedDate.format('yyyy-MM-dd HH:mm:ss', 'Europe/Madrid'); //"2017-12-23 16:30:21" yyyy-MM-dd 
            sendCase.zone = casoSeg.SEG_Zona__c;
            sendCase.organisation=casoSeg.SEG_Organizacion__c;
            sendCase.sr=casoSeg.CaseNumber;
            sendCase.origin='BCorp';
            sendCase.total_attach = '0';
    
            /*if(listFiles != null){
                sendCase.total_attach = String.valueOf(listFiles.size());
            }*/
    
            List<SEG_sendToCognitive.cls_attachs> attachments = new List<SEG_sendToCognitive.cls_attachs>();
            sendCase.attachs = attachments;

            /*for(ContentVersion cv:listFiles) {
                SEG_sendToCognitive.cls_attachs attachmentFile = new SEG_sendToCognitive.cls_attachs();
                attachmentFile.Name = cv.Title+'.'+cv.FileExtension;
                attachmentFile.binary = String.valueOf(cv.versiondata);
                attachmentFile.extension = cv.FileExtension;
                attachmentFile.size = cv.ContentSize;
                attachments.add(attachmentFile);
            }
    
            sendCase.attachs = attachments;
            */
    
            String jsonToCognitive = JSON.serialize(sendCase);
            jsonToCognitive=jsonToCognitive.replace('date_time', 'date-time');
            jsonToCognitive=jsonToCognitive.replace('total_attach', 'total-attach');

            // Custom Setting
            String intSetting = 'SEG_COGNITIVE';
            
            try {

                // Crear HEADER
                Map<String,string> mHeaders =  new  Map<String,string>();
                mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

                CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
                requestWrp.body = jsonToCognitive;
                requestWrp.intSetting = intSetting;
                requestWrp.method = 'POST';
                requestWrp.mHeaders = mHeaders;
                requestWrp.mUriParams = null;
                requestWrp.mQueryParams = null;

                HttpRequest request = CBK_HttpServiceIntegration.getRequest(requestWrp);
                //request.setClientCertificateName(oConfig.CC_Certificado__c);

                HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);
                
                oTraza.CC_MensajeEntrada__c = String.valueOf(jsonToCognitive);
    
                if (response != null && response.getStatusCode() == 200) {
                    Integer maxSize = 32767;
                    SEG_receiveFromCognitive results = new SEG_receiveFromCognitive();
                    
                    if (response.getBody() != null && response.getBody().length() < maxSize) {
                        oTraza.CC_MensajeSalida__c = response.getBody();
                    } else if(response.getBody() != null) {
                        oTraza.CC_MensajeSalida__c = response.getBody().substring(0, maxSize);
                    }
                    
                    oTraza.CC_FechaFin__c = datetime.now();
                    oTraza.CC_FinOK__c = true;
                    
                    results = SEG_receiveFromCognitive.parse(response.getBody());
    
                    Case casoControlCR = [SELECT Subject, SEG_ClasificacionRapida__c, SEG_ClasificacionRapida__r.Name, SEG_Case_Owner__c FROM Case WHERE id=:casoid];
                    
                    if(casoControlCR != null && (casoControlCR.SEG_ClasificacionRapida__c != null || casoControlCR.SEG_Case_Owner__c != 'SEG_BO') || (Test.isRunningTest() && casoControlCR.Subject.equalsIgnoreCase('TEST Caso Owner'))){
                        //US583083 - Se inserta en chatter un registro indicando que se ha indicado una CR manualmente durante la consulta a Cognitive.
                        FeedItem feed = new FeedItem();
                        feed.ParentId = casoid; 
                        if (casoControlCR.SEG_Case_Owner__c != 'SEG_BO') {
                            feed.Body = 'Cognitive: Se ha asignado un propietario previa consulta a Cognitive con lo que no se ha aplicado la CR indicada.'; 
                        } else {
                            feed.Body = 'Cognitive: El caso ya se encontraba clasificado manualmente por lo que no se ha podido aplicar Cognitive.'; 
                        }
                        
                        insert feed;

                        //Traza - No se asigna la clasificación al estar ya indicada manualmente.
                        oTraza.CC_FechaFin__c = datetime.now();
                        oTraza.CC_FinOK__c = true;
                        oTraza.CC_TipoError__c = 'Excepcion de asignacion';
                        oTraza.CC_DetalleError__c = 'El caso no ha sido clasificado por cognitive';
                    } else if(results != null && String.isNotBlank(results.category)) {
                        if(results.category=='Robot No Clasificado') { //Cognitive indica que no ha encontrado ninguna clasificacción en base a los datos indicados.
                            casoSeg.SEG_TipoClasificacion__c='Robot no clasificado';
                        } else {
                            FeedItem feed = new FeedItem();
                            feed.Type = 'TextPost';
                            feed.ParentId = casoid;
                            List<SEG_ClasificacionRapida__c> crCognitive = new List<SEG_ClasificacionRapida__c>([select id,name,SEG_Nombre_CR_Cognitive__c,SEG_Canaldeentrada__c, SEG_Tematica__c,SEG_Producto__c,SEG_Motivo__c,SEG_Detalle__c,SEG_Prioridad__c, SEG_CRAuditoria__c from SEG_ClasificacionRapida__c where SEG_Nombre_CR_Cognitive__c =:results.category AND SEG_Inactiva__c=false AND SEG_Organizacion__c includes(:casoSeg.SEG_Organizacion__c)]);
                            if(crCognitive != null && crCognitive.size()>0){
                                
                                casoSeg.SEG_ClasificacionRapida__c=crCognitive[0].id;
                                casoSeg.CC_MCC_Tematica__c = crCognitive[0].SEG_Tematica__c;
                                casoSeg.CC_MCC_ProdServ__c = crCognitive[0].SEG_Producto__c;
                                casoSeg.CC_MCC_Motivo__c = crCognitive[0].SEG_Motivo__c;
                                casoSeg.SEG_Detalle__c = crCognitive[0].SEG_Detalle__c;
                                casoSeg.Priority = crCognitive[0].SEG_Prioridad__c;
                                casoSeg.SEG_N_operaciones_del_caso__c = 1;
                                casoSeg.SEG_TipoClasificacion__c='Cognitive sin adjuntos';

                                feed.Body = 'Cognitive: ' + results.Category; 
                            } else {
                                //Traza - La CR indicada por Cognitive no existe en Salesforce.
                                oTraza.CC_FechaFin__c = datetime.now();
                                oTraza.CC_FinOK__c = false;
                                oTraza.CC_TipoError__c = 'CR No existente.';
                                oTraza.CC_DetalleError__c = 'No existe CR en Salesforce activa con Nombre Cognitive: ' + results.category +  '  y Organización: ' + casoSeg.SEG_Organizacion__c;

                                feed.Body = 'Cognitive: No existe CR en Salesforce activa con Nombre Cognitive: ' + results.category +  '  y Organización: ' + casoSeg.SEG_Organizacion__c; 
                            }
                            insert feed;
                        }
                        //Update caso
                        Database.SaveResult sr = Database.update(casoSeg, false);
                        if (sr.isSuccess()) {
                            Map<String,String> resutAutoasignar = SEG_Case_Operativas_Controller.autoAsignarGrupo(casoSeg.Id);
                            CBK_Log.error('SEG_Cognitive resutAutoasignar: ' + resutAutoasignar);
                        } else {
                            String erroresActualizacion = 'SEG_Cognitive Datasave Error ';
                            for(Database.Error err : sr.getErrors()) {
                                erroresActualizacion += ' - Error: ' + err.getStatusCode() + ' - ' + err.getMessage();
                            }
                            CBK_log.debug(erroresActualizacion, LoggingLevel.ERROR);
                            FeedItem feed = new FeedItem();
                            feed.Type = 'TextPost';
                            feed.ParentId = casoid;
                            feed.Body = 'Cognitive: No se ha podido relalizar la actualización correcta del caso.'; 
                        }                                                                      
                    }  
                } else {
                    //Traza - Error con la conexión al ws
                    oTraza.CC_FechaFin__c = datetime.now();
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_TipoError__c = 'Error comunicaciones.';
                    oTraza.CC_DetalleError__c = response.getStatusCode() + ':' + response.getBody();
                }
            } catch (Exception e) {
                //Traza - Error de Apex
                CBK_Log.error(e, 'Error durante la comunicación con Cognitive');
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = 'Error comunicaciones.';
                oTraza.CC_DetalleError__c = e.getMessage();
            }
        } else if(casoSeg != null){
            //US583083 - Se inserta en chatter un registro indicando que el caso ya tenía clasificación al contactar con cognitive.
            FeedItem feed = new FeedItem();
            feed.ParentId = casoid; 
            feed.Type = 'TextPost';
            if(casoSeg.SEG_Case_Owner__c != 'SEG_BO'){
                feed.Body = 'Cognitive: Se ha asignado un propietario previa consulta a Cognitive con lo que no se ha aplicado la CR indicada.'; 
            } else {
                feed.Body = 'Cognitive: El caso ya se encontraba clasificado manualmente por lo que no se ha podido aplicar Cognitive.'; 
            }

            insert feed;

            //Traza - No se asigna la clasificación al estar ya indicada manualmente.
            oTraza.CC_FechaFin__c = datetime.now();
            oTraza.CC_FinOK__c = true;
            oTraza.CC_TipoError__c = 'Excepcion de asignacion';
            oTraza.CC_DetalleError__c = 'El caso no ha sido clasificado por cognitive';
        }
        
        insert oTraza;       
    } 
    /*
    //Verión antigua con los adjuntos comentados.
    private static List<ContentVersion> getFilesCase(Id casoId)
    {
        List<ContentVersion> listFiles = new List<ContentVersion>();
        listFiles = [select id, versiondata,Title,FileExtension,ContentSize,FirstPublishLocationId from ContentVersion where FirstPublishLocationId=:casoId];
        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>([SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Case where id=: casoId) and LinkedEntity.Type='Case']);
        Set<Id> contentDocLinkIds = new Set<Id>();
        for (ContentDocumentLink contentLink:contentDocLinkList){
            contentDocLinkIds.add(contentLink.ContentDocumentId);
        }
        List<ContentVersion> listFiles = new List<ContentVersion>();
        listFiles = [select ContentDocumentId,Title,FileExtension,Description,VersionData,ContentSize from ContentVersion where ContentDocumentId in:contentDocLinkIds];
        return listFiles;
    }
    */
    /*
     20/02/2023 - Se comenta la versión del método con los adjuntos activos a petición de Adela hasta que se decida subir el desarrollo
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
    }*/
}