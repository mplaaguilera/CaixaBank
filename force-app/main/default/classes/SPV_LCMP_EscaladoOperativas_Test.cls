@isTest
public with sharing class SPV_LCMP_EscaladoOperativas_Test {
    @TestSetup
    static void makeData(){
        List<User> listaUsers = SPV_TestDataFactory.crearUsuarioSPVGeneral(1);
        SPV_DatabaseDML.insertListDML(listaUsers, true);
        List<User> listaUsersAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1);
        SPV_DatabaseDML.insertListDML(listaUsersAdmin, true);

        //Mapa campos
        Map<String, Object> camposObj = new Map<String, Object>();
        //Reclamacion
        Case recla = new Case();
        //Grupo
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();

        System.runAs(listaUsers[0]) {
            grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoDeTareas').getRecordTypeId();
            grupo.Name = 'grupotest';
            grupo.SAC_PermiteEscalado__c = true;
            grupo.OS_Negocio__c = 'SPV';
            grupo.SAC_DeveloperName__c = 'SPV_AJ';
            SPV_DatabaseDML.insertDML(grupo, true);

            CC_Grupo_Colaborador_Contact__c colabcontact = new CC_Grupo_Colaborador_Contact__c();
            colabcontact.CC_Usuario__c = listaUsers[0].Id;
            colabcontact.CC_Grupo_Colaborador__c = grupo.Id;
            SPV_DatabaseDML.insertDML(colabcontact, true);

            //Crear reclamacion
            camposObj.put('Subject', 'testrec1');
            recla = SPV_TestDataFactory.crearCaso('Reclamacion', camposObj);
            SPV_DatabaseDML.insertDML(recla, true);
        }

        system.runAs(listaUsersAdmin[0]) {
            //Cambiar owner de la reclamación
            recla.OwnerId = listaUsers[0].Id;
            SPV_DatabaseDML.updateDML(recla, true);
        }

        System.runAs(listaUsers[0]) {
            //Crear esacalado
            camposObj.clear();
            camposObj.put('SAC_CasoEscalado__c', recla.Id);
            camposObj.put('SAC_Titulo__c', 'testescalado1');
            camposObj.put('SAC_GrupoColaborador__c', grupo.Id);
            camposObj.put('SPV_TipoAllanamiento__c', 'SPV_Parcial');
            camposObj.put('SPV_MotivoAllanamiento__c', 'Test');
            camposObj.put('SPV_AnalisisAllanamiento__c', 'Test');
            camposObj.put('SPV_VerificacionesLetrado__c', 'Test');
            camposObj.put('SAC_Propuesta__c', 'Test');
            camposObj.put('SPV_TipoActuacion__c', 'SPV_Pago');
            camposObj.put('SPV_Importe__c', 1);
            camposObj.put('SPV_Imputable__c', 'SPV_Entidad');
            SAC_Interaccion__c escalado = SPV_TestDataFactory.crearInteraccion('Escalado', camposObj);
            SPV_DatabaseDML.insertDML(escalado, true);

            //Crear formulario
            SPV_Formulario__c formulario = new SPV_Formulario__c();
            formulario.RecordTypeId = Schema.SObjectType.SPV_Formulario__c.getRecordTypeInfosByDeveloperName().get('SPV_Formulario').getRecordTypeId();
            formulario.SPV_Caso__c = recla.Id;
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
            formulario.SPV_InformacionPrecontractual__c = 'TestSPV';
            SPV_DatabaseDML.insertDML(formulario, true);
        }
    }

    @isTest
    static void tomarPropiedadEscaladoTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id, SAC_GrupoColaborador__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];

        Test.startTest();
        System.runAs(usuario) {
            SPV_LCMP_EscaladoOperativas.tomarPropiedadEscalado(escalado.Id, escalado.SAC_GrupoColaborador__c, usuario.Id);
        }
        Test.stopTest();

        SAC_Interaccion__c escaladoResult = [SELECT Id, OwnerId FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];
        System.assertEquals(usuario.Id, escaladoResult.OwnerId, 'No se ha podido tomar en propiedad el escalado');
    }

    @isTest
    static void tomarPropiedadEscaladoFailTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id, SAC_GrupoColaborador__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];

        escalado.SAC_GrupoColaborador__c = null;
        SPV_DatabaseDML.updateDML(escalado, true);

        Test.startTest();
        System.runAs(usuario) {
            try {
                SPV_LCMP_EscaladoOperativas.tomarPropiedadEscalado(escalado.Id, escalado.SAC_GrupoColaborador__c, usuario.Id);    
            } catch (Exception e) {
                SAC_Interaccion__c escaladoResult = [SELECT Id, OwnerId FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];
                System.assertEquals(usuario.Id, escaladoResult.OwnerId, 'No se ha podido tomar en propiedad el escalado');        
            }
        }
        Test.stopTest();
    }

    @isTest
    static void devolverEscaladoAlGrupoTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id, SAC_GrupoColaborador__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];

        Test.startTest();
        System.runAs(usuario) {
            SPV_LCMP_EscaladoOperativas.devolverEscaladoAlGrupo(escalado.Id);
        }
        Test.stopTest();

        SAC_Interaccion__c escaladoResult = [SELECT Id, OwnerId FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];
        System.assertNotEquals(usuario.Id, escaladoResult.OwnerId, 'No se ha podido devolver el escalado al grupo');
    }

    @isTest
    static void enviarEscaladoTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id, SAC_GrupoColaborador__c, SAC_CasoEscalado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];

        Test.startTest();
        System.runAs(usuario) {
            SPV_LCMP_EscaladoOperativas.enviarEscalado(escalado.Id, escalado.SAC_CasoEscalado__c, 'SPV_Allanamiento');
        }
        Test.stopTest();

        SAC_Interaccion__c escaladoResult = [SELECT Id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];
        System.assertEquals('SAC_PendienteRespuesta', escaladoResult.SAC_Estado__c, 'No se ha podido enviar el escalado');
    }

    @isTest
    static void validarFormularioTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id, SAC_CasoEscalado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];
        SPV_Formulario__c formulario = [SELECT Id, SPV_Reclamante__c, SPV_LetradoSPV__c, SPV_LetradoRevisor__c, SPV_Importe__c, SPV_ResumenResolucion__c,
                                        SPV_ResolucionRemitidaEnPlazo__c, SPV_ReclamacionMalFuncionamiento__c, SPV_ObservacionesMalFuncionamiento__c, SPV_ActuacionCumpleCriterios__c,
                                        SPV_ObservacionesCriteriosBDE__c, SPV_DisponeDocumentacion__c, SPV_ObservacionesDocumentacion__c, SPV_DocumentacionNecesaria__c,
                                        SPV_CambiosDeCondiciones__c, SPV_ComunicacionLiquidaciones__c, SPV_JustificantesOperaciones__c, SPV_ComunicacionOficinaCliente__c,
                                        SPV_AntecedentesCumplimiento__c, SPV_CumplimientoCondicionesPactadas__c, SPV_InformeOficina__c, SPV_ExisteDefensaJuridicaSuficiente__c,
                                        SPV_ObservacionesDefensaJuridica__c, SPV_ConllevaRiesgoReputacional__c, SPV_ObservacionesRiesgoReputacional__c, SPV_ExisteCriterioRespectoTipologia__c,
                                        SPV_ObservacionesExisteCriterio__c, SPV_RiesgoInformeDesfavorable__c, SPV_ObservacionesInformeDesfavorable__c, SPV_PropuestaLetradoAllanamiento__c,
                                        SPV_PropuestaLetradoAlegaciones__c, SPV_TipoRespuesta__c, SPV_ObservacionesAJ__c, SPV_InformacionPrecontractual__c
                                        FROM SPV_Formulario__c
                                        WHERE SPV_Caso__c = :escalado.SAC_CasoEscalado__c LIMIT 1];

        String mensaje = null;
        Test.startTest();
        System.runAs(usuario) {
            mensaje = SPV_LCMP_EscaladoOperativas.validarFormulario(formulario, mensaje);
        }
        Test.stopTest();

        System.assertEquals(null, mensaje, 'No se ha validado correctamente el formulario');
    }

    @isTest
    static void responderEscaladoAceptadoTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id, SAC_GrupoColaborador__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'testrec1'];

        Test.startTest();
        System.runAs(usuario) {
            SPV_LCMP_EscaladoOperativas.responderEscalado(escalado.Id, 'SPV_Aceptado', 'comentarios', 'SPV_Allanamiento', usuario.Id, caso.Id);
        }
        Test.stopTest();

        SAC_Interaccion__c escaladoResult = [SELECT Id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];
        System.assertEquals('SAC_Resuelta', escaladoResult.SAC_Estado__c, 'No se ha podido responder el escalado');
    }

    @isTest
    static void responderEscaladoModificacionesTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id, SAC_GrupoColaborador__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'testrec1'];

        Test.startTest();
        System.runAs(usuario) {
            SPV_LCMP_EscaladoOperativas.responderEscalado(escalado.Id, 'SPV_AceptadoConModificaciones', 'comentarios', 'SPV_Allanamiento', usuario.Id, caso.Id);
        }
        Test.stopTest();

        SAC_Interaccion__c escaladoResult = [SELECT Id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];
        System.assertEquals('SPV_PendienteEnviar', escaladoResult.SAC_Estado__c, 'No se ha podido responder el escalado');
    }

    @isTest
    static void responderEscaladoRechazadoTest() {
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id, SAC_GrupoColaborador__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'testrec1'];

        Test.startTest();
        System.runAs(usuario) {
            SPV_LCMP_EscaladoOperativas.responderEscalado(escalado.Id, 'SPV_Rechazado', 'comentarios', 'SPV_Allanamiento', usuario.Id, caso.Id);
        }
        Test.stopTest();

        SAC_Interaccion__c escaladoResult = [SELECT Id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado1' LIMIT 1];
        System.assertEquals('SAC_Resuelta', escaladoResult.SAC_Estado__c, 'No se ha podido responder el escalado');
    }
}