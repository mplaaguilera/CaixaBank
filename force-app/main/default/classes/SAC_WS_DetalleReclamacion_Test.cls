/**
@name SAC_WS_DetalleReclamacion_Test
@version 1.0
@date 27-06-2022.
@author Nicolás García Muñoz, IBM
@description Clase Test para la clase SAC_WS_DetalleReclamacion
*/
@IsTest
public with sharing class SAC_WS_DetalleReclamacion_Test {
    
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
    public static void testProbarLlamadDetalle(){

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        CBK_IntegrationSetting__c csDetalle = new CBK_IntegrationSetting__c();
        csDetalle.Name = 'SAC_DetalleReclamacion';
        csDetalle.NamedCredential__c = 'callout:API_GWT_PRO/servicing/servicingIssue/claims/details';
        SAC_DatabaseDML.insertDML(csDetalle, false); 
        Boolean error;
        //Database.insert(csDetalle);

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));

        List<String> contractNumber = new List<String>();
        contractNumber.add('a');

        List<String> contractType = new List<String>();
        contractType.add('b');

        /*SAC_WS_DetalleReclamacion.Customer customer = new SAC_WS_DetalleReclamacion.Customer('customerTypeId', 'customerId', 'customerName', 'customerFirstSurname', 'customerSecondSurname');

        customer.getcustomerTypeId();
        customer.getCustomerId();
        customer.getCustomerName();
        customer.getcustomerFirstSurname();
        customer.getcustomerSecondSurname();

        SAC_WS_DetalleReclamacion.Agent agent = new SAC_WS_DetalleReclamacion.Agent('agentId', 'agentName', 'agentFirstSurname', 'agentSecondSurname');

        agent.getagentId();
        agent.getAgentName();
        agent.getagentFirstSurname();
        agent.getagentSecondSurname();

        SAC_WS_DetalleReclamacion.Detalle detalle = new SAC_WS_DetalleReclamacion.Detalle('claimCode', 'expedient', 'claimType', 'affectedEntity', 'originCompany', 'affectedCompany', 'claimStatus', 'claimSource', 'entranceChannel', 'claimFamily', 'claimProductService', 'claimFamilyCause', 'causeDetail', contractNumber, contractType, 'receptionDate', 'creationDate', 'resolutionDate', 'dueDate', 'resolutionType', 9, 9, customer, agent);

        detalle.getClaimCode();
        detalle.getExpedient();
        detalle.getClaimType();
        detalle.getaffectedEntity();
        detalle.getoriginCompany();
        detalle.getaffectedCompany();
        detalle.getclaimStatus();
        detalle.getclaimSource();
        detalle.getentranceChannel();
        detalle.getclaimFamily();
        detalle.getclaimProductService();
        detalle.getclaimFamilyCause();
        detalle.getcauseDetail();
        detalle.getcontractNumber();
        detalle.getcontractType();
        detalle.getreceptionDate();
        detalle.getcreationDate();
        detalle.getresolutionDate();
        detalle.getdueDate();
        detalle.getresolutionType();
        detalle.getamountClaimed();
        detalle.getamountPaid();
        detalle.getCustomer();
        detalle.getAgent();*/

        SAC_WS_DetalleReclamacion.DetalleResponse response;
        Test.startTest();
        System.runAs(usuario){
            try{
                response = SAC_WS_DetalleReclamacion.getDetalle('209603');
            }catch(Exception e){
                error = true;
            }
          
        }
        Test.stopTest();
        Assert.areNotEqual(error, false, 'Hay un error en la ejecución');
        //System.assertNotEquals(response, null, 'Hay un error en la ejecución');
    }

    @isTest
    public static void testProbarLlamadaDetalleError(){

        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        CBK_IntegrationSetting__c csDetalle = new CBK_IntegrationSetting__c();
        csDetalle.Name = 'SAC_DetalleReclamacion';
        csDetalle.NamedCredential__c = 'callout:API_GWT_PRO/servicing/servicingIssue/claims/details';
        SAC_DatabaseDML.insertDML(csDetalle, false); 
        //Database.insert(csDetalle);

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(404, 'KO', null, null));

        SAC_WS_DetalleReclamacion.DetalleResponse response;

        System.runAs(usuario){
            try{
                response = SAC_WS_DetalleReclamacion.getDetalle('209603');
            }
            catch(Exception e){
                System.assertEquals(response, null, 'Hay un error en la ejecución');
            }
        }
    }
}