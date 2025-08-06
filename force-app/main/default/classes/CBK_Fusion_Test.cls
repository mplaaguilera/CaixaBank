@isTest
public class CBK_Fusion_Test {
    @isTest
    public static void Test_Merge() {
        
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account a1 = New Account(Name='Test 1',RecordTypeId=cuentaRecordTypeId);
        insert a1;       
        Account a2 = New Account(Name='Test 2',RecordTypeId=cuentaRecordTypeId);
        insert a2;
        
        CBK_Fusion__c fus = New CBK_Fusion__c(
            Id_Principal__c = a1.Id,
            Id_Secundario__c = a2.Id,
            Tipo__c = 'Merge',
        	Entidad__c ='Account');
        insert fus;
        
        test.startTest();
        CBK_Fusion.exec(fus.Id);
        fus = [Select Id,Resultado__c,Error__c,Pendiente__c from CBK_Fusion__c where Id=:fus.Id];
        System.assertNotEquals(true,fus.Pendiente__c);
        System.assertNotEquals(true,fus.Error__c);
        test.stopTest();
    }
    
    @isTest
    public static void Test_Merge_Error() {
        
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account a1 = New Account(Name='Test 1',RecordTypeId=cuentaRecordTypeId);
        insert a1;       
        
        CBK_Fusion__c fus = New CBK_Fusion__c(
            Id_Principal__c = a1.Id,
            Tipo__c = 'Merge',
        	Entidad__c ='Account');
        insert fus;
        
        test.startTest();
        CBK_Fusion.exec(fus.Id);
        fus = [Select Id,Resultado__c,Error__c,Pendiente__c from CBK_Fusion__c where Id=:fus.Id];
        System.assertNotEquals(true,fus.Pendiente__c);
        System.assertNotEquals(false,fus.Error__c);
        test.stopTest();
    }
    
    @isTest
    public static void Test_Merge_Fields() {
        
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account a1 = New Account(Name='Test 1',RecordTypeId=cuentaRecordTypeId);
        insert a1;       
        Account a2 = New Account(Name='Test 2',RecordTypeId=cuentaRecordTypeId,Phone='600000000');
        insert a2;
        
        CBK_Fusion__c fus = New CBK_Fusion__c(
            Id_Principal__c = a1.Id,
            Id_Secundario__c = a2.Id,
            Tipo__c = 'Merge_Fields',
        	Entidad__c ='Account');
        insert fus;
        
        test.startTest();
        CBK_Fusion.exec(fus.Id);
        fus = [Select Id,Resultado__c,Error__c,Pendiente__c from CBK_Fusion__c where Id=:fus.Id];
        System.assertNotEquals(true,fus.Pendiente__c);
        System.assertNotEquals(true,fus.Error__c);
        test.stopTest();
    }

    @isTest
    public static void Test_Merge_NULLS() {
        
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account a1 = New Account(Name='Test 1',RecordTypeId=cuentaRecordTypeId);
        insert a1;       
        Account a2 = New Account(Name='Test 2',RecordTypeId=cuentaRecordTypeId,Phone='600000000');
        insert a2;
        
        CBK_Fusion__c fus = New CBK_Fusion__c(
            Id_Principal__c = a1.Id,
            Id_Secundario__c = a2.Id,
            Tipo__c = 'Merge_NULLS',
        	Entidad__c ='Account');
        insert fus;
        
        test.startTest();
        CBK_Fusion.exec(fus.Id);
        fus = [Select Id,Resultado__c,Error__c,Pendiente__c from CBK_Fusion__c where Id=:fus.Id];
        System.assertNotEquals(true,fus.Pendiente__c);
        System.assertNotEquals(true,fus.Error__c);
        test.stopTest();
    }
    
    @isTest
    public static void Test_Apex() {
        
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account a1 = New Account(Name='Test 1',RecordTypeId=cuentaRecordTypeId);
        insert a1;       
        Account a2 = New Account(Name='Test 2',RecordTypeId=cuentaRecordTypeId);
        insert a2;
        
        CBK_Fusion__c fus = New CBK_Fusion__c(
            Id_Principal__c = a1.Id,
            Id_Secundario__c = a2.Id,
            Tipo__c = 'APEX',
            ApexClass__c ='CBK_fusion_custom',
        	Entidad__c ='Account');
        insert fus;
        
        test.startTest();
        CBK_Fusion.exec(fus.Id);
        fus = [Select Id,Resultado__c,Error__c,Pendiente__c from CBK_Fusion__c where Id=:fus.Id];
        System.assertNotEquals(true,fus.Pendiente__c);
        System.assertNotEquals(true,fus.Error__c);
        test.stopTest();
    }
 

    @isTest
    public static void Test_Config() {
        
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account a1 = New Account(Name='Test 1',RecordTypeId=cuentaRecordTypeId);
        insert a1;       
        Account a2 = New Account(Name='Test 2',RecordTypeId=cuentaRecordTypeId);
        insert a2;
        
        CBK_Fusion__c fus = New CBK_Fusion__c(
            Id_Principal__c = a1.Id,
            Id_Secundario__c = a2.Id,
            Config__c='Fusion_Confidenciales');
        insert fus;
        
        test.startTest();
        CBK_Fusion.exec(fus.Id);
        fus = [Select Id,Resultado__c,Error__c,Pendiente__c from CBK_Fusion__c where Id=:fus.Id];
        System.assertNotEquals(true,fus.Pendiente__c);
        System.assertNotEquals(true,fus.Error__c);
        test.stopTest();
    }

    @isTest
    public static void Test_Split_Confidenciales() {
        
        Id cuentaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account a1 = New Account(Name='Test 1',AV_NumPerso__c='999999',CC_NumPerso__c='999999', RecordTypeId=cuentaRecordTypeId);
        insert a1;       
        
        CBK_Fusion__c fus = New CBK_Fusion__c(
            Id_Principal__c = a1.Id,
            Tipo__c = 'APEX',
            ApexClass__c ='CBK_Split_confidenciales',
        	Entidad__c ='Account');
        insert fus;
        
        test.startTest();
        CBK_Fusion.exec(fus.Id);
        fus = [Select Id,Resultado__c,Error__c,Pendiente__c from CBK_Fusion__c where Id=:fus.Id];
        System.assertNotEquals(true,fus.Pendiente__c);
        System.assertNotEquals(true,fus.Error__c);
        test.stopTest();
    }
}