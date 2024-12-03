@isTest
public with sharing class KIN_Genesys_Cloud_CTI_Extensions_Test {

    @TestSetup
    public static void testSetup() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Profile.Name LIKE 'System Administrator' AND IsActive = TRUE LIMIT 1];
        System.runAs(usuarioAdmin) {
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
    }

    @isTest
    public static void onClickToDial1() {
        User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];
		System.runAs(gestorCsbd) {
            Map<String, Object> input = new Map<String, Object>{'object' => 'Account'};

            Test.startTest();
            KIN_Genesys_Cloud_CTI_Extensions ctiExtensions = new KIN_Genesys_Cloud_CTI_Extensions();
            String retorno = ctiExtensions.onClickToDial(JSON.serialize(input));
            Test.stopTest();

            System.assertEquals('', retorno, 'El retono debería ser un String vacío al ser no ser object ni "Case" ni "Opportunity".');
        }
    }

    @isTest
    public static void onClickToDial2() {
        User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];
		System.runAs(gestorCsbd) {
            Case caso = new Case();
            insert caso;
            Map<String, Object> input = new Map<String, Object>{'object' => 'Case', 'objectId' => caso.Id};

            Test.startTest();
            KIN_Genesys_Cloud_CTI_Extensions ctiExtensions = new KIN_Genesys_Cloud_CTI_Extensions();
            String retorno = ctiExtensions.onClickToDial(JSON.serialize(input));
            Test.stopTest();

            Map<String, Object> clickToDialData = (Map<String, Object>)JSON.deserializeUntyped(retorno);
            System.assert(clickToDialData.containsKey('interactionAttributes'), 'Deberían haberse añadido custom attributes a la respuesta.');
        }
    }

    @isTest
    public static void onClickToDial3() {
        CC_Servicio_Genesys__c s1 = new CC_Servicio_Genesys__c();
        s1.RecordTypeId = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();
        s1.CBK_Negocio__c = 'CSBD';
        s1.CC_Tipo__C = 'Servicio';
        s1.Name = 'NIS Genesys Cloud Saliente Por Defecto';
        s1.CC_Codigo__c = 'NIS_GenesysCloudOutboundDefault';
        s1.CC_VDN__c = '4444444';
        s1.CC_Prefijo__c = '0';
        s1.CC_Tipo_Cliente__c = 'Cliente';
        s1.CC_Fecha_Inicio_Salesforce__c = Date.today();
        s1.CC_Principal__c = true;
        insert s1;

        User gestorCsbd = [SELECT Id FROM User WHERE LastName = 'Gestor CSBD Test'];
		System.runAs(gestorCsbd) {
            Opportunity opoprtunidad = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca');
            Map<String, Object> input = new Map<String, Object>{'object' => 'Opportunity', 'objectId' => opoprtunidad.Id};

            Test.startTest();
            KIN_Genesys_Cloud_CTI_Extensions ctiExtensions = new KIN_Genesys_Cloud_CTI_Extensions();
            String retorno = ctiExtensions.onClickToDial(JSON.serialize(input));
            Test.stopTest();

            Map<String, Object> clickToDialData = (Map<String, Object>)JSON.deserializeUntyped(retorno);
            System.assert(clickToDialData.containsKey('interactionAttributes'), 'Deberían haberse añadido custom attributes a la respuesta.');
        }
    }
}