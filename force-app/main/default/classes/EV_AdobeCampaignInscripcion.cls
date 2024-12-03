/**********************************************************************************************************************
 Name:	  EV_AdobeCampaignInscripcion
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración de inscripción NRT
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App Eventos		Jorge Centella    	28/12/2020			Init version
	1.1			US505932		Daniel Rodriguez	09/12/2023			Add field EV_FormatosAsitencia__c, EV_RTCampaign__c
	1.2			US593725		Daniel Rodriguez	15/05/2023			Add named credentials to login
	1.3			US587001		Mamen Arias			24/05/2023			Add methods inscriptionEventCMCustom, buildCallRequestBodyInscriptionEventCMCustom 
	1.4							Daniel Rodriguez    17/10/2023			Modify methods for add custom setting and modify call to login
	1.5			FIX				Daniel Rodriguez	13/11/2023			Comment error 401/403
***********************************************************************************************************************/

public with sharing class EV_AdobeCampaignInscripcion{

	public class Response {
		public String statusCode;
		public String errorMessage;
		public String errorCode;
	}
	
	public static Map<String,String> login(){
		String mockString = '<SOAP-ENV:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns="urn:xtk:session" xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><LogonResponse SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns="urn:xtk:session"><pstrSessionToken xsi:type="xsd:string">___4ad6754e-cdd4-4e28-a4a8-c61b2f901361</pstrSessionToken><pSessionInfo xsi:type="ns:Element" SOAP-ENV:encodingStyle="http://xml.apache.org/xml-soap/literalxml"><sessionInfo><serverInfo advisedClientBuildNumber="8896" allowSQL="false" buildNumber="8896" commitId="507e44c" databaseId="u0A7706282AAEBDAE" defaultNameSpace="cxb" instanceName="marketingdev" majNumber="6" minClientBuildNumber="8767" minNumber="7" minNumberTechnical="0" securityTimeOut="86400" serverDate="2018-05-07 09:34:52.331Z" servicePack="0" sessionTimeOut="86400" useVault="false"/><userInfo datakitInDatabase="true" homeDir="" instanceLocale="en-GB" locale="en-GB" login="username" loginCS="username" loginId="238250" noConsoleCnx="false" orgUnitId="0" theme="" timezone="Europe/Madrid"><login-group id="1053"/><login-group id="3457"/><login-right right="admin"/><installed-package name="sftpPackage" namespace="ace"/><installed-package name="apiToolkit" namespace="acx"/><installed-package name="configurationManager" namespace="acx"/><installed-package name="core" namespace="acx"/><installed-package name="fileManager" namespace="acx"/><installed-package name="cxb_PFS" namespace="cxb"/><installed-package name="cxb_PKG4" namespace="cxb"/><installed-package name="content" namespace="ncm"/><installed-package name="aamIntegration" namespace="nms"/><installed-package name="azuredw" namespace="nms"/><installed-package name="billing" namespace="nms"/><installed-package name="campaign" namespace="nms"/><installed-package name="centralLocal" namespace="nms"/><installed-package name="core" namespace="nms"/><installed-package name="coreInteraction" namespace="nms"/><installed-package name="country" namespace="nms"/><installed-package name="federatedDataAccess" namespace="nms"/><installed-package name="folder" namespace="nms"/><installed-package name="hive" namespace="nms"/><installed-package name="interaction" namespace="nms"/><installed-package name="interactionControl" namespace="nms"/><installed-package name="japanLoc" namespace="nms"/><installed-package name="macIntegration" namespace="nms"/><installed-package name="messageCenter" namespace="nms"/><installed-package name="messageCenterControl" namespace="nms"/><installed-package name="midEmitter" namespace="nms"/><installed-package name="mobile" namespace="nms"/><installed-package name="mobileApp" namespace="nms"/><installed-package name="mrm" namespace="nms"/><installed-package name="paper" namespace="nms"/><installed-package name="phone" namespace="nms"/><installed-package name="report" namespace="nms"/><installed-package name="response" namespace="nms"/><installed-package name="ruleset" namespace="nms"/><installed-package name="simulation" namespace="nms"/><installed-package name="social" namespace="nms"/><installed-package name="survey" namespace="nms"/><installed-package name="systemStrings" namespace="nms"/><installed-package name="webAnalytics" namespace="nms"/><installed-package name="core" namespace="xtk"/></userInfo></sessionInfo></pSessionInfo><pstrSecurityToken xsi:type="xsd:string">@3PKpbKVopBgCEtXl7jkfsil3d_S-su4FQU-mqeay9_R7aywbl4CKhUqH_a_IK7OlcQXligoucslvFnnZUxNbsYk9L18uRgcYkjiC8DT9FU4=</pstrSecurityToken></LogonResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
		Map<String,String> token = new Map<String,String>();
		Response resultMethod = new Response();
		String methodName = 'Logon';
		Map<String, String> mapHeader = buildHeaderRequest('"xtk:session#Logon"');
		AV_ApiCallout apiCallout = new AV_ApiCallout();
		apiCallout.setIsActive(true);
		apiCallout.setMethod('POST');
        
        if (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) {
            apiCallout.setEndpoint('callout:EV_PROAdobeCampaign');
        } else {
            apiCallout.setEndpoint('callout:EV_PREAdobeCampaign');
        }
    	
        String body = buildCallRequestBodyLogin();
        
		apiCallout.setHeaders(mapHeader);
		apiCallout.setBody(body);
		apiCallout.addContentTypeJsonHeader();
		apiCallout.debugMode();
		apiCallout.runCallout();           
		EV_LogDebug.printLogDebug('apiCallout', String.valueOf(apiCallout));
		EV_LogDebug.printLogDebug(methodName, '*****************************************');
		EV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
	
		//Check errors:
		String resultStatusCode = resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();
		if(reqStatusOK){
			EV_LogDebug.printLogDebug('Body Response ', String.valueOf(apiCallout.getBodyResponse()));
			DOM.Document document = new DOM.Document();
			document.load(apiCallout.getBodyResponse());
			for(Dom.XmlNode response : document.getRootElement().getChildElements()) {
				EV_LogDebug.printLogDebug('Response', String.valueOf(response));
				for(Dom.XmlNode responseNode : response.getChildElements()) {
					if(responseNode.getName() == 'Fault') {
						EV_LogDebug.printLogDebug('responseNode child', responseNode.getChildElement('faultcode',null).getText());
						EV_LogDebug.printLogDebug('responseNode child', responseNode.getChildElement('faultstring',null).getText());
					}else if(responseNode.getName() == 'LogonResponse'){
						for(Dom.XmlNode responseNode2 : responseNode.getChildElements()){
							if(responseNode2.getName() == 'pstrSessionToken'){
								EV_LogDebug.printLogDebug('responseNode2', String.valueOf(responseNode2));
								token.put('pstrSessionToken',responseNode2.getText());
							}
							if(responseNode2.getName() == 'pstrSecurityToken'){
								EV_LogDebug.printLogDebug('responseNode2', String.valueOf(responseNode2));
								token.put('pstrSecurityToken',responseNode2.getText());
							}
						}
						
					}
				}
			}
        }else{
            token.put('Error',resultStatusCode);
        }
		EV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + reqStatusOK);
        EV_LogDebug.printLogDebug(methodName, 'token login: ' + token);
		return token;
	}
	
    public static String buildCallRequestBodyLogin() {

		// initial part of the soap header for the appropriate
		String xmlBody =  +'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:xtk:session">'
		+'<soapenv:Header/>'
		+'<soapenv:Body>'
			+'<urn:Logon>'
			+'<urn:sessiontoken></urn:sessiontoken>'
			+'<urn:strLogin>'+ '{!$Credential.Username}' +'</urn:strLogin>'
			+'<urn:strPassword>'+ '{!$Credential.Password}' +'</urn:strPassword>'
			+'<urn:elemParameters></urn:elemParameters>'
			+'</urn:Logon>'
		+'</soapenv:Body>'
		+'</soapenv:Envelope>';
	
		// YOUR LOGIC TO STRUCTURE THE XML BODY WILL GO HERE
	
		return xmlBody;
	}
	
	public static Map<String, String> buildHeaderRequest( String soapAction){
	  
		Map<String, String> mapHeader = new Map<String, String>();
		mapHeader.put('SOAPAction', soapAction);

		return mapHeader;
	  
	}


	public static void inscriptionEvent(String campaignMemberId, String campaignId, String campaignEmail, Lead visitor, CampaignMember campMember){
        EV_LogDebug.printLogDebug('@@inscriptionEvent: ', String.valueOf(campMember));
		String methodName = 'inscriptionEvent';
        Map<String,String> token = new Map<String,String>();
        //Accedemos a la custom setting para recuperar a los tokens
        EV_ByPass__c cSettingTokens = EV_ByPass__c.getOrgDefaults();
        if(cSettingTokens.EV_pstrSecurityToken__c != null && cSettingTokens.EV_pstrSessionToken__c != null && !Test.isRunningTest()){
            EV_LogDebug.printLogDebug('@@cSettingTokens access', String.valueOf(cSettingTokens));
        	token.put('pstrSecurityToken',cSettingTokens.EV_pstrSecurityToken__c);
            token.put('pstrSessionToken',cSettingTokens.EV_pstrSessionToken__c);
            
        }else{
            token = login();
        }
      
		String mockString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cxb="sfdc:TBL_SLFC_CAMPAIGN"><soapenv:Header/><soapenv:Body><cxb:inscriptionEvent><cxb:sessiontoken>'+token.get('pstrSessionToken')+'</cxb:sessiontoken><cxb:campaignMemberId>00v5E00000Dw9SPQAZ</cxb:campaignMemberId><cxb:campaignId>7015E000000muGZQAY</cxb:campaignId></cxb:inscriptionEvent></soapenv:Body></soapenv:Envelope>';
		Response resultMethod = new Response();
		
		String body = buildCallRequestBodyInscriptionEvent(campaignMemberId, campaignId, campaignEmail, visitor, token, campMember);
		Map<String, String> mapHeader = buildHeaderRequest('"sfdc:TBL_SLFC_CAMPAIGN#inscriptionEvent"');
		mapHeader.put('cookie', '__sessiontoken=' + token.get('pstrSessionToken'));
		mapHeader.put('X-Security-Token', token.get('pstrSecurityToken'));
		mapHeader.put('Content-Type', 'application/json; charset=utf-8');
		EV_LogDebug.printLogDebug('@@@MapHeaders: ', String.valueOf(mapHeader));
        
		AV_ApiCallout apiCallout = new AV_ApiCallout();
		apiCallout.setIsActive(true);
		apiCallout.setMethod('POST');
        if (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) {
            apiCallout.setEndpoint('callout:EV_PROAdobeCampaign');
        } else {
            apiCallout.setEndpoint('callout:EV_PREAdobeCampaign');
        }
        
		apiCallout.setHeaders(mapHeader);
		apiCallout.setBody(body);
		apiCallout.addContentTypeJsonHeader();
		apiCallout.debugMode();
		apiCallout.runCallout();
      
		EV_LogDebug.printLogDebug('@@apicallout', String.valueOf(apiCallout));
		EV_LogDebug.printLogDebug('@@apiCallout.getResponse()', String.valueOf(apiCallout.getResponse()));
		EV_LogDebug.printLogDebug(methodName, '*****************************************');
		EV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
		//Check errors:
		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        EV_LogDebug.printLogDebug('@@resultMethod', String.valueOf(resultMethod.statusCode) + ' '+String.valueOf(resultMethod.errorMessage));
		if(reqStatusOK){
            if(cSettingTokens.EV_pstrSecurityToken__c != token.get('pstrSecurityToken') && cSettingTokens.EV_pstrSessionToken__c != token.get('pstrSessionToken')){
            	cSettingTokens.EV_pstrSecurityToken__c =  token.get('pstrSecurityToken');
            	cSettingTokens.EV_pstrSessionToken__c = token.get('pstrSessionToken');
            	upsert cSettingTokens;
        }
			EV_LogDebug.printLogDebug(methodName, 'Body Response' + apiCallout.getBodyResponse());
        }/*else if(resultMethod.statusCode == '401' || resultMethod.statusCode == '403'){
            system.debug('@@entro en error '+ resultMethod.statusCode);
            token = login();
            inscriptionEvent(campaignMemberId, campaignId, campaignEmail, visitor, campMember);
        }*/
		EV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + +reqStatusOK);
	}


	//Generación de SOAP para llamada.
	public static String buildCallRequestBodyInscriptionEvent(String campaignMemberId, String campaignId, String campaignEmail, Lead visitor, Map<String,String> tokens, CampaignMember campMember) {
		EV_LogDebug.printLogDebug('@@buildCallRequestBodyInscriptionEvent ', campaignMemberId + campaignId + campaignEmail + String.valueOf(visitor) + String.valueOf(tokens) + String.valueOf(campMember));
		// initial part of the soap header for the appropriate
		String xmlBody = ''; 

		if(campaignEmail != null && visitor == null){
			EV_LogDebug.printLogDebug('@@campaignEmail != null', campaignEmail);
			xmlBody ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cxb="sfdc:TBL_SLFC_CAMPAIGN">'
			+'<soapenv:Header/>'
			+'<soapenv:Body>'
			+'<cxb:inscriptionEvent>'
			+'<cxb:sessiontoken>'/*+tokens.get('pstrSessionToken')*/+'</cxb:sessiontoken>'
			+'<cxb:campaignMemberId>'+campaignMemberId+'</cxb:campaignMemberId>'
			+'<cxb:campaignId>'+campaignId+'</cxb:campaignId>'
			+'<cxb:campaignEmail>'+campaignEmail+'</cxb:campaignEmail>'
			+'<cxb:visitor>'
			+'<visitor id="" firstName="" lastName="" phone="" email="" status="" recordTypeId="" createdDate="" lastModifiedDate="" EV_Idiomas__c="" EV_NumeroDocumento__c="?" EV_Marketing__c="" EV_ConsentimientoGeneral__c="" EV_ConsentimientoTerceros__c="">'
			+'<campaignMember id="" lastModifiedById="" lastModifiedDate="" createdById="" createdDate="" mobilePhone="" phone="" email="" status="" EV_CanalOrigen__c="" EV_TelefonoDeCampana__c="" EV_Nickname__c="" EV_CodigoQR__c="" AV_NIF__c="" EV_URLEncuesta__c="" EV_ExternalID__c="" EV_URLRegistro__c="" EV_URLStreamingEvento__c=""/>'
			+'</visitor>'
			+'</cxb:visitor>'
			+'</cxb:inscriptionEvent>'
			+'</soapenv:Body>'
			+'</soapenv:Envelope>';
		}else if(campaignEmail == null && visitor == null){
			EV_LogDebug.printLogDebug('@@campaignEmail == null', campaignEmail);
			xmlBody ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cxb="sfdc:TBL_SLFC_CAMPAIGN">'
			+'<soapenv:Header/>'
			+'<soapenv:Body>'
			+'<cxb:inscriptionEvent>'
			+'<cxb:sessiontoken>'/*+tokens.get('pstrSessionToken')*/+'</cxb:sessiontoken>'
			+'<cxb:campaignMemberId>'+campaignMemberId+'</cxb:campaignMemberId>'
			+'<cxb:campaignId>'+campaignId+'</cxb:campaignId>'
			+'<cxb:campaignEmail>'+'</cxb:campaignEmail>'
			+'<cxb:visitor>'
			+'<visitor id="" firstName="" lastName="" phone="" email="" status="" recordTypeId="" createdDate="" lastModifiedDate="" EV_Idiomas__c="" EV_NumeroDocumento__c="?" EV_Marketing__c="" EV_ConsentimientoGeneral__c="" EV_ConsentimientoTerceros__c="">'
			+'<campaignMember id="" lastModifiedById="" lastModifiedDate="" createdById="" createdDate="" mobilePhone="" phone="" email="" status="" EV_CanalOrigen__c="" EV_TelefonoDeCampana__c="" EV_Nickname__c="" EV_CodigoQR__c="" AV_NIF__c="" EV_URLEncuesta__c="" EV_ExternalID__c="" EV_URLRegistro__c="" EV_URLStreamingEvento__c=""/>'
			+'</visitor>'
			+'</cxb:visitor>'
			+'</cxb:inscriptionEvent>'
			+'</soapenv:Body>'
			+'</soapenv:Envelope>';
		}else if(campaignEmail == null && visitor != null){//Si se envía el visitor no se puede enviar el CampaignMemberID del primer nodo.
			EV_LogDebug.printLogDebug('@@campaignEmail == null && visitor !=null', campaignEmail + String.valueOf(visitor));
			xmlBody ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cxb="sfdc:TBL_SLFC_CAMPAIGN">'
			+'<soapenv:Header/>'
			+'<soapenv:Body>'
			+'<cxb:inscriptionEvent>'
			+'<cxb:sessiontoken>'/*+tokens.get('pstrSessionToken')*/+'</cxb:sessiontoken>'
			+'<cxb:campaignMemberId>'+/*campaignMemberId+*/'</cxb:campaignMemberId>'
			+'<cxb:campaignId>'+campaignId+'</cxb:campaignId>'
			+'<cxb:campaignEmail>'+'</cxb:campaignEmail>'
			+'<cxb:visitor>'
			+'<visitor id="'+visitor.Id+'" firstName="'+visitor.FirstName+'" lastName="'+visitor.LastName+'" phone="'+visitor.Phone+'" email="'+visitor.Email+'" status="'+visitor.Status+'" recordTypeId="'+visitor.RecordtypeId+'" createdDate="'+visitor.CreatedDate.format('yyyy-MM-dd HH:mm:ss')+'" lastModifiedDate="'+visitor.LastModifiedDate.format('yyyy-MM-dd HH:mm:ss')+'" EV_Idiomas__c="'+visitor.EV_Idiomas__c+'" EV_NumeroDocumento__c="'+visitor.EV_NumeroDocumento__c+'" EV_Marketing__c="'+visitor.EV_Marketing__c+'" EV_ConsentimientoGeneral__c="'+visitor.EV_ConsentimientoGeneral__c+'" EV_ConsentimientoTerceros__c="'+visitor.EV_ConsentimientoTerceros__c+'">'
			+'<campaignMember id="'+campMember.id+'" EV_FormatodeAsistencias__c="'+campMember.EV_FormatodeAsistencias__c+'" EV_RTCampaign__c="'+campMember.EV_RTCampaign__c+'" lastModifiedById="'+campMember.LastModifiedbyId+'" lastModifiedDate="'+campMember.lastModifiedDate.format('yyyy-MM-dd HH:mm:ss')+'" createdById="'+campMember.createdById+'" createdDate="'+campMember.createdDate.format('yyyy-MM-dd HH:mm:ss')+'" mobilePhone="'+campMember.mobilePhone+'" phone="'+campMember.phone+'" email="'+campMember.email+'" status="'+campMember.status+'" EV_CanalOrigen__c="'+campMember.EV_CanalOrigen__c+'" EV_TelefonoDeCampana__c="'+campMember.EV_TelefonoDeCampana__c+'" EV_Nickname__c="'+campMember.EV_Nickname__c+'" EV_CodigoQR__c="'+campMember.EV_QR__c+'" AV_NIF__c="'+campMember.EV_NumeroDocumento__c+'" EV_URLEncuesta__c="'+campMember.EV_URLEncuesta__c.replace('&','&amp;')+'" EV_ExternalID__c="'+campMember.EV_ExternalID__c+'" EV_URLRegistro__c="'+campMember.EV_URLRegistro__c.replace('&','&amp;')+'" EV_URLStreamingEvento__c="'+campMember.EV_URLStreamingEvento__c.replace('&','&amp;')+'"/>'
			+'</visitor>'
			+'</cxb:visitor>'
			+'</cxb:inscriptionEvent>'
			+'</soapenv:Body>'
			+'</soapenv:Envelope>';
		}
		return xmlBody;
	}
    
    
    public static void inscriptionEventCMCustom(String campaignMemberId, String campaignId, String campaignEmail, Lead visitor, EV_CampaignMemberC__c campMember){
		String methodName = 'inscriptionEvent';
        Map<String,String> token = new Map<String,String>();
        //Accedemos a la custom setting para recuperar a los tokens
        EV_ByPass__c cSettingTokens = EV_ByPass__c.getOrgDefaults();
        if(cSettingTokens.EV_pstrSecurityToken__c != null && cSettingTokens.EV_pstrSessionToken__c != null){
            EV_LogDebug.printLogDebug('@@cSettingTokens access', String.valueOf(cSettingTokens));
        	token.put('pstrSecurityToken',cSettingTokens.EV_pstrSecurityToken__c);
            token.put('pstrSessionToken',cSettingTokens.EV_pstrSessionToken__c);
            
        }else{
            token = login();
        }
        
		String mockString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cxb="sfdc:TBL_SLFC_CAMPAIGN"><soapenv:Header/><soapenv:Body><cxb:inscriptionEvent><cxb:sessiontoken>'+token.get('pstrSessionToken')+'</cxb:sessiontoken><cxb:campaignMemberId>00v5E00000Dw9SPQAZ</cxb:campaignMemberId><cxb:campaignId>7015E000000muGZQAY</cxb:campaignId></cxb:inscriptionEvent></soapenv:Body></soapenv:Envelope>';
		Response resultMethod = new Response();
		CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_CustomerJourney');
		EV_LogDebug.printLogDebug('@@dataInterface ', String.valueOf(dataInterface));
		EV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
		EV_LogDebug.printLogDebug(methodName, '*****************************************');

		

		String body = buildCallRequestBodyInscriptionEventCMCustom(campaignMemberId, campaignId, campaignEmail, visitor, token, campMember);
		EV_LogDebug.printLogDebug('@@body ', body);
		Map<String, String> mapHeader = buildHeaderRequest('"sfdc:TBL_SLFC_CAMPAIGN#inscriptionEvent"');
		mapHeader.put('cookie', '__sessiontoken=' + token.get('pstrSessionToken'));
		mapHeader.put('X-Security-Token', token.get('pstrSecurityToken'));
		mapHeader.put('Content-Type', 'application/json; charset=utf-8');
		EV_LogDebug.printLogDebug('@@@MapHeaders: ', String.valueOf(mapHeader));
		EV_LogDebug.printLogDebug('@@@Body: ', body);
        
		AV_ApiCallout apiCallout = new AV_ApiCallout();
		apiCallout.setIsActive(true);
		apiCallout.setMethod('POST');
        if (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) {
            apiCallout.setEndpoint('callout:EV_PROAdobeCampaign');
        } else {
            apiCallout.setEndpoint('callout:EV_PREAdobeCampaign');
        }
        
		apiCallout.setHeaders(mapHeader);
		apiCallout.setBody(body);
		apiCallout.addContentTypeJsonHeader();
		apiCallout.debugMode();
		apiCallout.runCallout();
      
		EV_LogDebug.printLogDebug('@@apicallout', String.valueOf(apiCallout));
		EV_LogDebug.printLogDebug('@@apiCallout.getResponse()', String.valueOf(apiCallout.getResponse()));
		EV_LogDebug.printLogDebug(methodName, '*****************************************');
		EV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());

		//Check errors:
		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        EV_LogDebug.printLogDebug('@@resultMethod', String.valueOf(resultMethod.statusCode) + ' '+String.valueOf(resultMethod.errorMessage));

		if(reqStatusOK){
			EV_LogDebug.printLogDebug(methodName, 'Body Response' + apiCallout.getBodyResponse());
		}/*else if(resultMethod.statusCode == '401' || resultMethod.statusCode == '403'){
            token = login();
            inscriptionEventCMCustom(campaignMemberId, campaignId, campaignEmail, visitor, campMember);
        }*/
		EV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + +reqStatusOK);
	}


	//Generación de SOAP para llamada.
	public static String buildCallRequestBodyInscriptionEventCMCustom(String campaignMemberId, String campaignId, String campaignEmail, Lead visitor, Map<String,String> tokens, EV_CampaignMemberC__c campMember) {
		EV_LogDebug.printLogDebug('@@buildCallRequestBodyInscriptionEvent ', campaignMemberId + campaignId + campaignEmail + String.valueOf(visitor) + String.valueOf(tokens) + String.valueOf(campMember));
		// initial part of the soap header for the appropriate
		String xmlBody = ''; 

		if(campaignEmail != null && visitor == null){
			EV_LogDebug.printLogDebug('@@campaignEmail != null', campaignEmail);
			xmlBody ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cxb="sfdc:TBL_SLFC_CAMPAIGN">'
			+'<soapenv:Header/>'
			+'<soapenv:Body>'
			+'<cxb:inscriptionEvent>'
			+'<cxb:sessiontoken>'/*+tokens.get('pstrSessionToken')*/+'</cxb:sessiontoken>'
			+'<cxb:campaignMemberId>'+campaignMemberId+'</cxb:campaignMemberId>'
			+'<cxb:campaignId>'+campaignId+'</cxb:campaignId>'
			+'<cxb:campaignEmail>'+campaignEmail+'</cxb:campaignEmail>'
			+'<cxb:visitor>'
			+'<visitor id="" firstName="" lastName="" phone="" email="" status="" recordTypeId="" createdDate="" lastModifiedDate="" EV_Idiomas__c="" EV_NumeroDocumento__c="?" EV_Marketing__c="" EV_ConsentimientoGeneral__c="" EV_ConsentimientoTerceros__c="">'
			+'<campaignMember id="" lastModifiedById="" lastModifiedDate="" createdById="" createdDate="" mobilePhone="" phone="" email="" status="" EV_CanalOrigen__c="" EV_TelefonoDeCampana__c="" EV_Nickname__c="" EV_CodigoQR__c="" AV_NIF__c="" EV_URLEncuesta__c="" EV_ExternalID__c="" EV_URLRegistro__c="" EV_URLStreamingEvento__c=""/>'
			+'</visitor>'
			+'</cxb:visitor>'
			+'</cxb:inscriptionEvent>'
			+'</soapenv:Body>'
			+'</soapenv:Envelope>';
		}else if(campaignEmail == null && visitor == null){
			EV_LogDebug.printLogDebug('@@campaignEmail == null', campaignEmail);
			xmlBody ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cxb="sfdc:TBL_SLFC_CAMPAIGN">'
			+'<soapenv:Header/>'
			+'<soapenv:Body>'
			+'<cxb:inscriptionEvent>'
			+'<cxb:sessiontoken>'/*+tokens.get('pstrSessionToken')*/+'</cxb:sessiontoken>'
			+'<cxb:campaignMemberId>'+campaignMemberId+'</cxb:campaignMemberId>'
			+'<cxb:campaignId>'+campaignId+'</cxb:campaignId>'
			+'<cxb:campaignEmail>'+'</cxb:campaignEmail>'
			+'<cxb:visitor>'
			+'<visitor id="" firstName="" lastName="" phone="" email="" status="" recordTypeId="" createdDate="" lastModifiedDate="" EV_Idiomas__c="" EV_NumeroDocumento__c="?" EV_Marketing__c="" EV_ConsentimientoGeneral__c="" EV_ConsentimientoTerceros__c="">'
			+'<campaignMember id="" lastModifiedById="" lastModifiedDate="" createdById="" createdDate="" mobilePhone="" phone="" email="" status="" EV_CanalOrigen__c="" EV_TelefonoDeCampana__c="" EV_Nickname__c="" EV_CodigoQR__c="" AV_NIF__c="" EV_URLEncuesta__c="" EV_ExternalID__c="" EV_URLRegistro__c="" EV_URLStreamingEvento__c=""/>'
			+'</visitor>'
			+'</cxb:visitor>'
			+'</cxb:inscriptionEvent>'
			+'</soapenv:Body>'
			+'</soapenv:Envelope>';
		}else if(campaignEmail == null && visitor != null){//Si se envía el visitor no se puede enviar el CampaignMemberID del primer nodo.
			EV_LogDebug.printLogDebug('@@campaignEmail == null && visitor !=null', campaignEmail + String.valueOf(visitor));
			xmlBody ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cxb="sfdc:TBL_SLFC_CAMPAIGN">'
			+'<soapenv:Header/>'
			+'<soapenv:Body>'
			+'<cxb:inscriptionEvent>'
			+'<cxb:sessiontoken>'/*+tokens.get('pstrSessionToken')*/+'</cxb:sessiontoken>'
			+'<cxb:campaignMemberId>'+/*campaignMemberId+*/'</cxb:campaignMemberId>'
			+'<cxb:campaignId>'+campaignId+'</cxb:campaignId>'
			+'<cxb:campaignEmail>'+'</cxb:campaignEmail>'
			+'<cxb:visitor>'
			+'<visitor id="'+visitor.Id+'" firstName="'+visitor.FirstName+'" lastName="'+visitor.LastName+'" phone="'+visitor.Phone+'" email="'+visitor.Email+'" status="'+visitor.Status+'" recordTypeId="'+visitor.RecordtypeId+'" createdDate="'+visitor.CreatedDate.format('yyyy-MM-dd HH:mm:ss')+'" lastModifiedDate="'+visitor.LastModifiedDate.format('yyyy-MM-dd HH:mm:ss')+'" EV_Idiomas__c="'+visitor.EV_Idiomas__c+'" EV_NumeroDocumento__c="'+visitor.EV_NumeroDocumento__c+'" EV_Marketing__c="'+visitor.EV_Marketing__c+'" EV_ConsentimientoGeneral__c="'+visitor.EV_ConsentimientoGeneral__c+'" EV_ConsentimientoTerceros__c="'+visitor.EV_ConsentimientoTerceros__c+'">'
			+'<campaignMember id="'+campMember.Id+'" EV_FormatodeAsistencias__c="'+campMember.EV_FormatoDeAsistencias__c+'" EV_RTCampaign__c="'+campMember.EV_RTCampaign__c+'" lastModifiedById="'+campMember.LastModifiedById+'" lastModifiedDate="'+campMember.LastModifiedDate.format('yyyy-MM-dd HH:mm:ss')+'" createdById="'+campMember.CreatedById+'" createdDate="'+campMember.CreatedDate.format('yyyy-MM-dd HH:mm:ss')+'" mobilePhone="'+campMember.EV_MobilePhone__c+'" phone="'+campMember.EV_Phone__c+'" email="'+campMember.EV_Email__c+'" status="'+campMember.EV_Status__c+'" EV_CanalOrigen__c="'+campMember.EV_CanalOrigen__c+'" EV_TelefonoDeCampana__c="'+campMember.EV_TelefonoDeCampana__c+'" EV_Nickname__c="'+campMember.EV_Nickname__c+'" EV_CodigoQR__c="'+campMember.EV_QR__c+'" AV_NIF__c="'+campMember.EV_NumeroDocumento__c+'" EV_URLEncuesta__c="'+campMember.EV_URLEncuesta__c.replace('&','&amp;')+'" EV_ExternalID__c="'+campMember.EV_ExternalID__c+'" EV_URLRegistro__c="'+campMember.EV_URLRegistro__c.replace('&','&amp;')+'" EV_URLStreamingEvento__c="'+campMember.EV_URLStreamingEvento__c.replace('&','&amp;')+'"/>'
			+'</visitor>'
			+'</cxb:visitor>'
			+'</cxb:inscriptionEvent>'
			+'</soapenv:Body>'
			+'</soapenv:Envelope>';
		}
		return xmlBody;
	}
	
}