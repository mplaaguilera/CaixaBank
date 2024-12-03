/**********************************************************************************************************************
 Name:	  AV_FichaProductosHelper
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Helper class of AV_FichaProductos
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								David Rufo			19/05/2020			Init version
	1.1								Carolina Alonso		19/05/2020			Update logic
	1.2								ÁLvaro López		18/11/2020			Added professional prods

***********************************************************************************************************************/
({
	getInitData : function(cmp) {
		var getInitDataCall = cmp.get('c.getInitData');
		getInitDataCall.setParams({ "recordId" : cmp.get("v.recordId")});
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

	processData : function(cmp) {
		var listProds = cmp.get('v.data');
		var listNoProf = [];
		var listProfs = [];
		for(var prod of listProds.listProducts) {
			if(prod.isProfessional) {
				listProfs.push(prod);
				cmp.set("v.hasProfessional", true);
			} else {
				listNoProf.push(prod);
			}
		}
		cmp.set("v.dataNoProf", listNoProf);
		cmp.set("v.dataProf", listProfs);
	},

	show: function (cmp) {
		var spinner = cmp.find("mySpinner");
		$A.util.removeClass(spinner, "slds-hide");
		$A.util.addClass(spinner, "slds-show");
	},

	hide:function (cmp) {
		var spinner = cmp.find("mySpinner");
		$A.util.removeClass(spinner, "slds-show");
		$A.util.addClass(spinner, "slds-hide");
	}, 

	getOpportunityNumber : function(cmp, event, helper, clienteId, pfId) {
		var getOppData = cmp.get('c.getOpportunityNumber');
		helper.getClientName(cmp, clienteId);
		getOppData.setParams({ "clientId" : clienteId, 
									"pfId" : pfId});		
		getOppData.setCallback(this, function(response){
			//store state of response
			var state = response.getState();
			if (state === "SUCCESS") {
				cmp.set('v.numOpp',response.getReturnValue());
				var numOpp = response.getReturnValue();
				if(numOpp.length === 1){
					let targetObjectName = "Opportunity";
					var urlTo = '/lightning/r/' + targetObjectName + '/' + numOpp[0].Id + '/view';
					let workspaceAPI = cmp.find("workspace");

					workspaceAPI.openTab({
						url: urlTo,
						focus: true
					}).then(function(response) {
						workspaceAPI.openSubtab({
							parentTabId: response,
							url: urlTo,
							focus: true
						});
					})
					.catch(function(error) {
						console.log(error);
						this.showToast("error", error);
					});
				} else {
					helper.openModal(cmp, event, helper, clienteId, pfId);
				}
			} else {
				console.log("error", response.getError());
				this.showToast("error", response.getError());
			}
			this.hide(cmp);
		});
		$A.enqueueAction(getOppData);
	},
	
	openModal : function (component, event, helper, clienteId, pfId){
		component.set("v.isOpenModel", true);
		//Creating dynamic Lightning datatable
		var targetCmp = component.find("newDtPlaceholder");
		targetCmp.set("v.body",[]); //destroying existing one
		$A.createComponent("c:AV_ListOppPriorizador", {
				"data":	null,
				"clienteId": clienteId,
				"pfId": pfId
			},
			function(tbl, state, message) {
				if (state === "SUCCESS") {
					var body = targetCmp.get("v.body");
					body.push(tbl);
					targetCmp.set("v.body", body);
				}else{
					console.log("error", "openModal -> Error: " + message);
					this.showToast("error", message);
				}
			}
		);
	},

	getClientName : function(cmp, clienteId) {
		var getOppData = cmp.get('c.getClientName');
		getOppData.setParams({ "clientId" : clienteId});
		getOppData.setCallback(this, function(response){
			//store state of response
			var state = response.getState();
			if (state === "SUCCESS") {
				cmp.set('v.clienteName',response.getReturnValue());
				
			} else {
				console.log("error", response.getError());
				this.showToast("error", response.getError());
			}
			this.hide(cmp);
		});
		$A.enqueueAction(getOppData);
	},

	showToast : function(type, text) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"message": text,
			"type": type
		});
		toastEvent.fire();
	},

	showSpinner : function (component) {
		var spinner = component.find("mySpinner");
		$A.util.removeClass(spinner, "slds-hide");
		$A.util.addClass(spinner, "slds-show");
	},
})