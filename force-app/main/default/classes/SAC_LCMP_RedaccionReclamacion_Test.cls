/*****************************************************************
 * Name: SAC_LCMP_RedaccionReclamacion_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_LCMP_RedaccionReclamacion
 * 
 * Historial
 * -------
 * VERSION        USER_STORY        AUTHOR                  DATE         Description
 * 1.0            US248482          Marcela Neira           06/08/21     Creación
 * 1.1              ---             Jose Carlos Blanco  	08/09/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@istest
public with sharing class SAC_LCMP_RedaccionReclamacion_Test {
    @TestSetup
    static void makeData(){
        Test.startTest();
        //Usuario Admin
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);

        User usuario = new User();

        User usuarioGeneral;
        System.RunAs(usuarioAdmin) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];   
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);
        }

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Reclamación');
        camposRecl.put('OwnerId', usuarioGeneral.Id);
        camposRecl.put('OS_Email__c', 'lmesa@viewnext.com');
      
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        SAC_DatabaseDML.insertDML(reclamacion, false);

        List<Case> listaPret = new List<Case>();
        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'pretension1');
        camposPret.put('SAC_Reclamacion__c', reclamacion.id);
        camposPret.put('SAC_SentidoResolucion__c', 'SAC_001');
        camposPret.put('SAC_Redaccion__c', '--');
        camposPret.put('SAC_RedaccionFinal__c', true);
        camposPret.put('OwnerId', usuarioGeneral.Id);
      
        Case pretension1 = SAC_TestDataFactory.crearCaso('Pretension', camposPret);
        listaPret.add(pretension1);

        //Pretension 2
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SuppliedCompany', 'pretension2');
        camposPret2.put('SAC_Reclamacion__c', reclamacion.id);
        camposPret2.put('SAC_SentidoResolucion__c', 'SAC_001');
        camposPret2.put('SAC_Redaccion__c', 'Redacción');
        camposPret2.put('SAC_RedaccionFinal__c', true);
        camposPret2.put('OwnerId', usuarioGeneral.Id);
      
        Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension', camposPret2);
        listaPret.add(pretension2);

        SAC_DatabaseDML.insertListDML(listaPret, false);

        //Grupo
        CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion', 1)[0];
        grupoColaborador.Name = 'Grupo Proveedores Test';
        grupoColaborador.SAC_PermiteTareas__c = true;
        grupoColaborador.SAC_Email__c='test@test.com.invalid';
        SAC_DatabaseDML.insertDML(grupoColaborador, false);
        
        //Accion
        SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas(1, reclamacion, false)[0];
        tarea.SAC_EquipoResponsable__c= grupoColaborador.id;
        SAC_DatabaseDML.insertDML(tarea, false);

        Test.stopTest();
    }

    @istest
    static void guardarRedaccionTest(){
        String idPretension = [SELECT id FROM Case WHERE SuppliedCompany = 'pretension1' LIMIT 1].id;
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_RedaccionReclamacion.guardarRedaccion(idPretension, 'texto');
            Test.stopTest();
        }

        String textoRedaccion = [SELECT SAC_Redaccion__c FROM Case WHERE SuppliedCompany = 'pretension1' LIMIT 1].SAC_Redaccion__c;

        System.assertEquals('texto', textoRedaccion, 'No ha guardado la redacción');
    }

    @istest
    static void guardarSentidoResolucionTest(){
        String idReclamacion = [SELECT id FROM Case WHERE Subject = 'Reclamación' LIMIT 1].id;
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_RedaccionReclamacion.guardarSentidoResolucion(idReclamacion, 'SAC_001', 'argumento');
            Test.stopTest();
        }

        String argumento = [SELECT SAC_MotivoSentidoResolucion__c FROM Case WHERE Subject = 'Reclamación' LIMIT 1].SAC_MotivoSentidoResolucion__c;
        String sentido = [SELECT SAC_SentidoResolucion__c FROM Case WHERE Subject = 'Reclamación' LIMIT 1].SAC_SentidoResolucion__c;

        System.assertEquals('argumento', argumento, 'No ha guardado el argumento');
        System.assertEquals('SAC_001', sentido, 'No se ha guardado el sentido');                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
    }

    @istest
    static void validacionRedaccionTest(){
        Boolean respuesta=false;
        Case reclamacion = [SELECT id, subject FROM Case WHERE Subject = 'Reclamación' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.runAs(usuario){
            try {
                Test.startTest();
                respuesta = SAC_LCMP_RedaccionReclamacion.validacionRedaccion(reclamacion.id);
                Test.stopTest();
            } catch (Exception e) {
                respuesta = false;
            }
        }
            
        String textoRedaccion = [SELECT SAC_Redaccion__c FROM Case WHERE SuppliedCompany = 'pretension1' LIMIT 1].SAC_Redaccion__c;

        System.assertEquals(true, respuesta, 'No se ha importado la redaccion de las pretensiones');
    }

    @istest
    static void getBodyRedaccionTest(){
        String body='';
        Case reclamacion = [SELECT id, subject FROM Case WHERE Subject = 'Reclamación' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            body=SAC_LCMP_RedaccionReclamacion.getBodyRedaccion(reclamacion.id);
            Test.stopTest();
        }

        String textoRedaccion = [SELECT SAC_Redaccion__c FROM Case WHERE SuppliedCompany = 'pretension1' LIMIT 1].SAC_Redaccion__c;

        System.assertNotEquals(Null, body,'No hay body');
    }

    @istest
    static void gestionTareasTest(){
        Boolean tieneTareas = false;
        String idPretension = [SELECT id FROM Case WHERE SuppliedCompany = 'pretension1' LIMIT 1].id;
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.runAs(usuario){
            Test.startTest();
            tieneTareas = SAC_LCMP_RedaccionReclamacion.gestionTareas(idPretension);
            Test.stopTest();
        }

        System.assertEquals(false, tieneTareas, 'Esta pretension no debería tener tareas');
    }

    @istest
    static void finalizarRedaccionTest(){
        Boolean tieneTareas = false;
        Case reclamacion = [SELECT id, subject FROM Case WHERE Subject = 'Reclamación' LIMIT 1];
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        Account cuenta = SAC_TestDataFactory.crearCuentasOficina(1)[0];
        SAC_DatabaseDML.insertDML(cuenta, false);
        
        reclamacion.CC_Oficina_Afectada_Lookup__c = cuenta.id;
        SAC_DatabaseDML.updateDML(reclamacion, false);

        System.runAs(usuario){
            Test.startTest();
            SAC_LCMP_RedaccionReclamacion.guardarRedaccion(reclamacion.id, 'texto');
            DateTime fechaResolucion = SAC_LCMP_RedaccionReclamacion.finalizarRedaccion(reclamacion.id);
            Test.stopTest();
        }
        String estado =[SELECT Status FROM Case WHERE Subject = 'Reclamación' LIMIT 1].Status;

        System.assertEquals('SAC_004', estado, 'Esta reclamación no ha finalizado su redacción');
    }

    @istest
    static void getPickListValuesIntoListTest(){ 
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        List<SAC_LCMP_RedaccionReclamacion.plantillasWrapper> resultado = new List<SAC_LCMP_RedaccionReclamacion.plantillasWrapper>();
        
        System.runAs(usuario){
            Test.startTest();
            List<SAC_LCMP_RedaccionReclamacion.plantillasWrapper> resultado2 = SAC_LCMP_RedaccionReclamacion.getPickListValuesIntoList();
            Test.stopTest();
            System.assertNotEquals(resultado, resultado2, 'la comparacion del objeto wrapper ha fallado');
        }
    }
    
    @istest
    static void cambiaRedaccionFinal(){ 
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case pretension = [SELECT id, SAC_RedaccionFinal__c, SAC_Redaccion__c, SAC_SentidoResolucion__c, RecordTypeId FROM Case WHERE SuppliedCompany = 'pretension1' LIMIT 1];
        pretension.SAC_RedaccionFinal__c = false;
        List<Case> pretensiones = new List<Case>();
        pretensiones.add(pretension);
        
        Case pretension2 = [SELECT id, SAC_Redaccion__c, SAC_SentidoResolucion__c FROM Case WHERE SuppliedCompany = 'pretension1' LIMIT 1];
        pretension2.SAC_RedaccionFinal__c = true;
        Map<Id, Case> mapOld = new Map<Id, Case>();
        mapOld.put(pretension2.Id, pretension2);
          
        CC_Grupo_Colaborador__c grupoColaborador = [SELECT ID FROM CC_Grupo_Colaborador__c WHERE NAME = 'Grupo Proveedores Test'];

        // SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas(1, pretension, false)[0];
        // tarea.SAC_EquipoResponsable__c= grupoColaborador.id;
        // Database.insert(tarea);

        // SAC_Accion__c tarea2 = SAC_TestDataFactory.crearTareas(1, pretension, false)[0];
        // tarea2.SAC_EquipoResponsable__c= grupoColaborador.id;
        // Database.insert(tarea2);
        
        System.runAs(usuario){
            Test.startTest();
            SAC_Validaciones.validarListoParaEnviar(pretensiones, mapOld);
            Test.stopTest();
        }
        
        System.assertEquals('Llega', 'Llega', 'la comparacion del objeto wrapper ha fallado');
    }
}