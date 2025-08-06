@isTest
public with sharing class SPV_MaestroTemasHelper_Test {

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEMARCA = mapRTsObjects.get('SAC_MaestroTemas__c').get('SPV_Marcas').getRecordTypeId();
    
    @TestSetup
    static void makeData(){

        Test.startTest();
        List<User> listaUsers = SPV_TestDataFactory.crearUsuarioSPVGeneral(1);
        SPV_DatabaseDML.insertListDML(listaUsers, true);
    
        List<User> listaUsersAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1);
        SPV_DatabaseDML.insertListDML(listaUsersAdmin, true);

        Test.stopTest();

        System.runAs(listaUsersAdmin[0]){
            SAC_MaestroTemas__c marca = new SAC_MaestroTemas__c();
            marca.Name = 'Test SPV';
            marca.SAC_OrdenPrelacion__c = 1;
            marca.SAC_Activo__c = true;
            marca.RecordTypeId = RECTYPEMARCA;
            SPV_DatabaseDML.insertDML(marca, true);
        }        
    }

    @isTest
    static void insertarMarcaMaestroTemasTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        Test.startTest();

        System.runAs(usuario){
            SAC_MaestroTemas__c marca = new SAC_MaestroTemas__c();
            marca.Name = 'Test SPV1';
            marca.SAC_OrdenPrelacion__c = 2;
            marca.RecordTypeId = RECTYPEMARCA;
            SPV_DatabaseDML.insertDML(marca, true);
        }

        List<SAC_MaestroTemas__c> marcas = [SELECT Id FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPEMARCA AND Name = 'Test SPV1' LIMIT 1];
        Assert.areEqual(false, marcas.isEmpty(), 'No se ha insertado la marca correctamente');
        Test.stopTest();
    }

    @isTest
    static void updateMarcaMaestroTemasTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_MaestroTemas__c marca = [SELECT Id, SAC_OrdenPrelacion__c FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPEMARCA AND Name = 'Test SPV' LIMIT 1];
        Decimal ordenInicial = marca.SAC_OrdenPrelacion__c;

        Test.startTest();

        System.runAs(usuario){
            marca.SAC_OrdenPrelacion__c = 5;
            SPV_DatabaseDML.updateDML(marca, true);
        }

        List<SAC_MaestroTemas__c> marcas = [SELECT Id, SAC_OrdenPrelacion__c FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPEMARCA AND Name = 'Test SPV' LIMIT 1];
        Assert.areNotEqual(ordenInicial, marcas[0].SAC_OrdenPrelacion__c, 'No se ha actualizado la marca correctamente');
        Test.stopTest();
    }
}