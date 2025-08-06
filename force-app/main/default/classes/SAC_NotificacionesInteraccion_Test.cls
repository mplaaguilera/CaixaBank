/*****************************************************************
 * Name: SAC_NotificacionesInteraccion_Test
 * Copyright © 2021  CaixaBank
 *
 * Proposito: Testear la clase SAC_NotificacionesInteraccion
 *
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US219272         Carlos Solis         24/08/21     Creación
 * 1.1            US643756         Jose Carlos Blanco   05/07/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@isTest
public with sharing class SAC_NotificacionesInteraccion_Test {
    @TestSetup
    static void makeData(){

        User usuarioGeneral;
          System.runAs(new User(Id = Userinfo.getUserId())) {
               //Usuario SAC General
               usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];    
               SAC_DatabaseDML.insertDML(usuarioGeneral, false);   
               //Database.insert(usuarioGeneral);

               PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
               PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
               permiSetAssi.AssigneeId = usuarioGeneral.Id;
               permiSetAssi.PermissionSetId = permiSet.Id;
               SAC_DatabaseDML.insertDML(permiSetAssi, false);  
               //Database.insert(permiSetAssi);
          }

        //grupo colaborador nivel 2
        CC_Grupo_Colaborador__c grupo = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion', 1)[0];
        grupo.Name = 'grupoTest';
        grupo.SAC_PermiteEscalado__c = true;
        grupo.SAC_NivelGrupo__c = 'SAC_Nivel2';
        grupo.SAC_Email__c = 'etesting@test.test';
        SAC_DatabaseDML.insertDML(grupo, false);  
        //Database.insert(grupo);

        //RECLAMACION 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Alta');
        camposRecl.put('OwnerId', usuarioGeneral.id);
    
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false);  
        //Database.insert(casoReclamacion);  

        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Subject', 'TestRec2');
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('Status', 'Alta');
        camposPret.put('OwnerId', usuarioGeneral.id);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.id);
    
        Case pretension = SAC_TestDataFactory.crearCaso('Pretension', camposPret);
        SAC_DatabaseDML.insertDML(pretension, false);  
        //Database.insert(pretension);  

        //Interaccion escalado
        Map<String, Object> camposEsc = new Map<String, Object>();
        camposEsc.put('SAC_Titulo__c', 'propuesta test');
        camposEsc.put('SAC_Propuesta__c', 'propuesta test');
        camposEsc.put('SAC_CasoEscalado__c', casoReclamacion.Id);
        camposEsc.put('SAC_Email1__c', 'testing@test.test');
        camposEsc.put('OwnerId', usuarioGeneral.id);
        camposEsc.put('SAC_GrupoColaborador__c', grupo.Id);
        camposEsc.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        
        SAC_Interaccion__c escalado = SAC_TestDataFactory.crearInteraccion('Escalado',camposEsc);
        SAC_DatabaseDML.insertDML(escalado, false);  
        //Database.insert(escalado);

        //Parametrizacion validación escalado
        Map<String, Object> camposParam = new Map<String, Object>();
        camposParam.put('Name', 'Validacion Escalado AJ');
        camposParam.put('SAC_Mensaje__c', 'mensaje test');
        
        SAC_ParametrizacionEscalado__c validacionAJ = SAC_TestDataFactory.crearParamEsc(camposParam);
        SAC_DatabaseDML.insertDML(validacionAJ, false);  
        //Database.insert(validacionAJ);
    }

    @isTest
    static void notitifacionLetradosTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT id, SAC_Estado__c, SAC_CasoEscalado__c, Name FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];

        escalado.SAC_Estado__c = 'SAC_Atendida';

        List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();
        listaEscalados.add(escalado);

        Map<Id, SAC_Interaccion__c> mapOld = new Map<Id, SAC_Interaccion__c>();
        SAC_Interaccion__c escaladoOld = new SAC_Interaccion__C();
        escaladoOld.Id = escalado.Id;
        escaladoOld.SAC_Estado__c = 'SAC_PendienteRespuesta';
        mapOld.put(escaladoOld.Id, escaladoOld);

        Test.startTest();
        System.runAs(usuario) {
            SAC_NotificacionesInteraccion.notitifacionLetrados(listaEscalados, mapOld);
        }
        Test.stopTest();

        SAC_Interaccion__c escaladoResult = [SELECT id, SAC_Estado__c FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test' LIMIT 1];
        escaladoResult.SAC_Estado__c = 'SAC_Atendida';
        System.assertEquals('SAC_Atendida', escaladoResult.SAC_Estado__c, 'No se ha podido enviar la notificación');
    }
}