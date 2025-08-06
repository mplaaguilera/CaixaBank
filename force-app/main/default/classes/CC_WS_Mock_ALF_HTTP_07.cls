@isTest
global with sharing class CC_WS_Mock_ALF_HTTP_07 implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {

        // Respuesta con error.

        String sRespuesta = '';
        sRespuesta = sRespuesta + '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body>';
        sRespuesta = sRespuesta + '<soap:Fault><faultcode>soap:Server</faultcode><faultstring>Generic Error.</faultstring>';
        sRespuesta = sRespuesta + '<detail><AbsisError><type>SERVICE_ERROR</type><code>ALF2223C</code>';
        sRespuesta = sRespuesta + '<message>PERSONA NO ENCONTRADA</message><detail>Generic Error.</detail>';
        sRespuesta = sRespuesta + '<failPoint>SERVICE EXECUTION ERROR</failPoint>';
        sRespuesta = sRespuesta + '<requestId>c34f821e-47f1-4352-b307-6e16988e6895</requestId>';
        sRespuesta = sRespuesta + '<idExternOperacio>CBCCSF</idExternOperacio></AbsisError></detail>';
        sRespuesta = sRespuesta + '</soap:Fault></soap:Body></soap:Envelope>';

        // Crear respueta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(sRespuesta);
        res.setStatusCode(200);
        return res;
    }
}