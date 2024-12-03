/*****************************************************************
* Name: SAC_GenialOSEnvioRecIntegracion
* Copyright © 2024  CaixaBank
* 
* @description : Enviar los datos de la reclamación junto a los do-
* cumentos que ya han sido previamente cargados en DocumentAI a través
* de Open Services
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR                 DATE         Description
* 1.0            US977960         Alexandre Perez        29/07/24     Creación     
*****************************************************************/
public with sharing class SAC_GenialOSEnvioRecIntegracion {

    public static void callout(list<SAC_GenialOSEnvioDocIntegracion.ResponseOK> listaDocumentos, Id recordId){
        //separador necesario para el método multipart auque se ha pactado enviar documento a documento para minimizar posibles problemas con límites de salesforce,

        //String boundary = '----------------------------' + DateTime.now().getTime();
        //String crlf = '\r\n';
        case reclamacion = [SELECT Id, description, subject, caseNumber FROM case 
                                WHERE Id = : recordId
                                WITH SECURITY_ENFORCED];

        RequestBody requestBody = new RequestBody();
        requestBody.claim.claimId = reclamacion.Id;
        requestBody.claim.description = reclamacion.description;
        requestBody.claim.caseNumber = integer.valueOf(reclamacion.caseNumber);
        requestBody.claim.subject = reclamacion.subject;

        requestBody.attachedDocuments = listaDocumentos;

        string requestBodyJSON = JSON.serialize(requestBody);
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
        system.debug(req.getBody());
        system.debug(resp.getBody());
		system.debug(resp.getStatusCode());
        
        if(resp.getStatusCode() == 204){
            //codigo poner ok la reclamación y marcarla a finalizada
            system.debug('OK');
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
            system.debug('KO');
            //return null;
        }
        //reclamacion.SAC_Tipo_integracion_IA__c = 'OpenServices';
        //Database.SaveResult resRec = Database.update(reclamacion);

    }

    /*private class responseOKlist{
        responseO
    }*/
    //convertir en objeto request de segunda llamada
    public class ResponseOK {
        public string documentId;
        public string mimeTypeDesc;
        public string name;
    }

    private class RequestBody {
        public Claim claim = new Claim();
        public list<SAC_GenialOSEnvioDocIntegracion.ResponseOK> attachedDocuments = new list<SAC_GenialOSEnvioDocIntegracion.ResponseOK>();

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