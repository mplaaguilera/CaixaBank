/**********************************************************************************************************************
 Name:	  AV_FichaProductosController
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Controller class of AV_FichaProductos
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								David Rufo			19/05/2020			Init version
	1.1								Carolina Alonso		19/05/2020			Update logic
	1.2								Esperanza Conde		20/07/2020			Update logic to show listproduct and myBox
***********************************************************************************************************************/
({
	doInit: function(component, event, helper){
		//helper.show(component);
		//var actualData = component.get("v.data");
		//helper.getInitData(component);		
		helper.processData(component);
	},

	openSubtab : function(component, event, helper) {
		let targetId = event.currentTarget.getAttribute("data-codProduct");
		var recordId = event.currentTarget.getAttribute("data-clientId");
		helper.getOpportunityNumber(component,event, helper, recordId, targetId);		
	},	

	closeModal : function (component, event, helper){
			component.set("v.isOpenModel", false);
	},

	navigateToRecord : function (component, event, helper) {
		let recordId = event.currentTarget.getAttribute("data-codProduct");
		var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({
		  "recordId": recordId,
		  "slideDevName": "detail"
		});
		navEvt.fire();
	}
})