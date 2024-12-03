public with sharing class SPV_RQ_Documentos_Integration {
    
    public static String generateBody(String boundary, ContentVersion conVersion){
    
        String body = '';
        body += '--' + boundary + '\r\n';
        body += 'Content-Disposition: form-data; name="document"\r\n\r\n';

        // Metadata
        body += '{"metadata":{';
        body += '"documentId":166545614,';
        body += '"version":1,';
        body += '"format":"pdf",'; //Requerido conVersion.FileType
        body += '"catalogueId":4195,'; //Requerido -> Preguntar como lo recuperamos
        body += '"documentDescription":"Example document description",';
        body += '"monthReference":"JANUARY_01",';
        body += '"yearReference":"2023",';
        body += '"originId":"OUTSOURCED_SERVICE_14",';
        body += '"securityLevel":"PUBLIC_0",';
        body += '"valijaSignal":"NOT_VALIJA_APPLICATION",';
        body += '"ticketOCP":6287722695164947905';
        body += '},';

        // Relation
        body += '"relation":{';
        body += '"operation":9999700044332,';
        body += '"customerInternalId":214759120,';
        body += '"applicationXFile":"SRC",';
        body += '"extReferenceXFile":"EXAMPLE_EXT_REF"';
        body += '},';

        // Transaction
        body += '"transaction":{';
        body += '"application":"SRC",'; // Requerido:	application  Siglas de vuestra aplicación. Por ejemplo: “EER” (Expediente Electrónico de Riesgo)
        body += '"branchId":9712,'; // Requerido: -	branchId  Numeración del centro desde el que realizáis la consulta. Si no aplica informad “9712” como indica el ejemplo.
        body += '"uploadDate":1675209600000,';
        body += '"language":"SPANISH",';
        body += '"enterprise":"001",';
        body += '"accessId":"142"';
        body += '}';

        // Include other properties here similarly...

        body += '}\r\n';

        // Archivo binario (aquí deberías añadir el contenido real del archivo)
        body += '--' + boundary + '\r\n';
        //recuperar el titulo
        body += 'Content-Disposition: form-data; name="file"; filename="'+conVersion.Title+'.'+conVersion.FileType+'"\r\n';
        body += 'Content-Type: application/pdf\r\n\r\n';
        //conVersion recuperar el binario
        Blob fileContent = conVersion.VersionData;
        // Aquí convertirás el Blob a String
        String binario = EncodingUtil.base64Encode(fileContent);
        body +=  binario +'\r\n'; 
        body += '--' + boundary + '--\r\n';

        return body;
    }
}