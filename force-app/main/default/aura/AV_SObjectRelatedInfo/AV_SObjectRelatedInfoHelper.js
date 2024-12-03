({
	showHide : function(component, strComponent) {
		var objCmp = component.find(strComponent);
		$A.util.toggleClass(objCmp, "slds-hide");
	},

	hide : function(component, strComponent) {
		var objCmp = component.find(strComponent);
		$A.util.addClass(objCmp, "slds-hide");
	},

	show : function(component, strComponent) {
		var objCmp = component.find(strComponent);
		$A.util.removeClass(objCmp, "slds-hide");
	},

	showSpinner : function (component) {
		var spinner = component.find("mySpinner");
		$A.util.removeClass(spinner, "slds-hide");
		$A.util.addClass(spinner, "slds-show");
	},

	hideSpinner : function (component) {
		var spinner = component.find("mySpinner");
		$A.util.removeClass(spinner, "slds-show");
		$A.util.addClass(spinner, "slds-hide");
	},

	displayToast : function (component, message, type){
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": $A.get("$Label.c.AV_CMP_SuccessEvent"),
			"message": message,
			"type": type
		});
		toastEvent.fire();
	},

	displayToastSuccess : function (component, message){
		this.displayToast(component, message, "success");
	},

	displayToastWarning : function (component, message){
		this.displayToast(component, message, "warning");
	},

	displayToastError : function (component, message){
		this.displayToast(component, message, "error");
	}

})