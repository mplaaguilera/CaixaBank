@isTest
public class CSBD_LiveChatTriggerHelper_Test {

    @testSetup
    private static void setup() {

        Account cliente = new Account(
            FirstName = 'OLGA',
            LastName = 'ROBLES GEA',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Particular').getRecordTypeId(),
            CC_NumPerso__c = '16849239'
        );
        insert cliente;

        Id rtListaValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByName().get('Lista de valores').getRecordTypeId();
        CC_Lista_Valores__c listValoresHorario = new CC_Lista_Valores__c();
        listValoresHorario.RecordTypeId = rtListaValores;
        listValoresHorario.Name = 'CSBD: Relación de valores Now - Salesforce: Turno';
        CC_Lista_Valores__c listValoresProducto = new CC_Lista_Valores__c();
        listValoresProducto.RecordTypeId = rtListaValores;
        listValoresProducto.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto';
        insert new List<CC_Lista_Valores__c>{listValoresHorario, listValoresProducto};

        Id rtValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByName().get('Valor').getRecordTypeId();
        CC_Lista_Valores__c valoresHorario = new CC_Lista_Valores__c();
        valoresHorario.Name = '08-10h';
        valoresHorario.RecordTypeId = rtValores;
        valoresHorario.CC_Lista__c = listValoresHorario.Id;
        valoresHorario.CC_Valor__c = 'Mañana';
        valoresHorario.CC_Valor2__c = '08:00 - 10:00';
        valoresHorario.CC_Valor2__c = '8';
        CC_Lista_Valores__c valoresProducto = new CC_Lista_Valores__c();
        valoresProducto.Name = 'Prestamo Online';
        valoresProducto.RecordTypeId = rtValores;
        valoresProducto.CC_Lista__c = listValoresProducto.Id;
        valoresProducto.CC_Valor__c = 'Préstamos';
        valoresProducto.CC_Valor2__c = 'Genérico';
        valoresProducto.CC_Valor2__c = 'CaixaBank';
        insert new List<CC_Lista_Valores__c>{valoresHorario, valoresProducto};

        Opportunity opp = new Opportunity(
            Name = 'Chat CSBD',
            StageName = 'Solicitud',
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Chat').getRecordTypeId(),
            CSBD_Estado__c = 'Nueva',
            AccountId = cliente.Id
        );
        insert opp;

        CBK_OTP_Generado__c otp = new CBK_OTP_Generado__c();
        otp.CBK_Codigo_OTP__c = '11111111111';
        otp.CBK_Fecha_Codigo_OTP__c = DateTime.NOW().addHours(1);
        otp.CBK_Oportunidad__c = opp.Id;
        insert otp;
    }

    @isTest
    private static void cambiarOwner() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
            insert liveChatVisitor;

            LiveChatTranscript transcript = new LiveChatTranscript();
            transcript.CC_Tipo__c = 'CSBD';
            transcript.CSBD_OTP_Chat__c = '11111111111';
            transcript.LiveChatVisitorId = liveChatVisitor.Id;
            insert transcript;

            User gestor = CSBD_TestDataFactory.usuarioGestor();

            Test.startTest();
            transcript.OwnerId = gestor.Id;
            update transcript;

            System.assertEquals(1, [SELECT COUNT() FROM Opportunity WHERE OwnerId = :gestor.Id LIMIT 2], 'El gestor debería tener una oportunidad asignada');
        }
    }

    @isTest
    private static void testAsignarRT() {
        Account cliente = [SELECT Id FROM Account WHERE CC_NumPerso__c = '16849239'];

        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.CC_Tipo__c = 'CSBD';
        transcript.CSBD_OTP_Chat__c = '11111111111';
        transcript.LiveChatVisitorId = liveChatVisitor.Id;
        transcript.CSBD_Now_Codigo_Producto__c = 'Prestamo Online';

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            insert transcript;
            Test.stopTest();

            LiveChatTranscript transcriptUpdate = [Select RecordTypeId, AccountId, CSBD_Oportunidad_Id__c from LiveChatTranscript where Id = :transcript.Id];
            Id rtChatId = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByName().get('Gestor').getRecordTypeId();
            system.assertEquals(rtChatId, transcriptUpdate.RecordTypeId, 'Comprobamos coincide el rt de la transcripción.');
            system.assertEquals(cliente.Id, transcriptUpdate.AccountId, 'Comprobamos coincide el cliente de la transcripción.');
            system.assert(transcriptUpdate.CSBD_Oportunidad_Id__c != Null, 'Comprobamos coincide la opp de la transcripción.');

            List<Task> lstTarea = [Select Id, Subject from Task where WhatId = :transcriptUpdate.CSBD_Oportunidad_Id__c];
            Task tarea = lstTarea.get(0);

            system.assertEquals('Conversación con agente chat',tarea.Subject, 'Comprobamos coincide el asunto de la tarea.');
        }
    }

    /**
     * Probamos error de que no introducen el OTP
    */
    @isTest static void testValidaOTPNullError(){

        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.CC_Tipo__c = 'CSBD';
        transcript.LiveChatVisitorId = liveChatVisitor.Id;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            Database.SaveResult result = Database.insert(transcript, false);
            Test.stopTest();

            system.assert(result.getErrors()[0].getMessage().contains('Es necesario obtener el sessionId para conectar.'), 'Comprobamos el mensaje de error.');
        }
    }

    /**
     * Probamos error de que no coincide el OTP
    */
    @isTest static void testValidaOTPError(){

        CBK_OTP_Generado__c otp = [SELECT CBK_Fecha_Codigo_OTP__c FROM CBK_OTP_Generado__c WHERE CBK_Codigo_OTP__c = '11111111111'];

        otp.CBK_Fecha_Codigo_OTP__c = DateTime.now().addHours(-1);
        update otp;

        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.CC_Tipo__c = 'CSBD';
        transcript.CSBD_OTP_Chat__c = '11111111111';
        transcript.LiveChatVisitorId = liveChatVisitor.Id;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Test.startTest();
            Database.SaveResult result = Database.insert(transcript, false);
            Test.stopTest();

            system.assert(result.getErrors()[0].getMessage().contains('Transcurrido el tiempo de validez de la sesión. Por favor, solicita de nuevo el SessionId.'), 'Comprobamos el mensaje de error.');
        }
    }

}