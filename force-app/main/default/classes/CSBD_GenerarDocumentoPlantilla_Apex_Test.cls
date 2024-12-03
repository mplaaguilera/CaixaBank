@isTest
public with sharing class CSBD_GenerarDocumentoPlantilla_Apex_Test {

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

        EmailTemplate plantillaDocumento = new EmailTemplate();
        plantillaDocumento.DeveloperName = 'CSBD_Test_Generar_Doc_' + System.now().getTime();
        plantillaDocumento.Name = 'plantillaPdf';
        plantillaDocumento.TemplateType = 'custom';
        plantillaDocumento.FolderId = gestor.Id;
        plantillaDocumento.isActive = true;
        plantillaDocumento.Body = 'cuerpo';
        plantillaDocumento.HtmlValue = '<html><body>cuerpo</body></html>';
        System.runAs(gestor) {
            insert plantillaDocumento;
        }
	}

	@isTest
	public static void verCarpetaInicial() {
        User usuarioGestor = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test' LIMIT 1];
        System.runAs(usuarioGestor) {
            Test.startTest();
            Map<String, Object> retorno = CSBD_GenerarDocumentoPlantilla_Apex.verCarpetaInicial('carpetaDeveloperName');
            Test.stopTest();

            System.assertEquals(3, retorno.size(), 'El mapa retornado debería tener 3 claves');
        }
    }

	@isTest
	public static void verCarpeta() {
        User usuarioGestor = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test' LIMIT 1];
        System.runAs(usuarioGestor) {
            Test.startTest();
            Map<String, Object> retorno = CSBD_GenerarDocumentoPlantilla_Apex.verCarpeta(usuarioGestor.id);
            Test.stopTest();

            System.assertEquals(3, retorno.size(), 'El mapa retornado debería tener 3 claves');
        }
    }

	@isTest
	public static void cuerpoPlantilla() {
        User usuarioGestor = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test' LIMIT 1];
        System.runAs(usuarioGestor) {
            Map<String, Object> campos = new Map<String, Object>{'CSBD_GenerarDocumentoHtml__c' => '<p>hola&nbsp;OP-344833701 - 2</p>'};
			Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);

            EmailTemplate plantillaPdf = [SELECT Id FROM EmailTemplate WHERE Name = 'plantillaPdf'];
            Test.startTest();
            String cuerpoPlantilla = CSBD_GenerarDocumentoPlantilla_Apex.cuerpoPlantilla(plantillaPdf.Id, oportunidad.Id);
            Test.stopTest();

            System.assertNotEquals(null, cuerpoPlantilla, 'cuerpoPlantilla should not be null');
        }
    }

	@isTest
	public static void buscarPlantillas() {
        User usuarioGestor = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test' LIMIT 1];
        System.runAs(usuarioGestor) {
            Test.startTest();
            List<EmailTemplate> resultado = CSBD_GenerarDocumentoPlantilla_Apex.buscarPlantillas(usuarioGestor.id, 'cadena_búsqueda');
            Test.stopTest();

            System.assertNotEquals(null, resultado, 'resultado should not be null');
        }
    }
}