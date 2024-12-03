/**********************************************************************************************************************
Name:	  AV_BookManagementMTriggerHelper_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Unit test del servicio AV_BookManagementMTriggerHelper_Test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Daniel Rodriguez  	19/10/2021		Init version
1.1			DE52465		   Sandra Gómez			03/11/2021		Coverage
1.2	        AV_Query IT	   Daniel Rodríguez	    02/03/2022	        Change AV_Query to SOQL for User, Account, Contact
***********************************************************************************************************************/
@isTest
public with sharing class AV_BookManagementMTriggerHelper_Test {
    
    @TestSetup
	static void setup() {
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            Account acc = AV_TestHelper.createCaixaCenter();
            Set<String> labelProfile = new Set<String>{'Standard User', 'Usuario estándar'};
            List<Profile> prof = [SELECT Id FROM Profile WHERE Name IN  :labelProfile ];
            String username = AV_TestHelper.getEmail();
            AV_LimitBook__c cs = new AV_LimitBook__c();
            cs.AV_Limit__c= 150;
            cs.AV_LimitReassignment__c = 100;
            cs.SetupOwnerId = prof[0].Id;
            insert cs;

            User usuario = new User(
                Alias = 'tsAlias',
                Email = 'test2@test.dev',
                EmailEncodingKey = 'UTF-8',
                LastName = 'testLastName',
                LanguageLocaleKey = 'es',
                LocaleSidKey = 'es',
                TimeZoneSidKey = 'Europe/Berlin',
                ProfileId = prof[0].Id,
                UserName = username,
                AV_ExternalID__c = 'U0009006'
            );
            insert usuario;

        	Contact empleado = AV_TestHelper.createEmployee(acc, usuario);
        	
            AV_Book__c cartera= new AV_Book__c();
        	cartera.RecordTypeId = [SELECT ID FROM RECORDTYPE WHERE NAME  = 'Cartera' AND SOBJECTTYPE =	'AV_Book__c'].Id;
            cartera.Name = '100368827';
            cartera.AV_ExternalID__c = '00379BPE003';
            cartera.AV_Activa__c = 'S';
            cartera.AV_Centro__c = acc.id;
            cartera.AV_Negocio__c = 'BPA';
            insert cartera;
            
            AV_BookMember__c bookMember = new AV_BookMember__c(name='Test', AV_Cartera__c = cartera.id, AV_Cliente__c = acc.id, AV_CarteraPrincipal__c = true, AV_Activa__c = 'S');
            insert bookMember;
            
            AV_BookManagementMember__c carteraGestor= new AV_BookManagementMember__c();
            carteraGestor.AV_Cartera__c = cartera.Id;
            carteraGestor.AV_EmpleadoGestor__c = empleado.Id;
            carteraGestor.AV_ExternalID__c='00379BPE003';
            insert carteraGestor;
         }
	}
    
    @isTest
    public static void testcheckGeneralRT() {
        System.runAs(new User( Id = UserInfo.getUserId())){
            Test.startTest();
            AV_BookManagementMember__c bmm = [SELECT Id, AV_ExternalID__c FROM AV_BookManagementMember__c LIMIT 1];
            bmm.AV_ExternalID__c = '00379BPE002';
            update bmm;
            Test.stopTest();
            System.assertNotEquals(bmm, null);
        }

    }
}