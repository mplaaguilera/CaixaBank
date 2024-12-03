/**********************************************************************************************************************************************************************************************
Name:	  CIBE_NewEventOppDetail_Controller_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test de "CIBE_NewEventOppDetail_Controller"
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Historial
------------------------
VERSION     USER_STORY              AUTHOR              DATE            Description
1.0                                 Álvaro y Lucía                      Init version
1.1         US774293                Bea                 12/02/2024      Se añaden los test geCountRelated_Test, getOpportunitiesFromEvent_Test, getAccountId_Test, updateChecked_Test, updateCanceled_Test, updateClosed_Test, vinculateOpportunity_Test, disVinculateOpportunity_Test y makePrincipal_Test.
1.2                                 Lucía               30/10/2024      Se añaden los test getOpportunitiesFromEventGCTest, getAccountOpportunitiesGCTest, getActivityDateTest

**********************************************************************************************************************************************************************************************/
@isTest
public with sharing class CIBE_NewEventOppDetail_Controller_Test {
    @TestSetup
    static void makeData(){
        CIBE_TestInitialSetup.setupInitialDataEMP();

        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];

        System.runAs(usrSetup){ 
            Test.startTest();
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account acc = new Account(
                Name = 'Name',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '123',
                AV_Negocio__c = 'CIB',
                OwnerId = usuario.Id
            );
            insert acc;
            RecordType rtOpp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
            Opportunity opp = new Opportunity();
                opp.AccountId = acc.Id;
                opp.Name = 'Alerta Comercial';
                opp.StageName = 'Potencial';
                opp.RecordTypeId = rtOpp.Id;
                opp.CloseDate = System.today() + 5;
                opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
                opp.OwnerId = usuario.Id;
                opp.AV_ToDelete__c = false;
            insert opp;
            CIBE_TestHelper.createEvent(usuario, System.now(), acc);
            Event ev1 = CIBE_TestHelper.createEvent(usuario, System.now(), acc);
                ev1.Subject = 'Prueba';
            update ev1;

            AV_CustomActivityOpportunity__c cao = new AV_CustomActivityOpportunity__c();
                cao.AV_Task__c = ev1.AV_Task__c;
                cao.AV_Opportunity__c = opp.Id;
                cao.AV_IsMain__c = false;
            insert cao;

            Test.stopTest();
        }    
    }

    @IsTest
    static void getAccountOpportunitiesTest(){
        
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Account acc = [SELECT Id FROM Account WHERE Name = 'Name' AND CreatedDate = TODAY];
            List<CIBE_NewEventOppDetail_Controller.OpportunityWrapper>  wrap =  CIBE_NewEventOppDetail_Controller.getAccountOpportunities(acc.Id);
            System.assert(!wrap.isEmpty());

        }
        Test.stopTest();
    }


    @IsTest
    static void geCountRelatedTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Event ev1 = [SELECT Id FROM Event WHERE Subject = 'Prueba' AND OwnerId = :usuario.Id LIMIT 1];
            Integer numRel =  CIBE_NewEventOppDetail_Controller.geCountRelated(ev1.Id);
            System.assert(numRel != 0);

        }
        Test.stopTest();
    }


    @IsTest
    static void getOpportunitiesFromEventTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Event ev1 = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Prueba' AND OwnerId = :usuario.Id LIMIT 1];
            List<CIBE_NewEventOppDetail_Controller.OpportunityWrapper> listOppWr =  CIBE_NewEventOppDetail_Controller.getOpportunitiesFromEvent(ev1.Id);
            System.assert(!listOppWr.isEmpty());

        }
        Test.stopTest();
    }

    @IsTest
    static void getAccountIdTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Event ev = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Prueba' AND OwnerId = :usuario.Id LIMIT 1];
            Event evt =  CIBE_NewEventOppDetail_Controller.getAccountId(ev.Id);
            System.assertNotEquals(null, evt);

        }
        Test.stopTest();
    }

    @IsTest
    static void updateCheckedTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE OwnerId = :usuario.Id LIMIT 1];
            CIBE_NewEventOppDetail_Controller.updateChecked(opp.Id);
            Opportunity opp2 = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            System.assertEquals('CIBE_Cerrado positivo', opp2.StageName);

        }
        Test.stopTest();
    }

    @IsTest
    static void updateCanceledTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Opportunity opp = [SELECT Id, StageName, CIBE_CerradoNegativo__c FROM Opportunity WHERE OwnerId = :usuario.Id LIMIT 1];
            CIBE_NewEventOppDetail_Controller.updateCanceled(opp.Id);
            Opportunity opp2 = [SELECT Id, StageName, CIBE_CerradoNegativo__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            System.assertEquals('Cerrado negativo', opp2.StageName);
            System.assertEquals('Anulada', opp2.CIBE_CerradoNegativo__c);

        }
        Test.stopTest();
    }

    @IsTest
    static void updateClosedTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Opportunity opp = [SELECT Id, StageName, CIBE_CerradoNegativo__c FROM Opportunity WHERE OwnerId = :usuario.Id LIMIT 1];
            String cerradoNegativo = 'Competencia';
            CIBE_NewEventOppDetail_Controller.updateClosed(opp.Id, cerradoNegativo);
            Opportunity opp2 = [SELECT Id, StageName, CIBE_CerradoNegativo__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            System.assertEquals('Cerrado negativo', opp2.StageName);
            System.assertEquals('Competencia', opp2.CIBE_CerradoNegativo__c);

        }
        Test.stopTest();
    }

    @IsTest
    static void vinculateOpportunityTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Event ev1 = [SELECT Id, AV_Task__c, AccountId FROM Event WHERE Subject = 'Prueba' AND OwnerId = :usuario.Id LIMIT 1];
            Opportunity opp = [SELECT Id, StageName, CIBE_CerradoNegativo__c FROM Opportunity WHERE OwnerId = :usuario.Id LIMIT 1];
            CIBE_NewEventOppDetail_Controller.vinculateOpportunity(ev1.Id, opp.Id);
            AV_CustomActivityOpportunity__c cao = [SELECT Id FROM  AV_CustomActivityOpportunity__c LIMIT 1];
            System.assertNotEquals(null, cao);

        }
        Test.stopTest();
    }

    @IsTest
    static void disVinculateOpportunityTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Event ev1 = [SELECT Id FROM Event WHERE  Subject = 'Prueba' AND OwnerId = :usuario.Id LIMIT 1];
            Opportunity opp = [SELECT Id, StageName, CIBE_CerradoNegativo__c FROM Opportunity WHERE OwnerId = :usuario.Id LIMIT 1];

        
            CIBE_NewEventOppDetail_Controller.disVinculateOpportunity(ev1.Id, opp.Id);
            List <AV_CustomActivityOpportunity__c> cao = [SELECT Id FROM  AV_CustomActivityOpportunity__c LIMIT 1];
            System.assert(cao.isEmpty());

        }
        Test.stopTest();
    }

    @IsTest
    static void makePrincipalTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        User usuario2 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];
        Test.startTest();
        System.runAs(usuario2){ 
            Event ev1 = [SELECT Id, AV_Task__c FROM Event WHERE OwnerId = :usuario.Id AND Subject = 'Prueba' LIMIT 1];
            Opportunity opp = [SELECT Id, StageName, CIBE_CerradoNegativo__c FROM Opportunity WHERE OwnerId = :usuario.Id LIMIT 1];
            CIBE_NewEventOppDetail_Controller.makePrincipal(ev1.Id, opp.Id);
            AV_CustomActivityOpportunity__c cao2 = [SELECT Id,  AV_IsMain__c FROM  AV_CustomActivityOpportunity__c LIMIT 1];
            System.assertNotEquals(false, cao2.AV_IsMain__c);

        }
        Test.stopTest();
    }

    @IsTest
    static void getActivityDateTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Event ev1 = [SELECT Id, AV_Task__c FROM Event WHERE OwnerId = :usuario.Id AND Subject = 'Prueba' LIMIT 1];
            Boolean value = CIBE_NewEventOppDetail_Controller.getActivityDate(ev1.Id);
            System.assertNotEquals(true, value);

        }
        Test.stopTest();
    }


    @IsTest
    static void getAccountOpportunitiesGCTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Account acc = [SELECT Id FROM Account WHERE Name = 'Name' AND CreatedDate = TODAY];
            List<String> value = new List<String>{acc.Id};
            List<CIBE_NewEventOppDetail_Controller.OpportunityAccWrapper>  wrap =  CIBE_NewEventOppDetail_Controller.getAccountOpportunitiesGC(value);
            System.assert(!wrap.isEmpty());
        }
        Test.stopTest();
    }



    @IsTest
    static void getOpportunitiesFromEventGCTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(usuario){ 
            Account acc = [SELECT Id FROM Account WHERE Name = 'Name' AND CreatedDate = TODAY];
            List<String> value = new List<String>{acc.Id};
            Event ev1 = [SELECT Id, AV_Task__c FROM Event WHERE Subject = 'Prueba' AND OwnerId = :usuario.Id LIMIT 1];
            List<CIBE_NewEventOppDetail_Controller.OpportunityAccWrapper> listOppWr =  CIBE_NewEventOppDetail_Controller.getOpportunitiesFromEventGC(ev1.Id, value);
            System.assert(!listOppWr.isEmpty());
        }
        Test.stopTest();
    }
}