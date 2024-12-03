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
				component.set(
					'v.opcionesCargadas',
					{'tematicas': false, 'productos': false, 'motivos': false, 'causas': false, 'soluciones': false}
				);
			}
		});
		$A.enqueueAction(init);
	},

	recordDataUpdated: function(component, event, helper) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			if (event.getParams().changeType === 'CHANGED') {
				component.find('recordData').reloadRecord();
				//$A.enqueueAction(component.get('c.doInit'));
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
			'nuevoTipoContacto': component.find('CC_Tipo_Contacto__c').get('v.value'),
			'referenciaOperacion': component.find('OS_Referencia_Operacion__c').get('v.value')
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

				//if (component.find('OS_Numero_Operaciones__c').get('v.value') < 1) {
				//	helper.mostrarToast('error', 'No se pudo actualizar el caso', 'El valor del campo "Número de operaciones" debe ser mayor que cero.');
				//} else {
					if (event.getSource().getLocalId() === 'botonGuardarCerrar') {
						component.find('interaccion').set('v.value', 'Nuevo');
						component.find('fechaInteraccion').set('v.value', new Date().toJSON());
						component.find('estado').set('v.value', 'Cerrado');
					} else if (component.get('v.cambiarEstadoPendienteColaborador')) {
						//Acciones específicas para volver a "Pendiente Colaborador"
						component.find('estado').set('v.value', 'Pendiente Colaborador');
					}else if (event.getSource().getLocalId() === 'botonGuardar') {
						if(component.find('estado').get('v.value')=='Cerrado'){
							component.find('estado').set('v.value', component.find('caseStatus').get('v.value'));
						} 
					}
					component.set('v.guardando', true);
					component.find('recordEditForm').submit();
				//}
			}
		});
		$A.enqueueAction(validarGuardar);
	},

	menuRechazar: function(component, event) {
		switch (event.getParam('value')) {
			case 'rechazar':
				$A.enqueueAction(component.get('c.modalRechazarAbrir'));
				break;
		}
	},

	recordEditFormOnLoad: function(component) {
		component.set('v.recordEditFormCargada', true);
	},

	recordEditFormOnSuccess: function(component, event, helper) {
		//Se refresca la recordData, ya que al estar ésta en modo EDIT, el refresco no es automático
		component.find('recordData').reloadRecord(true);

		//Si se ha modificado la clasificación se crea la actividad de retipificación
		if (component.get('v.retipificar')) {
			//Se crea la actividad de retipificación (@future)
			let crearActividadRetipificacion = component.get('c.crearActividadRetipificacion');
			crearActividadRetipificacion.setParams({
				'recordId': component.get('v.recordId'),
				'tematicaAnterior': component.get('v.tematicaAnterior'),
				'productoAnterior': component.get('v.productoAnterior'),
				'motivoAnterior': component.get('v.motivoAnterior')
			});

			/*
			Marc Pla: comento para no penalizar el rendimiento ya que
			no es crítico ver la actividad inmediatamente

			crearActividadRetipificacion.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					//Se refresca el componente OS_Case_Gestion
					//let refrescar = $A.get('e.c:OS_Refresh_Case_Gestion');
					//refrescar.setParam('recordId', component.get('v.recordId'));
					//refrescar.fire();

					//Se refresca la vista para mostrar la nueva actividad
					//$A.get('e.force:refreshView').fire();
				}
			});
			*/
			$A.enqueueAction(crearActividadRetipificacion);
			component.set('v.retipificar', false);
		}

		//Casilla "Cambiar estado a Pendiente Colaborador" marcada
		if (component.get('v.cambiarEstadoPendienteColaborador')) {
			let reabrirTareaTrasladoColaborador = component.get('c.reabrirTareaTrasladoColaborador');
			reabrirTareaTrasladoColaborador.setParam('recordId', component.get('v.recordId'));
			reabrirTareaTrasladoColaborador.setCallback(this, () => component.set('v.cambiarEstadoPendienteColaborador', false));
			$A.enqueueAction(reabrirTareaTrasladoColaborador);
		}

		//Si el canal de procedencia se ha cambiado
		if (component.get('v.cambioCanalProcedencia')) {
			//Se recupera el la cola de procedencia correspondiente al nuevo canal de procedencia
			let accionesCambioCanalProcedencia = component.get('c.accionesCambioCanalProcedencia');
			accionesCambioCanalProcedencia.setParams({
				'idCaso': component.get('v.recordId'),
				'canalProcedenciaAnterior': component.get('v.canalProcedenciaAnterior')
			});
			accionesCambioCanalProcedencia.setCallback(this, $A.getCallback(() => $A.get('e.force:refreshView').fire()));
			$A.enqueueAction(accionesCambioCanalProcedencia);

			component.set('v.canalProcedenciaAnterior', component.find('CC_Canal_Procedencia__c').get('v.value'));
			$A.enqueueAction(component.get('c.canalProcedenciaOnChange'));
		}

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

	modalRechazarCerrar: function(component) {
		component.find('inputEnviarMotivoRechazo').set('v.value', null);
		$A.util.removeClass(component.find('modalRechazar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	modalRechazarRechazar: function(component, event, helper) {
		let inputMotivo = component.find('inputEnviarMotivoRechazo');
		if (!inputMotivo.checkValidity()) {
			inputMotivo.reportValidity();
		} else {
			component.set('v.guardando', true);			

			//PARA ELIMINAR LOS ICONOS DE REASIGNACIÓN DE CASO Y DE ENTRADA DE CORREO
			component.set('v.caso.CC_Ultima_Interaccion__c', 'Nuevo');
			component.set('v.caso.CC_Fecha_Ultima_Interaccion__c', new Date().toJSON());
			component.set('v.caso.Status', 'Rechazado');
			component.find('recordData').saveRecord($A.getCallback(saveResult => {
				if (saveResult.state === 'SUCCESS') {
					//Creación de la actividad de rechazo (@future)
					let crearActividadRechazo = component.get('c.crearActividad');
					crearActividadRechazo.setParams({
						'recordId': component.get('v.recordId'),
						'tipo': 'Rechazado',
						'motivo': inputMotivo.get('v.value')
					});
					$A.enqueueAction(crearActividadRechazo);

			        component.find('recordEditForm').submit();

					helper.mostrarToast('success', 'Se rechazó Caso', 'Se rechazó correctamente el caso ' + component.get('v.caso.CaseNumber') + '.');

					//Refrescar vista
					component.find('recordData').reloadRecord(false);
					//$A.get('e.force:refreshView').fire();
					$A.enqueueAction(component.get('c.modalRechazarCerrar'));
				} else {
					helper.mostrarToast('error', 'No se pudo rechazar el caso', saveResult.error[0].message);
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
					//$A.get('e.force:refreshView').fire();
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