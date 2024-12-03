@isTest
public with sharing class GRR_ActualizarFechaLanzamientoBatch_Test {

    private static GRR_UR__c crearUR() {
        GRR_UR__c ur = new GRR_UR__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_UR__c', 'GRR_UR'),
            GRR_Id_UR__c = '00000001',
            GRR_Fecha_Proximo_Lanzamiento__c = Datetime.now(),
            GRR_Situacion_Proximo_Lanzamiento__c = '',
            GRR_Situacion_Ultimo_Lanzamiento__c = ''
        );
        insert ur;
        return ur;
    }

    private static void crearLanzamiento(String urid) {
        GRR_UR__c ur = [SELECT Id, GRR_Id_UR__c FROM GRR_UR__c WHERE Id = :urid];
        GRR_Lanzamiento__c lanzamiento = new GRR_Lanzamiento__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Lanzamiento__c', 'GRR_Lanzamiento'),
            GRR_UR__c = ur.Id,
            GRR_Codigo_UR__c = ur.GRR_Id_UR__c,
            GRR_Fecha_Prevista_Posesion__c = Datetime.now()-1,
            GRR_Situacion__c = 'Lanzamiento Suspendido'
        );
        insert lanzamiento;
    }

    @isTest
    public static void testBatch() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            GRR_UR__c ur = crearUR();
            crearLanzamiento(ur.Id);
            List<GRR_UR__c> lstURs = new List<GRR_UR__c>();
            lstURs.add(ur);

            Test.startTest();
            GRR_Actualizar_Fechas_Lanzamiento_Batch batch = new GRR_Actualizar_Fechas_Lanzamiento_Batch();
            Database.executeBatch(batch);
            Test.stopTest();

            System.assertEquals('Lanzamiento Suspendido', [SELECT GRR_Situacion_Ultimo_Lanzamiento__c FROM GRR_UR__c LIMIT 1].GRR_Situacion_Ultimo_Lanzamiento__c);
        }
    }

}