global class CC_SDOCS_MCC_Batch_Schedule implements Schedulable {
	global void execute(SchedulableContext SC){       
         Database.executeBatch(new CC_SDOC_MCC_Batch());
    }
}