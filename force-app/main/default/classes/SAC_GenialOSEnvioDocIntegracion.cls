/*****************************************************************
* Name: SAC_GenialOSEnvioDoc_Integracion
* Copyright © 2024  CaixaBank
* 
* @description : Enviar los docs asociados a la reclamación que acaba de llegar a DocumentAI
* a través de Open Services
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR                 DATE         Description
* 1.0            US977960         Alexandre Perez        23/07/24     Creación     
*****************************************************************/
public with sharing class SAC_GenialOSEnvioDocIntegracion {

    public static ResponseOK callout(ContentDocumentLink doculink){
        //separador necesario para el método multipart auque se ha pactado enviar documento a documento para minimizar posibles problemas con límites de salesforce,

        String boundary = '----------------------------' + DateTime.now().getTime();
        String crlf = '\r\n';
        contentVersion docu = [SELECT Id, versionData, FileExtension, title FROM contentVersion 
                                WHERE ContentDocumentId = : doculink.ContentDocumentId and IsLatest = true
                                WITH SECURITY_ENFORCED];

        //convertimos la cabecera a binario y luego a hexadecimal para poder concatenarlo con el fichero                        
        /*blob cabecera =  blob.valueOf(boundary + crlf +
            'Content-Disposition: form-data; name="file"; filename="' + docu.title + '"' + crlf);*/
        string cabeceraString = EncodingUtil.Base64Encode(
            blob.valueOf(boundary + crlf +
            'Content-Disposition: form-data; name="file"; filename="' + docu.title + '"' + crlf)
        );
        //string hexaCabecera = 

        //blob blCabecera = blob.valueof(cabecera);
        //string testblob = docu.versionData.toString();
        string bodyString = cabeceraString + EncodingUtil.base64Encode(docu.versionData);
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
        HttpResponse resp = CBK_HttpServiceIntegration.callHttpService(req, '', 'SAC_GenialOSEnviarDoc');

        if(resp.getStatusCode() == 200){    
            list<responseOK> rOK = (list<responseOK>)JSON.deserialize(resp.getBody(), list<responseOK>.class);
            return rOK.get(0);
        } else {
            //con el framework la traza de error controlado será guardada en la cbk_log
            return null;
        }

    }

    /*private class responseOKlist{
        responseO
    }*/

    public class ResponseOK {
        public string documentId;
        public string mimeTypeDesc;
        public string name;
    }

    /*private class ResponseKO {
        public string type;
        public string status;
        public string title;
        public string detail;
    }*/

}