@isTest
public class CSBD_WS_Interaction_Test {
    @testSetup
    private static void setup() {
        User usuarioAdministrador = CSBD_TestDataFactory.usuarioAdministrador();
    }

    @isTest
    private static void csbdWsInteractionTest() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD'];
        System.runAs (usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_Interaction interaction = new CSBD_WS_Interaction();
            Test.stopTest();

            interaction.pasarTest = 'testValue';
            System.assertEquals('testValue', interaction.pasarTest);
        }
    }
}