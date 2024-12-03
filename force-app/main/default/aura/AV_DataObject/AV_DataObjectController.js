({
	doInit : function(component, event, helper) {
		helper.showSpinner(component);

		//Load the fields an retrieve the record ID
		helper.loadData(component, event, helper);

		//Hidden the edit button (on top)
		helper.readWriteMode(component);
	},

	editToogle : function(component, event, helper) {
		helper.editToogle(component);
	},

	handleSubmit : function(component, event, helper) {
		helper.showSpinner(component);
		$A.get('e.force:refreshView').fire();
	},

	handleSuccess: function(component, event, helper) {
		helper.hideSpinner(component);
		var updatedRecord = JSON.parse(JSON.stringify(event.getParams()));
		console.log('onsuccess: ', updatedRecord.response.id);
		helper.displayToastSuccess(component, $A.get("$Label.c.AV_CMP_SaveMsgSuccess"));

		//Change the display mode
		helper.editToogle(component);
	},

	handleError: function(component, event, helper) {
		helper.hideSpinner(component);
		console.log('onerror: ', JSON.stringify(event.getParams()));
		if(event.getParams().output.errors[0].errorCode === 'FIELD_CUSTOM_VALIDATION_EXCEPTION' && event.getParams().output.errors[0].message.includes($A.get("$Label.c.AV_ForbiddenWordsErrorMessage"))) {
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				title: 'Error',
				message: event.getParams().detail,
				type: 'error',
				mode: 'sticky'
			});
			toastEvent.fire();
		} else {
			helper.displayToastError(component, $A.get("$Label.c.AV_CMP_SaveMsgError"));		
		}
	},

	makeCall: function(component, event, helper) {
		helper.showSpinner(component);
		var typeMessage = 'warning';
		var message = 'Conectando C2C...';
		console.log(message);

		var calledDevice = event.getSource().get("v.label");
		if (calledDevice=='' || calledDevice.length==0){
			helper.displayToastError(component, $A.get("$Label.c.AV_CMP_C2C_ERR_PHONE_NUMBER"));
			return;
		}
		var actionProcess = component.get('c.c2cMakeCall');
		actionProcess.setParams({"calledDevice": calledDevice});
		actionProcess.setCallback(this, function (response) {
			//check state of response
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = response.getReturnValue();
				var typeMessage = data[0];
				var message = data[1];
				console.log("info", data);
				message = message.replace("<br/>", " ")
								.replace("<br/>", " ")
								.replace("<i>"," ")
								.replace("</i>"," ");
				if ("success" === typeMessage){
					helper.displayToastSuccess(component, message);
				}
				else if ("warning" === typeMessage){
					helper.displayToastWarning(component, message);
				}
				else if ("error" === typeMessage){
					helper.displayToastError(component, message);
				}
				else {
					helper.displayToastError(component, message);
				}
			} else {
				console.log("error", response.getError());
				helper.displayToastError(component, response.getError());
			}
			helper.hideSpinner(component);
		});
		$A.enqueueAction(actionProcess);
	},

	testFunction: function(component, event, helper) {
		console.log('llamada a metodo');
	}
})