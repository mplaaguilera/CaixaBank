({
	init: function(component) {
		let cargar = component.get('c.initComponentOp');
		cargar.setParam('caseId', component.get('v.recordId'));
		cargar.setCallback(this, response => {
			let result = response.getReturnValue();

			//checkorg y zona
			component.set('v.orgZona', result.vControlarOrgZona);
			component.set('v.iniciando', component.get('v.iniciando') + 1);

			//controlar ps
			component.set('v.esSupervisorEstado', result.vControlarPS);

			component.set('v.iniciando', component.get('v.iniciando') + 1);

			//controlar rt contacto
			component.set('v.esContactoEmpleado', result.vControlarRT);

			//Controlar Org-Zona de Grupos y Caso
			component.set('v.caseOrgZonaGroup', result.vControlarOrgZonaCaseGrupo);

			//Controlar UsuarioBO
			component.set('v.esUsuarioBO', result.vEsUsuarioBO);

			//Controlar AOR
			component.set('v.aorActivo', result.vControlarAORActivo);

			//Controlar RT Caso
			component.set('v.RTSeguimiento', result.vRTSeguimiento);

			if (!result.vRTSeguimiento && !result.vControlarPS) {

				component.set('v.controlRTyPS', true);

			}

		});
		$A.enqueueAction(cargar);
	},

	casoUpdatedDataService: function(component, event) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			component.set('v.esPropietario', $A.get('$SObjectType.CurrentUser.Id') === component.get('v.caso.OwnerId'));
			if (event.getParams().changeType === 'CHANGED') {
				//component.find('caseData').reloadRecord();
				let comprobacionOrgZonaGrupo = component.get('c.comprobacionGrupo');
				comprobacionOrgZonaGrupo.setParam('caseId', component.get('v.recordId'));
				comprobacionOrgZonaGrupo.setCallback(this, response => {
					let result = response.getReturnValue();
					component.set('v.caseOrgZonaGroup', result);
				});
				$A.enqueueAction(comprobacionOrgZonaGrupo);

			}
		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.errorLds'));
		}
	},

	busquedaGrupos: function(component) {
		let allGroups = component.get('v.grupos');
		let searchKey = component.find('gpName').get('v.value');
		let selected = [];
		if (searchKey) {
			allGroups.forEach(value => {
				let name = value.label.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
				if (name.includes(searchKey.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, ''))) {
					selected.push({label: value.label, value: value.value});
				}
			});
			component.set('v.groups', selected);
			component.set('v.mostrarGrupos', true);
		} else {
			component.set('v.groups', allGroups);
			component.set('v.mostrarGrupos', true);
		}
	},

	getGroups: function(component) {
		clearTimeout(component.get('v.searchTimeoutId'));
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		component.set('v.searchTimeoutId', setTimeout($A.getCallback(() => {
			let buscadorGrupos = component.get('c.buscadorGrupos');
			buscadorGrupos.setParams({
				'caseId': component.get('v.recordId'),
				'searchKey': component.find('gpName').get('v.value')
			});
			buscadorGrupos.setCallback(this, response => {
				let values = [];
				let result = response.getReturnValue();
				for (let key in result) {
					if (Object.prototype.hasOwnProperty.call(result, key)) {
						values.push({label: result[key].Name, value: key});
					}
				}
				component.set('v.groups', values);
			});
			$A.enqueueAction(buscadorGrupos);
		}), 300));
	},

	seleccionarGrupo: function(component, event) {
		component.set('v.groupName', event.currentTarget.name);
		component.set('v.selectedGroup', event.currentTarget.id);
		component.find('gpName').set('v.value', event.currentTarget.name);
	},

	cargarNotasTipificadas: function(component) {
		let fetchNotasTipificadas = component.get('c.fetchNotasTipificadas');
		fetchNotasTipificadas.setParam('caseId', component.get('v.recordId'));
		fetchNotasTipificadas.setCallback(this, response => {
			let result = response.getReturnValue();
			let values = [];
			for (let key in result) {
				if (Object.prototype.hasOwnProperty.call(result, key)) {
					values.push({label: result[key], value: key});
				}
			}
			values.push({label: 'Sin notas', value: 'Sin notas'});
			component.set('v.notasTipificadas', values);
		});
		$A.enqueueAction(fetchNotasTipificadas);
	},

	tomarPropiedad: function(component, event, helper) {
		component.set('v.spinner', true);
		let tomarPropiedadCaso = component.get('c.tomarPropiedadCasoOld');
		tomarPropiedadCaso.setParams({
			'caseId': component.get('v.recordId'),
			'ownerId': $A.get('$SObjectType.CurrentUser.Id')
		});
		tomarPropiedadCaso.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				let verificarUsuarioBO = component.get('c.verificarUsuarioBO');
				verificarUsuarioBO.setParams({
					'idUser': $A.get('$SObjectType.CurrentUser.Id')
				});
				verificarUsuarioBO.setCallback(this, response => {
					let state = response.getState();
					let result = response.getReturnValue();
					if (state === 'SUCCESS') {
						component.set('v.esUsuarioBO', result);
					} else if (state === 'ERROR') {
						let errors = response.getError();
						helper.mostrarToast('error', 'Error', errors[0].message);
					}
					helper.reinit(component);
				});				
				$A.enqueueAction(verificarUsuarioBO);
			} else if (state === 'ERROR') {
				let errors = response.getError();
				helper.mostrarToast('error', 'Error', errors[0].message);
			}
			helper.reinit(component);
			component.set('v.spinner', false);
		});
		$A.enqueueAction(tomarPropiedadCaso);
	},

	modalCerrarAbrir: function(component) {
		if (component.get('v.resultados').length === 0) {
			let getResultados = component.get('c.recuperarMapResultados');
			getResultados.setCallback(this, response => {
				let values = [];
				let result = response.getReturnValue();
				for (let key in result) {
					if (Object.prototype.hasOwnProperty.call(result, key)) {
						values.push({label: result[key], value: key});
					}
				}
				component.set('v.resultados', values);
			});
			$A.enqueueAction(getResultados);

			/*
			let getResultados = component.get('c.recuperarResultados');
			getResultados.setCallback(this, response => {
				let values = [];
				let result = response.getReturnValue();
				for (let key in result) {
					values.push({label: result[key], value: key});
				}
				component.set('v.resultados', values);
			});
			$A.enqueueAction(getResultados);
			*/
		}
		component.set('v.numOperacionesCaso', component.get('v.caso.SEG_N_operaciones_del_caso__c'));
		
		if(component.get('v.caso.SEG_Detalle__r.SEG_Criterio_imputacion_operaciones__c') != null){
			component.set('v.criterioImputacion', component.get('v.caso.SEG_Detalle__r.SEG_Criterio_imputacion_operaciones__c'));
		} else if(component.get('v.caso.CC_MCC_Motivo__r.SEG_Criterio_imputacion_operaciones__c') != null){
			component.set('v.criterioImputacion', component.get('v.caso.CC_MCC_Motivo__r.SEG_Criterio_imputacion_operaciones__c'));
		} else if(component.get('v.caso.CC_MCC_ProdServ__r.SEG_Criterio_imputacion_operaciones__c') != null){
			component.set('v.criterioImputacion', component.get('v.caso.CC_MCC_ProdServ__r.SEG_Criterio_imputacion_operaciones__c'));
		} else if(component.get('v.caso.CC_MCC_Tematica__r.SEG_Criterio_imputacion_operaciones__c') != null){
			component.set('v.criterioImputacion', component.get('v.caso.CC_MCC_Tematica__r.SEG_Criterio_imputacion_operaciones__c'));
		}

		component.set('v.renderizarModales', true);
		component.set('v.selectedNotasTip', 'Sin notas');
		$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalCerrar'), 'slds-fade-in-open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('resultados').focus()), 200);
	},

	modalCerrarCerrar: function(component) {
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalCerrar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalCasoAuditoria'), 'slds-fade-in-open');
		component.find('resultados').set('v.value', null);
		component.find('observacionCerrar').set('v.value', null);
		$A.util.removeClass(component.find('resultados'), 'slds-has-error');

		//Botones
		$A.util.removeClass(component.find('modalBotonSiguiente'), 'slds-hide');
		$A.util.removeClass(component.find('modalCerrarBotonIniciar'), 'slds-show');
		$A.util.addClass(component.find('modalBotonSiguiente'), 'slds-show');
		$A.util.addClass(component.find('modalCerrarBotonIniciar'), 'slds-hide');

		//Div Inputs
		$A.util.removeClass(component.find('divInputResultados'), 'slds-hide');
		$A.util.removeClass(component.find('divBotonesNumOperaciones'), 'slds-show');
		$A.util.addClass(component.find('divInputResultados'), 'slds-show');
		$A.util.addClass(component.find('divBotonesNumOperaciones'), 'slds-hide');

		component.set('v.numOperacionesCambio', true);

	},
	cerrarSiguiente: function(component) {
		component.set('v.numOperacionesCambio', false);
		//Div Inputs
		$A.util.removeClass(component.find('divInputResultados'), 'slds-show');
		$A.util.removeClass(component.find('divBotonesNumOperaciones'), 'slds-hide');
		$A.util.addClass(component.find('divInputResultados'), 'slds-hide');
		$A.util.addClass(component.find('divBotonesNumOperaciones'), 'slds-show');
	},

	modalRechazarCerrar: function(component) {
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalRechazar'), 'slds-fade-in-open');
	},

	modalRechazarAbrir: function(component) {
		component.set('v.renderizarModales', true);
		component.set('v.selectedNotasTip', 'Sin notas');
		$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalRechazar'), 'slds-fade-in-open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('modalRechazarBotonCancelar').focus()), 200);
	},

	rechazarSR: function(component, event, helper) {
		component.find('modalRechazarBotonIniciar').set('v.disabled', true);
		let action = component.get('c.rechazarCaso');
		action.setParam('caseId', component.get('v.recordId'));
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.find('botonRechazarSR').set('v.disabled', true);
				helper.reinit(component);
				//let toastEvent = $A.get('e.force:showToast');
				//toastEvent.setParams({'title': 'Éxito!', 'message': 'Se ha rechazado el caso correctamente.', 'type': 'success'});
				//toastEvent.fire();
				$A.enqueueAction(component.get('c.modalRechazarCerrar'));
			} else if (response.getState() === 'ERROR') {
				let errors = response.getError();
				helper.mostrarToast('error', 'Error rechazando el caso', errors[0].message);
				console.error(JSON.stringify(errors));
			}
			component.find('modalRechazarBotonIniciar').set('v.disabled', false);
		});
		$A.enqueueAction(action);
	},

	modalAutoasignarAbrir: function(component) {
		component.set('v.renderizarModales', true);
		component.set('v.datosAdicionalesValija', false);
		component.set('v.loadingDatosAdicionales', false);
		component.set('v.notasManuales', '');
		component.set('v.dataAnexos', []);
		component.set('v.datosTrasladoCalculados', '');
		component.set('v.currentSelectedRowsAnexos', []);
		$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalAutoasignar'), 'slds-fade-in-open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('modalAutoasignarBotonCancelar').focus()), 200);
	},

	modalAnyadirOperacionAbrir: function(component) {
		component.set('v.renderizarModales', true);
		$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalOperaciones'), 'slds-fade-in-open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('modalAnyadirOperacionCerrar').focus()), 200);
	},

	modalAnyadirOperacionCerrar: function(component) {
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalOperaciones'), 'slds-fade-in-open');
		component.set('v.selectedNotasTip', 'Sin notas');
		component.find('idObservacionOperaciones').set('v.value', '');

	},

	modalAnyadirOperaciones: function(component, event, helper) {
		component.set('v.loadingCreandoCaso', true);
		let caseId = component.get('v.recordId');
		let mccId = component.get('v.valorMCC');
		let numOperaciones = component.find('idNumOperaciones').get('v.value');
		let anyadirOp = component.get('c.anyadirOperaciones');
		let notaTipificada = component.get('v.selectedNotasTip');
		let observaciones = component.find('idObservacionOperaciones').get('v.value');
		let operativa = 'Añadir operaciones';
		anyadirOp.setParams({
			'caseId': caseId,
			'mccId': mccId,
			'numOperaciones': numOperaciones
		});
		anyadirOp.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				//La operación se ha creado con éxito
				$A.enqueueAction(component.get('c.modalAnyadirOperacionCerrar'));
				let publicar = component.get('c.postOnChatter');
				publicar.setParams({'caseId': caseId, 'observaciones': observaciones, 'operativa': operativa, 'notaTipificada': notaTipificada});
				$A.enqueueAction(publicar);
				//helper.mostrarToast('success', '¡Éxito!', 'La operación se ha creado correctamente.');
			} else if (response.getState() === 'ERROR') {
				helper.mostrarToast('error', 'No se ha creado la operación', JSON.stringify(response.getError()).replace(/{|}|[|]/gi, ' '));
				console.error(JSON.stringify(response.getError()));
			}
			component.set('v.loadingCreandoCaso', false);
			helper.reinit(component);
		});
		$A.enqueueAction(anyadirOp);
	},

	modalAutoasignarCerrar: function(component) {
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalAutoasignar'), 'slds-fade-in-open');
		component.set('v.selectedNotasTip', 'Sin notas');
		component.set('v.datosAdicionalesValija', false);
		component.set('v.loadingDatosAdicionales', false);
		component.set('v.notasManuales', '');
		component.set('v.dataAnexos', []);
		component.set('v.datosTrasladoCalculados', '');
		component.set('v.currentSelectedRowsAnexos', []);
		component.find('idObservacionAutoasginacion').set('v.value', '');
	},

	modalAutoasignarValijaCerrar: function(component) {
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalValija'), 'slds-fade-in-open');
		component.set('v.selectedNotasTip', 'Sin notas');
		component.set('v.datosAdicionalesValija', false);
		component.set('v.loadingDatosAdicionales', false);
		component.set('v.notasManuales', '');
		component.set('v.dataAnexos', []);
		component.set('v.datosTrasladoCalculados', '');
		component.set('v.currentSelectedRowsAnexos', []);
		component.find('idObservacionAutoasginacion').set('v.value', '');
	},

	autoasignar: function(component, event, helper) {
		let caseLoadedId = component.get('v.recordId');
		component.find('modalAutoasignarBotonIniciar').set('v.disabled', true);
		let asignar = component.get('c.autoAsignarGrupoAura');
		//asignar.setParam('caseId', component.get('v.recordId'));
		asignar.setParams({
			'caseId': caseLoadedId,
			'bAutomatico': false,
			'entradaPaqueteriaPAK': false
		});
		asignar.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {

				let datosAsignacion = response.getReturnValue();

				if (datosAsignacion.errorProceso !== 'N') {
					/*if (datosAsignacion.errorGrupoAuto == '1' && datosAsignacion.detalleError == '') {
						//Error en el cálculo de grupo automático sin cuenta informada.
						helper.mostrarToast('warning', '¡Advertencia!', 'El caso no tiene cuenta informada por lo que se ha asignado a un grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '2' && datosAsignacion.detalleError == '') {
						//Error en el cálculo de grupo standard.
						helper.mostrarToast('warning', '¡Advertencia!', 'La cuenta del caso no tiene el gestor informado por lo que se ha asignado a un grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '3' && datosAsignacion.detalleError == '') {
						//Error en el cálculo de grupo standard.
						helper.mostrarToast('warning', '¡Advertencia!', 'La cuenta del caso no tiene centro parametrizado por lo que se ha asignado a un grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '4' && datosAsignacion.detalleError == '') {
						//Error en el cálculo de grupo standard.
						helper.mostrarToast('warning', '¡Advertencia!', 'La cuenta del caso es un centro por lo que el caso se ha asignado a un grupo standard.');
					} else*/
					if (datosAsignacion.errorGrupoAuto === '5') {
						//Error en el cálculo de grupo standard.
						helper.mostrarToast('warning', '¡Advertencia!', 'El caso no se ha podido asignar al grupo designado por el automatismo ni existe un grupo standard para esta Organización y Zona. Por favor, contacta con el administrador.');
					} else if (datosAsignacion.errorGrupoAuto == '8') {
						//Error en la assignación de excepciones al caso.
						helper.mostrarToast('warning', '¡Advertencia!', 'Se han encontrado dos o más excepciones de asignación para este caso. Por favor, contacte con el administrador del sistema.');
					} else {
						//Error en el cálculo de grupo automático sin cuenta informada.
						let mensajeError = datosAsignacion.detalleError;
						if (mensajeError == null || mensajeError == undefined || mensajeError == '') {
							mensajeError = 'Se ha producido un error desconocido en el proceso de autoasignacion. Contacte con el administrador del sistema.';
						}
						helper.mostrarToast('warning', '¡Advertencia!', mensajeError);
					}
				} else {
					let avisoMostrado = false;
					if (datosAsignacion.errorGrupoAuto == '1') {
						//Error en el cálculo de grupo automático sin cuenta informada.
						avisoMostrado = true;
						helper.mostrarToast('warning', '¡Advertencia!', 'El caso no tiene cuenta informada por lo que se ha asignado a un grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '2') {
						//Error en el cálculo de grupo standard.
						avisoMostrado = true;
						helper.mostrarToast('warning', '¡Advertencia!', 'El gestor no pertenece a ningún grupo, por lo que el caso se ha asignado al grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '3') {
						//Error en el cálculo de grupo standard.
						avisoMostrado = true;
						helper.mostrarToast('warning', '¡Advertencia!', 'La cuenta del caso no tiene centro parametrizado por lo que se ha asignado a un grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '4') {
						//Error en el cálculo de grupo standard.
						avisoMostrado = true;
						helper.mostrarToast('warning', '¡Advertencia!', 'La cuenta del caso es un centro por lo que el caso se ha asignado a un grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '6') {
						avisoMostrado = true;
						helper.mostrarToast('warning', '¡Advertencia!', 'No se puede autoasignar el caso al grupo destino ya que pertenece a otra organización/zona. Consultar con un supervisor si se debe cambiar la carterización del cliente u organización/zona del caso.');
					} else if (datosAsignacion.errorGrupoAuto == '7') {
						avisoMostrado = true;
						helper.mostrarToast('error', 'No se ha asignado el caso', 'No se puede realizar el envío de correo, el caso no tiene informado el campo Gestor Comercial.');
					} else if (datosAsignacion.errorGrupoAuto == '9') {
						avisoMostrado = true;
						helper.mostrarToast('error', 'No se ha asignado el caso', 'No es posible asignar el caso a Valija sin tener el centro informado.');
					}

					if (datosAsignacion.requiereInfoAdicional == 'Y') {
						//Obtener record type del contacto asociado al caso
						if (component.get('v.esContactoEmpleado')) {
							//mostrar mensaje de error indicando que el contacto no es valido
							helper.mostrarToast('error', '¡Error!', 'No se puede realizar un envío a valija cuando el contacto del caso es un empleado.');
							//Cerrar el modal de autoasignar
							$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
							$A.util.removeClass(component.find('modalAutoasignar'), 'slds-fade-in-open');
						} else {

							//Cerrar el modal actual de autoasignar.
							$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
							$A.util.removeClass(component.find('modalAutoasignar'), 'slds-fade-in-open');

							//Es un traslado a Valija. Requiere revisar información adicional.
							component.set('v.caseIdValija', component.get('v.recordId'));
							component.set('v.datosAdicionalesValija', true);
							component.set('v.loadingDatosAdicionales', true);
							component.set('v.datosTrasladoCalculados', datosAsignacion.datosCalculadosTraslado);
							component.set('v.datosImpuestosModificados', false);

							let caracteresRestantes = 255 - component.find('idObservacionValija').get('v.value').length;
							component.set('v.enviarNotificacionCaracteresRestantes', caracteresRestantes);

							//Preparar apertura del modal Valija.
							$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
							$A.util.addClass(component.find('modalValija'), 'slds-fade-in-open');
							//eslint-disable-next-line @lwc/lwc/no-async-operation
							window.setTimeout($A.getCallback(() => component.find('modalAutoasignarBotonValijaCancelar').focus()), 200);

							//Preparar los ficheros adjuntos.
							let extensionesExcluidas = ['snote', 'html', 'htm'];
							component.set('v.dataAnexos', '');
							component.set('v.currentSelectedRowsAnexos', []);
							let getAnexos = component.get('c.getFilesCaseFiltroExt');
							//getAnexos.setParam('casoId', component.get('v.recordId'));
							getAnexos.setParams({
								'casoId': component.get('v.recordId'),
								'extensionesExcluir': extensionesExcluidas
							});
							getAnexos.setCallback(this, response => {
								if (response.getState() === 'SUCCESS') {
									component.set('v.dataAnexos', response.getReturnValue());
								}
							});
							$A.enqueueAction(getAnexos);

							component.set('v.columnasAnexos', [
								//{label: 'ID', fieldName: 'Id', type: 'text'},
								{label: 'Nombre', fieldName: 'Title', type: 'text'},
								{label: 'Extensión', fieldName: 'FileExtension', type: 'text'},
								{label: 'Descripción', fieldName: 'Description', type: 'text'}
							]);
						}
					} else if (datosAsignacion.asignado == 'Y') {
						if (!avisoMostrado) {
							//El caso se ha asignado.
							//helper.mostrarToast('success', '¡Éxito!', 'El grupo se ha asignado correctamente.');
							helper.postChatter(component, component.get('v.recordId'), 'Autoasignar caso', component.get('v.selectedNotasTip'), component.find('idObservacionAutoasginacion').get('v.value'));
						}
						$A.enqueueAction(component.get('c.modalAutoasignarCerrar'));
					} else {
						if (datosAsignacion.errorGrupoAuto != '6' && datosAsignacion.errorGrupoAuto != '7') {
							helper.mostrarToast('info', 'No se ha asignado el caso', 'No se ha encontrado un grupo para el caso.');
							$A.enqueueAction(component.get('c.modalAutoasignarCerrar'));
						} else if (datosAsignacion.errorGrupoAuto == '7') {
							$A.enqueueAction(component.get('c.modalAutoasignarCerrar'));
						}
					}

				}
				/*OLD.
				let result = response.getReturnValue();
				if (result) {
					helper.mostrarToast('success', '¡Éxito!', 'El grupo se ha asignado correctamente.');
					component.set('v.selectedNotasTip', 'Sin notas');
					helper.postChatter(component, component.get('v.recordId'), 'Autoasignar caso', component.get('v.selectedNotasTip'), component.find('idObservacionAutoasginacion').get('v.value'));
					$A.enqueueAction(component.get('c.modalAutoasignarCerrar'));
				} else {
					helper.mostrarToast('info', 'No se ha asignado el caso', 'No se ha encontrado un grupo para el caso.');
				}
				FIN OLD*/
				helper.reinit(component);
				//FIX. Si está la línea aquí, los traslados a valija no funcionan. $A.enqueueAction(component.get('c.modalAutoasignarCerrar'));

			} else if (response.getState() === 'ERROR') {
				helper.mostrarToast('error', 'No se ha asignado el caso', JSON.stringify(response.getError()).replace(/{|}|[|]/gi, ' '));
				console.error(JSON.stringify(response.getError()));
			}
			component.find('modalAutoasignarBotonIniciar').set('v.disabled', false);
		});
		$A.enqueueAction(asignar);
	},

	autoasignarValija: function(component, event, helper) {

		//Validar que no existan cambios pendientes de guardar en relación a los impuestos.

		let datosImpuestosGuardados = component.get('v.datosImpuestosModificados');
		if (datosImpuestosGuardados === true) {
			let errorAux = 'Para poder traspasar a Valija debe guardar los datos de impuestos que has modificado (se ha de pulsar el botón <Actualizar caso> de la sección <Datos de impuestos>).';
			helper.mostrarToast('warning', 'No se ha asignado el caso', errorAux);
			return;
		}

		//Validar que exista un fichero como mínimo seleccionado.
		let listaFicheros = component.get('v.currentSelectedRowsAnexos');
		if (listaFicheros === null || listaFicheros === undefined || listaFicheros.length === 0) {
			let errorAux = 'Para poder traspasar a Valija debe seleccionar como mínimo un fichero';
			helper.mostrarToast('warning', 'No se ha asignado el caso', errorAux);
			return;
		}

		//Validar que el caso tenga un número de operaciones informado.
		let operacionesCaso = component.find('caseOperations').get('v.value');
		if (operacionesCaso == null || operacionesCaso == undefined || operacionesCaso == '') {
			let errorAux = 'Para poder traspasar a Valija debe indicar el número de operaciones del caso';
			helper.mostrarToast('warning', 'No se ha asignado el caso', errorAux);
			return;
		}

		//Validar el tamaño de las observaciones.
		if (component.get('v.enviarNotificacionCaracteresRestantes') < 0) {
			let errorAux = 'Para poder traspasar a Valija debe revisar la longitud de las notas que has escrito';
			helper.mostrarToast('warning', 'No se ha asignado el caso', errorAux);
			return;
		}
		if (component.get('v.emailNoInformadoValija')) {
			let errorAux = 'No se permite realizar el envío a valija dado que el contacto no tiene email informado';
			helper.mostrarToast('warning', 'No se ha asignado el caso', errorAux);
			return;
		}

		/*component.find('modalAutoasignarBotonValija').set('v.disabled', true);
		component.find('modalAutoasignarBotonValijaCancelar').set('v.disabled', true);*/


		let button1 = component.find('modalAutoasignarBotonValija');
		button1.set('v.disabled', true);
		let button2 = component.find('modalAutoasignarBotonValijaCancelar');
		button2.set('v.disabled', true);
		let datosTraslado = component.get('v.datosTrasladoCalculados');
		let notasManuales = component.get('v.notasManuales');
		let notaTipificada = component.get('v.selectedNotasTip');
		let asignar = component.get('c.confirmarTrasladoValija');
		asignar.setParams({
			'datosTrasladoJSON': datosTraslado,
			'notasManuales': notasManuales,
			'listaFicheros': listaFicheros
		});
		asignar.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let datosAsignacion = response.getReturnValue();
				if (datosAsignacion.codigo == '0') {
					//helper.mostrarToast('success', '¡Éxito!', 'El grupo de Valija se ha asignado correctamente. Se ha iniciado el proceso de traslado a Valija y puedes consultar el estado en el chatter del caso');
					helper.postChatter(component, component.get('v.recordId'), 'Autoasignar caso', notaTipificada, notasManuales);
					$A.enqueueAction(component.get('c.modalAutoasignarCerrar'));
				} else {
					let errorAux = 'Se ha producido un error al asignar el caso. Mas información: ' + datosAsignacion.detalle;
					helper.mostrarToast('warning', 'No se ha asignado el caso', errorAux);
				}
			} else if (response.getState() === 'ERROR') {
				helper.mostrarToast('error', 'No se ha asignado el caso', JSON.stringify(response.getError()).replace(/{|}|[|]/gi, ' '));
				console.error(JSON.stringify(response.getError()));
			}
			component.find('modalAutoasignarBotonValija').set('v.disabled', false);
			component.find('modalAutoasignarBotonValijaCancelar').set('v.disabled', false);
		});
		$A.enqueueAction(asignar);
	},

	actualizarEnviarNotificacionCaracteresRestantes: function(component) {
		let caracteresRestantes = 255 - component.find('idObservacionValija').get('v.value').length;
		component.set('v.enviarNotificacionCaracteresRestantes', caracteresRestantes);

		if (caracteresRestantes < 21) {
			$A.util.addClass(component.find('divEnviarNotificacionCaracteresRestantes'), 'seg-rojo');
		} else {
			$A.util.removeClass(component.find('divEnviarNotificacionCaracteresRestantes'), 'seg-rojo');
		}
	},

	modalDevolverAbrir: function(component) {
		component.set('v.selectedNotasTip', 'Sin notas');
		component.set('v.renderizarModales', true);
		$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalDevolver'), 'slds-fade-in-open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('modalDevolverBotonCancelar').focus()), 200);
	},

	modalAORAbrir: function(component, event, helper) {

		if (component.get('v.caso.SEG_Numero_centro__c') == null) {
			helper.mostrarToast('warning', 'No es posible consultar con Asesoría', 'Es necesario que el caso cuente con número de centro.');
		} else {
			//controlar Botón AOR (Eric)
			let actionAOR = component.get('c.getDependentPicklistAOR');
			actionAOR.setParams({
				objectName: component.get('v.objectNameAOR'),
				parentField: component.get('v.AORTipologiaN1API'),
				childField: component.get('v.AORTipologiaN2API')
			});
			actionAOR.setCallback(this, response => {
				let statusAOR = response.getState();
				if (statusAOR === 'SUCCESS') {
					let pickListResponseAOR = response.getReturnValue();

					//guardo la respuesta
					component.set('v.pickListMapAOR', pickListResponseAOR.pickListMap);
					component.set('v.parentFieldLabel', pickListResponseAOR.parentFieldLabel);
					component.set('v.childFieldLabel', pickListResponseAOR.childFieldLabel);

					//creo un array vacío para almacenar los valores de las picklist
					let parentKeysAOR = [];
					let parentFieldAOR = [];

					//almaceno los valores del padre
					for (let pickKey in pickListResponseAOR.pickListMap) {
						if (Object.prototype.hasOwnProperty.call(pickListResponseAOR.pickListMap, pickKey)) {
							parentKeysAOR.push(pickKey);
						}
					}

					//poner los valores del padre en la selección
					if (parentKeysAOR != undefined && parentKeysAOR.length > 0) {
						parentFieldAOR.push('Seleccione un valor...');
					}

					for (let i = 0; i < parentKeysAOR.length; i++) {
						parentFieldAOR.push(parentKeysAOR[i]);
					}

					//poner la lista del campo padre
					component.set('v.parentListAOR', parentFieldAOR);

					//Poner los ficheros adjuntos
					let getAnexosAOR = component.get('c.getFilesCase');
					getAnexosAOR.setParam('casoId', component.get('v.recordId'));
					getAnexosAOR.setCallback(this, response => {
						if (response.getState() === 'SUCCESS') {
							component.set('v.dataAnexos', response.getReturnValue());
						}
					});
					$A.enqueueAction(getAnexosAOR);

					component.set('v.columnasAnexos', [
						//{label: 'ID', fieldName: 'Id', type: 'text'},
						{label: 'Nombre', fieldName: 'Title', type: 'text'},
						{label: 'Extensión', fieldName: 'FileExtension', type: 'text'},
						{label: 'Descripción', fieldName: 'Description', type: 'text'},
						{label: 'Fecha de subida', fieldName: 'CreatedDate', type: "date", typeAttributes:{
							month: 'numeric',
							day: 'numeric',
							year: 'numeric',
							hour:'2-digit' ,
							minute:'2-digit',
							second: '2-digit',
							timeZone:'Europe/Paris'
						  }
						}
						
					]);
					//eslint-disable-next-line @lwc/lwc/no-async-operation
					window.setTimeout($A.getCallback(() => component.find('modalAORBotonCancelar').focus()), 200);

				}
			});
			$A.enqueueAction(actionAOR);

			component.set('v.renderizarModales', true);
			$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
			$A.util.addClass(component.find('modalAOR'), 'slds-fade-in-open');
			if (component.get('v.caso.SEG_Identificador_AOR__c')) {
				component.find('modalAORBotonIniciarRitm').set('v.disabled', false);
			}

			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => component.find('modalAORBotonCancelar').focus()), 200);
		}

	},

	parentFieldChange: function(component) {
		let controllerValueAOR = component.find('tipologiaN1').get('v.value');
		let picklistMap = component.get('v.pickListMapAOR');

		if (controllerValueAOR != 'Seleccione un valor...') {

			//Rescatamos los valores del hijo
			let childValues = picklistMap[controllerValueAOR];
			let childValueList = [];
			childValueList.push('Seleccione un valor...');
			for (let i = 0; i < childValues.length; i++) {
				childValueList.push(childValues[i]);
			}

			//ponemos los valores del hijo
			component.set('v.childListAOR', childValueList);

			if (childValues.length > 0) {
				component.set('v.disabledChildFieldAOR', false);
			} else {
				component.set('v.disabledChildFieldAOR', true);
			}

		} else {
			component.set('v.childListAOR', ['Clasificación 2']);
			component.set('v.disabledChildFieldAOR', true);
		}
	},

	asignarSegBO: function(component, event, helper) {
		component.find('modalDevolverBotonIniciar').set('v.disabled', true);
		let devolverSegBO = component.get('c.devolverSegBO');
		devolverSegBO.setParam('caseId', component.get('v.recordId'));
		devolverSegBO.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				if (response.getReturnValue() === 'Actualizado') {
					helper.postChatter(component, component.get('v.recordId'), 'Devolver caso', component.get('v.selectedNotasTip'), component.find('observacionId').get('v.value'));
					$A.enqueueAction(component.get('c.modalDevolverCerrar'));
					//helper.mostrarToast('success', 'Caso devuelto', 'El caso se devolvió correctamente');
					//helper.reinit(component); --> SE refresca tras escribir en el chatter.
				} else {
					helper.mostrarToast('Error', 'No se ha podido devolver', 'El caso necesita tener cola de trabajo asignada');
				}
			} else if (state === 'ERROR') {
				let errors = response.getError();
				if (errors) {
					let detalleError;
					if (errors[0] && errors[0].message) {
						detalleError = errors[0].message;
					} else {
						detalleError = JSON.stringify(errors);
					}
					console.error('No se ha podido devolver el caso: ' + detalleError);
					helper.mostrarToast('error', 'Error devolviendo caso', detalleError);
				}
			}
			component.find('modalDevolverBotonIniciar').set('v.disabled', false);
		});
		$A.enqueueAction(devolverSegBO);
	},

	modalDevolverGrupoCerrar: function(component) {
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalDevolverGrupo'), 'slds-fade-in-open');
		component.find('observacion').set('v.value', null);
	},

	modalDevolverGrupoAbrir: function(component) {
		component.set('v.renderizarModales', true);
		$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalDevolverGrupo'), 'slds-fade-in-open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('modalDevolverGrupoBotonCancelar').focus()), 200);
	},

	asignarGrupoAnterior: function(component, event, helper) {
		component.find('modalDevolverGrupoBotonIniciar').set('v.disabled', true);

		let devolverGrupo = component.get('c.devolverGrupoAnterior');
		let notaTip = component.get('v.selectedNotasTip');
		let observacion = component.find('observacion').get('v.value');
		devolverGrupo.setParam('caseId', component.get('v.recordId'));
		$A.enqueueAction(devolverGrupo);
		devolverGrupo.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				//helper.reinit(component); --> SE refresca tras escribir en el chatter.
				component.set('v.selectedNotasTip', 'Sin notas');
				$A.enqueueAction(component.get('c.modalDevolverGrupoCerrar'));
			}
			component.find('modalDevolverGrupoBotonIniciar').set('v.disabled', false);

			helper.postChatter(component, component.get('v.recordId'), 'Devolver a grupo anterior', notaTip, observacion);
			//helper.mostrarToast('success', 'Caso devuelto', 'El caso se devolvió correctamente');

			/*let publicar = component.get('c.postOnChatter');
			publicar.setParams({'caseId': component.get('v.recordId'), 'observaciones': observacion, 'operativa': 'Devolver a grupo anterior', 'notaTipificada': notaTip});
			$A.enqueueAction(publicar);*/
		});

	},

	modalAsignarGrupoAbrir: function(component) {
		let recuperarGrupos = component.get('c.recuperarGrupos');
		recuperarGrupos.setParam('caseId', component.get('v.recordId'));
		recuperarGrupos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let values = [];
				let result = response.getReturnValue();
				for (let key in result) {
					if (Object.prototype.hasOwnProperty.call(result, key)) {
						values.push({label: result[key], value: key});
					}
				}
				component.set('v.grupos', values);
				component.set('v.groups', values);

				component.set('v.renderizarModales', true);
				$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
				$A.util.addClass(component.find('modalAsignarGrupo'), 'slds-fade-in-open');
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout($A.getCallback(() => component.find('modalAsignarGrupoBotonCancelar').focus()), 200);
			}
		});
		$A.enqueueAction(recuperarGrupos);
	},

	modalAsignarGrupoCerrar: function(component) {
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalAsignarGrupo'), 'slds-fade-in-open');
		component.find('idObservacion').set('v.value', '');
		component.set('v.selectedNotasTip', 'Sin notas');
		component.set('v.groupName', null);
		component.find('gpName').set('v.value', null);
	},

	inputBuscarGruposFocus: function(component) {
		component.set('v.mostrarGrupos', true);
	},

	inputBuscarGruposBlur: function(component) {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.set('v.mostrarGrupos', false)), 500);
	},

	modalCrearVinculadosAbrir: function(component, event, helper) {
		component.set('v.casoCreadoId', '');
		component.set('v.notasManuales', '');
		component.set('v.columnasAnexos', [
			{label: 'Título', fieldName: 'Title', type: 'text'},
			{label: 'Extensión', fieldName: 'FileExtension', type: 'text'},
			{label: 'Descripción', fieldName: 'Description', type: 'text'}
		]);
		helper.setDataAnexos(component);
		component.set('v.renderizarModales', true);
		$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalCrearVinculados'), 'slds-fade-in-open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('modalCrearVinculadosBotonCancelar').focus()), 200);
	},

	selectedRowsAnexos: function(component, event) {
		let selectedRows = event.getParam('selectedRows');
		let currentSelectedRows = [];
		//currentSelectedRows=component.get('v.currentSelectedRowsAnexos');
		selectedRows.forEach(selectedRow => {
			currentSelectedRows.push(selectedRow.ContentDocumentId);
		});
		component.set('v.currentSelectedRowsAnexos', currentSelectedRows);
	},

	modalCrearVinculadosCerrar: function(component) {
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalCrearVinculados'), 'slds-fade-in-open');
		component.set('v.selectedCaseId', '');
		component.set('v.selectedCaseNumber', '');
		component.set('v.selectedNotasTip', 'Sin notas');
		component.set('v.loadingCreandoCaso', false);
		component.set('v.currentSelectedRowsAnexos', []);
	},

	//??????????
	renderPantallaInicialCasos: function(component) {
		component.set('v.rendermostrarModalCasosHijos', true);
		component.set('v.rendermostrarCasoHijoCreado', false);
	},

	crearCasosHijos: function(component, event, helper) {
		component.set('v.loadingCreandoCaso', true);
		let ficherosList = component.get('v.currentSelectedRowsAnexos');
		let idCR = component.get('v.selectedCR');
		let idCase = component.get('v.recordId');
		let nullRows = component.get('v.defaultRows');

		let idsFiles = [];
		for (let i = 0; i < ficherosList.length; i++) {
			idsFiles.push(ficherosList[i]);
		}
		let idListJSON = JSON.stringify(idsFiles);

		let generarCasos = component.get('c.crearCasos');
		generarCasos.setParams({casoID: idCase, listFiles: idListJSON, crId: idCR});
		generarCasos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let datosHijo = response.getReturnValue();
				if (datosHijo === null || datosHijo === undefined || datosHijo.estado === 'KO') {
					let mensajeError = 'No se puede generar un caso hijo debido a uno de los siguientes motivos: ';
					mensajeError = mensajeError + 'Estás posicionado en un caso vinculado y no se permite la operativa; o bien, ';
					mensajeError = mensajeError + ' estás posicionado en un caso de seguimiento y tampoco se permite la operativa.';
					helper.mostrarToast('warning', 'Aviso no generación caso vinculado', mensajeError);
				} else if (datosHijo.estado === 'email KO') {
					helper.mostrarToast('error', 'Error en la generación del caso vinculado', datosHijo.detalleError);
				} else {
					component.set('v.casoCreadoCN', datosHijo.caseNumber);
					component.set('v.casoCreadoCR', datosHijo.crName);
					component.set('v.casoCreadoGrupo', datosHijo.groupName);
					component.set('v.casoCreadoId', datosHijo.casoId);
					component.set('v.currentSelectedRowsAnexos', nullRows);
					component.set('v.selectedCR', '');
					helper.abrirTab(component, datosHijo.casoId);
					$A.enqueueAction(component.get('c.modalCrearVinculadosCerrar'));
					//helper.mostrarToast('success', '¡Éxito!', 'Se ha creado un nuevo Caso');
				}
			} else {
				let errors = response.getError();
				console.error(JSON.stringify(errors));
				if (errors) {
					let detalleError;
					if (errors[0] && errors[0].message) {
						detalleError = errors[0].message;
					} else {
						detalleError = JSON.stringify(errors).replace(/{|}|[|]/gi, ' ');
					}
					helper.mostrarToast('error', 'Error creando caso vinculado', detalleError);
				}
				/*let errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						helper.mostrarToast('error', 'Ups...', 'Error inesperado contacta con el administrador:' + errors[0].message);
					}
				}*/
			}
			component.set('v.loadingCreandoCaso', false);
		});
		$A.enqueueAction(generarCasos);
	},

	crearCasosEmailReciclado: function(component, event, helper) {
		component.set('v.loadingCreandoCaso', true);
		let ficherosList = component.get('v.currentSelectedRowsAnexos');
		let idsFiles = [];
		for (let i = 0; i < ficherosList.length; i++) {
			idsFiles.push(ficherosList[i]);
		}
		let idListJSON = JSON.stringify(idsFiles);
		let idEmail = component.get('v.selectedEmailSR');
		let idCase = component.get('v.recordId');
		//let nullRows = component.get('v.defaultRows');
		let generarCasos = component.get('c.crearCasosReciclados');
		generarCasos.setParams({'casoID': idCase, 'listFiles': idListJSON, 'emailId': idEmail});
		generarCasos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let datosHijo = response.getReturnValue();
				if (datosHijo == null || datosHijo[0] === 'KO') {
					helper.mostrarToast('error', 'Ups...', 'No se pueden generar Casos aquí (debe existir un mail asociado)');
				} else {
					component.set('v.casoCreadoCN', datosHijo[0]);
					component.set('v.casoCreadoCR', datosHijo[1]);
					component.set('v.casoCreadoGrupo', datosHijo[2]);
					component.set('v.casoCreadoId', datosHijo[3]);
					//component.set('v.currentSelectedRowsAnexos', []);
					component.set('v.selectedCR', '');
					//helper.abrirTab(component, datosHijo[3]);


					//helper.mostrarToast('success', '¡Éxito!', 'Se ha creado un nuevo Caso');
				}
			} else if (response.getState() === 'ERROR') {

				let errors = response.getError();
				console.error(JSON.stringify(errors));
				if (errors) {
					let detalleError;
					if (errors[0] && errors[0].message) {
						detalleError = errors[0].message;
					} else {
						detalleError = JSON.stringify(errors).replace(/{|}|[|]/gi, ' ');
					}
					helper.mostrarToast('error', 'Error creando caso vinculado desde e-mail', detalleError);
				}
			}
			component.set('v.selectedEmailSR', '');
			component.set('v.loadingCreandoCaso', false);
		});
		$A.enqueueAction(generarCasos);
	},

	modalCrearCasoVerCaso: function(component, event, helper) {
		$A.enqueueAction(component.get('c.modalCrearCasoCerrar'));
		helper.abrirTab(component, component.get('v.casoCreadoId'));
	},

	importarFicheros: function(component, event, helper) {
		component.find('modalImportarArchivos2BotonSiguiente').set('v.disabled', true);
		let idsFiles = [];
		component.get('v.currentSelectedRowsAnexos').forEach(anexo => idsFiles.push(anexo));
		let importarEmailsAnexos = component.get('c.importarEmailsAnexos');
		importarEmailsAnexos.setParams({
			'casoID': component.get('v.recordId'),
			'listFiles': JSON.stringify(idsFiles),
			'emailId': component.get('v.selectedEmailSR'),
			'casoSelId': component.get('v.selectedCaseId')
		});
		importarEmailsAnexos.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				component.set('v.currentSelectedRowsAnexos', component.get('v.defaultRows'));
				component.set('v.rendermostrarficherocreado', true);
				$A.util.removeClass(component.find('modalImportarArchivos2'), 'slds-fade-in-open');
				$A.util.addClass(component.find('modalImportarArchivos3'), 'slds-fade-in-open');
				$A.util.addClass(component.find('modalImportarArchivos3Ok'), 'blink');
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout($A.getCallback(() => component.find('modalImportarArchivos3BotonCancelar').focus()), 200);
			} else if (state === 'ERROR') {
				let errors = importarEmailsAnexos.getError();
				if (errors) {
					let detalleError;
					if (errors[0] && errors[0].message) {
						detalleError = errors[0].message;
					} else {
						detalleError = JSON.stringify(errors);
					}
					console.error('No se han podido importar los archivos: ' + detalleError);
					helper.mostrarToast('error', 'No se han podido importar los archivos', detalleError);
				}
			}
			component.find('modalImportarArchivos2BotonSiguiente').set('v.disabled', false);
		});
		$A.enqueueAction(importarEmailsAnexos);
	},

	autoasignarCasoHijo: function(component, event, helper) {

		let caseLoadedId = component.get('v.casoCreadoId');
		component.find('modalCrearCasoBotonAutoasignarHijo').set('v.disabled', true);
		let asignar = component.get('c.autoAsignarGrupoAura');
		asignar.setParams({
			'caseId': caseLoadedId,
			'bAutomatico': false,
			'entradaPaqueteriaPAK': false
		});
		asignar.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {

				let datosAsignacion = response.getReturnValue();
				if (datosAsignacion.errorProceso != 'N') {

					/*if (datosAsignacion.errorGrupoAuto == '1' && datosAsignacion.detalleError == '') {
						//Error en el cálculo de grupo automático sin cuenta informada.
						helper.mostrarToast('warning', '¡Advertencia!', 'El caso no tiene cuenta informada por lo que se ha asignado a un grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '2' && datosAsignacion.detalleError == '') {
						//Error en el cálculo de grupo standard.
						helper.mostrarToast('warning', '¡Advertencia!', 'La cuenta del caso no tiene el gestor informado por lo que se ha asignado a un grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '3' && datosAsignacion.detalleError == '') {
						//Error en el cálculo de grupo standard.
						helper.mostrarToast('warning', '¡Advertencia!', 'La cuenta del caso no tiene centro parametrizado por lo que se ha asignado a un grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '4' && datosAsignacion.detalleError == '') {
						//Error en el cálculo de grupo standard.
						helper.mostrarToast('warning', '¡Advertencia!', 'La cuenta del caso es un centro por lo que el caso se ha asignado a un grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '5' && datosAsignacion.detalleError == '') {
						//Error en el cálculo de grupo standard.
						helper.mostrarToast('warning', '¡Advertencia!', 'El caso no se ha podido asignar al grupo designado por el automatismo ni existe un grupo standard para esta Organización y Zona. Por favor, contacta con el administrador.');
					} else {
						//Error en el cálculo de grupo automático sin cuenta informada.
						helper.mostrarToast('warning', '¡Advertencia!', datosAsignacion.detalleError);
					}*/
					if (datosAsignacion.errorGrupoAuto == '5') {
						//Error en el cálculo de grupo standard.
						helper.mostrarToast('warning', '¡Advertencia!', 'El caso no se ha podido asignar al grupo designado por el automatismo ni existe un grupo standard para esta Organización y Zona. Por favor, contacta con el administrador.');
					} else if (datosAsignacion.errorGrupoAuto == '8') {
						//Error en la assignación de excepciones al caso.
						helper.mostrarToast('warning', '¡Advertencia!', 'Se han encontrado dos o más excepciones de asignación para este caso. Por favor, contacte con el administrador del sistema.');
					} else {
						//Error en el cálculo de grupo automático sin cuenta informada.
						let mensajeError = datosAsignacion.detalleError;
						if (mensajeError == null || mensajeError == undefined || mensajeError == '') {
							mensajeError = 'Se ha producido un error desconocido en el proceso de autoasignacion. Contacte con el administrador del sistema.';
						}
						helper.mostrarToast('warning', '¡Advertencia!', mensajeError);
					}
				} else {

					let avisoMostrado = false;
					if (datosAsignacion.errorGrupoAuto == '1') {
						//Error en el cálculo de grupo automático sin cuenta informada.
						avisoMostrado = true;
						helper.mostrarToast('warning', '¡Advertencia!', 'El caso no tiene cuenta informada por lo que se ha asignado a un grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '2') {
						//Error en el cálculo de grupo standard.
						avisoMostrado = true;
						helper.mostrarToast('warning', '¡Advertencia!', 'El gestor no pertenece a ningún grupo, por lo que el caso se ha asignado al grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '3') {
						//Error en el cálculo de grupo standard.
						avisoMostrado = true;
						helper.mostrarToast('warning', '¡Advertencia!', 'La cuenta del caso no tiene centro parametrizado por lo que se ha asignado a un grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '4') {
						//Error en el cálculo de grupo standard.
						avisoMostrado = true;
						helper.mostrarToast('warning', '¡Advertencia!', 'La cuenta del caso es un centro por lo que el caso se ha asignado a un grupo standard.');
					} else if (datosAsignacion.errorGrupoAuto == '6') {
						avisoMostrado = true;
						helper.mostrarToast('warning', '¡Advertencia!', 'No se puede autoasignar el caso al grupo destino ya que pertenece a otra organización/zona. Consultar con un supervisor si se debe cambiar la carterización del cliente u organización/zona del caso.');
					} else if (datosAsignacion.errorGrupoAuto == '9') {
						avisoMostrado = true;
						helper.mostrarToast('warning', '¡Advertencia!', 'No es posible asignar el caso a Valija sin tener el centro informado.');
					}

					if (datosAsignacion.requiereInfoAdicional == 'Y') {

						//Cerrar el modal actual de autoasignar.
						$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
						$A.util.removeClass(component.find('modalCrearCaso'), 'slds-fade-in-open');

						//Es un traslado a Valija. Requiere revisar información adicional.
						let notasManuales = component.find('idObservacionAutoasginacionHijo').get('v.value');
						if (notasManuales == null || notasManuales == undefined) {
							notasManuales = '';
						}
						component.set('v.notasManuales', notasManuales);
						component.set('v.caseIdValija', caseLoadedId);
						component.set('v.datosAdicionalesValija', true);
						component.set('v.loadingDatosAdicionales', true);
						component.set('v.datosTrasladoCalculados', datosAsignacion.datosCalculadosTraslado);
						component.set('v.datosImpuestosModificados', false);

						let caracteresRestantes = 255 - notasManuales.length;
						component.set('v.enviarNotificacionCaracteresRestantes', caracteresRestantes);

						//Preparar apertura del modal Valija.
						$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
						$A.util.addClass(component.find('modalValija'), 'slds-fade-in-open');
						//eslint-disable-next-line @lwc/lwc/no-async-operation
						window.setTimeout($A.getCallback(() => component.find('modalAutoasignarBotonValijaCancelar').focus()), 200);

						//Preparar los ficheros adjuntos.
						let extensionesExcluidas = ['snote', 'html', 'htm'];
						component.set('v.dataAnexos', '');
						component.set('v.currentSelectedRowsAnexos', []);
						let getAnexos = component.get('c.getFilesCaseFiltroExt');
						//getAnexos.setParam('casoId', caseLoadedId);
						getAnexos.setParams({
							'casoId': caseLoadedId,
							'extensionesExcluir': extensionesExcluidas
						});
						getAnexos.setCallback(this, response => {
							if (response.getState() === 'SUCCESS') {
								component.set('v.dataAnexos', response.getReturnValue());
							}
						});
						$A.enqueueAction(getAnexos);

						component.set('v.columnasAnexos', [
							//{label: 'ID', fieldName: 'Id', type: 'text'},
							{label: 'Nombre', fieldName: 'Title', type: 'text'},
							{label: 'Extensión', fieldName: 'FileExtension', type: 'text'},
							{label: 'Descripción', fieldName: 'Description', type: 'text'}
						]);

					} else if (datosAsignacion.asignado == 'Y') {
						//El caso se ha asignado.
						if (avisoMostrado === false) {
							//El caso se ha asignado.
							//helper.mostrarToast('success', '¡Éxito!', 'El grupo se ha asignado correctamente.');
						}

						helper.postChatter(component, caseLoadedId, 'Autoasignar caso', 'Sin notas', component.find('idObservacionAutoasginacionHijo').get('v.value'));

					} else {
						if (datosAsignacion.errorGrupoAuto != '6') {
							helper.mostrarToast('info', 'No se ha asignado el caso', 'No se ha encontrado un grupo para el caso.');
						}
					}
				}
				helper.reinit(component);
			} else if (response.getState() === 'ERROR') {
				helper.mostrarToast('error', 'No se ha asignado el caso', JSON.stringify(response.getError()).replace(/{|}|[|]/gi, ' '));
				console.error(JSON.stringify(response.getError()));
			}
			component.find('modalCrearCasoBotonAutoasignarHijo').set('v.disabled', false);
		});
		$A.enqueueAction(asignar);

		/*OLD.
		let asignar = component.get('c.autoAsignarGrupo');
		asignar.setParam('caseId', component.get('v.casoCreadoId'));
		asignar.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {

				let datosAsignacion = response.getReturnValue();
				if (datosAsignacion.errorGrupoAuto == 'Y') {
					if (datosAsignacion.detalleError == '') {
						//Error en el cálculo de grupo automático sin cuenta informada.
						helper.mostrarToast('warning', 'No se ha asignado el caso', 'Se ha detectado un grupo automático pero el caso no tiene una cuenta informada o la cuenta no tiene definido los gestores correctamente');
					} else {
						//Error en el cálculo de grupo automático sin cuenta informada.
						helper.mostrarToast('warning', 'No se ha asignado el caso', datosAsignacion.detalleError);
					}
				} else {
					if (datosAsignacion.asignado == 'Y') {
						helper.mostrarToast('success', '¡Éxito!', 'El grupo se ha asignado correctamente');
						component.set('v.selectedNotasTip', 'Sin notas');

						let publicar = component.get('c.postOnChatter');
						publicar.setParams({
							caseId: component.get('v.casoCreadoId'),
							observaciones: component.find('idObservacionAutoasginacionHijo').get('v.value'),
							operativa: 'Autoasignar caso',
							notaTipificada: 'Sin notas'
						});
						$A.enqueueAction(publicar);
					} else {
						helper.mostrarToast('info', 'No se ha asignado el caso', 'No se ha encontrado un grupo para el caso.');
					}
				}
				helper.reinit(component);
			} else if (response.getState() === 'ERROR') {
				helper.mostrarToast('error', 'No se ha asignado el caso', JSON.stringify(response.getError()));
				console.error(JSON.stringify(response.getError()));
			}
		});
		$A.enqueueAction(asignar);
		FIN OLD.*/
	},

	asignarGrupoColaborador: function(component, event, helper) {

		let currentGroup = component.find('gpName').get('v.value');
		let operativa = 'Asignar grupo';

		if (!currentGroup) {
			helper.mostrarToast('error', 'Datos obligatorios no informados', 'Debe informar todos los datos obligatorios antes de continuar.');
		} else {
			component.set('v.loadingCreandoCaso', true);
			let idGroup = component.get('v.selectedGroup');
			let idCase = component.get('v.recordId');
			let notaTip = component.get('v.selectedNotasTip');
			let obserInput = component.find('idObservacion').get('v.value');

			let asignarGrupo = component.get('c.asignarGrupo');
			asignarGrupo.setParams({'caseId': idCase, 'grupoId': idGroup});
			asignarGrupo.setCallback(this, response => {
				let state = response.getState();
				if (state === 'SUCCESS') {
					if (response.getReturnValue() === 'Sin num centro') {
						helper.mostrarToast('warning', '¡Advertencia!', 'La cuenta del caso no tiene centro parametrizado por lo que se ha asignado a un grupo standard.');
					} else if (response.getReturnValue() === 'Sin grupo auto') {
						helper.mostrarToast('warning', '¡Advertencia!', 'Ha ocurrido un error al encontrar el grupo automático.');
					} else if (response.getReturnValue() === 'Sin cuenta') {
						helper.mostrarToast('warning', '¡Advertencia!', 'El caso no tiene cuenta informada por lo que se ha asignado a un grupo standard.');
					} else if (response.getReturnValue() === 'Sin gestor') {
						helper.mostrarToast('warning', '¡Advertencia!', 'La cuenta del caso no tiene el gestor informado por lo que se ha asignado a un grupo standard.');
					} else if (response.getReturnValue() === 'Sin standard') {
						helper.mostrarToast('warning', '¡Advertencia!', 'El caso no se ha podido asignar al grupo designado por el automatismo ni existe un grupo standard para esta Organización y Zona. Por favor, contacta con el administrador');
					} else if (response.getReturnValue() === 'centro caixabank') {
						helper.mostrarToast('warning', '¡Advertencia!', 'La cuenta del caso es un centro por lo que el caso se ha asignado a un grupo standard.');
					} else if (response.getReturnValue() === null) {
						//helper.mostrarToast('success', '¡Éxito!', 'El grupo ha sido asignado correctamente.');
					} else {
						helper.mostrarToast('warning', '¡Advertencia!', response.getReturnValue());
					}
					component.set('v.selectedNotasTip', 'Sin notas');
					//helper.mostrarToast('success', 'Éxito!', 'El grupo ha sido asignado correctamente.');
					$A.enqueueAction(component.get('c.modalAsignarGrupoCerrar'));

					if (obserInput === null) {
						obserInput === '';
					}
					let publicar = component.get('c.postOnChatter');
					publicar.setParams({'caseId': idCase, 'observaciones': obserInput, 'operativa': operativa, 'notaTipificada': notaTip});
					$A.enqueueAction(publicar);

					helper.reinit(component);
				} else {
					let errors = response.getError();
					console.error(JSON.stringify(errors));
					helper.mostrarToast('error', 'No se ha asignado el caso', errors[0].message);
				}
				component.set('v.loadingCreandoCaso', false);
			});
			$A.enqueueAction(asignarGrupo);
		}
	},

	cerrarCaso: function(component, event, helper) {
		component.set('v.loadingCreandoCaso', true);

		let obserInput = component.find('observacionCerrar').get('v.value');
		component.set('v.observacText', obserInput);
		let notaTip = component.get('v.selectedNotasTip');
		let notSRhijas = true;
		let numOperaciones = component.find('idNumOperacionesCierre').get('v.value');
		//Comentado mientras el forcedata este en VIEW
		//component.find("caseData").saveRecord($A.getCallback(() => {}));

		let cerrarCaso = component.get('c.cerrarCasoResultado');
		cerrarCaso.setParams({
			'caseId': component.get('v.recordId'),
			'resultado': component.get('v.selectedResul'),
			'numOperacionesCaso': numOperaciones
		});
		cerrarCaso.setCallback(this, response => {
			let state = response.getState();

			if (state === 'SUCCESS') {

				if (response.getReturnValue() === 'Caso cerrado' + true) {
					//helper.mostrarToast('success', 'Éxito!', 'El caso se ha cerrado con éxito');
				} else if (response.getReturnValue() === 'No cerrado') {
					helper.mostrarToast('error', 'Error!', 'El caso necesita estar clasificado');
				} else if (response.getReturnValue() === 'Contratos sin email') {
					helper.mostrarToast('error', 'Error!', 'Los contactos de los contratos asociados al caso deben de tener el mail informado.');
				} else if (response.getReturnValue() === 'Caso cerrado') {
					//helper.mostrarToast('success', 'Éxito!', 'El caso se ha cerrado sin envío de email');
				} else if (response.getReturnValue() === 'Plantilla vacía') {
					helper.mostrarToast('warning', 'Advertencia!', 'El caso se ha cerrado sin envío de email, plantilla vacía');
				} else if (response.getReturnValue() === 'Sin plantilla') {
					helper.mostrarToast('warning', 'Advertencia!', 'El caso se ha cerrado sin envío de email, no se ha encontrado plantilla.');
				} else if (response.getReturnValue() === 'Sin contacto') {
					helper.mostrarToast('warning', 'Advertencia!', 'El caso se ha cerrado sin envío de email, no se ha encontrado contacto.');
				} else if (response.getReturnValue() === 'Caso Auditoria') {
					$A.util.removeClass(component.find('modalCerrar'), 'slds-fade-in-open');
					$A.util.addClass(component.find('modalCerrarAuditoria'), 'slds-fade-in-open');
				} else if (response.getReturnValue() === 'Casos hijos') {
					helper.mostrarToast('error', 'Error!', 'No se puede cerrar un caso con casos vinculados pendientes.');
					notSRhijas = false;
				} else {
					helper.mostrarToast('warning', 'Advertencia!', response.getReturnValue());
				}
				component.set('v.selectedNotasTip', 'Sin notas');
				helper.reinit(component);
				$A.enqueueAction(component.get('c.modalCerrarCerrar'));
				if (notSRhijas) {
					let publicarChatter = component.get('c.postOnChatter');
					publicarChatter.setParams({
						'caseId': component.get('v.recordId'),
						'observaciones': obserInput,
						'operativa': 'Cerrar caso',
						'notaTipificada': notaTip
					});
					$A.enqueueAction(publicarChatter);

				}

			} else if (state === 'ERROR') {
				let error = cerrarCaso.getError();
				let parts = error[0].message.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
				if (parts.length > 1) {
					helper.mostrarToast('error', 'Error!', parts[1]);
				} else {
					helper.mostrarToast('error', 'Error!', error[0].message);
				}
			}
			component.set('v.loadingCreandoCaso', false);
		});
		$A.enqueueAction(cerrarCaso);
	},

	cerrarSRAuditoria: function(component, event, helper) {
		let obserInput = component.get('v.observacText');
		let operativa = 'Cerrar caso';
		let resul = component.get('v.selectedResul');
		let idCase = component.get('v.recordId');
		let notaTip = component.get('v.selectedNotasTip');

		let resul1 = 'Caso cerrado' + true;
		let resul2 = 'Caso cerrado';
		let resul3 = 'No cerrado';
		let resul4 = 'Plantilla vacía';
		let resul5 = 'Sin plantilla';

		let cerrarCasoAud = component.get('c.cerrarCasoAuditoria');
		cerrarCasoAud.setParams({'caseId': idCase, 'resultado': resul});
		cerrarCasoAud.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				if (response.getReturnValue() === resul1) {
					//helper.mostrarToast('success', 'Éxito!', 'El caso se ha cerrado con éxito');
					component.set('v.modalSRauditoria', false);
				} else if (response.getReturnValue() === resul3) {
					helper.mostrarToast('error', 'Error!', 'El caso necesita estar clasificado');
					component.set('v.modalSRauditoria', false);
				} else if (response.getReturnValue() === resul2) {
					//helper.mostrarToast('success', 'Éxito!', 'El caso se ha cerrado sin envío de email');
					component.set('v.modalSRauditoria', false);
				} else if (response.getReturnValue() === resul4) {
					helper.mostrarToast('warning', 'Advertencia!', 'El caso se ha cerrado sin envío de email, plantilla vacía');
					component.set('v.modalSRauditoria', false);
				} else if (response.getReturnValue() === resul5) {
					helper.mostrarToast('warning', 'Advertencia!', 'El caso se ha cerrado sin envío de email, no se ha encontrado plantilla.');
					component.set('v.modalSRauditoria', true);
				}

				let publicarCas = component.get('c.postOnChatter');
				publicarCas.setParams({'caseId': idCase, 'observaciones': obserInput, 'operativa': operativa, 'notaTipificada': notaTip});
				$A.enqueueAction(publicarCas);

				component.set('v.selectedNotasTip', 'Sin notas');
				helper.reinit(component);
			} else if (state === 'ERROR') {
				let errors = cerrarCasoAud.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.error('error' + errors[0].message);
						helper.mostrarToast('error', 'Error!', errors[0].message);
					}
				}
			}
		});
		$A.enqueueAction(cerrarCasoAud);
	},

	modalDevolverCerrar: function(component) {
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalDevolver'), 'slds-fade-in-open');
		component.find('observacionId').set('v.value', '');
	},

	modalAORCerrar: function(component) {
		component.set('v.loadingCreandoCaso', false);
		component.set('v.botonPulsado', false);

		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalAOR'), 'slds-fade-in-open');
		if (component.get('v.caso.SEG_Identificador_AOR__c')) {
			component.set('v.currentSelectedRowsAnexos', []);
			component.find('comentarioAOR').set('v.value', '');
		} else {
			component.find('tipologiaN1').set('v.value', '');
			component.find('tipologiaN2').set('v.value', null);
			component.set('v.childListAOR', []);
			component.set('v.disabledChildFieldAOR', true);
			component.find('consultaAOR').set('v.value', null);
		}

	},

	modalCrearCasoAbrir: function(component, event, helper) {
		//rellenar datos de tabla y renderizar posteriormente el modal
		let getAnexos = component.get('c.getFilesCase');
		getAnexos.setParam('casoId', component.get('v.recordId'));

		getAnexos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {

				let records = response.getReturnValue();
				records.forEach(record => {
					record.ContentSize = helper.formatBytes(record.ContentSize, 2);
				});
				component.set('v.casoCreadoId', '');
				component.set('v.notasManuales', '');
				helper.fetchEmail(component);
				component.set('v.columnasAnexos', [
					{label: 'Título', fieldName: 'Title', type: 'text'},
					{label: 'Extensión', fieldName: 'FileExtension', type: 'text'},
					{label: 'Descripción', fieldName: 'Description', type: 'text'},
					{
						label: 'Fecha de subida', fieldName: 'CreatedDate', type: 'date', typeAttributes: {
							month: 'numeric',
							day: 'numeric',
							year: 'numeric',
							hour: '2-digit',
							minute: '2-digit',
							second: '2-digit',
							timeZone: 'Europe/Paris'
						}
					},
					{label: 'Tamaño', fieldName: 'ContentSize', type: 'integer'}
				]);
				component.set('v.dataAnexos', response.getReturnValue());
			}
		});

		$A.enqueueAction(getAnexos);
		//helper.setDataAnexos(component);
		component.set('v.renderizarModales', true);
		$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalCrearCaso'), 'slds-fade-in-open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('modalCrearCasoBotonCancelar').focus()), 200);
	},

	modalCrearCasoCerrar: function(component) {
		//rellenar datos de tabla y renderizar posteriormente el modal
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalCrearCaso'), 'slds-fade-in-open');
		component.set('v.selectedCaseNumber', []);
		component.set('v.selectedCaseId', []);
		component.set('v.casoCreadoId', '');
		component.set('v.selectedNotasTip', 'Sin notas');
		component.set('v.selectedEmailSR', '');
		component.set('v.currentSelectedRowsAnexos', []);
	},

	modalImportarArchivosAbrir: function(component) {
		//rellenar datos de tabla y renderizar posteriormente el modal
		//helper.fetchEmailCaso(component);
		/*component.set('v.columnasAnexos', [
			{label: 'Título', fieldName: 'Title', type: 'text'},
			{label: 'Extensión', fieldName: 'FileExtension', type: 'text'},
			{label: 'Descripción', fieldName: 'Description', type: 'text'}
		]);*/
		//helper.setDataAnexos(component);
		component.set('v.renderizarModales', true);
		$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalImportarArchivos'), 'slds-fade-in-open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('modalImportarArchivosBotonCancelar').focus()), 200);
	},

	modalImportarArchivosCerrar: function(component) {
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalImportarArchivos'), 'slds-fade-in-open');
		component.set('v.selectedCaseNumber', '');
		component.set('v.selectedCaseId', '');
		component.set('v.columnasAnexos', '');
		component.find('casNum').set('v.value', '');
	},

	modalImportarArchivos2Abrir: function(component) {
		//rellenar datos de tabla y renderizar posteriormente el modal

		let getAnexos = component.get('c.getFilesCase');
		getAnexos.setParam('casoId', component.get('v.selectedCaseId'));
		getAnexos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.dataAnexos', response.getReturnValue());
			}
		});
		$A.enqueueAction(getAnexos);

		component.set('v.columnasAnexos', [
			//{label: 'ID', fieldName: 'Id', type: 'text'},
			{label: 'Nombre', fieldName: 'Title', type: 'text'},
			{label: 'Extensión', fieldName: 'FileExtension', type: 'text'},
			{label: 'Descripción', fieldName: 'Description', type: 'text'}
		]);

		$A.util.removeClass(component.find('modalImportarArchivos'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalImportarArchivos2'), 'slds-fade-in-open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('modalImportarArchivos2BotonSiguiente').focus()), 200);

		let actionEm = component.get('c.fetchEmailsCaso');
		actionEm.setParam('caseId', component.get('v.selectedCaseId'));
		actionEm.setCallback(this, response => {
			let values = [];
			let result = response.getReturnValue();
			for (let key in result) {
				if (Object.prototype.hasOwnProperty.call(result, key)) {
					values.push({
						label: result[key],
						value: key
					});
				}
			}
			component.set('v.Emailcaso', values);
		});
		$A.enqueueAction(actionEm);
	},

	modalImportarArchivos2Cerrar: function(component) {
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalImportarArchivos2'), 'slds-fade-in-open');
		component.set('v.selectedCaseNumber', '');
		component.set('v.selectedCaseId', '');
		component.set('v.columnasAnexos', '');
		component.set('v.selectedEmailSR', '');
		component.set('v.dataAnexos', '');
		component.set('v.currentSelectedRowsAnexos', '');
		component.set('v.selectedRowsAnexos', '');
		component.find('casNum').set('v.value', '');
	},

	modalCrearContratosAbrir: function(component, event, helper) {
		helper.fetchCRSeguimiento(component);
		component.set('v.renderizarModales', true);

		$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalCrearContratos'), 'slds-fade-in-open');
		$A.enqueueAction(component.get('c.inputNombresContratosChange'));
	},

	modalCrearContratosCerrar: function(component) {
		component.set('v.numeroContratos', 1);
		component.set('v.nombresContratos', '');
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalCrearContratos'), 'slds-fade-in-open');
		component.find('CRs').set('v.value', null);
	},

	modalImportarArchivos2Atras: function(component) {
		$A.util.removeClass(component.find('modalImportarArchivos2'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalImportarArchivos'), 'slds-fade-in-open');
	},

	modalImportarArchivos3Cerrar: function(component) {
		$A.util.removeClass(component.find('modalImportarArchivos3'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalImportarArchivos3Ok'), 'blink');
		component.set('v.selectedCaseNumber', '');
		component.set('v.selectedCaseId', '');
		component.set('v.columnasAnexos', '');
		component.find('casNum').set('v.value', '');
	},

	inputNombresContratosChange: function(component) {
		let numeroContratos = component.get('v.numeroContratos');
		numeroContratos = numeroContratos ? numeroContratos : 0;
		let listaNombresContratos = component.get('v.nombresContratos').split(',');
		component.set('v.fatalCrearContratos', listaNombresContratos.length > numeroContratos);
		component.find('modalCrearContratosBotonIniciar').set('v.disabled', listaNombresContratos.length > numeroContratos);
		component.set('v.warningCrearContratos', listaNombresContratos.length < numeroContratos || !component.get('v.nombresContratos'));
	},

	crearContratosVinculados: function(component, event, helper) {
		let nombresContratos = component.get('v.nombresContratos');
		let nContratos = component.get('v.numeroContratos');
		let idCR = component.get('v.selectedCR');
	
		if (!idCR || !nContratos || nContratos < 1) {
			helper.mostrarToast('error', 'Datos obligatorios no informados', 'Debe informar todos los datos obligatorios antes de proceder a la creación del contrato.');
		} else {
			component.find('modalCrearContratosBotonIniciar').set('v.disabled', true);
			component.set('v.loadingCreandoCaso', true);
	
			let idListJSON = '["0"]';
			let idCase = component.get('v.recordId');
			let nullRows = component.get('v.defaultRows');
	
			let generarCasos = component.get('c.crearCasoSeguimiento');
			generarCasos.setParams({casoID: idCase, listFiles: idListJSON, crId: idCR, numContratos: nContratos});
			generarCasos.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					if (response.getReturnValue() === null) {
						helper.mostrarToast('error', 'Ups...', 'Ha ocurrido un error inesperado durante la creación del caso.');
					} else {
						let datosHijo = response.getReturnValue();
	
						if (datosHijo.error == 'Seguimiento') {
							helper.mostrarToast('error', 'Ups...', 'No puedes generar caso de Seguimiento en un caso de Seguimiento');
						} else if(datosHijo.error == 'Contacto'){
							helper.mostrarToast('error', 'Ups...', 'No se puede crear el caso de Seguimiento, el contacto debe ser un cliente / gestor');
						} else {
							component.set('v.casoCreadoCN', datosHijo.casoCreadoCN);
							component.set('v.casoCreadoCR', datosHijo.casoCreadoCR);
							component.set('v.casoCreadoGrupo', datosHijo.casoCreadoGrupo);
							component.set('v.casoCreadoId', datosHijo.casoCreadoId);
							component.set('v.currentSelectedRowsAnexos', nullRows);
							component.set('v.selectedCR', '');
	
							let casoId = datosHijo.casoCreadoId;
							let casoMadre = datosHijo.casoCreadoCN;
							let crearContrato = component.get('c.crearContratos');
							crearContrato.setParams({
								'casoId': casoId,
								'nContratos': nContratos,
								'casoMadre': casoMadre,
								'nombresContratos': nombresContratos
							});
							crearContrato.setCallback(this, responseCrearContrato => {
								if (responseCrearContrato.getState() === 'SUCCESS') {
									helper.abrirTab(component, casoId);
									//helper.mostrarToast('success', '¡Éxito!', 'Se han creado los contratos');
									$A.enqueueAction(component.get('c.modalCrearContratosCerrar'));
								} else if (responseCrearContrato.getState() === 'ERROR') {
									let errors = responseCrearContrato.getError();
									console.error(JSON.stringify(errors));
									let errorString = JSON.stringify(errors).replace(/{|}|[|]/gi, ' ');
									let errorMessage = 'No se ha podido realizar la creación del contrato. Detalle: ';

									// Iterar sobre cada error
									errors.forEach(error => {
										Object.keys(error.fieldErrors).forEach(fieldName => {
											errorMessage += error.fieldErrors[fieldName][0].message + ' ';
										});
									});
									//helper.mostrarToast('error', 'Error en la creación del contrato', 'No se ha podido realizar la creación del contrato. Detalle: ' + errorString);
									helper.mostrarToast('error', 'Error en la creación del contrato', errorMessage);
								}
							});
							$A.enqueueAction(crearContrato);
						}
					}
				} else if (response.getState() === 'ERROR') {
					let errors = response.getError();
					console.error(JSON.stringify(errors));
					helper.mostrarToast('error', 'Error', errors.message);
				}
				component.set('v.loadingCreandoCaso', false);
				component.find('modalCrearContratosBotonIniciar').set('v.disabled', component.get('v.fatalCrearContratos'));
			});
			$A.enqueueAction(generarCasos);
		}
	},

	getCases: function(component) {
		window.clearTimeout(component.get('v.searchTimeoutId'));
		let cadenaBusqueda = component.find('casNum').get('v.value');
		if (cadenaBusqueda.length < 3) {
			component.find('casNum').set('v.isLoading', false);
		} else {
			component.find('casNum').set('v.isLoading', true);
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			component.set('v.searchTimeoutId', window.setTimeout($A.getCallback(() => {
				let buscadorCases = component.get('c.buscadorCases');
				buscadorCases.setParam('cadenaBusqueda', cadenaBusqueda);
				buscadorCases.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						let resultadosBusqueda = [];
						response.getReturnValue().forEach(caso => {
							resultadosBusqueda.push({
								id: caso.Id,
								caseNumber: caso.CaseNumber,
								subject: caso.Subject
							});
						});
						component.set('v.cases', resultadosBusqueda);
						component.set('v.mostrarCases', true);
					}
					component.find('casNum').set('v.isLoading', false);
				});
				$A.enqueueAction(buscadorCases);
			}), 200));
		}
	},

	inputBuscarCasosFocus: function(component) {
		if (component.find('casNum').get('v.value').length >= 3) {
			component.set('v.mostrarCases', true);
		}
	},

	inputBuscarCasosBlur: function(component) {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.set('v.mostrarCases', false)), 300);
	},

	seleccionarCaso: function(component, event) {
		component.set('v.selectedCaseId', event.currentTarget.id);
		component.set('v.selectedCaseNumber', event.currentTarget.name);
	},

	modalCanalBpoAbrir: function(component, event, helper) {
		let comprobarBPO = component.get('c.checkBPOPermision');
		comprobarBPO.setParam('caseId', component.get('v.recordId'));
		comprobarBPO.setCallback(this, response => {
			component.set('v.renderizarModales', true);
			if (response.getState() === 'SUCCESS') {
				if (response.getReturnValue()) {
					$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
					$A.util.addClass(component.find('modalCanalBpo'), 'slds-fade-in-open');
					//Preparar los ficheros adjuntos.
					let getAnexos = component.get('c.getFilesCase');
					getAnexos.setParam('casoId', component.get('v.recordId'));
					getAnexos.setCallback(this, response => {
						if (response.getState() === 'SUCCESS') {
							component.set('v.dataAnexos', response.getReturnValue());
						}
					});
					$A.enqueueAction(getAnexos);

					component.set('v.columnasAnexos', [
						//{label: 'ID', fieldName: 'Id', type: 'text'},
						{label: 'Nombre', fieldName: 'Title', type: 'text'},
						{label: 'Extensión', fieldName: 'FileExtension', type: 'text'},
						{label: 'Descripción', fieldName: 'Description', type: 'text'}
					]);
					//eslint-disable-next-line @lwc/lwc/no-async-operation
					window.setTimeout($A.getCallback(() => component.find('modalCanalBpoBotonCancelar').focus()), 200);
				} else {
					helper.mostrarToast('info', 'No aplica envío a Canal BPO', 'El caso no está en disposición de enviarse a Canal BPO o ya está sincronizado');
				}
			} else if (response.getState() === 'ERROR') {
				helper.mostrarToast('error', 'No se puede iniciar el envío a Canal BPO', '');
				console.error(JSON.stringify(response.getError()));
			}
		});
		$A.enqueueAction(comprobarBPO);
	},

	modalCanalBpoCerrar: function(component) {
		$A.util.removeClass(component.find('modalCanalBpo'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
	},
	inputNifRelacionChange: function(component) {
		let listaNifsRelaciones = component.get('v.notasCIF').split(',');
	},
	enviarCanalBpo: function(component) {
		component.find('modalCanalBpoBotonIniciar').set('v.disabled', true);
		let checkStatus = component.get('v.statusCasoBPO');
		let listaFiche = component.get('v.currentSelectedRowsAnexos');
		let notaNifRel = component.get('v.notasCIF');
		/*if (listaFiche == null || listaFiche == undefined || listaFiche.length == 0)
		{
			let errorAux = 'Para poder traspasar a BPO debe seleccionar como mínimo un fichero';
			helper.mostrarToast('warning', 'No se ha asignado el caso', errorAux);
			return;
		}*/
		let envioBPO = component.get('c.enviarCanalBPO');
		envioBPO.setParams({'caseId': component.get('v.recordId'), 'caseStatus': checkStatus, 'listaFicheros': listaFiche, 'notasCif': notaNifRel});
		envioBPO.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				$A.enqueueAction(component.get('c.modalCanalBpoCerrar'));
			}
			component.find('modalCanalBpoBotonIniciar').set('v.disabled', false);
		});
		$A.enqueueAction(envioBPO);
	},

	modalTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //Tecla ESC
			$A.enqueueAction(component.get('c.' + event.currentTarget.name + 'Cerrar'));
		}
	},

	modalCerrarAuditoriaCerrar: function(component) {
		$A.util.removeClass(component.find('modalCerrarAuditoria'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
	},

	menuCrearCaso: function(component, event) {
		if (event.getParam('value') === 'botonCrearSR') {
			$A.enqueueAction(component.get('c.modalCrearCasoAbrir'));
		}
	},

	checkOrgZona: function(component) {
		let cargar = component.get('c.initComponentOp');
		cargar.setParam('caseId', component.get('v.recordId'));
		cargar.setCallback(this, response => {
			let result = response.getReturnValue();

			//checkorg y zona
			component.set('v.orgZona', result.vControlarOrgZona);
			component.set('v.iniciando', component.get('v.iniciando') + 1);

			//controlar ps
			component.set('v.esSupervisorEstado', result.vControlarPS);
			component.set('v.iniciando', component.get('v.iniciando') + 1);

			//controlar rt contacto
			component.set('v.esContactoEmpleado', result.vControlarRT);

			//Controlar Org-Zona de Grupos y Caso
			component.set('v.caseOrgZonaGroup', result.vControlarOrgZonaCaseGrupo);
		});
		$A.enqueueAction(cargar);
		/*let orgZonaCheck = component.get('c.controlarOrgZona');
		orgZonaCheck.setParam('caseId', component.get('v.recordId'));
		orgZonaCheck.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.orgZona', response.getReturnValue());
			}

		});
		$A.enqueueAction(orgZonaCheck);*/
	},


	checkPermissionSet: function(component) {
		let permissionSetCheck = component.get('c.controlarPermissionSet');
		permissionSetCheck.setParam('caseId', component.get('v.recordId'));
		permissionSetCheck.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.esSupervisorEstado', response.getReturnValue());
			}

		});
		$A.enqueueAction(permissionSetCheck);
	},

	cerrarAvisoPlanificacion: function(component) {
		component.set('v.avisoPlanificacionCerrado', true);
	},

	desplanificar: function(component, event, helper) {
		component.set('v.desplanificando', true);
		let desplanificarCaso = component.get('c.desplanificarCaso');
		desplanificarCaso.setParam('recordId', component.get('v.recordId'));
		desplanificarCaso.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				//helper.mostrarToast('success', 'Se desplanificó Caso', 'El caso ha vuelto a estado Activo - En curso.');
				helper.reinit(component);
			}
			component.set('v.desplanificando', false);
		});
		$A.enqueueAction(desplanificarCaso);
	},

	datosImpuestosActualizados: function(component, event, helper) {
		component.set('v.datosImpuestosModificados', false);
		component.find('botonGuardarDatosImpuestos').set('v.disabled', false);
		component.find('modalAutoasignarBotonValija').set('v.disabled', false);
		component.find('modalAutoasignarBotonValijaCancelar').set('v.disabled', false);
		//helper.mostrarToast('success', 'Actualización datos', 'Se han actualizado los datos de impuestos del caso.');
	},

	finCargaDatosImpuestos: function(component, event, helper) {
		component.set('v.loadingDatosAdicionales', false);
	},

	inicioGuardadoDatosImpuestos: function(component, event, helper) {
		component.find('botonGuardarDatosImpuestos').set('v.disabled', true);
		component.find('modalAutoasignarBotonValija').set('v.disabled', true);
		component.find('modalAutoasignarBotonValijaCancelar').set('v.disabled', true);

		//Paramos el evento del submit estándar para validar los datos del modal.
		event.preventDefault();

		let datosValidos = true;
		let fields = event.getParam('fields');
		if (fields['SEG_TipoCargo__c'] == '03' && (fields['SEG_FechaCargo__c'] == null || fields['SEG_FechaCargo__c'] == undefined)) {
			datosValidos = false;
			helper.mostrarToast('error', 'Error al guardar la información del caso', 'Es obligatorio informar una fecha para el tipo de cargo <Fecha concreta>.');
			component.find('botonGuardarDatosImpuestos').set('v.disabled', false);
			component.find('modalAutoasignarBotonValija').set('v.disabled', false);
			component.find('modalAutoasignarBotonValijaCancelar').set('v.disabled', false);
		}

		//Submit del formulario si todo es válido.
		if (datosValidos === true) {
			component.find('formImpuestos').submit(fields);
		}
	},

	errorDatosImpuestos: function(component, event, helper) {
		component.set('v.loadingDatosAdicionales', false);
		component.find('botonGuardarDatosImpuestos').set('v.disabled', false);
		component.find('modalAutoasignarBotonValija').set('v.disabled', false);
		component.find('modalAutoasignarBotonValijaCancelar').set('v.disabled', false);
		//helper.mostrarToast('error', 'Error al guardar la información del caso', JSON.stringify(event.getParams()).replace(/{|}|[|]/gi, ' '));
		helper.mostrarToast('error', 'Error al guardar la información del caso', event.getParams().detail);
		console.error(JSON.stringify(event.getParams()));
	},

	marcarDatosImpuestos: function(component) {
		component.set('v.datosImpuestosModificados', true);
	},

	togglecheckStatusCaseChange: function(component, event) {
		let estadoCasoChecked = event.getSource().get('v.checked');
		component.set('v.statusCasoBPO', estadoCasoChecked);

	},

	metodosRenderizar: function(component) {
		//$A.enqueueAction(component.get('c.checkAccount'));
		//$A.enqueueAction(component.get('c.checkAccountAndContact'));
		//$A.enqueueAction(component.get('c.checkValijaSinEmail'));
		$A.enqueueAction(component.get('c.comprobarClienteCaso'));
	},

	comprobarClienteCaso: function(component) {
		let comprobarClienteCasoApex = component.get('c.comprobarClienteCasoApex');
		comprobarClienteCasoApex.setParam('recordId', component.get('v.recordId'));
		comprobarClienteCasoApex.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				const retorno = response.getReturnValue();
				component.set('v.cuentaYContactoNoInformado', retorno.cuentaContactoNoInformado);
				component.set('v.cuentaPendiente', retorno.cuentaPendiente);
				component.set('v.emailNoInformadoValija', retorno.emailNoInformadoValija);
			}
		});
		$A.enqueueAction(comprobarClienteCasoApex);
	},

	/*
	checkAccount: function(component) {
		let cuentaPendienteAso = component.get('c.controlarAccount');
		cuentaPendienteAso.setParam('caseId', component.get('v.recordId'));
		cuentaPendienteAso.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.cuentaPendiente', response.getReturnValue());
			}

		});
		$A.enqueueAction(cuentaPendienteAso);
	},

	checkAccountAndContact: function(component) {
		let cuentaYContacto = component.get('c.controlarAccountYContact');
		cuentaYContacto.setParam('caseId', component.get('v.recordId'));
		cuentaYContacto.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.cuentaYContactoNoInformado', response.getReturnValue());
			}

		});
		$A.enqueueAction(cuentaYContacto);
	},

	checkValijaSinEmail: function(component) {
		let contactEmail = component.get('c.controlarValijaSinEmail');
		contactEmail.setParam('caseId', component.get('v.recordId'));
		contactEmail.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.emailNoInformadoValija', response.getReturnValue());
			}
		});
		$A.enqueueAction(contactEmail);
	},
	*/

	checkValijaYCentro: function(component) {
		let cuentaYContacto = component.get('c.controlarValijaSinCentro');
		cuentaYContacto.setParam('caseId', component.get('v.recordId'));
		cuentaYContacto.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.valijaSinCentro', response.getReturnValue());
			}

		});
		$A.enqueueAction(cuentaYContacto);
	},

	enviarAOR: function(component) {
		//Spinner
		component.set('v.loadingCreandoCaso', true);
		// Control del botón pulsado
		component.set('v.botonPulsado', true);

		let listaFiche = component.get('v.currentSelectedRowsAnexos');
		let tipoAOR1 = component.get('v.selectedValueN1');
		let tipoAOR2 = component.get('v.selectedValueN2');
		let tipoconsulta = component.get('v.consultPeticionAOR');
		let comentarioAOR = component.get('v.comentarioAOR');
		let caseInfo = component.get('v.caso');
		let ritmCreado = component.get('v.caso.SEG_AORTipologiaN1__c');
		let ritm;
		if (caseInfo.SEG_Identificador_AOR__c != null) {
			ritm = caseInfo.SEG_Identificador_AOR__c;
			tipoAOR1 = component.get('v.caso.SEG_AORTipologia_N1__c');
			tipoAOR2 = component.get('v.caso.SEG_AORTipologia_N2__c');
		} else {
			ritm = 'noCreado';
		}
		if (tipoAOR1 == 'Seleccione un valor...' || tipoAOR2 == 'Seleccione un valor...') {
			helper.mostrarToast('error', 'Tipología no seleccionada', 'No se ha seleccionado una tipologia valida para el alta');

		} else {
			let envioAOR = component.get('c.enviarCanalAOR');
			envioAOR.setParams({
				'caseId': caseInfo.Id, 'tipologia1AOR': tipoAOR1, 'tipologia2AOR': tipoAOR2,
				'consultaAORaura': tipoconsulta, 'comentario': comentarioAOR, 'adjuntos': listaFiche, 'ritm': ritm
			});
			envioAOR.setCallback(this, response => {
				component.set('v.botonPulsado', false);

				if (response.getState() === 'SUCCESS') {
					$A.enqueueAction(component.get('c.modalAORCerrar'));
				} else {
					helper.mostrarToast('error', 'Error en respuesta', 'No se ha podido completar la petición');					
					$A.enqueueAction(component.get('c.modalAORCerrar'));
				}

				if(component.find('modalAORBotonIniciar') != null){
					component.find('modalAORBotonIniciar').set('v.disabled', false);
				}
				
				if(component.find('modalAORBotonIniciarRitm') != null){
					component.find('modalAORBotonIniciarRitm').set('v.disabled', false);
				}
				
				component.set('v.currentSelectedRowsAnexos', []);

				if (component.find('tipologiaN1') != null) {
					component.find('tipologiaN1').set('v.value', 'Seleccione un valor...');
				}

				if (component.find('tipologiaN2') != null) {
					component.find('tipologiaN2').set('v.value', 'Seleccione un valor...');
				}

				if (component.find('tipologiaN2') != null) {

				}

				component.set('v.spinner', false);

			});
			$A.enqueueAction(envioAOR);
		}
	}

});