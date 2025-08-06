@isTest
public class CBK_HttpService_Mock_TEST implements HttpCalloutMock {
	protected HttpRequest request { get; set; }
	protected HttpResponse response { get; set; }

	protected String endPointMock;
	protected String typeCallMock;
	protected String bodyMock;
	protected Integer statusCodeMock;

	public CBK_HttpService_Mock_TEST(String endPM, String bodyM, String typeCM, Integer statusCM) {
		this.endPointMock = endPM;
		this.bodyMock = bodyM;
		this.typeCallMock = typeCM;
		this.statusCodeMock = statusCM;
	}

	public CBK_HttpService_Mock_TEST(HttpResponse response) {
	System.debug('ffsfdasdfasdfadsfa');
		this.response = response;
	}

	public HTTPResponse respond(HTTPRequest req) {
		if (response == null) {
			// Create a fake response	
			response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody(bodyMock);
			response.setStatusCode(statusCodeMock);
		}

		return response;
	}
}