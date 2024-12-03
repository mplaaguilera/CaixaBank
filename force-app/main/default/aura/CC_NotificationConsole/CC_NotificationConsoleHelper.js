/* eslint-disable no-undef */
({
	subscribe: function(component) {
		component.find('empApi').subscribe(
			component.get('v.channel'),
			-1, //replayId
			$A.getCallback(message => this.onReceiveNotification(component, message))
		)
		.then($A.getCallback(newSubscription => component.set('v.subscription', newSubscription)));
	},

	subscribeAvisosAgrupador: function(component) {
		component.find('empApi').subscribe(
			component.get('v.channelAvisosAgrupador'),
			-1, //replayId
			$A.getCallback(message => this.onReceiveNotificationAvisosAgrupador(message))
		)
		.then($A.getCallback(newSubscription => component.set('v.subscriptionAvisosAgrupador', newSubscription)));
	},
    
    subscribeAvisosCase: function(component) {
		component.find('empApi').subscribe(
			component.get('v.channelAvisosCase'),
			-1, //replayId
			$A.getCallback(message => this.onReceiveNotificationCase(component,message))
		)
		.then($A.getCallback(newSubscription => component.set('v.subscriptionAvisosCase', newSubscription)));
	},
	
	subscribeNotificacionAgrupador: function(component) {
		component.find('empApi').subscribe(
			component.get('v.channelNotificacionAgrupador'),
			-1, //replayId
			$A.getCallback(message => this.onReceiveNotification(component, message))
		)
		.then($A.getCallback(newSubscription => component.set('v.subscriptionNotificacionAgrupador', newSubscription)));
	},

	unsubscribe: function(component) {
		component.find('empApi').unsubscribe(
			component.get('v.subscription'),
			$A.getCallback(function() {})
		);
	},

	onReceiveNotification: function(component, message) {
         
        //Extract notification from platform event
        const newNotification = {
            'createdTime': $A.localizationService.formatDateTime(message.data.payload.CreatedDate, 'HH:mm'),
            'message': message.data.payload.Message__c
        };
        
        //Save notification in history
        let notifications = component.get('v.notifications').unshift(newNotification);
        component.set('v.notifications', notifications);
        component.find('utilityBar').setUtilityLabel({'label': 'Avisos y notificaciones (' + notifications.length + ')'});
        
        //Display notification in a toast
        let newType = message.data.payload.Type__c;
        if (newType) {
            this.displayToast(newType, message.data.payload.Message__c);
        } else {
            this.displayToast('error', message.data.payload.Message__c);
        }    
        	
	},

	onReceiveNotificationAvisosAgrupador: function(message) {
		// Extract notification from platform event
		let messageTemplate = '';

		switch (message.data.payload.Agrupador_RecordType__c) {
			case 'Comunicación Informativa':
				//Se trata de un aviso relacionado con un agrupador de tipo Comunicación Informativa
				messageTemplate = 'Acceda a la Comunicación Informativa {0}.';
				break;
			case 'Comunicación Informativa de Campaña':
				//Se trata de un aviso relacionado con un agrupador de tipo Comunicación Informativa de Campaña
				messageTemplate = 'Acceda a la Comunicación Informativa de Campaña {0}.';
				break;
			case 'Incidencia':
				//Se trata de un aviso relacionado con un agrupador de tipo Incidencia
				messageTemplate = 'Acceda a la Incidencia {0}.';
				break;
			case 'Masiva de control':
				//Se trata de un aviso relacionado con un agrupador de tipo Masiva de Control
				messageTemplate = 'Acceda a la Masiva de control {0}.';
				break;
			case 'Seguimiento':
				//Se trata de un aviso relacionado con un agrupador de tipo Seguimiento
				messageTemplate = 'Acceda al Seguimiento {0}.';
				break;
		}
		
		this.displayToastAvisoAgrupador(
			message.data.payload.Tipo__c,
			message.data.payload.Mensaje__c,
			message.data.payload.Agrupador_Id__c,
			messageTemplate
		);
	},
    
    onReceiveNotificationCase: function(component, message) {
        
        let mostrarNotificacion = false;
        var subMessage =  message.data.payload.Mensaje__c;
        subMessage = subMessage.substring(0,42);
        if(subMessage == 'Ha llegado un nuevo caso a la cola 3N_CSBD'){
            let action = component.get('c.notificacionCSBD');
            action.setParams({'mensaje': message.data.payload.Mensaje__c});
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                	mostrarNotificacion = response.getReturnValue();                	
                    if(mostrarNotificacion){
                        // Extract notification from platform event
                        let messageTemplate = 'Acceda al caso {0}.';
                        this.displayToastAvisoCase(                
                            message.data.payload.Mensaje__c,
                            message.data.payload.Case_Id__c,
                            message.data.payload.Tipo__c,
                            messageTemplate
                        );
                        const newNotification = {
                            'createdTime': $A.localizationService.formatDateTime(message.data.payload.CreatedDate, 'HH:mm'),
                            'message': message.data.payload.Mensaje__c
                        };
                        //Save notification in history
                        let notifications = component.get('v.notifications').unshift(newNotification);
                        component.set('v.notifications', notifications);
                        component.find('utilityBar').setUtilityLabel({'label': 'Avisos y notificaciones (' + notifications.length + ')'});
                    }
                }                
            });
            $A.enqueueAction(action);
        }        		
	},
    
    displayToastAvisoAgrupador: function(type, message, agrupadorId, messageTemplate) {
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			'mode': 'sticky',
			'title': message,
			'message': message, // you will need to keep this attribute
			'type': type,
			'key': 'utility:check',
			'messageTemplate': messageTemplate,
			'messageTemplateData': [{url: '/lightning/r/CC_Agrupador__c/' + agrupadorId + '/view', label: 'aquí'}]
		});
		toastEvent.fire();
	},

	displayToastAvisoCase: function(message, caseId, type, messageTemplate) {
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			'mode': 'sticky',
			'title': message,
			'message': message, // you will need to keep this attribute
			'type': type,
			'key': 'utility:check',
			'messageTemplate': messageTemplate,
			'messageTemplateData': [{url: '/lightning/r/Case/' + caseId + '/view', label: 'aquí'}]
		});
		toastEvent.fire();
	},

	displayToast: function(type, message) {
        let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({'type': type, 'message': message, 'mode': "sticky"});
        toastEvent.fire();
	},
	
	getCurrentUser: function(component) {
		let action = component.get("c.tienePermisoNotificacion");
		action.setCallback(this, function(response) {
			if (response.getState() === "SUCCESS") {
				component.set("v.isVisible", response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	}
})