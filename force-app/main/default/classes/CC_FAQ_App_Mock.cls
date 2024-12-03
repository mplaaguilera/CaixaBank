@isTest
global with sharing class CC_FAQ_App_Mock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {

        String sFakeRespuesta = '';
        sFakeRespuesta = sFakeRespuesta + '{';
        sFakeRespuesta = sFakeRespuesta + '"idAplicacion":99999999,';
        sFakeRespuesta = sFakeRespuesta + '"nombre":"TestOnly",';
        sFakeRespuesta = sFakeRespuesta + '"codigo":"TestOnly",';
        sFakeRespuesta = sFakeRespuesta + '"aplicacionSiebel":"APP",';
        sFakeRespuesta = sFakeRespuesta + '"espacios":[';
        sFakeRespuesta = sFakeRespuesta + '{';
        sFakeRespuesta = sFakeRespuesta + '"idEspacio":"9999999915000012",';
        sFakeRespuesta = sFakeRespuesta + '"idArea":null,';
        sFakeRespuesta = sFakeRespuesta + '"espacio":"TestOnly",';
        sFakeRespuesta = sFakeRespuesta + '"descripcionEs":"TestOnly",';
        sFakeRespuesta = sFakeRespuesta + '"descripcionAreaEs":null,';
        sFakeRespuesta = sFakeRespuesta + '"descripcionCa":"TestOnly",';
        sFakeRespuesta = sFakeRespuesta + '"descripcionAreaCa":null,';
        sFakeRespuesta = sFakeRespuesta + '"area":null,';
        sFakeRespuesta = sFakeRespuesta + '"piloto":null,';
        sFakeRespuesta = sFakeRespuesta + '"pilotoSim":null,';
        sFakeRespuesta = sFakeRespuesta + '"aplicacion":null,';
        sFakeRespuesta = sFakeRespuesta + '"topics":null,';
        sFakeRespuesta = sFakeRespuesta + '"ha":null,';
        sFakeRespuesta = sFakeRespuesta + '"ca":null,';
        sFakeRespuesta = sFakeRespuesta + '"espacioCustoms":null,';
        sFakeRespuesta = sFakeRespuesta + '"idAplicacion":0,';
        sFakeRespuesta = sFakeRespuesta + '"listaAplicacionesEspacio":null,';
        sFakeRespuesta = sFakeRespuesta + '"idsGlobales":[';
//        sFakeRespuesta = sFakeRespuesta + '22,';
//        sFakeRespuesta = sFakeRespuesta + '23,';
        sFakeRespuesta = sFakeRespuesta + '24';
        sFakeRespuesta = sFakeRespuesta + ']';
        sFakeRespuesta = sFakeRespuesta + '}';
        sFakeRespuesta = sFakeRespuesta + ']';
        sFakeRespuesta = sFakeRespuesta + '';
        sFakeRespuesta = sFakeRespuesta + '}';

        // Crear respueta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(sFakeRespuesta);
        res.setStatusCode(200);
        return res;
    }
}