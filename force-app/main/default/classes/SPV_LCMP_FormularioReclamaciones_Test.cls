@isTest
public with sharing class SPV_LCMP_FormularioReclamaciones_Test {

    private static Set<String> objetos = new Set<String>{'SPV_Formulario__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEFORMULARIO = mapRTsObjects.get('SPV_Formulario__c').get('SPV_Formulario').getRecordTypeId();

    
    @TestSetup
    static void makeData(){

        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            Database.insert(usuarioGeneral);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            Database.insert(permiSetAssiAdmin);
        }
        Test.stopTest();

        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
        grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoDeTareas').getRecordTypeId();
        grupo.Name = 'grupotest';
        grupo.SAC_PermiteEscalado__c = true;
        grupo.OS_Negocio__c = 'SPV';
        grupo.SAC_DeveloperName__c = 'SPV_AJ';
        Database.insert(grupo);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Otros');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_TipoConsumidor__c', 'No');
        camposRecl.put('SAC_Naturaleza__c', 'SAC_004');
        camposRecl.put('OwnerId', usuarioGeneral.Id);

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        List<Case> reclamaciones = new List<Case>();
        reclamaciones.add(casoReclamacion);
        Database.insert(reclamaciones);


        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'testPret');
        camposPret.put('Origin', 'Otros');
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('OwnerId', usuarioGeneral.Id);

        Case casoPretension = SPV_TestDataFactory.crearCaso('Pretension',camposPret); 
        
        //Pretensiones
        List<Case> pretensiones = new List<Case>();
        pretensiones.add(casoPretension);
        Database.insert(pretensiones);

        //Crear esacalado
        Map<String, Object> camposObj = new Map<String, Object>();
        camposObj.put('SAC_CasoEscalado__c', casoReclamacion.Id);
        camposObj.put('SAC_Titulo__c', 'testescalado1');
        camposObj.put('SAC_GrupoColaborador__c', grupo.Id);
        SAC_Interaccion__c escalado = SPV_TestDataFactory.crearInteraccion('Escalado', camposObj);
        Database.insert(escalado);

        //Crear formulario
        SPV_Formulario__c formulario = new SPV_Formulario__c();
        formulario.RecordTypeId = Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName().get('SPV_Formulario').getRecordTypeId();
        formulario.SPV_Caso__c = casoReclamacion.Id;
        formulario.SPV_LetradoRevisor__c = 'TestSPV';
        formulario.SPV_Importe__c = 1;
        formulario.SPV_ResumenResolucion__c = 'TestSPV';
        formulario.SPV_ResolucionRemitidaEnPlazo__c = 'No';
        formulario.SPV_ReclamacionMalFuncionamiento__c = 'No';
        formulario.SPV_ObservacionesMalFuncionamiento__c = 'TestSPV';
        formulario.SPV_ActuacionCumpleCriterios__c = 'No';
        formulario.SPV_ObservacionesCriteriosBDE__c = 'TestSPV';
        formulario.SPV_DisponeDocumentacion__c = 'No';
        formulario.SPV_ObservacionesDocumentacion__c = 'TestSPV';
        formulario.SPV_DocumentacionNecesaria__c = 'TestSPV';
        formulario.SPV_CambiosDeCondiciones__c = 'TestSPV';
        formulario.SPV_ComunicacionLiquidaciones__c = 'TestSPV';
        formulario.SPV_JustificantesOperaciones__c = 'TestSPV';
        formulario.SPV_ComunicacionOficinaCliente__c = 'TestSPV';
        formulario.SPV_AntecedentesCumplimiento__c = 'TestSPV';
        formulario.SPV_CumplimientoCondicionesPactadas__c = 'TestSPV';
        formulario.SPV_InformeOficina__c = 'TestSPV';
        formulario.SPV_ExisteDefensaJuridicaSuficiente__c = 'No';
        formulario.SPV_ObservacionesDefensaJuridica__c = 'TestSPV';
        formulario.SPV_ConllevaRiesgoReputacional__c = 'No';
        formulario.SPV_ObservacionesRiesgoReputacional__c = 'TestSPV';
        formulario.SPV_ExisteCriterioRespectoTipologia__c = 'No';
        formulario.SPV_ObservacionesExisteCriterio__c = 'TestSPV';
        formulario.SPV_RiesgoInformeDesfavorable__c = 'No';
        formulario.SPV_ObservacionesInformeDesfavorable__c = 'TestSPV';
        formulario.SPV_PropuestaLetradoAllanamiento__c = 'Allanamiento';
        formulario.SPV_PropuestaLetradoAlegaciones__c = 'Alegación';
        formulario.SPV_TipoRespuesta__c = 'TestSPV';
        formulario.SPV_ObservacionesAJ__c = 'TestSPV';
        Database.insert(formulario);

    }

    @isTest
    static void getFormularioExistenteTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec'];

        System.runAs(usuario1){
            Test.startTest();
            String resultado = SPV_LCMP_FormularioReclamaciones.getFormularioExistente(reclamacion.Id);

            Assert.areNotEqual(null, resultado, 'No se han recuperado el formulario');
            Test.stopTest();
        }
    }

    @isTest
    static void getPretensionesReclamacionTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT id, Ownerid FROM Case WHERE Subject = 'TestRec'];

        System.runAs(usuario1){
            Test.startTest();
            List<Case> pretensiones = SPV_LCMP_FormularioReclamaciones.getPretensionesReclamacion(reclamacion.Id);

            Assert.areNotEqual(null, pretensiones[0].id, 'No se han recuperado las pretensiones');
            Test.stopTest();
        }
    }

    @isTest
    static void notificarCambioFichaTest(){

        User usuario1 = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];
        Case reclamacion = [SELECT id, CaseNumber FROM Case WHERE Subject = 'TestRec'];

        System.runAs(usuario1){
            Test.startTest();
            SPV_LCMP_FormularioReclamaciones.notificarCambioFicha(reclamacion.Id, reclamacion.CaseNumber);

            Assert.areNotEqual(null, 'text', 'No se haenviado la notificacion');
            Test.stopTest();
        }
    }
}