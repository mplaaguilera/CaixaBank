/*****************************************************************
 * Name: SAC_MilestoneTimeCalculatorAlta_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_MilestoneTimeCalculatorAlta
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US219258         Marcela Neira        17/06/21     Creación
 * 1.1            US643756         Jose Carlos Blanco   05/07/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@istest
public with sharing class SAC_MilestoneTimeCalculatorAlta_Test {
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

          //MCC
          String mccDetalleRecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
          
          CC_MCC__c mccDetalle = new CC_MCC__c(Name='Prueba', CC_Codigo_Externo__c='a', RecordTypeId=mccDetalleRecordTypeId, CC_Tipo_Cliente__c='SAC');
          Database.upsert(mccDetalle); 
  
          //PARAMETRIZACIONES MCC
          SAC_ParametrizacionSLATME__c parametrizacion1  = SAC_TestDataFactory.crearParamsSla('SLAAlta',1)[0];
          parametrizacion1.SAC_Duracion__c = 10;
          parametrizacion1.SAC_MCC__c = mccDetalle.Id;
          parametrizacion1.SAC_CanalProcedencia__c = ''; 
          Database.upsert(parametrizacion1);
  
          //Pretension
          Map<String, Object> camposPret = new Map<String, Object>();
          camposPret.put('Subject', 'TestPret');
          camposPret.put('Origin', 'Backoffice');
          camposPret.put('SEG_Detalle__c', mccDetalle.id);
        
          Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension', camposPret);
          Database.insert(casoPretension);

          //Reclamacion
          Map<String, Object> camposRecl = new Map<String, Object>();
          camposRecl.put('Subject', 'TestRec');
          camposRecl.put('Origin', 'Backoffice');
          camposRecl.put('SEG_Detalle__c', mccDetalle.id);
          camposRecl.put('SAC_PretensionPrincipal__c', casoPretension.id);
        
          Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
          Database.insert(casoReclamacion);  
     }

     @istest
     static void testMilestoneAlta(){
          User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' and IsActive = true limit 1];

          MilestoneType[] listMilestoneType = [SELECT Id, Name FROM MilestoneType LIMIT 1];      
          if(listMilestoneType.size() == 0) { 
               return; 
          }

          MilestoneType mt = listMilestoneType[0];
          
          Case casoReclamacion = [SELECT id, RecordTypeId, SAC_Reclamacion__c from case where subject = 'TestRec'];

          SAC_MilestoneTimeCalculatorAlta calculator = new SAC_MilestoneTimeCalculatorAlta();

          Integer actualTriggerTime;
          System.runAs(usuario){
               Test.startTest();
               actualTriggerTime = calculator.calculateMilestoneTriggerTime(casoReclamacion.Id, mt.Id);
               Test.stopTest();
          }
          
          SAC_ParametrizacionSLATME__c parametrizacion1 = [select id, SAC_Duracion__c from SAC_ParametrizacionSLATME__c where SAC_Duracion__c = 10];
  
          System.assertEquals((parametrizacion1.SAC_Duracion__c*1440), actualTriggerTime, 'No se ha podido asociar un tiempo');
     }
}