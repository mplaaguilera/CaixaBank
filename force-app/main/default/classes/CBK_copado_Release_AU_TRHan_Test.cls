@isTest
public class CBK_copado_Release_AU_TRHan_Test {
    @testSetup static void setup() {
        copado__Environment__c env = new copado__Environment__c();
		env.CBK_Validacion_OT__c = true;
		insert env;

        copado__Release__c release = New copado__Release__c();
        release.Name = 'Release Test';
        insert release;

		copado__User_Story__c us = New copado__User_Story__c();
		us.copado__Environment__c = env.Id;
		us.copado__User_Story_Title__c = 'TEST CBK_copado_Release_AU_TRHan_Test';
        us.copado__Release__c = release.Id;
		insert us;

		copado__User_Story_Metadata__c mtd = New copado__User_Story_Metadata__c();
		mtd.copado__Metadata_API_Name__c = 'CustomField.Contact.Id';
		mtd.copado__User_Story__c = us.Id;
		insert mtd;
    }

    @isTest
	public static void test1() {

        Test.startTest();
        List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name = 'Administrador de sistema' LIMIT 1];
		System.runAs(adminUser[0]) {
            copado__Release__c release = [SELECT Id, copado__Status__c FROM copado__Release__c WHERE Name = 'Release Test' LIMIT 1];
            release.copado__Status__c = 'Released';
            update release;

            copado__User_Story__c usModif = [SELECT Id, copado__Stop_Indexing_Metadata__c, copado__Exclude_From_CBM__c FROM copado__User_Story__c WHERE copado__Release__c =: release.Id LIMIT 1];
            System.assertEquals(true, usModif.copado__Stop_Indexing_Metadata__c, 'No se ha modificado el Exclude from Overlap Awareness');
            System.assertEquals(true, usModif.copado__Stop_Indexing_Metadata__c, 'No se ha modificado el Exclude from Pipelines');
        }
        Test.stopTest();
    }
}