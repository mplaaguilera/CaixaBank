/**********************************************************************************************************************
 Name:	  AV_PendingTasks_Controller_Test
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test of AV_PendingTasks_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US206851			Sandra Gómez		25/05/2021			Init version
    1.1          QC                 Oscar Moreno        12/06/2024       Delete UserInfo.geetUserId()

***********************************************************************************************************************/
@isTest
public with sharing class AV_PendingTasks_Controller_Test {
    @TestSetup
	static void setup() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 

        Date activityDate = date.today() + 2;
        User us=AV_TestHelper.createUser('');
        Account acc=AV_TestHelper.createCustomer();
        AV_TestHelper.createTareaExternalIdWithCustomer(us,'U0009003',acc);
		RecordType rt = AV_AppUtilities.getRecordType('Task', 'AV_MorosidadNormativa');
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
        tarea.OwnerId = usuarioGcf.Id;  
		tarea.Status = 'Open';
		tarea.Priority = 'Normal';
		tarea.AV_ExternalID__c = 'U0009002';
        tarea.ActivityDate=activityDate;
		tarea.RecordTypeId = rt.Id;
		tarea.WhatId = acc.Id;
		insert tarea;
    }
    
    @isTest
    public static void getAvisosTasksTest() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];  //mio

        Test.startTest();
        Task tarea = [SELECT Id FROM Task WHERE AV_ExternalID__c = 'U0009003' LIMIT 1];
        List<AV_PendingTasks_Controller.TaskAvisos> resul;
        System.runAs(usuarioGcf){
            resul = AV_PendingTasks_Controller.getAvisosTasks(tarea.Id);
        }
        Test.stopTest();
        System.assertNotEquals(null, resul);
    }
    
    @isTest
    public static void updateTasksAvisoTest() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];  //mio

        Test.startTest();	
     
        Task tarea = [SELECT Id FROM Task WHERE AV_ExternalID__c = 'U0009002' LIMIT 1];
        String idTarea=tarea.Id;
        AV_PendingTasks_Controller.TaskAviso tareaPendiente= new AV_PendingTasks_Controller.TaskAviso();
        tareaPendiente.id=idTarea;
        tareaPendiente.comentario='Hola';
        tareaPendiente.estado='Gestionada positiva';
        List<AV_PendingTasks_Controller.TaskAviso> listTask= new List<AV_PendingTasks_Controller.TaskAviso>();
        listTask.add(tareaPendiente);
		String jsonString = json.serialize(listTask);
        String resul;
        System.runAs(usuarioGcf){
            resul=AV_PendingTasks_Controller.updateTasksAviso(jsonString);
        }
        Test.stopTest();
        System.assertEquals('OK', resul);
    }
    
    @isTest
    public static void updateTasksAvisoErrorComentarioNullTest() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];  //mio

        Test.startTest();	
        Task tarea = [SELECT Id FROM Task WHERE AV_ExternalID__c = 'U0009002' LIMIT 1];
        String idTarea=tarea.Id;
        AV_PendingTasks_Controller.TaskAviso tareaPendiente= new AV_PendingTasks_Controller.TaskAviso();
        tareaPendiente.id=idTarea;
        tareaPendiente.comentario=null;
        tareaPendiente.estado='Mal';
        List<AV_PendingTasks_Controller.TaskAviso> listTask= new List<AV_PendingTasks_Controller.TaskAviso>();
        listTask.add(tareaPendiente);
		String jsonString = json.serialize(listTask);
        String resul;
        System.runAs(usuarioGcf){
            resul=AV_PendingTasks_Controller.updateTasksAviso(jsonString);
        }
        Test.stopTest();
        System.assertNotEquals('OK', resul);
    }
}