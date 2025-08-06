({
    getData : function(component, event, helper) {
        helper.selectColumns(component, event);
        helper.getActionOffice(component, event);
        helper.getEstados(component, event);
    },

    handleRowAction: function (cmp, event, helper) {
        var row = event.getParam('row');        

        let shareA = cmp.get("c.shareAccion");
        shareA.setParams({
            'accionId': row.Id
        });
        
        shareA.setCallback(this, function(response){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": row.Id,
                "slideDevName": "detail"
            });
            navEvt.fire();
        });
        $A.enqueueAction(shareA);
    },
    
    sortColumn : function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },

    buscarTarea: function(component, event, helper){
        component.set("v.sBusqueda");
        component.set("v.sBusquedaDesde");
        component.set("v.sBusquedaHasta");
        component.set('v.bError', false);
        helper.buscarTarea(component, event);
    },

    handleChange: function(component) {
        component.set("v.sBusqueda");
        component.set("v.sBusquedaDesde");
        component.set("v.sBusquedaHasta");
        component.set('v.bError', false);
	},

    
    buscarAlfabetico: function(component, event, helper) {
        component.set('v.porDefecto' , false);
        component.set('v.isLoading' , true);

        helper.getActionOffice(component, event);
    },

    handlePicklistChange: function(component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        component.set("v.sBusqueda", selectedOptionValue);
    },

    valorBusquedaTeclaPulsada: function(component, event) {
		if (event.which === 13) { //Intro
			$A.enqueueAction(component.get('c.buscarAlfabetico'));
		}
	}
})