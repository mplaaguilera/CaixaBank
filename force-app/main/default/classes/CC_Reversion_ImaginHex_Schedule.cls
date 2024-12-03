global class CC_Reversion_ImaginHex_Schedule implements Schedulable{
    global void execute(SchedulableContext SC){
        Database.executeBatch(new CC_Reversion_ImaginHex_Batch());
    }
}