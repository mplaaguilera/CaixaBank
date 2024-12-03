@isTest
global class KIN_PurecloudConversationApi_Mock implements HttpCalloutMock {

    global HttpResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('{"participants":[{"attributes":{"casoId":"5005E00000HdCPFQA3","agenteDestinoId":"0053Y00000ALRTSQA5"}}]}');
        return res;
    }

}