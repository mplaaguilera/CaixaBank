@isTest
public class CBK_ToolingApiQuery_Mock implements HttpCalloutMock{
    
    public HttpResponse respond(HTTPRequest req) {
        // Crea la respuesta simulada
        HttpResponse res = new HttpResponse();
        
        // Configura el código de estado y el contenido de la respuesta
        res.setHeader('Content-Type', 'application/json');
        
        //Dependiendo del endpoint se prepara una respuesta u otra
        if (req.getEndpoint().contains('InvalidQuery')) {
            res.setStatusCode(400);
        }else{
            res.setStatusCode(200);
            res.setBody('{"size":10,"totalSize":10,"done":true,"queryLocator":null,"entityTypeName":"User","records":[{"attributes":{"type":"User","url":"/services/data/v58.0/tooling/sobjects/User/0AfKA0000009OYj0AM"},"Id":"0AfKA0000009OYj0AM","Name":"Name1"},{"attributes":{"type":"User","url":"/services/data/v58.0/tooling/sobjects/User/0AfKA0000009OW40AM"},"Id":"0AfKA0000009OW40AM","Name":"Name2"},{"attributes":{"type":"User","url":"/services/data/v58.0/tooling/sobjects/User/0AfKA0000009OTP0A2"},"Id":"0AfKA0000009OTP0A2","Name":"Name3"},{"attributes":{"type":"User","url":"/services/data/v58.0/tooling/sobjects/User/0AfKA0000009OQQ0A2"},"Id":"0AfKA0000009OQQ0A2","Name":"Name4"},{"attributes":{"type":"User","url":"/services/data/v58.0/tooling/sobjects/User/0AfKA0000009OOo0AM"},"Id":"0AfKA0000009OOo0AM","Name":"Name5"},{"attributes":{"type":"User","url":"/services/data/v58.0/tooling/sobjects/User/0AfKA0000009OOj0AM"},"Id":"0AfKA0000009OOj0AM","Name":"Name6"},{"attributes":{"type":"User","url":"/services/data/v58.0/tooling/sobjects/User/0AfKA0000009OOZ0A2"},"Id":"0AfKA0000009OOZ0A2","Name":"Name7"},{"attributes":{"type":"User","url":"/services/data/v58.0/tooling/sobjects/User/0AfKA0000009GtZ0AU"},"Id":"0AfKA0000009GtZ0AU","Name":"Name8"},{"attributes":{"type":"User","url":"/services/data/v58.0/tooling/sobjects/User/0AfKA0000009Gt50AE"},"Id":"0AfKA0000009Gt50AE","Name":"Name9"},{"attributes":{"type":"User","url":"/services/data/v58.0/tooling/sobjects/User/0AfKA00000098ep0AA"},"Id":"0AfKA00000098ep0AA","Name":"Name10"}]}');
        }
        
        return res;
    }

}