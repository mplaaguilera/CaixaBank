({
    init : function(component, event, helper) {
		var recuperarRaiz = component.get("c.getRaiz");
		recuperarRaiz.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") { 
				component.set('v.idRaiz', response.getReturnValue());
			}
		});
		$A.enqueueAction(recuperarRaiz);
	},

	abrirModalPlantillas : function(component, event, helper){
		component.set('v.isLoading', true);
		component.set('v.modalPlantillas', true);
		var recuperarTemplates = component.get("c.recuperarPlantillas");
		recuperarTemplates.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") { 
				let plantillas = JSON.parse(response.getReturnValue());
				let items = [plantillas];
				component.set('v.items', items);

				component.set('v.isLoading', false);
			}
		});
		$A.enqueueAction(recuperarTemplates);
	},

	cerrarModalPlantillas : function(component, event, helper){
		component.set('v.modalPlantillas', false);
		component.set('v.puedeVolver', true);
		component.set('v.noEsPlantilla', true);
		component.set('v.ruta', []);
	},

	selectorArbol : function(component, event, helper){
		component.set('v.isLoading', true);
		component.set('v.valuePlantilla', event.getSource().get("v.name"));
		let nombrePadre = '';
		let idDelPadreController = event.getSource().get("v.name");
		let idDelPadre = idDelPadreController;
		let idPlantilla = component.get('v.valuePlantilla');
		if(idPlantilla.substring(0, 3) == '00l'){
			let idRaiz = component.get('v.idRaiz');
			component.set('v.noEsPlantilla', true);
			component.set('v.idPadre', event.getSource().get("v.name"));
			if(event.getSource().get("v.name") != idRaiz){
				component.set('v.puedeVolver', false);
			}
			else{
				component.set('v.puedeVolver', true);
			}
			var cambioCarpeta = component.get("c.cambioCarpeta");
			cambioCarpeta.setParams({'idPadre': idPlantilla});
			cambioCarpeta.setCallback(this, function(response){
				var state = response.getState();
				if (state === "SUCCESS") {
					let plantillas = JSON.parse(response.getReturnValue());
					for(var miPlantilla in plantillas) {
						let plantilla = plantillas[miPlantilla];
						nombrePadre = plantilla.labelParent;
						idDelPadre = plantilla.idParent;
					}

					let ruta = component.get('v.ruta');
					let copyOfRuta = ruta;
					ruta = [];
					let comparador = true;
					for(var nodo in copyOfRuta) {
						let elemento = copyOfRuta[nodo];
						if(comparador){
							ruta.push({ label: elemento.label, value: elemento.value });
						}
						else{ break; }

						if(elemento.value == idDelPadre){
							comparador = false;
						}
						
					}
					component.set('v.items', plantillas);
					component.set('v.ruta', JSON.parse(JSON.stringify(ruta)));
					component.set('v.isLoading', false);
				}
			});
			$A.enqueueAction(cambioCarpeta);
		}
		else{
			component.set('v.isLoading', false);
			component.set('v.noEsPlantilla', false);
		}
	},

	volverAtras : function(component, event, helper){
		component.set('v.isLoading', true);
		let idPadre = component.get('v.idPadre');
		let idRaiz = component.get('v.idRaiz');
		component.set('v.noEsPlantilla', true);
		if(idRaiz != idPadre){
			var vueltaAtras = component.get("c.volverHaciaArriba");
			vueltaAtras.setParams({'idPadre': idPadre});
			vueltaAtras.setCallback(this, function(response){
				var state = response.getState();
				if (state === "SUCCESS") {
					let plantillas = JSON.parse(response.getReturnValue());
					for(var miPlantilla in plantillas) {
						let plantilla = plantillas[miPlantilla];
						idPadre = plantilla.idParent;
					}            
					let ruta = component.get('v.ruta');
					let variableDesechable = ruta.pop();
					component.set('v.ruta', ruta);
					//let ultimaPosicion = ruta.length -1;

					component.set('v.idPadre', idPadre);
					component.set('v.items', plantillas);
					component.set('v.isLoading', false);
					if(idRaiz == idPadre){
						component.set('v.puedeVolver', true);
					}
				}
			});
			$A.enqueueAction(vueltaAtras);
		}
		else{
			component.set('v.puedeVolver', true);
			component.set('v.isLoading', false);
		}
	},

	handleSelect: function (component, event) {
		component.set('v.isLoading', true);
		component.set('v.valuePlantilla', event.getSource().get("v.name"));
		let nombrePadre = '';
		let idDelPadre = event.getSource().get("v.name");

		let idPlantilla = component.get('v.valuePlantilla');
		if(idPlantilla.substring(0, 3) == '00l'){
			let ruta = component.get('v.ruta');
			let idRaiz = component.get('v.idRaiz');
			component.set('v.noEsPlantilla', true);
			component.set('v.idPadre', event.getSource().get("v.name"));
			if(event.getSource().get("v.name") != idRaiz){
				component.set('v.puedeVolver', false);
			}
			else{
				component.set('v.puedeVolver', true);
			}
			var cambioCarpeta = component.get("c.cambioCarpeta");
			cambioCarpeta.setParams({'idPadre': idPlantilla});
			cambioCarpeta.setCallback(this, function(response){
				var state = response.getState();
				if (state === "SUCCESS") {
					let plantillas = JSON.parse(response.getReturnValue());
					for(var miPlantilla in plantillas) {
						let plantilla = plantillas[miPlantilla];
						nombrePadre = plantilla.labelParent;
						idDelPadre = plantilla.idParent;
					}
					ruta.push({ label: nombrePadre, value: idDelPadre });
					component.set('v.ruta', JSON.parse(JSON.stringify(ruta)));
					component.set('v.items', plantillas);

					component.set('v.isLoading', false);
				}
			});
			$A.enqueueAction(cambioCarpeta);
		}
		else{
			component.set('v.isLoading', false);
			component.set('v.noEsPlantilla', false);
		}
    },

	aplicarCambio : function(component, event, helper){
		component.set('v.isLoading', true);
		let idPlantilla = component.get('v.valuePlantilla');
		if(idPlantilla.substring(0, 3) != '00X'){
			let toastParams = {
				title: "Elemento seleccionado invalido",
				message: 'Seleccione una plantilla, y no una carpeta.', 
				type: "error"
			};
			toastEvent.setParams(toastParams);
			toastEvent.fire();
		}
		else{
			let record = component.get('v.recordId');
			let recordAux = component.get('v.recordIdAux');
			var obtenerCuerpo = component.get('c.obtenerTemplateBody');
			obtenerCuerpo.setParams({'idTemplate': idPlantilla, 'idObject': record,  'idObjectAux': recordAux});
			obtenerCuerpo.setCallback(this, function(response){

				if(response.getState() === "SUCCESS"){
					var contenidoPlantilla = response.getReturnValue();
					component.set('v.cuerpoPlantilla', contenidoPlantilla);

					var obtenerSubject = component.get('c.obtenerTemplateSubject');
					obtenerSubject.setParams({'idTemplate': idPlantilla, 'idObject': record,  'idObjectAux': recordAux});
					obtenerSubject.setCallback(this, function(response){
						if(response.getState() === "SUCCESS"){
							var contenidoSubject = response.getReturnValue();
							component.set('v.subjectPlantilla', contenidoSubject);

							let toastParams = {
								title: "Cambio aplicado",
								message: 'Se ha sustituido el cuerpo del email con el valor de la plantilla.', 
								type: "success"
							};
							let toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams(toastParams);
							component.set('v.modalPlantillas', false);
							component.set('v.isLoading', false);
							let rutaDesdeCero = [];
							component.set('v.ruta', rutaDesdeCero);
							toastEvent.fire();
						}else{
							component.set('v.isLoading', false);
							let errors = response.getError();
							let toastParams = {
								title: "Error",
								message: errors[0].message, 
								type: "error"
							};
							let toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams(toastParams);
							toastEvent.fire();
						}
					});
					$A.enqueueAction(obtenerSubject);
				}
				else{
					component.set('v.isLoading', false);
					let errors = response.getError();
					let toastParams = {
						title: "Error",
						message: errors[0].message, 
						type: "error"
					};
					let toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams(toastParams);
					toastEvent.fire();
				}
			});
			$A.enqueueAction(obtenerCuerpo);
		}	
	}
})