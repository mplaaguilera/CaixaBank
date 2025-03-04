@isTest
public with sharing class CBK_BorrarDatosSandbox_Test {

    @TestSetup
	private static void testSetup() {
        CSBD_TestDataFactory.usuarioAdministrador();
    }

	@isTest
	private static void borrarTrazasTest() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            Test.startTest();
            CBK_BorrarDatosSandbox.borrarTrazas();
            Test.stopTest();

            System.assertEquals(0, [SELECT COUNT() FROM CC_TrazaInt__c], 'Borrado de CC_TrazaInt__c KO');
        }
	}

	@isTest
	private static void borrarOportunidadesTest() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            Test.startTest();
            CBK_BorrarDatosSandbox.borrarOportunidades();
            Test.stopTest();

            System.assertEquals(0, [SELECT COUNT() FROM Opportunity], 'Borrado de Opportunity KO');
            System.assertEquals(0, [SELECT COUNT() FROM CSBD_Gestor_Oportunidad__c], 'Borrado de CSBD_Gestor_Oportunidad__c KO');
        }
	}

	@isTest
	private static void borrarLlamadasTest() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            Test.startTest();
            CBK_BorrarDatosSandbox.borrarLlamadas();
            Test.stopTest();

            System.assertEquals(0, [SELECT COUNT() FROM CC_Llamada__c], 'Borrado de CC_Llamada__c KO');
        }
	}

	@isTest
	private static void borrarChatsTest() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            Test.startTest();
            CBK_BorrarDatosSandbox.borrarChats();
            Test.stopTest();

            System.assertEquals(0, [SELECT COUNT() FROM LiveChatTranscript], 'Borrado de LiveChatTranscript KO');
        }
	}

	@isTest
	private static void borrarCasosTareasTest() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            Test.startTest();
            CBK_BorrarDatosSandbox.borrarCasosTareas();
            Test.stopTest();

            System.assertEquals(0, [SELECT COUNT() FROM CC_Marca_Case__c], 'Borrado de CC_Marca_Case__c KO');
            System.assertEquals(0, [SELECT COUNT() FROM SAC_Marca_Case__c], 'Borrado de SAC_Marca_Case__c KO');
            System.assertEquals(0, [SELECT COUNT() FROM SEG_Marcasdeuncaso__c], 'Borrado de SEG_Marcasdeuncaso__c KO');
            System.assertEquals(0, [SELECT COUNT() FROM CBK_CaseHistory__c], 'Borrado de CBK_CaseHistory__c KO');
            System.assertEquals(0, [SELECT COUNT() FROM Task], 'Borrado de Task KO');
            System.assertEquals(0, [SELECT COUNT() FROM Case], 'Borrado de Case KO');
        }
	}

    @isTest
    private static void borrarDatosSandboxTest() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            Test.startTest();
            CBK_BorrarDatosSandbox.borrarDatosSandbox();
            Test.stopTest();

            System.assertEquals(0, [SELECT COUNT() FROM Case], 'Borrado de Case KO');
        }
    }

    @isTest
    private static void notificarFinTest() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            Test.startTest();
            Messaging.SendEmailResult resultadoEnvio = CBK_BorrarDatosSandbox.notificarFin();
            Test.stopTest();

            System.assert(resultadoEnvio != null, 'Envío de correo de resultados ko');
        }
    }
}