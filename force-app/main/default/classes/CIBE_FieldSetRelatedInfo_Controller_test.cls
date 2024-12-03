/**********************************************************************************************************************
Name:	  CIBE_FieldSetRelatedInfo_Controller_test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_FieldSetRelatedInfo_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
    VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0			Test Class		Borja Lavesiera		19/11/2023		Init version
-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
@isTest
public with sharing class CIBE_FieldSetRelatedInfo_Controller_test {
    
    private static final String FILTER_SOBJECT	= 'Account';
    private static final String FIELDSET_NAME	= 'CIBE_CIBFichaInfocli';
    private static final String PHONE_FIELD_INPUT	= 'CIBE_Movil__c';

     /***********************************************************************************************************/
    @TestSetup
    static void setup(){
    	RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        User userGestor = CIBE_TestHelper.createUser('CIBE_Gestor', 'U01A76E1');
        Account acc = new Account(
            Name = 'Name',
            RecordTypeId = rt.Id,
            AV_NumPerso__c = '123',
            AV_Negocio__c = 'CIB',
            CC_Numero_Documento__c = 'P0301400H',
            AV_ContactPerson__c = 'name contact',
            CIBE_Movil__c = '624784514',
            CC_Email__c = 'test@test.com',
            AV_Rating__c = '7.5',
            CIBE_GrupoEconomico__c = 'Grupo Test',
            AV_Idioma__c = '002'
        );
        insert acc;

        Contact contGestor = CIBE_TestHelper.createEmployee(acc,userGestor);

        acc.AV_EAPGestor__c = contGestor.Id;
        update acc;
            
    }
    /***********************************************************************************************************/
    @isTest
    private static void getFieldsTest() {
        User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U01A76E1' AND IsActive = true];
        Account acc = [select id from account limit 1]; 
        Test.startTest();
        System.runAs(userGestor){
        List<CIBE_FieldSetRelatedInfo_Controller.Field> listField= CIBE_FieldSetRelatedInfo_Controller.getFields(acc.id,FIELDSET_NAME);
        Boolean containsFields = listField.isEmpty();
        System.Assert.isFalse(containsFields, 'Ha encontrado datos para ese FieldSet');
        }
        Test.stopTest();  
    }
    /***********************************************************************************************************/
    @isTest
    private static void getPhoneFieldTest() {
        User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'CIBE_Gestor'  AND AV_ExternalID__c = 'U01A76E1' AND IsActive = true];
        Account acc = [select id from account limit 1]; 
        Test.startTest();
        System.runAs(userGestor){
        List<CIBE_FieldSetRelatedInfo_Controller.Field> listPhoneField= CIBE_FieldSetRelatedInfo_Controller.getPhoneField(acc.id,FIELDSET_NAME,PHONE_FIELD_INPUT);
        Boolean containPhoneField = listPhoneField.isEmpty();
        System.Assert.isFalse(containPhoneField, 'Ha encontrado el campo Movil en el FieldSet');
        }
 		Test.stopTest();  
    }
    /***********************************************************************************************************/
	@isTest
    private static void getFieldValueTest() {
        User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'CIBE_Gestor'  AND AV_ExternalID__c = 'U01A76E1' AND IsActive = true];
        Account acc = [select id from account limit 1]; 
        Test.startTest();
        System.runAs(userGestor){
        Object result = CIBE_FieldSetRelatedInfo_Controller.getFieldValue(FILTER_SOBJECT, FIELDSET_NAME, PHONE_FIELD_INPUT, acc.Id);
        System.Assert.areEqual(true, result instanceof String, 'El resultado es de tipo String');
        }
 		Test.stopTest();  
    }
}