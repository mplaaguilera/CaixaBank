/**********************************************************************************************************************
Name:	  AV_SalesTriggerHelper_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_SalesTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY			AUTHOR				DATE			Description
    1.0			Test Class			Eric Vázquez		17/11/2020		Init version
    1.1         US132474        	Eric Vázquez        25/11/2020      Fix test class
	1.2			Fix "Con Venta"		David Rufo			17/02/2021		Fix method (updateOpp) because previously 
																		working bad for new sales in the same client
	1.3			FIX					Sandra Gómez		27/08/2021		Fix product opportunity
	1.4			US246855			Sandra Gómez		20/10/2021		Add all estructure products
	1.5			US246855			Sandra Gómez		02/02/2022		Add method changeTypeSales
    1.6		    AV_Query IT	        Daniel Rodríguez	07/02/2022	    Change AV_Query to SOQL for User and Account
	1.9         Fix	        		Daniel Rodríguez	10/03/2022      Fix Error, add AV_OrigenApp__c in setup()
	2.0			Fix					Sandra Gómez 		20/01/2022		Recoding
	2.1			Fix PMD Errors		Daniel Rodriguez	25/10/2023	    Add runAss in methods 

***********************************************************************************************************************/
@isTest
public with sharing class AV_SalesTriggerHelper_Test {
    
    @TestSetup
	static void setup(){
        AV_TestHelper.activateLogger();
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User usrTest 	= AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01234243243242');
        System.runAs(usuCli){
            AV_TestHelper.createPricebook2();
            Account customerBPA = AV_TestHelper.createCustomerWithNumpersonSinInsert('12345678910');
            Account customerBPA2 = AV_TestHelper.createCustomerWithNumpersonSinInsert('123');
            Account customerBPA3 = AV_TestHelper.createCustomerWithNumpersonSinInsert('12345678911');
            Account cenTest 	= AV_TestHelper.createCaixaCenterSinInsert();
            List<Account> listAcc = new List<Account> {customerBPA,customerBPA2,cenTest,customerBPA3};
            insert listAcc;
            
            Contact conTest = AV_TestHelper.createEmployee(cenTest, usrTest);
            List<Product2> listPF = new List<Product2>();
            for(Integer i=0;i<3;i++) {
                Product2 prod=AV_TestHelper.createProductSinInsert(null,null,'123456'+i);
                listPF.add(prod);
            }
            insert listPF;
            RecordType rt = AV_AppUtilities.getRecordType('Lead', 'AV_PlataformasHipotecarias');
            Lead le = new Lead();
            le.LastName= 'Last name 1';
            le.FirstName= 'First name 1';
            le.RecordTypeId=rt.Id;
            le.AV_Birthdate__c=Date.newInstance(1968, 12, 9);
            le.AV_IssuingCountry__c='ESP';
            le.AV_CustomerId__c='00000000Z';
            le.AV_CustomerType__c='1';
            le.AV_Requester__c=true;
            le.AV_IsClient__c=true;
            le.AV_PhonePrefix__c='34';
            le.AV_Country__c='ESP';
            le.MobilePhone='000000000';
            le.AV_numperso__c=customerBPA.Id;
            insert le;
            List<Product2> listPFNivel20 = new List<Product2>();
            List<Opportunity> listOpportunity = new List<Opportunity>();
            Integer cont=0;
            for(Product2 p:listPF) {
                Product2 prod;
                if (p.AV_ExternalID__c == '1234560') {
                    listOpportunity.add(AV_TestHelper.createOpportunityWithProductSinInsert(customerBPA, conTest,p,'123456'+cont,null,null));
                    listOpportunity.add(AV_TestHelper.createOpportunityWithProductSinInsert(customerBPA, conTest,p,'123457'+cont,null,null));
                    prod= AV_TestHelper.createProductSinInsert(p,'20','12345620'+cont);
                } else {
                    listOpportunity.add(AV_TestHelper.createOpportunityWithProductSinInsert(customerBPA2, conTest,p,'123456'+cont,null,null));
                    if (p.AV_ExternalID__c == '1234562'){
                        listOpportunity.add(AV_TestHelper.createOpportunityWithProductSinInsert(customerBPA2, conTest,p,'1234561'+cont,null,null));
                        listOpportunity.add(AV_TestHelper.createOpportunityWithProductSinInsert(customerBPA2, conTest,p,'1234562'+cont,system.today(),null));
                        listOpportunity.add(AV_TestHelper.createOpportunityWithProductSinInsert(customerBPA2, conTest,p,'1234563'+cont,system.today().addDays(2),null));
                        listOpportunity.add(AV_TestHelper.createOpportunityWithProductSinInsert(customerBPA2, conTest,p,'1234564'+cont,system.today(),null));
                        listOpportunity.add(AV_TestHelper.createOpportunityWithProductSinInsert(customerBPA2, conTest,p,'1234565'+cont,system.today().addDays(2),'Cerrado positivo'));
                        listOpportunity.add(AV_TestHelper.createOpportunityWithProductSinInsert(customerBPA2, conTest,p,'1234566'+cont,system.today(),'Cerrado positivo'));
                    }
                    prod= AV_TestHelper.createProductSinInsert(p,'20','12345620'+cont);
                }
                listPFNivel20.add(prod);
                cont++;
            }
            insert listOpportunity;
            insert listPFNivel20;
            cont=0;
            List<Product2> listPFNivel10 = new List<Product2>();
            for(Product2 p:listPFNivel20) {
                Product2 prod= AV_TestHelper.createProductSinInsert(p,'10','12345610'+cont);
                listPFNivel10.add(prod);
                cont++;
            }
            insert listPFNivel10;
        }
    }
    
    /**
	 * Update opp when one record Sales insert
	 */
    @isTest
    public static void insertSaleUpdateLeadOpp() {
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        List<AV_LeadOpportunity__c> listLeadOpp = new List<AV_LeadOpportunity__c>();
        System.runAs(usuCli){
            Test.startTest();
            List<Lead> le = [Select id from Lead limit 1];
            List<Product2> listPF2 = [Select id from Product2 where AV_Nivel__c =null and AV_ExternalId__c='1234560' limit 1];
            AV_LeadOpportunity__c leadopp = new AV_LeadOpportunity__c();
            RecordType rt2 = AV_AppUtilities.getRecordType('AV_LeadOpportunity__c', 'AV_PlataformasHipotecarias');
            leadopp.RecordTypeId=rt2.Id;
            leadopp.AV_CustomerOfferId__c = '0000000';
            leadopp.AV_ExternalId__c = '00dds0df';
            leadopp.AV_PrescriberId__c = 'RASTREATOR COMPARADOR CORREDURIA DE SEGUROS';
            leadopp.AV_Status__c='Nuevo';
            leadopp.AV_StatusLeadOpp__c = 'En gestión/insistir';
            leadopp.AV_Lead__c=le[0].Id;
            leadopp.AV_DueDate__c=Date.newInstance(2070, 01, 01);
            leadopp.AV_Producto__c=listPF2[0].Id;
            leadopp.AV_PrescriberId__c='Rastreator';
            insert leadopp;
            List<Account>listAcc=[Select Id From Account Where AV_NumPerso__c = '12345678910' limit 1];
            List<Product2> listPF = [Select id from Product2 where AV_Nivel__c ='10' and AV_ExternalId__c='123456100' limit 1];
            AV_TestHelper.createSales(listAcc.get(0), listPF.get(0));
            listLeadOpp = [Select id, AV_StatusLeadOpp__c From AV_LeadOpportunity__c where AV_StatusLeadOpp__c = 'Con venta'];
            Test.stopTest();
    	}
        System.assertEquals('Con venta', listLeadOpp[0].AV_StatusLeadOpp__c, 'KO');
    }

    /**
	 * Update opp when one record Sales insert
	 */
    @isTest
    public static void insertSaleUpdateOppConVenta() {
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        List<Opportunity> listOpp = new List<Opportunity>();
        System.runAs(usuCli) {
            Test.startTest();
            List<Account>listAcc=[Select Id From Account Where AV_NumPerso__c = '12345678910' limit 1];
            List<Product2> listPF = [Select id from Product2 where AV_Nivel__c ='10' and AV_ExternalId__c='123456100' limit 1];
            AV_TestHelper.createSales(listAcc.get(0), listPF.get(0));
            listOpp = [Select id, stageName From Opportunity where StageName = 'Con venta'];
            Test.stopTest();
        }
        System.assertEquals('Con venta', listOpp[0].StageName, 'KO');
    }
    
      /**
	 * Update more opps when one record Sales insert
	 */
    @isTest
    public static void insertSaleUpdateMoreOppsConVenta() {
         User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        List<Opportunity> listOpp = new List<Opportunity>();
        System.runAs(usuCli) {
            Test.startTest();
            List<Account>listAcc=[Select Id From Account Where AV_NumPerso__c = '123' limit 1];
            List<Product2> listPF = [Select id from Product2 where AV_Nivel__c ='10' and AV_ExternalId__c='123456102' limit 1];
            AV_TestHelper.createSales(listAcc.get(0), listPF.get(0));
            listOpp = [Select id, stageName From Opportunity where StageName = 'Con venta'];
            
            Test.stopTest();
        }
        System.assertEquals('Con venta', listOpp[0].StageName, 'KO');
    }
    
    /**
	 * Update opp when one record Sales update
	 */
    @isTest
    public static void validateChangeTypeSalesInsert() {
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        List<Opportunity> listOppNext = new List<Opportunity>();
        System.runAs(usuCli) {
            Test.startTest();
            Product2 prod = [Select id from Product2 where AV_Nivel__c ='10' and AV_ExternalId__c='123456102' limit 1];
            Account c2 = [SELECT Id from Account WHERE AV_NumPerso__c = '123' limit 1];
            List<Product2> proc2 = [SELECT id FROM Product2 where AV_Nivel__c ='10'];
            List<AV_Sales__c> listSales= new List<AV_Sales__c>();
            for (Product2 p:proc2) {
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
            }
            insert listSales;
            AV_TestHelper.createSales(c2, prod, null, null, 'AV',null, null,null,null);
            listOppNext = [Select Id, StageName from Opportunity where StageName = 'No interesado' limit 1];
            Test.stopTest();
        }
        System.assertEquals('No interesado', listOppNext[0].StageName, 'KO');
    }

    /**
	 * Update More opps when one record Sales update
	 */
    @isTest
    public static void validateChangeTypeSalesMoreOpps() {
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        List<Opportunity> listOppNext = new List<Opportunity>();
        System.runAs(usuCli) {
            Test.startTest();
            List<Account> listAcc= [Select Id From Account Where AV_NumPerso__c = '123' limit 1];
            List<Product2> listPF = [Select id from Product2 where AV_Nivel__c ='20'];
            AV_Sales__c sales1 = AV_TestHelper.createSales(listAcc.get(0), listPF.get(0));
            sales1.AV_ClaseVenta__c='A';
            update sales1;
            listOppNext = [Select Id, StageName from Opportunity where StageName =   'Potencial' limit 1];
            Test.stopTest();
        }
        System.assertEquals(  'Potencial', listOppNext[0].StageName, 'KO');
    }
    
    /**
	 * Update Event or Task in CBK_Activity_Extension__c when one record Sales
	 */
    @isTest
    public static void gestionEventAndTaskTest() {
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        CBK_Activity_Extension__c cbk = new CBK_Activity_Extension__c();
        System.runAs(usuCli){
            Test.startTest();
            Account customerBPA = [SELECT Id from Account WHERE AV_NumPerso__c = '123'];
            User usrTest 	= [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01234243243242'];
            Event vnt = AV_TestHelper.createEvent(usrTest,date.today(),customerBPA);
            Task tsk= AV_TestHelper.createTareaExternalIdCustomStatusWithCustomer(usrTest, '', customerBPA, 'Gestionada positiva');
            AV_ManagementHistory__c mngH = AV_TestHelper.createManagementHistory(tsk, date.today(), datetime.now());
            List<Product2> pro = [SELECT id FROM Product2 where AV_Nivel__c ='10' and AV_ExternalId__c='123456101' limit 1];
            AV_Sales__c sls = AV_TestHelper.createSalesWithDate(customerBPA, pro[0],date.today());
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_MOCNT', 'OK'));
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
            cbk = [SELECT Id, AV_FechaDeLaVenta__c FROM CBK_Activity_Extension__c limit 1];
            Test.stopTest();
        }
        System.assertEquals(cbk.AV_FechaDeLaVenta__c, date.today(), 'KO');
    }
    
    /**
	 * More Sales and More Opps Update
	 */
    @isTest
    public static void salesUpdateOpps() {
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        List<Opportunity> listOppNext = new List<Opportunity>();
        List<Opportunity> listOppNext2 = new List<Opportunity>();
        System.runAs(usuCli) {
            Test.startTest();
            Account c2 = [SELECT Id from Account WHERE AV_NumPerso__c = '123' limit 1];
            Account c1 = [SELECT Id from Account WHERE AV_NumPerso__c = '12345678910' limit 1];
            Account c3 = [SELECT Id from Account WHERE AV_NumPerso__c = '12345678911' limit 1];
            //List<Product2> proc1 = [SELECT id FROM Product2 where AV_Nivel__c ='10' and AV_NombrePF__r.AV_NombrePF__r.AV_ExternalId__c='1234560' limit 1];
            //List<Product2> proc2 = [SELECT id FROM Product2 where AV_Nivel__c ='10' and AV_NombrePF__r.AV_NombrePF__r.AV_ExternalId__c!='1234560'];
            List<Product2> proc1 = [SELECT id FROM Product2 where AV_Nivel__c ='20'  limit 1];
            List<Product2> proc2 = [SELECT id FROM Product2 where AV_Nivel__c ='20' limit 1 ];
            List<AV_Sales__c> listSales= new List<AV_Sales__c>();
            listSales.add(AV_TestHelper.createSalesSinInsert(c1,proc1[0]));
            listSales.add(AV_TestHelper.createSalesSinInsert(c1,proc1[0]));
            listSales.add(AV_TestHelper.createSalesSinInsert(c2,proc1[0]));
            listSales.add(AV_TestHelper.createSalesSinInsert(c3,proc1[0]));
            for (Product2 p:proc2) {
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
                listSales.add(AV_TestHelper.createSalesSinInsert(c2,p));
            }
            insert listSales;
            listOppNext = [Select Id, StageName from Opportunity where StageName = 'Con venta'];
            for(AV_Sales__c sa: listSales) {
                sa.AV_ClaseVenta__c='AV';
            }
            update listSales;
            listOppNext2 = [Select Id, StageName from Opportunity where StageName ='No interesado'];
            Test.stopTest();
        }
        System.assertEquals(2, listOppNext.size(), 'KO');
        
    }
    
    /**
	 * Update opp when one record Sales insert with ByPass
	 */
    @isTest
    public static void insertSaleUpdateOppConVentaByPass() {
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        List<Opportunity> listOpp = new List<Opportunity>();
        System.runAs(usuCli) {
            Test.startTest();
            AV_ByPass__c byPass = [select Id from AV_Bypass__c limit 1];
            byPass.AV_SalesOld__c=true;
            update byPass;
            List<Account>listAcc=[Select Id From Account Where AV_NumPerso__c = '12345678910' limit 1];
            List<Product2> listPF = [Select id from Product2 where AV_Nivel__c ='20' ];
            AV_TestHelper.createSales(listAcc.get(0), listPF.get(0));
            listOpp = [Select id, stageName From Opportunity where StageName = 'Con venta'];
            Test.stopTest();
        }
        System.assertEquals('Con venta', listOpp[0].StageName, 'KO');
    }
    
    /**
	 * Update opp when one record Sales update with ByPass
	 */
    @isTest
    public static void validateChangeTypeSalesByPass() {
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        List<Opportunity> listOppNext = new List<Opportunity>();
        System.runAs(usuCli) {
            Test.startTest();
            AV_ByPass__c byPass = [select Id from AV_Bypass__c limit 1];
            byPass.AV_SalesOld__c=true;
            update byPass; 
            List<Account> listAcc= [Select Id From Account Where AV_NumPerso__c = '12345678910' limit 1];
            //List<Product2> listPF = [Select id from Product2 where AV_Nivel__c ='10' and AV_ExternalId__c='123456100' limit 1];
            List<Product2> listPF = [Select id from Product2 where AV_Nivel__c ='20' ];
            AV_Sales__c sales1 = AV_TestHelper.createSales(listAcc.get(0), listPF.get(0));
            sales1.AV_ClaseVenta__c='AV';
            update sales1;
            listOppNext = [Select Id, StageName from Opportunity where StageName = 'No interesado' limit 1];
            Test.stopTest();
        }
        System.assertEquals('No interesado', listOppNext[0].StageName, 'KO');
    }
}