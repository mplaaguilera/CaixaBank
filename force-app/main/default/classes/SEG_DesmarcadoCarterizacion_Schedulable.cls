global class SEG_DesmarcadoCarterizacion_Schedulable implements Schedulable{
	global void execute(SchedulableContext SC){
        SEG_Desmarcado_prioridad_Segmentos_Batch batch = new SEG_Desmarcado_prioridad_Segmentos_Batch();
		Database.executeBatch(batch);
    }
}