@isTest
private class CBK_LWC_ChangeOwner_Controller_Test{
	@testSetup
    static void setup()
    {
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id,
            LastName = 'Administrator',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
        insert user;
    }

	@isTest
	private static void testGetRegistros() {
		User usr = [SELECT id FROM User WHERE LastName = 'Administrator' LIMIT 1];
        Test.startTest();
        System.runAs (usr ) {
			CBK_Adoption_FWK__c cbkAdop = new CBK_Adoption_FWK__c();
			cbkAdop.CBK_FWK_Name__c = 'Framework';
			cbkAdop.CBK_Project__c = 'CBK';
			cbkAdop.RecordTypeId =  Schema.getGlobalDescribe().get('CBK_Adoption_FWK__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Information').getRecordTypeId();
			cbkAdop.OwnerId = usr.Id;
			insert cbkAdop; 

			Case caso = new Case();
			caso.Origin = 'phone';
			caso.Description = 'test1';
			caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
			caso.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
			caso.CC_Tipo_Contacto__c = 'Asesoramiento';
			insert caso;

			//Change Owner by User
			List<SObject> lstSobj = CBK_LWC_ChangeOwner_Controller.getRegistros('Usuario', '', 'CBK', cbkAdop.Id);
			System.debug('Users: ' + JSON.serializePretty(lstSobj));
			SObject selectedItem;
			for (SObject item : lstSobj){
				if (item.getSObject('Assignee').get('Name') == 'Administrador de sistema 2'){
					selectedItem =  item;
					break;
				}
			}
			String result = CBK_LWC_ChangeOwner_Controller.functionChangeOwner(selectedItem, cbkAdop.Id);
			List<CBK_Adoption_FWK__c> lstcbkAdop = [SELECT Id, OwnerId, Owner.Name, Name FROM CBK_Adoption_FWK__c WHERE Id =:cbkAdop.Id Limit 1];
			System.assertEquals(selectedItem.getSObject('Assignee').get('Id'), lstcbkAdop[0].OwnerId, 'Error al cambiar de usuario');

			//Change Owner by Queue
			lstSobj = CBK_LWC_ChangeOwner_Controller.getRegistros('Cola', '', 'CBK', caso.Id);
			for (SObject item : lstSobj){
				if (item.getSObject('Queue').get('Name') == 'Accionistas'){
					selectedItem =  item;
					break;
				}
			}
			result = CBK_LWC_ChangeOwner_Controller.functionChangeOwner(selectedItem, caso.Id);
			List<Case> lstcase = [SELECT Id, OwnerId, Owner.Name FROM case WHERE Id =:caso.Id Limit 1];
			System.assertEquals(selectedItem.getSObject('Queue').get('Id'), lstcase[0].OwnerId, 'Error al cambiar de queue');

			//Error ChangeOwner
			result = CBK_LWC_ChangeOwner_Controller.functionChangeOwner(selectedItem, cbkAdop.Id);
			System.assertEquals(result, 'KO', 'Error al cambiar de queue');
		}
		Test.stopTest();
	}
	@isTest
	private static void masivoChangeOwner(){
		list<CBK_Adoption_FWK__c> lstcbkAdop = new List<CBK_Adoption_FWK__c>();
		CBK_ScheduleControls__c schInf = new CBK_ScheduleControls__c(name = 'ScheduleInfo', Retries__c = 0, ExecutionPeriod__c = 1, Date_Last_Execution__c = datetime.now() );
		insert schInf;
		CBK_Adoption_FWK__c cbkAdop; 
		User usr = [SELECT id FROM User WHERE LastName = 'Administrator' LIMIT 1];
		for(Integer  i = 0; i <= 11; i++){
			cbkAdop = new CBK_Adoption_FWK__c();
			cbkAdop.CBK_FWK_Name__c = 'Framework Test ' + i;
			cbkAdop.CBK_Project__c = 'CBK';
			cbkAdop.RecordTypeId =  Schema.getGlobalDescribe().get('CBK_Adoption_FWK__c').getDescribe().getRecordTypeInfosByDeveloperName().get('Information').getRecordTypeId();
			cbkAdop.OwnerId = usr.Id;
			lstcbkAdop.add(cbkAdop);
		}

		Database.SaveResult[] lstResp = Database.insert(lstcbkAdop, false);
		List<string> lstId = new List<string>();

		for(Database.SaveResult res : lstResp){
			lstId.add(res.id);
		}

		List<SObject> lstSobj = CBK_LWC_ChangeOwner_Controller.getRegistros('Usuario', '', 'CBK', lstcbkAdop[0].Id);
		SObject selectedItem;
		for (SObject item : lstSobj){
			if (item.getSObject('Assignee').get('Name') == 'Administrador de sistema 2'){
				selectedItem =  item;
				break;
			}
		}

		String result = CBK_LWC_ChangeOwner_Controller.functionChangeOwner(selectedItem, string.join(lstId, ','));
		System.assertEquals(result, 'OK', 'Registros creado en schedule');

		lstcbkAdop = [SELECT Id FROM CBK_Adoption_FWK__c WHERE Id IN :lstId];
		System.assertEquals(lstcbkAdop.size(), lstId.size(), 'Registros pendientes a schedular');

		Case caso = new Case();
		caso.Origin = 'phone';
		caso.Description = 'test1';
		caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
		caso.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
		caso.CC_Tipo_Contacto__c = 'Asesoramiento';
		insert caso;

		lstSobj = CBK_LWC_ChangeOwner_Controller.getRegistros('Cola', '', 'CBK', caso.Id);
		for (SObject item : lstSobj){
			if (item.getSObject('Queue').get('Name') == 'Accionistas'){
				selectedItem =  item;
				break;
			}
		}
		String resCreate = CBK_LWC_ChangeOwner_Controller.createScheduleRegister(lstId, selectedItem);
		System.assertEquals(result, 'OK', 'Registros creado en schedule');
	}
}