/*****************************************************************
 * Name: SAC_LCMP_InsertarReescalado_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_ListadoEmailsConsulta
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US219270         Esteve Llaó          06/09/2021   Creación
 * 1.1            US619477         Jose Carlos Blanco  	16/06/2023   Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_ListadoEmailsConsulta_Test {
    @TestSetup
    static void makeData(){

        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
        }

        //RECLAMACION
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Alta');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false);

        //Interaccion Consulta
        Map<String, Object> camposCons = new Map<String, Object>();
        camposCons.put('SAC_Reclamacion__c', casoReclamacion.id);
        camposCons.put('OwnerId', usuarioGeneral.id);
        
        SAC_Interaccion__c consulta = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons);
        SAC_DatabaseDML.insertDML(consulta, false);

        //Mensaje
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailServiceConsulta' LIMIT 1];
        String headerValueSTR = headerValue.LocalPart + '@' + headerValue.EmailDomainName;

        EmailMessage email = new EmailMessage();
        email.subject = 'Consulta1';
        email.relatedToId = consulta.id;
        email.FromAddress = 'test@mail.com';
        email.HtmlBody = 'probemos el indexed thread id  ref:_DoceCatorce_ref';
        email.Headers = '[{"value": "' + headerValueSTR + '","name": "X-SDFC-Original-RCPT"}]';

        SAC_DatabaseDML.insertDML(email, false);
    }

    @isTest
    static void conseguirEmailConsultaTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        SAC_Interaccion__c consulta = [SELECT id,SAC_IndexedThreadId__c FROM SAC_Interaccion__c LIMIT 1];
        String indice = consulta.SAC_IndexedThreadId__c;
        EmailMessage mensaje= [SELECT Id, Subject FROM EmailMessage WHERE subject = 'Consulta1'LIMIT 1];
        mensaje.HtmlBody = indice;
        SAC_DatabaseDML.updateDML(mensaje, false);

        Test.startTest();
        System.runAs(usuario) {
            List<EmailMessage> result = new List<EmailMessage>();
            result = SAC_LCMP_ListadoEmailsConsulta.getEmailsconsulta(consulta.Id);
        }
        Test.stopTest();

        System.assertEquals([SELECT Count() FROM EmailMessage WHERE FromAddress = 'test@mail.com'], 1, 'Correcto');
    }
}