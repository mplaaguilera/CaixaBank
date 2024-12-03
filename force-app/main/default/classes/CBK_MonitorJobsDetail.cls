public class CBK_MonitorJobsDetail implements Schedulable {
    
public void execute(SchedulableContext sc)  
    {  
        CBK_MonitorJobs_Batch batch = new CBK_MonitorJobs_Batch();
		database.executeBatch(batch,1);  
    }
}