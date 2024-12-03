public with sharing class CBK_Control_IPS_Profile {
    public static Map<string, List<String>> getProfileMetadata(List<string> inputProfiles, Boolean inputdataManager, string sessionId, string enviromentName){
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();

        Map<String, CBK_Control_IPS_Env__c> enviroments =  getCustomSetting();
        string vUrl = enviroments?.get(enviromentName)?.CBK_EnviromentUrl__c;
        CBK_Log.debug('URL Consulta Integración: ' + vUrl, logginglevel.DEBUG);
        if (!inputdataManager){
            service.endpoint_x = vUrl + '/services/Soap/m/42.0';
        }
        service.SessionHeader.sessionId = !inputdataManager ? sessionId : UserInfo.getSessionId();
        service.CallOptions = new MetadataService.CallOptions_element();
		service.timeout_x = 120000;

        List<MetadataService.Profile> profiles = (List<MetadataService.Profile>) service.readMetadata('Profile', inputProfiles).getRecords(); //read Profile to get existing IP ranges
        CBK_Log.debug('profiles: Nº ' + profiles.size(), logginglevel.DEBUG);

        Map<string, List<String>> mapProfilesIps = new Map<String, List<String>>();
        List<String> lstIps; 
        for(MetadataService.Profile prof : profiles){
            if(prof.loginIpRanges != null){
                for (MetadataService.ProfileLoginIpRange ips: prof.loginIpRanges){
                    if (prof.loginIpRanges != null) {          
                        if (mapProfilesIps.containsKey(prof.fullName)){
                            lstIps = new List<String>();
                            if (!lstIps.contains(ips.startAddress)){
                                lstIps.add(ips.startAddress);
                            }
                            if (!lstIps.contains(ips.endAddress)){
                                lstIps.add(ips.endAddress);
                            }
                            mapProfilesIps.get(prof.fullName).addAll(lstIps);
                        }else{
                            lstIps = new List<String>();
                            if (!lstIps.contains(ips.startAddress)){
                                lstIps.add(ips.startAddress);
                            }                            
                            if (!lstIps.contains(ips.endAddress)){
                                lstIps.add(ips.endAddress);
                            }
                            mapProfilesIps.put(prof.fullName, lstIps);
                        }
                    }
                }
            }
        }
        if(inputdataManager){
            createIPSDataManager(mapProfilesIps);
        }
        CBK_Log.debug('Perfiles con Ips: ' + JSON.serialize(mapProfilesIps), logginglevel.DEBUG);
        return mapProfilesIps;
	}

    public static void createIPSDataManager(Map<string, List<String>> mProfilesIps){
        Set<string> lstObject = new Set<String>();
        Map<string,CBK_DataManager__c> mObjects =  new Map<string,CBK_DataManager__c>();

        for(string key : mProfilesIps.keySet()){
            lstObject.add(key);
        }

        Id idRTProfile = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Profile').getRecordTypeId();
        List<CBK_DataManager__c> updDataManager = [SELECT Id, Name, ProfileName__c FROM CBK_DataManager__c WHERE RecordTypeId = :idRTProfile AND ProfileName__c IN :lstObject];
        if(updDataManager != null && updDataManager.size() > 0){
            for(CBK_DataManager__c dm : updDataManager ){
                mObjects.put(dm.ProfileName__c, dm);
            }
        }

        CBK_DataManager__c newObj;
        List<CBK_DataManager__c> lstNewObj = new List<CBK_DataManager__c>();
        Id  idIp = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Ip').getRecordTypeId();

        for(string key : mProfilesIps.keySet()){
            for(string ip : mProfilesIps.get(key)){
                newObj = new CBK_DataManager__c();
                newObj.RecordTypeId = idIp;
                newObj.Ip_Number__c = ip;
                newObj.Status__c = 'Approved';
                newObj.Name = ip;
                newObj.RelatedIp__c = mObjects.get(key).Id;
                lstNewObj.add(newObj);
            }
        }
        Database.SaveResult[] lstResp = Database.insert(lstNewObj, false);
        CBK_Log.debug('lst Response insert Ips: ' + JSON.serialize(lstResp), logginglevel.DEBUG);
    }

    public static void createProfilesDataManager(){
        Id  idProfile = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Profile').getRecordTypeId();
        List<Profile> lstAllprofiles = [SELECT Id,Name FROM Profile];
        integer i = 0;
        List<CBK_DataManager__c> lstDataManager = new List<CBK_DataManager__c>();
        CBK_DataManager__c vDataManager;
        if(lstAllprofiles != null && lstAllprofiles.size() > 0){
            for(Profile prf : lstAllprofiles){
                vDataManager =  new CBK_DataManager__c();
                vDataManager.RecordTypeId = idProfile;
                vDataManager.ProfileName__c = prf.Name;
                vDataManager.Name = prf.Name;
                lstDataManager.add(vDataManager);
            }   
            Database.SaveResult[] lstResp = Database.insert(lstDataManager, false);
            CBK_Log.debug('lst Response insert profiles: ' + JSON.serialize(lstResp), logginglevel.DEBUG);
        } 
    }
    
    public static Map<String, CBK_Control_IPS_Env__c> getCustomSetting(){
        Map<String, CBK_Control_IPS_Env__c> mEnvirUrl = new Map<String, CBK_Control_IPS_Env__c>();
        List<CBK_Control_IPS_Env__c> wsc = CBK_Control_IPS_Env__c.getAll().values();
        for(CBK_Control_IPS_Env__c cs  : wsc){
            mEnvirUrl.put(cs.CBK_EnviromentName_Copado__c, cs);
        }
        return mEnvirUrl;
    }
}