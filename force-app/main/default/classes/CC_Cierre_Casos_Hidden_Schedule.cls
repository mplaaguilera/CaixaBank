global class CC_Cierre_Casos_Hidden_Schedule implements Schedulable{
	 global void execute(SchedulableContext SC){
        CC_Cierre_Casos_Hidden_Batch batch = new CC_Cierre_Casos_Hidden_Batch();
		Database.executeBatch(batch, 1);
    }
}