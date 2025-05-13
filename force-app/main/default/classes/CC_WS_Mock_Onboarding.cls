@isTest
public with sharing class CC_WS_Mock_Onboarding implements HttpCalloutMock  {

    Integer statusCode;
    public CC_WS_Mock_Onboarding(Integer strStatusCode) {
        statusCode = strStatusCode;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();

        if (statusCode == 200) {
            String responseBody = '<?xml version="1.0" encoding="UTF-8"?>'
            + '<ResponseWrapper>'
            + '<Body>'
            + '<ConsultaEstadoSolicitudResponse>'
            + '<consultaEstadoSolicitudSalesforceResponse>'
            + '<resultado>'
            + '<codigo>1</codigo>'
            + '</resultado>'
            + '<empresa>CaixaBank</empresa>'
            + '<estado>Validación Vídeo Desasistida</estado>'
            + '<subestado>Validación Vídeo Desasistida</subestado>'
            + '<fechaEstado>11-10-2024 09:06:26</fechaEstado>'
            + '<fechaNacimiento>01-01-1974</fechaNacimiento>'
            + '<idReferencia>500501688</idReferencia>'
            + '<motivoCierre></motivoCierre>'
            + '<nombre>Juan Pineda Prado</nombre>'
            + '<numeroDocumento>29053641H</numeroDocumento>'
            + '</consultaEstadoSolicitudSalesforceResponse>'
            + '</ConsultaEstadoSolicitudResponse>'
            + '</Body>'
            + '</ResponseWrapper>';
    
    
            res.setBody(responseBody);
            res.setStatusCode(200);
        } else if (this.statusCode == 404) {
            String responseBody = '';
            res.setBody(responseBody);
            res.setStatusCode(404);
        }
        return res;
    }
}