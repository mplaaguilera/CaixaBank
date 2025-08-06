global class CC_LlamadasIZO_Batch_Schedule implements Schedulable{
    global void execute(SchedulableContext SC){
        Database.executeBatch(new CC_LlamadasIZO_Batch());
    }
}