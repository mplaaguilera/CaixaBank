/**********************************************************************************************************************
Name:	  SIR_LinksOperativoController_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Unit test to SIR_LCMP_LinksOperativoController controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Eq. Atmira       	01/09/2022		Init version
***********************************************************************************************************************/
@isTest
public with sharing class SIR_LinksOperativoController_Test {
    @isTest
    public static void testGetLinks(){
        Id accClienteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(SIR_Constantes.CLIENTE_RECORDTYPE_DEVELOPERNAME).getRecordTypeId();
		Account customer = new Account(
            FirstName = 'Account',
            LastName = 'Test',
            CC_TipoPersona__c = 'J',            	
			RecordTypeId = accClienteRecordTypeId,
            AV_NumPerso__c = '11582114',
            CC_Numero_Documento__c = '11111111P'
        );
        insert customer;
        
        List<SIR_LinksOperativosMCS__mdt> listActive = [SELECT Id, SIR_Url2__c, SIR_Orden__c, SIR_Externo__c, Label 
                                                          FROM SIR_LinksOperativosMCS__mdt
                                                          WHERE SIR_Activo__c =: true
                                                          AND SIR_Seccion__c LIKE: 'Account'];
        
        String urlOrg = 'https://test.salesforce.com';

        Test.startTest();
        system.debug('customer: '+customer +'. + customer.id: '+ customer.Id);
        List<SIR_LCMP_LinksOperativoController.LinksOperativos> listLinks = SIR_LCMP_LinksOperativoController.getLinks('Account', customer.Id, urlOrg); 
        Test.stopTest();
        system.assertEquals(listLinks.size(), listActive.size());
    
    }
}