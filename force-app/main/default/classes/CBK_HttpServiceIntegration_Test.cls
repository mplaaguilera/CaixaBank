/**
 * @description       : 
 * @author            :  D. Elizama
 * @group             : 
 * @last modified on  : 26-05-2022
 * @last modified by  : fzaragoza
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   		      delizama   Initial Version
 * 1.1   25-05-2022   fzaragoza   Inclusión del registro en objeto CC_TrazaInt__c
**/
@isTest 
private class CBK_HttpServiceIntegration_Test extends CBK_HttpServiceIntegration_Abstract{

	@isTest
	private static void testCALLHttpServiceOk() {
		
		string vJsonreq = '{\"Hola": "Adios"}';
		string vJsonres = '{\"status": "OK"}';
		string vCBKIntSetting = 'MyIntegrationTest';

		Map<String,string> mHeaders =  new  Map<String,string>();
		mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

		mHeaders.put('Authorization', 'Bearer SESSIONID');

		CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'MyIntegrationTest';
		wsc.NamedCredential__c = 'callout:MyIntegrationTest';

		insert wsc;

		Test.setCreatedDate(wsc.Id, DateTime.newInstanceGmt(2022,12,12));
		List<CBK_IntegrationSetting__c> wsc2 = [SELECT  Id, CreatedDate, Name, 	NamedCredential__c, RegistroTrazaIntegracion__c, ResourcePath__c, CBK_IsInput__c, CBK_ContentType__c, CBK_Method__c, CBK_TimeOut__c  FROM CBK_IntegrationSetting__c WHERE Id =: wsc.Id];
		wsc2[0].NamedCredential__c = 'fgadfgsdfgsdfgsdfgsfdgsd';
		update wsc2;

		Test.startTest();			
		//SET Cache
		//Cache.Org.put('local.CBKCache.MyIntegrationTest', 'Bearer TESTFG6563fdgs', 3600, Cache.Visibility.ALL, true);
		//SET MOCK
		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {
			HttpResponse resp = new HttpResponse();
			resp.setBody(vJsonres);		
			resp.setStatusCode(200);
			resp.setStatus('Ok');
			CBK_HttpService_Mock_TEST vMock = new CBK_HttpService_Mock_TEST(resp);
			Test.setMock(HttpCalloutMock.class, vMock);

			HttpRequest req = CBK_HttpServiceIntegration.getRequest(JSON.serialize(vJsonreq), vCBKIntSetting, 'POST', mHeaders);
			HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req);
			HttpResponse res2 = CBK_HttpServiceIntegration.callHttpService(req, '123456789', wsc.Name);

			System.assertEquals(200, res2.getStatusCode());
			List <CC_TrazaInt__c> lstTrazas =  [SELECT id FROM CC_TrazaInt__c];
			System.assertEquals(0, lstTrazas.size(), 'No se han recuperado el número de entradas esperadas en el objeto de traza de integración');

		}
		Test.stopTest();
	}
	/*
	@isTest
	private static void testCALLHttpService_KO() {
		
		string vJsonreq = '{\"Hola": "Adios"}';
		string vJsonres = '{\"status": "OK"}';
		string vCBKIntSetting = 'MyIntegrationTest';

		Map<String,string> mHeaders =  new  Map<String,string>();
		mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		mHeaders.put('Authorization', 'Bearer SESSIONID');

		CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'MyIntegrationTest';
		wsc.NamedCredential__c = 'callout:MyIntegrationTest';
		insert wsc;

		Test.setCreatedDate(wsc.Id, DateTime.newInstanceGmt(2022,12,12));

		Test.startTest();		
	
		//SET Cache
		//Cache.Org.put('local.CBKCache.MyIntegrationTest', 'Bearer TESTFG6563fdgs', 3600, Cache.Visibility.ALL, true);
		//SET MOCK
		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {
			HttpResponse resp = new HttpResponse();
			resp.setBody(vJsonres);		
			resp.setStatusCode(400);
			resp.setStatus('KO');
			CBK_HttpService_Mock_TEST vMock = new CBK_HttpService_Mock_TEST(resp);
			Test.setMock(HttpCalloutMock.class, vMock);

			HttpRequest req = CBK_HttpServiceIntegration.getRequest(JSON.serialize(vJsonreq), vCBKIntSetting, 'POST', mHeaders);
			HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req);
			HttpResponse res2 = CBK_HttpServiceIntegration.callHttpService(req, '123456789', wsc.Name);

			System.assertEquals(400,res2.getStatusCode());
			Test.stopTest();
		}
	}*/

	@isTest
	private static void testGetRequestKO() {
		
		string vJsonreq = '{\"Hola": "Adios"}';
		string vJsonres = '{\"status": "OK"}';
		string vCBKIntSetting = 'MyIntegrationTest';

		CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'MyIntegrationTest';
		wsc.NamedCredential__c = 'callout:MyIntegrationTest';
		insert wsc;

		Test.setCreatedDate(wsc.Id, DateTime.newInstanceGmt(2022,12,12));
		List<CBK_IntegrationSetting__c> wsc2 = [SELECT  Id, CreatedDate, Name, 	NamedCredential__c, RegistroTrazaIntegracion__c, ResourcePath__c, CBK_IsInput__c, CBK_ContentType__c, CBK_Method__c, CBK_TimeOut__c  FROM CBK_IntegrationSetting__c WHERE Id =: wsc.Id];
		wsc2[0].NamedCredential__c = 'callout:MyIntegrationTest';
		update wsc2;

		Map<String,string> mHeaders =  new  Map<String,string>();
		mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		mHeaders.put('Authorization', 'Bearer SESSIONID');

		Test.startTest();		
		//SET Cache
		//Cache.Org.put('local.CBKCache.MyIntegrationTest', 'Bearer TESTFG6563fdgs', 3600, Cache.Visibility.ALL, true);
		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {
			HttpRequest req = CBK_HttpServiceIntegration.getRequest(JSON.serialize(vJsonreq), vCBKIntSetting, 'POST', mHeaders);
			System.assertEquals('callout:MyIntegrationTest',req?.getEndpoint());
		}
		Test.stopTest();
	}

	@isTest
	private static void testabstratct() {
		Test.startTest();
		CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'MyIntegrationTest';
		wsc.RegistroTrazaIntegracion__c = true;
		wsc.ResourcePath__c = 'callout:MyIntegrationTest';//'/services/apexrest/MyResource/*';
		insert wsc;

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {
			Datetime dtStart = Datetime.now();
			String jsonReq = '{"nom":"test"}';
			RestRequest req = new RestRequest();
			req.requestBody =  Blob.valueOf(jsonReq);
			req.requestURI = 'https:miurl.test';
			req.resourcePath = '/services/apexrest/callout:MyIntegrationTest';//'/services/apexrest/MyResource/*';
			RestContext.request = req;
			register(req);

			Datetime dtStop = Datetime.now();
			String jsonRes = '{"Result":"true"}';
			RestResponse res = new RestResponse();
			res.responseBody =  Blob.valueOf(jsonRes);
			res.statusCode = 200;
			RestContext.response = res;
			register(res);
			register(req,res,dtStart,dtStop, '',wsc.Name);
			register(req,res,dtStart,dtStop, '','');


			res.statusCode = 500;
			RestContext.response = res;
			register(req,res,dtStart,dtStop, '',wsc.Name);
		}
		Test.stopTest();
		List <CC_TrazaInt__c> lstTrazas =  [SELECT id FROM CC_TrazaInt__c];
		System.assertEquals(3, lstTrazas.size(), 'No se han recuperado el número de entradas esperadas en el objeto de traza de integración');


	}

	@isTest
	private static void testCALLHttpServiceregisterTraceOk() {


		
		string vJsonreq = '{\"Hola": "Adios"}';
		string vJsonres = '{\"status": "OK"}';
		string vCBKIntSetting = 'MyIntegrationTest';

		Map<String,string> mHeaders =  new  Map<String,string>();
		mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		mHeaders.put('Authorization', 'Bearer SESSIONID');

		CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'MyIntegrationTest';
		wsc.NamedCredential__c = 'callout:MyIntegrationTest';
		wsc.RegistroTrazaIntegracion__c = true;
		wsc.CBK_Traza_Envio_Header__c = true;
		wsc.CBK_Traza_Respuesta_Header__c = true;
		insert wsc;
		
		Test.setCreatedDate(wsc.Id, DateTime.newInstanceGmt(2022,12,12));
		List<CBK_IntegrationSetting__c> wsc2 = [SELECT  Id, CreatedDate, Name, 	NamedCredential__c, RegistroTrazaIntegracion__c, ResourcePath__c, CBK_IsInput__c, CBK_ContentType__c, CBK_Method__c, CBK_TimeOut__c  FROM CBK_IntegrationSetting__c WHERE Id =: wsc.Id];
		wsc2[0].NamedCredential__c = 'callout:MyIntegrationTest';
		update wsc2;

		Test.startTest();	

		//SET Cache
		//Cache.Org.put('local.CBKCache.MyIntegrationTest', 'Bearer TESTFG6563fdgs', 3600, Cache.Visibility.ALL, true);
		//SET MOCK
		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {
			HttpResponse resp = new HttpResponse();
			resp.setBody(vJsonres);		
			resp.setStatusCode(200);
			resp.setStatus('Ok');
			CBK_HttpService_Mock_TEST vMock = new CBK_HttpService_Mock_TEST(resp);
			Test.setMock(HttpCalloutMock.class, vMock);

			HttpRequest req = CBK_HttpServiceIntegration.getRequest(JSON.serialize(vJsonreq), vCBKIntSetting, 'POST', mHeaders);
			HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req, '', 'MyIntegrationTest');
			System.assertEquals(200, res.getStatusCode());
			List <CC_TrazaInt__c> lstTrazas =  [SELECT id FROM CC_TrazaInt__c];
			System.assertEquals(1, lstTrazas.size(), 'No se han recuperado el número de entradas esperadas en el objeto de traza de integración');
		}
		Test.stopTest();
	}

	@isTest
	private static void testCALLHttpServiceregisterTraceKO() {
		
		string vJsonreq = '{\"Hola": "Adios"}';
		string vJsonres = '{\"status": "OK"}';
		string vCBKIntSetting = 'MyIntegrationTest';

		Map<String,string> mHeaders =  new  Map<String,string>();
		mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		mHeaders.put('Authorization', 'Bearer SESSIONID');

		CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'MyIntegrationTest';
		wsc.NamedCredential__c = 'callout:MyIntegrationTest';
		wsc.RegistroTrazaIntegracion__c = true;
		insert wsc;

		
		Test.setCreatedDate(wsc.Id, DateTime.newInstanceGmt(2022,12,12));
		List<CBK_IntegrationSetting__c> wsc2 = [SELECT  Id, CreatedDate, Name, 	NamedCredential__c, RegistroTrazaIntegracion__c, ResourcePath__c, CBK_IsInput__c, CBK_ContentType__c, CBK_Method__c, CBK_TimeOut__c  FROM CBK_IntegrationSetting__c WHERE Id =: wsc.Id];
		wsc2[0].NamedCredential__c = 'callout:MyIntegrationTest';
		update wsc2;


		Test.startTest();		
	
		//SET Cache
		//Cache.Org.put('local.CBKCache.MyIntegrationTest', 'Bearer TESTFG6563fdgs', 3600, Cache.Visibility.ALL, true);
		//SET MOCK
		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {
			HttpResponse resp = new HttpResponse();
			resp.setBody(vJsonres);		
			resp.setStatusCode(400);
			resp.setStatus('KO');
			CBK_HttpService_Mock_TEST vMock = new CBK_HttpService_Mock_TEST(resp);
			Test.setMock(HttpCalloutMock.class, vMock);

			HttpRequest req = CBK_HttpServiceIntegration.getRequest(JSON.serialize(vJsonreq), vCBKIntSetting, 'POST', mHeaders);
			HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req, '', 'MyIntegrationTest');

			System.assertEquals(400,res.getStatusCode());
			
			List <CC_TrazaInt__c> lstTrazas =  [SELECT id,CC_DetalleError__c FROM CC_TrazaInt__c];
			System.assertEquals(1, lstTrazas.size(), 'No se han recuperado el número de entradas esperadas en el objeto de traza de integración');
			System.assertNotEquals(null, lstTrazas[0].CC_DetalleError__c, 'No se ha registrado el mensaje de error en caso de fallo del servicio');
		}
		Test.stopTest();
	}

	@isTest
	private static void testmulticall() {
		CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'MyIntegrationTest';
		wsc.NamedCredential__c = 'callout:MyIntegrationTest/{PARAMS_1}/{PARAMS_2}/{PARAMS_3}/{PARAMS_4}';
		wsc.CBK_Method__c = 'POST';
		wsc.CBK_TimeOut__c = 120000;
		wsc.CBK_ContentType__c = 'application/json';
		wsc.RegistroTrazaIntegracion__c = true;
		wsc.CBK_Traza_Envio_Header__c = true;
		wsc.CBK_Traza_Respuesta_Header__c = true;
		insert wsc;

		
		Test.setCreatedDate(wsc.Id, DateTime.newInstanceGmt(2022,12,12));
		List<CBK_IntegrationSetting__c> wsc2 = [SELECT  Id, CreatedDate, Name, 	NamedCredential__c, RegistroTrazaIntegracion__c, ResourcePath__c, CBK_IsInput__c, CBK_ContentType__c, CBK_Method__c, CBK_TimeOut__c  FROM CBK_IntegrationSetting__c WHERE Id =: wsc.Id];
		wsc2[0].NamedCredential__c = 'callout:MyIntegrationTest';
		update wsc2;


		Test.startTest();					
		//SET MOCK
		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {
			string vJsonres = '{\"status": "OK"}';
			HttpResponse resp = new HttpResponse();
			resp.setBody(vJsonres);		
			resp.setStatusCode(200);
			resp.setStatus('Ok');
			CBK_HttpService_Mock_TEST vMock = new CBK_HttpService_Mock_TEST(resp);
			Test.setMock(HttpCalloutMock.class, vMock);

			string body = '{"test": "3"}';
			Map<String,String> mHeaders2 = new Map<String,String>();
			Map<String,String> muripar = new Map<String,String>();
			muripar.put('PARAMS_1', 'salesforce');
			muripar.put('PARAMS_2', 'test');
			muripar.put('PARAMS_3', 'params');
			muripar.put('PARAMS_4', 'url');
			Map<String,String> mqparam = new Map<String,String>();
			HttpRequest req =  CBK_HttpServiceIntegration.getRequest(body, 'MyIntegrationTest', mHeaders2,muripar, mqparam);
			System.debug('req2: ' + req );
			HttpResponse respon = CBK_HttpServiceIntegration.multiCallHttpService(req, '', 'MyIntegrationTest');
			System.assertEquals(200,respon.getStatusCode());
			CBK_HttpServiceIntegration.registroTrazaIntegracion();
		}
		Test.stopTest();
	}

	@isTest
	private static void testmulticallKO() {
		CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'MyIntegrationTest';
		wsc.NamedCredential__c = 'callout:MyIntegrationTest/{PARAMS_1}/{PARAMS_2}/{PARAMS_3}/{PARAMS_4}';
		wsc.CBK_Method__c = 'POST';
		wsc.CBK_TimeOut__c = 120000;
		wsc.CBK_ContentType__c = 'application/json';
		wsc.RegistroTrazaIntegracion__c = true;
		insert wsc;

		Test.setCreatedDate(wsc.Id, DateTime.newInstanceGmt(2022,12,12));
		List<CBK_IntegrationSetting__c> wsc2 = [SELECT  Id, CreatedDate, Name, 	NamedCredential__c, RegistroTrazaIntegracion__c, ResourcePath__c, CBK_IsInput__c, CBK_ContentType__c, CBK_Method__c, CBK_TimeOut__c  FROM CBK_IntegrationSetting__c WHERE Id =: wsc.Id];
		wsc2[0].NamedCredential__c = 'callout:MyIntegrationTest';
		update wsc2;

		Test.startTest();					
		//SET MOCK
		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {
			string vJsonres = '{\"status": "KO"}';
			HttpResponse resp = new HttpResponse();
			resp.setBody(vJsonres);		
			resp.setStatusCode(500);
			resp.setStatus('KO');
			CBK_HttpService_Mock_TEST vMock = new CBK_HttpService_Mock_TEST(resp);
			Test.setMock(HttpCalloutMock.class, vMock);

			string body = '{"test": "3"}';
			Map<String,String> mHeaders2 = new Map<String,String>();
			Map<String,String> muripar = new Map<String,String>();
			muripar.put('PARAMS_1', 'salesforce');
			muripar.put('PARAMS_2', 'test');
			muripar.put('PARAMS_3', 'params');
			muripar.put('PARAMS_4', 'url');
			Map<String,String> mqparam = new Map<String,String>();
			HttpRequest req =  CBK_HttpServiceIntegration.getRequest(body, 'MyIntegrationTest', mHeaders2,muripar, mqparam);
			System.debug('req2: ' + req );
			HttpResponse respon = CBK_HttpServiceIntegration.multiCallHttpService(req, '', 'MyIntegrationTest');
			System.assertEquals(500,respon.getStatusCode());
			CBK_HttpServiceIntegration.registroTrazaIntegracion();
		}
		Test.stopTest();
	}

	@isTest
	private static void testGetRequestWrapper(){
		string vJsonreq = '{\"Hola": "Adios"}';
		string vJsonres = '{\"status": "OK"}';
		string vCBKIntSetting = 'MyIntegrationTest';

		Map<String,string> mHeaders =  new  Map<String,string>();
		mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		mHeaders.put('Authorization', 'Bearer SESSIONID');

		CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'MyIntegrationTest';
		wsc.NamedCredential__c = 'callout:MyIntegrationTest/{PARAMS_1}/{PARAMS_2}/{PARAMS_3}/{PARAMS_4}';
		wsc.CBK_Method__c = 'POST';
		wsc.CBK_TimeOut__c = 120000;
		wsc.CBK_ContentType__c = 'application/json';
		wsc.RegistroTrazaIntegracion__c = true;
		insert wsc;
		
		Test.setCreatedDate(wsc.Id, DateTime.newInstanceGmt(2022,12,12));
		List<CBK_IntegrationSetting__c> wsc2 = [SELECT  Id, CreatedDate, Name, 	NamedCredential__c, RegistroTrazaIntegracion__c, ResourcePath__c, CBK_IsInput__c, CBK_ContentType__c, CBK_Method__c, CBK_TimeOut__c  FROM CBK_IntegrationSetting__c WHERE Id =: wsc.Id];
		wsc2[0].NamedCredential__c = 'callout:MyIntegrationTest';
		update wsc2;


		Map<String,String> muripar = new Map<String,String>();
		muripar.put('PARAMS_1', 'salesforce');
		muripar.put('PARAMS_2', 'test');
		muripar.put('PARAMS_3', 'params');
		muripar.put('PARAMS_4', 'url');

		Map<String,String> mqparam = new Map<String,String>();
		mqparam.put('name', 'value');
		mqparam.put('name1', 'value1');
		mqparam.put('name2', 'value2');

		CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
		reqWrapper.body = vJsonreq;
		reqWrapper.intSetting = 'MyIntegrationTest';
		reqWrapper.method = 'POST';
		reqWrapper.mHeaders = mHeaders;
		reqWrapper.mUriParams = muripar;
		reqWrapper.mQueryParams = mqparam;
		
		Test.startTest();		
		//SET MOCK
		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {
			
			HttpResponse resp = new HttpResponse();
			resp.setBody(vJsonres);		
			resp.setStatusCode(200);
			resp.setStatus('OK');

			CBK_HttpService_Mock_TEST vMock = new CBK_HttpService_Mock_TEST(resp);
			Test.setMock(HttpCalloutMock.class, vMock);

			HttpRequest req = CBK_HttpServiceIntegration.getRequest(reqWrapper);
			HttpResponse res2 = CBK_HttpServiceIntegration.callHttpService(req, '', 'MyIntegrationTest');

			System.assertEquals(200,res2.getStatusCode());
		}
		Test.stopTest();
	}

	@isTest
	private static void testGetRequestWrapperWithBodyBlob(){
		string vJsonreq = '{\"Hola": "Adios"}';
		string vJsonres = '{\"status": "OK"}';
		string vCBKIntSetting = 'MyIntegrationTest';

		CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'MyIntegrationTest';
		wsc.NamedCredential__c = 'callout:MyIntegrationTest/{PARAMS_1}/{PARAMS_2}/{PARAMS_3}/{PARAMS_4}';
		wsc.CBK_Method__c = 'POST';
		wsc.CBK_TimeOut__c = 120000;
		wsc.CBK_ContentType__c = 'application/json';
		wsc.RegistroTrazaIntegracion__c = true;
		insert wsc;
		
		Test.setCreatedDate(wsc.Id, DateTime.newInstanceGmt(2022,12,12));
		List<CBK_IntegrationSetting__c> wsc2 = [SELECT  Id, CreatedDate, Name, 	NamedCredential__c, RegistroTrazaIntegracion__c, ResourcePath__c, CBK_IsInput__c, CBK_ContentType__c, CBK_Method__c, CBK_TimeOut__c  FROM CBK_IntegrationSetting__c WHERE Id =: wsc.Id];
		wsc2[0].NamedCredential__c = 'callout:MyIntegrationTest';
		update wsc2;

		CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
		reqWrapper.bodyBlob = Blob.valueof(vJsonreq);
		reqWrapper.intSetting = 'MyIntegrationTest';
		reqWrapper.method = 'POST';
		reqWrapper.mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
		reqWrapper.mHeaders.put('Authorization', 'Bearer SESSIONID');
		reqWrapper.mUriParams.put('PARAMS_1', 'salesforce');
		reqWrapper.mUriParams.put('PARAMS_2', 'test');
		reqWrapper.mUriParams.put('PARAMS_3', 'params');
		reqWrapper.mUriParams.put('PARAMS_4', 'url');
		reqWrapper.mQueryParams.put('name', 'value');
		reqWrapper.mQueryParams.put('name1', 'value1');
		reqWrapper.mQueryParams.put('name2', 'value2');

		Test.startTest();		

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {
			
			HttpResponse resp = new HttpResponse();
			resp.setBody(vJsonres);		
			resp.setStatusCode(200);
			resp.setStatus('OK');

			CBK_HttpService_Mock_TEST vMock = new CBK_HttpService_Mock_TEST(resp);
			Test.setMock(HttpCalloutMock.class, vMock);

			HttpRequest req = CBK_HttpServiceIntegration.getRequest(reqWrapper);
			HttpResponse res2 = CBK_HttpServiceIntegration.callHttpService(req, '', 'MyIntegrationTest');

			System.assertEquals(200,res2.getStatusCode());
		}
		Test.stopTest();
	}
}