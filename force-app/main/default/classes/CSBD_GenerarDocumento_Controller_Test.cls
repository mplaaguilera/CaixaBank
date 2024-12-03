@isTest
public with sharing class CSBD_GenerarDocumento_Controller_Test {

	@testSetup
	private static void testSetup() {
		User gestor = new User();
		gestor.LastName = 'Gestor CSBD Test';
		gestor.Alias = 'gestor';
		gestor.Email = 'gestorcsbd@caixabank.com.invalid';
		gestor.Username = 'gestorcsbd_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
		gestor.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CSBD Gestor'].Id;
		gestor.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'CSBD_Generico'].Id;
		gestor.EmailEncodingkey = 'ISO-8859-1';
		gestor.LanguageLocaleKey = 'es';
		gestor.LocalesIdKey = 'es';
		gestor.TimezonesIdKey = 'Europe/Madrid';
		insert gestor;


		PermissionSet psGestorCsbd = [SELECT Id FROM PermissionSet WHERE Name = 'CSBD_PS_Gestor'];
		insert new PermissionSetAssignment(PermissionSetId = psGestorCsbd.id, AssigneeId = gestor.Id);
	}

	@isTest
	public static void generarDocumento() {
        User usuarioGestor = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test' LIMIT 1];
        System.runAs(usuarioGestor) {
			Map<String, Object> campos = new Map<String, Object>{'CSBD_GenerarDocumentoHtml__c' => '<p>hola&nbsp;OP-344833701 - 2</p>'};
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);

			Test.startTest();
			ContentVersion documento = CSBD_GenerarDocumento_Controller.generarDocumento(oportunidad.Id);
			Test.stopTest();


			System.assertNotEquals(null, documento.Title, 'Document Title should not be null');
		}
	}

	@isTest
	public static void getOrigin() {
		User usuarioGestor = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test' LIMIT 1];
        System.runAs(usuarioGestor) {
			Test.startTest();
			String originLwc = CSBD_GenerarDocumento_Controller.getOrigin('lwc');
			CSBD_GenerarDocumento_Controller controller = new CSBD_GenerarDocumento_Controller();
			String originVf = controller.origin;
			Test.stopTest();

			System.assertNotEquals(null, originLwc, 'Visualforce hostname should not be null');
			System.assertNotEquals(null, originVf, 'Visualforce hostname should not be null');
		}
	}
}