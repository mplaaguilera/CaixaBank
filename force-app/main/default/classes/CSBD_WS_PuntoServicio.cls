@RestResource(urlMapping='/puntoServicio/*')
global with sharing class CSBD_WS_PuntoServicio extends CBK_HttpServiceIntegration_Abstract{
    

    @HttpPost
    global static void handlePuntoServicio() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            // Get the JSON body of the request
            String jsonBody = req.requestBody.toString();

            // Parse the JSON body into a Map<String, Object>
            ContactInfo contactInfo = (ContactInfo) JSON.deserialize(jsonBody, ContactInfo.class);
            CSBD_DetectarOportunidadesSimilares controller = CSBD_DetectarOportunidadesSimilares.getInstance(
                contactInfo.documentIds, //diferentes nif de diff titulares. 
                contactInfo.requestPrescriberId, 
                'Plataformas Hipotecarias Digitales'
            );
            Map<String, Object> respuesta = controller.buscarOportunidadSimilares();
            if(respuesta.get('success') != null && (Boolean)respuesta.get('success')){
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(respuesta));
            }else{
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(respuesta));
            }
        }
        catch(Exception e) {
            // Log the error
            System.debug('Error: ' + e.getMessage());
            // Return a 400 error
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Error: ' + e.getMessage());
            CBK_Log.error('CSBD_WS_PuntoServicio', 'handlePuntoServicio Error: ' + e.getMessage());
        }
        finally {
            // Log request and response
            logRequest(req, res);
        }    
              
    }

    private static void logRequest(RestRequest req, RestResponse res) {
        // Log the request
        CBK_Log.debug('CSBD_WS_PuntoServicio', 'handlePuntoServicio Request: ' + req.toString());
        CBK_Log.debug('CSBD_WS_PuntoServicio', 'handlePuntoServicio Response: ' + res.toString());
    }

    //Wrapper para mapear el objeto JSON
    public class ContactInfo {
        public String name;
        public String lastname;
        public Integer documentType;
        public List<String> documentIds;
        public String requestPrescriberId;     
    }
    
}