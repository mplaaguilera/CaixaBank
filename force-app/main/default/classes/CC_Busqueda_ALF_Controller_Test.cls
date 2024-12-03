@IsTest
public with sharing class CC_Busqueda_ALF_Controller_Test {

     @TestSetup
    static void makeData() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        PermissionSet psOperadorCliente = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
        PermissionSet ccClases = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        //PermissionSet psSupervisorCliente = [SELECT Id FROM PermissionSet WHERE Name = 'CC_S'];

        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        User usuario = new User();        
        usuario.profileId = profileId;
        usuario.UserRoleId = roleCC;
        usuario.FirstName = 'Usuario supervisor Prueba1';
        usuario.LastName = 'last211';
        usuario.Email = 'tuser000@amamama.com';
        usuario.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario.CompanyName = 'MST';
        usuario.Title = 'title';
        usuario.Alias = 'alias';
        usuario.TimeZoneSidKey = 'Europe/Paris';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.LocaleSidKey = 'es_ES';
        
        insert usuario;

       	List<PermissionSetAssignment> insertPSAss = new List<PermissionSetAssignment>();
    	PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = usuario.Id, PermissionSetId = psOperadorCliente.Id);
		insertPSAss.add(psa1);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = usuario.Id, PermissionSetId = ccClases.Id);
        		insertPSAss.add(psa2);

        insert insertPSAss;
        
    }
    
    @isTest
    static void test01_setClienteCaso_01() {

        // Crear cuentas.
        List<Account> oCuentas = new List<Account>{
            	new Account(name='Test01',CC_Numero_Documento__c='12345678Z',CC_NumPerso__c = '99999991'),
                new Account(name='Test02',CC_Numero_Documento__c='09881783V',CC_NumPerso__c = '99999992'),
                new Account(name='Test03',CC_Numero_Documento__c='06898789P',CC_NumPerso__c = '99999993'),
                new Account(name='Test05',CC_Numero_Documento__c='71234771E'),
                new Account(name='Test07',CC_Numero_Documento__c='15197951B')
                };
		insert oCuentas;

        // Crear contactos.
        List<Contact> oContacts = new List<Contact>{
            	new Contact(LastName='Test01',CC_NumPerso__c = '99999991', Account=new Account(CC_NumPerso__c = '99999991')),
                new Contact(LastName='Test02',CC_NumPerso__c = '99999992', Account=new Account(CC_NumPerso__c = '99999992')),
                new Contact(LastName='Test03',Account=new Account(CC_NumPerso__c = '99999993')),
                new Contact(LastName='Test04'),
                new Contact(LastName='Test06')
                };
		insert oContacts;

        // Crear casos.
        List<Case> oCasos = new List<Case>{
            	new Case(Subject='Test01',Description = 'Prueba2',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                         CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
                         Account=new Account(CC_NumPerso__c = '99999991'),Contact=new Contact(CC_NumPerso__c = '99999991')),
				new Case(Subject='Test02',Description = 'Prueba3',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                         CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
                         Account=new Account(CC_NumPerso__c = '99999992'),Contact=new Contact(CC_NumPerso__c = '99999992')),
                new Case(Subject='Test03',Description = 'Prueba4',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                         CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
                         Account=new Account(CC_NumPerso__c = '99999993')),
                new Case(Subject='Test04',Description = 'Prueba5',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                         CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
                new Case(Subject='Test05',Description = 'Prueba6',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                         CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
                new Case(Subject='Test06',Description = 'Prueba7',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                         CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
                new Case(Subject='Test07',Description = 'Prueba',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                         CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store')
        		};
		insert oCasos;

		Account oAcc;
        Contact oCont;
        Case oCaso;

        // Validar datos vacíos.
        CC_Busqueda_ALF_Controller.setClienteCaso ('', '', '');
        CC_Busqueda_ALF_Controller.setClienteCaso ('x', 'x', '');

        // Vincular contacto identificado en origen y destino.
        oCaso = [SELECT Id FROM Case WHERE Subject = 'Test01'];
        oCont = [SELECT Id FROM Contact WHERE LastName = 'Test02'];
        CC_Busqueda_ALF_Controller.setClienteCaso (oCont.Id, 'Contacto', oCaso.Id);
    }

     @isTest
    static void test01_setClienteRepresentante() {
        
         User usuario1 = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE FirstName = 'Usuario supervisor Prueba1' LIMIT 1];
         System.runAs(usuario1){
        
        Id recordTypeCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        Account cuenta2 = new Account();
        cuenta2.FirstName = 'TestRepresentante';
        cuenta2.LastName = '2';
        cuenta2.CC_Numero_Documento__c = '05766562W';
        cuenta2.CC_NumPerso__c = '99999900';
        cuenta2.RecordTypeId = recordTypeCliente;
        cuenta2.CC_TipoPersona__c = 'F';
        cuenta2.CC_Confidencial__c = false;
		insert cuenta2;
            
        
        CC_Representante_Contrato__c representanteContrato1 = new CC_Representante_Contrato__c();
        representanteContrato1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante');
        representanteContrato1.CC_ClienteRepresentante__c = cuenta2.Id;
        insert representanteContrato1;

        CC_Representante_Contrato__c representanteContrato2 = new CC_Representante_Contrato__c();
        representanteContrato2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante');
        representanteContrato2.CC_RepresentanteAsociado__c = representanteContrato1.Id;
        insert representanteContrato2;

        //List<CC_Busqueda_ALF_Controller.RepresentanteOrContactoWrapper> resultado2 = CC_Busqueda_ALF_Controller.getRepresentantesOrContactosCliente(cuenta2.Id);
    
		Account cuentaMenor = new Account();
        cuentaMenor.FirstName = 'Menor';
        cuentaMenor.LastName = '2';
        cuentaMenor.CC_Numero_Documento__c = '36231292J';
        cuentaMenor.CC_NumPerso__c = '99999903';
        cuentaMenor.RecordTypeId = recordTypeCliente;
        cuentaMenor.CC_TipoPersona__c = 'F';
        cuentaMenor.CC_FechaNac__pc  = Date.newInstance(2020, 09,01);
		insert cuentaMenor;

        CC_Representante_Contrato__c representanteContratoMenor = new CC_Representante_Contrato__c();
        representanteContratoMenor.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante');
        representanteContratoMenor.CC_ClienteRepresentante__c = cuentaMenor.Id;
        representanteContratoMenor.CC_Representante__c = cuenta2.Id;
        insert representanteContratoMenor;    

        Case casoRepresentante = new Case();
        casoRepresentante.Subject='TestRepresentante';
        casoRepresentante.Description = 'Prueba2';
      	casoRepresentante.Status = 'Activo';
        casoRepresentante.Origin = 'Phone';
        casoRepresentante.CC_Idioma__c = 'es';
        casoRepresentante.CC_Tipo_Contacto__c = 'Consulta';
        casoRepresentante.CC_Tipo_Cliente__c = 'Cliente';
        casoRepresentante.CC_Canal_Procedencia__c = 'ImaginBank ';
        //casoRepresentante.AccountId = cuentaMenor.Id;
        casoRepresentante.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        insert casoRepresentante;
             
             
        Id recordTypeLlamada = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Cliente');
    
        CC_Llamada__c llamada = new CC_Llamada__c();
        llamada.RecordTypeId = recordTypeLlamada;
        insert llamada;     
             
        
		Case oCaso = [SELECT Id, ContactId FROM Case WHERE Subject = 'TestRepresentante'];
        
        Account cuentaRepresentante = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = '05766562W' AND CC_NumPerso__c = '99999900'];
        CC_Representante_Contrato__c representante = [SELECT Id FROM CC_Representante_Contrato__c WHERE CC_Representante__c = :cuentaRepresentante.Id];
     

      	Contact oContacto = [SELECT Id FROM Contact WHERE AccountId = :cuentaRepresentante.Id LIMIT 1];
      
        Test.startTest(); 
        
            CC_Busqueda_ALF_Controller.setClienteCaso (representante.Id, 'Representante', oCaso.Id);
            CC_Busqueda_ALF_Controller.setClienteLlamada(representante.Id, 'Representante', llamada.Id);

            Test.stopTest();
        
            oCaso = [SELECT Id, CC_Representante__c FROM Case WHERE Subject = 'TestRepresentante'];
         
        system.assertEquals(oCaso.CC_Representante__c, representante.Id, 'El representante se asocia al caso'); 
            }
    }
    
    
    @isTest
    static void test01_setClienteCaso_02() {

        // Crear cuentas. 
        List<Account> oCuentas = new List<Account>{
            	new Account(name='Test01',CC_Numero_Documento__c='12345678Z',CC_NumPerso__c = '99999991'),
                new Account(name='Test02',CC_Numero_Documento__c='09881783V',CC_NumPerso__c = '99999992'),
                new Account(name='Test03',CC_Numero_Documento__c='06898789P',CC_NumPerso__c = '99999993'),
                new Account(name='Test05',CC_Numero_Documento__c='71234771E'),
                new Account(name='Test07',CC_Numero_Documento__c='15197951B')
                };
		insert oCuentas;

        // Crear contactos.
        List<Contact> oContacts = new List<Contact>{
            	new Contact(LastName='Test01',CC_NumPerso__c = '99999991', Account=new Account(CC_NumPerso__c = '99999991')),
                new Contact(LastName='Test02',CC_NumPerso__c = '99999992', Account=new Account(CC_NumPerso__c = '99999992')),
                new Contact(LastName='Test03',Account=new Account(CC_NumPerso__c = '99999993')),
                new Contact(LastName='Test04'),
                new Contact(LastName='Test06')
                };
		insert oContacts;

        // Crear casos.
        List<Case> oCasos = new List<Case>{
            	new Case(Subject='Test01',Description = 'Prueba2',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                         CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
                         Account=new Account(CC_NumPerso__c = '99999991'),Contact=new Contact(CC_NumPerso__c = '99999991')),
				new Case(Subject='Test02',Description = 'Prueba3',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                         CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
                         Account=new Account(CC_NumPerso__c = '99999992'),Contact=new Contact(CC_NumPerso__c = '99999992')),
                new Case(Subject='Test03',Description = 'Prueba4',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                         CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
                         Account=new Account(CC_NumPerso__c = '99999993')),
                new Case(Subject='Test04',Description = 'Prueba5',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                         CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
                new Case(Subject='Test05',Description = 'Prueba6',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                         CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
                new Case(Subject='Test06',Description = 'Prueba7',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                         CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
                new Case(Subject='Test07',Description = 'Prueba',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                         CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store')
        		};
		insert oCasos;

		Account oAcc;
        Contact oCont;
        Case oCaso;

        // Vincular cuenta identificada en origen y destino.
        oCaso = [SELECT Id FROM Case WHERE Subject = 'Test02'];
        oAcc = [SELECT Id FROM Account WHERE name = 'Test02'];
        CC_Busqueda_ALF_Controller.setClienteCaso (oAcc.Id, 'Cuenta', oCaso.Id);

        // Vincular cuenta identificada en origen y destino (empresa)
        oCaso = [SELECT Id FROM Case WHERE Subject = 'Test03'];
        oCont = [SELECT Id FROM Contact WHERE LastName = 'Test03'];
        oCaso.ContactId = oCont.Id;
        update oCaso;
        oCont = [SELECT Id FROM Contact WHERE LastName = 'Test02'];
        CC_Busqueda_ALF_Controller.setClienteCaso (oCont.Id, 'Contacto', oCaso.Id);

        // Vincular cuenta identificada en origen (contacto sin cuenta) y destino (empresa)
        oCaso = [SELECT Id FROM Case WHERE Subject = 'Test04'];
        oCont = [SELECT Id FROM Contact WHERE LastName = 'Test04'];
        oCaso.ContactId = oCont.Id;
        update oCaso;
        oCont = [SELECT Id FROM Contact WHERE LastName = 'Test02'];
        CC_Busqueda_ALF_Controller.setClienteCaso (oCont.Id, 'Contacto', oCaso.Id);
    }

    @isTest
    static void test01_setClienteCaso_03() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        // Crear cuentas.
        List<Account> oCuentas = new List<Account>{
            	new Account(name='Test01',CC_Numero_Documento__c='12345678Z',CC_NumPerso__c = '99999991'),
                new Account(name='Test02',CC_Numero_Documento__c='09881783V',CC_NumPerso__c = '99999992'),
                new Account(name='Test03',CC_Numero_Documento__c='06898789P',CC_NumPerso__c = '99999993'),
                new Account(name='Test05',CC_Numero_Documento__c='71234771E'),
                new Account(name='Test07',CC_Numero_Documento__c='15197951B')
                };
		insert oCuentas;

        // Crear contactos.
        List<Contact> oContacts = new List<Contact>{
            	new Contact(LastName='Test01',CC_NumPerso__c = '99999991', Account=new Account(CC_NumPerso__c = '99999991')),
                new Contact(LastName='Test02',CC_NumPerso__c = '99999992', Account=new Account(CC_NumPerso__c = '99999992')),
                new Contact(LastName='Test03',Account=new Account(CC_NumPerso__c = '99999993')),
                new Contact(LastName='Test04'),
                new Contact(LastName='Test06')
                };
		insert oContacts;

        // Crear casos.
        List<Case> oCasos = new List<Case>{
            new Case(Subject='Test01',Description = 'Prueba2',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                        CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
                        Account=new Account(CC_NumPerso__c = '99999991'),Contact=new Contact(CC_NumPerso__c = '99999991')),
            new Case(Subject='Test02',Description = 'Prueba3',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                        CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
                        Account=new Account(CC_NumPerso__c = '99999992'),Contact=new Contact(CC_NumPerso__c = '99999992')),
            new Case(Subject='Test03',Description = 'Prueba4',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                        CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
                        Account=new Account(CC_NumPerso__c = '99999993')),
            new Case(Subject='Test04',Description = 'Prueba5',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                        CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
            new Case(Subject='Test05',Description = 'Prueba6',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                        CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
            new Case(Subject='Test06',Description = 'Prueba7',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                        CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
            new Case(Subject='Test07',Description = 'Prueba',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
                        CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store')
            };
		insert oCasos;

		Account oAcc;
        Contact oCont;
        Case oCaso;

        // Vincular cuenta identificada en origen (cuenta sin contacto) y destino (empresa)
        oCaso = [SELECT Id FROM Case WHERE Subject = 'Test05'];
        oAcc = [SELECT Id FROM Account WHERE Name = 'Test05'];
        oCaso.AccountId = oAcc.Id;
        update oCaso;
        oCont = [SELECT Id FROM Contact WHERE LastName = 'Test02'];
        CC_Busqueda_ALF_Controller.setClienteCaso (oCont.Id, 'Contacto', oCaso.Id);

        // Vincular cuenta identificada en origen (contacto sin cuenta) y destino (particular)
        oCaso = [SELECT Id FROM Case WHERE Subject = 'Test06'];
        oCont = [SELECT Id FROM Contact WHERE LastName = 'Test06'];
        oCaso.ContactId = oCont.Id;
        update oCaso;
        oAcc = [SELECT Id FROM Account WHERE Name = 'Test01'];
        CC_Busqueda_ALF_Controller.setClienteCaso (oAcc.Id, 'Cuenta', oCaso.Id);

        System.assertEquals(oCaso.ContactId,oCont.Id);

        // Vincular cuenta identificada en origen (cuenta sin identificar) y destino (particular)
        //oCaso = [SELECT Id FROM Case WHERE Subject = 'Test07'];
        //oAcc = [SELECT Id FROM Account WHERE Name = 'Test07'];
        //oCaso.AccountId = oAcc.Id;
        //update oCaso;
        //oAcc = [SELECT Id FROM Account WHERE Name = 'Test01'];
        //CC_Busqueda_ALF_Controller.setClienteCaso(oAcc.Id, 'Cuenta', oCaso.Id);
        }
    }

    @isTest
    static void test02_getIdentidad() {
        // Crear cuentas.
		Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        List<Account> oCuentas = new List<Account>{
            new Account(
                name='Test01',
                CC_Numero_Documento__c='12345678Z',
                CC_NumPerso__c = '99999991',
                RecordTypeId = recordTypeIdCliente
            )
        };
		insert oCuentas;

        // Crear contactos.
        List<Contact> oContacts = new List<Contact>{
            new Contact(
                LastName='Test01',
                CC_NumPerso__c = '99999991',
                Account = new Account(CC_NumPerso__c = '99999991')
            )
        };
		insert oContacts;

        Test.startTest();
        Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALFCONS_WSDL_01());
        Map<String, Object> oData = CC_Busqueda_ALF_Controller.getIdentidad ('DOC', '12345678Z');
        Test.stopTest();

        System.assertEquals(1, ((List<Account>)oData.get('CUENTAS')).size());

        // Recuperar los contactos de la cuenta obtenida.
        List<Object> oListaCont = CC_Busqueda_ALF_Controller.getRepresentantesOrContactosCliente(oCuentas[0].Id);

        System.assertEquals(oListaCont.size(), 1);
    }

    @isTest
    static void test03_getIdentidad() {

        // Crear cuentas.
		Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        List<Account> oCuentas = new List<Account>{
            	new Account(name='Test01',CC_Numero_Documento__c='12345678Z',CC_NumPerso__c = '99999991',RecordTypeId = recordTypeIdCliente)
                };
		insert oCuentas;

        // Crear contactos.
        List<Contact> oContacts = new List<Contact>{
            	new Contact(LastName='Test01',CC_NumPerso__c = '99999991', Account=new Account(CC_NumPerso__c = '99999991'))
                };
		insert oContacts;

        // Crear canal comunicación.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '99999991';
        c1.CC_ContactoId__c = oContacts[0].Id;
        c1.CC_CuentaId__c = oCuentas[0].Id;
        c1.CC_Telefono__c = '938500000';
        c1.RecordTypeId = sRecordType1;
        insert c1;

        Test.startTest();

        Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALFCONS_WSDL_01());

        Map<String,Object> oData = CC_Busqueda_ALF_Controller.getIdentidad ('TEL', '938500000');

        Test.stopTest();

        System.assertEquals(1, ((List<Account>)oData.get('CUENTAS')).size());

    }

    @isTest
    static void test04_controlVacios() {

        // Control de datos vacíos.

        Map<String,Object> oData = CC_Busqueda_ALF_Controller.getIdentidad ('', '');

        System.assertEquals(oData, null);

        List<Object> oListaCont = CC_Busqueda_ALF_Controller.getRepresentantesOrContactosCliente('');

        System.assertEquals(oListaCont, null);
    }

    @isTest
    static void buscarCasos() {
        Case c = new Case();
        c.Subject = 'Prueba';
        c.Description = 'Prueba';
        c.Status = 'Activo';
        c.Origin = 'Comentarios Stores';
        c.CC_Idioma__c = 'es';
		c.CC_Tipo_Contacto__c = 'Consulta';
		c.CC_Tipo_Cliente__c = 'Cliente';
        c.CC_Canal_Procedencia__c = 'Google Play Store';
        insert c;

		Case cs = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c='Google Play Store' LIMIT 1];
        SocialPost socPost = New SocialPost();
        socPost.Content = 'Prueba';
        socPost.Handle = 'oskiki';
        socPost.ParentId = cs.Id;
        //socPost.PersonaId = '';
        socPost.Provider = 'Other';
        socPost.Name = 'Prueba';
        socPost.IsOutbound = true;
        insert socPost;

        SocialPost sPost = [SELECT Id,PersonaId FROM SocialPost WHERE Name='Prueba' LIMIT 1];
        SocialPersona persona = New SocialPersona();
        persona.Name = 'oskiki';
        persona.RealName = 'Oscar';
        persona.Provider='Other';
        persona.ParentId = sPost.Id;
        insert persona;
        SocialPersona sp1 = [SELECT Id FROM SocialPersona WHERE RealName = 'Oscar' LIMIT 1];
        sPost.PersonaId= sp1.Id;
        update sPost;

        SocialPersona sp = [SELECT Id FROM SocialPersona WHERE RealName = 'Oscar' LIMIT 1];
        List<DataTableWrapper> response = new List<DataTableWrapper>();
        CC_Busqueda_ALF_Controller.buscarCasos(sp.Id);

        system.assertNotEquals(null, sp);
    }

    public class DataTableWrapper {
        @AuraEnabled
        public Id caseId {get;set;}
        @AuraEnabled
        public String caseNumber {get;set;}
        @AuraEnabled
        public String caseNumberUrl {get;set;}
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public String subject {get;set;}
        @AuraEnabled
        public String origin {get;set;}
    }

    @isTest
    static void buscarPersona() {
        Case c = new Case();
        c.Subject = 'Prueba';
        c.Description = 'Prueba';
        c.Status = 'Activo';
        c.Origin = 'Comentarios Stores';
        c.CC_Idioma__c = 'es';
		c.CC_Tipo_Contacto__c = 'Consulta';
		c.CC_Tipo_Cliente__c = 'Cliente';
        c.CC_Canal_Procedencia__c = 'Google Play Store';
        insert c;

        Case cs = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c='Google Play Store' LIMIT 1];
        SocialPost socPost = New SocialPost();
        socPost.Content = 'Prueba';
        socPost.Handle = 'oskiki';
        socPost.ParentId = cs.Id;
        //socPost.PersonaId = '';
        socPost.Provider = 'Other';
        socPost.Name = 'Prueba';
        socPost.IsOutbound = true;
        insert socPost;

        SocialPost sPost = [SELECT Id,PersonaId FROM SocialPost WHERE Name='Prueba' LIMIT 1];
        SocialPersona persona = New SocialPersona();
        persona.Name = 'oskiki';
        persona.RealName = 'Oscar';
        persona.Provider='Other';
        persona.ParentId = sPost.Id;
        insert persona;

        SocialPersona sp = [SELECT Id FROM SocialPersona WHERE RealName = 'Oscar' LIMIT 1];
        cs.CC_Social_Persona__c = sp.Id;
        update cs;

        Case oidSP = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c='Google Play Store' LIMIT 1];
        SocialPersona oSP = CC_Busqueda_ALF_Controller.buscarSocialPersona (oidSP.Id);

        system.assertNotEquals(null, oSP);
	}

    /*@isTest
    public static void getContratosCliente() {

		// Alta de datos para la prueba
        Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        //Id recordTypeIdContrato = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Contrato').getRecordTypeId();
        Id recordTypeIdRepresentante = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
        Account cuenta = new Account(name='Test01',CC_Numero_Documento__c='12345678Z',CC_NumPerso__c = '99999991',RecordTypeId = recordTypeIdCliente);
		insert cuenta;
        Contact contacto = new Contact(LastName='Test01',CC_NumPerso__c = '99999991', Account=new Account(CC_NumPerso__c = '99999991'));
        insert contacto;
        CC_Representante_Contrato__c representante = new CC_Representante_Contrato__c();
        representante.RecordTypeId = recordTypeIdRepresentante;
        representante.CC_ClienteRepresentante__c = cuenta.Id;
        insert representante;
        CC_Representante_Contrato__c contrato = new CC_Representante_Contrato__c();
        contrato.RecordTypeId = recordTypeIdContrato;
        contrato.CC_ClienteContrato__c = cuenta.Id;
        insert contrato;

        // Ejecución de la prueba
        Test.startTest();
        //List<CC_Busqueda_ALF_Controller.ContratoPicklistItemWrapper> contratosCliente = CC_Busqueda_ALF_Controller.getContratosCliente(contacto.Id, 'Contacto');
        //List<CC_Busqueda_ALF_Controller.ContratoPicklistItemWrapper> representantesCliente = CC_Busqueda_ALF_Controller.getContratosCliente(representante.Id, 'Representante');
        Test.stopTest();

        // Evaluación del resultado de la prueba
        // TODO
    }*/

    @isTest
    public static void toDo() {
        Account cuenta1 = new Account();
        cuenta1.Name = 'Test01';
        cuenta1.CC_Numero_Documento__c = '12345678Z';
        cuenta1.CC_NumPerso__c = '99999991';
        cuenta1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta1.CC_TipoPersona__c = 'J';
		insert cuenta1;

        Contact contacto1 = new Contact();
        contacto1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
        contacto1.LastName = 'test';
        contacto1.CC_CuentaRepresentada__c = cuenta1.Id;
        insert contacto1;

        List<CC_Busqueda_ALF_Controller.RepresentanteOrContactoWrapper> resultado1 = CC_Busqueda_ALF_Controller.getRepresentantesOrContactosCliente(cuenta1.Id);

        Account cuenta2 = new Account();
        cuenta2.Name = 'Test02';
        cuenta2.CC_Numero_Documento__c = '12345678Z';
        cuenta2.CC_NumPerso__c = '99999992';
        cuenta2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta2.CC_TipoPersona__c = 'F';
		insert cuenta2;

        CC_Representante_Contrato__c representanteContrato1 = new CC_Representante_Contrato__c();
        representanteContrato1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante');
        representanteContrato1.CC_ClienteRepresentante__c = cuenta2.Id;
        insert representanteContrato1;

        CC_Representante_Contrato__c representanteContrato2 = new CC_Representante_Contrato__c();
        representanteContrato2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante');
        representanteContrato2.CC_RepresentanteAsociado__c = representanteContrato1.Id;
        insert representanteContrato2;

        List<CC_Busqueda_ALF_Controller.RepresentanteOrContactoWrapper> resultado2 = CC_Busqueda_ALF_Controller.getRepresentantesOrContactosCliente(cuenta2.Id);
    
		Account cuentaMenor = new Account();
        cuentaMenor.FirstName = 'Menor';
        cuentaMenor.LastName = '1';

        
        cuentaMenor.CC_Numero_Documento__c = '12345678Y';
        cuentaMenor.CC_NumPerso__c = '99999993';
        cuentaMenor.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        cuentaMenor.CC_TipoPersona__c = 'F';
        cuentaMenor.CC_FechaNac__pc  = Date.valueof('2020-10-28');
       
		insert cuentaMenor;

        CC_Representante_Contrato__c representanteContratoMenor = new CC_Representante_Contrato__c();
        representanteContratoMenor.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante');
        representanteContratoMenor.CC_ClienteRepresentante__c = cuentaMenor.Id;
        representanteContratoMenor.CC_Representante__c = cuenta2.Id;
        insert representanteContratoMenor;    
    
        
        List<CC_Busqueda_ALF_Controller.RepresentanteOrContactoWrapper> resultadoMenor = CC_Busqueda_ALF_Controller.getRepresentantesOrContactosCliente(cuentaMenor.Id);
		
    
    }

    @isTest
    public static void setClienteOpportunity() {
        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = 'Préstamo';
        valor.CC_Valor__c = '1';
        listaValores.CC_Activa__c = true;
        insert valor;

        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'CSBD Price Book';
        listaPrecios.Description = 'CSBD Price Book';
        listaPrecios.IsActive = true;
        insert listaPrecios;

        Account cuenta = new Account();
        cuenta.Name = 'Test01';
        cuenta.CC_Numero_Documento__c = '12345678Z';
        cuenta.CC_NumPerso__c = '99999991';
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.CC_TipoPersona__c = 'J';
		insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contacto.LastName = 'test';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Map<String, Object> campos = new Map<String, Object>();
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', contacto.Id);
        Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);

        CC_Busqueda_ALF_Controller.setClienteOpportunity(cuenta.Id, 'Cuenta', prestamo.Id);
        CC_Busqueda_ALF_Controller.setClienteOpportunity(contacto.Id, 'Contacto', prestamo.Id);
        CC_Busqueda_ALF_Controller.setClienteOpportunity(null, null, prestamo.Id);
    }

    @isTest
    public static void toDo2() {

        Account cuenta = new Account();
        cuenta.Name = 'Test01';
        cuenta.CC_Numero_Documento__c = '12345678Z';
        cuenta.CC_NumPerso__c = '99999991';
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.CC_TipoPersona__c = 'J';
		insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contacto.LastName = 'test';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Case caso = new Case();
        caso.Subject='Test01';
        caso.Description = 'Prueba2';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;

        CC_Llamada__c llamada = new CC_Llamada__c();
        insert llamada;

        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = 'Préstamo';
        valor.CC_Valor__c = '1';
        listaValores.CC_Activa__c = true;
        insert valor;

        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'CSBD Price Book';
        listaPrecios.Description = 'CSBD Price Book';
        listaPrecios.IsActive = true;
        insert listaPrecios;

        Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');

        CC_Busqueda_ALF_Controller.getTipoRegistro(caso.Id);
        CC_Busqueda_ALF_Controller.getTipoRegistro(llamada.Id);
        CC_Busqueda_ALF_Controller.getTipoRegistro(oportunidad.Id);

        CC_Busqueda_ALF_Controller.getEsPropietarioCaso(caso.Id);
        CC_Busqueda_ALF_Controller.getEsPropietarioCaso(llamada.Id);
        CC_Busqueda_ALF_Controller.getEsPropietarioCaso(oportunidad.Id);

        CC_Busqueda_ALF_Controller.setClienteLlamada(contacto.Id, 'Contacto', llamada.Id);
        CC_Busqueda_ALF_Controller.setClienteLlamada(contacto.Id, '', llamada.Id);

        CC_Busqueda_ALF_Controller.datosRegistro(caso.Id);
        CC_Busqueda_ALF_Controller.datosRegistro(llamada.Id);
        CC_Busqueda_ALF_Controller.datosRegistro(oportunidad.Id);
        
        CC_Busqueda_ALF_Controller.datosCaso(caso.Id);
        CC_Busqueda_ALF_Controller.datosLlamada(llamada.Id);

        CC_Busqueda_ALF_Controller.actualizarIdentificacion(caso.Id, true, 'Case',null);
        CC_Busqueda_ALF_Controller.actualizarIdentificacion(llamada.Id, true, 'CC_Llamada__c',null);
    } 
}