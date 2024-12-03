@isTest
public class TMS_WS_Validation_Test {
    
    @TestSetup
    public static void crearDatosPrueba() {
        
        //09/10/2023 aún no se han asignado los permisos de los RT a los PS/Profile de TSM, se utiliza el SysAdmin hasta que se modifiquen
        
        
        User api = TMS_Usuarios.usuarioAPI();
        

        
        System.runAs(api) {
            // The following code runs as user 'uOs'
            // 

          
            
            Account acc = new Account();
            acc.CC_Tipo_Centro__c = 'DT';
            acc.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            acc.CC_Numero_Empresa__c = '001';
            acc.CC_Numero_Oficina__c = '22222';
            acc.Name = 'DT Test';
            acc.CC_Numperso__c = '10000';
            insert acc;
            
            Contact contacto = new Contact();
            contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
            contacto.AccountId = acc.Id;
            contacto.FirstName = 'Contacto Prueba Empleado';
            contacto.LastName = 'Contacto Prueba Empleado';
            contacto.CC_NumPerso__c = '25345550';
            contacto.CC_Idioma__c = 'ca';
            contacto.Email = 'correo@gmail.com';
            contacto.Phone = '973242323';
            contacto.AV_Numperso__c = '65536';
            insert contacto;

            Case caso = new Case();
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'TMS_Expediente');
            caso.Subject = 'Caso TMS ' + System.Today();
            caso.Origin = 'Backend';
            caso.CC_Canal_Procedencia__c = 'Testamentarias';
            caso.ContactId = contacto.Id;
            caso.TMS_Numexp__c = '11111111';
            caso.CC_Tipo_Contacto__c='Gestión expediente';
            caso.AccountId = acc.Id;
            
            insert caso;
        }
    }
    
    @isTest
    static void test01_searchCaseOK() {
        // Testar control numperso.
        TMS_WS_Validation_DTO.RequestDTO requestTms = new TMS_WS_Validation_DTO.RequestDTO();
        TMS_WS_Validation_DTO.ResponseDTO responseTms;
        
        Integer hora = System.Now().hour();
        
        Case caso = [SELECT Id, TMS_Numexp__c, Account.CC_NumPerso__c  FROM Case WHERE TMS_Numexp__c = '11111111'];
        requestTms.numExp = caso.TMS_Numexp__c;
        requestTms.numperSolicitanteCita =caso.Account.CC_NumPerso__c;
        String jsonMsg=JSON.serialize(requestTms);
        
        User us = [SELECT Id FROM User WHERE Alias = 'API_tms'];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/tms/case/validation';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        System.runAs (us){
        
            Test.startTest();
            TMS_WS_Validation_DTO.ResponseDTO respuesta = TMS_WS_Validation.validationCallme();
            
            System.AssertEquals(null, respuesta.mensajeError);
            System.AssertEquals('OK', respuesta.estado);
            Test.stopTest();
        }
    }

  @isTest
    static void test02_searchCaseNumKo() {
        // Testar control numperso.
        TMS_WS_Validation_DTO.RequestDTO requestTms = new TMS_WS_Validation_DTO.RequestDTO();
        TMS_WS_Validation_DTO.ResponseDTO responseTms;
        
        Integer hora = System.Now().hour();
        
        requestTms.numExp = '00000000';
        requestTms.numperSolicitanteCita ='111111111';
        
        String jsonMsg=JSON.serialize(requestTms);
        
        User us = [SELECT Id FROM User WHERE Alias = 'API_tms'];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/tms/case/validation';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        System.runAs (us){
        
            Test.startTest();
            TMS_WS_Validation_DTO.ResponseDTO respuesta = TMS_WS_Validation.validationCallme();
            
            System.AssertEquals('KO', respuesta.estado);
            System.AssertEquals('No existe un caso con el número introducido', respuesta.mensajeError);
            Test.stopTest();
        }
    }  
    
    @isTest
    static void test03_searchCaseKO() {
        // Testar control numperso.
        TMS_WS_Validation_DTO.RequestDTO requestTms = new TMS_WS_Validation_DTO.RequestDTO();
        TMS_WS_Validation_DTO.ResponseDTO responseTms;
        
        Integer hora = System.Now().hour();
        
        
        User us = [SELECT Id FROM User WHERE Alias = 'API_tms'];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/tms/case/event/alta';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(String.valueOf(hora));
        RestContext.request = req;
        RestContext.response= res;
        System.runAs (us){
        
            Test.startTest();
            TMS_WS_Validation_DTO.ResponseDTO respuesta = TMS_WS_Validation.validationCallme();
            
            System.AssertEquals('KO', respuesta.estado);
            Test.stopTest();
        }
    }
    
   
}