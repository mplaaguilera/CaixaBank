({
	columnasDatatable: function() {
		return [
			{label: 'Nombre', fieldName: 'Nombre_Documento', type: 'text', hideDefaultActions: true, sortable: true},
			{label: 'Tipo', fieldName: 'Tipo_Documento', type: 'text', hideDefaultActions: true, sortable: true},
			{label: 'Añadido el', fieldName: 'Fecha_Alta_Documento', type: 'date', hideDefaultActions: true, sortable: true,
				typeAttributes: {month: '2-digit', day: '2-digit', year: 'numeric'}},
			{label: 'Consultar', type: 'button-icon', initialWidth: 90,
				typeAttributes: {iconName: 'utility:preview', name: 'view_doc', title: 'Ver o descargar el documento'}}
		];
	},

	busquedaInicial: function(component) {
		component.set('v.data', []);
		let consultaInicial = component.get('c.consultaInicial');
		consultaInicial.setParam('ticketId', component.get('v.recordId'));
		consultaInicial.setCallback(this, response => {
			let result = response.getReturnValue();
			if (result && result !== '"noIdFiscal"') {
				component.set('v.data', JSON.parse(result));
			} else if (result === '"noIdFiscal"') {
				this.toast('info', 'Advertencia', 'La consulta no ha podido realizarse porque no hay identificador fiscal informado');
			} else {
				this.toast('error', 'Error', 'Ha ocurrido un error al consultar los documentos por Ticket');
			}
			component.find('inputNif').set('v.isLoading', false);
			component.find('botonBuscar').set('v.disabled', false);
		});
		$A.enqueueAction(consultaInicial);
	},

	busquedaManual: function(component) {
		const nifBuscado = component.get('v.NIFManual');
		if (nifBuscado) {
			component.find('inputNif').set('v.isLoading', true);
			component.find('botonBuscar').set('v.disabled', true);
			component.set('v.data', []);
			let consultaManual = component.get('c.consultaManual');
			consultaManual.setParams({ticketId: component.get('v.recordId'), nifBuscado});
			consultaManual.setCallback(this, response => {
				let result = response.getReturnValue();
				if (result && result !== '"noIdFiscal"') {
					component.set('v.data', JSON.parse(result));
				} else if (result === '"noIdFiscal"') {
					this.toast('info', 'Advertencia', 'La consulta no ha podido realizarse porque no hay identificador fiscal informado');
				} else {
					this.toast('error', 'Error', 'Ha ocurrido un error al consultar los documentos por NIF');
				}
				component.find('inputNif').set('v.isLoading', false);
				component.find('botonBuscar').set('v.disabled', false);
			});
			$A.enqueueAction(consultaManual);
		}
	},

	viewDocument: function(component, event) {
		let verDocumento = component.get('c.verDocumento');
		verDocumento.setParams({
			filenetId: event.getParam('row').Id_FileNet,
			serieDocumental: event.getParam('row').Serie_Documental
		});
		verDocumento.setCallback(this, response => {
			let result = response.getReturnValue();
			if (result) {
				let doc = JSON.parse(result);
				let link = document.createElement('a');
				link.download = doc.Nombre + doc.Extension;
				link.href = 'data:' + doc.MimeType + ';base64,' + doc.Content;
				link.click();
			} else {
				this.toast('error', 'Error', 'Ha ocurrido un error al obtener el documento.');
			}
		});
		$A.enqueueAction(verDocumento);
	},

	handleSort: function(component, event) {
		const getFuncionSort = (field, reverse, primer) => {
			const key = x => primer ? primer(x[field]) : x[field];
			return (a, b) => reverse * (key(a) > key(b) ? 1 : -1);
		};

		let sortedBy = event.getParam('fieldName');
		let sortDirection = event.getParam('sortDirection');
		const funcionSort = getFuncionSort(sortedBy, sortDirection === 'asc' ? 1 : -1);

		let cloneData = component.get('v.data');
		cloneData.sort(funcionSort);
		component.set('v.data', cloneData);

		component.set('v.sortDirection', sortDirection);
		component.set('v.sortedBy', sortedBy);
	},

	toast: function(type, title, message) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({title, type, message});
		toastEvent.fire();
	}
});