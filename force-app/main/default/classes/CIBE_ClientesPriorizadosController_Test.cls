/**********************************************************************************************************************
Name: CIBE_ClientesPriorizadosController_Test
Copyright © 2023  CaixaBank
------------------------------------------------ -----------------------------------------------------------------------
Proposito: Clase test de la clase CIBE_ClientesPriorizadosController
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY 				AUTHOR              DATE                Description
    1.0            US588247    		        Lucia Muñoz         07/09/2023           Init version
***********************************************************************************************************************/

@IsTest
public with sharing class CIBE_ClientesPriorizadosController_Test {

    @TestSetup
    static void setUp(){

        CIBE_TestInitialSetup.setupInitialDataEMP();

        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ONBOARDING_EMP_RT);
        RecordType rtAccGC = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_G_COMERCIAL_RT);
        RecordType rtAcc = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        Id rtRole = Schema.SObjectType.FinServ__ReciprocalRole__c.getRecordTypeInfosByDeveloperName().get('AccountRole').getRecordTypeId();
        Id rtAccR = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();



        System.runAs(new User(Id = UserInfo.getUserId())){

            Account acc = new Account(
                Name = 'Test Account 1',
                RecordTypeId = rtAcc.Id,
                AV_NumPerso__c = '123',
                AV_Negocio__c = 'CIB'
            );
            insert acc;

            Task tarea  = new Task();
            tarea.Subject = 'Test 1';
            tarea.OwnerId = u.Id;
            tarea.Status = 'Pendiente no localizado';
            tarea.Priority = 'Normal';
            tarea.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
            tarea.AV_ExternalID__c = '00000001';
            tarea.RecordTypeId = rt.Id;
            tarea.ActivityDate = System.today();
            tarea.AV_ToDelete__c = false;
            tarea.WhatId = acc.Id;
            insert tarea; 

            Account accGC = new Account(
                Name = 'Grupo Comercial Test',
                RecordTypeId = rtAccGC.Id,
                AV_InterlocName__c = 'Grupo Comercial Test',
                OwnerId = u.Id
            );
            insert accGC;

            FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c  (
                Name = 'Parent',
                RecordTypeId = rtRole,
                FinServ__InverseRole__c = 'Child'
            );

            insert role;

            FinServ__AccountAccountRelation__c  relation = new FinServ__AccountAccountRelation__c (
                FinServ__Account__c = accGC.Id,
                FinServ__RelatedAccount__c = tarea.WhatId,
                FinServ__Role__c = role.Id,
                OwnerId = u.Id,
                RecordTypeId = rtAccR

            );
            insert relation;
        }
    }

    @IsTest
    static void getDataTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP'];
        List<Id> selectedIds = new List <Id>();

        CIBE_ClientesPriorizadosController.Filters filters = new CIBE_ClientesPriorizadosController.Filters();
        filters.subjectFilterValue = 'Test';
        String mainClickFilter = 'CIBE_OnboardingEMP';

        System.runAs(usuario){
            Task t = [SELECT Id, AccountId FROM Task WHERE Subject = 'Test 1' AND AV_ExternalID__c = '00000001' AND RecordType.DeveloperName = :CIBE_AppConstants.TASK_ONBOARDING_EMP_RT LIMIT 1];
            System.assert (t != null);
            List<Account> accGC = [SELECT Id FROM Account WHERE Name = 'Grupo Comercial Test' AND RecordType.DeveloperName = :CIBE_AppConstants.ACCOUNT_G_COMERCIAL_RT];
            System.assert (!accGC.isEmpty());
            for (Account a : accGC) {
                selectedIds.add(a.Id);
            }

            Test.startTest();
            List<CIBE_ClientesPriorizadosController.Wrapper> results = CIBE_ClientesPriorizadosController.getData(filters, selectedIds, mainClickFilter);
            System.assert(!results.isEmpty());
            Test.stopTest();
        }

    }

    @IsTest
    static void searchGrupoComercialTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND UserRole.DeveloperName = 'EMP' AND CreatedDate = TODAY AND CreatedBy.Id = :UserInfo.getUserId()];
        System.runAs(usuario){
            Test.startTest();
                Account a = [SELECT Id, Name FROM Account WHERE Name = 'Grupo Comercial Test' AND recordType.DeveloperName = 'CIBE_GrupoComercial' AND CreatedDate = TODAY];
                System.assert(a != null);
                System.debug('@@@ ' + a);
                List<AV_LookupSearchResult> results = CIBE_ClientesPriorizadosController.searchGrupoComercial('Grupo');
                System.assert(!results.isEmpty());
            Test.stopTest();
        }

    }
    


}