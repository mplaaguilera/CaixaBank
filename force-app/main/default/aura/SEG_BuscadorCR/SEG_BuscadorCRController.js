({
	recordDataUpdated: function(component, event) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			//Se actualiza el atributo esPropietario para habilitar/deshabilitar el botón de guardado
			component.set('v.esPropietario', $A.get('$SObjectType.CurrentUser.Id') === component.get('v.caso.OwnerId'));
			component.set('v.recordTypeCase', component.get('v.caso.RecordType.DeveloperName'));
			//Se muestra el campo de búsqueda si el caso no está clasificado
			if (!component.get('v.caso.SEG_ClasificacionRapida__r.Name')) {
				component.set('v.mostrarBuscador', true);
			}

			if (event.getParams().changeType === 'CHANGED') {
				/*Refrescar los datos del LC. */
				component.find('caseData').reloadRecord();
			}

		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.ldsError'));
		}
	},

	searchRecords: function(component, event, helper) {
		let enteredValue = component.get('v.enteredValue');
		let objectList = component.get('v.objectList');
		let selectedObjectIndex = component.get('v.selectedIndex');

		switch (event.which) {
			case 38: //up key
				if (objectList.length > 0) {
					if (selectedObjectIndex !== undefined && selectedObjectIndex - 1 >= 0) {
						selectedObjectIndex--;
					} else if (selectedObjectIndex !== undefined && selectedObjectIndex - 1 < 0 || selectedObjectIndex === undefined) {
						selectedObjectIndex = objectList.length - 1;
					}
					component.set('v.selectedIndex', selectedObjectIndex);
				}
				break;

			case 40: //down key
				if (objectList.length > 0) {
					if (selectedObjectIndex !== undefined && selectedObjectIndex + 1 < objectList.length) {
						selectedObjectIndex++;
					} else if (selectedObjectIndex !== undefined && selectedObjectIndex + 1 === objectList.length || selectedObjectIndex === undefined) {
						selectedObjectIndex = 0;
					}
					component.set('v.selectedIndex', selectedObjectIndex);
				}
				break;

			case 27: //escape key
				component.set('v.objectList', []);
				component.set('v.lookupInputFocused', false);
				break;

			case 13: //enterKey
				helper.onValueSelect(component);
				break;

			case 39: //Right Key
			case 37: //Left Key
			case 35: //home
			case 36: //End
			case 16: //Shift
			case 17: //Control
			case 18: //Alt
				//don't to anything
				break;

			default: //any other character entered
				//Reseteo de los atributos de los resultados antes de hacer una nueva consulta
				component.set('v.selectedObject', undefined);
				component.set('v.selectedObjectDisplayName', '');
				component.set('v.crId', '');
				component.set('v.queryErrorMessage', '');
				component.set('v.queryErrorFound', false);
				component.set('v.botonSeleccion', 'Seleccionar');

				if (enteredValue.length >= 3) {
					//Se cancela la búsqueda pendiente anterior
					clearTimeout(component.get('v.idTimeout'));

					//Se programa la búsqueda para al cabo de unos ms (reduce el nombre de
					//consultas lanzadas mientras el usuario escribe los términos de búsqueda
					component.set('v.idTimeout', setTimeout($A.getCallback(() => {
						component.set('v.searching', true);
						component.set('v.objectList', []);
						let queryString = 'SELECT Id, Name FROM SEG_ClasificacionRapida__c WHERE Name LIKE \'%' + enteredValue.replace(/ /g, '%') + '%\' AND SEG_Inactiva__c = false AND SEG_CRContratos__c = false';
						queryString = queryString + ' AND CBK_Negocio__c = \'Segmentos\'';
						if (component.get('v.caso.SEG_Organizacion__c') != undefined && component.get('v.caso.SEG_Organizacion__c') != null && component.get('v.caso.SEG_Organizacion__c').length > 0) {
							queryString = queryString + ' AND SEG_Organizacion__c INCLUDES(\'' + component.get('v.caso.SEG_Organizacion__c') + '\')';
						}

						queryString = queryString + ' LIMIT 15';

						//Force cache.
						let fecha = new Date();
						let timeCacheValid = fecha.getFullYear().toString(10) + '_' + fecha.getMonth().toString(10) + '_' + fecha.getDay().toString(10) + '_' + fecha.getHours().toString(10);
						let minutos = fecha.getMinutes();
						if (minutos <= 20) {
							timeCacheValid = timeCacheValid + '_20';
						} else if (minutos <= 40) {
							timeCacheValid = timeCacheValid + '_40';
						} else {
							timeCacheValid = timeCacheValid + '_60';
						}

						let querySalesforceRecord = component.get('c.querySalesforceRecord');
						querySalesforceRecord.setParams({
							'queryString': queryString,
							'dateValidCache': timeCacheValid
						});
						querySalesforceRecord.setCallback(this, response => {
							if (response.getState() === 'SUCCESS') {
								component.set('v.objectList', response.getReturnValue());
								component.set('v.searching', false);
								component.set('v.selectedIndex', 0); //1?
							} else {
								console.error(response.getError()[0].message);
								component.set('v.queryErrorMessage', response.getError()[0].message);
								component.set('v.queryErrorFound', true);
								component.set('v.objectList', []);
								component.set('v.selectedIndex', undefined);
								component.set('v.searching', false);
							}
						});
						$A.enqueueAction(querySalesforceRecord);
					}), 400));
				} else {
					component.set('v.objectList', []);
					component.set('v.selectedIndex', undefined);
					component.set('v.searching', false);
				}
		} //fin switch
	},

	showColorOnMouseEnter: function(component, event) {
		$A.util.addClass(event.currentTarget, 'highlight');
	},

	hideColorOnMouseLeave: function(component, event) {
		$A.util.removeClass(event.currentTarget, 'highlight');
	},

	inputBlurred: function(component) {
		//delaying the setting of this flag. This is to make sure that the flag is set post the selection of the dropdown.
		window.setTimeout($A.getCallback(() => component.set('v.lookupInputFocused', false)), 100);
	},

	inputInFocus: function(component) {
		component.set('v.lookupInputFocused', true);
	},

	removeSelectedOption: function(component) {
		component.set('v.selectedIndex', undefined);
		component.set('v.selectedObject', undefined);
		component.set('v.selectedObjectDisplayName', '');
		component.set('v.crId', '');
		component.set('v.botonSeleccion', 'Seleccionar');
		component.set('v.value', undefined);
		component.set('v.lookupId', '');
	},

	onRowSelected: function(component, event, helper) {
		component.set('v.selectedIndex', parseInt(event.currentTarget.dataset.currentIndex, 10));
		helper.onValueSelect(component);
	},

	guardar: function(component, event, helper) {
		let idCase = component.get('v.recordId');
		let objectId = component.get('v.selectedObject.Id');
		console.log ('idcase ' + component.get('v.recordId'));
		console.log ('objectId ' + component.get('v.selectedObject.Id'));
		component.set('v.guardando', true);
		window.setTimeout($A.getCallback(() => {
			$A.util.addClass(component.find('backdropGuardando'), 'slds-backdrop_open');
			$A.util.addClass(component.find('modalGuardando'), 'slds-fade-in-open');
		}), 90);

		let updateCase = component.get('c.updateCaseCR');
		updateCase.setParams({
			'caseId': idCase,
			'crId': objectId
		});
		updateCase.setCallback(this, response => {
			$A.util.removeClass(component.find('modalGuardando'), 'slds-fade-in-open');
			$A.util.removeClass(component.find('backdropGuardando'), 'slds-backdrop_open');
			window.setTimeout($A.getCallback(() => component.set('v.guardando', false)), 200);

			if (response.getState() === 'SUCCESS') {
				//ocultar el buscador.
				component.set('v.mostrarBuscador', false);

				//helper.mostrarToast('success', 'Se actualizó caso', 'Se actualizó correctamente la clasificación rápida del caso.');
				//Vaciar campo de búsqueda
				$A.enqueueAction(component.get('c.removeSelectedOption'));

				//Refrescar registro para tener el registro actualizado del caso.
				//Fix. Este doble refresh hace que se interrumpa el refresco
				component.find('caseData').reloadRecord(true);
				//setTimeout(() => {$A.get('e.force:refreshView').fire();}, 300);
			} else {
				console.error(response.getError());
				var msgError = JSON.stringify(response.getError());
				if(msgError.includes('Tienes que asignar una organización y zona para establecer una Clasificación Rápida')){
					msgError = 'Tienes que asignar una organización y zona para establecer una Clasificación Rápida';
				}
				helper.mostrarToast('error', 'No se pudo actualizar', 'Error actualizando la clasificación rápida. Detalle: ' + JSON.stringify(msgError.replace(/{|}|[|]/gi, ' ')));

				//helper.mostrarToast('error', 'No se pudo actualizar', 'Error actualizando la clasificación rápida. Detalle: ' + JSON.stringify(response.getError()).replace(/{|}|[|]/gi, ' '));

				// Blanquear la CR
				component.set('v.enteredValue', null);
				component.set('v.selectedObjectDisplayName', '');
			}

        
            //FIX. No se actualiza por LDS dado que provoca la pérdida de la Cuenta y Contacto del Caso.
    
            //Refrescar registro para tener el registro actualizado del caso.
            component.find('caseData').reloadRecord();
    
            //component.set('v.casoEdit.SEG_ClasificacionRapida__c',component.get('v.selectedObject.Id'));
            component.set('v.caso.SEG_ClasificacionRapida__c', component.get('v.selectedObject.Id'));
            //component.find("caseDataEdit").saveRecord($A.getCallback(function(saveResult) {
            component.find('caseData').saveRecord($A.getCallback(saveResult => {
                $A.util.removeClass(component.find('modalGuardando'), 'slds-fade-in-open');
                $A.util.removeClass(component.find('backdropGuardando'), 'slds-backdrop_open');
                window.setTimeout($A.getCallback(() => component.set('v.guardando', false)), 200);
    
                if (saveResult.state === 'SUCCESS' || saveResult.state === 'DRAFT') {
                    //ocultar el buscador.
                    component.set('v.mostrarBuscador', false);
    
                    //helper.mostrarToast('success', 'Se actualizó caso', 'Se actualizó correctamente la clasificación rápida del caso.');
                    //Vaciar campo de búsqueda
                    $A.enqueueAction(component.get('c.removeSelectedOption'));
                } else if (saveResult.state === 'INCOMPLETE') {
                    console.log('Estado incompleto de la operación de guardado.');
                } else if (saveResult.state === 'ERROR') {
					var msgError2 = JSON.stringify(saveResult.error);
					if(!msgError2.includes('Tienes que asignar una organización y zona para establecer una Clasificación Rápida')){
						helper.mostrarToast('error', 'No se pudo actualizar', 'Error actualizando la clasificación rápida. Detalle: ' + msgError2);
						// Blanquear la CR
						component.set('v.enteredValue', null);
						component.set('v.selectedObjectDisplayName', '');
					}

                    console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                } else {
                    helper.mostrarToast('error', 'No se pudo actualizar', 'Error actualizando la clasificación rápida. Detalle: ' + JSON.stringify(saveResult.error));
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
					// Blanquear la CR
					component.set('v.enteredValue', null);
					component.set('v.selectedObjectDisplayName', '');
                }
		}));

        
        
		});
		$A.enqueueAction(updateCase);


	},

	seleccionarCR: function(component, event, helper) {
		//Actualizar la variable de selección (Binding Variable)
		component.set('v.crId', component.get('v.selectedObject.Id'));
		component.set('v.botonSeleccion', 'Confirmado!');
	},

	mostrarBuscador: function(component) {
		if (component.get('v.mostrarBuscador')) {
			component.set('v.mostrarBuscador', false);
		} else {
			component.set('v.mostrarBuscador', true);
			window.setTimeout($A.getCallback(() => component.find('lookUpInputElement').focus()), 15);
		}
	}
});