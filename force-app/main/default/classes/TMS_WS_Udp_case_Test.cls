@isTest
public class TMS_WS_Udp_case_Test {
    
    @TestSetup
    public static void crearDatosPrueba() {
        
        //09/10/2023 aún no se han asignado los permisos de los RT a los PS/Profile de TSM, se utiliza el SysAdmin hasta que se modifiquen
        
        
        User api = TMS_Usuarios.usuarioAPI();

        
        System.runAs(api) {
            // The following code runs as user 'u'
//Añadir cuenta
            
            Account oficinaGestora = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId(), 
                LastName = 'Cuenta oficina gestora', 
                CC_Email__c = 'test@test.com', 
                CC_Numero_Oficina__c = '00001');

            insert oficinaGestora;

            Contact contacto = new Contact();
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            contacto.LastName = 'Contacto test';
            contacto.Email='test@test.com';
            contacto.AV_NumPerso__c = '2147483647';
            contacto.Account = oficinaGestora;
            insert contacto;

            Case caso = new Case();
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TMS_Expediente').getRecordTypeId();
            caso.Subject = 'Caso TMS ' + System.Today();
			caso.Origin = 'Backend';
            caso.CC_Canal_Procedencia__c = 'Testamentarias';
            caso.TMS_Numexp__c = '11111111';
            caso.CC_Tipo_Contacto__c='Gestión expediente';
            caso.ContactId = contacto.Id;
            
            insert caso;
            
            CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
            lista.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c','CC_Lista_Valores');
            lista.Name  = 'TMS - Creación de tareas automáticas';
            
            insert lista;

            CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
            valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            valor.CC_Lista__c = lista.Id;
            valor.Name  = 'Acreditación Heredero';
            valor.CC_Valor__c  = 'Primer intento de llamada';
            insert valor;
        }
    }
    
    @isTest
    static void test01_searchCaseOK() {
        // Testar control numperso.
        
        User us = [SELECT Id FROM User WHERE Alias = 'API_tms'];
        System.runAs (us){
            TMS_WS_Udp_Case_DTO.RequestDTO requestTms = new TMS_WS_Udp_Case_DTO.RequestDTO();
            TMS_WS_Udp_Case_DTO.ResponseDTO responseTms;
            
            
            requestTms.numExp = '111111111';
            requestTms.estado = 'TMS_002';
            requestTms.gestoria = '5';
            requestTms.letrado = 'U01X9999';
            requestTms.numperHeredero = '2147483647';
            
            String jsonMsg=JSON.serialize(requestTms);
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/tms/case/upd';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof(jsonMsg);
            RestContext.request = req;
            RestContext.response= res;
        
            Test.startTest();
            TMS_WS_Udp_Case_DTO.ResponseDTO respuesta = TMS_WS_Udp_Case.updateCase();
            Case caso =[SELECT Id, TMS_Numexp__c FROM Case WHERE TMS_Numexp__c = '111111111' LIMIT 1];
            List<Task> tareas = [SELECT Id FROM TASK WHERE WhatId = :caso.Id];
            
            System.AssertEquals('OK', respuesta.estado);
            System.assertNotEquals(0, tareas.size());
            Test.stopTest();
        }
    }

    @isTest
    static void test02_searchCaseOK() {
        // Testar control numperso.
        User us = [SELECT Id FROM User WHERE Alias = 'API_tms'];
        System.runAs (us){
            TMS_WS_Udp_Case_DTO.RequestDTO requestTms = new TMS_WS_Udp_Case_DTO.RequestDTO();
            TMS_WS_Udp_Case_DTO.ResponseDTO responseTms;
            
            Case caso =[SELECT Id, TMS_Numexp__c FROM Case WHERE TMS_Numexp__c = '11111111' LIMIT 1];

            requestTms.numExp = caso.TMS_Numexp__c;
            requestTms.estado = 'TMS_002';
            requestTms.gestoria = '5';
            requestTms.letrado = 'U01X9999';
            requestTms.numperHeredero = '2147483647';

            
            String jsonMsg=JSON.serialize(requestTms);
            
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            req.requestURI = '/tms/case/upd';  //Request URL
            req.httpMethod = 'POST';//HTTP Request Type
            req.requestBody = Blob.valueof(jsonMsg);
            RestContext.request = req;
            RestContext.response= res;
        
            Test.startTest();
            TMS_WS_Udp_Case_DTO.ResponseDTO respuesta = TMS_WS_Udp_Case.updateCase();
            List<Task> tareas = [SELECT Id FROM TASK WHERE WhatId = :caso.Id];
            
            System.AssertEquals('OK', respuesta.estado);
            System.assertNotEquals(0, tareas.size());
            Test.stopTest();
        }
    }

    

	
    
    @isTest
    static void test03_searchCaseKO() {
        // Testar control numperso.
        TMS_WS_Udp_Case_DTO.RequestDTO requestTms = new TMS_WS_Udp_Case_DTO.RequestDTO();
        TMS_WS_Udp_Case_DTO.ResponseDTO responseTms;
        
        Integer hora = System.Now().hour();
        
        
        User us = [SELECT Id FROM User WHERE Alias = 'API_tms'];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/tms/case/upd';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(String.valueOf(hora));
        RestContext.request = req;
        RestContext.response= res;
        System.runAs (us){
        
            Test.startTest();
            TMS_WS_Udp_Case_DTO.ResponseDTO respuesta = TMS_WS_Udp_Case.updateCase();
            
            System.AssertEquals('KO', respuesta.estado);
            Test.stopTest();
        }
    }
    
}