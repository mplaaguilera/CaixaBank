@IsTest
public with sharing class SIR_cls_WS_procesosAgenciasMock implements HttpCalloutMock {

    public static final String RESPONSE_AGENCIAS_OK  =   '{"info":{"codigo":1,"mensaje":null,"descripcion":"Informacion del proceso"},"metadatos":{"fechaPeticion":"Tue May 21 11:35:53 CEST 2024","idioma":"es"},"respuesta":{"idActividad":162907039}}';
    public static final String RESPONSE_AGENCIAS_NOK =   '{"info":{"codigo": 0,"descripcion": "Prueba Error","mensaje": "Error de conexión"},"metadatos": {"fechaPeticion": "","idioma": ""},"respuesta": {}}';
    public static final String RESPONSE_AGENCIAS_ERROR = '{"info":{"codigo": 2,"descripcion": "Prueba Error","mensaje": "Error de conexión"},"metadatos": {"fechaPeticion": "","idioma": ""},"respuesta": {}}';
    public HTTPResponse respond(HTTPRequest req) {

        SIR_cls_WS_procesosAgencias.ProcesosAgenciasRequest request = (SIR_cls_WS_procesosAgencias.ProcesosAgenciasRequest)JSON.deserialize(req.getBody(), SIR_cls_WS_procesosAgencias.ProcesosAgenciasRequest.class);
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        Map<String, Object> respMap = new  Map<String, Object>();

        response.setHeader('Content-Type', 'application/json');        
        
        ///ENCRIPTAR con clave de clase constante para el test
        Blob bKey = EncodingUtil.base64Decode(SIR_Constantes.KEY_NUMPERSO_TEST);
        Blob decrypted = Crypto.decryptWithManagedIV('AES128', bKey, request.idPersona);

        if(decrypted.toString() == 'OK'){
            response.setStatusCode(200);
            response.setBody(RESPONSE_AGENCIAS_OK);
        } else if(decrypted.toString() == 'ERROR'){
            response.setStatusCode(200);
            response.setBody(RESPONSE_AGENCIAS_ERROR);        
        }else if(decrypted.toString() == 'NOK'){
            response.setStatusCode(500);   
            response.setBody(RESPONSE_AGENCIAS_NOK);
        }
        
        return response;

    }
}