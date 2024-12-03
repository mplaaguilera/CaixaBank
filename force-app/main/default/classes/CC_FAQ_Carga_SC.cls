global class CC_FAQ_Carga_SC implements Schedulable {

    global void execute(SchedulableContext SC) {
        //CC_FAQ.cargar();
        CC_FAQ_Batch batch = new CC_FAQ_Batch();
        Database.executeBatch(batch,1);
    }
}