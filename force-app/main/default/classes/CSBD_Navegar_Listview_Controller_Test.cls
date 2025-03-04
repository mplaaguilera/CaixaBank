@isTest
public with sharing class CSBD_Navegar_Listview_Controller_Test {

    @isTest
    public static void test() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Test.startTest();
            System.assertEquals(true, CSBD_Navegar_Listview_Controller.esResponsable(), 'CSBD_Navegar_Listview_Controller.esResponsable() KO');
            System.assertNotEquals(null, CSBD_Navegar_Listview_Controller.getListviews(''), 'CSBD_Navegar_Listview_Controller.getListviews() KO');
            Test.stopTest();
        }
    }
}