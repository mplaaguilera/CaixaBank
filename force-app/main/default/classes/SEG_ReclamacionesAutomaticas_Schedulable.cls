global class SEG_ReclamacionesAutomaticas_Schedulable implements Schedulable{
	global void execute(SchedulableContext SC){

    String sizeBatch = SEG_MetodosComunes.recuperarParametrosValor('SEG_BatchSizeReclamaciones');
    sizeBatch = (String.isNotBlank(sizeBatch)) ? sizeBatch : '25';

    SEG_ReclamacionesAutomaticas_Batch batchReclamaciones = new SEG_ReclamacionesAutomaticas_Batch();
    Id batch = Database.executeBatch(batchReclamaciones, Integer.valueOf(sizeBatch));
  }
}