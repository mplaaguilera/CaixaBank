@isTest
global with sharing class CC_WS_Mock_FAQ_HTTP_02 implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {

        String sRespuesta = '';
sRespuesta = sRespuesta + '{"faqs":[{"idFaq":"993365200","texto":"FAQ Guiada de Prueba","textoParaUsuarioEs":"FAQ Guiada de Prueba","textoParaUsuarioCa":';
sRespuesta = sRespuesta + '"FAQ Guiada de Prova","link":"","idEspacio":"15000000","idTopic":"13830021","idFaqSiebel":"0","intents":';
sRespuesta = sRespuesta + '[{"idIntent":314375931,"intent":"FAQ_Guiada_de_Prueba_LOE","respuestaCortaEs":"<p>Se trata de una respuesta ';
sRespuesta = sRespuesta + 'corta de una FAQ guiada de prueba</p>","respuestaCortaCa":"<p{"idEspacio":"15000000","espacio":"liniaObertaWSLOE"';
sRespuesta = sRespuesta + ',"descripcionEs":"Línea Abierta de LOE","descripcionCa":"Línia Oberta de LOE"},"topics":[{"idTopic":"13830021","idEspacio":"15000000",';
sRespuesta = sRespuesta + '"topic":"LineaAbiertaLOE","descripcionEs":"Linea Abierta","descripcionCa":"","tfnoEs:"99999",tfnoCa:"88888"}]}';

        // Crear respueta mock.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(sRespuesta);
        res.setStatusCode(200);
        return res;
    }
}