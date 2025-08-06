({
    launchFlow : function(component, evt, helper) {
        var eventType = evt.getParam('value');
        component.set("v.isOpen", true);
        var flow;
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var inputVariables;
        var oppId = evt.getParam('oppId');
        if(evt.getParam('value') == 'event') {
            flow = component.find("AV_NuevoEvento");
            component.set("v.titleFlow", 'Nuevo Evento');
            inputVariables = [
                {
                    name : 'LogedUserId',
                    type : 'String',
                    value : userId
                },
                {
                    name : 'recordId',
                    type : 'String',
                    value : oppId
                }			
            ];
            flow.startFlow("AV_NuevoEvento", inputVariables);
        } else if(eventType == 'task') {
            flow = component.find("AV_NuevaTarea");
            component.set("v.titleFlow", 'Nueva Tarea');
            inputVariables = [
                {
                    name : 'LoginFlow_UserId',
                    type : 'String',
                    value : userId
                },
                {
                    name : 'recordId',
                    type : 'String',
                    value : oppId
                }			
            ];
            flow.startFlow("AV_NuevaTarea", inputVariables);
        }
    },

    textErrorFlow : function (component, event) {
        component.set("v.errorFlow", event.getParam('textError'));
    },

    statusChange : function (component, event) {
		if (event.getParam('status') === "FINISHED") {
            component.set("v.isOpen", false);
            component.set("v.isOpenOpp", false);
		}
	},
	
	closeModel: function(component, event, helper) {
		// and set set the "isOpen" attribute to "False for close the model Box.		
        component.set("v.isOpen", false);
        component.set("v.isOpenOpp", false);
    },
    launchFlowOpp : function(component, evt, helper) {
        component.set("v.isOpenOpp", true);
        var flow;
        //var userId = $A.get("$SObjectType.CurrentUser.Id");
        var inputVariables;
        var recId = component.get("v.recId");

        flow = component.find("AV_NuevaOportunidadScreenFlow");
        component.set("v.titleFlow", 'Nueva Oportunidad');
        inputVariables = [
            /*{
                name : 'LogedUserId',
                type : 'String',
                value : userId
            },*/
            {
                name : 'recordId',
                type : 'String',
                value : recId
            }			
        ];
        flow.startFlow("AV_NuevaOportunidadScreenFlow", inputVariables);
    }
})