/**********************************************************************************************************************
 Name:      AV_ProccessOpportunityOwnersBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_ProccessOpportunityOwnersBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR               DATE                Description
    1.0            App FSC          Sandra Gómez        27/01/2021          Init version
	1.1            App FSC          David Rufo         	10/02/2021          Fix performance problem
	1.2            App FSC          David Rufo         	11/02/2021          Improve batch for execution list users
	1.3			   FIX				Sandra Gómez		27/08/2021			Fix product opportunity

***********************************************************************************************************************/
@isTest
private class AV_ProccessOpportunityOwnersBatch_Test {
	
    @TestSetup
	static void setup() {
		
		AV_TestHelper.activateLogger();
		User u1 = AV_TestHelper.createUser(null, 'U0100001');
        User u2 = AV_TestHelper.createUser(null, 'U0100002');
        //AV_LogDebug.printLogDebug('setup', 'User1: ' + u1);
        //AV_LogDebug.printLogDebug('setup', 'User2: ' + u2);
        Contact con =  AV_TestHelper.createEmployee(null,u1);
        //AV_LogDebug.printLogDebug('setup', 'Contact: ' + con);
		
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
		Account acc = AV_TestHelper.createCustomer();
		Test.startTest();

        Product2 prodPF = AV_TestHelper.createProduct(null,null);
		RecordType rt = AV_AppUtilities.getRecordType('Opportunity', 'AV_AlertaComercial');
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.Name = 'Alerta Comercial';
		opp.AV_ExternalID__c = '00000001';
		opp.StageName = 'En gestión/insistir';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c ='Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_Gestor__c = con.Id;
		opp.OwnerId = u1.Id;
        opp.AV_PF__c = prodPF.Id;
		insert opp;
        
        con.AV_UsuarioAsociado__c = u2.Id;
        update con;
		Test.stopTest();
	}
    
	@isTest
	static void executeProccessOpportunityOwnersBatch() {
        User u2 = [SELECT Id FROM User where AV_ExternalID__c = 'U0100002'];
        Set<String> setUserIds = new Set<String>{u2.Id};
        AV_LogDebug.printLogDebug('executeProccessOpportunityOwnersBatch', 'User2: ' + u2);
        
		AV_ProccessOpportunityOwnersBatch b = new AV_ProccessOpportunityOwnersBatch('300', setUserIds);
        
		Test.startTest();
		Database.executeBatch(b);
		Test.stopTest();
        
        List<Opportunity> listOpp = [SELECT id, OwnerId FROM Opportunity];
        for (Opportunity opp : listOpp) {
            System.assertEquals(opp.OwnerId, u2.id);
        }
	}
}