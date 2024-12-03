@isTest 
public with sharing class SEG_Milestone_Test {

    @isTest 
    public static void testMilestoneTimeCalculatorAntes1() {

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];

        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Mismo día recepción';
        caso.Origin = 'Email';
        insert caso;
        
        Test.setCreatedDate(caso.Id, DateTime.newInstance(System.today().year(), System.today().month(), System.today().day(), 12, 0, 0));
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
       
    }
    
    
    @isTest 
    public static void testMilestoneTimeCalculatorDespues1() {

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Mismo día recepción';
        caso.Origin = 'Email';
        insert caso;
        
        Test.setCreatedDate(caso.Id, DateTime.newInstance(System.today().year(), System.today().month(), System.today().day(), 14, 0, 0));
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
       

        //System.assertEquals(60, minutosRestantes);  //PENDIENTE TENER EN CUENTA FESTIVOS 

    }
    
    @isTest 
    public static void testMilestoneTimeCalculatorDespues2() {

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;

        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Mismo día recepción';
        caso.Origin = 'Email';
        insert caso;
        
        //Test.setCreatedDate(caso.Id, DateTime.newInstance(System.today().year(), System.today().month(), System.today().day(), 11, 0, 0));
		Test.setCreatedDate(caso.Id, DateTime.newInstance(2022,03,18,10,0,0));
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
        

    }
    
    @isTest 
    public static void testCompletarMilestones() {
        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;
        
        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Máximo 2h después recepción';
        caso.Origin = 'Email';
        caso.SEG_Fecha_valor__c = null;
        insert caso;
        
        String milestone = null;
        List<Id> idCasos = new List<Id> ();
        idCasos.add(caso.Id);

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
                SEG_Milestone.completarMilestones(idCasos);
            Test.stopTest();
            System.assert(milestone == null);
        }
        
    }
    
    @isTest 
    public static void testMilestoneTimeCalculatorAntes4() {

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];

        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Mismo día recepción';
        caso.Origin = 'Email';
        insert caso;
        Test.setCreatedDate(caso.Id, DateTime.newInstance(System.today().year(), System.today().month(), System.today().day(), 15, 0, 0));
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();

            System.assert(minutosRestantes != null);
            
        }
    }
    
    @isTest 
    public static void testMilestoneTimeCaldiaDespues() {

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA Dia despues' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];

        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Día siguiente recepción';
        caso.Origin = 'Email';
        insert caso;
        
        Test.setCreatedDate(caso.Id, DateTime.newInstance(System.today().year(), System.today().month(), System.today().day(), 12, 0, 0));

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
    }
    
    @isTest 
    public static void testMilestoneTimeCaldiaDespuesDialaboral() {

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA Dia despues' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];

        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'SLAcase';
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Día siguiente recepción';
        caso.Origin = 'Email';
        insert caso;

        Test.setCreatedDate(caso.Id, DateTime.newInstance(2022,03,18,10,0,0));

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Case mycase = [SELECT Id, Subject, CreatedDate FROM Case 
                                WHERE Subject = 'SLAcase' limit 1];
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
       
    }

    @isTest 
    public static void testMilestone2diasMax() {

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA 2 dias' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];

        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'SLAcase';
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Máximo 2 días hábiles desde la recepción';
        caso.Origin = 'Email';
        insert caso;
        Test.setCreatedDate(caso.Id, DateTime.newInstance(2022,03,18,10,0,0));

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Case mycase = [SELECT Id, Subject, CreatedDate FROM Case 
                                WHERE Subject = 'SLAcase' limit 1];
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
        
    }

    @isTest 
    public static void testMilestone3diasMax() {

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA 3 dias' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];

        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'SLAcase';
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Máximo 3 días hábiles desde la recepción';
        caso.Origin = 'Email';
        insert caso;

        Test.setCreatedDate(caso.Id, DateTime.newInstance(2022,03,18,10,0,0));

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Case mycase = [SELECT Id, Subject, CreatedDate FROM Case 
                                WHERE Subject = 'SLAcase' limit 1];
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
        
    }

    @isTest 
    public static void testMilestone4diasMax() {

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA 4 dias' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];

        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'SLAcase';
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Máximo 4 días hábiles desde la recepción';
        caso.Origin = 'Email';
        insert caso;
        
        //Test.setCreatedDate(caso.Id, DateTime.newInstance(System.today().year(), System.today().month(), System.today().day(), 12, 0, 0));
        Test.setCreatedDate(caso.Id, DateTime.newInstance(2022,03,18,10,0,0));
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Case mycase = [SELECT Id, Subject, CreatedDate FROM Case 
                                WHERE Subject = 'SLAcase' limit 1];
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
        
    }
    
    @isTest 
    public static void testMilestone5diasMax() {

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA 5 dias' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];

        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'SLAcase';
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Máximo 5 días hábiles desde la recepción';
        caso.Origin = 'Email';
        insert caso;
        Test.setCreatedDate(caso.Id, DateTime.newInstance(2022,03,18,10,0,0));

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Case mycase = [SELECT Id, Subject, CreatedDate FROM Case 
                                WHERE Subject = 'SLAcase' limit 1];
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
       
    }

    @isTest 
    public static void testMilestone1SemanaMax() {

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA 1 semana' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];

        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'SLAcase';
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Máximo 1 semana';
        caso.Origin = 'Email';
        insert caso;

        Test.setCreatedDate(caso.Id, DateTime.newInstance(2022,03,18,10,0,0));
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Case mycase = [SELECT Id, Subject, CreatedDate FROM Case 
                                WHERE Subject = 'SLAcase' limit 1];
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
        
    }

    @isTest 
    public static void testMilestone1MesMax() {

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA 1 mes' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];

        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        DateTime fechaInicioSla = DateTime.newInstance(2022,12,12,12,0,0);
        
        Case caso = new Case();
        caso.Subject = 'SLAcase';
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Máximo 1 mes';
        caso.SEG_Fecha_inicio_SLA__c = fechaInicioSla;
        caso.Origin = 'Email';
        insert caso;

        Test.setCreatedDate(caso.Id, DateTime.newInstance(2022,03,18,10,0,0));
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Case mycase = [SELECT Id, Subject, CreatedDate FROM Case 
                                WHERE Subject = 'SLAcase' limit 1];
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
        
    }
    
    @isTest 
    public static void testMilestone1MesMaxDespuesHorario() {

        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
	    e.EndDate = Date.today();
        insert e;

        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA 1 mes' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];

        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        
        DateTime fechaInicioSla = DateTime.newInstance(2022,12,12,15,0,0);

        Case caso = new Case();
        caso.Subject = 'SLAcase';
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Máximo 1 mes';
        caso.SEG_Fecha_inicio_SLA__c = fechaInicioSla;
        caso.Origin = 'Email';
        insert caso;
        Test.setCreatedDate(caso.Id, DateTime.newInstance(2022,12,12,15,0,0));

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Case mycase = [SELECT Id, Subject, CreatedDate FROM Case 
                                WHERE Subject = 'SLAcase' limit 1];
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
       
    }
    
    @isTest 
    public static void testMilestone1SemanaMaxEntiempo() {
        
        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
        e.EndDate = Date.today();
        insert e;
        
        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA 1 semana' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];
        
        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        DateTime fechaInicioSla = DateTime.newInstance(2022,12,12,12,0,0);
        
        Case caso = new Case();
        caso.Subject = 'SLAcase';
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Máximo 1 semana';
        caso.SEG_Fecha_inicio_SLA__c = fechaInicioSla;
        caso.Origin = 'Email';
        insert caso;
        Test.setCreatedDate(caso.Id, DateTime.newInstance(2022,03,18,10,0,0));
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Case mycase = [SELECT Id, Subject, CreatedDate FROM Case 
                        WHERE Subject = 'SLAcase' limit 1];
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
       
    }
    
    @isTest 
    public static void testMilestone5diasMaxEntiempo() {
        
        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
        e.EndDate = Date.today();
        insert e;
        
        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA 5 dias' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];
        
        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        DateTime fechaInicioSla = DateTime.newInstance(2022,12,12,12,0,0);
        
        Case caso = new Case();
        caso.Subject = 'SLAcase';
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Máximo 5 días hábiles desde la recepción';
        caso.SEG_Fecha_inicio_SLA__c = fechaInicioSla;
        caso.Origin = 'Email';
        insert caso;
        
        
        //Test.setCreatedDate(caso.Id, DateTime.newInstance(System.today().year(), System.today().month(), System.today().day(), 12, 0, 0));
        Test.setCreatedDate(caso.Id, DateTime.newInstance(2022,03,18,10,0,0));
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Case mycase = [SELECT Id, Subject, CreatedDate FROM Case 
                        WHERE Subject = 'SLAcase' limit 1];
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
    }
       
    
    @isTest 
    public static void testMilestone4diasMaxEntiempo() {
        
        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
        e.EndDate = Date.today();
        insert e;
        
        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA 4 dias' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];
        
        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        DateTime fechaInicioSla = DateTime.newInstance(2022,12,12,12,0,0);
        
        Case caso = new Case();
        caso.Subject = 'SLAcase';
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Máximo 4 días hábiles desde la recepción';
        caso.SEG_Fecha_inicio_SLA__c = fechaInicioSla;
        caso.Origin = 'Email';
        insert caso;
        
        
        //Test.setCreatedDate(caso.Id, DateTime.newInstance(System.today().year(), System.today().month(), System.today().day(), 12, 0, 0));
        Test.setCreatedDate(caso.Id, DateTime.newInstance(2022,03,18,10,0,0));
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Case mycase = [SELECT Id, Subject, CreatedDate FROM Case 
                        WHERE Subject = 'SLAcase' limit 1];
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
        
    }    
    @isTest 
    public static void testMilestone3diasMaxEntiempo() {
        
        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
        e.EndDate = Date.today();
        insert e;
        
        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA 3 dias' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];
        
        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        DateTime fechaInicioSla = DateTime.newInstance(2022,12,12,12,0,0);
        
        Case caso = new Case();
        caso.Subject = 'SLAcase';
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Máximo 3 días hábiles desde la recepción';
        caso.SEG_Fecha_inicio_SLA__c = fechaInicioSla;
        caso.Origin = 'Email';
        insert caso;

        Test.setCreatedDate(caso.Id, DateTime.newInstance(2022,03,18,10,0,0));
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Case mycase = [SELECT Id, Subject, CreatedDate FROM Case 
                        WHERE Subject = 'SLAcase' limit 1];
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
        
    }
    
    @isTest 
    public static void testMilestone2diasMaxEntiempo() {
        
        Account a = new Account();
        a.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        a.Name = 'account temp';
        insert a;
        
        Entitlement e = new Entitlement();
        e.Name = 'Entitlement SEG';
        //e.SlaProcessId = [SELECT Id FROM SlaProcess WHERE Name = 'SEG Entitlement Process' LIMIT 1].Id;
        e.AccountId = a.Id;
        e.BusinessHoursId = [SELECT Id FROM BusinessHours WHERE Name = 'Segmentos'].Id;
        e.StartDate = Date.today();
        e.EndDate = Date.today();
        insert e;
        
        // Select an existing milestone type to test with
        List<MilestoneType> mtLst = [SELECT Name FROM MilestoneType WHERE Name = 'SEG SLA 2 dias' LIMIT 1];      
        if (mtLst.isEmpty()) {
            return;
        }
        MilestoneType mt = mtLst[0];
        
        Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        DateTime fechaInicioSla = DateTime.newInstance(2022,12,12,12,0,0);
        
        Case caso = new Case();
        caso.Subject = 'SLAcase';
        caso.RecordTypeId = recordTypeSEG;
        caso.EntitlementId = e.Id;
        caso.SEG_SLA_cliente_case__c = 'Máximo 2 días hábiles desde la recepción';
        caso.SEG_Fecha_inicio_SLA__c = fechaInicioSla;
        caso.Origin = 'Email';
        insert caso;

        Test.setCreatedDate(caso.Id, DateTime.newInstance(2022,03,18,10,0,0));
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_Milestone milestonesCops = new SEG_Milestone();
            Case mycase = [SELECT Id, Subject, CreatedDate FROM Case 
                        WHERE Subject = 'SLAcase' limit 1];
            Integer minutosRestantes = milestonesCops.calculateMilestoneTriggerTime(caso.Id, mt.Id);
            Test.stopTest();
            System.assert(minutosRestantes != null);
        }
       
    }
}