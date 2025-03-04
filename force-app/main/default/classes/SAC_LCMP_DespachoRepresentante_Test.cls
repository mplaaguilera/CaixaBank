@isTest
public with sharing class SAC_LCMP_DespachoRepresentante_Test {

    @TestSetup
    static void makeData(){
        Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c', 'CC_Caracteristica__c'};
        Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
        //Los maestros de temas con este Record Type van a indicar qué valores de despachos representantes se pueden escoger
        Id recTypeDespachosMaestroTemas = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_DespachoRepresentante').getRecordTypeId();
        Id recTypeRepresentanteCaracteristica = mapRTsObjects.get('CC_Caracteristica__c').get('SAC_CaracteristicaRepresentante').getRecordTypeId();

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

        SAC_MaestroTemas__c maestroTemas1 = new SAC_MaestroTemas__c();
        maestroTemas1.RecordTypeId = recTypeDespachosMaestroTemas;
        maestroTemas1.Name = 'Ejemplo1';
        maestroTemas1.SAC_Activo__c = true;
        maestroTemas1.SAC_Descripcion__c = 'Ejemplo1';
        SAC_DatabaseDML.insertDML(maestroTemas1, true);

        CBK_Case_Extension__c casoExtension = new CBK_Case_Extension__c();
        SAC_DatabaseDML.insertDML(casoExtension, false);


        List<Case> reclamaciones = new List<Case>();
        Map<String, Object> mapaCamposCaso = new Map<String, Object>();
        mapaCamposCaso.put('Subject', 'TestRec');
        mapaCamposCaso.put('Origin', 'Backoffice');
        mapaCamposCaso.put('Status', 'SAC_001');
        mapaCamposCaso.put('OwnerId', usuarioAdmin.id);
        mapaCamposCaso.put('CC_Idioma__c', 'en');
        mapaCamposCaso.put('SAC_TipoDeRepresentante__c', 'SAC_Abogado');
        mapaCamposCaso.put('CBK_Case_Extension_Id__c', casoExtension.Id);
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', mapaCamposCaso);
        reclamaciones.add(casoReclamacion);

        SAC_DatabaseDML.insertListDML(reclamaciones, false);

        CC_Caracteristica__c caracteristica2 = new CC_Caracteristica__c(
            Name = 'Caracteristica tipo representante Test SAC',
            RecordTypeId = recTypeRepresentanteCaracteristica,
            CC_Descripcion__c = 'PruebaSAC'
        );
        SAC_DatabaseDML.insertDML(caracteristica2, true);

        CC_Caracteristica_Detalle__c asignacion = new CC_Caracteristica_Detalle__c();
        asignacion.CC_Caracteristica__c = caracteristica2.Id;
        asignacion.SAC_Identificador__c = 'TEST123456';
        SAC_DatabaseDML.insertDML(asignacion, true);


        Test.stopTest();
    }

    @isTest
    static void obtenerValoresDespachoRepresentanteTest(){
    
        List<String> listaResult = new List<String>();
        Test.startTest();
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];
        System.runAs(usuario){
            listaResult = SAC_LCMP_DespachoRepresentante.obtenerValoresDespachoRepresentante();
        }
        Assert.areNotEqual(listaResult.isEmpty(), true, 'No se han obtenido los despachos correctamente.');
        Test.stopTest();
    }

    @isTest
    static void guardarDespachoRepresentanteTest(){

        User usuario = [SELECT Id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];
        Case reclamacion = [SELECT Id, CBK_Case_Extension_Id__c FROM Case WHERE Subject = 'TestRec'];
        Test.startTest();

        System.runAs(usuario){
            SAC_LCMP_DespachoRepresentante.guardarDespachoRepresentante('Test', reclamacion.Id);
        }

        CBK_Case_Extension__c casoExtension = [SELECT Id, SAC_DespachoRepresentante__c FROM CBK_Case_Extension__c WHERE Id = :reclamacion.CBK_Case_Extension_Id__c];
        Assert.areEqual('Test', casoExtension.SAC_DespachoRepresentante__c, 'No se ha actualizado el despacho representante.');
        Test.stopTest();
    }



    @isTest
    static void verSiGestorTest(){
        User usuario = [SELECT Id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec'];
        Boolean resultado = false;

        Test.startTest();
        System.runAs(usuario){
            resultado= SAC_LCMP_DespachoRepresentante.verSiGestorLetrado(reclamacion.Id, reclamacion.OwnerId);
        }

        Assert.areEqual(true, resultado, 'No se ha comprobado correctamente si es gestor/letrado');
        Test.stopTest();
    }

    @isTest
    static void comprobarCaractRepresentanteTest() {
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];

        List<CC_Caracteristica_Detalle__c> listCaratetisticas = new List<CC_Caracteristica_Detalle__c>();

        System.runAs(usuario){
            Test.startTest();
            listCaratetisticas = SAC_LCMP_DespachoRepresentante.comprobarCaractRepresentante('TEST123456', '');
            Test.stopTest();
        }

        Assert.areNotEqual(null, listCaratetisticas[0].Id, 'No se ha podido recuperar las caracteristicas del representante');
    }

    
}