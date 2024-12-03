({
	getGruposClasificacion: function(component) {
		let getGruposMCC = component.get('c.getGruposMCC');
		getGruposMCC.setParam('recordId', component.get('v.recordId'));
		getGruposMCC.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.gruposClasificacionOptions', response.getReturnValue());
			}
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => component.find('gruposClasificacion').focus()), 25);
		});
		$A.enqueueAction(getGruposMCC);
	},

	getGruposBusqueda: function(component) {
		let buscarGruposColaboradores = component.get('c.buscarGruposColaboradores');
		buscarGruposColaboradores.setParam('cadenaBusqueda', component.get('v.literalBusquedaGrupo'));
		buscarGruposColaboradores.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.listOfSearchRecords', response.getReturnValue());
			}
		});
		$A.enqueueAction(buscarGruposColaboradores);
	},

	loadCarpetasIdioma: function(component) {
		let operativa = component.get('v.tipoOperativa');
		let idioma = component.get('v.caso.CC_Idioma__c');
		let carpetaOperativa;
		if (operativa === 'responderCliente') {
			/*if (component.get('v.caso.RecordType.DeveloperName') === 'OS_Empleado') {
				carpetaOperativa = 'OS_Responder_Empleado';
			} else {
				carpetaOperativa = 'OS_Responder';
			}*/
			carpetaOperativa = 'OS_Responder';
		} else if (operativa === 'solicitar') {
			/*if (component.get('v.caso.RecordType.DeveloperName') === 'OS_Empleado') {
				carpetaOperativa = 'OS_Solicitar_Empleado';
			} else {
				carpetaOperativa = 'OS_Solicitar';
			}*/
			carpetaOperativa = 'OS_Solicitar';
		}

		let getCarpetasIdioma = component.get('c.getCarpetas');
		getCarpetasIdioma.setParam('carpetaDeveloperName', carpetaOperativa);
		getCarpetasIdioma.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let opcionesIdiomaFolder = [];
				let opciones = response.getReturnValue();
				opciones.forEach(opcion => opcionesIdiomaFolder.push({'value': opcion.DeveloperName, 'label': opcion.Name}));
				component.set('v.opcionesIdiomaCarpeta', opcionesIdiomaFolder);
				if (operativa === 'responderCliente') {
					component.set('v.idiomaPlantilla', 'OS_Responder_' + idioma);
				} else if (operativa === 'solicitar') {
					component.set('v.idiomaPlantilla', 'OS_Solicitar_' + idioma);
				}
				$A.enqueueAction(component.get('c.handleCarpetaIdiomaSeleccionada'));
			}
		});
		$A.enqueueAction(getCarpetasIdioma);
	},

	loadCarpetasTratamiento: function(component) {
		let opcionesTratamientoFolder = [];
		let getCarpetasTratamiento = component.get('c.getCarpetas');
		getCarpetasTratamiento.setParam('carpetaDeveloperName', component.get('v.idiomaPlantilla'));
		getCarpetasTratamiento.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let arr = response.getReturnValue();
				arr.forEach(element => opcionesTratamientoFolder.push({'value': element.DeveloperName, 'label': element.Name}));
				component.set('v.opcionesTratamientoCarpeta', opcionesTratamientoFolder);
				if (opcionesTratamientoFolder.length === 1) {
					//Se selecciona automáticamente el único tratamiento disponible para el idioma seleccionado
					if (component.get('v.tipoOperativa') === 'solicitar') {
						component.find('selectItemTratamientoSol').set('v.value', opcionesTratamientoFolder[0].value);
					} else if (component.get('v.tipoOperativa') === 'responderCliente') {
						component.find('selectItemTratamiento').set('v.value', opcionesTratamientoFolder[0].value);
					}
					$A.enqueueAction(component.get('c.handleCarpetaTratamientoSeleccionada'));
				} else {
					//Se pone en el foco en el campo de tratamiento del modal correspondiente
					if (component.get('v.tipoOperativa') === 'solicitar') {
						//eslint-disable-next-line @lwc/lwc/no-async-operation
						window.setTimeout($A.getCallback(() => component.find('selectItemTratamientoSol').focus()), 20);
					} else {
						//eslint-disable-next-line @lwc/lwc/no-async-operation
						window.setTimeout($A.getCallback(() => component.find('selectItemTratamiento').focus()), 20);
					}
				}
			}
		});
		$A.enqueueAction(getCarpetasTratamiento);
	},

	buscarPlantillas: function(component) {
		let buscarPlantillas = component.get('c.buscarPlantillas');
		buscarPlantillas.setParam('cadenaBusqueda', component.get('v.literalBusquedaPlantilla'));
		buscarPlantillas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.listOfSearchRecordsPlantilla', response.getReturnValue());
			}
		});
		$A.enqueueAction(buscarPlantillas);
	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissable', 'duration': 4000});
		toastEvent.fire();
	},

	abrirTab: function(component, tabRecordId) {
		component.find('workspace').openTab({'recordId': tabRecordId, 'focus': true});
		component.find('caseData').saveRecord($A.getCallback(() => {}));
	},

	verCaso: function(idCaso) {
		let navEvt = $A.get('e.force:navigateToSObject');
		navEvt.setParams({'recordId': idCaso});
		navEvt.fire();
	},

	eliminarCaso: function(component, event) {
		let casosSeleccionados = component.get('v.casosSeleccionados');
		let casoParaEliminar = event.getParam('row').Id;
		let nuevaListaCasos = [];
		let listaCasos = [];
		let numeroCasos = '';
		casosSeleccionados.forEach(caso => {
			if (caso.Id !== casoParaEliminar) {
				nuevaListaCasos.push(caso);
				listaCasos.push(caso.Id);
				numeroCasos = numeroCasos + caso.CaseNumber + ', ';
			}
		});
		numeroCasos = numeroCasos.substring(0, numeroCasos.length - 2);
		component.set('v.CasesNumber', '(' + numeroCasos + ')');
		component.set('v.currentSelectedRows', listaCasos);
		component.set('v.casosSeleccionados', nuevaListaCasos);
	},

	asociarCaso: function(component) {
		component.set('v.procesando', true);
		let mergeCaseApex = component.get('c.mergeCase');
		mergeCaseApex.setParams({'masterCaseId': component.get('v.recordId') + '', 'listaIds': component.get('v.currentSelectedRows')});
		mergeCaseApex.setCallback(this, response => {
			if (response.getState() === 'ERROR') {
				let errors = mergeCaseApex.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						this.errorAsociacion(errors[0].message);
					}
				}
			} else if (response.getState() === 'SUCCESS') {
				if (response.getReturnValue() === 'Ok') {
					//Toast
					$A.util.removeClass(component.find('modalConfirmacion'), 'slds-fade-in-open');
					$A.util.removeClass(component.find('backdropConfirmacion'), 'slds-backdrop_open');
					$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
					$A.util.removeClass(component.find('modalAsociarCaso'), 'slds-fade-in-open');
					this.confirmarAsociacion();
					$A.get('e.force:refreshView').fire();

				} else {
					this.errorAsociacion(response.getReturnValue());
				}
			}
			component.set('v.procesando', false);
		});
		$A.enqueueAction(mergeCaseApex);
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

	cargarListadoEmails: function(component) {
		let getEmailsCaso = component.get('c.getEmailsCaso');
		getEmailsCaso.setParams({'caseId': component.get('v.recordId'),
			'campo': component.get('v.sortedBy'),
			'orden': component.get('v.sortDirection')
		});
		getEmailsCaso.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let retorno = response.getReturnValue();
				component.set('v.emailsCaso', retorno);
			}
		});
		$A.enqueueAction(getEmailsCaso);
		let columns = [
			{label: '', fieldName: '', iconName: 'standard:email', fixedWidth: 48, hideLabel: true, hideDefaultActions: true, cellAttributes: {iconName: 'standard:email'}},
			{label: 'Asunto', fieldName: 'nameUrl', type: 'url', sortable: true,
				typeAttributes: {label: {fieldName: 'asunto'}, target: '_self', tooltip: {fieldName: 'cuerpo'}}},
			{label: 'Remitente', fieldName: 'de', type: 'text', sortable: true},
			{label: 'Destinatarios', fieldName: 'para', type: 'text', sortable: true},
			{label: 'Destinatarios CC', fieldName: 'cc', type: 'text', sortable: true},
			{label: 'Fecha del mensaje', fieldName: 'fecha', type: 'text', sortable: true},
			{label: 'Estado', fieldName: 'estado', type: 'text', sortable: true},
			{
				fieldName: 'hasAttachment',
				label: 'Adjuntos',
				sortable: true,
				cellAttributes: {alignment: 'center', iconName: {fieldName: 'iconoAdjuntos', iconPosition: 'center'},
					width: 105}
			}
		];
		component.set('v.columnasEmail', columns);
	},

	modalidadMostrarAdjuntos: function(component) {

		let getAdjuntosPlantilla = component.get('c.getAdjuntosPlantilla');
		getAdjuntosPlantilla.setParams({'nameTemplate': component.find('selectItemPlantilla').get('v.value')});
		getAdjuntosPlantilla.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let retorno = response.getReturnValue();
				component.set('v.oAdjuntos', retorno.TEMPLATES);
			}
		});

		$A.enqueueAction(getAdjuntosPlantilla);
		component.set('v.oColumnasAdjuntos', [
			{label: 'Título', fieldName: 'Title', type: 'text', initialWidth: 360},
			{label: 'Ver', type: 'button', typeAttributes:
				{label: {fieldName: 'vercasoLabel'}, title: 'Visualizar', name: 'view_case', iconName: 'utility:preview', disabled: {fieldName: 'actionDisabled'}, class: 'btn_next'}}]);

		/*component.set('v.oColumnasCasosSeleccionados', [
				{label: 'Caso', fieldName: 'CaseNumber', type: 'text'},
				{label: 'Título', fieldName: 'Subject', type: 'text'},
				{label: 'Ver', type: 'button', initialWidth: 75, typeAttributes:
					{label: {fieldName: 'vercasoLabel'}, title: 'Visualizar', name: 'ver', iconName: 'utility:preview', disabled: {fieldName: 'actionDisabled'}, class: 'btn_next'}},
				{label: 'Eliminar', type: 'button', typeAttributes:
					{label: {fieldName: 'eliminarcasoLabel'}, title: 'Eliminar', name: 'delete_case', iconName: 'utility:close', disabled: {fieldName: 'actionDisabled'}, class: 'btn_next'}}]);
			*/

	}
});