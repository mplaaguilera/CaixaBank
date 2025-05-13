@isTest
public with sharing class KIN_Genesys_Cloud_CTI_Extensions_Test {
    @TestSetup
	private static void testSetup() {
       // Creamos un registro de Custom Setting HDT_Parametros__c para la prueba
        HDT_Parametros__c customSetting = new HDT_Parametros__c(
            Name = 'HDT_Llamadas_Salientes_No_Atendidas',
            HDT_Activo__c = true
        );
        insert customSetting;

    }


    @isTest
    public static void onClickToDial1() {
		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
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
       
		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            /*
            Case caso = new Case();
            insert caso;*/
            CC_Servicio_Genesys__c s1 = new CC_Servicio_Genesys__c();
            s1.RecordTypeId = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();
            s1.CBK_Negocio__c = 'HDT';
            s1.CC_Tipo__C = 'Servicio';
            s1.Name = 'HDT Genesys Cloud Outbound Default';
            s1.CC_Codigo__c = 'HDT Genesys Cloud Outbound Default';
            s1.CC_VDN__c = '4444444';
            s1.CC_Prefijo__c = '0';
            s1.CC_Tipo_Cliente__c = 'Empleado';
            s1.CC_Fecha_Inicio_Salesforce__c = Date.today();
            s1.CC_Principal__c = true;
            insert s1;


           

            Case caso = new Case();
            caso.Subject = 'Caso Test';
            caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
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
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
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
        }

		System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
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