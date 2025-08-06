({
	init : function(component, event, helper) {

		var userId = $A.get("$SObjectType.CurrentUser.Id");

		var getCaso = component.get('c.initInsertarPretension');
        getCaso.setParam('caseId', component.get('v.recordId'));
        getCaso.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
				
                component.set('v.caso', response.getReturnValue().caso);

				if(response.getReturnValue().esPropietario){

					component.set('v.tienePermisosEditar', response.getReturnValue().esPropietario);

				}else if(component.get('v.caso.OwnerId') == userId){

					component.set('v.tienePermisosEditar', true);
				}
			}
		});

		$A.enqueueAction(getCaso);

		var tienePermisos = component.get('c.tienePermisosReclamacionCerrada');
        tienePermisos.setParam('idCaso', component.get('v.recordId'));
		tienePermisos.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
				if(response.getReturnValue()){
					component.set('v.tienePermisosEditarReclamacionCerrada', response.getReturnValue());
				}
			}
		});

		$A.enqueueAction(tienePermisos);
	},

	abrirModalPretensiones : function(component, event, helper){

		component.set('v.modalPretensiones', true);
	},

	cerrarModalPretensiones : function(component, event, helper){

		component.set("v.listMCC", []);

		component.set('v.modalPretensiones', false);
	},

	eliminarRegistro : function(component, event, helper){

        var listMCCs = component.get("v.listMCC");

        var selectedItem = event.currentTarget;

        var index = selectedItem.dataset.record;

        listMCCs.splice(index, 1);

        component.set("v.listMCC", listMCCs)

	},

	cerrarModalReemplazarPretension : function(component, event, helper){

		component.set('v.modalReemplazarPrincipal', false);

	},

	generarPretensiones : function(component, event, helper){

		let botonReemplazo = event.getSource().get("v.title");
		let listaMCCs = component.get('v.listMCC');
	
		/*Controlamos las checkbox, si hay alguna seleccionada y cuántas son*/
		const checkboxes = document.querySelectorAll('table input[type="checkbox"][id="miElementoCheckbox"]');
		let contador = 0;
		let isChecked = false;
		checkboxes.forEach(checkbox=> {
			if(checkbox.checked){
				contador++;
				isChecked = true;
			}
		});

		if(listaMCCs == ''){

			let toastEvent = $A.get('e.force:showToast');
				toastEvent.setParams({
					'type': 'warning',
					'title': 'MCC no seleccionado',
					'message': 'Debes seleccionar al menos un MCC para poder crear pretensiones.'
				});
				toastEvent.fire();

		}else if(contador>1){
			
			let toastEvent = $A.get('e.force:showToast');
			toastEvent.setParams({
				'type': 'warning',
				'title': 'Pretensión principal',
				'message': 'Debes seleccionar solamente una pretensión principal.'
			});
			toastEvent.fire();
		
		}else if(isChecked && component.get('v.caso.SAC_PretensionPrincipal__c') != null && botonReemplazo !== 'botonReemplazar'){

			component.set('v.modalReemplazarPrincipal', true);
			/*let toastEvent = $A.get('e.force:showToast');
			toastEvent.setParams({
				'type': 'warning',
				'title': 'Existe pretensión principal',
				'message': 'Esta reclamación ya tiene una pretensión principal.'
			});
			toastEvent.fire();*/
	
		}else{
			component.set('v.isLoading', true);
			component.set('v.modalPretensiones', false);
			component.set('v.modalReemplazarPrincipal', false);
			let mccSelecPrin = [];
			let restoMCCs = [];
			/*Recuperamos el mcc seleccionado como principal*/
			checkboxes.forEach(function(checkbox){
				if(checkbox.checked){
					let index = checkbox.getAttribute("data-index");
					let mccPrin = listaMCCs[index];
		
					if (mccPrin){
						mccSelecPrin.push(mccPrin);
					}

					/*Asignamos la pretension principal a la reclamacion*/
					let asignarPretPrin = component.get('c.insertarPretensionPrincipal');
					asignarPretPrin.setParams({'idCase': component.get('v.recordId'), 'mccsPretension': mccSelecPrin});
					asignarPretPrin.setCallback(this, function(response) {
						var stateAsigPrin = response.getState();

						if(stateAsigPrin === "SUCCESS"){
							mccSelecPrin = [];

							let toastEvent = $A.get('e.force:showToast');
							toastEvent.setParams({
								'type': 'success',
								'title': 'Pretensión principal asignada',
								'message': 'Se ha asignado la pretensión principal correctamente.'
							});
							toastEvent.fire();
							
						}else if (stateAsigPrin === "ERROR") {
							component.set('v.isLoading', false);
							var errorAsignPrin = response.getError();
							if (errorAsignPrin) {
								if (errorAsignPrin[0] && errorAsignPrin[0].message) {

									let toastEvent = $A.get('e.force:showToast');
										toastEvent.setParams({
										'type': 'error',
										'title': 'Pretension principal no asignada',
										'message': errorAsignPrin[0].message
									});
									toastEvent.fire();
								}
							} else {

								let toastEvent = $A.get('e.force:showToast');
									toastEvent.setParams({
									'type': 'error',
									'title': 'Pretension principal no asignada',
									'message': 'No se ha asignado la pretension principal a la reclamación debido a un error.'
								});
								toastEvent.fire();
							}
						}
					});
					$A.enqueueAction(asignarPretPrin);

				/*Recogemos el resto de MCCs*/
				} else {
					let index = checkbox.getAttribute("data-index");
					restoMCCs.push(listaMCCs[index]);
				}
			});
			/*Insertamos las pretensiones no seleccionadas*/
			let insertarPretensiones = component.get('c.insertarPretensiones');
			insertarPretensiones.setParams({'idCase': component.get('v.recordId'), 'mccsPretension': restoMCCs/*component.get('v.listMCC')*/});
			insertarPretensiones.setCallback(this, function(response) {
				var state = response.getState();

				if (state === "SUCCESS") {

					component.set('v.isLoading', false);
					
					let toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						'type': 'success',
						'title': 'Pretensiones creadas',
						'message': 'Se ha creado ' + listaMCCs.length + ' pretensiones correctamente.'
					});
					toastEvent.fire();

					component.set("v.listMCC", []);
					$A.get('e.force:refreshView').fire();

				}else if (state === "ERROR") {

					component.set('v.isLoading', false);
					var errors = response.getError();
					if (errors) {
						if (errors[0] && errors[0].message) {

							let toastEvent = $A.get('e.force:showToast');
								toastEvent.setParams({
								'type': 'error',
								'title': 'Pretensiones no creadas',
								'message': errors[0].message
							});
							toastEvent.fire();
						}
					} else {

						let toastEvent = $A.get('e.force:showToast');
							toastEvent.setParams({
							'type': 'error',
							'title': 'Pretensiones no creadas',
							'message': 'No se han creado las pretensiones debido a un error.'
						});
						toastEvent.fire();
					}
				}
			});
			$A.enqueueAction(insertarPretensiones);	
		}
	},

	receiveLWCData: function (component, event, helper) {
		let nuevoMCC = event.getParam("dataToSend");
		let listaActualMCC = component.get('v.listMCC');
	
		let listaMCC = [...listaActualMCC, ...nuevoMCC];
		component.set("v.listMCC", listaMCC); 
	}
})