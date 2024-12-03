public class CC_CaseReclamante_TRDisp extends CC_TriggerDispatcherBase {

	/*
	 * Trigger dispatcher para el objeto <CC_Grupo_Colaborador__c>
	 *
	 * Cada función de Dispatcher gestiona la re-entrada de la misma forma:
	 * La varible estática contiene true si se estava ejecutando ese Handler, y false si es la primera vez en este contexto
	 *
	 * Cada evento invoca a su Handler específico, dedicado a ese evento
	 * 
	 */

	private static Boolean isBeforeInsertProcessing = false;
	private static Boolean isBeforeUpdateProcessing = false;
	private static Boolean isBeforeDeleteProcessing = false;
	private static Boolean isAfterInsertProcessing = false;
	private static Boolean isAfterUpdateProcessing = false;
	private static Boolean isAfterDeleteProcessing = false;
	private static Boolean isAfterUndeleteProcessing = false;
	private static String objectApiName = 'SAC_CaseReclamante__c';

	
	public virtual override void beforeInsert(CC_TriggerParameters tp) {
		if (!isBeforeInsertProcessing) {
			isBeforeInsertProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(objectApiName, 'beforeInsert')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
			}
			isBeforeInsertProcessing = false;
		}
		else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
	}
	
	public virtual override void beforeUpdate(CC_TriggerParameters tp) {
		if (!isBeforeUpdateProcessing) {
			isBeforeUpdateProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(objectApiName, 'beforeUpdate')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
			}
			isBeforeUpdateProcessing = false;
		}
		else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
	}
	/*
	public virtual override void beforeDelete(CC_TriggerParameters tp) {
		if (!isBeforeDeleteProcessing) {
			isBeforeDeleteProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(objectApiName, 'beforeDelete')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
			}
			isBeforeDeleteProcessing = false;
		}
		else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
	}

	public virtual override void afterInsert(CC_TriggerParameters tp) {

		if (!isAfterInsertProcessing) {
			isAfterInsertProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(objectApiName, 'afterInsert')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterInsert);
			}
			isAfterInsertProcessing = false;
		}
		else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterInsert);
	}
	/*
	*/
	public virtual override void afterUpdate(CC_TriggerParameters tp) {

		if (!isAfterUpdateProcessing) {
			isAfterUpdateProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(objectApiName, 'afterUpdate')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
			}
			isAfterUpdateProcessing = false;
		}
		else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
	}

	public virtual override void afterDelete(CC_TriggerParameters tp) {

		if (!isAfterDeleteProcessing) {
			isAfterDeleteProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(objectApiName, 'afterDelete')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterDelete);
			}
			isAfterDeleteProcessing = false;
		}
		else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterDelete);
	}
}