@isTest
public with sharing class TMS_Case_AU_TRHan_Test {
    
     @TestSetup
    public static void crearDatosPrueba() {
        
        User uTMS = TMS_Usuarios.usuarioAdminTMS();

        User uLetrado = TMS_Usuarios.usuarioLetrado();
        


        List<Account> cuentasInsertar = new List<Account>();

        Account oficinaGestora1 = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId(), 
            LastName = 'Cuenta oficina gestora', 
            CC_Email__c = 'test@test.com',
            AV_Confidencial__c = false,
            CC_Numero_Oficina__c = '00001');
        cuentasInsertar.add(oficinaGestora1);

        Account oficinaGestora2 = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId(), 
            LastName = 'Cuenta oficina gestora 2', 
            CC_Email__c = 'test2@test.com',
            AV_Confidencial__c = false,
            CC_Numero_Oficina__c = '00002');
        cuentasInsertar.add(oficinaGestora2); 

        insert cuentasInsertar;

        List<Case> casosInsert = new List<Case>();

        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TMS_Expediente').getRecordTypeId();
        caso.Subject = 'Caso TMS 1999-9393994';
        caso.Origin = 'Backend';
        caso.CC_Canal_Procedencia__c = 'Testamentarias';
        caso.TMS_Numexp__c = '11111111';
        caso.TMS_Gestoria__c = '5';
        caso.CC_Tipo_Contacto__c='Gestión expediente';
        caso.Status='TMS_001';
        caso.AccountId = oficinaGestora1.Id;
        caso.OwnerId = uLetrado.Id;
        casosInsert.add(caso);

        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TMS_Expediente').getRecordTypeId();
        caso2.Subject = 'Caso TMS 1999-9393995';
        caso2.Origin = 'Backend';
        caso2.CC_Canal_Procedencia__c = 'Testamentarias';
        caso2.TMS_Numexp__c = '11111112';
        caso2.TMS_Gestoria__c = '5';
        caso2.CC_Tipo_Contacto__c='Gestión expediente';
        caso2.Status='TMS_001';
        caso2.AccountId = oficinaGestora1.Id;
        caso2.OwnerId = uTMS.Id;
        casosInsert.add(caso2);
        
        insert casosInsert;

        List<AccountShare> accountList = new List<AccountShare>();

        AccountShare acshare = new AccountShare();
        acshare.AccountId = oficinaGestora1.Id;
        acshare.UserOrGroupId = uTMS.Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        accountList.add(acshare);

        AccountShare acshare2 = new AccountShare();
        acshare2.AccountId = oficinaGestora2.Id;
        acshare2.UserOrGroupId = uTMS.Id;
        acshare2.AccountAccessLevel = 'Edit';
        acshare2.OpportunityAccessLevel = 'Edit';
        acshare2.CaseAccessLevel = 'Edit';
        accountList.add(acshare2);

        insert accountList;

        List<CaseShare> csList = new List<CaseShare>();

        CaseShare csNuevo2 = new CaseShare();
        csNuevo2.CaseId = caso.Id;
        csNuevo2.UserOrGroupId = uTMS.Id;
        csNuevo2.CaseAccessLevel='Edit';
        csList.add(csNuevo2);
    

        insert csList;
        
    }
    
    @isTest
    static void testUpdateCuenta(){
        
        
        User us = [SELECT Id FROM User WHERE Alias = 'adminTMS'];
        Account nuevaCuenta = [SELECT Id FROM Account WHERE CC_Email__c = 'test2@test.com' LIMIT 1];
        System.runAs (us){
            List<Case> caso = [SELECT Id, AccountId FROM Case WHERE Subject = 'Caso TMS 1999-9393995'];
            caso[0].AccountId= nuevaCuenta.Id;
            
            Test.startTest();
            update caso;
            Test.stopTest();

            List<Task> tareasCaso =[SELECT Id FROM Task WHERE Type = 'Cambio de heredero'AND WhatId = :caso[0].Id and Status='Completed'];
            
            System.AssertNotEquals(0, tareasCaso.size());
        }
    }
     @isTest
    static void testUpdateOwner(){
        
        User us =  [SELECT Id FROM User WHERE Alias = 'adminTMS'];
        User letradoTMS = [SELECT Id FROM User WHERE Alias = 'LetTMS' AND IsActive = true LIMIT 1];
        //User letradoTMS = TMS_Usuarios.usuarioLetrado();
        System.runAs (us){
           
            Test.startTest();
            List<Case> caso = [SELECT Id, OwnerId, TMS_Gestoria__c, RecordType.DeveloperName FROM Case WHERE Subject = 'Caso TMS 1999-9393994'];
            caso[0].OwnerId= us.Id;

            update caso;

            List<Task> tareasCaso =[SELECT Id FROM Task WHERE Type = 'Reasignación' AND WhatId = :caso[0].Id and Status='Completed'];
            System.AssertNotEquals(0, tareasCaso.size());

            Test.stopTest();
        }
    }
   
}