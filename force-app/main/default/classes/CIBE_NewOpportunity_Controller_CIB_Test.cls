/**********************************************************************************************************************
    Name:	  CIBE_NewOpportunity_Controller_CIB_Test
    Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para dar cobertura a la clase CIBE_NewOpportunity_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US500486		Alicia		   		20/01/2021		  	Init version
    2.0         US521590        Jose Maria          14/02/2023      	Familia y producto relacionados
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_NewOpportunity_Controller_CIB_Test {
    
    
    @testSetup 
    public static void setup() {
        Id RTSUBPRODUCTO = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('CIBE_Producto').getRecordTypeId();
        Id RTFAMILIA = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('CIBE_Familia').getRecordTypeId();
        Product2 familia = new Product2();
        familia.Name = 'Producto Familia';
        familia.AV_Nivel__c = '1';
        familia.RecordTypeId = RTFAMILIA;
        familia.AV_ExternalID__c = '51000';
        familia.AV_Profesional__c = false;
        familia.AV_Activo__c = true;
        insert familia;
        
        Product2 prod = new Product2();
        prod.Name = 'Producto2';
        prod.AV_Nivel__c = '1';
        prod.RecordTypeId = RTSUBPRODUCTO;
        prod.AV_ExternalID__c = '50000';
        prod.AV_Profesional__c = false;
        prod.CIBE_Familia__c = familia.id;
        prod.AV_Activo__c = true;
        prod.CIBE_CamposOppProduct__c = 'CIBE_Sindicaciones__c;CIBE_Divisa__c;CIBE_Linea__c;';
        insert prod;
        
    }
	/**
	 * get picklist values
	 * get sub productos values
	 * get tipo operacion values
	 */
	@isTest
	public static void getTipoOperacionPicklistTest() {
		List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
        User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
        
        System.runAs(usuario) {
            Test.startTest();
                List<Map<String, String>> listMapValue = CIBE_NewOpportunity_Controller_CIB.getStatusValues('Opportunity', 'StageName');
                System.assert(!listMapValue.isEmpty());
                List<CIBE_NewOpportunity_Controller_CIB.OptionsField> listValues= new List<CIBE_NewOpportunity_Controller_CIB.OptionsField> ();
                listValues=CIBE_NewOpportunity_Controller_CIB.getSubProductoPicklist();
                System.assert(!listValues.isEmpty());
                listValues=CIBE_NewOpportunity_Controller_CIB.getTipoOperacionPicklist();
                System.assert(!listValues.isEmpty());
            Test.stopTest(); 
        }
    }
    
    /**
	 * get productos values
	 */
	@isTest
    public static void searchTest(){
        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        Test.startTest();
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
        User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
        
        System.runAs(usuario) {
            results = CIBE_NewOpportunity_Controller_CIB.search('','');
            System.assert(!results.isEmpty());
        }
        Test.stopTest();
    }	
    
    
    /**
	 * get productos values
	 */
	@isTest
    public static void searchFamilyTest(){
        Test.startTest();
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
        User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
        
        System.runAs(usuario) {
            List<AV_LookupSearchResult> results = CIBE_NewOpportunity_Controller_CIB.searchFamily('', '');
            System.assert(!results.isEmpty());
        }
        Test.stopTest();
    }	
    
    /**
	 * get productos values
	 */
	@isTest
    public static void selectFamilyTest(){
        Test.startTest();
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
        User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
        
        System.runAs(usuario) {
            List<Product2> listFamily =  [SELECT ID FROM Product2 WHERE CIBE_Familia__c!=null];
            String result = CIBE_NewOpportunity_Controller_CIB.selectFamily(listFamily[0].id);
            System.assert(result!=null);
        }
        Test.stopTest();
    }

    /**
	 * Test de la clase getOpportunityFields
	 */
	@isTest
    public static void getOpportunityFieldsTest(){
        Test.startTest();
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
        User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
        
        System.runAs(usuario) {
            List<Product2> listProd =  [SELECT ID FROM Product2 WHERE RecordType.DeveloperName ='CIBE_Producto'];
            List <String> result = CIBE_NewOpportunity_Controller_CIB.getOpportunityFields(listProd[0].id);
            System.assert(!result.isEmpty());
        }
        Test.stopTest();
    }
    
    /**
	 * Test de la clase getCliente
	 */
	@isTest
    public static void getClienteTest(){
        Test.startTest();
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
        User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
        System.runAs(usuario) {
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account acc = new Account(
                Name = CIBE_AppConstants.ACC_SINCLIENTE,
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '1234',
                AV_Negocio__c = 'BPA',
                AV_InterlocName__c = CIBE_AppConstants.ACC_SINCLIENTE
            );
            insert acc;
            String result = CIBE_NewOpportunity_Controller_CIB.getCliente();
            System.assert(!String.isBlank(result));
        }
        Test.stopTest();
    }

        /**
	 * Test de la clase getCliente
	 */
	@isTest
    public static void searchClienteTest(){
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
        User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
        System.runAs(usuario) {
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account acc = new Account(
                Name = CIBE_AppConstants.ACC_SINCLIENTE,
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '1234',
                AV_Negocio__c = 'BPA'
            );
            insert acc;
            Test.startTest();
                List<AV_LookupSearchResult> results = CIBE_NewOpportunity_Controller_CIB.searchCliente(CIBE_AppConstants.ACC_SINCLIENTE);
                System.assert(results.isEmpty());
            Test.stopTest();
        }
    }
}