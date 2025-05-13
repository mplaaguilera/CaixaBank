@isTest
public with sharing class CC_IA_CasosAbiertosUltimaSemana_Test {

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

			CC_MCC__c tematica = new CC_MCC__c();
			tematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
			tematica.CC_Tipo_Cliente__c = 'Cliente';
			tematica.Name = 'Temática';
			tematica.CC_Codigo_Externo__c = 'T1';
			tematica.CC_Canal_Operativo__c = 'Oficina';
			insert tematica;

			CC_MCC__c producto = new CC_MCC__c();
			producto.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
			producto.CC_Tipo_Cliente__c = 'Cliente';
			producto.Name = 'Producto';
			producto.CC_Tematica__c = tematica.Id;
			producto.CC_Codigo_Externo__c = 'P1';
			insert producto;

			CC_MCC__c motivo = new CC_MCC__c();
			motivo.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
			motivo.CC_Tipo_Cliente__c = 'Cliente';
			motivo.Name = 'Motivo';
			motivo.CC_Producto_Servicio__c = producto.Id;
			motivo.CC_Codigo_Externo__c = 'M1';
			insert motivo;

			CC_MCC__c causa = new CC_MCC__c();
			causa.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
			causa.CC_Tipo_Cliente__c = 'Cliente';
			causa.Name = 'Causa';
			causa.CC_Motivo__c = motivo.Id;
			causa.CC_Codigo_Externo__c = 'C1';
			insert causa;

			CC_MCC__c solucion = new CC_MCC__c();
			solucion.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
			solucion.CC_Tipo_Cliente__c = 'Cliente';
			solucion.Name = 'Solucion';
			solucion.CC_Causa__c = causa.Id;
			solucion.CC_Codigo_Externo__c = 'S1';
			insert solucion;

			Account cuenta = new Account();
			cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			cuenta.Name = 'Cuenta Test';
			cuenta.CC_NumPerso__c = '666';
			insert cuenta;

			Contact contacto = new Contact();
			contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			contacto.AccountId = cuenta.Id;
			contacto.FirstName = 'Contacto';
			contacto.LastName = 'Contacto Test';
			contacto.CC_NumPerso__c = '666';
			insert contacto;

			Case casoCliente = new Case();
			casoCliente.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			casoCliente.Subject = 'Caso cliente Testeo';
			casoCliente.Origin = 'Phone';
			casoCliente.CC_Canal_Respuesta__c = 'Phone';
			casoCliente.CC_Tipo_Cliente__c = 'Cliente';
			casoCliente.CC_No_Identificado__c = true;
			casoCliente.CC_Canal_Procedencia__c = 'CaixaBankNow';
			casoCliente.CC_MCC_Tematica__c = tematica.Id;
			casoCliente.CC_MCC_ProdServ__c = producto.Id;
			casoCliente.CC_MCC_Motivo__c = motivo.Id;
			casoCliente.CC_MCC_Causa__c = causa.Id;
			casoCliente.CC_MCC_Solucion__c = solucion.Id;
            casoCliente.AccountId = cuenta.id;
			insert casoCliente;


            Case casoCliente2 = new Case();
			casoCliente2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			casoCliente2.Subject = 'Caso cliente Test2';
			casoCliente2.Origin = 'Phone';
			casoCliente2.CC_Canal_Respuesta__c = 'Phone';
			casoCliente2.CC_Tipo_Cliente__c = 'Cliente';
			casoCliente2.CC_No_Identificado__c = true;
			casoCliente2.CC_Canal_Procedencia__c = 'CaixaBankNow';
			casoCliente2.CC_MCC_Tematica__c = tematica.Id;
			casoCliente2.CC_MCC_ProdServ__c = producto.Id;
			casoCliente2.CC_MCC_Motivo__c = motivo.Id;
			casoCliente2.CC_MCC_Causa__c = causa.Id;
			casoCliente2.CC_MCC_Solucion__c = solucion.Id;
            casoCliente2.AccountId = cuenta.id;
			insert casoCliente2;

            Case casoCliente3 = new Case();
			casoCliente3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			casoCliente3.Subject = 'Caso cliente Test3';
			casoCliente3.Origin = 'Phone';
			casoCliente3.CC_Canal_Respuesta__c = 'Phone';
			casoCliente3.CC_Tipo_Cliente__c = 'Cliente';
			casoCliente3.CC_No_Identificado__c = true;
			casoCliente3.CC_Canal_Procedencia__c = 'CaixaBankNow';
			casoCliente3.CC_MCC_Tematica__c = tematica.Id;
			casoCliente3.CC_MCC_ProdServ__c = producto.Id;
			casoCliente3.CC_MCC_Motivo__c = motivo.Id;
			casoCliente3.CC_MCC_Causa__c = causa.Id;
			casoCliente3.CC_MCC_Solucion__c = solucion.Id;
            casoCliente3.AccountId = cuenta.id;
			insert casoCliente3;
		}
	}

    @isTest
    public static void testObtenerCasosAbiertos() {
        Case caso = [SELECT id, AccountId, status FROM Case WHERE Subject = 'Caso cliente Testeo' Limit 1];
		User usuario = [SELECT id FROM User WHERE FirstName = 'Gestor CC' AND isActive = true Limit 1];
        System.runAs(usuario) {
			Test.startTest();
			CC_IA_CasosAbiertosUltimaSemana.Request request = new CC_IA_CasosAbiertosUltimaSemana.Request();
			request.objectToSummarize = caso;	
			// Llamar al método obtenerCasosAbiertos
			List<CC_IA_CasosAbiertosUltimaSemana.Response> responses = CC_IA_CasosAbiertosUltimaSemana.obtenerCasosAbiertos(new List<CC_IA_CasosAbiertosUltimaSemana.Request> { request });
			Test.stopTest();

			// Verificar que la respuesta no esté vacía
        	System.assert(!responses.isEmpty(), 'La lista de respuestas no debe estar vacía.');

        // Verificar que la respuesta contenga el resumen de los casos cerrados
        String responseData = responses[0].Prompt;

		System.assert(responseData.contains('Resumen de casos cerrados del cliente:'), 'Debe incluir el encabezado de resumen.');
        System.assert(responseData.contains('Número de caso: '), 'Debe incluir el número de caso.');
        System.assert(responseData.contains('Temática: '), 'Debe incluir la temática.');
        System.assert(responseData.contains('Asunto: Caso cliente Test2'), 'Debe incluir el asunto de los casos.');
        System.assert(responseData.contains('Caso cliente Test3'), 'El asunto del tercer caso debe estar presente.');
        System.assert(!responseData.contains('Caso cliente Testeo'), 'El caso inicial no debe aparecer en la respuesta.');
		}
    }
}