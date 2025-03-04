({
	//Maneja las actualizaciones de datos del chat
	chatDataUpdated: function(component, event) {
		if (event.getParams().changeType === 'LOADED') {
			//Recarga los datos de la oportunidad 3 segundos después de cargar el chat
			window.setTimeout(() => component.find('opportunityData').reloadRecord(), 3000);
		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.errorLds'));
		}
	},

	//Maneja las actualizaciones de datos de la oportunidad
	opportunityDataUpdated: function(component, event) {
		if (event.getParams().changeType === 'CHANGED') {
			component.find('opportunityData').reloadRecord();
		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.errorLds'));
		}
	},

	//Envía un mensaje de saludo automático al inicio del chat
	enviarSaludoAuto: function(component, event, helper) {
		let searchMessage = component.get('c.searchMessage');
		searchMessage.setParams({recordId: component.get('v.recordId'), tipoMensaje: 'Saludo'});
		searchMessage.setCallback(this, responseGetLiveChatSaludos => {
			let result = responseGetLiveChatSaludos.getReturnValue();
			component.set('v.timeout', result.timeOut);
			//Si el saludo no se ha enviado y todo está correcto, lo envía
			if (responseGetLiveChatSaludos.getState() === 'SUCCESS' && result.status === 'OK' && !result.enviadoWelcome) {
				window.setTimeout($A.getCallback(() =>
					helper.sendMessage(component, result.mensaje, () => component.set('v.saludoAutoCompletado', true))), 2000);
			} else {
				component.set('v.saludoAutoCompletado', true);
				//Manejo de errores en el envío del saludo
				let mensajeError = '';
				if (responseGetLiveChatSaludos.getState() === 'SUCCESS' && result.status === 'KO') {
					mensajeError = result.mensaje;
				} else {
					let errores = responseGetLiveChatSaludos.getError();
					mensajeError = errores.length ? errores[0].message : '';
				}
				helper.toast('error', 'Problema enviando saludo automático', mensajeError);
			}
		});
		$A.enqueueAction(searchMessage);
	},

	//Maneja la recepción de nuevos mensajes en el chat
	onNewMessage: function(component, event) {
		const recordIdAux = component.get('v.recordId').substring(0, 15);
		if (event.getParam('recordId') === recordIdAux) {
			const oportunidad = component.get('v.oportunidad');
			//Registra el primer contacto SLA si no existe
			if (!oportunidad.CSBD_PrimerContactoSLA__c) {
				oportunidad.CSBD_PrimerContactoSLA__c = new Date();
				component.set('v.oportunidad', oportunidad);
				component.find('opportunityData').saveRecord();
			}
		}
	},

	//Maneja el envío de mensajes por parte del agente
	onAgentSend: function(component, event) {
		const recordIdAux = component.get('v.recordId').substring(0, 15);
		if (event.getParam('recordId') === recordIdAux) {
			//Calcula el tiempo de primera respuesta del agente si no existe
			if (component.get('v.oportunidad.CSBD_SLA_Primera_Respuesta__c') == null
			&& component.get('v.saludoAutoCompletado')
			&& component.get('v.oportunidad.CSBD_PrimerContactoSLA__c')
			&& !component.get('v.primerMsgAgenteEnviado')) {
				component.set('v.primerMsgAgenteEnviado', true);

				const fechaEntradaChat = component.get('v.oportunidad.CreatedDate');
				const fecha1erMsgAgente = new Date();
				//Calcula el tiempo transcurrido en minutos
				const tiempoTranscurrido = Math.round((fecha1erMsgAgente - new Date(fechaEntradaChat)) / 60000);

				component.set('v.oportunidad.CSBD_SLA_Primera_Respuesta__c', tiempoTranscurrido);
				component.find('opportunityData').saveRecord();
			}
		}
	},

	//Finaliza el chat enviando un mensaje de despedida
	finalizarChat: function(component, event, helper) {
		let getLiveChatFin = component.get('c.searchMessage');
		getLiveChatFin.setParams({recordId: component.get('v.recordId'), tipoMensaje: 'Despedida'});
		getLiveChatFin.setCallback(this, responseGetLiveChatFin => {
			if (responseGetLiveChatFin.getState() === 'ERROR') {
				console.error(getLiveChatFin.getError());
				helper.toast('error', 'Error', getLiveChatFin.getError()[0].message);
			} else if (responseGetLiveChatFin.getState() === 'SUCCESS') {
				const result = responseGetLiveChatFin.getReturnValue();
				if (result.status === 'OK') {
					helper.sendMessage(component, result.mensaje);
					helper.endChat(component);
				} else if (result.status === 'KO') {
					helper.toast('error', 'Error', result.mensaje);
				}
			}
		});
		$A.enqueueAction(getLiveChatFin);
	},

	//Maneja el cierre del trabajo del agente
	onCloseWork: function(component, event) {
		const recordIdAux = component.get('v.recordId').substring(0, 15);
		if (event.getParam('recordId') === recordIdAux) {
			//Cierra el trabajo del agente en Omni-Channel
			let omniToolkit = component.find('omniToolkit');
			omniToolkit.getAgentWorks().then(result => {
				const works = JSON.parse(result.works);
				works.forEach(work => {
					if (work.workItemId.substring(0, 15) === recordIdAux) {
						omniToolkit.closeAgentWork({workId: work.workId});
					}
				});
			});

			//Procesa el cierre del chat después de 8 segundos
			window.setTimeout($A.getCallback(() => {
				let searchEvent = component.get('c.searchEventTranscript');
				searchEvent.setParam('recordId', event.getParam('recordId'));
				searchEvent.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						const timeout = response.getReturnValue().status === 'TimeOut';
						let finChat = component.get('c.finChat');
						finChat.setParams({idChat: event.getParam('recordId'), timeout});
						finChat.setCallback(this, responseFinChat => {
							if (responseFinChat.getState() === 'SUCCESS') {
								component.set('v.timeout', timeout);
								$A.get('e.force:refreshView').fire();

								//Calcula el tiempo total de atención si no existe
								if (!component.get('v.oportunidad.CSBD_SLA_TGT__c') && component.get('v.oportunidad.CSBD_PrimerContactoSLA__c')) {
									const tiempoAtencion = Math.round((new Date() - new Date(component.get('v.oportunidad.CSBD_PrimerContactoSLA__c'))) / 60000);
									component.set('v.oportunidad.CSBD_SLA_TGT__c', tiempoAtencion);
									component.find('opportunityData').saveRecord();
								}
							}
						});
						$A.enqueueAction(finChat);
					}
				});
				$A.enqueueAction(searchEvent);
			}), 8000);
		}
	}
});