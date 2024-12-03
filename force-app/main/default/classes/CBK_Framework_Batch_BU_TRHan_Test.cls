@isTest
public class CBK_Framework_Batch_BU_TRHan_Test {
    @testSetup static void setup() {
        CBK_Framework_Batch__c fb = new CBK_Framework_Batch__c();
        fb.Name = 'Test Batch setup';
        fb.Class_Name__c = 'Test class';
        fb.Tipo__c = 'Periodico';
        fb.Lunes__c = true;
        fb.Periodicidad__c = 1;
        fb.Tipo_de_periodicidad__c = 'Dias';
        insert fb;

        fb = new CBK_Framework_Batch__c();
        fb.Name = 'Test Batch setup2';
        fb.Class_Name__c = 'Test class';
        fb.Tipo__c = 'Periodico';
        fb.Lunes__c = true;
        fb.Periodicidad__c = 1;
        fb.Tipo_de_periodicidad__c = 'Dias';
        insert fb;
    }

    @isTest
    public static void batchExistenteTest(){

        test.startTest();
        List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

		System.runAs(adminUser[0]) {
            try {
                List <CBK_Framework_Batch__c> batchList = [SELECT Name FROM CBK_Framework_Batch__c WHERE Name = 'Test Batch setup' LIMIT 1];
                batchList[0].Name = 'Test Batch setup2';
                update batchList;
            } catch (Exception e) {
                System.assertEquals(true, e.getMessage().contains('Ya existe un Batch con ese nombre'), 'No se puede crear un Batch con un nombre ya existente');
            }
        }
        test.stopTest();
    }

    @isTest
    public static void batchNoExistenteTest(){
        CBK_Framework_Batch__c fb = new CBK_Framework_Batch__c();
        fb.Name = 'Test Batch 2';
        fb.Class_Name__c = 'Test class';
        fb.Tipo__c = 'Periodico';
        fb.Lunes__c = true;
        fb.Periodicidad__c = 1;
        fb.Tipo_de_periodicidad__c = 'Dias';
        insert fb;

        test.startTest();
        List<User> adminUser = [SELECT id, profileId, userRoleId, Name FROM User WHERE Name <> 'Administrador de sistema' LIMIT 1];

        System.runAs(adminUser[0]) {
            List<CBK_Framework_Batch__c> batchList = [SELECT Name FROM CBK_Framework_Batch__c WHERE Name LIKE 'Test Batch%'];
            System.assertEquals(3, batchList.size(), 'Debe haber 3 batchs cuyo nombre comience por Test Batch');
        }
       
        test.stopTest();
    }

}