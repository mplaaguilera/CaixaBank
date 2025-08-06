public with sharing class CBK_Control_IPS_Profile_Queueable implements Queueable, Database.AllowsCallouts{

    private List<string> profileList;
	String userStoryId;
	String enviromentName;
    public CBK_Control_IPS_Profile_Queueable(List<string> lprof, String usId, String envir) {
        this.profileList = lprof;
		this.userStoryId = usId;
		this.enviromentName = envir;
    }

    public void execute(QueueableContext context) {
		outPutId sessionId =  new outPutId();
		try{
			if(!Test.isRunningTest()){
				sessionId = getSessionId(enviromentName);
			}
			Map<string, List<String>> mDataManager = getIPsByProfileFromDM(profileList);
			Map<string, List<String>> mDataAPI	= CBK_Control_IPS_Profile.getProfileMetadata(profileList, false, sessionId.sessionId, enviromentName);

			CBK_Log.debug('profileList: ' + profileList, logginglevel.DEBUG);
			CBK_Log.debug('enviromentName: ' + enviromentName, logginglevel.DEBUG);
			CBK_Log.debug('mDataManager: ' + json.serialize(mDataManager), logginglevel.DEBUG);
			CBK_Log.debug('mDataAPI Entorno OT: ' + json.serialize(mDataAPI), logginglevel.DEBUG);

			List<string> lstIp;
			List<string> lstIpNew;
			Map<String, List<String>> mapainfo = new Map<String, List<String>>();
			Map<String, List<String>> mapainfo_New = new Map<String, List<String>>();
			for(string profile : mDataManager.keySet()){
				if (mDataManager.containsKey(profile)){
					for(string ips : mDataManager.get(profile)){
						if(mDataAPI.containsKey(profile) && !mDataAPI.get(profile).contains(ips)){
							if(mapainfo.containsKey(profile)){
								lstIp = new List<String>();
								lstIp.add(ips);
								mapainfo.get(profile).addAll(lstIp);
							}else{
								lstIp = new List<String>();
								lstIp.add(ips);
								mapainfo.put(profile, lstIp);
							}
						}
					}
				}
			}

			for(string profile : mDataAPI.keySet()){
				if (mDataAPI.containsKey(profile)){
					for(string ips : mDataAPI.get(profile)){
						if(mDataManager.containsKey(profile) && !mDataManager.get(profile).contains(ips)){
							if(mapainfo_New.containsKey(profile)){
								lstIpNew = new List<String>();
								lstIpNew.add(ips);
								mapainfo_New.get(profile).addAll(lstIpNew);
							}else{
								lstIpNew = new List<String>();
								lstIpNew.add(ips);
								mapainfo_New.put(profile, lstIpNew);
							}
						}
					}
				}
			}
			
			CBK_Log.debug('Lista de IPs que desaparecen en PRO: ' + json.serializePretty(mapainfo), logginglevel.DEBUG);
			CBK_Log.debug('Lista de IPs nuevas: ' + json.serializePretty(mapainfo_New), logginglevel.DEBUG);

			List<copado__User_Story__c>  copadoUSs = [SELECT Id, CBK_HasConflictIp__c, CBK_IP_Conflict__c FROM copado__User_Story__c WHERE  Id = :userStoryId];
			string bodyError = '';
			for (string prf : mapainfo.keySet()){
				bodyError += prf + ': Lista de IPs que desaparecen en PRO - [' + String.join(mapainfo.get(prf), ',') + ']\n';
			}
			for (string prf : mapainfo_New.keySet()){
				bodyError += prf + ': Lista de IPs nuevas - [' + String.join(mapainfo_New.get(prf), ',') + ']\n';
			}

			if(copadoUSs != null && copadoUSs.size() > 0 && string.isNotBlank(bodyError)){
				for (copado__User_Story__c us : copadoUSs) {
						if (string.isBlank(us.CBK_IP_Conflict__c)) {us.CBK_IP_Conflict__c = '';}
						us.CBK_IP_Conflict__c += '\n' + bodyError;
						us.CBK_HasConflictIp__c = true;
						us.copado__Promote_Change__c = false;
						us.copado__Promote_and_Deploy__c = false;
				}
				update copadoUSs;
			}
		}catch(Exception e){
			CBK_log.error(e, 'Error: CBK_Control_IPS_Profile_Queueable');
		}
    }

    private Map<string, List<String>> getIPsByProfileFromDM(List<String> profiles){
		Id  idProfile = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Ip').getRecordTypeId();
		List<CBK_DataManager__c> lstDM =  [SELECT Id,Ip_Number__c, RecordTypeId, Name, RelatedIp__r.ProfileName__c 
											FROM CBK_DataManager__c WHERE RecordTypeId = :idProfile AND RelatedIp__r.Check_By_OT__c  = true AND RelatedIp__r.ProfileName__c IN :profiles];
		Map<string, List<String>> mapProfilesIpsDM = new Map<string, List<String>>();
		List<String> lstIps;
		if (lstDM != null && lstDM.size() > 0){
			for(CBK_DataManager__c dm :lstDM){
				if (mapProfilesIpsDM.containsKey(dm.RelatedIp__r.ProfileName__c)){
					lstIps = new List<String>();
					lstIps.add(dm.Ip_Number__c);
					mapProfilesIpsDM.get(dm.RelatedIp__r.ProfileName__c).addAll(lstIps);
				}else{
					lstIps = new List<String>();
					lstIps.add(dm.Ip_Number__c);
					mapProfilesIpsDM.put(dm.RelatedIp__r.ProfileName__c, lstIps);
				}
			}
		}
		return mapProfilesIpsDM;
	}

	public static outPutId getSessionId(String enviromentName){
		Map<String, String> mHeaders =  new Map<String, String>();
        mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
        HttpRequest req;
        string url;
		Map<String, CBK_Control_IPS_Env__c> enviroments =  CBK_Control_IPS_Profile.getCustomSetting();
		CBK_Log.debug('enviromentName: ' + enviromentName + ' - Lista de Enviroments CustomSetting: ' + enviroments, logginglevel.DEBUG);
		
		String setting = enviroments?.get(enviromentName)?.CBK_IntegrationSetting__c;
		req = CBK_HttpServiceIntegration.getRequest('', setting, 'GET', mHeaders);
		url = req.getEndpoint();
        req.setEndpoint(url + '/getSession');
        HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req, url, setting);
		CBK_Log.debug('Response: ' + res, logginglevel.DEBUG);
		outPutId outputSession = (outPutId) JSON.deserialize(res.getBody(), outPutId.class);
		CBK_Log.debug('Response GetSession: '+ res + ' - body: ' + json.serialize(outputSession), logginglevel.DEBUG);
		return outputSession;
	}

	public class outPutId {
		public string sessionId { get; set; }
	}
}