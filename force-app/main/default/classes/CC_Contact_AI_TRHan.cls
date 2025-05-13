public with sharing class CC_Contact_AI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Contact>)tp.newList);
	}

	private void process(List<Contact> contactos) {
		// Migracion PB CC_Contact_Procesado
		if ([SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name != 'CIBE_Gestor') {
			Id idRtEmpleadoCc = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
			List<Id> idsEmpleadosCc = new List<Id>();
			for (Contact contacto : contactos) {
				if (contacto.RecordTypeId == idRtEmpleadoCc) {
					idsEmpleadosCc.add(contacto.Id);
				}
			}
			if (!idsEmpleadosCc.isEmpty()) {
				CC_Grupo_Colaborador_Contact.tratarColaborador(idsEmpleadosCc);
			}
		}

	}

}