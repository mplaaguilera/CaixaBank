@isTest
public class CSBD_InfobipSenderTest {

    @testSetup
    static void setupData() {
        
        User usuarioAdministrador = CSBD_TestDataFactory.usuarioAdministrador();
        System.runAs(usuarioAdministrador) {
            Map<String, SObject> cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('12345678Z');
            Account cuenta = (Account)cuentaContacto.get('cuenta');
            Opportunity opportunity = CSBD_Opportunity_Test.crearOportunidadPrestamo(cuenta);
            //Set a phone number
            opportunity.CSBD_Telefono_Solicitud__c = '663125698';
            update opportunity;
            // Create test data and setup records necessary for testing.
            CSBD_Infobip_Setting__c settings = new CSBD_Infobip_Setting__c(
                CSBD_Sender_Id__c = 'InfobipSender',
                CSBD_URL_Imagen__c = 'http://example.com/image.png',
                CSBD_Tiempo_Espera__c = 60,
                CSBD_Tipo_Tarea__c = 'Envio Mensaje RCS',
                CSBD_Card_Size__c = 'MEDIUM',
                CSBD_Envio_Automatico_Activo__c = true
            );
            insert settings;

            //Create Custom Setting FWK 
            CBK_IntegrationSetting__c integrationSetting = new CBK_IntegrationSetting__c();
            integrationSetting.Name = 'CSBD_Infobip_SendMessage';
            integrationSetting.NamedCredential__c = 'callout:CSBD_Infobip_Named_Credentials/rcs/2/messages';
            insert integrationSetting;
        }
       
    }

    @isTest
    static void testExecuteWithMock() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        String messageIdTest = '12345678';
        Test.setMock(HttpCalloutMock.class, new CSBD_Infobip_Callout_Mock('SUCCESS', messageIdTest, ''));

        System.runAs (usuarioAdministrador) {
            // Retrieve the test opportunity and add it to a list
            List<Opportunity> oppList = [
                SELECT Id, 
                    CSBD_Idioma_Solicitud__c, 
                    CSBD_Contact__c,                   
                    CSBD_Telefono_Solicitud__c
                FROM Opportunity 
                LIMIT 1
            ];
          
            Test.startTest();
            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                .addString('InfobipSenderTest')
                                .build();
                System.enqueueJob(
                    new CSBD_InfobipSender(oppList),
                    options
                );
            Test.stopTest();
            List<Task> tasks = [
                SELECT Id, CSBD_Evento_Estado__c
                FROM Task 
                WHERE AV_ExternalID__c =: messageIdTest 
                AND Type = 'Envio Mensaje RCS'];

            // Verify that tasks were created as expected          
            System.assertEquals('RCS Enviado', tasks[0].CSBD_Evento_Estado__c, 'The task should have a status of RCS Enviado');
        }  
     
    }

    @isTest
    static void testExecuteWithFailedSendRCS() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        // Use a mock that returns an error response
        Test.setMock(HttpCalloutMock.class, new CSBD_Infobip_Callout_Mock('ERROR', '', ''));
        System.runAs (usuarioAdministrador) {
            // This method will simulate a failed response from Infobip, using a modified mock
            List<Opportunity> oppList = [
                SELECT Id, 
                    CSBD_Idioma_Solicitud__c, 
                    CSBD_Contact__c,                   
                    CSBD_Telefono_Solicitud__c
                FROM Opportunity 
                LIMIT 1
            ];
            Test.startTest();
                AsyncOptions options = new AsyncOptions();
                options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                    .addString('InfobipSenderTest')
                                    .build();
                System.enqueueJob(
                    new CSBD_InfobipSender(oppList),
                    options
                );
            Test.stopTest();
            List<Task> tasks = [
                SELECT Id, CSBD_Evento_Estado__c
                FROM Task 
                WHERE WhatId =: oppList[0].Id 
                AND Type = 'Envio Mensaje RCS'
            ];
            
            // Verify that a failed task was created
            System.assertEquals('RCS Envío Fallido', tasks[0].CSBD_Evento_Estado__c, 'The task should have a status of RCS Envío Fallido');
        }   
    }

    @isTest
    static void testVerifyAndCorrectSpainNumber() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs (usuarioAdministrador) {
            List<Opportunity> oppList = [
                SELECT Id, 
                    CSBD_Idioma_Solicitud__c, 
                    CSBD_Contact__c,                   
                    CSBD_Telefono_Solicitud__c
                FROM Opportunity 
                LIMIT 1
            ];
            CSBD_InfobipSender infobipSender = new CSBD_InfobipSender(oppList);

            // Test case 1: Valid Spanish mobile number without prefix
            String phoneNumber1 = '612345678';
            String expectedOutput1 = '+34612345678';
            // Test case 2: Valid Spanish mobile number with prefix
            String phoneNumber2 = '+34612345678';
            String expectedOutput2 = '+34612345678';
            // Test case 3: Invalid Spanish mobile number (wrong starting digit)
            String invalidPhoneNumber1 = '512345678'; // Starts with '5' instead of 6, 7, 8, or 9
            // Test case 4: Invalid Spanish mobile number (less than 9 digits)
            String invalidPhoneNumber2 = '61234567';

            Test.startTest();
                String result1 = infobipSender.verifyAndCorrectSpainNumber(phoneNumber1);
                String result2 = infobipSender.verifyAndCorrectSpainNumber(phoneNumber2);
                String result3 = infobipSender.verifyAndCorrectSpainNumber(invalidPhoneNumber1);
                String result4 = infobipSender.verifyAndCorrectSpainNumber(invalidPhoneNumber2);
            Test.stopTest();

            System.assertEquals(expectedOutput1, result1, 'The number should be formatted with +34 prefix');
            System.assertEquals(expectedOutput2, result2, 'The number with +34 prefix should remain unchanged');
            System.assertEquals(invalidPhoneNumber1, result3, 'The invalid phone number should return unchanged');
            System.assertEquals(invalidPhoneNumber2, result4, 'The invalid phone number should return unchanged');
        }
    }
}