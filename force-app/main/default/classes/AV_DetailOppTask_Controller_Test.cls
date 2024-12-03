/**********************************************************************************************************************
 Name:	  AV_DetailOppTask_Controller_Test
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de Test para el controlador AV_DetailOppTask_Controller
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY					AUTHOR				DATE				Description
	1.0			App FSC						Esperanza Conde		13/10/2020			Test Class
	1.1			Palabras prohibidas			Álvaro Lóepz		26/11/2020			Added TestSetup and validateForbWordsTest method
	1.2			Fix							Sandra Gómez		26/08/2021			Fix product opportunity
	1.3		    AV_Query IT	       			Daniel Rodríguez    03/03/2022	        Change AV_Query to SOQL for User, Account, Contact
	1.4			Cambio de logica			Ángel Medina 		22/01/2024			Modified method updateMainRecordTest
***********************************************************************************************************************/
@isTest
public class AV_DetailOppTask_Controller_Test {

	@TestSetup
	static void setup(){
		List<CBK_ForbiddenWord__c> listWords = new List<CBK_ForbiddenWord__c>();
		CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
		listWords.add(word);
		CBK_ForbiddenWord__c word2 = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'CHANTAJE', CBK_TIPAVI__c = 'A', CBK_IsActive__c = true);
		listWords.add(word2);
		Database.insert(listWords, false);
	}
	
	@isTest
	public static void updateMainRecordTest() {
		Test.startTest();
		Account acc = AV_TestHelper.createCustomer();

		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;

		Opportunity opp = AV_TestHelper.createOpportunity(acc);
		Task tarea  = AV_TestHelper.createTarea(null);
		String idCabeceraTarea = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1].AV_Task__c;
		tarea.AV_Task__c = idCabeceraTarea;
		update tarea;

        AV_CustomActivityOpportunity__c testOptyTask1 = new AV_CustomActivityOpportunity__c(AV_Opportunity__c = opp.Id, AV_Task__c = idCabeceraTarea, AV_IsMain__c = false);
        AV_CustomActivityOpportunity__c testOptyTask2 = new AV_CustomActivityOpportunity__c(AV_Opportunity__c = opp.Id, AV_Task__c = idCabeceraTarea, AV_IsMain__c = true);

        insert new List<AV_CustomActivityOpportunity__c>{testOptyTask1, testOptyTask2};

        AV_DetailOppTask_Controller.updateMainRecord(opp, idCabeceraTarea);

        List<AV_CustomActivityOpportunity__c> listupdate = [SELECT Id, AV_Opportunity__c, AV_IsMain__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c = :opp.Id AND AV_IsMain__c = true];

        System.assertEquals(true, listupdate[0].AV_IsMain__c);
		Test.stopTest();	
		AV_DetailOppTask_Controller.unlinkOpp(opp, idCabeceraTarea);
	}

	
	@isTest
	public static void validateForbWordsTestE() {
		Test.startTest();
		String result = AV_DetailOppTask_Controller.validateForbWords(new List<String>{'prueba abellots', 'test chantaje'});
		AV_DetailOppTask_Controller.FBMessage message = (AV_DetailOppTask_Controller.FBMessage) JSON.deserialize(result, AV_DetailOppTask_Controller.FBMessage.class);
		Test.stopTest();

		System.assertEquals('E', message.type, 'El tipo de error no es correcto.');
	}

	@isTest
	public static void validateForbWordsTestA() {
		Test.startTest();
		String result = AV_DetailOppTask_Controller.validateForbWords(new List<String>{'prueba chantaje', 'test chantaje'});
		AV_DetailOppTask_Controller.FBMessage message = (AV_DetailOppTask_Controller.FBMessage) JSON.deserialize(result, AV_DetailOppTask_Controller.FBMessage.class);
		Test.stopTest();

		System.assertEquals('A', message.type, 'El tipo de error no es correcto.');
	}

	@isTest
	public static void validateForbWordsTestOK() {
		Test.startTest();
		String result = AV_DetailOppTask_Controller.validateForbWords(new List<String>{'prueba', 'test'});
		Test.stopTest();

		System.assertEquals('OK', result, 'Existe una palabra prohibida');
	}

}