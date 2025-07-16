({
	getGruposBusqueda: function(component) {
		let buscarGruposColaboradores = component.get('c.buscarGruposColaboradores');
		buscarGruposColaboradores.setParam('cadenaBusqueda', component.get('v.literalBusquedaGrupo'));
		buscarGruposColaboradores.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.listOfSearchRecords', response.getReturnValue());
			}
		});
		$A.enqueueAction(buscarGruposColaboradores);
	},

	//MLA: con este método obtenemos el subject y el cuerpo de la plantilla del caso
	getPlantillaCaso: function(component){
		let idPlantillaSeleccionada;
		if(component.get('v.tipoOperativa') === 'responderCliente'){
			if (component.get('v.verTodasLasPlantillas')) {
				idPlantillaSeleccionada = component.get('v.plantillaSeleccionadaColab.Id');
			} else {
				idPlantillaSeleccionada = component.get('v.plantillaSeleccionadaValue');
			}
		} 
		if (component.get('v.tipoOperativa') === 'solicitar'){
			idPlantillaSeleccionada = component.get('v.plantillaSeleccionadaValue');
		} 
		if(component.get('v.tipoOperativa') === 'trasladar'){
			if (component.get('v.verTodasLasPlantillas')) {
				idPlantillaSeleccionada = component.get('v.plantillaSeleccionadaColab.Id');
			} else {
				idPlantillaSeleccionada = component.get('v.plantillasGrupoValue');
			}
		}
		let plantillaCaso = component.get('c.plantillaCaso');
		plantillaCaso.setParam('plantillaId', idPlantillaSeleccionada);
		plantillaCaso.setCallback(this, response =>{
			if (response.getState() === 'SUCCESS') {
				let registro = response.getReturnValue();
				component.set('v.subjectPlantilla', registro.Subject);
				component.set('v.cuerpoPlantilla', registro.HtmlValue);
			}
		});
		$A.enqueueAction(plantillaCaso);

	},
		
	loadCarpetasIdioma: function(component) {
		let operativa = component.get('v.tipoOperativa');
		let idioma = component.get('v.caso.CC_Idioma__c');
		let carpetaOperativa;
		if (operativa === 'responderCliente') {
			carpetaOperativa = 'AM_Responder';
		} else if (operativa === 'solicitar') {
			carpetaOperativa = 'AM_Solicitar';
		}

		let getCarpetasIdioma = component.get('c.getCarpetas');
		getCarpetasIdioma.setParam('carpetaDeveloperName', carpetaOperativa);
		getCarpetasIdioma.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let opcionesIdiomaFolder = [];
				let opciones = response.getReturnValue();
				opciones.forEach(opcion => opcionesIdiomaFolder.push({'value': opcion.DeveloperName, 'label': opcion.Name}));
				component.set('v.opcionesIdiomaCarpeta', opcionesIdiomaFolder);
				if (operativa === 'responderCliente') {
					component.set('v.idiomaPlantilla', 'AM_Responder_' + idioma);
				} else if (operativa === 'solicitar') {
					component.set('v.idiomaPlantilla', 'AM_Solicitar_' + idioma);
				}
				$A.enqueueAction(component.get('c.handleCarpetaIdiomaSeleccionada'));
			}
		});
		$A.enqueueAction(getCarpetasIdioma);
	},

	loadCarpetasTratamiento: function(component) {
		let opcionesTratamientoFolder = [];
		let getCarpetasTratamiento = component.get('c.getCarpetas');
		getCarpetasTratamiento.setParam('carpetaDeveloperName', component.get('v.idiomaPlantilla'));
		getCarpetasTratamiento.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let arr = response.getReturnValue();
				arr.forEach(element => opcionesTratamientoFolder.push({'value': element.DeveloperName, 'label': element.Name}));
				component.set('v.opcionesTratamientoCarpeta', opcionesTratamientoFolder);
				if (opcionesTratamientoFolder.length === 1) {
					//Se selecciona automáticamente el único tratamiento disponible para el idioma seleccionado
					if (component.get('v.tipoOperativa') === 'solicitar') {
						component.find('selectItemTratamientoSol').set('v.value', opcionesTratamientoFolder[0].value);
					} else if (component.get('v.tipoOperativa') === 'responderCliente') {
						component.find('selectItemTratamiento').set('v.value', opcionesTratamientoFolder[0].value);
					}
					$A.enqueueAction(component.get('c.handleCarpetaTratamientoSeleccionada'));
				} else {
					//Se pone en el foco en el campo de tratamiento del modal correspondiente
					if (component.get('v.tipoOperativa') === 'solicitar') {
						window.setTimeout($A.getCallback(() => component.find('selectItemTratamientoSol').focus()), 20);
					} else {
						window.setTimeout($A.getCallback(() => component.find('selectItemTratamiento').focus()), 20);
					}
				}
			}
		});
		$A.enqueueAction(getCarpetasTratamiento);
	},

	buscarPlantillas: function(component) {
		let getPlantillas = component.get('c.buscarPlantillas');
		getPlantillas.setParam('cadenaBusqueda', component.get('v.literalBusquedaPlantilla'));
		getPlantillas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.listOfSearchRecordsPlantilla', response.getReturnValue());
			}
		});
		$A.enqueueAction(getPlantillas);
	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissable', 'duration': 4000});
		toastEvent.fire();
	}

});