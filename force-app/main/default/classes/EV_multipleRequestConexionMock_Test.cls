global class EV_multipleRequestConexionMock_Test implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;
     
    public EV_multipleRequestConexionMock_Test(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }
 
    public HTTPResponse respond(HTTPRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        if (mock != null) {
            return mock.respond(req);
        }
        return null;
    }
}