/* eslint-disable no-undef */
({
	onValueselect: function(component) {
		let primaryDisplayField = component.get("v.primaryDisplayField");
		let objectList = component.get('v.objectList');
		let selectedObjectIndex = component.get('v.selectedIndex');

		if (selectedObjectIndex != undefined) {
			component.set('v.selectedObject', objectList[selectedObjectIndex]);
			component.set('v.selectedObjectDisplayName', objectList[selectedObjectIndex][primaryDisplayField]);
			component.set('v.value', objectList[selectedObjectIndex]);
            component.set('v.lookupId', objectList[selectedObjectIndex]['Id']);
            component.set('v.objectList', []);
            component.set('v.enteredValue', '');
            component.set('v.lookupInputFocused', false);

            component.set('v.tematicaNew', objectList[selectedObjectIndex].CC_Tematica_Formula__c);
            component.set('v.producto_servicioNew', objectList[selectedObjectIndex].CC_Producto_Servicio_Formula__c);
            component.set('v.motivoNew', objectList[selectedObjectIndex].Name);
		}
	},

    datosCaso: function(component) {
        let action = component.get("c.datosCaso");
        action.setParams({'recordId': component.get("v.recordId")});
        action.setCallback(this, response => {
            if (response.getState() === "SUCCESS") {
                let retorno = response.getReturnValue();
                component.set("v.tipoCliente", retorno.RecordType.Name);
                component.set("v.deshabilitarOperativa", retorno.Status == 'Cerrado' || retorno.Status == 'Rechazado');

                if (retorno.CC_MCC_Tematica__c != null && retorno.CC_MCC_ProdServ__c != null && retorno.CC_MCC_Motivo__c != null) {
                    component.set('v.tematica', retorno.CC_MCC_Tematica__r.Name);
                    component.set('v.producto_servicio', retorno.CC_MCC_ProdServ__r.Name);
                    component.set('v.motivo', retorno.CC_MCC_Motivo__r.Name);
                }

            }
        });
        $A.enqueueAction(action);
    },
})