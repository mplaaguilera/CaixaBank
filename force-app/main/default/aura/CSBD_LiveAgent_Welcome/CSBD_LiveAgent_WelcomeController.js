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
				window.setTimeout($A.getCallback(() => {
					//envia mensaje por conversationKit 
					helper.sendMessage(component, result.mensaje, () => {
						//callback function cuando el mensaje fue enviado
						component.set('v.saludoAutoCompletado', true);
						//llamar a apex para guardar el momento en el que se envia el mensaje automatico		
						//no se utiliza el .saveRecord() en oportunidad porque este metodo se ejecuta antes de tener la oportunidad cargada		
						let registrarMensajeAuto = component.get('c.registrarMensajeAutomatico');
						registrarMensajeAuto.setParams({recordId: component.get('v.recordId')});
						//no necesita callback porque es un void. 						
						$A.enqueueAction(registrarMensajeAuto);
					})							
				}), 2000); //dar tiempo a cargar el componente estandar de escritura del chat;
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
			const oportunidad = component.get('v.oportunidad');
			if (!oportunidad.CSBD_PrimerContactoSLA__c) {
				oportunidad.CSBD_PrimerContactoSLA__c = new Date();
				component.set('v.oportunidad', oportunidad);
				component.find('opportunityData').saveRecord();
			}
		}
	},

	onAgentSend: function(component, event) { //Mensaje saliente del agente
		const recordIdAux = component.get('v.recordId').substring(0, 15);
		if (event.getParam('recordId') === recordIdAux) {			
			if (component.get('v.oportunidad.CSBD_Primera_Respuesta_Agente_SLA__c') == null
			&& component.get('v.saludoAutoCompletado')
			&& component.get('v.oportunidad.CSBD_PrimerContactoSLA__c')
			&& !component.get('v.primerMsgAgenteEnviado')) {
				//Primer mensaje del agente (sin contar el saludo automático) tras hablar el cliente
				component.set('v.primerMsgAgenteEnviado', true);
				component.set('v.oportunidad.CSBD_Primera_Respuesta_Agente_SLA__c', new Date());			
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
			//Retrasar el envio para dar tiempo a cargar el componente estandar de escritura del chat;
			window.setTimeout($A.getCallback(() => {
				let searchEvent = component.get('c.searchEventTranscript');
				searchEvent.setParam('recordId', event.getParam('recordId'));
				searchEvent.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						const timeout = (response.getReturnValue().status === 'TimeOut');
						component.set('v.timeout', timeout);
						$A.get('e.force:refreshView').fire();						
					}
				});
				$A.enqueueAction(searchEvent);
			}), 8000)
		
		}
	}
});