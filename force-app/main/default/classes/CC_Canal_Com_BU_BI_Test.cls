@isTest
public with sharing class CC_Canal_Com_BU_BI_Test {

    @isTest
    public static void testCanalComBIBU() {
        User admin = CC_TestDataFactory.getUserAdmin();
        System.runAs(admin) {
            CC_Canal_Com__c canalCom = new CC_Canal_Com__c();
            canalCom.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
            canalCom.CC_Telefono__c = '1234567890';
            Test.startTest();
            insert canalCom;
            canalCom = [SELECT Id, CC_TelefonoIDX__c FROM CC_Canal_Com__c WHERE Id = :canalCom.Id];
            System.assertEquals('1234567890', canalCom.CC_TelefonoIDX__c, 'El teléfono no se ha insertado correctamente');

            canalCom.CC_Telefono__c = '0987654321';
            update canalCom;
            canalCom = [SELECT Id, CC_TelefonoIDX__c FROM CC_Canal_Com__c WHERE Id = :canalCom.Id];
            System.assertEquals('0987654321', canalCom.CC_TelefonoIDX__c, 'El teléfono no se ha actualizado correctamente');

            Test.stopTest();
            


        }
    }
}