/**********************************************************************************************************************
 Name:    EV_AdobeCampaignPO
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
* @description  Clase de Adobe para PO
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY          AUTHOR              DATE                Description
    1.0         US593725            Daniel Rodriguez    15/05/2023          Add named credentials to login      
    1.1         US785364            Carolina Lopez      20/12/2023          Modified the logic adding external credential, including tokens update.
***********************************************************************************************************************/
public with sharing class EV_AdobeCampaignPO {
	/**
 	* @description wrapper for response
 	*/
    public class Response {
        public String statusCode;
        public String errorMessage;
        public String errorCode;
    }
    
	/**
	 * @description  logic to make connection
	 */
    public static Map<String,String> login(){
        String mockString = '<SOAP-ENV:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="urn:xtk:session" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><LogonResponse SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns="urn:xtk:session"><pstrSessionToken xsi:type="xsd:string">___4ad6754e-cdd4-4e28-a4a8-c61b2f901361</pstrSessionToken><pSessionInfo xsi:type="ns:Element" SOAP-ENV:encodingStyle="http://xml.apache.org/xml-soap/literalxml"><sessionInfo><serverInfo advisedClientBuildNumber="8896" allowSQL="false" buildNumber="8896" commitId="507e44c" databaseId="u0A7706282AAEBDAE" defaultNameSpace="cxb" instanceName="marketingdev" majNumber="6" minClientBuildNumber="8767" minNumber="7" minNumberTechnical="0" securityTimeOut="86400" serverDate="2018-05-07 09:34:52.331Z" servicePack="0" sessionTimeOut="86400" useVault="false"/><userInfo datakitInDatabase="true" homeDir="" instanceLocale="en-GB" locale="en-GB" login="username" loginCS="username" loginId="238250" noConsoleCnx="false" orgUnitId="0" theme="" timezone="Europe/Madrid"><login-group id="1053"/><login-group id="3457"/><login-right right="admin"/><installed-package name="sftpPackage" namespace="ace"/><installed-package name="apiToolkit" namespace="acx"/><installed-package name="configurationManager" namespace="acx"/><installed-package name="core" namespace="acx"/><installed-package name="fileManager" namespace="acx"/><installed-package name="cxb_PFS" namespace="cxb"/><installed-package name="cxb_PKG4" namespace="cxb"/><installed-package name="content" namespace="ncm"/><installed-package name="aamIntegration" namespace="nms"/><installed-package name="azuredw" namespace="nms"/><installed-package name="billing" namespace="nms"/><installed-package name="campaign" namespace="nms"/><installed-package name="centralLocal" namespace="nms"/><installed-package name="core" namespace="nms"/><installed-package name="coreInteraction" namespace="nms"/><installed-package name="country" namespace="nms"/><installed-package name="federatedDataAccess" namespace="nms"/><installed-package name="folder" namespace="nms"/><installed-package name="hive" namespace="nms"/><installed-package name="interaction" namespace="nms"/><installed-package name="interactionControl" namespace="nms"/><installed-package name="japanLoc" namespace="nms"/><installed-package name="macIntegration" namespace="nms"/><installed-package name="messageCenter" namespace="nms"/><installed-package name="messageCenterControl" namespace="nms"/><installed-package name="midEmitter" namespace="nms"/><installed-package name="mobile" namespace="nms"/><installed-package name="mobileApp" namespace="nms"/><installed-package name="mrm" namespace="nms"/><installed-package name="paper" namespace="nms"/><installed-package name="phone" namespace="nms"/><installed-package name="report" namespace="nms"/><installed-package name="response" namespace="nms"/><installed-package name="ruleset" namespace="nms"/><installed-package name="simulation" namespace="nms"/><installed-package name="social" namespace="nms"/><installed-package name="survey" namespace="nms"/><installed-package name="systemStrings" namespace="nms"/><installed-package name="webAnalytics" namespace="nms"/><installed-package name="core" namespace="xtk"/></userInfo></sessionInfo></pSessionInfo><pstrSecurityToken xsi:type="xsd:string">@3PKpbKVopBgCEtXl7jkfsil3d_S-su4FQU-mqeay9_R7aywbl4CKhUqH_a_IK7OlcQXligoucslvFnnZUxNbsYk9L18uRgcYkjiC8DT9FU4=</pstrSecurityToken></LogonResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
        Map<String,String> token = new Map<String,String>();
        Response resultMethod = new Response();
        String methodName = 'Logon';
        EV_ByPass__c cSettingTokens = EV_ByPass__c.getOrgDefaults();
        Map<String, String> mapHeader = buildHeaderRequest('"xtk:session#Logon"');
        
        AV_ApiCallout apiCallout = new AV_ApiCallout();
        apiCallout.setIsActive(true);
        apiCallout.setMethod('POST');
        if (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) {
            apiCallout.setEndpoint('callout:EV_AdobeCampaignPRO');
        } else {
            apiCallout.setEndpoint('callout:EV_AdobeCampaignPRE');
        }
        
        String body = buildCallRequestBodyLogin();
      
        apiCallout.setHeaders(mapHeader);
        apiCallout.setBody(body);
        apiCallout.addContentTypeJsonHeader();
        apiCallout.debugMode();
        apiCallout.runCallout();
        
        EV_LogDebug.printLogDebug(methodName, '*****************************************');
        EV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
    
        //Check errors:
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
        resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        if(reqStatusOK){
            String security = '';
            String session = '';
            DOM.Document document = new DOM.Document();
            document.load(apiCallout.getBodyResponse());
            for(Dom.XmlNode response : document.getRootElement().getChildElements()) {
                for(Dom.XmlNode responseNode : response.getChildElements()) {
                    if(responseNode.getName() == 'Fault') {
                        EV_LogDebug.printLogDebug('@@faultcode', responseNode.getChildElement('faultcode',null).getText());
                        EV_LogDebug.printLogDebug('@@faultstring', responseNode.getChildElement('faultstring',null).getText());
                    }else if(responseNode.getName() == 'LogonResponse'){
                        for(Dom.XmlNode responseNode2 : responseNode.getChildElements()){
                            if(responseNode2.getName() == 'pstrSessionToken'){
                                token.put('pstrSessionToken',responseNode2.getText());
                                session = responseNode2.getText();
                            }
                            if(responseNode2.getName() == 'pstrSecurityToken'){
                                token.put('pstrSecurityToken',responseNode2.getText());
                                security = responseNode2.getText();
                            }
                        }
                    }              
                }
            }
            if(cSettingTokens.EV_AdobeTimeExpireToken__c!= null){
                EV_TokenHelper.updateToken((DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) ? 'EV_AdobeCampaignCredentialPRO' : 'EV_AdobeCampaignCredentialPRE', security, session, Datetime.now().addHours(Integer.valueOF(cSettingTokens.EV_AdobeTimeExpireToken__c))); 
            }
        }
        EV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + +reqStatusOK);
        return token;
    }
    
	/**
	 * @description  build body 
	 */
    public static String buildCallRequestBodyLogin() {
        String domainCredential = (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) ? 'EV_AdobeCampaignCredentialPRO' : 'EV_AdobeCampaignCredentialPRE';
        // initial part of the soap header for the appropriate
        String xmlBody =  +'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:xtk:session">'
        +'<soapenv:Header/>'
        +'<soapenv:Body>'
        +'<urn:Logon>'
        +'<urn:sessiontoken></urn:sessiontoken>'
            +'<urn:strLogin>'+ '{!$Credential.' + domainCredential + '.Username}' +'</urn:strLogin>'
            +'<urn:strPassword>'+ '{!$Credential.' + domainCredential + '.Password}' +'</urn:strPassword>'
        +'<urn:elemParameters></urn:elemParameters>'
        +'</urn:Logon>'
        +'</soapenv:Body>'
        +'</soapenv:Envelope>';
        // YOUR LOGIC TO STRUCTURE THE XML BODY WILL GO HERE
        return xmlBody;
    }

	 /**
	 * @description  build header
	 * @param   soapAction 
	 */
    public static Map<String, String> buildHeaderRequest(String soapAction){
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('SOAPAction', soapAction);
        return mapHeader;
    }

	 /**
	 * @description  make requests
	 * @param   campaignId 
	 * @param   cPOAC 
	 * @param   idPO 
	 */
    public static void voulmePORequest(String campaignId, EV_DataTablePO_Controller.WrapperDataCPOAC cPOAC, String idPO){
        String methodName = 'targetAudienceSelectionEvent';
        Response resultMethod = new Response();
        Map<String,String> token = new Map<String,String>();

        if(EV_TokenHelper.checkTokenValidity((DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) ? 'EV_AdobeCampaignCredentialPRO' : 'EV_AdobeCampaignCredentialPRE') && !Test.isRunningTest()){
			EV_LogDebug.printLogDebug(methodName, ' checkTokenValidity IF');
            token = login();
        }else{
            token= getTokenConnectApi();
        }

        String body = buildCallRequestBodyVolumePO(campaignId, cPOAC, idPO, token);
        Map<String, String> mapHeader = buildHeaderRequest('"sfdc:TBL_SLFC_CAMPAIGN#targetAudienceSelectionEvent"');
        mapHeader.put('cookie', '__sessiontoken=' + token.get('pstrSessionToken'));
        mapHeader.put('X-Security-Token', token.get('pstrSecurityToken'));
        mapHeader.put('Content-Type', 'text/xml; charset=utf-8');
        
        AV_ApiCallout apiCallout = new AV_ApiCallout();
        apiCallout.setIsActive(true);
        apiCallout.setMethod('POST');

        if (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) {
            apiCallout.setEndpoint('callout:EV_AdobeCampaignPRO');
        } else {
            apiCallout.setEndpoint('callout:EV_AdobeCampaignPRE');
        }
        apiCallout.setHeaders(mapHeader);
        apiCallout.setBody(body);
        apiCallout.addContentTypeJsonHeader();
        apiCallout.debugMode();
        apiCallout.runCallout();
        
        EV_LogDebug.printLogDebug(methodName, '*****************************************');
        EV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
        //Check errors:
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
        resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        if(reqStatusOK){
            EV_LogDebug.printLogDebug('@@reqStatusOK',String.valueOf(apiCallout.getBodyResponse()));
        }
        EV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + +reqStatusOK);
    }

	/**
	 * @description  generate SOAP for the call
	 * @param   campaignId 
	 * @param   cPOAC 
	 * @param   idPO 
	 * @param   token 
	 */
    public static String buildCallRequestBodyVolumePO(String campaignId, EV_DataTablePO_Controller.WrapperDataCPOAC cPOAC, String idPO, Map<String,String> token) {
        // initial part of the soap header for the appropriate
        String xmlBody = ''; 
        String centro = '';
        String dan ='';
        String dt = '';
        String sexo = '';
        String tipoCliente = '';
        String carteraGestor = '';
        String provincia = '';
        String canalEnvioComunicacionAlCliente = '';
        String idioma ='';
        Decimal maxVolume =  500000;
        Campaign camp = [SELECT Id, EV_MaxVolumePO__c FROM Campaign WHERE Id = :campaignId];
        if (camp.EV_MaxVolumePO__c != null) {
            maxVolume = camp.EV_MaxVolumePO__c;
        } 
        if (String.isNotBlank(cPOAC.EV_Centro)) {
            centro = cPOAC.EV_Centro+',';
        } else {
            centro = cPOAC.EV_Centro ;
        }
        if (String.isNotBlank(cPOAC.EV_DAN)) {
            dan = cPOAC.EV_DAN+',';
        } else {
            dan = cPOAC.EV_DAN ;
        }
        if (String.isNotBlank(cPOAC.EV_DT)) {
            dt= cPOAC.EV_DT+',';
        } else {
            dt= cPOAC.EV_DT ;
        }
    
        if (String.isNotBlank(cPOAC.EV_Sexo)) {
            sexo = cPOAC.EV_Sexo+',';
        } else {
            sexo = cPOAC.EV_Sexo  ;
        }
        if (String.isNotBlank(cPOAC.EV_TipoCliente)) {
            tipoCliente= cPOAC.EV_TipoCliente+',' ;
        } else {
            tipoCliente= cPOAC.EV_TipoCliente ;
        }
        if (String.isNotBlank(cPOAC.EV_CarteraGestor)) {
            carteraGestor= cPOAC.EV_CarteraGestor +',' ;
        } else {
            carteraGestor= cPOAC.EV_CarteraGestor;
        }
        if (String.isNotBlank(cPOAC.EV_Provincia)) {
            provincia = cPOAC.EV_Provincia+',';
        } else {
            provincia = cPOAC.EV_Provincia ;
        }
        if (String.isNotBlank(cPOAC.EV_CanalEnvioComunicacionAlCliente)) {
            canalEnvioComunicacionAlCliente =  cPOAC.EV_CanalEnvioComunicacionAlCliente+',';
        } else {
            canalEnvioComunicacionAlCliente =  cPOAC.EV_CanalEnvioComunicacionAlCliente ;
        }
        if (String.isNotBlank(cPOAC.EV_Idioma)) {
            idioma= cPOAC.EV_Idioma+',';
        } else {
            idioma= cPOAC.EV_Idioma ;
        }

        if(campaignId != null){
            xmlBody ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sfdc="sfdc:TBL_SLFC_CAMPAIGN">'
            +'<soapenv:Header/>'
            +'<soapenv:Body>'
            +'<sfdc:targetAudienceSelectionEvent>'
            +'<sfdc:sessiontoken>'+token.get('pstrSessionToken')+'</sfdc:sessiontoken>'
            +'<sfdc:id>'+idPO+'</sfdc:id>'
            +'<sfdc:campaignId>'+campaignId+'</sfdc:campaignId>'
            +'<sfdc:criteria>'
            +'<criteria '  + 'EV_AgriculturaJardineria__c="'+cPOAC.EV_AgriculturaJardineria
            +'" EV_AltruismoDonacionesCambiarelmundo__c="'+cPOAC.EV_AltruismoDonacionesCambiarelmundo
            +'" EV_Basket__c="'+cPOAC.EV_Basket
            +'" EV_BellezaPeluqeriaPerfumes__c="'+cPOAC.EV_BellezaPeluqeriaPerfumes
            +'" EV_Cafe__c="'+cPOAC.EV_Cafe
            +'" EV_CiclismoIrenbici__c="'+cPOAC.EV_CiclismoIrenbici
            +'" EV_CinePeliculas__c="'+cPOAC.EV_CinePeliculas
            +'" EV_ComidahealthyVeganaVegetariana__c="'+cPOAC.EV_ComidahealthyVeganaVegetariana
            +'" EV_DeportesTiendasdedeportes__c="'+cPOAC.EV_DeportesTiendasdedeportes
            +'" EV_ElectronicaSmartphonesTvsPCs__c="'+cPOAC.EV_ElectronicaSmartphonesTvsPCs
            +'" EV_EmprendedoresAutonomos__c="'+cPOAC.EV_EmprendedoresAutonomos
            +'" EV_EsquiSnowboard__c="'+cPOAC.EV_EsquiSnowboard
            +'" EV_Eventosreligiosos__c="'+cPOAC.EV_Eventosreligiosos
            +'" EV_FinanzasBolsaInversion__c="'+cPOAC.EV_FinanzasBolsaInversion
            +'" EV_Futbol__c="'+cPOAC.EV_Futbol
            +'" EV_Gym__c="'+cPOAC.EV_Gym
            +'" EV_LibrosLeer__c="'+cPOAC.EV_LibrosLeer
            +'" EV_Mascotas__c="'+cPOAC.EV_Mascotas
            +'" EV_Medioambienteanimalismo__c="'+cPOAC.EV_Medioambienteanimalismo
            +'" EV_ModaShopping__c="'+cPOAC.EV_ModaShopping
            +'" EV_Museos__c="'+cPOAC.EV_Museos
            +'" EV_MusicaDiscosConciertos__c="'+cPOAC.EV_MusicaDiscosConciertos
            +'" EV_Parquesdeatracciones__c="'+cPOAC.EV_Parquesdeatracciones
            +'" EV_PaternidadFamiliaNinosBebes__c="'+cPOAC.EV_PaternidadFamiliaNinosBebes
            +'" EV_Recreomaritimo__c="'+cPOAC.EV_Recreomaritimo
            +'" EV_Restaurantes__c="'+cPOAC.EV_Restaurantes
            +'" EV_SalirBaresDiscotecas__c="'+cPOAC.EV_SalirBaresDiscotecas
            +'" EV_Teatro__c="'+cPOAC.EV_Teatro
            +'" EV_TenisoPadel__c="'+cPOAC.EV_TenisoPadel
            +'" EV_Tvseries__c="'+cPOAC.EV_Tvseries
            +'" EV_Universidad__c="'+cPOAC.EV_Universidad
            +'" EV_Viajes__c="'+cPOAC.EV_Viajes
            +'" EV_Videojuegos__c="'+cPOAC.EV_Videojuegos
            +'" EV_VinoBodegas__c="'+cPOAC.EV_VinoBodegas
            +'" EV_Centro__c="'+centro
            +'" EV_DAN__c="'+dan
            +'" EV_DT__c="' + dt
            +'" EV_EdadMaxima__c="'+Integer.valueOf(cPOAC.EV_EdadMaxima)
            +'" EV_EdadMinima__c="'+Integer.valueOf(cPOAC.EV_EdadMinima)
            +'" EV_Interlocutor__c="'+cPOAC.EV_Interlocutor
            +'" EV_Sexo__c="'+sexo
            +'" EV_TipoCliente__c="'+ tipoCliente
            +'" EV_Ciencia__c="'+cPOAC.EV_Ciencia
            +'" EV_CarteraGestor__c="'+carteraGestor
            +'" EV_Provincia__c="'+ provincia
            +'" EV_CanalEnvioComunicacionAlCliente__c="'+canalEnvioComunicacionAlCliente
            +'" EV_Idioma__c= "'+idioma
            +'" EV_Saturation__c="'+cPOAC.EV_Saturation+'"/>'
            +'</sfdc:criteria>'
            +'<sfdc:maxVolume>'+maxVolume+'</sfdc:maxVolume>'
            +'</sfdc:targetAudienceSelectionEvent>'
            +'</soapenv:Body>'
            +'</soapenv:Envelope>';
        }
        return xmlBody;
    }

	/**
	 * @description  confirmation request
	 * @param   campaignId 
	 */
    public static void confirmationPORequest(String campaignId){
        String methodName = 'targetAudienceConfirmationEvent';
        /*String mockString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sfdc="sfdc:TBL_SLFC_CAMPAIGN"><soapenv:Header/><soapenv:Body><sfdc:targetAudienceSelectionEvent><sfdc:sessiontoken>'+login().get('pstrSessionToken')+'</sfdc:sessiontoken><sfdc:campaignMemberId>00v5E00000Dw9SPQAZ</sfdc:campaignMemberId><sfdc:campaignId>7015E000000muGZQAY</sfdc:campaignId></sfdc:targetAudienceSelectionEvent></soapenv:Body></soapenv:Envelope>';*/
        Response resultMethod = new Response();
        Map<String,String> token = new Map<String,String>();

        if(EV_TokenHelper.checkTokenValidity((DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) ? 'EV_AdobeCampaignCredentialPRO' : 'EV_AdobeCampaignCredentialPRE') || Test.isRunningTest()){
            EV_LogDebug.printLogDebug(methodName, ' checkTokenValidity IF');
            token = login();
        }else{
            token= getTokenConnectApi();
        }
    
        String body = buildCallRequestBodyconfirmationPO(campaignId);
        Map<String, String> mapHeader = buildHeaderRequest('"sfdc:TBL_SLFC_CAMPAIGN#targetAudienceConfirmationEvent"');
        mapHeader.put('cookie', '__sessiontoken=' + token.get('pstrSessionToken'));
        mapHeader.put('X-Security-Token', token.get('pstrSecurityToken'));
        mapHeader.put('Content-Type', 'text/xml; charset=utf-8');
        
        AV_ApiCallout apiCallout = new AV_ApiCallout();
        apiCallout.setIsActive(true);
        apiCallout.setMethod('POST');

        if (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) {
            apiCallout.setEndpoint('callout:EV_AdobeCampaignPRO');
        } else {
            apiCallout.setEndpoint('callout:EV_AdobeCampaignPRE');
        }
        apiCallout.setHeaders(mapHeader);
        apiCallout.setBody(body);
        apiCallout.addContentTypeJsonHeader();
        apiCallout.debugMode();
        apiCallout.runCallout();
        
        EV_LogDebug.printLogDebug(methodName, '*****************************************');
        EV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
    
        //Check errors:
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
        resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        if(reqStatusOK){
            EV_LogDebug.printLogDebug('@@reqStatusOK',String.valueOf(apiCallout.getBodyResponse()));
        }
        EV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + +reqStatusOK);
    }

	/**
	 * @description  generate SOAP for the call
	 * @param   campaignId 
	 */
	public static String buildCallRequestBodyconfirmationPO(String campaignId) {
        // initial part of the soap header for the appropriate
        String xmlBody = ''; 
    
        if(campaignId != null){
            xmlBody ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sfdc="sfdc:TBL_SLFC_CAMPAIGN">'
            +'<soapenv:Header/>'
            +'<soapenv:Body>'
            +'<sfdc:targetAudienceConfirmationEvent>'
            +'<sfdc:sessiontoken>'/*+tokens.get('pstrSessionToken')*/+'</sfdc:sessiontoken>'
            +'<sfdc:campaignId>'+campaignId+'</sfdc:campaignId>'
            +'</sfdc:targetAudienceConfirmationEvent>'
            +'</soapenv:Body>'
            +'</soapenv:Envelope>';
        }
        return xmlBody;
    }

    /**
	 * @description  get Token to connectApi
	 */
    public static Map<String,String> getTokenConnectApi(){
        String methodName = 'getTokenConnectApi';
        EV_LogDebug.printLogDebug(methodName, 'getTokenConnectApi ELSE');
        Map<String,String> token = new Map<String,String>();
        ConnectApi.ExternalCredential externalCred;
        ConnectApi.Credential cred;
        
        if(DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null){
            externalCred = ConnectApi.NamedCredentials.getExternalCredential('EV_AdobeCampaignCredentialPRO');
            cred = ConnectApi.NamedCredentials.getCredential('EV_AdobeCampaignCredentialPRO', externalCred.principals[1].principalName, ConnectApi.CredentialPrincipalType.NamedPrincipal);
        }else{
            externalCred = ConnectApi.NamedCredentials.getExternalCredential('EV_AdobeCampaignCredentialPRE');
            cred = ConnectApi.NamedCredentials.getCredential('EV_AdobeCampaignCredentialPRE', externalCred.principals[1].principalName, ConnectApi.CredentialPrincipalType.NamedPrincipal);
        }
        
        ConnectApi.CredentialValue credValueSecurity = cred.credentials.get('SECURITY');
        ConnectApi.CredentialValue credValueSession = cred.credentials.get('SESSION');
        EV_LogDebug.printLogDebug('@@credValueSecurity ' , string.valueOf(credValueSecurity) + ' session ' + string.valueOf(credValueSession));
        token.put('pstrSecurityToken',credValueSecurity.value);
        token.put('pstrSessionToken',credValueSession.value);
        return token;
        
    }
}