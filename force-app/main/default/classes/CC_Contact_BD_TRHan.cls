public with sharing class CC_Contact_BD_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Contact>)tp.oldList);
	}
	
	/* Cuando eliminamos un contacto de tipo "empleado",
        eliminamos automáticamente su correspondiente colaborador */
	private void process(List<Contact> contactos) {
        Id empleadoId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
		List<Id> colaboradorIds = new List<Id>();
		for(Contact contacto : contactos) {
			if (contacto.RecordTypeId == empleadoId) {
				colaboradorIds.add(contacto.Id);
			}
		}
		
		List<CC_Grupo_Colaborador_Contact__c> colaboradores = [Select Id From CC_Grupo_Colaborador_Contact__c Where CC_Contacto__c in :colaboradorIds];

		if (colaboradores.size() > 0) {
			delete colaboradores;
		}
	}
}