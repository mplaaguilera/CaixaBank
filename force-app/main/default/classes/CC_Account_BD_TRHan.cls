public with sharing class CC_Account_BD_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Account>)tp.oldList);
	}
	
	/* Cuando eliminamos una cuenta de tipo "centro",
        eliminamos automáticamente su correspondiente grupo colaborador */
	private void process(List<Account> cuentas) {
        Id centroId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

		List<Id> cuentaIds = new List<Id>();
		for(Account cuenta : cuentas) {
			if (cuenta.RecordTypeId == centroId) {
				cuentaIds.add(cuenta.Id);
			}
		}

		List<CC_Grupo_Colaborador__c> grupos = [Select Id From CC_Grupo_Colaborador__c Where CC_cuenta__c in :cuentaIds];

		if (grupos.size() > 0) {
			delete grupos;
		}
	}
	
	//public override void inProgressEntry(CC_TriggerParameters tp) {
	//	System.debug('Código para la gestión de reentradas en caso necesario...');
	//}
	
	//public override void updateObjects() {
		// for demonstration purposes, don't do anything here...
	//}
}