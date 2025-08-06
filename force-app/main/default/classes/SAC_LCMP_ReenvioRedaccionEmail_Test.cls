/*****************************************************************
 * Name:  SAC_LCMP_ReenvioRedaccionEmail_Test 
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_ReenvioRedaccionEmail
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US330921         Marcela Neira        14/02/22     Creación
 * 1.1            US643756         Jose Carlos Blanco  	21/06/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/

@istest
public with sharing class SAC_LCMP_ReenvioRedaccionEmail_Test {

    @TestSetup
    static void makeData(){

        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];    
        SAC_DatabaseDML.insertDML(usuarioGeneral, false);    
        //Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);  
        //Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral) {

            //Reclamacion
            Map<String, Object> camporecl = new Map<String, Object>();
            camporecl.put('Subject', 'Reclamacion');

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camporecl);
            SAC_DatabaseDML.insertDML(reclamacion, false); 
            //Database.insert(reclamacion);

            EmailMessage em = new EmailMessage(ParentId = reclamacion.id, 
            SAC_EnvioRedaccion__c = 'primerenvioredaccion',
            FromAddress = 'email@email.com',
            ToAddress = 'test06-03-2024-10-24@test1.com.invalid', 
            CcAddress = 'test06-03-2024-10-24@test2.com.invalid', 
            BccAddress = 'test06-03-2024-10-24@test3.com.invalid', 
            Subject = 'Asunto',
            Incoming = true,
            Headers = '[{"value": ,"name": "X-SFDC-Original-RCPT"}]');
            SAC_DatabaseDML.insertDML(em, false);   
        }
    }

    @istest 
    static void reenviarRedaccionEmailTest() {
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case reclamacion = [SELECT id FROM Case  WHERE Subject = 'Reclamacion'];
        String mensaje;

        //Email
        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
        String headerValueSTR = headerValue.LocalPart + '@' + headerValue.EmailDomainName;
    
        EmailMessage em = new EmailMessage(ParentId = reclamacion.id, 
                            SAC_EnvioRedaccion__c = 'primerenvioredaccion',
                            FromAddress = 'email@email.com',
                            ToAddress = 'test06-03-2024-10-24@test1.com.invalid', 
                            CcAddress = 'test06-03-2024-10-24@test2.com.invalid', 
                            BccAddress = 'test06-03-2024-10-24@test3.com.invalid', 
                            Subject = 'Asunto',
                            Incoming = true,
                            Headers = '[{"value": "' + headerValueSTR + '","name": "X-SFDC-Original-RCPT"}]');
        SAC_DatabaseDML.insertDML(em, false);    
        //Database.insert(em);

        Test.startTest();
        System.runAs(usuario) {
            mensaje = SAC_LCMP_ReenvioRedaccionEmail.reenviarRedaccionEmail(reclamacion.Id, 'test06-03-2024-10-24@test1.com.invalid', 'test06-03-2024-10-24@test2.com.invalid','test06-03-2024-10-24@test3.com.invalid','Asunto', '[]', 'Cuerpo');
        }
        Test.stopTest();
        
        System.assertNotEquals(null, mensaje, 'No se ha ejecutado el método');
    }

    @isTest
    static void obtenerDatosEmailTest(){
        Case reclamacion = [SELECT Id, Status FROM Case WHERE Subject = 'Reclamacion' LIMIT 1];
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
        SAC_LCMP_ReenvioRedaccionEmail.DatosEmailWrapper informacion;

         //Email
         EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'SAC_EmailService' LIMIT 1];
         String headerValueSTR = headerValue.LocalPart + '@' + headerValue.EmailDomainName;
     
         EmailMessage em = new EmailMessage(ParentId = reclamacion.id, 
                             SAC_EnvioRedaccion__c = 'primerenvioredaccion',
                             FromAddress = 'email@email.com',
                             ToAddress = 'test06-03-2024-10-24@test1.com.invalid', 
                             CcAddress = 'test06-03-2024-10-24@test2.com.invalid', 
                             BccAddress = 'test06-03-2024-10-24@test3.com.invalid', 
                             Subject = 'Asunto',
                             Incoming = true,
                             Headers = '[{"value": "' + headerValueSTR + '","name": "X-SFDC-Original-RCPT"}]');
         SAC_DatabaseDML.insertDML(em, false);  

        System.runAs(usuarioGeneral){
            Test.startTest();
            informacion = SAC_LCMP_ReenvioRedaccionEmail.obtenerDatosEmail(reclamacion.Id);
            Test.stopTest();
        }
        System.assertNotEquals(informacion, null, 'El objeto wrapper con datos del email no se ha instanciado correctamente.');
    }
}