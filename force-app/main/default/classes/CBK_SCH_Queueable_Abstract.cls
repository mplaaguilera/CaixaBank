public abstract class CBK_SCH_Queueable_Abstract  implements Queueable, Database.AllowsCallouts{
	public abstract void execute(QueueableContext ctx);
	public  List<CBK_SCH_PendingProcess__c> lstInfoProcess  {get;set;}
}