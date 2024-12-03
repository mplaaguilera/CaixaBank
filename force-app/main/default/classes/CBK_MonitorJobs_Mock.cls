@isTest
global class CBK_MonitorJobs_Mock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        string body;
		
        User usr = [Select Id from User LIMIT 1];
        
        if (req.getEndpoint().contains('7503Y00000TGeNyQAL ')) {
            body =        ' {';
            body = body + '  "id" : "7503Y00000TGeNyQAL ",';
            body = body + '  "operation" : "upsert",';
            body = body + '  "object" : "Case",';
            body = body + '  "createdById" : "' + usr.Id + '",';
            body = body + '  "createdDate" : "2020-09-29T06:06:52.000+0000",';
            body = body + '  "systemModstamp" : "2020-09-29T06:07:03.000+0000",';
            body = body + '  "state" : "JobComplete",';
            body = body + '  "concurrencyMode" : "Parallel",';
            body = body + '  "contentType" : "CSV",';
            body = body + '  "apiVersion" : 49.0,';
            body = body + '  "jobType" : "Classic",';
            body = body + '  "numberRecordsProcessed" : 419,';
            body = body + '  "numberRecordsFailed" : 0,';
            body = body + '  "retries" : 0,';
            body = body + '  "totalProcessingTime" : 0,';
            body = body + '  "apiActiveProcessingTime" : 0,';
            body = body + '  "apexProcessingTime" : 0';
            body = body + '}';               
        } else {
            body = 		 '{ ';
            body = body +'  "done" : false,';
            body = body +'  "nextRecordsUrl" : null,';
            body = body +'  "records" : [ {';
            body = body +'    "id" : "7503Y00000TGeNyQAL ",';
            body = body +'    "operation" : "upsert",';
            body = body +'    "object" : "Case",';
            body = body +'    "createdById" : "' + usr.Id + '",';
            body = body +'    "createdDate" : "2020-09-30T03:00:53.000+0000",';
            body = body +'    "systemModstamp" : "2020-09-30T03:01:04.000+0000",';
            body = body +'    "state" : "JobComplete",';
            body = body +'    "concurrencyMode" : "Parallel",';
            body = body +'    "contentType" : "CSV",';
            body = body +'    "apiVersion" : 49.0,';
            body = body +'    "jobType" : "Classic"';
            body = body +'  }]}';            
        }
        
        system.debug(body);
        
        
        res.setBody(body);            
        
        return res;
    }
}