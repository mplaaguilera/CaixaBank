public with sharing class SPV_Documentos_Integration_ATR{
    
    public static final String HEADER_CONTENT_TYPE 		= 'Content-Type';
    public static final String APPLICATION_JSON 		= 'application/json';
    private static final String SPV_GET_TICKETEER       = 'SPV_Get_TicketEER';
    private static final String SPV_POST_TICKETEER      = 'SPV_Post_TicketEER';
    
    
    public class TicketGetDocumentoResponse {
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public List<Documento> lstDocumentos;
    }
    public class Documento{
        @AuraEnabled
        public String fechaRecepcion;
        @AuraEnabled
        public String nombreDocumento;
        @AuraEnabled
        public String ticketEER;
        @AuraEnabled
        public String tipologia;
        @AuraEnabled
        public String enviarBdE;
        @AuraEnabled
        public String idTipoDocumento;
        @AuraEnabled
        public String idDocumento;
    }
    
    public class PostTicketResponse {
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public Documento documento;
    }
    
    //Integración con ATR para recuperar el ticketEER del documento que tenga la reclamación
    @AuraEnabled
    public static TicketGetDocumentoResponse getTicketEER(String idReclamacion){ //Identificador interno PJUATR para reclamaciones.
        
        TicketGetDocumentoResponse response = new TicketGetDocumentoResponse();
        // Wrapper
        Map<String, String> mapHeaders = new Map<String, String>();
        mapHeaders.put(HEADER_CONTENT_TYPE, 'text/xml');
        CBK_HttpServiceIntegration.RequestWapper reqWap = new CBK_HttpServiceIntegration.RequestWapper();
        reqWap.body = null;
        reqWap.intSetting = SPV_GET_TICKETEER;
        reqWap.method = 'GET';
        reqWap.mHeaders = mapHeaders;
        // Request
        HttpRequest request = new HttpRequest();
        if(!Test.isRunningTest()){
            request = CBK_HttpServiceIntegration.getRequest(reqWap);
            // Endpoint
            String endpoint = '';
            if(request.getEndpoint().contains('{idReclamacion}')){
                endpoint = request.getEndpoint().replace('{idReclamacion}', idReclamacion);
            }
            request.setEndpoint(endpoint);
        }
        // Mockup
        String dataMockup = '';
        //if(Test.isRunningTest()){
        dataMockup = createMock();
        // }
        HTTPResponse resp = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : CBK_HttpServiceIntegration.multiCallHttpService(request, idReclamacion, SPV_GET_TICKETEER);
        String statusCode = String.valueOf(resp.getStatusCode());        
        if(statusCode.equalsIgnoreCase('200')){
            response.statusCode = statusCode;
            String xmlResponse = resp.getBody();
            // Parsear el XML
            Dom.Document doc = new Dom.Document();
            doc.load(xmlResponse);
            // Extraer los valores del XML
            Dom.XMLNode rootNode = doc.getRootElement();
            Dom.XMLNode bodyNode = rootNode.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XMLNode returnNode = bodyNode.getChildElement('return', null);
            Dom.XMLNode beanBodyNode = returnNode.getChildElement('BeanBodyOutDocReclamacionSE', null);
            List<Documento> documentoList = new List<Documento>();
            // Loop en lista
            for (Dom.XMLNode listaDocumentosNode : beanBodyNode.getChildElements()) {
                if (listaDocumentosNode.getName() == 'listaDocumentos') {
                    Documento docItem = new Documento();
                    docItem.fechaRecepcion = listaDocumentosNode.getChildElement('fechaRecepcion', null).getText();
                    docItem.nombreDocumento = listaDocumentosNode.getChildElement('nombreDocumento', null).getText();
                    docItem.ticketEER = listaDocumentosNode.getChildElement('ticketEER', null).getText(); // TICKET EER
                    docItem.tipologia = listaDocumentosNode.getChildElement('tipologia', null).getText();
                    docItem.enviarBdE = listaDocumentosNode.getChildElement('enviarBdE', null).getText();
                    docItem.idTipoDocumento = listaDocumentosNode.getChildElement('idTipoDocumento', null).getText();
                    docItem.idDocumento = listaDocumentosNode.getChildElement('idDocumento', null).getText();
                    documentoList.add(docItem);
                }
            }
            response.lstDocumentos = documentoList;
            response.statusCode = '200';
            // Convertir JSON
            String jsonResponse = JSON.serialize(documentoList);
            
        }else{
            response.statusCode = statusCode;
            response.errorCode = 'Error en el servicio.';
            response.errorMessage = resp.getStatus() + ' (' + resp.getStatusCode() + ')'; 
        } 
        return response;
    }
    
    //Integracion con ATR para cargar el ticketEER que nos ha devuelto EER cuando hemos cargado el nuevo documento
    @AuraEnabled
    public static PostTicketResponse sendTicketEER(String ticketEER){
        
        PostTicketResponse response = new PostTicketResponse();
        // Wrapper
        CC_InterfaceSettings__mdt confInterfaz = SAC_Utils.getInterfazConfigBody(SPV_POST_TICKETEER);
        String body = confInterfaz.CC_Body__c.replace('****', ticketEER); 
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put(HEADER_CONTENT_TYPE, 'text/xml');
        CBK_HttpServiceIntegration.RequestWapper reqWap = new CBK_HttpServiceIntegration.RequestWapper();
        reqWap.body = body;
        reqWap.intSetting = SPV_POST_TICKETEER;
        reqWap.method = 'POST';
        reqWap.mHeaders = mapHeader;
        // Request
        HttpRequest request = new HttpRequest();
        if(!Test.isRunningTest()){
            request = CBK_HttpServiceIntegration.getRequest(reqWap);
        }
        // Mockup
        String dataMockup = '';
        //if(Test.isRunningTest()){
        dataMockup = createMock2();
        // }
        
        HTTPResponse resp = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : CBK_HttpServiceIntegration.callHttpService(request, ticketEER, SPV_POST_TICKETEER);
        String statusCode = String.valueOf(resp.getStatusCode());
        if(statusCode.equalsIgnoreCase('200') || statusCode.equalsIgnoreCase('201')){
            System.debug('*resp.getbody() '+resp.getbody());
            response.statusCode = statusCode;
            // Convertir JSON
            String jsonResponse = JSON.serialize(response);
            System.debug('*JSON ' + jsonResponse);
        }else{
            response.statusCode = statusCode;
            response.errorCode = 'Error en el servicio.';
            response.errorMessage = resp.getStatus(); 
        }
        return response;
    }
    private static String createMock2(){
        String dataMockup = '';
        dataMockup +='<?xml version="1.0"?>';
        dataMockup += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:atr="https://extcaastb1.lacaixa.es/AttReclamacionesBusquedaReclamac/v1/BusquedaReclamac142/busquedaReclam/">';
        dataMockup += '<soapenv:Header/>';
        dataMockup += '<soapenv:Body>';
        dataMockup += '<return>';
        dataMockup += '<BeanBodyOutDocReclamacionSE>';
        dataMockup += '<fechaRecepcion>20231121</fechaRecepcion>';
        dataMockup += '<nombreDocumento>Documento X</nombreDocumento>';
        dataMockup += '<ticketEER>TICKET123</ticketEER>';
        dataMockup += '<tipologia>Tipologia 1</tipologia>';
        dataMockup += '<enviarBdE>Y</enviarBdE>';
        dataMockup += '<idTipoDocumento>TIPO123</idTipoDocumento>';
        dataMockup += '<idDocumento>DOC456</idDocumento>';
        dataMockup += '</BeanBodyOutDocReclamacionSE>';
        dataMockup += '</return>';
        dataMockup += '</soapenv:Body>';
        dataMockup += '</soapenv:Envelope>';
        return dataMockup;
    }
    private static String createMock(){
        String dataMockup = '';
        dataMockup +='<?xml version="1.0"?>';
        dataMockup += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:atr="https://extcaastb1.lacaixa.es/AttReclamacionesBusquedaReclamac/v1/BusquedaReclamac142/busquedaReclam/">';
        dataMockup += '<soapenv:Header/>';
        dataMockup += '<soapenv:Body>';
        dataMockup += '<return>';
        dataMockup += '<BeanBodyOutDocReclamacionSE>';
        dataMockup += '<listaDocumentos>';
        dataMockup += '<fechaRecepcion>20231121</fechaRecepcion>';
        dataMockup += '<nombreDocumento>Documento X</nombreDocumento>';
        dataMockup += '<ticketEER>TICKET123</ticketEER>';
        dataMockup += '<tipologia>Tipologia 1</tipologia>';
        dataMockup += '<enviarBdE>Y</enviarBdE>';
        dataMockup += '<idTipoDocumento>TIPO123</idTipoDocumento>';
        dataMockup += '<idDocumento>DOC456</idDocumento>';
        dataMockup += '</listaDocumentos>';
        dataMockup += '<listaDocumentos>';
        dataMockup += '<fechaRecepcion>20231124</fechaRecepcion>';
        dataMockup += '<nombreDocumento>Documento Y</nombreDocumento>';
        dataMockup += '<ticketEER>TICKET444</ticketEER>';
        dataMockup += '<tipologia>Tipologia 1</tipologia>';
        dataMockup += '<enviarBdE>Y</enviarBdE>';
        dataMockup += '<idTipoDocumento>TIPO123</idTipoDocumento>';
        dataMockup += '<idDocumento>DOC456</idDocumento>';
        dataMockup += '</listaDocumentos>';
        dataMockup += '</BeanBodyOutDocReclamacionSE>';
        dataMockup += '</return>';
        dataMockup += '</soapenv:Body>';
        dataMockup += '</soapenv:Envelope>';
        return dataMockup;
    }
    
    
    /**
* @description Generate the response for the mockup data
*/
    private static HTTPResponse getDataMockup(String dataMockup){
        
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(Integer.valueOf('200'));
        res.setStatus('OK');
        res.setBody(dataMockup);
        return res;
    }
    
    /**
* @description Convertir en objeto el json de la response
*/
    /*private static Object getBodyResponse(String response, String clazzName){
Object result = parseJsonToObject(response, clazzName);
return result;
}*/
    
    /**
* @description Convertir en objeto el json de la response
*/
    /*private static Object parseJsonToObject(String jsonData, String jsonType){
Type typeClass = Type.forName(jsonType);
return System.JSON.deserializeStrict(jsonData, typeClass);
}

static public List<String> extraerTicketEER (String sXMLData){        

List<String> lstTicketEER = new List<String>();

return lstTicketEER;
}*/
}