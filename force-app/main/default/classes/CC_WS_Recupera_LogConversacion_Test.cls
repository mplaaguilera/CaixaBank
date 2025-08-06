@isTest
public with sharing class CC_WS_Recupera_LogConversacion_Test {
    @testSetup 
    static void setup() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank_Empleados'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        UserRole rolCC = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        PermissionSet psOperador = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        List<Account> lstAccounts = new List<Account>();
        List<Contact> lstContacts = new List<Contact>();

        User usuarioAdmin = new User();        
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = rolCC.Id;
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
                 
        User operador = new User();
        operador.ProfileId = profileId;
        operador.FirstName = 'OperadorEmpleadoTest';
        operador.LastName = 'last11';
        operador.Email = 'tuser000@amamama.com';
        operador.Phone = '+34 123456789';
        operador.Username = 'tuser000@operador.com' + System.currentTimeMillis();
        operador.CompanyName = 'MST';
        operador.Title = 'title';
        operador.Alias = 'alias';
        operador.TimeZoneSidKey = 'Europe/Paris';
        operador.EmailEncodingKey = 'UTF-8';
        operador.LanguageLocaleKey = 'es';
        operador.LocaleSidKey = 'es_ES';
        operador.UserRoleId = rolCC.Id;
        insert new List<User>{operador, usuarioAdmin};

        insert new List<PermissionSetAssignment> {
            new PermissionSetAssignment(AssigneeId = operador.Id, PermissionSetId = psOperador.Id),
            new PermissionSetAssignment(AssigneeId = operador.Id, PermissionSetId = psClasses.Id)
        };

        System.runAs(usuarioAdmin) {
            Account cuenta = new Account();
            cuenta.Name = 'Prueba';
            cuenta.CC_Numero_Oficina_Empresa__c = '11111-001';
            cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
            insert cuenta;

            Contact contacto = new Contact();
            contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
            contacto.AccountId = cuenta.Id;
            contacto.LastName = 'empleado prueba 1';
            contacto.FirstName = 'empleado prueba 1';
            contacto.CC_Idioma__c = 'es';
            contacto.Email = 'test@contact.com';
            contacto.CC_Matricula__c = '9265';
            contacto.CC_NumPerso__c = '123456';
            insert contacto;

            List<CC_Canal_Com__c> listaCanales = new List<CC_Canal_Com__c>();
			Id recordTypeTelefono = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Canal_Com__c', 'CC_Telefono');
			listaCanales.add(new CC_Canal_Com__c(CC_Telefono__c='666001122', CC_ContactoId__c=contacto.Id, CC_CuentaId__c=cuenta.Id, RecordTypeId = recordTypeTelefono));
			insert listaCanales;

            CC_MCC__c mcc = new CC_MCC__c();
            mcc.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            mcc.Name = 'App\'s';
            mcc.CC_Tipo_Cliente__c = 'Empleado';
            mcc.CC_Codigo_Externo__c = 'TE-000001';
            mcc.CC_Canal_Operativo__c = 'App BrokerNow';
            insert mcc;
            CC_MCC__c mcc1 = new CC_MCC__c();
            mcc1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
            mcc1.Name = 'APP CaixaBank';
            mcc1.CC_Detalle__c = 'CaixaBank';
            mcc1.CC_Tipo_Cliente__c = 'Empleado';
            mcc1.CC_Tematica__c = mcc.Id;
            mcc1.CC_Codigo_Externo__c = 'PR-000001';
            insert mcc1;
            CC_MCC__c mcc2 = new CC_MCC__c();
            mcc2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            mcc2.Name = 'Valoración positiva';
            mcc2.CC_Tipo_Cliente__c = 'Empleado';
            mcc2.CC_Producto_Servicio__c = mcc1.Id;
            mcc2.CC_Codigo_Externo__c = 'MO-000001';
            mcc2.CC_ImpedirNivel2__c = true;
            mcc2.CC_ImpedirClienteDigital__c = false;
            insert mcc2;
            CC_MCC__c mcc3 = new CC_MCC__c();
            mcc3.Name = 'Solicita reversión';
            mcc3.CC_Tipo_Cliente__c = 'Empleado';
            mcc3.CC_Fecha_Vigencia_Inicio__c = date.today();
            mcc3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');
            mcc3.CC_Motivo__c = mcc2.Id;
            mcc3.CC_Codigo_Externo__c = 'CA-000001';
            insert mcc3;
            CC_MCC__c mcc4 = new CC_MCC__c();
            mcc4.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Solucion');
            mcc4.Name = 'Actualizar Sistema';
            mcc4.CC_Tipo_Cliente__c = 'Empleado';
            mcc4.CC_Causa__c = mcc3.Id;
            mcc4.CC_Codigo_Externo__c = 'CA-000002';
            insert mcc4;
            
            List<Case> caseInsertLst = new List<Case>();
            Case caso1 = new Case();
            caso1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Empleado');
            caso1.Subject = 'Caso Test 1';
            caso1.Status = 'Activo';
            caso1.CC_Canal_Procedencia__c = 'Activo';
            caso1.CC_Canal_Respuesta__c = 'Activo';
            caso1.CC_Idioma__c = 'es';
            caso1.Origin = 'Chat';
            caso1.OwnerId = operador.Id;
            caso1.AccountId = cuenta.Id;
            caso1.ContactId = contacto.Id;
            caso1.CC_MailTelfNotif__c  = 'contacto@test.com';
            caso1.CC_MCC_Tematica__c = mcc.Id;
            caso1.CC_MCC_ProdServ__c = mcc1.Id;
            caso1.CC_MCC_Motivo__c = mcc2.Id;
            caso1.CC_MCC_Causa__c = mcc3.Id;
            caso1.CC_MCC_Solucion__c = mcc4.Id;
            caso1.CC_Tipo_Contacto__c = 'Consulta';
            caso1.CC_Tipo_ChatTranscript__c = 'Hidden';
            caso1.CC_Detalles_Consulta__c = 'Prueba';
            caso1.CC_Detalles_Solucion__c = 'Prueba';
            caso1.CC_Id_Cognitivo__c = '87654321_9999998';
            caseInsertLst.add(caso1);
            insert caseInsertLst;

            List<CC_MCC__Share> totalPermisosMCC = new List<CC_MCC__Share>();
            for(CC_MCC__c record : [SELECT Id FROM CC_MCC__c]) {
                CC_MCC__Share mccShare = new CC_MCC__Share();
                mccShare.ParentId = record.Id;
                mccShare.UserOrGroupId = operador.Id;
                mccShare.AccessLevel = 'Edit';
                totalPermisosMCC.add(mccShare);
            }
            insert totalPermisosMCC;

            List<AccountShare> totalPermisosAccount = new List<AccountShare>();
            for(Account a : [SELECT Id FROM Account]) {
                AccountShare acshare = new AccountShare();
                acshare.AccountId = a.Id;
                acshare.UserOrGroupId = operador.Id;
                acshare.AccountAccessLevel = 'Edit';
                acshare.OpportunityAccessLevel = 'Edit';
                acshare.CaseAccessLevel = 'Edit';
                totalPermisosAccount.add(acshare);
            }
            Database.insert(totalPermisosAccount, false);

            
            List<ContactShare> totalPermisosContact = new List<ContactShare>();
            for(Contact c : [SELECT Id FROM Contact]) {
            ContactShare contactShare = new ContactShare();
            contactShare.ContactId = c.Id;
            contactShare.UserOrGroupId = operador.Id;
            contactShare.ContactAccessLevel = 'Edit';
            totalPermisosContact.add(contactShare);
            }

            Database.insert(totalPermisosContact, false);

            List<CaseShare> totalPermisosCase = new List<CaseShare>();
            for(Case c : [SELECT Id FROM Case]) {
                CaseShare cseShr = new CaseShare();

                cseShr.CaseId = c.Id;
                cseShr.UserOrGroupId = operador.Id;
                cseShr.CaseAccessLevel  = 'Edit';
                totalPermisosCase.add(cseShr);
            }
            Database.insert(totalPermisosCase, false);

            List<CC_Settings__c> listaSettings = new List<CC_Settings__c>();
            CC_Settings__c configuracion = new CC_Settings__c();
            configuracion.CC_Activa__c = false;
            configuracion.Name = 'CC_Agrupador_CI_Asignacion_Casos';
            configuracion.CC_Configuracion_1__c = 'false';
            listaSettings.add(configuracion);           
            CC_Settings__c configuracion1 = new CC_Settings__c();
            configuracion1.CC_Activa__c = false;
            configuracion1.Name = 'CC_Agrupador_CIC_Asignacion_Casos';
            configuracion1.CC_Configuracion_1__c = 'true';
            listaSettings.add(configuracion1);    
            CC_Settings__c configuracion2 = new CC_Settings__c();
            configuracion2.CC_Activa__c = false;
            configuracion2.Name = 'CC_Agrupador_CIM_Asignacion_Casos';
            configuracion2.CC_Configuracion_1__c = 'true';
            listaSettings.add(configuracion2);
            insert listaSettings;

        }

    }
    
    // Test con caso existente para que lo devuelva con status='Activo'
    @isTest
    public static void testCasoCerrado() {       
    User operador = [SELECT Id FROM User WHERE FirstName = 'OperadorEmpleadoTest' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1]; 
    System.runAs(operador) {
        Test.startTest();
        Case oCaseCerrado = [SELECT Origin, Status, CC_Idioma__c, CC_Canal_Respuesta__c, OwnerId, AccountId FROM Case WHERE Subject = 'Caso Test 1' LIMIT 1];
        oCaseCerrado.Status = 'Cerrado';
        update oCaseCerrado;
        Account cuenta = [SELECT Id FROM Account WHERE Name = 'Prueba' LIMIT 1];
        Contact contacto = [SELECT Id, CC_NumPerso__c FROM Contact WHERE LastName = 'empleado prueba 1' LIMIT 1];
        CC_Servicio_Genesys__c s1 = CC_Llamada_GC_Test.crearServicioEmpleado();
            CC_Llamada_Input inputLlamada = CC_Llamada_GC_Test.obtenerInputLlamada(s1.CC_Codigo__c, '', '', contacto.CC_NumPerso__c, null);
            inputLlamada.cognitivoId = '87654321_9999998';
            inputLlamada.connIdCognitivo = '87654321_9999998';
            Map<String, Object> retornoRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);
                    
            Case  oCaso = (Case)retornoRegistrarLlamadaEntrante.get('caso');
            assert.areEqual('Activo', oCaso.Status, 'El caso no se ha reactivado correctamente');
        Test.stopTest();
        }
    }
    
    @isTest
    public static void testCasoChat() {        
        User operador = [SELECT Id FROM User WHERE FirstName = 'OperadorEmpleadoTest' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1]; 
        System.runAs(operador) {
            Test.startTest();
            Account cuenta = [SELECT Id FROM Account WHERE Name = 'Prueba' LIMIT 1];
            Contact contacto = [SELECT Id, CC_NumPerso__c FROM Contact WHERE LastName = 'empleado prueba 1' LIMIT 1];

            CC_Servicio_Genesys__c s1 = CC_Llamada_GC_Test.crearServicioEmpleado();
            CC_Llamada_Input inputLlamada = CC_Llamada_GC_Test.obtenerInputLlamada(s1.CC_Codigo__c, '', null, contacto.CC_NumPerso__c, '666001122');
            inputLlamada.cognitivoId = '87654321_9999999';
            inputLlamada.connIdCognitivo = '87654321_9999999';
            Map<String, Object> retornoRegistrarLlamadaEntrante = CC_Llamada_GC.registrarLlamadaEntrante(inputLlamada);

            Case  oCaso = [SELECT Origin, Status, CC_Idioma__c, CC_Canal_Respuesta__c, OwnerId, AccountId FROM Case WHERE CC_Id_Cognitivo__c = '87654321_9999999' LIMIT 1];
            assert.areEqual('Activo', oCaso.Status, 'Hubo un problema al crear el caso');

            Test.stopTest();
            }     
    }
}