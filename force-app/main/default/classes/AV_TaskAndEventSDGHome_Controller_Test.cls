/**********************************************************************************************************************
Name:	  AV_TaskAndEventSDGHome_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para AV_TaskAndEventSDGHome_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	  AUTHOR		   	DATE				Description
	1.1			DE56793	      Patricia Solano  	16/11/2022		  	Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_TaskAndEventSDGHome_Controller_Test {
    
    @TestSetup
	static void setup(){
        
        //Create Sortable for Event
        Sortablegrid__SDG__c eventToday = new Sortablegrid__SDG__c();
        eventToday.Name = 'CRM - Eventos Ficha Cliente';
        eventToday.sortablegrid__Is_Valid__c = true;
        eventToday.sortablegrid__Parent_Field_Name__c = 'AccountId';
        eventToday.sortablegrid__SDG_Tag__c = 'AV_Home_Gestor_Citas_de_Hoy';
        eventToday.sortablegrid__sObjectName__c = 'Event';
        insert eventToday;

        Sortablegrid__SDG_Field__c fieldAccountEvent = new Sortablegrid__SDG_Field__c();
        fieldAccountEvent.sortablegrid__sdg__c = eventToday.Id;
        fieldAccountEvent.sortablegrid__APIName__c = 'Account.Name';
        fieldAccountEvent.sortablegrid__FieldOrder__c = 1;
        fieldAccountEvent.sortablegrid__Override_Label__c = 'CLIENTE';
        insert fieldAccountEvent;

        Sortablegrid__SDG_Field__c fieldSubjectLabel = new Sortablegrid__SDG_Field__c();
        fieldSubjectLabel.sortablegrid__sdg__c = eventToday.Id;
        fieldSubjectLabel.sortablegrid__APIName__c = 'AV_VerRegistro__c';
        fieldSubjectLabel.sortablegrid__FieldOrder__c = 2;
        fieldSubjectLabel.sortablegrid__Override_Label__c = 'ASUNTO';
        insert fieldSubjectLabel;
        
        Sortablegrid__SDG_Field__c fieldTypeEvent = new Sortablegrid__SDG_Field__c();
        fieldTypeEvent.sortablegrid__sdg__c = eventToday.Id;
        fieldTypeEvent.sortablegrid__APIName__c = 'AV_Tipo__c';
        fieldTypeEvent.sortablegrid__FieldOrder__c = 3;
        fieldTypeEvent.sortablegrid__Override_Label__c = 'TIPO';
        insert fieldTypeEvent;
        
        Sortablegrid__SDG_Field__c fieldDateEvent = new Sortablegrid__SDG_Field__c();
        fieldDateEvent.sortablegrid__sdg__c = eventToday.Id;
        fieldDateEvent.sortablegrid__APIName__c = 'StartDateTime';
        fieldDateEvent.sortablegrid__FieldOrder__c = 4;
        fieldDateEvent.sortablegrid__Override_Label__c = 'FECHA EVENTO';
        insert fieldDateEvent;

        Sortablegrid__SDG_Field__c fieldCustomClass = new Sortablegrid__SDG_Field__c();
        fieldCustomClass.sortablegrid__sdg__c = eventToday.Id;
        fieldCustomClass.sortablegrid__APIName__c = 'CSBD_Evento_Estado__c';
        fieldCustomClass.sortablegrid__FieldOrder__c = 5;
        fieldCustomClass.sortablegrid__Override_Label__c = 'ESTADO';
        insert fieldCustomClass;
        
        //Create Sortable for Task
        Sortablegrid__SDG__c taskToday = new Sortablegrid__SDG__c();
        taskToday.Name = 'CRM - Tareas Ficha Cliente';
        taskToday.sortablegrid__Is_Valid__c = true;
        taskToday.sortablegrid__Parent_Field_Name__c = 'AccountId';
        taskToday.sortablegrid__SDG_Tag__c = 'AV_Home_Gestor_Tareas_para_Hoy';
        taskToday.sortablegrid__sObjectName__c = 'Task';
        insert taskToday;

        Sortablegrid__SDG_Field__c fieldPriorityTask = new Sortablegrid__SDG_Field__c();
        fieldPriorityTask.sortablegrid__sdg__c = taskToday.Id;
        fieldPriorityTask.sortablegrid__APIName__c = 'Priority';
        fieldPriorityTask.sortablegrid__FieldOrder__c = 1;
        fieldPriorityTask.sortablegrid__Override_Label__c = 'PRIORIDAD';
        insert fieldPriorityTask;

        Sortablegrid__SDG_Field__c fieldOriginTask = new Sortablegrid__SDG_Field__c();
        fieldOriginTask.sortablegrid__sdg__c = taskToday.Id;
        fieldOriginTask.sortablegrid__APIName__c = 'AV_Origen__c';
        fieldOriginTask.sortablegrid__FieldOrder__c = 2;
        fieldOriginTask.sortablegrid__Override_Label__c = 'ORIGEN';
        insert fieldOriginTask;

        Sortablegrid__SDG_Field__c fieldClientLink = new Sortablegrid__SDG_Field__c();
        fieldClientLink.sortablegrid__sdg__c = taskToday.Id;
        fieldClientLink.sortablegrid__APIName__c = 'Account.Name';
        fieldClientLink.sortablegrid__FieldOrder__c = 3;
        fieldClientLink.sortablegrid__Override_Label__c = 'CLIENTE';
        insert fieldClientLink;

        Sortablegrid__SDG_Field__c fieldSubjectTask = new Sortablegrid__SDG_Field__c();
        fieldSubjectTask.sortablegrid__sdg__c = taskToday.Id;
        fieldSubjectTask.sortablegrid__APIName__c = 'AV_VerRegistro__c';
        fieldSubjectTask.sortablegrid__FieldOrder__c = 4;
        fieldSubjectTask.sortablegrid__Override_Label__c = 'ASUNTO';
        insert fieldSubjectTask;

        Sortablegrid__SDG_Field__c fieldStatusTask = new Sortablegrid__SDG_Field__c();
        fieldStatusTask.sortablegrid__sdg__c = taskToday.Id;
        fieldStatusTask.sortablegrid__APIName__c = 'Status';
        fieldStatusTask.sortablegrid__FieldOrder__c = 5;
        fieldStatusTask.sortablegrid__Override_Label__c = 'ESTADO';
        insert fieldStatusTask;

        Sortablegrid__SDG_Field__c fieldDateTask = new Sortablegrid__SDG_Field__c();
        fieldDateTask.sortablegrid__sdg__c = taskToday.Id;
        fieldDateTask.sortablegrid__APIName__c = 'ActivityDate';
        fieldDateTask.sortablegrid__FieldOrder__c = 6;
        fieldDateTask.sortablegrid__Override_Label__c = 'FECHA VENCIMIENTO';
        insert fieldDateTask;

        Sortablegrid__SDG_Field__c fieldMotiveTask = new Sortablegrid__SDG_Field__c();
        fieldMotiveTask.sortablegrid__sdg__c = taskToday.Id;
        fieldMotiveTask.sortablegrid__APIName__c = 'AV_Valor1__c';
        fieldMotiveTask.sortablegrid__FieldOrder__c = 7;
        fieldMotiveTask.sortablegrid__Override_Label__c = 'MOTIVO PRINCIPAL';
        insert fieldMotiveTask;
        
        Sortablegrid__SDG_Field__c fieldOwnerTask = new Sortablegrid__SDG_Field__c();
        fieldOwnerTask.sortablegrid__sdg__c = taskToday.Id;
        fieldOwnerTask.sortablegrid__APIName__c = 'Owner.Name';
        fieldOwnerTask.sortablegrid__FieldOrder__c = 8;
        fieldOwnerTask.sortablegrid__Override_Label__c = 'ASIGNADO';
        insert fieldOwnerTask;

        Account account = AV_TestHelper.createCustomer();
		Pricebook2 pricebook = new Pricebook2();
		pricebook.Name = 'Standard Price Book';
		insert pricebook;

        User user = AV_TestHelper.createUser('Standard User');

		Opportunity opportunity = AV_TestHelper.createOpportunity(account);

        Task task = AV_TestHelper.createTareaExternalIdWithCustomerSinInsert(user, '01928374', account);
        task.ActivityDate = System.today()+1;        
        insert task;

        String idTaskHeader = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = '01928374' LIMIT 1].AV_Task__c;
        
		AV_CustomActivityOpportunity__c oppTask= AV_TestHelper.createTareaOportunidad(opportunity, idTaskHeader);
	}

    @isTest
    public static void getTaskTodaytest(){
    	Test.startTest();
        Opportunity opportunity =  [SELECT ID FROM Opportunity LIMIT 1];
        AV_TaskAndEventSDGHome_Controller.DataResponse response = new AV_TaskAndEventSDGHome_Controller.DataResponse();
        response = AV_TaskAndEventSDGHome_Controller.getRecords('AV_Home_Gestor_Tareas_para_Hoy');
    	Test.stopTest();
        system.assertNotEquals(null, response);
    }

    @isTest
    public static void getTaskPendingtest(){
    	Test.startTest();
        Opportunity opportunity =  [SELECT ID FROM Opportunity LIMIT 1];
        Sortablegrid__SDG__c sortableGrid = [SELECT ID FROM Sortablegrid__SDG__c WHERE  Name = 'CRM - Tareas Ficha Cliente' LIMIT 1];
        sortableGrid.sortablegrid__SDG_Tag__c = 'AV_HomeGestorTareasPendientes';
        update sortableGrid;
        AV_TaskAndEventSDGHome_Controller.DataResponse response = new AV_TaskAndEventSDGHome_Controller.DataResponse();
        response = AV_TaskAndEventSDGHome_Controller.getRecords('AV_HomeGestorTareasPendientes');
    	Test.stopTest();
        system.assertNotEquals(null, response);
    }

    @isTest
    public static void getEventTodaytest(){
        Test.startTest();
        Opportunity opportunity = [SELECT ID FROM Opportunity LIMIT 1];
        AV_TaskAndEventSDGHome_Controller.DataResponse response = new AV_TaskAndEventSDGHome_Controller.DataResponse();
        response = AV_TaskAndEventSDGHome_Controller.getRecords('AV_Home_Gestor_Citas_de_Hoy');
        Test.stopTest();
        system.assertNotEquals(null, response);
    }

    @isTest
    public static void getEventPendingtest(){
        Test.startTest();
        Opportunity opportunity = [SELECT ID FROM Opportunity LIMIT 1];
        Sortablegrid__SDG__c sortableGrid = [SELECT ID FROM Sortablegrid__SDG__c WHERE  Name = 'CRM - Eventos Ficha Cliente' LIMIT 1];
        sortableGrid.sortablegrid__SDG_Tag__c = 'AV_HomeGestorCitasDeAyerNoCerradas';
        update sortableGrid;
        AV_TaskAndEventSDGHome_Controller.DataResponse response = new AV_TaskAndEventSDGHome_Controller.DataResponse();
        response = AV_TaskAndEventSDGHome_Controller.getRecords('AV_HomeGestorCitasDeAyerNoCerradas');
        Test.stopTest();
        system.assertNotEquals(null, response);
    }
}