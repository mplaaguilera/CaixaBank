global class CC_FacturarCasosCerrados_Schedule implements Schedulable{
    global void execute(SchedulableContext SC){
        Database.executeBatch(new CC_FacturarCasosCerrados_Batch());
    }
}