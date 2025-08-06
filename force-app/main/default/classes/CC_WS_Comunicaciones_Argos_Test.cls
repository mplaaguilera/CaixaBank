@isTest
public with sharing class CC_WS_Comunicaciones_Argos_Test {
    @TestSetup
    static void makeData(){
        User adminUser = CC_TestDataFactory.insertUserAdmin();
        User usuarioOperador = CC_TestDataFactory.insertUserOperadorCliente('U0123456a');
        System.runAs(adminUser){
                        
            CC_Settings__c setting = new CC_Settings__c();
            setting.Name = 'CC_Parametrizacion_WS_Argos';
            setting.CC_Activa__c = true;
            setting.CC_Configuracion_1__c = 'MENOR';
            setting.CC_Configuracion_2__c = 'JURIDICA';
            setting.CC_Configuracion_3__c = 'FISICA';
            setting.CC_Configuracion_4__c = '0027';
            setting.CC_Configuracion_6__c = '0001';
            setting.CC_Configuracion_7__c = 'ContactCenter';
            setting.CC_Configuracion_8__c = 'SALIENTE';
            setting.CC_Configuracion_9__c = 'ENTRADA';
            setting.CC_Configuracion_10__c = 'JURIDICA';
            insert setting;
            List<Account> lstAccounts = new List<Account>();
            List<Contact> lstContacts = new List<Contact>();

            Account cuenta = new Account(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA'),
            FirstName = 'Cuenta',
            LastName = 'Test',
            CC_Email__c = 'cuenta@test.com',
            PersonMobilePhone = '+34 123456789',
            PersonBirthdate = Date.newInstance(2000, 05, 22),
            CC_NumPerso__c = '206'
            );
            lstAccounts.add(cuenta);
            
            Account cuentaMenor = new Account(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA'),
                FirstName = 'Cuenta',
                LastName = 'Menor',
                PersonBirthdate = Date.newInstance(2014, 10, 22),
                PersonMobilePhone = '+34 123 123 123'
            );
            lstAccounts.add(cuentaMenor);

            Account cuentaJuridica = new Account(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'),
                Name = 'Cuenta Juridica'
            );
            lstAccounts.add(cuentaJuridica);

            insert lstAccounts;

            Contact contacto = new Contact(
                //RecordTypeId = recordTypeContacto,
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente'),
                FirstName = 'Contacto',
                LastName = 'Test',
                CC_Idioma__c = 'es',
                Email = 'contacto@test.com'
            );
            lstContacts.add(contacto);

            Contact apoderado = new Contact(
                //RecordTypeId = recordTypeContacto,
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CIBE_Apoderado'),
                FirstName = 'Apoderado',
                LastName = 'Test',
                CC_Idioma__c = 'es',
                Email = 'contacto@test.com',
                accountId = cuentaJuridica.Id
            );
            lstContacts.add(apoderado);

            insert lstContacts;

            CC_Representante_Contrato__c representante = new CC_Representante_Contrato__c(
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante'),
                CC_Nombre__c = 'Representante',
                CC_Apellido1__c = 'Test',
                CC_ClienteRepresentante__c = cuentaMenor.Id,
                CC_Representante__c = cuenta.Id
            );
            insert representante;

             CC_Caracteristica__c caracteristicaCuenta = new CC_Caracteristica__c();
            caracteristicaCuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Caracteristica__c', 'CC_Cliente_Cuenta');
            caracteristicaCuenta.Name = 'Característica Cuenta';
            caracteristicaCuenta.CC_Descripcion__c = 'descripcion';
            caracteristicaCuenta.OS_Negocio__c = 'FRA';
            caracteristicaCuenta.CC_RestriccionTotal__c = true;
            insert caracteristicaCuenta;

            
            
            Id recordTem = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            Id recordProd = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            Id recordMot = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');

            CC_MCC__c mcc = new CC_MCC__c();
            mcc.RecordTypeId = recordTem;
            mcc.Name = 'App\'s';
            mcc.CC_Tipo_Cliente__c = 'Cliente';
            mcc.CC_Codigo_Externo__c = 'TE-000001';
            mcc.CC_Canal_Operativo__c = 'App BrokerNow';
            insert mcc;
            CC_MCC__c mcc1 = new CC_MCC__c();
            mcc1.RecordTypeId = recordProd;
            mcc1.Name = 'APP CaixaBank';
            mcc1.CC_Detalle__c = 'CaixaBank';
            mcc1.CC_Tipo_Cliente__c = 'Cliente';
            mcc1.CC_Tematica__c = mcc.Id;
            mcc1.CC_Codigo_Externo__c = 'PR-000001';
            insert mcc1;
            CC_MCC__c mcc2 = new CC_MCC__c();
            mcc2.RecordTypeId = recordMot;
            mcc2.Name = 'Valoración positiva';
            mcc2.CC_Tipo_Cliente__c = 'Cliente';
            mcc2.CC_Producto_Servicio__c = mcc1.Id;
            mcc2.CC_Codigo_Externo__c = 'MO-000001';
            mcc2.CC_ImpedirNivel2__c = true;
            mcc2.CC_ImpedirClienteDigital__c = false;
            insert mcc2;
            
            CC_MCC__c mcc3 = new CC_MCC__c();
            mcc3.Name = 'Solicita reversión';
            mcc3.CC_Tipo_Cliente__c = 'Cliente';
            mcc3.CC_Fecha_Vigencia_Inicio__c = date.today();
            mcc3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
            mcc3.CC_Motivo__c = mcc2.Id;
            mcc3.CC_Codigo_Externo__c = 'CA-000001';
            mcc3.CC_Omitir_preguntas_Nivel_2__c = false;
            insert mcc3;
            CC_MCC__c mcc4 = new CC_MCC__c();
            mcc4.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
            mcc4.Name = 'Actualizar Sistema';
            mcc4.CC_Tipo_Cliente__c = 'Cliente';
            mcc4.CC_Causa__c = mcc3.Id;
            mcc4.CC_Codigo_Externo__c = 'CA-000002';
            insert mcc4;

            CC_MCC_Caracteristica__c mccCaracteristica = new CC_MCC_Caracteristica__c();
            mccCaracteristica.CC_MCC__c = mcc2.Id;
            mccCaracteristica.CC_Caracteristica__c = caracteristicaCuenta.Id;
            insert mccCaracteristica;
            
            List<CC_MCC__Share> totalPermisosMCC = new List<CC_MCC__Share>();
            for(CC_MCC__c record : [SELECT Id FROM CC_MCC__c]) {
                CC_MCC__Share mccShare = new CC_MCC__Share();
                mccShare.ParentId = record.Id;
                mccShare.UserOrGroupId = usuarioOperador.Id;
                mccShare.AccessLevel = 'Edit';
                totalPermisosMCC.add(mccShare);
            }
            insert totalPermisosMCC;

            List<AccountShare> totalPermisosAccount = new List<AccountShare>();
            for(Account a : [SELECT Id FROM Account]) {
                AccountShare acshare = new AccountShare();
                acshare.AccountId = a.Id;
                acshare.UserOrGroupId = usuarioOperador.Id;
                acshare.AccountAccessLevel = 'Edit';
                acshare.OpportunityAccessLevel = 'Edit';
                acshare.CaseAccessLevel = 'Edit';
                totalPermisosAccount.add(acshare);
            }

            insert totalPermisosAccount;
  
            List<ContactShare> totalPermisosContact = new List<ContactShare>();
            for(Contact c : [SELECT Id FROM Contact WHERE Account.RecordType.DeveloperName != 'CC_ClientePA' ]) {
            ContactShare contactShare = new ContactShare();
            contactShare.ContactId = c.Id;
            contactShare.UserOrGroupId = usuarioOperador.Id;
            contactShare.ContactAccessLevel = 'Edit';
            totalPermisosContact.add(contactShare);
            }

           insert totalPermisosContact ;

            Id rtClientes = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');

            List<Case> caseInsertLst = new List<Case>();

            //Caso Generico
            Case caso1 = new Case();
            caso1.RecordTypeId = rtClientes;
            caso1.Subject = 'Caso Test 1';
            caso1.Status = 'Activo';
            caso1.CC_Canal_Procedencia__c = 'Accionista';
            caso1.CC_Canal_Respuesta__c = 'Email';
            caso1.CC_Idioma__c = 'es';
            caso1.Origin = 'Phone';
            caso1.AccountId = cuenta.Id;
            caso1.ContactId = contacto.Id;
            caso1.CC_MailTelfNotif__c  = 'contacto@test.com';
            caso1.CC_MCC_Tematica__c = mcc.Id;
            caso1.CC_MCC_ProdServ__c = mcc1.Id;
            caso1.CC_MCC_Motivo__c = mcc2.Id;
            caso1.CC_MCC_Causa__c = mcc3.Id;
            caso1.CC_MCC_Solucion__c = mcc4.Id;
            caso1.CC_Telefono_Contacto__c = '+34 123456789';
            caseInsertLst.add(caso1);
            
            //Caso cuenta menor
            Case caso3 = new Case();
            caso3.RecordTypeId = rtClientes;
            caso3.Subject = 'Caso Test 2';
            caso3.CC_Canal_Procedencia__c= 'Accionista';
            caso3.CC_Representante__c = representante.Id;
            caso3.CC_Canal_Respuesta__c = 'Phone';
            caso3.CC_Idioma__c = 'es';
            caso3.Origin = 'Phone';
            caso3.AccountId = cuentaMenor.Id;
            caso3.ContactId = contacto.Id;
            caso3.CC_MailTelfNotif__c  = 'contacto@test.com';
            caso3.CC_MCC_Tematica__c = mcc.Id;
            caso3.CC_MCC_ProdServ__c = mcc1.Id;
            caso3.CC_MCC_Motivo__c = mcc2.Id;
            caso3.CC_MCC_Causa__c = mcc3.Id;
            caso3.CC_MCC_Solucion__c = mcc4.Id;
            caseInsertLst.add(caso3);

            //Caso juridico
            Case caso4 = new Case();
            caso4.RecordTypeId = rtClientes;
            caso4.Subject = 'Caso Test 3';
            caso4.CC_Canal_Procedencia__c = 'Accionista';
            caso4.CC_Canal_Respuesta__c = 'Phone';
            caso4.CC_Idioma__c = 'es';
            caso4.Origin = 'Phone';
            caso4.AccountId = cuentaJuridica.Id;
            caso4.ContactId = apoderado.Id;
            caso4.CC_MailTelfNotif__c  = 'contacto@test.com';
            caso4.CC_MCC_Tematica__c = mcc.Id;
            caso4.CC_MCC_ProdServ__c = mcc1.Id;
            caso4.CC_MCC_Motivo__c = mcc2.Id;
            caso4.CC_MCC_Causa__c = mcc3.Id;
            caso4.CC_MCC_Solucion__c = mcc4.Id;
            caseInsertLst.add(caso4);

            insert caseInsertLst;

            CBK_IntegrationSetting__c customSetting = new CBK_IntegrationSetting__c();
            customSetting.Name = 'CC_Argos';
            customSetting.NamedCredential__c = 'callout:API_GWT_TST_CCSF/itSecurity/fraudManagement/bis/operations/evaluation';
            customSetting.RegistroTrazaIntegracion__c = true;
            insert customSetting;
        } 
    }

    @isTest
    public static void testComunicacionesArgosOK() {
           Test.startTest();
           User usuarioOperador = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0123456a' LIMIT 1];
            System.runAs(usuarioOperador) {
            Case caso = [SELECT Id, OwnerId, Origin, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_Motivo_Derivacion__c,
                    CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_Motivo__c, CC_MCC_Motivo__r.Name, 
                    CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, 
                    Account.AV_IndicadoresClientes__c, RecordType.DeveloperName, CC_MCC_Causa__c, CC_Telefono_Contacto__c,
                    CC_MCC_Solucion__c, AccountId, ContactId, CC_Oportunidad_creada__c,Account.RecordType.DeveloperName, Account.AV_Segmento__c, Account.AV_NumPerso__c, Account.CC_NumPerso__c, Account.CC_Numero_Documento__c,
                    CC_Representante__r.CC_Representante__r.AV_IndicadoresClientes__c,  CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.CC_Numero_Documento__c, CC_Representante__r.CC_Representante__r.AV_NumPerso__c, Contact.RecordType.DeveloperName, Contact.CIBE_NumPerso__c, Contact.AV_NumPerso__c, Contact.CC_NumPerso__c, Contact.CC_Numero_Documento__c, CC_OTP_Nivel__c, CC_Status_Autorizacion__c 
                    FROM Case WHERE Subject LIKE 'Caso Test 1'];

           
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseArgos());
            
            Boolean pruebaDos = CC_WS_Comunicaciones_Argos.process(caso, false, false, null);
             System.assertEquals(true, pruebaDos, 'actualizar valor');
                 Test.stopTest();
        }
    }

       @isTest
    public static void testComunicacionesArgosKO() {
           Test.startTest();
           User usuarioOperador = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0123456a' LIMIT 1];
            System.runAs(usuarioOperador) {
            Case caso = [SELECT Id, OwnerId, Origin, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_Motivo_Derivacion__c,
                    CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_Motivo__c, CC_MCC_Motivo__r.Name, 
                    CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, 
                    Account.AV_IndicadoresClientes__c, RecordType.DeveloperName, CC_MCC_Causa__c, CC_Telefono_Contacto__c,
                    CC_MCC_Solucion__c, AccountId, ContactId, CC_Oportunidad_creada__c,Account.RecordType.DeveloperName, Account.AV_Segmento__c, Account.AV_NumPerso__c, Account.CC_NumPerso__c, Account.CC_Numero_Documento__c,
                    CC_Representante__r.CC_Representante__r.AV_IndicadoresClientes__c,  CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.CC_Numero_Documento__c, CC_Representante__r.CC_Representante__r.AV_NumPerso__c, Contact.RecordType.DeveloperName, Contact.CIBE_NumPerso__c, Contact.AV_NumPerso__c, Contact.CC_NumPerso__c, Contact.CC_Numero_Documento__c, CC_OTP_Nivel__c, CC_Status_Autorizacion__c 
                    FROM Case WHERE Subject LIKE 'Caso Test 1'];

            Boolean prueba = CC_WS_Comunicaciones_Argos.process(caso, false, false, null);

             System.assertEquals(false, prueba, 'actualizar valor');

            Test.stopTest();
        }
    }
@isTest
    public static void pruebaRepresentanteJuridicoMenor() {    
        Test.startTest();
        User usuarioOperador = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0123456a' LIMIT 1];
            System.runAs(usuarioOperador) {
            Case caso = [SELECT Id, OwnerId, Origin, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_Motivo_Derivacion__c,
            CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_Motivo__c, CC_MCC_Motivo__r.Name, 
            CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, 
            Account.AV_IndicadoresClientes__c, RecordType.DeveloperName, CC_MCC_Causa__c, CC_Telefono_Contacto__c,
            CC_MCC_Solucion__c, AccountId, ContactId, CC_Oportunidad_creada__c,Account.RecordType.DeveloperName, Account.AV_Segmento__c, Account.AV_NumPerso__c, Account.CC_NumPerso__c, Account.CC_Numero_Documento__c,
            CC_Representante__r.CC_Representante__r.AV_IndicadoresClientes__c,  CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.CC_Numero_Documento__c, CC_Representante__r.CC_Representante__r.AV_NumPerso__c, Contact.RecordType.DeveloperName, Contact.CIBE_NumPerso__c, Contact.AV_NumPerso__c, Contact.CC_NumPerso__c, Contact.CC_Numero_Documento__c, CC_OTP_Nivel__c, CC_Status_Autorizacion__c 
            FROM Case WHERE Subject LIKE 'Caso Test 2'];

            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());

            
            Boolean prueba = CC_WS_Comunicaciones_Argos.process(caso, false, true, null);
            
            System.assertEquals(false, prueba, 'actualizar valor');


            Test.stopTest();
            
            }
    }

@isTest
    public static void pruebaRepresentanteJuridico() {    
        Test.startTest();
        User usuarioOperador = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0123456a' LIMIT 1];
            System.runAs(usuarioOperador) {
            Case caso = [SELECT Id, OwnerId, Origin, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_Motivo_Derivacion__c,
            CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_Motivo__c, CC_MCC_Motivo__r.Name, 
            CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, 
            Account.AV_IndicadoresClientes__c, RecordType.DeveloperName, CC_MCC_Causa__c, CC_Telefono_Contacto__c,
            CC_MCC_Solucion__c, AccountId, ContactId, CC_Oportunidad_creada__c,Account.RecordType.DeveloperName, Account.AV_Segmento__c, Account.AV_NumPerso__c, Account.CC_NumPerso__c, Account.CC_Numero_Documento__c,
            CC_Representante__r.CC_Representante__r.AV_IndicadoresClientes__c,  CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.CC_Numero_Documento__c, CC_Representante__r.CC_Representante__r.AV_NumPerso__c, Contact.RecordType.DeveloperName, Contact.CIBE_NumPerso__c, Contact.AV_NumPerso__c, Contact.CC_NumPerso__c, Contact.CC_Numero_Documento__c, CC_OTP_Nivel__c, CC_Status_Autorizacion__c 
            FROM Case WHERE Subject LIKE 'Caso Test 3'];
            
            Boolean prueba = CC_WS_Comunicaciones_Argos.process(caso, false, false, null);
            
            System.assertEquals(false, prueba, 'actualizar valor');

            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());

            Boolean pruebaDos = CC_WS_Comunicaciones_Argos.process(caso, false, false, null);

            Test.stopTest();
            
            }
    }

    @isTest
    public static void pruebaRepresentanteJuridicoKO() {    
        Test.startTest();
        User usuarioOperador = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0123456a' LIMIT 1];
            System.runAs(usuarioOperador) {
            Case caso = [SELECT Id, OwnerId, Origin, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_Motivo_Derivacion__c,
            CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_Motivo__c, CC_MCC_Motivo__r.Name, 
            CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, 
            Account.AV_IndicadoresClientes__c, RecordType.DeveloperName, CC_MCC_Causa__c, CC_Telefono_Contacto__c,
            CC_MCC_Solucion__c, AccountId, ContactId, CC_Oportunidad_creada__c,Account.RecordType.DeveloperName, Account.AV_Segmento__c, Account.AV_NumPerso__c, Account.CC_NumPerso__c, Account.CC_Numero_Documento__c,
            CC_Representante__r.CC_Representante__r.AV_IndicadoresClientes__c,  CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.CC_Numero_Documento__c, CC_Representante__r.CC_Representante__r.AV_NumPerso__c, Contact.RecordType.DeveloperName, Contact.CIBE_NumPerso__c, Contact.AV_NumPerso__c, Contact.CC_NumPerso__c, Contact.CC_Numero_Documento__c, CC_OTP_Nivel__c, CC_Status_Autorizacion__c 
            FROM Case WHERE Subject LIKE 'Caso Test 3'];
            
            Boolean prueba = CC_WS_Comunicaciones_Argos.process(caso, false, false, null);
            
            System.assertEquals(false, prueba, 'actualizar valor');

            Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());

            Boolean pruebaDos = CC_WS_Comunicaciones_Argos.process(caso, false, true, null);

            Test.stopTest();
            
            }
    }

      @isTest
    public static void pruebaRepresentanteJuridicoOKBloquear() {    
        Test.startTest();
        User usuarioOperador = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0123456a' LIMIT 1];
            System.runAs(usuarioOperador) {
            Case caso = [SELECT Id, OwnerId, Origin, CC_MCC_Tematica__c, CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__c, CC_Motivo_Derivacion__c,
            CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__c, CC_Motivo__c, CC_MCC_Motivo__r.Name, 
            CC_MCC_Motivo__r.CC_Ambito_tareas_Imagin__c, CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c, 
            Account.AV_IndicadoresClientes__c, RecordType.DeveloperName, CC_MCC_Causa__c, CC_Telefono_Contacto__c,
            CC_MCC_Solucion__c, AccountId, ContactId, CC_Oportunidad_creada__c,Account.RecordType.DeveloperName, Account.AV_Segmento__c, Account.AV_NumPerso__c, Account.CC_NumPerso__c, Account.CC_Numero_Documento__c,
            CC_Representante__r.CC_Representante__r.AV_IndicadoresClientes__c,  CC_Representante__r.CC_Representante__r.CC_NumPerso__c, CC_Representante__r.CC_Representante__r.CC_Numero_Documento__c, CC_Representante__r.CC_Representante__r.AV_NumPerso__c, Contact.RecordType.DeveloperName, Contact.CIBE_NumPerso__c, Contact.AV_NumPerso__c, Contact.CC_NumPerso__c, Contact.CC_Numero_Documento__c, CC_OTP_Nivel__c, CC_Status_Autorizacion__c 
            FROM Case WHERE Subject LIKE 'Caso Test 3'];
            
            
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseArgos());
            
            Boolean pruebaDos = CC_WS_Comunicaciones_Argos.process(caso, false, true, null);
            System.assertEquals(true, pruebaDos, 'actualizar valor');

            Test.stopTest();
            
            }
    }

    private class MockHttpResponseArgos implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"operationFraudId":"fraudId","multiFactorAuthentication":"2","message":"Known user and device","device":{},"extraData":{"risk":[{"e":"valorE","ope":"ContactCenter","payee":"payee","first_try":"2025-05-23 08:00:28","last_try":"2025-05-23 08:00:28","usuclo":"usuclo","operation_id":"opid","restricted":false,"denied":false}]},"reason":"","operationNowId":"opNowId"}');
            res.setStatusCode(200);
            return res;
        }
    }

        private class MockHttpResponseExito implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) { 
            String bodyClienteDigital = '{"operationFraudId":"fraudId","multiFactorAuthentication":"0","message":"Known user and device","device":{},"extraData":{"risk":[{"e":"valorE","ope":"ContactCenter","payee":"payee","first_try":"2025-05-23 08:00:28","last_try":"2025-05-23 08:00:28","usuclo":"usuclo","operation_id":"opid","restricted":false,"denied":false}]},"reason":"","operationNowId":"opNowId"}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(bodyClienteDigital);
            res.setStatusCode(200);
            return res;
        }
    }

    private class MockHttpResponseError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) { 
            String bodyClienteDigital = '{"operationFraudId":"fraudId","multiFactorAuthentication":"2","message":"Known user and device","device":{},"extraData":{"risk":[]},"reason":"","operationNowId":"opNowId"}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody(bodyClienteDigital);
            res.setStatusCode(400);
            return res;
        }
    }

}