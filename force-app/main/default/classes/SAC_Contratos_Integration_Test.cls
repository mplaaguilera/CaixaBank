@isTest
public with sharing class SAC_Contratos_Integration_Test {
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
    public static void testGetCommercialProduct() {
        // Preparar los datos necesarios para la prueba
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        String customerId = '12345';
       
        CBK_IntegrationSetting__c csCliente = new CBK_IntegrationSetting__c();
        csCliente.Name = 'SAC_Contratos_Cliente';
        csCliente.NamedCredential__c = 'callout:API_GWT_PRO/partyReference/customers/contracts';
        Database.insert(csCliente);
        
        SAC_Contratos_Integration.ProductResponse  response;
        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));
        
      
        System.runAs(usuario){
        Test.startTest();
        response = SAC_Contratos_Integration.getCommercialProduct(customerId);
        Test.stopTest();
        }
        
        System.assertEquals('200', response.statusCode, 'Comprobar estado correcto');

    }
    @isTest
    public static void testGetCommercialProductDetail() {
        // Preparar los datos necesarios para la prueba
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        String customerId = '12345';
        String productId = '67890';

        CBK_IntegrationSetting__c csProductDetail = new CBK_IntegrationSetting__c();
        csProductDetail.Name = 'SAC_Contratos_Detalle';
        csProductDetail.NamedCredential__c = 'callout:API_GWT_PRO/partyReference/customers/commercialProducts/{commercialProductId}?tenure=S';
        Database.insert(csProductDetail);

        
        SAC_Contratos_Integration.ProductDetailResponse  response;
        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));
        
      
        System.runAs(usuario){
        Test.startTest();
        response = SAC_Contratos_Integration.getCommercialProductDetail(customerId, productId);
        Test.stopTest();
        }
        
        System.assertEquals('200', response.statusCode, 'Comprobar estado correcto');

    }

    @isTest
    public static void testGetTicketSAC() {
        // Preparar los datos necesarios para la prueba
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        String customerId = '206';
        CBK_IntegrationSetting__c csTicket = new CBK_IntegrationSetting__c();
        csTicket.Name = 'SAC_Contratos_Ticket';
        csTicket.NamedCredential__c = 'callout:API_GWT_PRO/customerPosition/customers/tickets';
        Database.insert(csTicket);

        
        SAC_Contratos_Integration.TicketResponse  response;
        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));
        
      
        System.runAs(usuario){
        Test.startTest();
        response = SAC_Contratos_Integration.getTicket(customerId, 'SAC_General');
        Test.stopTest();
        }
        
        System.assertEquals('200', response.statusCode, 'Comprobar estado correcto');

    }

    @isTest
    public static void testGetTicketSPV() {
        // Preparar los datos necesarios para la prueba
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        String customerId = '206';
        CBK_IntegrationSetting__c csTicket = new CBK_IntegrationSetting__c();
        csTicket.Name = 'SPV_Contratos_Ticket';
        csTicket.NamedCredential__c = 'callout:API_GWT_PRO/customerPosition/customers/tickets';
        Database.insert(csTicket);

        
        SAC_Contratos_Integration.TicketResponse  response;
        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));
        
      
        System.runAs(usuario){
        Test.startTest();
        response = SAC_Contratos_Integration.getTicket(customerId, 'SPV_General');
        Test.stopTest();
        }
        
        System.assertEquals('200', response.statusCode, 'Comprobar estado correcto');

    }

    @isTest
    public static void testGetContractSAC() {
        // Preparar los datos necesarios para la prueba
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        String numTicket = 'N0000000000000000020600527';
        CBK_IntegrationSetting__c csContract = new CBK_IntegrationSetting__c();
        csContract.Name = 'SAC_Contratos_Contrato';
        csContract.NamedCredential__c = 'https://api.private.cer.caixabank.com/customerPosition/customers/contracts?ticket={numTicket}&isCancelledContratcs=true';
        Database.insert(csContract);

        
        SAC_Contratos_Integration.ContractResponse  response;
        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));
        
      
        System.runAs(usuario){
        Test.startTest();
        response = SAC_Contratos_Integration.getContract(numTicket, 'SAC_General');
        Test.stopTest();
        }
        
        System.assertEquals('200', response.statusCode, 'Comprobar estado correcto');

    }

    @isTest
    public static void testGetContractSPV() {
        // Preparar los datos necesarios para la prueba
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        String numTicket = 'N0000000000000000020600527';
        CBK_IntegrationSetting__c csContract = new CBK_IntegrationSetting__c();
        csContract.Name = 'SPV_Contratos_Contrato';
        csContract.NamedCredential__c = 'https://api.private.cer.caixabank.com/customerPosition/customers/contracts?ticket={numTicket}&isCancelledContratcs=true';
        Database.insert(csContract);

        
        SAC_Contratos_Integration.ContractResponse  response;
        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', null, null));
        
      
        System.runAs(usuario){
        Test.startTest();
        response = SAC_Contratos_Integration.getContract(numTicket, 'SPV_General');
        Test.stopTest();
        }
        
        System.assertEquals('200', response.statusCode, 'Comprobar estado correcto');

    }

}