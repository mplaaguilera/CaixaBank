/**********************************************************************************************************************
Name:	  AV_OppButtons_Controller_Test
Copyright © 2024  CaixaBank
=======================================================================================================================
Proposito: Unit test to AV_OppButtons_Controller
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Gonzalo Ávila 	    01/09/2024		Init version
***********************************************************************************************************************/

@isTest
private class AV_OppButtons_Controller_Test {

    @TestSetup
	static void setup() {
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        User userGestor;
        Account customerTest;
        Account customerCompany;
        String pea = 'Acceso operativa{|}https://l.tf7.lacaixa.es/TF7WebUtilities/redirect/test';
        String pea2 = '01{|}Acceso operativa{|}https://l.tf7.lacaixa.es/TF7WebUtilities/redirect/test';

        
        System.runAs(usuario) {
            userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
            AV_TestHelper.insertNeededPermissions(userGestor);  
            AV_TestHelper.insertPermissionSet(userGestor.Id, 'AV_Simuladores');
			customerTest = AV_TestHelper.createCustomer();
            customerCompany = AV_TestHelper.createCustomerCompany();
        }
        Contact contactUSER = AV_TestHelper.createEmployee(customerCompany, userGestor);
        System.runAs(usuario) {
            Opportunity opp= AV_TestHelper.createOpportunityWithEmpleadoSinInsert(customerTest,contactUSER);
            opp.OwnerId = userGestor.Id;
            opp.AV_PEA__c = pea;
            opp.AV_PEA2__c=pea2;
 
            Database.insert(opp, true);

            CIBE_Section_Link__mdt mdt0=[SELECT id, Label, CIBE_Link_Reference__c, CIBE_Section_Reference__c FROM CIBE_Section_Link__mdt where CIBE_Section_Reference__r.CIBE_Setting__c = 'AV_0004' and CIBE_Link_Reference__r.CIBE_Active__c = true LIMIT 1];
            CIBE_Link__mdt mdt = [SELECT id, CIBE_Order__c, CIBE_Parameters__c, CIBE_Title__c, CIBE_URL__c, CIBE_URL_Long__c  FROM CIBE_Link__mdt WHERE Id =: mdt0.CIBE_Link_Reference__c and CIBE_Active__c = true LIMIT 1];
           
            Product2 product = [SELECT Id FROM Product2 WHERE Id =: opp.AV_PF__c];
            AV_Simulador__c simulador = new AV_Simulador__c();
            simulador.name = 'pruebaSimulador';
            simulador.AV_Color__c = '#557FB8';
            simulador.AV_URL_PEA__c = 'PEA';
            simulador.AV_PEA__c = mdt.CIBE_URL__c;
            simulador.AV_Producto__c = product.Id;
           

            insert simulador;
        }  
	}

    @isTest
    public static void getArgumentarioTest(){
        User us1=[SELECT id FROM User WHERE Alias = 'tsAlias'];
        Opportunity opp = [SELECT Id,AV_PF__c FROM Opportunity LIMIT 1];
        Product2 product = [SELECT Id, AV_URLArgumentario__c FROM Product2 WHERE Id =: opp.AV_PF__c];
        
        Test.startTest();
        System.runAs(us1){
            product.AV_URLArgumentario__c = 'https://google.es';
            update product;

            String url = AV_OppButtons_Controller.getArgumentario(opp.Id);

            System.assertNotEquals(null, url, 'url is null');
        }
        Test.stopTest();
       
    }

    @isTest
    public static void getEnlacesTest(){
        User us1=[SELECT id FROM User WHERE Alias = 'tsAlias'];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
      
        Test.startTest();
            System.runAs(us1){
                List<AV_Simulador__c> simuladores = AV_OppButtons_Controller.getEnlaces(opp.Id);
                System.assertNotEquals(null, simuladores, 'list simuladores is null');

            }
        Test.stopTest();
    }

    @isTest
    public static void getAyudaTest(){
        User us1=[SELECT id FROM User WHERE Alias = 'tsAlias'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AV_ExternalID__c = '00000001' LIMIT 1];
        AV_OppButtons_Controller.InfoAyuda ayuda = null;

        Test.startTest();
            System.runAs(us1){
                ayuda = AV_OppButtons_Controller.getAyuda(opp.Id, 'Opportunity');
            }

            System.assertNotEquals(null, ayuda, 'object ayuda is null');
        Test.stopTest();
    }
}