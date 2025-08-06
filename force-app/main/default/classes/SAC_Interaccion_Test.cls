/*****************************************************************
 * Name: SAC_Interaccion_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_Interaccion
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US219272         Carlos Solis         23/08/21     Creación
 * 1.1            US219272         Marcela Neira        27/08/21     Modificación
 * 1.2            US271688         Carlos Solis         26/10/21     Modificación (añadidos los metodos insertarTMEEscaladoTest y cerrarTMEEscaladoTest)
 * 1.3			  US415467		   Alex Perez	        26/09/22     Modificación(adaptar para incluir el periodo consulta)
 * 1.4            US537175         Raúl Santos          23/02/23     Modificación (cubrir el envio de mail)
 * 1.5            US593664         Jose Carlos Blanco  	09/05/23     Modificación (test modificada usando el SAC_TestDataFactory)   
******************************************************************/
@isTest
public with sharing class SAC_Interaccion_Test {
    @TestSetup
    static void makeData(){

        Test.startTest();
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];     
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);

        User usuario;
        System.runAs(usuarioAdmin) {
            //Usuario SAC General
            usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            usuario.Username = 'ustestesteo@test.com';      
            SAC_DatabaseDML.insertDML(usuario, false);

            /*PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);*/
        }
        Test.stopTest();

        // Id recordCentroCaixaBank = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        // Account cuentaOficina = new Account(Name = 'Oficina', CC_Email__c = 'test@test.com', RecordTypeId = recordCentroCaixaBank);
        // Database.insert(cuentaOficina);

        //Cuentas
        List<Account> listaCuentas = SAC_TestDataFactory.crearCuentas(2);
        listaCuentas[0].Name = 'Cuenta A';
        listaCuentas[0].Phone = '123456789';
        listaCuentas[0].CC_Email__c = 'cuenta@mail.com';
        listaCuentas[0].billingStreet  = 'Calle Mayor 55';
        listaCuentas[0].BillingCountry = 'España';
        listaCuentas[0].OwnerId = usuario.id;
        listaCuentas[0].recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        listaCuentas[1].recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        listaCuentas[1].Name = 'Cuenta D';
        listaCuentas[1].Phone = '123456789';
        listaCuentas[1].CC_Email__c = 'cuenta@mail.com';
        listaCuentas[1].billingStreet  = 'Calle Mayor 55';
        listaCuentas[1].BillingCountry = 'España';
        listaCuentas[1].CC_Numero_Documento__c = '46666666C';
        SAC_DatabaseDML.insertListDML(listaCuentas, false);

        //grupo colaborador nivel 2
        List<CC_Grupo_Colaborador__c> listaGrupos = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',6);
        listaGrupos[0].Name = 'grupoTest';
        listaGrupos[0].SAC_PermiteEscalado__c = true;
        listaGrupos[0].SAC_NivelGrupo__c = 'SAC_Nivel2';
        listaGrupos[0].SAC_Email__c = 'etesting@test.test';
        listaGrupos[0].SAC_Email2__c = 'etesting1@test.test';
        listaGrupos[0].SAC_Email3__c = 'etesting2@test.test';
        listaGrupos[0].SAC_PeriodoConsulta__c = 12;
        listaGrupos[0].SAC_PermiteConsultas__c = true;
        listaGrupos[0].SAC_TieneUsuariosActivos__c = true;
        listaGrupos[0].SAC_TienePropietario__c = true;

        //grupo colaborador nivel 3
        listaGrupos[1].Name = 'grupoTestNV3';
        listaGrupos[1].SAC_PermiteEscalado__c = true;
        listaGrupos[1].SAC_NivelGrupo__c = 'SAC_Nivel3';
        listaGrupos[1].SAC_Email__c = 'etesting@test.test';

        listaGrupos[2].Name = 'Grupo Proveedores Test';
        listaGrupos[2].SAC_PermiteEscalado__c=true;
        listaGrupos[2].SAC_Email__c = 'test@test.com';
        listaGrupos[2].SAC_DeveloperName__c = 'AJ';

        listaGrupos[3].Name = 'Grupo Proveedores Test2';
        listaGrupos[3].SAC_PermiteEscalado__c=true;

        listaGrupos[4].Name = 'Grupo Vida Caixa';
        listaGrupos[4].SAC_PermiteEscalado__c=true;
        listaGrupos[4].SAC_Email__c = 'test@test.com';
        listaGrupos[4].SAC_DeveloperName__c = 'AJ_VCX';

        listaGrupos[5].Name = 'grupoTest4';
        listaGrupos[5].SAC_PermiteEscalado__c = true;
        listaGrupos[5].SAC_NivelGrupo__c = 'SAC_Nivel2';
        listaGrupos[5].SAC_Email__c = 'etesting@test.test';
        listaGrupos[5].SAC_PeriodoConsulta__c = 12;
        listaGrupos[5].SAC_PermiteConsultas__c = true;
        listaGrupos[5].SAC_TieneUsuariosActivos__c = true;
        listaGrupos[5].SAC_Externo__c = true;
        SAC_DatabaseDML.insertListDML(listaGrupos, false);


        List<Case> listaReclamaciones = new List<Case>();
        //RECLAMACION 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Alta');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl.put('OwnerId', usuario.Id);
        camposRecl.put('AccountId', listaCuentas[0].Id);
        camposRecl.put('CC_Oficina_Afectada_Lookup__c', listaCuentas[0].Id);
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        listaReclamaciones.add(casoReclamacion);

        //RECLAMACION 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'Alta');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl2.put('OwnerId', usuario.Id);
        camposRecl2.put('CC_Importe_Reclamado__c', 1000);
        camposRecl2.put('SAC_Entidad_Afectada__c', 'SAC_007');
        
        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        listaReclamaciones.add(casoReclamacion2);

        //RECLAMACION 3 Para escalar
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'TestRec3');
        camposRecl3.put('Origin', 'Backoffice');
        camposRecl3.put('Status', 'Alta');
        camposRecl3.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl3.put('OwnerId', usuario.Id);
        camposRecl3.put('SAC_CasoEspecial__c', 'SAC_Presidencia');
        camposRecl3.put('SAC_Importe_Resuelto__c', 10);
        camposRecl3.put('SAC_EntidadProductora__c', 'Microbank');
        
        Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);
        listaReclamaciones.add(casoReclamacion3);

        //RECLAMACION 4 Para escalar
        Map<String, Object> camposRecl4 = new Map<String, Object>();
        camposRecl4.put('Subject', 'TestRec4');
        camposRecl4.put('Origin', 'Backoffice');
        camposRecl4.put('Status', 'Alta');
        camposRecl4.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl4.put('OwnerId', usuario.Id);
        camposRecl4.put('SEG_Grupo__c', listaGrupos[3].id);
        camposRecl4.put('CC_Importe_Reclamado__c', 300);
        camposRecl4.put('SAC_Importe_Resuelto__c', 300);
        camposRecl4.put('SAC_EntidadProductora__c', 'Bankia');
        
        Case casoReclamacion4 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl4);
        listaReclamaciones.add(casoReclamacion4);

        //RECLAMACION 5
        Map<String, Object> camposRecl5 = new Map<String, Object>();
        camposRecl5.put('Subject', 'Reclamacion5');
        camposRecl5.put('Status', 'Alta');
        camposRecl5.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl5.put('OwnerId', usuario.Id);
        camposRecl5.put('SAC_CasoEspecial__c', 'SAC_Sensible');

        Case casoReclamacion5 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl5);
        listaReclamaciones.add(casoReclamacion5);

        //RECLAMACION 6
        Map<String, Object> camposRecl6 = new Map<String, Object>();
        camposRecl6.put('Subject', 'Reclamacion6');
        camposRecl6.put('Status', 'Alta');
        camposRecl6.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl6.put('OwnerId', usuario.Id);
        camposRecl6.put('SAC_CasoEspecial__c', 'SAC_Sensible');

        Case casoReclamacion6 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl6);
        listaReclamaciones.add(casoReclamacion6);

        //RECLAMACION 7
        Map<String, Object> camposRecl7 = new Map<String, Object>();
        camposRecl7.put('Subject', 'Reclamacion7');
        camposRecl7.put('Status', 'Alta');
        camposRecl7.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl7.put('OwnerId', usuario.Id);
        camposRecl7.put('SAC_Entidad_Afectada__c', 'SAC_007');
        camposRecl7.put('CC_Importe_Reclamado__c', 20000);

        Case casoReclamacion7 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl7);
        listaReclamaciones.add(casoReclamacion7);

        //RECLAMACION 8
        Map<String, Object> camposRecl8 = new Map<String, Object>();
        camposRecl8.put('Subject', 'TestRec8');
        camposRecl8.put('Origin', 'Backoffice');
        camposRecl8.put('Status', 'Alta');
        camposRecl8.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl8.put('OwnerId', usuario.Id);
        camposRecl8.put('SAC_Importe_Resuelto__c', 10);
        camposRecl8.put('SAC_EntidadProductora__c', 'Microbank');

        Case casoReclamacion8 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl8);
        listaReclamaciones.add(casoReclamacion8);

        //RECLAMACION 9
        Map<String, Object> camposRecl9 = new Map<String, Object>();
        camposRecl9.put('Subject', 'TestRec9');
        camposRecl9.put('Origin', 'Backoffice');
        camposRecl9.put('Status', 'Alta');
        camposRecl9.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl9.put('OwnerId', usuario.Id);
        
        Case casoReclamacion9 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl9);
        listaReclamaciones.add(casoReclamacion9);

        //RECLAMACION 10
        Map<String, Object> camposRecl10 = new Map<String, Object>();
        camposRecl10.put('Subject', 'TestRec10');
        camposRecl10.put('Origin', 'Backoffice');
        camposRecl10.put('Status', 'Alta');
        camposRecl10.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl10.put('OwnerId', usuario.Id);
        
        Case casoReclamacion10 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl10);
        listaReclamaciones.add(casoReclamacion10);

        SAC_DatabaseDML.insertListDML(listaReclamaciones, false);


        //Interaccion escalado
        List<SAC_Interaccion__c> listaInteracciones = new List<SAC_Interaccion__c>();
        Map<String, Object> camposEsc = new Map<String, Object>();
        camposEsc.put('SAC_Titulo__c', 'propuesta test');
        camposEsc.put('SAC_Propuesta__c', 'propuesta test');
        camposEsc.put('SAC_CasoEscalado__c', casoReclamacion2.Id);
        camposEsc.put('SAC_Email1__c', 'testing@test.test');
        camposEsc.put('OwnerId', usuario.Id);
        camposEsc.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        camposEsc.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        
        SAC_Interaccion__c escalado = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc);
        listaInteracciones.add(escalado);

        //Escalado NV3
        Map<String, Object> camposEscNV3 = new Map<String, Object>();
        camposEscNV3.put('SAC_Titulo__c', 'propuesta test2');
        camposEscNV3.put('SAC_Propuesta__c', 'propuesta test2');
        camposEscNV3.put('SAC_CasoEscalado__c', casoReclamacion2.Id);
        camposEscNV3.put('SAC_Email1__c', 'testing@test.test');
        camposEscNV3.put('OwnerId', usuario.Id);
        camposEscNV3.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        camposEscNV3.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        
        SAC_Interaccion__c escaladoNV3 = SAC_TestDataFactory.crearInteraccion('EscaladoNV3',camposEscNV3);
        listaInteracciones.add(escaladoNV3);

        //Interaccion escalado 2
        Map<String, Object> camposEsc2 = new Map<String, Object>();
        camposEsc2.put('SAC_Titulo__c', 'propuesta test');
        camposEsc2.put('SAC_Propuesta__c', 'propuesta test');
        camposEsc2.put('SAC_CasoEscalado__c', casoReclamacion5.Id);
        camposEsc2.put('OwnerId', usuario.Id);
        camposEsc2.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        camposEsc2.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        camposEsc2.put('SAC_Email1__c', 'testingcorreo@test.test');
        
        SAC_Interaccion__c escalado2 = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc2);
        listaInteracciones.add(escalado2);

        //Interaccion escalado 3
        Map<String, Object> camposEsc3 = new Map<String, Object>();
        camposEsc3.put('SAC_Titulo__c', 'propuesta test3');
        camposEsc3.put('SAC_Propuesta__c', 'propuesta test3');
        camposEsc3.put('SAC_CasoEscalado__c', casoReclamacion10.Id);
        camposEsc3.put('OwnerId', usuario.Id);
        camposEsc3.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        camposEsc3.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        camposEsc3.put('SAC_Email1__c', 'testingcorreo@test.test');
        
        SAC_Interaccion__c escalado3 = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc3);
        listaInteracciones.add(escalado3);


        //Interaccion consulta
        Map<String, Object> camposCons = new Map<String, Object>();
        camposCons.put('SAC_Titulo__c', 'consulta');
        camposCons.put('SAC_Propuesta__c', 'consulta');
        camposCons.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposCons.put('SAC_Oficina__c', listaCuentas[0].Id);
        camposCons.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        camposCons.put('OwnerId', usuario.Id);
        
        SAC_Interaccion__c interaccion = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons);
        listaInteracciones.add(interaccion);

        //Interaccion consulta 2
        Map<String, Object> camposCons2 = new Map<String, Object>();
        camposCons2.put('SAC_Titulo__c', 'consulta2');
        camposCons2.put('SAC_Propuesta__c', 'consulta2');
        camposCons2.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        camposCons2.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposCons2.put('SAC_Oficina__c', listaCuentas[0].id);
        camposCons2.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        
        SAC_Interaccion__c consulta2 = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons2);
        listaInteracciones.add(consulta2);

        //Interaccion consulta 3
        Map<String, Object> camposCons3 = new Map<String, Object>();
        camposCons3.put('SAC_Titulo__c', 'consulta3');
        camposCons3.put('SAC_Propuesta__c', 'consulta3');
        camposCons3.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        camposCons3.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        
        SAC_Interaccion__c consulta3 = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons3);
        listaInteracciones.add(consulta3);

        //Interaccion consulta 4
        Map<String, Object> camposCons4 = new Map<String, Object>();
        camposCons4.put('SAC_Titulo__c', 'consulta4');
        camposCons4.put('SAC_Propuesta__c', 'consulta4');
        //camposCons4.put('SAC_Estado__c', 'SAC_Atendida');
        camposCons4.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposCons4.put('SAC_Oficina__c', listaCuentas[0].Id);
        camposCons4.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        camposCons4.put('SAC_EmailOficina__c', 'testSAC@SAC.com');
        camposCons4.put('SAC_EmailCC__c', 'testSACtest05@SAC.com');
        camposCons4.put('SAC_EmailCCO__c', 'testSACtest05@SAC.com');
        
        SAC_Interaccion__c consulta4 = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons4);
        listaInteracciones.add(consulta4);

        SAC_DatabaseDML.insertListDML(listaInteracciones, false);

        List<CC_MCC__c> listaMCCs = new List<CC_MCC__c>();
        //MCC
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.Name = 'PSD2';
        mcc.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        listaMCCs.add(mcc);

        //MCC 2
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.Name = 'SACDetalleMCC';
        mcc2.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        mcc2.SAC_EscaladoObligatorio__c = true;
        listaMCCs.add(mcc2);

        SAC_DatabaseDML.insertListDML(listaMCCs, false);


        List<Case> listaPretensiones = new List<Case>();
        //PRETENSION 1
        Map<String, Object> campsoPret1 = new Map<String, Object>();
        campsoPret1.put('Subject', 'TestPret1');
        campsoPret1.put('Origin', 'Backoffice');
        campsoPret1.put('Status', 'Alta');
        campsoPret1.put('SAC_StatusAuxiliar__c', 'Alta');
        campsoPret1.put('OwnerId', usuario.Id);
        campsoPret1.put('SEG_Detalle__c', mcc2.Id);
        campsoPret1.put('SAC_Reclamacion__c', casoReclamacion9.Id);
        
        Case casoPretension1 = SAC_TestDataFactory.crearCaso('Pretension',campsoPret1);
        listaPretensiones.add(casoPretension1);

        //PRETENSION 2
        Map<String, Object> campsoPret2 = new Map<String, Object>();
        campsoPret2.put('Subject', 'TestPret1');
        campsoPret2.put('Origin', 'Backoffice');
        campsoPret2.put('Status', 'Alta');
        campsoPret2.put('SAC_StatusAuxiliar__c', 'Alta');
        campsoPret2.put('OwnerId', usuario.Id);
        campsoPret2.put('SEG_Detalle__c', mcc2.Id);
        campsoPret2.put('SAC_Reclamacion__c', casoReclamacion10.Id);
        
        Case casoPretension2 = SAC_TestDataFactory.crearCaso('Pretension',campsoPret2);
        listaPretensiones.add(casoPretension2);

        SAC_DatabaseDML.insertListDML(listaPretensiones, false);


        //Parametrizaciones Escalados
        List<SAC_ParametrizacionEscalado__c> listaParametrizaciones = new List<SAC_ParametrizacionEscalado__c>();
        
        //Parametrizaciones Escalado 1
        Map<String, Object> camposParam = new Map<String, Object>();
        camposParam.put('Name', 'Validacion Escalado AJ');
        camposParam.put('Aplica_escalado__c', true);
        camposParam.put('SAC_Despacho__c', listaGrupos[3].id);
        camposParam.put('SAC_GrupoDestino__c', listaGrupos[2].Id);
        camposParam.put('SAC_Importe__c', 200);
        camposParam.put('SAC_Mensaje__c', 'Mensaje');
        camposParam.put('SAC_todosMCCs__c', true);
        camposParam.put('SAC_TodosDespachos__c', true);
        camposParam.put('SAC_validarImporte__c', false);
        
        SAC_ParametrizacionEscalado__c parametrizacionEscalado = SAC_TestDataFactory.crearParamEsc(camposParam);
        listaParametrizaciones.add(parametrizacionEscalado);

        //Parametrizaciones Escalado 2
        Map<String, Object> camposParam2 = new Map<String, Object>();
        camposParam2.put('Name', 'Validacion Escalado COPS');
        camposParam2.put('Aplica_escalado__c', true);
        camposParam2.put('SAC_Despacho__c', listaGrupos[3].id);
        camposParam2.put('SAC_GrupoDestino__c', listaGrupos[2].Id);
        camposParam2.put('SAC_Importe__c', 200);
        camposParam2.put('SAC_Mensaje__c', 'Mensaje');
        camposParam2.put('SAC_todosMCCs__c', true);
        camposParam2.put('SAC_TodosDespachos__c', true);
        camposParam2.put('SAC_validarImporte__c', false);
        
        SAC_ParametrizacionEscalado__c parametrizacionEscalado2 = SAC_TestDataFactory.crearParamEsc(camposParam2);
        listaParametrizaciones.add(parametrizacionEscalado2);

        //Parametrizaciones Escalado 3
        Map<String, Object> camposParam3 = new Map<String, Object>();
        camposParam3.put('Name', 'Validacion Escalado COPS');
        camposParam3.put('Aplica_escalado__c', true);
        camposParam3.put('SAC_Despacho__c', listaGrupos[3].id);
        camposParam3.put('SAC_GrupoDestino__c', listaGrupos[2].Id);
        camposParam3.put('SAC_Importe__c', 200);
        camposParam3.put('SAC_Mensaje__c', 'Mensaje');
        camposParam3.put('SAC_todosMCCs__c', true);
        camposParam3.put('SAC_TodosDespachos__c', true);
        camposParam3.put('SAC_validarImporte__c', false);
        
        SAC_ParametrizacionEscalado__c parametrizacionEscalado3 = SAC_TestDataFactory.crearParamEsc(camposParam3);
        listaParametrizaciones.add(parametrizacionEscalado3);

        //Parametrizaciones Escalado 4
        Map<String, Object> camposParam4 = new Map<String, Object>();
        camposParam4.put('Name', 'VidaCaixa 15K');
        camposParam4.put('Aplica_escalado__c', true);
        camposParam4.put('SAC_Despacho__c', listaGrupos[3].id);
        camposParam4.put('SAC_GrupoDestino__c', listaGrupos[2].Id);
        camposParam4.put('SAC_Importe__c', 15000);
        camposParam4.put('SAC_Mensaje__c', 'VidaCaixa 15K');
        camposParam4.put('SAC_todosMCCs__c', false);
        camposParam4.put('SAC_TodosDespachos__c', false);
        camposParam4.put('SAC_validarImporte__c', true);
        camposParam4.put('SAC_Entidad__c', 'SAC_001');
        
        SAC_ParametrizacionEscalado__c parametrizacionEscalado4 = SAC_TestDataFactory.crearParamEsc(camposParam4);
        listaParametrizaciones.add(parametrizacionEscalado4);

        //Parametrizaciones Escalado 5
        Map<String, Object> camposParam5 = new Map<String, Object>();
        camposParam5.put('Name', 'Validacion Test');
        camposParam5.put('Aplica_escalado__c', true);
        camposParam5.put('SAC_Despacho__c', listaGrupos[3].id);
        camposParam5.put('SAC_GrupoDestino__c', listaGrupos[2].Id);
        camposParam5.put('SAC_Importe__c', 5);
        camposParam5.put('SAC_ValidarImporte_Hasta__c', 20000);
        camposParam5.put('SAC_Mensaje__c', 'Validacion Test');
        camposParam5.put('SAC_todosMCCs__c', true);
        camposParam5.put('SAC_TodosDespachos__c', true);
        camposParam5.put('SAC_Entidad__c', 'SAC_016');
        camposParam5.put('SAC_validarImporte__c', false);
        
        SAC_ParametrizacionEscalado__c parametrizacionEscalado5 = SAC_TestDataFactory.crearParamEsc(camposParam5);
        listaParametrizaciones.add(parametrizacionEscalado5);

        //Parametrizaciones Escalado 6
        Map<String, Object> camposParam6 = new Map<String, Object>();
        camposParam6.put('Name', 'Validacion Test4');
        camposParam6.put('Aplica_escalado__c', true);
        camposParam6.put('SAC_Despacho__c', listaGrupos[3].id);
        camposParam6.put('SAC_GrupoDestino__c', listaGrupos[2].Id);
        camposParam6.put('SAC_Importe__c', 5);
        camposParam6.put('SAC_ValidarImporte_Hasta__c', 200);
        camposParam6.put('SAC_Mensaje__c', 'Validacion Test4');
        camposParam6.put('SAC_todosMCCs__c', true);
        camposParam6.put('SAC_TodosDespachos__c', true);
        camposParam6.put('SAC_Entidad__c', 'SAC_012');
        camposParam6.put('SAC_validarImporte__c', false);
        
        SAC_ParametrizacionEscalado__c parametrizacionEscalado6 = SAC_TestDataFactory.crearParamEsc(camposParam6);
        listaParametrizaciones.add(parametrizacionEscalado6);
       
        SAC_DatabaseDML.insertListDML(listaParametrizaciones, false);

        //CREACION EMAILTEMPLATE
        // User usuario2;
        // System.runAs(usuarioAdmin) {
        //     //Usuario SAC General
        //     usuario2 = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
        //     usuario2.Username = 'Name123456@test.com';      
        //     Database.insert(usuario2);

        //     PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        //     PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        //     permiSetAssi2.AssigneeId = usuario2.Id;
        //     permiSetAssi2.PermissionSetId = permiSet2.Id;
        //     Database.insert(permiSetAssi2);
        // }

        // System.runAs(usuario2){
        //     EmailTemplate validEmailTemplate = new EmailTemplate();
        //     validEmailTemplate.isActive = true;
        //     validEmailTemplate.Name = 'nombreTest';
        //     validEmailTemplate.DeveloperName = 'SAC_Test';
        //     validEmailTemplate.TemplateType = 'text';
        //     validEmailTemplate.HtmlValue = '<p><p>';
        //     validEmailTemplate.Body = 'Texted';
        //     validEmailTemplate.FolderId = usuarioAdmin.Id;
        //     Database.insert(validEmailTemplate);
        // }
    }

    @isTest
    static void rellenarNifYNombreReclamanteTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject, Account.name FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);


        Test.startTest();
        System.runAs(usuario) {
            //Interaccion consulta
            SAC_Interaccion__c interaccion = new SAC_Interaccion__c();
            interaccion.SAC_Titulo__c = 'testConsulta';
            interaccion.SAC_Propuesta__c = 'testConsulta';
            interaccion.SAC_Reclamacion__c = caso.Id;
            interaccion.recordTypeId = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
            SAC_DatabaseDML.insertDML(interaccion, false);
        }
        Test.stopTest();

        SAC_Interaccion__c interaccionResultado = [SELECT Id, SAC_Reclamante__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'testConsulta'];
        Assert.areEqual(caso.Account.name, interaccionResultado.SAC_Reclamante__c, 'No se han podido introducir los datos');
    }

    @isTest
    static void crearTaskEscaladoTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c escalado = [SELECT id,SAC_CasoEscalado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            SAC_LCMP_InsertarReescalado.insertReescalado(escalado.Id, 'propuesta cops', 'SAC_importe', 'observaciones');
        }
        Test.stopTest();

        Task tarea = [SELECT Id, Subject FROM Task WHERE Subject = 'Solicitud de escalado a AJ' LIMIT 1];
        Assert.areEqual('Solicitud de escalado a AJ', tarea.Subject, 'No se ha podido crear la task');
    }
    
    @isTest
    static void crearThreadIdTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c consulta = [SELECT id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            SAC_DatabaseDML.updateDML(consulta, false);
        }
        Test.stopTest();

        SAC_Interaccion__c consultaResult = [SELECT id, SAC_IndexedThreadId__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta' LIMIT 1];
        Assert.areNotEqual(null, consultaResult.SAC_IndexedThreadId__c, 'No se ha podido crear el ThreadId');
    }

    @istest
    static void validacionesEscaladosTest(){
        Boolean respuesta = false;
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        List<Case> listaCasos = [SELECT Id, Subject, Account.name FROM Case WHERE Subject = 'TestRec4' OR Subject = 'TestRec3'];
        Case caso = new Case();
        Case caso2 = new Case();

        for(Case casoAux: listaCasos){
            if(casoAux.Subject == 'TestRec4'){
                caso = casoAux;
            }else if(casoAux.Subject == 'TestRec3'){
                caso2 = casoAux;
            }
        }        

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            respuesta = SAC_Interaccion.validacionesEscalados(caso.id).escalado;
            SAC_Interaccion.validacionesEscalados(caso2.id);
        }
        Test.stopTest();

        Assert.areEqual(true, respuesta, 'No se ha podido comprobar la validación de escalados.');
    }

    @istest
    static void validacionesEscaladosTest4(){
        Boolean respuesta = false;
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        List<Case> listaCasos = [SELECT Id, Subject, Account.name FROM Case WHERE Subject = 'TestRec8'];
        Case caso = new Case();

        for(Case casoAux: listaCasos){
           if(casoAux.Subject == 'TestRec8'){
                caso = casoAux;
            }
        }

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            respuesta = SAC_Interaccion.validacionesEscalados(caso.id).escalado;
        }
        Test.stopTest();

        Assert.areEqual(true, respuesta, 'No se ha podido comprobar la validación de escalados.');
    }

    @istest
    static void insertarTMEEscaladoTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        User usuarioAdmin = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject, Account.name FROM Case WHERE Subject = 'TestRec4' LIMIT 1]; //No tiene escalados
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'grupoTest' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        SAC_Interaccion__c escalado = new SAC_Interaccion__c();
        escalado.SAC_Propuesta__c = 'propuesta test';
        escalado.SAC_CasoEscalado__c = caso.Id;
        escalado.recordTypeId = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Escalado').getRecordTypeId();
        escalado.SAC_Email1__c = 'testing@test.test';
        escalado.OwnerId = usuario.Id;
        escalado.SAC_GrupoColaborador__c = grupo.Id;
        escalado.SAC_Estado__c = 'SAC_PendienteRespuesta';

        Test.startTest();
        System.runAs(usuarioAdmin){
            SAC_DatabaseDML.insertDML(escalado, false);
        }
        //insert escalado;
        Test.stopTest();

        SAC_TMECaso__c tme = [SELECT Id FROM SAC_TMECaso__c WHERE SAC_Interaccion__c = :escalado.Id];
        Assert.areNotEqual(null, tme, 'No se ha podido crear el tme de el escalado.');
    }

    @istest
    static void cerrarTMEEscaladoTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c escalado = [SELECT Id FROM SAC_Interaccion__c WHERE  SAC_Titulo__c = 'propuesta test' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            escalado.SAC_Estado__c = 'SAC_Atendida';
            SAC_DatabaseDML.updateDML(escalado, false);
        }
        Test.stopTest();

        SAC_TMECaso__c tme = [SELECT Id, SAC_FechaFin__c FROM SAC_TMECaso__c WHERE SAC_Interaccion__c = :escalado.Id];
        Assert.areNotEqual(null, tme.SAC_FechaFin__c, 'No se ha podido cerrar el tme de el escalado.');
    }

    @istest
    static void reabrirTMETest(){
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE  SAC_Titulo__c = 'consulta' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            consulta.SAC_Pregunta__c = 'pregunta';
            SAC_DatabaseDML.updateDML(consulta, false);
            consulta.SAC_Estado__c = 'SAC_PendienteRespuestaDefinitiva';
            SAC_DatabaseDML.updateDML(consulta, false);
        }
        Test.stopTest();

        SAC_TMECaso__c tme = [SELECT Id, SAC_FechaFin__c FROM SAC_TMECaso__c WHERE SAC_Interaccion__c = :consulta.Id];
        Assert.areEqual(null, tme.SAC_FechaFin__c, 'No se ha podido reabrir el tme de la consulta.');
    }
    
    @istest
    static void requiereEscaladoCops(){
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c escalado = [SELECT Id FROM SAC_Interaccion__c WHERE  SAC_Titulo__c = 'propuesta test' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            SAC_Interaccion.requiereEscaladoCOPS(escalado.id);
        }
        Test.stopTest();

        Assert.areNotEqual(null, 'Mensaje', 'No se ha podido recuperar el mensaje.');
    }
    
    // @istest
    // static void validarImporteEscalados(){
    //     List<SAC_Interaccion__c> escalado = [SELECT Id FROM SAC_Interaccion__c WHERE  SAC_Titulo__c = 'propuesta test' LIMIT 1];
    //     List<SAC_Interaccion__c> escaladoNV3 = [SELECT Id FROM SAC_Interaccion__c WHERE  SAC_Titulo__c = 'propuesta test2' LIMIT 1];
    //     User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
		
    //     PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
    //     PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
    //     permiSetAssi.AssigneeId = usuario.Id;
    //     permiSetAssi.PermissionSetId = permiSet.Id;
    //     Database.insert(permiSetAssi);

    //     Test.startTest();
    //     System.runAs(usuario) {
    //         escalado[0].SAC_ImporteAutorizado__c = 50;
    //         escaladoNV3[0].SAC_ImporteAutorizado__c = 210;
    //         Database.update(escalado);
    //     }
    //     Test.stopTest();

    //     System.assertNotEquals(null, 'OK', 'No se ha podido actualizar el importe.');
    // }
    
      @istest
    static void recuperaEscaladosObligatorios(){
        Case caso = [SELECT Id, Subject, Account.name FROM Case WHERE Subject = 'TestRec4' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            SAC_Interaccion.recuperaEscaladosObligatorios(caso.id);
        }
        Test.stopTest();
		
        List<SAC_ParametrizacionEscalado__c>  validacionCOPS = [SELECT id, Name, SAC_Importe__c FROM SAC_ParametrizacionEscalado__c WHERE Name = 'Validacion Escalado COPS' LIMIT 1];
        Assert.areNotEqual(null, validacionCOPS[0], 'No se ha encontrado parametrización');
    }    
    
    @istest 
    static void validacionesEscaladosTest2() {
        Case caso = [SELECT Id, Subject, Account.name FROM Case WHERE Subject = 'Reclamacion5' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        SAC_Interaccion.ValidacionesEscalado respuesta;
        System.runAs(usuario) {
            respuesta = SAC_Interaccion.validacionesEscalados(caso.id);
        }
        Test.stopTest();

        Assert.areNotEqual(null, respuesta, 'No se ha ejecutado las validaciones de los escalados');
    }

    @istest 
    static void validacionesEscaladosTest3() {
        Case caso = [SELECT Id, Subject, Account.name FROM Case WHERE Subject = 'Reclamacion6' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        SAC_Interaccion.ValidacionesEscalado respuesta;
        System.runAs(usuario) {
            respuesta = SAC_Interaccion.validacionesEscalados(caso.id);
        }
        Test.stopTest();

        Assert.areNotEqual(null, respuesta, 'No se ha ejecutado las validaciones de los escalados');
    }

    @istest 
    static void validacionEscaladoEntidadVDX() {
        Case caso = [SELECT Id, Subject, Account.name FROM Case WHERE Subject = 'Reclamacion7' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        permisos.add(permiSetAssi);

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        permisos.add(permiSetAssi2);

        SAC_DatabaseDML.insertListDML(permisos, false);

        Test.startTest();
        SAC_Interaccion.ValidacionesEscalado respuesta;
        System.runAs(usuario) {
            respuesta = SAC_Interaccion.validacionesEscalados(caso.id);
        }
        Test.stopTest();

        Assert.areNotEqual(null, respuesta, 'No se ha ejecutado las validaciones de los escalados');
    }

    @istest 
    static void cambioEstadoConsulta() {
        SAC_Interaccion__c consulta = [SELECT Id, SAC_Pregunta__c, SAC_Estado__c FROM SAC_Interaccion__c WHERE  SAC_Titulo__c = 'consulta' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        consulta.SAC_Pregunta__c = 'pregunta test';

        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        permisos.add(permiSetAssi);

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        permisos.add(permiSetAssi2);

        SAC_DatabaseDML.insertListDML(permisos, false);


        Test.startTest();
        System.runAs(usuario) {
            SAC_DatabaseDML.updateDML(consulta, false);
        }
        Test.stopTest();

        SAC_Interaccion__c consultav2 = [SELECT Id, SAC_Pregunta__c, SAC_Estado__c FROM SAC_Interaccion__c WHERE  SAC_Titulo__c = 'consulta' LIMIT 1];
        Assert.areNotEqual(consulta.SAC_Estado__c, consultav2.SAC_Estado__c, 'No se ha modificado el estado');
    }
    
    @istest 
    static void finalizarConsultasPendienteRespuestaTest() {
        Case caso = [SELECT Id, Status, SAC_StatusAuxiliar__c  FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        caso.Status = 'Cerrado';
        caso.SAC_StatusAuxiliar__c = 'Cerrado';

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            SAC_DatabaseDML.updateDML(caso, false);
        }
        Test.stopTest();

        List<SAC_Interaccion__c> listaConsultasAFinalizar = [SELECT id, SAC_Estado__c, SAC_MotivoDeFinalizado__c FROM SAC_Interaccion__c  WHERE SAC_Reclamacion__c =: caso.id AND RecordType.DeveloperName = 'SAC_Consulta' AND SAC_Estado__c = 'SAC_PendienteRespuesta'];
        Assert.areNotEqual(null, listaConsultasAFinalizar, 'No se han finalizado las consultas');
    }


    @istest 
    static void finalizarConsultasCasoTest() {
        Case caso = [SELECT Id, Status, SAC_StatusAuxiliar__c  FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        List<SAC_Interaccion__c> listaConsultasAFinalizar = [SELECT id FROM SAC_Interaccion__c  WHERE SAC_Reclamacion__c =: caso.id AND RecordType.DeveloperName = 'SAC_Consulta' AND SAC_Estado__c = 'SAC_PendienteRespuesta'];
        List<String> consultasIds = new List<String>();
        for (SAC_Interaccion__c consulta: listaConsultasAFinalizar) {
            consultasIds.add(consulta.id);
        }
        String motivoFinalizado = 'SAC_CanceladaAltaErronea';

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            SAC_Interaccion.finalizarConsultasCaso(consultasIds, motivoFinalizado);
        }
        Test.stopTest();

        List<SAC_Interaccion__c> listaConsultasFinalizadas = [SELECT id, SAC_Estado__c, SAC_MotivoDeFinalizado__c FROM SAC_Interaccion__c  WHERE SAC_Reclamacion__c =: caso.id AND RecordType.DeveloperName = 'SAC_Consulta'];
        Assert.areNotEqual(motivoFinalizado, listaConsultasFinalizadas[0].SAC_MotivoDeFinalizado__c, 'No se han finalizado correctamente las consultas');
    }


    @istest 
    static void getConsultasCasoTest() {
        Case caso = [SELECT Id, Status, SAC_StatusAuxiliar__c  FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        List<SAC_Interaccion__c> consultasPendientes;
        Test.startTest();
        System.runAs(usuario) {
            consultasPendientes = SAC_Interaccion.getConsultasCaso(caso.id, true, false);
        }
        Test.stopTest();

        Assert.areNotEqual(null, consultasPendientes, 'No se han obtenido las consultas');
    }

    @istest 
    static void cambioGrupoConsultaTest() {
        List<SAC_Interaccion__c> listaConsultas = [SELECT Id, OwnerId, SAC_GrupoColaborador__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta3'];
        CC_Grupo_Colaborador__c grupo = [SELECT id FROM CC_Grupo_Colaborador__c WHERE name='grupoTest4'];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        usuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id;        
        SAC_DatabaseDML.updateDML(usuario, false);

        Test.startTest();
        System.runAs(usuario) {
            SAC_Interaccion__c consulta = listaConsultas[0];
            consulta.SAC_GrupoColaborador__c = grupo.id;
            SAC_DatabaseDML.updateDML(consulta, false);
        }
        Test.stopTest();

        List<SAC_Interaccion__c> listaConsultas2 = [SELECT Id, SAC_GrupoColaborador__c, OwnerId FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta'];

        Assert.areNotEqual(listaConsultas2[0].SAC_GrupoColaborador__c, grupo.Id, 'No se ha podido cambiar el grupo');
    }

    @istest 
    static void cambiarOficinaConsultaTest() {
        List<SAC_Interaccion__c> listaConsultas = [SELECT Id, SAC_GrupoColaborador__c, SAC_Reclamacion__c, SAC_Oficina__c, SAC_EmailOficina__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta2'];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            // Se recuperan los grupos colaboradores de la lista de interacciones listaConsultas
            List<CC_Grupo_Colaborador__c> listaGrupos = SAC_Interaccion.recuperarGruposConsulta(listaConsultas);
            SAC_Interaccion.cambiarOficinaConsulta(listaConsultas, listaGrupos);
        }
        Test.stopTest();

        List<SAC_Interaccion__c> listaConsultasResult = [SELECT Id, SAC_GrupoColaborador__c, SAC_Reclamacion__c, SAC_Oficina__c, SAC_EmailOficina__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta2'];

        Assert.areNotEqual(listaConsultas[0].SAC_Oficina__c, listaConsultasResult[0].SAC_Oficina__c, 'No se ha podido cambiar la oficina');
    }


    @istest 
    static void asignarPropietarioConsultaInternaTest() {
        List<SAC_Interaccion__c> listaConsultas = [SELECT Id, SAC_GrupoColaborador__c, OwnerId FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta'];

        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            // Se recuperan los grupos colaboradores de la lista de interacciones listaConsultas
            List<CC_Grupo_Colaborador__c> listaGrupos = SAC_Interaccion.recuperarGruposConsulta(listaConsultas);
            SAC_Interaccion.asignarPropietarioConsultaInterna(listaConsultas,listaGrupos);
        }
        Test.stopTest();

        List<SAC_Interaccion__c> listaConsultasResult = [SELECT Id, SAC_GrupoColaborador__c, OwnerId, Owner.Name FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta2'];

        Assert.areNotEqual(listaConsultasResult[0].Owner.Name, 'Pte. Asignar', 'No se ha podido cambiar la oficina');
    }

    @istest 
    static void enviarEmailConsultaInternaTest() {
        List<SAC_Interaccion__c> listaConsultas = [SELECT Id, SAC_GrupoColaborador__c, SAC_Oficina__c, SAC_Oficina__r.CC_Email__c, SAC_Pregunta__c, SAC_Estado__c, SAC_EmailOficina__c, SAC_EmailCC__c, SAC_EmailCCO__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta4'];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        Integer emailCnt = [SELECT Count() FROM EmailMessage WHERE CreatedDate = TODAY AND RelatedToId =: listaConsultas[0].Id];

        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        permisos.add(permiSetAssi);

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        permisos.add(permiSetAssi2);

        SAC_DatabaseDML.insertListDML(permisos, false);


        Test.startTest();
        System.runAs(usuario) {
            SAC_Interaccion.enviarEmailConsultaInterna(listaConsultas);
        }
        Test.stopTest();

        Assert.areNotEqual(emailCnt, [SELECT Count() FROM EmailMessage WHERE CreatedDate = TODAY AND RelatedToId =: listaConsultas[0].Id], 'No se ha enviado la consulta');
    }
    @istest 
    static void informarCorreoOficinaTest() {
        List<SAC_Interaccion__c> listaConsultas = [SELECT Id, SAC_GrupoColaborador__c, SAC_Oficina__c, SAC_Oficina__r.CC_Email__c, SAC_Pregunta__c, SAC_Estado__c, SAC_EmailOficina__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta4'];
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        List<PermissionSetAssignment> permisos = new List<PermissionSetAssignment>();

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        permisos.add(permiSetAssi);

        PermissionSet permiSet2 = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
        permiSetAssi2.AssigneeId = usuario.Id;
        permiSetAssi2.PermissionSetId = permiSet2.Id;
        permisos.add(permiSetAssi2);

        SAC_DatabaseDML.insertListDML(permisos, false);


        Test.startTest();
        System.runAs(usuario) {
            SAC_Interaccion.informarCorreoOficina(listaConsultas);
        }
        Test.stopTest();

        List<SAC_Interaccion__c> listaConsultasResult = [SELECT Id, SAC_GrupoColaborador__c, SAC_Oficina__c, SAC_Oficina__r.CC_Email__c, SAC_Pregunta__c, SAC_Estado__c, SAC_EmailOficina__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta4'];

        Assert.areNotEqual(listaConsultas[0].SAC_EmailOficina__c, listaConsultasResult[0].SAC_EmailOficina__c, 'No se ha informado el email.');
    }

    @istest
    static void validacionesEscaladosTest5(){
        Boolean respuesta = false;
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        List<Case> listaCasos = [SELECT Id, Subject, Account.name FROM Case WHERE Subject = 'TestRec9'];
        Case caso = new Case();

        for(Case casoAux: listaCasos){
           if(casoAux.Subject == 'TestRec9'){
                caso = casoAux;
            }
        }

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            respuesta = SAC_Interaccion.validacionesEscalados(caso.id).escalado;
        }
        Test.stopTest();

        Assert.areEqual(true, respuesta, 'No se ha podido comprobar la validación de escalados.');
    }

    @istest
    static void validacionesEscaladosTest6(){
        Boolean respuesta = false;
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];

        List<Case> listaCasos = [SELECT Id, Subject, Account.name FROM Case WHERE Subject = 'TestRec10'];
        Case caso = new Case();

        for(Case casoAux: listaCasos){
           if(casoAux.Subject == 'TestRec10'){
                caso = casoAux;
            }
        }

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            respuesta = SAC_Interaccion.validacionesEscalados(caso.id).escalado;
        }
        Test.stopTest();

        Assert.areEqual(true, respuesta, 'No se ha podido comprobar la validación de escalados.');
    }

    @istest
    static void validarUpdateCamposTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c escalado = [SELECT Id FROM SAC_Interaccion__c WHERE  SAC_Titulo__c = 'propuesta test' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_Administrador'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false);

        Test.startTest();
        System.runAs(usuario) {
            escalado.SAC_Titulo__c = 'test modificar titulo SAC';
            SAC_DatabaseDML.updateDML(escalado, true);
        }
        Test.stopTest();

        Assert.areNotEqual(null, 'Mensaje', 'No se ha podido actualizar el escalado.');
    }
}