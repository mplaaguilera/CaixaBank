public with sharing class SEG_AOR_addComment {
    public static void SEG_AOR_addCommentSend(id casoid, String comentario) {
        String sDescError = '';
        String sDetalleError = '';
        CC_TrazaInt__c oTraza;
        
        List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
        
        oTraza = new CC_TrazaInt__c();
                        oTraza.Name = 'SEG_AOR_addComment';
                        oTraza.CC_FechaInicio__c = datetime.now();
    

        Case casoSeg=new Case();
        casoSeg=[SELECT Id,OwnerId, SEG_Numero_centro__c, Account.Name, Account.CC_Numero_Documento__c,SEG_Consulta_AOR__c,SEG_Identificador_AOR__c,SEG_Comentario_AOR__c FROM Case WHERE id=:casoid];

        User oUser = new User();
        String matricula = '';
        if (casoSeg.OwnerId != null)
        {
            oUser = [SELECT Id, FederationIdentifier, EmployeeNumber FROM User WHERE Id = : casoSeg.OwnerId];
            matricula = oUser.EmployeeNumber;
        }
        DatosEnvioComentarioAOR sendComment = new DatosEnvioComentarioAOR();
        sendComment.user = matricula;
        sendComment.comment = comentario;
        sendComment.caseId = casoid;

        String jsonToCognitive = JSON.serialize(sendComment);
        //espacio para lanzar llamada HHTP

        // Custom Setting
        String intSetting = 'SEG_AOR_Comment';
        
        try {
            // Crear HEADER
            Map<String,string> mHeaders =  new  Map<String,string>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

            CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
            requestWrp.body = jsonToCognitive;
            requestWrp.intSetting = intSetting;
            requestWrp.method = 'PUT';
            requestWrp.mHeaders = mHeaders;
            requestWrp.mUriParams = null;
            requestWrp.mQueryParams = null;

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
                            //casoSeg.SEG_Identificador_AOR__c=parserSR.getText();
                            casoSeg.SEG_Comentario_AOR__c = comentario;
                            casoSeg.Status = 'Pendiente';
                            casoSeg.SEG_Subestado__c = 'Envío pendiente de respuesta jurídica';
                        }
                    }

                    FeedItem feed = new FeedItem();
                    feed.ParentId = casoid; 
                    feed.Body = 'Comentario añadido al caso de Asesoría Jurídica - ' + comentario; 
                    insert feed;
                    update casoSEG;                                                                           
                    
                }
                
            }
            else {
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = 'Error comunicaciones.';
                oTraza.CC_DetalleError__c = response.getStatusCode() + ':' + response.getBody();
                
            }
        } catch (Exception e) {
                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = 'Error comunicaciones.';
                oTraza.CC_DetalleError__c = e.getMessage();
        }
        insert oTraza;       
    } 
    public class DatosEnvioComentarioAOR {
        public String user; //Opcional
        public String comment; 
        public String caseId;
    }
}