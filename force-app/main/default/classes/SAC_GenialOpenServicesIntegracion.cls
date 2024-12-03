/********************************************************************************************************
* Name: SAC_GenialOpenServicesIntegraciopn
*
* @description : Contiene las dos conexiones necesirias hacia Open Services para enviar los datos a documentAI.
* Serán lanzadas secuencialmente desde SAC_GenialOpenServices_Queueable
*
* Historial
*------------------------------------------------------------------
* VERSION        USER_STORY       AUTHOR         DATE         Description
* 1.0            US967489         Alex Pérez     05/08/24     Creación
********************************************************************************************************/
public with sharing class SAC_GenialOpenServicesIntegracion {


    /*****************************************************************************************
    * @description : Enviar los datos de la reclamación junto a los do-
    * cumentos que ya han sido previamente cargados en DocumentAI a través
    * de Open Services
    * 
    * Inputs: 
    *    @param listaDocumentos -> lista de respuestas de la integración de envioDocumento
    *    @param recordId -> Id de la reclamación
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR                 DATE         Description
    * 1.0            US977960         Alexandre Perez        05/08/24     Creación     
    *****************************************************************/
    public static void envioReclamacion(list<DocumentsInfo> listaDocumentos, Id recordId){
        //separador necesario para el método multipart auque se ha pactado enviar documento a documento para minimizar posibles problemas con límites de salesforce,

        //String boundary = '----------------------------' + DateTime.now().getTime();
        //String crlf = '\r\n';
        case reclamacion = [SELECT Id, description, subject, caseNumber FROM case 
                                WHERE Id = : recordId
                                WITH SECURITY_ENFORCED];

        RequestBody requestBody = new RequestBody();
        requestBody.claim.claimId = reclamacion.Id;
        //requestBody.claim.description = reclamacion.description;
        //lo pasamos como documento
        //requestBody.claim.description = null;
        requestBody.claim.caseNumber = integer.valueOf(reclamacion.caseNumber);
        //requestBody.claim.subject = reclamacion.subject;
        //lo pasamos como documentoS
        //requestBody.claim.subject = null;

        requestBody.attachedDocuments = listaDocumentos;

        string requestBodyJSON = JSON.serialize(requestBody);
        requestBodyJSON = requestBodyJSON.replace('attachedDocuments','AttachedDocuments');
        /*String cabecera =  boundary + crlf +
            'Content-Disposition: form-data; name="file"; filename="' + docu.title + '"' + crlf;
        //blob blCabecera = blob.valueof(cabecera);
        string bodyString = cabecera + EncodingUtil.base64Encode(docu.versionData);
        //bodyBlob = bodyBlob + partBlob;
        blob bodyBlob = blob.valueOf(bodyString);*/
        Map<String,string> mHeaders =  new  Map<String,string>();
        //mHeaders.put('Content-Type', 'application/json' + boundary);

        CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
        //reqWrapper.body = body;
        reqWrapper.intSetting = 'SAC_GenialOSEnviarRec';
        //reqWrapper.method = 'POST';
       //Map<String,String> mHeaders2 = new Map<String,String>();
        reqWrapper.mHeaders = mHeaders;
        reqWrapper.body = requestBodyJSON;
        HttpRequest req =  CBK_HttpServiceIntegration.getRequest(reqWrapper);
        //req.setBodyAsBlob(bodyBlob);
        HttpResponse resp = CBK_HttpServiceIntegration.callHttpService(req, '', 'SAC_GenialOSEnviarRec');
        
        if(resp.getStatusCode() == 204){
            //codigo poner ok la reclamación y marcarla a finalizada
            reclamacion.SAC_GenialEstado__c = 'SAC_001';
            reclamacion.SAC_Tipo_integracion_IA__c = 'OpenServices';
            //list<responseOK> rOK = (list<responseOK>)JSON.deserialize(req.getBody(), responseOK.class);
            //return rOK.get(0);
            //reclamacion.
            
            /*if(Schema.SobjectType.Case.isUpdateable() &&
            Schema.sObjectType.Case.isAccessible() &&
            Schema.sObjectType.Case.fields.SAC_Tipo_integracion_IA__c.isUpdateable() &&
            Schema.sObjectType.Case.fields.SAC_GenialEstado__c.isUpdateable()){
                update reclamacion;
            }*/
            //update reclamacion;
            SAC_GenialUtils.modificarInsertarObjetos(new list<Case>{reclamacion}, 'update');
            
        } else {
            //clase para generalizar el tratamiento de error durante el proceso
            SAC_GenialOpenServices_Queueable.errorEnvio(reclamacion);
            /* reclamacion.SAC_GenialEstado__c = 'SAC_004';
            string nombreCola = 'SAC_PendienteAsignar';
            QueueSobject cola = null;
            List<QueueSobject> colas = [SELECT QueueId FROM QueueSobject WHERE queue.DeveloperName = : nombreCola AND SobjectType = 'Case' LIMIT 1];
            if(!colas.isEmpty()){
                cola = colas[0];
            }
            reclamacion.OwnerId = cola.QueueId; */
            //codigo meter KO la reclamación
            //usar clase general en el queueable ya que podría ponerse a KO ya en el envío de documentos
            //con el framework la traza de error controlado será guardada en la cbk_log
            //responseKO rKO = (responseKO)JSON.deserealize(req.getBody(), responseKO.class);
            //return null;
        }
        //reclamacion.SAC_Tipo_integracion_IA__c = 'OpenServices';
        //Database.SaveResult resRec = Database.update(reclamacion);

    }

    /*****************************************************************************************
    @description : Enviar los docs asociados a la reclamación que acaba de llegar a DocumentAI
    * a través de Open Services
    *
    * Inputs:  
    *   @param doculink -> registro que liga el documento con la reclamación
    *
    * Output:
    *   @param DocumentsInfo -> JSON convertido a objeto de respuesta de la integración para luego
    *   utilizarlo en envioRec
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR                 DATE         Description
    * 1.0            US977960         Alexandre Perez        05/08/24     Creación     
    *****************************************************************/
    //public static ResponseOK envioDocumento(ContentDocumentLink doculink){
    public static DocumentsInfo envioDocumento(ContentDocumentLink doculink){
        //separador necesario para el método multipart auque se ha pactado enviar documento a documento para minimizar posibles problemas con límites de salesforce,

        String boundary = '----------------------------' + DateTime.now().getTime();
        String crlf = '\r\n';
        contentVersion docu = [SELECT Id, versionData, FileExtension, title, PathOnClient FROM contentVersion 
                                WHERE ContentDocumentId = : doculink.ContentDocumentId and IsLatest = true
                                WITH SECURITY_ENFORCED];

        //convertimos la cabecera a binario y luego a hexadecimal para poder concatenarlo con el fichero                        
        /*blob cabecera =  blob.valueOf(boundary + crlf +
            'Content-Disposition: form-data; name="file"; filename="' + docu.title + '"' + crlf);*/
        string cabecera = '--' + boundary + crlf +
            'Content-Disposition: form-data; name="Documents"; filename="' + docu.PathOnClient + '"';
         string cabeceraString = EncodingUtil.Base64Encode(
            blob.valueOf(cabecera + crlf + crlf)
        );

        //espaciar para rellenar aquellos que no hayan caido en un trio de byte. Como mucho debe meter 2 espacios
        while(cabeceraString.endsWith('='))
        {
            cabecera+=' ';
            cabeceraString = EncodingUtil.base64Encode(Blob.valueOf(cabecera+crlf+crlf));
        }
        /* string pieString = EncodingUtil.Base64Encode(
            blob.valueOf(crlf + '--' + boundary + '--' + crlf)
        ); */
        /* string cabeceraString = '--' + boundary + crlf +
            'Content-Disposition: form-data; name="Documents"; filename="' + docu.title + '"' + crlf + crlf;
        string */
        //string hexaCabecera = 
        //string bodyString = cabeceraString + pieString;
        //blob blCabecera = blob.valueof(cabecera);
        //string testblob = docu.versionData.toString();
        string body64 = EncodingUtil.base64Encode(docu.versionData);
        String ultimosBytes = body64.substring(body64.length()-4,body64.length());
        //si los saltos de pie no estan en el body hay que ponerlos en el pie antes de decodificar
        string saltosDepie = '';
        //mira si hay bytes por rellenar, un = por byte
        if(ultimosBytes.endsWith('==')){
            //metemos \r\n al final del binario en base64 para completar los bits que faltan para que sea par de 3
            ultimosBytes = ultimosBytes.substring(0,2) + '0K';
            //los dos saltos en el binario
        } else if(ultimosBytes.endsWith('=')){
            //metemos \n al final del binario en base64 para completar el bit que falta para que sea par de 3
            ultimosBytes = ultimosBytes.substring(0,3) + 'N';
            //uno de los saltos está en el binario
            saltosDepie = '\n';
        } else {
            saltosDepie = '\r\n';
            //ninguno de los saltos en el binario
        }
        
        string pieString = EncodingUtil.Base64Encode(
            blob.valueOf(crlf + '--' + boundary + '--' + crlf)
        );
        body64 = body64.substring(0,body64.length()-4) + ultimosBytes;
        string bodyString = cabeceraString + body64 + pieString;
        //Blob.concat(List<Blob>)
        //string bodyString = cabecera + testblob;
        //string bodyString = EncodingUtil.convertToHex(cabecera) + EncodingUtil.convertToHex(docu.versionData);
        //blanqueamos variables para evitar limites de tamaño
        /*String cacheKey = 'docContent_' + doculink.ContentDocumentId;
        Cache.Org.put(cacheKey, EncodingUtil.convertToHex(cabecera) + EncodingUtil.convertToHex(docu.versionData));
        docu.versionData = null;*/
        //bodyBlob = bodyBlob + partBlob;
        /*blob bodyBlob = EncodingUtil.convertFromHex((string)Cache.Org.get(cacheKey));
        bodyString*/
        //Cache.Org.remove(cacheKey);
        //Cache.Org.remove(EncodingUtil.base64Decode(bodyString));
        //blanqueamos variables para evitar limites de tamaño
        //bodyString = null;
        Map<String,string> mHeaders =  new  Map<String,string>();
        mHeaders.put('Content-Type', 'multipart/form-data; boundary=' + boundary);

        CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
        //reqWrapper.body = body;
        reqWrapper.intSetting = 'SAC_GenialOSEnviarDoc';
        //reqWrapper.method = 'POST';
       //Map<String,String> mHeaders2 = new Map<String,String>();
        reqWrapper.mHeaders = mHeaders;

        HttpRequest req =  CBK_HttpServiceIntegration.getRequest(reqWrapper);
        req.setBodyAsBlob(EncodingUtil.base64Decode(bodyString));
        //recuperar capacidad de la instancia
        bodyString = null;
        HttpResponse resp = CBK_HttpServiceIntegration.callHttpService(req, '', 'SAC_GenialOSEnviarDoc');

        if(resp.getStatusCode() == 200){    
            /* list<responseOK> rOK = (list<responseOK>)JSON.deserialize(resp.getBody(), list<responseOK>.class);
            return rOK.get(0); */
            responseOK rOK = (responseOK)JSON.deserialize(resp.getBody(), responseOK.class);
            return rOK.documentsInfo.get(0);
        } else {
            //con el framework la traza de error controlado será guardada en la cbk_log
            return null;
        }

    }

    //public static ResponseOK envioBody(Id recordId){
    public static DocumentsInfo envioBody(Id recordId){
        //separador necesario para el método multipart auque se ha pactado enviar documento a documento para minimizar posibles problemas con límites de salesforce,

        String boundary = '----------------------------' + DateTime.now().getTime();
        String crlf = '\r\n';
        Case reclamacion = [SELECT Id, Subject, Description FROM Case 
                                WHERE Id = : recordId
                                WITH SECURITY_ENFORCED];

        //como solo va a ser texto no hace falta paraslo a blob
        string cabeceraString = '--' + boundary + crlf +'Content-Disposition: form-data; name="Documents"; filename="' + 'body.txt' + '"' + crlf + crlf;
        string bodyString = cabeceraString + 'Subject: ' + reclamacion.Subject + crlf + 'Body: ' +reclamacion.Description + crlf + '--' + boundary + '--';

        Map<String,string> mHeaders =  new  Map<String,string>();
        mHeaders.put('Content-Type', 'multipart/form-data; boundary=' + boundary);

        CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
        reqWrapper.intSetting = 'SAC_GenialOSEnviarDoc';
        reqWrapper.mHeaders = mHeaders;

        HttpRequest req =  CBK_HttpServiceIntegration.getRequest(reqWrapper);
       /*  req.setHeader('boundary', boundary);
        req.setHeader('Content-Disposition', 'form-data');
        req.setHeader('name', 'file');
        req.setHeader('filename', 'body.txt'); */
        //req.setBody(bodyString);
        //req.setBodyAsBlob(Blob.valueof(bodyString));
        req.setBody(bodyString);
        //recuperar capacidad de la instancia
        bodyString = null;
        HttpResponse resp = CBK_HttpServiceIntegration.callHttpService(req, '', 'SAC_GenialOSEnviarDoc');

        if(resp.getStatusCode() == 200){    
            //list<responseOK> rOK = (list<responseOK>)JSON.deserialize(resp.getBody(), list<responseOK>.class);
            responseOK rOK = (responseOK)JSON.deserialize(resp.getBody(), responseOK.class);
            return rOK.documentsInfo.get(0);
        } else {
            //con el framework la traza de error controlado será guardada en la cbk_log
            return null;
        }

    }

    /*private class responseOKlist{
        responseO
    }*/
    //convertir en objeto request de segunda llamada
    public class DocumentsInfo {
        public string documentId;
        public string mimeTypeDesc;
        public string name;
    }

    //nuevo objeto
    public class ResponseOK {
        public list<DocumentsInfo> documentsInfo;
    }

    private class RequestBody {
        public Claim claim = new Claim();
        public list<DocumentsInfo> attachedDocuments = new list<DocumentsInfo>();

       /* public requestBody(){
            this.attachedDocuments = new list<SAC_GenialOSEnvioDocIntegracion.ResponseOK>();
        }*/
    }

    private class Claim {
        public string claimId;
        public string subject;
        public string description;
        public integer caseNumber;
    }

    /*private class ResponseKO {
        public string type;
        public string status;
        public string title;
        public string detail;
    }*/
}