@isTest
public class CBK_Control_IPS_Profile_Queueable_Test {
    @isTest
	public static void compareProfilesMetadadaAPI() {
        copado__Environment__c env = new copado__Environment__c();
        env.CBK_Validacion_OT__c = true;
        env.Name = 'STAGINGINTtttt';
        insert env;
    
        copado__User_Story__c us = New copado__User_Story__c();
        us.copado__Environment__c = env.Id;
        us.copado__User_Story_Title__c = 'Profile US';
        insert us;
    
        copado__User_Story_Metadata__c mtd = New copado__User_Story_Metadata__c();
        mtd.copado__Metadata_API_Name__c = 'Profile.API Only';
        mtd.copado__User_Story__c = us.Id;
        insert mtd;

        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'CBK_Control_IPs';
		wsc.NamedCredential__c = 'callout:CBK_Control_IPs/services/oauth2/token';
		insert wsc;

        CBK_IntegrationSetting__c wsc2 = new CBK_IntegrationSetting__c();
		wsc2.Name = 'CBK_ControlIPs_MetadataApi';
		wsc2.NamedCredential__c = 'callout:CBK_ControlIPs_MetadataAPI/services/Soap/m/42.0';
		insert wsc2;

        CBK_IntegrationToken_Setting__c wscToken = new CBK_IntegrationToken_Setting__c();
        wscToken.ClientId__c = '3413414134123';
        wscToken.ClientSecret__c = '1234132455654';
        wscToken.Password__c = 'password';
        wscToken.UserName__c = 'AdminTest@caixabankccTest.com';
        wscToken.Name = 'CBK_Control_IPs';
        insert wscToken;

        Id  rt1 = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Profile').getRecordTypeId();
        CBK_DataManager__c objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt1;
        objDM.ProfileName__c = 'API Only';
        objDM.Name = 'API Only';
        objDM.Check_By_OT__c  = true;
        insert objDM;

        Id rt2 = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Ip').getRecordTypeId();
        CBK_DataManager__c objDMIp = new CBK_DataManager__c();
        objDMIp.RecordTypeId = rt2;
        objDMIp.Ip_Number__c = '1.1.1.1';
        objDMIp.Name = '1.1.1.1';
        objDMIp.RelatedIp__c = objDM.Id;
        insert objDMIp;

        objDMIp = new CBK_DataManager__c();
        objDMIp.RecordTypeId = rt2;
        objDMIp.Ip_Number__c = '2.2.2.2';
        objDMIp.Name = '2.2.2.2';
        objDMIp.RelatedIp__c = objDM.Id;
        insert objDMIp;

        objDMIp = new CBK_DataManager__c();
        objDMIp.RecordTypeId = rt2;
        objDMIp.Ip_Number__c = '6.6.6.6';
        objDMIp.Name = '6.6.6.6';
        objDMIp.RelatedIp__c = objDM.Id;
        insert objDMIp;

        objDMIp = new CBK_DataManager__c();
        objDMIp.RecordTypeId = rt2;
        objDMIp.Ip_Number__c = '5.5.5.5.5';
        objDMIp.Name = '5.5.5.5.5';
        objDMIp.RelatedIp__c = objDM.Id;
        insert objDMIp;


        List<string> profiles = new List<string>();
        profiles.add('API Only');

        test.startTest();
        CBK_WebServiceMockImpl_Test mock = new CBK_WebServiceMockImpl_Test();
        test.setMock(WebServiceMock.class, mock);
        System.assertEquals(profiles.size(), 1);

        CBK_Control_IPS_Profile_Queueable processIPs = new CBK_Control_IPS_Profile_Queueable(profiles, us.Id, 'OT');
        System.enqueueJob(processIPs);
        test.stopTest();
    }

    @isTest
	private static void getToken() {	
		CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'CBK_Control_IPs';
		wsc.NamedCredential__c = 'callout:CBK_Control_IPs/services/oauth2/token';
		insert wsc;

        CBK_Control_IPS_Env__c config = new CBK_Control_IPS_Env__c();
        config.Name = 'Integración OT';
        config.CBK_EnviromentName_Copado__c = 'Integración OT';
        config.CBK_EnviromentUrl__c = 'https://caixabankcc--ot.sandbox.my.salesforce.com';
        config.CBK_IntegrationSetting__c = 'CBK_Control_IPs';
        insert config;

		Test.startTest();
        outPutId respSession =  new outPutId();
        respSession.sessionId = 'dfadsfvasdgffgsdfgs42352345gfsfgsfgfdsgfgsf.sfdgsdfg';
        String jsonToken = JSON.serialize(respSession);

        HttpResponse resp = new HttpResponse();
		resp.setBody(jsonToken);		
		resp.setStatusCode(200);
		resp.setStatus('Ok');
		CBK_HttpService_Mock_TEST vMock = new CBK_HttpService_Mock_TEST(resp);
		Test.setMock(HttpCalloutMock.class, vMock);

		CBK_Control_IPS_Profile_Queueable.outPutId getSession = CBK_Control_IPS_Profile_Queueable.getSessionId('Integración OT');
        System.assertEquals('dfadsfvasdgffgsdfgs42352345gfsfgsfgfdsgfgsf.sfdgsdfg',getSession.sessionId);
		Test.stopTest();
	}

    @isTest
	private static void createProfilesDataManager(){
        Test.startTest();
        CBK_Control_IPS_Profile.createProfilesDataManager();
        Id  idProfile = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Profile').getRecordTypeId();
        List<CBK_DataManager__c> lstDM = [SELECT Id,ProfileName__c,Name  FROM CBK_DataManager__c WHERE RecordTypeId = :idProfile];
        boolean check = false;
        if (lstDM.size() > 0){
            check = true;
        }
        System.assertEquals(true, check);
        Test.stopTest();
    }

    @isTest
	private static void createIPSDataManager(){
        Id  rt1 = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Profile').getRecordTypeId();
        CBK_DataManager__c objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt1;
        objDM.ProfileName__c = 'API Only';
        objDM.Name = 'API Only';
        objDM.Check_By_OT__c  = true;
        insert objDM;

        List<String> lstIps = new List<String>();
        lstIps.add('1.1.1.1');
        lstIps.add('2.2.2.2');
        Map<string, List<String>> mProfilesIps = new Map<string, List<String>>();
        mProfilesIps.put('API Only', lstIps);

        Test.startTest();
        CBK_Control_IPS_Profile.createIPSDataManager(mProfilesIps);
        Id  idRTProfile = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Profile').getRecordTypeId();
        Id  idRTIp = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Ip').getRecordTypeId();
        List<CBK_DataManager__c> lstProfile = [SELECT Id,ProfileName__c,Name  FROM CBK_DataManager__c WHERE RecordTypeId = :idRTProfile and ProfileName__c = 'API Only' limit 1];
        System.assertEquals('API Only', lstProfile[0].ProfileName__c);

        List<CBK_DataManager__c> lstDMIp = [SELECT Id,ProfileName__c,Name  FROM CBK_DataManager__c WHERE RecordTypeId = :idRTIp and RelatedIp__r.ProfileName__c = 'API Only'];
        System.assertEquals(2,lstDMIp.size() );
        Test.stopTest();
    }

    public class outPutId {
		public string sessionId { get; set; }
	}
}