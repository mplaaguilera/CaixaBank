/*
* @description: SAC_PrestamoRelacionSchedulable to execute SAC_PrestamoRelacionBatch
* @test: SAC_PrestamoRelacionSchedulableTest
* @author: iria.alvarez.novoa@ibm.com
* @date: october 2024
*/
public with sharing class SAC_PrestamoRelacionSchedulable implements Schedulable {
    public void execute (SchedulableContext ctx) {
        Id batchId = Database.executeBatch(new SAC_PrestamoRelacionBatch(), 50);
    }
}