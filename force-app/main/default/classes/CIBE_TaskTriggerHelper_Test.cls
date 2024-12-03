// /**********************************************************************************************************************
// Name:	  CIBE_TaskTriggerHelper_Test
// Copyright © 2022  CaixaBank
// -----------------------------------------------------------------------------------------------------------------------
// Proposito: Testing class "CIBE_TaskTriggerHelper"
// -----------------------------------------------------------------------------------------------------------------------
// Historial
// VERSION		USER_STORY		AUTHOR				DATE			Description
// 1.0			Test Class		Mikel Lezama		30/08/2022		Init version

// -----------------------------------------------------------------------------------------------------------------------
// **********************************************************************************************************************/
// @isTest
// public class CIBE_TaskTriggerHelper_Test {
    
//     @TestSetup
//     static void setup(){
//         Test.startTest();   
        
        
//         List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP, CIBE_AppConstants.USER_AV_AVOIDBULKAPI};
        
//         CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);

//         User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];

//         System.runAs(usrSetup){
//             User managerUser = [SELECT Id, AV_ExternalId__c FROM User WHERE AV_ExternalID__c = 'U0000001' AND LastName = 'U0000001_LastName' LIMIT 1];

//             Account  centroCaixa = new Account();
//             Account  cliente = new Account();
//             Contact  empleado = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = : managerUser.Id];
                 
//             centroCaixa = CIBE_TestHelper.createCaixaCenter();
//             cliente = CIBE_TestHelper.createCustomer();
//             //empleado  = CIBE_TestHelper.createEmployee(centroCaixa, managerUser,managerUser.AV_ExternalId__c);
        
    
//             Pricebook2 pb = new Pricebook2();
//             pb.Name = 'Standard Price Book';
//             insert pb;
            
//             AV_Score__c score = new AV_Score__c(
//                 AV_Active__c = true,
//                 AV_Object__c = 'Task',
//                 Name = 'Otros',
//                 AV_RecordType__c = CIBE_AppConstants.TASK_OTROS_EMP_RT,
//                 AV_Score__c = 100
//             );
//             insert score;
           
//             RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
//             RecordType rtEvent = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);
            
//             Task task = new Task();
//             task.Subject = 'Prueba test insert';
//             task.recordtypeid = rt.id;
//             task.Description = 'Prueba test insert';
//             task.AV_CodigoGestorAsignado__c = '123456';
//             task.Status = CIBE_AppConstants.TASK_STATUS_PENDIENTE;
//             task.ActivityDate = System.now().Date();
//             task.AV_AssociatedOpportunityId__c='1234';
//             task.OwnerId = managerUser.Id;
            
//             insert task;
            
//             Opportunity opp =  CIBE_TestHelper.createOpportunityExternalId(cliente, empleado, task.AV_ExternalID__c);
                        
//             Event event = new Event();
//             event.Subject = 'Test Event 001-A - Outlook';
//             event.RecordTypeId = rtEvent.Id;
//             event.DurationInMinutes = 60;
//             event.ActivityDateTime = System.now();
//             event.Location = 'Outlook';
//             event.AV_ExternalID__c=task.AV_ExternalID__c;
//             event.CSBD_Evento_Estado__c= CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
//             event.Description = 'Prueba texto descripcion outlook: https://pexip.me/teams';
//             event.OwnerId = managerUser.Id;
            
//             insert event;
//         }

       
        
//         Test.stopTest();
//     }
//     /***********************************************************************************************************/
    
//     @isTest
//     public static void createDataCIB() {
//         User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
//         System.runAs(usuario){
//             Test.startTest(); 
//             // Opportunity opp = [select id from opportunity limit 1];
            
//             // AV_HeaderCustomActivity__c listHeaderTask = [Select id, AV_ExternalID__c from AV_HeaderCustomActivity__c];
//             // AV_CustomActivityOpportunity__c cao = CIBE_TestHelper.createTareaOportunidad(opp,listHeaderTask.id);
//             // Task tareaAlerta = CIBE_TestHelper.createTareaOtherExternalID(usuario);
            
//             Task task= [select id, Description, AV_CodigoGestorAsignado__c, ActivityDate,subject from Task WHERE Subject = 'Prueba test insert' limit 1];
//             task.subject = 'Prueba borrado';
//             task.Description = 'Prueba borrado';
//             task.AV_CodigoGestorAsignado__c = '123456';
//             task.ActivityDate = (System.now()+1).Date();
            
//             update task;
            
//             delete task;
            
//             List<Task> listaTask = [SELECT id from Task where Subject = 'Prueba borrado'];
//             System.assertEquals(0,listaTask.size());
//             Test.stopTest();
//         }
         
//     }
    
//     @isTest
//     public static void updateNextManagementDateOppTest() {
//         Test.startTest(); 
//         Date fecha;
//         Task task = new Task();
//         User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
//         List <Task> task1 = [select id, Description, Status, AV_CodigoGestorAsignado__c,AV_ExternalID__c, ActivityDate,subject, ownerId, recordtypeid from Task WHERE Recordtype.DeveloperName =:CIBE_AppConstants.TASK_OTROS_EMP_RT limit 1];
//         User ownerTask = [SELECT Id, name, Profile.name FROM User WHERE id =:task1[0].ownerId limit 1];
//         task1[0].ownerId = usuario.id;
//         update task1;
//         Opportunity opp = [select id from opportunity limit 1];
//         AV_HeaderCustomActivity__c listHeaderTask = [Select id, AV_ExternalID__c from AV_HeaderCustomActivity__c limit 1];
//         AV_CustomActivityOpportunity__c cao = CIBE_TestHelper.createTareaOportunidad(opp,listHeaderTask.id);
//         system.runAs(usuario){
//             task = [select id, Description, AV_CodigoGestorAsignado__c, ActivityDate,subject, recordtypeid,Status 
//             from Task WHERE Recordtype.DeveloperName =:CIBE_AppConstants.TASK_OTROS_EMP_RT limit 1];
//                 fecha = task.ActivityDate;
//                 task.Description = 'Prueba borrado';
//                 task.AV_CodigoGestorAsignado__c = '123456';
//                 task.ActivityDate = (System.now()+1).Date();
//             update task;
//         }
//         List <Task> taskResult = [SELECT id,recordtypeid,AV_ExternalID__c,Status, ActivityDate FROM Task WHERE id =:task.id limit 1];
//         Map <Id,Task> mapTareas = new Map<Id,Task>();
//         for(Task tsk: taskResult){
//             mapTareas.put(tsk.id,tsk);
//         }
//         CIBE_TaskTriggerHelper.updateNextManagementDateOpp(task1,mapTareas);
//         System.assertNotEquals(fecha,taskResult[0].ActivityDate);
//     Test.stopTest();

// }
    
//     /***********************************************************************************************************/
//     @isTest
// 	public static void validateUpdateGCF(){
// 		// User userApiOnly = AV_TestHelper.createUser('API Only');
// 		Test.startTest();
// 		User userApiOnly = [SELECT ID FROM USER WHERE Alias = 'AV-TF9' AND Profile.Name = 'API Only' and isActive = true LIMIT 1];
// 		// TAsk tareaAntes = AV_TestHelper.createTarea(userApiOnly);
// 		Task tareaAntes =[Select Id, Status, AV_ToDelete__c, AV_Tipo__c, Description, AV_Center__c, AV_CodigoGestorAsignado__c, LastModifiedById from Task WHERE Recordtype.DeveloperName =:CIBE_AppConstants.TASK_OTROS_EMP_RT];
//         Task tareaCambio = tareaAntes;
//         tareaCambio.Status = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO;
//         tareaCambio.AV_ToDelete__c = true;
//         System.runAs(userApiOnly) {
//             Database.update(tareaCambio);
//             tareaCambio.Status = AV_AppConstants.NO_GESTIONADA;
// 			Task tareaCambio2 =[Select Id, Status, AV_ToDelete__c, AV_Tipo__c, Description, AV_Center__c, AV_CodigoGestorAsignado__c, LastModifiedById from Task where Id = :tareaAntes.Id limit 1];
//             tareaCambio.AV_Center__c = '12345';
//             Database.update(tareaCambio2);
//         }
// 			Task tareaDespues =[Select Id, Status, AV_ToDelete__c, AV_Tipo__c, Description, AV_Center__c, AV_CodigoGestorAsignado__c, LastModifiedById from Task where Id = :tareaAntes.Id limit 1];
// 			System.assertNotEquals(tareaDespues.AV_ToDelete__c,true);
// 			System.assertEquals(tareaDespues.Status,AV_AppConstants.GESTIONADO_POSITIVO_ESTADO);
// 			System.assertNotEquals(tareaDespues.AV_Center__c,'12345');
//         Test.stopTest();
// 	}


    // @isTest
    // public static void deleteRelationsTest(){
    //     User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND LastName = 'U0000001_LastName' LIMIT 1];
    //     Test.startTest();

    //     System.runAs(usuario){

    //         RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
    //         Account accTest = new Account(
    //             Name = 'Test Name 2',
    //             RecordTypeId = rt.Id,
    //             AV_NumPerso__c = '021',
    //             AV_Negocio__c = 'EMP'
    //         );
    //         insert accTest;
    //         RecordType rtOppEMP = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
    //         Date yesterday = Date.today().addDays(-1);
    //         Opportunity opp = new Opportunity();
    //             opp.AccountId = accTest.Id;
    //             opp.Name = 'Test Alerta Comercial 2';
    //             opp.StageName = 'CIBE_Vencido';
    //             opp.RecordTypeId = rtOppEMP.Id;
    //             opp.CloseDate = yesterday;
    //             opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial 1';
    //             opp.AV_IncludeInPrioritizingCustomers__c = true;
    //             opp.CIBE_PriceApprove__c = 'Pendiente aprobación';
    //             opp.CIBE_ApprovalRisk__c = 'Pendiente aprobación';
    //             opp.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
    //         insert opp;

    //         //Task tsk = [SELECT Id , RecordTypeId FROM Task WHERE Subject = 'Prueba test insert' LIMIT 1];
    //         Task task = new Task();
    //         task.Subject = 'Prueba test insert2';
    //         task.recordtypeid = rt.id;
    //         task.Description = 'Prueba test insert2';
    //         task.AV_CodigoGestorAsignado__c = '234';
    //         task.Status = CIBE_AppConstants.TASK_STATUS_PENDIENTE;
    //         task.ActivityDate = System.now().Date();
    //         task.AV_AssociatedOpportunityId__c='543';
    //         task.OwnerId = usuario.Id;
    //         CIBE_TestHelper.createTareaOportunidad(opp, task.AV_Task__c);
    //         insert task;

    //         List<AV_CustomActivityOpportunity__c> relacionado = [SELECT Id, AV_Task__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :task.AV_Task__c and AV_Opportunity__c = :opp.Id];
    //         System.assert(!relacionado.isEmpty());
    //         delete task;
    //         List<AV_CustomActivityOpportunity__c> relacionado2 = [SELECT Id, AV_Task__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :task.AV_Task__c and AV_Opportunity__c = :opp.Id];
    //         System.assert(relacionado2.isEmpty());
    //         List<Task> tsk1 = [SELECT Id FROM Task WHERE Subject = 'Prueba test insert'];
    //         System.assert(tsk1.isEmpty());

    //     }
    //     Test.stoptest(); 
    // }  
    
// }

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
        RecordType rtTask = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);

        Test.startTest();    
        
        CIBE_TestInitialSetup.setupInitialDataEMP();
        User usuario = [SELECT Id, name, Profile.name FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario) {
            //Account centroCaixa = CIBE_TestHelper.createCaixaCenter();
            Account cliente = CIBE_TestHelper.createCustomer();
            Contact empleado  = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :usuario.Id];
        


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
        
            RecordType rtTsk = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
            RecordType rtEvent = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);

            Task task = CIBE_TestHelper.createTareaOrigenApp(usuario, rtTsk);
            
            Opportunity opp =  CIBE_TestHelper.createOpportunityExternalId(cliente, empleado, task.AV_ExternalID__c);
                        
            Event event = new Event();
            event.Subject = 'Test Event 001-A - Outlook';
            event.RecordTypeId = rtEvent.Id;
            event.DurationInMinutes = 60;
            event.ActivityDateTime = System.now();
            event.Location = 'Outlook';
            event.OwnerId = usuario.Id;
            event.AV_ExternalID__c=task.AV_ExternalID__c;
            event.CSBD_Evento_Estado__c= CIBE_AppConstants.EVENT_STATUS_PENDIENTE;
            event.Description = 'Prueba texto descripcion outlook: https://pexip.me/teams';
            
            insert event;

        }
        Test.stopTest();
    }
    /***********************************************************************************************************/
    
    @isTest
    public static void createDataCIB() {
        List<String> lstPSet = new list<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP, CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
        User usrTest = CIBE_TestHelper.loginUser(CIBE_AppConstants.CIBE_GESTOR,'','',lstPSet);
        User usuario = [SELECT Id, name, Profile.name FROM User WHERE AV_ExternalID__c = 'U0000001'];

         Test.startTest(); 
         System.runAs(usuario){

            //Opportunity opp = [select id from opportunity limit 1];
        
            //AV_HeaderCustomActivity__c listHeaderTask = [Select id, AV_ExternalID__c from AV_HeaderCustomActivity__c];
            //AV_CustomActivityOpportunity__c cao = CIBE_TestHelper.createTareaOportunidad(opp,listHeaderTask.id);
            //Task tareaAlerta = CIBE_TestHelper.createTareaOtherExternalID(usuario);           
            
            //Task task2= [select id, Description, AV_CodigoGestorAsignado__c, ActivityDate,subject from Task WHERE Recordtype.DeveloperName =:CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT limit 1];
            RecordType rt = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_EMP_RT);
		    Task tarea  = new Task();
            tarea.Subject = 'Llamada  SalienteTest';
            tarea.OwnerId = usuario.Id;
            tarea.Status = 'Gestionada positiva	';
            tarea.Priority = 'High';
            tarea.AV_ExternalID__c = '01928361';
            tarea.RecordTypeId = rt.Id;
            tarea.ActivityDate = System.today()-3;
            insert tarea;
            
            delete tarea;
            
            List<Task> listaTask = [SELECT id from Task where Subject = 'Prueba borrado'];
            System.assertEquals(0,listaTask.size());
        }
       
		Test.stopTest();
    }
    
    @isTest
    public static void updateNextManagementDateOppTest() {
        Test.startTest(); 
        Date fecha;
        Task task = new Task();
        User usuario = [SELECT Id, name, Profile.name FROM User WHERE AV_ExternalID__c = 'U0000001'];
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
    @isTest
    public static void deleteRelationsTest(){
        User usuario = [SELECT Id, name, Profile.name FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();

        System.runAs(usuario){

            Task tsk = [SELECT Id, AV_Task__c, AV_ExternalId__c FROM Task WHERE Subject = 'Llamada Saliente'];
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial'];
            AV_CustomActivityOpportunity__c cao = CIBE_TestHelper.createTareaOportunidadExt(opp, tsk.AV_ExternalId__c);

            List<AV_CustomActivityOpportunity__c> relacionado = [SELECT Id, AV_Task__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :tsk.AV_Task__c];
            System.assert(!relacionado.isEmpty());
            delete tsk;
            List<AV_CustomActivityOpportunity__c> relacionado2 = [SELECT Id, AV_Task__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :tsk.AV_Task__c];
            System.assert(relacionado2.isEmpty());
            List<Task> tsk1 = [SELECT Id FROM Task WHERE Subject = 'Llamada Saliente'];
            System.assert(tsk1.isEmpty());

        }
        Test.stoptest(); 
    }
    
    @isTest
    public static void validateDeleteTaskTest(){
        User usuario = [SELECT Id, name, Profile.name FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();

        System.runAs(usuario){
            RecordType rtTskCIB = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT);

            Task tarea  = new Task();
            tarea.Subject = 'Llamada SalienteTest2';
            tarea.OwnerId = usuario.Id;
            tarea.Status = 'Pendiente no localizado';
            tarea.Priority = 'Normal';
            tarea.AV_OrigenApp__c = ' ';
            tarea.AV_ExternalID__c = '01928360';
            tarea.RecordTypeId = rtTskCIB.Id;
            tarea.ActivityDate = System.today()-1;
            tarea.AV_ToDelete__c = false;
            insert tarea;

            delete tarea;

            List<Task> tsk1 = [SELECT Id FROM Task WHERE Subject = 'Llamada SalienteTest2'];
            System.assert(tsk1.isEmpty());

        }
        Test.stoptest(); 
    }
    
}