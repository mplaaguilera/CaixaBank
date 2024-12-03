/**
@name SAC_WS_Promor_Test
@version 1.0
@date 25-01-2020.
@author Nicolás García Muñoz, IBM
@description Clase Test para la clase SAC_WS_Promor
*/
@IsTest
public with sharing class SAC_WS_Promor_Test {

    @TestSetup
    static void makeData(){

        User usuarioGeneral;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
            Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }
    }
    
    @isTest
    public static void testProbarLlamadaAntecedentes(){

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        CBK_IntegrationSetting__c csPromo= new CBK_IntegrationSetting__c();
        csPromo.Name = 'SAC_Promor';
        csPromo.NamedCredential__c = 'callout:API_GWT_PRE/corporateServices/legalCompliance/debtClaims/request';
        Database.insert(csPromo);

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));
        
        List<SAC_WS_Promor_RP.ResolutionDocumentsWrapper> resolutionDocuments = new List<SAC_WS_Promor_RP.ResolutionDocumentsWrapper>();
        SAC_WS_Promor_RP.ResolutionDocumentsWrapper resolutionDocument = new SAC_WS_Promor_RP.ResolutionDocumentsWrapper('filename', 'downloadLink');
        resolutionDocuments.add(resolutionDocument);
        
        List<String> customerIds = new List<String>();
        customerIds.add('34534W');
        
        List<String> contracts = new List<String>();
        contracts.add('34534W');
        
        SAC_WS_Promor_RP.ClaimWrapper elemento = new SAC_WS_Promor_RP.ClaimWrapper(customerIds, contracts, 'ClaimCode', 'affectedOffice', 'product', 'claimStatus', resolutionDocuments, 0.0, 'creationDate', 'dueDate');
        elemento.getCustomerIds();
        elemento.getContracts();
        elemento.getClaimCode();
        elemento.getAffectedOffice();
        elemento.getProduct();
        elemento.getClaimStatus();
        elemento.getResolutionDocuments()[0].getFileName();
        elemento.getResolutionDocuments()[0].getDownloadLink();
        elemento.getClaimAmount();
        elemento.getCreationDate();
        elemento.getDueDate();

        SAC_WS_Promor_RQ.RequestWrapper request = new SAC_WS_Promor_RQ.RequestWrapper(customerIds);

        List<SAC_WS_Promor_RP.ClaimWrapper> response;
        Test.startTest();
        System.runAs(usuario){
            response = SAC_WS_Promor.sendRequest(request,'SAC_General');
        }
        Test.stopTest();

        System.assertNotEquals(response, null, 'Hay un error en la ejecución');
    }

    @isTest
    public static void testProbarLlamadaAntecedentesError(){

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        CBK_IntegrationSetting__c csPromo= new CBK_IntegrationSetting__c();
        csPromo.Name = 'SAC_Promor';
        csPromo.NamedCredential__c = 'callout:API_GWT_PRE/corporateServices/legalCompliance/debtClaims/request';
        Database.insert(csPromo);

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(404, 'KO', null, null));

        List<String> customerIds = new List<String>();
        customerIds.add('34534W');

        SAC_WS_Promor_RQ.RequestWrapper request = new SAC_WS_Promor_RQ.RequestWrapper(customerIds);
        List<SAC_WS_Promor_RP.ClaimWrapper> response;

        System.runAs(usuario){
            try{
                response = SAC_WS_Promor.sendRequest(request,'SAC_General');
            }
            catch(Exception e){
                System.assertEquals(response, null, 'Hay un error en la ejecución');
            }
        }
    }
}