@isTest
public with sharing class SPV_InteraccionHelper_Test {
    @TestSetup
    static void makeData(){

        Test.startTest();
        List<User> listaUsers = SPV_TestDataFactory.crearUsuarioSPVGeneral(1);
        SPV_DatabaseDML.insertListDML(listaUsers, true);
    
        List<User> listaUsersAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1);
        SPV_DatabaseDML.insertListDML(listaUsersAdmin, true);

        Test.stopTest();


        //RecordTypes
        Id tipoRegistroParametrizaciones = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SPV_TMO').getRecordTypeId();


        //Mapa campos
        Map<String, Object> camposObj = new Map<String, Object>();
        //Reclamacion
        Case recla = new Case();
        Case recla2 = new Case();
        Case reclamacion3 = new Case();
        Case reclamacion4 = new Case();
        Case reclamacion5 = new Case();

        //Grupo
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
        //Cuentas
        List<Account> listaCuentas = new List<Account>();

        System.runAs(listaUsers[0]) {
            grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoDeTareas').getRecordTypeId();
            grupo.Name = 'grupotest';
            grupo.SAC_DeveloperName__c = 'SPV_AJ';
            grupo.SAC_PermiteEscalado__c = true;
            grupo.SAC_PermiteConsultas__c = true;
            grupo.SAC_PermiteTareas__c = true;
            grupo.SAC_PeriodoConsulta__c = 12;
            grupo.OS_Negocio__c = 'SPV';
            grupo.SAC_Email__C = 'testemailspv@test.cominvalid';
            grupo.SAC_Email2__C = 'testemailspv@test.cominvalid';
            grupo.SAC_Email3__C = 'testemailspv@test.cominvalid';
            SPV_DatabaseDML.insertDML(grupo, true);

            CC_Grupo_Colaborador_Contact__c colabcontact = new CC_Grupo_Colaborador_Contact__c();
            colabcontact.CC_Usuario__c = listaUsers[0].Id;
            colabcontact.CC_Grupo_Colaborador__c = grupo.Id;
            SPV_DatabaseDML.insertDML(colabcontact, true);

            CC_Grupo_Colaborador__c grupoColaboradorOficina = new CC_Grupo_Colaborador__c();
            grupoColaboradorOficina.name = 'Oficinas test';
            grupoColaboradorOficina.SAC_PermiteConsultas__c = true;
            grupoColaboradorOficina.SAC_Externo__c = false;
            grupoColaboradorOficina.SAC_DeveloperName__c = 'OFICINA';
            grupoColaboradorOficina.SAC_PeriodoConsulta__c = 12;
            grupoColaboradorOficina.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoDeTareas').getRecordTypeId();
            grupoColaboradorOficina.SAC_Email__c = 'test@email.com';
            grupoColaboradorOficina.SAC_Email2__c = 'test@email.com';
            grupoColaboradorOficina.SAC_Email3__c = 'test@email.com';
            SPV_DatabaseDML.insertDML(grupoColaboradorOficina, true);


            List<Case> listaReclamaciones = new List<Case>();

            //Crear reclamacion
            camposObj.put('Subject', 'testrec1');
            recla = SPV_TestDataFactory.crearCaso('Reclamacion', camposObj);
            listaReclamaciones.add(recla);

            camposObj.clear();
            camposObj.put('Subject', 'testrec2');
            recla2 = SPV_TestDataFactory.crearCaso('Reclamacion', camposObj);
            listaReclamaciones.add(recla2);

            camposObj.clear();
            camposObj.put('Subject', 'testrec3');
            camposObj.put('Status', 'SAC_001');
            camposObj.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposObj.put('SPV_Pendiente_Escalado__c', true);
            reclamacion3 = SPV_TestDataFactory.crearCaso('Reclamacion', camposObj);
            listaReclamaciones.add(reclamacion3);

            camposObj.clear();
            camposObj.put('Subject', 'testrec4');
            camposObj.put('Status', 'SAC_001');
            camposObj.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposObj.put('SPV_Pendiente_Escalado__c', false);
            reclamacion4 = SPV_TestDataFactory.crearCaso('Reclamacion', camposObj);
            listaReclamaciones.add(reclamacion4);

            camposObj.clear();
            camposObj.put('Subject', 'testrec5');
            camposObj.put('Status', 'SAC_001');
            camposObj.put('SAC_StatusAuxiliar__c', 'SAC_001');
            camposObj.put('SPV_Pendiente_Escalado__c', false);
            reclamacion5 = SPV_TestDataFactory.crearCaso('Reclamacion', camposObj);
            listaReclamaciones.add(reclamacion5);

            SPV_DatabaseDML.insertListDML(listaReclamaciones, true);


            SAC_MaestroAccionesReclamacion__c maestro = SPV_TestDataFactory.crearMaestroAcciones(1,grupo.Id)[0];
            maestro.SAC_DeveloperName__c ='SPV_TareaAutomaticaEscalado';
            maestro.SAC_Descripcion__c = 'Maestro';  
            maestro.SAC_PlazoMaximo__c = 4; 
            maestro.SAC_Prorroga__c= 4;
            SPV_DatabaseDML.insertDML(maestro, true);
        }

        system.runAs(listaUsersAdmin[0]) {
            //Cambiar owner de la reclamación
            recla.OwnerId = listaUsers[0].Id;
            SPV_DatabaseDML.updateDML(recla, true);

            recla2.OwnerId = listaUsers[0].Id;
            SPV_DatabaseDML.updateDML(recla2, true);

            //Cambiar owner de la reclamación
            recla.OwnerId = listaUsers[0].Id;
            SPV_DatabaseDML.updateDML(reclamacion3, true);

            recla2.OwnerId = listaUsers[0].Id;
            SPV_DatabaseDML.updateDML(reclamacion4, true);

            //Cuentas
            listaCuentas = SPV_TestDataFactory.crearCuentas(1);
            listaCuentas[0].Name = 'Cuenta A';
            listaCuentas[0].CC_Tipo_Centro__c = 'OF';
            listaCuentas[0].Phone = '123456789';
            listaCuentas[0].CC_Email__c = 'cuenta@mail.com';
            listaCuentas[0].billingStreet  = 'Calle Mayor 55';
            listaCuentas[0].BillingCountry = 'España';
            listaCuentas[0].OwnerId = listaUsers[0].id;
            listaCuentas[0].recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            SPV_DatabaseDML.insertListDML(listaCuentas, true);

            EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'nombreTest';
            validEmailTemplate.DeveloperName = 'SAC_Test';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.HtmlValue = '<p>valor del body<p>';
            validEmailTemplate.Body = 'Texted';
            validEmailTemplate.FolderId = listaUsersAdmin[0].Id;
    
            SPV_DatabaseDML.insertDML(validEmailTemplate, true);
        }

        System.runAs(listaUsers[0]) {
            List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();
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
            camposObj.put('OwnerId', listaUsers[0].Id);
            SAC_Interaccion__c escalado = SPV_TestDataFactory.crearInteraccion('Escalado', camposObj);
            listaEscalados.add(escalado);

            //Crear esacalado 2
            camposObj.clear();
            camposObj.put('SAC_CasoEscalado__c', reclamacion3.Id);
            camposObj.put('SAC_Titulo__c', 'testescalado2');
            camposObj.put('SAC_GrupoColaborador__c', grupo.Id);
            camposObj.put('SPV_TipoAllanamiento__c', 'SPV_Parcial');
            camposObj.put('SPV_MotivoAllanamiento__c', 'Test');
            camposObj.put('SPV_AnalisisAllanamiento__c', 'Test');
            camposObj.put('SPV_VerificacionesLetrado__c', 'Test');
            camposObj.put('SAC_Propuesta__c', 'Test');
            camposObj.put('SPV_TipoActuacion__c', 'SPV_Pago');
            camposObj.put('SPV_Importe__c', 1);
            camposObj.put('SPV_Imputable__c', 'SPV_Entidad');
            camposObj.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
            camposObj.put('SPV_TipoEscalado__c', 'SPV_FormularioRectificacion');
            camposObj.put('SPV_InstruccionesAJ__c', 'Test');
            camposObj.put('SPV_DecisionFinal__c', 'Alegaciones');
            camposObj.put('SPV_ImporteDecisionFinal__c', 12);
            camposObj.put('SAC_Conclusion__c', 'SPV_Aceptado');
            camposObj.put('OwnerId', listaUsers[0].Id);
            SAC_Interaccion__c escalado2 = SPV_TestDataFactory.crearInteraccion('Escalado', camposObj);
            listaEscalados.add(escalado2);
            
            //Crear esacalado 2
            camposObj.clear();
            camposObj.put('SAC_CasoEscalado__c', reclamacion4.Id);
            camposObj.put('SAC_Titulo__c', 'testescalado3');
            camposObj.put('SAC_GrupoColaborador__c', grupo.Id);
            camposObj.put('SPV_TipoAllanamiento__c', 'SPV_Parcial');
            camposObj.put('SPV_TipoEscalado__c', 'SPV_FormularioRectificacion');
            camposObj.put('SPV_MotivoAllanamiento__c', 'Test');
            camposObj.put('SPV_AnalisisAllanamiento__c', 'Test');
            camposObj.put('SPV_VerificacionesLetrado__c', 'Test');
            camposObj.put('SAC_Propuesta__c', 'Test');
            camposObj.put('SPV_TipoActuacion__c', 'SPV_Pago');
            camposObj.put('SPV_Importe__c', 1);
            camposObj.put('SPV_Imputable__c', 'SPV_Entidad');
            camposObj.put('SAC_Estado__c', 'SPV_PendienteEnviar');
            camposObj.put('SPV_InstruccionesAJ__c', 'Test');
            camposObj.put('SPV_DecisionFinal__c', 'Alegaciones');
            camposObj.put('SPV_ImporteDecisionFinal__c', 12);
            camposObj.put('SAC_Conclusion__c', 'SPV_Aceptado');
            camposObj.put('OwnerId', listaUsers[0].Id);
            SAC_Interaccion__c escalado3 = SPV_TestDataFactory.crearInteraccion('Escalado', camposObj);
            listaEscalados.add(escalado3);

            //Crear esacalado 4
            camposObj.clear();
            camposObj.put('SAC_CasoEscalado__c', reclamacion5.Id);
            camposObj.put('SAC_Titulo__c', 'testescalado4');
            camposObj.put('SAC_GrupoColaborador__c', grupo.Id);
            camposObj.put('SPV_TipoAllanamiento__c', 'SPV_Parcial');
            camposObj.put('SPV_TipoEscalado__c', 'SPV_FormularioRectificacion');
            camposObj.put('SPV_MotivoAllanamiento__c', 'Test');
            camposObj.put('SPV_AnalisisAllanamiento__c', 'Test');
            camposObj.put('SPV_VerificacionesLetrado__c', 'Test');
            camposObj.put('SAC_Propuesta__c', 'Test');
            camposObj.put('SPV_TipoActuacion__c', 'SPV_Pago');
            camposObj.put('SPV_Importe__c', 1);
            camposObj.put('SPV_Imputable__c', 'SPV_Entidad');
            camposObj.put('SAC_Estado__c', 'SPV_PendienteEnviar');
            camposObj.put('OwnerId', listaUsers[0].Id);

            SAC_Interaccion__c escalado4 = SPV_TestDataFactory.crearInteraccion('Escalado', camposObj);
            listaEscalados.add(escalado4);

            SPV_DatabaseDML.insertListDML(listaEscalados, true);

            //Crear consulta
            camposObj.clear();
            camposObj.put('SAC_Reclamacion__c', recla.Id);
            camposObj.put('SAC_Titulo__c', 'ConsultaAsociadaEscalado');
            camposObj.put('SAC_GrupoColaborador__c', grupo.Id);
            camposObj.put('SAC_Pregunta__c', 'Test pregunta');
            camposObj.put('SAC_EscaladoNV2__c', escalado.id);
            SAC_Interaccion__c consulta = SPV_TestDataFactory.crearInteraccion('Consulta', camposObj);
            SPV_DatabaseDML.insertDML(consulta, true);

            camposObj.clear();
            camposObj.put('SAC_Reclamacion__c', recla.Id);
            camposObj.put('SAC_Oficina__c', listaCuentas[0].Id);
            camposObj.put('SAC_Titulo__c', 'ConsultaTest');
            camposObj.put('SAC_GrupoColaborador__c', grupo.Id);
            SAC_Interaccion__c consulta2 = SPV_TestDataFactory.crearInteraccion('Consulta', camposObj);
            SPV_DatabaseDML.insertDML(consulta2, true);

            camposObj.clear();
            camposObj.put('SAC_Reclamacion__c', recla2.Id);
            camposObj.put('SAC_Titulo__c', 'ConsultaTest2');
            camposObj.put('SAC_GrupoColaborador__c', grupo.Id);
            SAC_Interaccion__c consulta3 = SPV_TestDataFactory.crearInteraccion('Consulta', camposObj);
            SPV_DatabaseDML.insertDML(consulta3, true);
            

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

            //Parametrizaciones SLA/TMO
            List<SAC_ParametrizacionSLATME__c> listaParametrizaciones = new List<SAC_ParametrizacionSLATME__c>();
            SAC_ParametrizacionSLATME__c parametrizacion1 = new SAC_ParametrizacionSLATME__c();
            parametrizacion1.Name = 'TMO Análisis Complementaria Organismo';
            parametrizacion1.SAC_Estados__c = 'SPV_AnalisisComplementariaOrganismo';
            parametrizacion1.RecordTypeId = tipoRegistroParametrizaciones;

            listaParametrizaciones.add(parametrizacion1);

            SPV_DatabaseDML.insertListDML(listaParametrizaciones, true);
       

        }
    }



    @isTest
    static void registrarCambiosActividadesTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id, SAC_CasoEscalado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado3' LIMIT 1];
        Case reclamacion = [SELECT Id, SPV_Pendiente_Escalado__c FROM Case WHERE Subject = 'testrec4' LIMIT 1];

        System.runAs(usuario){
            escalado.SAC_MotivoEscalado__c = 'SAC_OtrosMotivosEsc';
            escalado.SPV_ObservacionesMotivoEscalado__c = 'Test';
            escalado.SPV_TipoEscalado__c = 'SPV_Otros';
            SPV_DatabaseDML.updateDML(escalado, true);
            
            escalado.SPV_TipoEscalado__c = 'SPV_FormularioRectificacion';
            escalado.SAC_Conclusion__c = 'SPV_AceptadoConModificaciones';
            escalado.SPV_DecisionFinal__c = 'Allanamiento';
            escalado.SPV_ImporteDecisionFinal__c = 59;
            SPV_DatabaseDML.updateDML(escalado, true);

        }

        List<FeedItem> result = [SELECT Id FROM FeedItem WHERE ParentId = :escalado.SAC_CasoEscalado__c];
        Assert.areNotEqual(result, null, 'No se han registrado los cambios en actividades');
        Test.stopTest();
    }

    @isTest
    static void registrarCreacionEscaladoActividadesTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id, SAC_CasoEscalado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado3' LIMIT 1];
        Case reclamacion = [SELECT Id, SPV_Pendiente_Escalado__c FROM Case WHERE Subject = 'testrec4' LIMIT 1];
        SAC_Interaccion__c escaladoNuevo = new SAC_Interaccion__c();

        System.runAs(usuario){
            escalado.SAC_Estado__c = 'SAC_Atendida';
            SPV_DatabaseDML.updateDML(escalado, true);
            
            Map<String, Object> camposObj = new Map<String, Object>();
            camposObj.clear();
            camposObj.put('SAC_CasoEscalado__c', reclamacion.Id);
            camposObj.put('SAC_Titulo__c', 'testescaladoTest');
            camposObj.put('SPV_TipoAllanamiento__c', 'SPV_Parcial');
            camposObj.put('SPV_TipoEscalado__c', 'SPV_Otros');
            camposObj.put('SPV_MotivoAllanamiento__c', 'Test');
            camposObj.put('SPV_AnalisisAllanamiento__c', 'Test');
            camposObj.put('SPV_VerificacionesLetrado__c', 'Test');
            camposObj.put('SAC_Propuesta__c', 'Test');
            camposObj.put('SPV_TipoActuacion__c', 'SPV_Pago');
            camposObj.put('SPV_Importe__c', 1);
            camposObj.put('SPV_Imputable__c', 'SPV_Entidad');
            camposObj.put('SAC_Estado__c', 'SPV_PendienteEnviar');
            camposObj.put('SPV_InstruccionesAJ__c', 'Test');
            camposObj.put('SPV_DecisionFinal__c', 'Alegaciones');
            camposObj.put('SPV_ImporteDecisionFinal__c', 12);
            camposObj.put('SAC_Conclusion__c', 'SPV_Aceptado');

            escaladoNuevo = SPV_TestDataFactory.crearInteraccion('Escalado', camposObj);
            SPV_DatabaseDML.insertDML(escaladoNuevo, true);
        }

        List<FeedItem> result = [SELECT Id FROM FeedItem WHERE ParentId = :escaladoNuevo.SAC_CasoEscalado__c];
        Assert.areNotEqual(result, null, 'No se ha registrado la creación del escalado en actividades.');
        Test.stopTest();
    }

    @isTest
    static void pausarORenaudarTMETest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado3' LIMIT 1];
        Case reclamacion = [SELECT Id, SPV_Pendiente_Escalado__c FROM Case WHERE Subject = 'testrec4' LIMIT 1];

        System.runAs(usuario){

            reclamacion.Status = 'SPV_AnalisisComplementariaOrganismo';
            SPV_DatabaseDML.updateDML(reclamacion, true);

            escalado.SAC_Estado__c = 'SAC_PendienteRespuesta';
            SPV_DatabaseDML.updateDML(escalado, true);

            escalado.SAC_Estado__c = 'SAC_Atendida';
            SPV_DatabaseDML.updateDML(escalado, true);
        }

        
        SAC_TMECaso__c tmeResult = [SELECT Id FROM SAC_TMECaso__c WHERE SAC_Caso__c = :reclamacion.Id AND Name = 'TMO Análisis Complementaria Organismo'];
        SAC_TiempoEstados__c tpeResult = [SELECT Id, SAC_Fin__c FROM SAC_TiempoEstados__c WHERE SAC_TMECaso__c = :tmeResult.Id ORDER BY CreatedDate desc LIMIT 1];
        Assert.areEqual(true, true, 'No se ha cerrado el TMO.');
        Test.stopTest();
    }

    @isTest
    static void validarCamposCambioEstadoEscaladoTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id,SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado4' LIMIT 1];
        Boolean saltaValidacion = false;

        System.runAs(usuario){
            try{
                escalado.SAC_Estado__c = 'SAC_PendienteRespuesta';
                SPV_DatabaseDML.updateDML(escalado, true);

                escalado.SAC_Estado__c = 'SAC_Atendida';
                SPV_DatabaseDML.updateDML(escalado, true);
            }catch(Exception e){
                saltaValidacion = true;
            }
        }

        SAC_Interaccion__c escaladoResult = [SELECT Id,SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado3' LIMIT 1];
        Assert.areEqual(true, saltaValidacion, 'No se hizo bien la validación de cambio de estado.');
        Test.stopTest();
    }

    @isTest
    static void validarObservacionesEscaladoTest1(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id,SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado3' LIMIT 1];
        Boolean saltaValidacion = false;

        System.runAs(usuario){
            try{
                escalado.SAC_MotivoEscalado__c = 'SAC_OtrosMotivosEsc';
                SPV_DatabaseDML.updateDML(escalado, true);

            }catch(Exception e){
                saltaValidacion = true;
            }
        }

        SAC_Interaccion__c escaladoResult = [SELECT Id,SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado3' LIMIT 1];
        Assert.areEqual(true, saltaValidacion, 'No se hizo bien la validación de cambio de motivo de escalado.');
        Test.stopTest();
    }

    @isTest
    static void validarObservacionesEscaladoTest2(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id,SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado3' LIMIT 1];

        System.runAs(usuario){
            escalado.SAC_MotivoEscalado__c = 'SAC_OtrosMotivosEsc';
            escalado.SPV_ObservacionesMotivoEscalado__c = 'Test';
            SPV_DatabaseDML.updateDML(escalado, true);

            escalado.SAC_MotivoEscalado__c = 'SAC_FaltaCriterio';
            SPV_DatabaseDML.updateDML(escalado, true);
        }

        SAC_Interaccion__c escaladoResult = [SELECT Id,SAC_Estado__c, SPV_ObservacionesMotivoEscalado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado3' LIMIT 1];
        Assert.areEqual(null, escaladoResult.SPV_ObservacionesMotivoEscalado__c , 'No se vació el campo de Observaciones del motivo de escalado.');
        Test.stopTest();
    }

    @isTest
    static void validarObservacionesEscaladoTest3(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id,SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado3' LIMIT 1];
        Boolean saltaValidacion = false;

        System.runAs(usuario){
            try{
                escalado.SPV_TipoEscalado__c = 'SPV_Otros';
                escalado.SPV_ObservacionesTipoEscalado__c = 'Test';
                SPV_DatabaseDML.updateDML(escalado, true);

                escalado.SPV_ObservacionesTipoEscalado__c = '';
                SPV_DatabaseDML.updateDML(escalado, true);

            }catch(Exception e){
                saltaValidacion = true;
            }
        }

        Assert.areEqual(true, saltaValidacion, 'No se hizo bien la validación de observaciones de tipo escalado.');
        Test.stopTest();
    }

    @isTest
    static void actualizarPendienteEscaladoReclamacionTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado2' LIMIT 1];

        System.runAs(usuario){
            escalado.SAC_Estado__c = 'SAC_Atendida';
            escalado.SPV_TipoRespuesta__c = 'SPV_Aceptado';
            SPV_DatabaseDML.updateDML(escalado, true);
        }

        Case reclamacionResultado = [SELECT Id, SPV_Pendiente_Escalado__c FROM Case WHERE Subject = 'testrec3' LIMIT 1];
        Assert.areEqual(reclamacionResultado.SPV_Pendiente_Escalado__c, false, 'No se ha actualizado pendiente de resolución de escalado');
        Test.stopTest();
    }

    @isTest
    static void actualizarReclamacionAlEnviarEscalado(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testescalado3' LIMIT 1];

        System.runAs(usuario){
            escalado.SAC_Estado__c = 'SAC_PendienteRespuesta';
            SPV_DatabaseDML.updateDML(escalado, true);
        }

        Case reclamacionResultado = [SELECT Id, SPV_Pendiente_Escalado__c FROM Case WHERE Subject = 'testrec4' LIMIT 1];
        Assert.areEqual(reclamacionResultado.SPV_Pendiente_Escalado__c, true, 'No se ha actualizado pendiente de resolución de escalado');
        Test.stopTest();
    }

    @isTest
    static void informarPreguntaConsultaTest() {
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'testrec1' LIMIT 1];
        SAC_Interaccion__c consulta = [SELECT Id, SAC_Oficina__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTest' LIMIT 1];
        Account oficina = [SELECT Id FROM Account WHERE CC_Email__c = 'cuenta@mail.com' LIMIT 1];

        consulta.SAC_Oficina__c = oficina.Id;
        SPV_DatabaseDML.updateDML(consulta, true);
        
        System.runAs(usuario) {
            consulta.SAC_Pregunta__c = 'Test pregunta';
            SPV_DatabaseDML.updateDML(consulta, true);
        }
        Test.stopTest();

        SAC_Interaccion__c consultaActualizada = [SELECT Id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Reclamacion__C = :caso.Id AND SAC_Oficina__c <> null LIMIT 1];
        System.assertEquals(consultaActualizada.SAC_Estado__c, 'SAC_PendienteRespuesta', 'No se ha informado la pregunta correctamente');
    }

    @isTest
    static void informarPreguntaConsultaTest2() {
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'testrec2' LIMIT 1];
        SAC_Interaccion__c consulta = [SELECT Id, SAC_Oficina__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTest2' LIMIT 1];
        
        System.runAs(usuario) {
            consulta.SAC_Pregunta__c = 'Test pregunta2';
            SPV_DatabaseDML.updateDML(consulta, true);
        }
        Test.stopTest();

        SAC_Interaccion__c consultaActualizada = [SELECT Id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Reclamacion__C = :caso.Id LIMIT 1];
        System.assertEquals(consultaActualizada.SAC_Estado__c, 'SAC_PendienteRespuesta', 'No se ha informado la pregunta correctamente');
    }
}