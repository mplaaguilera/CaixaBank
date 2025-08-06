({
	getOptionsCanalesOperativos: function(component) {
		let getCanalesOperativos = component.get('c.getCanalesOperativos');
		getCanalesOperativos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.opcionesCanalOperativo', response.getReturnValue());
				component.set('v.opcionesMccCargadas.canalesOperativos', true);
			}
		});
		$A.enqueueAction(getCanalesOperativos);
	},

	getOptionsTematicas: function(component) {
		let selectItemCanalOperativo = component.find('selectItemCanalOperativo');

		let getTematicas = component.get('c.getTematicas');
		getTematicas.setParams({
			tipoCliente: component.get('v.caso.RecordType.Name'),
			canalOperativo: selectItemCanalOperativo ? selectItemCanalOperativo.get('v.value') : null,
			canalProcedencia: component.get('v.caso.CC_Canal_Procedencia__c')
		});
		getTematicas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let opcionesTematicas = response.getReturnValue();
				component.set('v.opcionesTematicas', opcionesTematicas);
				component.set('v.opcionesMccCargadas.tematicas', true);
				if (opcionesTematicas.length === 1) {
					component.find('selectItemTematica').set('v.value', opcionesTematicas[0].value);
					$A.enqueueAction(component.get('c.handleTematicaSeleccionada'));
				}
			}
		});
		$A.enqueueAction(getTematicas);
	},

	getOptionsProductos: function(component) {
		let getProductos = component.get('c.getProductos');
		getProductos.setParams({
			tipoCliente: component.get('v.caso.RecordType.Name'),
			tematica: component.find('selectItemTematica').get('v.value'),
			canalProcedencia: component.get('v.caso.CC_Canal_Procedencia__c')
		});
		getProductos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let opcionesProductos = response.getReturnValue();
				component.set('v.opcionesProductos', opcionesProductos);
				component.set('v.opcionesMccCargadas.productos', true);
				if (opcionesProductos.length === 1) {
					component.find('selectItemProducto').set('v.value', opcionesProductos[0].value);
					$A.enqueueAction(component.get('c.handleProductoSeleccionado'));
				}
			}
		});
		$A.enqueueAction(getProductos);
	},

	getOptionsMotivos: function(component) {
		let getMotivos = component.get('c.getMotivos');
		getMotivos.setParams({
			tipoCliente: component.get('v.caso.RecordType.Name'),
			producto: component.find('selectItemProducto').get('v.value'),
			canalProcedencia: component.get('v.caso.CC_Canal_Procedencia__c')
		});
		getMotivos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let opcionesMotivos = response.getReturnValue();
				component.set('v.opcionesMotivos', opcionesMotivos);
				component.set('v.opcionesMccCargadas.motivos', true);
				if (opcionesMotivos.length === 1) {
					component.find('selectItemMotivo').set('v.value', opcionesMotivos[0].value);
					$A.enqueueAction(component.get('c.handleMotivoSeleccionado'));
				}
			}
		});
		$A.enqueueAction(getMotivos);
	},

	getOptionsCausas: function(component) {
		let getCausas = component.get('c.getCausas');
		getCausas.setParams({
			tipoCliente: component.get('v.caso.RecordType.Name'),
			motivo: component.find('selectItemMotivo').get('v.value'),
			canalProcedencia: component.get('v.caso.CC_Canal_Procedencia__c')
		});
		getCausas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let opcionesCausas = response.getReturnValue();
				component.set('v.opcionesCausas', opcionesCausas);
				component.set('v.opcionesMccCargadas.causas', true);
				if (opcionesCausas.length === 1) {
					component.find('selectItemCausa').set('v.value', opcionesCausas[0].value);
					$A.enqueueAction(component.get('c.handleCausaSeleccionada'));
				}
			}
		});
		$A.enqueueAction(getCausas);
	},

	getOptionsSoluciones: function(component) {
		let getSoluciones = component.get('c.getSoluciones');
		getSoluciones.setParams({
			tipoCliente: component.get('v.caso.RecordType.Name'),
			causa: component.find('selectItemCausa').get('v.value'),
			canalProcedencia: component.get('v.caso.CC_Canal_Procedencia__c')
		});
		getSoluciones.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let opcionesSoluciones = response.getReturnValue();
				component.set('v.opcionesSoluciones', opcionesSoluciones);
				component.set('v.opcionesMccCargadas.soluciones', true);
				if (opcionesSoluciones.length === 1) {
					component.find('selectItemSolucion').set('v.value', opcionesSoluciones[0].value);
				}
			}
		});
		$A.enqueueAction(getSoluciones);
	},

	getOptionsCampanas: function(component) {
		let getCampanas = component.get('c.getCampanas');
		getCampanas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.opcionesCampanas', response.getReturnValue());
				component.set('v.opcionesMccCargadas.campanas', true);
			}
		});
		$A.enqueueAction(getCampanas);
	},

	getOptionsErroresTf7: function(component) {
		let getCampanas = component.get('c.getErroresTf7');
		getCampanas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.opcionesErrores', response.getReturnValue());
				component.set('v.opcionesMccCargadas.erroresTf7', true);
			}
		});
		$A.enqueueAction(getCampanas);
	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({title: titulo, message: mensaje, type: tipo, mode: 'dismissable', duration: 4000});
		toastEvent.fire();
	},

	esCasoPromoCaixa: function(component) {
		let canalEntrada = component.get('v.caso.Origin');
		let canalProcedencia = component.get('v.caso.CC_Canal_Procedencia__c');
		if (canalEntrada === 'Email' && (canalProcedencia === 'Soporte Clientes CompraEstrella' || canalProcedencia === 'Soporte Empleados CompraEstrella')
		|| canalEntrada === 'Phone' && (canalProcedencia === 'Alfabético y Comercial' || canalProcedencia === 'Postventa CompraEstrella')
		|| canalEntrada === 'Backoffice' && canalProcedencia === 'Emisiones PromoCaixa'
		|| canalEntrada === 'Chat' && canalProcedencia === 'Alfabético y Comercial'
		|| component.get('v.caso.CC_Grupo_3N__c') === '3N de PromoCaixa Interno') {
			component.set('v.casoPromoCaixa', true);
		}
	},

	inicioGuardar: function(component) {
		component.set('v.guardando', true);
		/* window.setTimeout($A.getCallback(() => {
			let modalGuardando = component.find('modalGuardando');
			if (modalGuardando && component.get('v.guardando')) {
				$A.util.addClass(component.find('backdropGuardando'), 'slds-backdrop_open');
				$A.util.addClass(modalGuardando, 'slds-fade-in-open');
			}
		}), 200); */
	},

	finGuardar: function(component) {
		// $A.util.removeClass(component.find('modalGuardando'), 'slds-fade-in-open');
		// $A.util.removeClass(component.find('backdropGuardando'), 'slds-backdrop_open');
		// window.setTimeout($A.getCallback(() => component.set('v.guardando', false)), 300);
		component.set('v.guardando', false);
	},
	
	guardar: function(component, responseValidarGuardar) {
		//Se guarda la clasificación anterior para poder registrar la
		//actividad de reclasificación en el recordEditFormOnSuccess
		component.set('v.retipificar', responseValidarGuardar.retipificar);
		component.set('v.tematicaAnterior', responseValidarGuardar.tematicaAnteriorName);
		component.set('v.productoAnterior', responseValidarGuardar.productoAnteriorName);
		component.set('v.motivoAnterior', responseValidarGuardar.motivoAnteriorName);
		

		if (component.get('v.caso.RecordType.DeveloperName') === 'CC_Cliente') {
			component.find('derivar').set('v.value', false);		
			component.find('canalOperativoSeleccionadoOculto').set('v.value', component.find('selectItemCanalOperativo').get('v.value'));
			if(component.get('v.cambiarStatusAuto')){
				// component.find('statusAutoOculto').set('v.value', 'DENIED');
			}
		}
		
		let idTematica = component.find('selectItemTematica').get('v.value');
		let idProducto = component.find('selectItemProducto').get('v.value');
		let idMotivo = component.find('selectItemMotivo').get('v.value');
		let idCausa = component.find('selectItemCausa').get('v.value');
		let idSolucion = component.find('selectItemSolucion').get('v.value');
		component.find('tematicaSeleccionadaOculto').set('v.value', idTematica ? idTematica : null);
		component.find('productoSeleccionadoOculto').set('v.value', idProducto ? idProducto : null);
		component.find('motivoSeleccionadoOculto').set('v.value', idMotivo ? idMotivo : null);
		component.find('causaSeleccionadaOculto').set('v.value', idCausa ? idCausa : null);
		component.find('solucionSeleccionadaOculto').set('v.value', idSolucion ? idSolucion : null);
		if(component.find('campanaSeleccionadaOculto') && component.find('selectItemCampana')){
			component.find('campanaSeleccionadaOculto').set('v.value', component.find('selectItemCampana').get('v.value'));
		}
		if (component.get('v.caso.RecordType.DeveloperName') === 'CC_Empleado'
		| component.get('v.caso.RecordType.DeveloperName') === 'CC_CSI_Bankia') {
			component.find('errorTerminalSeleccionadoOculto').set('v.value', component.find('selectItemErroresTF7').get('v.value'));
		}
		
		if (component.get('v.cerrarCaso') && (component.get('v.tieneActividad') || component.get('v.ambitoCSBD'))){
			this.guardarCerrarAuxiliar(component);
		} else if (component.get('v.cambiarEstadoPendienteColaborador')) {
			component.find('estado').set('v.value', 'Pendiente Colaborador');
		}else if (!component.get('v.tieneActividad') && component.get('v.cerrarCaso') && (component.get('v.caso.RecordType.DeveloperName') === 'CC_Cliente' && !component.get('v.ambitoCSBD'))) {
			$A.enqueueAction(component.get('c.comprobarAgrupacionSolucion'));
		} else {
			component.find('estado').set('v.value', component.get('v.estadoInicial'));
		}
		if(!component.get('v.cerrarCaso') && component.find('recordEditForm')) {
			component.find('recordEditForm').submit();
		}
	},
	
	guardarCerrarAuxiliar: function(component) {
		let idTematica = component.find('selectItemTematica').get('v.value');
		let idProducto = component.find('selectItemProducto').get('v.value');
		let idMotivo = component.find('selectItemMotivo').get('v.value');
		let idCausa = component.find('selectItemCausa').get('v.value');
		let idSolucion = component.find('selectItemSolucion').get('v.value');
		component.find('tematicaSeleccionadaOculto').set('v.value', idTematica ? idTematica : null);
		component.find('productoSeleccionadoOculto').set('v.value', idProducto ? idProducto : null);
		component.find('motivoSeleccionadoOculto').set('v.value', idMotivo ? idMotivo : null);
		component.find('causaSeleccionadaOculto').set('v.value', idCausa ? idCausa : null);
		component.find('solucionSeleccionadaOculto').set('v.value', idSolucion ? idSolucion : null);
		if(component.find('campanaSeleccionadaOculto') && component.find('selectItemCampana')){
			component.find('campanaSeleccionadaOculto').set('v.value', component.find('selectItemCampana').get('v.value'));
		}
        if (component.get('v.caso.RecordType.DeveloperName') === 'CC_Empleado'
		| component.get('v.caso.RecordType.DeveloperName') === 'CC_CSI_Bankia') {
			component.find('errorTerminalSeleccionadoOculto').set('v.value', component.find('selectItemErroresTF7').get('v.value'));
		}
		component.find('tematicaInternaSeleccionadaOculto').set('v.value', idTematica ? component.get('v.opcionesTematicas').find(t => t.value === idTematica).label : null);
		component.find('productoInternoSeleccionadaOculto').set('v.value', idProducto ? component.get('v.opcionesProductos').find(p => p.value === idProducto).label : null);
		component.find('motivoInternoSeleccionadaOculto').set('v.value', idMotivo ? component.get('v.opcionesMotivos').find(m => m.value === idMotivo).label : null);
		component.find('causaInternaSeleccionadaOculto').set('v.value', idCausa ? component.get('v.opcionesCausas').find(c => c.value === idCausa).label : null);
		component.find('solucionInternaSeleccionadaOculto').set('v.value', idSolucion ? component.get('v.opcionesSoluciones').find(s => s.value === idSolucion).label : null);
		let today = new Date();
        if (component.get('v.cierroCaso')){          
            component.find('cerradoOperativa').set('v.value', today.toISOString());
            component.find('estado').set('v.value', 'Cerrado');
        }
		if(component.find('recordEditForm')){
			component.find('recordEditForm').submit();
		}
	},

	recuperarMensajeToast : function (component, tipo, validacion) {
        let recuperarMensajeToast = component.get("c.mensajeValidacionPreguntas");
            recuperarMensajeToast.setParams({ "validacion": validacion });
            recuperarMensajeToast.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    let tituloMensaje = response.getReturnValue();
					
                    this.mostrarToast(tipo, tituloMensaje.Name, tituloMensaje.CC_Valor__c);
                }
            });
            $A.enqueueAction(recuperarMensajeToast);
    },

	camposObligatoriosNoInformados: function(component){
		let retorno;
		let camposObligatoriosNoInformados = ['\n'];
		if (!['Twitter', 'Propuestas de mejora', 'Chat', 'Comentarios Stores'].includes(component.get('v.caso.Origin'))
		&& !['Buzón Fondos', 'Buzón Carteras'].includes(component.get('v.caso.CC_Canal_Procedencia__c'))
		&& !component.find('CC_Detalles_Consulta__c').get('v.value')) {
			camposObligatoriosNoInformados.push('Detalles consulta');
		}

		if (!['Propuestas de mejora', 'Email - Revisar'].includes(component.get('v.caso.Origin'))) {
			if (component.find('CC_Tipo_Contacto__c') && !component.find('CC_Tipo_Contacto__c').get('v.value')) {
				camposObligatoriosNoInformados.push('Tipo de contacto');
			}
			if (component.find('selectItemCanalOperativo') && !component.find('selectItemCanalOperativo').get('v.value')) {
				camposObligatoriosNoInformados.push('Canal operativo');
			}
			if (!component.find('selectItemTematica').get('v.value')) {
				camposObligatoriosNoInformados.push('Temática');
			}
			if (!component.find('selectItemProducto').get('v.value')) {
				camposObligatoriosNoInformados.push('Producto/Servicio');
			}
			if (!component.find('selectItemMotivo').get('v.value')) {
				camposObligatoriosNoInformados.push('Motivo');
			}
			if (!component.find('selectItemCausa').get('v.value')) {
				camposObligatoriosNoInformados.push('Causa');
			}
			// if (!component.find('selectItemCausa').get('v.value')) {
			// 	camposObligatoriosNoInformados.push('Solución');
			// }
			if (component.find('CC_Idioma__c') && !component.find('CC_Idioma__c').get('v.value')) {
				camposObligatoriosNoInformados.push('Idioma');
			}
		}

		if (component.get('v.caso.Origin') !== 'Twitter' && component.get('v.caso.Origin') !== 'Comentarios Stores'
		&& component.get('v.caso.Canal_del_Empleado__c') !== 'Hidden'
		&& !component.get('v.caso.CC_No_Identificado__c') && !component.get('v.caso.ContactId')) {
			camposObligatoriosNoInformados.push('Cuenta y contacto');
		}

		if (!component.get('v.caso.CC_Canal_Procedencia__c')) {
			camposObligatoriosNoInformados.push('Canal de procedencia');
		}
		
		if (camposObligatoriosNoInformados.length > 1) {
			this.mostrarToast('info', 'Campos obligatorios', 'Es necesario que informes Los siguientes campos antes de cerrar el caso:' + camposObligatoriosNoInformados.join('\n\u00a0\u00a0\u00a0\u00a0\u00a0·\u00a0\u00a0'));
			this.finGuardar(component);
			component.set('v.cerrarCaso', false);
			component.set('v.cierroCaso', false);
			retorno = false;
		} else {
			retorno = true;
		}

		return retorno;
    }
});