/*********************************************************************************************************
 * Name: SPV_TestDataFactory_Test
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Test de SPV_TestDataFactory
 * 
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0               ---             Raúl Santos          29/04/24             Creación
**********************************************************************************************************/

@isTest
public with sharing class SPV_TestDataFactory_Test {

    @TestSetup
    static void makeData(){
        
        Test.startTest();
        //Usuario
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);
        Test.stopTest();
    }
    
    @isTest
    static void crearTestData(){
        Map<String, Object> camposCaso = new Map<String, Object>();
        camposCaso.put('Subject', 'Test Subject');
        camposCaso.put('Status', 'SAC_001');
        camposCaso.put('Description', 'Test Description');

        Map<String, Object> camposEscalado = new Map<String, Object>();
        camposEscalado.put('SAC_Titulo__c', 'Test Titulo');
        camposEscalado.put('SAC_Email1__c', 'testescalado@testData.setup');

        User usuarioAdmin = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.runAs(usuarioAdmin){

            Test.startTest();
            List<User> listUsuarios = SPV_TestDataFactory.crearUsuarioSPVGeneral(1);
            Database.insert(listUsuarios);
            System.assertEquals(1, listUsuarios.size(), 'No se han creado el usuario.');

            List<User> listUsuariosAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1);
            listUsuariosAdmin[0].Username = 'useradmintestcreadotest@testSPV.com.testSetup';
            Database.insert(listUsuariosAdmin);
            System.assertEquals(1, listUsuariosAdmin.size(), 'No se han creado el usuario admin.');

            List<CC_Grupo_Colaborador__c> listGrupoGestor = SPV_TestDataFactory.crearGrupoColaborador('GrupoGestor',1);
            List<CC_Grupo_Colaborador__c> listGrupoLetrado = SPV_TestDataFactory.crearGrupoColaborador('GrupoLetrado',1);
            List<CC_Grupo_Colaborador__c> listGrupoDeTareas = SPV_TestDataFactory.crearGrupoColaborador('GrupoDeTareas',1);
            listGrupoDeTareas[0].SAC_PermiteTareas__c = true;
            Database.insert(listGrupoGestor);
            Database.insert(listGrupoLetrado);
            Database.insert(listGrupoDeTareas);
            System.assertEquals(1, listGrupoGestor.size(), 'No se ha creado el grupo gestor.');
            System.assertEquals(1, listGrupoLetrado.size(), 'No se ha creado el grupo letrado.');
            System.assertEquals(1, listGrupoDeTareas.size(), 'No se ha creado el grupo de tareas.');

            CC_Grupo_Colaborador_Contact__c colaborador = SPV_TestDataFactory.crearColaboradorContact(listUsuarios[0].id, listGrupoGestor[0].id);
            Database.insert(colaborador);
            System.assertNotEquals(null, colaborador.id, 'No se ha creado el colaborador.');

            Case reclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposCaso);
            Case pretension = SPV_TestDataFactory.crearCaso('Pretension', camposCaso);
            Database.insert(reclamacion);
            Database.insert(pretension);
            System.assertNotEquals(null, reclamacion.id, 'No se ha creado la reclamacion.');
            System.assertNotEquals(null, pretension.id, 'No se ha creado la pretension.');

            SAC_Interaccion__c escaladoInteraccion = SPV_TestDataFactory.crearInteraccion('Escalado', camposEscalado);
            Database.insert(escaladoInteraccion);
            System.assertNotEquals(null, escaladoInteraccion.id, 'No se ha creado el escalado.');

            List<SAC_Accion__c> tareasRec = SPV_TestDataFactory.crearTareas(1, reclamacion, null);
            List<SAC_Accion__c> tareasPret = SPV_TestDataFactory.crearTareas(1, reclamacion, pretension);
            Database.insert(tareasRec);
            Database.insert(tareasPret);
            System.assertNotEquals(null, tareasRec[0].Id, 'No se ha creado la tarea de la reclamacion.');
            System.assertNotEquals(null, tareasPret[0].Id, 'No se ha creado la tarea de la pretension.');

            List<SAC_MaestroAccionesReclamacion__c> maestroAccion = SPV_TestDataFactory.crearMaestroAcciones(1, listGrupoDeTareas[0].id);
            Database.insert(maestroAccion);
            System.assertNotEquals(null, maestroAccion[0].id, 'No se ha creado el maestro de acciones.');

            List<Account> cuentas = SPV_TestDataFactory.crearCuentas(2);
            List<Account> cuentasPA = SPV_TestDataFactory.crearCuentasNoClientePA(2);
            Database.insert(cuentas);
            Database.insert(cuentasPA);
            System.assertEquals(2, cuentas.size(), 'No se han creado las dos cuentas.');
            System.assertEquals(2, cuentasPA.size(), 'No se han creado las dos cuentas.');

            SAC_CaseReclamante__c reclamanteReclPrin = SPV_TestDataFactory.crearReclamante(true, reclamacion, cuentas[0].id);
            SAC_CaseReclamante__c reclamanteReclSec = SPV_TestDataFactory.crearReclamante(false, reclamacion, cuentas[0].id);
            SAC_CaseReclamante__c reclamantePretPrin = SPV_TestDataFactory.crearReclamante(true, pretension, cuentas[0].id);
            SAC_CaseReclamante__c reclamantePretSec = SPV_TestDataFactory.crearReclamante(false, pretension, cuentas[0].id);
            Database.insert(reclamanteReclPrin);
            Database.insert(reclamanteReclSec);
            Database.insert(reclamantePretPrin);
            Database.insert(reclamantePretSec);
            System.assertNotEquals(null, reclamanteReclPrin.id, 'No se ha creado el reclamante principal de la reclamación.');
            System.assertNotEquals(null, reclamanteReclSec.id, 'No se ha creado el reclamante secundario de la reclamación.');
            System.assertNotEquals(null, reclamantePretPrin.id, 'No se ha creado el reclamante principal de la pretension.');
            System.assertNotEquals(null, reclamantePretSec.id, 'No se ha creado el reclamante secundario de la pretension.');

            List<Contact> contacto = SPV_TestDataFactory.crearContacto(1, cuentas[0].id);
            List<Contact> contactoDos = SPV_TestDataFactory.crearContacto(2, cuentas[0].id);
            System.assertEquals(1, contacto.size(), 'No se ha creado el contacto.');
            System.assertEquals(2, contactoDos.size(), 'No se han creado los dos contactos.');
            System.assertNotEquals(null, contacto[0].AccountId, 'No se ha asignado el contacto a la cuenta.');
            System.assertNotEquals(null, contactoDos[0].AccountId, 'No se ha asignado el contacto a la cuenta.');

            Test.stopTest();
        }
    }
}