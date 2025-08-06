/**********************************************************************************************************************
Name:	  CIBE_SegmentoRentabilidadController_Test
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test para la clase CIBE_SegmentoRentabilidadController 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR			DATE			Description
	1.0			US850814    	Lucía	  	    05/06/2024		Init version 

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_SegmentoRentabilidadController_Test {

    @TestSetup
    static void makeData(){

        CIBE_TestInitialSetup.setupInitialDataCIB();
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario) {
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
            Account acc = new Account(
                Name = 'Name',
                RecordTypeId = rt.Id,
                AV_NumPerso__c = '123',
                AV_Negocio__c = 'CIB',
                CIBE_RelativeClientProfSeg__c = 'A',
                CIBE_RelativeGroupProfSeg__c = 'M',
                CIBE_AbsoluteClientProfSeg__c = 'MB',
                CIBE_AbsoluteGroupProfSeg__c = 'MOR'
            );
            insert acc;
        }
        
    }


    @IsTest
    static void getAccountTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        Test.startTest();
        System.runAs(usuario) {
            Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Name'];
            List<CIBE_SegmentoRentabilidadController.Entry> cliente = CIBE_SegmentoRentabilidadController.getAccount(acc.Id);
            System.assert(!cliente.isEmpty());
            
        }
        Test.stopTest();
    }

    @isTest
	public static void getValuesTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario) {
            Test.startTest();
            List<CIBE_SegmentoRentabilidadController.OptionsField> listValues = CIBE_SegmentoRentabilidadController.getValues();
            System.assert(!listValues.isEmpty());
            Test.stopTest(); 
        }
    }
    
}