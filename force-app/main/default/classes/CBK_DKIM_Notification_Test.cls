@IsTest
public with sharing class CBK_DKIM_Notification_Test {
    @TestSetup
    static void makeData(){
        CBK_DKIM_Notification_CSetting__c set1 = new CBK_DKIM_Notification_CSetting__c();
        set1.Name = 'fromAddress';
        set1.Addresses__c = 'oficinatecnica.salesforce@caixabanktech.com';
        insert set1;

        CBK_DKIM_Notification_CSetting__c set2 = new CBK_DKIM_Notification_CSetting__c();
        set2.Name = 'toAddress';
        set2.Addresses__c = 'cbktest1@test.com;cbktest2@test.com';
        insert set2;
    }

    @IsTest
    static void methodName(){
        Test.startTest();
        CBK_DKIM_Notification_Schedule sh1 = new CBK_DKIM_Notification_Schedule();
        String sch = '0 0 23 * * ?';
        System.schedule('Test DKIM Check', sch, sh1);
        Test.stopTest();
    }
}