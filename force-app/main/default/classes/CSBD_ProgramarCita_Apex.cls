public with sharing class CSBD_ProgramarCita_Apex {

	@AuraEnabled
	public static Event programarCita(Id recordId, Boolean asignacionAuto, Boolean comprobarContacto, Id idPropietario, Datetime startDateTime) {
		try {
			return CSBD_Opportunity.programarCita(recordId, asignacionAuto, comprobarContacto, idPropietario, startDateTime);
		} catch (Exception e) {
			CBK_Log.error(e);
			throw new AuraHandledException(e.getMessage());
		}
	}

}