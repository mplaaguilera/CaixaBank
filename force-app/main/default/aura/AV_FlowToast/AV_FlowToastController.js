({
	invoke : function(component, event, helper) {
		var messageRes = component.get("v.jsonToast");
		if(messageRes !== 'OK' && !messageRes.includes('Error')) {
			
	   
			var type = 'warning';
			var title = 'Warning';
			var message = messageRes;
			var mode = 'sticky';

			helper.showToast(type, title, message, mode);
		}
	}
})