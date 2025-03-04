/**
@name SAC_WS_Antecedentes_Test
@version 1.0
@date 25-01-2020.
@author Nicolás García Muñoz, IBM
@description Clase Test para la clase SAC_WS_Antecedentes
*/
@IsTest
public with sharing class SAC_WS_Antecedentes_Test {

    @TestSetup
    static void makeData(){

        User usuarioGeneral;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);       
            //Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);  
            //Database.insert(permiSetAssi);
        }
    }
    
    @isTest
    public static void testProbarLlamadaAntecedentes(){

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        CBK_IntegrationSetting__c csAntecedentes = new CBK_IntegrationSetting__c();
        csAntecedentes.Name = 'SAC_Antecedentes';
        csAntecedentes.NamedCredential__c = 'callout:API_GWT_PRO/servicing/servicingIssue/claims/request';
        SAC_DatabaseDML.insertDML(csAntecedentes, false); 
        //Database.insert(csAntecedentes);

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));
        
        List<SAC_WS_Antecedentes_RP.ClaimDocumentsWrapper> claimDocuments = new List<SAC_WS_Antecedentes_RP.ClaimDocumentsWrapper>();
        SAC_WS_Antecedentes_RP.ClaimDocumentsWrapper claimDocument = new SAC_WS_Antecedentes_RP.ClaimDocumentsWrapper('filename', 'downloadLink');
        claimDocuments.add(claimDocument);

        List<SAC_WS_Antecedentes_RP.ResolutionDocumentsWrapper> resolutionDocuments = new List<SAC_WS_Antecedentes_RP.ResolutionDocumentsWrapper>();
        SAC_WS_Antecedentes_RP.ResolutionDocumentsWrapper resolutionDocument = new SAC_WS_Antecedentes_RP.ResolutionDocumentsWrapper('filename', 'downloadLink');
        resolutionDocuments.add(resolutionDocument);

        List<String> customerIds = new List<String>();
        customerIds.add('34534W');

        SAC_WS_Antecedentes_RP.ClaimWrapper elemento = new SAC_WS_Antecedentes_RP.ClaimWrapper(customerIds, 'claimCode', 'expedient', 'affectedOffice', 'resolutionType', 'productservice', 'causeDetail', 'claimsTATUS', claimDocuments, resolutionDocuments, 0.0, 0.0, 'creationDate', 'dueDate', 'claimType', 'responsibleParty', 'managementOffice', 'getReceptionDate' );
        elemento.getAffectedOffice();
        elemento.getCauseDetail();
        elemento.getResolutionType();
        elemento.getClaimAmount();
        elemento.getReturnedAmount();
        elemento.getClaimCode();
        elemento.getClaimDocuments()[0].getFileName();
        elemento.getClaimDocuments()[0].getDownloadLink();
        elemento.getResolutionDocuments()[0].getFileName();
        elemento.getResolutionDocuments()[0].getDownloadLink();
        elemento.getClaimStatus();
        elemento.getClaimType();
        elemento.getCreationDate();
        elemento.getCustomerIds();
        elemento.getDueDate();
        elemento.getExpedient();
        elemento.getProductService();
        elemento.getResponsibleParty();
		elemento.getReceptionDate();
			

        SAC_WS_Antecedentes_RQ.RequestWrapper request = new SAC_WS_Antecedentes_RQ.RequestWrapper(customerIds);
    
        SAC_WS_Antecedentes.AntecedentesResponse response;

        Test.startTest();
        System.runAs(usuario){
            response = SAC_WS_Antecedentes.sendRequest(request, 'SAC_General');
        }
        Test.stopTest();

        System.assertNotEquals(response, null, 'Hay un error en la ejecución');
    }

    @isTest
    public static void testProbarLlamadaAntecedentesError(){

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        CBK_IntegrationSetting__c csAntecedentes = new CBK_IntegrationSetting__c();
        csAntecedentes.Name = 'SAC_Antecedentes';
        csAntecedentes.NamedCredential__c = 'callout:API_GWT_PRO/servicing/servicingIssue/claims/request';
        SAC_DatabaseDML.insertDML(csAntecedentes, false); 
        //Database.insert(csAntecedentes);

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(404, 'KO', null, null));

        List<String> customerIds = new List<String>();
        customerIds.add('34534W');

        SAC_WS_Antecedentes_RQ.RequestWrapper request = new SAC_WS_Antecedentes_RQ.RequestWrapper(customerIds);
        SAC_WS_Antecedentes.AntecedentesResponse response;

        System.runAs(usuario){
            try{
                response = SAC_WS_Antecedentes.sendRequest(request, 'SAC_General');
            }
            catch(Exception e){
                System.assertEquals(response, null, 'Hay un error en la ejecución');
            }
        }
    }
}