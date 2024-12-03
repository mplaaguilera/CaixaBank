/**********************************************************************************************************************
Name:	  CIBE_TaskTriggerHelper_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_TaskTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Mikel Lezama		30/08/2022		Init version

-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
@isTest
public class CIBE_TaskTriggerHelper_Test {
    
    @TestSetup
    static void setup(){
        Test.startTest();    
        List<String> lstPSet = new list<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
        Account  centroCaixa = new Account();
        Account  cliente = new Account();
        Contact  empleado = new Contact();
        User usrTest = new User (); 
        System.runAs(new User(Id = UserInfo.getUserId())) {
            usrTest = CIBE_TestHelper.loginUser('','','',lstPSet);
        }
        System.runAs(new User(Id = UserInfo.getUserId())) {
            centroCaixa = CIBE_TestHelper.createCaixaCenter();
            cliente = CIBE_TestHelper.createCustomer();
            empleado  = CIBE_TestHelper.createEmployee(centroCaixa, usrTest,usrTest.AV_ExternalId__c);
        }

        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        insert pb;
        
        AV_Score__c score = new AV_Score__c(
            AV_Active__c = true,
            AV_Object__c = 'Task',
            Name = 'Otros',
            AV_RecordType__c = CIBE_AppConstants.TASK_OTROS_EMP_RT,
            AV_Score__c = 100
        );
        insert score;
       
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
        RecordType rtEvent = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
        
        User us = [Select Id, name, Profile.name from User where AV_ExternalId__c='U0009003' limit 1];
        system.debug('@ us: '+us );
        
        Task task = new Task();
        task.Subject = 'Prueba test insert';
        task.recordtypeid = rt.id;
        task.ownerid= us.id;
        task.Description = 'Prueba test insert';
        task.AV_CodigoGestorAsignado__c = '123456';
        task.Status = CIBE_AppConstants.TASK_STATUS_PENDIENTE;
        task.ActivityDate = System.now().Date();
        task.AV_AssociatedOpportunityId__c='1234';
        
        insert task;
        
        Opportunity opp =  CIBE_TestHelper.createOpportunityExternalId(cliente, empleado, task.AV_ExternalID__c);
        
        Task tsk = [Select id, AV_ExternalID__c from Task where subject = 'Prueba test insert'];
        
        Event event = new Event();
        event.Subject = 'Test Event 001-A - Outlook';
        event.RecordTypeId = rtEvent.Id;
        event.DurationInMinutes = 60;
        event.ActivityDateTime = System.now();
        event.Location = 'Outlook';
        event.OwnerId = us.Id;
        event.AV_ExternalID__c=tsk.AV_ExternalID__c;
        event.CSBD_Evento_Estado__c= CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
        event.Description = 'Prueba texto descripcion outlook: https://pexip.me/teams';
        
        insert event;
        
        Test.stopTest();
    }
    /***********************************************************************************************************/
    
    @isTest
    public static void createDataCIB() {
         Test.startTest(); 
        Opportunity opp = [select id from opportunity limit 1];
        
        AV_HeaderCustomActivity__c listHeaderTask = [Select id, AV_ExternalID__c from AV_HeaderCustomActivity__c];
        AV_CustomActivityOpportunity__c cao = CIBE_TestHelper.createTareaOportunidad(opp,listHeaderTask.id);
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR limit 1];
        Task tareaAlerta = CIBE_TestHelper.createTareaOtherExternalID(usuario);
        
        Task task= [select id, Description, AV_CodigoGestorAsignado__c, ActivityDate,subject from Task WHERE Recordtype.DeveloperName =:CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT limit 1];
        task.subject = 'Prueba borrado';
        task.Description = 'Prueba borrado';
        task.AV_CodigoGestorAsignado__c = '123456';
        task.ActivityDate = (System.now()+1).Date();
        
        update task;
        
        delete task;
        
        List<Task> listaTask = [SELECT id from Task where Subject = 'Prueba borrado'];
        System.assertEquals(0,listaTask.size());
		Test.stopTest();
    }
    
    @isTest
    public static void updateNextManagementDateOppTest() {
        Test.startTest(); 
        Date fecha;
        Task task = new Task();
        User usuario = [SELECT Id, name, Profile.name FROM User WHERE AV_ExternalID__c = 'U0009003' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR limit 1];
        List <Task> task1 = [select id, Description, Status, AV_CodigoGestorAsignado__c,AV_ExternalID__c, ActivityDate,subject, ownerId, recordtypeid from Task WHERE Recordtype.DeveloperName =:CIBE_AppConstants.TASK_OTROS_EMP_RT limit 1];
        User ownerTask = [SELECT Id, name, Profile.name FROM User WHERE id =:task1[0].ownerId limit 1];
        task1[0].ownerId = usuario.id;
        update task1;
        Opportunity opp = [select id from opportunity limit 1];
        AV_HeaderCustomActivity__c listHeaderTask = [Select id, AV_ExternalID__c from AV_HeaderCustomActivity__c];
        AV_CustomActivityOpportunity__c cao = CIBE_TestHelper.createTareaOportunidad(opp,listHeaderTask.id);
        system.runAs(usuario){
            task = [select id, Description, AV_CodigoGestorAsignado__c, ActivityDate,subject, recordtypeid,Status 
            from Task WHERE Recordtype.DeveloperName =:CIBE_AppConstants.TASK_OTROS_EMP_RT limit 1];
                fecha = task.ActivityDate;
                task.Description = 'Prueba borrado';
                task.AV_CodigoGestorAsignado__c = '123456';
                task.ActivityDate = (System.now()+1).Date();
            update task;
        }
        List <Task> taskResult = [SELECT id,recordtypeid,AV_ExternalID__c,Status, ActivityDate FROM Task WHERE id =:task.id limit 1];
        Map <Id,Task> mapTareas = new Map<Id,Task>();
        for(Task tsk: taskResult){
            mapTareas.put(tsk.id,tsk);
        }
        CIBE_TaskTriggerHelper.updateNextManagementDateOpp(task1,mapTareas);
        System.assertNotEquals(fecha,taskResult[0].ActivityDate);
    Test.stopTest();

}
    
    /***********************************************************************************************************/
    @isTest
	public static void validateUpdateGCF(){
		// User userApiOnly = AV_TestHelper.createUser('API Only');
		Test.startTest();
		User userApiOnly = [SELECT ID FROM USER WHERE Alias = 'AV-TF9' AND Profile.Name = 'API Only' and isActive = true LIMIT 1];
		// TAsk tareaAntes = AV_TestHelper.createTarea(userApiOnly);
		Task tareaAntes =[Select Id, Status, AV_ToDelete__c, AV_Tipo__c, Description, AV_Center__c, AV_CodigoGestorAsignado__c, LastModifiedById from Task WHERE Recordtype.DeveloperName =:CIBE_AppConstants.TASK_OTROS_EMP_RT];
        Task tareaCambio = tareaAntes;
        tareaCambio.Status = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO;
        tareaCambio.AV_ToDelete__c = true;
        System.runAs(userApiOnly) {
            Database.update(tareaCambio);
            tareaCambio.Status = AV_AppConstants.NO_GESTIONADA;
			Task tareaCambio2 =[Select Id, Status, AV_ToDelete__c, AV_Tipo__c, Description, AV_Center__c, AV_CodigoGestorAsignado__c, LastModifiedById from Task where Id = :tareaAntes.Id limit 1];
            tareaCambio.AV_Center__c = '12345';
            Database.update(tareaCambio2);
        }
			Task tareaDespues =[Select Id, Status, AV_ToDelete__c, AV_Tipo__c, Description, AV_Center__c, AV_CodigoGestorAsignado__c, LastModifiedById from Task where Id = :tareaAntes.Id limit 1];
			System.assertNotEquals(tareaDespues.AV_ToDelete__c,true);
			System.assertEquals(tareaDespues.Status,AV_AppConstants.GESTIONADO_POSITIVO_ESTADO);
			System.assertNotEquals(tareaDespues.AV_Center__c,'12345');
        Test.stopTest();
	}

    /***********************************************************************************************************/
    /*
    @isTest
    public static void createDataCIBOtros() {
        Test.startTest();
        Account cliente = CIBE_TestHelper.createCustomer();
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        Account centroCaixa = CIBE_TestHelper.createCaixaCenter();
        Contact empleado  = CIBE_TestHelper.createEmployee(centroCaixa, usrTest,usrTest.AV_ExternalId__c);
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        insert pb;
        
        AV_Score__c score = new AV_Score__c(
            AV_Active__c = true,
            AV_Object__c = 'Task',
            Name = 'Otros',
            AV_RecordType__c = CIBE_AppConstants.TASK_OTROS_EMP_RT,
            AV_Score__c = 100
        );
        insert score;
        
        Test.stopTest();
        Test.startTest();
        
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
        RecordType rtEvent = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
        
        User us = [Select Id from User where AV_ExternalId__c='U0009003' limit 1];
        
        Task task = new Task();
        task.Subject = 'Prueba test insert';
        task.recordtypeid = rt.id;
        task.ownerid= us.id;
        task.Description = 'Prueba test mikel insert';
        task.AV_CodigoGestorAsignado__c = '123456';
        task.Status = CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO;
        task.ActivityDate = System.now().Date();
        task.AV_AssociatedOpportunityId__c='1234';
        
        insert task;
        Opportunity opp =  CIBE_TestHelper.createOpportunityExternalId(cliente, empleado, task.AV_ExternalID__c);
        
        Task tsk = [Select id, AV_ExternalID__c from Task where subject = 'Prueba test insert'];
        
        Event event = new Event();
        event.Subject = 'Test Event 001-A - Outlook';
        event.RecordTypeId = rtEvent.Id;
        event.DurationInMinutes = 60;
        event.ActivityDateTime = System.now();
        event.Location = 'Outlook';
        event.OwnerId = us.Id;
        event.AV_ExternalID__c=tsk.AV_ExternalID__c;
        event.CSBD_Evento_Estado__c= CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
        event.Description = 'Prueba texto descripcion outlook: https://pexip.me/teams';
        
        insert event;
        
        
        AV_HeaderCustomActivity__c listHeaderTask = [Select id, AV_ExternalID__c from AV_HeaderCustomActivity__c];
        AV_CustomActivityOpportunity__c cao = CIBE_TestHelper.createTareaOportunidad(opp,listHeaderTask.id);
        
        task.Description = 'Prueba test mikel update';
        task.AV_CodigoGestorAsignado__c = '123456';
        task.ActivityDate = (System.now()+1).Date();
        
        update task;
        
        delete task;
        
        Test.stopTest();
        
        List<Task> listaTask = [SELECT id from Task where Subject = 'Prueba test insert'];
        System.assertEquals(0,listaTask.size());
    }*/
    
}