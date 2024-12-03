global with sharing class CBK_DKIM_Notification_Schedule implements Schedulable{
    global void execute(SchedulableContext SC){
        CBK_DKIM_Notification.execute();
    }
}