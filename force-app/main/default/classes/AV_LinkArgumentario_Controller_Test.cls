/**********************************************************************************************************************
Name:	  AV_LinkArgumentario_Controller_Test
Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Unit test to AV_LinkArgumentario_Controller 
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Gonzalo Ávila 	    03/04/2024		Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_LinkArgumentario_Controller_Test {
    @TestSetup
	static void setup() {
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        User usuCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
        User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
        

        AV_TestHelper.insertNeededPermissions(userGestor);
        
        Account acc;
		Contact cnt;
        	System.runAs(usuCli) {
                cnt = AV_TestHelper.createEmployee(AV_TestHelper.createCaixaCenter(),userGestor,userGestor.AV_ExternalID__c);
				acc = AV_TestHelper.createCustomer();
                
           }

        System.runAs(userGcf){
					AV_ExperienceBusiness__c exp = AV_TestHelper.createExperienciaNegocioSinInsert();
					exp.AV_ExternalID__c = 'BPA004';
					exp.AV_Negocio__c = 'BPA';
					insert exp;
					Product2 prodPF = AV_TestHelper.createProduct(null,null);
					Product2 producto = AV_TestHelper.createProductSinInsert(prodPF,'20',null);
					producto.AV_Profesional__c = false;
					producto.AV_Activo__c = true;
					insert producto;
		
					AV_ProductExperience__c prodExp = AV_TestHelper.createPFExperienceSinInsert();
					prodExp.AV_Activo__c = true;
					prodExp.AV_ProductoFicha__c = producto.Id; 
					prodExp.AV_ExperienciaNegocio__c = exp.Id;
					prodExp.AV_ExternalId__c = 'BPA004_50077';
					insert prodExp;
					
					AV_ProductClient__c prodCliente = AV_TestHelper.createPFClienteSinInsert();
					prodCliente.AV_ProductoFicha__c = prodExp.Id;
					prodCliente.AV_Cliente__c = acc.Id;
					prodCliente.AV_ImportePreconcedido__c = 123123.12;
					prodCliente.AV_Target__c = true;
					prodCliente.AV_ExternalID__c = '50046';
					prodCliente.AV_Activo__c = true;
					insert prodCliente;
					Opportunity opp = AV_TestHelper.createOpportunityWithProduct(acc,cnt,prodPF,null,null,null);


        }
	}

    @isTest
    public static void testgetProductData(){
        User us1=[SELECT id FROM User WHERE Alias = 'AV-TF9'];
        Opportunity opp = [Select Id FROM Opportunity WHERE AV_ExternalID__c = '00000001'];
        
        Test.startTest();
        System.runAs(us1){
            Product2 data = AV_LinkArgumentario_Controller.getProductData(opp.id);
        System.assert(data != null);
        Test.stopTest();
        }
    }
}