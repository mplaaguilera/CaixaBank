/*****************************************************************
* Name: SAC_AccionGGH_Test
* Copyright © 2022  CaixaBank
* 
* Proposito: Testar la clase SAC_AccionGGH
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR              DATE         Description
* 1.0            US431440         Marcela Neira       05/09/22     Creación
* 1.1            US563153         Jose Carlos Blanco  08/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@istest
public with sharing class SAC_AccionGGH_Test {

   @TestSetup
   static void makeData(){  
      
      User usuarioGeneral;
      System.runAs(new User(Id = Userinfo.getUserId())) {
         //Usuario SAC General
         usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
         Database.insert(usuarioGeneral);
      
         PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
         PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
         permiSetAssi.AssigneeId = usuarioGeneral.Id;
         permiSetAssi.PermissionSetId = permiSet.Id;
         Database.insert(permiSetAssi);
      }

      CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1)[0];
      Database.insert(grupoColaborador);

      //Pretension
      Map<String, Object> camposPret = new Map<String, Object>();
      camposPret.put('SuppliedCompany', 'pretension');
      camposPret.put('OwnerId', usuarioGeneral.id);
      
      Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
      Database.insert(pretension);    
      
      
      SAC_MaestroAccionesReclamacion__c maestro = SAC_TestDataFactory.crearMaestroAcciones(1,grupoColaborador.Id)[0];
      maestro.SAC_DeveloperName__c ='GGH';
      maestro.SAC_Descripcion__c = 'Maestro';  
      maestro.SAC_PlazoMaximo__c = 4; 
      maestro.SAC_Prorroga__c= 4;
      Database.insert(maestro);

      SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas(1,pretension,true)[0];
      tarea.SAC_MaestroAccionesReclamacion__c = maestro.id;
      Database.insert(tarea);
   }

   @isTest
   static void tareaUnicaGGH_Test() {
      Id recordTypeAccionMaestro = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_MaestroDeTareas').getRecordTypeId();
      Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'pretension'];      
      List<SAC_MaestroAccionesReclamacion__c> maestroGHH = [SELECT id, SAC_DeveloperName__c FROM SAC_MaestroAccionesReclamacion__c WHERE SAC_DeveloperName__c = 'GGH' LIMIT 1]; 
      Boolean hayError = false;

      try{
         SAC_Accion__c tarea = new SAC_Accion__c(RecordTypeId = recordTypeAccionMaestro, SAC_MaestroAccionesReclamacion__c = maestroGHH[0].id, SAC_Pretension__c = pretension.Id);
         Database.insert(tarea);
      } catch (Exception e) {
         hayError = true;
      }

      User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
         Database.update(pretension);
      }
      System.assertEquals(true, hayError, 'No ha saltado el error.');
   }
}