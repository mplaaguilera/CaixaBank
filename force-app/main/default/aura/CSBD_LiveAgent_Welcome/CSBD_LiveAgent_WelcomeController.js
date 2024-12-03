({
	chatDataUpdated: function(component, event) {
		if (event.getParams().changeType === 'LOADED') {
			//Cargar force:recordData de la oportunidad
			//(tras 2s para asegurar que se ha acabado de crear)
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => component.find('opportunityData').reloadRecord(), 3000);

		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.errorLds'));
		}
	},

	opportunityDataUpdated: function(component, event) {
		if (event.getParams().changeType === 'CHANGED') {
			component.find('opportunityData').reloadRecord();
		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.errorLds'));
		}
	},

	enviarSaludoAuto: function(component, event, helper) {
		let searchMessage = component.get('c.searchMessage');
		searchMessage.setParams({recordId: component.get('v.recordId'), tipoMensaje: 'Saludo'});
		searchMessage.setCallback(this, responseGetLiveChatSaludos => {
			let result = responseGetLiveChatSaludos.getReturnValue();
			component.set('v.timeout', result.timeOut);
			if (responseGetLiveChatSaludos.getState() === 'SUCCESS' && result.status === 'OK' && !result.enviadoWelcome) {
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout($A.getCallback(() =>
					helper.sendMessage(component, result.mensaje, () => component.set('v.saludoAutoCompletado', true))), 2000); //dar tiempo a cargar el componente estandar de escritura del chat;
			} else {
				component.set('v.saludoAutoCompletado', true);
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

	onNewMessage: function(component, event) { //Mensaje entrante del cliente
		const recordIdAux = component.get('v.recordId').substring(0, 15);
		if (event.getParam('recordId') === recordIdAux) {
			if (!component.get('v.oportunidad.CSBD_PrimerContactoSLA__c')) {
				component.set('v.oportunidad.CSBD_PrimerContactoSLA__c', new Date());
				component.find('opportunityData').saveRecord();
			}
		}
	},

	onAgentSend: function(component, event) { //Mensaje saliente del agente
		const recordIdAux = component.get('v.recordId').substring(0, 15);
		if (event.getParam('recordId') === recordIdAux) {
			//let oportunidad = component.get('v.oportunidad');
			if (component.get('v.oportunidad.CSBD_SLA_Primera_Respuesta__c') == null
			&& component.get('v.saludoAutoCompletado')
			&& component.get('v.oportunidad.CSBD_PrimerContactoSLA__c')
			&& !component.get('v.primerMsgAgenteEnviado')) {
				//Primer mensaje del agente (sin contar el saludo automático) tras hablar el cliente
				component.set('v.primerMsgAgenteEnviado', true);

				const fechaEntradaChat = component.get('v.oportunidad.CreatedDate');
				const fecha1erMsgAgente = new Date();
				const tiempoTranscurrido = Math.round((fecha1erMsgAgente - new Date(fechaEntradaChat)) / 60000); //en minutos

				component.set('v.oportunidad.CSBD_SLA_Primera_Respuesta__c', tiempoTranscurrido);
				//component.set('v.oportunidad', oportunidad);
				component.find('opportunityData').saveRecord();
			}
		}
	},

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

	onCloseWork: function(component, event) {
		const recordIdAux = component.get('v.recordId').substring(0, 15);
		if (event.getParam('recordId') === recordIdAux) {

			let omniToolkit = component.find('omniToolkit');
			omniToolkit.getAgentWorks().then(result => {
				const works = JSON.parse(result.works);
				works.forEach(work => {
					if (work.workItemId.substring(0, 15) === recordIdAux) {
						omniToolkit.closeAgentWork({workId: work.workId});
					}
				});
			});

			//Retrasar el envio para dar tiempo a cargar el componente estandar de escritura del chat;
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