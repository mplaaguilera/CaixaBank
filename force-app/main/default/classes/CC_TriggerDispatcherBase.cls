public virtual class CC_TriggerDispatcherBase implements CC_ITriggerDispatcher {

	/*
	* Implementación de la interface de Dispatcher.
	* Permite implementar sólo los métodos que sean necesarios para la gestión de los triggers.
	*
	* La gestión de las re-entradas se lleva a cabo en el método execute, que es un método protected, lo que permite modificar
	* su implementación en las clases hijas.
	*
	*/

	private static CC_ITriggerHandler beforeInserthandler;
	private static CC_ITriggerHandler beforeUpdatehandler;
	private static CC_ITriggerHandler beforeDeleteHandler;
	private static CC_ITriggerHandler afterInserthandler;
	private static CC_ITriggerHandler afterUpdatehandler;
	private static CC_ITriggerHandler afterDeleteHandler;
	private static CC_ITriggerHandler afterUndeleteHandler;

	private static Boolean isBeforeInsertProcessing = false;
	private static Boolean isBeforeUpdateProcessing = false;
	private static Boolean isBeforeDeleteProcessing = false;
	private static Boolean isAfterInsertProcessing = false;
	private static Boolean isAfterUpdateProcessing = false;
	private static Boolean isAfterDeleteProcessing = false;
	private static Boolean isAfterUndeleteProcessing = false;

	/*
	* Este método se llama previo a la ejecución del evento before de un trigger.
	* Si se necesita hacer alguna carga de valores lookup o cachear información.
	*/
	public virtual void bulkBefore() {}

	/*
	* Este método se llama previo a la ejecución del evento after de un trigger.
	*/
	public virtual void bulkAfter() {}

	/*
	* Este método se llama para los registros que se van a insertar durante el BEFORE Trigger.
	*/
	public virtual void beforeInsert(CC_TriggerParameters tp) {
		if (!isBeforeInsertProcessing) {
			isBeforeInsertProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(tp.triggerObject, 'beforeInsert')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
			}
			isBeforeInsertProcessing = false;
		}
		else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
	}

	/*
	* Este método se llama para los registros que se van a actualizar durante el BEFORE Trigger.
	*/
	public virtual void beforeUpdate(CC_TriggerParameters tp) {
		if (!isBeforeUpdateProcessing) {
			isBeforeUpdateProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(tp.triggerObject, 'beforeUpdate')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
			}
			isBeforeUpdateProcessing = false;
		}
		else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
	}

	/*
	* Este método se llama para los registros que se van a eliminar durante el BEFORE Trigger.
	*/
	public virtual void beforeDelete(CC_TriggerParameters tp) {
		if(!isBeforeDeleteProcessing) {
			isBeforeDeleteProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(tp.triggerObject, 'beforeDelete')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterInsert);
			}
			isBeforeDeleteProcessing = false;
		}
		else execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
	}

	/*
	* Este método se llama para los registros insertados durante el AFTER Trigger.
	* El registro es 'read-only' en este punto.
	*/
	public virtual void afterInsert(CC_TriggerParameters tp) {
		if (!isAfterInsertProcessing) {
			isAfterInsertProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(tp.triggerObject, 'afterInsert')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterInsert);
			}
			isAfterInsertProcessing = false;
		}
		else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterInsert);
	}

	/*
	* Este método se llama de forma iterativa por cada registro actualizado durante el AFTER Trigger.
	*/
	public virtual void afterUpdate(CC_TriggerParameters tp) {
		if (!isAfterUpdateProcessing) {
			isAfterUpdateProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(tp.triggerObject, 'afterUpdate')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
			}
			isAfterUpdateProcessing = false;
		}
		else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterUpdate);
	}

	/*
	* Este método se llama de forma iterativa por cada registro borrado durante el AFTER Trigger.
	*/
	public virtual void afterDelete(CC_TriggerParameters tp) {
		if (!isAfterDeleteProcessing) {
			isAfterDeleteProcessing = true;
			for (String handlerClassName : getAssociatedHandlers(tp.triggerObject, 'afterDelete')) {
				Type handlerClassType = Type.forName(handlerClassName);
				execute((CC_ITriggerHandler) handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterDelete);
			}
			isAfterDeleteProcessing = false;
		}
		else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterDelete);
	}

	/*
	* Este método se llama previo a la ejecución del AFTER UNDELETE Trigger.
	*/
	public virtual void afterUnDelete(CC_TriggerParameters tp) {
		if (!isAfterUndeleteProcessing) {           
            isAfterUndeleteProcessing = true;
            for (String handlerClassName : getAssociatedHandlers(tp.triggerObject, 'afterUndelete')) {
                Type handlerClassType = Type.forName(handlerClassName);
                execute((CC_ITriggerHandler)handlerClassType.newInstance(), tp, CC_TriggerParameters.TriggerEvent.afterUndelete);
            }
            isAfterUndeleteProcessing = false;
        }
        else execute(null, tp, CC_TriggerParameters.TriggerEvent.afterUndelete);
	}

	public virtual void andFinally() {}

	/*
	* Este método se llama por los Event Handlers. Si es la primera llamada en el contexto, el método crea una nueva instancia
	* del handler adecuado y ejecuta el método mainEntry. Si hay una llamada en curso en el mismo contexto, el método utiliza
	* el handler existente por la primera llamada y ejecuta el método inProgressEntry.
	*
	* Parámetros:
	*   handlerInstance -> Instancia del trigger handler. Control de recursividad con el paso de valor null.
	*   tp -> Son los parámetros gestionados por el framework.
	*   tEvent -> El evento del trigger.
	*/
	protected void execute(CC_ITriggerHandler handlerInstance, CC_TriggerParameters tp, CC_TriggerParameters.TriggerEvent tEvent) {
		if (handlerInstance != null) {
			if (tEvent == CC_TriggerParameters.TriggerEvent.beforeInsert)
				beforeInsertHandler = handlerInstance;
			if (tEvent == CC_TriggerParameters.TriggerEvent.beforeUpdate)
				beforeUpdateHandler = handlerInstance;
			if (tEvent == CC_TriggerParameters.TriggerEvent.beforeDelete)
				beforeDeleteHandler = handlerInstance;
			if (tEvent == CC_TriggerParameters.TriggerEvent.afterInsert)
				afterInsertHandler = handlerInstance;
			if (tEvent == CC_TriggerParameters.TriggerEvent.afterUpdate)
				afterUpdateHandler = handlerInstance;
			if (tEvent == CC_TriggerParameters.TriggerEvent.afterDelete)
				afterDeleteHandler = handlerInstance;
			if (tEvent == CC_TriggerParameters.TriggerEvent.afterUnDelete)
				afterUndeleteHandler = handlerInstance;

			handlerInstance.mainEntry(tp);
			handlerInstance.updateObjects();
		} else {
			if(tEvent == CC_TriggerParameters.TriggerEvent.beforeInsert)
				beforeInsertHandler.inProgressEntry(tp);
			if(tEvent == CC_TriggerParameters.TriggerEvent.beforeUpdate)
				beforeUpdateHandler.inProgressEntry(tp);
			if(tEvent == CC_TriggerParameters.TriggerEvent.beforeDelete)
				beforeDeleteHandler.inProgressEntry(tp);
			if(tEvent == CC_TriggerParameters.TriggerEvent.afterInsert)
				afterInsertHandler.inProgressEntry(tp);
			if(tEvent == CC_TriggerParameters.TriggerEvent.afterUpdate)
				afterUpdateHandler.inProgressEntry(tp);
			if(tEvent == CC_TriggerParameters.TriggerEvent.afterDelete)
				afterDeleteHandler.inProgressEntry(tp);
			if(tEvent == CC_TriggerParameters.TriggerEvent.afterUnDelete)
				afterUndeleteHandler.inProgressEntry(tp);
		}
	}

	protected List<String> getAssociatedHandlers(String objectApiName, String triggerEvent) {
		
		List<String> handlerClassNames = new List<String>();
		List<CBK_TriggerHandlerAssociation__mdt> triggerHandlerAssociations = [SELECT CBK_HandlerClassName__c, DeveloperName FROM CBK_TriggerHandlerAssociation__mdt WHERE CBK_ObjectApiName__c = :objectApiName AND CBK_TriggerEvent__c = :triggerEvent ORDER BY CBK_Order__c, DeveloperName asc];
		for (CBK_TriggerHandlerAssociation__mdt triggerHandlerAssociation : triggerHandlerAssociations){
			if (String.isNotBlank(triggerHandlerAssociation.CBK_HandlerClassName__c)){
				Type handlerClassType = Type.forName(triggerHandlerAssociation.CBK_HandlerClassName__c);
				if(handlerClassType != null){
					handlerClassNames.add(triggerHandlerAssociation.CBK_HandlerClassName__c);
				}else{
					CBK_Log.error('Trigger Handler Associations - No existe la clase: ' + triggerHandlerAssociation.CBK_HandlerClassName__c + ' - Para el Objeto: ' + objectApiName + ', Evento: ' + triggerEvent);
				}
			}
		}
		return handlerClassNames;
	}

	protected Map<Id, SObject> generateMap(List<SObject> newList){
		Map<Id,SObject> mObj = new Map<Id,SObject>();
		for(SObject ob : newList){
			Id mId = string.valueOf(ob.get('Id'));
			mObj.put(mId, ob);
		}	
		return mObj;
	}

	protected List<SObject> generateOldList(List<SObject> newList, List<SObject> oldList){
		List<SObject> lstOld = new List<SObject>();
		Map<Id,SObject> mOld = new Map<Id,SObject>();
		Id mId;
		for( SObject so : oldList){
			mId = string.valueOf(so.get('Id'));
			mOld.put(mId, so);
		}
		for(SObject so : newList){
			mId = string.valueOf(so.get('Id'));
			if(mOld.containsKey(mId)){
				lstOld.add(mOld.get(mId));
			}
		}
		return lstOld;
	}
}