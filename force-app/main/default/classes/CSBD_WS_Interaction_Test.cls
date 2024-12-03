@isTest
public class CSBD_WS_Interaction_Test {  
    @testSetup
    private static void setup() {   
        User usuarioAdministrador = CSBD_Usuarios.usuarioAdministrador();
    }
    @isTest
    static void testCSBD_WS_Interaction() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' AND LastName = '1' AND Email = 'usuario_test@test.com' LIMIT 1];
        System.runAs (usuarioAdministrador) {
            Test.startTest();
            CSBD_WS_Interaction interaction = new CSBD_WS_Interaction();
            interaction.pasarTest = 'testValue';
            Test.stopTest();
        System.assertEquals('testValue', interaction.pasarTest);
    } 
    }    
}