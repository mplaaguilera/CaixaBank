public with sharing class CBK_copado_User_Story_BU_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<copado__User_Story__c>) tp.newList, (Map<Id, copado__User_Story__c>) tp.newMap);
	}

	private void process(List<copado__User_Story__c> listNewObj, Map<Id, copado__User_Story__c> mapNewObj) {
		Set<Id> userStory = new Set<Id> ();
		Map<String, copado__User_Story__c> mUserStories = new Map<String, copado__User_Story__c>();  
		for (copado__User_Story__c obj : listNewObj) {
			userStory.add((Id) obj.Id);
			mUserStories.put(obj.Id, obj);
		}
		Set<String> objetosUs = new Set<String> ();
		Set<String> objApex = new Set<String> ();
		Set<String> objFlow = new Set<String> ();
		Set<String> objectField = new Set<String> ();
		Set<String> objectRT = new Set<String> ();
		Set<String> objectProfile = new Set<String> ();

		list<string> n = new list<string> ();
		list<copado__User_Story_Metadata__c> metaDatos = [select Id, copado__User_Story__c, copado__Metadata_API_Name__c, copado__User_Story__r.copado__Environment__c from copado__User_Story_Metadata__c where copado__User_Story__c in :userStory];
		Map<String, List<String>> mUsProfiles = new Map<String, List<string>>();  
		for (copado__User_Story_Metadata__c item : metaDatos) {
			n = item.copado__Metadata_API_Name__c.Split('\\.');
			if (n.size() > 1) {
				if (item.copado__Metadata_API_Name__c.contains('ApexClass')){
					objApex.add(n[0] + '.' + n[1]);
				} else if (item.copado__Metadata_API_Name__c.contains('ApexTrigger')){
					objApex.add(n[0] + '.' + n[1]);
				//}else if (item.copado__Metadata_API_Name__c.contains('Flow') && !item.copado__Metadata_API_Name__c.contains('ApexTrigger') && !item.copado__Metadata_API_Name__c.contains('ApexClass') && !item.copado__Metadata_API_Name__c.contains('CustomMetadata')){
				}else if (item.copado__Metadata_API_Name__c.startswith('Flow.') || item.copado__Metadata_API_Name__c.startswith('FlowDefinition.')){
					objFlow.add(n[0] + '.' + n[1]);
				}else if (item.copado__Metadata_API_Name__c.contains('CustomField') && !item.copado__Metadata_API_Name__c.contains('__mdt')){
					string obj = n[1];
					if(obj == 'Activity'){
						obj = 'Task';
					}
					SObjectType objecttype = Schema.getGlobalDescribe()?.get(obj);	
					Schema.DescribeSObjectResult check = objecttype?.getDescribe();
					if(check != null && !check.isCustomSetting()){
						objectField.add(n[0] + '.' + n[1] + '.' + n[2]);
					}
				}else if (item.copado__Metadata_API_Name__c.contains('RecordType')){
					objectRT.add(n[0] + '.' + n[1] + '.' + n[2]);
				}else if (item.copado__Metadata_API_Name__c.contains('Profile')){
					objectProfile.add(n[1]);
				}else{
					objetosUs.add(n[0] + '.' + n[1]);
				}
			}
		}

		// Obtiene los enviroments disponibles y coge su info para luego consultar y tratar datos
		Map<Id, boolean> entornos = new Map<Id, boolean> ();
		Map<Id, String> entornosName = new Map<Id, String> ();
		List<String> origenName = new List<String> ();	
		for (copado__Environment__c obj :[SELECT Id, name,CBK_CheckControlIps__c,CBK_Validacion_OT__c, 
					(SELECT copado__Source_Environment__r.CBK_CheckControlIps__c, copado__Source_Environment__r.Name, copado__Source_Environment__c 
					FROM copado__Deployment_Flow_Steps1__r 
					WHERE copado__Destination_Environment__r.name='STAGINGINT' AND copado__Source_Environment__r.CBK_CheckControlIps__c = true) 
				FROM copado__Environment__c]){

			entornos.put(obj.id, obj.CBK_Validacion_OT__c);
			entornosName.put(obj.id, obj.Name);
			if (!obj.copado__Deployment_Flow_Steps1__r.isEmpty()){
				for(copado__Deployment_Flow_Step__c p : obj.copado__Deployment_Flow_Steps1__r){
					origenName.add(p.copado__Source_Environment__c);
				}
			}
		}
		map<Id, list<String>> rechazos = new map<Id, List<String>> ();

		//Check Flows
		Set<String> checkFlow = new Set<String> ();
		for (CBK_DataModel__mdt dm :[Select ClassName__c from CBK_DataModel__mdt where ClassName__c in :objFlow]) {
			checkFlow.add(dm.ClassName__c);
		}
		// Check if any obj not in whitelist(checkFlow)
		Set<String> objFlowBlackList = new Set<String> ();
		if (objFlow.size() > checkFlow.size()) {
			for (String obj : objFlow) {
				if (!checkFlow.contains(obj)) {
					objFlowBlackList.add(obj);
				}
			}
		}

		//Comprobar apex Class
		Set<String> checkApex = new Set<String> ();
		for (CBK_DataModel__mdt dm :[Select Developername, ClassName__c, Label from CBK_DataModel__mdt where ClassName__c in :objApex]) {
			checkApex.add(dm.ClassName__c);
		}

		Set<String> allclass = new Set<string> ();
		List<String> lstSplit = new List<String> ();
		List<String> lstSplit2 = new List<String> ();
		for (string oclass : objApex) {
			lstSplit = oclass.split('\\.');
			lstSplit2 = lstSplit.get(1).split('_');
			allclass.add(lstSplit.get(0) + '.' + lstSplit2.get(0));

			if (lstSplit2.contains('TRDisp')){
				allclass.add(lstSplit.get(0) + '.' + lstSplit2.get(0) + '_TRDisp');
			}
		}

		for (CBK_DataModel__mdt dm :[Select Developername, ClassName__c, Label from CBK_DataModel__mdt where ClassName__c in :allclass]) {
			checkApex.add(dm.ClassName__c);
		}


		Boolean hasCustomPermission = FeatureManagement.checkPermission('CBK_OT');
		Set<String> sErrors = checkToFwkDAN(objectField);
		sErrors = checkToFwkDANRT(objectRT, sErrors);
		
		for (copado__User_Story__c obj : listNewObj) {
			Boolean checkEnv = entornos.get(obj.copado__Environment__c);
			if (((obj.copado__Promote_Change__c) || (obj.copado__Promote_and_Deploy__c)) && (sErrors != null && sErrors.size() > 0 && !hasCustomPermission && checkEnv)) {
				CBK_Log.debug('Objetos/Campos no validados por la OT: ' + sErrors, logginglevel.DEBUG);
				obj.addError('Objetos/Campos no validados por la OT: ' + sErrors);
			}

		}

		// Check Apex class
		for (copado__User_Story__c obj : listNewObj) {
			Boolean checkEnv = entornos.get(obj.copado__Environment__c);
			if (((obj.copado__Promote_Change__c) || (obj.copado__Promote_and_Deploy__c) || Test.isRunningTest()) && (checkApex != null && checkApex.size() > 0) && !hasCustomPermission && checkEnv) {

				if (rechazos.get(obj.Id) != null && rechazos.get(obj.Id).size() > 0) {
					checkApex.addAll(rechazos.get(obj.Id));
					CBK_Log.debug('Objetos no validados por la OT: ' + checkApex, logginglevel.DEBUG);
					obj.addError('Objetos no validados por la OT: ' + checkApex);
				} else {
					CBK_Log.debug('Objetos no validados por la OT: ' + checkApex, logginglevel.DEBUG);
					obj.addError('Objetos no validados por la OT: ' + checkApex);
				}
			}
		}

		// Check Flows
		for (copado__User_Story__c obj : listNewObj) {
			Boolean checkEnv = entornos.get(obj.copado__Environment__c);
			if (((obj.copado__Promote_Change__c) || (obj.copado__Promote_and_Deploy__c) || Test.isRunningTest()) && (objFlowBlackList != null && objFlowBlackList.size() > 0) && !hasCustomPermission && checkEnv) {

				if (rechazos.get(obj.Id) != null && rechazos.get(obj.Id).size() > 0) {
					objFlowBlackList.addAll(rechazos.get(obj.Id));
					CBK_Log.debug('Objetos no validados por la OT: ' + objFlowBlackList, logginglevel.DEBUG);
					obj.addError('Objetos no validados por la OT: ' + objFlowBlackList);
				} else {
					CBK_Log.debug('Objetos no validados por la OT: ' + objFlowBlackList, logginglevel.DEBUG);
					obj.addError('Objetos no validados por la OT: ' + objFlowBlackList);
				}
			}
		}

		//Check ips
		List<string> profileList = new List<String>();
		profileList.addAll(objectProfile);
		Id  rtidProfile = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Profile').getRecordTypeId();
		CBK_Log.debug('Check IPs : nº profiles: '+ profileList.size() + ' List: '+ json.serializePretty(profileList), logginglevel.DEBUG);
		List<CBK_DataManager__c> lstDM = [SELECT Id, Name, ProfileName__c, Check_By_OT__c FROM CBK_DataManager__c WHERE RecordTypeId = :rtidProfile AND ProfileName__c IN :profileList AND Check_By_OT__c  = true];
		profileList = new List<String>();
		if (lstDM != null && lstDM.size()>0){
			for (CBK_DataManager__c dm : lstDM){
				profileList.add(dm.ProfileName__c);
			}
		}

		List<String> lstProfile = new List<String>();
		Integer iteracionProfile = 0;
		Integer lanzamiento = 1;
		Integer i = 1;
		string envirName = '';
		Map<String,List<String>> mprLauch = new Map<String,List<String>>();
		for (copado__User_Story__c obj : listNewObj) {
			String usId = obj.Id;
			Boolean checkEnvDest = origenName.contains(obj.copado__Environment__c);
			if(!obj.CBK_HasConflictIp__c && String.isBlank(obj.CBK_IP_Conflict__c) && profileList.size() > 0  && checkEnvDest && (obj.copado__Promote_Change__c || obj.copado__Promote_and_Deploy__c) && !checkWhiteList(obj.copado__Project__r.Name)){
				if (profileList.size() <= 3 && !Test.isRunningTest()){
					CBK_Control_IPS_Profile_Queueable callApi =  new CBK_Control_IPS_Profile_Queueable(profileList, usId, envirName);
					Id jobId = System.enqueueJob(callApi);
					break;
				}else{
					for(String profile : profileList){
						if(mprLauch.containsKey(string.valueOf(lanzamiento))){
							if(!mprLauch.get(string.valueOf(lanzamiento)).contains(profile)){
								if (iteracionProfile < 3 ){
									lstProfile =  new List<String>();
									lstProfile.add(profile);
									mprLauch.get(string.valueOf(lanzamiento)).addAll(lstProfile);
									iteracionProfile++;
								}
								if(iteracionProfile == 3){
									lanzamiento++;
									iteracionProfile = 0;
								}
							}
						}else{
							lstProfile =  new List<String>();
							lstProfile.add(profile);
							mprLauch.put(string.valueOf(lanzamiento), lstProfile);
							iteracionProfile++;
						}
						i++;
					}
				}
			}
			break;
		}

		//Check Ips: LLamada masiva con perfiles hacia la metadata api 
		CBK_Log.debug('MAPA ejcución Masiva: ' + json.serializePretty(mprLauch), logginglevel.DEBUG);
		if(mprLauch != null && mprLauch.keySet().size() > 0){
			integer ite=0;
			Id jobId;
			try{
				for (copado__User_Story__c obj : listNewObj) {
					envirName  = entornosName.get(obj.copado__Environment__c);
					for (String key : mprLauch.keySet()){
						if(!Test.isRunningTest()){
							CBK_Control_IPS_Profile_Queueable callApiMasivo =  new CBK_Control_IPS_Profile_Queueable(mprLauch.get(key), obj.Id, envirName);
							jobId = System.enqueueJob(callApiMasivo);
						}
						ite++;
						CBK_Log.debug('LLamada nº'+ite+ ' API Masiva - jobId :' + jobId + ' Prfiles: ' + mprLauch.get(key) + ' US: ' + obj.Id, logginglevel.DEBUG);
					}
					break;
				}
			}catch(Exception e){
				CBK_log.error(e, 'Error: Ejecución Masiva call Metadata API');
			}
		}
	}

	private Set<String> checkToFwkDAN(Set<String> objectField) {

		Map<String, list<String>> mObjField = new Map<String, List<String>> ();
		list<String> objName = new List<String> ();
		list<String> objField;
		List<String> separateSCheck = new List<String> ();
		List<String> objObjField = new List<String> ();

		for (String partSCheck : objectField) {
			separateSCheck = partSCheck.split('\\.');
			String partType = separateSCheck.get(0);
			String partObj = separateSCheck.get(1);
			String partField = separateSCheck.get(2);
			String partObjField = (partObj + '.' + partField);
			objName.add(partObj);

			objObjField.add(partObjField);

			if (mObjField.containsKey(partObj)) {
				mObjField.get(partObj).add(partField);
			} else {
				objField = new List<String> ();
				objField.add(partField);
				mObjField.put(partObj, objField);
			}
		}

		// Get info Data Manager
		List<CBK_DataManager__c> lstObjDM = [Select Field_Name__c, Check_By_OT__c, Object__r.Check_By_OT__c, Object__c, API_Name__c, Object__r.API_Name__c, Status__c FROM CBK_DataManager__c WHERE Object__r.API_Name__c IN :mObjField.keySet()];
		Map<String, List<CBK_DataManager__c>> mFieldDesc = new Map<String, List<CBK_DataManager__c>> ();
		List<CBK_DataManager__c> lmFieldDesc;

		for (CBK_DataManager__c objDMField : lstObjDM) {
			String nameObject = objDMField.Object__r.API_Name__c;
			String fieldObject = objDMField.Field_Name__c;

			lmFieldDesc = new List<CBK_DataManager__c> ();
			if (mFieldDesc.containsKey(nameObject)) {
				lmFieldDesc.add(objDMField);
				mFieldDesc.get(nameObject).addAll(lmFieldDesc);
			} else {
				lmFieldDesc.add(objDMField);
				mFieldDesc.put(nameObject, lmFieldDesc);
			}

		}

		Set<string> lstErrs = new Set<string> ();
		List<String> separateParts = new List<String> ();
		for (String objNameField : objObjField) {
			separateParts = objNameField.split('\\.');
			String pObj = separateParts.get(0);
			String pField = separateParts.get(1);

			if (mFieldDesc.containsKey(pObj)) {
				Set<String> vcheck = new Set<String> ();
				for (CBK_DataManager__c obj : mFieldDesc.get(pObj)) {
					vcheck.add(obj.API_Name__c);
				}

				for (CBK_DataManager__c obj : mFieldDesc.get(pObj)) {
					if (obj.Object__r.Check_By_OT__c) {
						if (obj.API_Name__c == pField) {
							if (obj.Status__c != 'Approved') {
								lstErrs.add(pObj + '.' + pField);
							}
						} else if (!vcheck.contains(pField)) {
							lstErrs.add(pObj + '.' + pField);
						}
					}
				}

			} else {
				lstErrs.add(pObj);
			}
		}
		return lstErrs;
	}

	// Recojo los Record Types que contiene la US
	private Set<String> checkToFwkDANRT(Set<String> objectRT, Set<String> sErrors ){
		Map<String, list<String>> mobjRT = new Map<String, list<String>>(); // Mapara Objeto ---> Record Types
		list<String> objRT; // Lista que recoge el nombre de los RT
		List<String> separateRT = new List<String> (); // Para la separación de como viene el RT en la US
		Set<String> objRTAll = new Set<String> ();

		for (String partRTk : objectRT) {
			separateRT = partRTk.split('\\.');
			String partTypeRT = separateRT.get(0);
			String partObjRT = separateRT.get(1);
			String partNameRT = separateRT.get(2);
			objRTAll.add(partNameRT);

			if (mobjRT.containsKey(partObjRT)) {
				mobjRT.get(partObjRT).add(partNameRT);
			} else {
				objRT = new List<String> ();
				objRT.add(partNameRT);
				mobjRT.put(partObjRT, objRT);
			}
		}

		// Recojo los Record Types que contienen los Objetos del Data Manager
		List<CBK_DataManager__c> lstRTDM = [Select RecordTypeName__c, Object__r.Check_By_OT__c, RecordTypes__r.API_Name__c, Status__c, Object__r.API_Name__c 
					FROM CBK_DataManager__c 
					WHERE RecordType.DeveloperName = 'RecordType' and Object__r.API_Name__c IN :mobjRT.keySet() and API_Name__c IN :objRTAll];

		Map<String, List<string>> mobjRTDM = new Map<String, List<string>>();
		Map<String, String> mobjRTId = new Map<String, String>();
		Map<String, CBK_DataManager__c> mRTidObj = new Map<String, CBK_DataManager__c>();
		List<String> lmRTDesc;

		if(lstRTDM != null && !lstRTDM.isEmpty()){
			for(CBK_DataManager__c objDMRT : lstRTDM){
				String nameObjRT= objDMRT.Object__r.API_Name__c;
				String nameRTDM= objDMRT.RecordTypeName__c;

				lmRTDesc = new List<String>();
				mobjRTId.put(nameObjRT,objDMRT.Id);
				mRTidObj.put(objDMRT.Id,objDMRT);

				if(mobjRTDM.containsKey(nameObjRT)){
					lmRTDesc.add(nameRTDM);
					mobjRTDM.get(nameObjRT).addAll(lmRTDesc);
				}else {
					lmRTDesc.add(nameRTDM);
					mobjRTDM.put(nameObjRT, lmRTDesc);
				}
			}
		}

		// Comparativa entre los RecordTypes y de US y de Data Manager
		Set<string> lstErrsRT = new Set<string>();
		List<String> separatePasrtRT = new List<String>();
		separateRT = new List<String> ();

		for(string rt : objectRT){
			separateRT = rt.split('\\.');
			String partObjRT = separateRT.get(1);
			String partNameRT = separateRT.get(2);

			if (mobjRTDM.containsKey(partObjRT)){
				if (mobjRTDM.get(partObjRT).contains(partNameRT)){
					string idRT = mobjRTId.get(partObjRT);
					CBK_DataManager__c objDM = mRTidObj.get(idRT);
					if (objDM.Status__c != 'Approved'){
						sErrors.add(rt);
					}
				}else{
					sErrors.add(rt);
				}
			}else {
				sErrors.add(rt);
			}
		}
		CBK_Log.debug('sErrors' + JSON.serializePretty(sErrors), logginglevel.DEBUG);
		return sErrors;
	}
	// White List para saltarse el control de ips
	private Boolean checkWhiteList(String project){
		List<CBK_ControlIps_WhiteListProject__mdt> mdtConfig = CBK_ControlIps_WhiteListProject__mdt.getAll().values();
		Boolean check = false;
		for(CBK_ControlIps_WhiteListProject__mdt mdt : mdtConfig){
			if(mdt.CBK_ProjectNameCopado__c == project){
				check = mdt.CBK_IsActive__c;
			}
		}
		return check;
	}
}