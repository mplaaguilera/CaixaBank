/*eslint-disable no-undef */
({
	buscarListas: function(component, event, cadenaBusqueda, lista) {
		let accionApex;
		if (lista === 'grupo') {
			accionApex = component.get('c.buscarGruposColaboradores');
			const negocio = component.get('v.tipoRegistro') === 'CC_CSI_Bankia' ? 'CSI_Bankia' : 'CC';
			accionApex.setParams({'cadenaBusqueda': cadenaBusqueda, 'negocio': negocio});
			accionApex.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let storeResponse = response.getReturnValue();
					if (storeResponse.length === 0) {
						component.set('v.Message', 'No hay resultados.');
					} else {
						component.set('v.Message', 'Resultados de la búsqueda:');
					}
					component.set('v.listOfSearchRecords', storeResponse);
				}
			});
		} else if (lista === 'empleado') {
			accionApex = component.get('c.buscarEmpleado');
			accionApex.setParams({'cadenaBusqueda': cadenaBusqueda});
			accionApex.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let storeResponse = response.getReturnValue();
					if (storeResponse.length === 0) {
						component.set('v.Message', 'No hay resultados.');
					} else {
						component.set('v.Message', 'Resultados de la búsqueda:');
					}
					component.set('v.listOfSearchRecordsEmpl', storeResponse);
				}
			});
		} else if (lista === 'oficina') {
			const filtrarNombreOficina = component.get('v.selectedRecordSegundaOficina') ? component.get('v.selectedRecordSegundaOficina').Name : null;
			accionApex = component.get('c.buscarOficina');
			accionApex.setParams({
				cadenaBusqueda: cadenaBusqueda,
				filtrarNombreOficina: filtrarNombreOficina
			});
			accionApex.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let storeResponse = response.getReturnValue();
					if (!storeResponse.length) {
						component.set('v.Message', 'No hay resultados.');
					} else {
						component.set('v.Message', 'Resultados de la búsqueda:');
					}
					component.set('v.listOfSearchRecordsOfi', storeResponse);
				}
			});
		} else if (lista === 'segundaOficina') {
			//let oficinaGestoraSeleccionada = component.get('v.oficinaGestoraSeleccionadaId');
			let oficinaGestoraSeleccionada = component.get('v.oficinaGestoraSeleccionada');
			let filtrarNombreOficina;
			if (oficinaGestoraSeleccionada) {
				filtrarNombreOficina = component.get('v.oficinaGestoraSeleccionadaId');
			} else {
				filtrarNombreOficina = component.get('v.selectedRecord') ? component.get('v.selectedRecord').Id : null;
			}
			//let filtrarNombreOficina = component.get('v.selectedRecord') ? component.get('v.selectedRecord').Id : null;
			let lookup2aOficinaInput = component.find('lookup2aOficinaInput');
			/*if(oficinaGestoraSeleccionada) {
				filtrarNombreOficina = oficinaGestoraSeleccionada;
			}*/
			lookup2aOficinaInput.set('v.isLoading', true);
			accionApex = component.get('c.buscarOficina');
			accionApex.setParams({
				cadenaBusqueda: cadenaBusqueda,
				filtrarNombreOficina: filtrarNombreOficina
			});
			accionApex.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					if (cadenaBusqueda === component.get('v.SearchKeyWordSegundaOfi')) {
						//No se ha modificado la cadena de búsqueda durante la ejecución del Apex
						lookup2aOficinaInput.set('v.isLoading', false);
						component.set('v.listOfSearchRecords2aOfi', response.getReturnValue());
						const lookup2aOficina = component.find('lookup2aOficina');
						$A.util.addClass(lookup2aOficina, 'slds-is-open');
						$A.util.removeClass(lookup2aOficina, 'slds-is-close');
					}
				}
			});
		}
		$A.enqueueAction(accionApex);
	},

	buscarGrupos3N: function(component, event, cadenaBusqueda) {
		let action = component.get('c.buscarGrupos3N');
		let caseRecordTypeName = component.get('v.tipoRegistro');
		let negocio = 'CC';
		if (caseRecordTypeName === 'CC_CSI_Bankia') {
			negocio = 'CSI_Bankia';

		}
		action.setParams({'cadenaBusqueda': cadenaBusqueda, 'negocio': negocio});
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let storeResponse = response.getReturnValue();
				if (storeResponse.length === 0) {
					component.set('v.Message', 'No hay resultados.');
				} else {
					component.set('v.Message', 'Resultado de la búsqueda...');
				}
				component.set('v.listOfSearchRecordsGroup', storeResponse);
			}
		});
		$A.enqueueAction(action);
	},

	buscarGrupos2N: function(component, event, cadenaBusqueda) {

		let action = component.get('c.buscarGrupos2N');
		let caseRecordTypeName = component.get('v.tipoRegistro');
		let negocio = 'CC';
		if (caseRecordTypeName === 'CC_CSI_Bankia') {
			negocio = 'CSI_Bankia';

		}
		action.setParams({'cadenaBusqueda': cadenaBusqueda, 'negocio': negocio});
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let storeResponse = response.getReturnValue();
				if (storeResponse.length === 0) {
					component.set('v.Message', 'No hay resultados.');
				} else {
					component.set('v.Message', 'Resultado de la búsqueda...');
				}
				component.set('v.listOfSearchRecordsGroup', storeResponse);
			}
		});
		$A.enqueueAction(action);
	},


	getPSGestorDocumentos: function(component) {
    	let datos = component.get('c.getPSGestorDocumentos');
		datos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
            	component.set('v.psSdocs', response.getReturnValue());
			}
		});
		$A.enqueueAction(datos);
	},

	getDatosCaso: function(component) {
		let datosCaso = component.get('c.datosCaso');
		datosCaso.setParam('recordId', component.get('v.recordId'));
		datosCaso.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let caso = response.getReturnValue();
				component.set('v.oCaso', caso);
				component.set('v.idioma', caso.CC_Idioma__c);
				component.set('v.canalProcedencia', caso.CC_Canal_Procedencia__c);
				component.set('v.canalRespuesta', caso.CC_Canal_Respuesta__c);
				component.set('v.estadoCaso', caso.Status);
				component.set('v.canalEntrada', caso.Origin);
				component.set('v.idPropietario', caso.OwnerId);
				component.set('v.ultimoGrupo3N', caso.CC_Grupo_3N__c);
				component.set('v.ultimoGrupo2N', caso.CC_Grupo_2N__c);
				component.set('v.tipoCliente', caso.CC_Tipo_Cliente__c);
				component.set('v.casoEnTercerNivel', caso.CC_En_Tercer_Nivel__c);
				component.set('v.casoEnSegundoNivel', caso.CC_En_Segundo_Nivel__c);
				component.set('v.tipoRegistro', caso.RecordType.DeveloperName);
				this.obtenerPermisos(component, caso);

				if (caso.CC_MCC_Motivo__c) {
					component.set('v.verSegundaOficina', caso.CC_MCC_Motivo__r.CC_Permitir_traslado_2_oficina__c);
				}

				if (caso.CC_Detalles_Consulta__c) {
					component.set('v.comentariosTarea', caso.CC_Detalles_Consulta__c);
				}

				if (caso.CC_Representante__c) {
					component.set('v.representanteId', caso.CC_Representante__c);
				}

				if (caso.AccountId) {
					component.set('v.oficinaId', caso.AccountId);
					component.set('v.oficinaName', caso.Account.Name);
					component.set('v.accountRecordtypeDeveloperName', caso.Account.RecordType.DeveloperName);
					component.set('v.accountRecordtypeId', caso.Account.RecordTypeId);
					component.set('v.numPerso', caso.Account.CC_NumPerso__c);

					if (caso.Account.AV_OficinaPrincipal__c) {
						component.set('v.oficinaGestoraSeleccionadaId', caso.Account.AV_OficinaPrincipal__c);
						component.set('v.oficinaGestoraSeleccionadaEmail', caso.Account.AV_OficinaPrincipal__r.CC_Email__c);
						component.set('v.oficinaGestoraSeleccionadaName', caso.Account.AV_OficinaPrincipal__r.Name);
						component.set('v.oficinaGestoraSeleccionadaRecordtypeId', caso.Account.AV_OficinaPrincipal__r.RecordtypeId);
					}

					if (caso.Account.AV_EAPGestor__c) {
						component.set('v.empleadoGestorId', caso.Account.AV_EAPGestor__c);
						component.set('v.empleadoGestorName', caso.Account.AV_EAPGestor__r.Name);
						component.set('v.oficinaGestor', caso.Account.AV_EAPGestor__r.AccountId);
					}
				}

				if (caso.RecordType.DeveloperName === 'CC_Empleado') {
					component.set('v.empleadoGestorId', caso.ContactId);
					if (caso.ContactId) {
						component.set('v.empleadoGestorName', caso.Contact.Name);
					}
					component.set('v.oficinaGestoraSeleccionadaId', caso.AccountId);
					if (caso.AccountId) {
						component.set('v.oficinaGestoraSeleccionadaEmail', caso.Account.CC_Email__c);
						component.set('v.oficinaGestoraSeleccionadaName', caso.Account.Name);
						component.set('v.oficinaGestoraSeleccionadaRecordtypeId', caso.Account.RecordTypeId);
					}
					component.set('v.oficinaGestor', caso.AccountId);
				}

				//Si el caso es de tipo empleado, se cambia el label para que en vez de cliente, ponga empleado
				if (caso.RecordType.DeveloperName === 'CC_Empleado' || caso.RecordType.DeveloperName === 'CC_CSI_Bankia') {
					component.set('v.labelResponder', 'Responder a empleado');
					component.set('v.labelClienteEmpleado', 'empleado');
				}

				if (caso.Status === 'Activo') {
					component.set('v.mostrarBotonesPendienteColaborador', true);
					component.set('v.mostrarBotonesPendienteInterno', true);
					component.set('v.mostrarBotonesPendienteCliente', true);
				} else {
					component.set('v.mostrarBotonesPendienteColaborador', false);
					component.set('v.mostrarBotonesPendienteInterno', false);
					component.set('v.mostrarBotonesPendienteCliente', false);
				}

				if (caso.Origin === 'Phone' || caso.Origin === 'Chat') {
					if (caso.RecordType.DeveloperName === 'CC_Empleado') {
						component.set('v.habilitarLync', true);
						component.set('v.mostrarIniLync', true);
					}
				} else if (caso.Origin === 'Propuestas de mejora') {
					component.set('v.deshabilitarQAPropuestasMejora', true);
				} else {
					component.set('v.habilitarLync', false);
				}
			}
		});
		$A.enqueueAction(datosCaso);
	},

	//se vacía la plantilla para que no se cargue la anterior
	vaciarPlantilla: function(component) {
		let vaciarPlantilla = component.get('c.vaciarPlantilla');
		vaciarPlantilla.setParam('recordId', component.get('v.recordId'));
		$A.enqueueAction(vaciarPlantilla);
	},

	obtenerPermisos: function(component, caso) {
		let getCustomPermissions = component.get('c.getCustomPermissions');
		getCustomPermissions.setParams({nombreGrupo3N: component.get('v.ultimoGrupo3N'), caso: caso});
		getCustomPermissions.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let permisos = response.getReturnValue();
				if (caso.RecordType.DeveloperName === 'CC_Cliente') {
					permisos.permisoDevolverAlSac = permisos.CC_DevolverAlSac && caso.ParentId != null && permisos.CC_parentIdRecordTypeIsSAC;
					permisos.permisoDerivarAlSac = permisos.CC_DerivarAlSac && caso.Origin === 'Email' && (caso.CC_Canal_Procedencia__c === 'Formulario web' || caso.CC_Canal_Procedencia__c === 'Código de Buenas Prácticas');
				}
				component.set('v.permisos', permisos);
			}
			component.set('v.cargando', false);

			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => component.set('v.renderModales', true)), 1000);
		});
		$A.enqueueAction(getCustomPermissions);
	},

	getPicklistPlantillas: function(component) {
		let tipoOperativa = component.get('v.tipoOperativa');
		let recordId = component.get('v.recordId');
		let action = component.get('c.getPlantillaList');
		action.setParams({'tipoOperativa': tipoOperativa, 'recordId': recordId});
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let options = response.getReturnValue();
				if (tipoOperativa === 'trasladar') {
					component.set('v.optionsPlantilla', options);
				} else if (tipoOperativa === 'solicitar') {
					component.set('v.optionsPlantillaSolicitud', options);
				}
			}
		});
		$A.enqueueAction(action);
	},

	getPicklistMCCGrupo: function(component) {
		let getMCCGrupoList = component.get('c.getMCCGrupoList');
		getMCCGrupoList.setParams({'recordId': component.get('v.recordId'), 'tipoGrupo': ''});
		getMCCGrupoList.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.optionsGrupo', response.getReturnValue());
			}
		});
		$A.enqueueAction(getMCCGrupoList);
	},

	getPicklistMCCGrupo3N: function(component) {
		let getMCCGrupo3NList = component.get('c.getMCCGrupoList');
		getMCCGrupo3NList.setParams({'recordId': component.get('v.recordId'), 'tipoGrupo': '3N'});
		getMCCGrupo3NList.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let options = response.getReturnValue();
				component.set('v.optionsGrupo3N', options);

			}
		});
		$A.enqueueAction(getMCCGrupo3NList);

	},

	getPicklistMCCGrupo2N: function(component) {
		let getMCCGrupo2NList = component.get('c.getMCCGrupoList');
		getMCCGrupo2NList.setParams({'recordId': component.get('v.recordId'), 'tipoGrupo': '2N'});
		getMCCGrupo2NList.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let options = response.getReturnValue();
				component.set('v.optionsGrupo2N', options);

			}
		});
		$A.enqueueAction(getMCCGrupo2NList);

	},

	getPicklistGrupos: function(component) {
		let action = component.get('c.getGrupoList');
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let options = response.getReturnValue();
				component.set('v.optionsGrupo', options);
			}
		});
		$A.enqueueAction(action);
	},

	loadCarpetasIdioma: function(component, event, helper) {
		let operativa = component.get('v.tipoOperativa');
		let canalProcedencia = component.get('v.canalProcedencia');
		canalProcedencia = canalProcedencia.replace(/\s/g, '');
		let idioma = component.get('v.idioma');
		let tipoRegistro = component.get('v.tipoRegistro');
		let carpetaOperativa;
		let carpetaGenerica;

		if (operativa === 'responder') {
			//idioma = 'CC_Responder_' + canalProcedencia+'_' + idioma;
			if (tipoRegistro === 'CC_Empleado') {
				if (canalProcedencia.includes('CompraEstrella') || canalProcedencia === 'EmisionesPromoCaixa') {
					component.set('v.canalProcedencia', 'Emisiones PromoCaixa');
					carpetaOperativa = 'CC_Responder_Empleado_Wivai';
				} else {
                	carpetaOperativa = 'CC_Responder_Empleado_' + canalProcedencia;
				}
			} else if (tipoRegistro === 'CC_CSI_Bankia') {
				carpetaOperativa = 'CC_Responder_CSI_Bankia_' + canalProcedencia;
			} else if (tipoRegistro === 'CC_Cliente' && (canalProcedencia.includes('CompraEstrella') || canalProcedencia === 'EmisionesPromoCaixa')) {
				carpetaOperativa = 'CC_Responder_EmisionesPromoCaixa';
			} else {
				carpetaOperativa = 'CC_Responder_' + canalProcedencia;
			}
		} else if (operativa === 'solicitar') {
			//idioma = 'CC_Solicitar_' + canalProcedencia + '_' + idioma;
			if (tipoRegistro === 'CC_Empleado') {
				carpetaOperativa = 'CC_Solicitar_Empleado_' + canalProcedencia;
			} else if (tipoRegistro === 'CC_CSI_Bankia') {
				carpetaOperativa = 'CC_Solicitar_CSI_Bankia_' + canalProcedencia;
			} else {
				carpetaOperativa = 'CC_Solicitar_' + canalProcedencia;
			}
		}

		let existeCarpeta = component.get('c.existeCarpeta');
		existeCarpeta.setParams({'carpetaDeveloperName': carpetaOperativa});
		existeCarpeta.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				if (response.getReturnValue()) {
					if (operativa === 'responder') {
						if (tipoRegistro === 'CC_Empleado') {
							if (canalProcedencia.includes('CompraEstrella') || canalProcedencia === 'EmisionesPromoCaixa') {
								idioma = 'CC_Responder_Empleado_Wivai_' + idioma;
								carpetaGenerica = 'CC_Responder_Empleado_Wivai"';
							} else {
								idioma = 'CC_Responder_Empleado_' + canalProcedencia + '_' + idioma;
								carpetaGenerica = 'CC_Responder_Empleado';
							}
						} else if (tipoRegistro === 'CC_CSI_Bankia') {
							idioma = 'CC_Responder_CSI_Bankia_' + canalProcedencia + '_' + idioma;
							carpetaGenerica = 'CC_Responder_CSI_Bankia';
						} else if (tipoRegistro === 'CC_Cliente' && (canalProcedencia.includes('CompraEstrella') || canalProcedencia === 'EmisionesPromoCaixa')) {
							idioma = 'CC_Responder_EmisionesPromoCaixa_' + idioma;
							carpetaGenerica = 'CC_Responder_EmisionesPromoCaixa';
						} else {
							idioma = 'CC_Responder_' + canalProcedencia + '_' + idioma;
							carpetaGenerica = 'CC_Responder';
						}
					} else if (operativa === 'solicitar') {
						if (tipoRegistro === 'CC_Empleado') {
							idioma = 'CC_Solicitar_Empleado_' + canalProcedencia + '_' + idioma;
							carpetaGenerica = 'CC_Solicitar_Empleado';
						} else if (tipoRegistro === 'CC_CSI_Bankia') {
							idioma = 'CC_Solicitar_CSI_Bankia_' + canalProcedencia + '_' + idioma;
							carpetaGenerica = 'CC_Solicitar_CSI_Bankia';
						} else {
							idioma = 'CC_Solicitar_' + canalProcedencia + '_' + idioma;
							carpetaGenerica = 'CC_Solicitar';
						}
					}
				} else {
					if (operativa === 'responder') {
						if (tipoRegistro === 'CC_Empleado') {
							if (canalProcedencia.includes('CompraEstrella') || canalProcedencia === 'EmisionesPromoCaixa') {
								idioma = 'CC_Responder_Empleado_Wivai_' + idioma;
								carpetaOperativa = 'CC_Responder_Empleado_Wivai';
							} else {
								idioma = 'CC_Responder_Empleado_' + idioma;
								carpetaOperativa = 'CC_Responder_Empleado';
							}
						} else if (tipoRegistro === 'CC_Cliente' && (canalProcedencia.includes('CompraEstrella') || canalProcedencia === 'EmisionesPromoCaixa')) {
							idioma = 'CC_Responder_EmisionesPromoCaixa_' + idioma;
							carpetaOperativa = 'CC_Responder_EmisionesPromoCaixa';
						} else if (tipoRegistro === 'CC_CSI_Bankia') {
							idioma = 'CC_Responder_CSI_Bankia_' + idioma;
							carpetaOperativa = 'CC_Responder_CSI_Bankia';
						} else {
							idioma = 'CC_Responder_' + idioma;
							carpetaOperativa = 'CC_Responder';
						}
					} else if (operativa === 'solicitar') {
						if (tipoRegistro === 'CC_Empleado') {
							idioma = 'CC_Solicitar_Empleado_' + idioma;
							carpetaOperativa = 'CC_Solicitar_Empleado';
						} else if (tipoRegistro === 'CC_CSI_Bankia') {
							idioma = 'CC_Solicitar_CSI_Bankia_' + idioma;
							carpetaOperativa = 'CC_Solicitar_CSI_Bankia';
						} else {
							idioma = 'CC_Solicitar_' + idioma;
							carpetaOperativa = 'CC_Solicitar';
						}
					}
				}
				let opcionesIdiomaFolder = [];
				let getCarpetas = component.get('c.getCarpetas');
				getCarpetas.setParams({
					'carpetaDeveloperName': carpetaOperativa,
					'carpetaGenerica': carpetaGenerica
				});
				getCarpetas.setCallback(this, responseGetCarpetas => {
					if (responseGetCarpetas.getState() === 'SUCCESS') {
						let arr = responseGetCarpetas.getReturnValue();
						arr.forEach(element => opcionesIdiomaFolder.push({value: element.DeveloperName, label: element.Name}));
						component.set('v.opcionesIdiomaFolder', opcionesIdiomaFolder);
						component.set('v.carpetaIdiomaSeleccionada', true);
						component.set('v.idiomaPlantilla', idioma);
						if (operativa === 'responder') {
							component.find('selectItemIdioma').set('v.value', idioma);
						} else if (operativa === 'solicitar') {
							component.find('selectItemIdiomaSol').set('v.value', idioma);
						}
						helper.loadCarpetasTratamiento(component, event, helper);

						//Se pone en el foco en el campo de tratamiento del modal correspondiente
						if (operativa === 'solicitar') {
							//eslint-disable-next-line @lwc/lwc/no-async-operation
							window.setTimeout($A.getCallback(() => component.find('selectItemTratamientoSol').focus()), 50);
						} else if (operativa === 'responder') {
							//eslint-disable-next-line @lwc/lwc/no-async-operation
							window.setTimeout($A.getCallback(() => component.find('selectItemTratamiento').focus()), 50);
						}
					}
				});
				$A.enqueueAction(getCarpetas);
			}
		});
		$A.enqueueAction(existeCarpeta);
	},

	loadCarpetasTratamiento: function(component, event, helper) {
		let opcionesTratamientoFolder = [];
		let idioma = component.get('v.idiomaPlantilla');
		let action = component.get('c.getCarpetas');
		action.setParams({'carpetaDeveloperName': idioma, 'carpetaGenerica': ''});
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let arr = response.getReturnValue();
				arr.forEach(element => {
					opcionesTratamientoFolder.push({value: element.DeveloperName, label: element.Name});
				});
				component.set('v.opcionesTratamientoFolder', opcionesTratamientoFolder);
			}
			if (opcionesTratamientoFolder.length === 0) {
				component.set('v.procesoFinalSeleccion', true);
				component.set('v.idiomaPlantilla', idioma);
				helper.loadPlantillas(component, event, helper);
			} else {
				component.set('v.carpetaIdiomaSeleccionada', true);
			}
		});
		$A.enqueueAction(action);
	},

	getPlantillasResponder: function(component) {
		let recordId = component.get('v.recordId');
		let tratamiento = component.get('v.tratamiento');
		let action = component.get('c.getPlantillasResponder');
		action.setParams({
			'recordId': recordId,
			'carpeta': tratamiento
		});
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let options = response.getReturnValue();
				component.set('v.optionsPlantillaResponder', options);
			}
		});
		$A.enqueueAction(action);
	},

	getBotones: function(component) {
		let mostrarBotonesPendienteColaborador = component.get('c.mostrarBotonesPendienteColaborador');
		mostrarBotonesPendienteColaborador.setParams({'recordId': component.get('v.recordId')});
		mostrarBotonesPendienteColaborador.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				if (response.getReturnValue()) {
					component.set('v.mostrarBotonesPendienteColaborador', true);
				} else {
					component.set('v.mostrarBotonesPendienteColaborador', false);
				}
			}
		});
		$A.enqueueAction(mostrarBotonesPendienteColaborador);

		let action = component.get('c.mostrarBotonesPendienteInterno');
		action.setParams({'recordId': component.get('v.recordId')});
		action.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				if (response.getReturnValue()) {
					component.set('v.mostrarBotonesPendienteInterno', true);
				} else {
					component.set('v.mostrarBotonesPendienteInterno', false);
				}
			}
		});
		$A.enqueueAction(action);

		let mostrarBotonesPendienteCliente = component.get('c.mostrarBotonesPendienteCliente');
		mostrarBotonesPendienteCliente.setParams({'recordId': component.get('v.recordId')});
		mostrarBotonesPendienteCliente.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let tienePermiso = response.getReturnValue();
				if (tienePermiso) {
					component.set('v.mostrarBotonesPendienteCliente', tienePermiso);
				} else {
					component.set('v.mostrarBotonesPendienteCliente', tienePermiso);
				}
			}
		});
		$A.enqueueAction(mostrarBotonesPendienteCliente);
	},

	buscarPlantillasResponder: function(component, event, cadenaBusqueda) {
		let tratamiento = component.get('v.tratamiento');
		let operativa = component.get('v.tipoOperativa');
		let tipoRegistro = component.get('v.tipoRegistro');
		if (operativa === 'remitir') {
			if (tipoRegistro === 'CC_Empleado') {
				tratamiento = 'CC_Remitir_Empleado_es';
			} else if (tipoRegistro === 'CC_CSI_Bankia') {
				tratamiento = 'CC_Remitir_CSI_Bankia_es';
			} else {
				tratamiento = 'CC_Remitir_es';
			}

		} else if (operativa === 'trasladar') {
			if (tipoRegistro === 'CC_Empleado') {
				tratamiento = 'CC_Trasladar_Empleado_es';
			} else if (tipoRegistro === 'CC_CSI_Bankia') {
				tratamiento = 'CC_Trasladar_CSI_Bankia_es';
			} else {
				tratamiento = 'CC_Trasladar_es';
			}
		}

		let action = component.get('c.buscarPlantillasResponder');
		action.setParams({'cadenaBusqueda': cadenaBusqueda, 'carpeta': tratamiento});
		action.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				let storeResponse = response.getReturnValue();
				if (storeResponse.length === 0) {
					component.set('v.Message', 'No hay resultados.');
				} else {
					component.set('v.Message', 'Resultado de la búsqueda...');
				}
				component.set('v.listOfSearchRecordsPlantilla', storeResponse);
			}
		});
		$A.enqueueAction(action);
	},

	validacionesGDPR: function(component, event, recordId) {
		let obtenerDatosCasoGDPR = component.get('c.obtenerDatosCasoGDPR');
		obtenerDatosCasoGDPR.setParams({'recordId': recordId});
		obtenerDatosCasoGDPR.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				let datos = response.getReturnValue();
				if (datos.productoGDPR && datos.tipoContacto === 'Petición de servicio' && datos.numPerso !== '' && datos.numeroDocumento !== '' && datos.edad >= 14 && !datos.confidencial && !datos.fallecido && datos.tipoPersona === 'F' && !datos.incapacitado) {
					//Abrimos la QuickAction de GDPR
					let actionAPI = component.find('quickActionAPI');
					let args = {actionName: 'Case.CC_GDPR'};
					actionAPI.selectAction(args);
				} else {
					let mensaje = 'Para poder realizar esta operativa:';
					if (!datos.productoGDPR) {
						mensaje += '\n- El caso debe estar clasificado con un Producto con la marca GDPR.';
					}
					if (datos.tipoContacto !== 'Petición de servicio') {
						mensaje += '\n- El campo Tipo Contacto debe estar informado como "Petición de Servicio".';
					}
					if (datos.numPerso === '') {
						mensaje += '\n- El cliente debe tener informado el NumPerso.';
					}
					if (datos.numeroDocumento === '') {
						mensaje += '\n- El cliente debe tener informado el Número de Documento.';
					}
					if (datos.tipoPersona !== 'F') {
						mensaje += '\n- El cliente debe ser una persona física.';
					}
					if (datos.edad < 14) {
						mensaje += '\n- El cliente debe tener una edad mínima de 14 años.';
					}
					if (datos.confidencial) {
						mensaje += '\n- El cliente no puede ser confidencial.';
					}
					if (datos.incapacitado) {
						mensaje += '\n- El cliente no puede constar como incapacitado legal.';
					}
					if (datos.fallecido) {
						mensaje += '\n- El cliente no puede constar como fallecido.';
					}

					let toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						title: 'Operativa no disponible', message: mensaje,
						key: 'info_alt', type: 'error', mode: 'dismissible', duration: '10000'
					});
					toastEvent.fire();
				}
			}
		});
		$A.enqueueAction(obtenerDatosCasoGDPR);
	},

	validacionesOTP: function(component, event, recordId) {
		let datosCaso = component.get('c.datosCaso');
		datosCaso.setParams({'recordId': recordId});
		datosCaso.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				let datos = response.getReturnValue();
				component.set('v.oCaso', datos);

				if (datos.AccountId == null && datos.ContactId == null) {
					let toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						title: 'Operativa no disponible', message: 'Para utilizar esta operativa debes asociar una cuenta y un contacto al caso.',
						key: 'info_alt', type: 'error', mode: 'dismissible', duration: '10000'
					});
					toastEvent.fire();
				} else if (datos.AccountId == null) {
					let toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						title: 'Operativa no disponible', message: 'Para utilizar esta operativa debes asociar una cuenta al caso.',
						key: 'info_alt', type: 'error', mode: 'dismissible', duration: '10000'
					});
					toastEvent.fire();
				} else if (datos.ContactId == null) {
					let toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						title: 'Operativa no disponible', message: 'Para utilizar esta operativa debes asociar un contacto al caso.',
						key: 'info_alt', type: 'error', mode: 'dismissible', duration: '10000'
					});
					toastEvent.fire();

				} else if (component.get('v.tipoCliente') !== 'Cliente') {
					let toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						title: 'Operativa no disponible', message: 'Operativa no disponible para este tipo de cliente del caso.',
						key: 'info_alt', type: 'error', mode: 'dismissible', duration: '10000'
					});
					toastEvent.fire();

				} else {
					//let canalValido = false;
					let validarCanalAutenticacion = component.get('c.validarCanalAutenticacion');
					validarCanalAutenticacion.setParam('recordId', component.get('v.recordId'));
					validarCanalAutenticacion.setCallback(this, responseValidarCanalAutenticacion => {
						if (responseValidarCanalAutenticacion.getState() === 'SUCCESS') {
							let canalValido = responseValidarCanalAutenticacion.getReturnValue();
							if (canalValido != null) {
								if (canalValido) {
									let actionAPI = component.find('quickActionAPI');
									let args = {actionName: 'Case.CC_OTP'};
									actionAPI.selectAction(args).catch(error => {
										console.error('Error selecting action:', error);
									});
								} else {
									let toastEvent = $A.get('e.force:showToast');
									toastEvent.setParams({
										title: 'Operativa no disponible', message: 'Operativa no disponible para este canal de entrada o tipo de cliente del caso.',
										key: 'info_alt', type: 'error', mode: 'dismissible', duration: '10000'
									});
									toastEvent.fire();
								}
							}

						} else {
							let toastEvent = $A.get('e.force:showToast');
							toastEvent.setParams({
								title: 'Operativa no disponible', message: 'Operativa no disponible para este canal de entrada o tipo de cliente del caso.',
								key: 'info_alt', type: 'error', mode: 'dismissible', duration: '10000'
							});
							toastEvent.fire();
						}
					});
					$A.enqueueAction(validarCanalAutenticacion);
				}
			}
		});

		$A.enqueueAction(datosCaso);
	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({title: titulo, message: mensaje, type: tipo, mode: 'dismissable', duration: '4000'});
		toastEvent.fire();
	},

	inicializarLync: function(component, event, recordId) {
		let obtenerDatosEmpleado = component.get('c.recuperaMailEmpleado');
		obtenerDatosEmpleado.setParams({'recordId': recordId});
		obtenerDatosEmpleado.setCallback(this, function(response) {
			let state = response.getState();
			if (state === 'SUCCESS') {
				let datos = response.getReturnValue();
				let email = datos[0].Contact.Email;
				let empleadoName = datos[0].Contact.Name;
				if (email !== null && email !== '') {
					component.set('v.emailWebCollab', email);
					let crearTareaWebCollab = component.get('c.crearTaskWebCollab');
					crearTareaWebCollab.setParams({'recordId': recordId, 'empleado': empleadoName});
					crearTareaWebCollab.setCallback(this, responseCrearTareaWebCollab => {
						if (responseCrearTareaWebCollab.getState() === 'SUCCESS') {
							let idTask = responseCrearTareaWebCollab.getReturnValue();
							if (idTask != null && idTask !== '') {
								/*
								*   Construcción link webcollab formato: webcollab://1|8-12345|8-67890|alex.bonich@dxc.com
								*   Indicador de método: si se recibe un 1, se invocará a la función Iniciar, si se recibe un 0, se invocará a la función Finalizar.
								*   Id SR: identificador de base de datos de la SR.
								*   Id Actividad: identificador de base de datos de la actividad creada específicamente para WebCollaboration.
								*   Email: dirección de correo electrónico del empleado.
								*/
								let url = 'webcollab://1|' + recordId + '|' + idTask + '|' + email;
								//window.open(url,target="_blank");
								let urlEvent = $A.get('e.force:navigateToURL');
								urlEvent.setParams({
									'url': url
								});
								urlEvent.fire();
							}
						}
					});
					$A.enqueueAction(crearTareaWebCollab);
				} else {
					let titulo = 'Error: ';
					let mensaje = 'El email del empleado debe estar informado a nivel de contacto.';
					let tipo = 'error';
					mostrarToast(tipo, titulo, mensaje);
				}
			}
		});
		$A.enqueueAction(obtenerDatosEmpleado);

		component.set('v.mostrarIniLync', false);
		component.set('v.mostrarFinLync', true);
	},

	finalizarLync: function(component, event, recordId) {
		let email = component.get('v.emailWebCollab');
		let actualizarTareaWebCollab = component.get('c.updateTaskWebCollab');
		actualizarTareaWebCollab.setParams({'recordId': recordId});
		actualizarTareaWebCollab.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				let idTask = response.getReturnValue();
				if (idTask != null && idTask !== '') {
					/*
					*   Construcción link webcollab formato: webcollab://1|8-12345|8-67890|alex.bonich@dxc.com
					*   Indicador de método: si se recibe un 1, se invocará a la función Iniciar, si se recibe un 0, se invocará a la función Finalizar.
					*   Id SR: identificador de base de datos de la SR.
					*   Id Actividad: identificador de base de datos de la actividad creada específicamente para WebCollaboration.
					*   Email: dirección de correo electrónico del empleado.
					*/
					//var newwindow = window.open('/apex/CallReportDataComponentPage','Call Report' '_blank');
					let url = 'webcollab://0|' + recordId + '|' + idTask + '|' + email;
					//window.open(url,target="_blank");
					let urlEvent = $A.get('e.force:navigateToURL');
					urlEvent.setParams({
						'url': url
					});
					urlEvent.fire();
				}
			}
		});
		$A.enqueueAction(actualizarTareaWebCollab);

		component.set('v.mostrarIniLync', true);
		component.set('v.mostrarFinLync', false);
	},

	esClienteDigital: function(component, tipoActividad) {
		component.set('v.cargandoGestor', true);
		let clienteDigital = component.get('c.esClienteDigital');
		clienteDigital.setParams({
			'recordId': component.get('v.recordId'),
			'tipoActividad': tipoActividad
		});
		clienteDigital.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let value = response.getReturnValue();
				if (value.resultado === 'OK') {
					component.set('v.esClienteDigital', value.clienteDigital);
					if (value.empleado1) {
						component.set('v.tieneGestor', true);
						component.set('v.numeroGestor', value.empleado1);
						component.set('v.nombreGestor', value.gestorClienteName);
						component.set('v.oficinaGestor', value.oficina1);
					} else {
						if (value.gestorClienteName === 'Sin Gestor/EAP') {
							component.set('v.nombreGestor', value.gestorClienteName);
							component.set('v.nombreGestorAsignado', value.nombreGestorAsignado);
						}
					}
					if (value.gestorAsignadoCoincide === 'false') {
						component.set('v.gestorAsignadoCoincide', false);
						component.set('v.nombreGestorAsignado', value.nombreGestorAsignado);
					}
				} else if (value.resultado === 'KO') {
					component.set('v.numeroGestor', 'KO');
					component.set('v.mensajeErrorInt', value.mensajeError);
				}
				component.set('v.cargandoGestor', false);
			}
		});
		$A.enqueueAction(clienteDigital);
	},

	consultarFechasDisponibilidad: function(component, gestorElegidoId) {
		let consultarFechasDisponibilidad = component.get('c.obtenerFechasDisponiblidadGestor');
		consultarFechasDisponibilidad.setParams({
			'recordId': component.get('v.recordId'),
			'employeeId': component.get('v.numeroGestor'),
			'gestorElegidoId': gestorElegidoId,
			'eventType': component.find('tipoCita').get('v.value')
		});
		consultarFechasDisponibilidad.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.disponibilidadConsultada', true);
				component.set('v.fechasDisponibilidad', response.getReturnValue());
			} else if (response.getState() === 'ERROR') {
				helper.mostrarToast('error', 'Error al obtener las fechas', consultarFechasDisponibilidad.getError()[0].message);
			}
		});
		$A.enqueueAction(consultarFechasDisponibilidad);
	},

	consultarHorasDisponibilidad: function(component, gestorElegidoId) {
		let consultarHorasDisponibilidad = component.get('c.obtenerHorasDisponiblidadGestor');
		consultarHorasDisponibilidad.setParams({
			'recordId': component.get('v.recordId'),
			'employeeId': component.get('v.numeroGestor'),
			'gestorElegidoId': gestorElegidoId,
			'eventType': component.find('tipoCita').get('v.value'),
			'fechaElegida': component.find('fechasDisponibilidad').get('v.value')
		});
		consultarHorasDisponibilidad.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.horasDisponibilidad', response.getReturnValue());
			} else if (response.getState() === 'ERROR') {
				helper.mostrarToast('error', 'Error al obtener las horas', consultarHorasDisponibilidad.getError()[0].message);
			}
		});
		$A.enqueueAction(consultarHorasDisponibilidad);
	},

	obtenerPlantillasOficina: function(component, event) {
		let ofiId;
		let oficinaId = component.get('v.oficinaId');
		if (component.get('v.verTodasLasOficinas')) {
			ofiId = component.get('v.selectedRecord.Id');
			component.set('v.oficinaSeleccionadaValue', ofiId);
			component.set('v.oficinaSeleccionadaName', component.get('v.selectedRecord.Name'));
		} else if (component.get('v.noVerOficinas') && component.get('v.oficinaGestoraSeleccionada')) {
			//?
		} else if (component.get('v.noVerOficinas')) {
			component.set('v.oficinaSeleccionada', true);
			component.set('v.oficinaSeleccionadaValue', component.get('v.oficinaId'));
			component.set('v.oficinaSeleccionadaName', component.get('v.oficinaName'));
		} else {
			ofiId = event.getParam('value');
			component.set('v.actualFirstOptionOficina', ofiId);
			let picklistFirstOptionsOficina = component.get('v.optionsGrupo');
			for (let key in picklistFirstOptionsOficina) {
				if (ofiId === picklistFirstOptionsOficina[key].value) {
					component.set('v.oficinaSeleccionadaValue', picklistFirstOptionsOficina[key].value);
					component.set('v.oficinaSeleccionadaName', picklistFirstOptionsOficina[key].label);
				}
			}
		}
		let action = component.get('c.getPlantillaOficinaList');

		if (component.get('v.verTodasLasOficinas')) {
			action.setParams({
				'ofiId': ofiId,
				'tipoOperativa': component.get('v.tipoOperativa'),
				'recTypeCase': component.get('v.oCaso.RecordType.DeveloperName'),
				'recTypeAccountId': component.get('v.selectedRecord.RecordTypeId')
			});
		} else if (component.get('v.noVerOficinas') && component.get('v.oficinaGestoraSeleccionada')) {
			action.setParams({
				'ofiId': component.get('v.oficinaGestoraSeleccionadaId'),
				'tipoOperativa': component.get('v.tipoOperativa'),
				'recTypeCase': component.get('v.oCaso.RecordType.DeveloperName'),
				'recTypeAccountId': ''
				//'recTypeAccountId': component.get('v.oCaso.Account.RecordTypeId')
			});

		} else if (component.get('v.noVerOficinas')) {
			action.setParams({
				'ofiId': oficinaId,
				'tipoOperativa': component.get('v.tipoOperativa'),
				'recTypeCase': component.get('v.oCaso.RecordType.DeveloperName'),
				'recTypeAccountId': component.get('v.accountRecordtypeId')
			});
		}
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.optionsPlantilla', response.getReturnValue());
				component.set('v.oficinaSeleccionada', true);
			}
		});
		$A.enqueueAction(action);
	},

	obtenerPlantillasEmpleado: function(component, event) {
		let empleId;

		if (component.get('v.empleadoSeleccionado')) {
			empleId = component.get('v.empleadoGestorId');

		} else if (component.get('v.verTodosLosEmpleados')) {
			empleId = component.get('v.selectedRecord.Id');
			component.set('v.emailParaEmplAux', component.get('v.selectedRecord.Email'));
			component.set('v.empleadoSeleccionadoValue', empleId);
			component.set('v.empleadoSeleccionadoName', component.get('v.selectedRecord.Name'));
			component.set('v.empleadoSeleccionado', true);
		} else {
			empleId = event.getParam('value');
			component.set('v.actualFirstOptionEmpleado', empleId);
			let picklistFirstOptionsEmpleado = component.get('v.optionsGrupo');
			for (let key in picklistFirstOptionsEmpleado) {
				if (empleId === picklistFirstOptionsEmpleado[key].value) {
					component.set('v.empleadoSeleccionadoValue', picklistFirstOptionsEmpleado[key].value);
					component.set('v.empleadoSeleccionadoName', picklistFirstOptionsEmpleado[key].label);
				}
			}
		}

		let action = component.get('c.getPlantillaEmpleadoList');
		action.setParams({
			'empleId': empleId,
			'tipoOperativa': component.get('v.tipoOperativa'),
			'recTypeCase': component.get('v.oCaso.RecordType.DeveloperName'),
			'recTypeAccountId': 'CC_Empleado'
		});
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.optionsPlantilla', response.getReturnValue());
				component.set('v.empleadoSeleccionado', true);
			}
		});
		$A.enqueueAction(action);
	},

	buscarColas: function(component, event, cadenaBusqueda) {
		let accionApex = component.get('c.buscarColasTransfer');
		accionApex.setParams({'cadenaBusqueda': cadenaBusqueda});
		accionApex.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let storeResponse = response.getReturnValue();
				if (storeResponse.length === 0) {
					component.set('v.Message', 'No hay resultados.');
				} else {
					component.set('v.Message', 'Resultados de la búsqueda:');
				}
				component.set('v.listOfSearchRecordsQueue', storeResponse);
			}
		});
		$A.enqueueAction(accionApex);
	},

	visibilidadBotonCitaTareaGestor: function(component) {
		let visibilidadBotones = component.get('c.comprobarVisibilidadBotonTareaCitaGestor');
		visibilidadBotones.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let respuesta = response.getReturnValue();
				component.set('v.mostrarCitaGestor', respuesta.botonCita);
				component.set('v.mostrarTareaGestor', respuesta.botonTarea);
			}
		});
		$A.enqueueAction(visibilidadBotones);
	},

	reiniciarDerivar: function(component) {
		let reiniciarDerivar = component.get('c.reiniciarDerivar');
		reiniciarDerivar.setParam('recordId', component.get('v.recordId'));
		$A.enqueueAction(reiniciarDerivar);
	},

	visibilidadBotonOnboarding: function(component) {
		let visibilidadBoton = component.get('c.comprobarVisibilidadBotonOnboarding');
		visibilidadBoton.setParam('recordId', component.get('v.recordId'));
		visibilidadBoton.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let respuesta = response.getReturnValue();
				component.set('v.mostrarOnboarding', respuesta);
			}
		});
		$A.enqueueAction(visibilidadBoton);
	}

	/*obtenerEmpleadosOficina: function(component) {
		if (!component.get('v.comboboxEmpleadosOptions').length) { //Si no se han cargado ya previamente
			let getEmpleadosTareaGestor = component.get('c.getEmpleadosTareaGestor');
			getEmpleadosTareaGestor.setParams({'recordId': component.get('v.recordId')});
			getEmpleadosTareaGestor.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					component.set('v.comboboxEmpleadosOptions', response.getReturnValue().map(e => ({label: e.Name, value: e.CC_Matricula__c})));
					//component.set('v.comboboxEmpleadoSeleccionado', true);
				} else {
					this.mostrarToast('error', 'Problema recuperando lista de empleados', 'Ha ocurrido un problema al recuperar los empleados de la oficina.');
				}
			});
			$A.enqueueAction(getEmpleadosTareaGestor);
		}
	}*/
});