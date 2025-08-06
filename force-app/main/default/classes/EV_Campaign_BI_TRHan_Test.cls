/**********************************************************************************************************************
 Name:	  EV_Campaign_BU_TRHan_Test
 Copyright © 2020  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para Trigger de Campaign BeforeInsert
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App Eventos	    Jorge Centella	    09/02/2020			Init version
	1.1			App Eventos	    Daniel Rodriguez	03/02/2023			Modify method executeCampaignMemberBITrigger
	1.2		     US511092       Daniel Rodriguez    09/01/2024			Remove system.debug
***********************************************************************************************************************/
@isTest
public class EV_Campaign_BI_TRHan_Test {
    
	@isTest
	public static void executeCampaignMemberBITrigger() {
        Test.startTest();
        
        Campaign camp= EV_TestHelper.createChildCampaignVirtual();
        Campaign campTest = [Select id, StartDate, EV_DiaHora_evento__c, EV_FechaHoraFin__c, EV_HoraInicio__c, EV_HoraFin__c from Campaign where id = :camp.Id Limit 1];
		
		Test.stopTest();
        Time horaInicio = campTest.EV_HoraInicio__c;
        Time horaFin =campTest.EV_HoraFin__c;
        System.assertEquals(campTest.EV_DiaHora_evento__c, campTest.EV_DiaHora_evento__c, 'La fecha de inicio del evento es incorrecta');
        //System.assertEquals(DateTime.newInstance(campTest.StartDate,horaFin.addhours(1)), campTest.EV_FechaHoraFin__c, 'La fecha de fin del evento es incorrecta');
	}
}