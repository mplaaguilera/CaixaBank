({
	ejecutarConsulta  : function(component, event, helper) {
		var recordId = component.get("v.recordId");
		var fechaIni = component.get("v.fechaIni");
        var fechaFin = component.get("v.fechaFin");
		console.log("entramos" + recordId + fechaFin + fechaIni);
        //
        var obtenerDatos = component.get("c.ejecutarConsulta");        
		obtenerDatos.setParams({
                        'numPerso': recordId,
           				'fechaIni': fechaIni,
          				'fechaFin': fechaFin
                    });
        obtenerDatos.setCallback (this , response => {
             var state = response.getState();
            if (state ==="SUCCESS") {
            	console.log("resultado - OK" + response.getReturnValue());
                 component.set('v.contactos', response.getReturnValue());

             	}
			else {
            	console.log("resultado - KO");
                const toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({
                    type: "error",
                    message: "error al obtener los datos.",
                    mode: "pester"
                });
                toastEvent.fire();    
			}
        });
       
        $A.enqueueAction(obtenerDatos);
        
	}	
	
})