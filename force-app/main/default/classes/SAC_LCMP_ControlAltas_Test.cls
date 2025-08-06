@isTest
public with sharing class SAC_LCMP_ControlAltas_Test {

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPECONTROLALTAS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_ControlAltas').getRecordTypeId();
    
    @TestSetup
    static void makeData(){
        
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];    
        SAC_DatabaseDML.insertDML(usuarioAdmin, false); 
        
        User usuarioGeneral;
        System.runAs(usuarioAdmin) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
            SAC_DatabaseDML.insertDML(usuarioGeneral, false); 
            
            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false); 
                        
            // Casos
            List<Case> listaReclamaciones = new List<Case>();
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'TestRec');
            camposRecl.put('Origin', 'Backoffice');
            camposRecl.put('Status', 'SAC_001');
            camposRecl.put('OwnerId', usuarioGeneral.id);
            camposRecl.put('SAC_TipoConsumidor__c', 'Si');
            
            Case casoReclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            listaReclamaciones.add(casoReclamacion1);
            
            Map<String, Object> camposRec2 = new Map<String, Object>();
            camposRec2.put('Subject', 'TestRec2');
            camposRec2.put('Origin', 'Backoffice');
            camposRec2.put('Status', 'SAC_002');
            camposRec2.put('OwnerId', usuarioGeneral.id);
            camposRec2.put('SAC_TipoConsumidor__c', 'Si');
            
            Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRec2);
            listaReclamaciones.add(casoReclamacion2);
            SAC_DatabaseDML.insertListDML(listaReclamaciones, false); 
            
            List<SAC_MaestroTemas__c> controlAlta = SAC_TestDataFactory.crearMaestroTemas(1, 'SAC_ControlAltas');
            controlAlta[0].SAC_Descripcion__c = 'Test SAC CAltas';
            SAC_DatabaseDML.insertListDML(controlAlta, false);
            
            SAC_Marca_Case__c controlAltaCaso = new SAC_Marca_Case__c();
            controlAltaCaso.SAC_Case__c = casoReclamacion2.Id;
            controlAltaCaso.SAC_Marca__c = controlAlta[0].id;
            SAC_DatabaseDML.insertDML(controlAltaCaso, false);
        }
        
    }

    @isTest
    static void cargarDatosControlAltasTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT id FROM Case WHERE subject = 'TestRec' limit 1];

        Map<String, List<SAC_LCMP_ControlAltas.WrapperControlAltas>> mapResult = new Map<String, List<SAC_LCMP_ControlAltas.WrapperControlAltas>>();

        Test.startTest();
        System.runAs(usuario){
           mapResult = SAC_LCMP_ControlAltas.cargarDatosControlAltas(caso.Id);
        }
        Test.stopTest();
        
        Assert.areEqual(false, mapResult.isEmpty(), 'No se han recuperado datos del control de altas');
    }

    @isTest
    static void cargarDatosControlAltasTest2(){
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT id FROM Case WHERE subject = 'TestRec2' limit 1];

        Map<String, List<SAC_LCMP_ControlAltas.WrapperControlAltas>> mapResult = new Map<String, List<SAC_LCMP_ControlAltas.WrapperControlAltas>>();

        Test.startTest();
        System.runAs(usuario){
           mapResult = SAC_LCMP_ControlAltas.cargarDatosControlAltas(caso.Id);
        }
        Test.stopTest();
        
        Assert.areEqual(false, mapResult.isEmpty(), 'No se han recuperado datos del control de altas');
    }

    @isTest
    static void guardarControlAltaTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT id FROM Case WHERE subject = 'TestRec' limit 1];
        SAC_MaestroTemas__c controlAlta = [SELECT Id FROM SAC_MaestroTemas__c LIMIT 1];

        Test.startTest();
        System.runAs(usuario){
            List<String> listIds = new List<String>();
            listIds.add(controlAlta.Id);
            SAC_LCMP_ControlAltas.guardarControlAlta(caso.Id, listIds);
        }
        Test.stopTest();
        
        List<SAC_Marca_Case__c> controlAltaCaso = [SELECT Id FROM SAC_Marca_Case__c WHERE SAC_Marca__r.RecordTypeId =:RECTYPECONTROLALTAS AND SAC_Case__c = :caso.Id AND SAC_Marca__c = :controlAlta.Id];
        Assert.areEqual(false, controlAltaCaso.isEmpty(), 'No se han insertar datos del control de altas');
    }

    @isTest
    static void guardarControlAltaTest2(){
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT id FROM Case WHERE subject = 'TestRec2' limit 1];
        SAC_MaestroTemas__c controlAlta = [SELECT Id FROM SAC_MaestroTemas__c LIMIT 1];

        Test.startTest();
        System.runAs(usuario){
            List<String> listIds = new List<String>();
            SAC_LCMP_ControlAltas.guardarControlAlta(caso.Id, listIds);
        }
        Test.stopTest();
        
        List<SAC_Marca_Case__c> controlAltaCaso = [SELECT Id FROM SAC_Marca_Case__c WHERE SAC_Marca__r.RecordTypeId =:RECTYPECONTROLALTAS AND SAC_Case__c = :caso.Id AND SAC_Marca__c = :controlAlta.Id];
        Assert.areEqual(true, controlAltaCaso.isEmpty(), 'No se han eliminado datos del control de altas');
    }
}