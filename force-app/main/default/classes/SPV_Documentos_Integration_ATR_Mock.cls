@isTest
global with sharing class SPV_Documentos_Integration_ATR_Mock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        String sRespuesta = '';
        sRespuesta = sRespuesta + '<?xml version="1.0"?>';
        sRespuesta = sRespuesta + '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:atr="https://extcaastb1.lacaixa.es/AttReclamacionesBusquedaReclamac/v1/BusquedaReclamac142/busquedaReclam/">';
        sRespuesta = sRespuesta + '<soapenv:Header/>';
        sRespuesta = sRespuesta + '<soapenv:Body>';
        sRespuesta = sRespuesta + '<return>';
        sRespuesta = sRespuesta + '<BeanBodyOutDocReclamacionSE>';
        sRespuesta = sRespuesta + '<listaDocumentos>';
        sRespuesta = sRespuesta + '<fechaRecepcion>20231121</fechaRecepcion>';
        sRespuesta = sRespuesta + '<nombreDocumento>Documento X</nombreDocumento>';
        sRespuesta = sRespuesta + '<ticketEER>TICKET123</ticketEER>';
        sRespuesta = sRespuesta + '<tipologia>Tipologia 1</tipologia>';
        sRespuesta = sRespuesta + '<enviarBdE>Y</enviarBdE>';
        sRespuesta = sRespuesta + '<idTipoDocumento>TIPO123</idTipoDocumento>';
        sRespuesta = sRespuesta + '<idDocumento>DOC456</idDocumento>';
        sRespuesta = sRespuesta + '</listaDocumentos>';
        sRespuesta = sRespuesta + '</BeanBodyOutDocReclamacionSE>';
        sRespuesta = sRespuesta + '</return>';
        sRespuesta = sRespuesta + '</soapenv:Body>';
        sRespuesta = sRespuesta + '</soapenv:Envelope>';
        
        // Crear respueta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(sRespuesta);
        res.setStatusCode(200);
        return res;
    }
}