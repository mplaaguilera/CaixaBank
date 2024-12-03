/**********************************************************************************************************************
 Name:	CC_TraduccionDeEvento_TRDisp
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			                    Mamen Arias			28/11/2022			Init version

***********************************************************************************************************************/
public with sharing class CC_TraduccionDeEvento_TRDisp extends CC_TriggerDispatcherBase {
	private static Boolean isAfterInsertProcessing = false;
	private static Boolean isBeforeUpdateProcessing = false;

	public virtual override void beforeInsert(CC_TriggerParameters tp) {
		system.debug('@@entramos en trigger');
		if(!isAfterInsertProcessing) {
			isAfterInsertProcessing = true;
			execute(new EV_TraduccionDeEvento_BI_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
			isAfterInsertProcessing = false;
		}
		else{
			execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeInsert);
		}
	}

	public virtual override void beforeUpdate(CC_TriggerParameters tp) {
		if(!isBeforeUpdateProcessing) {
			isBeforeUpdateProcessing = true;
			execute(new EV_TraduccionDeEvento_BU_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
			isBeforeUpdateProcessing = false;
		}
		else{
			execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeUpdate);
		}
	}
	
	/*public virtual override void beforeDelete(CC_TriggerParameters tp) {
		if(!isBeforeUpdateProcessing) {
			isBeforeUpdateProcessing = true;
			execute(new EV_TraduccionDeEvento_BD_TRHan(), tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
			isBeforeUpdateProcessing = false;
		}
		else{
			execute(null, tp, CC_TriggerParameters.TriggerEvent.beforeDelete);
		}
	}*/
}