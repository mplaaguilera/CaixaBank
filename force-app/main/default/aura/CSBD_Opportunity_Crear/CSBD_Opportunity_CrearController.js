({
	doInit: function(component, event, helper) {
		window.setTimeout($A.getCallback(() => {
			let getRecordTypesCSBD = component.get('c.getRecordTypesCSBD');
			getRecordTypesCSBD.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					const recordTypes = response.getReturnValue();
					component.set('v.opcionesRecordType', recordTypes);
					for (let i = 0; i < recordTypes.length; i++) {
						if (recordTypes[i].label === 'Hipoteca') {
							component.set('v.recordTypeIdForHipoteca', recordTypes[i].value);
							break;
						}
					}
				} else if (response.getState() === 'ERROR') {
					console.error(response.getError()[0].message);
					helper.mostrarToast('error', 'Se ha encontrado un problema', response.getError()[0].message);
				}
			});
			$A.enqueueAction(getRecordTypesCSBD);

			const viewportHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
			if (viewportHeight > 844) {
				$A.util.addClass(component.find('divCampos'), 'dropdownMuyAlto');
			} else if (viewportHeight > 778) {
				$A.util.addClass(component.find('divCampos'), 'dropdownAlto');
			}
		}), 700);
	},

	seleccionarOpcionRecordType: function(component, event, helper) {
		//El valor por defecto de la fecha de cierre es la actual más los días parametrizados para
		//el record type seleccionado (el valor debe  unsera cadena con el formato "2018-01-06T00:00")
		let diasFechaCierre = component.get('c.diasFechaCierre');
		//diasFechaCierre.setParam('recordTypeName', component.get('v.recordTypeId'));
		diasFechaCierre.setParam('recordTypeName', component.get('v.opcionesRecordType').find(rt => rt.value === event.getParam('value')).label);
		diasFechaCierre.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let fechaCierre = new Date();
				fechaCierre.setDate(fechaCierre.getDate() + response.getReturnValue()); //Suma el número de días recuperados
				component.set('v.fechaCierreInicial', fechaCierre.toISOString().split('.')[0]);
				component.find('botonEnviar').focus();
			} else if (response.getState() === 'ERROR') {
				console.error(response.getError()[0].message);
				helper.mostrarToast('error', 'Se ha encontrado un problema', response.getError()[0].message);
			}
		});
		$A.enqueueAction(diasFechaCierre);
	},

	enviar: function(component) {
		component.set('v.creando', true);
		component.find('formulario').submit();
	},

	success: function(component, event, helper) {
		const idOportunidad = event.getParams().response.id;
		helper.abrirTab(component, idOportunidad);

		helper.mostrarToast('success', 'Se creó Oportunidad', 'Se creó correctamente Oportunidad');

		helper.minimizarPanel(component);
		component.find('comboboxRecordTypes').set('v.value', null);
		component.set('v.creando', false);

		component.find('inputName').set('v.value', 'temp');
		component.find('inputEtapa').set('v.value', 'Solicitud');
		const inputNoIdentificado = component.find('inputNoIdentificado');
		if (inputNoIdentificado) {
			inputNoIdentificado.set('v.value', true);
		}
		component.find('inputTitulo').set('v.value', null);
		component.find('inputDescripcion').set('v.value', null);

		let oportunidadesHijas = component.get('c.altaOportunidadesHijas');
		oportunidadesHijas.setParam('idOportunidad', idOportunidad);
		$A.enqueueAction(oportunidadesHijas);

		let crearActividad = component.get('c.crearActividad');
		crearActividad.setParam('idOportunidad', idOportunidad);
		$A.enqueueAction(crearActividad);
	},

	error: function(component, event, helper) {
		//Error en la creación
		console.error(JSON.stringify(event, null, 3));
		helper.mostrarToast('error', 'No se pudo crear Oportunidad', JSON.stringify(event, null, 3));
		component.set('v.creando', false);
	},

	cerrarPanel: function(component, event, helper) {
		//Cerrar la pestaña
		helper.minimizarPanel(component, event);
	}
});