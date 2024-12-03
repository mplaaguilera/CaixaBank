/**********************************************************************************************************************
Name:	  CIBE_Header_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_Header_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
    VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0			Test Class		Alex Campos			15/06/2022		Init version
	2.0			Test class		Jose Maria			21/11/2022		Mejora de cobertura
    2.1			Test class		Luis Martínez	    30/06/2023		modificacion getDateLoad.

-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
@isTest
public with sharing class CIBE_Header_Controller_Test {
    
    private static final String FILTER_SOBJECT	= 'Account';
    private static final String FIELDSET_NAME	= 'CIBE_HeaderCliente_CIB';

     /***********************************************************************************************************/
    @TestSetup
    static void setup(){
        CIBE_TestInitialSetup.setupInitialDataEMP();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usuario){
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account acc = new Account(
                Name = 'Name',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '123',
                AV_Negocio__c = 'CIB',
                CIBE_PD__c = 0.1,
                AV_Rating__c = '7.5',
                CIBE_FechaRating_SP__c = Date.parse('11/11/2022'),
                OwnerId = usuario.Id
            );
            insert acc;
        }
    	
    
    }
    /***********************************************************************************************************/
    @isTest
    private static void getNameTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usuario){
            Test.startTest();
            Account acc = [select id from account where Name = 'Name' limit 1]; 
            String valorCampo = CIBE_Header_Controller.getName(acc.id,'name');
            System.assert(valorCampo != Null); 
            Test.stopTest(); 
        }
         
    }
    /***********************************************************************************************************/
	@isTest
    private static void getDateLoadTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
         System.runAs(usuario){
            Test.startTest();
            Account acc = [select id from account where Name = 'Name' limit 1];
            String filterObject = 'Account'; 
            String helpField = 'CIBE_FechaRating_SP__c'; 
            String valorFecha = CIBE_Header_Controller.getDateLoad(acc.id,filterObject,helpField);
            System.assert(valorFecha != Null); 
            Test.stopTest();
        }
          
    }
    /***********************************************************************************************************/
    @isTest
    private static void getActionsTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usuario){
            Test.startTest();
            List<CIBE_FlowActions__mdt> listFlwAct = [select id,CIBE_Setting__c from CIBE_FlowActions__mdt];
           
            List<CIBE_Header_Controller.Action> listAction= CIBE_Header_Controller.getActions('CIBE_Account');
            System.assert(!listAction.isEmpty()); 
            
            Test.stopTest();  
        }
      
    }
    /***********************************************************************************************************/
     @isTest
    private static void getFieldsTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usuario){
            Test.startTest();
            Account acc = [select id from account where Name = 'Name' limit 1]; 
            List<CIBE_Header_Controller.Field> listField= CIBE_Header_Controller.getFields(acc.id,FIELDSET_NAME);
            System.assert(!listField.isEmpty()); 
            Test.stopTest();  
        }
       
    }
    /***********************************************************************************************************/

    @isTest
    private static void getAccountInfoTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usuario){
            Test.startTest();
            Account acc = [select id from account where Name = 'Name' limit 1]; 
            List<String> accountInfo = CIBE_Header_Controller.getAccountInfo(acc.Id);
            System.assert(!accountInfo.isEmpty()); 
            Test.stopTest();  
        }
       
    }
}