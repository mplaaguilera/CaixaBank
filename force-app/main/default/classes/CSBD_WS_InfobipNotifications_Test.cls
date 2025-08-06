@IsTest
private class CSBD_WS_InfobipNotifications_Test {
     // Utility method to set up test data for Tasks
    @TestSetup
    static void setupTestData() {

        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {

            Map<String, SObject> cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('12345678Z');
            Account cuenta = (Account)cuentaContacto.get('cuenta');
            Opportunity opportunity = CSBD_Opportunity_Test.crearOportunidadPrestamo(cuenta);
            
                //create Task
            Task tarea = new Task();
            tarea.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CSBD_Task');
            tarea.WhatId = opportunity.Id;
            tarea.Type = 'Envio Mensaje RCS';
            tarea.Status = 'Open';
            tarea.Subject = 'Envio Mensaje RCS';
            tarea.Description = 'Test';
            tarea.AV_ExternalID__c = '123456';
            tarea.CSBD_Evento_Estado__c = 'RCS Enviado';
            tarea.ActivityDate = System.today();
            insert tarea;
        }
 
    }
    
    @IsTest
    static void testHandleDeliveryNotificationDeliverySuccess() {
        // Set up the RestRequest and RestContext
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Mock request parameters
        req.params.put('channel', 'RCS');
        req.params.put('notification', 'delivery');

        // Mock request body with delivery notification JSON
        String messageIdTest = '123456';
        String requestBody = '{"results":[{"messageId":"'+messageIdTest+'","status":{"groupName":"DELIVERED"}}]}';
        req.requestBody = Blob.valueOf(requestBody);

        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        
        System.runAs (usuarioAdministrador) {            
            Test.startTest();
                CSBD_WS_InfobipNotifications.handleDeliveryNotification();
            Test.stopTest();
        }    
        // Assertions
        List<Task> tareaAfter = [
            SELECT Id, CSBD_Evento_Estado__c
            FROM Task
            WHERE AV_ExternalId__c =: messageIdTest
        ];
        System.assertEquals(200, res.statusCode, 'Expected a successful response');
        System.assert(!tareaAfter.isEmpty() , 'NO se encontro ninguna tarea asociada al mensaje RCS');
        System.assert(tareaAfter[0].CSBD_Evento_Estado__c.contains('Entregado') , 'NO se actualizo el estado de la Tarea');
        System.assert(res.responseBody.toString().contains('Notification processed successfully'), 'Response body should indicate success.');
    }

    @IsTest
    static void testHandleDeliveryNotificationDeliveryFails() {
        // Set up the RestRequest and RestContext
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Mock request parameters
        req.params.put('channel', 'RCS');
        req.params.put('notification', 'delivery');

        // Mock request body with delivery notification JSON
        String messageIdTest = '123456';
        String requestBody = '{"results":[{"messageId":"'+messageIdTest+'","status":{"groupName":"REJECTED"}}]}';
        req.requestBody = Blob.valueOf(requestBody);

        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        
        System.runAs (usuarioAdministrador) {            
            Test.startTest();
                CSBD_WS_InfobipNotifications.handleDeliveryNotification();
            Test.stopTest();
        }    
        // Assertions
        List<Task> tareaAfter = [
            SELECT Id, CSBD_Evento_Estado__c
            FROM Task
            WHERE AV_ExternalId__c =: messageIdTest
        ];
        System.assertEquals(200, res.statusCode, 'Expected a successful response');
        System.assert(!tareaAfter.isEmpty() , 'NO se encontro ninguna tarea asociada al mensaje RCS');
        System.assert(tareaAfter[0].CSBD_Evento_Estado__c.contains('Fallido') , 'NO se actualizo el estado de la Tarea');
        System.assert(res.responseBody.toString().contains('Notification processed successfully'), 'Response body should indicate success.');
    }

    @IsTest
    static void testHandleDeliveryNotificationSeenSuccess() {
        // Set up the RestRequest and RestContext
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Mock request parameters
        req.params.put('channel', 'RCS');
        req.params.put('notification', 'seen');

        // Mock request body with seen notification JSON
        String messageIdTest = '123456';
        String requestBody = '{"results":[{"messageId":"'+messageIdTest+'"}]}';
        req.requestBody = Blob.valueOf(requestBody);
  
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
          
        System.runAs (usuarioAdministrador) {            
              Test.startTest();
                  CSBD_WS_InfobipNotifications.handleDeliveryNotification();
              Test.stopTest();
        }    

        // Assertions
        List<Task> tareaAfter = [
              SELECT Id, CSBD_Evento_Estado__c
              FROM Task
              WHERE AV_ExternalId__c =: messageIdTest
        ];

        // Assertions
        System.assertEquals(200, res.statusCode, 'Expected a successful response');
        System.assert(!tareaAfter.isEmpty() , 'NO se encontro ninguna tarea asociada al mensaje RCS');
        System.assert(tareaAfter[0].CSBD_Evento_Estado__c.contains('Visto') , 'NO se actualizo el estado de la Tarea');
        System.assert(res.responseBody.toString().contains('Notification processed successfully'), 'Response body should indicate success.');
    }

    @IsTest
    static void testHandleDeliveryNotificationErrorHandling() {
        // Set up the RestRequest and RestContext
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Mock request parameters
        req.params.put('channel', 'RCS');
        req.params.put('notification', 'delivery');

        // Mock invalid request body to simulate an error
        String requestBody = '{"invalid":"json"}';
        req.requestBody = Blob.valueOf(requestBody);

        // Execute the method
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
          
        System.runAs (usuarioAdministrador) {            
              Test.startTest();
                  CSBD_WS_InfobipNotifications.handleDeliveryNotification();
              Test.stopTest();
        }    
        // Assertions
        System.assertEquals(500, res.statusCode, 'Expected an error response');
        System.assert(res.responseBody.toString().contains('Error processing the delivery notification'), 'Response body should indicate an error.');
    }

    @IsTest
    static void testHandleDeliveryNotificationMissingParameters() {
        // Set up the RestRequest and RestContext
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Mock request body without required parameters
        String requestBody = '{"results":[{"messageId":"12345","status":{"groupName":"DELIVERED"}}]}';
        req.requestBody = Blob.valueOf(requestBody);

        // Execute the method
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
          
        System.runAs (usuarioAdministrador) {            
            Test.startTest();
                CSBD_WS_InfobipNotifications.handleDeliveryNotification();
            Test.stopTest();
        } 

        // Assertions
        System.assertEquals(400, res.statusCode, 'Expected an error response due to missing parameters');
        System.assert(res.responseBody.toString().contains('Query parameter missing'), 'Response body should indicate an error.');
    }

  /*  @IsTest
    static void testProcessNotificationWithException() {
        String messageIdTest = '123456';
         // Assertions
         List<Task> tareaBefore = [
            SELECT Id, CSBD_Evento_Estado__c
            FROM Task
            WHERE AV_ExternalId__c =: messageIdTest
        ];

        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        System.runAs(usuarioAdministrador){
            Test.startTest();       
                CSBD_WS_InfobipNotifications.processDeliveryNotification(messageIdTest, 'delivery', 'RCS', 'UNDELIVERABLE' );
            Test.stopTest();
        }    
         
        // Assertions
        List<Task> tareaAfter = [
            SELECT Id, CSBD_Evento_Estado__c
            FROM Task
            WHERE AV_ExternalId__c =: messageIdTest
        ];

        System.assert(tareaAfter[0].CSBD_Evento_Estado__c == tareaBefore[0].CSBD_Evento_Estado__c , 'Se actualizo el estado de la tarea');
    }*/

    @isTest
    static void testParseDeliveryDTO() {
        String json='{'+
		'  "results": ['+
		'    {'+
		'      "bulkId": "string",'+
		'      "price": {'+
		'        "pricePerMessage": 0,'+
		'        "currency": "string"'+
		'      },'+
		'      "status": {'+
		'        "groupId": 0,'+
		'        "groupName": "ACCEPTED",'+
		'        "id": 0,'+
		'        "name": "string",'+
		'        "description": "string",'+
		'        "action": "string"'+
		'      },'+
		'      "error": {'+
		'        "groupId": 0,'+
		'        "groupName": "OK",'+
		'        "id": 0,'+
		'        "name": "string",'+
		'        "description": "string",'+
		'        "permanent": true'+
		'      },'+
		'      "messageId": "string",'+
		'      "to": "string",'+
		'      "sender": "string",'+
		'      "sentAt": "2024-11-12T10:46:29Z",'+
		'      "doneAt": "2024-11-12T10:46:29Z",'+
		'      "messageCount": 0,'+
		'      "mccMnc": "string",'+
		'      "callbackData": "string",'+
		'      "platform": {'+
		'        "entityId": "string",'+
		'        "applicationId": "string"'+
		'      },'+
		'      "campaignReferenceId": "string"'+
		'    }'+
		'  ]'+
		'}';

        //Por cumplir con las reglas del QualityCloud
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
          
        System.runAs (usuarioAdministrador) {            
            Test.startTest();
                CSBD_Infobip_Delivered_DTO obj = CSBD_Infobip_Delivered_DTO.parse(json);
                System.assert(obj != null, 'No se hizo el parse correctamente para el delivery JSON');
            Test.stopTest();
        } 		
	}

    @isTest
    static void testParseSeenDTO() {
		String json=		'{'+
		'  "results": ['+
		'    {'+
		'      "messageId": "string",'+
		'      "from": "string",'+
		'      "to": "string",'+
		'      "sentAt": "2024-11-12T10:47:33Z",'+
		'      "seenAt": "2024-11-12T10:47:33Z",'+
		'      "applicationId": "string",'+
		'      "entityId": "string",'+
		'      "campaignReferenceId": "string"'+
		'    }'+
		'  ]'+
		'}';
          //Por cumplir con las reglas del QualityCloud
          User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
          
          System.runAs (usuarioAdministrador) {            
              Test.startTest();
                CSBD_Infobip_Seen_DTO obj  = CSBD_Infobip_Seen_DTO.parse(json);
                System.assert(obj != null, 'No se hizo el parse correctamente para el seenß JSON');
              Test.stopTest();
          } 		
	}

   
}