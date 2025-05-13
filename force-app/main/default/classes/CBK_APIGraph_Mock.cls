@isTest
global class CBK_APIGraph_Mock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        User usr = [Select Id from User LIMIT 1];
        
        if (req.getEndpoint().contains('forward')) {
            res.setStatusCode(202);
        }else{
            res.setStatusCode(200);
            res.setBody('{"accessToken" : "test"}');
        }
        
        return res;
    }
}