@isTest
private class CC_Accion_TRDisp_Test {

	@isTest
	private static void testName() {

		createObjects();
	}
	public static void createObjects()
	{
		CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
		grupoColaborador.name = 'grupoATest';
		grupoColaborador.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();

		insert grupoColaborador;

		SAC_MaestroAccionesReclamacion__c registroTareaMaestro2 = new SAC_MaestroAccionesReclamacion__c();
		registroTareaMaestro2.SAC_Descripcion__c = 'Rellenar Formulario';
		registroTareaMaestro2.SAC_EquipoResponsable__c = grupoColaborador.id;
		registroTareaMaestro2.SAC_PlazoMaximo__c = 2;
		registroTareaMaestro2.RecordTypeId = Schema.SObjectType.SAC_MaestroAccionesReclamacion__c.getRecordTypeInfosByDeveloperName().get('SAC_MaestroAcciones').getRecordTypeId();
		registroTareaMaestro2.SAC_Prorroga__c = 2;
		registroTareaMaestro2.SAC_Activo__c = true;
		insert registroTareaMaestro2;

		SAC_Accion__c tareaParaModificar = new SAC_Accion__c();
		//tareaParaModificar.SAC_EquipoResponsable__c = grupoColaborador.id;
		tareaParaModificar.SAC_MaestroAccionesReclamacion__c = registroTareaMaestro2.id;
		insert tareaParaModificar;
	}
}