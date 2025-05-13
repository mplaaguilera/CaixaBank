/*****************************************************************
 * Name: CC_IA_CallerWrapper_Test
 * Copyright © 2024  CaixaBank
 * 
 * @description: Clase Test para Handler del LLM
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0                             Borja Lavesiera   07/01/24     Creación
*****************************************************************/
@isTest
/**
     * @description   Clase Test para Handler del LLM
     * @Autor: Borja Lavesiera Muñoz
     */
public with sharing class CC_IA_CallerWrapper_Test  {

    @TestSetup
    private static void testSetup() {
		Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
		// Usuario Gestor
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

		System.runAs(usuarioGestor){
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

            //Control Tiempos
            //Datetime fecha = Datetime.now();
            //Datetime fechaInicio = fecha.addHours(2);
            //Datetime fechaCaducidad = fecha.addHours(10);

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
    @isTest
    static void testLlmCaseCallerWrapperWithException() {
        Case caso = [SELECT id, AccountId, CBK_Case_Extension_Id__c FROM Case WHERE Subject = 'Caso cliente Test' Limit 1];
        User usuario = [SELECT Id FROM User WHERE FirstName = 'Gestor CC' LIMIT 1];
        String caseId = caso.Id;
        // Creamos un mapa de prueba para los IDs de objetos
        Map<String, String> objectIdsMap = new Map<String, String>{'Case' => caseId}; // Usamos un ID de ejemplo

        // Simulamos el comportamiento de la llamada al LLM
        String promptTemplate = 'CC_IA_Chat_Interactivo';
        String freeText = 'Texto libre de prueba';

        // Crear instancia de la clase CC_IA_CallerWrapper
        CC_IA_CallerWrapper wrapper = new CC_IA_CallerWrapper();

        //Exception exc;  // Capturamos la excepción genérica
        System.runAs(usuario) {
            Test.startTest();
            try {
                // Llamamos al método que lanzará la excepción si ocurre algún error
                String resultado = wrapper.llmCaseCallerWrapper(objectIdsMap, promptTemplate, freeText);
            } catch (Exception e) {
                CBK_Log.error('@@Excepción capturada: ' + e.getMessage());
                CBK_Log.error('@@Detalle de la excepción: ' + e);
            }
            Test.stopTest();
        }

        // Verificamos que la excepción fue capturada correctamente
        System.assertNotEquals(null, CC_IA_CallerWrapper.testException, 'La excepción no fue lanzada como se esperaba.');
        System.assertEquals('ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true).', CC_IA_CallerWrapper.testException.getMessage(), 'El mensaje de error no coincide.');
        
    }
}