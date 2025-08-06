@isTest
public with sharing class GRR_LanzamientoTriggerHelper_Test {

    private static GRR_UR__c crearUR() {
        GRR_UR__c ur = new GRR_UR__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_UR__c', 'GRR_UR'),
            GRR_Id_UR__c = '00000001',
            GRR_Fecha_Ultimo_Lanzamiento__c = Datetime.now()-1,
            GRR_Fecha_Proximo_Lanzamiento__c = Datetime.now()+1
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
            GRR_Fecha_Prevista_Posesion__c = Datetime.now()+2,
            GRR_Situacion__c = 'Situación 1'
        );
        insert lanzamiento;
        return lanzamiento;
    }

    @isTest
    public static void testCrearNuevasURs() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Test.startTest();
            GRR_Lanzamiento__c lanzamiento = new GRR_Lanzamiento__c(
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Lanzamiento__c', 'GRR_Lanzamiento'),
                GRR_Codigo_UR__c = '00000002',
                GRR_Fecha_Prevista_Posesion__c = Datetime.now()+1
            );
            insert lanzamiento;
            Test.stopTest();
            
            System.assertEquals('00000002', [SELECT GRR_Id_UR__c FROM GRR_UR__c].GRR_Id_UR__c);
        }
    }

    @isTest
    public static void testRegularizarFechaProximaUR() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            GRR_UR__c ur = crearUR();
            GRR_Lanzamiento__c lanzamiento = crearLanzamiento(ur.Id);
            
            Test.startTest();
            Database.delete(lanzamiento, false);
            Test.stopTest();
            System.assertEquals(ur.GRR_Fecha_Proximo_Lanzamiento__c, [SELECT GRR_Fecha_Proximo_Lanzamiento__c FROM GRR_UR__c].GRR_Fecha_Proximo_Lanzamiento__c);
        }
    }

    @isTest
    public static void testRegularizarFechaUltimaUR() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            GRR_UR__c ur = crearUR();
            GRR_Lanzamiento__c lanzamiento = crearLanzamiento(ur.Id);
            lanzamiento.GRR_Fecha_Prevista_Posesion__c = Datetime.now()-2;
            update lanzamiento;
            
            Test.startTest();
            Database.delete(lanzamiento, false);
            Test.stopTest();
            System.assertEquals(ur.GRR_Fecha_Ultimo_Lanzamiento__c, [SELECT GRR_Fecha_Ultimo_Lanzamiento__c FROM GRR_UR__c].GRR_Fecha_Ultimo_Lanzamiento__c);
        }
    }

    @isTest
    public static void testObtenerFechaProxima() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            GRR_UR__c ur = crearUR();
            GRR_Lanzamiento__c lanzamiento = crearLanzamiento(ur.Id);
            Datetime fechaBorrada = Datetime.now();

            Test.startTest();
            GRR_Lanzamiento__c fechaProxima = GRR_LanzamientoTriggerHelper.obtenerFechaProxima(ur, fechaBorrada);
            Test.stopTest();
            
            System.assertNotEquals(0, [SELECT COUNT() FROM GRR_Lanzamiento__c]);    
        }
    }

    @isTest
    public static void testObtenerFechaUltima() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            GRR_UR__c ur = crearUR();
            GRR_Lanzamiento__c lanzamiento = crearLanzamiento(ur.Id);
            Datetime fechaBorrada = Datetime.now();

            Test.startTest();
            GRR_Lanzamiento__c fechaUltima = GRR_LanzamientoTriggerHelper.obtenerFechaUltima(ur, fechaBorrada);
            Test.stopTest();
            
            System.assertNotEquals(0, [SELECT COUNT() FROM GRR_Lanzamiento__c]);    
        }
    }

}