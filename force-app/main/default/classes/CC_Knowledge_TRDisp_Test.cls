@isTest
private class CC_Knowledge_TRDisp_Test {

	@isTest
	private static void insertData() {
		Knowledge__kav kn = createObjects();
		insert kn;
	}

	@isTest
	private static void UpdateData() {

		Knowledge__kav kn = createObjects();
		insert kn;
		update kn;
	}

	public static Knowledge__kav createObjects()
	{
		String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
		CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
		oGrupo.RecordTypeId = sRecordType3;
		oGrupo.Name = 'Grupo1';
		oGrupo.CC_External__c = 'GC-00001';
		insert oGrupo;

		Account cuenta = new Account();
		cuenta.Name = 'PRUEBA TEST';
		 cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
		insert cuenta;

		Contact contacto = new Contact();
		contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
		contacto.FirstName = 'Test';
		contacto.LastName = 'Prueba';
		contacto.Email = 'mp@test.com';
		contacto.AccountId = cuenta.Id;
		insert contacto;

		        
        Datetime fecha = Datetime.now();
        Datetime fechaInicio = fecha.addHours(2);
        Datetime fechaCaducidad = fecha.addHours(10);

		Knowledge__kav articulo = new Knowledge__kav();
		articulo.URLName = 'Apex-Test' + System.now().getTime();
		articulo.Title = 'Articulo test';
		articulo.CC_Fecha_Inicio_Publicacion__c = fechaInicio;
        articulo.CC_Fecha_Caducidad__c = fechaCaducidad;
		articulo.CC_Responsable_Externo__c = contacto.Id;
		articulo.ValidationStatus = 'Validado';
		return articulo;
	}
}