/**********************************************************************************************************************
Name:     CSBD_LiveChatTriggerHelper_Test
Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase test de la clase CSBD_LiveChatTranscriptTriggerHelper
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY      AUTHOR              DATE                Description
1.0         App CSBD        Esperanza Conde     02/02/2022          Init version
***********************************************************************************************************************/
@isTest
public with sharing class CSBD_LiveChatTriggerHelper_Test {
    
    @testSetup static void setup() {

    	Id rt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Particular').getRecordTypeId();
        Id rtListaValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByName().get('Lista de valores').getRecordTypeId();
        Id rtValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByName().get('Valor').getRecordTypeId();
       	Id rtChatId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Chat').getRecordTypeId();
        
        Account cliente = new Account(
            FirstName = 'OLGA',
            LastName = 'ROBLES GEA',
            RecordTypeId = rt,
            CC_NumPerso__c = '16849239'
        );
        
        insert cliente;
        //Insertamos la lista de valores
        CC_Lista_Valores__c listValoresHorario = new CC_Lista_Valores__c();
        listValoresHorario.Name = 'CSBD: Relación de valores Now - Salesforce: Turno';
        listValoresHorario.CC_Activa__c = true;
        listValoresHorario.RecordTypeId = rtListaValores;
        
        insert listValoresHorario;
        
        CC_Lista_Valores__c valoresHorario = new CC_Lista_Valores__c();
        valoresHorario.Name = '08-10h';
        valoresHorario.RecordTypeId = rtValores;
        valoresHorario.CC_Lista__c = listValoresHorario.Id;
        valoresHorario.CC_Valor__c = 'Mañana';
        valoresHorario.CC_Valor2__c = '08:00 - 10:00';
        valoresHorario.CC_Valor2__c = '8';
        
        insert valoresHorario;
        
        //Insertamos la lista de valores
        CC_Lista_Valores__c listValoresProducto = new CC_Lista_Valores__c();
        listValoresProducto.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto';
        listValoresProducto.CC_Activa__c = true;
        listValoresProducto.RecordTypeId = rtListaValores;
        
        insert listValoresProducto;
        
        CC_Lista_Valores__c valoresProducto = new CC_Lista_Valores__c();
        valoresProducto.Name = 'Prestamo Online';
        valoresProducto.RecordTypeId = rtValores;
        valoresProducto.CC_Lista__c = listValoresProducto.Id;
        valoresProducto.CC_Valor__c = 'Préstamos';
        valoresProducto.CC_Valor2__c = 'Genérico';
        valoresProducto.CC_Valor2__c = 'CaixaBank';
        valoresProducto.CC_Activa__c = true;
        
        insert valoresProducto;
        
        Opportunity opp = new Opportunity(
            Name = 'Chat CSBD',
            StageName = 'Solicitud',
            RecordTypeId = rtChatId,
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

   /** 
     * Cambiar el owner de la oportunidad al traspasar el chat a otro agente
    */
    @isTest static void cambiarOwner(){
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.CC_Tipo__c = 'CSBD';
        transcript.CSBD_OTP_Chat__c = '11111111111';
        transcript.LiveChatVisitorId = liveChatVisitor.Id;
        insert transcript;
        
        User agente = CSBD_Usuarios.usuarioAdministrador();
        System.runAs (agente) {
            transcript.OwnerId = agente.Id;
            Test.startTest();
            update transcript;
            Test.stopTest();

            List<Opportunity> oportunidades = [SELECT Id FROM Opportunity where OwnerId =: agente.Id];
            
            System.assertEquals(1, oportunidades.size());
        }
    }

    /** 
     * Probamos la asignacion del RT segun el tipo de la transcripción y la creacion correcta con el OTP
    */
    @isTest static void testAsignarRT(){

        Account cliente = [Select id from Account where CC_NumPerso__c = '16849239'];

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

        CBK_OTP_Generado__c otp = [Select id, CBK_Fecha_Codigo_OTP__c from CBK_OTP_Generado__c where CBK_Codigo_OTP__c = '11111111111'];

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