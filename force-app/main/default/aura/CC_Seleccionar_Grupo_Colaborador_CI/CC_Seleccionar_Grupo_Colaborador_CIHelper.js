({
	getGC : function(component, event, helper) {
        
		var recordId = component.get("v.recordId");
        var action = component.get("c.getMCCGrupoList");  
        action.setParams({'recordId': recordId});
        action.setCallback(this, function(response) {
		if (response.getState() == "SUCCESS") {
            var options = response.getReturnValue();
			component.set("v.optionsGrupo", options);
            }else {
                console.log('ERROR updateAgrupador');                
            }
        });
        $A.enqueueAction(action); 
                 
	},
    
    cargarValor: function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        var defaultValue = component.get("v.defaultValue");
        var accion = component.get("c.getNombreGrupoColaborador");  
        accion.setParams({'recordId': recordId});
        accion.setCallback(this, function(response) {
		if (response.getState() == "SUCCESS") {
            var valueGC = response.getReturnValue();
			component.set("v.defaultValue", valueGC);
            
            }else {
                console.log('ERROR updateAgrupador');                
            }
        });
        $A.enqueueAction(accion); 
    },
	
	updateAgrupador: function(component, event, helper) {
		var recordId = component.get("v.recordId");
		var grupoColabId = component.get("v.grupoSeleccionadoValue");
        var grupoSeleccionadoName = component.get("v.grupoSeleccionadoName");
        var action = component.get("c.updateAg");  
        action.setParams({
            'recordId': recordId,
            'grupoColaboradorId': grupoColabId,
            'grupoColaboradorName' : grupoSeleccionadoName
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
			
            }else {
                console.log('ERROR updateAgrupador');
            }
        });
        $A.enqueueAction(action); 
	
	}
})