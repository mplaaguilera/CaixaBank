public class CBK_BatchJobCheck implements Schedulable {
    public void execute(SchedulableContext sc)  
    {  
        Datetime vtoday = System.now();
        list<CronTrigger> lstjobs = [SELECT Id,CreatedDate, CronJobDetail.name, State FROM CronTrigger
									  Where (CronJobDetail.name like 'Framework Batch:%')
										and (State in ('WAITING','ACQUIRED','EXECUTING')  OR CreatedDate >= :vtoday.addMinutes(-5))];
        
        if (lstjobs.size()==0) {
            CBK_BatchJob_Sched.newSchedule();
        } 
        //comprueba si el FWK schedule esta en marcha, de lo contrario lo ejecuta.
        checkFWKSchedule();
    }

    public static void checkFWKSchedule(){

        Datetime vtoday = System.now();
        list<CronTrigger> lstjobs = [SELECT Id,CreatedDate, CronJobDetail.name, State 
            FROM CronTrigger
            WHERE (CronJobDetail.name like 'Job-Pending Process Recurrent_%')
            AND (State in ('WAITING','ACQUIRED','EXECUTING') OR CreatedDate >= :vtoday.addMinutes(-5))];

        if (lstjobs.size()==0) {
            CBK_ScheduleProcess_Controller sch = new CBK_ScheduleProcess_Controller();
            sch.execute(null);
        }  
    }
}