global with sharing class OS_NoCliente_Borrar_Batch_Schedule implements Schedulable{

	 global void execute(SchedulableContext SC){
        Database.executeBatch(new OS_NoCliente_Borrar_Batch());

    }    
}