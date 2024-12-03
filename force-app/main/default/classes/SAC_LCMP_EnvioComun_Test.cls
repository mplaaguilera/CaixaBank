/*****************************************************************
 * Name: SAC_LCMP_EnvioComun_Test
 * Copyright © 2021  CaixaBank
 * 
 *     Proposito:     Testear la clase SAC_LCMP_EnvioComunicacionCartaPostal
 * 
 * Historial
 * -------
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_EnvioComun_Test {
    @TestSetup
    static void makeData(){
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);
    
        System.runAs(usuarioGeneral){
            Account cuenta = SAC_TestDataFactory.crearCuentasNoClientePA(1)[0];
            Database.insert(cuenta);

            SlaProcess slaPro = [select id, name, IsActive, versionNumber from SlaProcess where name = 'SAC_Process' order by versionNumber desc limit 1];

            Entitlement entitle = SAC_TestDataFactory.crearEntitlement(cuenta.Id);
            Database.insert(entitle);

            Map<String, Object> camposRecl2 = new Map<String, Object>();
            camposRecl2.put('Subject','TestRec2');
            camposRecl2.put('Origin', 'Otros');
            camposRecl2.put('Status', 'SAC_001');
            camposRecl2.put('SAC_NombreContacto__c', 'cuentaTest');
            camposRecl2.put('SAC_TipoConsumidor__c', 'No');

            Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl2);
            Database.insert(casoReclamacion2);

            SAC_DocumentoEnvio__c carta = new SAC_DocumentoEnvio__c(SAC_TipoDocumento__c = 'comunicación', SAC_Caso__c = casoReclamacion2.Id, SAC_Documento__c = null);

            Database.insert(carta);

            // Plantilla
            EmailTemplate validEmailTemplate = new EmailTemplate(
                isActive = true, 
                Name = 'SAC_Redaccion',
                //DeveloperName = 'SAC_Test',
                TemplateType = 'text', 
                HtmlValue = '<p>htmlValue<p>', 
                Body = 'Texted', 
                FolderId = UserInfo.getUserId()
            );
            Database.insert(validEmailTemplate); 
        }
    }

    @isTest
    static void envioCarta_Test() {
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'TestRec2'];
        ContentVersion content;
        SAC_LCMP_EnvioCartaPostal.WrappedInfo myInfo;

        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_EnvioComunicacionCartaPostal.envioCarta(caso.Id);
            content = [SELECT Id, PathOnClient FROM ContentVersion WHERE FirstPublishLocationId =: caso.id LIMIT 1];
            myInfo = SAC_LCMP_EnvioComunicacionCartaPostal.getInfoPostal(caso.Id);
            Test.stopTest();
        }
        System.assertEquals('SampleTitle.pdf', content.PathOnClient, 'Fallo en la obtencion del path del cliente');
        System.assertEquals('cuentaTest', myInfo.nombreTitular, 'La obtención de datos postales ha fallado');   
    }

    @isTest
    static void envioCartaProrroga_Test() {
        User usuarioGeneral = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'TestRec2'];
        ContentVersion content;
        System.runAs(usuarioGeneral){
            Test.startTest();
            SAC_LCMP_EnvioComunicacionCartaPostal.envioCartaProrroga(caso.Id);
            content = [SELECT Id, PathOnClient FROM ContentVersion WHERE FirstPublishLocationId =: caso.id LIMIT 1];
            Test.stopTest();
        }
        System.assertEquals('SampleTitle.pdf', content.PathOnClient, 'Fallo en la obtencion del path del cliente');
    }
}