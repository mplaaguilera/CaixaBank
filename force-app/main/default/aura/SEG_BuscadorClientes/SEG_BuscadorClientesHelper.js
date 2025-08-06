({
	buscarDatosClientes: function(component) {
		component.find('valorBusqueda').set('v.isLoading', true);
		let getIdentidad = component.get('c.getIdentidad');
		getIdentidad.setParams({
			'cuentaPadre': component.get('v.cuentaSel'),
			'valorBusqueda': component.get('v.sBusqueda').trim(),
			'tipoFiltroContacto': component.get('v.searchTypeContact'),
			'filtroContacto': component.get('v.valueSearch')
		});
		getIdentidad.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let oMap = response.getReturnValue();
				if (oMap !== null) {
					if (oMap.RESULTADO === '1') {
						//Mensaje informativo de resultados parciales.
						if (oMap.LIMIT_EXCEEDED) {
							component.set('v.bInfo', true);
							component.set('v.sMensInfo', 'Se han encontrado más datos de los que se muestran a continuación. Realice una búsqueda más concreta.');
						}
						component.set('v.searchResult', oMap);
						component.set('v.pagina', 1);
						component.set('v.totalPaginas', oMap.TOTAL_PAGINAS);
						if (oMap.REGISTROS > 0) {
							component.set('v.mostrarResultados', true);
							component.set('v.oCuentas', oMap['BUSQUEDA_CUENTAS_' + component.get('v.pagina').toString()]);
							component.set('v.oContactos', oMap['BUSQUEDA_CONTACTOS_' + component.get('v.pagina').toString()]);
						} else {
							//Mostrar mensaje sin resultados
							component.set('v.bError', true);
							component.set('v.sMensErr', 'No se ha identificado ningún cliente/contacto.');
						}
					} else {
						//Mostrar mensaje sin resultados
						component.set('v.bError', true);
						component.set('v.sMensErr', oMap.DETALLE);
					}
				} else {
					//Mostrar mensaje sin resultados
					component.set('v.bError', true);
					component.set('v.sMensErr', 'No se ha identificado ningún cliente / contacto.');
				}
			} else {
				//Mostrar error
				component.set('v.bError', true);
				component.set('v.sMensErr', 'Se ha producido un error al realizar la consulta.');
			}
			component.find('valorBusqueda').set('v.isLoading', false);
		});
		$A.enqueueAction(getIdentidad);
	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissible', 'duration': 4000});
		toastEvent.fire();
	},

	resetErrores: function(component) {
		component.set('v.bInfo', false);
		component.set('v.bError', false);

	},

	resetResultados: function(component) {
		component.set('v.mostrarResultados', false);
	},

	resetResultadosApex: function(component) {
		component.set('v.oContactos', null);
		component.set('v.oCuentas', null);
		component.set('v.searchResult', null);
		component.set('v.pagina', 1);
		component.set('v.totalPaginas', 1);
	},

	resetFiltroContactos: function(component) {
		component.set('v.valueSearch', '');
	},

	resetCuentaSeleccionada: function(component) {
		component.set('v.cuentaSel', '');
	}
});