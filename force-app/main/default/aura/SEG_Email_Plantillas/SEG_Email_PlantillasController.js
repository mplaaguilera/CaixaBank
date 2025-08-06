({
	init: function(component) {
		let getUser = component.get('c.recuperarUser');
		getUser.setCallback(this, response => {
			component.set('v.user', response.getReturnValue());
			component.set('v.esPropietario', component.get('v.user') === component.get('v.caso.OwnerId'));
		});
		$A.enqueueAction(getUser);

		if (component.get('v.selectedIdioma')) {
			$A.enqueueAction(component.get('c.mostrarPlantillasIdioma'));
		}

		if (component.get('v.cntId')) {
			let getNombreEmailContacto = component.get('c.getNombreEmailContacto');
			getNombreEmailContacto.setParam('idContacto', component.get('v.cntId'));
			getNombreEmailContacto.setCallback(this, response => {
				let state = response.getState();
				if (state === 'SUCCESS') {
					component.set('v.contactPrincipal', response.getReturnValue());
				} else if (state === 'ERROR') {
					console.error(JSON.stringify(response.getError()));
				}
			});
			$A.enqueueAction(getNombreEmailContacto);
		}
	},

	cargarPlantillas: function(component, event, helper) {
		let devolverPlantillas = component.get('c.recuperarPlantillas');
		devolverPlantillas.setParam('caseId', component.get('v.caseId'));
		devolverPlantillas.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				let values = [];
				let result = response.getReturnValue();
				for (let key in result) {
					if (Object.prototype.hasOwnProperty.call(result, key)) {
						values.push({label: result[key], value: key});
					}
				}
				if (values[0] != null) {
					component.set('v.plantillas', values);
				}
			} else if (state === 'ERROR') {
				let errors = response.getError();
				helper.mostrarToast('error', 'No se han podido recuperar las plantillas', errors[0].message);
				console.error(JSON.stringify(errors));
			}
		});
		$A.enqueueAction(devolverPlantillas);
	},

	abrirModalResp: function(component) {
		component.set('v.modalResp', true);
	},

	buscarPlantilla: function(component) {
		let idioma = component.get('v.selectedIdioma');
		let idCase = component.get('v.caseId');
		let searchKey = component.find('buscarKeyPlantilla').get('v.value');
		if (searchKey == null) {
			component.set('v.mostrarPlantillas', false);
		}
		let action = component.get('c.buscadorPlantilla');
		action.setParams({'searchKey': searchKey, 'idCase': idCase, 'idioma': idioma});
		action.setCallback(this, response => {
			let values = [];
			let result = response.getReturnValue();
			for (let key in result) {
				if (Object.prototype.hasOwnProperty.call(result, key)) {
					values.push({label: result[key].Name, value: key});
				}
			}

			if (values[0] != null) {
				component.set('v.mostrarPlantillas', true);
				component.set('v.plantillasOrg', values);
			} else {
				component.set('v.mostrarPlantillas', false);
			}
		});
		$A.enqueueAction(action);
	},

	plantillaLista: function(component) {
		component.set('v.nombrePlantilla', null);
	},

	mostrarPlantillasIdioma: function(component, event, helper) {
		component.set('v.plantillaId', null);
		component.set('v.idiomaPlanId', component.get('v.selectedIdioma'));
		component.set('v.plantillas', null);

		let contid = component.get('v.cntId');
		//JAV START
		//Seleccionamos el id o del contacto al que vamos a responder o remitir o del contacto que hemos seleccionado
		let contactcurid = component.get('v.datosContact.Id');
		let contactIdcurrent = '';
		if (contid) {
			contactIdcurrent = contid;
		} else if (!contid && contactcurid) {
			contactIdcurrent = contactcurid;
		}
		//JAV END
		let contacto = component.get('c.getDatosDestinatarioNuevo');

		contacto.setParam('recordId', contid);
		contacto.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let values = [];
				let result = response.getReturnValue();
				for (let key in result) {
					if (Object.prototype.hasOwnProperty.call(result, key)) {
						values.push({label: result[key], value: key});
						component.set('v.contactParaEmail', result[key]);
					}
				}
				component.set('v.contactPara', values);
				let cmpEvent = component.getEvent('cargarLista');
				cmpEvent.setParams({'lstContactNuevo': values});
				cmpEvent.fire();
			}
		});
		$A.enqueueAction(contacto);

		let plantillasContact = component.get('c.getPlantillas');
		plantillasContact.setParams({
			contactId: contactIdcurrent,
			idioma: component.get('v.selectedIdioma'),
			caseId: component.get('v.caseId')
		});
		plantillasContact.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				let values = [];
				let result = response.getReturnValue();
				for (let key in result) {
					if (Object.prototype.hasOwnProperty.call(result, key)) {
						values.push({label: result[key].Name, value: key});
					}
				}
				if (values[0] != null) {
					component.set('v.plantillas', values);
				}
			} else if (state === 'ERROR') {
				let errors = response.getError();
				helper.mostrarToast('error', 'No se han podido recuperar las plantillas', errors[0].message);
				console.error(JSON.stringify(errors));
			}
		});
		$A.enqueueAction(plantillasContact);
	},

	seleccionarPlantilla: function(component, event) {

		//Get nombre plantilla
		let nombrePlantilla = event.currentTarget.name;
		let plantillaIdOrg = event.currentTarget.id;

		component.set('v.mostrarPlantillas', false);

		//Seleccionar plantilla Org y vaciar la del caso
		component.set('v.nombrePlantilla', nombrePlantilla);
		component.set('v.plantillaIdOrg', plantillaIdOrg);
		component.set('v.plantillaId', null);
	}

	/*inputBlur: function(component, event) {
		window.setTimeout($A.getCallback(() => {
			component.set('v.mostrarPlantillas', false);			
		}), 200);
	}*/
});