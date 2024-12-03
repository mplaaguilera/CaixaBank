({
	recordDataUpdated: function(component, event) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			//Se actualiza el atributo esPropietario para habilitar/deshabilitar el botón de guardado
			component.set('v.esPropietario', $A.get('$SObjectType.CurrentUser.Id') === component.get('v.caso.OwnerId'));
			if (component.get('v.caso.RecordType.DeveloperName')) {
				component.set('v.negocio', component.get('v.caso.RecordType.DeveloperName').split('_')[0]);
			}

			component.set('v.recordTypeCase', component.get('v.caso.RecordType.DeveloperName'));
			if (component.get('v.caso.RecordType.DeveloperName') === 'SAC_Reclamacion') {
				component.set('v.readOnly', true);

			} else {
				component.set('v.readOnly', false);
			}

			//Se muestra el campo de búsqueda si el caso no está clasificado
			if (!component.get('v.caso.CC_MCC_Motivo__r.Name')) {
				component.set('v.mostrarBuscador', true);
			}
			if (component.get('v.negocio') === 'OS') {
				let campos = component.get('v.campos');
				let add = true;
				campos.forEach(campo => {
					if (campo === 'CC_MCC_Motivo__r.CBK_Traslado_Remitido__c') {
						add = false;
					}
				});
				if (add) {
					campos.push('CC_MCC_Motivo__r.CBK_Traslado_Remitido__c');
					component.set('v.campos', campos);
				}
			}

			if (component.get('v.negocio') === 'SAC') {
				let idCasoActual = component.get('v.recordId');
				let comprobarFamilia = component.get('c.compruebaPermisoSAC');
				let userId = $A.get('$SObjectType.CurrentUser.Id');
				comprobarFamilia.setParams({'caseId': idCasoActual, 'idUsuario': userId});
				comprobarFamilia.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						component.set('v.esPropietario', response.getReturnValue());

						let comprobarUsuarioSAC = component.get('c.comprobarUsuarioSAC');
						comprobarUsuarioSAC.setParams({'idUser': userId});
						comprobarUsuarioSAC.setCallback(this, responseComprobarUsuarioSAC => {
							if (responseComprobarUsuarioSAC.getState() === 'SUCCESS') {
								component.set('v.esAuditorSAC', responseComprobarUsuarioSAC.getReturnValue());
							} else {
								component.set('v.esAuditorSAC', false);
							}
						});
						$A.enqueueAction(comprobarUsuarioSAC);
					} else {
						//console.log('Error metodo familia');
					}
				});
				$A.enqueueAction(comprobarFamilia);

				let alternateDisplayFields = ['CC_Tematica_Formula__c', 'CC_Producto_Servicio_Formula__c', 'SEG_Motivo_Formula__c', 'Name'];
				component.set('v.alternateDisplayField', alternateDisplayFields);
				component.set('v.showDetalle', true);

				let campos = component.get('v.campos');
				let add = true;
				campos.forEach(campo => {
					if (campo === 'SEG_Detalle__r.Name') {
						add = false;
					}
				});
				if (add) {
					campos.push('SEG_Detalle__r.Name');
					component.set('v.campos', campos);
				}
			}

			if (component.get('v.negocio') === 'SEG') {

				let alternateDisplayFields = ['CC_Tematica_Formula__c', 'CC_Producto_Servicio_Formula__c', 'SEG_Motivo_Formula__c', 'SEG_Detalle_Formula__c'];
				component.set('v.alternateDisplayField', alternateDisplayFields);
				component.set('v.showDetalle', true);

				let campos = component.get('v.campos');
				let add = true;
				campos.forEach(campo => {
					if (campo === 'SEG_Detalle__r.Name') {
						add = false;
					}
				});
				if (add) {
					campos.push('SEG_Detalle__r.Name');
					component.set('v.campos', campos);
					component.find('caseData').reloadRecord(true);
				}
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
					if (selectedObjectIndex !== null && selectedObjectIndex - 1 >= 0) {
						selectedObjectIndex--;
					} else if (selectedObjectIndex !== null && selectedObjectIndex - 1 < 0 || selectedObjectIndex === null) {
						selectedObjectIndex = objectList.length - 1;
					}
					component.set('v.selectedIndex', selectedObjectIndex);
				}
				break;

			case 40: //down key
				if (objectList.length > 0) {
					if (selectedObjectIndex !== null && selectedObjectIndex + 1 < objectList.length) {
						selectedObjectIndex++;
					} else if (selectedObjectIndex !== null && selectedObjectIndex + 1 === objectList.length || selectedObjectIndex === null) {
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
				//Sin acciones
				break;

			default: //cualquier otra tecla
				//Reseteo de los atributos de los resultados antes de hacer una nueva consulta
				component.set('v.selectedObject', null);
				component.set('v.selectedObjectDisplayName', '');
				component.set('v.queryErrorMessage', '');
				component.set('v.queryErrorFound', false);

				if (enteredValue.length >= 3) {
					//Se cancela la búsqueda pendiente anterior
					clearTimeout(component.get('v.idTimeout'));

					//Se programa la búsqueda para al cabo de unos ms (reduce el nombre de
					//consultas lanzadas mientras el usuario escribe los términos de búsqueda)
					//eslint-disable-next-line @lwc/lwc/no-async-operation
					component.set('v.idTimeout', setTimeout($A.getCallback(() => {
						component.set('v.searching', true);
						component.set('v.objectList', []);

						let queryString = '';
						if (component.get('v.negocio') === 'OS') {
							queryString = 'SELECT CC_Tematica_Formula__c, CC_Producto_Servicio_Formula__c, Name, CC_Detalle__c, CC_3N_CSBD__c, CC_Producto_Servicio__r.CC_Tematica__r.CC_3N_CSBD__c, CC_Producto_Servicio__r.CC_Tematica__r.Name, CBK_Traslado_Remitido__c FROM CC_MCC__c WHERE CC_Clasificacion_Completa_Formula__c LIKE \'%' + enteredValue.replace(/ /g, '%') + '%\'';
							queryString += ' AND RecordType.DeveloperName = \'CC_Motivo\' AND CC_Activo__c = true';
						}
						if (component.get('v.negocio') !== 'OS') {
							queryString = 'SELECT CC_Tematica_Formula__c, CC_Producto_Servicio_Formula__c, Name, CC_Detalle__c, CC_3N_CSBD__c, CC_Producto_Servicio__r.CC_Tematica__r.CC_3N_CSBD__c, CC_Producto_Servicio__r.CC_Tematica__r.Name FROM CC_MCC__c WHERE CC_Clasificacion_Completa_Formula__c LIKE \'%' + enteredValue.replace(/ /g, '%') + '%\'';
							//Si estamos en SAC, modificamos la query para introducir un filtro nuevo
							if (component.get('v.recordTypeCase').split('_')[0] === 'SAC') {
								queryString = 'SELECT CC_Tematica_Formula__c, CC_Producto_Servicio_Formula__c, Name, CC_Detalle__c, CC_3N_CSBD__c, CC_Producto_Servicio__r.CC_Tematica__r.CC_3N_CSBD__c, CC_Producto_Servicio__r.CC_Tematica__r.Name, SEG_Motivo_Formula__c FROM CC_MCC__c WHERE CC_Clasificacion_Completa_Formula__c LIKE \'%' + enteredValue.replace(/ /g, '%') + '%\'';
								queryString += ' AND RecordType.DeveloperName IN (\'SAC_Detalle\') AND CC_Activo__c = true';
							} else {
								queryString = 'SELECT CC_Producto_Servicio__r.CC_Tematica__r.CC_Canal_Operativo__c,CC_Tematica_Formula__c, CC_Producto_Servicio_Formula__c, Name, CC_Detalle__c, CC_3N_CSBD__c, CC_Producto_Servicio__r.CC_Tematica__r.CC_3N_CSBD__c, CC_Producto_Servicio__r.CC_Tematica__r.Name FROM CC_MCC__c WHERE CC_Clasificacion_Completa_Formula__c LIKE \'%' + enteredValue.replace(/ /g, '%') + '%\'';
								queryString += ' AND RecordType.DeveloperName = \'CC_Motivo\' AND CC_Activo__c = true';
							}

							//Si estamos en Segmentos, modificamos la query para el negocio.
							if (component.get('v.negocio') === 'SEG') {
								queryString = 'SELECT CC_Tematica_Formula__c, CC_Producto_Servicio_Formula__c, SEG_Motivo_Formula__c,SEG_Detalle_Formula__c, CC_Detalle__c, Name FROM CC_MCC__c WHERE CC_Clasificacion_Completa_Formula__c LIKE \'%' + enteredValue.replace(/ /g, '%') + '%\'';
								queryString += ' AND RecordType.DeveloperName IN (\'CC_Motivo\',\'SEG_Detalle\') AND CC_Activo__c = true';
							}
						}

						//let queryString = FIND {enteredValue} IN CC_Clasificacion_Completa_Formula__c RETURNING
						//let queryString = 'FIND {enteredValue} IN CC_MCC__c RETURNING (CC_Tematica_Formula__c, CC_Producto_Servicio_Formula__c, Name, CC_Detalle__c) WHERE CC_Clasificacion_Completa_Formula__c LIKE \'%' + enteredValue.replace(/ /g, '%') + '%\'';

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
							'objectId': component.get('v.recordId'),
							'queryString': queryString,
							'numResultados': 15,
							'dateValidCache': timeCacheValid
						});
						querySalesforceRecord.setCallback(this, response => {
							if (response.getState() === 'SUCCESS') {
								component.set('v.objectList', response.getReturnValue());
								component.set('v.searching', false);
								component.set('v.selectedIndex', 0); //1?
								if (component.get('v.negocio') === 'SEG') {
									component.set('v.pagina', 1);
									component.set('v.objectListAux', response.getReturnValue());
									let numPaginas = response.getReturnValue().length / 15;
									if (numPaginas < 1) {
										component.set('v.totalPaginas', 1);
									} else {
										if (numPaginas % 1 !== 0) {
											component.set('v.totalPaginas', Math.floor(numPaginas) + 1);
										} else {
											component.set('v.totalPaginas', Math.floor(numPaginas));
										}
									}
								}
							} else {
								console.error(response.getError()[0].message);
								component.set('v.queryErrorMessage', response.getError()[0].message);
								component.set('v.queryErrorFound', true);
								component.set('v.objectList', []);
								component.set('v.selectedIndex', null);
								component.set('v.searching', false);
							}
						});
						$A.enqueueAction(querySalesforceRecord);
					}), 400));

				} else {
					component.set('v.objectList', []);
					component.set('v.selectedIndex', null);
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
		let negocio = component.get('v.negocio');
		if (component.get('v.objectList').length === 0) {
			$A.util.removeClass(component.find('sinResultadosBusqueda'), 'cc-fade-in');
			$A.util.addClass(component.find('sinResultadosBusqueda'), 'cc-fade-out');
		} else {
			if (negocio !== 'SEG') {
				$A.util.removeClass(component.find('resultadosBusqueda'), 'cc-fade-in');
				$A.util.addClass(component.find('resultadosBusqueda'), 'cc-fade-out');
			}
		}
		if (negocio !== 'SEG') {
			component.set(
				'v.idTimeoutFade',
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout($A.getCallback(() => component.set('v.lookupInputFocused', false)), 500)
			);
		}
	},

	inputInFocus: function(component) {
		clearTimeout(component.get('v.idTimeoutFade'));
		component.set('v.lookupInputFocused', true);
		if (component.get('v.objectList').length === 0) {
			$A.util.removeClass(component.find('sinResultadosBusqueda'), 'cc-fade-out');
			$A.util.addClass(component.find('sinResultadosBusqueda'), 'cc-fade-in');
		} else {
			$A.util.removeClass(component.find('resultadosBusqueda'), 'cc-fade-out');
			$A.util.addClass(component.find('resultadosBusqueda'), 'cc-fade-in');
		}
	},

	removeSelectedOption: function(component) {
		component.set('v.selectedIndex', null);
		component.set('v.selectedObject', null);
		component.set('v.selectedObjectDisplayName', '');
		component.set('v.value', null);
		component.set('v.lookupId', '');
	},

	onRowSelected: function(component, event, helper) {
		component.set('v.selectedIndex', parseInt(event.currentTarget.dataset.currentIndex, 10));
		helper.onValueSelect(component);
	},

	guardar: function(component, event, helper) {
		component.set('v.guardando', true);
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => {
			let modalGuardando = component.find('modalGuardando');
			if (modalGuardando) {
				$A.util.addClass(component.find('backdropGuardando'), 'slds-backdrop_open');
				$A.util.addClass(modalGuardando, 'slds-fade-in-open');
			}
		}), 200);
		component.set('v.trasladoRemitidoCops', '');

		let negocio = component.get('v.negocio');
		let actualizarCaso;
		if (negocio === 'SAC') {
			actualizarCaso = component.get('c.actualizarCasoSAC');
			actualizarCaso.setParams({'recordId': component.get('v.recordId'), 'idDetalle': component.get('v.selectedObject.Id')});
		} else if (negocio === 'SEG') {
			actualizarCaso = component.get('c.actualizarCasoSEG');
			actualizarCaso.setParams({'recordId': component.get('v.recordId'), 'idMotivo': component.get('v.selectedObject.Id')});
		} else {
			actualizarCaso = component.get('c.actualizarCaso');
			actualizarCaso.setParams({'recordId': component.get('v.recordId'), 'idMotivo': component.get('v.selectedObject.Id')});
		}

		//let actualizarCaso = component.get('c.actualizarCaso');
		//actualizarCaso.setParams({'recordId': component.get('v.recordId'), 'idMotivo': component.get('v.selectedObject.Id')});
		actualizarCaso.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				//ocultar el buscador.
				if (component.get('v.negocio') !== 'HDT') {
					component.set('v.mostrarBuscador', false);
				}

				//Refrescar LC CC_MCC_Clasificar
				let eventoCC = $A.get('e.c:CC_Refresh_MCC_Clasificar');
				eventoCC.setParams({'recordId': component.get('v.recordId')});
				eventoCC.fire();

				//Refrescar LC OS_Case_Gestion
				let eventoCops = $A.get('e.c:OS_Refresh_Case_Gestion');
				eventoCops.setParams({'recordId': component.get('v.recordId')});
				eventoCops.fire();
				if (component.get('v.negocio') !== 'CC' || component.get('v.negocio') !== 'HDT') {
					component.find('caseData').reloadRecord(true);
				}

				//Refrescar datos del caso en el buscador
				component.set('v.caso', response.getReturnValue());

				//Vaciar campo de búsqueda
				$A.enqueueAction(component.get('c.removeSelectedOption'));

				//Toast OK
				helper.mostrarToast('success', 'Se actualizó caso', 'Se actualizó correctamente el caso ' + component.get('v.caso.CaseNumber') + '.');
			} else {
				//Toast de error
				helper.mostrarToast('error', 'No se pudo actualizar', actualizarCaso.getError()[0].message);
			}
			$A.util.removeClass(component.find('modalGuardando'), 'slds-fade-in-open');
			$A.util.removeClass(component.find('backdropGuardando'), 'slds-backdrop_open');
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => component.set('v.guardando', false)), 300);
		});
		$A.enqueueAction(actualizarCaso);
	},

	mostrarBuscador: function(component) {
		//Fix reset variables. Error de pintado de componente.
		component.set('v.selectedIndex', null);
		component.set('v.selectedObject', null);
		component.set('v.selectedObjectDisplayName', '');
		component.set('v.value', null);
		component.set('v.lookupId', '');

		if (component.get('v.mostrarBuscador')) {
			component.set('v.mostrarBuscador', false);
		} else {
			component.set('v.mostrarBuscador', true);
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => component.find('lookUpInputElement').focus()), 15);
		}
	},

	beforePage: function(component) {
		let focusMccs = [];
		let pagina = component.get('v.pagina');
		let objectListAux = component.get('v.objectListAux');
		pagina = pagina - 1;
		if (pagina < 0) {
			pagina = 1;
		}
		component.set('v.pagina', pagina);
		let firstReg = 0;
		let lastReg = 15;
		if (pagina > 1) {
			firstReg = 15 * (pagina - 1);
			lastReg = 15 * pagina;
		}
		let n = firstReg;
		while (n <= lastReg) {
			focusMccs.push(objectListAux[n]);
			n++;
		}
		component.set('v.objectList', focusMccs);
	},

	nextPage: function(component) {
		let focusMccs = [];
		let pagina = component.get('v.pagina');
		let objectListAux = component.get('v.objectListAux');
		let totalPaginas = component.get('v.totalPaginas');
		let mccsSize = component.get('v.objectListAux').length;
		pagina = pagina + 1;
		if (pagina > totalPaginas) {
			pagina = totalPaginas;
		}
		component.set('v.pagina', pagina);

		let firstReg = 15 * (pagina - 1);
		let lastReg = 15 * pagina;
		let n = firstReg;
		while (n <= lastReg) {
			if (n < mccsSize) {
				focusMccs.push(objectListAux[n]);
			}
			n++;
		}
		component.set('v.objectList', focusMccs);
	}
});