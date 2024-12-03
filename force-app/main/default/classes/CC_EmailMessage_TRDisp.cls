public with sharing class CC_EmailMessage_TRDisp extends CC_TriggerDispatcherBase {
//Esta variable puede estar rellena o no y tomar el no estar informada como estar a false
private static Map<CC_TriggerParameters.TriggerEvent, Boolean> isTriggerProcessing = new Map<CC_TriggerParameters.TriggerEvent, Boolean>();
private static Boolean ignoreTrigger = false;

	private static String objectApiName = 'EmailMessage';
	private static String handlerClassTypeResult = 'CC_EmailMessage_TRDisp';

	public virtual override void beforeInsert(CC_TriggerParameters tp) {
 		handleParent(tp, CC_TriggerParameters.TriggerEvent.beforeInsert, tp.newList);
	}

	public virtual override void afterInsert(CC_TriggerParameters tp) {
		handleParent(tp, CC_TriggerParameters.TriggerEvent.afterInsert, tp.newList);
 	}

 	public virtual override void beforeDelete(CC_TriggerParameters tp) {
		// handleParent(tp, CC_TriggerParameters.TriggerEvent.beforeDelete, tp.oldList);
 	}

	 public virtual override void afterDelete(CC_TriggerParameters tp) {
		// handleParent(tp, CC_TriggerParameters.TriggerEvent.afterDelete, tp.oldList);
 	}

	public void handleParent(CC_TriggerParameters tp, CC_TriggerParameters.TriggerEvent triggerEvent, List<SObject> referenceList){
		if (!isTriggerProcessing.containsKey(triggerEvent) || !isTriggerProcessing.get(triggerEvent)) {
			isTriggerProcessing.put(triggerEvent, true);
			Boolean execParent = true;
	 		Boolean activeParent = false;
	 		try {
	 			List<EmailMessage> emList = (List<EmailMessage>) referenceList;
	 			for (EmailMessage em : emList) {
					if (em.CBK_IgnoreTrigger__c){ignoreTrigger = true;}
				}

	 			if (ignoreTrigger) {
					CBK_log.debug('Entra saltando triggers', LoggingLevel.INFO);
				}else{
					if (execParent) {
	 					Type handlerClassType = Type.forName('CBK_EmailMessage_Parent_TRHan');
						CBK_EmailMessage_Parent_TRHan parentHand = (CBK_EmailMessage_Parent_TRHan) handlerClassType.newInstance();
	 					parentHand.executeParent(tp, triggerEvent);
						execParent = false;
					}
	 			}
	 		} catch(Exception e) {
	 			Type handlerClassType2 = Type.forName('CBK_EmailExceptions_TRHan');
				CBK_EmailExceptions_TRHan emailHand = (CBK_EmailExceptions_TRHan) handlerClassType2.newInstance();
	 			emailHand.handledException(e, tp, 'CBK_EmailMessage_Parent_TRHan');
				isTriggerProcessing.put(triggerEvent, false);
	 			throw e;
	 		}

	 		isTriggerProcessing.put(triggerEvent, false);
	 		ignoreTrigger = false;
	 	}else {execute(null, tp, triggerEvent);}
	}
}