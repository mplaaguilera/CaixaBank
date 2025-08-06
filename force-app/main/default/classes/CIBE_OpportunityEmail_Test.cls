/*****************************************************************************************
* Name: CIBE_OpportunityEmail_Test
* Copyright © 2023  CaixaBank
* 
* Proposito: test de la clase CIBE_OpportunityEmail.
* 
* -------
* VERSION        USER_STORY         AUTHOR          	DATE            Description
*   1.0            US615974           Ali               30/10/2023      Init Version
*   1.1            PPM100538662       Lucía             23/10/2024      New methods emailRequerimientoTest, emailRequerimientoTest2, getLanguageTest

******************************************************************************************/
@isTest
public with sharing class CIBE_OpportunityEmail_Test {    

    @testSetup
	static void testSetup() {
        
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        
        CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' AND (Profile.Name = 'System Administrator' or Profile.Name = 'Administrador del Sistema') LIMIT 1];
        User user = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name =: CIBE_AppConstants.CIBE_GESTOR LIMIT 1];
        Account acc = CIBE_TestHelper.createCustomer(usrSetup);
        Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
        RecordType rtOpp = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
        
        System.runAs(usrSetup) {
            Opportunity opp = new Opportunity();
                opp.AccountId = acc.Id;
                opp.Name = 'Prueba Test Email';
                opp.OwnerId = usrSetup.Id;
                opp.StageName = 'Potencial';
                opp.RecordTypeId = rtOpp.Id;
                opp.CloseDate = System.today() + 5;
                opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
                opp.AV_ClienteConfidencial__c = true;
                opp.CIBE_ALM__c = true;
            insert opp;   
        
            List<Opportunity> listOpp = new List<Opportunity>();
                listOpp.add(opp);
            
            OpportunityTeamMember oppTM = new OpportunityTeamMember();
                oppTM.OpportunityId = listOpp[0].Id;
                oppTM.UserId = user.Id;
                oppTM.TeamMemberRole = 'Participante';
                oppTM.OpportunityAccessLevel = 'Edit';

            OpportunityTeamMember oppTM2 = new OpportunityTeamMember();
                oppTM2.OpportunityId = listOpp[0].Id;
                oppTM2.UserId = usrSetup.Id;
                oppTM2.TeamMemberRole = 'Gestor';
                oppTM2.OpportunityAccessLevel = 'Edit';

            List<OpportunityTeamMember> listOppTM = new List<OpportunityTeamMember>();
                listOppTM.add(oppTM);
                listOppTM.add(oppTM2);
            insert listOppTM;

            
        }

    }

    @isTest 
    static void emailConfidentialTest() {
        User user = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name =: CIBE_AppConstants.CIBE_GESTOR LIMIT 1];
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' AND (Profile.Name = 'System Administrator' or Profile.Name = 'Administrador del Sistema') LIMIT 1];
        Test.startTest();
        System.runAs(user){
            Boolean confi = false;
            List<Opportunity> listNews = [SELECT Id, AV_ClienteConfidencial__c, Owner.Name FROM Opportunity WHERE Name = 'Prueba Test Email' AND AV_ClienteConfidencial__c = true LIMIT 1];
            for (Opportunity oppo : listNews){
                confi = oppo.AV_ClienteConfidencial__c;
                oppo.AV_ClienteConfidencial__c = false;
            }
            update listNews;  

            List<Opportunity> listUp = [SELECT Id, AV_ClienteConfidencial__c FROM Opportunity WHERE Name = 'Prueba Test Email' LIMIT 1];
            System.assertNotEquals(confi, listUp[0].AV_ClienteConfidencial__c);
        }
        Test.stopTest();
    }
//************************************************************************************************************************************************************** */
    @isTest 
    static void emailStageNameTest() {
        Test.startTest();
        User user = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name =: CIBE_AppConstants.CIBE_GESTOR LIMIT 1];
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' AND (Profile.Name = 'System Administrator' or Profile.Name = 'Administrador del Sistema') LIMIT 1];
        
        System.runAs(user){
            List<Opportunity> listNews = [SELECT Id, StageName FROM Opportunity WHERE Name = 'Prueba Test Email' LIMIT 1];
            String statusOpp = listNews[0].StageName;
            for (Opportunity oppo : listNews){
                oppo.StageName = 'En curso';
            }
            update listNews;  
            System.assertNotEquals(statusOpp, listNews[0].StageName);
        }
        Test.stopTest();
    }
//************************************************************************************************************************************************************** */
    @isTest 
    static void emailoppOwnerTest() {
        Test.startTest();
        User user = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name =: CIBE_AppConstants.CIBE_GESTOR LIMIT 1];
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' AND (Profile.Name = 'System Administrator' or Profile.Name = 'Administrador del Sistema') LIMIT 1];

        System.runAs(user){
            List<Opportunity> listNews = [SELECT Id, OwnerId FROM Opportunity WHERE Name = 'Prueba Test Email' LIMIT 1];
            for (Opportunity oppo : listNews){
                oppo.OwnerId = usrSetup.Id;
            }
            update listNews;  

            System.assertEquals(listNews[0].OwnerId, usrSetup.Id);
        }
        Test.stopTest();
    }

//************************************************************************************************************************************************************** */
    @isTest 
    static void emailDeleteOppTMTest() {
        User user = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name =: CIBE_AppConstants.CIBE_GESTOR LIMIT 1];
        User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' AND (Profile.Name = 'System Administrator' or Profile.Name = 'Administrador del Sistema') LIMIT 1];
    
        Test.startTest();
            System.runAs(user) {
                List<OpportunityTeamMember> listOppTM = [SELECT Id, OpportunityId FROM OpportunityTeamMember WHERE Opportunity.Name = 'Prueba Test Email' ];
                Integer num = listOppTM.size()-1;

                Opportunity oportunidad = new Opportunity();
                oportunidad.Id = listOppTM[0].OpportunityId; 
                oportunidad.OwnerId = user.Id;
                Update oportunidad;

                Delete listOppTM[0];
                List<OpportunityTeamMember> listOppTM2 = [SELECT Id FROM OpportunityTeamMember WHERE Opportunity.Name = 'Prueba Test Email' ];

                System.assertEquals(listOppTM2.size(), num);
            }      
        Test.stopTest();
    }



    @isTest 
    static void emailRequerimientoTest() {
        Test.startTest();
        User user = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name =: CIBE_AppConstants.CIBE_GESTOR LIMIT 1];
        
        System.runAs(user){
            List<Opportunity> listNews = [SELECT Id, CIBE_LoanSyndicateSales__c FROM Opportunity WHERE Name = 'Prueba Test Email' LIMIT 1];
            for (Opportunity oppo : listNews){
                oppo.CIBE_LoanSyndicateSales__c = true;
            }
            update listNews;  
            System.assertEquals(true, listNews[0].CIBE_LoanSyndicateSales__c);
        }
        Test.stopTest();
    }


    @isTest 
    static void emailRequerimientoTest2() {
        Test.startTest();
        User user = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name =: CIBE_AppConstants.CIBE_GESTOR LIMIT 1];
        
        System.runAs(user){
            List<Opportunity> listNews = [SELECT Id, CIBE_ALM__c FROM Opportunity WHERE Name = 'Prueba Test Email' LIMIT 1];
            for (Opportunity oppo : listNews){
                oppo.CIBE_ALM__c = false;
            }
            update listNews;  
            System.assertEquals(false, listNews[0].CIBE_ALM__c);
        }
        Test.stopTest();
    }


    @isTest 
    static void getLanguageTest() {
        Test.startTest();
        User user = [SELECT Id, LanguageLocaleKey FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name =: CIBE_AppConstants.CIBE_GESTOR LIMIT 1];
        
        System.runAs(user){
            String idioma = CIBE_OpportunityEmail.getLanguage();
            System.assertEquals(user.LanguageLocaleKey, idioma);
        }
        Test.stopTest();
    }
}