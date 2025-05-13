@isTest
private with sharing class CC_IA_CasosUltimaSemana_Controller_Test {

    @TestSetup
      private  static void testSetup(){
            User usuarioAdmin = [SELECT Id FROM User WHERE Profile.Name IN ('System Administrator', 'Administrador del sistema')
								AND IsActive = TRUE LIMIT 1];
		System.runAs(usuarioAdmin) {
			User adminKinton = new User();
			adminKinton.LastName = 'Administrador Kinton';
			adminKinton.Alias = 'AUno';
			adminKinton.Email = 'ccAgenteGC@invalid.com';
			adminKinton.UserName = 'ccAgenteGC_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
			adminKinton.ProfileId = [SELECT Id FROM Profile WHERE Name = 'API Only'].Id;
			adminKinton.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
			adminKinton.EmailEncodingkey = 'UTF-8';
			adminKinton.LanguageLocaleKey = 'en_US';
			adminKinton.LocalesIdKey = 'en_US';
			adminKinton.TimezonesIdKey = 'Europe/Madrid';

			insert adminKinton;

			PermissionSet psKinAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'KIN_Admin'];
			insert new PermissionSetAssignment(PermissionSetId = psKinAdmin.Id, AssigneeId = adminKinton.Id);
		}

		Id idRtServicioGenesys = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();
		CC_Servicio_Genesys__c s1 = new CC_Servicio_Genesys__c();
		s1.RecordTypeId = idRtServicioGenesys;
		s1.Name = 'Servicio 1';
		s1.CC_Codigo__c = 'S1';
		s1.CC_VDN__c = '4444444';
		s1.CC_Tipo__C = 'Servicio';
		s1.CC_Canal_Procedencia__c = 'CaixaBankNow';
		s1.CC_Prefijo__c = '0';
		s1.CC_Tipo_Cliente__c = 'Cliente';

		CC_Servicio_Genesys__c s2 = new CC_Servicio_Genesys__c();
		s2.RecordTypeId = idRtServicioGenesys;
		s2.Name = 'SACH GenesysCloudOutboundDefault';
		s2.CC_Codigo__c = 'SACH_GenesysCloudOutboundDefault';
		s2.CC_Tipo__C = 'Servicio';
		s2.CBK_Negocio__c = 'SACH';
		s2.CC_Tipo_Cliente__c = 'Cliente';
		s2.CC_VDN__c = '4444444';
		s2.CC_Canal_Procedencia__c = 'CaixaBankNow';
		s2.CC_Prefijo__c = '0';
		s2.CC_Fecha_Inicio_Salesforce__c = Date.today();
		s2.CC_Principal__c = true;
		insert new List<CC_Servicio_Genesys__c>{s1, s2};

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

        User adminKinton = [SELECT Id FROM User WHERE LastName = 'Administrador Kinton'];
        System.runAs(adminKinton) {
			Account oficinaGestora = new Account();
			oficinaGestora.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
			oficinaGestora.CC_Numero_Empresa__c = '001';
			oficinaGestora.CC_Numero_Oficina__c = '00001';
			oficinaGestora.CC_Numero_Oficina_Empresa__c = '001-00001';
			oficinaGestora.Name = 'Oficina gestora Test';
			oficinaGestora.CC_Tipo_Centro__c = 'OF';
			oficinaGestora.CC_Email__c = 'test@test.com';
			insert oficinaGestora;

			Contact empleadoGestor = new Contact();
			empleadoGestor.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
			empleadoGestor.LastName = 'Empleado gestor Test';
			empleadoGestor.AccountId = oficinaGestora.Id;
			insert empleadoGestor;

			Account cuenta = new Account();
			cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			cuenta.Name = 'Cuenta Test';
			cuenta.CC_NumPerso__c = '666';
			cuenta.CC_OficinaGestoraId__c = oficinaGestora.Id;
			cuenta.AV_OficinaPrincipal__c = oficinaGestora.Id;
			cuenta.AV_EAPGestor__c = empleadoGestor.Id;
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
			casoCliente.Subject = 'Caso cliente Test';
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
		}
	}

    @isTest
    static void testInvocation() {
    Case caso = [SELECT id, AccountId FROM Case WHERE Subject = 'Caso cliente Test' Limit 1];
    User usuario = [SELECT id FROM User WHERE LastName = 'Administrador Kinton' AND isActive = true Limit 1];
    System.runAs(usuario) {
        Test.startTest();
			String result = CC_IA_CasosUltimaSemana_Controller.generarResumenCasos(caso.Id);
        Test.stopTest();
    
        // THEN
        Assert.areEqual(
            '',
            result,
            'E'
        );
    }
    }
}