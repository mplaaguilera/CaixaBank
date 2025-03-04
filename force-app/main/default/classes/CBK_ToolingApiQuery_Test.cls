/**********************************************************************************************************************
 Name:	  CBK_ToolingApiQuery_Test
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------
Propósito: Test Class of CBK_ToolingApiQuery
------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	        AUTHOR		   	           DATE				Description
	1.0			US868474		    Jose Manuel			       17/10/2024		    Init version
***********************************************************************************************************************/
@isTest
public class CBK_ToolingApiQuery_Test {

    @TestSetup
    static void setup() {
        // Crear un usuario de prueba
        System.runAs (new User(Id = UserInfo.getUserId()) ) {
            Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole role = [SELECT Id FROM UserRole WHERE Name='Sistemática Comercial'];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User testUser = new User(
                alias = 'user2', 
                email='testuser@example.com',
                emailencodingkey='UTF-8', 
                lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', 
                profileid = profile.Id, 
                userroleid = role.Id,
                timezonesidkey='America/Los_Angeles',
                Username = uniqueName + '@test' + orgId + '.org');
            insert testUser;
        }
        
        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'CBK_ToolingQuery';
		wsc.NamedCredential__c = 'https://caixabankcc--devotfwk.sandbox.lightning.force.com/services/data/v58.0/tooling/query/?q=';
        wsc.CBK_Method__c = 'GET';
		insert wsc;
    }

    @isTest
    static void testGetInfo() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@example.com' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CBK_ToolingApiQuery_Mock());
        String query = 'SELECT+Id,Name+FROM+User';
        Map<String, Object> result;

        Test.startTest();

        System.runAs (testUser) {

            result = CBK_ToolingApiQuery.getInfo(query, true);
        }

        Test.stopTest();

        // Assert
        System.assertEquals(6, result.size(), 'The number of result records should be 6');
        List<Object> listRecords = (List<Object>) result.get('records');
        for (Object record : listRecords) {
            Map<String, Object> recordMap = (Map<String, Object>) record;
            System.assertNotEquals(null, recordMap.get('Name'), 'The Name field should not be null');
            System.assertNotEquals(null, recordMap.get('Id'), 'The Id field should not be null');
        }
    }
    
    @isTest
    static void testGetNoInfo() {
        User testUser = [SELECT Id FROM User WHERE Email = 'testuser@example.com' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CBK_ToolingApiQuery_Mock());
        String query = 'InvalidQuery';
        Map<String, Object> result;

        Test.startTest();

        System.runAs (testUser) {
            result = CBK_ToolingApiQuery.getInfo(query, false);
        }

        Test.stopTest();

        // Assert
        System.assertEquals(1, result.size(), 'The number of result records should be 1');
    }
}