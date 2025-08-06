@isTest
private class SEG_DiscrepanciaOrgZona_Test {
    @isTest
    static void testObtenerMtd() {
        User supervisor = [SELECT Id FROM User WHERE Profile.Name = 'SEG_Usuario_CaixaBank' AND IsActive = true AND FirstName = 'IBM' AND LastName = 'Segmentos' LIMIT 1];
        System.runAs(supervisor){
            Test.startTest();
            List<SEG_Excepciones_Org_Zona__mdt> listMdt = SEG_DiscrepanciaOrgZona.obtenerMtd();
            Test.stopTest();
            
            // Verify the results
            System.assertNotEquals(null, listMdt, 'No se ha encontrado la metadata');
        }
    }
}