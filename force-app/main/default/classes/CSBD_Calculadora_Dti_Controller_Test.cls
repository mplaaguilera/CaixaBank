@isTest
public with sharing class CSBD_Calculadora_Dti_Controller_Test {

    @TestSetup
	private static void testSetup() {
		User admin = new User();
        admin.profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        admin.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'CSBD_Generico'].Id;
        admin.FirstName = 'Admin';
        admin.LastName = 'Admin';
        admin.Email = 'tuser000@amamama.com';
		admin.UserName = 'admintest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
        admin.Alias = 'alias';
        admin.TimeZoneSidKey = 'Europe/Paris';
        admin.EmailEncodingKey = 'UTF-8';
        admin.LanguageLocaleKey = 'es';
        admin.LocaleSidKey = 'es_ES';
		insert admin;

		System.runAs(admin) {
			User gestor = new User();
			gestor.FirstName = 'GestorCSBD';
			gestor.LastName = 'GestorCSBD';
			gestor.IsActive = true;
			gestor.Alias = 'Gestor';
			gestor.Email = 'usuario_test@test.com';
			gestor.EmailEncodingKey = 'ISO-8859-1';
			gestor.LanguageLocaleKey = 'es';
			gestor.LocaleSidKey = 'es_ES';
			gestor.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CSBD Genérico'].Id;
			gestor.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSBD Gestor'].Id;
			gestor.TimeZoneSidKey = 'Europe/Madrid';
			gestor.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
			insert gestor;

			PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CSBD_PS_Gestor' LIMIT 1];
			if (permissionSet != null) {
				PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
				nuevoPermiso.PermissionSetId = permissionSet.Id;
				nuevoPermiso.AssigneeId = gestor.Id;
				insert nuevoPermiso;
			}

			System.runAs(admin) {
				CC_Lista_Valores__c lov = new CC_Lista_Valores__c();
                lov.Name = 'CSBD: Fondos propios - Tipos impositivos';
                lov.CC_Activa__c = true;
                lov.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
                insert lov;

                CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c();
                valor1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
                valor1.CC_Lista__c = lov.Id;
                valor1.Name = 'Andalucía';
                valor1.CC_Valor__c = '0.2';
                valor1.CC_Activa__c = true;

                CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
                valor2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
                valor2.CC_Lista__c = lov.Id;
                valor2.Name = 'Andalucía';
                valor2.CC_Valor__c = '0.4';
                valor2.CC_Activa__c = true;
                insert new List<CC_Lista_Valores__c>{valor1, valor2};
			}
		}
	}

    @isTest
    public static void tiposBonificados() {
        User usuarioGestor = [SELECT Id FROM User WHERE LastName = 'GestorCSBD' LIMIT 1];
		System.runAs(usuarioGestor) {
            Test.startTest();
            Map<String, List<Map<String, Object>>> retorno = CSBD_Calculadora_Dti_Controller.tiposBonificados();
            Test.stopTest();

            System.assert(!retorno.isEmpty(), 'El retorno debe contener datos');
        }
    }
}