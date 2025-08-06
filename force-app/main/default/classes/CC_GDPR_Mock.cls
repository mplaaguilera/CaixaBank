@isTest
global with sharing class CC_GDPR_Mock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {

        String sFakeRespuesta = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><ns2:AltaSolicitudResponse xmlns:ns2="http://gdprderechos.gdprderechos.mca.si.absis.lacaixa.es/"><return><errorAlta/><idSolicitud>5483</idSolicitud><resultado>OK</resultado></return></ns2:AltaSolicitudResponse></soap:Body></soap:Envelope>';

        // Crear respuesta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody(sFakeRespuesta);
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
}