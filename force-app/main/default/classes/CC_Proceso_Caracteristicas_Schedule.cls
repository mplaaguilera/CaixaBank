global class CC_Proceso_Caracteristicas_Schedule implements Schedulable{
	global void execute(SchedulableContext SC){
        CC_Proceso_Caracteristicas_Batch batch = new CC_Proceso_Caracteristicas_Batch();
		Database.executeBatch(batch);
    }
}