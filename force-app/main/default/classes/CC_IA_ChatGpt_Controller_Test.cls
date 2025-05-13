/*****************************************************************
 * Name: CC_IA_ChatGpt_Controller_Test
 * Copyright © 2024  CaixaBank
 * 
 * @description: Clase Test para controlador de ChatGPT POC CC 
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0                             Borja Lavesiera   07/01/24     Creación
*****************************************************************/
@isTest
/**
     * @description   Clase Test para Controler del Chat Interactivo
     * @Autor: Borja Lavesiera Muñoz
     */
public with sharing class CC_IA_ChatGpt_Controller_Test {

    @TestSetup
      private  static void testSetup(){
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];

        User usuarioGestor = new User();
        usuarioGestor.ProfileId = profileId;
        usuarioGestor.FirstName = 'Gestor CC';
        usuarioGestor.LastName = 'last1';
        usuarioGestor.Email = 'tuser0004@amamama.com';
        usuarioGestor.Username = 'tuser0004@amamama.com' + System.currentTimeMillis();
        usuarioGestor.CompanyName = 'MST';
        usuarioGestor.Title = 'title';
        usuarioGestor.Alias = 'aliºas';
        usuarioGestor.TimeZoneSidKey = 'Europe/Paris';
        usuarioGestor.EmailEncodingKey = 'UTF-8';
        usuarioGestor.LanguageLocaleKey = 'es';
        usuarioGestor.LocaleSidKey = 'es_ES';
        usuarioGestor.UserRoleId = rolId.Id;
        insert(usuarioGestor);

        // Obtenemos los PS Necesarios
        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name IN ('CC_IA_Prompt_User', 'Knowledge_LSF_Permission_Set')];

        // Asignamos PS CC_IA_UsuarioPromptsIA
        PermissionSet permiSet1 = permiSets[0];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGestor.Id;
        permiSetAssi.PermissionSetId = permiSet1.Id;
        insert(permiSetAssi);

        // Asignamos PS Knowledge_LSF_Permission_Set
        PermissionSet permiSet2 = permiSets[1];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuarioGestor.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        insert(permiSetAssi2);

        System.runAs(usuarioGestor) {
            Account cuenta = new Account();
            cuenta.Name = 'PRUEBA TEST';
            cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
            insert(cuenta);

            Contact contacto = new Contact();
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
            contacto.FirstName = 'Test';
            contacto.LastName = 'Prueba';
            contacto.Email = 'mp@test.com';
            contacto.AccountId = cuenta.Id;
            insert(contacto);

            Case casoCliente = new Case();
            casoCliente.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            casoCliente.Subject = 'Caso cliente Test';
            casoCliente.Origin = 'Phone';
            casoCliente.CC_Canal_Respuesta__c = 'Phone';
            casoCliente.CC_Tipo_Cliente__c = 'Cliente';
            casoCliente.CC_No_Identificado__c = true;
            casoCliente.CC_Canal_Procedencia__c = 'CaixaBankNow';
            casoCliente.AccountId = cuenta.id;
            insert(casoCliente);

            // Creamos objeto extension
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                caseExtension.CC_IA_Cumple_Condiciones_Prompts__c = true;
                caseExtension.CC_IA_Historico_ChatGpt__c = 'Pregunta del chat';
                caseExtension.CC_IA_Interacciones_Asistente_IA__c = 1;
            insert(caseExtension);

            casoCliente.CBK_Case_Extension_Id__c = caseExtension.Id;
            update(casoCliente);
        }
	}

    @IsTest
    public static void testgetCaseExtension() {
        Case caso = [SELECT id, AccountId, CBK_Case_Extension_Id__c FROM Case WHERE Subject = 'Caso cliente Test' Limit 1];
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Gestor CC' LIMIT 1];
        CBK_Case_Extension__c caseExtension = [SELECT Id, CC_IA_Historico_ChatGpt__c,CC_IA_Interacciones_Asistente_IA__c  FROM CBK_Case_Extension__c WHERE Id = :caso.CBK_Case_Extension_Id__c LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();
            CBK_Case_Extension__c valoracion= CC_IA_ChatGpt_Controller.getCaseExtension(caseExtension.Id);
            Test.stopTest();
            System.assertEquals(caso.CBK_Case_Extension_Id__c, valoracion.Id, 'Tienen el mismo ID".');
        }
    }

     @isTest
    static void testGetCaseExtensionValoracionConError() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Gestor CC' LIMIT 1];
        System.runAs(usuario) {
            try {
                CBK_Case_Extension__c extension = CC_IA_ChatGpt_Controller.getCaseExtension(null);
                System.assert(false, 'Se esperaba que se lanzara una excepción AuraHandledException');
            } catch (AuraHandledException e) {
                System.assertEquals('Script-thrown exception', e.getMessage(),'Salta la excepción');
            }
        }
    }

    @isTest
    static void testejecutarPrompt() {
        Case caso = [SELECT id, AccountId, CBK_Case_Extension_Id__c, CC_Canal_Procedencia__c FROM Case WHERE Subject = 'Caso cliente Test' Limit 1];
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Gestor CC' LIMIT 1];
        String pregunta='Que dia es hoy';
        CC_IA_Einstein_Config__c config = new CC_IA_Einstein_Config__c();
        config.Name= 'TestCanal';
        config.CC_IA_RAG_Activo__c= false;
        config.CC_IA_ON_OFF__c=true;
        insert config;

        System.runAs(usuario) {                  
            Test.startTest();
            String result = CC_IA_ChatGpt_Controller.ejecutarPrompt(pregunta, caso.Id);
            Test.stopTest();

            System.assertEquals('', result, 'La respuesta es vacía porque el LLM en clase de test lo devuelve vacío.');
        }
    }
   
    @isTest
    static void testejecutarPromptSinCaseExtension() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Gestor CC' LIMIT 1];
        //Case caso = [SELECT id, AccountId FROM Case WHERE Subject = 'Caso cliente Test' Limit 1];
        String pregunta='Que dia es hoy';
        CC_IA_Einstein_Config__c config = new CC_IA_Einstein_Config__c();
        config.Name= 'TestCanal';
        config.CC_IA_RAG_Activo__c= false;
        config.CC_IA_ON_OFF__c=true;
        insert config;
       

        System.runAs(usuario) {
            Case caso = [SELECT id, AccountId, CBK_Case_Extension_Id__c FROM Case WHERE Subject = 'Caso cliente Test' Limit 1];
            caso.CBK_Case_Extension_Id__c = null;
            update caso;

            Test.startTest();
            String result = CC_IA_ChatGpt_Controller.ejecutarPrompt(pregunta, caso.Id);
            Test.stopTest();

            System.assertEquals('El Caso no tiene un registro de Case Extension asociado.', result, 'Coincide con el mensaje esperado.');
        }
    }
    @isTest
    static void testejecutarPromptSinSubject() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Gestor CC' LIMIT 1];
        //Case caso = [SELECT id, AccountId FROM Case WHERE Subject = 'Caso cliente Test' Limit 1];
        String pregunta='Que dia es hoy';
       

        System.runAs(usuario) {
            Case caso = [SELECT id, AccountId, Subject FROM Case WHERE Subject = 'Caso cliente Test' Limit 1];
            caso.Subject = '';
            update caso;
            
            Test.startTest();
            String result = CC_IA_ChatGpt_Controller.ejecutarPrompt(pregunta, caso.Id);
            Test.stopTest();

            System.assertEquals('El Caso no contiene la información necesaria para ejecutar el chat', result, 'Coincide con el mensaje esperado.');
        }
    }
    @isTest
    static void testActualizarCaseExtension() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Gestor CC' LIMIT 1];
        Case caso = [SELECT id, AccountId FROM Case WHERE Subject = 'Caso cliente Test' Limit 1];

        // Crear un registro de Case Extension
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
            caseExtension.CC_IA_Historico_ChatGpt__c = 'Historico de chat';
            caseExtension.CC_IA_Interacciones_Asistente_IA__c = 10;            
            insert caseExtension;

            caso.CBK_Case_Extension_Id__c=caseExtension.Id;
            update caso;

        // Maps con Info
        Map<String, Object> fields = new Map<String, Object>{
            'historicoChat' => 'Nuevo historico de chat',
            'interacciones' => 20
        };
        System.runAs(usuario) {
            Test.startTest();
            CC_IA_ChatGpt_Controller.actualizarCaseExtension(caso.Id, fields);
            Test.stopTest();
            // Verificar que el registro de Case Extension haya sido actualizado
            CBK_Case_Extension__c actualizadoCasoExtension = [SELECT Id, CC_IA_Historico_ChatGpt__c, CC_IA_Interacciones_Asistente_IA__c 
                                                            FROM CBK_Case_Extension__c 
                                                            WHERE Id = :caseExtension.Id WITH SECURITY_ENFORCED LIMIT 1];
            System.assert(actualizadoCasoExtension.CC_IA_Historico_ChatGpt__c == 'Nuevo historico de chat', 'Coincide el historico');
            System.assert(actualizadoCasoExtension.CC_IA_Interacciones_Asistente_IA__c == 20, 'Coinciden las interacciones');
        }
    }
}