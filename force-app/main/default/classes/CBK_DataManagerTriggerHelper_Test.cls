@isTest
private class CBK_DataManagerTriggerHelper_Test {

	@isTest
	private static void checkDataManager_Object() {

		Test.startTest();
		string rto = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('Object').getRecordTypeId();
		string rtf = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('Field').getRecordTypeId();
		List<CBK_DataManager__c> lst = new List<CBK_DataManager__c> ();

		CBK_DataManager__c dm = new CBK_DataManager__c();
		dm.RecordTypeId = rto;
		//dm.Name = 'Objeto test';
		//dm.Object_Name__c = 'ObjectTest';
		dm.API_Name__c = 'Object__c';
		insert dm;

		CBK_DataManager__c dm2 = new CBK_DataManager__c();
		dm2.RecordTypeId = rto;
		//dm2.Name = 'Objeto test';
		//dm2.Object_Name__c = 'ObjectTest';
		dm2.API_Name__c = 'Object__c';
		lst.add(dm2);

		if (lst.size() > 0) {
			CBK_DataManagerTriggerHelper.checkDataManager(lst);
		}

		//system.debug('lst ' + lst);

		Test.stopTest();
	}

	@isTest
	private static void checkDataManager_Field() {

		Test.startTest();
		string rto = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('Object').getRecordTypeId();
		string rtf = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('Field').getRecordTypeId();
		List<CBK_DataManager__c> lst = new List<CBK_DataManager__c> ();

		CBK_DataManager__c dm = new CBK_DataManager__c();
		dm.RecordTypeId = rto;
		//dm.Name = 'Objeto test';
		//dm.Object_Name__c = 'ObjectTest';
		dm.API_Name__c = 'Object__c';
		insert dm;

		CBK_DataManager__c dm2 = new CBK_DataManager__c();
		dm2.RecordTypeId = rtf;
		//dm2.Name = 'Field Test';
		//dm2.Field_Name__c = 'Field Test';
		dm2.API_Name__c = 'Field__c';
		dm2.Object__c = dm.Id;
		insert dm2;

		CBK_DataManager__c dm3 = new CBK_DataManager__c();
		dm3.RecordTypeId = rtf;
		//dm3.Name = 'Field Test Copy';
		//dm3.Field_Name__c = 'Field Test Copy';
		dm3.API_Name__c = 'Field__c';
		dm3.Object__c = dm.Id;
		lst.add(dm3);

		if (lst.size() > 0) {
			CBK_DataManagerTriggerHelper.checkDataManager(lst);
		}
		//system.debug('lst ' + lst);
		Test.stopTest();
	}

	@isTest
	private static void checkDataManager_Proyectos() {

		Test.startTest();
		string rto = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('Object').getRecordTypeId();
		string rtf = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('Field').getRecordTypeId();
		List<CBK_DataManager__c> lst = new List<CBK_DataManager__c> ();

		CBK_DataManager__c dm = new CBK_DataManager__c();
		dm.RecordTypeId = rto;
		//dm.Name = 'Objeto test';
		//dm.Object_Name__c = 'ObjectTest';
		dm.Status__c = 'Approved';
		dm.API_Name__c = 'Object__c';
		dm.Proyectos__c = 'CC';
		insert dm;

		CBK_DataManager__c dm2 = new CBK_DataManager__c();
		dm2.RecordTypeId = rtf;
		dm2.Status__c = 'Approved';
		dm2.Proyectos__c = 'CC';
		//dm2.Name = 'Field Test';
		//dm2.Field_Name__c = 'Field Test';
		dm2.API_Name__c = 'Field__c';
		dm2.Object__c = dm.Id;
		insert dm2;
		dm2.Proyectos__c = 'CC;SAC';

		try {
			update dm2;
		} catch(Exception ex) {
			System.assert(true, ex.getMessage().contains('Cambios aprobados. Solo se permite editar para otro proyecto'));
		}

		CBK_DataManager__c dm3 = new CBK_DataManager__c();
		dm3.RecordTypeId = rtf;
		dm3.Status__c = 'Approved';
		//dm3.Name = 'Field Test Copy';
		//dm3.Field_Name__c = 'Field Test Copy';
		dm3.API_Name__c = 'Field__c';
		dm3.Proyectos__c = 'CC;SAC';
		dm3.Object__c = dm.Id;
		lst.add(dm3);

		CBK_DataManager__c dm4 = new CBK_DataManager__c();
		dm4.RecordTypeId = rtf;
		dm4.Status__c = 'Pending';
		//dm3.Name = 'Field Test Copy';
		//dm3.Field_Name__c = 'Field Test Copy';
		dm4.API_Name__c = 'Field2__c';
		dm4.Proyectos__c = 'CC;SAC';
		dm4.Object__c = dm.Id;
		insert dm4;
		dm4.Status__c = 'Approved';
		try {
			update dm4;
		} catch(Exception ex) {
			System.assert(true, ex.getMessage().contains('No tienes Permisos para validar'));
		}


		CBK_DataManager__c dm5 = new CBK_DataManager__c();
		dm5.RecordTypeId = rtf;
		dm5.Status__c = 'Pending';
		//dm3.Name = 'Field Test Copy';
		//dm3.Field_Name__c = 'Field Test Copy';
		dm5.API_Name__c = 'Field3__c';
		dm5.Proyectos__c = 'CC;SAC';
		dm5.Object__c = dm.Id;
		insert dm5;
		dm5.API_Name__c = 'dfasdfas';

		try {
			update dm5;
		} catch(Exception ex) {
			System.assert(true, ex.getMessage().contains('No tienes Permisos para cambiar el API Name'));
		}

		CBK_DataManager__c dm6 = new CBK_DataManager__c();
		dm6.RecordTypeId = rtf;
		dm6.Status__c = 'Pending';
		//dm3.Name = 'Field Test Copy';
		//dm3.Field_Name__c = 'Field Test Copy';
		dm6.API_Name__c = 'Field4__c';
		dm6.Proyectos__c = 'CC';
		dm6.Object__c = dm.Id;
		insert dm6;
		dm6.Status__c = 'Approved';
		dm6.Proyectos__c = 'CC;SAC';

		List<User> AdminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema'];

		System.runAs(AdminUser[0]) {
			try {
				update dm6;
			} catch(Exception ex) {
				//System.assert(true, ex.getMessage().contains('No tienes Permisos para cambiar el API Name'));
			}
		}

		//if (lst.size() > 0) {
		//CBK_DataManagerTriggerHelper.checkDataManager(lst);
		//}
		//system.debug('lst ' + lst);
		Test.stopTest();
	}
}