@isTest
public with sharing class CIBE_TaskReport_Controller_Test {

    @TestSetup
    static void makeData(){
        CIBE_TestInitialSetup.setupInitialDataEMP();
        User usuario = [SELECT Id, name, Profile.name FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario){
            Contact empleado  = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :usuario.Id];
            Account acc = CIBE_TestHelper.createCustomer();
            RecordType rtTsk = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
            Task tsk = CIBE_TestHelper.createTareaOrigenApp(usuario, rtTsk);
            
            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.AV_ExternalID__c = tsk.AV_ExternalID__c;
            opp.Name = 'Alerta Comercial';
            opp.StageName = 'En curso';
            opp.RecordTypeId = rt.Id;
            opp.CloseDate = System.today() + 5;
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp.AV_Gestor__c = empleado.Id;
            opp.AV_PF__c = prodPF.Id;
            opp.OwnerId = usuario.Id;
            insert opp;
        }
    }


    @isTest
    static void updateCurrentTaskTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            Task tsk = [SELECT Id FROM Task WHERE Subject = 'Llamada Saliente'];
            CIBE_TaskReport_Controller.updateCurrentTask(tsk.Id, 'Gestionada positiva');
            Task tskUpdate = [SELECT Id, Status FROM Task WHERE Id = :tsk.Id];
            System.assertEquals('Gestionada positiva', tskUpdate.Status);
            Test.stopTest();
        }
    }   

    @isTest
    static void getTaskDataTest() {
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            Task tsk = [SELECT Id, AV_ExternalId__c FROM Task WHERE Subject = 'Llamada Saliente'];
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Alerta Comercial'];
            AV_CustomActivityOpportunity__c cao = CIBE_TestHelper.createTareaOportunidadExt(opp, tsk.AV_ExternalId__c);
            CIBE_TaskReport_Controller.TaskWrapper tarea = CIBE_TaskReport_Controller.getTaskData(tsk.Id);
            System.assert(tarea != null);
            Test.stopTest();
        }
    }   
    
}