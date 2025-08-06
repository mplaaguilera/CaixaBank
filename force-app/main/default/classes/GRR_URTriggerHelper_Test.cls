@isTest
public with sharing class GRR_URTriggerHelper_Test {

    private static GRR_UR__c crearUR() {
        GRR_UR__c ur = new GRR_UR__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_UR__c', 'GRR_UR'),
            GRR_Id_UR__c = '00000001'
        );
        insert ur;
        return ur;
    }

    private static GRR_Lanzamiento__c crearLanzamiento(String urid) {
        GRR_UR__c ur = [SELECT Id, GRR_Id_UR__c FROM GRR_UR__c WHERE Id = :urid];
        GRR_Lanzamiento__c lanzamiento = new GRR_Lanzamiento__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Lanzamiento__c', 'GRR_Lanzamiento'),
            GRR_UR__c = ur.Id,
            GRR_Codigo_UR__c = ur.GRR_Id_UR__c,
            GRR_Fecha_Prevista_Posesion__c = Datetime.now()
        );
        insert lanzamiento;
        return lanzamiento;
    }

    @isTest
    public static void testFiltrarUrsGRRAD() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            GRR_UR__c ur = crearUR();
            List<GRR_UR__c> lstUrs = new List<GRR_UR__c>();
            lstUrs.add(ur);

            Test.startTest();
            Set<String> idsUR = GRR_URTriggerHelper.filtrarUrsGRRAD(lstUrs);
            Test.stopTest();
            
            System.assertEquals(idsUR != null, true);    
        }
    }

    @isTest
    public static void testBorrarLanzamientosUR() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            GRR_UR__c ur = crearUR();
            GRR_Lanzamiento__c lanzamiento = crearLanzamiento(ur.Id);
            Set<String> setCodigosUR = new Set<String>{'00000001'};

            Test.startTest();
            GRR_URTriggerHelper.borrarLanzamientosUR(setCodigosUR);
            Test.stopTest();
            
            System.assertEquals(0, [SELECT COUNT() FROM GRR_Lanzamiento__c]);    
        }
    }

    @isTest
    public static void testRegularizarCambioURFechas() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            GRR_UR__c ur = crearUR();
            GRR_Lanzamiento__c lanzamiento = crearLanzamiento(ur.Id);
            Map<Id, GRR_UR__c> mapaURs = new Map<Id, GRR_UR__c>([SELECT Id, GRR_Id_UR__c FROM GRR_UR__c]);
            List<GRR_UR__c> lstURs = new List<GRR_UR__c>();
            ur.GRR_Id_UR__c = '00000002';
            update ur;
            lstURs.add(ur);

            Test.startTest();
            GRR_URTriggerHelper.regularizarCambioURFechas(lstURs, mapaURs);
            Test.stopTest();
            
            GRR_Lanzamiento__c lanzamientoActualizado = [SELECT GRR_Codigo_UR__c, GRR_Codigo_Lanzamiento__c FROM GRR_Lanzamiento__c  LIMIT 1];
            System.assertEquals(lanzamientoActualizado.GRR_Codigo_UR__c, '00000002');    
        }
    }

    @isTest
    public static void testGRR_UR_AD_TRHan() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            GRR_UR__c ur = crearUR();
            GRR_Lanzamiento__c lanzamiento = crearLanzamiento(ur.Id);
            
            Test.startTest();
            Database.delete(ur, false);
            Test.stopTest();
            
            System.assertEquals(0, [SELECT COUNT() FROM GRR_Lanzamiento__c]);    
        }
    }

}