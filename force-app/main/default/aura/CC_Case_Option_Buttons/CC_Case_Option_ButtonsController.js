/*eslint-disable no-undef */
({
	doInit: function(component, event, helper) {
		helper.getDatosCaso(component);
		component.set('v.today', $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD'));
		helper.visibilidadBotonCitaTareaGestor(component);
		helper.getPSGestorDocumentos(component);
		//helper.visibilidadBotonOnboarding(component);
		//helper.vaciarPlantilla(component);
	},

	recordDataUpdated: function(component, event, helper) {
		if (event.getParams().changeType === 'LOADED') { //|| event.getParams().changeType === 'CHANGED') {
			if (component.get('v.caso.CC_MCC_Plantilla__c')) {
				helper.vaciarPlantilla(component);
			}
		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.recordDataError'));
			helper.mostrarToast('error', 'Problema recuperando los datos del caso', component.get('v.recordDataError'));
		}
	},

	//Función añadida por Moisés Cano - US969672
	//validacionesLinksTF : function(component, event, helper) {
	//var mccMotivoId = component.get('v.caso.CC_MCC_Motivo__c'); // Obtén el ID del MCC_Motivo


	//if (mccMotivoId) {
	//// Llamar al método Apex para obtener el link
	//var action = component.get("c.obtenerCCLink"); // Llama al método obtenerCCLink en la clase Apex
	//action.setParams({
	//motivoId: mccMotivoId // Pasa el motivoId al método Apex
	//});

	//// Manejar la respuesta de Apex para obtenerCCLink
	//action.setCallback(this, function(response) {
	//var state = response.getState();
	//if (state === "SUCCESS") {
	//var ccLink = response.getReturnValue(); // Valor devuelto desde Apex

	//if (ccLink) {
	//// Si el link no está vacío, abre una nueva pestaña
	//window.open(ccLink, '_blank');
	//} else {
	//// Mostrar mensaje de error si el link está vacío
	//var toastEvent = $A.get("e.force:showToast");
	//toastEvent.setParams({
	//"title": "Error",
	//"message": "Este MCC de motivo no tiene asignado ningún enlace.",
	//"type": "error"
	//});
	//toastEvent.fire();
	//}

	//// Llamar al método Apex para obtener el valor desde el MCC Motivo
	//var actionValor = component.get("c.crearTareaTF9"); // Llama al método crearTareaTF9
	//actionValor.setParams({
	//recordId: component.get('v.recordId') // Pasa el motivoId al método Apex
	//});

	//// Manejar la respuesta de Apex para crearTareaTF9
	//actionValor.setCallback(this, function(responseValor) {
	//var stateValor = responseValor.getState();
	//if (stateValor === "SUCCESS") {
	//var valor = responseValor.getReturnValue(); // Valor devuelto desde Apex
	//// Aquí puedes implementar cualquier lógica que dependa del valor obtenido
	//if (valor) {
	//var toastEvent = $A.get("e.force:showToast");
	//toastEvent.setParams({
	//"title": "Nueva actividad creada",
	//"message": "Actividad Creada ",
	//"type": "success"
	//});
	//toastEvent.fire();
	//}
	//} else if (stateValor === "ERROR") {
	//// Manejar el error si ocurre
	//var errorsValor = responseValor.getError();
	//var errorMessageValor = 'Error desconocido'; // Mensaje genérico
	//if (errorsValor && Array.isArray(errorsValor) && errorsValor.length > 0) {
	//errorMessageValor = errorsValor[0].message; // Mensaje específico del error
	//}
	//var toastEvent = $A.get("e.force:showToast");
	//toastEvent.setParams({
	//"title": "Error",
	//"message": errorMessageValor,
	//"type": "error"
	//});
	//toastEvent.fire();
	//}
	//});

	//$A.enqueueAction(actionValor); // Ejecuta la acción de Apex para obtenerValorDesdeMccMotivo
	//} else if (state === "ERROR") {
	//// Manejar el error si ocurre
	//var errors = response.getError();
	//var errorMessage = 'Error desconocido'; // Mensaje genérico
	//if (errors && Array.isArray(errors) && errors.length > 0) {
	//errorMessage = errors[0].message; // Mensaje específico del error
	//}
	//var toastEvent = $A.get("e.force:showToast");
	//toastEvent.setParams({
	//"title": "Error",
	//"message": errorMessage,
	//"type": "error"
	//});
	//toastEvent.fire();
	//}
	//});

	//$A.enqueueAction(action); // Ejecuta la acción de Apex para obtenerCCLink
	//} else {
	//// Mostrar mensaje si no se seleccionó un MCC Motivo
	//var toastEvent = $A.get("e.force:showToast");
	//toastEvent.setParams({
	//"title": "Error",
	//"message": "No se ha seleccionado ningún MCC de motivo.",
	//"type": "error"
	//});
	//toastEvent.fire();
	//}
	//},

	//Fin US969672


	handleComponentEvent: function(component, event) {
		component.set('v.selectedRecord', event.getParam('accountByEvent'));
		$A.enqueueAction(component.get('c.obtenerPlantillasGrupo'));

		let lookupPill = component.find('lookup-pill');
		$A.util.addClass(lookupPill, 'slds-show');
		$A.util.removeClass(lookupPill, 'slds-hide');

		let searchRes = component.find('searchRes');
		$A.util.addClass(searchRes, 'slds-is-close');
		$A.util.removeClass(searchRes, 'slds-is-open');

		let lookupField = component.find('lookupField');
		$A.util.addClass(lookupField, 'slds-hide');
		$A.util.removeClass(lookupField, 'slds-show');

		let lookupPill2 = component.find('lookup-pill-2');
		$A.util.addClass(lookupPill2, 'slds-show');
		$A.util.removeClass(lookupPill2, 'slds-hide');

		let searchRes2 = component.find('searchRes2');
		$A.util.addClass(searchRes2, 'slds-is-close');
		$A.util.removeClass(searchRes2, 'slds-is-open');

		let lookupField2 = component.find('lookupField2');
		$A.util.addClass(lookupField2, 'slds-hide');
		$A.util.removeClass(lookupField2, 'slds-show');

		let lookupPill3 = component.find('lookup-pill-3');
		$A.util.addClass(lookupPill3, 'slds-show');
		$A.util.removeClass(lookupPill3, 'slds-hide');

		let searchRes3 = component.find('searchRes3');
		$A.util.addClass(searchRes3, 'slds-is-close');
		$A.util.removeClass(searchRes3, 'slds-is-open');

		let lookupField3 = component.find('lookupField3');
		$A.util.addClass(lookupField3, 'slds-hide');
		$A.util.removeClass(lookupField3, 'slds-show');
	},

	handleComponentEventOffice: function(component, event, helper) {
		if (!event.getParam('segundaOficina')) {
			component.set('v.selectedRecord', event.getParam('officeByEvent'));
		} else {
			component.set('v.selectedRecordSegundaOficina', event.getParam('officeByEvent'));
		}
		//component.set('v.oficinaSeleccionada', true);
		helper.obtenerPlantillasOficina(component, event, helper);

		let lookupPill = component.find('lookup-pill');
		$A.util.addClass(lookupPill, 'slds-show');
		$A.util.removeClass(lookupPill, 'slds-hide');

		let searchRes = component.find('searchRes');
		$A.util.addClass(searchRes, 'slds-is-close');
		$A.util.removeClass(searchRes, 'slds-is-open');

		let lookupField = component.find('lookupField');
		$A.util.addClass(lookupField, 'slds-hide');
		$A.util.removeClass(lookupField, 'slds-show');

		if (!event.getParam('segundaOficina')) {
			let lookupPill2 = component.find('lookup-pill-2');
			$A.util.addClass(lookupPill2, 'slds-show');
			$A.util.removeClass(lookupPill2, 'slds-hide');
		} else {
			let lookupPillSegundaOficina = component.find('lookup-pill-segunda-oficina');
			$A.util.addClass(lookupPillSegundaOficina, 'slds-show');
			$A.util.removeClass(lookupPillSegundaOficina, 'slds-hide');
		}

		let searchRes2 = component.find('searchRes2');
		$A.util.addClass(searchRes2, 'slds-is-close');
		$A.util.removeClass(searchRes2, 'slds-is-open');

		let searchResSegundaOfi = component.find('searchResSegundaOfi');
		$A.util.addClass(searchResSegundaOfi, 'slds-is-close');
		$A.util.removeClass(searchResSegundaOfi, 'slds-is-open');

		let lookupField2 = component.find('lookupField2');
		$A.util.addClass(lookupField2, 'slds-hide');
		$A.util.removeClass(lookupField2, 'slds-show');

		let lookupPill3 = component.find('lookup-pill-3');
		$A.util.addClass(lookupPill3, 'slds-show');
		$A.util.removeClass(lookupPill3, 'slds-hide');

		let searchRes3 = component.find('searchRes3');
		$A.util.addClass(searchRes3, 'slds-is-close');
		$A.util.removeClass(searchRes3, 'slds-is-open');

		let lookupField3 = component.find('lookupField3');
		$A.util.addClass(lookupField3, 'slds-hide');
		$A.util.removeClass(lookupField3, 'slds-show');
	},

	handleComponentEventEmpleado: function(component, event, helper) {

		component.set('v.selectedRecord', event.getParam('contactByEvent'));
		//component.set('v.oficinaSeleccionada', true);
		helper.obtenerPlantillasEmpleado(component, event, helper);

		let lookupPill = component.find('lookup-pill');
		$A.util.addClass(lookupPill, 'slds-show');
		$A.util.removeClass(lookupPill, 'slds-hide');

		let searchRes = component.find('searchRes');
		$A.util.addClass(searchRes, 'slds-is-close');
		$A.util.removeClass(searchRes, 'slds-is-open');

		let lookupField = component.find('lookupField');
		$A.util.addClass(lookupField, 'slds-hide');
		$A.util.removeClass(lookupField, 'slds-show');

		let lookupPill2 = component.find('lookup-pill-2');
		$A.util.addClass(lookupPill2, 'slds-show');
		$A.util.removeClass(lookupPill2, 'slds-hide');

		let searchRes2 = component.find('searchRes2');
		$A.util.addClass(searchRes2, 'slds-is-close');
		$A.util.removeClass(searchRes2, 'slds-is-open');

		let lookupField2 = component.find('lookupField2');
		$A.util.addClass(lookupField2, 'slds-hide');
		$A.util.removeClass(lookupField2, 'slds-show');

		let lookupPill3 = component.find('lookup-pill-3');
		$A.util.addClass(lookupPill3, 'slds-show');
		$A.util.removeClass(lookupPill3, 'slds-hide');

		let searchRes3 = component.find('searchRes3');
		$A.util.addClass(searchRes3, 'slds-is-close');
		$A.util.removeClass(searchRes3, 'slds-is-open');

		let lookupField3 = component.find('lookupField3');
		$A.util.addClass(lookupField3, 'slds-hide');
		$A.util.removeClass(lookupField3, 'slds-show');
	},

	handleComponentEventNivel3: function(component, event) {
		//get the selected Queue Group record from the COMPONETN event
		let selectedGroupGetFromEvent = event.getParam('groupByEvent');
		component.set('v.selectedRecordGroup', selectedGroupGetFromEvent);
		component.set('v.ultimoGrupo3N', selectedGroupGetFromEvent.Name);
		component.set('v.ultimoGrupo3NId', selectedGroupGetFromEvent.Id);

		let tipoGestion = document.getElementsByClassName('tipoGestion');
		if (selectedGroupGetFromEvent.Name === '3N de CaixaBank Demanda') {
			tipoGestion[0].style.display = 'block';
		} else {
			tipoGestion[0].style.display = 'none';
		}

		$A.util.addClass(component.find('lookup-pill-group'), 'slds-show');
		$A.util.removeClass(component.find('lookup-pill-group'), 'slds-hide');

		$A.util.addClass(component.find('searchResGroup'), 'slds-is-close');
		$A.util.removeClass(component.find('searchResGroup'), 'slds-is-open');

		$A.util.addClass(component.find('lookupFieldGroup'), 'slds-hide');
		$A.util.removeClass(component.find('lookupFieldGroup'), 'slds-show');
	},

	handleComponentEventNivel2: function(component, event) {
		//get the selected Queue Group record from the COMPONENT event
		let selectedGroupGetFromEvent = event.getParam('groupByEvent');
		component.set('v.selectedRecordGroup', selectedGroupGetFromEvent);
		component.set('v.ultimoGrupo2N', selectedGroupGetFromEvent.Name);
		component.set('v.ultimoGrupo2NId', selectedGroupGetFromEvent.Id);

		$A.util.addClass(component.find('lookup-pill-group2N'), 'slds-show');
		$A.util.removeClass(component.find('lookup-pill-group2N'), 'slds-hide');

		$A.util.addClass(component.find('searchResGroup2N'), 'slds-is-close');
		$A.util.removeClass(component.find('searchResGroup2N'), 'slds-is-open');

		$A.util.addClass(component.find('lookupFieldGroup2N'), 'slds-hide');
		$A.util.removeClass(component.find('lookupFieldGrop2N'), 'slds-show');
	},

	handleComponentEventPlantilla: function(component, event) {
		//This function call when the end User Select any record from the result list.
		//get the selected Account record from the COMPONENT event
		component.set('v.selectedRecordPlantilla', event.getParam('plantillaByEvent'));

		let lookupPill = component.find('lookup-pill-plantilla');
		$A.util.addClass(lookupPill, 'slds-show');
		$A.util.removeClass(lookupPill, 'slds-hide');

		let searchRes = component.find('searchResPlantilla');
		$A.util.addClass(searchRes, 'slds-is-close');
		$A.util.removeClass(searchRes, 'slds-is-open');

		let lookupField = component.find('lookupFieldPlantilla');
		$A.util.addClass(lookupField, 'slds-hide');
		$A.util.removeClass(lookupField, 'slds-show');
	},

	handleComponentEventPlantilla2: function(component, event) {
		let plantillaSeleccionada = component.get('v.listOfSearchRecordsPlantilla').find(plantilla => plantilla.Id === event.currentTarget.id);
		component.set('v.plantillaSeleccionada', plantillaSeleccionada);
		component.set('v.plantillaSeleccionadaValue', plantillaSeleccionada.Id);
		component.set('v.plantillaSeleccionadaName', plantillaSeleccionada.Name);
	},

	handleComponentEventTransfer: function(component, event) {
		component.set('v.selectedRecordQueue', event.getParam('queueByEvent').Queue);

		$A.util.addClass(component.find('lookup-pill-queue'), 'slds-show');
		$A.util.removeClass(component.find('lookup-pill-queue'), 'slds-hide');

		$A.util.addClass(component.find('searchResQueue'), 'slds-is-close');
		$A.util.removeClass(component.find('searchResQueue'), 'slds-is-open');

		$A.util.addClass(component.find('lookupFieldQueue'), 'slds-hide');
		$A.util.removeClass(component.find('lookupFieldQueue'), 'slds-show');
	},

	validacionesOperativa: function(component, event, helper) {
		component.set('v.botonOperativa', '');
		let nombreBoton = event.getSource().getLocalId();
		let recordId = component.get('v.recordId');
		if (nombreBoton === 'operativaOficina' || ['Trasladar Colaborador', 'Remitir Colaborador'].includes(nombreBoton)) {
			if (nombreBoton === 'operativaOficina') {
				component.set('v.spinnerActivado', true);
				helper.reiniciarDerivar(component);
			}
			let comprobarBotonOficinaEmpleado = component.get('c.getMostrarBotonOficinaEmpleadoCaixaBank');
			comprobarBotonOficinaEmpleado.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let respuesta = response.getReturnValue();
					let canalProcedencia = component.get('v.canalProcedencia');
					let canales = respuesta.canales;
					component.set('v.mostrarBotonOficinaEmpleadoCaixaBank', respuesta.mostrarBoton);
					if (!component.get('v.mostrarBotonOficinaEmpleadoCaixaBank') && (component.get('v.casoEnTercerNivel') || component.get('v.tipoRegistro') === 'CC_Empleado' || canales.includes(canalProcedencia))) {
						component.set('v.mostrarBotonOficinaEmpleadoCaixaBank', true);
					}
				}
			});
			$A.enqueueAction(comprobarBotonOficinaEmpleado);
		}

		//Chema: por defecto ocultamos el tipo gestión
		let tipoGestion = document.getElementsByClassName('tipoGestion');
		if (tipoGestion.length) {
			tipoGestion[0].style.display = 'none';
		}

		//Comprobación del propietario del caso
		let getEsPropietarioCaso = component.get('c.getEsPropietarioCaso');
		getEsPropietarioCaso.setParams({ownerId: component.get('v.caso.OwnerId')});
		getEsPropietarioCaso.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				if (!response.getReturnValue()) {
					//No es propietario
					let toastPropietario = $A.get('e.force:showToast');
					toastPropietario.setParams({
						title: 'Error permisos propietario', message: 'Esta operativa solo está disponible si es propietario del caso',
						type: 'error', mode: 'dismissible', duration: 4000
					});
					toastPropietario.fire();
				} else {
					//Sí es propietario
					let datosCaso = component.get('c.datosCaso');
					datosCaso.setParams({'recordId': recordId});
					datosCaso.setCallback(this, function(responseDatosCaso) {
						if (responseDatosCaso.getState() === 'SUCCESS') {
							let datos = responseDatosCaso.getReturnValue();
							component.set('v.oCaso', datos);
							component.set('v.idioma', datos.CC_Idioma__c);
							component.set('v.canalProcedencia', datos.CC_Canal_Procedencia__c);
							component.set('v.canalRespuesta', datos.CC_Canal_Respuesta__c);
							component.set('v.estadoCaso', datos.Status);
							component.set('v.canalEntrada', datos.Origin);
							component.set('v.idPropietario', datos.OwnerId);
							component.set('v.ultimoGrupo3N', datos.CC_Grupo_3N__c);
							component.set('v.ultimoGrupo2N', datos.CC_Grupo_2N__c);
							component.set('v.canalOperativo', datos.CC_Canal_Operativo__c);
							component.set('v.causa', datos.CC_MCC_Causa__c);
							component.set('v.solucion', datos.CC_MCC_Solucion__c);
							component.set('v.canalOperativo', datos.CC_Canal_Operativo__c);
							component.set('v.noIdentificado', datos.CC_No_Identificado__c);

							if (datos.AccountId) {
								component.set('v.emailAccountCase', datos.Account.PersonEmail);
								component.set('v.nombreAccountCase', datos.Account.Name);
							}
							//Account y contacto
							component.set('v.ContactId', datos.ContactId);
							component.set('v.AccountId', datos.AccountId);

							let estadoCaso = datos.Status;
							if (estadoCaso === 'Activo' || estadoCaso === 'Pendiente Incidencia' && nombreBoton === 'Trasladar Incidencia' || estadoCaso === 'Pendiente Colaborador' && (nombreBoton === 'Responder Cliente Email' || nombreBoton === 'Responder Cliente SMS' || nombreBoton === 'Responder Cliente Twitter' || nombreBoton === 'Responder Cliente Apps')) {
								component.set('v.mostrarBotonesPendienteColaborador', true);
								component.set('v.mostrarBotonesPendienteInterno', true);
								component.set('v.mostrarBotonesPendienteCliente', true);

								let idPropietario = component.get('v.idPropietario');
								if (idPropietario.startsWith('00G')) {
									helper.mostrarToast('error', 'Operativa no disponible', 'Para poder realizar esta operativa, el caso debe estar asignado a un usuario');
								} else {
									let validarCamposCaso = component.get('c.validarCamposCaso');
									validarCamposCaso.setParam('recordId', component.get('v.recordId'));
									validarCamposCaso.setCallback(this, responseValidarCamposCaso => {
										if (responseValidarCamposCaso.getState() === 'SUCCESS') {
											let camposNoValidos = responseValidarCamposCaso.getReturnValue();
											component.set('v.habilitarOperativas', camposNoValidos.length === 0);
											if (camposNoValidos.length) {
												let mensaje = '';
												//Se comprueba si la clasificación está inactiva
												if (camposNoValidos.indexOf('Clasificación inactiva') > -1) {
													//Si lo está se prepara el mensaje y se quita el elemento del array
													mensaje = 'La clasificación actual del caso ha sido inactivada, debe reclasificarlo. ';
													camposNoValidos.splice(camposNoValidos.indexOf('Clasificación inactiva'), 1);
												}
												if (camposNoValidos.length && ['derivarAlSAC', 'devolverAlSAC'].includes(nombreBoton)) {
													if (!component.get('v.AccountId')) {
														camposNoValidos.push('Cuenta');
													}
													if (!component.get('v.ContactId')) {
														camposNoValidos.push('Contacto');
													}
													mensaje += 'Debe informar los siguientes campos obligatorios: ' + camposNoValidos.join(', ') + '.';
												} else if (camposNoValidos.length && nombreBoton === 'Solicitud Info Email') {
													if (!component.get('v.canalOperativo') && component.get('v.tipoRegistro') === 'CC_Cliente') {
														camposNoValidos.push('Canal operativo');
													}
													mensaje += 'Debe informar los siguientes campos obligatorios: ' + camposNoValidos.join(', ') + '.';
												} else if (camposNoValidos.length && (nombreBoton === 'Devolver Nivel 1' || nombreBoton === 'Rechazar Nivel 1')) {
													mensaje += 'Debes informar el campo Resolución correspondiente dependiendo el nivel del caso en la gestión del caso para continuar';
												} else if (camposNoValidos.length) {
													//El resto de elementos son campos obligatorios actualmente nulos
													mensaje += 'Debe informar los siguientes campos obligatorios: ' + camposNoValidos.join(', ') + '.';
												}

												if (mensaje !== '') {
													helper.mostrarToast('error', 'Operativa no disponible', mensaje);
												}
											} else {
												//Validación de campo OK
												//KEVIN ROIG: Validacion añadida: Comprobar que la cuenta y contactó estén rellenados
												component.set('v.botonOperativa', nombreBoton);
												if (['Trasladar Colaborador', 'Remitir Colaborador'].includes(nombreBoton)) {
													if ((!component.get('v.AccountId') || !component.get('v.ContactId') && !component.get('v.representanteId')) && !component.get('v.noIdentificado')) {
														helper.mostrarToast('error', 'Datos del Caso', 'Para poder realizar esta operativa, el caso debe estar vinculado a una cuenta, un contacto o un representante');
													} else {
														$A.enqueueAction(component.get('c.abrirModalTrasladarColaborador'));
													}
												} else if (nombreBoton === 'Trasladar 3N') {
													if ((!component.get('v.AccountId') || !component.get('v.ContactId') && !component.get('v.representanteId')) && !component.get('v.noIdentificado')) {
														helper.mostrarToast('error', 'Datos del Caso', 'Para poder realizar esta operativa, el caso debe estar vinculado a una cuenta, un contacto o un representante');
													} else {
														$A.enqueueAction(component.get('c.abrirModalTrasladar3N'));
													}
												} else if (nombreBoton === 'Devolver Nivel 1' || nombreBoton === 'Rechazar Nivel 1') {
													$A.enqueueAction(component.get('c.abrirModalDevolver1N'));
												} else if (nombreBoton === 'Trasladar Incidencia') {

													//Obligatoriedad de campos al trasladar incidencia
													if ((!component.get('v.AccountId') || !component.get('v.ContactId') && !component.get('v.representanteId')) && !component.get('v.noIdentificado') ||
													!component.get('v.canalProcedencia') || !component.get('v.canalEntrada') || !component.get('v.canalOperativo') || !component.get('v.causa') || !component.get('v.solucion')) {
														helper.mostrarToast('error', 'Datos del Caso', 'Debes informar los campos Canal de entrada, Canal de procedencia, Idioma, Tipo de contacto, Canal operativo, Causa y Solución, Cuenta y Contacto');
													} else {
														$A.enqueueAction(component.get('c.abrirQuickActionIncidencia'));
													}
												} else if (['Solicitud Info Email', 'Solicitud Info SMS', 'Solicitud Info Twitter', 'Solicitud Info Apps'].includes(nombreBoton)) {
													if (nombreBoton === 'Solicitud Info Email') {
														if (!component.get('v.canalOperativo') && component.get('v.tipoRegistro') === 'CC_Cliente' ||
														(!component.get('v.AccountId') || !component.get('v.ContactId') && !component.get('v.representanteId')) && !component.get('v.noIdentificado')) {
															helper.mostrarToast('error', 'Datos del Caso', 'Debes informar los campos Canal operativo, Cuenta y Contacto');
														} else {
															$A.enqueueAction(component.get('c.abrirModalSolicitarInfo'));
														}
													} else {
														$A.enqueueAction(component.get('c.abrirModalSolicitarInfo'));
													}
												} else if (['Responder Cliente Email', 'Responder Cliente SMS', 'Responder Cliente Twitter', 'Responder Cliente Apps'].includes(nombreBoton)) {
													if (nombreBoton === 'Responder Cliente Email' && ((!component.get('v.AccountId') || !component.get('v.ContactId') && !component.get('v.representanteId')) && !component.get('v.noIdentificado'))) {
														helper.mostrarToast('error', 'Datos del Caso', 'Para poder realizar esta operativa, el caso debe estar vinculado a una cuenta, un contacto o un representante');
													} else {
														$A.enqueueAction(component.get('c.abrirModalResponderCliente'));
													}
												} else if (nombreBoton === 'botonNotificacionPush') {
													$A.enqueueAction(component.get('c.abrirModalEnviarNotificacion'));
												} else if (nombreBoton === 'botonDeepLinking') {
													component.set('v.motivo', datos.CC_MCC_Motivo__c);
													$A.enqueueAction(component.get('c.abrirModalDeepLink'));
												} else if (nombreBoton === 'GDPR') {
													helper.validacionesGDPR(component, event, recordId);
												} else if (nombreBoton === 'OTP') {
													helper.validacionesOTP(component, event, recordId);
												} else if (nombreBoton === 'IniLync') {
													helper.inicializarLync(component, event, recordId);
												} else if (nombreBoton === 'FinLync') {
													helper.finalizarLync(component, event, recordId);
												} else if (nombreBoton === 'derivarAlSAC') {
													if (!component.get('v.AccountId') || !component.get('v.ContactId') && !component.get('v.representanteId')) {
														helper.mostrarToast('error', 'Datos del Caso', 'Debe informar los siguientes campos obligatorios: Cuenta, Contacto o Representante');
													} else {
														$A.enqueueAction(component.get('c.onClickDerivarAlSac'));
													}
												} else if (nombreBoton === 'devolverAlSAC') {
													if (!component.get('v.AccountId') || !component.get('v.ContactId') && !component.get('v.representanteId')) {
														helper.mostrarToast('error', 'Datos del Caso', 'Debe informar los siguientes campos obligatorios: Cuenta, Contacto o Representante');
													} else {
														$A.enqueueAction(component.get('c.onClickDevolverAlSac'));
													}
												} else if (nombreBoton === 'verClienteConfidencial') {
													//Ini: Condicion añadida por JH para US504352
													$A.enqueueAction(component.get('c.mostrarInfoConfidencial'));
													//Fin: Condicion añadida por JH para US504352
												} else if (nombreBoton === 'Trasladar 2N') {
													if ((!component.get('v.AccountId') || !component.get('v.ContactId') && !component.get('v.representanteId')) && !component.get('v.noIdentificado')) {
														helper.mostrarToast('error', 'Datos del Caso', 'Para poder realizar esta operativa, el caso debe estar vinculado a una cuenta, un contacto o un representante');
													} else {
														$A.enqueueAction(component.get('c.abrirModalTrasladar2N'));
													}
												} else if (['tareaGestor', 'citaGestor', 'operativaOficina'].includes(nombreBoton)) {
													if ((!component.get('v.AccountId') || !component.get('v.ContactId') && !component.get('v.representanteId')) && !component.get('v.noIdentificado')) {
														helper.mostrarToast('error', 'Datos del Caso', 'Para poder realizar esta operativa, el caso debe estar vinculado a una cuenta, un contacto o un representante');
													} else {
														if (nombreBoton === 'tareaGestor') {
															$A.enqueueAction(component.get('c.modalTareaGestorAbrir'));
														} else if (nombreBoton === 'citaGestor') {
															$A.enqueueAction(component.get('c.mmodalCitaGestorAbrir'));
														} else if (nombreBoton === 'operativaOficina') {
															if (!component.get('v.solucion')) {
																helper.mostrarToast('error', 'Datos del Caso', 'Debes informar los campos Causa y Solución');
															} else {
																$A.enqueueAction(component.get('c.handleModalOficina'));
															}
														}
													}
												} else if (nombreBoton === 'cancelarCita') {
													if ((!component.get('v.AccountId') || !component.get('v.ContactId') && !component.get('v.representanteId')) && !component.get('v.noIdentificado')) {
														helper.mostrarToast('error', 'Datos del Caso', 'Para poder realizar esta operativa, el caso debe estar vinculado a una cuenta, un contacto o un representante');
													} else {
														$A.enqueueAction(component.get('c.handleModalCancelarCita'));
													}
												} else if (nombreBoton === 'operativaOnboarding') {
													if ((!component.get('v.AccountId') || !component.get('v.ContactId') && !component.get('v.representanteId')) && !component.get('v.noIdentificado')) {
														helper.mostrarToast('error', 'Datos del Caso', 'Para poder realizar esta operativa, el caso debe estar vinculado a una cuenta, un contacto o un representante');
													} else {
														//Llamada al WS
														//let llamadaWSONB = component.get('c.llamadaWSOnboarding');
														//$A.enqueueAction(llamadaWSONB);
														$A.enqueueAction(component.get('c.modalOnboardingAbrir'));

													}
												}
											}
										}
									});
									$A.enqueueAction(validarCamposCaso);
								}
							} else {
								if (nombreBoton !== 'botonDeepLinking') {
									component.set('v.mostrarBotonesPendienteColaborador', false);
									component.set('v.mostrarBotonesPendienteInterno', false);
									component.set('v.mostrarBotonesPendienteCliente', false);
									helper.mostrarToast('error', 'Operativa no disponible', 'Esta operativa solo está disponible para casos activos');
								} else {
									component.set('v.motivo', datos.CC_MCC_Motivo__c);
									$A.enqueueAction(component.get('c.abrirModalDeepLink'));
								}
							}
						}
					});
					$A.enqueueAction(datosCaso);
				}
			}
		});
		if (nombreBoton === 'operativaOficina') {
			component.set('v.spinnerActivado', false);
		}
		$A.enqueueAction(getEsPropietarioCaso);
	},

	//Funciones referentes al Traslado Colaborador
	abrirModalTrasladarColaborador: function(component, event, helper) {
		if (component.get('v.botonOperativa') === 'Trasladar Colaborador') {
			component.set('v.remitir', false);
			component.set('v.tipoOperativa', 'trasladar');
		} else {
			component.set('v.tipoOperativa', 'remitir');
			component.set('v.remitir', true);
		}
		helper.getPicklistMCCGrupo(component, event, helper);
		$A.util.addClass(component.find('ModalboxColab'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');

		//Poner el foco en el desplegable de grupos al abrir el modal
		if (component.find('selectGroups')) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => component.find('selectGroups').focus()), 1);
		}
	},

	cerrarModalTrasladarColaborador: function(component) {
		if (component.find('selectGroups')) {
			component.find('selectGroups').set('v.value', '');
		}

		component.set('v.plantillaSeleccionadaValue', null);
		component.set('v.plantillaSeleccionadaName', '');
		component.set('v.grupoSeleccionadoValue', '');
		component.set('v.grupoSeleccionadoName', '');
		component.set('v.grupoSeleccionadoId', '');
		component.set('v.actualFirstOptionPlantilla', '');
		component.set('v.actualFirstOptionGrupo', '');
		component.set('v.optionsPlantilla', null);
		component.set('v.optionsGrupo', null);
		component.set('v.verTodosLosGrupos', false);
		component.set('v.grupoSeleccionado', false);
		component.set('v.plantillaEstaSeleccionada', false);
		component.set('v.tipoOperativa', '');

		//limpieza variables
		component.set('v.verGrupos', true);
		component.set('v.verOficinas', false);
		component.set('v.verEmpleados', false);
		component.set('v.verTodasLasOficinas', false);
		component.set('v.noVerOficinas', false);
		component.set('v.noVerEmpleados', false);
		component.set('v.verTodosLosEmpleados', false);
		component.set('v.empleadoSeleccionado', false);
		component.set('v.oficinaSeleccionada', false);
		component.set('v.oficinaGestoraSeleccionada', false);
		component.set('v.empleadoGestorSeleccionado', false);
		component.set('v.SearchKeyWordEmp', '');
		component.set('v.SearchKeyWordOfi', '');
		component.set('v.optionsPlantilla', null);
		component.set('v.SearchKeyWordSegundaOfi', '');
		component.set('v.selectedRecordSegundaOficina', null);

		$A.enqueueAction(component.get('c.deseleccionarPlantilla2'));

		$A.enqueueAction(component.get('c.deseleccionarGrupoColaborador'));

		$A.util.removeClass(component.find('ModalboxColab'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	prepararCuerpoEmail: function(component) {
		let listPara = [];
		let listCC = [];
		let contador = 0; //Utilizado para limitar el numero de copias en traslados y remitidos
		let limiteContador = 0; //En caso de que se haga un traslado/remitido con segunda oficina sera 10 (5 de cada oficina)
		let plantillaName = component.get('v.plantillaSeleccionadaName');
		let oficinaSeleccionada = component.get('v.oficinaSeleccionada');
		let oficinaGestoraSeleccionada = component.get('v.oficinaGestoraSeleccionada');
		let empleadoGestorSeleccionado = component.get('v.empleadoGestorSeleccionado');
		let empleadoSeleccionado = component.get('v.empleadoSeleccionado');
		const segundaOficina = component.get('v.selectedRecordSegundaOficina');
		const segundaOficinaId = segundaOficina ? segundaOficina.Id : null;
		const segundaOficinaName = segundaOficina ? segundaOficina.Name : null;
		const segundaOficinaEmail = segundaOficina ? segundaOficina.CC_Email__c : null;
		if (component.get('v.idBoton') === 'tab1') {
			if (oficinaGestoraSeleccionada && oficinaSeleccionada) {
				//OficinaGestora del cliente
				let buscarEmpleadoOfi = component.get('c.buscarEmpleadoOficina');
				buscarEmpleadoOfi.setParams({
					'idOficina': component.get('v.oficinaGestoraSeleccionadaId'),
					'emailAccountCase': '',
					'nombreAccount': '',
					'flagCamino': true,
					'empleadoGestorId': component.get('v.empleadoGestorId'),
					'idSegundaOficina': segundaOficinaId
				});
				buscarEmpleadoOfi.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						let direcciones = response.getReturnValue();
						if (segundaOficina) {
							limiteContador = 10;
						} else {
							limiteContador = 5;
						}
						for (let indice in direcciones) {
							if (!component.get('v.casoEnSegundoNivel') && !component.get('v.casoEnTercerNivel')) {
								if (contador < limiteContador) {
									listCC.push(indice);
									contador = contador + 1;
								}
							} else {
								listCC.push(indice);
							}
						}
						if (!component.get('v.oficinaGestoraSeleccionadaEmail') && !listCC[0]) {
							while (listCC.length) {
								listCC.pop();
							}
							while (listPara.length) {
								listPara.pop();
							}
						} else if (!listCC[0]) {
							while (listCC.length) {
								listCC.pop();
							}
							listPara.push(component.get('v.oficinaGestoraSeleccionadaEmail'));
							if (component.get('v.selectedRecordSegundaOficina')) {
								listPara.push(component.get('v.selectedRecordSegundaOficina.CC_Email__c'));
							}
						} else if (!component.get('v.oficinaGestoraSeleccionadaEmail')) {
							while (listPara.length) {
								listPara.pop();
							}
						} else {
							listPara.push(component.get('v.oficinaGestoraSeleccionadaEmail'));
							if (component.get('v.selectedRecordSegundaOficina')) {
								listPara.push(segundaOficinaEmail);
							}
						}
						let args = {
							actionName: 'Case.Email_Colaborador',
							targetFields: {
								'ToAddress': {value: listPara},
								'CcAddress': {value: listCC},
								'BccAddress': {value: ''},
								'CC_Grupo_Colab__c': {value: component.get('v.oficinaGestoraSeleccionadaName')},
								'CC_Procedencia__c': {value: 'Traslado Colaborador'},
								'CC_Plantilla__c': {value: plantillaName},
								'CC_Segunda_Oficina__c': {value: segundaOficinaName}
							}
						};
						component.find('quickActionAPI').setActionFieldValues(args);

						//Cerrar modal de traslado a colaborador
						$A.enqueueAction(component.get('c.cerrarModalTrasladarColaborador'));

						//Refrescar la vista
						$A.get('e.force:refreshView').fire();
					}
				});
				$A.enqueueAction(buscarEmpleadoOfi);
			} else if (oficinaSeleccionada && !oficinaGestoraSeleccionada) {
				//Otra oficina
				let buscarEmpleadoOfi = component.get('c.buscarEmpleadoOficina');
				buscarEmpleadoOfi.setParams({
					'idOficina': component.get('v.selectedRecord').Id,
					'emailAccountCase': component.get('v.emailAccountCase'),
					'nombreAccount': component.get('v.nombreAccountCase'),
					'flagCamino': true,
					'empleadoGestorId': component.get('v.empleadoGestorId'),
					'idSegundaOficina': segundaOficinaId
				});

				buscarEmpleadoOfi.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						if (segundaOficina) {
							limiteContador = 10;
						} else {
							limiteContador = 5;
						}
						let direcciones = response.getReturnValue();
						for (let indice in direcciones) {
							if (!component.get('v.casoEnSegundoNivel') && !component.get('v.casoEnTercerNivel')) {
								if (contador < limiteContador) {
									listCC.push(indice);
									contador++;
								}
							} else {
								listCC.push(indice);
							}
						}

						if (!component.get('v.emailParaAux') && !listCC[0]) {
							while (listCC.length) {
								listCC.pop();
							}
							while (listPara.length) {
								listPara.pop();
							}
						} else if (!listCC[0]) {
							while (listCC.length) {
								listCC.pop();
							}
							listPara.push(component.get('v.emailParaAux'));
							if (component.get('v.selectedRecordSegundaOficina')) {
								listPara.push(segundaOficinaEmail);
							}
						} else if (!component.get('v.emailParaAux')) {
							while (listPara.length) {
								listPara.pop();
							}
						} else {
							listPara.push(component.get('v.emailParaAux'));
							if (component.get('v.selectedRecordSegundaOficina')) {
								listPara.push(segundaOficinaEmail);
							}
						}
						let args = {
							actionName: 'Case.Email_Colaborador',
							targetFields: {
								'ToAddress': {value: listPara},
								'CcAddress': {value: listCC},
								'BccAddress': {value: ''},
								'CC_Grupo_Colab__c': {value: component.get('v.selectedRecord').Name},
								'CC_Procedencia__c': {value: 'Traslado Colaborador'},
								'CC_Plantilla__c': {value: plantillaName},
								'CC_Segunda_Oficina__c': {value: segundaOficinaName}
							}
						};
						component.find('quickActionAPI').setActionFieldValues(args);

						//Cerrar modal de traslado a colaborador
						$A.enqueueAction(component.get('c.cerrarModalTrasladarColaborador'));

						//Refrescar la vista
						$A.get('e.force:refreshView').fire();
					}
				});

				$A.enqueueAction(buscarEmpleadoOfi);
			} else if (empleadoSeleccionado && empleadoGestorSeleccionado) {
				let buscarEmpleOfi = component.get('c.buscarEmpleadoOficina');
				buscarEmpleOfi.setParams({
					'idOficina': component.get('v.oficinaGestor'),
					'emailAccountCase': '',
					'nombreAccount': component.get('v.nombreAccountCase'),
					'flagCamino': true,
					'empleadoGestorId': '',
					'idSegundaOficina': null
				});

				buscarEmpleOfi.setCallback(this, responsebuscarEmpleOfi => {
					if (responsebuscarEmpleOfi.getState() === 'SUCCESS') {
						let direcciones = responsebuscarEmpleOfi.getReturnValue();
						for (let indice in direcciones) {
							if (!component.get('v.casoEnSegundoNivel') && !component.get('v.casoEnTercerNivel')) {
								if (contador < limiteContador) {
									listCC.push(indice);
									contador = contador + 1;
								}
							} else {
								listCC.push(indice);
							}
						}

						let obtenerParaOficinaEmpleado = component.get('c.buscarEmpleadoOficina');
						obtenerParaOficinaEmpleado.setParams({
							'idOficina': component.get('v.empleadoGestorId'),
							'emailAccountCase': '',
							'nombreAccount': component.get('v.nombreAccountCase'),
							'flagCamino': false,
							'empleadoGestorId': 'empleado',
							'idSegundaOficina': null
						});
						obtenerParaOficinaEmpleado.setCallback(this, resp => {
							if (resp.getState() === 'SUCCESS') {
								let direccionesPara = resp.getReturnValue();
								let grupoColab = component.get('v.empleadoGestorName');
								for (let indice in direccionesPara) {
									if (Object.prototype.hasOwnProperty.call(direccionesPara, indice)) {
										listPara.push(indice);
									}
								}

								//let para = resp.getReturnValue().paraEmail;
								//let grupoColab = resp.getReturnValue().grupoColab;
								/*if((para == undefined || para == '')
								&&
								!listCC[0]){
									while(listCC.length) {
										listCC.pop();
									}
									while(listPara.length) {
										listPara.pop();
									}
								}
								else if!listCC[0]{
									while(listCC.length) {
										listCC.pop();
									}
								}
								else if(para == undefined || para == ''){
									while(listPara.length) {
										listPara.pop();
									}
								}
								else{
									listPara.push(para);
								}
								*/
								let args = {
									actionName: 'Case.Email_Colaborador',
									targetFields: {
										'ToAddress': {value: listPara},
										'CcAddress': {value: listCC},
										'CC_Grupo_Colab__c': {value: grupoColab},
										'CC_Procedencia__c': {value: 'Traslado Colaborador'},
										'BccAddress': {value: ''},
										'CC_Plantilla__c': {value: plantillaName},
										'CC_Segunda_Oficina__c': {value: null}
									}
								};
								component.find('quickActionAPI').setActionFieldValues(args);

								//Cerrar modal de traslado a colaborador
								$A.enqueueAction(component.get('c.cerrarModalTrasladarColaborador'));

								//Refrescar la vista
								$A.get('e.force:refreshView').fire();
							}
						});
						$A.enqueueAction(obtenerParaOficinaEmpleado);
					}
				});
				$A.enqueueAction(buscarEmpleOfi);
			} else if (empleadoSeleccionado && !empleadoGestorSeleccionado) {
				let buscarEmpleado = component.get('c.buscarEmpleadoOficina');
				buscarEmpleado.setParams({
					'idOficina': component.get('v.selectedRecord').Id,
					'emailAccountCase': '',
					'nombreAccount': component.get('v.nombreAccountCase'),
					'flagCamino': false,
					'empleadoGestorId': '',
					'idSegundaOficina': null
				});
				buscarEmpleado.setCallback(this, responsebuscarEmpleado => {
					if (responsebuscarEmpleado.getState() === 'SUCCESS') {
						let direcciones = responsebuscarEmpleado.getReturnValue();

						for (let indice in direcciones) {
							if (!component.get('v.casoEnSegundoNivel') && !component.get('v.casoEnTercerNivel')) {
								if (contador < limiteContador) {
									listCC.push(indice);
									contador = contador++;
								}
							} else {
								listCC.push(indice);
							}
						}
						let obtenerParaOficinaEmpleado = component.get('c.getAccountFromClient2');
						let idContacto = component.get('v.selectedRecord').Id;
						obtenerParaOficinaEmpleado.setParams({'clienteId': idContacto});
						obtenerParaOficinaEmpleado.setCallback(this, resp => {

							if (resp.getState() === 'SUCCESS') {
								let para = resp.getReturnValue().paraEmail;
								let grupoColab = resp.getReturnValue().grupoColab;
								if (!para && listCC[0]) {
									while (listCC.length) {
										listCC.pop();
									}
									while (listPara.length) {
										listPara.pop();
									}
								} else if (!listCC[0]) {
									while (listCC.length) {
										listCC.pop();
									}
									listPara.push(para);
								} else if (!para) {
									while (listPara.length) {
										listPara.pop();
									}
								} else {
									listPara.push(para);
								}

								let args = {
									actionName: 'Case.Email_Colaborador',
									targetFields: {
										'ToAddress': {value: listPara},
										'CcAddress': {value: listCC},
										'CC_Grupo_Colab__c': {value: grupoColab},
										'CC_Procedencia__c': {value: 'Traslado Colaborador'},
										'BccAddress': {value: ''},
										'CC_Plantilla__c': {value: plantillaName},
										'CC_Segunda_Oficina__c': {value: null}
									}
								};
								component.find('quickActionAPI').setActionFieldValues(args);

								//Cerrar modal de traslado a colaborador
								$A.enqueueAction(component.get('c.cerrarModalTrasladarColaborador'));

								//Refrescar la vista
								$A.get('e.force:refreshView').fire();
							}

						});
						$A.enqueueAction(obtenerParaOficinaEmpleado);
					}

				});
				$A.enqueueAction(buscarEmpleado);
			} else {
				let buscarColaborador = component.get('c.buscarColaborador');
				buscarColaborador.setParams({'idGrupoColaborador': component.get('v.grupoSeleccionadoValue')});
				buscarColaborador.setCallback(this, responseBuscarColaborador => {
					if (responseBuscarColaborador.getState() === 'SUCCESS') {
						let direcciones = responseBuscarColaborador.getReturnValue();
						for (let indice in direcciones) {
							if (direcciones[indice] === 'Para') {
								listPara.push(indice);
							} else if (direcciones[indice] === 'CC') {
								listCC.push(indice);
							}
						}
						component.set('v.myMap', responseBuscarColaborador.getReturnValue());
						if (!listPara[0]) {
							while (listCC.length) {
								listCC.pop();
							}
							while (listPara.length) {
								listPara.pop();
							}
						} else if (listCC[0] === undefined) {
							while (listCC.length) {
								listCC.pop();
							}
						} else if (listPara[0] === undefined) {
							while (listPara.length) {
								listPara.pop();
							}
						}


						let args = {
							actionName: 'Case.Email_Colaborador',
							targetFields: {
								'ToAddress': {value: listPara},
								'CcAddress': {value: listCC},
								'CC_Grupo_Colab__c': {value: component.get('v.grupoSeleccionadoName')},
								'CC_Procedencia__c': {value: 'Traslado Colaborador'},
								'BccAddress': {value: ''},
								'CC_Plantilla__c': {value: plantillaName},
								'CC_Segunda_Oficina__c': {value: null}
							}
						};
						component.find('quickActionAPI').setActionFieldValues(args);

						//Cerrar modal de traslado a colaborador
						$A.enqueueAction(component.get('c.cerrarModalTrasladarColaborador'));

						//Refrescar la vista
						$A.get('e.force:refreshView').fire();
					}
				});
				$A.enqueueAction(buscarColaborador);
			}
		} else if (component.get('v.idBoton') === 'tab2') {

			if (oficinaGestoraSeleccionada && oficinaSeleccionada) {
				//OficinaGestora del cliente
				let buscarEmpleadoOfi = component.get('c.buscarEmpleadoOficina');
				buscarEmpleadoOfi.setParams({
					'idOficina': component.get('v.oficinaGestoraSeleccionadaId'),
					'emailAccountCase': '',
					'nombreAccount': '',
					'flagCamino': true,
					'empleadoGestorId': component.get('v.empleadoGestorId'),
					'idSegundaOficina': segundaOficinaId
				});
				buscarEmpleadoOfi.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						if (segundaOficina) {
							limiteContador = 10;
						} else {
							limiteContador = 5;
						}
						let direcciones = response.getReturnValue();
						for (let indice in direcciones) {
							if (!component.get('v.casoEnSegundoNivel') && !component.get('v.casoEnTercerNivel')) {
								if (contador < limiteContador) {
									listCC.push(indice);
									contador = contador + 1;
								}
							} else {
								listCC.push(indice);
							}
						}
						if (!component.get('v.oficinaGestoraSeleccionadaEmail') && !listCC[0]) {
							while (listCC.length) {
								listCC.pop();
							}
							while (listPara.length) {
								listPara.pop();
							}
						} else if (!listCC[0]) {
							while (listCC.length) {
								listCC.pop();
							}
							listPara.push(component.get('v.oficinaGestoraSeleccionadaEmail'));
							if (component.get('v.selectedRecordSegundaOficina')) {
								listPara.push(component.get('v.selectedRecordSegundaOficina.CC_Email__c'));
							}
						} else if (!component.get('v.oficinaGestoraSeleccionadaEmail')) {
							while (listPara.length) {
								listPara.pop();
							}
						} else {
							listPara.push(component.get('v.oficinaGestoraSeleccionadaEmail'));
							if (component.get('v.selectedRecordSegundaOficina')) {
								listPara.push(component.get('v.selectedRecordSegundaOficina.CC_Email__c'));
							}
						}
						let args = {
							actionName: 'Case.Email_Colaborador',
							targetFields: {
								'ToAddress': {value: listPara},
								'CcAddress': {value: listCC},
								'BccAddress': {value: ''},
								'CC_Grupo_Colab__c': {value: component.get('v.oficinaGestoraSeleccionadaName')},
								'CC_Procedencia__c': {value: 'Remitir Colaborador'},
								'CC_Plantilla__c': {value: plantillaName},
								'CC_Segunda_Oficina__c': {value: segundaOficinaName}
							}
						};
						component.find('quickActionAPI').setActionFieldValues(args);

						//Cerrar modal de traslado a colaborador
						$A.enqueueAction(component.get('c.cerrarModalTrasladarColaborador'));

						//Refrescar la vista
						$A.get('e.force:refreshView').fire();
					}
				});

				$A.enqueueAction(buscarEmpleadoOfi);
			} else if (oficinaSeleccionada && !oficinaGestoraSeleccionada) {
				//Otra oficina
				let buscarEmpleadoOfi = component.get('c.buscarEmpleadoOficina');
				buscarEmpleadoOfi.setParams({
					'idOficina': component.get('v.selectedRecord').Id,
					'emailAccountCase': component.get('v.emailAccountCase'),
					'nombreAccount': component.get('v.nombreAccountCase'),
					'flagCamino': true,
					'empleadoGestorId': component.get('v.empleadoGestorId'),
					'idSegundaOficina': segundaOficinaId
				});

				buscarEmpleadoOfi.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						if (segundaOficina) {
							limiteContador = 10;
						} else {
							limiteContador = 5;
						}
						let direcciones = response.getReturnValue();
						for (let indice in direcciones) {
							if (!component.get('v.casoEnSegundoNivel') && !component.get('v.casoEnTercerNivel')) {
								if (contador < limiteContador) {
									listCC.push(indice);
									contador = contador + 1;
								}
							} else {
								listCC.push(indice);
							}
						}

						if (!component.get('v.emailParaAux') && !listCC[0]) {
							while (listCC.length) {
								listCC.pop();
							}
							while (listPara.length) {
								listPara.pop();
							}
						} else if (!listCC[0]) {
							while (listCC.length) {
								listCC.pop();
							}
							listPara.push(component.get('v.emailParaAux'));
							if (component.get('v.selectedRecordSegundaOficina')) {
								listPara.push(segundaOficinaEmail);
							}
						} else if (!component.get('v.emailParaAux')) {
							while (listPara.length) {
								listPara.pop();
							}
						} else {
							listPara.push(component.get('v.emailParaAux'));
							if (component.get('v.selectedRecordSegundaOficina')) {
								listPara.push(segundaOficinaEmail);
							}
						}

						let args = {
							actionName: 'Case.Email_Colaborador',
							targetFields: {
								'ToAddress': {value: listPara},
								'CcAddress': {value: listCC},
								'BccAddress': {value: ''},
								'CC_Grupo_Colab__c': {value: component.get('v.selectedRecord').Name},
								'CC_Procedencia__c': {value: 'Remitir Colaborador'},
								'CC_Plantilla__c': {value: plantillaName},
								'CC_Segunda_Oficina__c': {value: segundaOficinaName}
							}
						};
						component.find('quickActionAPI').setActionFieldValues(args);

						//Cerrar modal de traslado a colaborador
						$A.enqueueAction(component.get('c.cerrarModalTrasladarColaborador'));

						//Refrescar la vista
						$A.get('e.force:refreshView').fire();
					}
				});

				$A.enqueueAction(buscarEmpleadoOfi);
			} else if (empleadoSeleccionado && empleadoGestorSeleccionado) {
				let buscarEmpleOfi = component.get('c.buscarEmpleadoOficina');
				buscarEmpleOfi.setParams({
					'idOficina': component.get('v.oficinaGestor'),
					'emailAccountCase': '',
					'nombreAccount': component.get('v.nombreAccountCase'),
					'flagCamino': true,
					'empleadoGestorId': '',
					'idSegundaOficina': null
				});
				buscarEmpleOfi.setCallback(this, responsebuscarEmpleOfi => {
					if (responsebuscarEmpleOfi.getState() === 'SUCCESS') {
						let direcciones = responsebuscarEmpleOfi.getReturnValue();
						for (let indice in direcciones) {
							if (!component.get('v.casoEnSegundoNivel') && !component.get('v.casoEnTercerNivel')) {
								if (contador < limiteContador) {
									listCC.push(indice);
									contador = contador + 1;
								}
							} else {
								listCC.push(indice);
							}
						}
						let obtenerParaOficinaEmpleado = component.get('c.getAccountFromClient2');
						let idContacto = component.get('v.empleadoGestorId');
						obtenerParaOficinaEmpleado.setParams({'clienteId': idContacto});
						obtenerParaOficinaEmpleado.setCallback(this, resp => {
							if (resp.getState() === 'SUCCESS') {
								let para = resp.getReturnValue().paraEmail;
								let grupoColab = resp.getReturnValue().grupoColab;
								if (!para && !listCC[0]) {
									while (listCC.length) {
										listCC.pop();
									}
									while (listPara.length) {
										listPara.pop();
									}
								} else if (!listCC[0]) {
									while (listCC.length) {
										listCC.pop();
									}
									listPara.push(para);
								} else if (!para) {
									while (listPara.length) {
										listPara.pop();
									}
								} else {
									listPara.push(para);
								}

								let args = {
									actionName: 'Case.Email_Colaborador',
									targetFields: {
										'ToAddress': {value: listPara},
										'CcAddress': {value: listCC},
										'CC_Grupo_Colab__c': {value: grupoColab},
										'CC_Procedencia__c': {value: 'Remitir Colaborador'},
										'BccAddress': {value: ''},
										'CC_Plantilla__c': {value: plantillaName},
										'CC_Segunda_Oficina__c': {value: null}
									}
								};
								component.find('quickActionAPI').setActionFieldValues(args);

								//Cerrar modal de traslado a colaborador
								$A.enqueueAction(component.get('c.cerrarModalTrasladarColaborador'));

								//Refrescar la vista
								$A.get('e.force:refreshView').fire();
							}
						});
						$A.enqueueAction(obtenerParaOficinaEmpleado);
					}

				});
				$A.enqueueAction(buscarEmpleOfi);
			} else if (empleadoSeleccionado && !empleadoGestorSeleccionado) {
				let buscarEmpleado = component.get('c.buscarEmpleadoOficina');
				buscarEmpleado.setParams({
					'idOficina': component.get('v.selectedRecord').Id,
					'emailAccountCase': '',
					'nombreAccount': component.get('v.nombreAccountCase'),
					'flagCamino': false,
					'empleadoGestorId': '',
					'idSegundaOficina': null
				});
				buscarEmpleado.setCallback(this, responsebuscarEmpleado => {
					if (responsebuscarEmpleado.getState() === 'SUCCESS') {
						let direcciones = responsebuscarEmpleado.getReturnValue();

						for (let indice in direcciones) {
							if (!component.get('v.casoEnSegundoNivel') && !component.get('v.casoEnTercerNivel')) {
								if (contador < limiteContador) {
									listCC.push(indice);
									contador = contador + 1;
								}
							} else {
								listCC.push(indice);
							}
						}
						let obtenerParaOficinaEmpleado = component.get('c.getAccountFromClient2');
						let idContacto = component.get('v.selectedRecord').Id;
						obtenerParaOficinaEmpleado.setParams({clienteId: idContacto});
						obtenerParaOficinaEmpleado.setCallback(this, resp => {

							if (resp.getState() === 'SUCCESS') {
								let para = resp.getReturnValue().paraEmail;
								let grupoColab = resp.getReturnValue().grupoColab;
								if (!para && !listCC[0]) {
									while (listCC.length) {
										listCC.pop();
									}
									while (listPara.length) {
										listPara.pop();
									}
								} else if (!listCC[0]) {
									while (listCC.length) {
										listCC.pop();
									}
									listPara.push(para);
								} else if (!para) {
									while (listPara.length) {
										listPara.pop();
									}
								} else {
									listPara.push(para);
								}

								let args = {
									actionName: 'Case.Email_Colaborador',
									targetFields: {
										'ToAddress': {value: listPara},
										'CcAddress': {value: listCC},
										'CC_Grupo_Colab__c': {value: grupoColab},
										'CC_Procedencia__c': {value: 'Remitir Colaborador'},
										'BccAddress': {value: ''},
										'CC_Plantilla__c': {value: plantillaName},
										'CC_Segunda_Oficina__c': {value: null}
									}
								};
								component.find('quickActionAPI').setActionFieldValues(args);

								//Cerrar modal de traslado a colaborador
								$A.enqueueAction(component.get('c.cerrarModalTrasladarColaborador'));

								//Refrescar la vista
								$A.get('e.force:refreshView').fire();
							}

						});
						$A.enqueueAction(obtenerParaOficinaEmpleado);
					}

				});
				$A.enqueueAction(buscarEmpleado);
			} else {
				let grupoSeleccionadoName = component.get('v.grupoSeleccionadoName');

				let buscarColaborador = component.get('c.buscarColaborador');
				buscarColaborador.setParams({'idGrupoColaborador': component.get('v.grupoSeleccionadoValue')});
				buscarColaborador.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						let direcciones = response.getReturnValue();
						for (let indice in direcciones) {
							if (direcciones[indice] === 'Para') {
								listPara.push(indice);
							} else if (direcciones[indice] === 'CC') {
								listCC.push(indice);
							}
						}
						component.set('v.myMap', response.getReturnValue());
						if (!listPara[0]) {
							while (listCC.length) {
								listCC.pop();
							}
							while (listPara.length) {
								listPara.pop();
							}
						} else if (listCC[0] === undefined) {
							while (listCC.length) {
								listCC.pop();
							}
						} else if (listPara[0] === undefined) {
							while (listPara.length) {
								listPara.pop();
							}
						}

						//Preparar borrador de correo con la plantilla seleccionada
						let args = {
							actionName: 'Case.Email_Colaborador',
							targetFields: {
								'ToAddress': {value: listPara},
								'CcAddress': {value: listCC},
								'CC_Grupo_Colab__c': {value: grupoSeleccionadoName},
								'CC_Procedencia__c': {value: 'Remitir Colaborador'},
								'BccAddress': {value: ''},
								'CC_Plantilla__c': {value: plantillaName},
								'CC_Segunda_Oficina__c': {value: null}
							}
						};
						component.find('quickActionAPI').setActionFieldValues(args);
					}
				});
				$A.enqueueAction(buscarColaborador);

				//Cerrar modal de remitir a colaborador
				$A.enqueueAction(component.get('c.cerrarModalTrasladarColaborador'));
				$A.get('e.force:refreshView').fire();
			}
		}
	},

	trasladarColaborador: function(component, event) {
		let buttonClicked = event.getSource().getLocalId();
		component.set('v.idBoton', buttonClicked);
		let plantilla = '';
		let nombrePlantilla = '';
		let plantillaName = '';
		if (!component.get('v.casoEnSegundoNivel') && !component.get('v.casoEnTercerNivel')) {
			let oficinaSeleccionada = component.get('v.oficinaSeleccionada');
			let oficinaGestoraSeleccionada = component.get('v.oficinaGestoraSeleccionada');
			let oficinaCaso = component.get('c.oficinaPermiteTrasladarRemitir');
			oficinaCaso.setParams({'recordId': component.get('v.recordId'), 'otraOficina': oficinaGestoraSeleccionada, 'oficinaSeleccionada': component.get('v.selectedRecord.Name')});
			oficinaCaso.setCallback(this, function(responseOficinaAccount) {
				if (responseOficinaAccount.getState() === 'SUCCESS') {
					let oficina = responseOficinaAccount.getReturnValue();
					component.set('v.oficinaAccount', oficina);
					if (oficinaSeleccionada && (oficinaGestoraSeleccionada || !oficinaGestoraSeleccionada)) {
						if (!component.get('v.oficinaAccount')) {
							let toastEvent = $A.get('e.force:showToast');
							toastEvent.setParams({title: 'Oficina no permitida', message: 'No se puede realizar la operativa con esta oficina.', type: 'error', mode: 'dismissable', duration: '4000'});
							toastEvent.fire();
						} else {
							if (component.get('v.uncheckedPlantilla')) {
								plantilla = component.get('v.selectedRecordPlantilla.Id');
								nombrePlantilla = component.get('v.selectedRecordPlantilla.Name');
								component.set('v.plantillaSeleccionadaValue', plantilla);
								component.set('v.plantillaSeleccionadaName', nombrePlantilla);
								plantillaName = component.get('v.plantillaSeleccionadaName');
							}

							//Se guarda el nombre de la plantilla para poder enviar el correo, con la plantilla correspondiente
							let actualizarCaso = component.get('c.actualizarCaso');
							actualizarCaso.setParams({
								'idCaso': component.get('v.recordId'),
								'plantilla': component.get('v.plantillaSeleccionadaValue'),
								'informarReferenciaCorreo': true,
								'tratamiento': '',
								'operativa': component.get('v.tipoOperativa'),
								'canalRespuesta': 'Email',
								'canalProcedencia': component.get('v.tipoOperativa'),
								'tipoRegistro': component.get('v.tipoRegistro')
							});
							actualizarCaso.setCallback(this, response => {
								if (response.getState() === 'SUCCESS') {
									//Caso actualizado, se prepara el borrador de correo
									$A.enqueueAction(component.get('c.prepararCuerpoEmail'));
								}
							});
							$A.enqueueAction(actualizarCaso);
						}
					} else if (!oficinaSeleccionada) {
						if (component.get('v.uncheckedPlantilla')) {
							plantilla = component.get('v.selectedRecordPlantilla.Id');
							nombrePlantilla = component.get('v.selectedRecordPlantilla.Name');
							component.set('v.plantillaSeleccionadaValue', plantilla);
							component.set('v.plantillaSeleccionadaName', nombrePlantilla);
							plantillaName = component.get('v.plantillaSeleccionadaName');
						}

						//Se guarda el nombre de la plantilla para poder enviar el correo, con la plantilla correspondiente
						let actualizarCaso = component.get('c.actualizarCaso');
						actualizarCaso.setParams({
							'idCaso': component.get('v.recordId'),
							'plantilla': component.get('v.plantillaSeleccionadaValue'),
							'informarReferenciaCorreo': true,
							'tratamiento': '',
							'operativa': component.get('v.tipoOperativa'),
							'canalRespuesta': 'Email',
							'canalProcedencia': component.get('v.tipoOperativa'),
							'tipoRegistro': component.get('v.tipoRegistro')
						});
						actualizarCaso.setCallback(this, response => {
							if (response.getState() === 'SUCCESS') {
								//Caso actualizado, se prepara el borrador de correo
								$A.enqueueAction(component.get('c.prepararCuerpoEmail'));
							}
						});
						$A.enqueueAction(actualizarCaso);
					}
				}
			});
			$A.enqueueAction(oficinaCaso);
		} else {
			if (component.get('v.uncheckedPlantilla')) {
				plantilla = component.get('v.selectedRecordPlantilla.Id');
				nombrePlantilla = component.get('v.selectedRecordPlantilla.Name');
				component.set('v.plantillaSeleccionadaValue', plantilla);
				component.set('v.plantillaSeleccionadaName', nombrePlantilla);
			}

			//Se guarda el nombre de la plantilla para poder enviar el correo, con la plantilla correspondiente
			let actualizarCaso = component.get('c.actualizarCaso');
			actualizarCaso.setParams({
				'idCaso': component.get('v.recordId'),
				'plantilla': component.get('v.plantillaSeleccionadaValue'),
				'informarReferenciaCorreo': true,
				'tratamiento': '',
				'operativa': component.get('v.tipoOperativa'),
				'canalRespuesta': 'Email',
				'canalProcedencia': component.get('v.tipoOperativa'),
				'tipoRegistro': component.get('v.tipoRegistro')
			});
			actualizarCaso.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					//Caso actualizado, se prepara el borrador de correo
					$A.enqueueAction(component.get('c.prepararCuerpoEmail'));
				}
			});
			$A.enqueueAction(actualizarCaso);
		}
	},

	teclaPulsadaLookupGrupoColaborador: function(component, event, helper) {
		let searchRes = component.find('searchRes');
		if (component.get('v.SearchKeyWord').length > 0) {
			$A.util.addClass(searchRes, 'slds-is-open');
			$A.util.removeClass(searchRes, 'slds-is-close');
			helper.buscarListas(component, event, component.get('v.SearchKeyWord'), 'grupo');
		} else {
			$A.util.addClass(searchRes, 'slds-is-close');
			$A.util.removeClass(searchRes, 'slds-is-open');
			component.set('v.listOfSearchRecords', null);
		}
	},

	teclaPulsadaLookupOficina: function(component, event, helper) {
		let searchRes = component.find('searchRes2');
		if (component.get('v.SearchKeyWordOfi')) {
			$A.util.addClass(searchRes, 'slds-is-open');
			$A.util.removeClass(searchRes, 'slds-is-close');
			helper.buscarListas(component, event, component.get('v.SearchKeyWordOfi'), 'oficina');
		} else {
			$A.util.addClass(searchRes, 'slds-is-close');
			$A.util.removeClass(searchRes, 'slds-is-open');
			component.set('v.listOfSearchRecordsOfi', null);
		}
	},

	teclaPulsadaLookup2aOficina: function(component, event, helper) {
		let searchResSegundaOfi = component.find('searchResSegundaOfi');
		if (component.get('v.SearchKeyWordSegundaOfi')) {
			$A.util.addClass(searchResSegundaOfi, 'slds-is-open');
			$A.util.removeClass(searchResSegundaOfi, 'slds-is-close');
			helper.buscarListas(component, event, component.get('v.SearchKeyWordSegundaOfi'), 'segundaOficina');
		} else {
			$A.util.addClass(searchResSegundaOfi, 'slds-is-close');
			$A.util.removeClass(searchResSegundaOfi, 'slds-is-open');
			component.set('v.listOfSearchRecords2aOfi', null);
		}
	},

	teclaPulsadaLookupEmpleado: function(component, event, helper) {
		let searchRes = component.find('searchRes3');
		if (component.get('v.SearchKeyWordEmp').length > 0) {
			$A.util.addClass(searchRes, 'slds-is-open');
			$A.util.removeClass(searchRes, 'slds-is-close');
			helper.buscarListas(component, event, component.get('v.SearchKeyWordEmp'), 'empleado');
		} else {
			$A.util.addClass(searchRes, 'slds-is-close');
			$A.util.removeClass(searchRes, 'slds-is-open');
			component.set('v.listOfSearchRecordsEmpl', null);
		}
	},
	obtenerPlantillasGrupo: function(component, event) {
		let grupoId;
		if (component.get('v.verTodosLosGrupos')) {
			grupoId = component.get('v.selectedRecord.Id');
			component.set('v.grupoSeleccionadoValue', grupoId);
			component.set('v.grupoSeleccionadoName', component.get('v.selectedRecord.Name'));
		} else {
			grupoId = event.getParam('value');
			component.set('v.actualFirstOptionGrupo', grupoId);
			let picklistFirstOptionsGrupo = component.get('v.optionsGrupo');
			for (let key in picklistFirstOptionsGrupo) {
				if (grupoId === picklistFirstOptionsGrupo[key].value) {
					component.set('v.grupoSeleccionadoValue', picklistFirstOptionsGrupo[key].value);
					component.set('v.grupoSeleccionadoName', picklistFirstOptionsGrupo[key].label);
				}
			}
		}

		let action = component.get('c.getPlantillaGrupoList');
		action.setParams({'grupoId': grupoId, 'tipoOperativa': component.get('v.tipoOperativa')});
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.optionsPlantilla', response.getReturnValue());
				component.set('v.grupoSeleccionado', true);
			}
		});
		$A.enqueueAction(action);
	},

	deseleccionarGrupoColaborador: function(component) {
		//Eliminar el grupo seleccionado
		let pillTarget = component.find('lookup-pill');
		$A.util.addClass(pillTarget, 'slds-hide');
		$A.util.removeClass(pillTarget, 'slds-show');

		let lookUpTarget = component.find('lookupField');
		$A.util.addClass(lookUpTarget, 'slds-show');
		$A.util.removeClass(lookUpTarget, 'slds-hide');

		component.set('v.SearchKeyWord', null);
		component.set('v.listOfSearchRecords', null);
		component.set('v.grupoSeleccionado', false);
		component.set('v.plantillaEstaSeleccionada', false);
	},
	deseleccionarOficina: function(component) {
		let pillTarget = component.find('lookup-pill-2');
		$A.util.addClass(pillTarget, 'slds-hide');
		$A.util.removeClass(pillTarget, 'slds-show');

		let lookUpTarget = component.find('lookupField2');
		$A.util.addClass(lookUpTarget, 'slds-show');
		$A.util.removeClass(lookUpTarget, 'slds-hide');

		component.set('v.SearchKeyWordOfi', null);
		component.set('v.listOfSearchRecordsOfi', null);
		component.set('v.oficinaSeleccionada', false);
		component.set('v.plantillaEstaSeleccionada', false);
	},
	deseleccionarEmpleado: function(component) {
		let pillTarget = component.find('lookup-pill-3');
		$A.util.addClass(pillTarget, 'slds-hide');
		$A.util.removeClass(pillTarget, 'slds-show');

		let lookUpTarget = component.find('lookupField3');
		$A.util.addClass(lookUpTarget, 'slds-show');
		$A.util.removeClass(lookUpTarget, 'slds-hide');

		component.set('v.SearchKeyWordEmp', null);
		component.set('v.listOfSearchRecordsEmpl', null);
		component.set('v.empleadoSeleccionado', false);
		component.set('v.plantillaEstaSeleccionada', false);
	},

	//Funciones referentes al Remitir Colaborador
	remitirColaborador: function(component, event) {
		let buttonClicked = event.getSource().getLocalId();
		component.set('v.idBoton', buttonClicked);

		let plantilla = '';
		let nombrePlantilla = '';
		let plantillaName = '';
		if (!component.get('v.casoEnSegundoNivel') && !component.get('v.casoEnTercerNivel')) {
			let oficinaSeleccionada = component.get('v.oficinaSeleccionada');
			let oficinaGestoraSeleccionada = component.get('v.oficinaGestoraSeleccionada');
			let oficinaCaso = component.get('c.oficinaPermiteTrasladarRemitir');
			oficinaCaso.setParams({'recordId': component.get('v.recordId'), 'otraOficina': oficinaGestoraSeleccionada, 'oficinaSeleccionada': component.get('v.selectedRecord.Name')});

			oficinaCaso.setCallback(this, function(responseOficinaAccount) {
				if (responseOficinaAccount.getState() === 'SUCCESS') {
					let oficina = responseOficinaAccount.getReturnValue();
					component.set('v.oficinaAccount', oficina);
					if (oficinaSeleccionada && (oficinaGestoraSeleccionada || !oficinaGestoraSeleccionada)) {
						if (!component.get('v.oficinaAccount')) {
							let toastEvent = $A.get('e.force:showToast');
							toastEvent.setParams({title: 'Oficina no permitida', message: 'No se puede realizar la operativa con esta oficina.', type: 'error', mode: 'dismissable', duration: '4000'});
							toastEvent.fire();
						} else {
							if (component.get('v.uncheckedPlantilla')) {
								plantilla = component.get('v.selectedRecordPlantilla.Id');
								nombrePlantilla = component.get('v.selectedRecordPlantilla.Name');
								component.set('v.plantillaSeleccionadaValue', plantilla);
								component.set('v.plantillaSeleccionadaName', nombrePlantilla);
								plantillaName = component.get('v.plantillaSeleccionadaName');
							}

							//Se guarda el nombre de la plantilla para poder enviar el correo, con la plantilla correspondiente
							let actualizarCaso = component.get('c.actualizarCaso');
							actualizarCaso.setParams({
								'idCaso': component.get('v.recordId'),
								'plantilla': component.get('v.plantillaSeleccionadaValue'),
								'informarReferenciaCorreo': true,
								'tratamiento': '',
								'operativa': component.get('v.tipoOperativa'),
								'canalRespuesta': 'Email',
								'canalProcedencia': component.get('v.canalProcedencia'),
								'tipoRegistro': component.get('v.tipoRegistro')
							});
							actualizarCaso.setCallback(this, response => {
								if (response.getState() === 'SUCCESS') {
									//Caso actualizado, se prepara el borrador de correo
									$A.enqueueAction(component.get('c.prepararCuerpoEmail'));
								}
							});
							$A.enqueueAction(actualizarCaso);
						}
					} else if (!oficinaSeleccionada) {
						if (component.get('v.uncheckedPlantilla')) {
							plantilla = component.get('v.selectedRecordPlantilla.Id');
							nombrePlantilla = component.get('v.selectedRecordPlantilla.Name');
							component.set('v.plantillaSeleccionadaValue', plantilla);
							component.set('v.plantillaSeleccionadaName', nombrePlantilla);
							plantillaName = component.get('v.plantillaSeleccionadaName');
						}

						//Se guarda el nombre de la plantilla para poder enviar el correo, con la plantilla correspondiente
						let actualizarCaso = component.get('c.actualizarCaso');
						actualizarCaso.setParams({
							'idCaso': component.get('v.recordId'),
							'plantilla': component.get('v.plantillaSeleccionadaValue'),
							'informarReferenciaCorreo': true,
							'tratamiento': '',
							'operativa': component.get('v.tipoOperativa'),
							'canalRespuesta': 'Email',
							'canalProcedencia': component.get('v.canalProcedencia'),
							'tipoRegistro': component.get('v.tipoRegistro')
						});
						actualizarCaso.setCallback(this, response => {
							if (response.getState() === 'SUCCESS') {
								//Caso actualizado, se prepara el borrador de correo
								$A.enqueueAction(component.get('c.prepararCuerpoEmail'));
							}
						});
						$A.enqueueAction(actualizarCaso);
					}
				}
			});
			$A.enqueueAction(oficinaCaso);
		} else {
			if (component.get('v.uncheckedPlantilla')) {
				plantilla = component.get('v.selectedRecordPlantilla.Id');
				nombrePlantilla = component.get('v.selectedRecordPlantilla.Name');
				component.set('v.plantillaSeleccionadaValue', plantilla);
				component.set('v.plantillaSeleccionadaName', nombrePlantilla);
			}

			//Actualización del caso con la referencia de correo saliente
			let actualizarCaso = component.get('c.actualizarCaso');
			actualizarCaso.setParams({
				'idCaso': component.get('v.recordId'),
				'plantilla': component.get('v.plantillaSeleccionadaValue'),
				'informarReferenciaCorreo': true,
				'tratamiento': '',
				'operativa': component.get('v.tipoOperativa'),
				'canalRespuesta': 'Email',
				'canalProcedencia': component.get('v.canalProcedencia'),
				'tipoRegistro': component.get('v.tipoRegistro')
			});
			$A.enqueueAction(actualizarCaso);

			//Recuperar destinatarios
			$A.enqueueAction(component.get('c.prepararCuerpoEmail'));
		}
	},

	abrirModalSolicitarInfo: function(component, event, helper) {
		//Solo se abre el modal de Solicitar info si el canal de respuesta es Email, Chat o vacío y si el campo canal operativa esta definido.
		let canalRespuesta = component.get('v.canalRespuesta');
		let canalOperativo = component.get('v.canalOperativo');
		if (!canalRespuesta || ['Email', 'Chat', 'Phone', 'Backoffice'].includes(canalRespuesta)) {
			component.set('v.tipoOperativa', 'solicitar');
			helper.loadCarpetasIdioma(component, event, helper);
			$A.util.addClass(component.find('ModalboxSolicitarInfo'), 'slds-fade-in-open');
			$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		} else if (canalRespuesta === 'Twitter' && canalOperativo !== null) {
			let actionAPI = component.find('quickActionAPI');
			let args = {actionName: 'Case.SocialPublisher', targetFields: {'CC_Solicitud_Informacion__c': {value: true}}};
			actionAPI.selectAction(args).then(() => {
				actionAPI.setActionFieldValues(args);
			});
		}
	},

	cerrarModalSolicitarInfo: function(component) {
		let selectItemIdioma = component.find('selectItemIdiomaSol').get('v.value');
		if (selectItemIdioma) {
			component.find('selectItemIdiomaSol').set('v.value', null);
			let selectItemTratamiento = component.find('selectItemTratamientoSol').get('v.value');
			if (selectItemTratamiento) {
				component.find('selectItemTratamientoSol').set('v.value', null);
				let selectItemPlantilla = component.find('selectItemPlantillaSol').get('v.value');
				if (selectItemPlantilla) {
					component.find('selectItemPlantillaSol').set('v.value', null);
				}
			}
		}

		//Cierra el modal de Solicitud de información
		/*component.find('plantillaSeleccionadaSolicitud').set('v.value', '');*/
		component.set('v.plantillaSeleccionadaValue', null);
		component.set('v.plantillaSeleccionadaName', '');
		component.set('v.actualFirstOptionPlantillaSolicitud', '');
		component.set('v.optionsPlantillaSolicitud', null);
		component.set('v.carpetaIdioma', '');
		component.set('v.carpetaIdiomaSeleccionada', false);
		component.set('v.opcionesIdiomaFolder', null);
		component.set('v.opcionesTratamientoFolder', null);
		component.set('v.carpetaFinal', null);
		component.set('v.procesoFinalSeleccion', false);
		component.set('v.tipoOperativa', '');

		let cmpTarget = component.find('ModalboxSolicitarInfo');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');

		let cmpBack = component.find('backdrop');
		$A.util.removeClass(cmpBack, 'slds-backdrop--open');
	},

	solicitarInfo: function(component) {
		let recordId = component.get('v.recordId');
		let plantilla = component.get('v.plantillaSeleccionadaValue');
		let plantillaName = component.get('v.plantillaSeleccionadaName');
		let operativa = component.get('v.tipoOperativa');
		let canalProcedencia = component.get('v.canalProcedencia');

		let update = component.get('c.actualizarCaso');
		update.setParams({
			'idCaso': recordId,
			'plantilla': plantilla,
			'informarReferenciaCorreo': true,
			'tratamiento': '',
			'operativa': operativa,
			'canalRespuesta': component.get('v.canalRespuesta'),
			'canalProcedencia': canalProcedencia,
			'tipoRegistro': component.get('v.tipoRegistro')
		});
		$A.enqueueAction(update);

		let action = component.get('c.buscarCorreoContacto');
		action.setParams({'idCaso': component.get('v.recordId')});
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let actionAPI = component.find('quickActionAPI');
				let args = {
					actionName: 'Case.Email_Colaborador',
					targetFields: {
						'ToAddress': {value: response.getReturnValue()},
						'CC_Procedencia__c': {value: 'Solicitud Información'},
						'BccAddress': {value: ''},
						'CcAddress': {value: ''},
						'CC_Plantilla__c': {value: plantillaName}
					}
				};
				actionAPI.setActionFieldValues(args);
			}
		});
		$A.enqueueAction(action);

		//Cierre del modal
		let close = component.get('c.cerrarModalSolicitarInfo');
		$A.enqueueAction(close);
		$A.get('e.force:refreshView').fire();
	},

	//Funciones referentes al Trasladar a 3N
	abrirModalTrasladar3N: function(component, event, helper) {

		$A.util.addClass(component.find('Modalbox3Nivel'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		helper.getPicklistMCCGrupo3N(component, event, helper);

		if (component.find('selectGroups3N')) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => component.find('selectGroups3N').focus()), 50);
		}
	},

	seleccionarGrupo3N: function(component, event) {
		let unchecked = component.get('v.verTodosLosGrupos3N');
		let grupoId = '';
		let grupoName = '';
		if (unchecked) {
			grupoId = component.get('v.selectedRecord.Id');
			grupoName = component.get('v.selectedRecord.Name');
			component.set('v.grupoSeleccionadoValue', grupoId);
			component.set('v.grupoSeleccionadoName', grupoName);
		} else {
			grupoId = event.getParam('value');
			component.set('v.actualFirstOptionGrupo', grupoId);
			let picklistFirstOptionsGrupo = component.get('v.optionsGrupo3N');
			for (let key in picklistFirstOptionsGrupo) {
				if (grupoId === picklistFirstOptionsGrupo[key].value) {
					component.set('v.grupoSeleccionadoValue', picklistFirstOptionsGrupo[key].value);
					component.set('v.grupoSeleccionadoName', picklistFirstOptionsGrupo[key].label);
					component.set('v.grupoSeleccionadoId', picklistFirstOptionsGrupo[key].idRegistro);
				}
			}
		}
	},

	cerrarModalTrasladar3N: function(component) {

		if (component.find('selectGroups3N')) {
			component.find('selectGroups3N').set('v.value', '');
		}

		component.set('v.grupoSeleccionadoValue', '');
		component.set('v.grupoSeleccionadoName', '');
		component.set('v.grupoSeleccionadoId', '');
		component.set('v.actualFirstOptionGrupo', '');
		component.set('v.optionsGrupo3N', null);
		component.set('v.verTodosLosGrupos3N', false);
		component.set('v.grupoSeleccionado', false);

		let modalbox3Nivel = component.find('Modalbox3Nivel');
		$A.util.removeClass(modalbox3Nivel, 'slds-fade-in-open');

		let modalbackdrop3Nivel = component.find('backdrop');
		$A.util.removeClass(modalbackdrop3Nivel, 'slds-backdrop--open');

		let deseleccionarGrupo3N = component.get('c.deseleccionarGrupo3N');
		$A.enqueueAction(deseleccionarGrupo3N);
	},

	teclaPulsadaLookupGrupo3N: function(component, event, helper) {
		let getInputkeyWordGroup = component.get('v.SearchKeyWordGroup');
		if (getInputkeyWordGroup.length > 0) {
			$A.util.addClass(component.find('searchResGroup'), 'slds-is-open');
			$A.util.removeClass(component.find('searchResGroup'), 'slds-is-close');
			helper.buscarGrupos3N(component, event, getInputkeyWordGroup);
		} else {
			component.set('v.listOfSearchRecordsGroup', null);
			$A.util.addClass(component.find('searchResGroup'), 'slds-is-close');
			$A.util.removeClass(component.find('searchResGroup'), 'slds-is-open');
		}
	},

	trasladar3N: function(component, event, helper) {
		component.set('v.deshabilitarEscalar', true);
		let recordId = component.get('v.recordId');
		let colaName;
		let grupoName;
		let grupoId;
		let unchecked = component.get('v.verTodosLosGrupos3N');
		if (unchecked) {
			colaName = component.get('v.selectedRecordGroup.CC_Queue_Traslado__c');
			grupoName = component.get('v.ultimoGrupo3N');
			grupoId =  component.get('v.ultimoGrupo3NId');
		} else {
			colaName = component.get('v.grupoSeleccionadoValue');
			grupoName = component.get('v.grupoSeleccionadoName');
			grupoId = component.get('v.grupoSeleccionadoId');
		}

		let tipoGestion = component.get('v.tipoGestion3N');
		let comentario = '';

		let guardarTipoGestion = component.get('c.guardaTipoGestion');
		guardarTipoGestion.setParams({'sIdCaso': recordId, 'tipoGestion': tipoGestion});
		guardarTipoGestion.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				//alert('test');
				let cambiarPropietario = component.get('c.cambiarPropietario');
				cambiarPropietario.setParams({'grupoName': grupoName, 'colaName': colaName, 'recordId': recordId, 'comentario': comentario, 'grupoId': grupoId});
				cambiarPropietario.setCallback(this, responseCambiarPropietario => {
					if (responseCambiarPropietario.getState() === 'SUCCESS') {
						let close = component.get('c.cerrarModalTrasladar3N');
						component.set('v.casoEnTercerNivel', true);
						$A.enqueueAction(close);
						helper.getDatosCaso(component);
						$A.get('e.force:refreshView').fire();
					}
				});
				$A.enqueueAction(cambiarPropietario);
			}
		});
		$A.enqueueAction(guardarTipoGestion);
	},

	deseleccionarGrupo3N: function(component) {
		let pillTarget = component.find('lookup-pill-group');
		$A.util.addClass(pillTarget, 'slds-hide');
		$A.util.removeClass(pillTarget, 'slds-show');

		let lookUpTarget = component.find('lookupFieldGroup');
		$A.util.addClass(lookUpTarget, 'slds-show');
		$A.util.removeClass(lookUpTarget, 'slds-hide');

		component.set('v.SearchKeyWordGroup', null);
		component.set('v.listOfSearchRecordsGroup', null);

		let tipoGestion = document.getElementsByClassName('tipoGestion');
		tipoGestion[0].style.display = 'none';
		component.set('v.tipoGestion3N', '');
	},

	//Funciones referentes al Trasladar a 2N
	abrirModalTrasladar2N: function(component, event, helper) {

		$A.util.addClass(component.find('Modalbox2Nivel'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		helper.getPicklistMCCGrupo2N(component, event, helper);

		if (component.find('selectGroups2N')) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => component.find('selectGroups2N').focus()), 50);
		}
	},

	seleccionarGrupo2N: function(component, event) {
		let unchecked = component.get('v.verTodosLosGrupos2N');
		let grupoId = '';
		let grupoName = '';
		if (unchecked) {
			grupoId = component.get('v.selectedRecord.Id');
			grupoName = component.get('v.selectedRecord.Name');
			component.set('v.grupoSeleccionadoValue', grupoId);
			component.set('v.grupoSeleccionadoName', grupoName);
		} else {
			grupoId = event.getParam('value');
			component.set('v.actualFirstOptionGrupo', grupoId);
			let picklistFirstOptionsGrupo = component.get('v.optionsGrupo2N');
			for (let key in picklistFirstOptionsGrupo) {
				if (grupoId === picklistFirstOptionsGrupo[key].value) {
					component.set('v.grupoSeleccionadoValue', picklistFirstOptionsGrupo[key].value);
					component.set('v.grupoSeleccionadoName', picklistFirstOptionsGrupo[key].label);
					component.set('v.grupoSeleccionadoId', picklistFirstOptionsGrupo[key].idRegistro);
				}
			}
		}
	},

	cerrarModalTrasladar2N: function(component) {

		if (component.find('selectGroups2N')) {
			component.find('selectGroups2N').set('v.value', '');
		}

		component.set('v.grupoSeleccionadoValue', '');
		component.set('v.grupoSeleccionadoName', '');
		component.set('v.grupoSeleccionadoId', '');
		component.set('v.actualFirstOptionGrupo', '');
		component.set('v.optionsGrupo2N', null);
		component.set('v.verTodosLosGrupos2N', false);
		component.set('v.grupoSeleccionado', false);

		let modalbox2Nivel = component.find('Modalbox2Nivel');
		$A.util.removeClass(modalbox2Nivel, 'slds-fade-in-open');

		let modalbackdrop2Nivel = component.find('backdrop');
		$A.util.removeClass(modalbackdrop2Nivel, 'slds-backdrop--open');

		let deseleccionarGrupo2N = component.get('c.deseleccionarGrupo2N');
		$A.enqueueAction(deseleccionarGrupo2N);
	},

	teclaPulsadaLookupGrupo2N: function(component, event, helper) {
		let getInputkeyWordGroup = component.get('v.SearchKeyWordGroup');

		if (getInputkeyWordGroup.length > 0) {
			$A.util.addClass(component.find('searchResGroup2N'), 'slds-is-open');
			$A.util.removeClass(component.find('searchResGroup2N'), 'slds-is-close');
			helper.buscarGrupos2N(component, event, getInputkeyWordGroup);
		} else {
			component.set('v.listOfSearchRecordsGroup', null);
			$A.util.addClass(component.find('searchResGroup2N'), 'slds-is-close');
			$A.util.removeClass(component.find('searchResGroup2N'), 'slds-is-open');
		}
	},

	trasladar2N: function(component, event, helper) {
		component.set('v.deshabilitarEscalar', true);
		let recordId = component.get('v.recordId');
		let colaName;
		let grupoName;
		let grupoId;
		let unchecked = component.get('v.verTodosLosGrupos2N');
		if (unchecked) {
			colaName = component.get('v.selectedRecordGroup.CC_Queue_Traslado__c');
			grupoName = component.get('v.ultimoGrupo2N');
			grupoId = component.get('v.ultimoGrupo2NId');
		} else {
			colaName = component.get('v.grupoSeleccionadoValue');
			grupoName = component.get('v.grupoSeleccionadoName');
			grupoId = component.get('v.grupoSeleccionadoId');
		}
		let tipoGestion = component.get('v.tipoGestion2N');
		let comentario = '';
		let guardarTipoGestion = component.get('c.guardaTipoGestion');
		guardarTipoGestion.setParams({'sIdCaso': recordId, 'tipoGestion': tipoGestion});
		guardarTipoGestion.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				let cambiarPropietario = component.get('c.cambiarPropietario2N');
				cambiarPropietario.setParams({'grupoName': grupoName, 'colaName': colaName, 'recordId': recordId, 'comentario': comentario, 'grupoId': grupoId});
				cambiarPropietario.setCallback(this, responseCambiarPropietario => {
					if (responseCambiarPropietario.getState() === 'SUCCESS') {
						let close = component.get('c.cerrarModalTrasladar2N');
						component.set('v.casoEnSegundoNivel', true);
						$A.enqueueAction(close);
						helper.getDatosCaso(component);
						$A.get('e.force:refreshView').fire();
					}
				});
				$A.enqueueAction(cambiarPropietario);
			}
		});
		$A.enqueueAction(guardarTipoGestion);
	},

	deseleccionarGrupo2N: function(component) {
		let pillTarget = component.find('lookup-pill-group2N');
		$A.util.addClass(pillTarget, 'slds-hide');
		$A.util.removeClass(pillTarget, 'slds-show');

		let lookUpTarget = component.find('lookupFieldGroup');
		$A.util.addClass(lookUpTarget, 'slds-show');
		$A.util.removeClass(lookUpTarget, 'slds-hide');

		component.set('v.SearchKeyWordGroup', null);
		component.set('v.listOfSearchRecordsGroup', null);

		let tipoGestion = document.getElementsByClassName('tipoGestion');
		tipoGestion[0].style.display = 'none';
		component.set('v.tipoGestion2N', '');
	},

	//Funciones referentes al Devolver a 1N
	abrirModalDevolver1N: function(component) {
		let nombreBoton = component.get('v.botonOperativa');
		if (nombreBoton === 'Devolver Nivel 1') {
			component.set('v.tipoTarea', 'devolver');
			$A.util.addClass(component.find('ModalboxDevolver1N'), 'slds-fade-in-open');

			$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');

		} else if (nombreBoton === 'Rechazar Nivel 1') {
			component.set('v.tipoTarea', 'rechazar');
			$A.util.addClass(component.find('ModalboxDevolver1N'), 'slds-fade-in-open');
			$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		}

		//Al abrir el modal se pone el foco en el campo de motivo de devolución
		if (component.find('inputMotivoDevolucion')) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => component.find('inputMotivoDevolucion').focus()), 50);
		}
	},

	cerrarModalDevolver1N: function(component) {
		let cmpTarget = component.find('ModalboxDevolver1N');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');

		let cmpBack = component.find('backdrop');
		$A.util.removeClass(cmpBack, 'slds-backdrop--open');

		component.set('v.comentario', null);

	},

	devolver1N: function(component, event, helper) {
		if (!component.get('v.comentario')) {
			let mensaje = 'Es necesario indicar un motivo para continuar.';
			let toastEvent = $A.get('e.force:showToast');
			toastEvent.setParams({title: 'Datos del Caso.', message: mensaje, type: 'error'});
			toastEvent.fire();
		} else {
			let action = component.get('c.devolver');
			action.setParams({
				'recordId': component.get('v.recordId'),
				'comentario': component.get('v.comentario'),
				'tipo': component.get('v.tipoTarea'),
				'ampliarInformacion': component.get('v.ampliarInformacionDevolucion1N')
			});

			action.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let res = response.getReturnValue();
					if (res === 'KO') {
						helper.mostrarToast('error', 'Datos del Caso', 'Debes informar el campo Resolución correspondiente dependiendo el nivel del caso en la gestión del caso para continuar');
					} else {
						component.get('v.casoEnTercerNivel');
						//Si el caso esta en 3N entrará en esta condición
						if (component.get('v.casoEnTercerNivel')) {
							component.set('v.casoEnTercerNivel', false);
							component.set('v.ultimoGrupo3N', '');
						}

						//Si el caso esta en 2N entrará en esta condición
						if (component.get('v.casoEnSegundoNivel')) {
							component.set('v.casoEnSegundoNivel', false);
							component.set('v.ultimoGrupo2N', '');
							component.set('v.ultimoGrupo2NId', '');
						}
						$A.get('e.force:refreshView').fire();
						let clear = component.get('c.cerrarModalDevolver1N');
						$A.enqueueAction(clear);
					}
				}
			});
			$A.enqueueAction(action);
		}
	},

	//Funciones referentes al Responder Cliente
	abrirModalResponderCliente: function(component, event, helper) {
		let actionAPI = component.find('quickActionAPI');

		//Solo se abre el modal de Solicitar info si el canal de respuesta es Email, Chat o vacío.
		let canalRespuesta = component.get('v.canalRespuesta');
		if (canalRespuesta === 'Email' || canalRespuesta === 'Chat' || canalRespuesta === 'Phone' || !canalRespuesta || canalRespuesta === 'Backoffice') {
			//Abre el modal de Responder Cliente
			component.set('v.tipoOperativa', 'responder');
			helper.loadCarpetasIdioma(component, event, helper);
			if (component.get('v.tipoRegistro') === 'CC_Cliente' && canalRespuesta === 'Email' && component.get('v.psSdocs')) {
				$A.util.addClass(component.find('ModalboxPrevioResponderCliente'), 'slds-fade-in-open');
			} else {
				$A.util.addClass(component.find('ModalboxResponderCliente'), 'slds-fade-in-open');
			}

			$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		} else if (canalRespuesta === 'Twitter') {
			let args = {actionName: 'Case.SocialPublisher', targetFields: {'CC_Solicitud_Informacion__c': {value: false}}};
			actionAPI.selectAction(args).then(() => {
				actionAPI.setActionFieldValues(args);
			});
		} else if (canalRespuesta === 'Comentarios Apps') {
			component.find('quickActionAPI').selectAction({actionName: 'Case.Stores'});
		}
	},


	cerrarModalPrevioResponderCliente: function(component) {

		component.set('v.procesoFinalSeleccion', false);
		component.set('v.tipoOperativa', '');
		component.set('v.mostrarModalGenerarDocumento', false);

		$A.util.removeClass(component.find('ModalboxPrevioResponderCliente'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	responderEmail: function(component) {

		$A.util.removeClass(component.find('ModalboxPrevioResponderCliente'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');

		$A.util.addClass(component.find('ModalboxResponderCliente'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');

	},

	responderCPostal: function(component, event) {
		component.set('v.mostrarModalGenerarDocumento', true);
		//$A.util.removeClass(component.find('ModalboxPrevioResponderCliente'), 'slds-fade-in-open');
		//$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');

		window.setTimeout(() => component.find('modalGenerarDocumento').abrirModalX(), 150);
		//component.find('modalGenerarDocumento').LWCFunction();

	},

	cerrarModalResponderCliente: function(component) {
		let selectItemIdioma = component.find('selectItemIdioma').get('v.value');
		if (selectItemIdioma) {
			component.find('selectItemIdioma').set('v.value', null);
			let selectItemTratamiento = component.find('selectItemTratamiento').get('v.value');
			if (selectItemTratamiento) {
				component.find('selectItemTratamiento').set('v.value', null);
				if (!component.get('v.uncheckedPlantilla')) {
					let selectItemPlantilla = component.find('selectItemPlantilla').get('v.value');
					if (selectItemPlantilla) {
						component.find('selectItemPlantilla').set('v.value', null);
					}
				}
			}
		}
		component.set('v.plantillaSeleccionada', null);
		component.set('v.plantillaSeleccionadaValue', null);
		component.set('v.carpetaIdioma', '');
		component.set('v.carpetaIdiomaSeleccionada', false);
		component.set('v.opcionesIdiomaFolder', null);
		component.set('v.opcionesTratamientoFolder', null);
		component.set('v.carpetaFinal', null);
		component.set('v.procesoFinalSeleccion', false);
		component.set('v.tipoOperativa', '');

		//Cierra el modal de Responder a cliente
		$A.enqueueAction(component.get('c.deseleccionarPlantilla'));
		$A.util.removeClass(component.find('ModalboxPrevioResponderCliente'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('ModalboxResponderCliente'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	responderCliente: function(component) {
		let update = component.get('c.actualizarCaso');
		let plantillaName = component.get('v.plantillaSeleccionadaName');
		//añadir valor del campo url formulario del registro
		update.setParams({
			'idCaso': component.get('v.recordId'),
			'plantilla': component.get('v.plantillaSeleccionadaValue'),
			'informarReferenciaCorreo': true,
			'tratamiento': component.get('v.tratamiento'),
			'operativa': component.get('v.tipoOperativa'),
			'canalRespuesta': component.get('v.canalRespuesta'),
			'canalProcedencia': component.get('v.canalProcedencia'),
			'tipoRegistro': component.get('v.tipoRegistro')
		});
		$A.enqueueAction(update);

		let action = component.get('c.buscarCorreoContacto');
		action.setParam('idCaso', component.get('v.recordId'));
		action.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				let actionAPI = component.find('quickActionAPI');
				let args = {
					actionName: 'Case.Email_Colaborador',
					targetFields: {
						'ToAddress': {value: response.getReturnValue()},
						'CC_Procedencia__c': {value: 'Responder Cliente'},
						'BccAddress': {value: ''},
						'CcAddress': {value: ''},
						'CC_Plantilla__c': {value: plantillaName}
					}
				};
				actionAPI.setActionFieldValues(args);
			}
		});
		$A.enqueueAction(action);

		//Cierre del modal
		$A.enqueueAction(component.get('c.cerrarModalResponderCliente'));
		$A.get('e.force:refreshView').fire();
	},

	responderCliente22: function(component) {
		let plantilla = '';
		let nombrePlantilla = '';
		let plantillaName = component.get('v.plantillaSeleccionadaName');
		if (component.get('v.uncheckedPlantilla')) {
			plantilla = component.get('v.selectedRecordPlantilla.Id');
			nombrePlantilla = component.get('v.selectedRecordPlantilla.Name');
			component.set('v.plantillaSeleccionadaValue', plantilla);
			component.set('v.plantillaSeleccionadaName', nombrePlantilla);
			plantillaName = component.get('v.plantillaSeleccionadaName');
		}

		let recordId = component.get('v.recordId');
		plantilla = component.get('v.plantillaSeleccionadaValue');
		let tratamiento = component.get('v.tratamiento');
		let operativa = component.get('v.tipoOperativa');
		let canalProcedencia = component.get('v.canalProcedencia');
		let update = component.get('c.actualizarCaso');
		update.setParams({
			'idCaso': recordId,
			'plantilla': plantilla,
			'informarReferenciaCorreo': true,
			'tratamiento': tratamiento,
			'operativa': operativa,
			'canalRespuesta': component.get('v.canalRespuesta'),
			'canalProcedencia': canalProcedencia,
			'tipoRegistro': component.get('v.tipoRegistro')
		});
		$A.enqueueAction(update);

		let action = component.get('c.buscarCorreoContacto');
		action.setParams({'idCaso': component.get('v.recordId')});
		action.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				let actionAPI = component.find('quickActionAPI');
				let args = {
					actionName: 'Case.Email_Colaborador',
					targetFields: {
						'ToAddress': {value: response.getReturnValue()},
						'CC_Procedencia__c': {value: 'Responder Cliente'},
						'BccAddress': {value: ''},
						'CcAddress': {value: ''},
						'CC_Plantilla__c': {value: plantillaName}
					}
				};
				actionAPI.setActionFieldValues(args);
			}
		});
		$A.enqueueAction(action);

		//Cierre del modal
		$A.enqueueAction(component.get('c.cerrarModalResponderCliente'));
		$A.get('e.force:refreshView').fire();
	},

	seleccionarPlantilla: function(component, event) {
		component.set('v.plantillaEstaSeleccionada', true);
		let tipoOperativa = component.get('v.tipoOperativa');
		if (tipoOperativa === 'trasladar' || tipoOperativa === 'remitir') {
			component.set('v.actualFirstOptionPlantilla', event.getParam('value'));
			let optionsPlantilla = component.get('v.optionsPlantilla');
			for (let key in optionsPlantilla) {
				if (event.getParam('value') === optionsPlantilla[key].value) {
					component.set('v.plantillaSeleccionadaValue', optionsPlantilla[key].value);
					component.set('v.plantillaSeleccionadaName', optionsPlantilla[key].label);
				}
			}
		} else if (tipoOperativa === 'responder') {
			component.set('v.actualFirstOptionPlantilla', event.getParam('value'));
			let picklistFirstOptionsPlantilla = component.get('v.optionsPlantillaResponder');
			for (let key in picklistFirstOptionsPlantilla) {
				if (event.getParam('value') === picklistFirstOptionsPlantilla[key].value) {
					component.set('v.plantillaSeleccionadaValue', picklistFirstOptionsPlantilla[key].value);
					component.set('v.plantillaSeleccionadaName', picklistFirstOptionsPlantilla[key].label);
				}
			}
		} else {
			component.set('v.actualFirstOptionPlantillaSolicitud', event.getParam('value'));
			let optionsPlantillaResponder = component.get('v.optionsPlantillaResponder');
			for (let key in optionsPlantillaResponder) {
				if (event.getParam('value') === optionsPlantillaResponder[key].value) {
					component.set('v.plantillaSeleccionadaValue', optionsPlantillaResponder[key].value);
					component.set('v.plantillaSeleccionadaName', optionsPlantillaResponder[key].label);
				}
			}
		}
	},
	seeGrupos: function(component) {
		if (component.get('v.verGrupos')) {
			component.set('v.verOficinas', false);
			component.set('v.verEmpleados', false);
			component.set('v.verTodasLasOficinas', false);
			component.set('v.noVerOficinas', false);
			component.set('v.noVerEmpleados', false);
			component.set('v.verTodosLosEmpleados', false);
			component.set('v.empleadoSeleccionado', false);
			component.set('v.oficinaSeleccionada', false);
			component.set('v.oficinaGestoraSeleccionada', false);
			component.set('v.empleadoGestorSeleccionado', false);
			component.set('v.SearchKeyWordEmp', '');
			component.set('v.SearchKeyWordOfi', '');
			component.set('v.optionsPlantilla', null);

			$A.enqueueAction(component.get('c.deseleccionarPlantilla2'));
		}
	},
	seeOficinas: function(component, event, helper) {
		if (component.get('v.verOficinas')) {
			component.set('v.verGrupos', false);
			component.set('v.verEmpleados', false);
			component.set('v.noVerOficinas', true);
			component.set('v.noVerEmpleados', false);
			component.set('v.verTodosLosEmpleados', false);
			component.set('v.grupoSeleccionado', false);
			component.set('v.empleadoSeleccionado', false);
			component.set('v.oficinaSeleccionada', true);
			component.set('v.empleadoGestorSeleccionado', false);
			component.set('v.SearchKeyWordEmp', '');
			component.set('v.SearchKeyWord', '');
			component.set('v.optionsPlantilla', null);
			if (!component.get('v.oficinaGestoraSeleccionada')) {
				component.set('v.oficinaGestoraSeleccionada', true);
			} else {
				component.set('v.oficinaGestoraSeleccionada', false);
			}

			$A.enqueueAction(component.get('c.deseleccionarPlantilla2'));
			helper.obtenerPlantillasOficina(component, event, helper);
		}
	},
	allOficinas: function(component) {
		if (component.get('v.verTodasLasOficinas')) {
			component.set('v.noVerOficinas', false);
			component.set('v.oficinaSeleccionada', false);
			component.set('v.optionsPlantilla', null);
			if (!component.get('v.oficinaGestoraSeleccionada')) {
				component.set('v.oficinaGestoraSeleccionada', true);
			} else {
				component.set('v.oficinaGestoraSeleccionada', false);
			}
		}
	},
	getOfiCliente: function(component, event, helper) {
		if (component.get('v.noVerOficinas')) {
			component.set('v.verTodasLasOficinas', false);
			component.set('v.oficinaSeleccionada', true);
			component.set('v.optionsPlantilla', null);
			component.set('v.oficinaGestoraSeleccionada', true);
			helper.obtenerPlantillasOficina(component, event, helper);
		}
	},
	seeEmpleados: function(component, event, helper) {
		if (component.get('v.verEmpleados')) {
			component.set('v.verGrupos', false);
			component.set('v.verOficinas', false);
			component.set('v.verTodasLasOficinas', false);
			component.set('v.noVerOficinas', false);
			component.set('v.noVerEmpleados', true);
			component.set('v.grupoSeleccionado', false);
			component.set('v.oficinaSeleccionada', false);
			component.set('v.oficinaGestoraSeleccionada', false);
			component.set('v.SearchKeyWordOfi', '');
			component.set('v.SearchKeyWord', '');
			component.set('v.optionsPlantilla', null);
			component.set('v.empleadoGestorSeleccionado', true);

			component.set('v.uncheckedPlantilla', false);
			if (!component.get('v.empleadoSeleccionado')) {
				component.set('v.empleadoSeleccionado', true);
			} else {
				component.set('v.empleadoSeleccionado', false);
			}

			$A.enqueueAction(component.get('c.deseleccionarPlantilla2'));
			helper.obtenerPlantillasEmpleado(component, event, helper);
		}
	},
	allEmpleados: function(component) {
		if (component.get('v.verTodosLosEmpleados')) {
			component.set('v.noVerEmpleados', false);
			component.set('v.optionsPlantilla', null);
			component.set('v.empleadoSeleccionado', false);
			component.set('v.empleadoGestorSeleccionado', false);
		}
	},
	getEmpleCliente: function(component, event, helper) {
		if (component.get('v.noVerEmpleados')) {
			component.set('v.verTodosLosEmpleados', false);
			component.set('v.empleadoSeleccionado', true);
			component.set('v.empleadoGestorSeleccionado', true);
			component.set('v.optionsPlantilla', null);
			helper.obtenerPlantillasEmpleado(component, event, helper);

		}
	},

	allGrupos: function(component, event, helper) {
		component.set('v.grupoSeleccionado', false);
		if (component.get('v.verTodosLosGrupos')) {
			component.set('v.canalProcedencia', false);
		} else {
			component.set('v.plantillaEstaSeleccionada', false);
			helper.getPicklistMCCGrupo(component, event, helper);
		}
	},

	allGrupos3N: function(component, event, helper) {
		//component.set('v.grupoSeleccionado', false);
		if (!component.get('v.verTodosLosGrupos3N')) {
			helper.getPicklistMCCGrupo3N(component, event, helper);
		}
	},

	allGrupos2N: function(component, event, helper) {
		//component.set('v.grupoSeleccionado', false);
		if (!component.get('v.verTodosLosGrupos2N')) {
			helper.getPicklistMCCGrupo2N(component, event, helper);
		}
	},

	handleCarpetaIdiomaSeleccionada: function(component, event, helper) {
		component.set('v.idiomaPlantilla', event.getParam('value'));
		helper.loadCarpetasTratamiento(component, event, helper);
	},

	handleCarpetaTratamientoSeleccionada: function(component, event, helper) {
		component.set('v.procesoFinalSeleccion', true);
		component.set('v.tratamiento', event.getParam('value'));
		helper.getPlantillasResponder(component, event, helper);
	},

	deseleccionarPlantilla: function(component) {
		//Eliminar el grupo seleccionado
		let pillTarget = component.find('lookup-pill-plantilla');
		$A.util.addClass(pillTarget, 'slds-hide');
		$A.util.removeClass(pillTarget, 'slds-show');

		let lookUpTarget = component.find('lookupFieldPlantilla');
		$A.util.addClass(lookUpTarget, 'slds-show');
		$A.util.removeClass(lookUpTarget, 'slds-hide');

		component.set('v.SearchKeyWordPlantilla', null);
		component.set('v.listOfSearchRecordsPlantilla', null);
		component.set('v.plantillaSeleccionadaValue', null);
		component.set('v.plantillaSeleccionadaName', null);
		component.set('v.plantillaEstaSeleccionada', false);
		component.set('v.plantillaSeleccionada', null);
	},

	deseleccionarPlantilla2: function(component) {
		//Eliminar el grupo seleccionado
		component.set('v.SearchKeyWordPlantilla', null);
		component.set('v.listOfSearchRecordsPlantilla', null);
		component.set('v.plantillaSeleccionadaValue', null);
		component.set('v.plantillaSeleccionadaName', null);
		component.set('v.plantillaEstaSeleccionada', false);
		component.set('v.plantillaSeleccionada', null);
	},

	teclaPulsadaLookupPlantilla: function(component, event, helper) {
		let searchRes = component.find('searchResPlantilla');
		let getInputkeyWord = component.get('v.SearchKeyWordPlantilla');

		if (getInputkeyWord.length > 0) {
			$A.util.addClass(searchRes, 'slds-is-open');
			$A.util.removeClass(searchRes, 'slds-is-close');
			if (getInputkeyWord.length > 2) {
				helper.buscarPlantillasResponder(component, event, getInputkeyWord);
			}
		} else {
			$A.util.addClass(searchRes, 'slds-is-close');
			$A.util.removeClass(searchRes, 'slds-is-open');
			component.set('v.listOfSearchRecordsPlantilla', null);
		}
	},

	teclaPulsadaLookupPlantilla2: function(component, event, helper) {
		let getInputkeyWord = component.get('v.SearchKeyWordPlantilla');
		if (getInputkeyWord.length > 2) {
			helper.buscarPlantillasResponder(component, event, getInputkeyWord);
		} else {
			component.set('v.listOfSearchRecordsPlantilla', null);
		}
	},

	abrirQuickActionIncidencia: function(component) {
		let args = {actionName: 'Case.CC_Indicencia'};
		component.find('quickActionAPI').selectAction(args);
	},

	onClickAutoasignarme: function(component) {
		let autoasignarmeCaso = component.get('c.autoasignarmeCaso');
		autoasignarmeCaso.setParams({'recordId': component.get('v.recordId')});
		autoasignarmeCaso.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				component.set('v.idPropietario', $A.get('$SObjectType.CurrentUser.Id'));
				let toastEvent = $A.get('e.force:showToast');
				toastEvent.setParams({
					message: 'El caso le ha sido autoasignado.',
					type: 'success',
					mode: 'dismissible',
					duration: '4000'
				});
				toastEvent.fire();
				$A.get('e.force:refreshView').fire();
			}
		});
		$A.enqueueAction(autoasignarmeCaso);
	},

	abrirModalEnviarNotificacion: function(component) {
		component.find('inputEnviarNotificacionDestinatario').set('v.value', component.get('v.oCaso.Contact.Phone'));

		$A.util.addClass(component.find('modalboxEnviarNotificacion'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');

		//Cargar carpetas de idioma
		let subdirectoriosOperativas = component.get('c.subdirectorios');
		subdirectoriosOperativas.setParams({'rutaDevName': 'CC_Notificacion'});
		subdirectoriosOperativas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let listaEnviarNotificacionIdiomas = [];
				let retorno = response.getReturnValue();
				retorno.forEach(element => listaEnviarNotificacionIdiomas.push({value: element.DeveloperName, label: element.Name}));
				component.set('v.enviarNotificacionIdiomas', listaEnviarNotificacionIdiomas);
				let idioma = component.get('v.oCaso.CC_Idioma__c');
				if (idioma === 'ca') {
					idioma = 'CC_Notificacion_Catalan';
				} else if (idioma === 'en') {
					idioma = 'CC_Notificacion_Ingles';
				} else {
					idioma = 'CC_Notificacion_Castellano';
				}
				component.set('v.enviarNotificacionIdioma', idioma);
				$A.enqueueAction(component.get('c.seleccionaEnviarNotificacionIdioma'));

				if (component.find('inputEnviarNotificacionPlantilla')) {
					//eslint-disable-next-line @lwc/lwc/no-async-operation
					window.setTimeout($A.getCallback(() => component.find('inputEnviarNotificacionPlantilla').focus()), 50);
				}
			}
		});
		$A.enqueueAction(subdirectoriosOperativas);
		$A.enqueueAction(component.get('c.actualizarEnviarNotificacionCaracteresRestantes'));
	},

	abrirModalDeepLink: function(component) {
		component.set('v.spinnerActivado', true);
		let numPersoParam = component.get('v.numPerso');
		let validacionEnrollment = component.get('c.validarEnrollment');
		validacionEnrollment.setParams({'numPerso': numPersoParam});
		validacionEnrollment.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let lstResult = response.getReturnValue();
				let apps = [];

				for (let key in lstResult) {
					if (Object.prototype.hasOwnProperty.call(lstResult, key)) {
						if (lstResult[key].validacion) {
							apps.push(lstResult[key].app);
						}
					}
				}
				if (apps.length) {
					//Cargar deeplinks
					//let apps = response.getReturnValue().apps;
					let subdirectoriosOperativas = component.get('c.getDeeplinks');
					subdirectoriosOperativas.setParams({
						'motivoId': component.get('v.motivo'),
						'canalOperativo': component.get('v.canalOperativo'),
						'apps': apps,
						'idioma': component.get('v.idioma')
					});
					subdirectoriosOperativas.setCallback(this, respuesta => {
						if (respuesta.getState() === 'SUCCESS') {
							let listaDeeplinks = [];
							let retorno = respuesta.getReturnValue();

							for (let element in retorno) {
								if (Object.prototype.hasOwnProperty.call(retorno, element)) {
									listaDeeplinks.push({label: retorno[element].label, value: retorno[element].value});
								}
							}
							component.set('v.plantillasDeeplinking', listaDeeplinks);
							component.set('v.spinnerActivado', false);
							$A.util.addClass(component.find('modalboxDeepLink'), 'slds-fade-in-open');
							$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
						} else {
							let toastEvent = $A.get('e.force:showToast');
							toastEvent.setParams({title: 'Error', message: 'No se ha recuperado ninguna plantilla vinculada con el motivo del caso.', type: 'error', mode: 'dismissable', duration: '4000'});
							toastEvent.fire();
							component.set('v.spinnerActivado', false);
						}

					});

					$A.enqueueAction(subdirectoriosOperativas);
				} else {
					let toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({title: 'Error', message: 'No existe ningún enrollment asociado.', type: 'error', mode: 'dismissable', duration: '4000'});
					toastEvent.fire();
					component.set('v.spinnerActivado', false);
					//helper.mostrarToast('error', 'Error', 'No existe ningún enrollment asociado.');
				}
			} else {
				let toastEvent = $A.get('e.force:showToast');
				toastEvent.setParams({title: 'Error', message: 'La cuente del caso no contiene ningún numPerso asociado.', type: 'error', mode: 'dismissable', duration: '4000'});
				toastEvent.fire();
				component.set('v.spinnerActivado', false);
			}

		});
		$A.enqueueAction(validacionEnrollment);

	},

	seleccionplantillasDeeplinking: function(component, event) {
		component.set('v.plantillaDeeplink', event.getParam('value'));
		let actualizaVariables = component.get('c.obtenerDatosSeleccionado');
		let validarSegundoParametro = component.get('c.validacionParametroDeeplink');
		actualizaVariables.setParams({'idDeeplink': component.get('v.plantillaDeeplink')});
		actualizaVariables.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let respuesta = response.getReturnValue();
				component.set('v.DeeplinkApp', respuesta.CC_App__c);
				component.set('v.DeeplinkAsuntoCas', respuesta.CC_Asunto_Cas__c);
				component.set('v.DeeplinkAsuntoCat', respuesta.CC_Asunto_Cat__c);
				component.set('v.DeeplinkAsuntoIng', respuesta.CC_Asunto_Ing__c);
				component.set('v.valorDeeplink', respuesta.CC_Deeplink__c);
				component.set('v.DeeplinkTxtPrivCas', respuesta.CC_TextoPrivado_Cas__c);
				component.set('v.DeeplinkTxtPrivCat', respuesta.CC_TextoPrivado_Cat__c);
				component.set('v.DeeplinkTxtPrivIng', respuesta.CC_TextoPrivado_Ing__c);
				component.set('v.DeeplinkTxtPubCas', respuesta.CC_TextoPublico_Cas__c);
				component.set('v.DeeplinkTxtPubCat', respuesta.CC_TextoPublico_Cat__c);
				component.set('v.DeeplinkTxtPubIng', respuesta.CC_TextoPublico_Ing__c);
				component.set('v.DeeplinkSobreTituloCas', respuesta.CC_Sobretitulo_Cas__c);
				component.set('v.DeeplinkSobreTituloCat', respuesta.CC_Sobretitulo_Cat__c);
				component.set('v.DeeplinkSobreTituloIng', respuesta.CC_Sobretitulo_Ing__c);
				component.set('v.DeeplinkTituloCas', respuesta.CC_Titulo_Cas__c);
				component.set('v.DeeplinkTituloCat', respuesta.CC_Titulo_Cat__c);
				component.set('v.DeeplinkTituloIng', respuesta.CC_Titulo_Ing__c);
				component.set('v.DeeplinkTxtBotonCas', respuesta.CC_Texto_Bot_Cas__c);
				component.set('v.DeeplinkTxtBotonCat', respuesta.CC_Texto_Bot_Cat__c);
				component.set('v.DeeplinkTxtBotonIng', respuesta.CC_Texto_Bot_Ing__c);
				component.set('v.tituloMensajePoseidon', respuesta.CC_TituloConsentimientoCliente__c);
				component.set('v.cuerpoMensajePoseidon', respuesta.CC_CuerpoConsentimientoCliente__c);
			}
		});
		$A.enqueueAction(actualizaVariables);

		component.set('v.valueInputPoseidon', null);
		validarSegundoParametro.setParams({'idDeeplink': component.get('v.plantillaDeeplink')});
		validarSegundoParametro.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let objetoRespuesta = response.getReturnValue();
				component.set('v.boolParametrosPoseidon', objetoRespuesta.bool);
				component.set('v.placeholderInputPoseidon', objetoRespuesta.valorLabel);
				component.set('v.lengthInputPoseidon', objetoRespuesta.valor2);
				function labelTimeout() {
					let labelPoseidon = document.getElementById('labelParametroPoseidon');
					labelPoseidon.innerText = objetoRespuesta.valorLabel;
				}

				setTimeout(labelTimeout, 100);
			}
		});
		$A.enqueueAction(validarSegundoParametro);
	},

	cerrarModalEnviarNotificacion: function(component) {
		//Se vacía el contenido del destinatario y del mensaje
		component.find('inputEnviarNotificacionDestinatario').set('v.value', '');
		component.find('inputEnviarNotificacionPlantilla').set('v.value', '');
		component.find('inputEnviarNotificacionContenido').set('v.value', '');

		$A.util.removeClass(component.find('modalboxEnviarNotificacion'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	cerrarModalDeepLinking: function(component) {
		$A.util.removeClass(component.find('modalboxDeepLink'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');

		component.set('v.plantillaDeeplink', null);
		component.set('v.boolParametrosPoseidon', false);
		component.set('v.labelParametroPoseidon', null);
		component.set('v.valueInputPoseidon', null);

	},

	enviarNotificacionDeepLinking: function(component) {
		//alert('Test click envio deeplink');
		$A.enqueueAction(component.get('c.cerrarModalDeepLinking'));
		component.set('v.spinnerActivado', true);

		let app = component.get('v.DeeplinkApp');
		let envioDeeplink = component.get('c.envioPoseidon');
		let recId = component.get('v.recordId');
		let idiomaParam = component.get('v.idioma');
		let numPersoParam = component.get('v.numPerso');
		let txtPublicoParam = '';
		let txtPrivadoParam = '';
		let asuntoParam = '';
		let sobreTituloParam = '';
		let tituloParam = '';
		let txtBotonParam = '';
		let deeplinkParam = component.get('v.valorDeeplink');
		let parametroDeeplink = component.get('v.valueInputPoseidon');

		if (idiomaParam === 'es') {
			txtPublicoParam = component.get('v.DeeplinkTxtPubCas');
			txtPrivadoParam = component.get('v.DeeplinkTxtPrivCas');
			sobreTituloParam = component.get('v.DeeplinkSobreTituloCas');
			tituloParam = component.get('v.DeeplinkTituloCas');
			txtBotonParam = component.get('v.DeeplinkTxtBotonCas');
			asuntoParam = component.get('v.DeeplinkAsuntoCas');
		} else if (idiomaParam === 'ca') {
			txtPublicoParam = component.get('v.DeeplinkTxtPubCat');
			txtPrivadoParam = component.get('v.DeeplinkTxtPrivCat');
			sobreTituloParam = component.get('v.DeeplinkSobreTituloCat');
			tituloParam = component.get('v.DeeplinkTituloCat');
			txtBotonParam = component.get('v.DeeplinkTxtBotonCat');
			asuntoParam = component.get('v.DeeplinkAsuntoCat');
		} else if (idiomaParam === 'en') {
			txtPublicoParam = component.get('v.DeeplinkTxtPubIng');
			txtPrivadoParam = component.get('v.DeeplinkTxtPrivIng');
			sobreTituloParam = component.get('v.DeeplinkSobreTituloIng');
			tituloParam = component.get('v.DeeplinkTituloIng');
			txtBotonParam = component.get('v.DeeplinkTxtBotonIng');
			asuntoParam = component.get('v.DeeplinkAsuntoIng');
		}
		envioDeeplink.setParams({
			'sObjectId': recId,
			'app': app,
			'numPer': numPersoParam,
			'textoPublico': txtPublicoParam,
			'textoPrivado': txtPrivadoParam,
			'asunto': asuntoParam,
			'deeplink': deeplinkParam,
			'idioma': idiomaParam,
			'titulo': tituloParam,
			'sobreTitulo': sobreTituloParam,
			'textoBoton': txtBotonParam,
			'segundoParametro': parametroDeeplink
		});

		envioDeeplink.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let respuesta = response.getReturnValue();
				let toastEvent = $A.get('e.force:showToast');
				if (respuesta) {
					toastEvent.setParams({title: 'Éxito', message: 'Se ha enviado la notificación.', type: 'success', mode: 'dismissable', duration: '4000'});
					toastEvent.fire();
					component.set('v.spinnerActivado', false);
				} else {
					toastEvent.setParams({title: 'Error', message: 'No se ha podido enviar la plantilla al cliente.', type: 'error', mode: 'dismissable', duration: '4000'});
					toastEvent.fire();
					component.set('v.spinnerActivado', false);
					$A.util.addClass(component.find('modalboxDeepLink'), 'slds-fade-in-open');
					$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
				}
			}
		});
		$A.enqueueAction(envioDeeplink);
	},

	seleccionaEnviarNotificacionIdioma: function(component) {
		let plantillas = component.get('c.plantillas');
		plantillas.setParams({'rutaDevName': component.find('inputEnviarNotificacionIdioma').get('v.value')});
		plantillas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let listaPlantillas = [];
				let retorno = response.getReturnValue();
				retorno.forEach(element => listaPlantillas.push({value: element.DeveloperName, label: element.Name}));
				component.set('v.enviarNotificacionPlantillas', listaPlantillas);
			}
		});
		$A.enqueueAction(plantillas);
	},

	seleccionaEnviarNotificacionPlantilla: function(component) {
		let plantillaCuerpo = component.get('c.plantillaCuerpo');
		plantillaCuerpo.setParams({'developerName': component.find('inputEnviarNotificacionPlantilla').get('v.value'), 'convertirATextoPlano': true});
		plantillaCuerpo.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				//Cargar contenido de la plantilla en el campo de del modal
				component.find('inputEnviarNotificacionContenido').set('v.value', response.getReturnValue());
				//Actualizar contador de caracteres restantes
				let actualizarEnviarNotificacionCaracteresRestantes = component.get('c.actualizarEnviarNotificacionCaracteresRestantes');
				$A.enqueueAction(actualizarEnviarNotificacionCaracteresRestantes);
			}
		});
		$A.enqueueAction(plantillaCuerpo);
	},

	actualizarEnviarNotificacionCaracteresRestantes: function(component) {
		let caracteresRestantes = 160 - component.find('inputEnviarNotificacionContenido').get('v.value').length;
		component.set('v.enviarNotificacionCaracteresRestantes', caracteresRestantes);

		if (caracteresRestantes < 21) {
			$A.util.addClass(component.find('divEnviarNotificacionCaracteresRestantes'), 'cc-rojo');
		} else {
			$A.util.removeClass(component.find('divEnviarNotificacionCaracteresRestantes'), 'cc-rojo');
		}
	},

	enviarNotificacion: function(component, event, helper) {
		//Validación de campos obligatorios
		let destinatario = component.find('inputEnviarNotificacionDestinatario').get('v.value');
		let texto = component.find('inputEnviarNotificacionContenido').get('v.value');
		if (!destinatario || !texto) {
			//eslint-disable-next-line no-alert
			alert('Debe indicar el destinatario y el contenido.');
		} else {
			//Se inhabilita el botón hasta recibir la respuesta
			event.getSource().set('v.disabled', true);

			let enviarSMS = component.get('c.enviarNotificacinPushSMS');
			enviarSMS.setParams({'sObjectId': component.get('v.recordId'), 'destinatario': destinatario, 'texto': texto});
			enviarSMS.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let resultado = response.getReturnValue();
					if (resultado === 'OK') {
						//Toast OK
						helper.mostrarToast('success', 'Se envió la notificación', 'Se envió correctamente la notificación/SMS al destinatario ' + destinatario);

						//Se cierra el modal
						$A.enqueueAction(component.get('c.cerrarModalEnviarNotificacion'));

						//Refrescar la vista
						$A.get('e.force:refreshView').fire();
					} else {
						//Toast KO
						helper.mostrarToast('error', 'No se pudo enviar la notificación', resultado);
					}
				}
				//Se vuelve a habilitar el botón
				event.getSource().set('v.disabled', false);
			});
			$A.enqueueAction(enviarSMS);
		}
	},

	modalTrasladarColaboradorTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalTrasladarColaborador'));
		}
	},

	modalTrasladar3NTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalTrasladar3N'));
		}
	},

	modalTrasladar2NTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalTrasladar2N'));
		}
	},

	modalSolicitarInfoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalSolicitarInfo'));
		}
	},

	modalDevolver1NTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalDevolver1N'));
		}
	},

	modalResponderClienteTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalResponderCliente'));
		}
	},

	modalEnviarNotificacionTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalEnviarNotificacion'));
		}
	},

	modalDeepLinkingTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalDeepLinking'));
		}
	},

	modaAutenticacionTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalAutenticacion'));
		}
	},

	modalDevolverSACTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalDevolverSAC'));
		}
	},

	abrirModalAutenticacion: function(component) {
		component.set('v.modalAutenticacionVisible', true);
		$A.util.addClass(component.find('modalboxAutenticacion'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	cerrarModalAutenticacion: function(component) {
		$A.util.removeClass(component.find('modalboxAutenticacion'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.modalAutenticacionVisible', false);
	},

	abrirModalDevolverSAC: function(component) {
		component.set('v.modalDevolverSACVisible', true);
		$A.util.addClass(component.find('ModalboxReturnSAC'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	/*abrirModalDevolverSAC: function(component) {
		if (component.get('v.botonOperativa') === 'Devolver a SAC') {
			$A.util.addClass(component.find('ModalboxReturnSAC'), 'slds-fade-in-open');
			$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		}
	},*/

	cerrarModalDevolverSAC: function(component) {
		$A.util.removeClass(component.find('ModalboxReturnSAC'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.modalDevolverSACVisible', false);
	},

	ampliarMotivoDevolverSAC: function(component) {
		let check = component.get('v.ampliarInfoDevolverSAC');
		let textarea = component.find('ampliarMotivoDevolucionSAC');
		let text = component.find('motDevolucionSAC');
		if (!check) {

			$A.util.removeClass(textarea, 'slds-hide');
			$A.util.addClass(textarea, 'slds-show');
			$A.util.removeClass(text, 'slds-show');
			$A.util.addClass(text, 'slds-hide');
			component.set('v.ampliarInfoDevolverSAC', true);
		} else {

			$A.util.removeClass(text, 'slds-hide');
			$A.util.addClass(text, 'slds-show');
			$A.util.removeClass(textarea, 'slds-show');
			$A.util.addClass(textarea, 'slds-hide');
			component.set('v.ampliarInfoDevolverSAC', false);
		}
	},

	devolverSAC: function(component) {
		let devolverAlSac = component.get('c.devolverCasoAlSAC');
		let motivoDevolver = component.get('v.motivoDevolucionSAC');
		if (motivoDevolver !== '' && motivoDevolver != null) {
			devolverAlSac.setParams({'motivo': motivoDevolver, 'casoContactCenter': component.get('v.oCaso')});
			devolverAlSac.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						message: 'El caso se ha devuelto al SAC.',
						type: 'success',
						mode: 'dismissible',
						duration: '4000'
					});
					toastEvent.fire();
					$A.get('e.force:refreshView').fire();

				}
			});
			$A.enqueueAction(devolverAlSac);
			$A.enqueueAction(component.get('c.cerrarModalDevolverSAC'));
		} else {
			let toastEvent = $A.get('e.force:showToast');
			toastEvent.setParams({
				message: 'Es necesario introducir un motivo para devolver el caso a SAC.',
				type: 'error',
				mode: 'dismissible',
				duration: '4000'
			});
			toastEvent.fire();
		}
	},
	//Inicio Métodos Devolver/Derivar al SAC
	onClickDevolverAlSac: function(component) {
		/**
		* Todos los casos que nos derivan con cualquier RT de SAC?
		* Actividad 'Devuelto al SAC'
		* ParentId y Parent.Recordtype == SAC --> OK
		* Dudas: Qué caso se debe devolver a SAC?
		* Con devolver se refiere a que igual el caso esté en estado 'pendiente algo'/'cerrado' y que cuando nosotros le damos a Devolver el caso pase a 'Activo' (del SAC)?
		* Cuando lo devolvemos ellos pueden volver a derivanoslo? Entonces la actividad esta pendiente hasta que nos lo deriven de nuevo?
		*/

		//Crear modal, abrirlo, capturar evento del motivo

		$A.enqueueAction(component.get('c.abrirModalDevolverSAC'));
		component.find('devolverAlSAC').set('v.disabled', true);
		//let motivoDevolver = 'Eçrror en la asignación, falta de competencia de Contact Center';
		/*
		let devolverAlSac = component.get('c.devolverCasoAlSAC');
		devolverAlSac.setParams({ 'motivo': motivoDevolver, 'casoContactCenter': component.get('v.oCaso') });
		devolverAlSac.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let toastEvent = $A.get('e.force:showToast');
				toastEvent.setParams({
					message: 'El caso se ha devuelto al SAC.',
					type: 'success',
					mode: 'dismissible',
					duration: '4000'
				});
				toastEvent.fire();
				//component.find('devolverAlSac').set('v.disabled', false);
				$A.get('e.force:refreshView').fire();

			}
		});
		$A.enqueueAction(devolverAlSac);*/
	},

	onClickDerivarAlSac: function(component, event, helper) {
		/**
		* Actividad 'Derivado a SAC'
		* Canal de entrada 'Email' y canal de procedencia 'Formulario web' --> OK
		* Dudas: Al crear la actividad nuestro caso pasa a 'Pendiente algo' o se cierra?
		* La actividad esta abierta? Sac nos devuelve el caso? Si nos lo devuelve, completamos la actividad de 'Derivado al SAC'?
		* La opción de derivar a parte de que esté activa en la lista depende también del canal de entrada email y canal de procedencia formulario web? Resumen US y tarea dicen cosas distintas.
		*/
		component.find('derivarAlSAC').set('v.disabled', true);
		let derivarCasoAlSAC = component.get('c.derivarCasoAlSAC');
		derivarCasoAlSAC.setParams({casoContactCenter: component.get('v.oCaso'), motivo: 'Asignación de caso al SAC'});
		derivarCasoAlSAC.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				helper.mostrarToast('success', 'El caso se derivó al SAC', 'El caso ' + component.get('v.caso.CaseNumber') + ' se derivó correctamente al SAC');
				$A.get('e.force:refreshView').fire();
			}
		});
		$A.enqueueAction(derivarCasoAlSAC);
	},


	crearTarea: function(component, event, helper) {
		if (component.find('asuntoTarea').get('v.value') === '' || component.find('comentariosTarea').get('v.value') === '' || component.find('fechaActividad').get('v.value') === null) {
			helper.mostrarToast('warning', 'Campos vacíos', 'Por favor, informe todos los campos del formulario');
		} else {
			component.set('v.cargandoGestor', true);
			let crearTareaGestor = component.get('c.crearTareaGestor');

			/*cambiar parametro numeroGestor por la variable matriculaGestor
			let matriculaGestor;
			if (component.find('comboboxEmpleados').get('v.value') != null) {
				matriculaGestor = component.find('comboboxEmpleados').get('v.value');
			} else {
				matriculaGestor = component.get('v.numeroGestor');
			}*/

			crearTareaGestor.setParams({
				'recordId': component.get('v.recordId'),
				'esClienteDigital': component.get('v.esClienteDigital'),
				'numeroGestor': component.get('v.numeroGestor'),
				'asunto': component.find('asuntoTarea').get('v.value'),
				'fechaActividad': component.find('fechaActividad').get('v.value'),
				'comentarios': component.find('comentariosTarea').get('v.value')
			});

			crearTareaGestor.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let respuesta = response.getReturnValue();
					if (!respuesta.cuenta) {
						helper.mostrarToast('success', 'Tarea creada con éxito', respuesta.mensaje);
					} else if (!respuesta.cuenta.Id) {
						helper.mostrarToast('success', 'Tarea creada con exito', respuesta.mensaje);
					} else {
						let comprobacionCaso = component.get('c.devolverMensaje');
						comprobacionCaso.setParams({recordId: respuesta.cuenta.Id});
						comprobacionCaso.setCallback(this, response => {
							if (response.getState() === 'SUCCESS') {
								if (response.getReturnValue() != null) {
									let objetoRespuesta = response.getReturnValue();
									let toastEvent = $A.get('e.force:showToast');
									toastEvent.setParams({
										title: 'Tarea creada con éxito',
										type: 'success',
										message: 'Mensaje',
										mode: 'sticky',
										messageTemplate: respuesta.mensaje.toString() + ' {1}',
										messageTemplateData: ['Salesforce', {
											url: objetoRespuesta.getMensaje,
											label: objetoRespuesta.getCuenta.CC_Numero_Oficina__c
										}
										]
									});
									toastEvent.fire();
								}
							}
						});
						$A.enqueueAction(comprobacionCaso);
					}
					$A.enqueueAction(component.get('c.modalTareaGestorCerrar'));
				} else {
					helper.mostrarToast('error', 'No es posible crear la tarea', 'El proceso de creación de la tarea ha fallado.');
					$A.enqueueAction(component.get('c.modalTareaGestorCerrar'));
				}
			});
			$A.enqueueAction(crearTareaGestor);
		}
	},

	resetDisponibilidadConsultada: function(component) {
		component.set('v.disponibilidadConsultada', false);
	},

	consultarFechasDisponibilidadGestor: function(component, event, helper) {
		helper.consultarFechasDisponibilidad(component, component.get('v.numeroGestor'));
	},

	consultarHorasDisponibilidadGestor: function(component, event, helper) {
		helper.consultarHorasDisponibilidad(component, component.get('v.numeroGestor'));
		component.set('v.gestorElegido', component.get('v.numeroGestor'));
		component.set('v.nombreGestorElegido', component.get('v.nombreGestor'));
	},

	consultarFechasDisponibilidadBackup: function(component, event, helper) {
		helper.consultarFechasDisponibilidad(component, component.find('gestoresBackup').get('v.value'));
	},

	consultarHorasDisponibilidadBackup: function(component, event, helper) {
		helper.consultarHorasDisponibilidad(component, component.find('gestoresBackup').get('v.value'));
		component.set('v.gestorElegido', component.find('gestoresBackup').get('v.value'));
		let gestorSeleccionado = component.find('gestoresBackup').get('v.value');
		let labelGestoreleccionado = component.get('v.gestoresBackup').find(gestor => gestor.value === gestorSeleccionado).label;
		component.set('v.nombreGestorElegido', labelGestoreleccionado);

	},

	mostrarGestorBackup: function(component, event, helper) {
		if (component.get('v.gestorBackupActivo')) {
			component.set('v.fechasDisponibilidad', undefined);
			component.set('v.horasDisponibilidad', undefined);
			component.set('v.disponibilidadConsultada', false);

			let consultarGestoresBackup = component.get('c.obtenerGestoresBackup');
			consultarGestoresBackup.setParams({
				recordId: component.get('v.recordId'),
				employeeId: component.get('v.numeroGestor'),
				gestorElegidoId: component.get('v.numeroGestor'),
				eventType: component.find('tipoCita').get('v.value')
			});
			consultarGestoresBackup.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					component.set('v.gestoresBackup', response.getReturnValue());
					if (response.getReturnValue() === '') {
						component.set('v.existeBackup', false);
					}
					component.set('v.gestorBackupActivoDos', true);
				} else if (response.getState() === 'ERROR') {
					helper.mostrarToast('error', 'Error al consultar los gestores backup', consultarGestoresBackup.getError()[0].message);
				}
			});
			$A.enqueueAction(consultarGestoresBackup);
		} else {
			component.set('v.gestorBackupActivoDos', false);
			component.set('v.fechasDisponibilidad', []);
			component.set('v.horasDisponibilidad', []);
			component.set('v.disponibilidadConsultada', false);
		}
	},

	confirmarCitaGestor: function(component, event, helper) {
		if (component.find('asuntoEvento').get('v.value') === '' || component.find('fechasDisponibilidad').get('v.value') === undefined || component.find('horasDisponibilidad').get('v.value') === undefined) {
			helper.mostrarToast('warning', 'Campos vacíos', 'Por favor, informe todos los campos del formulario');
		} else {
			component.set('v.cargandoGestor', true);
			component.set('v.disponibilidadConsultada', false);
			let confirmarCita = component.get('c.altaCitaGestor');
			confirmarCita.setParams({
				'recordId': component.get('v.recordId'),
				'empleadoEx': component.get('v.gestorElegido'),
				'nombreGestor': component.get('v.nombreGestorElegido'),
				'centroEx': component.get('v.oficinaGestor'),
				'asunto': component.find('asuntoEvento').get('v.value'),
				'fecContacto': component.find('fechasDisponibilidad').get('v.value'),
				'horaIni': component.find('horasDisponibilidad').get('v.value'),
				'medio': component.find('tipoCita').get('v.value')
			});

			confirmarCita.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let value = response.getReturnValue();
					if (value.resultat === 'OK') {
						helper.mostrarToast('success', 'Cita creada con éxito', 'La cita estará disponible en la ficha del cliente. Al caso se asocia una tarea para dejar constancia de la solicitud.');
						$A.enqueueAction(component.get('c.modalCitaGestorCerrar'));
					} else {
						helper.mostrarToast('error', 'No es posible crear la cita', value.txtError);
						$A.enqueueAction(component.get('c.modalCitaGestorCerrar'));
					}
				} else if (response.getState() === 'ERROR') {
					helper.mostrarToast('error', 'Error al confirmar la cita', confirmarCita.getError()[0].message);
					$A.enqueueAction(component.get('c.modalCitaGestorCerrar'));
				}
			});
			$A.enqueueAction(confirmarCita);
		}
	},

	mmodalCitaGestorAbrir: function(component, event, helper) {
		$A.util.addClass(component.find('modalCitaGestor'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('modalCitaGestorCancelar').focus()), 200);
		helper.esClienteDigital(component, 'Cita gestor');
	},

	modalCitaGestorCerrar: function(component) {
		$A.util.removeClass(component.find('modalCitaGestor'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.cargandoGestor', false);
		component.set('v.disponibilidadConsultada', false);
		$A.get('e.force:refreshView').fire();
	},

	modalCitaGestorTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalCitaGestorCerrar'));
		}
	},

	modalTareaGestorAbrir: function(component, event, helper) {
		component.set('v.comentariosTarea', '');
		helper.getDatosCaso(component);
		//helper.obtenerEmpleadosOficina(component);
		$A.util.addClass(component.find('modalTareaGestor'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('modalTareaGestorCancelar').focus()), 200);
		helper.esClienteDigital(component, 'Tarea gestor');
	},

	modalTareaGestorCerrar: function(component) {
		$A.util.removeClass(component.find('modalTareaGestor'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.cargandoGestor', false);
		$A.get('e.force:refreshView').fire();
	},

	modalTareaGestorTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalTareaGestorCerrar'));
		}
	},

	checkboxPlantillaChange: function(component) {
		component.set('v.SearchKeyWordPlantilla', null);
		component.set('v.listOfSearchRecordsPlantilla', null);
		component.set('v.plantillaSeleccionadaValue', null);
		component.set('v.plantillaSeleccionadaName', null);
		component.set('v.plantillaEstaSeleccionada', false);
		component.set('v.plantillaSeleccionada', null);
	},

	lookupAbrir: function(component) {
		if (component.get('v.SearchKeyWordSegundaOfi').length > 1) {
			let lookup2aOficina = component.find('lookup2aOficina');
			$A.util.addClass(lookup2aOficina, 'slds-is-open');
			$A.util.removeClass(lookup2aOficina, 'slds-is-close');
		}
	},

	lookupCerrar: function(component) {
	//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			let lookup2aOficina = component.find('lookup2aOficina');
			$A.util.addClass(lookup2aOficina, 'slds-is-close');
			$A.util.removeClass(lookup2aOficina, 'slds-is-open');
		}, 100);
	},

	lookupOnchange: function(component, event, helper) {
		window.clearTimeout(component.get('v.timeoutTeclaPulsada'));
		const lookupValue = component.get('v.SearchKeyWordSegundaOfi');
		if (lookupValue.length > 1) {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
			component.set('v.timeoutTeclaPulsada', window.setTimeout($A.getCallback(() => helper.buscarListas(component, null, lookupValue, 'segundaOficina')), 500));
		} else {
			component.find('lookup2aOficinaInput').set('v.isLoading', false);
			const lookup2aOficina = component.find('lookup2aOficina');
			$A.util.addClass(lookup2aOficina, 'slds-is-close');
			$A.util.removeClass(lookup2aOficina, 'slds-is-open');
			component.set('v.listOfSearchRecords2aOfi', null);
		}
	},

	lookupSeleccionar: function(component, event) {
		const segundaOficina = component.get('v.listOfSearchRecords2aOfi').find(record => record.Id === event.currentTarget.dataset.id);
		component.set('v.selectedRecordSegundaOficina', segundaOficina);
		//component.set('v.emailParaAux', segundaOficina.CC_Email__c);
		component.set('v.emailCopiaAux', [segundaOficina.AV_DescFuncion__c, segundaOficina.AV_EAPGestor__pc]);
	},

	lookupDeseleccionar: function(component) {
		component.set('v.selectedRecordSegundaOficina', null);
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => component.find('lookup2aOficinaInput').focus(), 200);
	},

	//Ini: Función añadida por JH para US504352
	//Funciones referentes al Ver Cliente Confidencial
	mostrarInfoConfidencial: function(component) {
		let mostrarInfo = component.get('c.getCuentaConfidencial');
		mostrarInfo.setParams({'AccountId': component.get('v.AccountId')});
		mostrarInfo.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let retorno = response.getReturnValue();
				if (retorno != null) {
					let navService = component.find('navService');
					let pageReference = {
						'type': 'standard__recordPage',
						'attributes': {
							'recordId': retorno.Id,
							'objectApiName': 'Account',
							'actionName': 'view'
						}
					};
					navService.navigate(pageReference);
				} else {
					let toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						title: 'Sin cuenta', message: 'No existe una cuenta asociada al contacto confidencial.',
						key: 'info_alt', type: 'error', mode: 'dismissible', duration: '10000'
					});
					toastEvent.fire();
				}
			}
		});
		$A.enqueueAction(mostrarInfo);
	},
	//Fin: Función añadida por JH para US504352

	toggleVerTodasLasPlantillasOnclick: function(component) {
		component.set('v.plantillaEstaSeleccionada', false);
		component.set('v.selectedRecordPlantilla', false);
	},

	modalTransferAbrir: function(component) {
		window.setTimeout($A.getCallback(() => {
			$A.util.addClass(component.find('ModalBoxTransfer'), 'slds-fade-in-open');
			$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
			component.find('ModalBoxTransfer').focus();
		}), 200);
	},

	modalTransferCerrar: function(component) {
		component.set('v.selectedRecordQueue', null);
		component.set('v.SearchKeyWordQueue', null);
		component.set('v.listOfSearchRecordsQueue', []);

		let pillTarget = component.find('lookup-pill-queue');
		$A.util.addClass(pillTarget, 'slds-hide');
		$A.util.removeClass(pillTarget, 'slds-show');

		let lookUpTarget = component.find('lookupFieldQueue');
		$A.util.addClass(lookUpTarget, 'slds-show');
		$A.util.removeClass(lookUpTarget, 'slds-hide');

		$A.util.removeClass(component.find('ModalBoxTransfer'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	modalTransferTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalTransferCerrar'));
		}
	},

	deseleccionarQueue: function(component) {
		let pillTarget = component.find('lookup-pill-queue');
		$A.util.addClass(pillTarget, 'slds-hide');
		$A.util.removeClass(pillTarget, 'slds-show');

		let lookUpTarget = component.find('lookupFieldQueue');
		$A.util.addClass(lookUpTarget, 'slds-show');
		$A.util.removeClass(lookUpTarget, 'slds-hide');

		component.set('v.selectedRecordQueue', null);

		if (component.get('v.SearchKeyWordQueue')) {
			$A.util.addClass(component.find('searchResQueue'), 'slds-is-open');
			$A.util.removeClass(component.find('searchResQueue'), 'slds-is-close');
		}
	},

	inputTextQueueOnchange: function(component, event, helper) {
		let searchRes = component.get('v.SearchKeyWordQueue');
		if (searchRes.length > 0) {
			$A.util.addClass(component.find('searchResQueue'), 'slds-is-open');
			$A.util.removeClass(component.find('searchResQueue'), 'slds-is-close');
			helper.buscarColas(component, null, searchRes);
		} else {
			$A.util.addClass(component.find('searchResQueue'), 'slds-is-close');
			$A.util.removeClass(component.find('searchResQueue'), 'slds-is-open');
			component.set('v.listOfSearchRecordsQueue', null);
		}
	},

	cambiarPropietarioTransfer: function(component, event, helper) {
		if (component.get('v.selectedRecordQueue')) {
			component.set('v.deshabilitarTransfer', true);

			let cambiarPropietario = component.get('c.cambiarPropietarioTransferApex');
			cambiarPropietario.setParams({
				recordId: component.get('v.recordId'),
				idCola: component.get('v.selectedRecordQueue.Id')
			});
			cambiarPropietario.setCallback(this, responseCambiarPropietario => {
				if (responseCambiarPropietario.getState() === 'SUCCESS') {
					helper.mostrarToast('success', 'Se actualizó Caso', 'Se actualizó correctamente el propietario del caso');
					$A.enqueueAction(component.get('c.modalTransferCerrar'));
					helper.getDatosCaso(component);
					$A.get('e.force:refreshView').fire();
				} else if (responseCambiarPropietario.getState() === 'ERROR') {
					console.error(cambiarPropietario.getError);
					helper.mostrarToast('error', 'Problema actualizando Caso', JSON.stringify(cambiarPropietario.getError()));
				}
				component.set('v.deshabilitarTransfer', false);
			});
			$A.enqueueAction(cambiarPropietario);
		}
	},

	handleModalOficina: function(component) {
		component.set('v.mostrarModalOficina', true);
		component.set('v.spinnerActivado', true);
	},

	handleModalOficinaCerrado: function(component, event) {
		component.set('v.mostrarModalOficina', false);
	},

	//handleModalCancelarCita: function(component) {
	//console.log('entra handle');
	//component.set('v.mostrarModalCancelarCita', true);
	//},

	//handleModalCancelarCitaCerrado: function(component) {
	//component.set('v.mostrarModalCancelarCita', false);
	//},

	realizarTrasladoDesdeDerivar: function(component) {
		component.set('v.botonOperativa', 'Trasladar Colaborador');
		$A.enqueueAction(component.get('c.abrirModalTrasladarColaborador'));
	},

	realizarRemitidoDesdeDerivar: function(component) {
		let recuperarPlantilla = component.get('c.plantillaRemitirDesdeDerivar');
		recuperarPlantilla.setParams({recordId: component.get('v.recordId')});
		recuperarPlantilla.setCallback(this, responseRecuperarPlantilla => {
			if (recuperarPlantilla.getState() === 'SUCCESS') {
				component.set('v.selectedRecordPlantilla', responseRecuperarPlantilla.idPlantilla);
			} else if (recuperarPlantilla.getState() === 'ERROR') {
				console.error(recuperarPlantilla.getError);
				helper.mostrarToast('error', 'Problema recuperando plantilla', JSON.stringify(recuperarPlantilla.getError()));
			}
		});
		$A.enqueueAction(recuperarPlantilla);
		$A.enqueueAction(component.get('c.abrirModalTrasladarColaborador'));
	},

	refreshTab: function(component) {
		let workspaceAPI = component.find('workspace');
		workspaceAPI.getFocusedTabInfo().then(response => {
			let focusedTabId = response.tabId;
			workspaceAPI.refreshTab({
				tabId: focusedTabId,
				includeAllSubtabs: true
			});
		})
		.catch();
	},


	//-------Metodos onboarding---------
	modalOnboardingAbrir: function(component, event, helper) {
		window.setTimeout($A.getCallback(() => {
			$A.util.addClass(component.find('ModalBoxOnboarding'), 'slds-fade-in-open');
			$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
			component.find('ModalBoxOnboarding').focus();
		}), 200);
	},

	modalOnboardingCerrar: function(component, event, helper) {
		component.set('v.valueInputDNI', null);

		let pillTarget = component.find('lookup-pill-queue');
		$A.util.addClass(pillTarget, 'slds-hide');
		$A.util.removeClass(pillTarget, 'slds-show');

		let lookUpTarget = component.find('lookupFieldQueue');
		$A.util.addClass(lookUpTarget, 'slds-show');
		$A.util.removeClass(lookUpTarget, 'slds-hide');

		$A.util.removeClass(component.find('ModalBoxOnboarding'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	modalOnboardingTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalOnboardingCerrar'));
		}
	},

	validarDNIOnboarding: function(component, event) {
		let valorTest = component.get('v.valueInputDNI');
		if (component.find('inputDNIOnboarding').get('v.value') == null || component.find('inputDNIOnboarding').get('v.value') == '') {
			component.set('v.botonValidarOnboarding', true);
		} else {
			component.set('v.botonValidarOnboarding', false);
		}
	},
	//-------Fin Metodos onboarding---------

	desactivarSpinnerDerivar: function(component) {
		component.set('v.spinnerActivado', false);
	}

/*
tareaGestorEmpleadoSeleccionadoOnChange: function(component, event) {
	//Matrícula del gestor
	let empleadoSeleccionadoValue = event.getParam('value');
	component.set('v.comboboxEmpleadoSeleccionado', empleadoSeleccionadoValue);

	//Nombre del gestor
	let empleadoSeleccionadoLabel;
	component.get('v.comboboxEmpleadosOptions').forEach(e => {
		if (e.value === empleadoSeleccionadoValue) {
			empleadoSeleccionadoLabel = e.label;
		}
	});
	component.set('v.nombreGestor', empleadoSeleccionadoLabel);
}
*/
});