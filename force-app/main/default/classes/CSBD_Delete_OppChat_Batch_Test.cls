/**********************************************************************************************************************
Name:     CSBD_Delete_OppChat_Batch_Test
Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase test del batch que borra las oportunidades no relacionadas a un chat.
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY      AUTHOR              DATE                Description
1.0         App CSBD        Esperanza Conde     08/03/2022          Init version
***********************************************************************************************************************/
@isTest
public with sharing class CSBD_Delete_OppChat_Batch_Test {
    
    @testSetup static void setup() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        Id rt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Particular').getRecordTypeId();
        Id rtListaValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByName().get('Lista de valores').getRecordTypeId();
        Id rtValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByName().get('Valor').getRecordTypeId();
        Id rtChatId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Chat').getRecordTypeId();
        List<Opportunity> lstOpp = new List<Opportunity>();
        
        Account cliente = new Account(
            FirstName = 'OLGA',
            LastName = 'ROBLES GEA',
            RecordTypeId = rt,
            CC_NumPerso__c = '16849239'
        );
        insert cliente;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cliente.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

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
        
        Opportunity opp1 = new Opportunity(
            Name = 'Chat CSBD',
            StageName = 'Solicitud',
            RecordTypeId = rtChatId,
            CSBD_Estado__c = 'Nueva',
            AccountId = cliente.Id
        );
        
        lstOpp.add(opp1);

        Opportunity opp2 = new Opportunity(
            Name = 'Chat CSBD',
            StageName = 'Solicitud',
            RecordTypeId = rtChatId,
            CSBD_Estado__c = 'Nueva',
            AccountId = cliente.Id
        );
        
        lstOpp.add(opp2);

        Opportunity opp3 = new Opportunity(
            Name = 'Chat CSBD',
            StageName = 'Solicitud',
            RecordTypeId = rtChatId,
            CSBD_Estado__c = 'Nueva',
            AccountId = cliente.Id
        );
        
        lstOpp.add(opp3);

        insert lstOpp;

   }

    /** 
     * Probamos la asignacion del RT segun el tipo de la transcripción y la creacion correcta con el OTP
    */
    @isTest static void testAsignarRT(){
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        List<Opportunity> lstOpp = [Select Id from Opportunity];
        system.assertEquals(3, lstOpp.size(), 'Comprobamos que al principio hay 3 oportunidades.');

        Opportunity opp = lstOpp.get(0);

        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.CC_Tipo__c = 'CSBD';
        transcript.CSBD_OTP_Chat__c = '11111111111';
        transcript.LiveChatVisitorId = liveChatVisitor.Id;
        transcript.CSBD_Now_Codigo_Producto__c = 'Prestamo Online';
        transcript.CSBD_Oportunidad_Id__c = opp.Id;
        insert transcript;

        LiveChatTranscriptShare transcriptShare = new LiveChatTranscriptShare();
        transcriptShare.ParentId = transcript.Id;
        transcriptShare.UserOrGroupId = usuarioGestor.Id;
        transcriptShare.AccessLevel = 'Edit';
        insert transcriptShare;
        
        System.runAs (usuarioGestor) {
            transcript.OwnerId = usuarioGestor.Id;
            update transcript;
            Test.startTest();
            CSBD_Delete_OppChat_Batch obj = new CSBD_Delete_OppChat_Batch();
            DataBase.executeBatch(obj); 
            Test.stopTest();

            List<Opportunity> lstOppFinal = [Select Id from Opportunity];
            system.assertEquals(1, lstOppFinal.size(), 'Comprobamos que se borran 2 oportunidades y ahora solo queda 1.');
        }
    }

}