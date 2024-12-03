/**********************************************************************************************************************
 Name:	  CBK_CyberIPRangesValidation_Test
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase de test para la cobertura de la clase 'CBK_CyberIPRangesValidation'
------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	        AUTHOR		   		DATE				Description
	1.0			US807680		    Jose M. Fernández	08/06/2024		    Init version
***********************************************************************************************************************/
@isTest
private with sharing class CBK_CyberIPRangesValidation_Test {
    @testSetup
	static void itsDataCreatingTime(){  
            Profile oProfile = [SELECT Id
                                FROM Profile
                                WHERE Name = 'System Administrator'];

            UserRole oRole = [SELECT Id
                              FROM UserRole
                              WHERE Name = 'Oficina Técnica'];

            User oUser = new User();
                oUser.alias = 'user2';
                oUser.email = 'testSEGBI2@acme.com';
                oUser.emailencodingkey = 'UTF-8';
                oUser.lastname = 'Smith';
                oUser.languagelocalekey = 'en_US';
                oUser.localesidkey = 'en_US';
                oUser.profileid = oProfile.Id;
                oUser.userroleid = oRole.Id;
                oUser.timezonesidkey='America/Los_Angeles';
                oUser.username = 'testSEGBI2xx@acme.com';
            insert oUser;

            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for(PermissionSetGroupComponent oPermSetGroupComponent : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name
                                                                      FROM PermissionSetGroupComponent
                                                                      WHERE PermissionSetGroup.DeveloperName IN ('CBK_Framework_Login','CBK_Framework_Admin')])
            {
                PermissionSetAssignment oPermissionSetAssignment = new PermissionSetAssignment();
                oPermissionSetAssignment.PermissionSetId = oPermSetGroupComponent.PermissionSetId;
                oPermissionSetAssignment.AssigneeId = oUser.id;
                listPermissionSetAssignment.add(oPermissionSetAssignment);
            }

            if(!listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
    }

    @isTest
    static void testCyberIPRangesValidationOKSuccess() {
        User oUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI2xx@acme.com' LIMIT 1];

        System.runAs(oUser){
            LoginEvent oLoginEvent = new LoginEvent();
            oLoginEvent.UserId = oUser.Id;
            oLoginEvent.SourceIp = '31.149.131.115';
            oLoginEvent.Status = 'Success';

            Test.startTest();
                CBK_CyberIPRangesValidation oEventCondition = new CBK_CyberIPRangesValidation();
                Boolean bEvaluate = oEventCondition.evaluate(oLoginEvent);
            Test.stopTest();

            Assert.areEqual(false, bEvaluate, 'Evaluate result should be false'); 
        }
    }

    @isTest
    static void testCyberIPRangesValidationOKNullEvent() {
        User oUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI2xx@acme.com' LIMIT 1];

        System.runAs(oUser){
            Test.startTest();
                CBK_CyberIPRangesValidation oEventCondition = new CBK_CyberIPRangesValidation();
                Boolean bEvaluate = oEventCondition.evaluate(null);
            Test.stopTest();

            Assert.areEqual(false, bEvaluate, 'Evaluate result should be false'); 
        }
    }

    @isTest
    static void testCyberIPRangesValidationOKNotLoginEvent() {
        User oUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI2xx@acme.com' LIMIT 1];

        System.runAs(oUser){
            ReportEvent oReportEvent = new ReportEvent();
            oReportEvent.UserId = oUser.Id;

            Test.startTest();
                CBK_CyberIPRangesValidation oEventCondition = new CBK_CyberIPRangesValidation();
                Boolean bEvaluate = oEventCondition.evaluate(oReportEvent);
            Test.stopTest();

            Assert.areEqual(false, bEvaluate, 'Evaluate result should be false'); 
        }
    }

    @isTest
    static void testCyberIPRangesValidationKONotInRange() {
        User oUser = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI2xx@acme.com' LIMIT 1];

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
        oCustomPicklistValue1.Name = 'Login IP Out Of Range';
        oCustomPicklistValue1.RecordTypeId = sRecordTypeIdPicklistValue;
        insert oCustomPicklistValue1;

        System.runAs(oUser){
            LoginEvent oLoginEvent = new LoginEvent();
            oLoginEvent.UserId = oUser.Id;
            oLoginEvent.SourceIp = '34.149.131.115';
            oLoginEvent.Status = 'Success';

            Test.startTest();
                CBK_CyberIPRangesValidation oEventCondition = new CBK_CyberIPRangesValidation();
                Boolean bEvaluate = oEventCondition.evaluate(oLoginEvent);
            Test.stopTest();

            Assert.areEqual(true, bEvaluate, 'Evaluate result should be true'); 
        }
    }
}