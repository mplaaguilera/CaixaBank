/**********************************************************************************************************************
Name:	  AV_LinkOperativoController_Test
Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Unit test to AV_LinkOperativoController controller
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Esperanza Conde 	25/09/2020		Init version
1.1         Test Class      Esperanza Conde     26/10/2020      Add customerId to the method
***********************************************************************************************************************/
@isTest
public class AV_LinkOperativoController_Test {
    
    @TestSetup
	static void setup() {
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        String pea = 'Acceso operativa{|}https://tst.tf7.lacaixa.es/TF7WebUtilities/redirect/test';
        
        System.runAs(usuario) {
            
			Account customerTest = AV_TestHelper.createCustomer();
            Lead l = AV_TestHelper.createLead();
            l.AV_numperso__c= customerTest.id;
            update l;
            User u = AV_TestHelper.createUser('AV_Usuario_CaixaBank', null, 'AV_SistematicaComercial');
			AV_TestHelper.insertNeededPermissions(u);
            Task t = AV_TestHelper.createTarea(u);            
            Opportunity opp= AV_TestHelper.createOpportunity(customerTest);
            opp.AV_PEA__c = pea;
            t.AV_PEA__c=pea;
            opp.AV_PEA2__c=pea;
            t.AV_PEA2__c=pea;
            update t;
            update opp;
            
        }
	}

    @isTest
    public static void testGetLinks(){
        User us1=[SELECT id FROM User WHERE Alias = 'AV-TF9'];
        
        Account customer= [SELECT id FROM Account WHERE AV_NumPerso__c = '123'];
        
        Test.startTest();
        System.runAs(us1){
        List<AV_LinkOperativoController.Section> listLinks = AV_LinkOperativoController.getLinks('Account', 'Account', customer.Id, customer.Id, 'CIBE0001');
        System.assert(!listLinks.isEmpty());
        Test.stopTest();
        }
    }
    
    @isTest
    public static void testGetLinksLo(){
        User us1=[SELECT id FROM User WHERE Alias = 'AV-TF9'];
        Account customer= [SELECT id FROM Account WHERE AV_NumPerso__c = '123'];
        
        Product2 prod = new Product2(Name = 'Hipoteca', AV_ExternalID__c = '50030');
        RecordType rt = AV_AppUtilities.getRecordType('Lead', 'AV_PlataformasHipotecarias');
        
        Lead l = [SELECT id FROM Lead WHERE AV_CustomerId__c='00000000Z'];
        
        Test.startTest();
        System.runAs(us1){
        AV_LeadOpportunity__c lo = AV_TestHelper.createLeadOpportunity(l);
        
        List<AV_LinkOperativoController.Section> listLinks = AV_LinkOperativoController.getLinks('AV_LeadOpportunity__c', 'AV_LeadOpportunity__c', lo.Id, lo.Id, 'AV+DOC0001');
        System.assert(!listLinks.isEmpty());
        Test.stopTest();
        }
    }

    // @isTest(SeeAllData=true)
    @isTest
    public static void testGetOppLink() {
        User us1=[SELECT id FROM User WHERE Alias = 'AV-TF9'];
        
        Account a= [SELECT id FROM Account WHERE AV_NumPerso__c = '123'];
        Task t = [SELECT id FROM Task WHERE Subject = 'Llamada Saliente'];
        Opportunity opp= [Select id FROM Opportunity WHERE Name = 'Alerta Comercial'];
        
        Test.startTest();
        System.runAs(us1){
        AV_LinkOperativoController.LinksOperativos loTask = AV_LinkOperativoController.getOppLinkPEA(t.Id, 'Task','AV_PEA__c');
        AV_LinkOperativoController.LinksOperativos loOpp = AV_LinkOperativoController.getOppLinkPEA(opp.Id, 'Opportunity','AV_PEA__c');
        AV_LinkOperativoController.LinksOperativos loTask2 = AV_LinkOperativoController.getOppLinkPEA(t.Id, 'Task','AV_PEA2__c');
        AV_LinkOperativoController.LinksOperativos loOpp2 = AV_LinkOperativoController.getOppLinkPEA(opp.Id, 'Opportunity','AV_PEA2__c');
        Test.stopTest();
        System.assertNotEquals(loTask, null);
        System.assertNotEquals(loOpp, null);
        System.assertNotEquals(loTask2, null);
        System.assertNotEquals(loOpp2, null);
        }
    }

}