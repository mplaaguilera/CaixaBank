public with sharing class CC_Contact_AU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Contact>)tp.newList, (Map<Id, Contact>)tp.oldMap);
	}

    private void process(List<Contact> contactos, Map<Id, Contact> contactosViejos) {
		// Migracion PB CC_Contact_Procesado
		String perfilUtilizado = null;

		if(UserInfo.getProfileId() != null ){
			perfilUtilizado = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
		}
		
		String usuarioUtilizado = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId()].Name;

		if ((perfilUtilizado != null && perfilUtilizado != 'CIBE_Gestor') || usuarioUtilizado == 'Automated Process') {
			Id idRtEmpleadoCc = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
			List<Id> idsEmpleados = new List<Id>();
			for (Contact contacto : contactos) {
				if (contacto.RecordTypeId == idRtEmpleadoCc) {
					idsEmpleados.add(contacto.Id);
				}
			}
			if (!idsEmpleados.isEmpty()) {
				CC_Grupo_Colaborador_Contact.tratarColaborador(idsEmpleados);
			}
		}
	}
}