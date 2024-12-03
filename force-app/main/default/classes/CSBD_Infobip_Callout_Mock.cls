@isTest
public class CSBD_Infobip_Callout_Mock implements HttpCalloutMock {
    private string status {set;get;}
    private string messageId {set;get;}
    private string deliveryStatus {set;get;}

    public CSBD_Infobip_Callout_Mock(String status, String messageId, String deliveryStatus) {
		this.status = status;
		this.messageId = messageId;
		this.deliveryStatus = deliveryStatus;
	}

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        if(this.status == 'SUCCESS'){
            res.setStatusCode(200);
            res.setBody('{"messages":[{"messageId":"'+this.messageId+'"}]}');
        } else if (this.status == 'ERROR'){
            res.setStatusCode(400);
            res.setBody('{"errorCode": "E400",'+
            '"description": "Request cannot be processed."}');
        }
     
        return res;
    }
}