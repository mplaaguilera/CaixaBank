@isTest
public class AV_DeleteRecordsRetosBatch_Test {

        @isTest static void testa() {
        integer a= AV_DeleteRecordsRetosBatch.Ra();
        System.enqueueJob(new AV_DeleteRecordsRetosBatchQueueable());
        System.assertEquals(1,a);
        }
}