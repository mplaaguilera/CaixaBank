/**********************************************************************************************************************
 Name:	  EV_Campaign_BU_TRHan_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para Trigger de Campaign BeforeUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App Eventos	    Jorge Centella	    09/02/2020			Init version

***********************************************************************************************************************/
@isTest
public class EV_Campaign_BU_TRHan_Test {
    
	@isTest
	public static void executeCampaignMemberBUTrigger() {
        Test.startTest();
        
        Campaign camp= EV_TestHelper.createChildCampaignVirtual();
        Campaign campTest = [Select id, StartDate, EV_DiaHora_evento__c, EV_FechaHoraFin__c, EV_HoraInicio__c, EV_HoraFin__c from Campaign where id = :camp.Id Limit 1];

        campTest.StartDate = Date.newInstance(2021,03,16);
        update campTest;

        campTest = [Select id, StartDate, EV_DiaHora_evento__c, EV_FechaHoraFin__c, EV_HoraInicio__c, EV_HoraFin__c from Campaign where id = :camp.Id Limit 1];

        System.assertEquals(DateTime.newInstance(campTest.StartDate,campTest.EV_HoraInicio__c), campTest.EV_DiaHora_evento__c, 'La fecha de inicio del evento es incorrecta');
        System.assertEquals(DateTime.newInstance(campTest.StartDate,campTest.EV_HoraFin__c), campTest.EV_FechaHoraFin__c, 'La fecha de fin del evento es incorrecta');
		
		Test.stopTest();
	}

    @isTest
	public static void newFlowACTest() {
        
        
        Campaign campTest = EV_TestHelper.createChildCampaignVirtual();
		//Set<String> setFieldsCampaign = new Set<String>{'Id', 'EV_URLChatVirtual__c','Status'};
		List<Campaign> listCampaign = [SELECT Id, EV_URLChatVirtual__c, Status FROM Campaign LIMIT 1];
        List<EV_TraduccionDeEvento__c> traductTest = EV_TestHelper.createTraduccionesDeEvento(campTest.Id);
		//Set<String> setFieldsTraduct = new Set<String>{'Id', 'EV_URLImagenEsperaStreaming__c', 'EV_URLVideoTeaser__c', 'EV_Evento__c'};
		List<EV_TraduccionDeEvento__c> listTraduct = [SELECT Id, EV_URLImagenEsperaStreaming__c, EV_URLVideoTeaser__c, EV_Evento__c FROM EV_TraduccionDeEvento__c LIMIT 1];

		Test.startTest();
		listCampaign[0].Status = '009';
		update listCampaign;
		System.assertEquals('009', listCampaign[0].Status);
		Test.stopTest();
	}
}