global class CC_ST_ReviewsBatch_Schedule implements Schedulable{
	 global void execute(SchedulableContext SC){
        CC_ST_ReviewsBatch batch = new CC_ST_ReviewsBatch();
		Database.executeBatch(batch,1);
    }
}