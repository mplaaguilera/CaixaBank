@isTest
public with sharing class CC_WS_Alta_Citas_Test {
    @testSetup 
    static void setup() {
        Id profileCC = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];       
        UserRole rolCC = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        Id recordTypeLista = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        Id recordTypeValor = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        
        List<User> userList = new List<User>();
        User admin = new User();
        admin.ProfileId = profileAdmin;
        admin.FirstName = 'Usuario Admin Prueba';
        admin.LastName = 'last211';
        admin.Email = 'aalsdna@kfsb.com';
        admin.Username = 'tuser0001@amamama.com' + System.currentTimeMillis();
        admin.CompanyName = 'MST';
        admin.Title = 'title';
        admin.Alias = 'alias';
        admin.TimeZoneSidKey = 'Europe/Paris';
        admin.EmailEncodingKey = 'UTF-8';
        admin.LanguageLocaleKey = 'es';
        admin.LocaleSidKey = 'es_ES';
        userList.add(admin);

        User agente = new User();
        agente.profileId = profileCC;
        agente.UserRoleId = rolCC.Id;
        agente.FirstName = '';
        agente.LastName = 'CC_Usuario_CaixaBank';
        agente.Email = 'tuser000@amamama.com';
        agente.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        agente.CompanyName = 'MST';
        agente.Title = 'title';
        agente.Alias = 'alias';
        agente.TimeZoneSidKey = 'Europe/Paris';
        agente.EmailEncodingKey = 'UTF-8';
        agente.LanguageLocaleKey = 'es';
        agente.LocaleSidKey = 'es_ES';
        userList.add(agente);
        insert userList;

        insert new PermissionSetAssignment(AssigneeId = agente.Id, PermissionSetId = ps.Id);

        List <CC_Settings__c> settingsList = new List <CC_Settings__c>();

        CC_Settings__c reservationType = new CC_Settings__c(
            Name = 'CC_Configuracion_Cita_Rapida',
            CC_Activa__c = true,
            CC_Configuracion_1__c = 'true',
            CC_Configuracion_2__c = 'TELEMATIC',
            CC_Configuracion_6__c = '4'
        );
        settingsList.add(reservationType);

        CBK_IntegrationSetting__c customSetting = new CBK_IntegrationSetting__c();
        customSetting.Name = 'CC_Alta_Cita';
        customSetting.NamedCredential__c = 'callout:API_GWT_TST_CC/customerManagement/customerRelationshipManagement/sales/xpe/customers/id/reservation';
        customSetting.RegistroTrazaIntegracion__c = true;
       
        System.runAs(admin) {
            Account cuentaCliente = new Account();
            cuentaCliente.LastName = 'Cliente Senior';
            cuentaCliente.CC_NumPerso__c = '0000012';
            cuentaCliente.AV_IndicadoresClientes__c = '28';
            cuentaCliente.RecordtypeId =  rtClientePA;
            cuentaCliente.CC_Numero_Documento__c = '45729937A';
            cuentaCliente.AV_Cliente__c = true;
            cuentaCliente.PersonEmail = 'test@test.com';
            insert cuentaCliente;

            Case caso = new Case();
            caso.Subject = 'Caso cita gestor';
            caso.Origin = 'Email';
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.RecordTypeId = recordTypeCaso;
            caso.accountId = cuentaCliente.Id;
            caso.OwnerId = agente.Id;
            insert caso;
            insert customSetting;
            insert settingsList;

            CC_Lista_Valores__c listaDerivar = new CC_Lista_Valores__c();
            listaDerivar.Name = 'Textos operativa Derivar';
            listaDerivar.RecordTypeId = recordTypeLista;
            insert listaDerivar;

            List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();
            CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c();
            valor1.Name = 'Toast cita rapida presencial';
            valor1.RecordTypeId = recordTypeValor;
            valor1.CC_Lista__c = listaDerivar.Id;
            valor1.CC_Mensajes_Mostrar__c = 'El cliente debe acudir presencialmente el día XX a las XX:XX horas a la oficina';
            valores.add(valor1);
            
            CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
            valor2.Name = 'Toast cita rapida telefonica';
            valor2.RecordTypeId = recordTypeValor;
            valor2.CC_Lista__c = listaDerivar.Id;
            valor2.CC_Mensajes_Mostrar__c = 'Informar al cliente que su gestor se pondrá en contacto con él el día XX a las XX:XX horas';
            valores.add(valor2);
            insert valores;
        }
    }

    @isTest
    static void altaCitaOK() {
        User usuario = [SELECT Id FROM User WHERE LastName = 'CC_Usuario_CaixaBank'];
        Id recordId = [SELECT Id FROM Case WHERE Subject = 'Caso cita gestor'].Id;
        System.runAs(usuario) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
            Map<String, Object> resultado = CC_WS_Alta_Citas.crearAltaCita('123450', '134598', '2024-12-20', '10:30 - 11:00', 'Cita gestor', recordId, '42');
            Test.stopTest();
            System.assertEquals(false, resultado.size() == 0);
        }
    }

    @isTest
    static void altaCitaKOIntegracion() {
        Boolean excepcion = false;
        User usuario = [SELECT Id FROM User WHERE LastName = 'CC_Usuario_CaixaBank'];
        Id recordId = [SELECT Id FROM Case WHERE Subject = 'Caso cita gestor'].Id;
        System.runAs(usuario) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());
            try {
                Map<String, Object> resultadoNumPerKO = CC_WS_Alta_Citas.crearAltaCita('12345','1345', '2024-11-20', '10:30 - 11:00', 'Cita gestor', recordId, '42');
            } catch (Exception e) {
                excepcion = true;
            }
            Test.stopTest();
            System.assertEquals(excepcion, true);
        }
    }

    private class MockHttpResponseExito implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) { 
            String respuesta = '{"appointmentId":"0000000500002311"}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(respuesta);
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    private class MockHttpResponseError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) { 
            String respuesta = '{"detail":"altaReserva - Ya existe una reserva anterior del cliente en el centro ","stackTrace":[],"type":"customerRelationshipManagement/invalid-appointment","status":400}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(respuesta);
            res.setStatusCode(400);
            res.setStatus('KO');
            return res;
        }
    }
}