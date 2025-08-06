@isTest
public class GRR_MarcarBorrarURs_BatchTest {

    @TestSetup
    static void setupTestData() {

        User usuario = GRR_TestDataFactory.usuarioPruebasGRR();
        System.runAs(usuario) {
        // Crear UR de prueba con fecha antigua
        GRR_UR__c urAntigua = new GRR_UR__c(
            CreatedDate = CBK_UtilsDate.nowSYS().addYears(-9),
            GRR_Id_UR__c = '1234567890',
            GRR_ToDelete__c = false
        );
        insert urAntigua;
        }
    }

    
    @isTest
    static void testBatch() {
        User usuario = [SELECT Id FROM User WHERE FirstName = 'GRR' LIMIT 1];
        System.runAs(usuario) {
        Test.startTest();
        GRR_MarcarBorrarURs_Batch batch = new GRR_MarcarBorrarURs_Batch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verificar resultados
        List<GRR_UR__c> ursActualizadas = [
            SELECT Id, GRR_ToDelete__c 
            FROM GRR_UR__c 
            WHERE GRR_ToDelete__c = false
        ];
        
        // La UR antigua debería estar marcada para borrar
        System.assertEquals(true, ursActualizadas.isEmpty(), 'Se ha marcado para borrar una UR que no debería');
        }
    }
}