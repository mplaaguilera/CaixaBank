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
    handleStatusChange : function (component, event, helper) {
        if(event.getParam("status") === "FINISHED") {
           // Get the output variables and iterate over them
           helper.editToogle(component);
           //Load the fields an retrieve the record ID
		    helper.loadData(component, event, helper);
        }
     },

	 handleGetValueFromLwc : function (component, event, helper){
		component.set("v.readOnly",event.getParam('isReadOnly'));
	 },

	 handleCancelEdit : function (component, event, helper){
		component.set("v.readOnly",true);
	 }
/*
	openTabWithSubtab : function(component, event, helper) {
		var workspaceAPI = component.find("workspace");
		var interlocutorId = component.get("v.interlocutor");
		console.log("interlocutorId: " + interlocutorId);
		workspaceAPI.openSubtab({
			url: '/lightning/r/Account/' + interlocutorId + '/view',
			focus: true
		})
		.catch(function(error) {
			console.log(error);
		});
	}
*/
})