public class CBK_ScheduleProcess_Dispacher extends CBK_ScheduleProcess_Abstract {
	public override void execute(Map<String, List<CBK_SCH_PendingProcess__c>> mapToProcess)
	{
		Type typeProcessAction;
		CBK_SCH_Queueable_Abstract processAction;
		List<CBK_SCH_PendingProcess__c> lstpp;
		for (string cn : mapToProcess.keySet())
		{
			try {
				lstpp = mapToProcess.get(cn);
				typeProcessAction = Type.forName(cn);

				CBK_log.debug('Class: CBK_ScheduleProcess_Dispacher - Launch ' + cn, LoggingLevel.INFO);

				processAction = (CBK_SCH_Queueable_Abstract) typeProcessAction.newInstance();
				processAction.lstInfoProcess = mapToProcess.get(cn);
				System.enqueueJob(processAction);

			} catch(Exception e) {
				CBK_log.error(e, 'Error : CBK_ScheduleProcess_Dispacher - Launch ' + cn);
				Set<string> setIds = new Set<string> ();

				for (CBK_SCH_PendingProcess__c pp : lstpp) {
					setIds.add(pp.id);
				}
				if (setIds != null && setIds.size() > 0) {
					CBK_ScheduleProcess_Controller.updateRecordSchProcess(setIds, null, true);
				}
			}
		}
	}
}