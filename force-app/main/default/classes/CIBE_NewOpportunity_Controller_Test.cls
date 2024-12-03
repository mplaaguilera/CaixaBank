/**********************************************************************************************************************
 Name:	  CIBE_NewOpportunity_Controller_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase CIBE_NewOpportunity_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US372929		Jose Maria		   	05/07/2022		  	Init version
	1.0			US372930		Jose Maria		   	05/07/2022		  	Init version
    2.0         US496487        Jose Maria          20/01/2023      	División de funcionalidad en las otras clases del componente
    3.0         DE83223         Lucia               29/09/2023          Nuevo metodo searchTest
		
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_NewOpportunity_Controller_Test {


    @testSetup 
    public static void setup() {
        CIBE_TestInitialSetup.setupInitialDataEMP();
        Id RTProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('AV_PF').getRecordTypeId();


        System.runAs(new User(Id = UserInfo.getUserId())){

            User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];

            Product2 p = new Product2();
                p.Name = 'ProductoTest';
                p.AV_Nivel__c = '1';
                p.RecordTypeId = RTProduct;
                p.AV_ExternalID__c = '11100';
                p.AV_Profesional__c = false;
                p.AV_Activo__c = true;
            insert p;
        }
    }


	@isTest
	public static void getSubProductoPicklistTest() {
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
      	User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
       	
        System.runAs(usuario) {
            Test.startTest();
                List<Map<String, String>> listMapValue = CIBE_NewOpportunity_Controller.getStatusValues('Opportunity', 'StageName');
             	System.assert(!listMapValue.isEmpty());
                List<CIBE_NewOpportunity_Controller.OptionsField> listValues= new List<CIBE_NewOpportunity_Controller.OptionsField> ();
                listValues=CIBE_NewOpportunity_Controller.getSubProductoPicklist();
             	System.assert(!listValues.isEmpty());
                listValues=CIBE_NewOpportunity_Controller.getTipoOperacionPicklist();
             	System.assert(!listValues.isEmpty());
            Test.stopTest(); 
       }
    }
    
    @isTest
    public static void searchTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
        Test.startTest();
        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        System.runAs(usuario) {
            results = CIBE_NewOpportunity_Controller.search('');
            System.assert(!results.isEmpty());
        }
        Test.stopTest();
    }
}