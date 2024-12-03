global with sharing class CC_FinalizarLlamadas_Batch_Schedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new CC_FinalizarLlamadas_Batch());
    }
}