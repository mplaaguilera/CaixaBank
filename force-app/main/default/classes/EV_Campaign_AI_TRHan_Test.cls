/**********************************************************************************************************************
 Name:	  EV_Campaign_AI_TRHan_Test
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de Test para Trigger de CampaignMember BeforeUpdate
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App Eventos	    Jorge Centella	    29/10/2020			Init version

***********************************************************************************************************************/
@isTest

public with sharing class EV_Campaign_AI_TRHan_Test {

    @isTest
	public static void executeCampaignAITrigger() {
		Test.startTest();

		Campaign camp = EV_TestHelper.createChildCampaignVirtual();		
		Test.stopTest();
        System.assertEquals(camp.EV_ExternalID__c != null, camp.EV_ExternalID__c != null, 'El external ID es incorrecto');
    }
    
    @isTest
	public static void executegenerarTraduccionesEventoHijo() {
		Test.startTest();
        Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoVirtual').getRecordTypeId();

        Campaign camp = EV_TestHelper.createParentCampaignVirtual();
        List<EV_TraduccionDeEvento__c> lstTraducciones = EV_TestHelper.createTraduccionesDeEvento(camp.Id);

        Campaign campVirtual = new Campaign(
			Name = 'TestCampaign',
            RecordTypeId = rtEvento,
            ParentId= camp.Id
        ); 
        insert campVirtual;

        List<EV_TraduccionDeEvento__c> lstTraduccionesChild = [Select id, EV_Idioma__c, EV_Descripcion__c, EV_Evento__c from EV_TraduccionDeEvento__c where EV_Evento__c =: campVirtual.Id];
        
        List<EV_TraduccionDeEvento__c> lstAuxAssert = lstTraducciones.clone();

        for(EV_TraduccionDeEvento__c trad : lstAuxAssert){
            trad.EV_Evento__c = campVirtual.Id;
        }

        System.assertEquals(lstAuxAssert[0].EV_Evento__c, lstTraduccionesChild[0].EV_Evento__c, 'Las traducciones no se han generado correctamente');
        
		Test.stopTest();
	}
}