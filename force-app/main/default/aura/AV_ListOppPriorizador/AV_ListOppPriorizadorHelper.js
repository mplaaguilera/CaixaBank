/**********************************************************************************************************************
 Name:	  AV_ListOppPriorizadorHelper
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Helper class of AV_ListOppPriorizador
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								David Rufo			19/05/2020			Init version
	1.1								Carolina Alonso		19/05/2020			Update logic

***********************************************************************************************************************/
({
	getInitData : function(cmp) {
		var getInitDataCall = cmp.get('c.getInitData');
		getInitDataCall.setParams({ "recordId" : cmp.get("v.recordId"),
									"oppType" : cmp.get("v.oppType")});
		getInitDataCall.setCallback(this, function(response){
			//store state of response
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = response.getReturnValue();
				if(!data){
                    console.log("error", "empty data");
                    this.showToast("error", "empty data");
				} else {
					cmp.set("v.data", data);
				}
			} else {
                console.log("error", response.getError());
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

	getInitDataMapProducts : function(cmp) {
		var getInitDataCall = cmp.get('c.getInitDataMapProducts');
		getInitDataCall.setParams({ "clienteId" : cmp.get("v.clienteId"), 
									"pfId" : cmp.get("v.pfId")});
		getInitDataCall.setCallback(this, function(response){
			//store state of response
			var state = response.getState();
			if (state === "SUCCESS") {
				var data = response.getReturnValue();
				if(!data){
					console.log("error", "empty data");
				} else {
					cmp.set("v.data", data);
				}
			} else {
                console.log("error", response.getError());
                this.showToast("error", response.getError());
			}
			this.hide(cmp);
		});
		$A.enqueueAction(getInitDataCall);
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