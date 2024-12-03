@isTest
public class CC_Grupo_Colaborador_Contact_Anadir_Test {
    @TestSetup
    static void makeData(){
        //List<User> listaUsuarios = [SELECT Id FROM User WHERE IsActive = true and Email like '%.com' ORDER BY UserName desc LIMIT 3];
        User u = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id,
             LastName = 'last',
             Email = 'puser000@amamama.com',
             Username = 'puser000@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        insert u;
        
        Group grupo = new Group();
        grupo.Name = 'Grupo Colaborador Test';
        grupo.DeveloperName = 'CC_Grupo_Colaborador_Test';
        grupo.Type = 'Regular'; 
        insert grupo;
        GroupMember miembroGrupo = new GroupMember();
        miembroGrupo.GroupId = grupo.Id;
        miembroGrupo.UserOrGroupId = u.Id;
        insert miembroGrupo;

        Group cola = new Group();
        cola.Name = 'Cola Test';
        cola.DeveloperName = 'CC_Cola_Test';
        cola.Type = 'Queue'; 
        insert cola;
        GroupMember miembroCola = new GroupMember();
        miembroCola.GroupId = cola.Id;
        miembroCola.UserOrGroupId = u.Id;
        insert miembroCola;
    }

    @isTest
    private static void test() {
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c();
        grupoColaborador.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        grupoColaborador.CC_Queue_Traslado__c = 'CC_Grupo_Colaborador_Test';
        grupoColaborador.CC_External__c = 'GC-00001';
        insert grupoColaborador;
        CC_Grupo_Colaborador__c grupoColaborador2 = new CC_Grupo_Colaborador__c();
        grupoColaborador2.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
        grupoColaborador2.CC_Queue_Traslado__c = 'CC_Cola_Test';
        grupoColaborador2.CC_External__c = 'GC-00002';
        insert grupoColaborador2;


        //List<User> listaUsuarios = [SELECT Id FROM User WHERE IsActive = true ORDER BY UserName LIMIT 3];
        User u = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id,
             LastName = 'last',
             Email = 'puser000@amamama.com',
             Username = 'puser000@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        insert u;

		User u2 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id,
             LastName = 'last2',
             Email = 'puser002@amamama.com',
             Username = 'puser002@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        insert u2;
        
        User u3 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id,
             LastName = 'last3',
             Email = 'puser003@amamama.com',
             Username = 'puser003@amamama.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US'
        );
        insert u3;
        List<CC_Grupo_Colaborador_Contact__c> listaGrupoColaboradorContacto = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact = new CC_Grupo_Colaborador_Contact__c();

        grupoColaboradorContact.CC_Grupo_Colaborador__c = grupoColaborador.Id;
        grupoColaboradorContact.CC_Usuario__c = u.Id;
        listaGrupoColaboradorContacto.add(grupoColaboradorContact.clone());
        grupoColaboradorContact.CC_Usuario__c = u2.Id;
        listaGrupoColaboradorContacto.add(grupoColaboradorContact.clone());

        grupoColaboradorContact.CC_Grupo_Colaborador__c = grupoColaborador2.Id;
        grupoColaboradorContact.CC_Usuario__c = u.Id;
        listaGrupoColaboradorContacto.add(grupoColaboradorContact.clone());
        grupoColaboradorContact.CC_Usuario__c = u3.Id;
        listaGrupoColaboradorContacto.add(grupoColaboradorContact.clone());
        insert listaGrupoColaboradorContacto;

        Test.startTest();
        List<Id> idsGruposColaboradorContact = new List<Id>();
        for (CC_Grupo_Colaborador_Contact__c gcc : listaGrupoColaboradorContacto) {
            idsGruposColaboradorContact.add(gcc.Id);
        }
        CC_Grupo_Colaborador_Contact_Anadir.anadirUsuario(idsGruposColaboradorContact);
        Test.stopTest();

        // Nos aseguramos que se han añadido los 2 usuarios nuevos
        List<GroupMember> resultado = [SELECT Id FROM GroupMember
                                       WHERE (Group.DeveloperName = 'CC_Grupo_Colaborador_Test' AND UserOrGroupId = :u2.Id) OR
                                             (Group.DeveloperName = 'CC_Cola_Test' AND UserOrGroupId = :u3.Id)];
        System.assertEquals(2, resultado.size());

        // Nos aseguramos de que no esta el usuario que ya estaba no se ha vuelto ha asignar creando duplicados
        resultado = [SELECT Id FROM GroupMember WHERE (Group.DeveloperName = 'CC_Cola_Test' OR Group.DeveloperName = 'CC_Grupo_Colaborador_Test') AND UserOrGroupId = :u.Id ];
        System.assertEquals(2, resultado.size());
    }
}