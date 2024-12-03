@isTest
public with sharing class CSBD_Navegar_Listview_Controller_Test {
    
    @isTest
    public static void test() {
        User usuarioAdministrador = CSBD_Usuarios.usuarioAdministrador();

        System.runAs ( usuarioAdministrador ) {
            Test.startTest();
            Boolean siEsResponsable = CSBD_Navegar_Listview_Controller.esResponsable();
            List<ListView> resultado = CSBD_Navegar_Listview_Controller.getListviews('');
            Test.stopTest();

            System.assertEquals(true, siEsResponsable);
            System.assertNotEquals(null, resultado);
        }
    }
}