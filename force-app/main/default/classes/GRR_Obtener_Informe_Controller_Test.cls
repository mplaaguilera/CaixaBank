@isTest
private class GRR_Obtener_Informe_Controller_Test {

    @isTest(SeeAllData=true)
    public static void testGetUrlImport() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            String idReport = GRR_Obtener_Informe_Controller.getReportId();
            Test.stopTest();

            System.assertEquals(true, idReport != null);
        }
    }
}