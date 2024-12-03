/**
@name SAC_WS_Proesp_Test
@version 1.0
@date 25-01-2020.
@author Nicolás García Muñoz, IBM
@description Clase Test para la clase SAC_WS_Proesp
*/
@IsTest
public with sharing class SAC_WS_Proesp_Test {

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

        CBK_IntegrationSetting__c csProes = new CBK_IntegrationSetting__c();
        csProes.Name = 'SAC_Proesp';
        csProes.NamedCredential__c = 'callout:API_GWT_PRE/nonITAndNonHREnterpriseServices/legalCompliance/specialProcs/request/bulk';
        Database.insert(csProes);
        
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));
        
        List<SAC_WS_Proesp_RP.procResponseDocumentsWrapper> procResponseDocuments = new List<SAC_WS_Proesp_RP.procResponseDocumentsWrapper>();
        SAC_WS_Proesp_RP.procResponseDocumentsWrapper procResponseDocument = new SAC_WS_Proesp_RP.procResponseDocumentsWrapper('filename', 'downloadLink');
        procResponseDocuments.add(procResponseDocument);
        
        List<SAC_WS_Proesp_RP.ResolutionDocumentsWrapper> resolutionDocuments = new List<SAC_WS_Proesp_RP.ResolutionDocumentsWrapper>();
        SAC_WS_Proesp_RP.ResolutionDocumentsWrapper resolutionDocument = new SAC_WS_Proesp_RP.ResolutionDocumentsWrapper('filename', 'downloadLink');
        resolutionDocuments.add(resolutionDocument);
        
        List<String> customerIds = new List<String>();
        customerIds.add('34534W');
        
        List<String> contracts = new List<String>();
        contracts.add('34534W');
        
        List<String> subjects = new List<String>();
        subjects.add('34534W');
        
        SAC_WS_Proesp_RP.ClaimWrapper elemento = new SAC_WS_Proesp_RP.ClaimWrapper(customerIds, contracts, subjects, 'procCode', 'expedient', 'product', 'procStatus', procResponseDocuments, resolutionDocuments, 'creationDate', 'dueDate');
        elemento.getCustomerIds();
        elemento.getContracts();
        elemento.getSubjects();
        elemento.getProcCode();
        elemento.getExpedient();
        elemento.getProduct();
        elemento.getProcStatus();
        elemento.getProcResponseDocuments()[0].getFileName();
        elemento.getProcResponseDocuments()[0].getDownloadLink();
        elemento.getResolutionDocuments()[0].getFileName();
        elemento.getResolutionDocuments()[0].getDownloadLink();
        elemento.getCreationDate();
        elemento.getDueDate();

        SAC_WS_Proesp_RQ.RequestWrapper request = new SAC_WS_Proesp_RQ.RequestWrapper(customerIds);

        List<SAC_WS_Proesp_RP.ClaimWrapper> response;
        Test.startTest();
        System.runAs(usuario){
            response = SAC_WS_Proesp.sendRequest(request, 'SAC_General');
        }
        Test.stopTest();

        System.assertNotEquals(response, null, 'Hay un error en la ejecución');
    }

    @isTest
    public static void testProbarLlamadaAntecedentesError(){

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        CBK_IntegrationSetting__c csProes = new CBK_IntegrationSetting__c();
        csProes.Name = 'SAC_Proesp';
        csProes.NamedCredential__c = 'callout:API_GWT_PRE/nonITAndNonHREnterpriseServices/legalCompliance/specialProcs/request/bulk';
        Database.insert(csProes);

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(404, 'KO', null, null));

        List<String> customerIds = new List<String>();
        customerIds.add('34534W');

        SAC_WS_Proesp_RQ.RequestWrapper request = new SAC_WS_Proesp_RQ.RequestWrapper(customerIds);
        List<SAC_WS_Proesp_RP.ClaimWrapper> response;

        System.runAs(usuario){
            try{
                response = SAC_WS_Proesp.sendRequest(request, 'SAC_General');
            }
            catch(Exception e){
                System.assertEquals(response, null, 'Hay un error en la ejecución');
            }
        }
    }
}