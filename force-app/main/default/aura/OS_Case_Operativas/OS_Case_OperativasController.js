({
	onRender: function(component) {
		//Para evitar referencias a popovers de pestañas sin foco, se les da un id único
		if (!component.get('v.primerRenderizadoFinalizado')) {
			document.getElementById('popoverOtrasOperativas').id = 'popoverOtrasOperativas' + component.get('v.recordId');
			component.set('v.primerRenderizadoFinalizado', true);
		}
	},

	init: function(component, event, helper) {
		//cargar la lista de emails
		helper.cargarListadoEmails(component, event);
		//component.set('v.defaultRows', []);
		//component.set('v.emailSeleccionado', '');
	},

	recordDataUpdated: function(component, event) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			//Se actualiza el atributo esPropietario para habilitar/deshabilitar el botón de guardado
			component.set('v.esPropietario', $A.get('$SObjectType.CurrentUser.Id') === component.get('v.caso.OwnerId'));

			if (event.getParams().changeType === 'CHANGED') {
				component.find('caseData').reloadRecord();
			}
		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.ldsError'));
		}
	},

	abrirOtrasOperativas: function(component) {
		window.clearTimeout(component.get('v.otrasOperativasTimeout'));
		document.getElementById('popoverOtrasOperativas' + component.get('v.recordId')).style.display = 'block';
	},

	cerrarOtrasOperativas: function(component) {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		let otrasOperativasTimeout = window.setTimeout(() => document.getElementById('popoverOtrasOperativas' + component.get('v.recordId')).style.display = 'none', 500);
		component.set('v.otrasOperativasTimeout', otrasOperativasTimeout);
	},

	iniciarOperativa: function(component, event, helper) {
		if (component.get('v.caso.CC_Canal_Procedencia__c') === 'Buzón Servicio Firma'
		|| component.get('v.caso.CC_Canal_Procedencia__c') === 'Teléfono Servicio Firma') {
			component.set('v.esBuzonFirma', false);
		}
		//Validación de campos requeridos
		let validarCamposCaso = component.get('c.validarCamposCaso');
		validarCamposCaso.setParams({
			'recordId': component.get('v.recordId'),
			'operativa': event.getSource().getLocalId()
		});
		validarCamposCaso.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let camposNoValidos = response.getReturnValue();
				if (camposNoValidos.length > 0) {
					//Validación de campos requeridos KO
					let mensaje = '';
					//Se comprueba si la clasificación está inactiva
					if (camposNoValidos.indexOf('Clasificación inactiva') > -1) {
						//Si lo está se prepara el mensaje y se quita el elemento del
						//array para que no salga en la lista de campos no informados.
						mensaje = 'El caso está vinculado con una clasificación que ya no está activa. ';
						camposNoValidos.splice(camposNoValidos.indexOf('Clasificación inactiva'), 1);
					}
					if (camposNoValidos.length > 0) {
						//El resto de elementos son campos obligatorios actualmente nulos
						mensaje += 'Debe informar los siguientes campos obligatorios: ' + camposNoValidos.join(', ') + '.';
					}
					if (mensaje !== '') {
						helper.mostrarToast('error', 'Operativa no disponible', mensaje);
					}
				} else {
					//Lanzar operativa
					switch (event.getSource().getLocalId()) {
						case 'Trasladar Colaborador':
							component.set('v.tipoOperativa', 'trasladar');
							$A.enqueueAction(component.get('c.modalColabAbrir'));
							break;
						case 'Remitir Colaborador':
							component.set('v.tipoOperativa', 'remitir');
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
						case 'botonNotificacionPush':
							component.set('v.tipoOperativa', 'enviarNotificacion');
							$A.enqueueAction(component.get('c.abrirModalEnviarNotificacion'));
							break;
						case 'botonProgramarAlerta':
							component.set('v.tipoOperativa', 'programarAlerta');
							$A.enqueueAction(component.get('c.modalProgramarAlertaAbrir'));
							break;
						case 'botonDesprogramarAlerta':
							component.set('v.tipoOperativa', 'desprogramarAlerta');
							$A.enqueueAction(component.get('c.modalProgramarAlertaAbrir'));
							break;
						case 'botonDuplicar':
							component.set('v.tipoOperativa', 'duplicarCaso');
							$A.enqueueAction(component.get('c.modalDuplicarAbrir'));
							break;

					}
				}
			}
		});
		$A.enqueueAction(validarCamposCaso);
	},

	iniciarOperativaMenuColaborador: function(component, event, helper) {
		if (event.getParam('value') === 'remitir') {
			//Validación de campos requeridos
			let validarCamposCaso = component.get('c.validarCamposCaso');
			validarCamposCaso.setParams({
				'recordId': component.get('v.recordId')

			});
			validarCamposCaso.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let camposNoValidos = response.getReturnValue();
					if (camposNoValidos.length > 0) {
						//Validación de campos requeridos KsssO
						let mensaje = '';
						//Se comprueba si la clasificación está inactiva
						if (camposNoValidos.indexOf('Clasificación inactiva') > -1) {
							//Si lo está se prepara el mensaje y se quita el elemento del
							//array para que no salga en la lista de campos no informados.
							mensaje = 'El caso está vinculado con una clasificación que ya no está activa. ';
							camposNoValidos.splice(camposNoValidos.indexOf('Clasificación inactiva'), 1);
						}
						if (camposNoValidos.length > 0) {
							//El resto de elementos son campos obligatorios actualmente nulos
							mensaje += 'Debe informar los siguientes campos obligatorios: ' + camposNoValidos.join(', ') + '.';
						}
						if (mensaje !== '') {
							helper.mostrarToast('error', 'Operativa no disponible', mensaje);
						}
					} else {
						//Lanzar operativa
						component.set('v.tipoOperativa', 'remitir');
						$A.enqueueAction(component.get('c.modalColabAbrir'));
					}
				}
			});
			$A.enqueueAction(validarCamposCaso);
		}
	},

	seleccionarResultadoGrupo: function(component, event) {
		component.set('v.grupoSeleccionado', event.getParam('accountByEvent'));
		$A.enqueueAction(component.get('c.obtenerPlantillasGrupo'));

		let lookupPill = component.find('pillGrupoSeleccionado');
		$A.util.addClass(lookupPill, 'slds-show');
		$A.util.removeClass(lookupPill, 'slds-hide');

		let searchRes = component.find('grupoResultados');
		//$A.util.addClass(searchRes, 'slds-is-close');
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
		//$A.util.addClass(plantillaResultados, 'slds-is-close');
		$A.util.removeClass(plantillaResultados, 'slds-is-open');

		let plantillaResultadosResponder = component.find('plantillaResultadosResponder');
		//$A.util.addClass(plantillaResultadosResponder, 'slds-is-close');
		$A.util.removeClass(plantillaResultadosResponder, 'slds-is-open');

		let lookupFieldPlantilla = component.find('lookupFieldPlantilla');
		$A.util.addClass(lookupFieldPlantilla, 'slds-hide');
		$A.util.removeClass(lookupFieldPlantilla, 'slds-show');

		let lookupFieldPlantillaResponder = component.find('lookupFieldPlantillaResponder');
		$A.util.addClass(lookupFieldPlantillaResponder, 'slds-hide');
		$A.util.removeClass(lookupFieldPlantillaResponder, 'slds-show');
	},

	//OPERATIVAS DEL FUSIONAR

	abrirModalAsociarCaso: function(component) {
		let getCaso = component.get('c.getCaso');
		getCaso.setParams({'recordId': component.get('v.recordId')});
		getCaso.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let retorno = response.getReturnValue();
				component.set('v.CC_ContactoRelacionado', retorno.CASO.CC_ContactoRelacionado__c);
				component.set('v.CaseNumber', retorno.CASO.CaseNumber);
				component.set('v.bHabilitado', retorno.HABILITADO);
				component.set('v.bMensaje', retorno.MENSAJE);
				component.set('v.oCasosContacto', retorno.CASOSCONTACTO);
				component.set('v.oCasosAsunto', retorno.CASOSASUNTO);
				component.set('v.Asunto', retorno.CASO.Subject);



				component.find('CC_ContactoRelacionado').set('v.value', retorno.CASO.CC_ContactoRelacionado__c);
				component.find('Asunto').set('v.value', retorno.CASO.Subject);


				$A.enqueueAction(component.get('c.contactoSelect'));
			}
		});
		$A.enqueueAction(getCaso);
		component.set('v.oColumnas', [
			{label: 'Caso', fieldName: 'CaseNumber', initialWidth: 85, type: 'text'},
			{label: 'Título', fieldName: 'Subject', type: 'text', initialWidth: 360},
			{label: 'Fecha creación', fieldName: 'CreatedDate', initialWidth: 140, type: 'date'},
			{label: 'Estado', fieldName: 'Status', initialWidth: 110, type: 'text'},
			{label: 'Ver', type: 'button', initialWidth: 75, typeAttributes:
            {label: {fieldName: 'vercasoLabel'}, title: 'Visualizar', name: 'view_case', iconName: 'utility:preview', disabled: {fieldName: 'actionDisabled'}, class: 'btn_next'}}]);

		component.set('v.oColumnasCasosSeleccionados', [
			{label: 'Caso', fieldName: 'CaseNumber', type: 'text'},
			{label: 'Título', fieldName: 'Subject', type: 'text'},
			{label: 'Ver', type: 'button', initialWidth: 75, typeAttributes:
				{label: {fieldName: 'vercasoLabel'}, title: 'Visualizar', name: 'ver', iconName: 'utility:preview', disabled: {fieldName: 'actionDisabled'}, class: 'btn_next'}},
			{label: 'Eliminar', type: 'button', typeAttributes:
				{label: {fieldName: 'eliminarcasoLabel'}, title: 'Eliminar', name: 'delete_case', iconName: 'utility:close', disabled: {fieldName: 'actionDisabled'}, class: 'btn_next'}}]);

		component.set('v.currentSelectedRows', []);
		component.set('v.casosSeleccionados', []);
		component.set('v.CasesNumber', '');		component.set('v.renderModalFusionar', true);
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		$A.util.addClass(component.find('modalAsociarCaso'), 'slds-fade-in-open');
	},

	verCaso: function(component, event, helper) {
		let idCaso = component.find('CC_CasoRelacionado').get('v.value');
		helper.verCaso(idCaso);
	},

	abrirModalConfirmacion: function(component) {
		$A.util.addClass(component.find('modalConfirmacion'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdropConfirmacion'), 'slds-backdrop_open');
	},

	asociarCaso: function(component, event, helper) {
		helper.asociarCaso(component);
		$A.util.removeClass(component.find('modalConfirmacion'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdropConfirmacion'), 'slds-backdrop_open');
	},

	cancelModal: function(component) {
		$A.util.removeClass(component.find('modalConfirmacion'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdropConfirmacion'), 'slds-backdrop_open');
	},

	finCargando: function(component) {
		component.set('v.cargando', false);
	},

	confirmarAsociacion: function() {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': 'Actualizado!', 'message': 'Asociado al caso satisfactoriamente.', 'type': 'success'});
		toastEvent.fire();
	},

	errorAsociacion: function(mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': 'Error', 'message': mensaje, 'type': 'error'});
		toastEvent.fire();
	},
	cerrarModalAsociarCaso: function(component) {
		$A.util.removeClass(component.find('modalAsociarCaso'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.renderModalFusionar', false);
	},

	modalAsociarCasoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalAsociarCaso'));
		}
	},

	//A PARTIR DEL CONTACTO
	handleRowAction: function(component, event, helper) {
		switch (event.getParam('action').name) {
			case 'view_case':
				helper.verCaso(event.getParam('row').Id);
				break;
			case 'delete_case':
				helper.eliminarCaso(component, event);
				break;
			case 'ver':
				helper.verCaso(event.getParam('row').Id);
				break;
		}
	},

	contactoSelect: function(component) {
		let getCasosContacto = component.get('c.getCasosContacto');
		getCasosContacto.setParams({
			'contactId': component.find('CC_ContactoRelacionado').get('v.value'),
			'recordId': component.get('v.recordId') + ''
		});
		getCasosContacto.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.oCasosContacto', response.getReturnValue());
			}
		});
		$A.enqueueAction(getCasosContacto);
	},

	selectedRows: function(component, event) {
		let selectedRows = event.getParam('selectedRows');
		let currentSelectedRows = component.get('v.currentSelectedRows');
		let numeroCasos = '';

		selectedRows.forEach(selectedRow => {
			if (!currentSelectedRows.includes(selectedRow.Id)) {
				currentSelectedRows.push(selectedRow.Id);
			}
			numeroCasos = numeroCasos + selectedRow.CaseNumber + ', ';
		});
		numeroCasos = numeroCasos.substring(0, numeroCasos.length - 2);

		component.set('v.currentSelectedRows', currentSelectedRows);
		component.set('v.CasesNumber', '(' + numeroCasos + ')');

	},
	/*
	selectedRowsAdjuntos: function(component, event) {
		let selectedRows = event.getParam('selectedRows');
		let currentSelectedRows = component.get('v.currentSelectedAttachments');
		let numeroAdjuntos = '';

		selectedRows.forEach(selectedRow => {
			if (!currentSelectedRows.includes(selectedRow.Id)) {
				currentSelectedRows.push(selectedRow.Id);
			}
			numeroAdjuntos = numeroAdjuntos + selectedRow.CaseNumber + ', ';
		});
		numeroAdjuntos = numeroAdjuntos.substring(0, numeroAdjuntos.length - 2);

		component.set('v.currentSelectedRows', currentSelectedRows);
		component.set('v.CasesNumber', '(' + numeroAdjuntos + ')');

	},
*/
	//TODOS LOS CASOS

	inicializarCasosSeleccionados: function(component) {
		component.set('v.currentSelectedRows', []);
		component.set('v.casosSeleccionados', []);
		component.set('v.CasesNumber', '');

	},

	casoSelect: function(component, event) {
		component.set('v.vcaso', String(event.getParam('value')));
	},

	seleccionarCaso: function(component) {
		let casoId = component.get('v.newCaseNumber');
		let mostrarCasos = component.get('v.casosSeleccionados');
		let casosSeleccionados = component.get('v.currentSelectedRows');

		let numeroCasos = '';
		let addCaso = true;

		mostrarCasos.forEach(c => {
			if (c.Id === casoId) {
				addCaso = false;
			}
		});
		if (addCaso) {
			casosSeleccionados.push(casoId);
			component.set('v.currentSelectedRows', casosSeleccionados);

			let getCaso = component.get('c.getCaso');
			getCaso.setParams({'recordId': casoId});
			getCaso.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let retorno = response.getReturnValue();
					mostrarCasos.push(retorno.CASO);
					mostrarCasos.forEach(c => {
						numeroCasos = numeroCasos + String(c.CaseNumber) + ', ';
					});
					numeroCasos = numeroCasos.substring(0, numeroCasos.length - 2);
					component.set('v.CasesNumber', '(' + numeroCasos + ')');
					component.set('v.casosSeleccionados', mostrarCasos);
				}
			});
			$A.enqueueAction(getCaso);
		}
		component.set('v.newCaseNumber', '');
		component.find('botonSeleccionar').set('v.disabled', true);
	},



	//A PARTIR DEL ASUNTO

	iniciarAsunto: function(component) {
		component.set('v.currentSelectedRows', []);
		component.set('v.casosSeleccionados', []);
		component.set('v.CasesNumber', '');

		component.set('v.oColumnasAsunto', [
			{label: 'Asunto', fieldName: 'Subject', type: 'text', initialWidth: 360},
			{label: 'Caso', fieldName: 'CaseNumber', initialWidth: 85, type: 'text'},
			{label: 'Fecha creación', fieldName: 'CreatedDate', initialWidth: 140, type: 'date'},
			{label: 'Estado', fieldName: 'Status', initialWidth: 110, type: 'text'},
			{label: 'Ver', type: 'button', initialWidth: 75, typeAttributes:
            {label: {fieldName: 'vercasoLabel'}, title: 'Visualizar', name: 'view_case', iconName: 'utility:preview', disabled: {fieldName: 'actionDisabled'}, class: 'btn_next'}}]);

	},


	asuntoSelect: function(component) {
		let getCasosAsunto = component.get('c.getCasosAsunto');
		getCasosAsunto.setParams({
			'Asunto': component.find('Asunto').get('v.value'),
			'recordId': component.get('v.recordId') + ''
		});
		getCasosAsunto.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.oCasosAsunto', response.getReturnValue());
			}
		});
		$A.enqueueAction(getCasosAsunto);
	},

	//Metodos Lista de correos Electronicos
	handleSort: function(component, event, helper) {
		component.set('v.sortedBy', event.getParam('fieldName'));
		component.set('v.sortDirection', event.getParam('sortDirection'));
		helper.cargarListadoEmails(component);
	},

	handleRowSelection: function(component, event) {
		let selectedRows = event.getParam('selectedRows');
		let emailSeleccionado = '';
		selectedRows.forEach(selectedRow => {
			emailSeleccionado = selectedRow.id;
		});
		component.set('v.emailSeleccionado', emailSeleccionado);
	},

	modalColabAbrir: function(component, event, helper) {
		component.set('v.procesando', false);
		component.set('v.renderModalColab', true);
		component.set('v.verTodosLosGrupos', false);
		component.set('v.gruposClasificacionOptions', null);
		component.set('v.gruposClasificacionValue', null);
		component.set('v.literalBusquedaGrupo', null);
		component.set('v.grupoSeleccionado', null);
		component.set('v.literalBusquedaGrupo', null);
		component.set('v.verTodasLasPlantillas', false);
		component.set('v.plantillasGrupoOptions', null);
		component.set('v.plantillasGrupoValue', null);
		component.set('v.literalBusquedaPlantilla', '');
		component.set('v.plantillaSeleccionadaColab', null);
		component.set('v.plantillaSeleccionadaValue', null);
		component.set('v.plantillaSeleccionadaName', null);

		helper.getGruposClasificacion(component);
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
			//$A.util.removeClass(grupoResultados, 'slds-is-close');
			helper.getGruposBusqueda(component);
		} else {
			//$A.util.addClass(grupoResultados, 'slds-is-close');
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

				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout($A.getCallback(() => component.find('plantillaSeleccionada').focus()), 100);
			}
		});
		$A.enqueueAction(getPlantillaGrupoList);
	},

	trasladarColaborador: function(component) {
		component.set('v.procesando', true);

		//if (component.get('v.caso.CC_Canal_Procedencia__c') === 'Buzón Servicio Firma' || component.get('v.caso.CC_Canal_Procedencia__c') === 'Teléfono Servicio Firma') {
		//}

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
			'cerradoOperativa': false,
			'emailSeleccionado': component.get('v.emailSeleccionado'),
			'tipoRespuesta': component.get('v.tipoRespuesta')
		});
		prepararCaso.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
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
						let args = {
							'actionName': 'Case.OS_Enviar_Correo',
							'targetFields': {
								'ToAddress': {'value': destinatariosPara},
								'CcAddress': {'value': destinatariosEnCopia},
								'CC_Grupo_Colab__c': {'value': nombreGrupoColaborador},
								'CC_Procedencia__c': {'value': 'Traslado Colaborador'},
								'BccAddress': {'value': ''}
							}
						};
						component.find('quickActionAPI').setActionFieldValues(args);
						$A.enqueueAction(component.get('c.modalColabCerrar'));
						$A.get('e.force:refreshView').fire();
					}
				});
				$A.enqueueAction(buscarColaborador);
			}
		});
		$A.enqueueAction(prepararCaso);
	},

	remitirColaborador: function(component) {
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
			'cerradoOperativa': false,
			'emailSeleccionado': component.get('v.emailSeleccionado'),
			'tipoRespuesta': component.get('v.tipoRespuesta')
		});
		prepararCaso.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
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
						let args = {
							'actionName': 'Case.OS_Enviar_Correo',
							'targetFields': {
								'ToAddress': {'value': destinatariosPara},
								'CcAddress': {'value': destinatariosEnCopia},
								'CC_Grupo_Colab__c': {'value': nombreGrupoColaborador},
								'CC_Procedencia__c': {'value': 'Remitir Colaborador'},
								'BccAddress': {'value': ''}
							}
						};
						component.find('quickActionAPI').setActionFieldValues(args);
						$A.enqueueAction(component.get('c.modalColabCerrar'));
						$A.get('e.force:refreshView').fire();
					}
				});
				$A.enqueueAction(buscarColaborador);
			}
		});
		$A.enqueueAction(prepararCaso);
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
		component.set('v.plantillaSeleccionadaValue', null);
		component.set('v.plantillaSeleccionadaName', '');
		component.set('v.optionsPlantillaSolicitud', null);
		component.set('v.carpetaIdioma', '');
		component.set('v.opcionesIdiomaCarpeta', null);
		component.set('v.opcionesTratamientoCarpeta', null);
		component.set('v.carpetaFinal', null);
		component.set('v.tipoOperativa', '');

		$A.util.removeClass(component.find('ModalboxSolicitarInfo'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.renderModalSolInfo', false);
	},

	solicitarInfo: function(component) {
		component.set('v.procesando', true);
		let prepararCaso = component.get('c.prepararCaso');
		prepararCaso.setParams({
			'idCaso': component.get('v.recordId'),
			'plantilla': component.get('v.plantillaSeleccionadaValue'),
			'informarReferenciaCorreo': true,
			'operativa': component.get('v.tipoOperativa'),
			'cerradoOperativa': false,
			'emailSeleccionado': component.get('v.emailSeleccionado'),
			'tipoRespuesta': component.get('v.tipoRespuesta')
		});
		prepararCaso.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let correoCaso = component.get('c.correoCaso');
				correoCaso.setParam('idCaso', component.get('v.recordId'));
				correoCaso.setCallback(this, responseCorreoCaso => {
					if (responseCorreoCaso.getState() === 'SUCCESS') {

						let destinatariosPara = [];
						responseCorreoCaso.getReturnValue().Para.forEach(element => destinatariosPara.push(element));
						let destinatariosCc = [];
						responseCorreoCaso.getReturnValue().Cc.forEach(element => destinatariosCc.push(element));

						let actionAPI = component.find('quickActionAPI');
						let args = {
							'actionName': 'Case.OS_Enviar_Correo',
							'targetFields': {
								'CC_Procedencia__c': {'value': 'Solicitud Información'},
								'ToAddress': {'value': destinatariosPara},
								'CcAddress': {'value': destinatariosCc},
								'BccAddress': {'value': ''}
							}
						};
						actionAPI.setActionFieldValues(args);

						//Cierre del modal
						$A.enqueueAction(component.get('c.cerrarModalSolicitarInfo'));
						$A.get('e.force:refreshView').fire();
					}
				});
				$A.enqueueAction(correoCaso);
			}
		});
		$A.enqueueAction(prepararCaso);
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
							//eslint-disable-next-line @lwc/lwc/no-async-operation
							window.setTimeout($A.getCallback(() => component.find('selectItemPlantillaSol').focus()), 100);
						} else {
							component.find('selectItemPlantilla').set('v.value', null);
							//eslint-disable-next-line @lwc/lwc/no-async-operation
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
		component.set('v.optionsPlantillaResponder', []);
		component.set('v.opcionesIdiomaCarpeta', []);
		component.set('v.opcionesTratamientoCarpeta', []);
		component.set('v.idiomaPlantilla', null);
		component.set('v.tratamiento', null);
		//component.find('selectItemPlantilla').set('v.value', null);
		component.set('v.selectItemPlantillaValue', null);
		component.set('v.listOfSearchRecordsPlantilla', []);
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
		//component.set('v.renderModalResponder', false);
		//component.set('v.verTodasLasPlantillas', false);
	},

	modalResponderClienteTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalResponderCliente'));
		}
	},

	responderCliente: function(component) {
		component.set('v.procesando', true);
		let plantilla = '';
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
			'cerradoOperativa': component.find('responderCerrar').get('v.checked'),
			'emailSeleccionado': component.get('v.emailSeleccionado'),
			'tipoRespuesta': component.get('v.tipoRespuesta')
		});
		prepararCaso.setCallback(this, responsePrepararCaso => {
			if (responsePrepararCaso.getState() === 'SUCCESS') {
				let correoCaso = component.get('c.correoCaso');
				correoCaso.setParam('idCaso', component.get('v.recordId'));
				correoCaso.setCallback(this, responseCorreoCaso => {
					if (responseCorreoCaso.getState() === 'SUCCESS') {

						let destinatariosPara = [];
						responseCorreoCaso.getReturnValue().Para.forEach(element => destinatariosPara.push(element));
						let destinatariosCc = [];
						responseCorreoCaso.getReturnValue().Cc.forEach(element => destinatariosCc.push(element));

						let actionAPI = component.find('quickActionAPI');
						let args = {
							'actionName': 'Case.OS_Enviar_Correo',
							'targetFields': {
								'CC_Procedencia__c': {'value': 'Responder Cliente'},
								'ToAddress': {'value': destinatariosPara},
								'CcAddress': {'value': destinatariosCc},
								'BccAddress': {'value': ''}
								//'AttachmentId': {'value': '0691j000002bNH7AAM'}
							}
						};
						actionAPI.setActionFieldValues(args);

						/*let actualizarCerrado = component.get('c.actualizarCampoCerradoOperativa');
						actualizarCerrado.setParams({
							'idCaso': component.get('v.recordId'),
							'cerradoOperativa': component.find('responderCerrar').get('v.checked'),
						});
						$A.enqueueAction(actualizarCerrado);*/
						//Cierre del modal
						$A.enqueueAction(component.get('c.cerrarModalResponderCliente'));
						$A.get('e.force:refreshView').fire();

					}
				});
				$A.enqueueAction(correoCaso);
			}
		});
		$A.enqueueAction(prepararCaso);
	},

	teclaPulsadaLookupPlantilla: function(component, event, helper) {
		let panelResultados;
		if (event.getSource().getLocalId() === 'inputBuscarPlantillaResponder') {
			panelResultados = component.find('plantillaResultadosResponder');
		} else {
			panelResultados = component.find('plantillaResultados');
		}

		//if (component.get('v.literalBusquedaPlantilla').length) {
		if (event.getSource().get('v.value')) {
			//$A.util.removeClass(panelResultados, 'slds-is-close');
			helper.buscarPlantillas(component);
			$A.util.addClass(panelResultados, 'slds-is-open');
		} else {
			//$A.util.addClass(panelResultados, 'slds-is-close');
			$A.util.removeClass(panelResultados, 'slds-is-open');
			component.set('v.listOfSearchRecordsPlantilla', []);
		}
	},

	seleccionarOpcionPlantilla: function(component, event, helper) {
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
			helper.modalidadMostrarAdjuntos(component);

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

		component.set('v.literalBusquedaPlantilla', '');
		component.set('v.listOfSearchRecordsPlantilla', null);
		component.set('v.plantillaSeleccionadaColab', null);
	},

	abrirModalEnviarNotificacion: function(component) {
		component.set('v.renderModalNotificacion', true);
		let telefono = component.get('v.caso.OS_Telefono__c');
		if (!telefono) {
			telefono = component.get('v.caso.Contact.Phone');
		}
		component.find('inputEnviarNotificacionDestinatario').set('v.value', telefono);

		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		$A.util.addClass(component.find('modalboxEnviarNotificacion'), 'slds-fade-in-open');

		//Cargar carpetas de idioma
		let subdirectoriosOperativas = component.get('c.subdirectorios');
		subdirectoriosOperativas.setParams({'rutaDevName': 'OS_Notificacion'});
		subdirectoriosOperativas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let listaEnviarNotificacionIdiomas = [];
				let retorno = response.getReturnValue();
				retorno.forEach(element => listaEnviarNotificacionIdiomas.push({'value': element.DeveloperName, 'label': element.Name}));
				component.set('v.enviarNotificacionIdiomas', listaEnviarNotificacionIdiomas);
				let idioma = component.get('v.caso.CC_Idioma__c');
				if (idioma === 'ca') {
					idioma = 'OS_Notificacion_Catalan';
				} else if (idioma === 'en') {
					idioma = 'OS_Notificacion_Ingles';
				} else {
					idioma = 'OS_Notificacion_Castellano';
				}
				component.set('v.enviarNotificacionIdioma', idioma);
				$A.enqueueAction(component.get('c.seleccionaEnviarNotificacionIdioma'));
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout($A.getCallback(() => component.find('inputEnviarNotificacionPlantilla').focus()), 1);
			}
		});
		$A.enqueueAction(subdirectoriosOperativas);
		$A.enqueueAction(component.get('c.actualizarEnviarNotificacionCaracteresRestantes'));
	},

	modalEnviarNotificacionTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalEnviarNotificacion'));
		}
	},

	cerrarModalEnviarNotificacion: function(component) {
		//Se vacía el contenido del destinatario y del mensaje
		component.find('inputEnviarNotificacionDestinatario').set('v.value', '');
		component.find('inputEnviarNotificacionPlantilla').set('v.value', '');
		component.find('inputEnviarNotificacionContenido').set('v.value', '');

		$A.util.removeClass(component.find('modalboxEnviarNotificacion'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.renderModalNotificacion', false);
	},

	seleccionaEnviarNotificacionIdioma: function(component) {
		let plantillas = component.get('c.plantillas');
		plantillas.setParams({'rutaDevName': component.find('inputEnviarNotificacionIdioma').get('v.value')});
		plantillas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let listaPlantillas = [];
				let retorno = response.getReturnValue();
				retorno.forEach(element => listaPlantillas.push({'value': element.DeveloperName, 'label': element.Name}));
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
			$A.util.addClass(component.find('divEnviarNotificacionCaracteresRestantes'), 'os-rojo');
		} else {
			$A.util.removeClass(component.find('divEnviarNotificacionCaracteresRestantes'), 'os-rojo');
		}
	},

	enviarNotificacion: function(component, event, helper) {
		//Validación de campos obligatorios
		let valoresOK = true;

		let campoDestinatario = component.find('inputEnviarNotificacionDestinatario');
		if (!campoDestinatario.checkValidity()) {
			campoDestinatario.reportValidity();
			valoresOK = false;
		}

		let campoContenido = component.find('inputEnviarNotificacionContenido');
		if (!campoContenido.checkValidity()) {
			campoContenido.reportValidity();
			valoresOK = false;
		}

		if (valoresOK) {
			//Se inhabilita el botón hasta recibir la respuesta
			event.getSource().set('v.disabled', true);
			let enviarSMS = component.get('c.enviarNotificacinPushSMS');
			enviarSMS.setParams({
				'sObjectId': component.get('v.recordId'),
				'destinatario': campoDestinatario.get('v.value'),
				'texto': campoContenido.get('v.value')
			});
			enviarSMS.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let resultado = response.getReturnValue();
					if (resultado === 'OK') {
						helper.mostrarToast('success', 'Se envió la notificación', 'Se envió correctamente la notificación/SMS al destinatario ' + campoDestinatario.get('v.value'));
						$A.enqueueAction(component.get('c.cerrarModalEnviarNotificacion'));
						$A.get('e.force:refreshView').fire();
					} else {
						helper.mostrarToast('error', 'No se pudo enviar la notificación', resultado);
					}
				}
				//Se vuelve a habilitar el botón
				event.getSource().set('v.disabled', false);
			});
			$A.enqueueAction(enviarSMS);
		}
	},

	tomarPropiedad: function(component, event, helper) {
		component.set('v.caso.OwnerId', $A.get('$SObjectType.CurrentUser.Id'));
		component.find('caseData').saveRecord($A.getCallback(saveResult => {
			if (saveResult.state === 'SUCCESS') {
				helper.mostrarToast('success', 'Se reasignó Caso', 'Ahora es el propietario del caso ' + component.get('v.caso.CaseNumber'));
			} else if (saveResult.state === 'ERROR') {
				console.error(saveResult);
				helper.mostrarToast('error', 'No se reasignó Caso', JSON.stringify(saveResult.error[0].message));
			}
		}));
	},

	modalProgramarAlertaAbrir: function(component) {
		component.set('v.renderModalProgramarAlerta', true);

		if (component.get('v.tipoOperativa') === 'programarAlerta') {
			//Programar alerta
			component.find('OS_Alerta_Fecha__c').set('v.value', null);
			component.find('OS_Alerta_Descripcion__c').set('v.value', null);
			component.find('OS_Alerta_Nuevo_Propietario__c').set('v.value', $A.get('$SObjectType.CurrentUser.Id'));

			//Retraso de apertura del modal para evitar abrirlo mientas la recordEditForm aún carga
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => {
				$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
				$A.util.addClass(component.find('modalProgramarAlerta'), 'slds-fade-in-open');
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout($A.getCallback(() => component.find('programarAlertaBotonProgramar').focus()), 10);
			}), 460);

		} else if (component.get('v.tipoOperativa') === 'desprogramarAlerta') {
			//Desprogramar alerta
			$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
			$A.util.addClass(component.find('modalProgramarAlerta'), 'slds-fade-in-open');
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => component.find('programarAlertaBotonDesprogramar').focus()), 10);
		}
	},

	modalProgramarAlertaTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalProgramarAlertaCerrar'));
		}
	},

	botonProgramarAlerta: function(component, event, helper) {
		if (component.find('OS_Alerta_Fecha__c').get('v.value') == null
		|| !component.find('OS_Alerta_Nuevo_Propietario__c').get('v.value')) {
			helper.mostrarToast('error', '', 'Debe indicar una fecha y un propietario.');
		} else {
			let fechaAlerta = new Date(component.find('OS_Alerta_Fecha__c').get('v.value'));
			let fechaActual = new Date();

			if (fechaAlerta > fechaActual) {
				component.find('programarAlertaBotonProgramar').set('v.disabled', true);
				component.find('estado').set('v.value', 'Pendiente Alerta');
				component.find('recordEditFormProgramarAlerta').submit();
			} else {
				helper.mostrarToast('error', '', 'No se puede programar una alerta para una fecha anterior a la actual.');
			}
		}
	},

	botonDesprogramarAlerta: function(component, event, helper) {
		component.find('programarAlertaBotonDesprogramar').set('v.disabled', true);
		let fechaHora = component.get('v.caso.OS_Alerta_Fecha__c');
		let desprogramar = component.get('c.desprogramarAlerta');
		desprogramar.setParams({'caseId': component.get('v.recordId'), 'fechaHora': fechaHora});
		desprogramar.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				helper.mostrarToast(
					'success',
					'Se desprogramó Alerta',
					'Se ha desprogramado la alerta para el día ' + $A.localizationService.formatDate(component.get('v.caso.OS_Alerta_Fecha__c'), 'dd/MM/yyyy HH:mm')
				);
				component.set('v.caso.Status', 'Activo');
				component.set('v.caso.OS_Alerta_Fecha__c', null);
				component.set('v.caso.OS_Alerta_Nuevo_Propietario__c', null);
				component.set('v.caso.OS_Alerta_Descripcion__c', null);
				//component.find('caseData').saveRecord($A.getCallback(() => {}));
				component.find('caseData').saveRecord();
				$A.get('e.force:refreshView').fire();
				$A.enqueueAction(component.get('c.modalProgramarAlertaCerrar'));
			}
		});
		$A.enqueueAction(desprogramar);
	},

	programarOnSuccess: function(component, event, helper) {
		let fechaHora = component.find('OS_Alerta_Fecha__c').get('v.value');

		let programar = component.get('c.programarAlerta');
		programar.setParams({
			'caseId': component.get('v.recordId'),
			'fechaHora': fechaHora,
			'ownerId': component.find('OS_Alerta_Nuevo_Propietario__c').get('v.value'),
			'descripcion': component.find('OS_Alerta_Descripcion__c').get('v.value')
		});
		programar.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				helper.mostrarToast('success', 'Se programó la alerta', 'Se ha programado una alerta con fecha ' + $A.localizationService.formatDate(fechaHora, 'dd/MM/yyyy HH:mm') + '.');
				/*component.set('v.caso.Status', 'Pendiente Alerta');
				component.find('caseData').saveRecord($A.getCallback(() => {}));
				$A.get('e.force:refreshView').fire();*/
				$A.enqueueAction(component.get('c.modalProgramarAlertaCerrar'));
			}
		});
		$A.enqueueAction(programar);
	},

	programarOnError: function(component, event, helper) {
		console.error('error recordeditform: ' + event.getParam('message'));
		console.error('error event: ' + JSON.stringify(event));
		helper.mostrarToast('error', 'El campo "Fecha alerta" debe estar informado.', event.getParam('detail'));
		component.find('programarAlertaBotonDesprogramar').set('v.disabled', false);

	},

	modalProgramarAlertaCerrar: function(component) {
		$A.util.removeClass(component.find('modalProgramarAlerta'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		if (component.get('v.tipoOperativa') === 'programarAlerta') {
			component.find('programarAlertaBotonProgramar').set('v.disabled', false);
		} else if (component.get('v.tipoOperativa') === 'desprogramarAlerta') {
			component.find('programarAlertaBotonDesprogramar').set('v.disabled', false);
		}
		component.set('v.renderModalProgramarAlerta', false);
	},

	inputBuscarPlantillaResponderFocus: function(component) {
		//if (component.get('v.verTodasLasPlantillas') && component.find('inputBuscarPlantillaResponder').get('v.value')) {
		if (component.get('v.verTodasLasPlantillas') && component.get('v.literalBusquedaPlantilla')) {
			$A.util.addClass(component.find('plantillaResultadosResponder'), 'slds-is-open');
			//$A.util.removeClass(component.find('plantillaResultadosResponder'), 'slds-is-close');
		}
	},

	inputBuscarPlantillaResponderBlur: function(component) {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => {
			if (component.find('plantillaResultadosResponder') != null) {
				//$A.util.addClass(component.find('plantillaResultadosResponder'), 'slds-is-close');
				$A.util.removeClass(component.find('plantillaResultadosResponder'), 'slds-is-open');
			}
		}), 200);
	},

	inputBuscarColabFocus: function(component) {
		if (component.find('inputBuscarColab').get('v.value')) {
			$A.util.addClass(component.find('grupoResultados'), 'slds-is-open');
			//$A.util.removeClass(component.find('grupoResultados'), 'slds-is-close');
		}
	},

	inputBuscarColabBlur: function(component) {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => {
			if (component.find('grupoResultados') != null) {
				//$A.util.addClass(component.find('grupoResultados'), 'slds-is-close');
				$A.util.removeClass(component.find('grupoResultados'), 'slds-is-open');
			}
		}), 200);
	},

	inputBuscarPlantillaColabFocus: function(component) {
		if (component.find('inputBuscarPlantillaColab').get('v.value')) {
			$A.util.addClass(component.find('plantillaResultados'), 'slds-is-open');
			//$A.util.removeClass(component.find('plantillaResultados'), 'slds-is-close');
		}
	},

	inputBuscarPlantillaColabBlur: function(component) {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => {
			if (component.find('plantillaResultados') != null) {
				//$A.util.addClass(component.find('plantillaResultados'), 'slds-is-close');
				$A.util.removeClass(component.find('plantillaResultados'), 'slds-is-open');
			}
		}), 200);
	},

	modalDuplicarAbrir: function(component) {
		component.set('v.renderModalDuplicar', true);
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		$A.util.addClass(component.find('modalDuplicar'), 'slds-fade-in-open');
		component.find('duplicarBotonDuplicar').focus();
	},

	botonDuplicar: function(component, event, helper) {
		component.find('duplicarBotonDuplicar').set('v.disabled', true);
		let duplicar = component.get('c.duplicarCaso');
		duplicar.setParam('caso', component.get('v.caso'));
		duplicar.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				helper.abrirTab(component, response.getReturnValue().Id);
				helper.mostrarToast('success', 'Caso duplicado', 'Se ha duplicado correctamente el caso.');
				$A.enqueueAction(component.get('c.modalDuplicarCerrar'));
			} else if (response.getState() === 'ERROR') {
				helper.mostrarToast('error', 'No se duplicó Caso', duplicar.getError()[0].message);
				component.find('duplicarBotonDuplicar').set('v.disabled', false);

			}
		});
		$A.enqueueAction(duplicar);
	},

	modalDuplicarCerrar: function(component) {
		$A.util.removeClass(component.find('modalDuplicar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.renderModalDuplicar', false);
	},

	modalDuplicarTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalDuplicarCerrar'));
		}
	},

	botonVincularLlamada: function(component, event, helper) {
		let vincularLlamada = component.get('c.vincularLlamada');
		vincularLlamada.setParam('idCaso', component.get('v.recordId'));
		vincularLlamada.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				helper.mostrarToast('success', 'Se vinculó caso con llamada en curso', 'Se vinculó correctamente la llamada ' + response.getReturnValue() + ' al caso ' + component.get('v.caso.CaseNumber') + '.');
				$A.get('e.force:refreshView').fire();
			} else if (response.getState() === 'ERROR') {
				let errors = vincularLlamada.getError();
				if (errors) {
					let mensajeError = '';
					errors.forEach(error => mensajeError += error.message + '\n');
					helper.mostrarToast('info', 'No se vinculó el caso con la llamada', mensajeError);
				}
			}
		});
		$A.enqueueAction(vincularLlamada);
	},

	botonCambiarRecordType: function(component, event, helper) {
		component.find('botonCambiarRT').set('v.disabled', true);
		let cambiarRecordType = component.get('c.cambiarRecordType');
		cambiarRecordType.setParam('idCaso', component.get('v.recordId'));
		cambiarRecordType.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				$A.enqueueAction(component.get('c.modalCambiarRTCerrar'));
				helper.mostrarToast('success', response.getReturnValue(), '');
				helper.mostrarToast('success', 'Se cambió el tipo del caso', 'Se cambió el tipo del caso a "' + response.getReturnValue() + '"');
				$A.get('e.force:refreshView').fire();
			} else if (response.getState() === 'ERROR') {
				let errors = cambiarRecordType.getError();
				if (errors) {
					let mensajeError = '';
					errors.forEach(error => mensajeError += error.message + '\n');
					helper.mostrarToast('error', 'No se pudo cambiar el tipo del caso', mensajeError);
				}
			}
		});
		$A.enqueueAction(cambiarRecordType);
	},

	modalCambiarRTAbrir: function(component) {
		component.set('v.renderModalCambiarRT', true);
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		$A.util.addClass(component.find('modalCambiarRT'), 'slds-fade-in-open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('botonCambiarRT').focus()), 20);
	},

	modalCambiarRTCerrar: function(component) {
		$A.util.removeClass(component.find('modalCambiarRT'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		component.set('v.renderModalCambiarRT', false);
	},

	modalCambiarRTTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalCambiarRTCerrar'));
		}
	},

	finalidadSeleccionada: function(component) {
		if (component.find('tipoRespuesta').get('v.value')) {
			component.set('v.esBuzonFirma', true);
		} else {
			component.set('v.esBuzonFirma', false);
		}
		component.set('v.tipoRespuesta', component.find('tipoRespuesta').get('v.value'));
	}
});