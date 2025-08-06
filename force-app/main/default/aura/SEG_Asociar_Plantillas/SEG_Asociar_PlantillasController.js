/*eslint-disable camelcase */
({
	init: function(component) {
		let getPlantillas = component.get('c.getPlantillas');
		getPlantillas.setParam('idPlantillaSeg', component.get('v.recordId'));
		getPlantillas.setCallback(this, response => {
			let opcionesPlantillas = [];
			response.getReturnValue().plantillas.forEach(plantilla => {
				opcionesPlantillas.push({
					id: plantilla.Id,
					name: plantilla.DeveloperName,
					label: plantilla.Name,
					folderDevName: plantilla.Folder.DeveloperName
				});
			});

			let opcionesCastellano = opcionesPlantillas.filter(opcion => opcion.folderDevName === 'SEG_Castellano');
			let opcionesCatalan = opcionesPlantillas.filter(opcion => opcion.folderDevName === 'SEG_Catala');
			let opcionesIngles = opcionesPlantillas.filter(opcion => opcion.folderDevName === 'SEG_Ingles');
			let opcionesEuskera = opcionesPlantillas.filter(opcion => opcion.folderDevName === 'SEG_Euskera');
			let opcionesGallego = opcionesPlantillas.filter(opcion => opcion.folderDevName === 'SEG_Gallego');
			component.set('v.opcionesPlantillaCastellano', opcionesCastellano);
			component.set('v.opcionesPlantillaCastellanoFiltro', opcionesCastellano);
			component.set('v.opcionesPlantillaCatalan', opcionesCatalan);
			component.set('v.opcionesPlantillaCatalanFiltro', opcionesCatalan);
			component.set('v.opcionesPlantillaIngles', opcionesIngles);
			component.set('v.opcionesPlantillaInglesFiltro', opcionesIngles);
			component.set('v.opcionesPlantillaEuskera', opcionesEuskera);
			component.set('v.opcionesPlantillaEuskeraFiltro', opcionesEuskera);
			component.set('v.opcionesPlantillaGallego', opcionesGallego);
			component.set('v.opcionesPlantillaGallegoFiltro', opcionesGallego);

			let plantillaSeg = response.getReturnValue().plantillaSeg;
			component.set('v.plantillaCastellano', opcionesCastellano.find(opcion => opcion.id === plantillaSeg.SEG_PlantillaCastellanoID__c));
			component.set('v.plantillaCatalan', opcionesCatalan.find(opcion => opcion.id === plantillaSeg.SEG_PlantillaCatalanID__c));
			component.set('v.plantillaIngles', opcionesIngles.find(opcion => opcion.id === plantillaSeg.SEG_PlantillaInglesID__c));
			component.set('v.plantillaEuskera', opcionesEuskera.find(opcion => opcion.id === plantillaSeg.SEG_PlantillaEuskeraID__c));
			component.set('v.plantillaGallego', opcionesGallego.find(opcion => opcion.id === plantillaSeg.SEG_PlantillaGalegoID__c));
		});
		$A.enqueueAction(getPlantillas);

	},

	seleccionarPlantilla: function(component, event) {
		let idioma = event.currentTarget.dataset.idioma;
		let opcionesIdioma, nombreAtributoOpcionSeleccionadaIdioma;
		if (idioma === 'castellano') {
			opcionesIdioma = component.get('v.opcionesPlantillaCastellanoFiltro');
			nombreAtributoOpcionSeleccionadaIdioma = 'v.plantillaCastellano';
		} else if (idioma === 'catalán') {
			opcionesIdioma = component.get('v.opcionesPlantillaCatalanFiltro');
			nombreAtributoOpcionSeleccionadaIdioma = 'v.plantillaCatalan';
		} else if (idioma === 'inglés') {
			opcionesIdioma = component.get('v.opcionesPlantillaInglesFiltro');
			nombreAtributoOpcionSeleccionadaIdioma = 'v.plantillaIngles';
		} else if (idioma === 'euskera') {
			opcionesIdioma = component.get('v.opcionesPlantillaEuskeraFiltro');
			nombreAtributoOpcionSeleccionadaIdioma = 'v.plantillaEuskera';
		} else if (idioma === 'gallego') {
			opcionesIdioma = component.get('v.opcionesPlantillaGallegoFiltro');
			nombreAtributoOpcionSeleccionadaIdioma = 'v.plantillaGallego';
		}
		component.set(
			nombreAtributoOpcionSeleccionadaIdioma,
			opcionesIdioma.find(opcion => opcion.id === event.currentTarget.dataset.idplantilla)
		);
	},

	deseleccionarPlantilla: function(component, event) {
		let idioma = event.currentTarget.dataset.idioma;
		if (idioma === 'castellano') {
			component.set('v.plantillaCastellano', null);
		} else if (idioma === 'catalán') {
			component.set('v.plantillaCatalan', null);
		} else if (idioma === 'inglés') {
			component.set('v.plantillaIngles', null);
		} else if (idioma === 'euskera') {
			component.set('v.plantillaEuskera', null);
		} else if (idioma === 'gallego') {
			component.set('v.plantillaGallego', null);
		}
	},

	inputFocus: function(component, event) {
		let nombreInput = event.getSource().getLocalId();
		if (nombreInput === 'inputCastellano') {
			let input = component.find('inputCastellano');
			input.setCustomValidity('');
			input.reportValidity();
			component.set('v.mostrarResultadosCastellano', true);
		} else if (nombreInput === 'inputCatalan') {
			let inputCatalan = component.find('inputCatalan');
			inputCatalan.setCustomValidity('');
			inputCatalan.reportValidity();
			component.set('v.mostrarResultadosCatalan', true);
		} else if (nombreInput === 'inputIngles') {
			let inputIngles = component.find('inputIngles');
			inputIngles.setCustomValidity('');
			inputIngles.reportValidity();
			component.set('v.mostrarResultadosIngles', true);
		} else if (nombreInput === 'inputEuskera') {
			let inputEuskera = component.find('inputEuskera');
			inputEuskera.setCustomValidity('');
			inputEuskera.reportValidity();
			component.set('v.mostrarResultadosEuskera', true);
		} else if (nombreInput === 'inputGallego') {
			let inputGallego = component.find('inputGallego');
			inputGallego.setCustomValidity('');
			inputGallego.reportValidity();
			component.set('v.mostrarResultadosGallego', true);
		}
	},

	inputBlur: function(component, event) {
		window.setTimeout($A.getCallback(() => {
			let input = event.getSource().getLocalId();
			if (input === 'inputCastellano') {
				component.set('v.mostrarResultadosCastellano', false);
			} else if (input === 'inputCatalan') {
				component.set('v.mostrarResultadosCatalan', false);
			} else if (input === 'inputIngles') {
				component.set('v.mostrarResultadosIngles', false);
			} else if (input === 'inputEuskera') {
				component.set('v.mostrarResultadosEuskera', false);
			} else if (input === 'inputGallego') {
				component.set('v.mostrarResultadosGallego', false);
			}
		}), 200);
	},

	inputChange: function(component, event) {
		let input = event.getSource().getLocalId();
		let cadenaBusqueda;
		if (input === 'inputCastellano') {
			let opcionesCastellano = component.get('v.opcionesPlantillaCastellano');
			cadenaBusqueda = component.find('inputCastellano').get('v.value');
			if (cadenaBusqueda) {
				component.set('v.opcionesPlantillaCastellanoFiltro', opcionesCastellano.filter(opcion => opcion.label.toLowerCase().includes(cadenaBusqueda)));
			} else {
				component.set('v.opcionesPlantillaCastellanoFiltro', opcionesCastellano);
			}
		} else if (input === 'inputCatalan') {
			let opcionesCatalan = component.get('v.opcionesPlantillaCatalan');
			cadenaBusqueda = component.find('inputCatalan').get('v.value').toLowerCase();
			if (cadenaBusqueda) {
				component.set('v.opcionesPlantillaCatalanFiltro', opcionesCatalan.filter(opcion => opcion.label.toLowerCase().includes(cadenaBusqueda)));
			} else {
				component.set('v.opcionesPlantillaCatalanFiltro', opcionesCatalan);
			}
		} else if (input === 'inputIngles') {
			let opcionesIngles = component.get('v.opcionesPlantillaIngles');
			cadenaBusqueda = component.find('inputIngles').get('v.value').toLowerCase();
			if (cadenaBusqueda) {
				component.set('v.opcionesPlantillaInglesFiltro', opcionesIngles.filter(opcion => opcion.label.toLowerCase().includes(cadenaBusqueda)));
			} else {
				component.set('v.opcionesPlantillaInglesFiltro', opcionesIngles);
			}
		} else if (input === 'inputEuskera') {
			let opcionesEuskera = component.get('v.opcionesPlantillaEuskera');
			cadenaBusqueda = component.find('inputEuskera').get('v.value').toLowerCase();
			if (cadenaBusqueda) {
				component.set('v.opcionesPlantillaEuskeraFiltro', opcionesEuskera.filter(opcion => opcion.label.toLowerCase().includes(cadenaBusqueda)));
			} else {
				component.set('v.opcionesPlantillaEuskeraFiltro', opcionesEuskera);
			}
		} else if (input === 'inputGallego') {
			let opcionesGallego = component.get('v.opcionesPlantillaGallego');
			cadenaBusqueda = component.find('inputGallego').get('v.value').toLowerCase();
			if (cadenaBusqueda) {
				component.set('v.opcionesPlantillaGallegoFiltro', opcionesGallego.filter(opcion => opcion.label.toLowerCase().includes(cadenaBusqueda)));
			} else {
				component.set('v.opcionesPlantillaGallegoFiltro', opcionesGallego);
			}
		}
	},

	asociar: function(component, event, helper) {
		let plantillaCastellano = component.get('v.plantillaCastellano');
		let plantillaCatalan = component.get('v.plantillaCatalan');
		let plantillaIngles = component.get('v.plantillaIngles');
		let plantillaEuskera = component.get('v.plantillaEuskera');
		let plantillaGallego = component.get('v.plantillaGallego');

		let inputCastellano = component.find('inputCastellano');
		let inputCatalan = component.find('inputCatalan');
		let inputIngles = component.find('inputIngles');
		let inputEuskera = component.find('inputEuskera');
		let inputGallego = component.find('inputGallego');

		//Validar que los campos de plantilla están vacíos o con selección
		let valid = true;

		if (!plantillaCastellano && inputCastellano.get('v.value')) {
			inputCastellano.setCustomValidity('Seleccione una plantilla correcta.');
			inputCastellano.reportValidity();
			valid = false;
		}
		if (!plantillaCatalan && inputCatalan.get('v.value')) {
			inputCatalan.setCustomValidity('Seleccione una plantilla correcta.');
			inputCatalan.reportValidity();
			valid = false;
		}
		if (!plantillaIngles && inputIngles.get('v.value')) {
			inputIngles.setCustomValidity('Seleccione una plantilla correcta.');
			inputIngles.reportValidity();
			valid = false;
		}
		if (!plantillaEuskera && inputEuskera.get('v.value')) {
			inputEuskera.setCustomValidity('Seleccione una plantilla correcta.');
			inputEuskera.reportValidity();
			valid = false;
		}
		if (!plantillaGallego && inputGallego.get('v.value')) {
			inputGallego.setCustomValidity('Seleccione una plantilla correcta.');
			inputGallego.reportValidity();
			valid = false;
		}

		if (!valid) {
			return;
		}

		let datosPlantillas = {
			SEG_PlantillaCastellanoID__c: '',
			SEG_PlantillaCastellano__c: '',
			SEG_PlantillaCatalanID__c: '',
			SEG_PlantillaCatalan__c: '',
			SEG_PlantillaInglesID__c: '',
			SEG_PlantillaIngles__c: '',
			SEG_PlantillaEuskeraID__c: '',
			SEG_PlantillaEuskera__c: '',
			SEG_PlantillaGalegoID__c: '',
			SEG_PlantillaGalego__c: ''
		};

		if (plantillaCastellano) {
			datosPlantillas.SEG_PlantillaCastellanoID__c = plantillaCastellano.id;
			datosPlantillas.SEG_PlantillaCastellano__c = plantillaCastellano.label;
		}
		if (plantillaCatalan) {
			datosPlantillas.SEG_PlantillaCatalanID__c = plantillaCatalan.id;
			datosPlantillas.SEG_PlantillaCatalan__c = plantillaCatalan.label;
		}
		if (plantillaIngles) {
			datosPlantillas.SEG_PlantillaInglesID__c = plantillaIngles.id;
			datosPlantillas.SEG_PlantillaIngles__c = plantillaIngles.label;
		}
		if (plantillaEuskera) {
			datosPlantillas.SEG_PlantillaEuskeraID__c = plantillaEuskera.id;
			datosPlantillas.SEG_PlantillaEuskera__c = plantillaEuskera.label;
		}
		if (plantillaGallego) {
			datosPlantillas.SEG_PlantillaGalegoID__c = plantillaGallego.id;
			datosPlantillas.SEG_PlantillaGalego__c = plantillaGallego.label;
		}

		let asociarPlantillas = component.get('c.asociarPlantillas');
		asociarPlantillas.setParams({
			idPlantillaSeg: component.get('v.recordId'),
			datosPlantillas: datosPlantillas
		});
		asociarPlantillas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				$A.get('e.force:closeQuickAction').fire();
				$A.get('e.force:refreshView').fire();
			} else if (response.getState() === 'ERROR') {
				let errors = response.getError();
				helper.mostrarToast('error', 'Error asociando plantillas', errors[0].message);
				console.error(JSON.stringify(errors));
			}
		});
		$A.enqueueAction(asociarPlantillas);
	},

	cancelar: function() {
		$A.get('e.force:closeQuickAction').fire();
	}
});