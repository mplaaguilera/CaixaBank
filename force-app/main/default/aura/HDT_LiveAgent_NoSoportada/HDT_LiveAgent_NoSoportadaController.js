({
	doInit: function(component) {
		let getMensajesChat = component.get('c.getMensajesChat');
		getMensajesChat.setParams({
			sCodigoMsj: 'No Soportada',
			idioma: component.get('v.idioma'),
			//oGlobalIds : component.get("v.oIdentGlobales"),
			oGlobalIds: null,
			sOrigen: component.get('v.origen'),
			sAreaChat: component.get('v.areaChat')
		});
		getMensajesChat.setCallback(this, response => {
			let list = response.getReturnValue();
			if (list && list.length) {
				let msgCognitivo = [];
				let auto = [];
				list.forEach(item => {
					msgCognitivo.push(item.CC_Respuesta_Mensaje_Automatico_es__c);
					auto.push(item.CC_Mensaje_Agente_es__c);
				});
				component.set('v.picklistValues', msgCognitivo);
				component.set('v.codCognitive', list[0].CC_Codigo_Cognitive__c);
				component.set('v.auto', auto);
			} else {
				component.set('v.picklistValues', []);
			}
		});
		$A.enqueueAction(getMensajesChat);
	},

	handleCancel: function(component) {
		component.set('v.isActive', false);
	},

	aceptar: function(component) {
		let autoIter = component.find('selectId').get('v.value');
		if (autoIter === '') {
			return;
		}

		let auto = component.get('v.auto')[autoIter];
		let msg = component.get('v.picklistValues')[autoIter];

		let conversationKit = component.find('conversationKit');
		conversationKit.sendMessage({
			recordId: component.get('v.chatId').substring(0, 15),
			message: {text: auto}
		});
		component.set('v.isActive', false);
		component.set('v.valor', '');

		//Envio del evento a Watson
		conversationKit.sendCustomEvent({
			recordId: component.get('v.chatId').substring(0, 15),
			type: 'AGENT_ACTION',
			data: JSON.stringify({
				responseType: component.get('v.codCognitive'), //"MSG"
				txtMsg: msg
			})
		});
		let activityNoSoportada = component.get('c.ActivityNoSoportada');
		activityNoSoportada.setParams({
			recordId: component.get('v.caseId'),
			comentario: msg,
			cognitiveId: component.get('v.cognitiveId'),
			subject: 'Chat - No Soportada',
			transcriptId: component.get('v.chatId')
		});
		activityNoSoportada.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				$A.get('e.force:refreshView').fire();
			}
		});
		$A.enqueueAction(activityNoSoportada);
	}
});