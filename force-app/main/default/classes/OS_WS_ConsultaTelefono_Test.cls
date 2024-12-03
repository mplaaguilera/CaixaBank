@isTest
public with sharing class OS_WS_ConsultaTelefono_Test {
    @testSetup
    private static void setup() {
        User usuarioResponsable = OS_Usuarios.usuarioResponsable();

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta Caixabank Gestor';
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        //cuenta.OwnerId = usuarioAdministrador.Id;
        cuenta.CC_Email__c = [SELECT Id, Address FROM OrgWideEmailAddress LIMIT 1].Address;
        cuenta.CC_Numero_Oficina__c = '00044';
        cuenta.Phone = '123456789';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contacto.AccountId = cuenta.Id;
        contacto.Phone = '987654321';
        contacto.LastName = 'contacto test';
        insert contacto;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'ResponsableOS' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        //acshare.ContactAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;
    }

    @isTest
    public static void consultaTelefonoEmpleado(){
        User usuarioResponsable = [SELECT Id FROM User WHERE FirstName = 'ResponsableOS' LIMIT 1];
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/consultaTelefonoEmpleadoCentro/obtenerContactoTelefono';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"ani": "987654321"}');
        RestContext.request = request;
        RestContext.response = response;

        System.runAs (usuarioResponsable){
            Test.startTest();
            OS_WS_ConsultaTelefono.Output output = OS_WS_ConsultaTelefono.obtenerContactoTelefono();
            String respuesta = output.contacto;    
            Test.stopTest();
            System.assertEquals('OK#100', respuesta);
        }
        
    }

    @isTest
    public static void consultaTelefonoCentro(){
        User usuarioResponsable = [SELECT Id FROM User WHERE FirstName = 'ResponsableOS' LIMIT 1];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/consultaTelefonoEmpleadoCentro/obtenerContactoTelefono';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"ani": "123456789"}');
        RestContext.request = request;
        RestContext.response = response;

        Account cuente = [SELECT Id FROM Account WHERE Name = 'Cuenta Caixabank Gestor'];

        System.runAs (usuarioResponsable){
            Test.startTest();
            OS_WS_ConsultaTelefono.Output output = OS_WS_ConsultaTelefono.obtenerContactoTelefono();
            String respuesta = output.contacto;    
            Test.stopTest();
            System.assertEquals('OK#100', respuesta);
        }
        
    }

    @isTest
    public static void consultaTelefonoDesconocido(){
        User usuarioResponsable = [SELECT Id FROM User WHERE FirstName = 'ResponsableOS' LIMIT 1];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        // Set request properties
        request.requestUri = '/services/apexrest/consultaTelefonoEmpleadoCentro/obtenerContactoTelefono';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{"ani": "112233445"}');
        RestContext.request = request;
        RestContext.response = response;

        System.runAs (usuarioResponsable){
            Test.startTest();
            OS_WS_ConsultaTelefono.Output output = OS_WS_ConsultaTelefono.obtenerContactoTelefono();
            String respuesta = output.contacto;    
            Test.stopTest();
            System.assertEquals('OK#200', respuesta);
        }
    }
}