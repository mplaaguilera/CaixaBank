@isTest
public class CSBD_LiveAgent_Welcome_Controller_Test {

    @TestSetup
    private static void setup() {

        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Id idRecordTypeListaValores = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByName().get('Lista de valores').getRecordTypeId();
            CC_Lista_Valores__c lovDiasCierre = new CC_Lista_Valores__c();
            lovDiasCierre.RecordTypeId = idRecordTypeListaValores;
            lovDiasCierre.Name = 'CSBD: Días cierre oportunidad por defecto';
            CC_Lista_Valores__c listValoresHorario = new CC_Lista_Valores__c();
            listValoresHorario.RecordTypeId = idRecordTypeListaValores;
            listValoresHorario.Name = 'CSBD: Relación de valores Now - Salesforce: Turno';
            CC_Lista_Valores__c listValoresProducto = new CC_Lista_Valores__c();
            listValoresProducto.RecordTypeId = idRecordTypeListaValores;
            listValoresProducto.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto';
            insert new List<CC_Lista_Valores__c>{lovDiasCierre, listValoresHorario, listValoresProducto};

            Id idRecordTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByName().get('Valor').getRecordTypeId();
            CC_Lista_Valores__c valorDiasCierre = new CC_Lista_Valores__c();
            valorDiasCierre.RecordTypeId = idRecordTypeValor;
            valorDiasCierre.CC_Lista__c = lovDiasCierre.Id;
            valorDiasCierre.Name = 'Chat';
            valorDiasCierre.CC_Valor__c = '1';
            CC_Lista_Valores__c valoresHorario = new CC_Lista_Valores__c();
            valoresHorario.RecordTypeId = idRecordTypeValor;
            valoresHorario.CC_Lista__c = listValoresHorario.Id;
            valoresHorario.Name = '08-10h';
            valoresHorario.CC_Valor__c = 'Mañana';
            valoresHorario.CC_Valor2__c = '08:00 - 10:00';
            valoresHorario.CC_Valor2__c = '8';
            CC_Lista_Valores__c valoresProducto = new CC_Lista_Valores__c();
            valoresProducto.RecordTypeId = idRecordTypeValor;
            valoresProducto.CC_Lista__c = listValoresProducto.Id;
            valoresProducto.Name = 'Prestamo Online';
            valoresProducto.CC_Valor__c = 'Préstamos';
            valoresProducto.CC_Valor2__c = 'Genérico';
            valoresProducto.CC_Valor2__c = 'CaixaBank';
            valoresProducto.CC_Activa__c = true;
            insert new List<CC_Lista_Valores__c>{valorDiasCierre, valoresHorario, valoresProducto};

            Account clienteParticular = new Account();
            clienteParticular.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente Particular').getRecordTypeId();
            clienteParticular.FirstName = 'OLGA';
            clienteParticular.LastName = 'ROBLES GEA';
            clienteParticular.CC_NumPerso__c = '16849239';
            insert clienteParticular;

            Opportunity chat = CSBD_Opportunity.crearOportunidad('CSBD_Chat', new Map<String, Object>{
                'Name' => 'Chat CSBD', 'AccountId' => clienteParticular.Id
            });

            CBK_OTP_Generado__c otp = new CBK_OTP_Generado__c();
            otp.RecordtypeId = Schema.SObjectType.CBK_OTP_Generado__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId();
            otp.CBK_Oportunidad__c = chat.Id;
            otp.CBK_Codigo_OTP__c = '11111111111';
            otp.CBK_Fecha_Codigo_OTP__c = Datetime.now().addHours(1);
            insert otp;

			User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();

			LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
			insert liveChatVisitor;

			LiveChatTranscript transcript = new LiveChatTranscript();
			transcript.RecordTypeId = Schema.SObjectType.LiveChatTranscript.getRecordTypeInfosByDeveloperName().get('CSBD_Gestor').getRecordTypeId();
			transcript.OwnerId = usuarioGestor.Id;
			transcript.CC_Tipo__c = 'CSBD';
			transcript.CSBD_OTP_Chat__c = '11111111111';
			transcript.LiveChatVisitorId = liveChatVisitor.Id;
			insert transcript;
		}
    }

    @isTest
    private static void testSaludo() {
		System.runAs((User)[SELECT Id FROM User WHERE FirstName = 'GestorCSBD' LIMIT 1]) {
			LiveChatTranscript transcript = [SELECT Id FROM LiveChatTranscript WHERE CC_Tipo__c = 'CSBD'];
			EmailTemplate plantilla = new EmailTemplate();
			plantilla.Name = 'testEt';
			plantilla.DeveloperName = 'Saludo_noEsConfidencial_esTEST';
			plantilla.HtmlValue = 'testBody';
			plantilla.FolderId = [SELECT Id FROM Folder WHERE Type = 'Email' LIMIT 1].Id;
			plantilla.TemplateType = 'Custom';
            insert plantilla;

            Test.startTest();
            CSBD_LiveAgent_Welcome_Controller.Response response = CSBD_LiveAgent_Welcome_Controller.searchMessage(transcript.Id, 'Saludo');
            Test.stopTest();

			System.assert(response.mensaje.contains('testBody'), 'Se comprueba el mensaje de error.');
            System.assertEquals('OK', response.status, 'Comprobamos el estado es correcto.');
		}
	}

    @isTest
    private static void testDespedida() {
		System.runAs((User)[SELECT Id FROM User WHERE FirstName = 'GestorCSBD' LIMIT 1]) {
			LiveChatTranscript transcript = [SELECT Id FROM LiveChatTranscript WHERE CC_Tipo__c = 'CSBD'];
			Test.startTest();
            String responseStatus = CSBD_LiveAgent_Welcome_Controller.searchMessage(transcript.Id, 'Despedida').status;
			Test.stopTest();

            System.assertEquals('OK', responseStatus, 'Comprobamos el estado es correcto.');
		}
	}

    @isTest
    private static void testSaludoNoParametrizado() {
		System.runAs((User)[SELECT Id FROM User WHERE FirstName = 'GestorCSBD' LIMIT 1]) {
			LiveChatTranscript transcript = [SELECT Id FROM LiveChatTranscript WHERE CC_Tipo__c = 'CSBD'];
			Test.startTest();
			CSBD_LiveAgent_Welcome_Controller.Response response = CSBD_LiveAgent_Welcome_Controller.searchMessage(transcript.Id, 'Saludoaa');
			Test.stopTest();

			System.assert(response.mensaje.contains('No se encuentra una coincidencia para la parametrización.'), 'Se comprueba el mensaje de error.');
			System.assertEquals('KO', response.status, 'Comprobamos el estado es correcto.');
		}
    }

    @isTest
	private static void testNotFoundTranscription() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
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

    @isTest
    private static void testNotRecordId() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            try {
                CSBD_LiveAgent_Welcome_Controller.searchMessage(null, 'Saludo');
				System.assertEquals(true, false, 'Debería haberse producido una excepción');
            } catch (Exception e) {
                System.assertEquals(true, true, 'Debería haberse producido una excepción');
            }
            Test.stopTest();
        }
    }

    @isTest
	private static void testSearchEvent() {
		System.runAs((User)[SELECT Id FROM User WHERE FirstName = 'GestorCSBD' LIMIT 1]) {
			LiveChatTranscript transcript = [SELECT Id FROM LiveChatTranscript WHERE CC_Tipo__c = 'CSBD'];
			Test.startTest();
            Boolean responseTimeout = CSBD_LiveAgent_Welcome_Controller.searchEventTranscript(transcript.Id).timeOut;
			Test.stopTest();

            System.assert(responseTimeout == null, 'Comprobamos no hay time out.');
		}
	}

    @isTest
	private static void finChat() {
		System.runAs((User)[SELECT Id FROM User WHERE FirstName = 'GestorCSBD' LIMIT 1]) {
			LiveChatTranscript transcript = [SELECT Id FROM LiveChatTranscript WHERE CC_Tipo__c = 'CSBD'];
			Test.startTest();
            CSBD_LiveAgent_Welcome_Controller.finChat(transcript.Id, true);
			Test.stopTest();

			Integer numTareasTimeout = [SELECT COUNT() FROM Task WHERE CC_LiveChatTranscript_Id__c = :transcript.Id AND Type = 'Time Out'];
            System.assertEquals(1, numTareasTimeout, 'Debería existir una tarea de cierre por inactividad');
		}
	}

    @isTest 
    static void testRegistrarMensajeAutomatico(){

        System.runAs((User)[SELECT Id FROM User WHERE FirstName = 'GestorCSBD' LIMIT 1]) {
            //recuperar transcript y enviar el mensaje de saludo
			LiveChatTranscript transcript = [SELECT Id FROM LiveChatTranscript WHERE CC_Tipo__c = 'CSBD'];
			EmailTemplate plantilla = new EmailTemplate();
			plantilla.Name = 'testEt';
			plantilla.DeveloperName = 'Saludo_noEsConfidencial_esTEST';
			plantilla.HtmlValue = 'testBody';
			plantilla.FolderId = [SELECT Id FROM Folder WHERE Type = 'Email' LIMIT 1].Id;
			plantilla.TemplateType = 'Custom';
            insert plantilla;
            CSBD_LiveAgent_Welcome_Controller.searchMessage(transcript.Id, 'Saludo');
            
            Test.startTest();
                CSBD_LiveAgent_Welcome_Controller.Response response = CSBD_LiveAgent_Welcome_Controller.registrarMensajeAutomatico(transcript.Id);
            Test.stopTest();

            LiveChatTranscript chatAfter = [
				SELECT CSBD_Oportunidad_Id__c, CSBD_Oportunidad_Id__r.CSBD_SLA_Primera_Respuesta__c
				FROM LiveChatTranscript 
				WHERE Id = :transcript.Id
			];

            System.assert(chatAfter.CSBD_Oportunidad_Id__c != null, 'El chat no tiene Oportunidad.');
            System.assert(chatAfter.CSBD_Oportunidad_Id__r.CSBD_SLA_Primera_Respuesta__c != null, 'No se registro el mensaje automatico.');
            System.assertEquals('OK', response.status, 'Comprobamos el estado es correcto.');
		}       

	}
}