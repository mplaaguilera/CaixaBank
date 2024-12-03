global class CC_FAQ_App_SC implements Schedulable {

    global void execute(SchedulableContext SC) {
        CC_FAQ.cargarApps();
    }
}