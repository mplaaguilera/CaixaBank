({
	doinit: function(component, event, helper) {
		component.set('v.columns', helper.columnasDatatable());
		helper.busquedaInicial(component);
	},

	busquedaInicial: function(component, event, helper) {
		component.set('v.NIFManual', '');
		helper.busquedaInicial(component);
	},

	busquedaManual: function(component, event, helper) {
		helper.busquedaManual(component);
	},

	consultarDocumento: function(component, event, helper) {
		helper.viewDocument(component, event);
	},

	handleSort: function(component, event, helper) {
		helper.handleSort(component, event);
	}
});