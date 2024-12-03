/**********************************************************************************************************************
 Name:      CIBE_ProccessOpportunityOwnersBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase CIBE_ProccessOpportunityOwnersBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR               DATE                Description
    1.0           US639303        Bea      				01/08/2023        	Init version

***********************************************************************************************************************/
@isTest
private class CIBE_ProccessOpportunityOwnersBatch_Test {
	
    @TestSetup
	static void setup() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
			
            User usrTest1 = CIBE_TestHelper.createUser('CIBE_Gestor');
			usrTest1.AV_ExternalID__c = 'U0009003';
			update usrTest1;
			User usrTest2 = CIBE_TestHelper.createUser('CIBE_Gestor');
			usrTest2.AV_ExternalID__c = 'U0009004';
			update usrTest2;

            Contact empleado = new Contact();
            empleado.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            empleado.LastName = 'Prueba 1';
            empleado.Phone = '987456321';
			empleado.CC_Matricula__c = 'U0009003';
			empleado.AV_UsuarioAsociado__c = usrTest1.Id;
			empleado.AV_DescFuncion__c = 'EMPLEADO';
            insert empleado;

        
		RecordType rt = AV_AppUtilities.getRecordType('Opportunity', 'CIBE_AccionComercialCIB');
		Opportunity opp = new Opportunity();
		opp.Name = 'Alerta Comercial';
		opp.StageName = 'En gestión/insistir';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c ='Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_Gestor__c = empleado.Id;
		opp.OwnerId = usrTest1.Id;
		insert opp;
        
        empleado.AV_UsuarioAsociado__c = usrTest2.Id;
        update empleado;
	}
}  
	@isTest
	static void executeProccessOpportunityOwnersBatch() {
		
		System.runAs(new User(Id = UserInfo.getUserId())) {
			
			User usrTest2 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009004'];
			Set<String> setUserIds = new Set<String>{usrTest2.Id};
			
			CIBE_ProccessOpportunityOwnersBatch b = new CIBE_ProccessOpportunityOwnersBatch('300', setUserIds);
			
			Test.startTest();
			Database.executeBatch(b);
			Test.stopTest();
			
			List<Opportunity> listOpp = [SELECT id, OwnerId FROM Opportunity];
			for (Opportunity opp : listOpp) {
				System.assertEquals(opp.OwnerId, usrTest2.id);
			}
		}
	}
}