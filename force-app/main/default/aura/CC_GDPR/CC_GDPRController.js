({
	/*
     * Método de inicialización.
     */
	doInit: function(component, event, helper) {
		component.set('v.loaded', false);
		component.set('v.cssStyle', '<style>.cuf-scroller-outside {background: rgb(255, 255, 255) !important;}</style>');
		component.set('v.columnasDerechosCliente', [
			{label: 'Derecho', fieldName: 'idUrl', type: 'url', typeAttributes: {label: {fieldName: 'tipo'}, target: '_self'}, sortable: false},
			{label: 'Estado', fieldName: 'estado', type: 'text', sortable: false},
			{label: 'Fecha envío', fieldName: 'fechaEnvio', type: 'text', sortable: false},
			{label: 'Caso', fieldName: 'idCasoUrl', type: 'url', typeAttributes: {label: {fieldName: 'numeroCaso'}, target: '_self'}, sortable: false},
			{label: 'Documento cliente', fieldName: 'documentoCliente', sortable: false}
		]);
		helper.obtenerDerechosDelCliente(component);
		component.set('v.columnasDerechosCaso', [
			{label: 'Derecho', fieldName: 'idUrl', type: 'url', typeAttributes: {label: {fieldName: 'tipo'}, target: '_self'}, sortable: false},
			{label: 'Estado', fieldName: 'estado', type: 'text', sortable: false},
			{label: 'Fecha envío', fieldName: 'fechaEnvio', type: 'text', sortable: false},
			{label: 'Documento cliente', fieldName: 'documentoCliente', sortable: false}
		]);
		helper.obtenerDerechosDelCaso(component);
		$A.enqueueAction(component.get('c.cargarRecordTypesDerecho'));
	},

	/*
     * Este método se invoca al clicar sobre el boton "Ejercer derecho".
     * Abre el modal de Ejercer Derecho.
     */
	abrirModalEjercerDerecho: function(component, event, helper) {

		let modalboxColab = component.find('ModalboxEjercerDerecho');
		$A.util.addClass(modalboxColab, 'slds-fade-in-open');
		let modalBackdropColab = component.find('ModalBackdropEjercerDerecho');
		$A.util.addClass(modalBackdropColab, 'slds-backdrop--open');
	},

	/*
     * Este método se invoca al clicar sobre el aspa o el botón
     * "Cancelar" del modal de Ejercer Derecho, provocando el cierre
     * del mismo y la inicialización de todos sus campos.
     */
	cerrarModalEjercerDerecho: function(component, event, helper) {

		let cmpTarget = component.find('ModalboxEjercerDerecho');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
		let cmpBack = component.find('ModalBackdropEjercerDerecho');
		$A.util.removeClass(cmpBack, 'slds-backdrop--open');
		component.find('recordTypePickList').set('v.value', '');

	},

	/*
     * Este método se invoca al abrir el modal de Ejercer Derecho.
     * Obtiene los nombres de todos los record types de Derecho
     * y los guarda en una lista para cargarlos en el desplegable.
     */
	cargarRecordTypesDerecho: function(component, event, helper) {

		let obtenerRecordTypesDerecho = component.get('c.obtenerRecordTypesDerecho');
		obtenerRecordTypesDerecho.setCallback(this, response => {
			let mapOfRecordTypes = response.getReturnValue();
			component.set('v.mapOfRecordType', mapOfRecordTypes);
			let recordTypeList = [];
			for (let key in mapOfRecordTypes) {
				recordTypeList.push(mapOfRecordTypes[key]);
			}
			component.set('v.lstOfRecordType', recordTypeList);
		});
		$A.enqueueAction(obtenerRecordTypesDerecho);
	},

	/*
     * Este método se invoca al clicar el botón "Siguiente".
     * Obtiene el recordTypeId del recordTypeName seleccionado
     * y se lo pasa al helper para crear un registro de Derecho.
     */
	crearRegistroDerecho: function(component, event, helper, sObjectRecord) {

		let selectedRecordTypeName = component.find('recordTypePickList').get('v.value');
		if (selectedRecordTypeName != '') {
			let selectedRecordTypeMap = component.get('v.mapOfRecordType');
			let selectedRecordTypeId;

			//Obtener el recordTypeId del tipo de Derecho seleccionado
			for (let key in selectedRecordTypeMap) {
				if (selectedRecordTypeName == selectedRecordTypeMap[key]) {
					selectedRecordTypeId = key;
					break;
				}
			}

			//Cerrar el modal de Ejercer Derecho
			let cerrarModalEjercerDerecho = component.get('c.cerrarModalEjercerDerecho');
			$A.enqueueAction(cerrarModalEjercerDerecho);
			//Llamar al modal de CreateRecord de Derecho proporcionándole el recordTypeId seleccionado
			helper.showCreateRecordModal(component, selectedRecordTypeId, 'CC_Derecho__c');
		} else {
			component.find('recordTypePickList').showHelpMessageIfInvalid();
		}
	},

	refrescar: function(component, event, helper) {
    	$A.enqueueAction(component.get('c.doInit'));
	}
});