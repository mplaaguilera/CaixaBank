({
	buscarDatosClientes: function(component) {
		let getIdentidad = component.get('c.getIdentidad');
		getIdentidad.setParams({
			valorBusqueda: component.get('v.sBusqueda').trim(),
			caseId: component.get('v.caseId')
		});
		getIdentidad.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let respuesta = response.getReturnValue();
				if (respuesta) {
					if (respuesta.RESULTADO === '1') {
						//Mensaje informativo de resultados parciales.
						component.set('v.searchResult', respuesta);

						if (respuesta.REGISTROS > 0) {
							component.set('v.numeroResultados', respuesta.REGISTROS);
							component.set('v.mostrarResultados', true);
							component.set('v.oColaboradores', respuesta['BUSQUEDA_COLABORADORES']);
							component.set('v.oContactos', respuesta['BUSQUEDA_CONTACTOS']);
							component.set('v.oGrupos', respuesta['BUSQUEDA_GRUPOS']);
							component.set('v.oGestores', respuesta['BUSQUEDA_GESTORES']);
							component.set('v.oOtrosGestores', respuesta['BUSQUEDA_OTROSGESTORES']);
						} else {
							//Mostrar mensaje sin resultados
							component.set('v.bError', true);
							component.set('v.sMensErr', 'No se ha encontrado ningún resultado.');
						}
					} else {
						//Mostrar mensaje sin resultados
						component.set('v.bError', true);
						component.set('v.sMensErr', respuesta.DETALLE);
					}
				} else {
					//Mostrar mensaje sin resultados
					component.set('v.bError', true);
					component.set('v.sMensErr', 'No se ha encontrado ningún resultado.');
				}
			} else {
				//Mostrar error
				component.set('v.bError', true);
				component.set('v.sMensErr', 'Se ha producido un error al realizar la consulta.');
				console.error(JSON.stringify(response.getError()));
			}
		});
		$A.enqueueAction(getIdentidad);
	},

	buscarContactosBoton: function(component, event) {
		let getIdentidadBoton;
		//Limpiamos la variable de pulsados para quitar la selección de los otros botones
		component.set('v.pulsadoSOE', false);
		component.set('v.pulsadoOSN', false);
		component.set('v.pulsadoRelacionados', false);

		//Si se ha pulsado el boton de Contactos SOE
		if(event.getSource().getLocalId() == "contactosSOE"){
			component.set('v.pulsadoSOE', true);
			getIdentidadBoton = component.get('c.getContactosSOE_OSN');
			getIdentidadBoton.setParams({
				'caseId': component.get('v.caseId'),
				'botonSOE': true
			});
		//Si se ha pulsado el boton de Contactos OSN	
		}else if(event.getSource().getLocalId() == "contactosOSN"){//Si se ha pulsado el boton de Contactos OSN
			component.set('v.pulsadoOSN', true);
			getIdentidadBoton = component.get('c.getContactosSOE_OSN');
			getIdentidadBoton.setParams({
				'caseId': component.get('v.caseId'),
				'botonSOE': false
			});
		//Si se ha pulsado el boton Relacionados	
		}else{
			component.set('v.pulsadoRelacionados', true);
			getIdentidadBoton = component.get('c.getIdentidadBoton');
			getIdentidadBoton.setParam('caseId', component.get('v.caseId'));
		}

		getIdentidadBoton.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let respuesta = response.getReturnValue();
				if (respuesta) {
					if (respuesta.RESULTADO === '1') {						
						component.set('v.searchResult', respuesta);

						if (respuesta.REGISTROS > 0) {
							component.set('v.numeroResultados', respuesta.REGISTROS);
							component.set('v.mostrarResultados', true);
							component.set('v.oContactos', respuesta['BUSQUEDA_CONTACTOS']);
							component.set('v.oGestores', respuesta['BUSQUEDA_GESTORES']);
						} else {
							//Mostrar mensaje sin resultados
							component.set('v.bError', true);
							component.set('v.sMensErr', 'No se ha encontrado ningún resultado.');
						}
					} else {
						//Mostrar mensaje sin resultados
						component.set('v.bError', true);
						component.set('v.sMensErr', respuesta.DETALLE);
					}
				} else {
				//Mostrar mensaje sin resultados
					component.set('v.bError', true);
					component.set('v.sMensErr', 'No se ha encontrado ningún resultado.');
				}
			} else {
			//Mostrar error
				component.set('v.bError', true);
				component.set('v.sMensErr', 'Se ha producido un error al realizar la consulta.');
			}
			//Refrescar vista
			//$A.get('e.force:refreshView').fire();
		});
		$A.enqueueAction(getIdentidadBoton);

	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissible', 'duration': 4000});
		toastEvent.fire();
	},

	mostrarToastQuick: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissible', 'duration': 60});
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
		component.set('v.oColaboradores', null);
		component.set('v.oGestores', null);
		component.set('v.oOtrosGestores', null);
		component.set('v.searchResult', null);
	},

	resetCuentaSeleccionada: function(component) {
		component.set('v.cuentaSel', '');
	},

	logicaSeleccionarNuevo: function(component) {
		component.set('v.boolPlantillas', true);
		component.set('v.origenBusqueda', 'destinatarios');
		component.set('v.nuevoDestinatario', true);
		component.set('v.cerrarDestinatarios', false);
	}
});