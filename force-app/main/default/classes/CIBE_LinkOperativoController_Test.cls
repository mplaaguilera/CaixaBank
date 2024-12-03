/**********************************************************************************************************************
Name:	  CIBE_LinkOperativoController_Test
Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Unit test to CIBE_LinkOperativoController controller
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Init    		Alicia       	    25/05/2023		Init version
***********************************************************************************************************************/
@isTest
public class CIBE_LinkOperativoController_Test {
    
    @TestSetup
	static void setup() {
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        String pea = 'Acceso operativa{|}https://tst.tf7.lacaixa.es/TF7WebUtilities/redirect/test';
        
        System.runAs(usuario) {
            
			Account customerTest = CIBE_TestHelper.createCustomer();
            Lead l = CIBE_TestHelper.createLead();
            l.AV_numperso__c= customerTest.id;
            update l;
            User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
            Task tarea = CIBE_TestHelper.createTareaOtherExternalID(usrTest);
            tarea.AV_PEA__c=pea;
            tarea.AV_PEA2__c=pea;
            update tarea;
            
        }
	}

    @isTest
    public static void testGetLinks(){
        User us1=[SELECT id FROM User WHERE Alias = 'AV-TF9'];
        
        Account customer= [SELECT id FROM Account WHERE AV_NumPerso__c = '123'];
        
        Test.startTest();
        System.runAs(us1){
        List<CIBE_LinkOperativoController.Section> listLinks = CIBE_LinkOperativoController.getLinks('Account', 'Account', customer.Id, customer.Id, 'CIBE0001');
        System.assert(!listLinks.isEmpty());
        Test.stopTest();
        }
    }
    
    @isTest
    public static void testGetLinksLo(){
        User us1=[SELECT id FROM User WHERE Alias = 'AV-TF9'];
        Account customer= [SELECT id FROM Account WHERE AV_NumPerso__c = '123'];
        
        Product2 prod = new Product2(Name = 'Hipoteca', AV_ExternalID__c = '50030');
        RecordType rt = cibe_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);    
        
        Lead l = [SELECT id FROM Lead WHERE AV_CustomerId__c='00000000Z'];
        
        Test.startTest();
        System.runAs(us1){
        AV_LeadOpportunity__c lo = AV_TestHelper.createLeadOpportunity(l);
        
        List<CIBE_LinkOperativoController.Section> listLinks = CIBE_LinkOperativoController.getLinks('AV_LeadOpportunity__c', 'AV_LeadOpportunity__c', lo.Id, lo.Id, 'AV+DOC0001');
        System.assert(!listLinks.isEmpty());
        Test.stopTest();
        }
    }

    // @isTest(SeeAllData=true)
    @isTest
    public static void testGetOppLinkPEA() {
        User us1=[SELECT id FROM User WHERE Alias = 'AV-TF9'];
        
        Account a= [SELECT id FROM Account WHERE AV_NumPerso__c = '123'];
        Task t = [SELECT id FROM Task WHERE Subject = 'Llamada Saliente'];
        
        Test.startTest();
            System.runAs(us1){
                CIBE_LinkOperativoController.LinksOperativos loTask = CIBE_LinkOperativoController.getOppLinkPEA(t.Id, 'Task','AV_PEA__c');
                CIBE_LinkOperativoController.LinksOperativos loTask2 = CIBE_LinkOperativoController.getOppLinkPEA(t.Id, 'Task','AV_PEA2__c');
                System.assertNotEquals(loTask, null);
                System.assertNotEquals(loTask2, null);
            }
        Test.stopTest();
    }

}