@isTest
public with sharing class TMS_WS_Alta_CallMe_Test {
    
    @TestSetup
    public static void crearDatosPrueba() {
        
        //09/10/2023 aún no se han asignado los permisos de los RT a los PS/Profile de TSM, se utiliza el SysAdmin hasta que se modifiquen
        
        CBK_UtilsDate.nowDatetime = Datetime.newInstance(2024,2,22,12,0,0);

        User api = TMS_Usuarios.usuarioAPI();
        System.runAs(api) {
            // The following code runs as user 'u'
            Contact contacto = new Contact();
            contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            contacto.LastName = 'Contacto test';
            contacto.Email='test@test.com';
            contacto.AV_NumPerso__c = '2147483647';
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
        }
    }
    
    @isTest
    static void test01_insertEventOK() {
        // Testar control numperso.
        TMS_WS_Alta_CallMe_DTO.RequestDTO requestTms = new TMS_WS_Alta_CallMe_DTO.RequestDTO();
        TMS_WS_Alta_CallMe_DTO.ResponseDTO responseTms;
        
        Datetime hora = CBK_UtilsDate.nowDT();
        
        Case caso = [SELECT Id, TMS_Numexp__c, OwnerId FROM Case WHERE TMS_Numexp__c = '11111111'];
        requestTms.numExp = caso.TMS_Numexp__c;
        requestTms.horaInicio = String.valueOf(hora.hour());
        requestTms.horaFin = String.valueOf(hora.addHours(1).hour());
        requestTms.comentario = 'test';
        requestTms.tipologia = 'test tipo';
        requestTms.telefonoContacto = '666666666';
        requestTms.numperSolicitanteCita ='7FFFFFFF';
        
        String jsonMsg=JSON.serialize(requestTms);
        
        User us = [SELECT Id FROM User WHERE Alias = 'API_tms'];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/tms/case/event/alta';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        System.runAs (us){
        
            Test.startTest();
            TMS_WS_Alta_CallMe_DTO.ResponseDTO respuesta = TMS_WS_Alta_CallMe.altaCallme();
            
            System.AssertEquals('OK', respuesta.estado);
            System.AssertEquals(null, respuesta.mensajeError);
            Test.stopTest();
        }
    }

	@isTest
    static void test02_insertEventCaseKo() {
        // Testar control numperso.
        TMS_WS_Alta_CallMe_DTO.RequestDTO requestTms = new TMS_WS_Alta_CallMe_DTO.RequestDTO();
        TMS_WS_Alta_CallMe_DTO.ResponseDTO responseTms;
        
        Datetime hora = CBK_UtilsDate.nowDT();
        
        Case caso = [SELECT Id, TMS_Numexp__c, OwnerId FROM Case WHERE TMS_Numexp__c = '11111111'];
        requestTms.numExp = '000000000';
        requestTms.horaInicio = String.valueOf(hora.hour());
        requestTms.horaFin = String.valueOf(hora.addHours(1).hour());
        requestTms.comentario = 'test';
        requestTms.tipologia = 'test tipo';
        requestTms.telefonoContacto = '666666666';
        requestTms.numperSolicitanteCita ='111111111';
        
        String jsonMsg=JSON.serialize(requestTms);
        
        User us = [SELECT Id FROM User WHERE Alias = 'API_tms'];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/tms/case/event/alta';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        System.runAs (us){
        
            Test.startTest();
            TMS_WS_Alta_CallMe_DTO.ResponseDTO respuesta = TMS_WS_Alta_CallMe.altaCallme();
            
            System.AssertEquals('KO', respuesta.estado);
            System.AssertEquals('El solicitante no está asociado al expediente proporcionado.', respuesta.mensajeError);
            Test.stopTest();
        }
    }  
    
    @isTest
    static void test03_insertEventKO() {
        // Testar control numperso.
        TMS_WS_Alta_CallMe_DTO.RequestDTO requestTms = new TMS_WS_Alta_CallMe_DTO.RequestDTO();
        TMS_WS_Alta_CallMe_DTO.ResponseDTO responseTms;
        
        Datetime hora = CBK_UtilsDate.nowDT();
        
        Case caso = [SELECT Id, TMS_Numexp__c, OwnerId FROM Case WHERE TMS_Numexp__c = '11111111'];
        requestTms.numExp = caso.TMS_Numexp__c;
        requestTms.horaFin = String.valueOf(hora.addHours(1).hour());
        requestTms.comentario = 'test';
        requestTms.tipologia = 'test tipo';
        requestTms.telefonoContacto = '666666666';
        requestTms.numperSolicitanteCita ='111111111';
        
        String jsonMsg=JSON.serialize(requestTms);
        
        User us = [SELECT Id FROM User WHERE Alias = 'API_tms'];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/tms/case/event/alta';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        System.runAs (us){
        
            Test.startTest();
            TMS_WS_Alta_CallMe_DTO.ResponseDTO respuesta = TMS_WS_Alta_CallMe.altaCallme();
            
            System.AssertEquals('KO', respuesta.estado);
            Test.stopTest();
        }
    }
    
    @isTest
    static void test04_insertEventNextDayOK() {
        // Testar control numperso.
        TMS_WS_Alta_CallMe_DTO.RequestDTO requestTms = new TMS_WS_Alta_CallMe_DTO.RequestDTO();
        TMS_WS_Alta_CallMe_DTO.ResponseDTO responseTms;
        
        Datetime hora = CBK_UtilsDate.nowDT();
        
        Case caso = [SELECT Id, TMS_Numexp__c, OwnerId FROM Case WHERE TMS_Numexp__c = '11111111'];
        requestTms.numExp = caso.TMS_Numexp__c;
        requestTms.horaInicio = String.valueOf(hora.addHours(-3).hour());
        requestTms.horaFin =String.valueOf( hora.hour());
        requestTms.comentario = 'test';
        requestTms.tipologia = 'test tipo';
        requestTms.telefonoContacto = '666666666';
        requestTms.numperSolicitanteCita ='7FFFFFFF';
        
        String jsonMsg=JSON.serialize(requestTms);
        
        User us = [SELECT Id FROM User WHERE Alias = 'API_tms'];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/tms/case/event/alta';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        System.runAs (us){
        
            Test.startTest();
            TMS_WS_Alta_CallMe_DTO.ResponseDTO respuesta = TMS_WS_Alta_CallMe.altaCallme();
            
            System.AssertEquals('OK', respuesta.estado);
            System.AssertEquals(null, respuesta.mensajeError);
            Test.stopTest();
        }
    }
}