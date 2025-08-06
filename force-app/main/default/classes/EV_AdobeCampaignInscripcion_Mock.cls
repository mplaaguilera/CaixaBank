@isTest
global class EV_AdobeCampaignInscripcion_Mock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {

        String sRespuesta = '<?xml version=\'1.0\'?><SOAP-ENV:Envelope xmlns:xsd=\'http://www.w3.org/2001/XMLSchema\' xmlns:xsi=\'http://www.w3.org/2001/XMLSchema-instance\' xmlns:ns=\'urn:sfdc:TBL_SLFC_CAMPAIGN\' xmlns:SOAP-ENV=\'http://schemas.xmlsoap.org/soap/envelope/\'><SOAP-ENV:Body><inscriptionEventResponse xmlns=\'urn:sfdc:TBL_SLFC_CAMPAIGN\' SOAP-ENV:encodingStyle=\'http://schemas.xmlsoap.org/soap/encoding/\'><acresults xsi:type=\'ns:Element\' SOAP-ENV:encodingStyle=\'http://xml.apache.org/xml-soap/literalxml\'><acresults><global><code>200</code><exception></exception><message>OK</message></global></acresults></acresults></inscriptionEventResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';

        // Crear respueta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json;charset=UTF-8');
        res.setBody(sRespuesta);
        res.setStatusCode(200);
        return res;
    }
}