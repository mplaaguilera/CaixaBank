/**********************************************************************************************************************
 Name:	  AV_ListContractCLIController
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Controller class of AV_ListContractCLI
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Carolina Alonso		11/09/2020			Init version

***********************************************************************************************************************/
({
	doInit: function(component, event, helper){
		helper.show(component);
		var titleCard = component.get("v.titleCard");
		if (titleCard){
			var valueTitleCard = $A.getReference("$Label.c."+titleCard);
			component.set("v.valueTitleCard", valueTitleCard);
		}
		helper.getInitData(component);
			
	}
})