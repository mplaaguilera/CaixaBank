@isTest
public class CBK_copado_User_Story_BU_TRHan_Test {

	@testSetup static void setup() {
		copado__Environment__c env = new copado__Environment__c();
		env.CBK_Validacion_OT__c = true;
		insert env;

		copado__User_Story__c us = New copado__User_Story__c();
		us.copado__Environment__c = env.Id;
		us.copado__User_Story_Title__c = 'TEST CBK_copado_User_Story_BU_TRHan_Test';
		insert us;


		copado__User_Story_Metadata__c mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Contact.Id';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Contact.XXXX';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Contact.Noexist';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Activity.XXXX';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Others.XXXX';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'Others.XXXX';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;
	}

	@isTest
	public static void test1() {
		Id idRTObject = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Object').getRecordTypeId();
		Id idRTField = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Field').getRecordTypeId();

		CBK_DataManager__c dmObj = new CBK_DataManager__c();
		
		dmObj.API_Name__c = 'Contact';
		dmObj.RecordTypeId = idRTObject;
		dmObj.Check_By_OT__c = true;
		dmObj.Status__c = 'Approved';
		insert dmObj;

		CBK_DataManager__c dmField = new CBK_DataManager__c();
		List<CBK_DataManager__c> lstdmField = new List<CBK_DataManager__c>();
		dmField.API_Name__c = 'Id';
		dmField.RecordTypeId = idRTField;
		dmField.Status__c = 'Approved';
		dmField.Object__c = dmObj.Id;
		lstdmField.add(dmField);
		insert lstdmField;

		test.startTest();

		copado__User_Story__c us = [Select Id, copado__User_Story_Title__c from copado__User_Story__c where copado__User_Story_Title__c = 'TEST CBK_copado_User_Story_BU_TRHan_Test' LIMIT 1];
		us.copado__User_Story_Title__c = '1223456789';
		us.copado__Promote_Change__c = true;
	
		try {
			upsert us;
		}
		catch(Exception e) {
			Boolean expectedExceptionThrown = (e.getMessage().contains('Contact.XXXX')) ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
			 expectedExceptionThrown = (e.getMessage().contains('Contact.XXXX')) ? true : false;
		}

		test.stopTest();
	}
	

	@isTest
	public static void test2() {
		copado__Environment__c env = new copado__Environment__c();
		env.CBK_Validacion_OT__c = true;
		insert env;

		copado__User_Story__c us = New copado__User_Story__c();
		us.copado__Environment__c = env.Id;
		us.copado__User_Story_Title__c = 'TEST Class';
		insert us;

		copado__User_Story_Metadata__c mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'ApexClass.CBK_TEST';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'ApexClass.CC_TRDisp';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;


		test.startTest();

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {

			copado__User_Story__c us2 = [Select Id, copado__User_Story_Title__c from copado__User_Story__c where copado__User_Story_Title__c = 'TEST Class' LIMIT 1];
			us2.copado__User_Story_Title__c = 'Apex test';
			us2.copado__Promote_Change__c = true;
			try {
				update us2;
			}
			catch(Exception e) {
				Boolean expectedExceptionThrown = (e.getMessage().contains('ApexClass.CBK')) ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
			}
		}
		test.stopTest();

	}


	@isTest
	public static void test3() {
		copado__Environment__c env = new copado__Environment__c();
		env.CBK_Validacion_OT__c = true;
		insert env;

		copado__User_Story__c us = New copado__User_Story__c();
		us.copado__Environment__c = env.Id;
		us.copado__User_Story_Title__c = 'TEST Class';
		insert us;

		

		copado__User_Story_Metadata__c mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Contact.XXXX';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		 mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'ApexTrigger.CC_Test';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		test.startTest();

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {

			copado__User_Story__c us2 = [Select Id, copado__User_Story_Title__c from copado__User_Story__c where copado__User_Story_Title__c = 'TEST Class' LIMIT 1];
			us2.copado__User_Story_Title__c = 'Apex test';
			us2.copado__Promote_Change__c = true;

			try {
				update us2;
			}
			catch(Exception e) {
				Boolean expectedExceptionThrown = (e.getMessage().contains('ApexTrigger')) ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
			}
		}
		test.stopTest();

	}

	@isTest
	public static void test4() {
		copado__Environment__c env = new copado__Environment__c();
		env.CBK_Validacion_OT__c = true;
		insert env;

		copado__User_Story__c us = New copado__User_Story__c();
		us.copado__Environment__c = env.Id;
		us.copado__User_Story_Title__c = 'TEST Flows';
		insert us;

		copado__User_Story_Metadata__c mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'Flow.CBK_TEST_PB';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		copado__User_Story_Metadata__c mtd2 = New copado__User_Story_Metadata__c();
		mtd2.copado__Metadata_API_Name__c = 'FlowDefinition.CBK_TEST_PB';
		mtd2.copado__User_Story__c = us.Id;
		insert mtd2;

		test.startTest();

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {

			copado__User_Story__c us2 = [Select Id, copado__User_Story_Title__c from copado__User_Story__c where copado__User_Story_Title__c = 'TEST Flows' LIMIT 1];
			us2.copado__User_Story_Title__c = 'Flow test';
			us2.copado__Promote_Change__c = true;
			try {
				update us2;
			}
			catch(Exception e) {
				System.debug('exception Flow: ' + e);
				Boolean expectedExceptionThrown = (e.getMessage().contains('Flow.CBK')) ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
			}
		}
		test.stopTest();
	}

	@isTest
	public static void test5() {
		Id idRTObject = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Object').getRecordTypeId();
		Id idRTField = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Field').getRecordTypeId();

		CBK_DataManager__c dmObj = new CBK_DataManager__c();
		dmObj.API_Name__c = 'Contact';
		dmObj.RecordTypeId = idRTObject;
		dmObj.Check_By_OT__c = true;
		dmObj.Status__c = 'Approved';
		insert dmObj;

		CBK_DataManager__c dmField = new CBK_DataManager__c();
		List<CBK_DataManager__c> lstdmField = new List<CBK_DataManager__c>();
		dmField = new CBK_DataManager__c();
		dmField.API_Name__c = 'XXXX';
		dmField.RecordTypeId = idRTField;
		dmField.Status__c = 'Draft';
		dmField.Object__c = dmObj.Id;
		lstdmField.add(dmField);
		insert lstdmField;

		dmField = new CBK_DataManager__c();
		dmField.API_Name__c = 'Id';
		dmField.RecordTypeId = idRTField;
		dmField.Status__c = 'Approved';
		dmField.Object__c = dmObj.Id;
		insert dmField;

		test.startTest();

		copado__User_Story__c us = [Select Id,copado__Environment__c, copado__User_Story_Title__c from copado__User_Story__c where copado__User_Story_Title__c = 'TEST CBK_copado_User_Story_BU_TRHan_Test' LIMIT 1];
		us.copado__Promote_Change__c = true;

		try {
			update us;
		}
		catch(Exception e) {
			system.debug('Exception: ' + e.getMessage());
			Boolean expectedExceptionThrown = (e.getMessage().contains('Contact.XXXX')) ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
		}
		test.stopTest();
	}	

	@isTest
	public static void test6() {
		copado__Environment__c env = new copado__Environment__c();
		env.CBK_Validacion_OT__c = true;
		insert env;

		copado__User_Story__c us = New copado__User_Story__c();
		us.copado__Environment__c = env.Id;
		us.copado__Promote_Change__c = false;
		us.copado__User_Story_Title__c = 'TEST OT';
		insert us;

		copado__User_Story_Metadata__c mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'RecordType.object.CBK_TEST';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		Id rt1 = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Object').getRecordTypeId();
        CBK_DataManager__c objDM1 = new CBK_DataManager__c();
        objDM1.RecordTypeId = rt1;
        objDM1.Object_Name__c = 'object';
		objDM1.API_Name__c = 'object';
        objDM1.Name = 'object';
        objDM1.Check_By_OT__c  = true;
        insert objDM1;

		Id rt2 = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('RecordType').getRecordTypeId();
        CBK_DataManager__c objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt2;
		objDM.Object__c  = objDM1.Id;
		objDM.API_Name__c = 'CBK_TEST';
        objDM.RecordTypeName__c = 'CBK_TEST';
        objDM.Check_By_OT__c  = true;
		objDM.Status__c = 'Pending';
        insert objDM;
	
		test.startTest();
		List<copado__User_Story__c> uscopado = [Select Id,copado__Promote_Change__c,copado__Environment__c, copado__User_Story_Title__c from copado__User_Story__c where Id =: us.Id LIMIT 1];
		uscopado[0].copado__Promote_Change__c = true;
		
		try {
			update uscopado;
		}
		catch(Exception e) {
			Boolean expectedExceptionThrown = (e.getMessage().contains('RecordType.object.CBK_TEST')) ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
		}
		test.stopTest();
	}

	@isTest
	public static void test7() {

		copado__Deployment_Flow__c flow = new copado__Deployment_Flow__c();
		flow.Name = 'CaixaBankcc';
		insert flow;

		copado__Environment__c env = new copado__Environment__c();
		env.CBK_Validacion_OT__c = true;
		env.CBK_CheckControlIps__c = true;
    	env.Name = 'STAGINGINT';
		insert env;

		copado__Environment__c sourceenv = new copado__Environment__c();
		sourceenv.CBK_Validacion_OT__c = true;
		sourceenv.CBK_CheckControlIps__c = true;
    	sourceenv.Name = 'INTOT';
		insert sourceenv;

		copado__Deployment_Flow_Step__c flowStep =  new copado__Deployment_Flow_Step__c();
		flowStep.copado__Source_Environment__c = sourceenv.Id;
		flowStep.copado__Destination_Environment__c = env.Id;
		flowStep.copado__Deployment_Flow__c  = flow.Id;
		insert flowStep;

		copado__Project__c project =  new copado__Project__c();
		project.Name = 'Oficina Técnica';
		project.copado__Deployment_Flow__c = flow.Id;
		insert project;

		copado__User_Story__c us = New copado__User_Story__c();
		us.copado__Environment__c = sourceenv.Id;
		us.copado__Promote_Change__c = false;
		us.copado__User_Story_Title__c = 'TEST OT';
		us.CBK_HasConflictIp__c = false;
		us.copado__Project__c = project.Id;
		insert us;

		copado__User_Story_Metadata__c mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'Profile.API Only';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;
		
		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'Profile.OS_Usuario_CaixaBank';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'Profile.Admin Bulk API Hard Delete';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'Profile.AV_Usuario_CaixaBank';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'Profile.API Only - MasVoz';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'Profile.OT_Usuario_CaixaBank';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		Id  rt1 = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Profile').getRecordTypeId();
        CBK_DataManager__c objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt1;
        objDM.ProfileName__c = 'API Only';
        objDM.Name = 'API Only';
        objDM.Check_By_OT__c  = true;
        insert objDM;

		objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt1;
        objDM.ProfileName__c = 'OS_Usuario_CaixaBank';
        objDM.Name = 'OS_Usuario_CaixaBank';
        objDM.Check_By_OT__c  = true;
        insert objDM;

		objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt1;
        objDM.ProfileName__c = 'Admin Bulk API Hard Delet';
        objDM.Name = 'Admin Bulk API Hard Delet';
        objDM.Check_By_OT__c  = true;
        insert objDM;

		objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt1;
        objDM.ProfileName__c = 'API Only - MasVoz';
        objDM.Name = 'API Only - MasVoz';
        objDM.Check_By_OT__c  = true;
        insert objDM;

		objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt1;
        objDM.ProfileName__c = 'AV_Usuario_CaixaBank';
        objDM.Name = 'AAV_Usuario_CaixaBank';
        objDM.Check_By_OT__c  = true;
        insert objDM;

		objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt1;
        objDM.ProfileName__c = 'OT_Usuario_CaixaBank';
        objDM.Name = 'OT_Usuario_CaixaBank';
        objDM.Check_By_OT__c  = true;
        insert objDM;


		test.startTest();
		List<copado__User_Story__c> uscopado = [Select Id,copado__Promote_Change__c,copado__Environment__c, copado__User_Story_Title__c from copado__User_Story__c where Id =: us.Id LIMIT 1];
		uscopado[0].copado__Promote_Change__c = true;
		update uscopado;

		uscopado = [Select Id,copado__Promote_Change__c,copado__Environment__c, copado__User_Story_Title__c from copado__User_Story__c where Id =: us.Id LIMIT 1];
		System.AssertEquals(uscopado[0].copado__Promote_Change__c, true);

		test.stopTest();
	}
}