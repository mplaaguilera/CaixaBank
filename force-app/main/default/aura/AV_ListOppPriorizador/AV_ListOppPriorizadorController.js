/**********************************************************************************************************************
 Name:	  AV_ListOppPriorizadorController
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Controller class of AV_ListOppPriorizador
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								David Rufo			19/05/2020			Init version
	1.1								Carolina Alonso		19/05/2020			Update logic

***********************************************************************************************************************/
({
	doInit: function(component, event, helper){
		helper.show(component);
		var clienteId = component.get("v.clienteId");
		var pfId = component.get("v.pfId");
		var titleCard = component.get("v.titleCard");
		var oppType = component.get("v.oppType");
		if (titleCard){
			var valueTitleCard = $A.getReference("$Label.c."+titleCard);
			component.set("v.valueTitleCard", valueTitleCard);
		}
		var titleAccordion = component.get("v.titleAccordion");
		if (titleAccordion){
			var valueTitleAccordion = $A.getReference("$Label.c."+titleAccordion);
			component.set("v.valueTitleAccordion", valueTitleAccordion);
		}
		if ((typeof clienteId === 'undefined' || clienteId.length <= 0) && (typeof pfId === 'undefined' || pfId.length <= 0)) {
			helper.getInitData(component);
		}
		else{
			helper.getInitDataMapProducts(component);
		}		
	},
	
	newTask : function(component, event, helper){
		component.set("v.isOpen", true);
		var flow = component.find("AV_NuevaTarea");
		var codOpp = event.currentTarget.getAttribute("data-codOpp");
		var userId = $A.get("$SObjectType.CurrentUser.Id");
		var inputVariables = [
			{
				name : 'LoginFlow_UserId',
				type : 'String',
				value : userId
			},
			{
				name : 'recordId',
				type : 'String',
				value : codOpp
			}			
			];
		flow.startFlow("AV_NuevaTarea", inputVariables);
	},

	newEvent : function(component, event, helper){
		component.set("v.isOpenEvent", true);
		var flow = component.find("AV_NuevoEvento");
		var codOpp = event.currentTarget.getAttribute("data-codOpp");
		var userId = $A.get("$SObjectType.CurrentUser.Id");
		var inputVariables = [
			{
				name : 'LogedUserId',
				type : 'String',
				value : userId
			},
			{
				name : 'recordId',
				type : 'String',
				value : codOpp
			}			
			];
		flow.startFlow("AV_NuevoEvento", inputVariables);
	},
	
	statusChange : function (component, event) {
		if (event.getParam('status') === "FINISHED") {
			component.set("v.isOpen", false);
			component.set("v.isOpenEvent", false);
		}
	},
	
	closeModel: function(component, event, helper) {
		// and set set the "isOpen" attribute to "False for close the model Box.		
		component.set("v.isOpen", false);
		component.set("v.isOpenEvent", false);
	},
})