/**********************************************************************************************************************
 Name:	  Cibe_ProductFieldsOpportunity_Contr_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase Cibe_ProductFieldsOpportunity_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
    1.0         US496487        Jose Maria          20/01/2023      	División de funcionalidad en las otras clases del componente	
***********************************************************************************************************************/
@isTest
public with sharing class Cibe_ProductFieldsOpportunity_Contr_Test {

    /**
	 * 
	 */
	@isTest
	public static void getProductFieldsNewOppoProducto() {
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS};
      	User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);

		System.runAs(usuario){
            Product2 p2 = CIBE_TestHelper.createProduct(null, '1'); 
            List<Product2> listProduct = [SELECT ID FROM Product2 LIMIT 1];
            List<Cibe_ProductFieldsOpportunity_Controller.ProductFieldsNewOpp> listValues= new List<Cibe_ProductFieldsOpportunity_Controller.ProductFieldsNewOpp> ();
            listValues=Cibe_ProductFieldsOpportunity_Controller.getProductFieldsNewOppo(listProduct[0].id);
            System.assert(!listValues.isEmpty());
        }
    }
    
    @isTest
	public static void getProductFieldsNewOppoDefault() {
      	List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS};
      	User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
       	
		System.runAs(usuario){
            Product2 prod = new Product2();
            prod.Name = 'renting Vehiculos';
            prod.AV_Nivel__c = '2';
            prod.AV_ExternalID__c = '50001';
            prod.AV_Profesional__c = false;
            prod.AV_Activo__c = true;
            insert prod; 
            List<Product2> listProduct = [SELECT ID FROM Product2 LIMIT 1];
            List<Cibe_ProductFieldsOpportunity_Controller.ProductFieldsNewOpp> listValues= new List<Cibe_ProductFieldsOpportunity_Controller.ProductFieldsNewOpp> ();
            listValues=Cibe_ProductFieldsOpportunity_Controller.getProductFieldsNewOppo(listProduct[0].id);
            System.assert(!listValues.isEmpty());
        }
    }
}