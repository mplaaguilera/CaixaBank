/**********************************************************************************************************************
Name:     CSBD_LiveAgent_Welcome_Controller
Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Controlador apex del aura component: CSBD_LiveAgent_Welcome
=======================================================================================================================
Historial
---------------------
VERSION     USER_STORY      AUTHOR              DATE                Description
1.0         App CSBD        Esperanza Conde	    10/02/2022          Init version
***********************************************************************************************************************/

public with sharing class CSBD_LiveAgent_Welcome_Controller {

	public class Response {
		@AuraEnabled public String status {get;set;}
		@AuraEnabled public String mensaje {get;set;}
		@AuraEnabled public Boolean timeOut {get;set;}
		@AuraEnabled public Boolean enviadoWelcome {get;set;}
	}

	@AuraEnabled
	public static Response searchMessage(String recordId, String tipoMensaje) {
		Response result = new Response();
		try {
			LiveChatTranscript chat = [SELECT OwnerId, CC_Cerrado_TimeOut__c, CSBD_Oportunidad_Id__c,
										CSBD_Welcome_Enviado__c, CC_Idioma__c, Account.CC_Confidencial__c, //CreatedDate
										Account.FirstName FROM LiveChatTranscript WHERE Id = :recordId];


			String horaMensaje;
			if (tipoMensaje == 'Despedida') {
				Integer horaActual = DateTime.now().hour();
				if (horaActual > 0 && horaActual <= 13) {
					horaMensaje = 'Manana';
				} else if (horaActual > 13 && horaActual <= 20) {
					horaMensaje = 'Tarde';
				} else if (horaActual > 20 && horaActual <= 24) {
					horaMensaje = 'Noche';
				}
			}

			Boolean isConfidencial = chat.Account.CC_Confidencial__c;
			List<EmailTemplate> mdtMensaje = searchCustomMetadata(chat, tipoMensaje, isConfidencial, horaMensaje);
			if (!mdtMensaje.isEmpty()) {
				String mensajeAux = '';
				/*
				if (mensajeAux.contains('{clienteName}')) {
					mensajeAux = mensajeAux.replace('{clienteName}', transcript.Account.FirstName);
				}
				if (mensajeAux.contains('{gestorName}')) {
					mensajeAux = mensajeAux.replace('{gestorName}', UserInfo.getName());
				}
				*/

				List<String> cuerpos = new List<String>{mdtMensaje[0].HtmlValue.stripHtmlTags()};
				List<Messaging.RenderEmailTemplateBodyResult> renderStored = Messaging.renderEmailTemplate(UserInfo.getUserId(), recordId, cuerpos);
				if (!renderStored.isEmpty()) {
					String bienvenida = renderStored[0].getMergedBody();
					mensajeAux = bienvenida;
				}

				if (tipoMensaje == 'Saludo') {
					//Consulta para ver si se ha enviado o no el chat de welcome.
					result.enviadoWelcome = chat.CSBD_Welcome_Enviado__c;
					if (!chat.CSBD_Welcome_Enviado__c) {
						chat.CSBD_Welcome_Enviado__c = true;
						update chat;
						relacionarTranscript(chat); //Relacionamos la opp y la tarea al gestor de CSBD que este logueado.
					}
				}
				result.timeOut = chat.CC_Cerrado_TimeOut__c;
				result.status = 'OK';
				result.mensaje = mensajeAux;
			} else {
				result.status = 'KO';
				result.mensaje = 'No se encuentra una coincidencia para la parametrización. Tipo de Mensaje: ' + tipoMensaje + '. Idioma: ' + chat.CC_Idioma__c + '. Cliente confidencial? : ' + isConfidencial + '.';
			}
			return result;

		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	/**
	* @description		 	Busca el custom metadata que guarda los mensajes automaticos del chat
	* @param transcript		la transcripción
	* @param tipoMensaje	tipo de mensaje buscado
	* @param isConfidencial	isConfidencial
	* @param horaMensaje	horaMensaje
	*/
	//@AuraEnabled(cacheable=true)
	private static List<EmailTemplate> searchCustomMetadata(LiveChatTranscript transcript, String tipoMensaje, Boolean isConfidencial, String horaMensaje) {
		String confidencial = isConfidencial ? 'esConfidencial' : 'noEsConfidencial';
		String nombrePlantilla;
		if (tipoMensaje == 'Despedida') {
			nombrePlantilla = horaMensaje + '_' + tipoMensaje + '_' + confidencial + '_' + transcript.CC_Idioma__c;
		} else if (tipoMensaje == 'Saludo') {
			nombrePlantilla = tipoMensaje + '_' + confidencial + '_' + transcript.CC_Idioma__c;
			if (Test.isRunningTest()) {
				nombrePlantilla += 'Test';
			}
		}
		return [SELECT DeveloperName, HtmlValue FROM EmailTemplate WHERE DeveloperName = :nombrePlantilla];
	}

	private static void relacionarTranscript(LiveChatTranscript chat) {
		if (chat.CSBD_Oportunidad_Id__c != null) {
			Opportunity oportunidad = new Opportunity(Id = chat.CSBD_Oportunidad_Id__c);
			oportunidad.OwnerId = chat.OwnerId;
			update oportunidad;

			List<Task> tareas = [SELECT Id FROM Task WHERE WhatId = :oportunidad.Id
									AND CC_LiveChatTranscript_Id__c = :chat.Id ORDER BY CreatedDate DESC LIMIT 1];
			if (!tareas.isEmpty()) {
				tareas[0].OwnerId = chat.OwnerId;
				update tareas[0];
			}
		}
	}

	@AuraEnabled
	public static Response searchEventTranscript(Id recordId) {
		Response result = new Response();
		if (recordId != null) {
			List<LiveChatTranscriptEvent> eventosTimeout = [SELECT Type FROM LiveChatTranscriptEvent WHERE LiveChatTranscriptId = :recordId
															AND Type IN ('ConnectionTimeout', 'ChasitorIdleTimeout') LIMIT 1];
			if (!eventosTimeout.isEmpty()) {
				result.status = 'TimeOut';
			}
		}
		return result;
	}

	@AuraEnabled
	public static void finChat(Id idChat, Boolean timeout) {
		LiveChatTranscript chat = [SELECT CSBD_Oportunidad_Id__c FROM LiveChatTranscript WHERE Id = :idChat];
		if (timeout) {
			chat.CC_Cerrado_TimeOut__c = true;
			update chat;
		}

		String asunto = timeout ? 'Conversación - Time Out' : 'Conversación con agente chat finalizada';
		String tipo = timeout ? 'Time Out' : 'Automática';
		String descripcion = timeout ? 'Se ha producido un time out por inactividad.' : null;
		createActivity(idChat, chat.CSBD_Oportunidad_Id__c, asunto, tipo, descripcion);
	}

	@AuraEnabled
	public static void createActivity(Id idChat, Id idOportunidad, String asunto, String tipo, String descripcion) {
		Task task = new Task();
		task.WhatId = idOportunidad;
		task.CC_LiveChatTranscript_Id__c = idChat;
		task.ActivityDate = System.today();
		task.Subject = asunto;
		task.Type = tipo;
		task.Status = 'Completed';
		task.Description = descripcion;
		CC_Activity.crearActividad(task);
	}
}