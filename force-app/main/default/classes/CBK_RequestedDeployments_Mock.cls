@isTest
public class CBK_RequestedDeployments_Mock implements HttpCalloutMock {
    public HttpResponse respond(HTTPRequest req) {
        // Crea la respuesta simulada
        HttpResponse res = new HttpResponse();
        
        // Configura el código de estado y el contenido de la respuesta
        res.setHeader('Content-Type', 'application/json');
        
        //Dependiendo del endpoint se prepara una respuesta u otra
        if (req.getEndpoint().contains('tooling/sobjects/DeployRequest')) {
            res.setStatusCode(201);
            res.setBody('{"attributes":{"type":"DeployRequest","url":"/services/data/v58.0/tooling/sobjects/DeployRequest/0AfKA0000009OYj0AM"},"Id":"0AfKA0000009OYj0AM","IsDeleted":false,"CreatedDate":"2024-12-12T19:24:11.000+0000","CreatedById":"0051t000002cLWcAAM","LastModifiedDate":"2024-12-12T19:36:43.000+0000","LastModifiedById":"0051t000002cLWcAAM","SystemModstamp":"2024-12-12T19:36:43.000+0000","NumberComponentsDeployed":37,"NumberComponentErrors":0,"NumberComponentsTotal":37,"NumberTestsCompleted":103,"NumberTestErrors":0,"NumberTestsTotal":103,"CheckOnly":false,"IgnoreWarnings":true,"RollbackOnError":true,"Type":"Api","StartDate":"2024-12-12T19:24:11.000+0000","CompletedDate":"2024-12-12T19:36:43.000+0000","CanceledById":null,"RunTestsEnabled":true,"ChangeSetName":null,"ErrorStatusCode":null,"Status":"Succeeded","StateDetail":null,"ErrorMessage":null,"AllowMissingFiles":false,"AutoUpdatePackage":false,"PurgeOnDelete":false,"SinglePackage":true,"TestLevel":"RunSpecifiedTests"}');
        }else{
            res.setStatusCode(200);
            res.setBody('{"size":10,"totalSize":10,"done":true,"queryLocator":null,"entityTypeName":"DeployRequest","records":[{"attributes":{"type":"DeployRequest","url":"/services/data/v58.0/tooling/sobjects/DeployRequest/0AfKA0000009OYj0AM"},"Id":"0AfKA0000009OYj0AM","CreatedDate":"2024-12-12T19:24:11.000+0000"},{"attributes":{"type":"DeployRequest","url":"/services/data/v58.0/tooling/sobjects/DeployRequest/0AfKA0000009OW40AM"},"Id":"0AfKA0000009OW40AM","CreatedDate":"2024-12-12T18:46:00.000+0000"},{"attributes":{"type":"DeployRequest","url":"/services/data/v58.0/tooling/sobjects/DeployRequest/0AfKA0000009OTP0A2"},"Id":"0AfKA0000009OTP0A2","CreatedDate":"2024-12-12T13:35:24.000+0000"},{"attributes":{"type":"DeployRequest","url":"/services/data/v58.0/tooling/sobjects/DeployRequest/0AfKA0000009OQQ0A2"},"Id":"0AfKA0000009OQQ0A2","CreatedDate":"2024-12-12T11:41:13.000+0000"},{"attributes":{"type":"DeployRequest","url":"/services/data/v58.0/tooling/sobjects/DeployRequest/0AfKA0000009OOo0AM"},"Id":"0AfKA0000009OOo0AM","CreatedDate":"2024-12-11T17:04:46.000+0000"},{"attributes":{"type":"DeployRequest","url":"/services/data/v58.0/tooling/sobjects/DeployRequest/0AfKA0000009OOj0AM"},"Id":"0AfKA0000009OOj0AM","CreatedDate":"2024-12-11T17:04:30.000+0000"},{"attributes":{"type":"DeployRequest","url":"/services/data/v58.0/tooling/sobjects/DeployRequest/0AfKA0000009OOZ0A2"},"Id":"0AfKA0000009OOZ0A2","CreatedDate":"2024-12-11T16:09:14.000+0000"},{"attributes":{"type":"DeployRequest","url":"/services/data/v58.0/tooling/sobjects/DeployRequest/0AfKA0000009GtZ0AU"},"Id":"0AfKA0000009GtZ0AU","CreatedDate":"2024-12-03T17:33:19.000+0000"},{"attributes":{"type":"DeployRequest","url":"/services/data/v58.0/tooling/sobjects/DeployRequest/0AfKA0000009Gt50AE"},"Id":"0AfKA0000009Gt50AE","CreatedDate":"2024-12-03T17:08:42.000+0000"},{"attributes":{"type":"DeployRequest","url":"/services/data/v58.0/tooling/sobjects/DeployRequest/0AfKA00000098ep0AA"},"Id":"0AfKA00000098ep0AA","CreatedDate":"2024-11-26T18:50:09.000+0000"}]}');
        }
        return res;
    }
}