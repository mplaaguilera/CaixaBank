/**********************************************************************************************************************
Name:      CIBE_Teams_Integration
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración con Teams
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY 			AUTHOR              DATE                Description
    1.0            US507827    	        Alex Campos         31/01/2023          Init version (Copy from retail)

***********************************************************************************************************************/
public with sharing class CIBE_Teams_Integration {

	public static final String AV_TEAMSLOGIN   = 'AV_TeamsLogin';

	public class Response {
		public String errorMessage;
		public String statusCode;
		public String errorCode;
		public ResponseTeamsLogin data;
	}

	public class ResponseTeamsLogin {
		public String token_type;
		public Integer expires_in;
		public Integer ext_expires_in;
		public String access_token;
	}

	public class Meeting{
		public Datetime startDateTime;
		public Datetime endDateTime;
		public String subject;
	}

	public class ErrorResponseTeamsLogin {
		public String error;
		public String error_description;
		public List<Integer> error_codes;
		public Datetime timestamp;
		public String trace_id;
		public String correlation_id;
	}

	public class ResponseUser {
		public String errorMessage;
		public String statusCode;
		public String errorCode;
		public ResponseUserBody body;
	}

	public class ResponseMeeting {
		public String errorMessage;
		public String statusCode;
		public String errorCode;
		public ResponseMeetingBody body;
	}

	public class ResponseUserBody{
		public String contex;
		public List<String> businessPhones;
		public String displayName;
		public String givenName;
		public String jobTitle;
		public String mail;
		public String mobilePhone;
		public String officeLocation;
		public String preferredLanguage;
		public String surname;
		public String userPrincipalName;
		public String id;
	}

	public class UserIn {
		public String id;
		public String displayName;
	}
	
	public class ResponseMeetingBody{
		public String odata_type;// in json: @odata.type
		public String odata_context;// in json: @odata.context
		public AudioConferencing audioConferencing;
		public ChatInfo chatInfo;
		public String creationDateTime;
		public String startDateTime;
		public String endDateTime;
		public String id;
		public String joinWebUrl;
		public Participants participants;
		public String subject;
	}
	
	public class ChatInfo {
		public String threadId;
		public String messageId;
		public String replyChainMessageId;
	}
	
	public class Organizer {
		public Identity identity;
		public String upn;
	}
	
	public class AudioConferencing {
		public String tollNumber;
		public String tollFreeNumber;
		public String ConferenceId;
		public String dialinUrl;
	}
	
	public class Participants {
		public Organizer organizer;
	}
	
	public class Identity {
		public UserIn user;
	}

	public static Response getToken(){
		Response resultMethod = new Response();
		String methodName = 'getToken';
		
		CC_InterfaceSettings__mdt dataInterface = CIBE_IntegrationUtilities.fetchMetadataInterface(AV_TEAMSLOGIN);
		
		Map<String, String> mapHeader = new Map<String, String>();
		mapHeader.put(CIBE_IntegrationConstants.HEADER_CONTENT_TYPE, CIBE_IntegrationConstants.HEADER_CONTENT_TYPE_VALUE_FORM_URLENCODED);
		mapHeader.put(CIBE_IntegrationConstants.HEADER_ACCEPT, CIBE_IntegrationConstants.HEADER_ACCEPT_VALUE_JSON);

		// recoger CC_Body__c sustituir campo {username} por AV_Username__c y {password} por AV_Password__c
		String body = dataInterface.CC_Body__c.replace('{username}', dataInterface.AV_Username__c);
		String bodyFinal = body.replace('{password}',getJWSToken());

		// el campo CC_EndPoint__c sustituir campo tenant por CC_SoapAction__c despues del igual
		String tenant = dataInterface.CC_SoapAction__c.substringAfter('=');
		String endPoint = dataInterface.CC_EndPoint__c.replace('{tenant}',tenant);
		AV_ApiCallout apiCallout = new AV_ApiCallout()
			.setIsActive(dataInterface.CC_Activa__c)
			.setMethod(dataInterface.CC_TipoPeticion__c)
			.setEndpoint(endPoint) 
			.setCertificate(dataInterface.CC_Certificado__c)
			.setBody(bodyFinal)
			//.addContentTypeJsonHeader()
			.setHeaders(mapHeader)
			.debugMode()
			//.setDataMockup('{"token_type":"Bearer","expires_in":86399,"ext_expires_in":86399,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6ImI3UkllanVkNzNNS0pKd0hSaGN5RWlxT3kwMkVNSmd1NGxjNlVQUXByYlUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTI2MDEwLCJuYmYiOjE2MTg5MjYwMTAsImV4cCI6MTYxOTAxMjcxMCwiYWlvIjoiRTJaZ1lHZzFpSzc0RTNLTE9aVHQ2TGRLMjRhSEFBPT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6IlNCQ3pzMVFXZ0UtSUR0bjE1UUVoQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.d0-GfU_40TWZg9B52QCxBC2i9talgvsDFdWtZqEqekeT5KpX3Zbki1MPHCk0vfjoTWzlQjzwj8NTFNqiVZd1sZJ937QIrT_keNBswCe7sUL8ye4_-3Y2U4u9X7Zjgr2ysKeZZ85YpOluvtKgPP4ophDlye7ruh81y9IbiyCwOBXsvNU74t09-FmV7tB9rqpxU8xeRGlSsZTKgV9dTlDyhc1ZCDIe6T41rSqq1z0g3R-xut0oPiaQ8RTkOpDLpoZLacm_rrlfkcwobyPlXqdJeQfDobAz6aMpZzU04Hh4-b0TyONO0b6gr7jb4YG1aP5pqPy_QH3J0zh5yUCevquoDg"}')
			.runCallout();
		
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
		//Response: {Body={"token_type":"Bearer","expires_in":86399,"ext_expires_in":86399,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IjhpUm54QmFEeXNQd0pTb0Rtd1lqQllGS2pqby1QS2sweldYN3dOYkRVLUUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTkyOTYxLCJuYmYiOjE2MTg5OTI5NjEsImV4cCI6MTYxOTA3OTY2MSwiYWlvIjoiRTJaZ1lQaXJ4N2xVNE11bEU5ZVlqMjY0VlBsME5nQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6InlxYXkzc2FLVDBhTXNEMWVmQlBJQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.fxx3i9FDTx10PK5l5d4TcxOWepZ5eYK7HAsUcCV19Q9iFQPR9sFOOFCR0NHaChDPwS4jfnZQzhcqA0PnrUhLl8PakVxn9WJP3Dls55JUZYyoDnYZ_rT4tNc0eq4Al-K7SWj977yIRRUAdmwqo39-jHMULD9YTBEBM6YZFxaaBjA26tWAj3tb-HIPgcjFkdGXiWFnqfDX1xZtSSUz8jq2nVqqXL4UUiYx7jShA0CsHR49St0pWiPsaRGv4bPrhST5C7xHm1o9ltFhRk8pVGNf0fPEusOHo4jBMP8cBNAxOCel6_A9_d70j3Q6aAMyM0MKv2MhTQ5JTNS23XjiTX4RcQ"}, Status=OK, StatusCode=200, TimeElapsed=345}			
		//Check errors:
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();
		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();
		
		if (reqStatusOK){
			ResponseTeamsLogin bodyResponse = (CIBE_Teams_Integration.ResponseTeamsLogin)apiCallout.getBodyResponse('CIBE_Teams_Integration.ResponseTeamsLogin');
			resultMethod.data = bodyResponse;
		} else {
			ErrorResponseTeamsLogin bodyResponse = (CIBE_Teams_Integration.ErrorResponseTeamsLogin)apiCallout.getBodyResponse('CIBE_Teams_Integration.ErrorResponseTeamsLogin');
			resultMethod.errorMessage = bodyResponse.error_description;
			string errorCodes = string.join(bodyResponse.error_codes,', ');
			resultMethod.errorCode = errorCodes;
		}

		AV_LogDebug.printLogDebug(methodName, 'Result method: ' + resultMethod);
		//Result method: Response:[data=ResponseTeamsLogin:[access_token=eyJ0eXAiOiJKV1QiLCJub25jZSI6Ikswc3F0VWlFa29HTVJyZkJCUzJNMmxOSDNHRkZIMHpHWnB4aFZvSEZPMjQiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTk0MjAxLCJuYmYiOjE2MTg5OTQyMDEsImV4cCI6MTYxOTA4MDkwMSwiYWlvIjoiRTJaZ1lEangwYWhlYkpOeDE4STlJdnQzZmhFeUFnQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6ImFFejZQWGxQbzBtbXVuWUlIdnE5QUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.Wo5faLe-RdB87I78AwMXJMC4zqyVo8CNk3ihZ86qkf_4eMcln_jV7d9lk7JtRwg4ry_bGgq91lJsOzIJzqFKA_rW561ee10WR6H3E3RFNrQ-U2jIQQfdMofnhBMyH5-fz7b2JIF60EbT3tonnSlmG1-ZzR0zesSSQkMDHqGYeEuBIp4PDKfdpHyobaW0srpIwUPIAacabT19vEEcOFN6mFC2kYs5kudRrhd9i55ZjLqozH35mlCNtQYj-CLuTPrIdxQGfDWAqHxwdRSttI1JcIkBcHOW14wXTNejnSQX1Ncjn3BxGrzj6CLrZDQtI_jYMBtf6sVhJVvg__8M69t4rw, expires_in=86399, ext_expires_in=86399, token_type=Bearer], errorCode=200, errorMessage=null, statusCode=200]
		AV_LogDebug.printLogDebug(methodName, '*******' + resultMethod.data.access_token.length());
		return resultMethod;
	}

	public static String getUserId(String token, String username){
		ResponseUser resultMethod = new ResponseUser();
		String methodName = 'getUserId';

		CC_InterfaceSettings__mdt dataInterface = CIBE_IntegrationUtilities.fetchMetadataInterface('AV_TeamGetUserId');
		AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		
		Map<String, String> mapHeader = new Map<String, String>();
		mapHeader.put('Content-Type','application/json');
		mapHeader.put('Accept','text/html, application/json');
		// recoger CC_Body__c sustituir campo {username} por AV_Username__c y {password} por AV_Password__c
		String endPoint=dataInterface.CC_EndPoint__c.replace('{userPrincipalName}',username);
		AV_ApiCallout apiCallout = new AV_ApiCallout()
			.setIsActive(dataInterface.CC_Activa__c)
			.setMethod(dataInterface.CC_TipoPeticion__c)
			.setEndpoint(endPoint) 
			.setCertificate(dataInterface.CC_Certificado__c)
			.addAuthorizationBearerHeader(token)
			//.addContentTypeJsonHeader()
			.setHeaders(mapHeader)
			.debugMode()
			//.setDataMockup('{"token_type":"Bearer","expires_in":86399,"ext_expires_in":86399,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6ImI3UkllanVkNzNNS0pKd0hSaGN5RWlxT3kwMkVNSmd1NGxjNlVQUXByYlUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTI2MDEwLCJuYmYiOjE2MTg5MjYwMTAsImV4cCI6MTYxOTAxMjcxMCwiYWlvIjoiRTJaZ1lHZzFpSzc0RTNLTE9aVHQ2TGRLMjRhSEFBPT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6IlNCQ3pzMVFXZ0UtSUR0bjE1UUVoQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.d0-GfU_40TWZg9B52QCxBC2i9talgvsDFdWtZqEqekeT5KpX3Zbki1MPHCk0vfjoTWzlQjzwj8NTFNqiVZd1sZJ937QIrT_keNBswCe7sUL8ye4_-3Y2U4u9X7Zjgr2ysKeZZ85YpOluvtKgPP4ophDlye7ruh81y9IbiyCwOBXsvNU74t09-FmV7tB9rqpxU8xeRGlSsZTKgV9dTlDyhc1ZCDIe6T41rSqq1z0g3R-xut0oPiaQ8RTkOpDLpoZLacm_rrlfkcwobyPlXqdJeQfDobAz6aMpZzU04Hh4-b0TyONO0b6gr7jb4YG1aP5pqPy_QH3J0zh5yUCevquoDg"}')
			.runCallout();
		
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
		//Response: {Body={"token_type":"Bearer","expires_in":86399,"ext_expires_in":86399,"access_token":"eyJ0eXAiOiJKV1QiLCJub25jZSI6IjhpUm54QmFEeXNQd0pTb0Rtd1lqQllGS2pqby1QS2sweldYN3dOYkRVLUUiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWF0IjoxNjE4OTkyOTYxLCJuYmYiOjE2MTg5OTI5NjEsImV4cCI6MTYxOTA3OTY2MSwiYWlvIjoiRTJaZ1lQaXJ4N2xVNE11bEU5ZVlqMjY0VlBsME5nQT0iLCJhcHBfZGlzcGxheW5hbWUiOiJUdXRvcmlhbCBTYW1wbGUgQXBwIiwiYXBwaWQiOiI2NzMxZGU3Ni0xNGE2LTQ5YWUtOTdiYy02ZWJhNjkxNDM5MWUiLCJhcHBpZGFjciI6IjEiLCJpZHAiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83MmY5ODhiZi04NmYxLTQxYWYtOTFhYi0yZDdjZDAxMWRiNDcvIiwiaWR0eXAiOiJhcHAiLCJvaWQiOiJhODRkYjQ0YS1jZTlhLTQ4N2UtYTgxYi1hMTFkOTEyZTRjMGQiLCJyaCI6IjAuQVJvQXY0ajVjdkdHcjBHUnF5MTgwQkhiUjNiZU1XZW1GSzVKbDd4dXVta1VPUjRhQUFBLiIsInN1YiI6ImE4NGRiNDRhLWNlOWEtNDg3ZS1hODFiLWExMWQ5MTJlNGMwZCIsInRlbmFudF9yZWdpb25fc2NvcGUiOiJXVyIsInRpZCI6IjcyZjk4OGJmLTg2ZjEtNDFhZi05MWFiLTJkN2NkMDExZGI0NyIsInV0aSI6InlxYXkzc2FLVDBhTXNEMWVmQlBJQUEiLCJ2ZXIiOiIxLjAiLCJ4bXNfdGNkdCI6MTI4OTI0MTU0N30.fxx3i9FDTx10PK5l5d4TcxOWepZ5eYK7HAsUcCV19Q9iFQPR9sFOOFCR0NHaChDPwS4jfnZQzhcqA0PnrUhLl8PakVxn9WJP3Dls55JUZYyoDnYZ_rT4tNc0eq4Al-K7SWj977yIRRUAdmwqo39-jHMULD9YTBEBM6YZFxaaBjA26tWAj3tb-HIPgcjFkdGXiWFnqfDX1xZtSSUz8jq2nVqqXL4UUiYx7jShA0CsHR49St0pWiPsaRGv4bPrhST5C7xHm1o9ltFhRk8pVGNf0fPEusOHo4jBMP8cBNAxOCel6_A9_d70j3Q6aAMyM0MKv2MhTQ5JTNS23XjiTX4RcQ"}, Status=OK, StatusCode=200, TimeElapsed=345}			
		//Check errors:
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();
		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();
		
		if (reqStatusOK){
			String body = apiCallout.getBodyResponse().replaceAll('@odata.contex', 'contex');
			ResponseUserBody bodyResponse = (CIBE_Teams_Integration.ResponseUserBody)  JSON.deserialize(body, ResponseUserBody.class) ;
			resultMethod.body = bodyResponse;
			return resultMethod.body.id;
		}else{
			return null;
		}
	}

	public static String createMeeting(String token, Meeting meeting, String userId ){

		ResponseMeeting resultMethod = new ResponseMeeting();
		String methodName = 'getToken';

		CC_InterfaceSettings__mdt dataInterface = CIBE_IntegrationUtilities.fetchMetadataInterface('AV_TeamCreateMeeting');
		AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		Map<String, String> mapHeader = new Map<String, String>();
		mapHeader.put('Content-Type','application/json');
		mapHeader.put('Accept','text/html, application/json');
		String body = JSON.serialize(meeting);
		String endPoint=dataInterface.CC_EndPoint__c.replace('{userId}',userId);
		AV_ApiCallout apiCallout = new AV_ApiCallout()
			.setIsActive(dataInterface.CC_Activa__c)
			.setMethod(dataInterface.CC_TipoPeticion__c)
			.setEndpoint(endPoint) 
			.setCertificate(dataInterface.CC_Certificado__c)
			.addAuthorizationBearerHeader(token)
			.setBody(body)
			//.setBody(meeting)
			.setHeaders(mapHeader)
			.debugMode()
			.runCallout();
		
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
		//Check errors:
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();
		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();
		
		if (reqStatusOK){
			String bodyRes = apiCallout.getBodyResponse().replaceAll('@odata.type', 'odata_type').replaceAll('@odata.context', 'odata_context');
			ResponseMeetingBody bodyResponse = (CIBE_Teams_Integration.ResponseMeetingBody)  JSON.deserialize(bodyRes, ResponseMeetingBody.class) ;
			resultMethod.body = bodyResponse;
			return resultMethod.body.joinWebUrl;
		} else {
			return null;
		}
	}

	public static String getJWSToken(){
		CC_InterfaceSettings__mdt dataInterface = CIBE_IntegrationUtilities.fetchMetadataInterface(AV_TEAMSLOGIN);
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
		DateTime exp = DateTime.now().addMinutes(5);
		DateTime nbf = DateTime.now();         
		String alg = 'RS256';
		
		String iss1 = dataInterface.AV_Username__c;
		String tenant=dataInterface.CC_SoapAction__c.substringAfter('=');
		String aud1 = dataInterface.CC_ConvAmbito__c.replace('{tenant}',tenant);
		String sub1 = dataInterface.AV_Username__c;
		
		String headerJson = '{"typ":"JWT","alg":"RS256","kid":"' + dataInterface.AV_Password__c + '"}';
		String bodyJson =  '{"iss":"' + iss1 + '","sub":"' + sub1 + '","jti":"' + guid + '","aud":"' + aud1 + '","exp":' + (exp.getTime() / 1000) + ',"nbf":'+ (nbf.getTime() / 1000) + '}';
		String token = EncodingUtil.base64Encode(Blob.valueOf(headerJson)).replace('+', '-').replace('/', '_').replace('==','') 
						+ '.' +   EncodingUtil.base64Encode(Blob.valueOf(bodyJson)).replace('+', '-').replace('/', '_').replace('==','') ;
		String signature =  EncodingUtil.base64Encode(Crypto.signWithCertificate(
			'RSA-SHA256',
			Blob.valueOf(token),
			dataInterface.CC_Certificado__c
		)).replace('+', '-').replace('/', '_').replace('==','') ;
		token += '.' + signature;
	   	return token;
	}
	
	@invocableMethod(label='createOnlineMeeting')
	public static void createOnlineMeeting(List<List<String>> fields){
		// if(!fields.isEmpty() && fields[0].size() > 0){
		// 	String eventId = fields[0][0];
		// 	Event evProd = [SELECT Id, Subject, EndDateTime, StartDateTime, AV_Task__c FROM Event WHERE Id = :eventId];
		String eventId = fields[0][0];
		Event evProd = [SELECT Id, Subject, EndDateTime, StartDateTime, AV_Task__c FROM Event WHERE Id = :eventId];
        // Event evProd = (Event) new AV_Query('Event')
		// 					.selectFields('id, Subject, EndDateTime, StartDateTime, AV_Task__c')
		// 					.addConditionEq('Id',fields[0][0])
		// 					.fetch();
		Event ev = [Select Id, IsRecurrence2, IsRecurrence, WhatId, OwnerId, AV_ExternalId__c, AV_CodigoGestorAsignado__c, CreatedDate, Subject, RecordTypeId, Description, AV_Tipo__c, CSBD_Evento_Estado__c, AV_BranchPhysicalMeet__c, Location, StartDateTime, EndDateTime, isPrivate, AV_Task__c from Event where Id = :fields[0][0] limit 1];
		User emp  = [Select Id, AV_ExternalID__c, AV_AzureId__c,FederationIdentifier From User Where Id = :UserInfo.getUserId() limit 1];
		String jsonString = json.serialize(ev);
		System.enqueueJob(new AV_TeamsGCF_Queueable(jsonString, ev.Subject, ev.EndDateTime, ev.StartDateTime, ev.AV_Task__c,emp.FederationIdentifier , emp.AV_AzureId__c));
	}

	public static String getTokenString(String[] parts){
		String result = '';
		for (String part : parts) {
			if (!String.isEmpty(part) && part != null) result += part;
		}
		return result;
	}

	public static Integer kSPLIT = 255;
	public static void processBody(AV_AzureTeamsToken__c tk, String input) {
		if (tk == null || input == null) return;
		Integer inSize = input.length();
		if (0*kSPLIT <= inSize) tk.AV_Token1__c = input.substring(0*kSPLIT,inSize < 1*kSPLIT ? inSize : 1*kSPLIT);
		if (1*kSPLIT <= inSize) tk.AV_Token2__c = input.substring(1*kSPLIT,inSize < 2*kSPLIT ? inSize : 2*kSPLIT);
		if (2*kSPLIT <= inSize) tk.AV_Token3__c = input.substring(2*kSPLIT,inSize < 3*kSPLIT ? inSize : 3*kSPLIT);
		if (3*kSPLIT <= inSize) tk.AV_Token4__c = input.substring(3*kSPLIT,inSize < 4*kSPLIT ? inSize : 4*kSPLIT);
		if (4*kSPLIT <= inSize) tk.AV_Token5__c = input.substring(4*kSPLIT,inSize < 5*kSPLIT ? inSize : 5*kSPLIT);
		if (5*kSPLIT <= inSize) tk.AV_Token6__c = input.substring(5*kSPLIT,inSize < 6*kSPLIT ? inSize : 6*kSPLIT);
		if (6*kSPLIT <= inSize) tk.AV_Token7__c = input.substring(6*kSPLIT,inSize < 7*kSPLIT ? inSize : 7*kSPLIT);
		if (7*kSPLIT <= inSize) tk.AV_Token8__c = input.substring(7*kSPLIT,inSize < 8*kSPLIT ? inSize : 8*kSPLIT);
		if (8*kSPLIT <= inSize) tk.AV_Token9__c = input.substring(8*kSPLIT,inSize < 9*kSPLIT ? inSize : 9*kSPLIT);
	}
}