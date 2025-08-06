@isTest
public class SEG_MockHttpResponseGenerator implements HttpCalloutMock{
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;
    /*
    *
    * @methodName               SEG_MockHttpResponseGenerator
    * @received parameters      Integer code, String status, String body, Map<String, String> responseHeaders
    * @return                   HttpResponse response
    *
    */
    public SEG_MockHttpResponseGenerator(Integer code, String status, String body, Map<String, String> responseHeaders){
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }
    /*
    *
    * @methodName               mockResponse
    * @received parameters      HttpRequest request
    * @return                   HttpResponse response
    *
    */
    public HttpResponse respond(HttpRequest request) {
        HTTPResponse res = new HTTPResponse();
        if (request.getEndpoint().contains('tech/orqcor/predict')) {
            res.setBody('{"sr": "03934069", "model_name": "model-salesforce", "category": "Credit Cards", "categories": [{"category": "Tarjetas", "ratio": "0.57436"}, {"category": "Tarjetas-Alta tarjeta/ VIA T", "ratio": "0.26805"}, {"category": "Alfabético", "ratio": "0.06269"}, {"category": "Bastanteos", "ratio": "0.06056"}, {"category": "Tarjetas-Baja tarjeta/VIA T", "ratio": "0.01888"}], "attributes": {"text_regex": [{"name": "cif_regex", "value": "A-28010791"}]}, "text_vector_words": [0.0]}');
            res.setStatusCode(code);
            res.setStatus(status);
        }else if(request.getEndpoint().contains('detidi/predictscores')){
            res.setBody('{"sr": "03934195", "model_name": "model-salesforce", "category": "Robot No Clasificado", "categories": [{"category": "Tarjetas", "ratio": "0.40430"}, {"category": "Tarjetas-Alta tarjeta/ VIA T", "ratio": "0.21459"}, {"category": "Robot No Clasificado", "ratio": "0.17570"}, {"category": "Transferencias-Devolución/retrocesión transferencia", "ratio": "0.08676"}, {"category": "Tarjetas-Baja tarjeta/VIA T", "ratio": "0.02030"}], "attributes": {"text_regex": [{"name": "cif_regex", "value": "A-28010791"}]}, "text_vector_words": [0.0]}');
            res.setStatusCode(code);
            res.setStatus(status);
        }else if(request.getEndpoint().contains('operationalServices/cognitive/mails/categories')){
            res.setBody('{"sr": "03934069", "model_name": "model-salesforce", "category": "Credit Cards", "categories": [{"category": "Tarjetas", "ratio": "0.57436"}, {"category": "Tarjetas-Alta tarjeta/ VIA T", "ratio": "0.26805"}, {"category": "Alfabético", "ratio": "0.06269"}, {"category": "Bastanteos", "ratio": "0.06056"}, {"category": "Tarjetas-Baja tarjeta/VIA T", "ratio": "0.01888"}], "attributes": {"text_regex": [{"name": "cif_regex", "value": "A-28010791"}]}, "text_vector_words": [0.0]}');
            res.setStatusCode(code);
            res.setStatus(status);
        }else if(request.getEndpoint().contains('tech/evssbb/ServidorValija/api/connectorSalesforce/sendValijaSalesforce')){
            res.setBody('{"cat":"0.791","eng":"0.718","esp":"1.000","language":"esp"}');
            res.setStatusCode(code);
            res.setStatus(status);
        }
        return res;
    }    
  }