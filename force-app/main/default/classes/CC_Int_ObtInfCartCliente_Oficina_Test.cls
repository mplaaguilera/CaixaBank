@isTest
public class CC_Int_ObtInfCartCliente_Oficina_Test {
    @TestSetup
    static void testSetup() {
         List<User> userList = new List<User>();
        User usuario2 = new User();
        usuario2.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        usuario2.FirstName = 'Usuario Admin Prueba';
        usuario2.LastName = 'last211';
        usuario2.Email = 'aalsdna@kfsb.com';
        usuario2.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario2.CompanyName = 'MST';
        usuario2.Title = 'title';
        usuario2.Alias = 'alias';
        usuario2.TimeZoneSidKey = 'Europe/Paris';
        usuario2.EmailEncodingKey = 'UTF-8';
        usuario2.LanguageLocaleKey = 'es';
        usuario2.LocaleSidKey = 'es_ES';
        insert usuario2;
        
        system.runAs(usuario2){
        User usuario1 = new User();
        usuario1.Alias = 'standt1';
        usuario1.Email = 'standarduser1@testorg.com';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LastName = 'Testing';
        usuario1.LanguageLocaleKey ='en_US';
        usuario1.LocaleSidKey = 'en_US';
        usuario1.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id;
        usuario1.TimeZoneSidKey = 'America/Los_Angeles';
        usuario1.UserName = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0,8) + '@myorg.com';
        usuario1.AV_ExternalID__c = 'U0123456';
        usuario1.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        insert usuario1;
             }

        //Cuentas centro caixabank
        Account cuentaCentro = new Account();
        cuentaCentro.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        cuentaCentro.Name = 'Centro CaixaBank';
        insert cuentaCentro;

        Contact contactoEmpleado = new Contact();
        contactoEmpleado.LastName = 'Test contacto';
        contactoEmpleado.Email = 'test@test.es';
        contactoEmpleado.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contactoEmpleado.AccountId = cuentaCentro.Id;
        contactoEmpleado.CC_Matricula__c = 'U0165432';
        insert contactoEmpleado;
        
        //Cuentas cliente
        List<Account> accountsInsert = new List<Account>();

        Account cuentaCliente = new Account();
        cuentaCliente.LastName = 'Cliente Senior'; 
        cuentaCliente.CC_NumPerso__c = '0000012';
        cuentaCliente.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        accountsInsert.add(cuentaCliente);
        
        Account cuentaCliente2 = new Account();
        cuentaCliente2.LastName = 'Cliente No senior'; 
        cuentaCliente2.CC_NumPerso__c = '0000060';
        cuentaCliente2.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        cuentaCliente2.AV_EAPGestor__c = contactoEmpleado.Id;
        accountsInsert.add(cuentaCliente2);

        /*Account cuentaSinGestor = new Account();
        cuentaCliente2.LastName = 'Cliente Sin Gestor';
        cuentaCliente2.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        cuentaCliente2.AV_EAPGestor__c = contactoEmpleado.Id;
        accountsInsert.add(cuentaSinGestor);*/

        insert accountsInsert;

        //Casos
        List<Case> casosInsert = new List<Case>();

        Case casoCC = new Case();
        casoCC.Subject = 'Caso de Contact Center';
        casoCC.Description = 'Caso de Contact Center';
        casoCC.CC_Idioma__c = 'es';
        casoCC.Origin = 'Email';
        casoCC.CC_Tipo_Contacto__c = 'Consulta';
        casoCC.CC_Canal_Procedencia__c = 'Formulario web';
        casoCC.CC_Detalles_Consulta__c = 'Caso de Contact Center';
        casoCC.Status = 'Activo';
        casoCC.AccountId = cuentaCliente.Id;
        casoCC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        casosInsert.add(casoCC);

        Case casoCC2 = new Case();
        casoCC2.Subject = 'Caso de Contact Center 2';
        casoCC2.Description = 'Caso de Contact Center';
        casoCC2.CC_Idioma__c = 'es';
        casoCC2.Origin = 'Email';
        casoCC2.CC_Tipo_Contacto__c = 'Consulta';
        casoCC2.CC_Canal_Procedencia__c = 'Formulario web';
        casoCC2.CC_Detalles_Consulta__c = 'Caso de Contact Center';
        casoCC2.Status = 'Activo';
        casoCC2.AccountId = cuentaCliente2.Id;
        casoCC2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        casosInsert.add(casoCC2);

       /* Case casoSinGestor = new Case();
        casoSinGestor.Subject = 'Caso de Contact Center sin gestor';
        casoSinGestor.Description = 'Caso de Contact Center sin gestor';
        casoSinGestor.CC_Idioma__c = 'es';
        casoSinGestor.Origin = 'Email';
        casoSinGestor.CC_Tipo_Contacto__c = 'Consulta';
        casoSinGestor.CC_Canal_Procedencia__c = 'Formulario web';
        casoSinGestor.CC_Detalles_Consulta__c = 'Caso de Contact Center';
        casoSinGestor.Status = 'Activo';
        casoSinGestor.AccountId = cuentaSinGestor.Id;
        casoSinGestor.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        casosInsert.add(casoSinGestor);*/

        insert casosInsert;
       
        CC_Lista_Valores__c listaValor = new CC_Lista_Valores__c();
        listaValor.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        listaValor.CC_Activa__c = true;
        listaValor.Name = 'Gestor por defecto CC';
        insert listaValor;
        
        CC_Lista_Valores__c valorId = new CC_Lista_Valores__c();
        valorId.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorId.CC_Activa__c = true;
        valorId.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c  WHERE name = 'Gestor por defecto CC'].Id;
        valorId.Name = 'ExternalID';
        valorId.CC_Valor__c = '000000';
        insert valorId;
        
        CC_Lista_Valores__c valorName = new CC_Lista_Valores__c();
        valorName.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorName.CC_Activa__c = true;
        valorName.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c  WHERE name = 'Gestor por defecto CC'].Id;
        valorName.Name = 'Nombre';
        valorName.CC_Valor__c = 'Sin Gestor/EAP';
        insert valorName;
       
    }

    private class MockHttpResponseExito implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            CC_Int_ObtInfCarterizaCliente.RespuestaClienteDigital respuestaClienteDigital = new CC_Int_ObtInfCarterizaCliente.RespuestaClienteDigital();
            respuestaClienteDigital.empleado1 = '62433';
            respuestaClienteDigital.gestorOEAP1 = 'E';
            respuestaClienteDigital.oficina1 = '2591';
            respuestaClienteDigital.clienteDigital = 'N';
            respuestaClienteDigital.muroAbierto = 'N';
            respuestaClienteDigital.resultado = 'OK';
            respuestaClienteDigital.pilotoAppNow1 = 'S';
            respuestaClienteDigital.indSexo1 = 'H';

            String bodyClienteDigital = JSON.serialize(respuestaClienteDigital);

            HttpResponse res = new HttpResponse();
            res.setHeader('x-absis-customerInternalId', '0000012');
            res.setBody(bodyClienteDigital);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    private static void esClienteDigital(){
        User u = [SELECT Id FROM User WHERE IsActive = true AND LastName = 'Testing' AND UserRole.DeveloperName = 'Contact_Center' AND Email = 'standarduser1@testorg.com'];

        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
        System.RunAs(u){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
            Map<Object, Object> respuesta = CC_Int_ObtInfCarterizaCliente.esClienteDigital(caso.Id, 'Tarea gestor');      
            Test.stopTest();
            
        System.assertEquals('OK', respuesta.get('resultado'));
        System.assertEquals('62433', respuesta.get('empleado1'));
            }
    }

    private class MockHttpResponseExitoConGestor implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            CC_Int_ObtInfCarterizaCliente.RespuestaClienteDigital respuestaClienteDigital = new CC_Int_ObtInfCarterizaCliente.RespuestaClienteDigital();
            respuestaClienteDigital.empleado1 = '23456';
            respuestaClienteDigital.gestorOEAP1 = 'E';
            respuestaClienteDigital.oficina1 = '2591';
            respuestaClienteDigital.clienteDigital = 'S';
            respuestaClienteDigital.muroAbierto = 'N';
            respuestaClienteDigital.resultado = 'OK';
            respuestaClienteDigital.pilotoAppNow1 = 'S';
            respuestaClienteDigital.indSexo1 = 'H';

            String bodyClienteDigital = JSON.serialize(respuestaClienteDigital);

            HttpResponse res = new HttpResponse();
            res.setHeader('x-absis-customerInternalId', '0000060');
            res.setBody(bodyClienteDigital);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    private static void esClienteDigitalConGestor(){
        User u = [SELECT Id FROM User WHERE IsActive = true AND LastName = 'Testing' AND UserRole.DeveloperName = 'Contact_Center' AND Email = 'standarduser1@testorg.com'];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center 2'];
         System.RunAs(u){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExitoConGestor());
            Map<Object, Object> respuesta = CC_Operativa_Oficina_Controller.esClienteDigital(caso.Id, 'Cita gestor');      
            Test.stopTest();
            System.assertEquals('OK', respuesta.get('resultado'));
            System.assertEquals('23456', respuesta.get('empleado1'));
         }
    }

    private class MockHttpResponseExitoSinGestor implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            CC_Int_ObtInfCarterizaCliente.RespuestaClienteDigital respuestaClienteDigital = new CC_Int_ObtInfCarterizaCliente.RespuestaClienteDigital();
            respuestaClienteDigital.clienteDigital = 'S';
            respuestaClienteDigital.muroAbierto = 'N';
            respuestaClienteDigital.resultado = 'OK';
            respuestaClienteDigital.pilotoAppNow1 = 'S';
            respuestaClienteDigital.indSexo1 = 'H';

            String bodyClienteDigital = JSON.serialize(respuestaClienteDigital);

            HttpResponse res = new HttpResponse();
            res.setHeader('x-absis-customerInternalId', '0000060');
            res.setBody(bodyClienteDigital);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    private static void esClienteDigitalSinGestor(){
        User u = [SELECT Id FROM User WHERE IsActive = true AND LastName = 'Testing' AND UserRole.DeveloperName = 'Contact_Center' AND Email = 'standarduser1@testorg.com'];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center 2'];
         System.RunAs(u){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExitoSinGestor());
            Map<Object, Object> respuesta = CC_Operativa_Oficina_Controller.esClienteDigital(caso.Id, 'Cita gestor');      
            Test.stopTest();
            System.assertEquals('OK', respuesta.get('resultado'));
            System.assertEquals(null, respuesta.get('empleado1'));
        }
    }

    @isTest
    private static void llamadaKO(){
        User u = [SELECT Id FROM User WHERE IsActive = true AND LastName = 'Testing' AND UserRole.DeveloperName = 'Contact_Center' AND Email = 'standarduser1@testorg.com'];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center 2'];
        System.RunAs(u){
            Test.startTest();
            Map<Object, Object> respuesta = CC_Operativa_Oficina_Controller.esClienteDigital(caso.Id, 'Cita gestor');      
            Test.stopTest();
            System.assertEquals('KO', respuesta.get('resultado'));
         }
    }
}