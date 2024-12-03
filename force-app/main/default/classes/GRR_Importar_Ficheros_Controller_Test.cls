@isTest
private class GRR_Importar_Ficheros_Controller_Test {

    @isTest
    public static void testGetUrlImport() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            String url = GRR_Importar_Ficheros_Controller.getUrlImport('Lanzamiento');
            Test.stopTest();

            System.assertEquals(url != null, true);
        }
    }
}