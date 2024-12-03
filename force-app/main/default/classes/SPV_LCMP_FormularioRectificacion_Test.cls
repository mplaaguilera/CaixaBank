@isTest
public with sharing class SPV_LCMP_FormularioRectificacion_Test {
    private static Set<String> objetos = new Set<String>{'SPV_Formulario__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEFORMULARIO = mapRTsObjects.get('SPV_Formulario__c').get('SPV_FormularioRectificacion').getRecordTypeId();

    @TestSetup
    static void makeData(){
        
        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SPV_DatabaseDML.insertDML(usuarioAdmin, true);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            SPV_DatabaseDML.insertDML(usuarioGeneral, true);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            SPV_DatabaseDML.insertDML(permiSetAssiAdmin, true);
        }
        Test.stopTest();


         //Reclamacion
         Map<String, Object> camposRecl = new Map<String, Object>();
         camposRecl.put('Subject', 'TestRec');
         camposRecl.put('Origin', 'Otros');
         camposRecl.put('Status', 'SPV_Rectificacion');
         camposRecl.put('SAC_TipoConsumidor__c', 'No');
         camposRecl.put('SAC_Naturaleza__c', 'SAC_004');
         camposRecl.put('OwnerId', usuarioGeneral.Id);
 
         Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl);
 
         List<Case> reclamaciones = new List<Case>();
         reclamaciones.add(casoReclamacion);
         SPV_DatabaseDML.insertListDML(reclamaciones, true);

        //Crear formulario
        SPV_Formulario__c formulario = new SPV_Formulario__c();
        formulario.RecordTypeId = Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName().get('SPV_FormularioRectificacion').getRecordTypeId();
        formulario.SPV_Caso__c = casoReclamacion.Id;
        formulario.SPV_PropuestaRectificacion__c = 'Test';
        formulario.SPV_InstruccionesRect__c = 'Test';
        formulario.SPV_Resena__c = 'TestSPV';
        formulario.SPV_Mejoras__c = 'TestSPV';
        formulario.SPV_RectificacionCompletada__c = false;
        SPV_DatabaseDML.insertDML(formulario, true);

        SPV_Formulario__c formulario2 = new SPV_Formulario__c();
        formulario2.RecordTypeId = Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName().get('SPV_FormularioRectificacion').getRecordTypeId();
        formulario2.SPV_Caso__c = casoReclamacion.Id;
        formulario2.SPV_PropuestaRectificacion__c = 'Test3';
        formulario2.SPV_InstruccionesRect__c = 'Test3';
        formulario2.SPV_Resena__c = 'TestSPV3';
        formulario2.SPV_Mejoras__c = 'TestSPV3';
        formulario2.SPV_RectificacionCompletada__c = true;
        SPV_DatabaseDML.insertDML(formulario2, true);

        List<CC_Grupo_Colaborador__c> gruposColaboradores = SPV_TestDataFactory.crearGrupoColaborador('GrupoLetrado', 1);
        gruposColaboradores[0].Name = 'Grupo Letrado Test';
        SPV_DatabaseDML.insertListDML(gruposColaboradores, true);

    }

    @isTest
    static void getFormularioExistenteTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec'];

        System.runAs(usuario1){
            Test.startTest();
            String resultado = SPV_LCMP_FormularioRectificacion.getFormularioExistente(reclamacion.Id);

            Assert.areNotEqual(null, resultado, 'No se han recuperado el formulario');
            Test.stopTest();
        }
    }

    @isTest
    static void getRectificacionesAnterioresTest(){
        
        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec'];

        System.runAs(usuario1){
            Test.startTest();
            List<SPV_Formulario__c> resultado = SPV_LCMP_FormularioRectificacion.getRectificacionesAnteriores(reclamacion.Id);

            Assert.areNotEqual(null, resultado, 'No se han recuperado las rectificaciones anteriores');
            Test.stopTest();
        }
    }

    @isTest
    static void compruebaLetradoSPVTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name ='Grupo Letrado Test' Limit 1];
        usuario1.SAC_GruposPerteneciente__c = grupo.id;
        SPV_DatabaseDML.updateDML(usuario1, true);
        Case reclamacion = [SELECT id, CaseNumber FROM Case WHERE Subject = 'TestRec'];


        System.runAs(usuario1){
            reclamacion.OwnerId = usuario1.id;
            reclamacion.SAC_Letrado__c = grupo.id;
            SPV_DatabaseDML.updateDML(reclamacion, true);
            Test.startTest();
            Boolean resultado=SPV_LCMP_FormularioRectificacion.compruebaLetradoSPV(reclamacion.Id);

            Assert.areNotEqual(null, resultado, 'error comprobacion');
            Test.stopTest();
        }
    }
}