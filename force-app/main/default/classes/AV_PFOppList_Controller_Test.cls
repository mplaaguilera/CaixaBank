/**********************************************************************************************************************
 Name:	  AV_PFOppList_Controller_Test
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: av_PFOppList controller_Test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US158028			Álvaro López		29/01/2021			Init version
	1.1			FIX					Sandra Gómez		27/08/2021			Fix product opportunity
    1.3         US592987		    Ángel Medina		30/05/2023		    Changed AV_Query to SOQL queries
	1.4			Fix PMD Errors      Daniel Rodriguez    18/10/2023			Modify test with runAs

***********************************************************************************************************************/
@isTest
public with sharing class AV_PFOppList_Controller_Test {

    /**
	 * Create Contact without an associated Supervisor.
	 */
	@TestSetup
	static void setup() {
        AV_TestHelper.activateLogger();

        User usuarioCli =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];
		System.runAs(usuarioCli){
            Account acc = AV_TestHelper.createCustomer();
            Pricebook2 pb = new Pricebook2();
            pb.Name = 'Standard Price Book';
            insert pb;
            Opportunity opp = AV_TestHelper.createOpportunity(acc);       
            AV_ExperienceBusiness__c exp = AV_TestHelper.createExperienciaNegocio();     
            AV_ProductExperience__c prodExp = AV_TestHelper.createPFExperience();
            prodExp.AV_Activo__c = true;
            prodExp.AV_ProductoFicha__c = opp.AV_PF__c; 
            prodExp.AV_ExperienciaNegocio__c = exp.Id;
            update prodExp;
            
            AV_ProductClient__c prodCliente = AV_TestHelper.createPFCliente();
            prodCliente.AV_ProductoFicha__c = prodExp.Id;
            prodCliente.AV_Cliente__c = acc.Id;
            prodCliente.AV_TieneOportunidad__c = 'OPORT';
            prodCliente.AV_TenenciaProducto__c = '1';
            prodCliente.AV_Potencialidad__c = 'S';
            update prodCliente;
        }

		
    }
    
    @isTest
    public static void getListDataTest() {
        User usuarioCli =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];
        AV_ProductClient__c pfCliente = new AV_ProductClient__c();
        AV_PFOppList_Controller.DataPF dpf = new AV_PFOppList_Controller.DataPF();
        System.runAs(usuarioCli){
        Test.startTest();    
            pfCliente = [SELECT Id,AV_Cliente__c,AV_ProductoFicha__r.AV_ProductoFicha__r.Id FROM AV_ProductClient__c LIMIT 1];   
            dpf = AV_PFOppList_Controller.getPFInfo(String.valueOf(pfCliente.Id));
            List<Opportunity> listOpps = AV_PFOppList_Controller.getListData(JSON.serialize(dpf), 'Vigentes');
            List<Opportunity> listOpps2 = AV_PFOppList_Controller.getListData(JSON.serialize(dpf), 'Historico');
            List<Opportunity> listOpps3 = AV_PFOppList_Controller.getListData(JSON.serialize(dpf), 'Otro');
        Test.stopTest();
        }
        System.assertEquals(pfCliente.AV_Cliente__c, dpf.clientId, 'Incorrect client id.');
        System.assertEquals(pfCliente.AV_ProductoFicha__r.AV_ProductoFicha__r.Id, dpf.prodId, 'Incorrect product id.');
    }
}