@isTest
public with sharing class SAC_LCMP_CargarCaractRepresentante_Test {
    @TestSetup
    static void makeData(){

        Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
        Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
        Id recTypeDespachosMaestroTemas = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_DespachoRepresentante').getRecordTypeId();

        Test.startTest();
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];     
        SAC_DatabaseDML.insertDML(usuarioAdmin, true);

        User usuario;
        System.runAs(usuarioAdmin) {
            //Usuario SAC General
            usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            usuario.Username = 'ustestesteo@test.com';      
            SAC_DatabaseDML.insertDML(usuario, true);
        }
        Test.stopTest();

        CC_Caracteristica__c caracteristica2 = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo representante Test SAC',
            RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SAC_CaracteristicaRepresentante').getRecordTypeId(),
            CC_Descripcion__c = 'PruebaSAC'
        );
        SAC_DatabaseDML.insertDML(caracteristica2, true);

        CC_Caracteristica_Detalle__c asignacion = new CC_Caracteristica_Detalle__c();
        asignacion.CC_Caracteristica__c = caracteristica2.Id;
        asignacion.SAC_Identificador__c = 'TEST123456';
        SAC_DatabaseDML.insertDML(asignacion, true);

        SAC_MaestroTemas__c maestroTemas1 = new SAC_MaestroTemas__c();
        maestroTemas1.RecordTypeId = recTypeDespachosMaestroTemas;
        maestroTemas1.Name = 'Ejemplo1';
        maestroTemas1.SAC_Activo__c = true;
        maestroTemas1.SAC_Descripcion__c = 'Ejemplo1';
        SAC_DatabaseDML.insertDML(maestroTemas1, true);


    }

    @isTest
    static void getAsignacionesByCaractIdTest() {
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];
        CC_Caracteristica__c caract = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'Caracteristica tipo representante Test SAC' LIMIT 1];

        List<CC_Caracteristica_Detalle__c> listCaratetisticas = new List<CC_Caracteristica_Detalle__c>();

        System.runAs(usuario){
            Test.startTest();
            listCaratetisticas = SAC_LCMP_CargarCaractRepresentante.getAsignacionesByCaractId(caract.id);
            Test.stopTest();
        }

        Assert.areNotEqual(null, listCaratetisticas[0].Id, 'No se ha podido recuperar las caracteristicas del representante');
    }

    @isTest
    static void obtenerValoresDespachoRepresentanteTest(){

        List<String> listaResult = new List<String>();
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];
        System.runAs(usuario){
            listaResult = SAC_LCMP_CargarCaractRepresentante.obtenerValoresDespachoRepresentante();
        }
        Assert.areNotEqual(listaResult.isEmpty(), true, 'No se han obtenido los despachos correctamente.');
        Test.stopTest();
    }


    @isTest
    static void crearAsignacionTest() {
        User usuario = [SELECT id FROM User WHERE username = 'ustestesteo@test.com' and IsActive = true limit 1];
        CC_Caracteristica__c caract = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'Caracteristica tipo representante Test SAC' LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_CargarCaractRepresentante.crearAsignacion(caract.id, 'TESTCREAR1234');
            Test.stopTest();
        }

        CC_Caracteristica_Detalle__c asignacion = [SELECT Id FROM CC_Caracteristica_Detalle__c WHERE SAC_Identificador__c = 'TESTCREAR1234' LIMIT 1];

        Assert.areNotEqual(null, asignacion, 'No se ha podido crear la asignación de caracteristicas del representante');
    }

    @isTest
    static void actualizarAsignacionTest() {
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true limit 1];
        CC_Caracteristica_Detalle__c asignacion = [SELECT Id, SAC_Identificador__c FROM CC_Caracteristica_Detalle__c WHERE SAC_Identificador__c = 'TEST123456' LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_CargarCaractRepresentante.actualizarAsignacion(asignacion.id, 'TESTCREAR1234Act');
            Test.stopTest();
        }

        CC_Caracteristica_Detalle__c asignacionDesp = [SELECT Id, SAC_Identificador__c FROM CC_Caracteristica_Detalle__c WHERE SAC_Identificador__c = 'TESTCREAR1234Act' LIMIT 1];

        Assert.areNotEqual(asignacion.SAC_Identificador__c, asignacionDesp.SAC_Identificador__c, 'No se ha podido actualizar la asignación de caracteristicas del representante');
    }

    @isTest
    static void eliminarAsignacionTest() {
        User usuario = [SELECT id FROM User WHERE username = 'ustestesteo@test.com' and IsActive = true limit 1];
        CC_Caracteristica_Detalle__c asignacion = [SELECT Id, SAC_Identificador__c FROM CC_Caracteristica_Detalle__c WHERE SAC_Identificador__c = 'TEST123456' LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_CargarCaractRepresentante.eliminarAsignacion(asignacion.id);
            Test.stopTest();
        }

        Assert.areNotEqual(null, asignacion.Id, 'No se ha podido eliminar la asignación de caracteristicas del representante');
    }
}