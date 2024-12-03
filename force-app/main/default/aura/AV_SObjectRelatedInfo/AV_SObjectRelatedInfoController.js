({
	doInit : function(component, event, helper) {
		var titleCard = component.get("v.titleCard");
		if (titleCard){
			var valueTitleCard = $A.getReference("$Label.c."+titleCard);
			component.set("v.valueTitleCard", valueTitleCard);
		}
		var titleAccordion = component.get("v.titleAccordion");
		if (titleAccordion){
			var valueTitleAccordion = $A.getReference("$Label.c."+titleAccordion);
			component.set("v.valueTitleAccordion", valueTitleAccordion);
		}
	},

	handleComponentEvent : function(component, event, helper) {
		var childHasInterlocutor = event.getParam("hasInterlocutor");
        component.set("v.interlocutor", childHasInterlocutor);
	}
})