/**********************************************************************************************************************
 Name:      CIBE_OppAccActivitiesController_Test
 Copyright © 2023  CaixaBank
=======================================================================================================================
Proposito: Clase test de CIBE_OppAccActivitiesController
=======================================================================================================================
Historial
---------------------
   VERSION        USER_STORY       AUTHOR               DATE                Description
   1.0            Integrations     Alexandre Pérez      28/02/2023          Init version

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_OppAccActivitiesController_Test {
    @isTest
    public static void testGetActivities() {
        User cIBUser;
        CIBE_OppAccActivitiesController.ActivitiesWrapper wrapper;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            cIBUser = CIBE_TestHelper.loginUser('CIBE_Gestor', 'CIBE_CIBEmpresas', '', new List<String>{'CIBE_OperativaCIB', 'CIBE_CustomMetadata', 'CIBE_Analytics'});
        }

        Account acc;
        System.runAs(cIBUser){
            acc = CIBE_TestHelper.createCustomerWithNumperson('123456');
        }
        Account center = CIBE_TestHelper.createCaixaCenter();
        contact empleado = CIBE_TestHelper.createEmployee(center, cIBUser);
        Opportunity opp = CIBE_TestHelper.createOpportunityWithEmpleado(acc, empleado);
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT);
        RecordType rtEvent = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);

        list<event> elist = new list<event>();
       Task t;

       system.runAs(cIBUser){
            list<task> taskList = new list<task>();
            t = new Task(
                Subject='Test Task', 
                ActivityDate=System.today()-3, 
                WhatId=opp.Id, 
                recordTypeId = rt.id,
                AV_ExternalID__c = '01928363',
                Priority = 'Normal',
                Status = 'Pendiente no localizado',
                OwnerId = cIBUser.Id
            );
            taskList.add(t);
            Task t2 = new Task(
                Subject='Test Task2', 
                ActivityDate=System.today()-2, 
                WhatId=acc.Id, 
                recordTypeId = rt.id,
                AV_ExternalID__c = '01928364',
                Priority = 'Normal',
                Status = 'Pendiente no localizado',
                //AV_Task__c = acthead.Id,
                OwnerId = cIBUser.Id
            );
            taskList.add(t2);
            insert taskList;
            
                CIBE_TestHelper.createTareaOportunidad(opp, [SELECT ID, AV_TASK__C FROM TASK WHERE Subject = 'Test Task2'].AV_Task__c);
        }

        Event e1 = new Event(Subject='Test Event2', ActivityDate=Date.today(), WhatId=opp.Id, CSBD_Evento_Estado__c='Completado', DurationInMinutes=60, ActivityDateTime=datetime.now(), OwnerId=CIBUser.Id, recordTypeId = rtEvent.Id);
        Event e = new Event(Subject='Test Event', ActivityDate=Date.today(), WhatId=opp.Id, CSBD_Evento_Estado__c='Pendiente', DurationInMinutes=60, ActivityDateTime=datetime.now(), OwnerId=CIBUser.Id, recordTypeId = rtEvent.Id);
        Event e2 = new Event(Subject='Test Event3', ActivityDate=Date.today(), WhatId=opp.Id, CSBD_Evento_Estado__c='Completado', DurationInMinutes=60, ActivityDateTime=datetime.now()+1, OwnerId=CIBUser.Id, recordTypeId = rtEvent.Id);
        elist.add(e1);
        elist.add(e);
        elist.add(e2);
        insert elist;
        
        
        test.startTest();
        System.runAs(cIBUser) {
            wrapper = CIBE_OppAccActivitiesController.getActivities(opp.Id);
        }
        test.stopTest();
        System.assertEquals(2, wrapper.taskList.size(), 'No se están mostrando la cantidad de Task esperadas');
        System.assertEquals(t.Id, wrapper.taskList[0].Id, 'No se está realizando el orden de Tasks esperado');
        System.assertEquals(3, wrapper.eventList.size(), 'No se están mostrando la cantidad de Events esperados');
        System.assertEquals(e.Id, wrapper.eventList[0].Id, 'No se está realizando el orden de Events esperado');
    }
}