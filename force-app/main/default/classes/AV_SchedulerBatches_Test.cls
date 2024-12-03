/**********************************************************************************************************************
 Name:      AV_SchedulerBatches_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_ScheduleDeleteBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            App FSC          Maria Telleria   29/04/2020          Init version
   1.1            App FSC          David Rufo   	29/11/2020          Improve coverage + Fix
   1.2			  USXXXXXX		   Daniel Rodriguez	22/11/2021			add FWK Batches
   1.3            US448873         Luis Fernández   08/03/2023          Added few methods in order to improve cobertry (testDeactivateSingleBatch,
                                                                                                                        testDeactivadedBatches)
   1.4            Fix              Patricia Villacañas  18/05/2023          Modified to set run as

***********************************************************************************************************************/
@isTest
private class AV_SchedulerBatches_Test {

    /**
     * Setup configuration
     */
    @TestSetup
    static void setup() {

        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];


        System.runAs(userGcf){
        AV_TestHelper.activateLogger();
    }
    }

    /**
     * Activation batches
     */
    @isTest
    static void testActivationBatches() {
        
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

        Test.startTest();
        System.runAs(userGcf){

        List<AV_ScheduleBatch__mdt> listData = AV_SchedulerBatches.getMetadata('true');       
        AV_SchedulerBatches.deactivate();
        AV_SchedulerBatches.activate();
        List<CronTrigger> a = [select CronJobDetail.Name from CronTrigger WHERE CronJobDetail.Name like 'AV_%'];
        for(CronTrigger b : a ){
            System.debug(b.CronJobDetail.Name);
        }
    
        System.assertEquals(listData.size(), [SELECT count() FROM AV_ScheduleBatch__mdt WHERE DeveloperName LIKE 'AV_%' AND AV_Active__C = TRUE]);

        if (listData != null && !listData.isEmpty()) {

            List<String> activationlist =new List<String>();

            for (AV_ScheduleBatch__mdt sm : listData) {

               
                 activationlist.add(sm.DeveloperName);
               
            }

            List<CronTrigger> ct = [SELECT State FROM CronTrigger WHERE CronJobDetail.Name IN :activationlist ];
                
            }

        }
        Test.stopTest();
    }

    /**
     * Deactivation batches
     */
    @isTest
    static void testDeactivationBatches() {
        List<AV_ScheduleBatch__mdt> listData = AV_SchedulerBatches.getMetadata('true');
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        System.runAs(userGcf){

        AV_SchedulerBatches.deactivate();
        AV_SchedulerBatches.activate();
        System.assertEquals(listData.size(), [SELECT count() FROM AV_ScheduleBatch__mdt WHERE DeveloperName LIKE 'AV_%' AND AV_Active__C = TRUE]);

        if (listData != null && !listData.isEmpty()) {

            List<String> deactivationList =new List<String>();

            for (AV_ScheduleBatch__mdt st : listData) {

                
                 deactivationList.add(st.DeveloperName);  
            }

             List<CronTrigger> ct = [SELECT State FROM CronTrigger WHERE CronJobDetail.Name IN :deactivationList];
             
        }

        AV_SchedulerBatches.deactivate();
    }
        System.assertEquals(0, [select count() from CronTrigger WHERE CronJobDetail.Name like 'AV_%']);
        Test.stopTest();
    }
    
    /**
     * Deactivation batches
     */
    @isTest
    static void testexecuteMaskProcessBatches() {
        List<AV_ScheduleBatch__mdt> listData = AV_SchedulerBatches.getMetadata(null);

        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        System.runAs(userGcf){
        AV_SchedulerBatches.executeMaskProcess();
        }
        Test.stopTest();
        
        List<CBK_Framework_Batch__c> jobList = [SELECT Id FROM CBK_Framework_Batch__c];
        System.assertEquals(2, jobList.size());
    }
    
    @isTest
    static void testDeactivateSingleBatch(){
        List<AV_ScheduleBatch__mdt> listData = AV_SchedulerBatches.getMetadata('true');       

        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Test.startTest();
        System.runAs(userGcf){
            String blankStr = '';
            AV_SchedulerBatches.deactivate(blankStr);
            if([SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :listData[1].DeveloperName].isEmpty()){
                AV_SchedulerBatches.activate(listData[1].DeveloperName);
            }
            AV_SchedulerBatches.deactivate(listData[1].DeveloperName);
		}
        Test.stopTest();
        List<CronTrigger> result = [SELECT Id FROM CronTrigger where CronJobDetail.Name = :listData[1].DeveloperName LIMIT 1];
        System.assert(result.isEmpty());
    }
    
    @isTest 
    static void testDeactivadedBatches(){
        List<AV_ScheduleBatch__mdt> deactivatedBatches = [SELECT Id,DeveloperName FROM AV_ScheduleBatch__mdt WHERE DeveloperName LIKE 'AV_%' AND AV_Active__C = FALSE ];
        String strBlank = '';
        List<String> dvNames = new List<String>{strBlank};
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

        for(AV_ScheduleBatch__mdt mdt : deactivatedBatches){
            dvNames.add(mdt.DeveloperName);
        }
       
        Test.startTest();
        System.runAs(userGcf){
		String methodName = 'testDeactivadedBatches';
        for(String str : dvNames){
            try{
                AV_SchedulerBatches.activate(str);
            }catch(Exception err){
                AV_LogDebug.printException(methodName, err);
                continue;
            }
        }
    }
        Test.stopTest();
        System.assert(!deactivatedBatches.isEmpty());
    }
}