public class CBK_SCH_Queueable extends CBK_SCH_Queueable_Abstract {
	public override void execute(QueueableContext ctx) {
		List<CBK_SCH_PendingProcess__c> LstInfoPp = this.lstInfoProcess;
		work(LstInfoPp);

	}

	private void work(List<CBK_SCH_PendingProcess__c> LstInfoPp) {
		System.debug('CBK_SCH_Queueable - Input list: ' + JSON.serialize(LstInfoPp));
	}
}