@isTest
public class CSBD_InfobipControllerTest {

    @testSetup
    static void setupData() {
        // Insert necessary setup data here
        CSBD_Infobip_Setting__c settings = new CSBD_Infobip_Setting__c(
            CSBD_Envio_Automatico_Activo__c = true,
            CSBD_Delay_Update__c = 1,
            CSBD_Tipo_Tarea__c = 'Envio Mensaje RCS'
        );
        insert settings;

        User usuarioAdministrador = CSBD_Usuarios.usuarioAdministrador();

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

    @isTest
    static void testSendInfobipMessage() {
       
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        System.runAs (usuarioAdministrador) {
             // Prepare input JSON
            String inputJson = '{"idOportunidades":["' + [SELECT Id FROM Opportunity LIMIT 1][0].Id + '"]}';
            Test.startTest();
                CSBD_InfobipController.sendInfobipMessage(inputJson);             
                Integer jobCount = [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name LIKE 'CSBD_InfobipSender'];
                System.assertEquals(1, jobCount, 'The Queueable job should be enqueued');   
            Test.stopTest();          
        }
    }

 
    @isTest
    static void testCheckConditionsBeforeSend() {

        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs (usuarioAdministrador) {
            CSBD_InfobipController controller = new CSBD_InfobipController();
            // Validate the condition check
            Boolean result = controller.checkConditionsBeforeSend();
            System.assertEquals(true, result, 'Automatic sending should be active as per settings');
        }
    }

    @isTest
    static void testUpdateTaskFromNotification() {
        String messageIdTest = '123456';
        // Before Assertions
        List<Task> tareaBefore = [
           SELECT Id, CSBD_Evento_Estado__c
           FROM Task
           WHERE AV_ExternalId__c =: messageIdTest
       ];
       
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        System.runAs (usuarioAdministrador) {
            
            Test.startTest();
                CSBD_InfobipController.InfobipDataWrapper info = new CSBD_InfobipController.InfobipDataWrapper();
                info.messageId = messageIdTest;
                info.notificationType = 'delivery';
                info.channel = 'rcs';
                info.status = 'UNDELIVERABLE';
                info.origin = CSBD_InfobipController.ORIGIN_NOTIFICATION;
                CSBD_InfobipController.upsertTask(
                    new List<CSBD_InfobipController.InfobipDataWrapper>{info}, 
                    CSBD_InfobipController.ORIGIN_NOTIFICATION
                );
            Test.stopTest();          
        }
     
       // Assertions
       List<Task> tareaAfter = [
           SELECT Id, CSBD_Evento_Estado__c
           FROM Task
           WHERE AV_ExternalId__c =: messageIdTest
       ];

       System.assert(tareaAfter[0].CSBD_Evento_Estado__c != tareaBefore[0].CSBD_Evento_Estado__c , 'No se actualizo el estado de la tarea');
    }

    @isTest
    static void testUpdateTaskNotificationFromScratch() {
        String messageIdTest = '123_new';
        // Before Assertions
        List<Task> tareaBefore = [
           SELECT Id, CSBD_Evento_Estado__c
           FROM Task
           WHERE AV_ExternalId__c =: messageIdTest
        ];
        
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        System.runAs (usuarioAdministrador) {

            List<Opportunity> opps = [
                SELECT Id
                FROM Opportunity
                WHERE RecordType.DeveloperName = 'CSBD_Prestamo'
            ];
            
            Test.startTest();
                CSBD_InfobipController.InfobipDataWrapper info = new CSBD_InfobipController.InfobipDataWrapper();
                info.messageId = messageIdTest;
                info.notificationType = 'delivery';
                info.channel = 'rcs';
                info.status = 'UNDELIVERABLE';
                info.opportunityId = opps[0].Id;
                info.origin = CSBD_InfobipController.ORIGIN_NOTIFICATION;
                CSBD_InfobipController.upsertTask(
                    new List<CSBD_InfobipController.InfobipDataWrapper>{info}, 
                    CSBD_InfobipController.ORIGIN_NOTIFICATION
                );
            Test.stopTest();          
        }
     
       // Assertions
       List<Task> tareaAfter = [
           SELECT Id, CSBD_Evento_Estado__c
           FROM Task
           WHERE AV_ExternalId__c =: messageIdTest
       ];

       System.assert(tareaBefore.isEmpty() , 'Existia tarea con el external id');
       System.assert(!tareaAfter.isEmpty() , 'No se inserta la tarea');
    }

    @isTest
    static void testUpdateTaskFromSenderAfterNotificacion() {
        String messageIdTest = '123456';
        // Before Assertions
        List<Task> tareaBefore = [
           SELECT Id, CSBD_Evento_Estado__c, AV_ExternalId__c, Subject, Description
           FROM Task
           WHERE AV_ExternalId__c =: messageIdTest
       ];
       
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        List<Task> tareaAfterNotif;
        System.runAs (usuarioAdministrador) {
            
            Test.startTest();
                //If notification comes first
                CSBD_InfobipController.InfobipDataWrapper info = new CSBD_InfobipController.InfobipDataWrapper();
                info.messageId = messageIdTest;
                info.notificationType = 'delivery';
                info.channel = 'rcs';
                info.status = 'UNDELIVERABLE';
                info.origin = CSBD_InfobipController.ORIGIN_NOTIFICATION;
                CSBD_InfobipController.upsertTask(new List<CSBD_InfobipController.InfobipDataWrapper>{info}, CSBD_InfobipController.ORIGIN_NOTIFICATION);
                //Task after process notificaction
                tareaAfterNotif = [
                    SELECT Id, CSBD_Evento_Estado__c, AV_ExternalId__c, Subject, Description
                    FROM Task
                    WHERE AV_ExternalId__c =: messageIdTest
                ];
                //set previous stage
                Task tCopy = tareaAfterNotif[0];
                tCopy.CSBD_Evento_Estado__c = 'RCS Enviado';
                //And senders is executed after that
                CSBD_InfobipController.InfobipDataWrapper info2 = new CSBD_InfobipController.InfobipDataWrapper();
                info2.taskToInsert = new List<Task>();
                info2.taskToUpsert = new List<Task>{tCopy};            
                info2.origin = CSBD_InfobipController.ORIGIN_SENDER;
                CSBD_InfobipController.upsertTask(info2);
            Test.stopTest();          
        }
     
       // Assertions
       List<Task> tareaAfter = [
           SELECT Id, CSBD_Evento_Estado__c, Description
           FROM Task
           WHERE AV_ExternalId__c =: messageIdTest
       ];

       System.assert(tareaAfterNotif[0].CSBD_Evento_Estado__c != tareaBefore[0].CSBD_Evento_Estado__c , 'No se actualizo el estado de la tarea');
       System.assert(tareaAfterNotif[0].CSBD_Evento_Estado__c == tareaAfter[0].CSBD_Evento_Estado__c , 'Se sobreescribio el estado de la tarea en el sender');
    }

    @isTest
    static void testUpdateTaskFromSender() {
        String messageIdTest = '123456_1';
        // Before Assertions
        List<Task> tareaBefore = [
           SELECT Id, CSBD_Evento_Estado__c, AV_ExternalId__c, Subject, Description
           FROM Task
           WHERE AV_ExternalId__c =: messageIdTest
       ];
       
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
       // List<Task> tareaAfterNotif;
        System.runAs (usuarioAdministrador) {
            
            Test.startTest();
                List<Opportunity> opps = [
                    SELECT Id
                    FROM Opportunity
                    WHERE RecordType.DeveloperName = 'CSBD_Prestamo'
                ];
                //called from sender
                CSBD_InfobipController.InfobipDataWrapper info2 = new CSBD_InfobipController.InfobipDataWrapper();
                info2.taskToInsert = new List<Task>();
                info2.taskToUpsert = new List<Task> {
                    CSBD_Activity.crearActividadReturn(
                        new Task(), 
                        opps[0].Id, 
                        'Envio Mensaje RCS', //La definida en el setting,
                        'Completed', 
                        'Envio de mensaje RCS - Enviado (Pendiente Entregar)', 
                        'Test description', 
                        new Map<String , String> {
                            'CSBD_Evento_Estado__c' => CSBD_InfobipController.STATUS_ENVIADO,
                            'AV_ExternalID__c' => messageIdTest
                        })
                };            
                info2.origin = CSBD_InfobipController.ORIGIN_SENDER;
                CSBD_InfobipController.upsertTask(info2);
            Test.stopTest();          
        }
     
       // Assertions
       List<Task> tareaAfter = [
           SELECT Id, CSBD_Evento_Estado__c, Description
           FROM Task
           WHERE AV_ExternalId__c =: messageIdTest
       ];

       System.assert(tareaBefore.isEmpty(), 'Existia una tarea con el mismo external Id');
       System.assert(!tareaAfter.isEmpty(), 'No se creo la tarea');
    }


    @isTest
    static void testUpdateQueueable() {
        String messageIdTest = '123456';
        // Before Assertions
        List<Task> tareaBefore = [
           SELECT Id, CSBD_Evento_Estado__c
           FROM Task
           WHERE AV_ExternalId__c =: messageIdTest
       ];
       
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];

        System.runAs (usuarioAdministrador) {
            
            Test.startTest();
                CSBD_InfobipController.InfobipDataWrapper info = new CSBD_InfobipController.InfobipDataWrapper();
                info.messageId = messageIdTest;
                info.notificationType = 'delivery';
                info.channel = 'rcs';
                info.status = 'UNDELIVERABLE';
                info.origin = CSBD_InfobipController.ORIGIN_NOTIFICATION;
                //info.minutesDelayed = 1;
                CSBD_InfobipController.enqueueUpdater(new List<CSBD_InfobipController.InfobipDataWrapper>{info}, CSBD_InfobipController.ORIGIN_NOTIFICATION);
            Test.stopTest();          
        }
     
       // Assertions
       List<Task> tareaAfter = [
           SELECT Id, CSBD_Evento_Estado__c
           FROM Task
           WHERE AV_ExternalId__c =: messageIdTest
       ];

       System.assert(tareaAfter[0].CSBD_Evento_Estado__c != tareaBefore[0].CSBD_Evento_Estado__c , 'No se actualizo el estado de la tarea');
    }


}