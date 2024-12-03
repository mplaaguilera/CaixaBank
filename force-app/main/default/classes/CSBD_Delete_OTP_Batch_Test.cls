/**********************************************************************************************************************
Name:     CSBD_Delete_OTP_Batch_Test
Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase test de la clase CSBD_Delete_OTP_Batch
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY      AUTHOR              DATE                Description
1.0         App CSBD        Esperanza Conde     09/06/2022          Init version
***********************************************************************************************************************/
@isTest
public with sharing class CSBD_Delete_OTP_Batch_Test {
    
    @testSetup static void setup() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        Id rt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Particular').getRecordTypeId();
        Id rtListaValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByName().get('Lista de valores').getRecordTypeId();
        Id rtValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByName().get('Valor').getRecordTypeId();
        Id rtChatId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Chat').getRecordTypeId();
        Id rtOTPId = Schema.SObjectType.CBK_OTP_Generado__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId();
        List<Opportunity> lstOpp = new List<Opportunity>();
        
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

        CBK_OTP_Generado__c otp = new CBK_OTP_Generado__c();
        otp.CBK_Codigo_OTP__c = '11111111111'; 
        otp.CBK_Fecha_Codigo_OTP__c = DateTime.NOW().addHours(1);
        otp.CBK_Oportunidad__c = opp2.Id;
        otp.recordtypeId = rtOTPId;

        CBK_OTP_Generado__c otp2 = new CBK_OTP_Generado__c();
        otp2.CBK_Codigo_OTP__c = '11111111112'; 
        otp2.CBK_Fecha_Codigo_OTP__c = DateTime.NOW().addHours(1);
        otp2.CBK_Oportunidad__c = opp3.Id;
        otp2.recordtypeId = rtOTPId;

        List<CBK_OTP_Generado__c> lstOTP = new List<CBK_OTP_Generado__c>();
        lstOTP.add(otp);
        lstOTP.add(otp2);

        insert lstOTP;

   }

    /** 
     * Probamos el borrado de los OTP generados
    */
    @isTest static void testComprobarBorrado(){
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        System.runAs (usuarioGestor) {
            List<CBK_OTP_Generado__c> lstOTP = [Select Id from CBK_OTP_Generado__c];
            system.assertEquals(2, lstOTP.size(), 'Comprobamos que al principio hay 2.');

            Test.startTest();
            CSBD_Delete_OTP_Batch obj = new CSBD_Delete_OTP_Batch();
            DataBase.executeBatch(obj); 
            Test.stopTest();

            List<CBK_OTP_Generado__c> lstOTPFinal = [Select Id from CBK_OTP_Generado__c];
            system.assertEquals(0, lstOTPFinal.size(), 'Comprobamos que se borran los 2.');
        }
    }

}