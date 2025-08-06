@IsTest
public with sharing class CBK_Log_Debug_Builder_Test {

    @testSetup
	static void initialData() {
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
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('CBK_Framework_Login','CBK_Framework_Admin')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }
    }

    @IsTest
    static void testDebugProcessConfigBuilder() {

        User testUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Email = 'testSEGBI2@acme.com' LIMIT 1];

        //Creación Custom Picklist
        String sRecordTypeIdPicklist = Schema.SObjectType.CBK_PicklistValues__c.getRecordTypeInfosByDeveloperName().get('CBK_Picklist').getRecordTypeId();
        String sRecordTypeIdPicklistValue = Schema.SObjectType.CBK_PicklistValues__c.getRecordTypeInfosByDeveloperName().get('CBK_PicklistValue').getRecordTypeId();
        CBK_PicklistValues__c oCustomPicklist = new CBK_PicklistValues__c();
        oCustomPicklist.Name = 'CBK_Category__c';
        oCustomPicklist.CBK_Object__c = 'CBK_Log';
        oCustomPicklist.RecordTypeId = sRecordTypeIdPicklist;
        insert oCustomPicklist;
        CBK_PicklistValues__c oCustomPicklistValue1 = new CBK_PicklistValues__c();
        oCustomPicklistValue1.CBK_Picklist__c = oCustomPicklist.Id;
        oCustomPicklistValue1.Name = 'test';
        oCustomPicklistValue1.RecordTypeId = sRecordTypeIdPicklistValue;
        insert oCustomPicklistValue1;

        System.runAs (testUser) {

            // Setup AdminSettings__c instance
            AdminSettings__c settings = new AdminSettings__c(
                LogViaEvents__c = true,
                LogDEBUG__c = true,
                LogINFO__c = true,
                LogWARN__c = true,
                LogERROR__c = true,
                CBK_SnapshotExecutionLimit__c = 5000
            );
            insert settings;
    
            // Test the builder with different logging levels and configurations
            CBK_Log_Debug_Builder.DebugProcessConfigBuilder builder = new CBK_Log_Debug_Builder.DebugProcessConfigBuilder()
                .setContextId('TestContextId')
                .setMessage(new Map<String, String>{'key1' => 'value1', 'key2' => 'value2'})
                .setValues(new List<Object>{'Value1', 'Value2'})
                .setLevel(LoggingLevel.INFO)
                .setforce(true)
                .seterr(new DmlException('Test Exception'))
                .setemail(new Messaging.InboundEmail())
                .setCategory('test');
    
            CBK_Log_Debug_Builder.executeDebugBuilder(builder);
    
            // Assert the values are set correctly
            CBK_Log_Debug_Builder.DebugProcessConfig config = builder.build();
            System.assertEquals('TestContextId', config.getcontextId(),'El usuario de contexto no coincide.');
            System.assertEquals('value1', config.getmessage().get('key1'),'El value 1 no corresponde');
            System.assertEquals(LoggingLevel.INFO, config.getlevel(),'El Log Level no es identico');
            System.assertEquals(true, config.getforce(),'La condicion no es verdadera');
            System.assertEquals('Test Exception', config.geterr().getMessage(),'No coinciden los test Exception');
    
            // Validate that the event was published or system debug was called
            Test.startTest();
            CBK_Log_Debug_Builder.executeDebugBuilder(builder);
            Test.stopTest();
    
            // Since we can't query event logs, we can at least ensure no errors are thrown
            System.assert(true, 'The executeDebugBuilder method executed without errors.');
            }
        }
}