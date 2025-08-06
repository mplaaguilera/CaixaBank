global class CBK_Adoption_FWK_Batch implements Database.Batchable<sObject>, Database.Stateful{
    private Integer recordsProcessed = 0;
    private final static Map<String, String> mpickPrj = picklistValues('CBK_Adoption_FWK__c', 'CBK_Project__c');
    private Map<string,Map<String,List<string>>> mFwkByProj2;
	private String customlimit;

	global CBK_Adoption_FWK_Batch(){
		customlimit = null;
        mFwkByProj2 = new Map<string,Map<String,List<string>>>();
	}

	global CBK_Adoption_FWK_Batch(String limitQuery) {
        this.customlimit = limitQuery;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) { 
        cleanInfoFWK();
		mFwkByProj2 = new Map<string,Map<String,List<string>>>();
        String query = 'SELECT Name, Body, Status ' + 
                        'FROM ApexClass ' + 
                        'WHERE Status = \'Active\'';
		
		if (string.isNotBlank(customlimit) && Test.isRunningTest()){
			query +=  ' AND Name LIKE \'CBK%\' LIMIT ' + customlimit; 
		}
       
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<ApexClass> listApex){
        try{
            recordsProcessed = listApex.size(); 
			if(listApex.size() > 0){
				tratarInfoFWK(listApex);
			} 
        }catch(System.Exception e){
            CBK_Log.error(e);
        }
    }

    global void finish(Database.BatchableContext bc){
        getInfoFWKBatch(mFwkByProj2);
        createInfoAdoptionFWK(mFwkByProj2);
        CBK_Log.debug('Record Processed: ' + recordsProcessed);
		CBK_Log.debug('FWKs por aplicación: ' + mFwkByProj2);
    }

	private static void cleanInfoFWK(){
		List<CBK_Adoption_FWK__c> lstInfFWK = [SELECT Id FROM CBK_Adoption_FWK__c WHERE CreatedDate >= TODAY ];
		if (lstInfFWK.size() > 0){
			List<Database.DeleteResult> results = Database.delete(lstInfFWK,false);
		}
	}

    public void tratarInfoFWK(List<ApexClass> lstCass){
		Map<String, CBK_AdoptionMedatada__mdt> mMdt = getMetadataConfig();
		List<CBK_Adoption_FWK__c> lstInfFWK = new List<CBK_Adoption_FWK__c>();
		CBK_Adoption_FWK__c infoFWK;
		for (String key : mMdt.keySet()) {
			for (ApexClass apxClass : lstCass) {
				Set<string> sprj = getProjectsbyClass(mpickPrj.values(), apxClass.Name);
				String projectName = '';

				if (apxClass.Body.contains(key) && sprj.size() > 1) {
					for (string value : mpickPrj.keySet()) {
						if (apxClass.Name.contains(value) && value != 'CBK') {
							for (string ac : sprj) {
								if (ac != 'CBK' && sprj.size() > 1) {
									projectName = ac;
									infoFWK = new CBK_Adoption_FWK__c();
									infoFWK.CBK_ClassName__c = apxClass.Name;
									infoFWK.CBK_FWK_Name__c = mMdt.get(key).Label;
								//	infoFWK.Name = mMdt.get(key).Label;
									infoFWK.CBK_Project__c = projectName;
									lstInfFWK.add(infoFWK);
								}
							}
						}
					}
				} else if (apxClass.Body.contains(key) ) {
					projectName = getProjectName(mpickPrj.values(), apxClass.Name);
					infoFWK = new CBK_Adoption_FWK__c();
					infoFWK.CBK_ClassName__c = apxClass.Name;
					infoFWK.CBK_FWK_Name__c = mMdt.get(key).Label;
				//	infoFWK.Name = mMdt.get(key).Label;
					infoFWK.CBK_Project__c = projectName;
					lstInfFWK.add(infoFWK);
				}
			}
		}
		segmentationInfo(lstInfFWK);
	}

	public static void getInfoFWKBatch(Map<string,Map<String,List<string>>> mInfoFwk){
		List<AggregateResult> lstFwkBatchRes = [SELECT Class_Name__c  FROM CBK_Framework_Batch__c GROUP BY Class_Name__c];
		Set<String> sClassName = new Set<String>();
		for (AggregateResult aggRes : lstFwkBatchRes){
			String strClass = string.valueOf(aggRes.get('Class_Name__c'));
			sClassName.add(strClass);
		}
		Map<String,List<string>> mFWKClass;
		List<string> lstClass;

		for(string cls : sClassName){
			String prjName = getProjectName(mpickPrj.values(), cls);

			if (mInfoFwk.containsKey(prjName)){
				if(mInfoFwk.get(prjName).containsKey('FWK Batch Apex')){
					if(!mInfoFwk.get(prjName).get('FWK Batch Apex').contains(cls)){
						mInfoFwk.get(prjName).get('FWK Batch Apex').add(cls);
					}
				}else{
					lstClass = new List<string>();
					lstClass.add(cls);
					mInfoFwk.get(prjName).put('FWK Batch Apex',lstClass);
				}
			}else{
				lstClass =  new List<string>();
				lstClass.add(cls);
				mFWKClass =  new Map<String,List<string>>();
				mFWKClass.put('FWK Batch Apex', lstClass);
				mInfoFwk.put(prjName, mFWKClass);
			}
		}
	}

	public void createInfoAdoptionFWK(Map<string,Map<String,List<string>>> mInfoFWK){
		CBK_Log.debug('Mapa mInfoFWK: ' + JSON.serializePretty(mInfoFWK));
		List<CBK_Adoption_FWK__c> lstInfFWK = new List<CBK_Adoption_FWK__c>();
		CBK_Adoption_FWK__c infoFWK;
		Id rtInformation= Schema.getGlobalDescribe().get('CBK_Adoption_FWK__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Information').getRecordTypeId();
		for(string val : mpickPrj.keySet()){
			if(mInfoFWK.containsKey(val)){
				for(string fwkName : mInfoFWK.get(val).keySet()){
					if (mInfoFWK.get(val).containsKey(fwkName)){
						infoFWK =  new CBK_Adoption_FWK__c();
						infoFWK.RecordTypeId = rtInformation;
						//infoFWK.Name = fwkName;
						infoFWK.CBK_FWK_Name__c = fwkName;
						infoFWK.CBK_Project__c = val;
						lstInfFWK.add(infoFWK);
					}
				}
			}
		}
		CBK_Log.debug('Lista Insert: ' + JSON.serialize(lstInfFWK));
		Database.SaveResult[] lstResp = Database.insert(lstInfFWK, false);
		CBK_Log.debug('Lista Response Insert: ' + JSON.serialize(lstResp));

		set<String> ids = new Set<String>();
		for(Database.SaveResult res : lstResp){
			if (res.success){
				ids.add(res.id);
			}
		}

		list<CBK_Adoption_FWK__c> adopFWK = [SELECT Id,CBK_FWK_Name__c, CBK_RelatedClass__c, RecordTypeId, Name, CBK_ClassName__c, CBK_Project__c FROM  CBK_Adoption_FWK__c WHERE Id in :ids];
		lstInfFWK = new List<CBK_Adoption_FWK__c>();
		Id rtApexClass = Schema.getGlobalDescribe().get('CBK_Adoption_FWK__c').getDescribe().getRecordTypeInfosByDeveloperName().get('ApexClass').getRecordTypeId();
		if(adopFWK.size() > 0){
			for(CBK_Adoption_FWK__c adop : adopFWK){
				if (mInfoFWK.containsKey(adop.CBK_Project__c)){
					if(mInfoFWK.get(adop.CBK_Project__c).containskey(adop.CBK_FWK_Name__c)){//adop.Name
						for (string className : mInfoFWK.get(adop.CBK_Project__c).get(adop.CBK_FWK_Name__c)){//adop.Name
							infoFWK =  new CBK_Adoption_FWK__c();
							infoFWK.CBK_RelatedClass__c = adop.Id;
							infoFWK.RecordTypeId = rtApexClass;
							//infoFWK.Name = className;
							infoFWK.CBK_FWK_Name__c = adop.CBK_FWK_Name__c;
							infoFWK.CBK_ClassName__c = className;
							lstInfFWK.add(infoFWK);
						}
					}
				}
			}
		}
		CBK_Log.debug('Lista Insert Apex : ' + JSON.serialize(lstInfFWK));
		Database.SaveResult[] lstResp2 = Database.insert(lstInfFWK, false);
		CBK_Log.debug('Lista Response Apex : ' + JSON.serialize(lstResp2));
	}

	public static Set<String> getProjectsbyClass(List<string> lstValues, String apexName) {
		Set<String> lstAcert = new Set<String> ();
		for (string nn : lstValues) {
			if (apexname.contains(nn)) {
				lstAcert.add(nn);
			}
		}
		return lstAcert;
	}

	public static String getProjectName(List<string> lstValues, String apexName) {
		Set<String> lstAcert = new Set<String> ();
		string projectName = '';
		for (string nn : lstValues) {
			if (apexname.contains(nn)) {
				lstAcert.add(nn);
			}
		}
		for (string ac : lstAcert) {
			if (ac != 'CBK' && lstAcert.size() > 0) {
				projectName = ac;
			}else if(lstAcert.size() > 0){
				projectName = 'CBK';
			}
		}
		return projectName;
	}

	public void segmentationInfo(List<CBK_Adoption_FWK__c> lstInfFWK){
		Map<String,List<string>> mFWKClass;
		List<string> lstClass;
		for(CBK_Adoption_FWK__c obj : lstInfFWK){
			if(mFwkByProj2.containsKey(obj.CBK_Project__c)){
				if (this.mFwkByProj2.get(obj.CBK_Project__c).containsKey(obj.CBK_FWK_Name__c)){//obj.Name

					if (!mFwkByProj2.get(obj.CBK_Project__c).get(obj.CBK_FWK_Name__c).contains(obj.CBK_ClassName__c)){//obj.Name
						lstClass = new List<string>();
						lstClass.add(obj.CBK_ClassName__c);
						mFwkByProj2.get(obj.CBK_Project__c).get(obj.CBK_FWK_Name__c).addAll(lstClass);//obj.Name
					}
				}else{
					lstClass = new List<string>();
					lstClass.add(obj.CBK_ClassName__c);
					mFwkByProj2.get(obj.CBK_Project__c).put(obj.CBK_FWK_Name__c, lstClass);//obj.Name
				}
			}else{
				mFWKClass = new Map<String,List<string>>();
				lstClass = new List<string>();
				lstClass.add(obj.CBK_ClassName__c);
				mFWKClass.put(obj.CBK_FWK_Name__c,lstClass);//obj.Name
				mFwkByProj2.put(obj.CBK_Project__c, mFWKClass);
			}
		}	
		CBK_Log.debug('MAP Info Adoption: ' +  JSON.serializePretty(mFwkByProj2));
	}

	public static Map<String, CBK_AdoptionMedatada__mdt> getMetadataConfig(){
		Map<String, CBK_AdoptionMedatada__mdt> mdt = CBK_AdoptionMedatada__mdt.getAll();
		Map<String, CBK_AdoptionMedatada__mdt> mMdt = new Map<String, CBK_AdoptionMedatada__mdt> ();
		CBK_AdoptionMedatada__mdt conf;
		for (String adm : mdt.keySet()) {
			conf = mdt.get(adm);
			mMdt.put(conf.CBK_ClassName__c, conf);
		}
		return mMdt;
	}

	public static Map<String, String> picklistValues(String objectName, String fieldName) {
		Map<String, String> values = new Map<String, String> { };

		List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String> { objectName });

		for (Schema.DescribeSobjectResult res : results) {
			for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
				if (entry.isActive()) {
					values.put(entry.getValue(), entry.getLabel());
				}
			}
		}
		return values;
	}	
}