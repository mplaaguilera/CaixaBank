@isTest
public class CC_Grupo_Colaborador_Contact_AI_Test {

    @isTest
    public static void anadirUsuario() {

        //GRUPO COLABORADOR
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.Name = 'Grupo Trabajo Prueba';
        grupoColaborador.OS_GrupoTrabajo__c = 'Grupo Trabajo Prueba';
        grupoColaborador.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('OS_GrupoTrabajo').getRecordTypeId();
        insert grupoColaborador;

        //USUARIO
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'OS_Responsable'].Id,
            LastName = 'last',
            Email = 'test@gmail.com',
            Username = 'test@gmail.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;

        Group grupoPublico = new Group();
        grupoPublico.Name = 'Grupo Trabajo Prueba';
        grupoPublico.Type = 'Regular';
        insert grupoPublico;

        //COLABORADOR
        CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c();
        colaborador.CC_Usuario__c = u.Id;
        colaborador.CC_Grupo_Colaborador__c = grupoColaborador.Id;

        Test.startTest();
        insert colaborador;
        Test.stopTest();

        List<GroupMember> listaGrupMmebers = [SELECT Id, Group.DeveloperName, UserOrGroupId FROM GroupMember WHERE Group.Type = 'Regular' AND UserOrGroupId = :u.Id];
        System.assertNotEquals(null, listaGrupMmebers);

    }

    @isTest
    public static void updateUser(){

        //GRUPO COLABORADOR
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.Name = 'Grupo Trabajo Prueba';
        grupoColaborador.OS_GrupoTrabajo__c = 'Grupo Trabajo Prueba';
        grupoColaborador.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('OS_GrupoTrabajo').getRecordTypeId();
        insert grupoColaborador;

        //USUARIO
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'OS_Responsable'].Id,
            LastName = 'last',
            Email = 'test@gmail.com',
            Username = 'test@gmail.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;

        Group grupoPublico = new Group();
        grupoPublico.Name = 'Grupo Trabajo Prueba';
        grupoPublico.Type = 'Regular';
        insert grupoPublico;

        Group cola = new Group();
        cola.Name = 'Grupo Trabajo Prueba';
        cola.Type = 'Queue';
        insert cola;

        //COLABORADOR
        CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c();
        colaborador.CC_Usuario__c = u.Id;
        colaborador.CC_Grupo_Colaborador__c = grupoColaborador.Id;

        insert colaborador;

        Test.startTest();
        update colaborador;
        Test.stopTest();
    }

    @isTest
    public static void eliminarUsuario() {

        //GRUPO COLABORADOR
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.Name = 'Grupo Trabajo Prueba';
        grupoColaborador.OS_GrupoTrabajo__c = 'Grupo Trabajo Prueba';
        grupoColaborador.CC_Queue_Traslado__c = 'CC_Twitter';
        grupoColaborador.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('OS_GrupoTrabajo').getRecordTypeId();
        insert grupoColaborador;

        //USUARIO
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'OS_Responsable'].Id,
            LastName = 'last',
            Email = 'test@gmail.com',
            Username = 'test@gmail.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;

        Group grupoPublico = new Group();
        grupoPublico.Name = 'Grupo Trabajo Prueba';
        grupoPublico.Type = 'Regular';
        insert grupoPublico;

        Group cola = new Group();
        cola.Name = 'Grupo Trabajo Prueba';
        cola.Type = 'Queue';
        insert cola;

        //COLABORADOR
        CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c();
        colaborador.CC_Usuario__c = u.Id;
        colaborador.CC_Grupo_Colaborador__c = grupoColaborador.Id;

        insert colaborador;

        Test.startTest();
        delete colaborador;
        Test.stopTest();

        List<GroupMember> listaGrupMmebers = [SELECT Id, Group.DeveloperName, UserOrGroupId FROM GroupMember WHERE Group.Type = 'Regular' AND UserOrGroupId = :u.Id];
        System.assertEquals(0, listaGrupMmebers.size());

    }
}