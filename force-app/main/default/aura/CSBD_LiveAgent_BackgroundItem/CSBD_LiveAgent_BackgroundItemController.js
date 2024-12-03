({
    doInit: function (component, event){
        console.log('SBD BackgroundItem - On Init' + Date.now);
    },
    onCloseWork: function(component, event) {
		let chatRecordId = event.getParam('recordId');
        console.log('SBD BackgroundItem - chatrecordId ' + chatRecordId);
/*

		

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
			}), 8000);*/
    }

	
})