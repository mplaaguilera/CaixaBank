({
	init: function(component) {
		let numeroMaximoCasosAsociados = component.get('c.numeroMaximoCasosAsociados');
		numeroMaximoCasosAsociados.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.maximoCasos', numeroMaximoCasosAsociados.getReturnValue());
			}
		});
		$A.enqueueAction(numeroMaximoCasosAsociados);
	},

	agrupadorDataUpdated: function(component, event) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			const estadoAgrupador = component.get('v.agrupador.CC_Estado__c');
			const deshabilitado = estadoAgrupador !== 'Activo' && estadoAgrupador !== 'Pendiente Revision';
			component.set('v.deshabilitado', deshabilitado);

			if (!deshabilitado && !component.get('v.datatableColumnas').length) {
				component.set('v.datatableColumnas', [
					{fieldName: '', iconName: 'standard:case', fixedWidth: 40, hideDefaultActions: true, hideLabel: true, cellAttributes: {iconName: 'standard:case', alignment: 'center'}},
					{label: 'Fecha de apertura', fieldName: 'CreatedDate', type: 'date', innerWidth: 140, hideDefaultActions: true, sortable: true, typeAttributes: {year: 'numeric', month: 'numeric', day: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false}},
					{label: 'Número', fieldName: 'CaseNumber', hideDefaultActions: true},
					{label: 'Temática', fieldName: 'nombreTematica', initialWidth: 190, hideDefaultActions: true},
					{label: 'Estado', fieldName: 'Status', initialWidth: 130, hideDefaultActions: true},
					{iconName: 'utility:preview', type: 'button-icon', name: 'verDetalle', fixedWidth: 39, hideDefaultActions: true, typeAttributes: {title: 'Ver detalle', iconName: 'utility:preview', variant: 'bare', size: 'x-small'}},
					{iconName: 'utility:delete', type: 'button-icon', name: 'eliminar', fixedWidth: 39, hideDefaultActions: true, typeAttributes: {title: 'Eliminar', iconName: 'utility:delete', variant: 'bare', size: 'x-small'}}
				]);
			}
		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.errorLds'));
		}
	},

	lookupCasoAbrir: function(component) {
		if (component.get('v.lookupCasoValue').length > 1) {
			let lookupCaso = component.find('lookupCaso');
			$A.util.addClass(lookupCaso, 'slds-is-open');
			$A.util.removeClass(lookupCaso, 'slds-is-close');
		}
	},

	lookupCasoCerrar: function(component) {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => {
			let lookupCaso = component.find('lookupCaso');
			$A.util.addClass(lookupCaso, 'slds-is-close');
			$A.util.removeClass(lookupCaso, 'slds-is-open');
		}), 200);
	},

	lookupCasoOnchange: function(component) {
		window.clearTimeout(component.get('v.lookupCasoTimeoutTeclaPulsada'));
		const lookupCasoValue = component.get('v.lookupCasoValue');
		const lookupCasoInput = component.find('lookupCasoInput');
		if (lookupCasoValue.length > 1) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			component.set('v.lookupCasoTimeoutTeclaPulsada', window.setTimeout($A.getCallback(() => {
				lookupCasoInput.set('v.isLoading', true);
				let buscarCasosApex = component.get('c.buscarCasos');
				buscarCasosApex.setParam('cadenaBusqueda', lookupCasoValue.trim());
				buscarCasosApex.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						if (lookupCasoValue === component.get('v.lookupCasoValue')) {
							//No se ha modificado la cadena de búsqueda durante la ejecución del Apex
							lookupCasoInput.set('v.isLoading', false);
							let resultados = buscarCasosApex.getReturnValue();
							resultados.forEach((c, index, array) => {
								c.fechaApertura = new Date(c.CreatedDate).toLocaleString();
								if (c.CC_MCC_Tematica__c) {
									c.nombreTematica = c.CC_MCC_Tematica__r.Name;
								}
								array[index] = c;
							});
							component.set('v.lookupCasoResultados', resultados);
							console.log(JSON.stringify(resultados));
							const lookupCaso = component.find('lookupCaso');
							$A.util.addClass(lookupCaso, 'slds-is-open');
							$A.util.removeClass(lookupCaso, 'slds-is-close');
						}
					}
				});
				$A.enqueueAction(buscarCasosApex);
			}), 400));

		} else {
			lookupCasoInput.set('v.isLoading', false);
			const lookupCaso = component.find('lookupCaso');
			$A.util.addClass(lookupCaso, 'slds-is-close');
			$A.util.removeClass(lookupCaso, 'slds-is-open');
			component.set('v.lookupCasoResultados', null);
		}
	},

	lookupCasoSeleccionar: function(component, event) {
		let casos = component.get('v.casos');
		if (!component.get('v.casos').some(c => c.Id === event.currentTarget.dataset.id)) {
			let caso = component.get('v.lookupCasoResultados').find(c => c.Id === event.currentTarget.dataset.id);
			casos.push(caso);
			component.set('v.casos', casos);
			$A.enqueueAction(component.get('c.lookupCasoCerrar'));
		}
	},

	lookupCasoDeseleccionar: function(component) {
		component.set('v.lookupCasoSeleccionado', null);
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => component.find('lookupCasoInput').focus(), 200);
	},

	vincularAgrupadores: function(component, event, helper) {
		component.set('v.procesando', true);
		$A.enqueueAction(component.get('c.cerrarModalConfirmacion'));
		let vincularCasosApex = component.get('c.vincularCasos');
		vincularCasosApex.setParams({
			idAgrupador: component.get('v.recordId'),
			idCasos: component.get('v.casos').map(c => c.Id)
		});
		vincularCasosApex.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				helper.mostrarToast('success', 'Casos vinculados al agrupador', 'Los casos se han vinculado correctamente al agrupador ' + component.get('v.agrupador.Name'));
				$A.enqueueAction(component.get('c.cerrarModalAsociarCasos'));
				$A.get('e.force:refreshView').fire();
			}
			component.set('v.procesando', false);
		});
		$A.enqueueAction(vincularCasosApex);
	},

	datatableOnrowaction: function(component, event, helper) {
		const actionName = event.getParam('action').title;
		if (actionName === 'Eliminar') {
			let casos = component.get('v.casos');
			const indexCaso = casos.findIndex(c => c.Id === event.getParam('row').Id);
			casos.splice(indexCaso, 1);
			component.set('v.casos', casos);

		} else if (actionName === 'Ver detalle') {
			helper.verCaso(event.getParam('row').Id);
		}
	},

	abrirModalConfirmacion: function(component) {
		$A.util.addClass(component.find('modalConfirmacion'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdropConfirmacion'), 'slds-backdrop_open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('modalConfirmacionCancelar').focus()), 250);
	},

	cerrarModalConfirmacion: function(component) {
		$A.util.removeClass(component.find('modalConfirmacion'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdropConfirmacion'), 'slds-backdrop_open');
		component.find('modalAsociarCasosCancelar').focus();
	},

	abrirModalAsociarCasos: function(component) {
		$A.util.addClass(component.find('modalAsociarCasos'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdropModalAsociarCasos'), 'slds-backdrop_open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('lookupCasoInput').focus()), 250);
	},

	cerrarModalAsociarCasos: function(component) {
		$A.util.removeClass(component.find('modalAsociarCasos'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdropModalAsociarCasos'), 'slds-backdrop_open');
		component.set('v.lookupCasoResultados', []);
		component.set('v.casos', []);
		component.set('v.lookupCasoValue', '');
	},

	modalAsociarCasosOnkeydown: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalAsociarCasos'));
		}
	},

	lookupCasoInputOnkeydown: function(component, event) {
		if (component.get('v.lookupCasoValue').length) {
			event.stopPropagation();
		}
	},

	modalConfirmacionOnkeydown: function(component, event) {
		event.stopPropagation();
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalConfirmacion'));
		}
	}
});