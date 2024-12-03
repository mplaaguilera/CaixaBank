/**********************************************************************************************************************
 Name:    AV_AdobeCampaingnCJ_Integration
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración con API para Customer Journeys
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY      AUTHOR              DATE                Description
    1.0         App FSC         Jashanpreet         18/11/2020          Init version
    1.1         US251016        Víctor Santiago     31/08/2021          Replaced Name and AV_CJName__c values with each other
    1.2         Hotfix          Víctor Santiago     22/09/2021          Added CustomSetting AdobeToken in syncCJ method
	1.3         Hotfix          David Rufo     		25/09/2021          Check login process and update class
    1.4         Fix Unexp.char. Víctor Santiago     12/01/2021          Fix for unexpected character in syncCJ() errorMessage : SOAP-ENV:Server
    1.5         Hotfix          Víctor Santiago     21/03/2022          Deleted login retry process in syncCJ method
    1.6         US609232        Oscar Moreno        13/06/2023          The class is commented out to avoid making the unnecessary calls to Adobe Campaign

***********************************************************************************************************************/
public with sharing class AV_AdobeCampaingnCJ_Integration {

   
    public class Response {
    	public String statusCode;
    	public String errorMessage;
      	public String errorCode;
  	}
    
    
   public static Map<String,String> login(){
    	String methodName = 'login';
        AV_LogDebug.printLogDebug(methodName, '------------------------> Login process');
    
        //String mockString = '<SOAP-ENV:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="urn:xtk:session" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><LogonResponse SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns="urn:xtk:session"><pstrSessionToken xsi:type="xsd:string">___4ad6754e-cdd4-4e28-a4a8-c61b2f901361</pstrSessionToken><pSessionInfo xsi:type="ns:Element" SOAP-ENV:encodingStyle="http://xml.apache.org/xml-soap/literalxml"><sessionInfo><serverInfo advisedClientBuildNumber="8896" allowSQL="false" buildNumber="8896" commitId="507e44c" databaseId="u0A7706282AAEBDAE" defaultNameSpace="cxb" instanceName="marketingdev" majNumber="6" minClientBuildNumber="8767" minNumber="7" minNumberTechnical="0" securityTimeOut="86400" serverDate="2018-05-07 09:34:52.331Z" servicePack="0" sessionTimeOut="86400" useVault="false"/><userInfo datakitInDatabase="true" homeDir="" instanceLocale="en-GB" locale="en-GB" login="username" loginCS="username" loginId="238250" noConsoleCnx="false" orgUnitId="0" theme="" timezone="Europe/Madrid"><login-group id="1053"/><login-group id="3457"/><login-right right="admin"/><installed-package name="sftpPackage" namespace="ace"/><installed-package name="apiToolkit" namespace="acx"/><installed-package name="configurationManager" namespace="acx"/><installed-package name="core" namespace="acx"/><installed-package name="fileManager" namespace="acx"/><installed-package name="cxb_PFS" namespace="cxb"/><installed-package name="cxb_PKG4" namespace="cxb"/><installed-package name="content" namespace="ncm"/><installed-package name="aamIntegration" namespace="nms"/><installed-package name="azuredw" namespace="nms"/><installed-package name="billing" namespace="nms"/><installed-package name="campaign" namespace="nms"/><installed-package name="centralLocal" namespace="nms"/><installed-package name="core" namespace="nms"/><installed-package name="coreInteraction" namespace="nms"/><installed-package name="country" namespace="nms"/><installed-package name="federatedDataAccess" namespace="nms"/><installed-package name="folder" namespace="nms"/><installed-package name="hive" namespace="nms"/><installed-package name="interaction" namespace="nms"/><installed-package name="interactionControl" namespace="nms"/><installed-package name="japanLoc" namespace="nms"/><installed-package name="macIntegration" namespace="nms"/><installed-package name="messageCenter" namespace="nms"/><installed-package name="messageCenterControl" namespace="nms"/><installed-package name="midEmitter" namespace="nms"/><installed-package name="mobile" namespace="nms"/><installed-package name="mobileApp" namespace="nms"/><installed-package name="mrm" namespace="nms"/><installed-package name="paper" namespace="nms"/><installed-package name="phone" namespace="nms"/><installed-package name="report" namespace="nms"/><installed-package name="response" namespace="nms"/><installed-package name="ruleset" namespace="nms"/><installed-package name="simulation" namespace="nms"/><installed-package name="social" namespace="nms"/><installed-package name="survey" namespace="nms"/><installed-package name="systemStrings" namespace="nms"/><installed-package name="webAnalytics" namespace="nms"/><installed-package name="core" namespace="xtk"/></userInfo></sessionInfo></pSessionInfo><pstrSecurityToken xsi:type="xsd:string">@3PKpbKVopBgCEtXl7jkfsil3d_S-su4FQU-mqeay9_R7aywbl4CKhUqH_a_IK7OlcQXligoucslvFnnZUxNbsYk9L18uRgcYkjiC8DT9FU4=</pstrSecurityToken></LogonResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
        Map<String,String> token = new Map<String,String>();
        Response resultMethod = new Response();
        
        /*CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_CustomerJourney');
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        String body = buildCallRequestBodyLogin(dataInterface);
        Map<String, String> mapHeader = buildHeaderRequest('"xtk:session#Logon"');

        
        /*if (executeAPICall){
            AV_ApiCallout apiCallout = new AV_ApiCallout()
                  .setIsActive(dataInterface.CC_Activa__c)
                  .setMethod(dataInterface.CC_TipoPeticion__c)
                  .setEndpoint(dataInterface.CC_EndPoint__c) 
                  .setCertificate(dataInterface.CC_Certificado__c)
                  .setHeaders(mapHeader)
                  .setBody(body)
                  //.addContentTypeJsonHeader()
                  .debugMode()
                  //.setDataMockup(mockString)
                  .runCallout();
            AV_LogDebug.printLogDebug(methodName, '*****************************************');
            AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
    
            //Check errors:
            resultMethod.statusCode = apiCallout.getStatusCodeResponse();
            resultMethod.errorMessage = apiCallout.getErrorResponse();
            resultMethod.errorCode = apiCallout.getStatusCodeResponse();
            boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        
            if(reqStatusOK){
                DOM.Document document = new DOM.Document();
                document.load(apiCallout.getBodyResponse());
                for(Dom.XmlNode response : document.getRootElement().getChildElements()) {
                    for(Dom.XmlNode responseNode : response.getChildElements()) {
                        if(responseNode.getName() == 'Fault') {
                              insertErrorCJ( 'Login', 'errorMessage : ' + responseNode.getChildElement('faultcode',null).getText());
                        }
                        else if(responseNode.getName() == 'LogonResponse'){
                            for(Dom.XmlNode responseNode2 : responseNode.getChildElements()){
                                if(responseNode2.getName() == 'pstrSessionToken'){
                                    token.put('pstrSessionToken',responseNode2.getText());
                                }
                                if(responseNode2.getName() == 'pstrSecurityToken'){
                                    token.put('pstrSecurityToken',responseNode2.getText());
                                }
                            }
                        }              
                    }
                }
              }
              AV_LogDebug.printLogDebug(methodName, 'Request status: ' + +reqStatusOK);
            }*/
              return token;
    }
    
    

  	/*public static String lookUpCJ(String numperso, Map<String,String> token){
        String methodName = 'lookUpCJ';
        AV_LogDebug.printLogDebug(methodName, '------------------------> lookUpCJ process');
      
        //String mockString = '<SOAP-ENV:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="urn:nms:recipient" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><lookUpCJResponse SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns="urn:nms:recipient"><acresults xsi:type="ns:Element" SOAP-ENV:encodingStyle="http://xml.apache.org/xml-soap/literalxml"><acresults><global><code>0</code><exception/><message>Success</message></global><acresult><code>0</code><exception/><message>Success</message><result><![CDATA[<recipient id="36909131" numperso="6916916"><FK_Recipient_LookUpCJs boapId="62000" status="0"><FK_LookUpCJs_Boap document="" duration="0" id="62000" label="CA 03 -DL - Resto Click &amp; GO"><FK_BriefOnPage_ProductGroup><FK_Recipient_LookUpCJs><FK_LookUpCJs_Boap productGroupName="Préstamos"/></FK_Recipient_LookUpCJs></FK_BriefOnPage_ProductGroup><FK_BriefOnPage_ProductSubGroup><FK_Recipient_LookUpCJs><FK_LookUpCJs_Boap productSubGroupName="Préstamo personal"/></FK_Recipient_LookUpCJs></FK_BriefOnPage_ProductSubGroup></FK_LookUpCJs_Boap></FK_Recipient_LookUpCJs></recipient>]]></result></acresult><acresult><code>0</code><exception/><message>Success</message><result><![CDATA[<recipient id="42319444" numperso="6916916"><FK_Recipient_LookUpCJs boapId="51000" status="0"><FK_LookUpCJs_Boap document="" duration="0" id="51000" label="CA 03 -DL - Resto Click &amp; GO"><FK_BriefOnPage_ProductGroup><FK_Recipient_LookUpCJs><FK_LookUpCJs_Boap productGroupName="Préstamos"/></FK_Recipient_LookUpCJs></FK_BriefOnPage_ProductGroup><FK_BriefOnPage_ProductSubGroup><FK_Recipient_LookUpCJs><FK_LookUpCJs_Boap productSubGroupName="Préstamo personal"/></FK_Recipient_LookUpCJs></FK_BriefOnPage_ProductSubGroup></FK_LookUpCJs_Boap></FK_Recipient_LookUpCJs></recipient>]]></result></acresult></acresults></acresults></lookUpCJResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
        //String mockString = '<?xml version="1.0"?><SOAP-ENV:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"	xmlns:ns="urn:nms:recipient"	xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><lookUpCJResponse xmlns="urn:nms:recipient"	SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><acresults xsi:type="ns:Element"	SOAP-ENV:encodingStyle="http://xml.apache.org/xml-soap/literalxml"><acresults><global><code>0</code><exception/><message>Success</message></global><acresult><code>0</code><exception/><message>Success</message><result><recipient id="470595417"	numperso="58230785"><FK_Recipient_LookUpCJs boapId="21000"	status="2"><FK_LookUpCJs_Boap document=""	duration="16"	id="21000"	label="CJ 17 - Remarketing Móviles"><FK_BriefOnPage_ProductGroup><FK_Recipient_LookUpCJs><FK_LookUpCJs_Boap productGroupName="Promocaixa"/></FK_Recipient_LookUpCJs></FK_BriefOnPage_ProductGroup><FK_BriefOnPage_ProductSubGroup><FK_Recipient_LookUpCJs><FK_LookUpCJs_Boap productSubGroupName="Telefonía"/></FK_Recipient_LookUpCJs></FK_BriefOnPage_ProductSubGroup></FK_LookUpCJs_Boap></FK_Recipient_LookUpCJs><FK_Recipient_LookUpCJs boapId="12091"	status="0"><FK_LookUpCJs_Boap document=""	duration="7"	id="12091"	label="CJ B - Remarketing Seguro Automóvil"><FK_BriefOnPage_ProductGroup><FK_Recipient_LookUpCJs><FK_LookUpCJs_Boap productGroupName="Seguros Patrimonio"/></FK_Recipient_LookUpCJs></FK_BriefOnPage_ProductGroup><FK_BriefOnPage_ProductSubGroup><FK_Recipient_LookUpCJs><FK_LookUpCJs_Boap productSubGroupName="Seguro autos"/></FK_Recipient_LookUpCJs></FK_BriefOnPage_ProductSubGroup></FK_LookUpCJs_Boap></FK_Recipient_LookUpCJs><FK_Recipient_LookUpCJs boapId="30000"	status="0"><FK_LookUpCJs_Boap document=""	duration="2"	id="30000"	label="CJ 40 - Experience Felicitación de Cumpleaños"/></FK_Recipient_LookUpCJs><FK_Recipient_LookUpCJs boapId="105000"	status="0"><FK_LookUpCJs_Boap document=""	duration="0"	id="105000"	label="CA 12 - DL - Prestamo C&amp;amp;G BAU"/></FK_Recipient_LookUpCJs><FK_Recipient_LookUpCJs boapId="32030"	status="0"><FK_LookUpCJs_Boap document=""	duration="24"	id="32030"	label="CJ 41 - 18099 - DAS Lab - Incremento límite"><FK_BriefOnPage_ProductGroup><FK_Recipient_LookUpCJs><FK_LookUpCJs_Boap productGroupName="Préstamos"/></FK_Recipient_LookUpCJs></FK_BriefOnPage_ProductGroup><FK_BriefOnPage_ProductSubGroup><FK_Recipient_LookUpCJs><FK_LookUpCJs_Boap productSubGroupName="Préstamo personal"/></FK_Recipient_LookUpCJs></FK_BriefOnPage_ProductSubGroup></FK_LookUpCJs_Boap></FK_Recipient_LookUpCJs><FK_Recipient_LookUpCJs boapId="59000"	status="2"><FK_LookUpCJs_Boap document=""	duration="365"	id="59000"	label="CJ 74 - OnBoarding MyBox Hogar"><FK_BriefOnPage_ProductGroup><FK_Recipient_LookUpCJs><FK_LookUpCJs_Boap productGroupName="Seguros Patrimonio"/></FK_Recipient_LookUpCJs></FK_BriefOnPage_ProductGroup><FK_BriefOnPage_ProductSubGroup><FK_Recipient_LookUpCJs><FK_LookUpCJs_Boap productSubGroupName="Seguros de hogar"/></FK_Recipient_LookUpCJs></FK_BriefOnPage_ProductSubGroup><FK_BriefOnPage_Product><FK_Recipient_LookUpCJs><FK_LookUpCJs_Boap productName="MyBox Hogar"/></FK_Recipient_LookUpCJs></FK_BriefOnPage_Product></FK_LookUpCJs_Boap></FK_Recipient_LookUpCJs></recipient></result></acresult></acresults></acresults></lookUpCJResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
        
        Response resultMethod = new Response();
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_CustomerJourney');
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        String body = buildCallRequestBodyLookupCJ(numperso);
        Map<String, String> mapHeader = buildHeaderRequest('"nms:recipient#lookUpCJ"');
        mapHeader.put('X-Security-Token', token.get('pstrSecurityToken'));
        mapHeader.put('cookie', '__sessiontoken=' + token.get('pstrSessionToken'));
        
        
        /*if (executeAPICall){
            AV_ApiCallout apiCallout = new AV_ApiCallout()
                .setIsActive(dataInterface.CC_Activa__c)
                .setMethod(dataInterface.CC_TipoPeticion__c)
                .setEndpoint(dataInterface.CC_EndPoint__c) 
                .setCertificate(dataInterface.CC_Certificado__c)
                .setHeaders(mapHeader)
                .setBody(body)
                //.addContentTypeJsonHeader()
                .debugMode()
                //.setDataMockup(mockString)
                .runCallout();
            AV_LogDebug.printLogDebug(methodName, '*****************************************');
            AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
            
            //Check errors:
            resultMethod.statusCode = apiCallout.getStatusCodeResponse();
            resultMethod.errorMessage = apiCallout.getErrorResponse();
            resultMethod.errorCode = apiCallout.getStatusCodeResponse();
            
            boolean reqStatusOK = apiCallout.checkErrorStatusCode();
            if(reqStatusOK){
                String xml = apiCallout.getBodyResponse().replace( '<!\\[CDATA\\[', 'XML_CDATA_START' ).replace( ']]>', 'XML_CDATA_END' ).replace('&lt;', '<').replace('&gt;', '>');
                DOM.Document document = new DOM.Document();
                document.load(xml);
                for(Dom.XmlNode response : document.getRootElement().getChildElements()) {
                    for(Dom.XmlNode responseNode : response.getChildElements()) {
                        if(responseNode.getName() == 'Fault') {
                            insertErrorCJ( numperso, 'errorMessage : ' + responseNode.getChildElement('faultcode',null).getText());
                            return  'errorMessage : ' + responseNode.getChildElement('faultcode',null).getText();
                        }
                        else if(responseNode.getName() == 'lookUpCJResponse'){
                            String jsonBody = AV_XMLParser.xmlToJson(xml);
                            jsonBody = jsonBody.replaceAll('global', 'global_Z').replaceAll('type', 'type_Z').replaceAll('desc', 'desc_Z');
                            return jsonBody;
                        }              
                    }
                }
            }
            AV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + +reqStatusOK);
            }
            return null;
    }
    
    

    public static String marketing360(String numperso, Map<String,String> token){
        String methodName = 'marketing360';
        AV_LogDebug.printLogDebug(methodName, '------------------------> marketing360 process');
        
        Response resultMethod = new Response();
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_CustomerJourney');
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        String body = buildCallRequestBodyMarketing360(numperso);
        Map<String, String> mapHeader = buildHeaderRequest('"nms:recipient#marketing360"');
        mapHeader.put('X-Security-Token', token.get('pstrSecurityToken'));
        mapHeader.put('cookie', '__sessiontoken=' + token.get('pstrSessionToken'));
        
        AV_ApiCallout apiCallout = new AV_ApiCallout()
            .setIsActive(dataInterface.CC_Activa__c)
            .setMethod(dataInterface.CC_TipoPeticion__c)
            .setEndpoint(dataInterface.CC_EndPoint__c) 
            .setCertificate(dataInterface.CC_Certificado__c)
            .setHeaders(mapHeader)
            .setBody(body)
            //.addContentTypeJsonHeader()
            .debugMode()
            //.setDataMockup(mockString)
            .runCallout();
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
        
        //Check errors:
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
        resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();
        
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        if(reqStatusOK){
            String xml = apiCallout.getBodyResponse().replace( '<!\\[CDATA\\[', 'XML_CDATA_START' ).replace( ']]>', 'XML_CDATA_END' ).replace('&lt;', '<').replace('&gt;', '>');
            DOM.Document document = new DOM.Document();
            document.load(xml);
            for(Dom.XmlNode response : document.getRootElement().getChildElements()) {
                for(Dom.XmlNode responseNode : response.getChildElements()) {
                    if(responseNode.getName() == 'Fault') {
                        insertErrorCJ( numperso, 'errorMessage : ' + responseNode.getChildElement('faultcode',null).getText());
                        return  'errorMessage : ' + responseNode.getChildElement('faultcode',null).getText();
                    }
                    else if(responseNode.getName() == 'marketing360Response'){
                        return xml;
                    }              
                }
            }
        }
        AV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + +reqStatusOK);
        return null;
    }

    private static String buildCallRequestBodyLookupCJ(String numperso) {
        Long longUser = long.valueOf(numperso);
        String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
        String fromDate = Datetime.now().addYears(-1).format('yyyy-MM-dd');
        // initial part of the soap header for the appropriate
        String xmlBody =  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:nms="nms:recipient">'
            +'<soapenv:Header/>'
            +'<soapenv:Body>'
            +'<nms:lookUpCJ>'
            +'<urn:sessiontoken></urn:sessiontoken>'
            +'<nms:targets>'
            +'<target>'
            + '<target bid="" pid="" personId="'+hexDigest +'" pan="" role="" mcid="" hashId=""/>'
            +'</target>'
            +'</nms:targets>'
            +'<nms:fromDate>' + fromDate + '</nms:fromDate>'
            +'<nms:limit>20</nms:limit>'
            +'<nms:mode>recipients</nms:mode>'
            +'</nms:lookUpCJ>'
            +'</soapenv:Body>'
            +'</soapenv:Envelope>';
        
        
        return xmlBody;
    }

    private static String buildCallRequestBodyMarketing360(String numperso) {
        Long longUser = long.valueOf(numperso);
        String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
        String fromDate = Datetime.now().addYears(-1).format('yyyy-MM-dd');
        // initial part of the soap header for the appropriate
        String xmlBody =  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:nms="nms:recipient">'
            +'<soapenv:Header/>'
            +'<soapenv:Body>'
            +'<nms:marketing360>'
            +'<urn:sessiontoken></urn:sessiontoken>'
            +'<nms:recipients>'
            +'<recipient>'
            + '<recipient bid="" pid="" personId="'+hexDigest +'" pan="" role="" mcid="" hashId=""/>'
            +'</recipient>'
            +'</nms:recipients>'
            +'<nms:fromDate>' + fromDate + '</nms:fromDate>'
            +'<nms:limit>20</nms:limit>'
            +'</nms:marketing360>'
            +'</soapenv:Body>'
            +'</soapenv:Envelope>';
        
        return xmlBody;
    }

    private static String buildCallRequestBodyLogin(CC_InterfaceSettings__mdt dataInterface) {
        // initial part of the soap header for the appropriate
        String xmlBody =  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:xtk:session">'
            +'<soapenv:Header/>'
            +'<soapenv:Body>'
            +'<urn:Logon>'
            +'<urn:sessiontoken></urn:sessiontoken>'
            +'<urn:strLogin>'+ dataInterface.AV_Username__c +'</urn:strLogin>'
            +'<urn:strPassword>'+ dataInterface.AV_Password__c +'</urn:strPassword>'
            +'<urn:elemParameters></urn:elemParameters>'
            +'</urn:Logon>'
            +'</soapenv:Body>'
            +'</soapenv:Envelope>';
        
        // YOUR LOGIC TO STRUCTURE THE XML BODY WILL GO HERE
        
        return xmlBody;
    }*/

    /**
     * @description            Construye el header de la peticion.
     * @param customerId     -> Identificador del cliente
     * @param employeeId     -> Identificador del empleado
     */
    /*private static Map<String, String> buildHeaderRequest( String soapAction){
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('SOAPAction', soapAction);
        return mapHeader;
    }
  
    private static Map<String,AV_CustomerJourney__c> upsertCJ(String numperso, AV_CJWrapper jsonBody){
        //AV_CJWrapper body = AV_CJWrapper.parse(jsonBody);
        Map<String,AV_CustomerJourney__c> cjs = new Map<String,AV_CustomerJourney__c>();
        AV_CustomerJourney__c cj = new AV_CustomerJourney__c ();
        cj.AV_ExternalID__c = numperso + '-'+ jsonBody.Envelope.Body.lookUpCJResponse.acresults.acresults.acresult.result.recipient.FK_Recipient_LookUpCJs.boapId;
        String productName = '';
        if(jsonBody.Envelope.Body.lookUpCJResponse.acresults.acresults.acresult.result.recipient.FK_Recipient_LookUpCJs.FK_LookUpCJs_Boap.FK_BriefOnPage_ProductSubGroup != null){
            productName = jsonBody.Envelope.Body.lookUpCJResponse.acresults.acresults.acresult.result.recipient.FK_Recipient_LookUpCJs.FK_LookUpCJs_Boap.FK_BriefOnPage_ProductSubGroup.FK_Recipient_LookUpCJs.FK_LookUpCJs_Boap.productSubGroupName;
        }
        List<Product2> prod = new List<Product2>();
        if(String.isNotBlank(productName)){
            productName = '%' + productName + '%';
            prod = [SELECT Id FROM Product2 Where Name LIKE :productName];
        }
        if(prod != null && !prod.isEmpty())cj.AV_ProductN20__c = prod[0].Id;
        Account a = new Account(AV_NumPerso__c = numperso);
        cj.Account__r = a;
        cj.AV_Duration__c = jsonBody.Envelope.Body.lookUpCJResponse.acresults.acresults.acresult.result.recipient.FK_Recipient_LookUpCJs.FK_LookUpCJs_Boap.duration;
        //cj.AV_CJName__c= jsonBody.Envelope.Body.lookUpCJResponse.acresults.acresults.acresult.result.recipient.FK_Recipient_LookUpCJs.FK_LookUpCJs_Boap.label;
        cj.Name= jsonBody.Envelope.Body.lookUpCJResponse.acresults.acresults.acresult.result.recipient.FK_Recipient_LookUpCJs.FK_LookUpCJs_Boap.label;
        cjs.put(cj.AV_ExternalID__c, cj);
        return cjs;
    }

    private static Map<String,AV_CustomerJourney__c> upsertCJs(String numPerso, AV_CJListWrapper jsonBody){
        //AV_CJWrapper body = AV_CJWrapper.parse(jsonBody);
        Map<String,AV_CustomerJourney__c> cjs = new Map<String,AV_CustomerJourney__c>();
        Set<String> productNames = new Set<String>();
        
        for(AV_CJListWrapper.Recipient r :  jsonBody.Envelope.Body.lookUpCJResponse.acresults.acresults.acresult.result.recipient){
            if(r.FK_LookUpCJs_Boap.FK_BriefOnPage_ProductSubGroup != null){
                productNames.add(r.FK_LookUpCJs_Boap.FK_BriefOnPage_ProductSubGroup.FK_Recipient_LookUpCJs.FK_LookUpCJs_Boap.productSubGroupName);
            }
        }
        Map<String,Id> mapProdByName = new Map<String,Id>();
        if(!productNames.isEmpty()){
            List<Product2> prods = [SELECT Id, Name FROM Product2 WHERE Name LIKE :productNames];
            if(prods != null && !prods.isEmpty()){
                for(Product2 p : prods){
                    mapProdByName.put(p.Name, p.Id);
                } 
            }
        }
        
        for(AV_CJListWrapper.Recipient res :  jsonBody.Envelope.Body.lookUpCJResponse.acresults.acresults.acresult.result.recipient){
            AV_CustomerJourney__c cj = new AV_CustomerJourney__c ();
            cj.AV_ExternalID__c = numperso + '-' + res.FK_LookUpCJs_Boap.id;
            if(res.FK_LookUpCJs_Boap.FK_BriefOnPage_ProductSubGroup != null){
                if(mapProdByName.get(res.FK_LookUpCJs_Boap.FK_BriefOnPage_ProductSubGroup.FK_Recipient_LookUpCJs.FK_LookUpCJs_Boap.productSubGroupName) != null) {
                    cj.AV_ProductN20__c = mapProdByName.get(res.FK_LookUpCJs_Boap.FK_BriefOnPage_ProductSubGroup.FK_Recipient_LookUpCJs.FK_LookUpCJs_Boap.productSubGroupName);
                }
            }
            Account a = new Account(AV_NumPerso__c = numPerso);
            cj.Account__r = a;
            cj.AV_Duration__c = res.FK_LookUpCJs_Boap.duration;
            //cj.AV_CJName__c= res.FK_LookUpCJs_Boap.label;
            cj.Name= res.FK_LookUpCJs_Boap.label;
            cjs.put(cj.AV_ExternalID__c, cj);
        }
        return cjs;
    }

    private static AV_CustomerJourney__c insertErrorCJ(String numperso, String error){
        AV_CustomerJourney__c cj = new AV_CustomerJourney__c ();
        Account a = new Account(AV_NumPerso__c = numperso);
        cj.AV_ExternalID__c = numperso;
        cj.Account__r = a;
        cj.Name = 'Error' + numperso;
        cj.AV_ErrorDateTime__c = Datetime.now();
        cj.AV_Error__c = error;
        return cj;
    }

    public static String syncCJ(String numPerso){
        String methodName = 'syncCJ';
        String resultSyncCJ = 'OK';
        Map<String,AV_CustomerJourney__c> cjsUpsert = new Map<String,AV_CustomerJourney__c>();
        Map<String,AV_CustomerJourney__c> cjs = new Map<String,AV_CustomerJourney__c>();
        Map<String, String> token = new Map<String, String>();
        Boolean csSavable = false;
        String jsonBody;
        
        //Check status token of login
        AV_AzureTeamsToken__c tok = AV_AzureTeamsToken__c.getValues('AdobeToken');
        Long tokDate = tok.LastModifiedDate.getTime() + (Long) tok.AV_ExpiresIn__c * 1000;
        if (String.isNotBlank(tok.AV_SessionToken__c) && String.isNotBlank(tok.AV_Token1__c) && Datetime.now() < Datetime.newInstance(tokDate)) {
            token.put('pstrSessionToken', tok.AV_SessionToken__c);
            token.put('pstrSecurityToken', tok.AV_Token1__c);
        } else {
            token = AV_AdobeCampaingnCJ_Integration.login();
            csSavable = true;
        }
        
        jsonBody = AV_AdobeCampaingnCJ_Integration.lookUpCJ(numPerso, token);
        Set<String> removeFromMap = new Set<String>();
        
        //Check json response "lookupCJ"
        if (String.isNotBlank(jsonBody)){
            if(jsonBody.contains('"result": "')){
                AV_CJWrapperError bodyObject = (AV_CJWrapperError) JSON.deserialize(jsonBody, AV_CJWrapperError.class);
                String errorMessage = bodyObject.Envelope.Body.lookUpCJResponse.acresults.acresults.acresult.result + 
                    					' Message: ' + bodyObject.Envelope.Body.lookUpCJResponse.acresults.acresults.acresult.message;
                if(!errorMessage.contains('no record found.')){
                    AV_CustomerJourney__c c = insertErrorCJ( numperso, errorMessage);
                    cjs.put(c.AV_ExternalID__c,c);
                }
            }
            else if(jsonBody.contains('"result": {"recipient": [{"')){
                AV_CJListWrapper bodyObject = (AV_CJListWrapper) JSON.deserialize(jsonBody, AV_CJListWrapper.class);
                if(bodyObject.Envelope.Body.lookUpCJResponse.acresults.acresults.acresult.result.recipient[0] != null){
                    cjs.putAll(upsertCJs(numperso,bodyObject));
                }
            }
            else if(jsonBody.contains('"result": {"recipient": {"')){
                AV_CJWrapper bodyObject = (AV_CJWrapper) JSON.deserialize(jsonBody, AV_CJWrapper.class);
                if(bodyObject.Envelope.Body.lookUpCJResponse.acresults.acresults.acresult.result.recipient.FK_Recipient_LookUpCJs != null){
                    cjs.putAll(upsertCJ(numperso,bodyObject));
                }
            }
            else{
                if (!'errorMessage : SOAP-ENV:Server'.equals(jsonBody)) {
                    AV_CJWrapperError bodyObject = (AV_CJWrapperError) JSON.deserialize(jsonBody, AV_CJWrapperError.class);
                    String errorMessage = bodyObject.Envelope.Body.lookUpCJResponse.acresults.acresults.acresult.result + 
                                            ' Message: ' + bodyObject.Envelope.Body.lookUpCJResponse.acresults.acresults.acresult.message;
                    if(!errorMessage.contains('no record found.')){
                        AV_CustomerJourney__c c = insertErrorCJ( numperso, errorMessage);
                        cjs.put(c.AV_ExternalID__c,c);
                    }
                }
            }
        }
        
        if(cjs != null && !cjs.isEmpty()){
            String result = AV_AdobeCampaingnCJ_Integration.marketing360(numPerso, token);
            AV_XMLParser.recipientElement recipient = new AV_XMLParser.recipientElement(); 
            recipient = AV_XMLParser.parserXML(result);     
            if(recipient.broadLog != null){
                for(AV_XMLParser.broadLogElement b : recipient.broadLog){
                    if(b.operation != null){
                        AV_CustomerJourney__c cj = cjs.get(numPerso + '-' + b.operation.lookUpCJs_Boap_Id);
                        if(cj != null){
                            AV_CustomerJourney__c cjn = cj.clone();
                            cjn.AV_ExternalID__c = numperso + '-' + b.broadLogId + '-' + b.operation.lookUpCJs_Boap_Id;
                            cjn.AV_LastImpactDate_del__c = DateTime.valueOf(b.eventDate);
                            //cjn.Name = b.delivery.label;
                            cjn.AV_CJName__c = b.delivery.label;
                            cjn.AV_Channel__c = b.delivery.messageType;
                            cjsUpsert.put(cjn.AV_ExternalID__c, cjn);
                            removeFromMap.add(numPerso + '-' + b.operation.lookUpCJs_Boap_Id);
                        }              
                    }
                }
            }
            
            if(recipient.broadLogAppSubRcp != null){
                for(AV_XMLParser.broadLogAppSubRcpElement b : recipient.broadLogAppSubRcp){
                    if(b.operation != null){
                        AV_CustomerJourney__c cj = cjs.get(numPerso + '-' + b.operation.lookUpCJs_Boap_Id);
                        if(cj != null){
                            AV_CustomerJourney__c cjn = cj.clone();
                            cjn.AV_ExternalID__c = numperso + '-' + b.broadLogId + '-' + b.operation.lookUpCJs_Boap_Id;
                            cjn.AV_LastImpactDate_del__c = DateTime.valueOf(b.eventDate);
                            //cjn.Name = b.delivery.label;
                            cjn.AV_CJName__c = b.delivery.label;
                            cjn.AV_Channel__c = b.delivery.messageType;
                            cjsUpsert.put(cjn.AV_ExternalID__c, cjn);
                            removeFromMap.add(numPerso + '-' + b.operation.lookUpCJs_Boap_Id);
                        }
                    }
                }
            }
            
            if(removeFromMap != null && !removeFromMap.isEmpty()){
                for(String s : removeFromMap){
                    cjs.remove(s);
                }
            }
        }
        
        if(cjs != null && !cjs.isEmpty()){
            cjsUpsert.putAll(cjs);
        }
        if(cjsUpsert != null && !cjsUpsert.isEmpty()){
            Schema.SObjectField externalId = AV_CustomerJourney__c.Fields.AV_ExternalID__c;
            List<Database.UpsertResult> listUpdateResult = Database.upsert(cjsUpsert.values(), externalId);
            AV_AppUtilities.displayErrors(methodName, listUpdateResult);
        }
        
        AV_LogDebug.printLogDebug(methodName, '------------------------> csSavable: ' + csSavable);
        //AV_LogDebug.printLogDebug(methodName, '------------------------> token: ' + token);
        if (csSavable) {
            tok = AV_AzureTeamsToken__c.getInstance('AdobeToken');
            tok.AV_Token1__c = token.get('pstrSecurityToken');
            tok.AV_SessionToken__c = token.get('pstrSessionToken');
            Database.update(tok);
        }
        return resultSyncCJ;
    }*/
   
}