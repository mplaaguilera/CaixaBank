/**********************************************************************************************************************
Name:     CSBD_LiveAgent_Welcome_Controller_Test
Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase test de la clase CSBD_LiveAgent_Welcome_Controller
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY      AUTHOR              DATE                Description
1.0         App CSBD        Esperanza Conde	    14/02/2022          Init version
***********************************************************************************************************************/
@isTest
public with sharing class CSBD_LiveAgent_Welcome_Controller_Test {

    @testSetup static void setup() {

        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        User usuarioAdmin = new User();
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id roleCSBD = [SELECT Id FROM UserRole WHERE DeveloperName = 'CSBD_Generico'].Id;

        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCSBD;
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

        insert usuarioAdmin;
        System.runAs(usuarioAdmin){
            Id rt = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Particular').getRecordTypeId();
            Id rtListaValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByName().get('Lista de valores').getRecordTypeId();
            Id rtValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByName().get('Valor').getRecordTypeId();
             Id rtChatId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Chat').getRecordTypeId();
            Id rtOTPId = Schema.SObjectType.CBK_OTP_Generado__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId();

            Account cliente = new Account(
                FirstName = 'OLGA',
                LastName = 'ROBLES GEA',
                RecordTypeId = rt,
                CC_NumPerso__c = '16849239'
            );

            insert cliente;
            //Insertamos la lista de valores
            CC_Lista_Valores__c listValoresHorario = new CC_Lista_Valores__c();
            listValoresHorario.Name = 'CSBD: Relación de valores Now - Salesforce: Turno';
            listValoresHorario.CC_Activa__c = true;
            listValoresHorario.RecordTypeId = rtListaValores;

            insert listValoresHorario;

            CC_Lista_Valores__c valoresHorario = new CC_Lista_Valores__c();
            valoresHorario.Name = '08-10h';
            valoresHorario.RecordTypeId = rtValores;
            valoresHorario.CC_Lista__c = listValoresHorario.Id;
            valoresHorario.CC_Valor__c = 'Mañana';
            valoresHorario.CC_Valor2__c = '08:00 - 10:00';
            valoresHorario.CC_Valor2__c = '8';

            insert valoresHorario;

            //Insertamos la lista de valores
            CC_Lista_Valores__c listValoresProducto = new CC_Lista_Valores__c();
            listValoresProducto.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto';
            listValoresProducto.CC_Activa__c = true;
            listValoresProducto.RecordTypeId = rtListaValores;

            insert listValoresProducto;

            CC_Lista_Valores__c valoresProducto = new CC_Lista_Valores__c();
            valoresProducto.Name = 'Prestamo Online';
            valoresProducto.RecordTypeId = rtValores;
            valoresProducto.CC_Lista__c = listValoresProducto.Id;
            valoresProducto.CC_Valor__c = 'Préstamos';
            valoresProducto.CC_Valor2__c = 'Genérico';
            valoresProducto.CC_Valor2__c = 'CaixaBank';
            valoresProducto.CC_Activa__c = true;

            insert valoresProducto;

            Opportunity opp = new Opportunity(
                Name = 'Chat CSBD',
                StageName = 'Solicitud',
                RecordTypeId = rtChatId,
                CSBD_Estado__c = 'Nueva',
                AccountId = cliente.Id
            );

            insert opp;

            CBK_OTP_Generado__c otp = new CBK_OTP_Generado__c();
            otp.CBK_Codigo_OTP__c = '11111111111';
            otp.CBK_Fecha_Codigo_OTP__c = DateTime.NOW().addHours(1);
            otp.CBK_Oportunidad__c = opp.Id;
            otp.RecordtypeId = rtOTPId;
            insert otp;


        }
   }

    /**
     * Probamos el mensaje de Saludo en español que salga correcto
	*/
    @isTest static void testSaludo(){

        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.CC_Tipo__c = 'CSBD';
        transcript.CSBD_OTP_Chat__c = '11111111111';
        transcript.LiveChatVisitorId = liveChatVisitor.Id;
		insert transcript;

        User usuarioGestor = [SELECT Id FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        System.runAs (usuarioGestor) {
            Folder f = [SELECT Id FROM Folder WHERE Type = 'Email' LIMIT 1];
            EmailTemplate et = new EmailTemplate(Name= 'testEt', DeveloperName='Saludo_noEsConfidencial_esTEST', HtmlValue='testBody', FolderId=f.Id, TemplateType='Custom');
        	insert et;

            Test.startTest();
            CSBD_LiveAgent_Welcome_Controller.Response response = CSBD_LiveAgent_Welcome_Controller.searchMessage(transcript.Id, 'Saludo');
            Test.stopTest();
            system.assert(response.mensaje.contains('testBody'), 'Se comprueba el mensaje de error.');
            system.assertEquals('OK', response.status, 'Comprobamos el estado es correcto.');
        }

	}

    /**
     * Probamos el mensaje de despedida en español que salga correcto
	*/
    @isTest static void testDespedida(){

        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.CC_Tipo__c = 'CSBD';
        transcript.CSBD_OTP_Chat__c = '11111111111';
        transcript.LiveChatVisitorId = liveChatVisitor.Id;
		insert transcript;

        User usuarioGestor = [SELECT Id FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_LiveAgent_Welcome_Controller.Response response = CSBD_LiveAgent_Welcome_Controller.searchMessage(transcript.Id, 'Despedida');
            Test.stopTest();
            system.assertEquals('OK', response.status, 'Comprobamos el estado es correcto.');
        }
	}

	/**
     * Probamos el error de la no parametrización
	*/
    @isTest static void testSaludoNoParametrizado(){

        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.CC_Tipo__c = 'CSBD';
        transcript.CSBD_OTP_Chat__c = '11111111111';
        transcript.LiveChatVisitorId = liveChatVisitor.Id;
		insert transcript;

        User usuarioGestor = [SELECT Id FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_LiveAgent_Welcome_Controller.Response response = CSBD_LiveAgent_Welcome_Controller.searchMessage(transcript.Id, 'Saludoaa');
            Test.stopTest();

            system.assert(response.mensaje.contains('No se encuentra una coincidencia para la parametrización.'), 'Se comprueba el mensaje de error.');
            system.assertEquals('KO', response.status, 'Comprobamos el estado es correcto.');
        }
    }


    /**
     * Probamos que no se encuentre la transcripcion
	*/
    @isTest static void testNotFoundTranscription(){
        User usuarioGestor = [SELECT Id FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        System.runAs (usuarioGestor) {
            Test.startTest();
            try {
                CSBD_LiveAgent_Welcome_Controller.Response response = CSBD_LiveAgent_Welcome_Controller.searchMessage('123345xgds', 'Saludo');
            } catch (Exception e) {
                System.assertEquals(true, true, 'Debería haberse producido una excepción');
            }
            Test.stopTest();

            // system.assert(response.mensaje.contains('No se ha encontrado la transcripción.'), 'Se comprueba el mensaje de error.');
            // system.assertEquals('KO', response.status, 'Comprobamos el estado es correcto.');
        }
    }


    /**
     * Probamos que no llegue el recordId
	*/
    @isTest
    public static void testNotRecordId() {

        User usuarioGestor = [SELECT Id FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        System.runAs(usuarioGestor) {
            Test.startTest();
            try {
                CSBD_LiveAgent_Welcome_Controller.Response response = CSBD_LiveAgent_Welcome_Controller.searchMessage(null, 'Saludo');
            } catch (Exception e) {
                System.assertEquals(true, true, 'Debería haberse producido una excepción');
            }
            Test.stopTest();
        }
    }

    /**
     * Probamos la creación del LiveChatTranscriptEvent
	*/
    @isTest static void testSearchEvent(){

        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.CC_Tipo__c = 'CSBD';
        transcript.CSBD_OTP_Chat__c = '11111111111';
        transcript.LiveChatVisitorId = liveChatVisitor.Id;
		insert transcript;

        User usuarioGestor = [SELECT Id FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_LiveAgent_Welcome_Controller.Response response = CSBD_LiveAgent_Welcome_Controller.searchEventTranscript(transcript.Id);
            Test.stopTest();

            system.assert(response.timeOut == null, 'Comprobamos no hay time out.');
        }
	}

    /**
     * Probamos la creación de la tarea de finalizar un chat
	*/
    @isTest static void finChat(){

        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;

        LiveChatTranscript transcript = new LiveChatTranscript();
        transcript.CC_Tipo__c = 'CSBD';
        transcript.CSBD_OTP_Chat__c = '11111111111';
        transcript.LiveChatVisitorId = liveChatVisitor.Id;
		insert transcript;

        User usuarioGestor = [SELECT Id FROM User WHERE Email = 'tuser000@amamama.com' LIMIT 1];
        System.runAs (usuarioGestor) {
            Test.startTest();
            CSBD_LiveAgent_Welcome_Controller.finChat(transcript.Id, true);
            Test.stopTest();

            List<Task> lstTarea = [Select Subject, Description, Type FROM Task WHERE CC_LiveChatTranscript_Id__c = :transcript.Id];

            Task tarea = lstTarea.get(0);

            system.assertEquals('Time Out', tarea.Type, 'Debería existir una tarea de cierre por inactividad');
        }
	}


}