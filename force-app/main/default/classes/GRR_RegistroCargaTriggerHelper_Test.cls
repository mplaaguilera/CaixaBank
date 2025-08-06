@isTest
public with sharing class GRR_RegistroCargaTriggerHelper_Test {

    private static GRR_UR__c crearUR() {
        GRR_UR__c ur = new GRR_UR__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_UR__c', 'GRR_UR'),
            GRR_Id_UR__c = '00000001'
        );
        insert ur;
        return ur;
    }

    private static GRR_Carga__c crearFichero() {
        GRR_Carga__c fichero = new GRR_Carga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_Carga__c', 'GRR_Carga'),
            GRR_NombreDelFichero__c = 'Fichero prueba',
            GRR_TipoDeFichero__c = 'Acta de comité'
        );
        insert fichero;
        return fichero;
    }

    private static GRR_RegistroCarga__c crearRegistroCarga(String idfichero, String urid) {
        GRR_Carga__c fichero = [SELECT Id FROM GRR_Carga__c WHERE Id = :idfichero];
        GRR_UR__c ur = [SELECT Id, GRR_Id_UR__c FROM GRR_UR__c WHERE Id = :urid];
        GRR_RegistroCarga__c registroCarga = new GRR_RegistroCarga__c(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('GRR_RegistroCarga__c', 'GRR_Acta_comite'),
            GRR_Fichero__c = fichero.Id,
            GRR_CodigoUR__c = ur.GRR_Id_UR__c
        );
        insert registroCarga;
        return registroCarga;
    }

    @isTest
    public static void testGRR_RegistroCargaTriggerHelper() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            GRR_UR__c ur = crearUR();
            GRR_Carga__c fichero = crearFichero();
            GRR_RegistroCarga__c registroCarga = crearRegistroCarga(fichero.Id, ur.Id);
            List<GRR_RegistroCarga__c> lstRegistrosCarga = new List<GRR_RegistroCarga__c>();
            lstRegistrosCarga.add(registroCarga);

            Test.startTest();
            List<GRR_RegistroCarga__c> lstRegistrosCargaFiltrados = GRR_RegistroCargaTriggerHelper.filtrarRegistrosCargaActaComiteHist(lstRegistrosCarga);
            Test.stopTest();
            
            System.assertEquals(lstRegistrosCargaFiltrados != null, true);    
        }
    }
    
}