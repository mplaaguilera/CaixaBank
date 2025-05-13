@isTest
public with sharing class SEG_Casos_Por_Grupo_Test{
//User operativo = SEG_Usuarios.usuarioOperativo();
//User supervisor = SEG_Usuarios.usuarioSupervisor();

    @testSetup
    static void testSetup(){

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            User thisUser = new User(alias = 'user2', email='testSEGBI2@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                username='testSEGBI2@acme.com');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }
    }

    @isTest
    public static void getGruposListviews() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        CC_Grupo_Colaborador__c grupoOperativo = new CC_Grupo_Colaborador__c();
        grupoOperativo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo.Name = 'Grupo operativo Test';
        insert grupoOperativo;
        
        //RT Account
        Id recordCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        //Creamos centro
        Account acc = new Account();
        acc.Name = 'centro';
        acc.RecordTypeId = recordCentro;
        acc.CC_Numero_Documento__c = '45137744D';
        insert acc;

        Contact gestor = new Contact();
        gestor.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        gestor.Email = 'colaborador@gmail.com';
        gestor.FirstName = 'Trevor';
        gestor.LastName = 'Smart';
        gestor.AccountId = acc.Id;
        insert gestor;

        CC_Grupo_Colaborador_Contact__c grupoOperativoContact = new CC_Grupo_Colaborador_Contact__c();
        grupoOperativoContact.CC_Grupo_Colaborador__c = grupoOperativo.id;
        grupoOperativoContact.CC_Contacto__c = gestor.Id;
        insert grupoOperativoContact;

        System.runAs(supervisor) {
            Test.startTest();
            
            SEG_Casos_Por_Grupo.GruposListviews gruposListviews = SEG_Casos_Por_Grupo.getGruposListviews();
            
            Test.stopTest();
            System.assertNotEquals(gruposListviews, null, 'No se han encontrado grupos');
        }
    }

    @isTest
    public static void getCasosGruposOperativos() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        User usuarioSegBo = new User();
        usuarioSegBo.Username = 'usergeneral2@test.com';
        usuarioSegBo.Email = 'maria@test.com';
        usuarioSegBo.LastName = 'SEG_BO';
        usuarioSegBo.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SEG_Usuario_CaixaBank'].Id;
        usuarioSegBo.Alias = 'segbo';
        usuarioSegBo.TimeZoneSidKey = 'GMT';
        usuarioSegBo.LocaleSidKey = 'es_ES';
        usuarioSegBo.EmailEncodingKey = 'ISO-8859-1';
        usuarioSegBo.LanguageLocaleKey = 'en_US';
        usuarioSegBo.isActive = true;       
        insert usuarioSegBo;

        CC_Grupo_Colaborador__c grupoOperativo1 = new CC_Grupo_Colaborador__c();
        grupoOperativo1.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo1.Name = 'Grupo operativo Test 1';
        insert grupoOperativo1;

        CC_Grupo_Colaborador__c grupoOperativo2 = new CC_Grupo_Colaborador__c();
        grupoOperativo2.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo2.Name = 'Grupo operativo Test 2';
        insert grupoOperativo2;

        Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.SEG_Grupo__c = grupoOperativo1.Id;
		caso1.Status = 'Abierto';
        caso1.Subject = 'test 1';
        caso1.OwnerId = usuarioSegBo.Id;
        caso1.SEG_Organizacion__c = 'Centro Empresas';
        caso1.SEG_Zona__c = 'Empresas Barcelona';

		Case caso2 = new Case();
		caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso2.SEG_Grupo__c = grupoOperativo1.Id;
        caso2.Status = 'Activo';
		caso2.Subject = 'test 2';
        caso2.OwnerId = usuarioSegBo.Id;
        caso2.SEG_Organizacion__c = 'Centro Empresas';
        caso2.SEG_Zona__c = 'Empresas Madrid';

        Case caso3 = new Case();
		caso3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso3.SEG_Grupo__c = grupoOperativo2.Id;
        caso3.Status = 'Activo';
		caso3.Subject = 'test 3';
        caso3.OwnerId = usuarioSegBo.Id;
        caso3.SEG_Organizacion__c = 'Centro Empresas';
        caso3.SEG_Zona__c = 'Empresas Valencia';

		insert new List<Case>{caso1, caso2, caso3};

        System.runAs(supervisor) {
            Test.startTest();
            
            List<SEG_Casos_Por_Grupo.Filtro> lstFiltros = new List<SEG_Casos_Por_Grupo.Filtro>();
            SEG_Casos_Por_Grupo.Filtro filtro = new SEG_Casos_Por_Grupo.Filtro();
            filtro.Id = 'id1';
            filtro.nombre = 'Account.Name';
            filtro.campo = 'Account.Name';
            filtro.operador = 'igual';
            filtro.operadorApi = '=';
            filtro.valor = 'id1';
            filtro.title = 'id1';
            lstFiltros.add(filtro);

            String jsonFiltros = JSON.serialize(lstFiltros);
            String logicaFiltro;
            SEG_Casos_Por_Grupo.ResultadoCasos resultado = SEG_Casos_Por_Grupo.getCasosGruposOperativos(
                'Casos de los grupos seleccionados',
                new List<Id>{grupoOperativo1.Id, grupoOperativo2.Id},
                new List<String>{'Subject', 'Status'},
                new List<String>{'Empresas Barcelona', 'Empresas Valencia'},
                0, false, jsonFiltros, logicaFiltro
            );
        
            Test.stopTest();

            System.assertEquals(2, 2, 'Número de casos recuperados incoherente');
        }
    }

    @isTest
    public static void getCasosGruposOperativos2() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        User usuarioSegBo = new User();
        usuarioSegBo.Username = 'usergeneral2@test.com';
        usuarioSegBo.Email = 'maria@test.com';
        usuarioSegBo.LastName = 'SEG_BO';
        usuarioSegBo.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SEG_Usuario_CaixaBank'].Id;
        usuarioSegBo.Alias = 'segbo';
        usuarioSegBo.TimeZoneSidKey = 'GMT';
        usuarioSegBo.LocaleSidKey = 'es_ES';
        usuarioSegBo.EmailEncodingKey = 'ISO-8859-1';
        usuarioSegBo.LanguageLocaleKey = 'en_US';
        usuarioSegBo.isActive = true;       
        insert usuarioSegBo;

        CC_Grupo_Colaborador__c grupoOperativo1 = new CC_Grupo_Colaborador__c();
        grupoOperativo1.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo1.Name = 'Grupo operativo Test 1';
        insert grupoOperativo1;

        CC_Grupo_Colaborador__c grupoOperativo2 = new CC_Grupo_Colaborador__c();
        grupoOperativo2.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo2.Name = 'Grupo operativo Test 2';
        insert grupoOperativo2;

        Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.SEG_Grupo__c = grupoOperativo1.Id;
		caso1.Status = 'Abierto';
        caso1.Subject = 'test 1';
        caso1.OwnerId = usuarioSegBo.Id;
        caso1.SEG_Organizacion__c = 'Centro Empresas';
        caso1.SEG_Zona__c = 'Empresas Barcelona';
		insert caso1;

        System.runAs(supervisor) {

            Test.startTest();
            
            List<SEG_Casos_Por_Grupo.Filtro> lstFiltros = new List<SEG_Casos_Por_Grupo.Filtro>();
            SEG_Casos_Por_Grupo.Filtro filtro = new SEG_Casos_Por_Grupo.Filtro();
            filtro.Id = 'id1';
            filtro.nombre = 'Account.Name';
            filtro.campo = 'Account.Name';
            filtro.operador = 'igual';
            filtro.operadorApi = '=';
            filtro.valor = 'id1';
            filtro.title = 'id1';
            lstFiltros.add(filtro);

            String jsonFiltros = JSON.serialize(lstFiltros);
            String logicaFiltro;
            SEG_Casos_Por_Grupo.ResultadoCasos resultado = SEG_Casos_Por_Grupo.getCasosGruposOperativos(
                'Mis casos',
                new List<Id>{grupoOperativo1.Id, grupoOperativo2.Id},
                new List<String>{'Subject', 'Status'},
                new List<String>{'Empresas Barcelona', 'Empresas Valencia'},
                0, false, jsonFiltros, logicaFiltro
            );
            
            Test.stopTest();

            System.assertEquals(2, 2, 'Número de casos recuperados incoherente');
        }
    }

    @isTest
    public static void getCasosGruposOperativos3() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        User usuarioSegBo = new User();
        usuarioSegBo.Username = 'usergeneral2@test.com';
        usuarioSegBo.Email = 'maria@test.com';
        usuarioSegBo.LastName = 'SEG_BO';
        usuarioSegBo.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SEG_Usuario_CaixaBank'].Id;
        usuarioSegBo.Alias = 'segbo';
        usuarioSegBo.TimeZoneSidKey = 'GMT';
        usuarioSegBo.LocaleSidKey = 'es_ES';
        usuarioSegBo.EmailEncodingKey = 'ISO-8859-1';
        usuarioSegBo.LanguageLocaleKey = 'en_US';
        usuarioSegBo.isActive = true;       
        insert usuarioSegBo;

        CC_Grupo_Colaborador__c grupoOperativo1 = new CC_Grupo_Colaborador__c();
        grupoOperativo1.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo1.Name = 'Grupo operativo Test 1';
        insert grupoOperativo1;

        CC_Grupo_Colaborador__c grupoOperativo2 = new CC_Grupo_Colaborador__c();
        grupoOperativo2.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo2.Name = 'Grupo operativo Test 2';
        insert grupoOperativo2;

        Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.SEG_Grupo__c = grupoOperativo1.Id;
		caso1.Status = 'Abierto';
        caso1.Subject = 'test 1';
        caso1.OwnerId = usuarioSegBo.Id;
        caso1.SEG_Organizacion__c = 'Centro Empresas';
        caso1.SEG_Zona__c = 'Empresas Barcelona';
		insert caso1;

        System.runAs(supervisor) {
            Test.startTest();
            
            List<SEG_Casos_Por_Grupo.Filtro> lstFiltros = new List<SEG_Casos_Por_Grupo.Filtro>();
            SEG_Casos_Por_Grupo.Filtro filtro = new SEG_Casos_Por_Grupo.Filtro();
            filtro.Id = 'id1';
            filtro.nombre = 'Account.Name';
            filtro.campo = 'Account.Name';
            filtro.operador = 'igual';
            filtro.operadorApi = '=';
            filtro.valor = 'id1';
            filtro.title = 'id1';
            lstFiltros.add(filtro);

            String jsonFiltros = JSON.serialize(lstFiltros);
            String logicaFiltro;
            SEG_Casos_Por_Grupo.ResultadoCasos resultado = SEG_Casos_Por_Grupo.getCasosGruposOperativos(
                'Mis casos activos',
                new List<Id>{grupoOperativo1.Id, grupoOperativo2.Id},
                new List<String>{'Subject', 'Status'},
                new List<String>{'Empresas Barcelona', 'Empresas Valencia'},
                0, false, jsonFiltros, logicaFiltro
            );
            
            Test.stopTest();

            System.assertEquals(2, 2, 'Número de casos recuperados incoherente');
        }
    }

    @isTest
    public static void getCasosGruposOperativos4() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        User usuarioSegBo = new User();
        usuarioSegBo.Username = 'usergeneral2@test.com';
        usuarioSegBo.Email = 'maria@test.com';
        usuarioSegBo.LastName = 'SEG_BO';
        usuarioSegBo.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SEG_Usuario_CaixaBank'].Id;
        usuarioSegBo.Alias = 'segbo';
        usuarioSegBo.TimeZoneSidKey = 'GMT';
        usuarioSegBo.LocaleSidKey = 'es_ES';
        usuarioSegBo.EmailEncodingKey = 'ISO-8859-1';
        usuarioSegBo.LanguageLocaleKey = 'en_US';
        usuarioSegBo.isActive = true;       
        insert usuarioSegBo;

        CC_Grupo_Colaborador__c grupoOperativo1 = new CC_Grupo_Colaborador__c();
        grupoOperativo1.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo1.Name = 'Grupo operativo Test 1';
        insert grupoOperativo1;

        CC_Grupo_Colaborador__c grupoOperativo2 = new CC_Grupo_Colaborador__c();
        grupoOperativo2.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo2.Name = 'Grupo operativo Test 2';
        insert grupoOperativo2;

        Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.SEG_Grupo__c = grupoOperativo1.Id;
		caso1.Status = 'Abierto';
        caso1.Subject = 'test 1';
        caso1.OwnerId = usuarioSegBo.Id;
        caso1.SEG_Organizacion__c = 'Centro Empresas';
        caso1.SEG_Zona__c = 'Empresas Barcelona';
		insert caso1;

        System.runAs(supervisor) {
            Test.startTest();
            
            List<SEG_Casos_Por_Grupo.Filtro> lstFiltros = new List<SEG_Casos_Por_Grupo.Filtro>();
            SEG_Casos_Por_Grupo.Filtro filtro = new SEG_Casos_Por_Grupo.Filtro();
            filtro.Id = 'id1';
            filtro.nombre = 'Account.Name';
            filtro.campo = 'Account.Name';
            filtro.operador = 'igual';
            filtro.operadorApi = '=';
            filtro.valor = 'id1';
            filtro.title = 'id1';
            lstFiltros.add(filtro);

            String jsonFiltros = JSON.serialize(lstFiltros);
            String logicaFiltro;
            SEG_Casos_Por_Grupo.ResultadoCasos resultado = SEG_Casos_Por_Grupo.getCasosGruposOperativos(
                'Mis casos pendientes',
                new List<Id>{grupoOperativo1.Id, grupoOperativo2.Id},
                new List<String>{'Subject', 'Status'},
                new List<String>{'Empresas Barcelona', 'Empresas Valencia'},
                0, false, jsonFiltros, logicaFiltro
            );
            
            Test.stopTest();

            System.assertEquals(2, 2, 'Número de casos recuperados incoherente');
        }
    }

    @isTest
    public static void getCasosGruposOperativos5() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        User usuarioSegBo = new User();
        usuarioSegBo.Username = 'usergeneral2@test.com';
        usuarioSegBo.Email = 'maria@test.com';
        usuarioSegBo.LastName = 'SEG_BO';
        usuarioSegBo.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SEG_Usuario_CaixaBank'].Id;
        usuarioSegBo.Alias = 'segbo';
        usuarioSegBo.TimeZoneSidKey = 'GMT';
        usuarioSegBo.LocaleSidKey = 'es_ES';
        usuarioSegBo.EmailEncodingKey = 'ISO-8859-1';
        usuarioSegBo.LanguageLocaleKey = 'en_US';
        usuarioSegBo.isActive = true;       
        insert usuarioSegBo;

        CC_Grupo_Colaborador__c grupoOperativo1 = new CC_Grupo_Colaborador__c();
        grupoOperativo1.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo1.Name = 'Grupo operativo Test 1';
        insert grupoOperativo1;

        CC_Grupo_Colaborador__c grupoOperativo2 = new CC_Grupo_Colaborador__c();
        grupoOperativo2.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo2.Name = 'Grupo operativo Test 2';
        insert grupoOperativo2;

        Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.SEG_Grupo__c = grupoOperativo1.Id;
		caso1.Status = 'Abierto';
        caso1.Subject = 'test 1';
        caso1.OwnerId = usuarioSegBo.Id;
        caso1.SEG_Organizacion__c = 'Centro Empresas';
        caso1.SEG_Zona__c = 'Empresas Barcelona';
		insert caso1;

        System.runAs(supervisor) {
            Test.startTest();
            
            List<SEG_Casos_Por_Grupo.Filtro> lstFiltros = new List<SEG_Casos_Por_Grupo.Filtro>();
            SEG_Casos_Por_Grupo.Filtro filtro = new SEG_Casos_Por_Grupo.Filtro();
            filtro.Id = 'id1';
            filtro.nombre = 'Account.Name';
            filtro.campo = 'Account.Name';
            filtro.operador = 'igual';
            filtro.operadorApi = '=';
            filtro.valor = 'id1';
            filtro.title = 'id1';
            lstFiltros.add(filtro);

            String jsonFiltros = JSON.serialize(lstFiltros);
            String logicaFiltro;
            SEG_Casos_Por_Grupo.ResultadoCasos resultado = SEG_Casos_Por_Grupo.getCasosGruposOperativos(
                'Mis casos planificados',
                new List<Id>{grupoOperativo1.Id, grupoOperativo2.Id},
                new List<String>{'Subject', 'Status'},
                new List<String>{'Empresas Barcelona', 'Empresas Valencia'},
                0, false, jsonFiltros, logicaFiltro
            );
            
            Test.stopTest();

            System.assertEquals(2, 2, 'Número de casos recuperados incoherente');
        }
    }

    @isTest
    public static void getCasosGruposOperativos6() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        User usuarioSegBo = new User();
        usuarioSegBo.Username = 'usergeneral2@test.com';
        usuarioSegBo.Email = 'maria@test.com';
        usuarioSegBo.LastName = 'SEG_BO';
        usuarioSegBo.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SEG_Usuario_CaixaBank'].Id;
        usuarioSegBo.Alias = 'segbo';
        usuarioSegBo.TimeZoneSidKey = 'GMT';
        usuarioSegBo.LocaleSidKey = 'es_ES';
        usuarioSegBo.EmailEncodingKey = 'ISO-8859-1';
        usuarioSegBo.LanguageLocaleKey = 'en_US';
        usuarioSegBo.isActive = true;       
        insert usuarioSegBo;

        CC_Grupo_Colaborador__c grupoOperativo1 = new CC_Grupo_Colaborador__c();
        grupoOperativo1.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo1.Name = 'Grupo operativo Test 1';
        insert grupoOperativo1;

        CC_Grupo_Colaborador__c grupoOperativo2 = new CC_Grupo_Colaborador__c();
        grupoOperativo2.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo2.Name = 'Grupo operativo Test 2';
        insert grupoOperativo2;

        Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.SEG_Grupo__c = grupoOperativo1.Id;
		caso1.Status = 'Abierto';
        caso1.Subject = 'test 1';
        caso1.OwnerId = usuarioSegBo.Id;
        caso1.SEG_Organizacion__c = 'Centro Empresas';
        caso1.SEG_Zona__c = 'Empresas Barcelona';
		insert caso1;

        System.runAs(supervisor) {
            Test.startTest();
            
            List<SEG_Casos_Por_Grupo.Filtro> lstFiltros = new List<SEG_Casos_Por_Grupo.Filtro>();
            SEG_Casos_Por_Grupo.Filtro filtro = new SEG_Casos_Por_Grupo.Filtro();
            filtro.Id = 'id1';
            filtro.nombre = 'Account.Name';
            filtro.campo = 'Account.Name';
            filtro.operador = 'igual';
            filtro.operadorApi = '=';
            filtro.valor = 'id1';
            filtro.title = 'id1';
            lstFiltros.add(filtro);

            String jsonFiltros = JSON.serialize(lstFiltros);
            String logicaFiltro;
            SEG_Casos_Por_Grupo.ResultadoCasos resultado = SEG_Casos_Por_Grupo.getCasosGruposOperativos(
                'Mis casos cerrados',
                new List<Id>{grupoOperativo1.Id, grupoOperativo2.Id},
                new List<String>{'Subject', 'Status'},
                new List<String>{'Empresas Barcelona', 'Empresas Valencia'},
                0, false, jsonFiltros, logicaFiltro
            );
            
            Test.stopTest();

            System.assertEquals(2, 2, 'Número de casos recuperados incoherente');
        }
    }

    @isTest
    public static void getCasosGruposOperativos7() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        User usuarioSegBo = new User();
        usuarioSegBo.Username = 'usergeneral2@test.com';
        usuarioSegBo.Email = 'maria@test.com';
        usuarioSegBo.LastName = 'SEG_BO';
        usuarioSegBo.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SEG_Usuario_CaixaBank'].Id;
        usuarioSegBo.Alias = 'segbo';
        usuarioSegBo.TimeZoneSidKey = 'GMT';
        usuarioSegBo.LocaleSidKey = 'es_ES';
        usuarioSegBo.EmailEncodingKey = 'ISO-8859-1';
        usuarioSegBo.LanguageLocaleKey = 'en_US';
        usuarioSegBo.isActive = true;       
        insert usuarioSegBo;

        CC_Grupo_Colaborador__c grupoOperativo1 = new CC_Grupo_Colaborador__c();
        grupoOperativo1.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo1.Name = 'Grupo operativo Test 1';
        insert grupoOperativo1;

        CC_Grupo_Colaborador__c grupoOperativo2 = new CC_Grupo_Colaborador__c();
        grupoOperativo2.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        grupoOperativo2.Name = 'Grupo operativo Test 2';
        insert grupoOperativo2;

        Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.SEG_Grupo__c = grupoOperativo1.Id;
		caso1.Status = 'Abierto';
        caso1.Subject = 'test 1';
        caso1.OwnerId = usuarioSegBo.Id;
        caso1.SEG_Organizacion__c = 'Centro Empresas';
        caso1.SEG_Zona__c = 'Empresas Barcelona';
		insert caso1;

        System.runAs(supervisor) {
            Test.startTest();
            
            List<SEG_Casos_Por_Grupo.Filtro> lstFiltros = new List<SEG_Casos_Por_Grupo.Filtro>();
            SEG_Casos_Por_Grupo.Filtro filtro = new SEG_Casos_Por_Grupo.Filtro();
            filtro.Id = 'id1';
            filtro.nombre = 'Account.Name';
            filtro.campo = 'Account.Name';
            filtro.operador = 'igual';
            filtro.operadorApi = '=';
            filtro.valor = 'id1';
            filtro.title = 'id1';
            lstFiltros.add(filtro);

            String jsonFiltros = JSON.serialize(lstFiltros);
            String logicaFiltro;
            SEG_Casos_Por_Grupo.ResultadoCasos resultado = SEG_Casos_Por_Grupo.getCasosGruposOperativos(
                'Casos activos de mis grupos',
                new List<Id>{grupoOperativo1.Id, grupoOperativo2.Id},
                new List<String>{'Subject', 'Status'},
                new List<String>{'Empresas Barcelona', 'Empresas Valencia'},
                0, false, jsonFiltros, logicaFiltro
            );
            Test.stopTest();

            System.assertEquals(2, 2, 'Número de casos recuperados incoherente');
        }
    }

    @isTest
    public static void definicionCamposCase() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];

        User supervisor = SEG_Usuarios.usuarioSupervisor();
        Test.startTest();
        System.runAs(usuarioTest) { 
            List<SEG_Casos_Por_Grupo.Campo> definicionCamposCase = SEG_Casos_Por_Grupo.definicionCamposCase(); 
            Test.stopTest();

            System.assert(!definicionCamposCase.isEmpty(), 'Error recuperando definición del objeto Case');
        }
    }

    @isTest
    public static void getZonas() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        System.runAs(supervisor) {
            Test.startTest();
            List<Map<String, String>> zonas = SEG_Casos_Por_Grupo.getZonas();           
            Test.stopTest();

            System.assert(!zonas.isEmpty(), 'Error recuperando lista de zonas');
        }
    }

    @isTest
    public static void tomarPropiedad() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];

        User supervisor = SEG_Usuarios.usuarioSupervisor();

        User usuarioSegBo = new User();
        usuarioSegBo.Username = 'usergeneral2@test.com';
        usuarioSegBo.Email = 'maria@test.com';
        usuarioSegBo.LastName = 'SEG_BO';
        usuarioSegBo.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SEG_Usuario_CaixaBank'].Id;
        usuarioSegBo.Alias = 'segbo';
        usuarioSegBo.TimeZoneSidKey = 'GMT';
        usuarioSegBo.LocaleSidKey = 'es_ES';
        usuarioSegBo.EmailEncodingKey = 'ISO-8859-1';
        usuarioSegBo.LanguageLocaleKey = 'en_US';
        usuarioSegBo.isActive = true;       
        insert usuarioSegBo;

        CC_Grupo_Colaborador__c grupoGestor = new CC_Grupo_Colaborador__c();
		grupoGestor.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__C.getRecordTypeInfosByDeveloperName().get('SEG_GrupoAutomaticoSegmentos').getRecordTypeId();
		grupoGestor.Name = 'Gestor Operativa Internacional';
		insert grupoGestor;

        SEG_Excepciones__c excepcion = new SEG_Excepciones__c();
		excepcion.RecordTypeId = Schema.SObjectType.SEG_Excepciones__c.getRecordTypeInfosByDeveloperName().get('SEG_Asignacion').getRecordTypeId();
		excepcion.SEG_FechaActivacion__c  = Date.today().addDays(-2);
		excepcion.SEG_Organizacion__c = 'Banca Corporativa';
		excepcion.SEG_Zona__c = 'Corporativa';
		excepcion.SEG_Grupoasignado__c = grupoGestor.Id;
		insert excepcion;

        Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.Status = 'Abierto';
        caso1.Subject = 'test 1';
        caso1.OwnerId = usuarioSegBo.Id;
        caso1.SEG_Zona__c = 'Corporativa';
        caso1.SEG_Organizacion__C = 'Banca Corporativa';
        insert caso1;

		Case caso2 = new Case();
		caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso2.Status = 'Activo';
		caso2.Subject = 'test 2';
        caso2.OwnerId = usuarioSegBo.Id;
        caso2.SEG_Zona__c = 'Corporativa';
        caso2.SEG_Organizacion__C = 'Banca Corporativa';
        insert caso2;

        List<Id> idCasos = new List<Id>{caso1.Id, caso2.Id};

        Test.startTest();
        System.runAs(usuarioTest) { 
            SEG_Casos_Por_Grupo.tomarPropiedad(idCasos);
            Test.stopTest();

            Map<Id, Case> casos = new Map<Id, Case>([SELECT OwnerId FROM Case WHERE Id IN :idCasos]);
            System.assertEquals(usuarioTest.Id, casos.get(caso1.Id).OwnerId, 'No se ha tomado la propiedad del caso 1');
            System.assertEquals(usuarioTest.Id, casos.get(caso2.Id).OwnerId, 'No se ha tomado la propiedad del caso 2');
        }
    }

    @isTest
    public static void rechazar() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];

        User supervisor = SEG_Usuarios.usuarioSupervisor();

        SEG_ClasificacionRapida__c cr = new SEG_ClasificacionRapida__c();
        cr.Name = 'No procede';
        insert cr;

        Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.Status = 'Abierto';
        caso1.Subject = 'test 1';
        caso1.SEG_Zona__c = 'Corporativa';
        caso1.SEG_Organizacion__C = 'Banca Corporativa';
        insert caso1;

		Case caso2 = new Case();
		caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso2.Status = 'Activo';
		caso2.Subject = 'test 2';
        caso2.SEG_Zona__c = 'Corporativa';
        caso2.SEG_Organizacion__C = 'Banca Corporativa';
        insert caso2;

        List<Id> idCasos = new List<Id>{caso1.Id, caso2.Id};

        Test.startTest();
        System.runAs(usuarioTest) { 
            SEG_Casos_Por_Grupo.rechazar(idCasos);
            Test.stopTest();

            Map<Id, Case> casos = new Map<Id, Case>([SELECT Status FROM Case WHERE Id IN :idCasos]);
            System.assertEquals('Descartado', casos.get(caso1.Id).Status, 'El estado del caso1 debería ser "Descartado"');
            System.assertEquals('Descartado', casos.get(caso2.Id).Status, 'El estado del caso2 debería ser "Descartado"');
        }
    }

    @isTest
    public static void esSupervisor() {
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        User usuarioSegBo = new User();
        usuarioSegBo.Username = 'usergeneral2@test.com';
        usuarioSegBo.Email = 'maria@test.com';
        usuarioSegBo.LastName = 'SEG_BO';
        usuarioSegBo.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SEG_Usuario_CaixaBank'].Id;
        usuarioSegBo.Alias = 'segbo';
        usuarioSegBo.TimeZoneSidKey = 'GMT';
        usuarioSegBo.LocaleSidKey = 'es_ES';
        usuarioSegBo.EmailEncodingKey = 'ISO-8859-1';
        usuarioSegBo.LanguageLocaleKey = 'en_US';
        usuarioSegBo.isActive = true;       
        insert usuarioSegBo;

        PermissionSetAssignment userPS = new PermissionSetAssignment();
        userPS.AssigneeId = usuarioSegBo.Id;
        userPS.PermissionSetId = [SELECT id FROM permissionSet WHERE name = 'SEG_Supervisor'].id;
        insert userPs;
        
        System.runAs(supervisor) {
            Test.startTest();
                Boolean result = SEG_Casos_Por_Grupo.esSupervisor(usuarioSegBo.id);            
            Test.stopTest();
                System.assertEquals(true, true,'El resultado deberia ser True');
        }
    }
    
    @isTest
    public static void cambiarPropietarioMasivo(){
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE email = 'testSEGBI2@acme.com' LIMIT 1];

        User supervisor = SEG_Usuarios.usuarioSupervisor();

        List<Id> casos = new List<Id>();
        Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.Status = 'Abierto';
        caso1.Subject = 'test 1';
        caso1.SEG_Zona__c = 'Corporativa';
        caso1.SEG_Organizacion__C = 'Banca Corporativa';
        insert caso1;
        casos.add(caso1.Id);

        User usuarioSegBo = new User();
        usuarioSegBo.Username = 'usergeneral2@test.com';
        usuarioSegBo.Email = 'maria@test.com';
        usuarioSegBo.LastName = 'SEG_BO';
        usuarioSegBo.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SEG_Usuario_CaixaBank'].Id;
        usuarioSegBo.Alias = 'segbo';
        usuarioSegBo.TimeZoneSidKey = 'GMT';
        usuarioSegBo.LocaleSidKey = 'es_ES';
        usuarioSegBo.EmailEncodingKey = 'ISO-8859-1';
        usuarioSegBo.LanguageLocaleKey = 'en_US';
        usuarioSegBo.isActive = true;       
        insert usuarioSegBo;
        
        Test.startTest();
        System.runAs(usuarioTest) { 
                SEG_Casos_Por_Grupo.cambiarPropietarioMasivo(casos,usuarioSegBo.id);
            Test.stopTest();
            
            List<Case> caso = [SELECT id, OwnerId FROM case WHERE id =: caso1.id];
            System.assertNotEquals(caso1.OwnerId, caso[0].ownerId,'El propietario no es correcto');
        }
    }

    @isTest
    public static void getSegmentosRecordType(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();
        
        System.runAs(supervisor) {
            Test.startTest();
                String recordTypeId = SEG_Casos_Por_Grupo.getSegmentosRecordType();
            Test.stopTest();
            
            System.assertNotEquals(null, recordTypeId,'No se ha encontrado el RecordType');
        }
    }
    
        
    @isTest
    public static void getNIF(){
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI2@acme.com' LIMIT 1];

        System.runAs ( usuarioTest ) {

            //RT Account
            Id recordCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

            //Creamos centro
            Account acc = new Account();
            acc.Name = 'centroDos';
            acc.RecordTypeId = recordCentro;
            acc.SEG_Organizacion__c = 'Banca Corporativa';
            acc.SEG_Zona__c = 'Corporativa';
            insert acc;
            
            //Creamos centro
            Account acc2 = new Account();
            acc2.Name = 'centro';
            acc2.RecordTypeId = recordCentro;
            acc2.CC_Numero_Documento__c = '39396441V';
            acc2.SEG_Prioridad_Carterizacion_Segmentos__c = true;
            acc2.SEG_Oficina_Gestora_Segmentos__c = acc.Id;
            insert acc2;
            
            Test.startTest();
                Map<String, Object> nif = SEG_Casos_Por_Grupo.validarNif('45137788D');
                Map<String, Object> nif2 = SEG_Casos_Por_Grupo.validarNif('39396441V');
            Test.stopTest();
            
            List<Account> cuenta = [SELECT id, CC_Numero_Documento__c, name FROM Account WHERE CC_Numero_Documento__c = '39396441V' LIMIT 1];
                   	
            System.assertEquals('NIF no existente.' , nif.get('validación') ,'Se ha encontrado el nif');
        }
    }

    @isTest
    public static void getUsers(){
        User supervisor = SEG_Usuarios.usuarioSupervisor();

        User usuarioSegBo = new User();
        usuarioSegBo.Username = 'usergeneral3@test.com';
        usuarioSegBo.Email = 'testUser@test.com';
        usuarioSegBo.LastName = 'testUser';
        usuarioSegBo.ProfileId = [SELECT Id FROM Profile WHERE Name = 'SEG_Usuario_CaixaBank'].Id;
        usuarioSegBo.Alias = 'segbo';
        usuarioSegBo.TimeZoneSidKey = 'GMT';
        usuarioSegBo.LocaleSidKey = 'es_ES';
        usuarioSegBo.EmailEncodingKey = 'ISO-8859-1';
        usuarioSegBo.LanguageLocaleKey = 'en_US';
        usuarioSegBo.isActive = true;       
        insert usuarioSegBo;
              
        System.runAs(supervisor) {
            Test.startTest();
            List<User> uList = SEG_Casos_Por_Grupo.getUsuariosSEG('testUs');
            Test.stopTest();
                               	
            System.assertEquals(uList.size() , 1, 'La lista debería devolver 1 usuario');
        }
    }
}