@isTest
public class CSBD_AppUtilities_Test {

    @isTest
    private static void testHexadecimal(){
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            String numper = CSBD_AppUtilities.formatearNumperso('A120E2');
            Test.stopTest();

            System.assertEquals('10559714', numper, 'Comprobamos que los numper coinciden');
        }
    }

    @isTest
    private static void testRestaFechas(){
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            Long numper = CSBD_AppUtilities.calculateTimeDifferences(Datetime.now() - 1, Datetime.now());
            Test.stopTest();

            System.assert(numper > 30, 'Comprobamos que la fecha es superior a los 30 min');
        }
    }
}