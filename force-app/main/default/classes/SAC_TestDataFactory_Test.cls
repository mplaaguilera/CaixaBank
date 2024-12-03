/*****************************************************************
 * Name: SAC_TestDataFactory_Test
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Testear la clase SAC_TestDataFactory.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US535374         Jose Carlos Blanco   17/03/23     Creación
*****************************************************************/
@isTest
public with sharing class SAC_TestDataFactory_Test {
    @isTest
    static void crearTestData(){
        Map<String, Object> camposCaso = new Map<String, Object>();
        camposCaso.put('Subject', 'Test Subject');
        camposCaso.put('Status', 'SAC_001');
        camposCaso.put('Description', 'Test Description');

        User usuario = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            List<User> usuariosDos = SAC_TestDataFactory.crearUsuarioSACGeneral(2);
            List<User> usuariosTres = SAC_TestDataFactory.crearUsuarioSACGeneral(3);
            List<User> usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1);
            Database.insert(usuariosDos);
            System.assertEquals(2, usuariosDos.size(), 'No se han creado los dos usuarios.');
            System.assertEquals(3, usuariosTres.size(), 'No se han creado los tres usuarios.');
            System.assertEquals(1, usuarioAdmin.size(), 'No se han creado el usuario admin.');

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposCaso);
            Case pretension = SAC_TestDataFactory.crearCaso('Pretension', camposCaso);
            Case consulta = SAC_TestDataFactory.crearCaso('Consulta', camposCaso);
            Database.insert(reclamacion);
            Database.insert(pretension);
            Database.insert(consulta);
            System.assertNotEquals(null, reclamacion.id, 'No se ha creado la reclamacion.');
            System.assertNotEquals(null, pretension.id, 'No se ha creado la pretension.');
            System.assertNotEquals(null, consulta.id, 'No se ha creado la consulta.');


            List<Case> reclamacionesDos = SAC_TestDataFactory.crearReclamacion(2);
            List<Case> reclamacionesTres = SAC_TestDataFactory.crearReclamacion(3);
            List<Case> consultasDos = SAC_TestDataFactory.crearConsulta(2);
            List<Case> consultasTres = SAC_TestDataFactory.crearConsulta(3);
            List<Case> pretensiones = SAC_TestDataFactory.crearPretension(2,reclamacion.id);
            List<Account> cuentas = SAC_TestDataFactory.crearCuentas(2);
            List<Account> cuentasPA = SAC_TestDataFactory.crearCuentasNoClientePA(2);
            List<Account> cuentasOficina = SAC_TestDataFactory.crearCuentasOficina(2);
            Database.insert(cuentas);
            System.assertEquals(2, reclamacionesDos.size(), 'No se han creado las dos reclamaciones.');
            System.assertEquals(3, reclamacionesTres.size(), 'No se han creado las tres reclamaciones.');
            System.assertEquals(2, consultasDos.size(), 'No se han creado las dos consultas.');
            System.assertEquals(3, consultasTres.size(), 'No se han creado las tres consultas.');
            System.assertEquals(2, pretensiones.size(), 'No se han creado las dos pretensiones.');
            System.assertNotEquals(null, pretensiones[0].SAC_Reclamacion__c, 'No se ha asignado la pretension al caso.');
            System.assertNotEquals(null, pretensiones[1].SAC_Reclamacion__c, 'No se ha asignado la pretension al caso.');
            System.assertEquals(2, cuentas.size(), 'No se han creado las dos cuentas.');
            System.assertEquals(2, cuentasPA.size(), 'No se han creado las dos cuentas.');
            System.assertEquals(2, cuentasOficina.size(), 'No se han creado las dos cuentas oficina.');

            SAC_CaseReclamante__c reclamanteReclPrin = SAC_TestDataFactory.crearReclamante(true, reclamacion, cuentas[0].id);
            SAC_CaseReclamante__c reclamanteReclSec = SAC_TestDataFactory.crearReclamante(false, reclamacion, cuentas[0].id);
            SAC_CaseReclamante__c reclamantePretPrin = SAC_TestDataFactory.crearReclamante(true, pretension, cuentas[0].id);
            SAC_CaseReclamante__c reclamantePretSec = SAC_TestDataFactory.crearReclamante(false, pretension, cuentas[0].id);
            Database.insert(reclamanteReclPrin);
            Database.insert(reclamanteReclSec);
            Database.insert(reclamantePretPrin);
            Database.insert(reclamantePretSec);
            System.assertNotEquals(null, reclamanteReclPrin.id, 'No se ha creado el reclamante principal de la reclamación.');
            System.assertNotEquals(null, reclamanteReclSec.id, 'No se ha creado el reclamante secundario de la reclamación.');
            System.assertNotEquals(null, reclamantePretPrin.id, 'No se ha creado el reclamante principal de la pretension.');
            System.assertNotEquals(null, reclamantePretSec.id, 'No se ha creado el reclamante secundario de la pretension.');

            List<SAC_Accion__c> tareasMaestroRec = SAC_TestDataFactory.crearTareas(2, reclamacion, true);
            List<SAC_Accion__c> tareasOtrasRec = SAC_TestDataFactory.crearTareas(5, reclamacion, false);
            List<SAC_Accion__c> tareasMaestroPret = SAC_TestDataFactory.crearTareas(2, pretension, true);
            List<SAC_Accion__c> tareasOtrasPret = SAC_TestDataFactory.crearTareas(5, pretension, false);
            System.assertEquals(2, tareasMaestroRec.size(), 'No se han creado las dos tareas.');
            System.assertEquals(5, tareasOtrasRec.size(), 'No se han creado las cinco tareas.');
            System.assertNotEquals(null, tareasMaestroRec[0].SAC_Reclamacion__c, 'No se ha asignado la tarea a la reclamación.');
            System.assertNotEquals(null, tareasOtrasRec[0].SAC_Reclamacion__c, 'No se ha asignado la tarea a la reclamación.');
            System.assertEquals(2, tareasMaestroPret.size(), 'No se han creado las dos tareas.');
            System.assertEquals(5, tareasOtrasPret.size(), 'No se han creado las cinco tareas.');
            System.assertNotEquals(null, tareasMaestroPret[0].SAC_Pretension__c, 'No se ha asignado la tarea a la pretensión.');
            System.assertNotEquals(null, tareasOtrasPret[0].SAC_Pretension__c, 'No se ha asignado la tarea a la pretensión.');

            List<SAC_Alerta__c> alertas = SAC_TestDataFactory.crearAlerta(3, reclamacion.id);
            System.assertEquals(3, alertas.size(), 'No se han creado las tres alertas.');
            System.assertNotEquals(null, alertas[0].SAC_Reclamacion__c, 'No se ha asignado la alerta a la reclamación.');
            Test.stopTest();
        }     
    } 
    @isTest
    static void crearTestData2(){
        User usuario = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            List<User> usuariosDos = SAC_TestDataFactory.crearUsuarioSACGeneral(2);
            List<User> usuariosTres = SAC_TestDataFactory.crearUsuarioSACGeneral(3);
            Database.insert(usuariosDos);
            System.assertEquals(2, usuariosDos.size(), 'No se han creado los dos usuarios.');
            System.assertEquals(3, usuariosTres.size(), 'No se han creado los tres usuarios.');
            List<Group> gruposDos = SAC_TestDataFactory.crearGrupo(2);
            List<Group> gruposTres = SAC_TestDataFactory.crearGrupo(3);
            System.assertEquals(2, gruposDos.size(), 'No se han creado los dos grupos.');
            System.assertEquals(3, gruposTres.size(), 'No se han creado los tres grupos.');

            List<CC_Grupo_Colaborador__c> grupoRespAccion = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',2);
            List<CC_Grupo_Colaborador__c> grupoProv = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',3);
            List<CC_Grupo_Colaborador__c> grupoLet = SAC_TestDataFactory.crearGrupoColaborador('GrupoLetrados',5);
            Database.insert(grupoRespAccion);
            Database.insert(grupoProv);
            Database.insert(grupoLet);
            System.assertEquals(2, grupoRespAccion.size(), 'No se han creado los dos grupos.');
            System.assertEquals(3, grupoProv.size(), 'No se han creado los tres grupos.');
            System.assertEquals(5, grupoLet.size(), 'No se han creado los cinco grupos.');

            CC_Grupo_Colaborador_Contact__c contactRespAccion = SAC_TestDataFactory.crearColaboradorContact(usuariosDos[0].id, grupoRespAccion[0].id);
            CC_Grupo_Colaborador_Contact__c contactProv = SAC_TestDataFactory.crearColaboradorContact(usuariosDos[0].id, grupoProv[0].id);
            CC_Grupo_Colaborador_Contact__c contactLet = SAC_TestDataFactory.crearColaboradorContact(usuariosDos[0].id, grupoLet[0].id);
            Database.insert(contactRespAccion);
            Database.insert(contactProv);
            Database.insert(contactLet);
            System.assertNotEquals(null, contactRespAccion.id, 'No se ha creado el contacto para el grupo Responsable Acción.');
            System.assertNotEquals(null, contactProv.id, 'No se ha creado el contacto para el grupo Proveedores.');
            System.assertNotEquals(null, contactLet.id, 'No se ha creado el contacto para el grupo Letrados.');

            
            Test.stopTest();
        }
    }
    @isTest
    static void crearContactosTest(){
        User usuario = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            List<Account> cuentas = SAC_TestDataFactory.crearCuentas(2);
            Database.insert(cuentas);
            System.assertEquals(2, cuentas.size(), 'No se han creado las dos cuentas.');
            
            List<Contact> contacto = SAC_TestDataFactory.crearContacto(1, cuentas[0].id);
            List<Contact> contactoDos = SAC_TestDataFactory.crearContacto(2, cuentas[0].id);
            System.assertEquals(1, contacto.size(), 'No se ha creado el contacto.');
            System.assertEquals(2, contactoDos.size(), 'No se han creado los dos contactos.');
            System.assertNotEquals(null, contacto[0].AccountId, 'No se ha asignado el contacto a la cuenta.');
            System.assertNotEquals(null, contactoDos[0].AccountId, 'No se ha asignado el contacto a la cuenta.');
            Test.stopTest();
        }
    }
    @isTest
    static void crearMCCsTest(){
        User usuario = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            List<CC_MCC__c> mccs = SAC_TestDataFactory.crearMCCs();
            System.assertEquals(false, mccs.isEmpty(), 'No se han creado los MCCs.');
            Test.stopTest();  
        }
    }
    @isTest
    static void crearSLAsTest(){
        User usuario = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_ParametrizacionSLATME__c> slaTme = SAC_TestDataFactory.crearParamsSla('TME',2);
            List<SAC_ParametrizacionSLATME__c> slaReg = SAC_TestDataFactory.crearParamsSla('Regulatorio',3);
            List<SAC_ParametrizacionSLATME__c> slaLet = SAC_TestDataFactory.crearParamsSla('Letrado',4);
            System.assertEquals(false, slaTme.isEmpty(), 'No se han creado los SLAs.');
            System.assertEquals(false, slaReg.isEmpty(), 'No se han creado los SLAs.');
            System.assertEquals(false, slaLet.isEmpty(), 'No se han creado los SLAs.');
            Test.stopTest();
        }
    }
    @isTest
    static void crearEntitlementTest(){
        User usuario = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
            Database.insert(cuenta);

            Entitlement entitle = SAC_TestDataFactory.crearEntitlement(cuenta.id);
            System.assertEquals(cuenta.id, entitle.AccountId, 'No se ha creado correctamente el entitlement.');
            Test.stopTest();
        }
    }
    @isTest
    static void crearDocumentoEnvioTest(){
        User usuario = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            Map<String, Object> camposCaso = new Map<String, Object>();
            camposCaso.put('Subject', 'Test Subject');
            camposCaso.put('Status', 'SAC_001');
            camposCaso.put('Description', 'Test Description');
            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposCaso);
            Database.insert(reclamacion);


            List<SAC_DocumentoEnvio__c> docs = SAC_TestDataFactory.crearDocumentoEnvio(2, reclamacion);
            List<SAC_DocumentoEnvio__c> docs2 = SAC_TestDataFactory.crearDocumentoEnvio(4, reclamacion);
            System.assertEquals(2, docs.size(), 'No se han creado los dos documentos.');
            System.assertEquals(4, docs2.size(), 'No se han creado los cuatro documentos.');
            System.assertEquals(reclamacion.id, docs[1].SAC_Caso__c, 'No se ha asignado correctamente el caso.');
            System.assertEquals(reclamacion.id, docs2[3].SAC_Caso__c, 'No se ha asignado correctamente el caso.');
            Test.stopTest();
        }
    }
    @isTest
    static void clasificacionesReglasMultivaloresTest(){
        User usuario = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            Map<String, Object> camposClasR = new Map<String, Object>();
            camposClasR.put('Name', 'CRTest');
            camposClasR.put('SAC_Target__c', 'SAC_Reclamacion');
            camposClasR.put('SEG_Inactiva__c', false);
            camposClasR.put('OS_EstadoCaso__c', 'Rechazado');
            camposClasR.put('SAC_MotivoRechazo__c', 'Spam');
            camposClasR.put('SAC_MotivoDescarte__c', 'SAC_Otros');

            Map<String, Object> camposReglas = new Map<String, Object>();
            camposReglas.put('Name', 'RCTest');
            camposReglas.put('SEG_Inactiva__c', false);
            camposReglas.put('OS_Logica_Multivalor__c', 'OR');
            camposReglas.put('OS_OrdenEjecucion__c', 1);
            
            SEG_ClasificacionRapida__c clasR = SAC_TestDataFactory.crearClasificacionRapida(camposClasR);
            Database.insert(clasR);
            
            SEG_Regladeclasificacion__c reglas = SAC_TestDataFactory.crearReglasClasificacion(clasR.id, camposReglas);
            Database.insert(reglas);

            List<SEG_Multivalor__c> multivalores = SAC_TestDataFactory.crearMultivalor(2, reglas.id, 'Remitente');
            List<SEG_Multivalor__c> multivalores2 = SAC_TestDataFactory.crearMultivalor(4, reglas.id, 'Destinatario a excluir');

            System.assertNotEquals(null, clasR.id, 'No se ha creado la clasificación rápida.');
            System.assertEquals('CRTest', clasR.Name, 'No se han asignado los campos de la clasificación.');
            System.assertNotEquals(null, reglas.id, 'No se han creado las reglas.');
            System.assertEquals('RCTest', reglas.Name, 'No se han asignado los campos de las reglas.');
            System.assertEquals(2, multivalores.size(), 'No se han creado los dos multivalores.');
            System.assertEquals(4, multivalores2.size(), 'No se han creado los cuatro multivalores.');
            System.assertEquals(reglas.id, multivalores[1].SEG_Reglas_Clasificacion__c, 'No se ha asignado correctamente las reglas.');
            System.assertEquals(reglas.id, multivalores2[3].SEG_Reglas_Clasificacion__c, 'No se ha asignado correctamente las reglas.');
            Test.stopTest();
        }
    } 
    
    @isTest
    static void crearMaestroTemasTest(){

        User usuario = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_MaestroTemas__c> listMaestroTemas = SAC_TestDataFactory.crearMaestroTemas(1, 'SAC_TipoAdjuntos');
            System.assertNotEquals(0, listMaestroTemas.size(), 'No se han creado correctamente el maestro.');
            Test.stopTest();
        }
    }

    @isTest
    static void crearMaestroTemasTest2(){

        User usuario = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_MaestroTemas__c> listMaestroTemas = SAC_TestDataFactory.crearMaestroTemas(1, 'SAC_InformacionCualitativa');
            System.assertNotEquals(0, listMaestroTemas.size(), 'No se han creado correctamente el maestro.');
            Test.stopTest();
        }
    }

    @isTest
    static void crearMaestroTemasTest3(){

        User usuario = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            List<SAC_MaestroTemas__c> listMaestroTemas = SAC_TestDataFactory.crearMaestroTemas(1, 'SAC_Temas');
            System.assertNotEquals(0, listMaestroTemas.size(), 'No se han creado correctamente el maestro.');
            Test.stopTest();
        }
    }

    @isTest
    static void crearContentVersionTest(){

        User usuario = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            Map<String, Object> camposCaso = new Map<String, Object>();
            camposCaso.put('Subject', 'Test Subject');
            camposCaso.put('Status', 'SAC_001');
            camposCaso.put('Description', 'Test Description');
            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposCaso);
            Database.insert(reclamacion);

            ContentVersion cv = SAC_TestDataFactory.crearContentVersion(reclamacion);
            System.assertNotEquals(null, cv.Title, 'No se han creado correctamente el content version.');
            Test.stopTest();
        }
    }

    @isTest
    static void crearMaestroAccionesTest(){

        User usuario = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            List<CC_Grupo_Colaborador__c> grupoRespAccion = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1);
            Database.insert(grupoRespAccion);

            List<SAC_MaestroAccionesReclamacion__c> listMaestroAcciones = SAC_TestDataFactory.crearMaestroAcciones(1, grupoRespAccion[0].Id);
            System.assertNotEquals(0, listMaestroAcciones.size(), 'No se han creado correctamente el maestro.');
            Test.stopTest();
        }
    } 

    @isTest
    static void crearInteraccionTest(){
        Map<String, Object> camposInteraccion = new Map<String, Object>();
        camposInteraccion.put('SAC_Titulo__c', 'Test Titulo');

        Map<String, Object> camposEscalado = new Map<String, Object>();
        camposEscalado.put('SAC_Titulo__c', 'Test Titulo');
        camposEscalado.put('SAC_Email1__c', 'testescalado@testData.setup');

        User usuario = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
        System.runAs(usuario){
            Test.startTest();
            SAC_Interaccion__c consultaInteraccion = SAC_TestDataFactory.crearInteraccion('Consulta', camposInteraccion);
            Database.insert(consultaInteraccion);

            SAC_Interaccion__c escaladoInteraccion = SAC_TestDataFactory.crearInteraccion('Escalado', camposEscalado);
            Database.insert(escaladoInteraccion);

            SAC_Interaccion__c escaladonv3Interaccion = SAC_TestDataFactory.crearInteraccion('EscaladoNV3', camposEscalado);
            Database.insert(escaladonv3Interaccion);

            System.assertNotEquals(null, consultaInteraccion.id, 'No se ha creado la consulta.');
            System.assertNotEquals(null, escaladoInteraccion.id, 'No se ha creado el escalado.');
            System.assertNotEquals(null, escaladonv3Interaccion.id, 'No se ha creado el escalado.');
            Test.stopTest();
        }
    }
}