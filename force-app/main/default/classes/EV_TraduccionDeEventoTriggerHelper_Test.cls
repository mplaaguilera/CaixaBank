/**********************************************************************************************************************
 Name:	EV_TraduccionDeEventoTriggerHelper_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Test de EV_TraduccionEventosTriggerHelper
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			                    Mamen Arias 		28/11/2022			Init version

***********************************************************************************************************************/
@isTest
public with sharing class EV_TraduccionDeEventoTriggerHelper_Test {
    @isTest
	public static void checkInsertTraduccionDuplicada(){
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoFisico').getRecordTypeId();
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Test.startTest();
        System.runAs(newUser){
          	Campaign campFisica = new Campaign(
			Name = 'TestCampaign',
			RecordTypeId = rtEvento,
			EV_ExternalId__c = '1234567895',
			StartDate = Date.today(),
			EV_HoraInicio__c = Time.newInstance(16, 30, 00, 00),
			EV_HoraFin__c = Time.newInstance(19, 30, 00, 00)
			); 
            insert campFisica;
    
            EV_TestHelper.createTraduccionesDeEvento(campFisica.Id);
    
            EV_TraduccionDeEvento__c traduccion3 = new EV_TraduccionDeEvento__c(
                Name = 'Traduccion castellano 2',
                EV_Evento__c = campFisica.Id,
                EV_Idioma__c = '002',
                EV_Descripcion__c = 'Traduccion castellano test, Traduccion castellano test,Traduccion castellano test,Traduccion castellano test,Traduccion castellano test,Traduccion castellano test,Traduccion castellano test,Traduccion castellano test,Traduccion castellano test,Traduccion castellano test'
            );
            try{
                insert traduccion3;
            } catch (Exception e){
                Test.stopTest();
                System.assertEquals(e.getMessage().contains('Ya existe una traducción con ese idioma. Es necesario eliminar la anterior para crear una nueva.'), true);
            }
        }
	}

	@isTest
	public static void checkUpdateTraduccion(){
		Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoFisico').getRecordTypeId();

        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Test.startTest();
        System.runAs(newUser){
            Campaign campFisica = new Campaign(
			Name = 'TestCampaign',
			RecordTypeId = rtEvento,
			EV_ExternalId__c = '1234567895',
			StartDate = Date.today(),
			EV_HoraInicio__c = Time.newInstance(16, 30, 00, 00),
			EV_HoraFin__c = Time.newInstance(19, 30, 00, 00)
			); 
            insert campFisica;
            List<EV_TraduccionDeEvento__c> listTraducciones = EV_TestHelper.createTraduccionesDeEvento(campFisica.Id);
            EV_TraduccionDeEvento__c traduccion2 = listTraducciones[1];
            traduccion2.EV_Idioma__c = '002';
    
            try{
                update traduccion2;
            } catch (Exception e){
                Test.stopTest();
                System.assertEquals(e.getMessage().contains('Ya existe una traducción con ese idioma. Es necesario eliminar la anterior para crear una nueva.'), true);
            }
        }
	}
}