/**
@name SAC_WS_Gescon_Test
@version 1.0
@date 25-01-2020.
@author Nicolás García Muñoz, IBM
@description Clase Test para la clase SAC_WS_Gescon
*/
@IsTest
public with sharing class SAC_WS_Gescon_Test {

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
    public static void testProbarLlamadGescon(){

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));
        
        CBK_IntegrationSetting__c csGescon = new CBK_IntegrationSetting__c();
        csGescon.Name = 'SAC_Gescon';
        csGescon.NamedCredential__c = 'callout:API_GWT_PRE/nonITAndNonHREnterpriseServices/legalCompliance/bankruptcyProcs/request/bulk';
        Database.insert(csGescon);

        List<String> customerIds = new List<String>();
        customerIds.add('34534W');

        List<String> contracts = new List<String>();
        contracts.add('34534W');

        SAC_WS_Gescon_RP.ClaimWrapper elemento = new SAC_WS_Gescon_RP.ClaimWrapper(customerIds, contracts, 'procCode', 'expedient', 'procPhase', 'procStatus', 'creationDate', 'dueDate');
        elemento.getCustomerIds();
        elemento.getContracts();
        elemento.getProcCode();
        elemento.getExpedient();
        elemento.getProcPhase();
        elemento.getProcStatus();
        elemento.getCreationDate();
        elemento.getDueDate();

        SAC_WS_Gescon_RQ.RequestWrapper request = new SAC_WS_Gescon_RQ.RequestWrapper(customerIds);

        List<SAC_WS_Gescon_RP.ClaimWrapper> response;
        Test.startTest();
        System.runAs(usuario){
            response = SAC_WS_Gescon.sendRequest(request, 'SAC_General');
        }
        Test.stopTest();

        System.assertNotEquals(response, null, 'Hay un error en la ejecución');
    }

    @isTest
    public static void testProbarLlamadaAntecedentesError(){

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(404, 'KO', null, null));

        CBK_IntegrationSetting__c csGescon = new CBK_IntegrationSetting__c();
        csGescon.Name = 'SAC_Gescon';
        csGescon.NamedCredential__c = 'callout:API_GWT_PRE/nonITAndNonHREnterpriseServices/legalCompliance/bankruptcyProcs/request/bulk';
        Database.insert(csGescon);

        List<String> customerIds = new List<String>();
        customerIds.add('34534W');

        SAC_WS_Gescon_RQ.RequestWrapper request = new SAC_WS_Gescon_RQ.RequestWrapper(customerIds);
        List<SAC_WS_Gescon_RP.ClaimWrapper> response;

        System.runAs(usuario){
            try{
                response = SAC_WS_Gescon.sendRequest(request, 'SAC_General');
            }
            catch(Exception e){
                System.assertEquals(response, null, 'Hay un error en la ejecución');
            }
        }
    }
}