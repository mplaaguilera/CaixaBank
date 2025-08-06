/**********************************************************************************************************************
Name: AV_GenerateRecordsManHistoryQueueableTest
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test para la clase AV_GenerateRecordsManHistoryQueueable
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY			AUTHOR              	DATE                Description
	1.0            FIX SCRIPT       	Vladislav Lityagin      10/01/2023          Init version

***********************************************************************************************************************/
@isTest
public with sharing class AV_GenerateRecordsManHistQueueableTest {
    @TestSetup
    static void setup(){
        AV_TestHelper.activateLogger();
        Account centroCaixa = AV_TestHelper.createCaixaCenter();
        Account accTest = AV_TestHelper.createCustomer();
		User user = AV_TestHelper.createUser(null);
		Contact employee = AV_TestHelper.createEmployee(centroCaixa, user);
        Account client = AV_TestHelper.createCustomerWithNumperson('000000001');
        AV_TestHelper.createPricebook2();
        AV_TestHelper.createTarea(user);
        AV_LimitBook__c cs = new AV_LimitBook__c();
        cs.AV_Limit__c= 10;
        cs.AV_LimitReassignment__c = 9;
        insert cs;
    }

    @isTest
    public static void generateRecordsManHistQueueableTest() {
        Test.startTest();  
        AV_GenerateRecordsEventQueueable.doChainJob = true;
        User user = [SELECT ID FROM USER WHERE ID IN (SELECT AV_UsuarioAsociado__c FROM Contact) LIMIT 1];
        Account client = [SELECT ID FROM ACCOUNT WHERE AV_Numperso__c = '000000001' LIMIT 1];
        Contact employee = [SELECT ID FROM CONTACT WHERE AV_UsuarioAsociado__c = :user.Id LIMIT 1];
        Task tarea = [SELECT Id FROM Task LIMIT 1];
        
        Date fecha = System.Date.today();
        DateTime hora = System.Datetime.now();
        List<AV_ManagementHistory__c> listManHist = new List<AV_ManagementHistory__c>();
        for (integer i=0; i<15; i++) {
    		AV_ManagementHistory__c historial = new AV_ManagementHistory__c (
            AV_ActivityId__c = tarea.id, 
            AV_Comment__c = 'Prueba historial de gestion',
            AV_Status__c = 'Gestionada positiva',
            AV_Date__c = fecha,
            AV_Reminder__c = hora
        	);
            listManHist.add(historial);
		}
        
        System.enqueueJob(new AV_GenerateRecordsManHistoryQueueable(listManHist, new List<AV_CustomActivityOpportunity__c>(),false));
        Test.stopTest();
        
        List<AV_ManagementHistory__c> listMH = [SELECT Id FROM AV_ManagementHistory__c LIMIT 10];
        System.assert(!listMH.isEmpty());
    }
    
   @isTest
    public static void generateRecordsManHistQueueableTest2() {
        Test.startTest();  
        AV_GenerateRecordsEventQueueable.doChainJob = true;
        User user = [SELECT ID FROM USER WHERE ID IN (SELECT AV_UsuarioAsociado__c FROM Contact) LIMIT 1];
        Account client = [SELECT ID FROM ACCOUNT WHERE AV_Numperso__c = '000000001' LIMIT 1];
        Contact employee = [SELECT ID FROM CONTACT WHERE AV_UsuarioAsociado__c = :user.Id LIMIT 1];
        Task tarea = [SELECT Id FROM Task LIMIT 1];
                
        Date fecha = System.Date.today();
        DateTime hora = System.Datetime.now();
        AV_ManagementHistory__c historial = new AV_ManagementHistory__c (
            AV_ActivityId__c = tarea.id, 
            AV_Comment__c = 'Prueba historial de gestion',
            AV_Status__c = 'Gestionada positiva',
            AV_Date__c = fecha,
            AV_Reminder__c = hora
        );
          
        System.enqueueJob(new AV_GenerateRecordsManHistoryQueueable(new List<AV_ManagementHistory__c>(), new List<AV_CustomActivityOpportunity__c>(),true));
        Test.stopTest();
        
        List<AV_ManagementHistory__c> listMH = [SELECT Id FROM AV_ManagementHistory__c LIMIT 10];
        System.assert(!listMH.isEmpty());
    }
}