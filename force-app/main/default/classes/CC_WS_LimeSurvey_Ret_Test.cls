@isTest
public with sharing class CC_WS_LimeSurvey_Ret_Test {
       
    @TestSetup
    static void crearDatosPrueba() {

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
    
        User usuario1 = new User();
        usuario1.ProfileId = profileId;
        usuario1.FirstName = 'Usuario Admin Prueba';
        usuario1.LastName = 'last211';
        usuario1.Email = 'aalsdna@kfsb.com';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';

        insert usuario1;

        System.runAs(usuario1){
            Contact contacto = new Contact();
            contacto.LastName = 'Test contacto';
            contacto.Email = 'test@test.es';
            insert contacto;
            
            Case caso = new Case();
            caso.Subject = 'Test Incidencia LimeSurvey';
            caso.Origin = 'Email';
            caso.ContactId = contacto.Id;
            caso.CC_NotIncidencia__c = '1';
            caso.CC_MailTelfNotif__c = 'test@test.es';
            caso.CC_CanalNotifCli__c = 'Email';
            caso.CC_Idioma__c = 'es';
            insert caso; 
            
            CC_Envio_Encuesta__c tipoEncuesta = new CC_Envio_Encuesta__c();
            tipoEncuesta.Name= 'TipoCase';
            tipoEncuesta.CC_Tipo_Encuesta__c= 'Caso';
            tipoEncuesta.CC_Id_Encuesta__c = '687532';
    
            CC_Envio_Encuesta__c tipoEncuestaChat = new CC_Envio_Encuesta__c();
            tipoEncuestaChat.Name= 'TipoChat';
            tipoEncuestaChat.CC_Tipo_Encuesta__c= 'Chat';
            tipoEncuestaChat.CC_Id_Encuesta__c = '6875321';
    
            List<CC_Envio_Encuesta__c> encuestas = new List<CC_Envio_Encuesta__c>();
            encuestas.add(tipoEncuesta);
            encuestas.add(tipoEncuestaChat);
    
            insert encuestas;
            
            CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
                wsc.Name = 'CC_WS_LimeSurvey';
                wsc.RegistroTrazaIntegracion__c = true;
                insert wsc;
        }
        
    }

    @IsTest
    public static void datosObligatoriosNoInformadosEnBlancoTest(){

        List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input> oData = new List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input>();
        CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input datos = new CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input();
        CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_QA qAndA = new CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_QA();
        qAndA.codPregunta='pregunta1';
        qAndA.respuesta = 'Respuesta1';
       

        User usuario = [SELECT Id FROM User WHERE Email = 'aalsdna@kfsb.com' LIMIT 1];
        
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Incidencia LimeSurvey' LIMIT 1];
        
        datos.ticketId = '       ';
        datos.fecha = Datetime.ValueOf('2019-06-03T10:01:42+02:00'.replace('T', ' '));
        oData.add(datos);
        
        String jsonMsg=JSON.serialize(oData);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/CC_Encuestas/*';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;


        Test.startTest();
        System.runAs(usuario){
            List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Output> resultado= CC_WS_LimeSurvey_Ret.putRtaLimeServey(oData);
       	    System.assertEquals('Datos obligatorios no informados.', resultado[0].sDetalleError, 'La ejecución ha fallado.');
        }
        Test.stopTest();

    }
        @IsTest
    	public static void registroInsertadoCaseTest(){

        List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input> oData = new List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input>();
        CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input datos = new CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input();
        CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_QA qAndA = new CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_QA();
        qAndA.codPregunta='Xs00';
        qAndA.respuesta = 'Respuesta1';

        User usuario = [SELECT Id FROM User WHERE Email = 'aalsdna@kfsb.com' LIMIT 1];
        
		Case caso = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'Test Incidencia LimeSurvey' LIMIT 1];
            
        datos.id = '687532';
        datos.ticketId = caso.CaseNumber;
        datos.fecha = Datetime.ValueOf('2019-06-03T10:01:42+02:00'.replace('T', ' '));
        datos.resultadoEncuesta = new List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_QA>();
        datos.resultadoEncuesta.add(qAndA);
        oData.add(datos);
            
         oData.add(datos);
        
        String jsonMsg=JSON.serialize(oData);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/CC_Encuestas/*';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        System.runAs(usuario){
            List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Output> resultado= CC_WS_LimeSurvey_Ret.putRtaLimeServey(oData);
            System.assertEquals('Registro Insertado.', resultado[0].sDetalleError, 'La ejecución ha fallado.');
        }      	
        Test.stopTest();

    }
            @IsTest
    	public static void registroInsertadoChatTest(){

        List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input> oData = new List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input>();
        CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input datos = new CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input();
        CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_QA qAndA = new CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_QA();
        qAndA.codPregunta='Xs00';
        qAndA.respuesta = 'Respuesta1';

        User usuario = [SELECT Id FROM User WHERE Email = 'aalsdna@kfsb.com' LIMIT 1];

		Case caso = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'Test Incidencia LimeSurvey' LIMIT 1];
        caso.CC_Id_Cognitivo__c = 'PRE-20210714214168';
        update caso;
        CC_Envio_Encuesta__c tipoEncuesta = [SELECT CC_Tipo_Encuesta__c FROM CC_Envio_Encuesta__c WHERE Name = 'TipoCase' ];
        tipoEncuesta.Name= 'TipoChat2';
        tipoEncuesta.CC_Tipo_Encuesta__c= 'Chat';
        tipoEncuesta.CC_Id_Encuesta__c = '372471';
        update tipoEncuesta;
            
        datos.id = '372471';
        datos.ticketId = caso.CaseNumber;
        datos.fecha = Datetime.ValueOf('2019-06-03T10:01:42+02:00'.replace('T', ' '));
        datos.resultadoEncuesta = new List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_QA>();
        datos.resultadoEncuesta.add(qAndA);
        oData.add(datos);
        
         oData.add(datos);
        
        String jsonMsg=JSON.serialize(oData);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/CC_Encuestas/*';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
            
        Test.startTest();
        System.runAs(usuario){
            List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Output> resultado= CC_WS_LimeSurvey_Ret.putRtaLimeServey(oData);
            System.assertEquals('Registro Insertado.', resultado[0].sDetalleError, 'La ejecución ha fallado.');
        }
        Test.stopTest();

    }
    @IsTest
    	public static void listaDePreguntasYRespuestasVaciaTest(){

        List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input> oData = new List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input>();
        CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input datos = new CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input();
        CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_QA qAndA = new CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_QA();
        
		Case caso = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'Test Incidencia LimeSurvey' LIMIT 1];
            
        User usuario = [SELECT Id FROM User WHERE Email = 'aalsdna@kfsb.com' LIMIT 1];

        datos.id = '687532';
        datos.ticketId = caso.CaseNumber;
        datos.fecha = Datetime.ValueOf('2019-06-03T10:01:42+02:00'.replace('T', ' '));
        datos.resultadoEncuesta = new List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_QA>();
        oData.add(datos);
            
         oData.add(datos);
        
        String jsonMsg=JSON.serialize(oData);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/CC_Encuestas/*';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        System.runAs(usuario){
            List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Output> resultado= CC_WS_LimeSurvey_Ret.putRtaLimeServey(oData);
            System.assertEquals('No se recibieron preguntas y respuestas.', resultado[0].sDetalleError, 'La ejecución ha fallado.');
        }
        Test.stopTest();

    }
        @IsTest
    	public static void ErrorAlRecuperarRegistrosTest(){

        List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input> oData = new List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input>();
        CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input datos = new CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Input();
        CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_QA qAndA = new CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_QA();
        
		Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Incidencia LimeSurvey' LIMIT 1];
        List<CC_Envio_Encuesta__c> tipoEncuesta = [SELECT CC_Tipo_Encuesta__c FROM CC_Envio_Encuesta__c WHERE Name = 'TipoCase' OR Name = 'TipoChat' ];
        delete tipoEncuesta;

        User usuario = [SELECT Id FROM User WHERE Email = 'aalsdna@kfsb.com' LIMIT 1];
            
        datos.id = '687532';
        datos.ticketId = caso.id;
        datos.fecha = Datetime.ValueOf('2019-06-03T10:01:42+02:00'.replace('T', ' '));
        datos.resultadoEncuesta = new List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_QA>();
        oData.add(datos);

         oData.add(datos);
        
        String jsonMsg=JSON.serialize(oData);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/CC_Encuestas/*';  //Request URL
        req.httpMethod = 'PUT';//HTTP Request Type
        req.requestBody = Blob.valueof(jsonMsg);
        RestContext.request = req;
        RestContext.response= res;
            
        Test.startTest();
        System.runAs(usuario){
            List<CC_WS_LimeSurvey_Ret.CC_WS_LimeSurvey_Output> resultado= CC_WS_LimeSurvey_Ret.putRtaLimeServey(oData);
            System.assertEquals('No se recibieron preguntas y respuestas.', resultado[0].sDetalleError, 'La ejecución ha fallado.');
        }
        Test.stopTest();

    }


}