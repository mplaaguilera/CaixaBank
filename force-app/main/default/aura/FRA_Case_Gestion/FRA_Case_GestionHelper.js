({
	getTematicas: function(component) {
		let getTematicas = component.get('c.getTematicas');
		getTematicas.setParams({
			'tipoCliente': component.get('v.recordTypeName'),
			'recordId': component.get('v.recordId')
		});
		getTematicas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.opcionesTematicas', response.getReturnValue());
				component.set('v.opcionesCargadas.tematicas', true);
			}
		});
		$A.enqueueAction(getTematicas);
	},

	getProductos: function(component) {
		let getProductos = component.get('c.getProductos');
		getProductos.setParams({
			'tipoCliente': component.get('v.recordTypeName'),
			'tematica': component.find('desplegableTematica').get('v.value')
		});
		getProductos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.opcionesProductos', response.getReturnValue());
				component.set('v.opcionesCargadas.productos', true);

				if (response.getReturnValue().length === 1) {
					component.find('desplegableProducto').set('v.value', response.getReturnValue()[0].value);
					$A.enqueueAction(component.get('c.productoSeleccionado'));
				}
			}
		});
		$A.enqueueAction(getProductos);
	},

	getMotivos: function(component) {
		let getMotivos = component.get('c.getMotivos');
		getMotivos.setParams({
			'tipoCliente': component.get('v.recordTypeName'),
			'producto': component.find('desplegableProducto').get('v.value')
		});
		getMotivos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.opcionesMotivos', response.getReturnValue());
				component.set('v.opcionesCargadas.motivos', true);

				if (response.getReturnValue().length === 1) {
					component.find('desplegableMotivo').set('v.value', response.getReturnValue()[0].value);
					$A.enqueueAction(component.get('c.motivoSeleccionado'));
				}
			}
		});
		$A.enqueueAction(getMotivos);
	},

	getCausas: function(component) {
		let getCausas = component.get('c.getCausas');
		getCausas.setParams({
			'tipoCliente': component.get('v.recordTypeName'),
			'motivo': component.find('desplegableMotivo').get('v.value')
		});
		getCausas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.opcionesCausas', response.getReturnValue());
				component.set('v.opcionesCargadas.causas', true);

				if (response.getReturnValue().length === 1) {
					component.find('desplegableCausa').set('v.value', response.getReturnValue()[0].value);
					$A.enqueueAction(component.get('c.causaSeleccionada'));
				}
			}
		});
		$A.enqueueAction(getCausas);
	},

	getSoluciones: function(component) {
		let getSoluciones = component.get('c.getSoluciones');
		getSoluciones.setParams({
			'tipoCliente': component.get('v.recordTypeName'),
			'causa': component.find('desplegableCausa').get('v.value')
		});
		getSoluciones.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.opcionesSoluciones', response.getReturnValue());
				component.set('v.opcionesCargadas.soluciones', true);

				if (response.getReturnValue().length === 1) {
					component.find('desplegableSolucion').set('v.value', response.getReturnValue()[0].value);
					$A.enqueueAction(component.get('c.solucionSeleccionada'));
				}
			}
		});
		$A.enqueueAction(getSoluciones);
	},

	getCampanasPicklistFMW: function(component) {
		let getPicklistValues = component.get('c.getPicklistValuesFMW');
		getPicklistValues.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let picklistValues = response.getReturnValue();

				// Ordenar de forma ascendente
				picklistValues.sort((a, b) => {
					return a.label.localeCompare(b.label);
				});
				
				component.set('v.opcionesCampanaFMW', picklistValues);
				component.set('v.opcionesCargadas.campanasFMW', true);

				if (response.getReturnValue().length === 1) {
					component.find('desplegableCampanaCustom').set('v.value', response.getReturnValue()[0].value);
					$A.enqueueAction(component.get('c.campanaCustomSeleccionada'));
				}
			}
		});
		$A.enqueueAction(getPicklistValues);
	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissable', 'duration': 4000});
		toastEvent.fire();
	},

	vaciarNivelClasificacion: function(component, nombreNivel) {
		switch (nombreNivel) {
			case 'tematica':
				component.set('v.opcionesTematicas', null);
				component.find('desplegableTematica').set('v.value', null);
				component.set('v.opcionesCargadas.tematicas', false);
				component.set('v.nivelSeleccionado.tematica', false);
				break;
			case 'producto':
				component.set('v.opcionesProductos', null);
				component.find('desplegableProducto').set('v.value', null);
				component.set('v.opcionesCargadas.productos', false);
				component.set('v.nivelSeleccionado.producto', false);
				break;
			case 'motivo':
				component.set('v.opcionesMotivos', null);
				component.find('desplegableMotivo').set('v.value', null);
				component.set('v.opcionesCargadas.motivos', false);
				component.set('v.nivelSeleccionado.motivo', false);
				break;
			case 'causa':
				component.set('v.opcionesCausas', null);
				component.find('desplegableCausa').set('v.value', null);
				component.set('v.opcionesCargadas.causas', false);
				component.set('v.nivelSeleccionado.causa', false);
				break;
			case 'solucion':
				component.find('desplegableSolucion').set('v.value', null);
				component.set('v.opcionesSoluciones', null);
				component.set('v.opcionesCargadas.soluciones', false);
				component.set('v.nivelSeleccionado.solucion', false);
				break;
		}
	}
});