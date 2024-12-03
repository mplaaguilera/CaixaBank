public class CC_Llamada_Grabacion {

    @AuraEnabled
    public static String getGrabacion() {
        String ficheroBase64 = '';
        try {
            HttpRequest req = new HttpRequest(); 
            req.setMethod('GET');
            req.setEndpoint('https://file-examples.com/wp-content/uploads/2017/11/file_example_MP3_700KB.mp3');
            req.setHeader('Connection','keep-alive');
            //req.setHeader('Cookie','hcp-ns-auth=YzNjY3M4X2Z1bGw=:859303cc43b37af8da2a0b0f8eaddc3a');
            req.setHeader('content-type', 'audio/mpeg');
            Http http = new Http();
            HttpResponse res = http.send(req);  
            System.debug('STATUS:'+res.getStatus());
            System.debug('STATUS_CODE:'+res.getStatusCode());
            Blob ficheroBlob = res.getBodyAsBlob();
            ficheroBase64 = EncodingUtil.base64Encode(ficheroBlob);
        } catch(Exception e) {
            system.debug(e);
        }

        return ficheroBase64;
    }
    
}