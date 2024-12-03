/**********************************************************************************************************************
Name:     CSBD_OTPChat_Test
Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase test de la clase CSBD_OTPChat
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY      AUTHOR              DATE                Description
1.0         App CSBD        Esperanza Conde	    31/01/2022          Init version
***********************************************************************************************************************/
@isTest
public with sharing class CSBD_OTPChat_Test {
    
    @testSetup static void setup() { 
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        Id rt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Particular').getRecordTypeId();
        Id rtListaValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByName().get('Lista de valores').getRecordTypeId();
        Id rtValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByName().get('Valor').getRecordTypeId();
        
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
    }
    
    /** 
	* Probamos el OK de la consulta
	*/
    @isTest static void testConsultaOTPOK(){
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        Account cliente = [Select Id, personContactId, CC_NumPerso__c from Account where  CC_NumPerso__c = '16849239' limit 1];
        Contact contacto = [Select Id, CC_NumPerso__c from Contact where Id = :cliente.PersonContactId];

        contacto.CC_NumPerso__c = '16849239';
        update contacto;

        RestRequest req         = new RestRequest();
        RestResponse res        = new RestResponse();
        
        req.requestURI          = '/services/apexrest/ConsultaOTP';
        req.httpMethod          = 'POST';
        
        RestContext.request     = req;
        RestContext.response    = res;
        
        String jsonConsulta = '{"consultaWrapper": {"NUMPERSO": "01011957","IDIOMA": "es","CANAL": "Web","EMAILCLIENTE": "ramame69@hotmail.com","TELEFONOCLIENTE": "prueba2.txt","NOMBRESOLICITANTE": "RAQUEL","APELLIDO1": "Martos","APELLIDO2": "Medina","NIFSOLICITANTE": "46636883J","NOMBREPRODUCTO": "Prestamo Online","HORARIOCONTACTO": "08-10h"}}';
        req.requestBody = Blob.valueOf(jsonConsulta);
        
        System.runAs (CSBD_Usuarios.usuarioAdministrador()) {
            Test.startTest();           
            CSBD_OTPChat.getOPT();
            Test.stopTest();
    
            CBK_OTP_Generado__c otpGenerado = [Select CBK_Codigo_OTP__c, CBK_Oportunidad__c from CBK_OTP_Generado__c];
            
            system.assert(otpGenerado != null, 'Comprobamos se crea el registro del OTP');
            system.assert(otpGenerado.CBK_Codigo_OTP__c != null, 'Comprobamos se asocia un sessionId al registro OTP');
            system.assert(otpGenerado.CBK_Oportunidad__c != null, 'Comprobamos se asocia una oportunidad al registro OTP');
        }
        
    }
    
    /** 
	* Probamos el KO de la integracion
	*/
    @isTest static void testConsultaOTP1KO(){
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        RestRequest req         = new RestRequest();
        RestResponse res        = new RestResponse();
        
        req.requestURI          = '/services/apexrest/ConsultaOTP';
        req.httpMethod          = 'POST';
        
        RestContext.request     = req;
        RestContext.response    = res;
        String jsonConsulta = '{"consultaWrapper": {"NUMPERSO": "","IDIOMA": "es","CANAL": "Web","EMAILCLIENTE": "ramame69@hotmail.com","TELEFONOCLIENTE": "prueba2.txt","NOMBRESOLICITANTE": "RAQUEL","APELLIDO1": "Martos","APELLIDO2": "Medina","NIFSOLICITANTE": "46636883J","NOMBREPRODUCTO": "Prestamo Online","HORARIOCONTACTO": "08-10h"}}';
        req.requestBody = Blob.valueOf(jsonConsulta);

        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_OTPChat.getOPT();
            Test.stopTest();
            
            system.assert(res.statusCode == 400, 'Comprobamos el error de la integración');
        }        
    }

}