/**********************************************************************************************************************
 Name:	  AV_ListContractCLIHelper
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Helper class of AV_ListContractCLI
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Carolina Alonso		11/09/2020			Init version

***********************************************************************************************************************/
({
	getInitData : function(cmp) {
		var getInitDataCall = cmp.get('c.getCommercialProductResponse');
		getInitDataCall.setParams({"recordId" : cmp.get("v.recordId")});
		getInitDataCall.setCallback(this, function(response){
			//store state of response
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = response.getReturnValue();
				if(!data){
					console.log("error", "empty data");
					this.showToast("error", "empty data");
				} else {
					cmp.set("v.commercialProducts", data);
				}
			} else {
				console.log('error: ' + JSON.stringify(response.getError()));
				this.showToast("error", response.getError());
			}
			this.hide(cmp);
		});
		$A.enqueueAction(getInitDataCall);
	},

	show: function (cmp) {
		var spinner = cmp.find("mySpinner");
		this.showElement(cmp, spinner);
	},

	showElement : function(cmp, element){
		$A.util.removeClass(element, "slds-hide");
		$A.util.addClass(element, "slds-show");
	},

	hide:function (cmp) {
		var spinner = cmp.find("mySpinner");
		this.hideElement(cmp, spinner);
	},

	hideElement : function(cmp, element){
		$A.util.removeClass(element, "slds-show");
		$A.util.addClass(element, "slds-hide");
	},

	showToast : function(type, text) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"message": text,
			"type": type
		});
		toastEvent.fire();
	}
})