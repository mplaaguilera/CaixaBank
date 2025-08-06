/**********************************************************************************************************************
 Name:	  CIBE_FichaProductosCIBController
 Copyright © 2023  CaixaBank
=======================================================================================================================
Proposito: Controller class of CIBE_FichaProductosComponentController
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0			US556905		    Lucía Muñoz		    22/03/2023          Init version

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