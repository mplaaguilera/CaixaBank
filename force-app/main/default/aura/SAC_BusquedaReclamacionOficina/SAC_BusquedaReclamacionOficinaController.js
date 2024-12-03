({
    valorBusquedaTeclaPulsada: function(component, event) {
		if (event.which === 13) { //Intro
			let sBusqueda = component.get("v.sBusqueda");
            let getOffices = component.get("c.getOffices");
            getOffices.setParams({
                'officeName': sBusqueda
            });
            getOffices.setCallback(this, function(response){
                let state = response.getState();
                if (state === "SUCCESS") {
                    let rows = response.getReturnValue();
                    component.set("v.predictions", rows);
                }
            });
            $A.enqueueAction(getOffices);
		}
	},
    handleChange: function(component, event){
        let sBusqueda = component.get("v.sBusqueda");
        if(sBusqueda.length > 2){
            let getOffices = component.get("c.getOffices");
            getOffices.setParams({
                'officeName': sBusqueda
            });
            getOffices.setCallback(this, function(response){
                let state = response.getState();
                if (state === "SUCCESS") {
                    let rows = response.getReturnValue();
                    component.set("v.predictions", rows);
                }
            });
            $A.enqueueAction(getOffices);
        }
    },
    selectOffice :function(component, event, handler){
        handler.selectOffice(component, event);
    }
})