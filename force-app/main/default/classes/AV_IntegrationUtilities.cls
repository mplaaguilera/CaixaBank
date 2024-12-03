/**********************************************************************************************************************
 Name:      AV_IntegrationUtilities
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de métodos útiles para las integraciones
=======================================================================================================================
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            Integrations     David Rufo       11/02/2020          Init version
   1.1            Integrations     David Rufo       11/02/2020          Methods for treatment the error response in the callouts
   1.2            Integrations     David Rufo       10/09/2020          New method for convert a number in hexadecimal
   1.3            Integrations     Álvaro López     29/09/2020          New method for fill with zero in side left
   1.4            Fix              Luis Fernández   11/07/2022          Changed AV_query to SOQL queries

***********************************************************************************************************************/
public with sharing class AV_IntegrationUtilities {

    /**
     * @description     Serialize object data
     * @param objData   info object
     * @return          string in format JSON
     **/
    public static String parseObjectToJson(Object objData){
        return System.JSON.serialize(objData);
    }

    /**
     * @description     Deserialize json data into class
     * @param jsonData  json file as a String
     * @param jsonType  json type of class result
     * @return          Object with the information -> casting to object wanted
     **/
    public static Object parseJsonToObject(String jsonData, String jsonType){
        Type typeClass = Type.forName(jsonType);
        return System.JSON.deserialize(jsonData, typeClass);
    }

    /**
     * @description     Format date with specific format
     * @param  dateIn   Data input with date (Date)
     * @param  format   Type format. Example: 'YYYY-MM-DD'
     * @return          string with date in string format
     */
    public static String formatDate(Date dateIn, String format){
        if (dateIn==null || String.isBlank(format)){
            return null;
        }
        Datetime dt = Datetime.newInstance(dateIn.year(), dateIn.month(), dateIn.day());
        return formatDate(dt,format);
    }

    /**
     * @description     Format date with specific format
     * @param  dateIn   Data input with date (Datetime)
     * @param  format   Type format. Example: 'YYYY-MM-DD'
     * @return          string with date in string format
     */
    public static String formatDate(Datetime dateIn, String format){
        if (dateIn==null || String.isBlank(format)){
            return null;
        }
        return dateIn.format(format);
    }

    /**
     * @description Check the current heap size
     * @return      -> true if the current size is upper than the limit
     */
    public static boolean statusHeapSize(){
        boolean status = Limits.getHeapSize()>Limits.getLimitHeapSize();
        AV_LogDebug.printLogDebug('statusHeapSize', 'Heap Size: ' + Limits.getHeapSize() + ' (' + Limits.getLimitHeapSize() + ') -> ' + status);
        return status;
    }

    /**
     * @description         Get name endpoint for callout
     * @param nameEndpoint  named credential for endpoint
     * @return              string with name complete of endpoint
     **/
    public static String getEndpoint(String nameEndpoint){
        return 'callout:'+nameEndpoint;
    }

    /**
     * @description         Add params to URL in the query
     * @param url           endpoint of web service
     * @param params        Parameters to include in the query string
     * @return              endpoint with params encode UTF-8
     **/
    public static String addQueryString(String url, Map<String,String> params){
        String urlAux = url;
        if (params!=null && !params.isEmpty()){
            if(!urlAux.contains(AV_AppConstants.QUESTION)){
                urlAux += AV_AppConstants.QUESTION;
            }
            String paramString = AV_AppConstants.EMPTY;
            for (String key : params.keySet()) {
                String value = params.get(key);
                paramString += key + AV_AppConstants.EQUAL + EncodingUtil.urlEncode(value, AV_IntegrationConstants.ENCONDING_UTF8) + AV_AppConstants.AMPERSAND;
            }
            paramString = paramString.substring(0, paramString.length()-1);
            urlAux += paramString;
        }
        return urlAux;
    }

    /**
     * @description             Retrieve the metadata of the interface
     * @param apiMetadataName   -> API name of the metadata callout
     * @return                  null if the metadata is not found or metadata found more than 1 element
     */
    public static CC_InterfaceSettings__mdt fetchMetadataInterface(String apiMetadataName){
        // List<CC_InterfaceSettings__mdt> listDataC2C = new AV_Query('CC_InterfaceSettings__mdt')
        //         .selectAllFields()
        //         .addConditionEq('DeveloperName', apiMetadataName)
        //         .run();

        List<CC_InterfaceSettings__mdt> listDataC2C = [SELECT 
        Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, CC_Activa__c, CC_Body__c, 
        CC_Certificado__c, CC_CharSet__c, CC_ContentType__c, CC_DiasRef__c, CC_EndPoint__c, CC_HttpRequest__c, CC_SoapAction__c,
        CC_TimeOut__c, CC_TipoPeticion__c, CC_TrazaActiva__c, CC_TrazaEntrada__c, CC_TrazaSalida__c, CC_ALF_CliConf__c,
        CC_CliConfiErr__c, CC_ACTION__c, CC_AFFECTEDEMAIL__c, CC_AFFECTEDPHONE__c, CC_CLASS__c, CC_ConvAmbito__c,
        CC_EXTERNALSYSTEM__c, CC_ITD_ITNINCIDENTINCI__c, CC_ITNESCENARIO__c, CC_ITNEVENTO__c, CC_ITNINCTYPE__c, 
        CC_ITNRELEVANTE__c, CC_ITNROL__c, CC_ORGID__c, CC_REPORTEDEMAIL__c, CC_REPORTEDPHONE__c, CC_SITEID__c, 
        CC_WORKLOG_ACTION__c, CC_WORKLOG_LOGTYPE__c, AV_Username__c, AV_Password__c
        FROM CC_InterfaceSettings__mdt 
        WHERE DeveloperName = :apiMetadataName ];
        CC_InterfaceSettings__mdt dataC2C = null;
        if (listDataC2C!=null && !listDataC2C.isEmpty() && listDataC2C.size()==1) {
            dataC2C = listDataC2C.get(0);
        }

        return dataC2C;
    }

    /**
     * @description     -> Handle exception error
     * @param methodName -> method name where happened the problem
     * @param e         -> exception throw
     * @return          -> list with 2 values: severity (position 0) and message (position 1)
     */
    public static List<String> handleExceptionError(String methodName, Exception e){
        List<String> result = new List<String>();
        AV_LogDebug.printException(methodName, e);
        AV_ApiCallout.ErrorMessage errorMsg = AV_ApiCallout.getDefaultMsgError(e.getMessage());
        result.add(errorMsg.severity);
        result.add(errorMsg.msg);
        return result;
    }

    /**
     * @description     -> Handle error messages
     * @param methodName -> method name where happened the problem
     * @param apiCallout -> callout executed for retrieve the error
     * @return          -> list with 2 values: severity (position 0) and message (position 1)
     */
    public static List<String> handleErrorMessages(String methodName, AV_ApiCallout apiCallout){
        List<String> result = new List<String>();
        AV_ApiCallout.ErrorMessage errorMsg = apiCallout.getMsgUserError();
        AV_LogDebug.printLogDebug(methodName, errorMsg.msg);
        result.add(errorMsg.severity);
        result.add(errorMsg.msg);
        return result;
    }

    /**
     * @description         -> Add node and value to DOM (XML)
     * @param xmlNode       -> XML node
     * @param nameNode      -> Name of the child
     * @param namespace     -> Namespace of the child
     * @param prefixNamespace   -> Prefix of namespace
     * @param valueOfNode   -> value of the node (optional)
     * @return              -> XML Node with the new node and value
     */
    public static Dom.XMLNode addDomXmlNode(Dom.XMLNode xmlNode, String nameNode, String namespace, String prefixNamespace, String valueOfNode){
        Dom.XMLNode result = xmlNode.addChildElement(nameNode, namespace, prefixNamespace);
        if (String.isNotBlank(valueOfNode)){
            result.addTextNode(valueOfNode);
        }
        return result;
    }
	
    
    /**
     * @description         -> Add node and value to DOM (XML)
     * @param xmlNode       -> XML node
     * @param nameNode      -> Name of the child
     * @param namespace     -> Namespace of the child
     * @param prefixNamespace   -> Prefix of namespace
     * @param valueOfNode   -> value of the node (optional)
     * @return              -> XML Node with the new node and value
    */ 
    public static Dom.XMLNode addDomXmlNode(Dom.XMLNode xmlNode, String nameNode, String namespace, String prefixNamespace, Integer valueOfNode){
        String strValue = '';
        if (valueOfNode!=null){
            strValue = String.valueOf(valueOfNode);
        }
        return addDomXmlNode(xmlNode,nameNode,namespace,prefixNamespace,strValue);
    }
	
    
    /**
     * @description         -> Add node and value to DOM (XML)
     * @param xmlNode       -> XML node
     * @param nameNode      -> Name of the child
     * @param namespace     -> Namespace of the child
     * @param prefixNamespace   -> Prefix of namespace
     * @param valueOfNode   -> value of the node (optional)
     * @return              -> XML Node with the new node and value
     */
    public static Dom.XMLNode addDomXmlNode(Dom.XMLNode xmlNode, String nameNode, String namespace, String prefixNamespace, Boolean valueOfNode){
        String strValue = '';
        if (valueOfNode!=null){
            strValue = String.valueOf(valueOfNode);
        }
        return addDomXmlNode(xmlNode,nameNode,namespace,prefixNamespace,strValue);
    }

    /**
     * @description     -> convert the long number to hexadecimal number
     * @param num       -> number in long format
     * @return          -> the number in hexadecimal
     */
    public static String convertToHexadecimal(Long num){
        integer rem;
        String str2='';
        String[] hex=new String[]{'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
        while(num>0){
            rem=(integer)Math.mod(num, 16);
            str2=hex[rem]+str2;
            num=num/16;
        }
        return str2;
    }

    /**
     * @description     Fill with zero in side left
     * @param data      string with value
     * @param length    max size
     * @return          return string with value
     **/
    public static String leftPadZero(String data, Integer length){
        if (data==null){
            return null;
        }
        Integer count = length - data.length();
        String ceros = '';
        String result = data;
        if (count >= 1){
            for(Integer i=0;i<count;i++){
                ceros += '0';
            }
            result = ceros + data;
        }
        return result;
    }

}