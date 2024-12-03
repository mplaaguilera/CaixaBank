/**********************************************************************************************************************
 Name:	  EV_AdobeCampaignPO
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Adobe para PO
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US593725			Daniel Rodriguez	15/05/2023			Add named credentials to login		

***********************************************************************************************************************/
public with sharing class EV_AdobeCampaignPO {

	public class Response {
        public String StatusCode;
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
        
		EV_LogDebug.printLogDebug(methodName, '*****************************************');
		EV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
	
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
					EV_LogDebug.printLogDebug('@@faultcode', responseNode.getChildElement('faultcode',null).getText());
					EV_LogDebug.printLogDebug('@@faultstring', responseNode.getChildElement('faultstring',null).getText());
				}else if(responseNode.getName() == 'LogonResponse'){
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
		EV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + +reqStatusOK);
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

	public static Map<String, String> buildHeaderRequest(String soapAction){
      
		Map<String, String> mapHeader = new Map<String, String>();
		mapHeader.put('SOAPAction', soapAction);
		
		return mapHeader;
		
	}

	
	public static void voulmePORequest(String campaignId, EV_DataTablePO_Controller.WrapperDataCPOAC cPOAC, String IdPO){
		String methodName = 'targetAudienceSelectionEvent';
		/*String mockString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sfdc="sfdc:TBL_SLFC_CAMPAIGN"><soapenv:Header/><soapenv:Body><sfdc:targetAudienceSelectionEvent><sfdc:sessiontoken>'+login().get('pstrSessionToken')+'</sfdc:sessiontoken><sfdc:campaignMemberId>00v5E00000Dw9SPQAZ</sfdc:campaignMemberId><sfdc:campaignId>7015E000000muGZQAY</sfdc:campaignId></sfdc:targetAudienceSelectionEvent></soapenv:Body></soapenv:Envelope>';*/
		Response resultMethod = new Response();
        
		Map<String,String> token = login();
		String body = buildCallRequestBodyVolumePO(campaignId, cPOAC, IdPO);
		Map<String, String> mapHeader = buildHeaderRequest('"sfdc:TBL_SLFC_CAMPAIGN#targetAudienceSelectionEvent"');
		mapHeader.put('cookie', '__sessiontoken=' + token.get('pstrSessionToken'));
		mapHeader.put('X-Security-Token', token.get('pstrSecurityToken'));
		mapHeader.put('Content-Type', 'text/xml; charset=utf-8');
		
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
	
	//Generación de SOAP para llamada.
	public static String buildCallRequestBodyVolumePO(String campaignId, EV_DataTablePO_Controller.WrapperDataCPOAC cPOAC, String IdPO) {
		
		// initial part of the soap header for the appropriate
		String xmlBody = ''; 
		String ev_Centro = '';
		String ev_DAN ='';
		String ev_DT = '';
		String ev_Sexo = '';
		String ev_TipoCliente = '';
		String ev_CarteraGestor = '';
		String ev_Provincia = '';
		String ev_CanalEnvioComunicacionAlCliente = '';
		String ev_Idioma ='';
		Decimal ev_maxVolume =  500000;
		Campaign camp = [SELECT Id, EV_MaxVolumePO__c FROM Campaign WHERE Id = :campaignId];
		if (camp.EV_MaxVolumePO__c != null) {
			ev_maxVolume = camp.EV_MaxVolumePO__c;
		} 
		if (String.isNotBlank(cPOAC.EV_Centro)) {
			ev_Centro = cPOAC.EV_Centro+',';
		} else {
			ev_Centro = cPOAC.EV_Centro ;
		}
		if (String.isNotBlank(cPOAC.EV_DAN)) {
			ev_DAN = cPOAC.EV_DAN+',';
		} else {
			ev_DAN = cPOAC.EV_DAN ;
		}
		if (String.isNotBlank(cPOAC.EV_DT)) {
			ev_DT= cPOAC.EV_DT+',';
		} else {
			ev_DT= cPOAC.EV_DT ;
		}
	
		if (String.isNotBlank(cPOAC.EV_Sexo)) {
			ev_Sexo = cPOAC.EV_Sexo+',';
		} else {
			ev_Sexo = cPOAC.EV_Sexo  ;
		}
		if (String.isNotBlank(cPOAC.EV_TipoCliente)) {
			ev_TipoCliente= cPOAC.EV_TipoCliente+',' ;
		} else {
			ev_TipoCliente= cPOAC.EV_TipoCliente ;
		}
		if (String.isNotBlank(cPOAC.EV_CarteraGestor)) {
			ev_CarteraGestor= cPOAC.EV_CarteraGestor +',' ;
		} else {
			ev_CarteraGestor= cPOAC.EV_CarteraGestor;
		}
		if (String.isNotBlank(cPOAC.EV_Provincia)) {
			ev_Provincia = cPOAC.EV_Provincia+',';
		} else {
			ev_Provincia = cPOAC.EV_Provincia ;
		}
		if (String.isNotBlank(cPOAC.EV_CanalEnvioComunicacionAlCliente)) {
			ev_CanalEnvioComunicacionAlCliente =  cPOAC.EV_CanalEnvioComunicacionAlCliente+',';
		} else {
			ev_CanalEnvioComunicacionAlCliente =  cPOAC.EV_CanalEnvioComunicacionAlCliente ;
		}
		if (String.isNotBlank(cPOAC.EV_Idioma)) {
			ev_Idioma= cPOAC.EV_Idioma+',';
		} else {
			ev_Idioma= cPOAC.EV_Idioma ;
		}

		Map<String,String> token = login();
		if(campaignId != null){
			xmlBody ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sfdc="sfdc:TBL_SLFC_CAMPAIGN">'
			+'<soapenv:Header/>'
			+'<soapenv:Body>'
			+'<sfdc:targetAudienceSelectionEvent>'
			+'<sfdc:sessiontoken>'+token.get('pstrSessionToken')+'</sfdc:sessiontoken>'
			+'<sfdc:id>'+IdPO+'</sfdc:id>'
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
			+'" EV_Centro__c="'+ev_Centro
			+'" EV_DAN__c="'+ev_DAN
			+'" EV_DT__c="' + ev_DT
			+'" EV_EdadMaxima__c="'+Integer.valueOf(cPOAC.EV_EdadMaxima)
			+'" EV_EdadMinima__c="'+Integer.valueOf(cPOAC.EV_EdadMinima)
			+'" EV_Interlocutor__c="'+cPOAC.EV_Interlocutor
			+'" EV_Sexo__c="'+ev_Sexo
			+'" EV_TipoCliente__c="'+ ev_TipoCliente
			+'" EV_Ciencia__c="'+cPOAC.EV_Ciencia
			+'" EV_CarteraGestor__c="'+ev_CarteraGestor
			+'" EV_Provincia__c="'+ ev_Provincia
			+'" EV_CanalEnvioComunicacionAlCliente__c="'+ev_CanalEnvioComunicacionAlCliente
			+'" EV_Idioma__c= "'+ev_Idioma
			+'" EV_Saturation__c="'+cPOAC.EV_Saturation+'"/>'
			+'</sfdc:criteria>'
			+'<sfdc:maxVolume>'+ev_maxVolume+'</sfdc:maxVolume>'
			+'</sfdc:targetAudienceSelectionEvent>'
			+'</soapenv:Body>'
			+'</soapenv:Envelope>';
		}
		return xmlBody;
	}

	public static void confirmationPORequest(String campaignId){
		String methodName = 'targetAudienceConfirmationEvent';
		/*String mockString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sfdc="sfdc:TBL_SLFC_CAMPAIGN"><soapenv:Header/><soapenv:Body><sfdc:targetAudienceSelectionEvent><sfdc:sessiontoken>'+login().get('pstrSessionToken')+'</sfdc:sessiontoken><sfdc:campaignMemberId>00v5E00000Dw9SPQAZ</sfdc:campaignMemberId><sfdc:campaignId>7015E000000muGZQAY</sfdc:campaignId></sfdc:targetAudienceSelectionEvent></soapenv:Body></soapenv:Envelope>';*/
		Response resultMethod = new Response();
	
		Map<String,String> token = login();
	
		String body = buildCallRequestBodyconfirmationPO(campaignId);
		Map<String, String> mapHeader = buildHeaderRequest('"sfdc:TBL_SLFC_CAMPAIGN#targetAudienceConfirmationEvent"');
		mapHeader.put('cookie', '__sessiontoken=' + token.get('pstrSessionToken'));
		mapHeader.put('X-Security-Token', token.get('pstrSecurityToken'));
		mapHeader.put('Content-Type', 'text/xml; charset=utf-8');
		
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

	//Generación de SOAP para llamada.
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
}