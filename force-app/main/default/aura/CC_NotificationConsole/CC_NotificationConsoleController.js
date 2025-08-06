/* eslint-disable no-console */
/* eslint-disable no-undef */
({
	onInit: function(component, event, helper) {
		//component.set('v.subscription', null);
		//component.set('v.subscriptionAvisosAgrupador', null);
		
		//Register empApi error listener and pass in the error handler function.
		component.find('empApi').onError($A.getCallback(message => console.error('Received error: ', JSON.stringify(message))));

		helper.subscribe(component);
		helper.subscribeAvisosAgrupador(component);
        
		
		let get3NUser = component.get('c.get3NUser');
		get3NUser.setCallback(this, response => {
			if (response.getState() === "SUCCESS") {
                if(response.getReturnValue()){
                    helper.subscribeAvisosCase(component);
                }
			}
		});	
		$A.enqueueAction(get3NUser);
       
        helper.subscribeNotificacionAgrupador(component);
		
		//Get Current Profile User
		helper.getCurrentUser(component);

		/*
		// Get type picklist items
		let getTypePicklistItems = component.get('c.getTypePicklistItems');
		getTypePicklistItems.setCallback(this, response => {
			if (response.getState() === "SUCCESS") {
				component.set('v.options', response.getReturnValue());
				console.log(JSON.stringify(response.getReturnValue()));
			}
		});
		$A.enqueueAction(getTypePicklistItems);
		*/

		// Get visible notifications
		let getVisibleNotifications = component.get('c.getVisibleNotifications');
		getVisibleNotifications.setCallback(this, response => {
			if (response.getState() === "SUCCESS") {
				component.set('v.notifications', response.getReturnValue());
				if (component.get('v.notifications.length') > 0) {            		
					component.find('utilityBar').setUtilityLabel({'label': 'Avisos y notificaciones (' + component.get('v.notifications.length') + ')' });
				}
			}
		});
		$A.enqueueAction(getVisibleNotifications);
	},

	/*
	// Clear notifications in console app.
	onClear: function(component) {
		component.set('v.notifications', []);
	},

	// Mute toast messages and unsubscribe/resubscribe to channel.
	onToggleMute: function(component, event, helper) {
		const isMuted = !(component.get('v.isMuted'));
		component.set('v.isMuted', isMuted);
		if (isMuted) {
			helper.unsubscribe(component);
		} else {
			helper.subscribe(component);
		}
		helper.displayToast('success', 'Notificaciones ' +
			((isMuted) ? 'desactivadas' : 'activadas') + '.');
	},

	onSendNotification: function(component, event, helper) {
		let comments = component.find("motivoText").get("v.value");

		// Save notification in history
		let time = new Date();
		const newNotification = {
			'createdTime': $A.localizationService.formatDateTime(time.getTime(), 'HH:mm'),
			'message': comments
		};
		
		component.set('v.notifications', component.get('v.notifications').unshift(newNotification));
		helper.displayToast(component.find("comboType").get("v.value"), comments);
	},
	*/
	
	onSendEvent: function(component) {
		let comments = component.find("motivoText").get("v.value");
		let tipoNot = component.find("comboType").get("v.value");

		let sendEvent = component.get("c.sendEvent");
		sendEvent.setParams({'message': comments, 'type': tipoNot});
		$A.enqueueAction(sendEvent);

		// Save notification in Historial Notificación entity
		let saveNotification = component.get('c.saveNotification');
		saveNotification.setParams({'message': comments, 'type': tipoNot});
		$A.enqueueAction(saveNotification);
	}
})