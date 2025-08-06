public inherited sharing class SEG_ActivarUsuarios_Controller {

	@AuraEnabled
	public static void activarUsuariosCSO(List<Id> recordIds)
	{
		SEG_UsuariosCSO__c usuario;
		List<SEG_UsuariosCSO__c> lstUsuarios = new List<SEG_UsuariosCSO__c> ();
		for (Id recordId : recordIds) {
			usuario = new SEG_UsuariosCSO__c();
			usuario.Id = recordId;
			usuario.SEG_ActivoCSO__c = true;
			lstUsuarios.add(usuario);
		}
		if (lstUsuarios.size() > 0) {
			update lstUsuarios;
		}
	}
}