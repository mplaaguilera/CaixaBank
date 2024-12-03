public without sharing class CBK_EmailMessage_Parent_TRHan extends CC_TriggerDispatcherBase {
	private static String objectApiName = 'EmailMessage';
	private final static String HEADER_PARAMS = 'X-SFDC-Original-RCPT';
	private static Map<Id, String> mapRTInfo = new Map <Id, String>();
	private static Set<String> checkRTExistsSet = new Set<String>();
	public void executeParent(CC_TriggerParameters tp, CC_TriggerParameters.TriggerEvent eventype) {
		process((List<EmailMessage>) tp.newList, (Map<Id, EmailMessage>) tp.newMap, (List<EmailMessage>) tp.oldList, (Map<Id, EmailMessage>) tp.oldMap, eventype);
	}

	public void process(List<EmailMessage> correos, Map<Id, EmailMessage> mapaCorreos, List<EmailMessage> correosOld, Map<Id, EmailMessage> mapaCorreosOld, CC_TriggerParameters.TriggerEvent eventype) {
		CBK_log.debug('Parent Handler CBK_EmailMessage_Parent_TRHan - eventype: ' + eventype, LoggingLevel.INFO);
		List<SObject> lstEntr = new List<SObject> ();
		List<SObject> lstSal = new List<SObject> ();

		List<SObject> lstEntrOld = new List<SObject> ();
		List<SObject> lstSalOld = new List<SObject> ();

		if(mapRTInfo.isEmpty()){
			for(RecordType rtInfo : [SELECT Id, DeveloperName, SobjectType FROM RecordType]){
				mapRTInfo.put(rtInfo.Id, rtInfo.DeveloperName );
				checkRTExistsSet.add(rtInfo.SobjectType);
			}
		}
		
		Request reqInfo = Request.getCurrent();
		Quiddity currentType = reqInfo.getQuiddity();  
		String result = String.valueOf(currentType);
		CBK_log.debug('Parent Handler CBK_EmailMessage_Parent_TRHan - getQuiddity: ' + result, LoggingLevel.INFO);

		if (String.valueOf(eventype) == 'beforeDelete' || String.valueOf(eventype) == 'afterDelete'){
			correos = correosOld;
		}
		
		for (EmailMessage correo : correos) {
			if (correo.Incoming) {
				if(result == 'INBOUND_EMAIL_SERVICE' || Test.isRunningTest()){
					lstEntr.add(correo);
				}
			} else {
				lstSal.add(correo);
			}
		}
		if (lstSal.size() > 0) {
			tratarSalida(lstSal,mapaCorreosOld, eventype);
		}
		if (lstEntr.size() > 0) {
			tratarEntrada(lstEntr, mapaCorreosOld, eventype);
		}
	}


	public void tratarSalida(List<EmailMessage> correos, Map<Id, EmailMessage> mapaCorreosOld, CC_TriggerParameters.TriggerEvent eventype) {
		Map<string, Map<String, List<EmailMessage>>> mSobjectInfo = new Map<string, Map<String, List<EmailMessage>>> ();
		Map<String, CBK_TriggerHandlerParent__mdt> mcs = CBK_TriggerHandlerParent__mdt.getAll();

		//Mapa de Set de acumulación de Ids
		Map<String, Set<String>> sObjectsIdsBySObjectType = new Map<String, Set<String>>();

		String sObjName;
		List<EmailMessage> lstem;

		//Rellenamos el mapa con el tipo de objeto y los Ids de esos objetos
		for (EmailMessage correo : correos) {
			if (String.isNotBlank(correo.ParentId)) {
				sObjName = correo.ParentId.getSObjectType().getDescribe().getName();
				if (!sObjectsIdsBySObjectType.containsKey(sObjName)) {
					sObjectsIdsBySObjectType.put(sObjName, new Set<String>());
					sObjectsIdsBySObjectType.get(sObjName).add(correo.ParentId);
				}else{
					sObjectsIdsBySObjectType.get(sObjName).add(correo.ParentId);
				}
			} else if(String.isNotBlank(correo.RelatedToId)){
				sObjName = correo.RelatedToId.getSObjectType().getDescribe().getName();
				if (!sObjectsIdsBySObjectType.containsKey(sObjName)) {
					sObjectsIdsBySObjectType.put(sObjName, new Set<String>());
					sObjectsIdsBySObjectType.get(sObjName).add(correo.RelatedToId);
				}else{
					sObjectsIdsBySObjectType.get(sObjName).add(correo.RelatedToId);
				}
			}
		}
		//Creamos un mapa que contenga como clave el nombre del objeto
		Map<String, Map<Id, SObject>> sObjectMapsBySObjectType = new Map<String, Map<Id, SObject>>();

		for(String sObjectName : sObjectsIdsBySObjectType.keySet()){
			if(checkRTExistsSet.contains(sObjectName)){
				Set<String> idSet = SObjectsIdsBySObjectType.get(sObjectName);
				Map<Id, SObject> newSObjectMap = new Map<Id, SObject>(Database.query(String.format('SELECT Id, RecordTypeId FROM {0} WHERE Id IN : idSet', new List<String>{sObjectName})));
				
				if(!newSObjectMap.isEmpty()){
					sObjectMapsBySObjectType.put(sObjectName, newSObjectMap);
				}
			}
		}

		String rt;

		//get info Metadata
		Map<String, set<String>> mapInfoMdt = getInfoMdtSalida(String.valueOf(eventype));
		mapInfoMdt = mapInfoMdt.size() > 0 ? mapInfoMdt : new Map<String, set<String>>();
		Boolean result;

		mSobjectInfo = relatedSObjectSegmentation(correos, mapInfoMdt, sObjectMapsBySObjectType);

		string objetoMT;
		String className;
		String eventtrigger;
		string typeEm;
		Boolean active = false;
		CC_TriggerParameters tp;

		//Ejecucion de handler clasificados por Objeto -> RecordType -> Lista de Emails
		List<String> configHandlerSort = new List<String>(mcs.keySet());
		configHandlerSort.sort();
		for (string mt : configHandlerSort){
			rt = mcs.get(mt).CBK_RecordType__c;
			objetoMT = mcs.get(mt).CBK_ObjectAPIName__c;
			className = mcs.get(mt).CBK_HandlerClassName__c;
			eventtrigger = mcs.get(mt).CBKL_TriggerEvent__c;
			typeEm = String.isBlank(mcs.get(mt).CBK_Type__c) ? '' : mcs.get(mt).CBK_Type__c;
			active = mcs.get(mt).CBK_Active__c;
			tp = new CC_TriggerParameters();

			if (typeEm.toUpperCase() == String.valueOf('Salida').toUpperCase()) {
				if (mSobjectInfo.containsKey(objetoMT) && eventtrigger == String.valueOf(eventype)) {
					tp.newList = mSobjectInfo.get(objetoMT).get(rt);
					tp.newMap = generateMap(mSobjectInfo.get(objetoMT).get(rt), eventype);
					if (String.valueOf(eventype) == 'beforeDelete' || String.valueOf(eventype) == 'afterDelete'){
						tp.newList = new List<EmailMessage>();
						tp.newMap = new Map<Id,EmailMessage>();
						tp.oldList = mSobjectInfo.get(objetoMT).get(rt);
						tp.oldMap = generateMap(mSobjectInfo.get(objetoMT).get(rt), eventype);
					}else if(String.valueOf(eventype) == 'beforeUpdate' || String.valueOf(eventype) == 'afterUpdate'){
						tp.oldList =  generateOldList(tp.newList, mapaCorreosOld);
						tp.oldMap = generateMap(tp.oldList, eventype);
					}
					
					if (Test.isRunningTest()) {
						active = true;
					}
					if (((tp.newList != null && tp.newList.size() > 0) || (tp.oldList != null && tp.oldList.size() > 0 ))  && active){
						Type handlerClassType = Type.forName(className);
						if(handlerClassType != null){
							execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, eventype);
						}else{
							CBK_Log.addError(null, null, 'Trigger Handler Associations - No existe la clase: ' + className + ' - Para el Objeto: ' + objectApiName + ', Evento: ' + eventype, new List <Object>(), null);
						}
					}
				}
			}
		}
		CBK_Config__mdt mc = CBK_Config__mdt.getInstance('Active_Execution');
		//Ejecuccion normal para aquellos Emails no incluidos en mdt: Trigger Handlers Parent
		for (string handlerClassName : getAssociatedHandlers(objectApiName, String.valueOf(eventype))) {
			Type handlerClassType = Type.forName(handlerClassName);
			if (mSobjectInfo.containsKey('Otros') && mSobjectInfo.get('Otros').containsKey('Otros')) {
				tp = new CC_TriggerParameters();
				tp.newList = mSobjectInfo.get('Otros').get('Otros');
				tp.newMap = generateMap(mSobjectInfo.get('Otros').get('Otros'), eventype);
			
				if (String.valueOf(eventype) == 'beforeDelete' || String.valueOf(eventype) == 'afterDelete'){
					tp.newList = new List<EmailMessage>();
					tp.newMap = new Map<Id,EmailMessage>();
					tp.oldList = mSobjectInfo.get('Otros').get('Otros');
					tp.oldMap = generateMap(mSobjectInfo.get('Otros').get('Otros'), eventype);
				}else if(String.valueOf(eventype) == 'beforeUpdate' || String.valueOf(eventype) == 'afterUpdate'){
					tp.oldList =  generateOldList(tp.newList, mapaCorreosOld);
					tp.oldMap = generateMap(tp.oldList, eventype);
				}
				if(tp.newList != null && !tp.newList.isEmpty()){
					CBK_log.debug('\n Emails Salida - Fuera del FWK: '+ eventype + ' ' + JSON.serialize(tp.newList), LoggingLevel.INFO);
				}
				if (mc.CBK_Active__c){
					if(handlerClassType != null){
						if(tp.newList != null && !tp.newList.isEmpty()){
							CBK_log.debug('\n Emails Salida Ejecucion normal: '+ eventype + ' - Objeto: Otros - Recordtype: Otros -  ClassName: '+ handlerClassName + JSON.serialize(tp.newList), LoggingLevel.INFO);
						}
						execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, eventype);
					}else{
						CBK_Log.addError(null, null, 'Trigger Handler Associations - No existe la clase: ' + handlerClassName + ' - Para el Objeto: ' + objectApiName + ', Evento: ' + eventype, new List <Object>(), null);
					}
				}
			}
		}
	}

	public void tratarEntrada(List<EmailMessage> correos, Map<Id, EmailMessage> mapaCorreosOld, CC_TriggerParameters.TriggerEvent eventype) {
		Map<string, List<EmailMessage>> mSobjectInfo = new Map<string, List<EmailMessage>> ();
		Map<String, CBK_TriggerHandlerParent__mdt> mcs = CBK_TriggerHandlerParent__mdt.getAll();

		//get info Metadata
		Map<String, Set<String>> mapInfoMdt = getInfoMdtEntrada(String.valueOf(eventype));
		List<EmailMessage> lstem;
		CBK_TriggerHandlerParent__mdt mdt;
		Set<string> lstLocalPart = new Set<String>();
		string inputEmail = '';
		List<String> emailTocaseInfo = getEmailToCaseinfo();

		for (EmailMessage correo : correos) {
			inputEmail = correo.ToAddress;
			string emailHeader = getToAddresHeader(correo.Headers, inputEmail, emailTocaseInfo );
			List<string> localPart  = emailHeader.split('@');
			lstLocalPart.add(localPart[0]);
		}
		
		//Get info EmailService
		Map<String,string> mEmailServiceInfo = new Map<String,string>();
		mEmailServiceInfo = getEmailServiceAndEmailToCase(lstLocalPart);
		CBK_log.debug('mEmailServiceInfo ' + JSON.serialize(mEmailServiceInfo), LoggingLevel.INFO);

		for (EmailMessage correo : correos) {
			inputEmail = correo.ToAddress;
			string emailHeader = getToAddresHeader(correo.Headers, inputEmail, emailTocaseInfo);

			emailHeader = mEmailServiceInfo.containsKey(emailHeader) ? mEmailServiceInfo.get(emailHeader) : '';	
			if (!mapInfoMdt.containsKey(emailHeader)) {
				emailHeader = 'Otros';
			}
			lstem = new List<EmailMessage> ();
			lstem.add(correo);
			if (mSobjectInfo.containsKey(emailHeader)) {
				mSobjectInfo.get(emailHeader).addAll(lstem);
			} else {
				mSobjectInfo.put(emailHeader, lstem);
			}	
		}
		CBK_log.debug('Entrada Map --> EmailServices: ' + JSON.serialize(mSobjectInfo), LoggingLevel.INFO);
		
		String inEmail;
		String className;
		String typeEm;
		String eventtrigger;
		Boolean active = false;
		CC_TriggerParameters tp;
		
		//Ejecucion de handler clasificados por: Email Entrante -> Handler class 
		List<String> configHandlerSort = new List<String>(mcs.keySet());
		configHandlerSort.sort();
		for (string mt : configHandlerSort){
			inEmail = String.isBlank(mcs.get(mt).CBK_Email__c) ? '' : mcs.get(mt).CBK_Email__c;
			className = mcs.get(mt).CBK_HandlerClassName__c;
			typeEm = String.isBlank(mcs.get(mt).CBK_Type__c) ? '' : mcs.get(mt).CBK_Type__c;
			eventtrigger = mcs.get(mt).CBKL_TriggerEvent__c;
			active = mcs.get(mt).CBK_Active__c;
			tp = new CC_TriggerParameters();

			if (typeEm.toUpperCase() == String.valueOf('Entrada').toUpperCase()) {
				if (mSobjectInfo.containsKey(inEmail) && eventtrigger == String.valueOf(eventype)) {
					tp.newList = mSobjectInfo.get(inEmail);
					tp.newMap = generateMap(mSobjectInfo.get(inEmail), eventype);
					if (String.valueOf(eventype) == 'beforeDelete' || String.valueOf(eventype) == 'afterDelete'){
						tp.newList = new List<EmailMessage>();
						tp.newMap = new Map<Id,EmailMessage>();
						tp.oldList = mSobjectInfo.get(inEmail);
						tp.oldMap = generateMap(mSobjectInfo.get(inEmail), eventype);
					}else if(String.valueOf(eventype) == 'beforeUpdate' || String.valueOf(eventype) == 'afterUpdate'){
						tp.oldList =  generateOldList(tp.newList, mapaCorreosOld);
						tp.oldMap = generateMap(tp.oldList, eventype);
					}
					
					if (Test.isRunningTest()) {
						active = true;
					}
					
					if (((tp.newList != null && tp.newList.size() > 0) || (tp.oldList != null && tp.oldList.size() > 0 ))  && active) {
						Type handlerClassType = Type.forName(className);
						if(handlerClassType != null){
						CBK_log.debug('Entrada Parent - Exec Class: ' + eventype + ' - EmailService: ' + inEmail + ' - ' + className, LoggingLevel.INFO);
						CBK_log.debug('Entrada Lst Emails: ' + JSON.serialize(tp.newList), LoggingLevel.INFO);
						CBK_log.debug('Entrada Map Emails: ' + JSON.serialize(tp.newMap), LoggingLevel.INFO);
						execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, eventype);
						}else{
							CBK_Log.addError(null, null, 'Trigger Handler Associations - No existe la clase: ' + className + ' - Para el Objeto: ' + objectApiName + ', Evento: ' + eventtrigger, new List <Object>(), null);
						}
					}
				}
			}
		}
		CBK_log.debug('entrada Map: ' + json.serialize(mSobjectInfo), LoggingLevel.INFO);
		CBK_Config__mdt mc = CBK_Config__mdt.getInstance('Active_Execution');
		//Ejecuccion fuera del FWK trigger
		for (string handlerClassName : getAssociatedHandlers(objectApiName, String.valueOf(eventype))) {
			Type handlerClassType = Type.forName(handlerClassName);
			if (mSobjectInfo.containsKey('Otros')) {
				tp = new CC_TriggerParameters();
				tp.newList = mSobjectInfo.get('Otros');
				tp.newMap = generateMap(mSobjectInfo.get('Otros'), eventype);
				
				if (mc.CBK_Active__c){
					if(handlerClassType != null){
					CBK_log.debug('\n Emails Entrada Fuera del FWK: '+ eventype + ' - EmailService: Otros ' + JSON.serialize(tp.newList), LoggingLevel.INFO);
					CBK_log.debug('\n Emails Entrada Ejecucion normal: '+ eventype + ' - EmailService: Otros - ClassName: '+ handlerClassName + JSON.serialize(tp.newList), LoggingLevel.INFO);
					execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, eventype);
					}else{
						CBK_Log.addError(null, null, 'Trigger Handler Associations - No existe la clase: ' + handlerClassName + ' - Para el Objeto: ' + objectApiName + ', Evento: ' + eventype, new List <Object>(), null);
					}
				}
			}
		}
	}

	//Metodos
	private static Map<String, set<String>> getInfoMdtSalida(String eventype) {
		Map<String, CBK_TriggerHandlerParent__mdt> mcs = CBK_TriggerHandlerParent__mdt.getAll();
		CBK_TriggerHandlerParent__mdt mdt;
		set<string> lstRTmdt;
		Boolean active = false;
		String eventypeMdt = '';
		Map<String, set<String>> mRTmdt = new Map<String, set<String>> ();
		for (string mt : mcs.keySet()) {
			mdt = mcs.get(mt);
			active = mdt.CBK_Active__c;
			eventypeMdt = mdt.CBKL_TriggerEvent__c;
			string cbkType = String.isBlank(mdt.CBK_Type__c) ? '' : mdt.CBK_Type__c;
			if (String.valueOf(cbkType).toUpperCase() == String.valueOf('Salida').toUpperCase()) {

				if (Test.isRunningTest()) {
					active = true;
				}

				if (active && eventypeMdt == eventype) {
					if (mRTmdt.containsKey(mdt.CBK_ObjectAPIName__c)) {
						lstRTmdt = new set<String> ();
						lstRTmdt.add(mdt.CBK_RecordType__c);
						mRTmdt.get(mdt.CBK_ObjectAPIName__c).addAll(lstRTmdt);
					} else {
						lstRTmdt = new set<String> ();
						lstRTmdt.add(mdt.CBK_RecordType__c);
						mRTmdt.put(mdt.CBK_ObjectAPIName__c, lstRTmdt);
					}
				}
			}
		}
		return mRTmdt;
	}

	private static Map<String, Set<string>> getInfoMdtEntrada(String eventype) {
		Map<String, CBK_TriggerHandlerParent__mdt> mcs = CBK_TriggerHandlerParent__mdt.getAll();
		CBK_TriggerHandlerParent__mdt mdt;
		set<string> lstRTmdt;
		Boolean active = false;
		String eventypeMdt = '';
		Map<String, Set<String>> mEntradaMdt = new Map<String, Set<String>> ();
		for (string mt : mcs.keySet()) {
			mdt = mcs.get(mt);
			active = mdt.CBK_Active__c;
			eventypeMdt = mdt.CBKL_TriggerEvent__c;
			if (String.valueOf(mdt.CBK_Type__c).toUpperCase() == String.valueOf('Entrada').toUpperCase()) {

				if (Test.isRunningTest()) {
					active = true;
				}

				if (active && eventypeMdt == eventype) {
					if (mEntradaMdt.containsKey(mdt.CBK_Email__c)) {
						lstRTmdt = new set<String> ();
						lstRTmdt.add(mdt.CBK_HandlerClassName__c);
						mEntradaMdt.get(mdt.CBK_Email__c).addAll(lstRTmdt);

					} else {
						lstRTmdt = new set<String> ();
						lstRTmdt.add(mdt.CBK_HandlerClassName__c);
						mEntradaMdt.put(mdt.CBK_Email__c, lstRTmdt);
					}
				}
			}
		}
		return mEntradaMdt;
	}

	public static Map<String,string> getEmailServiceAndEmailToCase(Set<string> slocalPart){
	
		List<EmailServicesAddress> lstEmailService = [SELECT LocalPart, DeveloperName, EmailDomainName,Function.FunctionName FROM EmailServicesAddress 
													WHERE LocalPart IN :slocalPart limit 200];

		Map<String,string> mEmailServiceInfo = new Map<String,string>();

		if (lstEmailService != null && lstEmailService.size() > 0){
			
			for(EmailServicesAddress ems : lstEmailService){
			
				if (ems.Function.FunctionName != 'EmailToCase'){
					mEmailServiceInfo.put(ems.LocalPart + '@' + ems.EmailDomainName, ems.Function.FunctionName);
				}else{
					mEmailServiceInfo.put(ems.LocalPart + '@' + ems.EmailDomainName, ems.DeveloperName);
				}
			}		
		}
		return mEmailServiceInfo;
	}

	public static String getToAddresHeader(String header, string toAdress, List<String> emailTocaseInfo) {
    	List<HeaderDTO> lstHeaderDTO;
		try{
			lstHeaderDTO = (List<HeaderDTO>) JSON.deserialize(header, List<HeaderDTO>.class);
		}catch(Exception e){
			if(String.isNotBlank(header)){
				List<String> refactor =  header.split('\n'); 
				lstHeaderDTO = new List<HeaderDTO>();
				for (String key: refactor){
					if (key.contains('X-SFDC-Original-RCPT')){
						String headerEmail = key.split(':')[1];
						HeaderDTO head =  new HeaderDTO();
						head.name = key.split(':')[0];
						head.value = headerEmail.trim();
						lstHeaderDTO.add(head);
						break;
					}	
				}
			}else{
				CBK_Log.addError(null, e, 'Error Header Vacio', new List<Object>() , null);		
			}
		}
		Map<String, String> mheaderInfo = new Map<String, String> ();
		string emailHeader = '';
		if (lstHeaderDTO != null && lstHeaderDTO.size() > 0) {
			for (HeaderDTO hdto : lstHeaderDTO) {
				if (!mheaderInfo.containsKey(hdto.name)) {
					mheaderInfo.put(hdto.name, hdto.value);
				}
			}
			emailHeader = mheaderInfo.get(HEADER_PARAMS);
		}
		return emailHeader;
	}

	public static String getToAddresHeader(String header) {
    	List<HeaderDTO> lstHeaderDTO;
		if (String.isNotBlank(header) && header.contains(HEADER_PARAMS)) {
			lstHeaderDTO = (List<HeaderDTO>) JSON.deserialize(header, List<HeaderDTO>.class);
		}
		Map<String, String> mheaderInfo = new Map<String, String> ();
		string emailHeader = '';
		if (lstHeaderDTO != null && lstHeaderDTO.size() > 0) {
			for (HeaderDTO hdto : lstHeaderDTO) {
				if (!mheaderInfo.containsKey(hdto.name)) {
					mheaderInfo.put(hdto.name, hdto.value);
				}
			}
			emailHeader = mheaderInfo.get(HEADER_PARAMS);
		}
		return emailHeader;
	}

	public static Map<Id,EmailMessage> generateMap(List<EmailMessage> lstEmail, CC_TriggerParameters.TriggerEvent eventype) {
		Map<Id,EmailMessage> mEmailMessage =  new Map<Id,EmailMessage>();
		if(lstEmail != null && lstEmail.size() > 0){
			if (string.valueOf(eventype) =='afterInsert' || string.valueOf(eventype) =='beforeDelete' || string.valueOf(eventype) =='afterDelete' || string.valueOf(eventype) =='beforeUpdate' || string.valueOf(eventype) =='afterUpdate'){
				for(EmailMessage em : lstEmail){
					mEmailMessage.put(em.Id, em);
				}	
			}else{
				mEmailMessage = null;
			}
		}else{
			mEmailMessage = null;
		}
		return mEmailMessage;
	}

	//Tratar emails por objeto
	//Tratamiento de objetos relacionados
	public static Map<string, Map<String, List<EmailMessage>>> relatedSObjectSegmentation(List<EmailMessage> correos, Map<String, set<String>> configMdtSalida, Map<String, Map<Id, SObject>> sObjectMapsBySObjectType ){
		String sObjName;
		String rt;
		Map<String, Map<String, List<EmailMessage>>> mSobjectInfo = new Map<String, Map<String, List<EmailMessage>>>();

		for (EmailMessage cs : correos){
			List<EmailMessage> lstem = new List<EmailMessage>();
		//Inicializar la información con ParentId
			if (String.isNotBlank(cs.ParentId)) {
				sObjName = cs.ParentId.getSObjectType().getDescribe().getName();
				if(checkRTExistsSet.contains(sObjName)){
					Id rtId = (Id) sObjectMapsBySObjectType.get(sObjName).get(cs.ParentId).get('RecordtypeId');
					rt = mapRTInfo.get(rtId);
					lstem.add(cs);
				}
			}else if(String.isNotBlank(cs.RelatedToId)){
				sObjName = cs.RelatedToId.getSObjectType().getDescribe().getName();
				if(checkRTExistsSet.contains(sObjName)){
					Id rtId = (Id) sObjectMapsBySObjectType.get(sObjName).get(cs.RelatedToId).get('RecordtypeId');
					rt = mapRTInfo.get(rtId);
					lstem.add(cs);
				}
			}

			//En su defecto inicializar la información con RelatedId
			if(configMdtSalida != null && (!configMdtSalida.containsKey(sObjName) || !configMdtSalida.get(sObjName).contains(rt))){
				sObjName = 'Otros';
				rt = 'Otros';
			}
			
			if (!mSobjectInfo.containsKey(sObjName)) {
				mSobjectInfo.put(sObjName, new Map<String, List<EmailMessage>>());
				mSobjectInfo.get(sObjName).put(rt,lstem);
			}else{
				if (mSobjectInfo.containsKey(sObjName) && !mSobjectInfo.get(sObjName).containsKey(rt)) {
					mSobjectInfo.get(sObjName).put(rt,lstem);
				}else if(mSobjectInfo.containsKey(sObjName) && mSobjectInfo.get(sObjName).containsKey(rt)){
					mSobjectInfo.get(sObjName).get(rt).addAll(lstem);
				}
			}
		}
		return mSobjectInfo;
	}

	public static List<String> getEmailToCaseinfo(){
		List<String> emails = new List<String>();
		List<EmailServicesAddress> lstEmailCase = [SELECT Id,LocalPart,  EmailDomainName,Function.FunctionName,DeveloperName FROM EmailServicesAddress where Function.FunctionName = 'EmailToCase'];	
		if(!lstEmailCase.isEmpty()){
			for(EmailServicesAddress ems : lstEmailCase){
				emails.add(ems.localPart + '@' + ems.EmailDomainName);
			}
		}
		return emails;
	}

	public static List<SObject> generateOldList(List<SObject> newList, Map<Id,EmailMessage> mapaCorreosOld){
		List<SObject> lstOld = new List<SObject>();
		Id mId;
		for(SObject so : newList){
			mId = string.valueOf(so.get('Id'));
			if(mapaCorreosOld.containsKey(mId)){
				lstOld.add(mapaCorreosOld.get(mId));
			}
		}
		return lstOld;
	}
	
	public class HeaderDTO {
		public string value { get; set; }
		public string name { get; set; }

	}
}