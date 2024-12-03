@isTest
public with sharing class CC_FinalizarLlamadas_Batch_Schedule_Test {
    @isTest
    static void test() {
        SchedulableContext sc = null;
        CC_FinalizarLlamadas_Batch_Schedule lbs = new CC_FinalizarLlamadas_Batch_Schedule();
        lbs.execute(sc);
    }
}