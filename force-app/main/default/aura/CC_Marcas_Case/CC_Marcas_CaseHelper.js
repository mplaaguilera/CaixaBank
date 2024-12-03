/* eslint-disable no-undef */
({
    getParameterByName: function(name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },

    getDatosCaso: function(component) {
        let action = component.get("c.caracteristicas");
        action.setParam("recordId", component.get('v.recordId'));
        action.setCallback(this, response => {
            if (response.getState() === "SUCCESS") {
                let datos = response.getReturnValue();
                let options = [];
                datos.forEach(element => options.push({'value': element.Id, 'label': element.Name}));
                component.set("v.opcionesMarcasActivasLista", options);
            }
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action);
    },

    openSubtabMarca: function(component, idMarca) {
        let workspaceAPI = component.find("workspace");
        workspaceAPI.openSubtab({
            'parentTabId': workspaceAPI.getEnclosingTabId(),
            'url': '/lightning/r/CC_Marca_Case__c /' + idMarca + '/view',
            'focus': true
        });
    },
    
    mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissible', 'duration': 4000});
		toastEvent.fire();
	}
})