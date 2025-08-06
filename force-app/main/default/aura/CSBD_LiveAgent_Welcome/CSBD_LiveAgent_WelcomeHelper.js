({
	sendMessage: function(component, message, callback) {
		component.find('conversationKit').sendMessage({
			recordId: component.get('v.recordId'),
			message: {text: message}
		}).then(callback);
	},

	endChat: function(component) {
		component.find('conversationKit').endChat({recordId: component.get('v.recordId')});
	},

	toast: function(type, title, message) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({type, title, message});
		toastEvent.fire();
	}
});