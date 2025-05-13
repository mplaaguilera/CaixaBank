@isTest
public with sharing class CSBD_WS_PreAltaOportunidad_Test {

    @isTest
    static void testPreAltaOportunidad() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Test.startTest();
            CSBD_WS_PreAltaOportunidad.Output output = CSBD_WS_PreAltaOportunidad.preAltaOportunidad();
            Test.stopTest();

            System.assertEquals('OK', output.resultado);
        }
    }
}