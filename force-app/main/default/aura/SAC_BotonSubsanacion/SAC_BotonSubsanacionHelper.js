({
	recuperarPlantilla : function(component, event, helper) {
		var spinner = component.find('mySpinner');
        $A.util.removeClass(spinner, "slds-hide");

		var idCase = component.get("v.recordId");
		var idioma = this.idiomaPlantilla(component, event, helper);
		var motivo = component.get("v.motivoSeleccionado");


		var plantillaSubsanacion = component.get('c.getPlantillaSubsanacion');
		plantillaSubsanacion.setParams({'record': idCase,
										'idiomaPlantilla': idioma,
										'motivoSubsanacion': motivo});
		plantillaSubsanacion.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var wrapper = response.getReturnValue();
				component.set('v.idTemplateCliente', wrapper.idTemplate);
				//component.set('v.para', wrapper.paraTemplate);
				component.set('v.asunto', wrapper.subjectTemplate);
				component.set('v.cuerpo', wrapper.htmlValueTemplate);
			}
			else{
				component.set('v.asunto', '');
				component.set('v.cuerpo', '');
			}
			$A.util.addClass(spinner, "slds-hide");

		})
		$A.enqueueAction(plantillaSubsanacion);
	},
	idiomaPlantilla : function(component, event, helper) {
		var caso = component.get('v.caso');
		var idiomaPlantilla;
		switch (caso.CC_Idioma__c) {
			case 'es':
				idiomaPlantilla = 'ES';
				break;
			case 'ca':
				idiomaPlantilla = 'CAT';
				break;
				case 'en':
				idiomaPlantilla = 'ING';
				break;
				case 'eu':
				idiomaPlantilla = 'EUSK';
				break;
				case 'va':
				idiomaPlantilla = 'VAL';
				break;
				case 'ga':
				idiomaPlantilla = 'GAL';
				break;
			default:
				idiomaPlantilla = 'ES';

		}
		return idiomaPlantilla;
	},

	setFicherosBorrados: function(component, event){
		let idCase = component.get("v.recordId");
		let obtieneAdjuntos = component.get('c.obtieneAdjuntos');
		obtieneAdjuntos.setParams({'id': idCase});
		obtieneAdjuntos.setCallback(this, function(response) {
			let state = response.getState();
			if (state === "SUCCESS") {
				let ficherosBorrados = [];
				let adjuntos = response.getReturnValue();
				//Los archivos no deberian cargarse en la subsanación
				for(let i = 0; i < adjuntos.length; i++){
					ficherosBorrados.push(adjuntos[i].Id);
				}
				component.set('v.ficherosBorrados', ficherosBorrados);
			}
			else{
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": 'Se ha producido un error',
					"message": 'Se ha producido un error al abrir el componente de subsanación.',
					"type":'error'
				});
				toastEvent.fire();
			}
		})
		$A.enqueueAction(obtieneAdjuntos);
	}

})