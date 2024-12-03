@IsTest private class CBK_MaskBatchLauncher_Test {
    @testSetup static void setup() {
        // Create common test accounts
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            Account acc = new Account();
            acc.Name = 'Prueba Test ' + i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            testAccts.add(acc);
        }
        insert testAccts;
        Account acc = [SELECT Id FROM Account Limit 1];
        Id colaboradorContactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        List <Contact> lstCtcs = new List <Contact> ();
        Contact cnt1 = new Contact ();
        cnt1.recordtypeId = colaboradorContactRT;
        cnt1.lastname = 'cnt1';
        cnt1.email = 'test@test.com';
        cnt1.AccountId = acc.ID;
        lstCtcs.add(cnt1);
        Contact cnt2 = new Contact();
        cnt2.recordtypeId = colaboradorContactRT;
        cnt2.lastname = 'cnt2';
        cnt2.email = 'Atest@test.com';
        cnt2.AccountId = acc.ID;
        lstCtcs.add(cnt2);
        Contact cnt3 = new Contact();
        cnt3.recordtypeId = colaboradorContactRT;
        cnt3.lastname = 'cnt3';
        cnt3.email = 'Btest@test.com';
        cnt3.AccountId = acc.ID;
        lstCtcs.add(cnt3);
        insert lstCtcs;
    }
    
    @IsTest static void testMethods() {
        CBK_MaskBatchLauncher.launchSerialMaskLeadBatch();
        CBK_MaskBatchLauncher.launchSerialMaskCaseBatch('100');
        CBK_MaskBatchLauncher.launchSerialMaskCaseBatch('');
        CBK_MaskBatchLauncher.launchParallelMaskCaseBatch(2,200);
        CBK_MaskBatchLauncher.launchSerialMaskAccountBatch('100');
        CBK_MaskBatchLauncher.launchSerialMaskAccountBatch('');
        CBK_MaskBatchLauncher.launchSerialMaskContactBatch('100');
        CBK_MaskBatchLauncher.launchSerialMaskContactBatch('');
        CBK_MaskBatchLauncher.launchParallelMaskAccountBatch(2,200);
        CBK_MaskBatchLauncher.launchMaskContactBatch(true,500000000,false);
        CBK_MaskBatchLauncher.launchMaskContactBatch(false,500000000,true);
        CBK_MaskBatchLauncher.coberturaDa();
	}

}