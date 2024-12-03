@isTest
public with sharing class CC_Grupo_Colaborador_Test {
    private static Id centroRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
    private static Id caracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Centro_CaixaBank').getRecordTypeId();
    @isTest
    public static void insertCuentaOF() {
        Account cuenta = new Account(
            Name = 'Centro Test',
            RecordTypeId = centroRecordTypeId,
            CC_Tipo_Centro__c = 'OF'
        );
        insert cuenta;

        List<Account> cuentaId = new List<Account>{cuenta};
        CC_Grupo_Colaborador.tratarGrupo(cuentaId);
        List<CC_Grupo_Colaborador__c> grupos = [SELECT Name FROM CC_Grupo_Colaborador__c WHERE CC_Cuenta__c = :cuenta.Id];
        System.assertEquals(1, grupos.size());
        System.assertEquals('Centro Test', grupos[0].Name);
    }

    @isTest 
    public static void updateCuentaOF() {
        Account cuenta = new Account(
            Name = 'Centro Test 1',
            RecordTypeId = centroRecordTypeId,
            CC_Tipo_Centro__c = 'OF'
        );
        insert cuenta;

        List<Account> cuentaId = new List<Account>{cuenta};
        CC_Grupo_Colaborador.tratarGrupo(cuentaId);

        cuenta.Name = 'Centro Test 2';
        update cuenta;

        CC_Grupo_Colaborador.tratarGrupo(cuentaId);
        List<CC_Grupo_Colaborador__c> grupos = [SELECT Name FROM CC_Grupo_Colaborador__c WHERE CC_Cuenta__c = :cuenta.Id];
        System.assertEquals(1, grupos.size());
        System.assertEquals('Centro Test 2', grupos[0].Name);
    }
    @isTest
    public static void insertCuentaGC() {
        Account cuenta = new Account(
            Name = 'Centro Test',
            RecordTypeId = centroRecordTypeId,
            CC_Tipo_Centro__c = 'GC'
        );
        insert cuenta;

        List<Account> cuentaId = new List<Account>{cuenta};
        CC_Grupo_Colaborador.tratarGrupo(cuentaId);
        List<CC_Grupo_Colaborador__c> grupos = [SELECT Name FROM CC_Grupo_Colaborador__c WHERE CC_Cuenta__c = :cuenta.Id];
        System.assertEquals(1, grupos.size());
        System.assertEquals('Centro Test', grupos[0].Name);
    }

    @isTest 
    public static void updateCuentaGC() {
        Account cuenta = new Account(
            Name = 'Centro Test 1',
            RecordTypeId = centroRecordTypeId,
            CC_Tipo_Centro__c = 'GC'
        );
        insert cuenta;

        List<Account> cuentaId = new List<Account>{cuenta};
        CC_Grupo_Colaborador.tratarGrupo(cuentaId);

        cuenta.Name = 'Centro Test 2';
        update cuenta;

        CC_Grupo_Colaborador.tratarGrupo(cuentaId);
        List<CC_Grupo_Colaborador__c> grupos = [SELECT Name FROM CC_Grupo_Colaborador__c WHERE CC_Cuenta__c = :cuenta.Id];
        System.assertEquals(1, grupos.size());
        System.assertEquals('Centro Test 2', grupos[0].Name);
    }
    @isTest
    public static void insertCuentaNoOFNoGC() {
        Account cuenta = new Account(
            Name = 'Centro Test',
            RecordTypeId = centroRecordTypeId
        );
        insert cuenta;

        List<Account> cuentaId = new List<Account>{cuenta};
        CC_Grupo_Colaborador.tratarGrupo(cuentaId);
        List<CC_Grupo_Colaborador__c> grupos = [SELECT Name FROM CC_Grupo_Colaborador__c WHERE CC_Cuenta__c = :cuenta.Id];
        System.assertEquals(0, grupos.size());
    }

    @isTest 
    public static void updateCuentaNoOFNoGC() {
        Account cuenta = new Account(
            Name = 'Centro Test 1',
            RecordTypeId = centroRecordTypeId
        );
        insert cuenta;

        List<Account> cuentaId = new List<Account>{cuenta};
        CC_Grupo_Colaborador.tratarGrupo(cuentaId);

        cuenta.Name = 'Centro Test 2';
        update cuenta;

        CC_Grupo_Colaborador.tratarGrupo(cuentaId);
        List<CC_Grupo_Colaborador__c> grupos = [SELECT Name FROM CC_Grupo_Colaborador__c WHERE CC_Cuenta__c = :cuenta.Id];
        System.assertEquals(0, grupos.size());
    }
}