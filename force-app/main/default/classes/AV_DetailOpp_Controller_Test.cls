/**********************************************************************************************************************
 Name:	  AV_DetailOpp_Controller_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para el controlador AV_DetailOpp_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE		Description
	1.0			App FSC			Esperanza Conde		13/10/2020	Test Class
	1.1			Fix				Sandra Gómez		26/08/2021	Fix product opportunity
	1.2		    AV_Query IT	    Daniel Rodríguez    03/03/2022	Change AV_Query to SOQL for User, Account, Contact
	1.3		    US385253	    Víctor Santiago     16/06/2022	Added linkOppMoreInfoTest

***********************************************************************************************************************/
@isTest
public class AV_DetailOpp_Controller_Test {

	/**
	 * Link opp to customActivityOpp
	 */
	@isTest
	public static void linkOppTest() {
		Account acc = AV_TestHelper.createCustomer();

		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;

		Opportunity opp = AV_TestHelper.createOpportunity(acc);

		Task tarea  = AV_TestHelper.createTarea(null);
		String idCabeceraTarea = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1].AV_Task__c;
		tarea.AV_Task__c = idCabeceraTarea;
        update tarea;
         
		Test.startTest();
		AV_DetailOpp_Controller.linkOpp(tarea.AV_Task__c, opp);
        Test.stopTest();
        
		AV_CustomActivityOpportunity__c tareaOpp =[Select Id From AV_CustomActivityOpportunity__c where AV_Opportunity__c = :opp.Id limit 1];
        /*AV_CustomActivityOpportunity__c tareaOpp = (AV_CustomActivityOpportunity__c) new AV_Query('AV_CustomActivityOpportunity__c')
                                                    .selectField('Id')
                                                    .addConditionEq('AV_Opportunity__c', opp.Id)
                                                    .fetch();*/
      
        System.assert(tareaOpp != Null);

    }

	@isTest
	public static void linkOppMoreInfoTest() {
		Account acc = AV_TestHelper.createCustomer();

		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;

		Opportunity opp = AV_TestHelper.createOpportunity(acc);

		Task tarea  = AV_TestHelper.createTarea(null);
		String idCabeceraTarea = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1].AV_Task__c;
		tarea.AV_Task__c = idCabeceraTarea;
        update tarea;
        AV_ListOpportunities_Controller.RecordInfo wrapper = new AV_ListOpportunities_Controller.RecordInfo();
		wrapper.taskHeader = tarea.AV_Task__c;
		wrapper.accountId = acc.Id;
		wrapper.activityId = tarea.Id;
		wrapper.activityDate = tarea.ActivityDate;
		wrapper.status = tarea.Status;
		Test.startTest();
		AV_DetailOpp_Controller.linkOpp(JSON.serialize(wrapper), opp);
        Test.stopTest();
        
		AV_CustomActivityOpportunity__c tareaOpp =[Select Id From AV_CustomActivityOpportunity__c where AV_Opportunity__c = :opp.Id limit 1];
      
        System.assert(tareaOpp != Null);
	}

}