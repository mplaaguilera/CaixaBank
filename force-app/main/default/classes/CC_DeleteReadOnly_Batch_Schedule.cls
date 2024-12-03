global class CC_DeleteReadOnly_Batch_Schedule implements Schedulable{
    global void execute(SchedulableContext SC){
        Database.executeBatch(new CC_DeleteReadOnly_Batch());
    }
}