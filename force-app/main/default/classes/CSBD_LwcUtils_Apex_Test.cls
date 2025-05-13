@isTest
public class CSBD_LwcUtils_Apex_Test {

    @isTest
    private static void usuarioDesarrolladorTest() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

            System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
                Test.startTest();
                System.assertEquals(false, CSBD_LwcUtils_Apex.usuarioDesarrollador(usuarioGestor.Id), 'El usuario gestor no deberia ser identificado como desarrollador');
                Test.stopTest();
            }
        }
    }
}