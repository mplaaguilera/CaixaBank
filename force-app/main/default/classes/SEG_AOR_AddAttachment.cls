public with sharing class SEG_AOR_AddAttachment {
    //TODO: Revisar parametros de envio ( Id de attachment)
    @Future(callout=true)	
    public static void SEG_AOR_AddAttachmentSend(id casoid, Id idAdjunto) {

        List<ContentVersion> listFiles = [SELECT Id,ContentDocumentId,Title,FileExtension,Description, CreatedDate, ContentSize FROM ContentVersion WHERE ContentDocumentId =: idAdjunto];
        
        String sDescError = '';
        String sDetalleError = '';
        CC_TrazaInt__c oTraza;
            
        oTraza = new CC_TrazaInt__c();
        oTraza.Name = 'SEG_AOR_Attachment';
        oTraza.CC_FechaInicio__c = datetime.now();
        

        Case casoSeg=new Case();
        casoSeg=[SELECT Id,OwnerId, CaseNumber, SEG_Numero_centro__c, Account.Name, Account.CC_Numero_Documento__c,SEG_Consulta_AOR__c,SEG_Identificador_AOR__c,SEG_Comentario_AOR__c FROM Case WHERE id=:casoid];
        datosEnviarAdjuntoAOR sendCaseAtt = new datosEnviarAdjuntoAOR();
        oTraza.CC_Identificador__c = casoSeg.CaseNumber;

        sendCaseAtt.id_attachment = listFiles[0].Id;
        sendCaseAtt.nombre_attachment = !listFiles[0].Title.endsWithIgnoreCase(listFiles[0].FileExtension) ? listFiles[0].Title + '.' + listFiles[0].FileExtension : listFiles[0].Title;
        sendCaseAtt.tipo_attachment = listFiles[0].FileExtension;


        String jsonToCognitive = JSON.serialize(sendCaseAtt);
        //espacio para lanzar llamada HHTP

        // Custom Setting
        String intSetting = 'SEG_AOR_Attachment';
        
        try {
            // Crear HEADER
            Map<String,string> mHeaders =  new  Map<String,string>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

            CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
            requestWrp.body = jsonToCognitive;
            requestWrp.intSetting = intSetting;
            requestWrp.method = 'PUT';
            requestWrp.mHeaders = mHeaders;

            HttpRequest request = CBK_HttpServiceIntegration.getRequest(requestWrp);
            request.setEndpoint(request.getEndpoint() + casoSeg.SEG_Identificador_AOR__c);
            HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);

            oTraza.CC_MensajeEntrada__c = String.valueOf(jsonToCognitive);
            
            String jsonResults = response.getBody();

            if (response.getStatusCode() == 200) {
                SEG_receiveFromAOR results = new SEG_receiveFromAOR();

                oTraza.CC_MensajeSalida__c = response.getBody();             
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = true;
                
                
                results = SEG_receiveFromAOR.parse(response.getBody());
                if(jsonResults!=null)
                {
                    System.JSONParser parserSR = System.JSON.createParser(String.valueOf(jsonResults));
                    while (parserSR.nextToken() != null){
                        if ((parserSR.getCurrentToken() == JSONToken.FIELD_NAME) && (parserSR.getText() == 'request')) {
                            // Get the value.
                            parserSR.nextToken();
                            // Compute the grand total price for all invoices.
                            //sDescError = parserSR.getText();
                            casoSeg.SEG_Identificador_AOR__c=parserSR.getText();
                            casoSeg.Status = 'Pendiente';
                            casoSeg.SEG_Subestado__c = 'Envío pendiente de respuesta jurídica';
                        }
                    }

                    FeedItem feed = new FeedItem();
                    feed.ParentId = casoid; 
                    feed.Body = 'Adjuntos añadidos al caso de Asesoría Jurídica - ' + casoSeg.SEG_Identificador_AOR__c; 
                    insert feed;
                    //Update caso
                    update casoSeg;                                                                            
                }
            }
            else {
                sDescError = 'Error comunicaciones.';
                sDetalleError = response.getStatusCode() + ':' + response.getBody();
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = sDescError;
                oTraza.CC_DetalleError__c = sDetalleError;
            }
        } catch (Exception e) {
                sDescError = 'Error comunicaciones.';
                sDetalleError = e.getMessage();
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = sDescError;
                oTraza.CC_DetalleError__c = sDetalleError;
        }
        insert oTraza;       
    } 
    public class datosEnviarAdjuntoAOR {
        public String id_attachment;
        public String nombre_attachment;
        public String tipo_attachment;
    }
}