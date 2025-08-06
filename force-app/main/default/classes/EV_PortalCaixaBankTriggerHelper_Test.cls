/**********************************************************************************************************************
 Name:  EV_PortalCaixaBankTriggerHelper_Test
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test para el Trigger Helper del objeto EV_PortalCaixaBankTalks__c
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
  VERSION	USER_STORY		AUTHOR				DATE			Description
  1.0		US633077		Mamen Arias			29/09/2023		Init version
  1.1		US854993		Carolina Lopez		10/04/2024		Add method transferDateVisibilityTest.
***********************************************************************************************************************/
@isTest
public with sharing class EV_PortalCaixaBankTriggerHelper_Test {
	@isTest
	public static void transferDateVisibilityTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign campTest = new Campaign();
		EV_PortalCaixaBankTalks__c qportal = new EV_PortalCaixaBankTalks__c();
		System.runAs(newUser){
			campTest = EV_TestHelper.createChildCampaignVirtualCMCustom();
			campTest.EV_Fechadespublicacion__c = Date.newInstance(2024, 4, 4);
			update campTest;
		}
		Test.startTest();
		System.runAs(newUser){
			EV_PortalCaixaBankTalks__c portal = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '001', EV_Orden__c= '1' , EV_Evento__c = campTest.Id);
			insert portal;

			qportal = [SELECT Id, EV_Orden__c, EV_Fechadespublicacion__c, EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Evento__c = :campTest.Id];	
		}
		Test.stopTest();
		System.assertEquals(qportal.EV_Fechadespublicacion__c, Date.valueOf('2024-04-04'));
	}

	@isTest
	public static void  checkExistDestacadosTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign campTest = new Campaign();
		Campaign campTest2 = new Campaign();
		EV_PortalCaixaBankTalks__c qportal = new EV_PortalCaixaBankTalks__c();

		System.runAs(newUser){
			campTest = EV_TestHelper.createChildCampaignVirtual();
			campTest2 = EV_TestHelper.createChildCampaignFisica();
		}
		
		Test.startTest();
		System.runAs(newUser){
			EV_PortalCaixaBankTalks__c portal = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '001', EV_Orden__c= '1' , EV_Evento__c = campTest.Id);
			insert portal;
			EV_PortalCaixaBankTalks__c portal2 = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '001', EV_Orden__c= '1' , EV_Evento__c = campTest2.Id);
			insert portal2;
			qportal = [SELECT Id, EV_Orden__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Evento__c = :campTest.Id];	
		}
		Test.stopTest();
		System.assertEquals(qportal.EV_Orden__c, '2');
	}

	@isTest
	public static void  checkExistUltimosTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign campTest = new Campaign();
		Campaign campTest2 = new Campaign();
		EV_PortalCaixaBankTalks__c qportal = new EV_PortalCaixaBankTalks__c();

		System.runAs(newUser){
			campTest = EV_TestHelper.createChildCampaignVirtual();
			campTest2 = EV_TestHelper.createChildCampaignFisica();
		}
		
		Test.startTest();
		System.runAs(newUser){
			EV_PortalCaixaBankTalks__c portal = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '004', EV_Orden__c= '1' , EV_Evento__c = campTest.Id);
			insert portal;
			EV_PortalCaixaBankTalks__c portal2 = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '004', EV_Orden__c= '1' , EV_Evento__c = campTest2.Id);
			insert portal2;
			qportal = [SELECT Id, EV_Orden__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Evento__c = :campTest.Id];
		}
		Test.stopTest();
		System.assertEquals(qportal.EV_Orden__c, '2');
	}

	@isTest
	public static void  checkExistMayorDiezTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign campTest = new Campaign();
		Campaign campTest2 = new Campaign();
		EV_PortalCaixaBankTalks__c qportal = new EV_PortalCaixaBankTalks__c();

		System.runAs(newUSer){
			Id rtEvento = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoFisico').getRecordTypeId();
			campTest = EV_TestHelper.createChildCampaignVirtual();
			campTest2 = EV_TestHelper.createChildCampaignFisica();
		}
		
		Test.startTest();
		System.runAs(newUser){
			EV_PortalCaixaBankTalks__c portal = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '004', EV_Orden__c= '10' , EV_Evento__c = campTest.Id);
			insert portal;
			EV_PortalCaixaBankTalks__c portal2 = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '004', EV_Orden__c= '10' , EV_Evento__c = campTest2.Id);
			insert portal2;
			EV_PortalCaixaBankTalks__c portal3 = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '001', EV_Orden__c= '10' , EV_Evento__c = campTest.Id);
			insert portal3;
			EV_PortalCaixaBankTalks__c portal4 = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '001', EV_Orden__c= '10' , EV_Evento__c = campTest2.Id);
			insert portal4;
			qportal = [SELECT Id, EV_Orden__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Evento__c = :campTest2.Id AND EV_Posicionamiento__c = '004'];
		}
		Test.stopTest();
		System.assertEquals(qportal.EV_Orden__c, '10');
	}

	@isTest
	public static void checkDuplicateDestacadosTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign campTest = new Campaign();

		System.runAs(newUser){
			campTest = EV_TestHelper.createChildCampaignVirtual();
		}
		
		Test.startTest();
		System.runAs(newUser){
			EV_PortalCaixaBankTalks__c portal = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '001', EV_Orden__c= '1' , EV_Evento__c = campTest.Id);
			insert portal;
			EV_PortalCaixaBankTalks__c portal2 = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '001', EV_Orden__c= '1' , EV_Evento__c = campTest.Id);
			try{
				insert portal2;
			} catch (Exception e){
				Test.stopTest();
				System.assertEquals(e.getMessage().contains('Ya existe un objeto portal "Destacado home" en el evento'), true);
			}
		}
	}

	@isTest
	public static void checkDuplicateUltimosTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign campTest = new Campaign();

		System.runAs(newUser){
			campTest = EV_TestHelper.createChildCampaignVirtual();
		}
		
		Test.startTest();
		System.runAs(newUser){
			EV_PortalCaixaBankTalks__c portal = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '004', EV_Orden__c= '1' , EV_Evento__c = campTest.Id);
			insert portal;
			EV_PortalCaixaBankTalks__c portal2 = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '004', EV_Orden__c= '1' , EV_Evento__c = campTest.Id);
			try{
				insert portal2;
			} catch (Exception e){
				Test.stopTest();
				System.assertEquals(e.getMessage().contains('Ya existe un objeto portal "Ultimos añadidos" en el evento'), true);
			}
		}
	}

	@isTest
	public static void checkValueOrderTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
		Campaign campTest = new Campaign();

		System.runAs(newUser){
			campTest = EV_TestHelper.createChildCampaignVirtual();
		}
		
		Test.startTest();
		System.runAs(newUser){
			EV_PortalCaixaBankTalks__c portal = new EV_PortalCaixaBankTalks__c(EV_Posicionamiento__c = '004', EV_Orden__c= null , EV_Evento__c = campTest.Id);
			try{
				insert portal;
			} catch (Exception e){
				Test.stopTest();
				System.assertEquals(e.getMessage().contains('Debe seleccionar un valor para el campo Orden.'), true);
			}
		}
	}
}