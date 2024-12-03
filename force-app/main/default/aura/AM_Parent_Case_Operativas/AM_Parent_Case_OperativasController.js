({
	onRender: function(component) {
		//Para evitar referencias a popovers de pestañas sin foco, se les da un id único
		if (!component.get('v.primerRenderizadoFinalizado')) {
			//document.getElementById('popoverOtrasOperativas').id = 'popoverOtrasOperativas' + component.get('v.recordId');
			component.set('v.primerRenderizadoFinalizado', true);
		}
	},
	
	recordDataUpdated: function(component, event) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			//Se actualiza el atributo esPropietario para habilitar/deshabilitar el botón de guardado
			let estado = component.get('v.caso.Status');
			let esPropietario = $A.get('$SObjectType.CurrentUser.Id') === component.get('v.caso.OwnerId');
			let isClosed = component.get('v.caso.IsClosed');
			component.set('v.esPropietario', esPropietario);
			component.set('v.botonCerrarActivo', estado === 'Activo' && esPropietario);
			component.set('v.botonReactivarActivo', isClosed && esPropietario);
			
			if (event.getParams().changeType === 'CHANGED') {
				component.find('caseData').reloadRecord();
			}
		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.ldsError'));
		}
	},
	

	iniciarOperativa: function(component, event, helper) {
			
        //Lanzar operativa
        switch (event.getSource().getLocalId()) {
            case 'Trasladar Colaborador':
                component.set('v.tipoOperativa', 'trasladar');
                $A.enqueueAction(component.get('c.modalColabAbrir'));
                break;
            case 'Solicitud Info Email':
                component.set('v.tipoOperativa', 'solicitar');
                $A.enqueueAction(component.get('c.abrirModalSolicitarInfo'));
                break;
            case 'botonResponder':
                component.set('v.tipoOperativa', 'responderCliente');
                $A.enqueueAction(component.get('c.abrirModalResponderCliente'));
                break;
            }
	},

	seleccionarResultadoGrupo: function(component, event) {
		component.set('v.grupoSeleccionado', event.getParam('accountByEvent'));
		$A.enqueueAction(component.get('c.obtenerPlantillasGrupo'));

		let lookupPill = component.find('pillGrupoSeleccionado');
		$A.util.addClass(lookupPill, 'slds-show');
		$A.util.removeClass(lookupPill, 'slds-hide');

		let searchRes = component.find('grupoResultados');
		$A.util.addClass(searchRes, 'slds-is-close');
		$A.util.removeClass(searchRes, 'slds-is-open');

		let lookupField = component.find('lookupField');
		$A.util.addClass(lookupField, 'slds-hide');
		$A.util.removeClass(lookupField, 'slds-show');
	},

	seleccionarResultadoPlantilla: function(component, event) {
		component.set('v.plantillaSeleccionadaColab', event.getParam('plantillaByEvent'));

		let pillPlantillaSeleccionada = component.find('pillPlantillaSeleccionada');
		$A.util.addClass(pillPlantillaSeleccionada, 'slds-show');
		$A.util.removeClass(pillPlantillaSeleccionada, 'slds-hide');

		let pillPlantillaSeleccionadaResponder = component.find('pillPlantillaSeleccionadaResponder');
		$A.util.addClass(pillPlantillaSeleccionadaResponder, 'slds-show');
		$A.util.removeClass(pillPlantillaSeleccionadaResponder, 'slds-hide');

		let plantillaResultados = component.find('plantillaResultados');
		$A.util.addClass(plantillaResultados, 'slds-is-close');
		$A.util.removeClass(plantillaResultados, 'slds-is-open');

		let plantillaResultadosResponder = component.find('plantillaResultadosResponder');
		$A.util.addClass(plantillaResultadosResponder, 'slds-is-close');
		$A.util.removeClass(plantillaResultadosResponder, 'slds-is-open');

		let lookupFieldPlantilla = component.find('lookupFieldPlantilla');
		$A.util.addClass(lookupFieldPlantilla, 'slds-hide');
		$A.util.removeClass(lookupFieldPlantilla, 'slds-show');

		let lookupFieldPlantillaResponder = component.find('lookupFieldPlantillaResponder');
		$A.util.addClass(lookupFieldPlantillaResponder, 'slds-hide');
		$A.util.removeClass(lookupFieldPlantillaResponder, 'slds-show');
	},

	modalColabAbrir: function(component, event, helper) {
		component.set('v.procesando', false);
		component.set('v.renderModalColab', true);
		component.set('v.verTodosLosGrupos', true);//MLA: pongo el toggle a true para que directamente se muestren todos los grupos
		component.set('v.gruposClasificacionOptions', null);
		component.set('v.gruposClasificacionValue', null);
		component.set('v.grupoSeleccionado', null);
		component.set('v.literalBusquedaGrupo', null);
		component.set('v.verTodasLasPlantillas', false);
		component.set('v.plantillasGrupoOptions', null);
		component.set('v.plantillasGrupoValue', null);
		component.set('v.literalBusquedaPlantilla', null);
		component.set('v.plantillaSeleccionadaColab', null);
		component.set('v.plantillaSeleccionadaValue', null);
		component.set('v.plantillaSeleccionadaName', null);

		//helper.getGruposClasificacion(component); MLA: No hace falta cargar los colaboradores porque tienen que aparecer todos
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		$A.util.addClass(component.find('modalColab'), 'slds-fade-in-open');
	},

	modalColabCerrar: function(component) {
		$A.util.removeClass(component.find('modalColab'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.renderModalColab', false);
	},

	modalColabTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalColabCerrar'));
		}
	},

	teclaPulsadaLookupGrupoColaborador: function(component, event, helper) {
		let grupoResultados = component.find('grupoResultados');
		if (component.get('v.literalBusquedaGrupo').length > 0) {
			$A.util.addClass(grupoResultados, 'slds-is-open');
			$A.util.removeClass(grupoResultados, 'slds-is-close');
			helper.getGruposBusqueda(component);
		} else {
			$A.util.addClass(grupoResultados, 'slds-is-close');
			$A.util.removeClass(grupoResultados, 'slds-is-open');
			component.set('v.listOfSearchRecords', null);
		}
	},

	deseleccionarGrupoColaborador: function(component) {
		//Eliminar el grupo seleccionado
		$A.util.addClass(component.find('pillGrupoSeleccionado'), 'slds-hide');
		$A.util.removeClass(component.find('pillGrupoSeleccionado'), 'slds-show');

		$A.util.addClass(component.find('lookupField'), 'slds-show');
		$A.util.removeClass(component.find('lookupField'), 'slds-hide');

		component.set('v.literalBusquedaGrupo', null);
		component.set('v.listOfSearchRecords', null);
		component.set('v.grupoSeleccionado', null);
		component.set('v.gruposClasificacionValue', null);
	},

	obtenerPlantillasGrupo: function(component, event) {
		let getPlantillaGrupoList = component.get('c.getPlantillaGrupoList');
		getPlantillaGrupoList.setParams({
			'grupoId': component.get('v.verTodosLosGrupos') ? component.get('v.grupoSeleccionado.Id') : event.getParam('value'),
			'tipoOperativa': component.get('v.tipoOperativa')
		});
		getPlantillaGrupoList.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let opcionesPlantillas = response.getReturnValue();
				component.set('v.plantillasGrupoOptions', opcionesPlantillas);
				component.find('plantillaSeleccionada').set('v.value', null);

				window.setTimeout($A.getCallback(() => component.find('plantillaSeleccionada').focus()), 100);
			}
		});
		$A.enqueueAction(getPlantillaGrupoList);
	},

	trasladarColaborador: function(component) {
		component.set('v.procesando', true);

		let idGrupoColaborador;
		let nombreGrupoColaborador;
		if (component.get('v.verTodosLosGrupos')) {
			idGrupoColaborador = component.get('v.grupoSeleccionado.Id');
			nombreGrupoColaborador = component.get('v.grupoSeleccionado.Name');
		} else {
			idGrupoColaborador = component.find('gruposClasificacion').get('v.value');
			nombreGrupoColaborador = component.get('v.gruposClasificacionOptions').find(grupo => grupo.value === idGrupoColaborador).label;
		}
		
		let idPlantillaSeleccionada;
		if (component.get('v.verTodasLasPlantillas')) {
			idPlantillaSeleccionada = component.get('v.plantillaSeleccionadaColab.Id');
		} else {
			idPlantillaSeleccionada = component.get('v.plantillasGrupoValue');
		}

		let prepararCaso = component.get('c.prepararCaso');
		prepararCaso.setParams({
			'idCaso': component.get('v.recordId'),
			'plantilla': idPlantillaSeleccionada,
			'informarReferenciaCorreo': true,
			'operativa': component.get('v.tipoOperativa'),
			'colaboradorName': nombreGrupoColaborador

		});
		$A.enqueueAction(prepararCaso);
		$A.enqueueAction(component.get('c.modalColabCerrar'));
		$A.get('e.force:refreshView').fire();
		$A.enqueueAction(component.get('c.modalCorreoColabAbrir'));
	},

	modalCorreoColabAbrir: function(component, event, helper) {
		component.set('v.procesando', false);
		component.set('v.renderModalColabCorreo', true);
		helper.getPlantillaCaso(component);
		$A.util.addClass(component.find('modalColabCorreo'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		
	},

	modalCorreoColabCerrar: function(component) {
		$A.util.removeClass(component.find('modalColabCorreo'), 'slds-fade-in-open');//Aquí
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.renderModalColabCorreo', false);
		$A.get('e.force:refreshView').fire();
	},

	modalColabCorreoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalCorreoColabCerrar'));
		}
	},

	enviarCorreoColab: function(component, event, helper) {
		let idGrupoColaborador;
		let tipoOperativa = component.get('v.tipoOperativa');
		idGrupoColaborador = component.get('v.grupoSeleccionado.Id');
		let buscarColaborador = component.get('c.destinatariosColaborador');
		buscarColaborador.setParam('idGrupoColaborador', idGrupoColaborador);
		buscarColaborador.setCallback(this, responseBuscarColaborador => {
			if (responseBuscarColaborador.getState() === 'SUCCESS') {
				
				let destinatariosPara = [];
				let destinatariosEnCopia = [];
				let direcciones = responseBuscarColaborador.getReturnValue();
				for (let indice in direcciones) {
					if (direcciones[indice] === 'Para') {
						destinatariosPara.push(indice);
					} else if (direcciones[indice] === 'CC') {
						destinatariosEnCopia.push(indice);
					}
				}
				let envioCorreo = component.get('c.envioCorreo');
				envioCorreo.setParams({
					'idCasoPadre': component.get('v.recordId'),
					'cuerpoPlantilla': component.get('v.cuerpoPlantilla'),
					'subjectPlantilla': component.get('v.subjectPlantilla'),
					'destinatariosPara': destinatariosPara,
					'destinatariosCC': destinatariosEnCopia,
					'operativa': tipoOperativa
				});
				envioCorreo.setCallback(this, responseEnvioCorreo => {
					if (responseEnvioCorreo.getState() === 'SUCCESS') {
						helper.mostrarToast('success', 'Emails Enviados', 'Se han enviado correctamente los emails.');
					}	
				});
				
				$A.enqueueAction(envioCorreo);
			}
			
			
		});
		$A.enqueueAction(buscarColaborador);
		$A.enqueueAction(component.get('c.modalCorreoColabCerrar'));
	},

	abrirModalSolicitarInfo: function(component, event, helper) {
		component.set('v.procesando', false);
		component.set('v.renderModalSolInfo', true);
		component.set('v.optionsPlantillaResponder', null);
		component.set('v.opcionesIdiomaCarpeta', null);
		component.set('v.opcionesTratamientoCarpeta', null);
		component.set('v.idiomaPlantilla', null);
		component.set('v.tratamiento', null);
		component.set('v.listOfSearchRecords', null);
		component.set('v.listOfSearchRecordsPlantilla', null);
		component.set('v.plantillaSeleccionadaValue', null);
		component.set('v.plantillaSeleccionadaName', '');

		helper.loadCarpetasIdioma(component);

		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		$A.util.addClass(component.find('ModalboxSolicitarInfo'), 'slds-fade-in-open');
	},

	modalSolicitarInfoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalSolicitarInfo'));
		}
	},

	cerrarModalSolicitarInfo: function(component) {
		let selectItemIdioma = component.find('selectItemIdiomaSol').get('v.value');
		if (selectItemIdioma != null && selectItemIdioma !== '') {
			component.find('selectItemIdiomaSol').set('v.value', null);
			let selectItemTratamiento = component.find('selectItemTratamientoSol').get('v.value');
			if (selectItemTratamiento != null && selectItemTratamiento !== '') {
				component.find('selectItemTratamientoSol').set('v.value', null);
				let selectItemPlantilla = component.find('selectItemPlantillaSol').get('v.value');
				if (selectItemPlantilla != null && selectItemPlantilla !== '') {
					component.find('selectItemPlantillaSol').set('v.value', null);
				}
			}
		}

		//Cierra el modal de Solicitud de información
		//component.set('v.plantillaSeleccionadaValue', null);
		//component.set('v.plantillaSeleccionadaName', '');
		//component.set('v.optionsPlantillaSolicitud', null);
		//component.set('v.carpetaIdioma', '');
		component.set('v.opcionesIdiomaCarpeta', null);
		component.set('v.opcionesTratamientoCarpeta', null);
		//component.set('v.carpetaFinal', null);
		//component.set('v.tipoOperativa', '');

		$A.enqueueAction(component.get('c.deseleccionarPlantilla'));
		$A.util.removeClass(component.find('ModalboxSolicitarInfo'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.renderModalSolInfo', false);
	},

	solicitarInfo: function(component) {
		component.set('v.procesando', true);
		let colaboradorName;
		let prepararCaso = component.get('c.prepararCaso');
		prepararCaso.setParams({
			'idCaso': component.get('v.recordId'),
			'plantilla': component.get('v.plantillaSeleccionadaValue'),
			'informarReferenciaCorreo': true,
			'operativa': component.get('v.tipoOperativa'),
			'colaboradorName': colaboradorName
		});
		
		$A.enqueueAction(component.get('c.cerrarModalSolicitarInfo'));
		$A.enqueueAction(prepararCaso);
		$A.get('e.force:refreshView').fire();
		$A.enqueueAction(component.get('c.modalCorreoSolInfoAbrir'));
	},

	modalSolInfoCorreoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalCorreoSolInfoCerrar'));
		}
	},

	modalCorreoSolInfoAbrir: function(component, event, helper) {
		component.set('v.procesando', false);
		component.set('v.renderModalSolInfoCorreo', true);
		helper.getPlantillaCaso(component);
		$A.util.addClass(component.find('modalSolInfoCorreo'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		
	},

	modalCorreoSolInfoCerrar: function(component) {
		$A.util.removeClass(component.find('modalSolInfoCorreo'), 'slds-fade-in-open');//Aquí
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.renderModalSolInfoCorreo', false);
		$A.get('e.force:refreshView').fire();
	},

	handleCarpetaIdiomaSeleccionada: function(component, event, helper) {
		component.set('v.opcionesTratamientoCarpeta', null);
		component.set('v.optionsPlantillaResponder', null);
		component.set('v.tratamiento', null);
		component.set('v.plantillaSeleccionadaValue', null);
		//component.set('v.idiomaPlantilla', event.getParam('value'));
		helper.loadCarpetasTratamiento(component);
	},

	handleCarpetaTratamientoSeleccionada: function(component) {
		if (component.get('v.tratamiento')) {
			let getPlantillasResponder = component.get('c.getPlantillasResponder');
			getPlantillasResponder.setParams({
				'recordId': component.get('v.recordId'),
				'carpeta': component.get('v.tratamiento')
			});
			getPlantillasResponder.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					component.set('v.optionsPlantillaResponder', response.getReturnValue());
					component.set('v.plantillaSeleccionadaValue', null);
					if (response.getReturnValue().length > 0) {
						if (component.get('v.tipoOperativa') === 'solicitar') {
							window.setTimeout($A.getCallback(() => component.find('selectItemPlantillaSol').focus()), 100);
						} else {
							component.find('selectItemPlantilla').set('v.value', null);
							window.setTimeout($A.getCallback(() => component.find('selectItemPlantilla').focus()), 100);
						}
					}
				}
			});
			$A.enqueueAction(getPlantillasResponder);
		}
	},

	abrirModalResponderCliente: function(component, event, helper) {
		component.set('v.procesando', false);
		component.set('v.renderModalResponder', true);
		component.set('v.optionsPlantillaResponder', null);
		component.set('v.opcionesIdiomaCarpeta', null);
		component.set('v.opcionesTratamientoCarpeta', null);
		component.set('v.idiomaPlantilla', null);
		component.set('v.tratamiento', null);
		component.find('selectItemPlantilla').set('v.value', null);
		component.set('v.listOfSearchRecordsPlantilla', null);
		component.set('v.verTodasLasPlantillas', false);
		component.set('v.plantillaSeleccionadaValue', null);
		helper.loadCarpetasIdioma(component);
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		$A.util.addClass(component.find('ModalboxResponderCliente'), 'slds-fade-in-open');
	},

	cerrarModalResponderCliente: function(component) {
		$A.enqueueAction(component.get('c.deseleccionarPlantilla'));
		$A.util.removeClass(component.find('ModalboxResponderCliente'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.renderModalResponder', false);
		component.set('v.verTodasLasPlantillas', false);
	},

	modalResponderClienteTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalResponderCliente'));
		}
	},

	responderCliente: function(component) {
		component.set('v.procesando', true);
		component.set('v.toggleCerrarCaso', component.find('responderCerrar').get('v.checked'));
		let plantilla = '';
		let colaboradorName;
		if (!component.get('v.verTodasLasPlantillas')) {
			//Desplegable de plantillas
			plantilla = component.get('v.plantillaSeleccionadaValue');
		} else {
			//Buscador de plantillas
			plantilla = component.get('v.plantillaSeleccionadaColab.Id');
		}
		let prepararCaso = component.get('c.prepararCaso');
		prepararCaso.setParams({
			'idCaso': component.get('v.recordId'),
			'plantilla': plantilla,
			'informarReferenciaCorreo': true,
			'operativa': component.get('v.tipoOperativa'),
			'colaboradorName': colaboradorName
		});
		
		$A.enqueueAction(component.get('c.cerrarModalResponderCliente'));
		$A.enqueueAction(prepararCaso);
		$A.get('e.force:refreshView').fire();
		$A.enqueueAction(component.get('c.modalCorreoResponderAbrir'));
	},

	modalResponderCorreoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalCorreoResponderCerrar'));
		}
	},

	modalCorreoResponderAbrir: function(component, event, helper) {
		component.set('v.procesando', false);
		component.set('v.renderModalResponderCorreo', true);
		helper.getPlantillaCaso(component);
		$A.util.addClass(component.find('modalResponderCorreo'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		
	},

	modalCorreoResponderCerrar: function(component) {
		$A.util.removeClass(component.find('modalResponderCorreo'), 'slds-fade-in-open');//Aquí
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.renderModalResponderCorreo', false);
		$A.get('e.force:refreshView').fire();
	},

	enviarCorreoRespInfo: function(component, event, helper) {
		let tipoOperativa = component.get('v.tipoOperativa');
		let destinatariosPara = [];
		let destinatariosEnCopia = [];
		let envioCorreo = component.get('c.envioCorreo');
		envioCorreo.setParams({
			'idCasoPadre': component.get('v.recordId'),
			'cuerpoPlantilla': component.get('v.cuerpoPlantilla'),
			'subjectPlantilla': component.get('v.subjectPlantilla'),
			'destinatariosPara': destinatariosPara,
			'destinatariosCC': destinatariosEnCopia,
			'operativa': tipoOperativa
		});
		envioCorreo.setCallback(this, responseEnvioCorreo => {
			if (responseEnvioCorreo.getState() === 'SUCCESS') {
				helper.mostrarToast('success', 'Emails Enviados', 'Se han enviado correctamente los emails.');
				
			} else {
				helper.mostrarToast('error', 'Error', 'No se ha podido realizar la operativa.');
			}
		});
		if(tipoOperativa === 'responderCliente'){
			let actualizarCerrado = component.get('c.actualizarCampoCerradoOperativa');
			actualizarCerrado.setParams({
				'idCaso': component.get('v.recordId'),
				'cerradoOperativa': component.get('v.toggleCerrarCaso')
			});
			actualizarCerrado.setCallback(this, responseActualizarCerrado => {
			});
			$A.enqueueAction(actualizarCerrado);
			$A.enqueueAction(component.get('c.modalCorreoResponderCerrar'));
		} else if (tipoOperativa === 'solicitar'){
			$A.enqueueAction(component.get('c.modalCorreoSolInfoCerrar'));
		}	
		$A.enqueueAction(envioCorreo);
	},

	teclaPulsadaLookupPlantilla: function(component, event, helper) {
		let panelResultados;
		if (event.getSource().getLocalId() === 'inputBuscarPlantillaResponder') {
			panelResultados = component.find('plantillaResultadosResponder');
		} else {
			panelResultados = component.find('plantillaResultados');
		}

		if (component.get('v.literalBusquedaPlantilla').length > 0) {
			$A.util.addClass(panelResultados, 'slds-is-open');
			$A.util.removeClass(panelResultados, 'slds-is-close');
			helper.buscarPlantillas(component);
		} else {
			$A.util.addClass(panelResultados, 'slds-is-close');
			$A.util.removeClass(panelResultados, 'slds-is-open');
			component.set('v.listOfSearchRecordsPlantilla', null);
		}
	},

	seleccionarOpcionPlantilla: function(component, event) {
		let tipoOperativa = component.get('v.tipoOperativa');
		if (tipoOperativa === 'trasladar' || tipoOperativa === 'remitir') {
			let optionsPlantilla = component.get('v.plantillasGrupoOptions');
			for (let key in optionsPlantilla) {
				if (event.getParam('value') === optionsPlantilla[key].value) {
					component.set('v.plantillaSeleccionadaValue', optionsPlantilla[key].value);
					component.set('v.plantillaSeleccionadaName', optionsPlantilla[key].label);
				}
			}
		} else if (tipoOperativa === 'responderCliente') {
			let picklistFirstOptionsPlantilla = component.get('v.optionsPlantillaResponder');
			for (let key in picklistFirstOptionsPlantilla) {
				if (event.getParam('value') === picklistFirstOptionsPlantilla[key].value) {
					component.set('v.plantillaSeleccionadaValue', picklistFirstOptionsPlantilla[key].value);
					component.set('v.plantillaSeleccionadaName', picklistFirstOptionsPlantilla[key].label);
				}
			}
		} else {
			let optionsPlantillaResponder = component.get('v.optionsPlantillaResponder');
			for (let key in optionsPlantillaResponder) {
				if (event.getParam('value') === optionsPlantillaResponder[key].value) {
					component.set('v.plantillaSeleccionadaValue', optionsPlantillaResponder[key].value);
					component.set('v.plantillaSeleccionadaName', optionsPlantillaResponder[key].label);
				}
			}
		}
	},

	deseleccionarPlantilla: function(component) {
		//Eliminar el grupo seleccionado
		let pillTarget = component.find('pillPlantillaSeleccionada');
		$A.util.addClass(pillTarget, 'slds-hide');
		$A.util.removeClass(pillTarget, 'slds-show');

		let lookupFieldPlantilla = component.find('lookupFieldPlantilla');
		$A.util.addClass(lookupFieldPlantilla, 'slds-show');
		$A.util.removeClass(lookupFieldPlantilla, 'slds-hide');

		let lookUpTarget = component.find('lookupFieldPlantillaResponder');
		$A.util.addClass(lookUpTarget, 'slds-show');
		$A.util.removeClass(lookUpTarget, 'slds-hide');

		component.set('v.literalBusquedaPlantilla', null);
		component.set('v.listOfSearchRecordsPlantilla', null);
		component.set('v.plantillaSeleccionadaColab', null);
	},

	tomarPropiedad: function(component, event, helper) {
		component.set('v.caso.OwnerId', $A.get('$SObjectType.CurrentUser.Id'));
		component.find('caseData').saveRecord($A.getCallback(saveResult => {
			if (saveResult.state === 'SUCCESS') {
				helper.mostrarToast('success', 'Se reasignó Caso', 'Ahora es el propietario del caso ' + component.get('v.caso.CaseNumber'));
			} else if (saveResult.state === 'ERROR') {
				helper.mostrarToast('error', 'No se reasignó Caso', JSON.stringify(saveResult.error));
			}
		}));
	},

	inputBuscarPlantillaResponderFocus: function(component) {
		if (component.get('v.verTodasLasPlantillas') && component.find('inputBuscarPlantillaResponder').get('v.value')) {
			$A.util.addClass(component.find('plantillaResultadosResponder'), 'slds-is-open');
			$A.util.removeClass(component.find('plantillaResultadosResponder'), 'slds-is-close');
		}
	},

	inputBuscarPlantillaResponderBlur: function(component) {
		window.setTimeout($A.getCallback(() => {
			if (component.find('plantillaResultadosResponder') != null) {
				$A.util.addClass(component.find('plantillaResultadosResponder'), 'slds-is-close');
				$A.util.removeClass(component.find('plantillaResultadosResponder'), 'slds-is-open');
			}
		}), 200);
	},

	inputBuscarColabFocus: function(component) {
		if (component.find('inputBuscarColab').get('v.value')) {
			$A.util.addClass(component.find('grupoResultados'), 'slds-is-open');
			$A.util.removeClass(component.find('grupoResultados'), 'slds-is-close');
		}
	},

	inputBuscarColabBlur: function(component) {
		window.setTimeout($A.getCallback(() => {
			if (component.find('grupoResultados') != null) {
				$A.util.addClass(component.find('grupoResultados'), 'slds-is-close');
				$A.util.removeClass(component.find('grupoResultados'), 'slds-is-open');
			}
		}), 200);
	},

	inputBuscarPlantillaColabFocus: function(component) {
		if (component.find('inputBuscarPlantillaColab').get('v.value')) {
			$A.util.addClass(component.find('plantillaResultados'), 'slds-is-open');
			$A.util.removeClass(component.find('plantillaResultados'), 'slds-is-close');
		}
	},

	inputBuscarPlantillaColabBlur: function(component) {
		window.setTimeout($A.getCallback(() => {
			if (component.find('plantillaResultados') != null) {
				$A.util.addClass(component.find('plantillaResultados'), 'slds-is-close');
				$A.util.removeClass(component.find('plantillaResultados'), 'slds-is-open');
			}
		}), 200);
	},

	casoCerrar: function(component, event, helper) {
		component.set('v.caso.Status', 'Cerrado');
		component.find('caseData').saveRecord($A.getCallback(saveResult => {
			if (saveResult.state === 'SUCCESS') {
				helper.mostrarToast('success', 'Se cerró el Caso', 'Se cerró correctamente el Caso ' + component.get('v.caso.CaseNumber'));
			} else if (saveResult.state === 'ERROR') {
				helper.mostrarToast('error', 'No se cerró Caso', JSON.stringify(saveResult.error));
			}
		}));
	},

	casoReactivar: function(component, event, helper) {
		component.set('v.caso.Status', 'Activo');
		component.find('caseData').saveRecord($A.getCallback(saveResult => {
			if (saveResult.state === 'SUCCESS') {
				helper.mostrarToast('success', 'Se reactivó el Caso', 'Se reactivó correctamente el Caso ' + component.get('v.caso.CaseNumber'));
			} else if (saveResult.state === 'ERROR') {
				helper.mostrarToast('error', 'No se reactivó Caso', JSON.stringify(saveResult.error));
			}
		}));
	}

});