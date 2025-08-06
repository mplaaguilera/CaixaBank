/* eslint-disable no-undef */
({
	verCaso: function(idCaso) {
		let navEvt = $A.get('e.force:navigateToSObject');
		navEvt.setParams({'recordId': idCaso});
		navEvt.fire();
	},
    
	asociarCaso: function(component) {
		component.set('v.procesando', true);
		let mergeCaseApex = component.get('c.mergeCase');
		mergeCaseApex.setParams({'masterCaseId': component.get('v.vcaso') + '', 'mergeCaseId': component.get('v.recordId') + ''});
		mergeCaseApex.setCallback(this, response => {
			if (response.getState() === 'ERROR') {
				var errors = mergeCaseApex.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						this.errorAsociacion(errors[0].message);
					}
				}
			} else if (response.getState() === 'SUCCESS') {
				if (response.getReturnValue() === 'Ok') {
					//Toast
					this.confirmarAsociacion();
                    
					//Abrir el caso en una nueva pestaña
					let workspaceAPI = component.find('workspace');
					workspaceAPI.getFocusedTabInfo()
						.then(response => {
							var focusedTabId = response.tabId;
							workspaceAPI.openTab({focus: true,
								pageReference: {'type': 'standard__recordPage',
									'attributes': {'recordId': component.get('v.vcaso'), 'actionName':'view'},
									'state': {}}})
								.then(response => {
									workspaceAPI.focusTab({tabId: response})
										.then(responsefocus => {
											workspaceAPI.refreshTab({ 'tabId': responsefocus, 'includeAllSubtabs': true });
											workspaceAPI.closeTab({'tabId': focusedTabId});
										});
								});
						});
				} else {
					this.errorAsociacion(response.getReturnValue());
				}
			}
			component.set('v.procesando', false);
		});
		$A.enqueueAction(mergeCaseApex);
	},
    
	confirmarAsociacion: function() {
		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': 'Actualizado!', 'message': 'Asociado al caso satisfactoriamente.', 'type': 'success'});
		toastEvent.fire();
	},
    
	errorAsociacion: function(mensaje) {
		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': 'Error', 'message': mensaje , 'type': 'error'});
		toastEvent.fire();
	},
});