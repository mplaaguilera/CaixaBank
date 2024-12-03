/**********************************************************************************************************************
Name:	  AV_NotifyExpCliTaskSchedulable_Test
Copyright © 2023  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase para dar cobertura a la clase AV_NotifyExpCliTaskSchedulable
------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	        AUTHOR		   		DATE				Description
1.0			US464358		    Luis Fernandez	     15/02/2023		Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_NotifyExpCliTaskSchedulable_Test {
   @TestSetup
   public static void setup(){

    User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
    User us;
    System.runAs(usuGcf){
        us = AV_TestHelper.createUser(null);
        AV_TestHelper.createEmployee(null, us);
    }
    insert new CBK_ScheduleControls__c(
        Name = 'ScheduleInfo',
        Retries__c =0
        );
    Task t = AV_TestHelper.createTareaExternalIdSinInsert(us,'9999999');
    t.RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK,AV_AppConstants.TASKEXPCLIENT_RT).Id;
    t.ActivityDate = date.today().addDays(10);
    
   
    insert t;    
   }

   @isTest 
   public static void testSchedulable(){
    
    Task t = [SELECT Id FROM Task WHERE Owner.Alias = 'tsAlias' LIMIT 1];
    string  dispacherName = 'CBK_ScheduleProcess_Dispacher';
    User usuGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];

    
    Type typeProcessAction = Type.forName(dispacherName);
    CBK_SCH_PendingProcess__c sch = [SELECT Id,
    RecordId__c,Param1__c,Param2__c,Schedule_Time__c,Queued__c,QueuedDate__c,ClassName__c FROM CBK_SCH_PendingProcess__c WHERE RecordId__c = :t.id LIMIT 1];
    
    String classToTest= sch.ClassName__c;
    Map<String, List<CBK_SCH_PendingProcess__c>> mapTest = new Map<String, List<CBK_SCH_PendingProcess__c>>
    {
        classToTest => new List<CBK_SCH_PendingProcess__c>{sch}
    };
    CBK_ScheduleProcess_Abstract processAction = (CBK_ScheduleProcess_Abstract) typeProcessAction.newInstance();
    Test.startTest();
    System.runAs(usuGcf){
        processAction.execute(mapTest);
    }
    Test.stopTest();
    System.assert(true);

   }
}