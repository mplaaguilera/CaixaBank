({
	doInit: function(component) {
		let init = component.get('c.init');
		init.setParam('recordId', component.get('v.recordId'));
		init.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let retorno = response.getReturnValue();
				component.set('v.recordTypeName', retorno.RecordTypeName);
				
				if (retorno.Tematica_Caso) {
					component.set('v.opcionesTematicas', [{'value': retorno.Tematica_Caso, 'label': retorno.Tematica_Caso_Name}]);
					component.find('desplegableTematica').set('v.value', retorno.Tematica_Caso);
					component.set('v.nivelSeleccionado.tematica', true);
				}
				if (retorno.Producto_Caso) {
					component.set('v.opcionesProductos', [{'value': retorno.Producto_Caso, 'label': retorno.Producto_Caso_Name}]);
					component.find('desplegableProducto').set('v.value', retorno.Producto_Caso);
					component.set('v.nivelSeleccionado.producto', true);
				}
				if (retorno.Motivo_Caso) {
					component.set('v.opcionesMotivos', [{'value': retorno.Motivo_Caso, 'label': retorno.Motivo_Caso_Name}]);
					component.find('desplegableMotivo').set('v.value', retorno.Motivo_Caso);
					component.set('v.nivelSeleccionado.motivo', true);
				}

				if (retorno.Causa_Caso && retorno.Causa_Caso !== 'NULL') {
					component.set('v.opcionesCausas', [{'value': retorno.Causa_Caso, 'label': retorno.Causa_Caso_Name}]);
					component.find('desplegableCausa').set('v.value', retorno.Causa_Caso);
					component.set('v.nivelSeleccionado.causa', true);
				} else {
					component.set('v.opcionesCausas', [{}]);
					component.find('desplegableCausa').set('v.value', null);
					component.set('v.nivelSeleccionado.causa', false);
				}

				if (retorno.Solucion_Caso && retorno.Solucion_Caso !== 'NULL') {
					component.set('v.opcionesSoluciones', [{'value': retorno.Solucion_Caso, 'label': retorno.Solucion_Caso_Name}]);
					component.find('desplegableSolucion').set('v.value', retorno.Solucion_Caso);
					component.set('v.nivelSeleccionado.solucion', true);
				} else {
					component.set('v.opcionesSoluciones', [{}]);
					component.find('desplegableSolucion').set('v.value', null);
					component.set('v.nivelSeleccionado.solucion', false);
				}

				//Obtener el valor de Campana Fraude
				if (retorno.FRA_CampanaFraude__c) {
					component.set('v.opcionesCampanaFMW', [{'value': retorno.FRA_CampanaFraude__c, 'label': retorno.FRA_CampanaFraude__c}]);
					component.find('desplegableCampanaCustom').set('v.value', retorno.FRA_CampanaFraude__c);
				}

				component.set(
					'v.opcionesCargadas',
					{'tematicas': false, 'productos': false, 'motivos': false, 'causas': false, 'soluciones': false, 'campanasFMW': false}
				);
			}
		});
		$A.enqueueAction(init);
	},

	recordDataUpdated: function(component, event, helper) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			if (event.getParams().changeType === 'CHANGED') {
				component.find('recordData').reloadRecord();
			} else if (event.getParams().changeType === 'LOADED') {
				//Guardamos el canal de procedencia para controlar si cambia respecto al valor inicial
				component.set('v.canalProcedenciaAnterior', component.get('v.caso.CC_Canal_Procedencia__c'));
			}

			component.set('v.casoCerrado', component.get('v.caso.Status') === 'Cerrado' || component.get('v.caso.Status') === 'Rechazado' );
			component.set('v.esPropietario', $A.get('$SObjectType.CurrentUser.Id') === component.get('v.caso.OwnerId'));


		} else if (event.getParams().changeType === 'ERROR') {
			helper.mostrarToast('error', 'Error', component.get('v.recordDataError'));
		}
	},

	tematicaFocus: function(component, event, helper) {
		if (!component.get('v.opcionesCargadas.tematicas')) {
			helper.getTematicas(component);
		}
	},

	productoFocus: function(component, event, helper) {
		if (!component.get('v.opcionesCargadas.productos')) {
			helper.getProductos(component);
		}
	},

	motivoFocus: function(component, event, helper) {
		if (!component.get('v.opcionesCargadas.motivos')) {
			helper.getMotivos(component);
		}
	},

	causaFocus: function(component, event, helper) {
		if (!component.get('v.opcionesCargadas.causas')) {
			helper.getCausas(component);
		}
	},

	solucionFocus: function(component, event, helper) {
		if (!component.get('v.opcionesCargadas.soluciones')) {
			helper.getSoluciones(component);
		}
	},

	campanaCustomFocus: function(component, event, helper) {
		if (!component.get('v.opcionesCargadas.campanasFMW')) {
			helper.getCampanasPicklistFMW(component);
		}
	},

	campanaCustomSeleccionada: function(component) {
        component.set('v.nivelSeleccionado.campanaFMW', true);
    },

	tematicaSeleccionada: function(component, event, helper) {
		component.set('v.nivelSeleccionado.tematica', true);
		helper.vaciarNivelClasificacion(component, 'producto');
		helper.vaciarNivelClasificacion(component, 'motivo');
		helper.vaciarNivelClasificacion(component, 'causa');
		helper.vaciarNivelClasificacion(component, 'solucion');
		helper.getProductos(component);
	},

	productoSeleccionado: function(component, event, helper) {
		component.set('v.nivelSeleccionado.producto', true);
		helper.vaciarNivelClasificacion(component, 'motivo');
		helper.vaciarNivelClasificacion(component, 'causa');
		helper.vaciarNivelClasificacion(component, 'solucion');
		helper.getMotivos(component);
	},

	motivoSeleccionado: function(component, event, helper) {
		component.set('v.nivelSeleccionado.motivo', true);
		helper.vaciarNivelClasificacion(component, 'causa');
		helper.vaciarNivelClasificacion(component, 'solucion');
		helper.getCausas(component);
	},

	causaSeleccionada: function(component, event, helper) {
		component.set('v.nivelSeleccionado.causa', true);
		helper.vaciarNivelClasificacion('solucion');
		helper.getSoluciones(component);
	},

	solucionSeleccionada: function(component) {
		component.set('v.nivelSeleccionado.solucion', true);
	},

	botonGuardarCerrar: function(component, event, helper) {
		let validarGuardar = component.get('c.validarGuardar');
		validarGuardar.setParams({
			'recordId': component.get('v.recordId'),
			'nuevaTematica': component.find('desplegableTematica').get('v.value'),
			'nuevoProducto': component.find('desplegableProducto').get('v.value'),
			'nuevoMotivo': component.find('desplegableMotivo').get('v.value'),
			'nuevaCausa': component.find('desplegableCausa').get('v.value'),
			'nuevaSolucion': component.find('desplegableSolucion').get('v.value'),
			'esCierre': event.getSource().getLocalId() === 'botonGuardarCerrar',
			'nuevoTipoContacto': component.find('CC_Tipo_Contacto__c').get('v.value')
		});
		validarGuardar.setCallback(this, response => {

			if (response.getState() === 'ERROR') {
				//Se muestra un Toast de error y no se sigue adelante con el update de la recordEditForm
				let errors = validarGuardar.getError();
				let mensajeError = '';
				if (errors) {
					errors.forEach(error => mensajeError += error.message + '\n');
					helper.mostrarToast('error', 'No se pudo actualizar el caso', mensajeError);
				}
			} else if (response.getState() === 'SUCCESS') {

				//Se guarda la clasificación anterior para poder registrar la
				//actividad de reclasificación en el recordEditFormOnSuccess
				let retorno = response.getReturnValue();
				component.set('v.retipificar', retorno.retipificar);
				component.set('v.tematicaAnterior', retorno.tematicaAnteriorName);
				component.set('v.productoAnterior', retorno.productoAnteriorName);
				component.set('v.motivoAnterior', retorno.motivoAnteriorName);

				component.find('tematica').set('v.value', component.find('desplegableTematica').get('v.value'));
				component.find('producto').set('v.value', component.find('desplegableProducto').get('v.value'));
				component.find('motivo').set('v.value', component.find('desplegableMotivo').get('v.value'));
				component.find('causa').set('v.value', component.find('desplegableCausa').get('v.value'));
				component.find('solucion').set('v.value', component.find('desplegableSolucion').get('v.value'));
				component.find('campana').set('v.value', component.find('desplegableCampanaCustom').get('v.value'));

				if (event.getSource().getLocalId() === 'botonGuardarCerrar') {
					component.find('interaccion').set('v.value', 'Nuevo');
					component.find('fechaInteraccion').set('v.value', new Date().toJSON());
					component.find('estado').set('v.value', 'Cerrado');
				}else if (event.getSource().getLocalId() === 'botonGuardar') {
					if(component.find('estado').get('v.value')=='Cerrado'){
						component.find('estado').set('v.value', component.find('caseStatus').get('v.value'));
					} 
				}

				if (retorno.retipificar){                        
                    var labelMotivo= '';
                        
					let letOpcionesTematicas = component.get('v.opcionesTematicas');
                    let opcionesTematicasMap = new Map(letOpcionesTematicas.map((obj) => [obj.value, obj.label]));
					var valorTematica = component.find('tematica').get('v.value');
                    var labelTematica = valorTematica ? opcionesTematicasMap.get(valorTematica):'';
                        
                    let letOpcionesProductos = component.get('v.opcionesProductos');
                    let opcionesProductosMap = new Map(letOpcionesProductos.map((obj) => [obj.value, obj.label]));
					var valorProducto = component.find('producto').get('v.value');
                    var labelProducto = valorProducto ? opcionesProductosMap.get(valorProducto):'';
                        
                    let letOpcionesMotivos = component.get('v.opcionesMotivos');
                    if(valorProducto){
                        let opcionesMotivosMap = new Map(letOpcionesMotivos.map((obj) => [obj.value, obj.label]));
						var valorMotivo = component.find('motivo').get('v.value');
                       	labelMotivo = valorMotivo ? opcionesMotivosMap.get(valorMotivo):'';
                    }
                        
					let cuerpo = 'Se ha retipificado el caso.\n\n';
					cuerpo += 'Clasificación anterior:\n· Temática: '+ component.get('v.tematicaAnterior') + '\n· Producto/Servicio: '+ component.get('v.productoAnterior') + '\n· Motivo: '+ component.get('v.motivoAnterior') + '\n\n';
					cuerpo += 'Clasificación nueva:\n· Temática: '+ labelTematica + '\n· Producto/Servicio: '+ labelProducto + '\n· Motivo: '+ labelMotivo + '\n';
								
					let crearActividadRetificacion = component.get('c.crearActividad');
					crearActividadRetificacion.setParams({
						'recordId': component.get('v.recordId'),
						'tipo': 'Reclasificación',
						'motivo': cuerpo
					});
					$A.enqueueAction(crearActividadRetificacion);
				}
					

				component.set('v.guardando', true);
				component.find('recordEditForm').submit();

			}
		});
		$A.enqueueAction(validarGuardar);
	},

	menuRechazar: function(component, event) {
		switch (event.getParam('value')) {
			case 'rechazar':
				$A.enqueueAction(component.get('c.modalRechazarAbrir'));
				break;
			case 'pendienteContactarCliente':
				$A.enqueueAction(component.get('c.modalPendienteContactarClienteAbrir'));
				break;
		}
	},

	recordEditFormOnLoad: function(component) {
		component.set('v.recordEditFormCargada', true);
	},

	recordEditFormOnSuccess: function(component, event, helper) {
		//Se refresca la recordData, ya que al estar ésta en modo EDIT, el refresco no es automático
		component.find('recordData').reloadRecord(true);

		component.set('v.guardando', false);
		helper.mostrarToast('success', 'Se actualizó Caso', 'Se actualizaron correctamente los datos del caso ' + component.get('v.caso.CaseNumber') + '.');
	},

	recordEditFormOnError: function(component, event, helper) {
		component.set('v.guardando', false);
		helper.mostrarToast('error', 'Error actualizando Caso', event.getParam('detail'));
	},

	modalRechazarAbrir: function(component) {
		$A.util.addClass(component.find('modalRechazar'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
	},
	
	// FRA -> para abrir el modal de la funcionalidad Cerrar
	modalCerrarAbrir: function(component) { 
		$A.util.addClass(component.find('modalCerrar'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	// FRA -> para abrir el modal de la funcionalidad Pendiente Contactar Cliente
	modalPendienteContactarClienteAbrir: function(component) {
		$A.util.addClass(component.find('modalPendienteContactarCliente'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	modalRechazarCerrar: function(component) {
		component.find('inputEnviarMotivoRechazo').set('v.value', null);
		$A.util.removeClass(component.find('modalRechazar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	// FRA -> para cerrar el modal de la funcionalidad Cerrar
	modalCerrarCerrar: function(component) { 
		component.find('inputEnviarMotivoCierre').set('v.value', null);
		$A.util.removeClass(component.find('modalCerrar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	// FRA -> para cerrar el modal de la funcionalidad Pendiente Contactar Cliente
	modalPendienteContactarClienteCerrar: function(component) {
		component.find('inputEnviarMotivoPendienteContactoCliente').set('v.value', null);
		$A.util.removeClass(component.find('modalPendienteContactarCliente'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},


	modalRechazarRechazar: function(component, event, helper) {
		//console.log('>> modalRechazarRechazar: Inicio');
	
		let inputMotivo = component.find('inputEnviarMotivoRechazo');
	
		// Validación del campo de motivo
		if (!inputMotivo.checkValidity()) {
			inputMotivo.reportValidity();
			return;
		}
	
		component.set('v.guardando', true);
		component.set('v.caso.Status', 'Rechazado');
	
		// Llamada a Apex para validar si tiene caso en Contact Center
		let action = component.get("c.validarCasoEnContactCenter");
		action.setParams({
			recordId: component.get("v.recordId")
		});
	
		action.setCallback(this, function(response) {
			if (response.getState() === "SUCCESS") {
				let tieneCasoAnterior = response.getReturnValue();
				//console.log('>> Tiene caso anterior:', tieneCasoAnterior);
	
				// Guardar el caso
				component.find('recordData').saveRecord($A.getCallback(saveResult => {
					if (saveResult.state === 'SUCCESS') {
	
						let crearActividadRechazo = component.get('c.crearActividad');
						crearActividadRechazo.setParams({
							recordId: component.get('v.recordId'),
							tipo: 'Rechazado',
							motivo: inputMotivo.get('v.value')
						});
	
						crearActividadRechazo.setCallback(this, function(response) {
							if (response.getState() !== "SUCCESS") {
								let errors = response.getError();
								let message = errors && errors[0] && errors[0].message ? errors[0].message : "Error desconocido.";
								helper.mostrarToast("error", "Error al crear actividad", message);
							}
						});
	
						if (tieneCasoAnterior) {
							let actualizarOtroCaso = component.get('c.rechazarCasoFraude');
							actualizarOtroCaso.setParams({
								recordId: component.get('v.recordId'),
								motivo: inputMotivo.get('v.value')
							});
	
							actualizarOtroCaso.setCallback(this, function(response) {
								if (response.getState() === "SUCCESS") {
									helper.mostrarToast("success", "Caso actualizado", "El caso original se ha reabierto y se ha cerrado el caso de fraude.");
								} else {
									let errors = response.getError();
									let message = errors && errors[0] && errors[0].message ? errors[0].message : "Error desconocido.";
									helper.mostrarToast("error", "Error al rechazar caso", message);
								}
							});
	
							$A.enqueueAction(crearActividadRechazo);
							$A.enqueueAction(actualizarOtroCaso);
	
						} else {
							//console.log('>> No tiene caso anterior, solo se crea la actividad');
							$A.enqueueAction(crearActividadRechazo);
							helper.mostrarToast('success', 'Se rechazó Caso', 'Se rechazó correctamente el caso ' + component.get('v.caso.CaseNumber') + '.');
						}
	
						component.find('recordData').reloadRecord(false);
						$A.enqueueAction(component.get('c.modalRechazarCerrar'));
	
					} else {
						let errorMsg = saveResult.error && saveResult.error[0] && saveResult.error[0].message ? saveResult.error[0].message : "Error desconocido.";
						helper.mostrarToast('error', 'No se pudo rechazar el caso', errorMsg);
					}
					component.set('v.guardando', false);
				}));
	
			} else {
				let errors = response.getError();
				let message = errors && errors[0] && errors[0].message ? errors[0].message : "Error desconocido.";
				helper.mostrarToast('error', 'Error al consultar el caso', message);
				component.set('v.guardando', false);
			}
		});
	
		$A.enqueueAction(action);
	},
	

	// FRA -> para realizar la funcionalidad final de Cerrar
	modalCerrarFinal: function(component, event, helper) {
		let inputMotivo = component.find('inputEnviarMotivoCierre');
		if (!inputMotivo.checkValidity()) {
			inputMotivo.reportValidity();
		} else {
			component.set('v.guardando', true);			

			component.set('v.caso.Status', 'Cerrado');
			component.find('recordData').saveRecord($A.getCallback(saveResult => {
				if (saveResult.state === 'SUCCESS') {
					//FRA -> Creación de la actividad de cerrado (@future)
					let crearActividadCerrado = component.get('c.crearActividad');
					crearActividadCerrado.setParams({
						'recordId': component.get('v.recordId'),
						'tipo': 'Cerrado',
						'motivo': inputMotivo.get('v.value')
					});
					$A.enqueueAction(crearActividadCerrado);

					helper.mostrarToast('success', 'Se cerró Caso', 'Se cerró correctamente el caso ' + component.get('v.caso.CaseNumber') + '.');

					//Refrescar vista
					component.find('recordData').reloadRecord(false);
					$A.enqueueAction(component.get('c.modalCerrarCerrar'));
				} else {
					helper.mostrarToast('error', 'No se pudo cerrar el caso', saveResult.error[0].message);
				}
				component.set('v.guardando', false);
			}));

		}
	},

	// FRA -> para realizar la funcionalidad final de Pendiente Contactar Cliente
	modalPendienteContactarClienteFinal: function(component, event, helper) {
		let inputMotivo = component.find('inputEnviarMotivoPendienteContactoCliente');
		if (!inputMotivo.checkValidity()) {
			inputMotivo.reportValidity();
		} else {
			component.set('v.guardando', true);			

			component.set('v.caso.Status', 'FRA_001');
			component.find('recordData').saveRecord($A.getCallback(saveResult => {
				if (saveResult.state === 'SUCCESS') {
					//Creación de la actividad de pendiente contactar cliente (@future)
					let crearActividadPendienteContactarCliente = component.get('c.crearActividad');
					crearActividadPendienteContactarCliente.setParams({
						'recordId': component.get('v.recordId'),
						'tipo': 'FRA_Pendiente_Contactar_Cliente',
						'motivo': inputMotivo.get('v.value')
					});
					$A.enqueueAction(crearActividadPendienteContactarCliente);

					helper.mostrarToast('success', 'Se modificó el Caso', 'Se cambió el estado correctamente del caso ' + component.get('v.caso.CaseNumber') + '.');

					//Refrescar vista
					component.find('recordData').reloadRecord(false);
					$A.enqueueAction(component.get('c.modalPendienteContactarClienteCerrar'));
				} else {
					helper.mostrarToast('error', 'No se pudo cambiar el estado del caso', saveResult.error[0].message);
				}
				component.set('v.guardando', false);
			}));

		}
	},

	modalRechazarTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalRechazarCerrar'));
		}
	},

	// FRA -> para salir con la tecla esc del modal de la funcionalidad Cerrar
	modalCerrarTeclaPulsada: function(component, event) { 
		if (event.keyCode === 27) { //ESC 
			$A.enqueueAction(component.get('c.modalCerrarCerrar'));
		}
	},

	// FRA -> para salir con la tecla esc del modal de la funcionalidad Pendiente Contactar Cliente
	modalPendienteContactarClienteTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalPendienteContactarClienteCerrar'));
		}
	},

	modalReactivarAbrir: function(component) {
		$A.util.addClass(component.find('modalReactivar'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	modalReactivarCerrar: function(component) {
		$A.util.removeClass(component.find('modalReactivar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.find('inputEnviarMotivoReactivar').set('v.value', '');
	},

	modalReactivarReactivar: function(component, event, helper) {
		let inputMotivo = component.find('inputEnviarMotivoReactivar');
		if (!inputMotivo.checkValidity()) {
			inputMotivo.reportValidity();
		} else {
			component.set('v.guardando', true);
			component.set('v.caso.Status', 'Activo');
			component.find('recordData').saveRecord($A.getCallback(saveResult => {
				if (saveResult.state === 'SUCCESS') {
					//Creación de la actividad de reactivación (@future)
					let crearActividadReactivar = component.get('c.crearActividad');
					crearActividadReactivar.setParams({
						'recordId': component.get('v.recordId'),
						'tipo': 'Reactivación',
						'motivo': inputMotivo.get('v.value')
					});
					$A.enqueueAction(crearActividadReactivar);

					helper.mostrarToast('success', 'Se reactivó Caso', 'Se reactivó correctamente el caso ' + component.get('v.caso.CaseNumber') + '.');

					component.find('recordData').reloadRecord(false);
					$A.enqueueAction(component.get('c.modalReactivarCerrar'));
				} else {
					helper.mostrarToast('error', 'No se pudo reactivar el caso', JSON.stringify(saveResult.error));
				}
				component.set('v.guardando', false);
			}));
		}
	},

	modalReactivarTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalReactivarCerrar'));
		}
	},

	canalProcedenciaOnChange: function(component) {
		component.set('v.cambioCanalProcedencia', component.get('v.canalProcedenciaAnterior') !== component.find('CC_Canal_Procedencia__c').get('v.value'));
	}
});