@isTest
public with sharing class CC_MonitorOnlineMethods_Test {
    @TestSetUp
    public static void makeData(){
        //crear usuarios CC
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id profile2Id = [SELECT Id FROM Profile WHERE Name = 'CC_Analísta y 2º nivel MVP2'].Id;
        Id profileSupervisor = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];

        User admin = new User();
        admin.ProfileId = profileId;
        admin.FirstName = 'Usuario Admin Prueba';
        admin.LastName = 'last211';
        admin.Email = 'aalsdnatest@kfsb.com';
        admin.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        admin.CompanyName = 'DXC';
        admin.Title = 'title';
        admin.Alias = 'alias';
        admin.TimeZoneSidKey = 'Europe/Paris';
        admin.EmailEncodingKey = 'UTF-8';
        admin.LanguageLocaleKey = 'es';
        admin.LocaleSidKey = 'es_ES';
        insert admin;

        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];

        System.runAs(admin)
        {
            User supervisor = new User();
            supervisor.ProfileId = profileSupervisor;
            supervisor.FirstName = 'Supervisor';
            supervisor.LastName = 'last11';
            supervisor.Email = 'tuser000@amamama.com';
            supervisor.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
            supervisor.CompanyName = 'MST';
            supervisor.Title = 'title';
            supervisor.Alias = 'alias';
            supervisor.TimeZoneSidKey = 'Europe/Paris';
            supervisor.EmailEncodingKey = 'UTF-8';
            supervisor.LanguageLocaleKey = 'es';
            supervisor.LocaleSidKey = 'es_ES';
            supervisor.UserRoleId = rolId.Id;
            supervisor.UserPermissionsLiveAgentUser = true;
            insert supervisor;
            ServicePresenceStatus presenceStatus = CC_OpenCTI.obtenerEstadoOmnichannel('Disponible');

            insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psClasses.Id);
            insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = ps.Id);

            Date dT = System.today();
            Datetime ahora = System.now();
            String ahoraNum = String.valueOf(ahora).substring(11, 13);
                     
            String campo = 'CC_'+ahoraNum+'__c';
            CC_Prevision__c prev1 = new CC_Prevision__c(
                CC_Proveedor__c = 'TODOS',
                CC_FranjaHoraria__c = ahoraNum,
                CC_Fecha__c = dT,
                CC_TipoDePrevisiones__c = 'Cliente',
                CC_NumeroDePrevisiones__c = 10,
                CC_Servicio__c = 'Extranjero',
                RecordTypeId = Schema.SObjectType.CC_Prevision__c.getRecordTypeInfosByDeveloperName().get('CC_Chats').getRecordTypeId(),
                CC_00__c = 1,
                CC_01__c = 1,
                CC_02__c = 1,
                CC_03__c = 1,
                CC_04__c = 1,
                CC_05__c = 1,
                CC_06__c = 1,
                CC_07__c = 1,
                CC_08__c = 1,
                CC_09__c = 1,
                CC_10__c = 1,
                CC_11__c = 1,
                CC_12__c = 1,
                CC_13__c = 1,
                CC_14__c = 1,
                CC_15__c = 1,
                CC_16__c = 1,
                CC_17__c = 1,
                CC_18__c = 1,
                CC_19__c = 1,
                CC_20__c = 1,
                CC_21__c = 1,
                CC_22__c = 1,
                CC_23__c = 1
            );
            insert prev1;
            
            CC_Prevision__c prev2 = new CC_Prevision__c(
                CC_Proveedor__c = 'TODOS',
                CC_FranjaHoraria__c = ahoraNum,
                CC_Fecha__c = dT,
                CC_TipoDePrevisiones__c = 'Cliente',
                CC_NumeroDePrevisiones__c = 10,
                RecordTypeId = Schema.SObjectType.CC_Prevision__c.getRecordTypeInfosByDeveloperName().get('CC_Agentes').getRecordTypeId(),
                CC_00__c = 1,
                CC_01__c = 1,
                CC_02__c = 1,
                CC_03__c = 1,
                CC_04__c = 1,
                CC_05__c = 1,
                CC_06__c = 1,
                CC_07__c = 1,
                CC_08__c = 1,
                CC_09__c = 1,
                CC_10__c = 1,
                CC_11__c = 1,
                CC_12__c = 1,
                CC_13__c = 1,
                CC_14__c = 1,
                CC_15__c = 1,
                CC_16__c = 1,
                CC_17__c = 1,
                CC_18__c = 1,
                CC_19__c = 1,
                CC_20__c = 1,
                CC_21__c = 1,
                CC_22__c = 1,
                CC_23__c = 1
            );
            insert prev2;
            
            // Crear cliente.
            Account a = new Account();
            a.Name = 'Cliente prueba 1';
            a.CC_NumPerso__c = '999910559714';
            insert a;
            
            // Crear contacto.
            Contact b = new Contact();
            b.LastName = 'Contacto prueba 1';
            b.CC_NumPerso__c = '999910559714';
            b.CC_Numero_Documento__c = '59044623N';
            insert b;
            
            List<Case> oCasos = new List<Case>();
        
            // Crear caso.
            Case c = new Case();
            c.Subject = 'Test_01';
            c.AccountId = a.Id;
            c.ContactId = b.Id;
            c.Status = 'New';
            c.Origin = 'Email';
            c.CC_NumPerso__c = '999910559714';
            oCasos.add(c);
            
             // Crear caso.
            Case c2 = new Case();
            c2.Subject = 'Test_02';
            c2.AccountId = a.Id;
            c2.ContactId = b.Id;
            c2.Status = 'New';
            c2.Origin = 'Email';
            c2.CC_NumPerso__c = '999910559714';
            oCasos.add(c2);
            
            insert oCasos;
            
            LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
            insert liveChatVisitor;
            
            LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
                CC_Bienvenida__c = false,
                CC_Nickname__c = 'Cliente 1',
                CC_Idioma__c = 'es',
                CC_Tipo__c = 'Agente',
                LiveChatVisitorId = liveChatVisitor.Id,
                CC_Id_Cognitive__c='9001029aa',
                CC_NumPerso__c = '999910559714',
                CC_NumPerso2__c = '999910559714',
                Status = 'Missed',
                AccountId = [SELECT Id FROM Account WHERE CC_NumPerso__c = '999910559714'].Id,
                ContactId = [SELECT Id FROM Contact WHERE CC_NumPerso__c = '999910559714'].Id,
                CaseId = [SELECT Id FROM Case WHERE Subject = 'Test_01'].Id,
                RecordTypeId = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('CC_Clientes').getRecordTypeId()
            );
            insert liveChatTranscript;
            
            
            
            LiveChatVisitor liveChatVisitor2 = new LiveChatVisitor();
            insert liveChatVisitor2;
            
            LiveChatTranscript liveChatTranscript2 = new LiveChatTranscript(
                CC_Bienvenida__c = false,
                CC_Nickname__c = 'Cliente 2',
                CC_Idioma__c = 'es',
                CC_Tipo__c = 'Agente',
                LiveChatVisitorId = liveChatVisitor2.Id,
                CC_Id_Cognitive__c='9001029aa',
                CC_NumPerso__c = '999910559714',
                CC_NumPerso2__c = '999910559714',
                Status = 'Completed',
                AccountId = [SELECT Id FROM Account WHERE CC_NumPerso__c = '999910559714'].Id,
                ContactId = [SELECT Id FROM Contact WHERE CC_NumPerso__c = '999910559714'].Id,
                CaseId = [SELECT Id FROM Case WHERE Subject = 'Test_02'].Id,
                RecordTypeId = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('CC_Clientes').getRecordTypeId()
            );
            insert liveChatTranscript2;
                
        }
    }

    @isTest
    public static void getDataTest()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Date dT = System.today();
        Datetime ahora = System.now();
        String ahoraNum = String.valueOf(ahora).substring(11, 13);
        List<CC_Prevision__c> prevBefore = [SELECT Id, CC_FranjaHoraria__c FROM CC_Prevision__c WHERE CC_FranjaHoraria__c = :ahoraNum];
        
        System.runAs(supervisor)
        {            
            Test.startTest();
            CC_MonitorOnlineMethods.WrapperInfoInicial result = CC_MonitorOnlineMethods.getData();
            Test.stopTest();
            System.assertNotEquals(result.pickListEntries[0], null, 'La obtención de datos ha fallado.');
        }
    }

    @isTest
    public static void filterDataChatsTest()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Date dT = System.today();
        Datetime ahora = System.now();
        String ahoraNum = String.valueOf(ahora).substring(11, 13);
        List<CC_Prevision__c> prevBefore = [SELECT Id FROM CC_Prevision__c WHERE CC_FranjaHoraria__c = :ahoraNum];

        System.runAs(supervisor)
        {
            Test.startTest();
            List<String> fh = new List<String>();
            fh.add(ahoraNum);
            List<String> prov = new List<String>();
            prov.add('TODOS');
            List<String> tipo = new List<String>();
            tipo.add('Cliente');
            List<String> servicios = new List<String>();
            servicios.add('Extranjero');
            String tabla = 'CC_Chats';

            CC_MonitorOnlineMethods.WrapperInfoInicial result = CC_MonitorOnlineMethods.busquedaFiltrada(fh, prov, tipo, servicios, tabla);

            Test.stopTest();
			System.assertNotEquals(result.previsionDataChats[0].franjaHoraria, null, 'La obtención de datos ha fallado.');        
        }
    }
    
     @isTest
    public static void filterDataAgentesTest()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];
        Date dT = System.today();
        Datetime ahora = System.now();
        String ahoraNum = String.valueOf(ahora).substring(11, 13);
        List<CC_Prevision__c> prevBefore = [SELECT Id FROM CC_Prevision__c WHERE CC_FranjaHoraria__c = :ahoraNum];

        System.runAs(supervisor)
        {
            Test.startTest();
            List<String> fh = new List<String>();
            fh.add(ahoraNum);
            List<String> prov = new List<String>();
            prov.add('TODOS');
            List<String> tipo = new List<String>();
            tipo.add('Cliente');
            List<String> servicios = new List<String>();
            String tabla = 'CC_Agentes';

            CC_MonitorOnlineMethods.WrapperInfoInicial result = CC_MonitorOnlineMethods.busquedaFiltrada(fh, prov, tipo, servicios, tabla);

            Test.stopTest();
            System.assertNotEquals(result.previsionData[0].franjaHoraria, null, 'La obtención de datos ha fallado.');        
        }
    }
}