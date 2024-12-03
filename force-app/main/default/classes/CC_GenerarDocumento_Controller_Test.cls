@isTest
public with sharing class CC_GenerarDocumento_Controller_Test{

	@testSetup
	private static void testSetup() {
		User usuario = new User();
		usuario.LastName = 'Gestor CC Test';
		usuario.Alias = 'gestor';
		usuario.Email = 'gestorcc@caixabank.com.invalid';
		usuario.Username = 'gestorcc_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
		usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_Caixabank'].Id;
		usuario.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
		usuario.EmailEncodingkey = 'ISO-8859-1';
		usuario.LanguageLocaleKey = 'es';
		usuario.LocalesIdKey = 'es';
		usuario.TimezonesIdKey = 'Europe/Madrid';
		insert usuario;

		PermissionSet psCC = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
		insert new PermissionSetAssignment(PermissionSetId = psCC.id, AssigneeId = usuario.Id);
        
        EmailTemplate plantillaDocumento = new EmailTemplate();
        plantillaDocumento.DeveloperName = 'CC_Test_Generar_Doc_1' + System.now().getTime();
        plantillaDocumento.Name = 'plantillaPdf1';
        plantillaDocumento.TemplateType = 'custom';
        plantillaDocumento.FolderId = usuario.Id;
        plantillaDocumento.isActive = true;
        plantillaDocumento.Body = 'cuerpo';
        plantillaDocumento.HtmlValue = '<html><body>cuerpo</body></html>';
        System.runAs(usuario) {
            insert plantillaDocumento;
        }
        
         System.runAs(usuario) {
        Case caso = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
            Origin = 'Email',
            Status = 'Activo',
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            OwnerId = usuario.Id,
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Canal_Procedencia__c = 'Formulario web',
            Subject = 'Prueba Gestor Documento',
            Description = 'Prueba'
        );
         insert caso;
        }             
	}

    
    @isTest
    public static void testGenerarDocumento() {
       User usuario = [SELECT Id FROM User WHERE LastName = 'Gestor CC Test' LIMIT 1];
        System.runAs(usuario) {
            
            String plantillaPdf = [SELECT Id FROM EmailTemplate WHERE Name = 'plantillaPdf1'].Id;
            Test.startTest();
            Case caso = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'Prueba Gestor Documento' LIMIT 1];
            // Llamar al método generarDocumento
            ContentVersion resultado = CC_GenerarDocumento_Controller.generarDocumento(caso.Id, plantillaPdf);
            
            Test.stopTest();
            // Verificar que se haya creado un nuevo documento
        System.assert(resultado.ContentDocumentId != null);

        // Verificar que el título del documento sea correcto
        System.assertEquals(caso.CaseNumber+' Documento generado', resultado.Title);

        // Verificar que la actividad haya sido creada correctamente
        Task actividad = [SELECT Id, WhatId, Type, Subject, Status FROM Task WHERE WhatId = :caso.Id AND Type = 'Generación Documento'];
        System.assert(actividad != null);
        System.assertEquals('Completed', actividad.Status);
        }
    }
    
    @isTest
    static void getRutaTest(){
        String ruta;
        
        User usuario = [SELECT Id FROM User WHERE LastName = 'Gestor CC Test' LIMIT 1];
        System.runAs(usuario) {
            Test.startTest();
            ruta = CC_GenerarDocumento_Controller.getVisualforceHostname();
            Test.stopTest();
        }
        Assert.areNotEqual(ruta, null, 'El método que trae la ruta ha fallado.');
    }
    
    
	/*
    @isTest
    static void test_generarDocumento_sinInternet() {
        // Configurar la variable de prueba para que no se llame al método que genera el documento
        System.setProperty('InternetMock', 'true');

        // Llamar al método generarDocumento
        try {
            CC_GenerarDocumento_Controller.generarDocumento(new Case().Id);
            System.assert(false); // Debe lanzar una excepción
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('No se puede acceder a Internet'));
        }
    }

    @isTest
    static void test_generarDocumento_conError() {
        // Configurar el método para que lance un error
        System.setProperty('GenerarDocumento_Error', 'true');

        // Llamar al método generarDocumento
        try {
            CC_GenerarDocumento_Controller.generarDocumento(new Case().Id);
            System.assert(false); // Debe lanzar una excepción
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Error al generar documento'));
        }
    }
    */
    
    
    
    
    
}