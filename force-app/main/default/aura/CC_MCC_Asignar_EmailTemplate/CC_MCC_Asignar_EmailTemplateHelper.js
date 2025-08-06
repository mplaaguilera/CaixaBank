({
	loadCarpetasOperativa: function(component) {
		let getNegocio = component.get('c.getNegocio');
		getNegocio.setParam('recordId', component.get('v.recordId'));
		getNegocio.setCallback(this, responseGetNegocio => {
			if (responseGetNegocio.getState() === 'SUCCESS') {
				let opcionesOperativaFolder = [];
                let getCarpetas = component.get('c.getCarpetas');
                let negocio = responseGetNegocio.getReturnValue();
                let carpetaDeveloperName = '';
                if (negocio == 'OS')
                {
                    carpetaDeveloperName = 'OS_Operativas';
                }else if (negocio == 'HDT')
                {
                    carpetaDeveloperName = 'HDT_Operativas';
                }
                else if (negocio == 'CSI_Bankia')
                {
                    carpetaDeveloperName = 'CC_Operativas_CSI_Bankia';
                }
				else if (negocio == 'AM')
                {
                    carpetaDeveloperName = 'AM_Operativas';
                }
                
				getCarpetas.setParam('carpetaDeveloperName', carpetaDeveloperName);
				getCarpetas.setCallback(this, responseGetCarpetas => {
					if (responseGetCarpetas.getState() === 'SUCCESS') {
						let arr = responseGetCarpetas.getReturnValue() ;
						arr.forEach(element => {
							opcionesOperativaFolder.push({value: element.DeveloperName, label: element.Name});
						});
    console.log('opcionesOperativaFolder: '+opcionesOperativaFolder);
						component.set('v.opcionesOperativaFolder', opcionesOperativaFolder);
						component.set('v.carpetaOperativaSeleccionada', false);
						component.set('v.carpetaOperativa', '');
						component.set('v.carpetaIdiomaSeleccionada', false);
						component.set('v.carpetaIdioma', '');
						component.set('v.procesoFinalSeleccion', false);
						component.set('v.carpetaFinal', '');
						component.set('v.plantillaSeleccionada', false);
					}
				});
				$A.enqueueAction(getCarpetas);
			}
		});
		$A.enqueueAction(getNegocio);
	},

	loadCarpetasIdioma: function(component, event, helper) {
		let opcionesIdiomaFolder = [
		];
		let carpetaOperativa = component.get('v.carpetaOperativa');
		let action = component.get('c.getCarpetas');
		action.setParams({
			'carpetaDeveloperName': carpetaOperativa
		});
		action.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				let arr = response.getReturnValue() ;
				arr.forEach(element => {
					opcionesIdiomaFolder.push({value: element.DeveloperName, label: element.Name});
				});
				component.set('v.opcionesIdiomaFolder', opcionesIdiomaFolder);
				component.set('v.carpetaIdiomaSeleccionada', false);
				component.set('v.carpetaIdioma', '');
				component.set('v.procesoFinalSeleccion', false);
				component.set('v.carpetaFinal', '');
				component.set('v.plantillaSeleccionada', false);
			}
			if (opcionesIdiomaFolder.length == 0) {
				component.set('v.procesoFinalSeleccion', true);
				component.set('v.carpetaFinal', carpetaOperativa);
				helper.loadPlantillas(component, event, helper);
			} else {
				component.set('v.carpetaOperativaSeleccionada', true);
			}
		});
		$A.enqueueAction(action);
	},
	loadCarpetasTratamiento: function(component, event, helper) {
		let opcionesTratamientoFolder = [
		];
		let carpetaIdioma = component.get('v.carpetaIdioma');
		let action = component.get('c.getCarpetas');
		action.setParams({
			'carpetaDeveloperName': carpetaIdioma
		});
		action.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				let arr = response.getReturnValue() ;
				arr.forEach(element => {
					opcionesTratamientoFolder.push({value: element.DeveloperName, label: element.Name});
				});
				component.set('v.opcionesTratamientoFolder', opcionesTratamientoFolder);
				component.set('v.carpetaIdiomaSeleccionada', false);
				component.set('v.procesoFinalSeleccion', false);
				component.set('v.carpetaFinal', '');
				component.set('v.plantillaSeleccionada', false);
			}
			if (opcionesTratamientoFolder.length == 0) {
				component.set('v.procesoFinalSeleccion', true);
				component.set('v.carpetaFinal', carpetaIdioma);
				helper.loadPlantillas(component, event, helper);
			} else {
				component.set('v.carpetaIdiomaSeleccionada', true);
			}
		});
		$A.enqueueAction(action);
	},

	loadPlantillas: function(component, event, helper) {
		let mccId = component.get('v.recordId');
		let carpetaFinal = component.get('v.carpetaFinal');
		let opcionesPlantilla = [
		];

		let carpetaOperativa = component.get('v.carpetaOperativa');
		if (carpetaOperativa != carpetaFinal && carpetaOperativa != '') {
			var action = component.get('c.getPlantillas');
			action.setParams({
				'mccId': mccId,
				'carpeta': carpetaOperativa
			});
			action.setCallback(this, response => {
				let state = response.getState();
				if (state === 'SUCCESS') {
					let arr = response.getReturnValue() ;
					arr.forEach(element => {
						opcionesPlantilla.push({value: element.DeveloperName, label: element.Name});
					});
				}
			});
			$A.enqueueAction(action);
		}

		let carpetaIdioma = component.get('v.carpetaIdioma');
		if (carpetaIdioma != carpetaFinal && carpetaIdioma != '') {
			var action = component.get('c.getPlantillas');
			action.setParams({
				'mccId': mccId,
				'carpeta': carpetaIdioma
			});
			action.setCallback(this, response => {
				let state = response.getState();
				if (state === 'SUCCESS') {
					let arr = response.getReturnValue() ;
					arr.forEach(element => {
						opcionesPlantilla.push({value: element.DeveloperName, label: element.Name});
					});
				}
			});
			$A.enqueueAction(action);
		}

		var action = component.get('c.getPlantillas');
		action.setParams({
			'mccId': mccId,
			'carpeta': carpetaFinal
		});
		action.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				let arr = response.getReturnValue() ;
				arr.forEach(element => {
					opcionesPlantilla.push({value: element.DeveloperName, label: element.Name});
				});
				component.set('v.opcionesPlantilla', opcionesPlantilla);
			}
		});
		$A.enqueueAction(action);
	},
	showToast: function(component, event, helper) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
			mode: 'dismissible',
			message: 'Se ha asignado la plantilla.',
			type: 'success'
		});
		toastEvent.fire();
	}
});