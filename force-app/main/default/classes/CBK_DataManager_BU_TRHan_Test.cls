@isTest 
private class CBK_DataManager_BU_TRHan_Test {

	@isTest
	private static void handlerTest() {
		string rto = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('Object').getRecordTypeId();
		string rtf = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('Field').getRecordTypeId();
		createObject();

		CBK_DataManager__c dmObj = new CBK_DataManager__c();
		dmObj.RecordTypeId = rto;
		//dmObj.Name = 'Objeto test';
		//dmObj.Object_Name__c = 'ObjectTest';
		dmObj.API_Name__c = 'Object__c';

		try{
			insert dmObj;
		}catch(Exception e){	
			System.assert(true, e.getMessage().contains('duplicado'));
		}
        Test.startTest();
        List<CBK_DataManager__c> dmObjs = [SELECT Id, Description__c FROM CBK_DataManager__c WHERE RecordTypeId = :rto];
        if (dmObjs.size() > 0) {
            dmObjs[0].Description__c = 'Objecttt__c';
            update dmObjs[0];
        }
		Test.stopTest();
	}

	private static void createObject() {

		string rto = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('Object').getRecordTypeId();
		string rtf = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('Field').getRecordTypeId();
		string rtype = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByName().get('RecordType').getRecordTypeId();
		List<CBK_DataManager__c> lst = new List<CBK_DataManager__c> ();
		CBK_DataManager__c dmObj = new CBK_DataManager__c();
		dmObj.RecordTypeId = rto;
		//dmObj.Name = 'Objeto test';
		//dmObj.Object_Name__c = 'ObjectTest';
		dmObj.API_Name__c = 'Object__c';
		insert dmObj;

		CBK_DataManager__c dmFld = new CBK_DataManager__c();
		dmFld.RecordTypeId = rtf;
		//dmFld.Name = 'Field Test';
		//dmFld.Field_Name__c = 'Field Test';
		dmFld.API_Name__c = 'Field__c';
		dmFld.Object__c = dmObj.Id;
		insert dmFld;

		CBK_DataManager__c dmObjRT = new CBK_DataManager__c();
		dmObjRT.Object__c = dmObj.Id;
		dmObjRT.RecordTypes__c = dmObj.Id;
		dmObjRT.RecordTypeId = Id.valueOf(rtype);
		dmObjRT.RecordTypeName__c = 'TEST';
		dmObjRT.Name = 'Test';
		dmObjRT.Status__c = 'Approved';
		dmObjRT.Proyectos__c = 'CC';
		insert dmObjRT;
	}
}