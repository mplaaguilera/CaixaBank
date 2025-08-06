public with sharing class CBK_DataManagerTriggerHelper {
	static String ERR_MSG = 'El valor esta duplicado : ';
	static String OBJECT_RT_ID = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('Object').getRecordTypeId();
	static String FIELD_RT_ID = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('Field').getRecordTypeId();

	public static void checkDataManager(List<CBK_DataManager__c> lstDataManager) {
		//system.debug('OBJECT_RT_ID ' + OBJECT_RT_ID);
		//system.debug('FIELD_RT_ID ' + FIELD_RT_ID);
		//system.debug('lstDataManager ' + lstDataManager);

		Set<String> fieldSet = new Set<String> ();
		Set<String> objectSet = new Set<String> ();

		id duplicateId = null;

		String query = ' SELECT Id, Object_Name__c, API_Name__c,Field_Name__c, RecordTypeId  ' +
		' FROM CBK_DataManager__c';

		for (CBK_DataManager__c m : lstDataManager) {

			if (m.RecordTypeId == OBJECT_RT_ID)
			m.Object__c = null;

			if (m.RecordTypeId == OBJECT_RT_ID) {
				objectSet.add(m.API_Name__c);

				query += ' WHERE RecordTypeId = ' + '\'' + OBJECT_RT_ID + '\'' + ' AND API_Name__c IN (';

				for (String oIdName : objectSet) {
					query += '\'' + oIdName + '\',';
				}
				query = query.left((query.length() - 1)) + ')';

			}
			else if (m.RecordTypeId == FIELD_RT_ID) {
				fieldSet.add(m.API_Name__c);
				query += ' WHERE RecordTypeId = ' + '\'' + FIELD_RT_ID + '\'' + 'AND Object__c =  ' + '\'' + m.Object__c + '\'' + ' AND API_Name__c IN (';

				for (String fIdName : fieldSet) {
					query += '\'' + fIdName + '\',';
				}
				query = query.left((query.length() - 1)) + ')';

			}
		}
		System.debug('QUERY: ' + query);
		List<CBK_DataManager__c> lstData = (List<CBK_DataManager__c>) Database.query(query);
		Map<String, Id> duplicatedMap = new Map<String, Id> ();
		if (lstData.size() > 0) {
			for (CBK_DataManager__c m : lstData) {

				if (m.RecordTypeId == FIELD_RT_ID) {
					duplicatedMap.put(m.API_Name__c, m.Id);
				}
				else if (m.RecordTypeId == OBJECT_RT_ID) {
					duplicatedMap.put(m.API_Name__c, m.Id);
				}
			}
		}

		for (CBK_DataManager__c m : lstDataManager) {

			if (m.RecordTypeId == FIELD_RT_ID)
			duplicateId = duplicatedMap.get(m.API_Name__c);
			else if (m.RecordTypeId == OBJECT_RT_ID)
			duplicateId = duplicatedMap.get(m.API_Name__c);

			if (duplicateId != null)
			m.addError(ERR_MSG + duplicateId + ' (' + m.API_Name__c + ')');
		}

	}
	public static void checkDataManagerApp(List<CBK_DataManager__c> listOldObj, List<CBK_DataManager__c> listNewObj) {

		Map<String, CBK_DataManager__c> mOld = new Map<String, CBK_DataManager__c> ();
		Map<String, CBK_DataManager__c> mNew = new Map<String, CBK_DataManager__c> ();

		for (CBK_DataManager__c lst : listOldObj) {

			if (!mOld.containsKey(lst.API_Name__c)) {
				mOld.put(lst.API_Name__c, lst);
			}
		}

		for (CBK_DataManager__c lst : listNewObj) {

			if (!mNew.containsKey(lst.API_Name__c)) {
				mNew.put(lst.API_Name__c, lst);
			}
		}
		CBK_DataManager__c objOld = new CBK_DataManager__c();
		Boolean hasCustomPermission = FeatureManagement.checkPermission('CBK_OT');
		System.debug('mnew ' + mNew);
		for (CBK_DataManager__c lst : mNew.values()) {
			objOld = mOld.get(lst.API_Name__c);
			if (!hasCustomPermission ){
				if (objOld == null){
					if (lst.Status__c == 'Approved') lst.addError('No tienes Permisos para cambiar el API Name');
				}
				else if (objOld.Name != lst.Name) {
					lst.addError('No tienes Permisos para cambiar el Name');
				}
				else if (objOld.Status__c != lst.Status__c && lst.Status__c == 'Approved'){
					lst.addError('No tienes Permisos para validar');
				}
				else if (lst.Status__c == 'Approved' && objOld.Proyectos__c == lst.Proyectos__c){
					lst.addError('Cambios aprobados. Solo se permite editar para otro proyecto');
				}
				else if (mOld.containsKey(lst.API_Name__c) && lst.Status__c == 'Approved' && objOld.Proyectos__c <> lst.Proyectos__c) {
					lst.Status__c = 'Pending';
				}
				
			}
			else if (mOld.containsKey(lst.API_Name__c) && lst.Status__c == 'Approved' && objOld.Proyectos__c <> lst.Proyectos__c) {
				lst.Status__c = 'Pending';
			//	lst.cambios = lst.cambios + ' \n' + 'dfasdfasdfa';
			}
		}

	}
}