@isTest
public class CBK_copado_User_Story_BU_TRHan_Test {

	@testSetup static void setup() {

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Sistemática Comercial'];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User thisUser = new User(alias = 'user2', email='testSEGBI2@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                Username = uniqueName + '@test' + orgId + '.org');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('CBK_COPADO')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }

		copado__Environment__c env = new copado__Environment__c();
		env.CBK_Validacion_OT__c = true;
		insert env;

		copado__Project__c proyecto = new copado__Project__c();
		proyecto.Name = 'Otros';
		insert proyecto;

		copado__Release__c release = new copado__Release__c();
		release.copado__Status__c = 'Planned';
		release.CBK_Fecha_de_Inicio__c = Datetime.now();
		release.CBK_Fecha_de_Cierre__c = Datetime.now().addDays(1);
		release.Name = 'TEST RELEASE';
		insert release;

		copado__User_Story__c us = New copado__User_Story__c();
		us.copado__Environment__c = env.Id;
		us.copado__User_Story_Title__c = 'TEST CBK_copado_User_Story_BU_TRHan_Test';
		us.copado__Release__c = release.Id;
		insert us;

		copado__User_Story__c us2 = New copado__User_Story__c();
		us2.copado__Environment__c = env.Id;
		us2.copado__User_Story_Title__c = 'TEST CustomSetting';
		us2.copado__Project__c = proyecto.Id;
		us2.copado__Release__c = release.Id;
		insert us2;

		List<copado__User_Story_Metadata__c> lstUserStory = new List<copado__User_Story_Metadata__c>();
		copado__User_Story_Metadata__c mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Contact.Id';
		mtd.copado__User_Story__c = us.Id;
		lstUserStory.add(mtd);

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Contact.XXXX';
		mtd.copado__User_Story__c = us.Id;
		lstUserStory.add(mtd);

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Contact.Noexist';
		mtd.copado__User_Story__c = us.Id;
		lstUserStory.add(mtd);

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Activity.XXXX';
		mtd.copado__User_Story__c = us.Id;
		lstUserStory.add(mtd);

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Others.XXXX';
		mtd.copado__User_Story__c = us.Id;
		lstUserStory.add(mtd);

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'Others.XXXX';
		mtd.copado__User_Story__c = us.Id;
		lstUserStory.add(mtd);

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.CBK_IntegrationSetting__c.CBK_TimeOut__c';
		mtd.copado__User_Story__c = us2.Id;
		lstUserStory.add(mtd);

		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Contact.XXXX';
		mtd.copado__User_Story__c = us2.Id;
		lstUserStory.add(mtd);
		insert lstUserStory;
	}

	@isTest
	public static void test1() {
		Id idRTObject = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Object').getRecordTypeId();
		Id idRTField = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Field').getRecordTypeId();

		CBK_Config__mdt proceso = new CBK_Config__mdt();
		proceso.CBK_Active__c = false;
		CBK_copado_User_Story_BU_TRHan.procesoDatamanagerTest = proceso;

		CBK_DataManager__c dmObj = new CBK_DataManager__c();
		
		dmObj.API_Name__c = 'Contact';
		dmObj.RecordTypeId = idRTObject;
		dmObj.Check_By_OT__c = true;
		dmObj.Status__c = 'Approved';
        dmObj.Description__c = 'Description';
		insert dmObj;

		CBK_DataManager__c dmField = new CBK_DataManager__c();
		List<CBK_DataManager__c> lstdmField = new List<CBK_DataManager__c>();
		dmField.API_Name__c = 'Id';
		dmField.RecordTypeId = idRTField;
		dmField.Status__c = 'Approved';
		dmField.Object__c = dmObj.Id;
        dmField.Description__c = 'Description';
		lstdmField.add(dmField);
		insert lstdmField;

		test.startTest();

		copado__User_Story__c us = [Select Id, copado__User_Story_Title__c from copado__User_Story__c where copado__User_Story_Title__c = 'TEST CBK_copado_User_Story_BU_TRHan_Test' LIMIT 1];
		us.copado__User_Story_Title__c = '1223456789';
		us.copado__Promote_Change__c = true;
	
		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
		
		System.runAs(adminUser[0]) {
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
	}
	

	@isTest
	public static void test2() {

		copado__Release__c release = [SELECT Id FROM copado__Release__c LIMIT 1];
		copado__Environment__c env = new copado__Environment__c();
		env.CBK_Validacion_OT__c = true;
		insert env;

		CBK_Config__mdt proceso = new CBK_Config__mdt();
		proceso.CBK_Active__c = false;
		CBK_copado_User_Story_BU_TRHan.procesoDatamanagerTest = proceso;

		copado__User_Story__c us = New copado__User_Story__c();
		us.copado__Environment__c = env.Id;
		us.copado__User_Story_Title__c = 'TEST Class';
		us.copado__Release__c = release.Id;
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

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
		
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

		CBK_Config__mdt proceso = new CBK_Config__mdt();
		proceso.CBK_Active__c = false;
		CBK_copado_User_Story_BU_TRHan.procesoDatamanagerTest = proceso;

		copado__Release__c release = [SELECT Id FROM copado__Release__c LIMIT 1];
		copado__User_Story__c us = New copado__User_Story__c();
		us.copado__Environment__c = env.Id;
		us.copado__User_Story_Title__c = 'TEST Class';
		us.copado__Release__c = release.Id;
		insert us;

		copado__User_Story_Metadata__c mtd = New copado__User_Story_Metadata__c();
		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'ApexTrigger.CC_Test';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		test.startTest();

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
		
		System.runAs(adminUser[0]) {

			copado__User_Story__c us2 = [Select Id, copado__User_Story_Title__c from copado__User_Story__c where copado__User_Story_Title__c = 'TEST Class' LIMIT 1];
			us2.copado__User_Story_Title__c = 'Apex test';
			us2.copado__Promote_Change__c = true;

			try {
				update us2;
			}
			catch(Exception e) {
				System.debug('e: ' + e);
				Boolean expectedExceptionThrown = (e.getMessage().contains('ApexTrigger')) ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
			}
		}
		test.stopTest();

	}

	@isTest
	public static void test4() {
		copado__Release__c release = [SELECT Id FROM copado__Release__c LIMIT 1];
		copado__Environment__c env = new copado__Environment__c();
		env.CBK_Validacion_OT__c = true;
		insert env;

		CBK_Config__mdt proceso = new CBK_Config__mdt();
		proceso.CBK_Active__c = false;
		CBK_copado_User_Story_BU_TRHan.procesoDatamanagerTest = proceso;

		copado__User_Story__c us = New copado__User_Story__c();
		us.copado__Environment__c = env.Id;
		us.copado__User_Story_Title__c = 'TEST Flows';
		us.copado__Release__c = release.Id;
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

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
		
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

		CBK_Config__mdt proceso = new CBK_Config__mdt();
		proceso.CBK_Active__c = false;
		CBK_copado_User_Story_BU_TRHan.procesoDatamanagerTest = proceso;

		CBK_DataManager__c dmObj = new CBK_DataManager__c();
		dmObj.API_Name__c = 'Contact';
		dmObj.RecordTypeId = idRTObject;
		dmObj.Check_By_OT__c = true;
		dmObj.Status__c = 'Approved';
        dmObj.Description__c = 'Description';
		insert dmObj;

		CBK_DataManager__c dmField = new CBK_DataManager__c();
		List<CBK_DataManager__c> lstdmField = new List<CBK_DataManager__c>();
		dmField = new CBK_DataManager__c();
		dmField.API_Name__c = 'XXXX';
		dmField.RecordTypeId = idRTField;
		dmField.Status__c = 'Draft';
		dmField.Object__c = dmObj.Id;
        dmField.Description__c = 'Description';
		lstdmField.add(dmField);
		insert lstdmField;

		dmField = new CBK_DataManager__c();
		dmField.API_Name__c = 'Id';
		dmField.RecordTypeId = idRTField;
		dmField.Status__c = 'Approved';
		dmField.Object__c = dmObj.Id;
        dmField.Description__c = 'Description';
		insert dmField;

		test.startTest();

		copado__User_Story__c us = [Select Id,copado__Environment__c, copado__User_Story_Title__c from copado__User_Story__c where copado__User_Story_Title__c = 'TEST CBK_copado_User_Story_BU_TRHan_Test' LIMIT 1];
		us.copado__Promote_Change__c = true;

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
		
		System.runAs(adminUser[0]) {

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
	}	

	@isTest
	public static void test6() {

		CBK_Config__mdt proceso = new CBK_Config__mdt();
		proceso.CBK_Active__c = false;
		CBK_copado_User_Story_BU_TRHan.procesoDatamanagerTest = proceso;

		copado__Environment__c env = new copado__Environment__c();
		env.CBK_Validacion_OT__c = true;
		insert env;

		copado__Release__c release = [SELECT Id FROM copado__Release__c LIMIT 1];
		copado__User_Story__c us = New copado__User_Story__c();
		us.copado__Environment__c = env.Id;
		us.copado__Promote_Change__c = false;
		us.copado__User_Story_Title__c = 'TEST OT';
		us.copado__Release__c = release.Id;
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
        objDM1.Description__c = 'Description';
        insert objDM1;

		Id rt2 = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('RecordType').getRecordTypeId();
        CBK_DataManager__c objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt2;
		objDM.Object__c  = objDM1.Id;
		objDM.API_Name__c = 'CBK_TEST';
        objDM.RecordTypeName__c = 'CBK_TEST';
        objDM.Check_By_OT__c  = true;
		objDM.Status__c = 'Pending';
        objDM.Description__c = 'Description';
        insert objDM;
	
		test.startTest();
		List<copado__User_Story__c> uscopado = [Select Id,copado__Promote_Change__c,copado__Environment__c, copado__User_Story_Title__c from copado__User_Story__c where Id =: us.Id LIMIT 1];
		uscopado[0].copado__Promote_Change__c = true;
		
		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
		
		System.runAs(adminUser[0]) {
			try {
				update uscopado;
			}
			catch(Exception e) {
				Boolean expectedExceptionThrown = (e.getMessage().contains('RecordType.object.CBK_TEST')) ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
			}
			test.stopTest();
		}
	}

	@isTest
	public static void test7() {

		CBK_Config__mdt proceso = new CBK_Config__mdt();
		proceso.CBK_Active__c = false;
		CBK_copado_User_Story_BU_TRHan.procesoDatamanagerTest = proceso;

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

		copado__Release__c release = [SELECT Id FROM copado__Release__c LIMIT 1];
		copado__User_Story__c us = New copado__User_Story__c();
		us.copado__Environment__c = sourceenv.Id;
		us.copado__Promote_Change__c = false;
		us.copado__User_Story_Title__c = 'TEST OT';
		us.CBK_HasConflictIp__c = false;
		us.copado__Project__c = project.Id;
		us.copado__Release__c = release.Id;
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
        objDM.Description__c = 'Description';
        insert objDM;

		objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt1;
        objDM.ProfileName__c = 'OS_Usuario_CaixaBank';
        objDM.Name = 'OS_Usuario_CaixaBank';
        objDM.Check_By_OT__c  = true;
        objDM.Description__c = 'Description';
        insert objDM;

		objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt1;
        objDM.ProfileName__c = 'Admin Bulk API Hard Delet';
        objDM.Name = 'Admin Bulk API Hard Delet';
        objDM.Check_By_OT__c  = true;
        objDM.Description__c = 'Description';
        insert objDM;

		objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt1;
        objDM.ProfileName__c = 'API Only - MasVoz';
        objDM.Name = 'API Only - MasVoz';
        objDM.Check_By_OT__c  = true;
        objDM.Description__c = 'Description';
        insert objDM;

		objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt1;
        objDM.ProfileName__c = 'AV_Usuario_CaixaBank';
        objDM.Name = 'AAV_Usuario_CaixaBank';
        objDM.Check_By_OT__c  = true;
        objDM.Description__c = 'Description';
        insert objDM;

		objDM = new CBK_DataManager__c();
        objDM.RecordTypeId = rt1;
        objDM.ProfileName__c = 'OT_Usuario_CaixaBank';
        objDM.Name = 'OT_Usuario_CaixaBank';
        objDM.Check_By_OT__c  = true;
        objDM.Description__c = 'Description';
        insert objDM;

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
		
		System.runAs(adminUser[0]) {

			test.startTest();
			List<copado__User_Story__c> uscopado = [Select Id,copado__Promote_Change__c,copado__Environment__c, copado__User_Story_Title__c from copado__User_Story__c where Id =: us.Id LIMIT 1];
			uscopado[0].copado__Promote_Change__c = true;
			update uscopado;

			uscopado = [Select Id,copado__Promote_Change__c,copado__Environment__c, copado__User_Story_Title__c from copado__User_Story__c where Id =: us.Id LIMIT 1];
			System.AssertEquals(uscopado[0].copado__Promote_Change__c, true);

			test.stopTest();
		}
	}

	@isTest
	public static void test8() {
		Id idRTObject = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Object').getRecordTypeId();
		Id idRTField = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Field').getRecordTypeId();

		CBK_Config__mdt proceso = new CBK_Config__mdt();
		proceso.CBK_Active__c = false;
		CBK_copado_User_Story_BU_TRHan.procesoDatamanagerTest = proceso;

		CBK_DataManager__c dmObj = new CBK_DataManager__c();
		dmObj.API_Name__c = 'Contact';
		dmObj.RecordTypeId = idRTObject;
		dmObj.Check_By_OT__c = true;
		dmObj.Status__c = 'Approved';
        dmObj.Description__c = 'Description';
		insert dmObj;

		CBK_DataManager__c dmField = new CBK_DataManager__c();
		List<CBK_DataManager__c> lstdmField = new List<CBK_DataManager__c>();
		dmField.API_Name__c = 'XXXX';
		dmField.RecordTypeId = idRTField;
		dmField.Status__c = 'Approved';
		dmField.Object__c = dmObj.Id;
        dmField.Description__c = 'Description';
		lstdmField.add(dmField);
		insert lstdmField;
		
		test.startTest();

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

		System.runAs(adminUser[0]) {
			copado__User_Story__c us = [Select Id, copado__User_Story_Title__c from copado__User_Story__c where copado__User_Story_Title__c = 'TEST CustomSetting' LIMIT 1];
			us.copado__User_Story_Title__c = '1223456789';
			us.copado__Promote_Change__c = true;
			upsert us;

			copado__User_Story__c usActualizada = [Select Id, copado__User_Story_Title__c from copado__User_Story__c where copado__User_Story_Title__c = '1223456789' LIMIT 1];
			System.assertNotEquals(null, usActualizada, 'No se ha actualizado la US');
		}

		test.stopTest();
	}

	@isTest
	public static void pruebaDataManagerProyectoError() {

		Id idRTTraspaso = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('CBK_Traspaso').getRecordTypeId();

		copado__User_Story__c us = [SELECT Id, copado__User_Story_Title__c FROM copado__User_Story__c WHERE copado__User_Story_Title__c = 'TEST CustomSetting' LIMIT 1];
		
		copado__User_Story_Metadata__c mtd = new copado__User_Story_Metadata__c();
		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Opportunity.AV_FechaAviso__c';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		CBK_Config__mdt proceso = new CBK_Config__mdt();
		proceso.CBK_Active__c = true;
		CBK_copado_User_Story_BU_TRHan.procesoDatamanagerTest = proceso;

		CBK_DataManager__c dmCustomField = new CBK_DataManager__c();
		dmCustomField.API_Name__c = 'CustomField.Opportunity.AV_FechaAviso__c';
		dmCustomField.Status__c = 'Approved';
		dmCustomField.RecordTypeId = idRTTraspaso;
		dmCustomField.Proyectos__c = 'SEG';
        dmCustomField.Description__c = 'Description';
		insert dmCustomField;

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
		
		System.runAs(adminUser[0]) {
			Test.startTest();
			try {
				us.copado__User_Story_Title__c = '1223456789';
				us.copado__Promote_Change__c = true;
				update us;
			} catch (Exception e) {
				System.assertEquals(true, String.valueOf(e).contains('Objeto no disponible para el Proyecto indicado:'), 'El error indicado no es el correcto.');
			}
			Test.stopTest();
		}
	}

	@isTest
	public static void pruebaDataManagerProyectoCorrecto() {

		Id idRTTraspaso = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('CBK_Traspaso').getRecordTypeId();

		copado__User_Story__c us = [SELECT Id, copado__User_Story_Title__c FROM copado__User_Story__c WHERE copado__User_Story_Title__c = 'TEST CustomSetting' LIMIT 1];
		
		copado__User_Story_Metadata__c mtd = new copado__User_Story_Metadata__c();
		mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Opportunity.AV_FechaAviso__c';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;

		CBK_Config__mdt proceso = new CBK_Config__mdt();
		proceso.CBK_Active__c = true;
		CBK_copado_User_Story_BU_TRHan.procesoDatamanagerTest = proceso;

		CBK_DataManager__c dmCustomField = new CBK_DataManager__c();
		dmCustomField.API_Name__c = 'CustomField.Opportunity.AV_FechaAviso__c';
		dmCustomField.Status__c = 'Approved';
		dmCustomField.RecordTypeId = idRTTraspaso;
		dmCustomField.Proyectos__c = 'Otros';
        dmCustomField.Description__c = 'Description';
		insert dmCustomField;

		CBK_DataManager__c dmCustomField2 = new CBK_DataManager__c();
		dmCustomField2.API_Name__c = 'CustomField.Contact.XXXX';
		dmCustomField2.Status__c = 'Approved';
		dmCustomField2.RecordTypeId = idRTTraspaso;
		dmCustomField2.Proyectos__c = 'Otros';
        dmCustomField2.Description__c = 'Description';
		insert dmCustomField2;

		CBK_DataManager__c dmCustomField3 = new CBK_DataManager__c();
		dmCustomField3.API_Name__c = 'CustomField.CBK_IntegrationSetting__c.CBK_TimeOut__c';
		dmCustomField3.Status__c = 'Approved';
		dmCustomField3.RecordTypeId = idRTTraspaso;
		dmCustomField3.Proyectos__c = 'Otros';
        dmCustomField3.Description__c = 'Description';
		insert dmCustomField3;

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
		
		System.runAs(adminUser[0]) {
			Test.startTest();
			try {
				us.copado__User_Story_Title__c = '1223456789';
				us.copado__Promote_Change__c = true;
				Database.SaveResult sr = database.update(us); 
				System.assertEquals(true, sr.isSuccess(), 'No se ha actualizado la US');
			} catch (Exception e) {
				System.assertEquals(false, String.valueOf(e).contains('Update failed'), 'El error indicado no es el correcto.');
			}
			Test.stopTest();
		}
	}

	@isTest
	public static void pruebaDataManagerAprobacionError() {

		Id idRTTraspaso = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('CBK_Traspaso').getRecordTypeId();

		CBK_Config__mdt proceso = new CBK_Config__mdt();
		proceso.CBK_Active__c = true;
		CBK_copado_User_Story_BU_TRHan.procesoDatamanagerTest = proceso;

		CBK_DataManager__c dmCustomField = new CBK_DataManager__c();
		dmCustomField.API_Name__c = 'CustomField.Opportunity.AV_FechaAviso__c';
		dmCustomField.Status__c = 'Draft';
		dmCustomField.RecordTypeId = idRTTraspaso;
		dmCustomField.Proyectos__c = 'Otros';
        dmCustomField.Description__c = 'Description';
		insert dmCustomField;

		CBK_DataManager__c dmCustomField2 = new CBK_DataManager__c();
		dmCustomField2.API_Name__c = 'CustomField.Contact.XXXX';
		dmCustomField2.Status__c = 'Draft';
		dmCustomField2.RecordTypeId = idRTTraspaso;
		dmCustomField2.Proyectos__c = 'Otros';
        dmCustomField2.Description__c = 'Description';
		insert dmCustomField2;

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
		
		System.runAs(adminUser[0]) {
			Test.startTest();
			try {
				copado__User_Story__c us = [SELECT Id, copado__User_Story_Title__c FROM copado__User_Story__c WHERE copado__User_Story_Title__c = 'TEST CustomSetting' LIMIT 1];
				us.copado__User_Story_Title__c = '1223456789';
				us.copado__Promote_Change__c = true;
				update us;
			} catch (Exception e) {
				System.assertEquals(true, String.valueOf(e).contains('Objetos no aprobado por la OT:'), 'El error indicado no es el correcto.');
			}
			Test.stopTest();
		}
	}

	@isTest
	public static void pruebaDataManagerRestriccionError() {

		Id idRTTraspaso = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('CBK_Traspaso').getRecordTypeId();

		CBK_Config__mdt proceso = new CBK_Config__mdt();
		proceso.CBK_Active__c = true;
		CBK_copado_User_Story_BU_TRHan.procesoDatamanagerTest = proceso;

		copado__User_Story__c us2 = [SELECT Id, copado__User_Story_Title__c FROM copado__User_Story__c WHERE copado__User_Story_Title__c = 'TEST CustomSetting' LIMIT 1];
		copado__User_Story_Metadata__c mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'ApexClass.CBK_Prueba';
		mtd.copado__User_Story__c = us2.Id;
		insert mtd;

		CBK_DataManager__c dmCustomField = new CBK_DataManager__c();
		dmCustomField.API_Name__c = 'ApexClass.CBK_Prueba';
		dmCustomField.RecordTypeId = idRTTraspaso;
        dmCustomField.Description__c = 'Description';
		insert dmCustomField;

		CBK_DataManager__c dmCustomField2 = new CBK_DataManager__c();
		dmCustomField2.API_Name__c = 'CustomField.Contact.XXXX';
		dmCustomField2.Status__c = 'Approved';
		dmCustomField2.RecordTypeId = idRTTraspaso;
		dmCustomField2.Proyectos__c = 'Otros';
        dmCustomField2.Description__c = 'Description';
		insert dmCustomField2;

		CBK_DataManager__c dmCustomField3 = new CBK_DataManager__c();
		dmCustomField3.API_Name__c = 'CustomField.CBK_IntegrationSetting__c.CBK_TimeOut__c';
		dmCustomField3.Status__c = 'Approved';
		dmCustomField3.RecordTypeId = idRTTraspaso;
		dmCustomField3.Proyectos__c = 'Otros';
        dmCustomField3.Description__c = 'Description';
		insert dmCustomField3;

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
		
		System.runAs(adminUser[0]) {
			Test.startTest();
			try {
				copado__User_Story__c us = [SELECT Id, copado__User_Story_Title__c FROM copado__User_Story__c WHERE copado__User_Story_Title__c = 'TEST CustomSetting' LIMIT 1];
				us.copado__User_Story_Title__c = '1223456789';
				us.copado__Promote_Change__c = true;
				update us;
			} catch (Exception e) {
				System.assertEquals(true, String.valueOf(e).contains('Objeto restringido por la OT'), 'El error indicado no es el correcto.');
			}
			Test.stopTest();
		}
	}

	@isTest
	public static void pruebaDataManagerRestriccionCorrecto() {

		Id idRTTraspaso = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('CBK_Traspaso').getRecordTypeId();

		CBK_Config__mdt proceso = new CBK_Config__mdt();
		proceso.CBK_Active__c = true;
		CBK_copado_User_Story_BU_TRHan.procesoDatamanagerTest = proceso;

		copado__User_Story__c us2 = [SELECT Id, copado__User_Story_Title__c FROM copado__User_Story__c WHERE copado__User_Story_Title__c = 'TEST CustomSetting' LIMIT 1];
		copado__User_Story_Metadata__c mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'ApexClass.CBK_Prueba';
		mtd.copado__User_Story__c = us2.Id;
		insert mtd;

		CBK_DataManager__c dmCustomField2 = new CBK_DataManager__c();
		dmCustomField2.API_Name__c = 'CustomField.Contact.XXXX';
		dmCustomField2.Status__c = 'Approved';
		dmCustomField2.RecordTypeId = idRTTraspaso;
		dmCustomField2.Proyectos__c = 'Otros';
        dmCustomField2.Description__c = 'Description';
		insert dmCustomField2;

		CBK_DataManager__c dmCustomField3 = new CBK_DataManager__c();
		dmCustomField3.API_Name__c = 'CustomField.CBK_IntegrationSetting__c.CBK_TimeOut__c';
		dmCustomField3.Status__c = 'Approved';
		dmCustomField3.RecordTypeId = idRTTraspaso;
		dmCustomField3.Proyectos__c = 'Otros';
        dmCustomField3.Description__c = 'Description';
		insert dmCustomField3;

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
		
		System.runAs(adminUser[0]) {
			Test.startTest();
			try {
				copado__User_Story__c us = [SELECT Id, copado__User_Story_Title__c FROM copado__User_Story__c WHERE copado__User_Story_Title__c = 'TEST CustomSetting' LIMIT 1];
				us.copado__User_Story_Title__c = '1223456789';
				us.copado__Promote_Change__c = true;
				Database.SaveResult sr = database.update(us); 
				System.assertEquals(true, sr.isSuccess(), 'No se ha actualizado la US');
			} catch (Exception e) {
				System.assertEquals(false, String.valueOf(e).contains('Update failed'), 'El error indicado no es el correcto.');
			}
			Test.stopTest();
		}
	}

	@isTest
	public static void pruebaProfileCorrecto() {

		Id idRTTraspaso = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('CBK_Traspaso').getRecordTypeId();
		Id rtidProfile = Schema.SObjectType.CBK_DataManager__c.getRecordTypeInfosByDeveloperName().get('Profile').getRecordTypeId();

		CBK_Config__mdt proceso = new CBK_Config__mdt();
		proceso.CBK_Active__c = true;
		CBK_copado_User_Story_BU_TRHan.procesoDatamanagerTest = proceso;

		copado__User_Story__c us2 = [SELECT Id, copado__User_Story_Title__c FROM copado__User_Story__c WHERE copado__User_Story_Title__c = 'TEST CustomSetting' LIMIT 1];
		copado__User_Story_Metadata__c mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'Profile.SEG_Usuario_CaixaBank';
		mtd.copado__User_Story__c = us2.Id;
		insert mtd;

		CBK_DataManager__c dmCustomField2 = new CBK_DataManager__c();
		dmCustomField2.API_Name__c = 'CustomField.Contact.XXXX';
		dmCustomField2.Status__c = 'Approved';
		dmCustomField2.RecordTypeId = idRTTraspaso;
		dmCustomField2.Proyectos__c = 'Otros';
        dmCustomField2.Description__c = 'Description';
		insert dmCustomField2;

		CBK_DataManager__c dmCustomField3 = new CBK_DataManager__c();
		dmCustomField3.API_Name__c = 'CustomField.CBK_IntegrationSetting__c.CBK_TimeOut__c';
		dmCustomField3.Status__c = 'Approved';
		dmCustomField3.RecordTypeId = idRTTraspaso;
		dmCustomField3.Proyectos__c = 'Otros';
        dmCustomField3.Description__c = 'Description';
		insert dmCustomField3;

		CBK_DataManager__c dmprofile = new CBK_DataManager__c();
		dmprofile.ProfileName__c = 'SEG_Usuario_CaixaBank';
		dmprofile.RecordTypeId = rtidProfile;
        dmprofile.Description__c = 'Description';
		insert dmprofile;

		List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];
		
		System.runAs(adminUser[0]) {
			Test.startTest();
			try {
				copado__User_Story__c us = [SELECT Id, copado__User_Story_Title__c FROM copado__User_Story__c WHERE copado__User_Story_Title__c = 'TEST CustomSetting' LIMIT 1];
				us.copado__User_Story_Title__c = '1223456789';
				us.copado__Promote_Change__c = true;
				us.CBK_HasConflictIp__c = false;
				Database.SaveResult sr = database.update(us); 
			} catch (Exception e) {
				System.assertEquals(true, String.valueOf(e).contains('User Stories Contiene cambios que pueden afectar a las IPs de un profile'), 'El error indicado no es el correcto.');
			}
			Test.stopTest();
		}
	}
}