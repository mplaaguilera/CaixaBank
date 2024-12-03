({
	iniciar : function(component, event, helper) {
		helper.getGC(component,event,helper);
        helper.cargarValor(component,event,helper);
	},
	
	seleccionaGrupoColaborador: function(component, event, helper) {
        component.set("v.opcionSeleccionada", true);
        var actualOption = event.getParam("value"); //Id        
        var picklistFirstOptionsGrupo = component.get("v.optionsGrupo");
            for (var key in picklistFirstOptionsGrupo) {
                if (event.getParam("value") === picklistFirstOptionsGrupo[key].value) {
                    component.set("v.grupoSeleccionadoValue", picklistFirstOptionsGrupo[key].value);
                    component.set("v.grupoSeleccionadoName", picklistFirstOptionsGrupo[key].label);
                }
            }       

    },
    
    guardar : function(component, event, helper) {
		helper.updateAgrupador(component, event, helper);
        $A.get('e.force:refreshView').fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({ message:'Grupo Colaborador Asignado',                        
                                        type: 'success', 
                                        mode: 'dismissible', 
                                        duration: '4000' });
        toastEvent.fire();
	}
                    

})