({
	// getActividadesTrasladoColaborador: function(component) {
	// 	let getActividadesTrasladoColaborador = component.get('c.actividadesTrasladoColaborador');
	// 	getActividadesTrasladoColaborador.setParam('recordId', component.get('v.recordId'));
	// 	getActividadesTrasladoColaborador.setCallback(this, response => {
	// 		if (response.getState() === 'SUCCESS') {
	// 			component.find('cambiarEstadoPendienteColaborador').set('v.disabled', !response.getReturnValue());
	// 		}
	// 	});
	// 	$A.enqueueAction(getActividadesTrasladoColaborador);
	// },

	onInit : function(component, event, helper) {
        helper.subscribeToEvent(component);
    },

	recordDataUpdated: function(component, event, helper) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			component.set('v.estadoInicial', component.get('v.caso.Status'));
			component.set('v.opcionesMccCargadas', {canalesOperativos: false, tematicas: false, productos: false, motivos: false, causas: false, soluciones: false, campanas: false, erroresTf7: false});

			//if (event.getParams().changeType === 'LOADED') {
			component.set('v.recordLoaded', true);
			if (component.get('v.caso.CC_MCC_Tematica__c')) {
				//if (!component.get('v.opcionesMccCargadas.tematicas')) {
				component.set('v.opcionesTematicas', [{value: component.get('v.caso.CC_MCC_Tematica__c'), label: component.get('v.caso.CC_MCC_Tematica__r.Name')}]);
				//}
				component.find('selectItemTematica').set('v.value', component.get('v.caso.CC_MCC_Tematica__c'));
				component.set('v.comboboxesInformados.tematica', true);
			}
			if (component.get('v.caso.CC_MCC_ProdServ__c')) {
				//if (!component.get('v.opcionesMccCargadas.productos')) {
				component.set('v.opcionesProductos', [{value: component.get('v.caso.CC_MCC_ProdServ__c'), label: component.get('v.caso.CC_MCC_ProdServ__r.Name')}]);
				//}
				component.find('selectItemProducto').set('v.value', component.get('v.caso.CC_MCC_ProdServ__c'));
				component.set('v.comboboxesInformados.producto', true);
			}
			if (component.get('v.caso.CC_MCC_Motivo__c')) {
				//if (!component.get('v.opcionesMccCargadas.motivos')) {
				component.set('v.opcionesMotivos', [{value: component.get('v.caso.CC_MCC_Motivo__c'), label: component.get('v.caso.CC_MCC_Motivo__r.Name')}]);
				//}
				component.find('selectItemMotivo').set('v.value', component.get('v.caso.CC_MCC_Motivo__c'));
				component.set('v.comboboxesInformados.motivo', true);
			}
			if (component.get('v.caso.CC_MCC_Causa__c')) {
				//if (!component.get('v.opcionesMccCargadas.causas')) {
				component.set('v.opcionesCausas', [{value: component.get('v.caso.CC_MCC_Causa__c'), label: component.get('v.caso.CC_MCC_Causa__r.Name')}]);
				//}
				component.find('selectItemCausa').set('v.value', component.get('v.caso.CC_MCC_Causa__c'));
				component.set('v.comboboxesInformados.causa', true);
			}
			if(component.get('v.caso.RecordType.DeveloperName') === 'CC_Cliente'){
				component.set('v.dynamicHidden', 'slds-hide');
			} else {
				component.set('v.dynamicHidden', '');
			}
			if (component.get('v.caso.CC_MCC_Solucion__c')) {
				//if (!component.get('v.opcionesMccCargadas.soluciones')) {
				component.set('v.opcionesSoluciones', [{value: component.get('v.caso.CC_MCC_Solucion__c'), label: component.get('v.caso.CC_MCC_Solucion__r.Name')}]);
				//}
				component.find('selectItemSolucion').set('v.value', component.get('v.caso.CC_MCC_Solucion__c'));
				component.set('v.comboboxesInformados.solucion', true);
			}
			if (component.get('v.caso.CC_Campana__c')) {
				//if (!component.get('v.opcionesMccCargadas.campanas')) {
				component.set('v.opcionesCampanas', [{value: component.get('v.caso.CC_Campana__c'), label: component.get('v.caso.CC_Campana__r.Name')}]);
				//}
				component.find('selectItemCampana').set('v.value', component.get('v.caso.CC_Campana__c'));
				component.set('v.comboboxesInformados.campaña', true);
			}
			if (component.get('v.caso.CC_Reapertura_Valida__c')) {
				component.set('v.opcionesCampanas', [{value: component.get('v.caso.CC_Reapertura_Valida__c'), label: component.get('v.caso.CC_Campana__r.Name')}]);
				component.find('CC_Reapertura_Valida__c').set('v.value', component.get('v.caso.CC_Reapertura_Valida__c'));
				component.set('v.comboboxesInformados.reaperturaValida', true);
			}

			if (component.get('v.caso.RecordType.DeveloperName') === 'CC_Cliente' && component.get('v.caso.CC_Canal_Operativo__c')) {
				if (!component.get('v.opcionesMccCargadas.canalesOperativos')) {
					let getCanalesOperativos = component.get('c.getCanalesOperativos');
					getCanalesOperativos.setCallback(this, response => {
						if (response.getState() === 'SUCCESS') {
							component.set('v.opcionesCanalOperativo', response.getReturnValue());
							const labelCanalOperativo = component.get('v.opcionesCanalOperativo').find(opcion => opcion.value === component.get('v.caso.CC_Canal_Operativo__c')).label;
							component.find('selectItemCanalOperativo').set('v.value', labelCanalOperativo);
							component.set('v.opcionesMccCargadas.canalesOperativos', true);

							//agrupacionComboBox = component.get('v.opcionesSoluciones').find(opcion => opcion.value === component.find('selectItemSolucion').get('v.value')).agrupacion;

							component.find('selectItemCanalOperativo').set('v.value', component.get('v.caso.CC_Canal_Operativo__c'));
							component.set('v.comboboxesInformados.canalOperativo', true);
						} else {
                	component.set('v.opcionesCanalOperativo', [{value: component.get('v.caso.CC_Canal_Operativo__c'), label: component.get('v.caso.CC_Canal_Operativo__c')}]);

						}
					});
					$A.enqueueAction(getCanalesOperativos);

				}


			} else if (component.get('v.caso.CC_Error_TF7__c') && (component.get('v.caso.RecordType.DeveloperName') === 'CC_Empleado' || component.get('v.caso.RecordType.DeveloperName') === 'CC_CSI_Bankia')) {
				if (!component.get('v.opcionesMccCargadas.erroresTf7')) {
					component.set('v.opcionesErrores', [{value: component.get('v.caso.CC_Error_TF7__c'), label: component.get('v.caso.CC_Error_TF7__c')}]);
				}
				component.find('selectItemErroresTF7').set('v.value', component.get('v.caso.CC_Error_TF7__c'));
			}
			//}
			helper.esCasoPromoCaixa(component);
			if(component.get('v.caso.CC_Canal_Procedencia__c') && (component.get('v.caso.CC_Canal_Procedencia__c') === 'Emisiones PromoCaixa' || component.get('v.caso.CC_Canal_Procedencia__c').includes('CompraEstrella'))){
                component.set('v.isFacilitea', true);
            }else{
				component.set('v.isFacilitea', false);
			}
			
			if(component.get('v.caso.CC_MCC_Tematica__r.Name') && component.get('v.caso.CC_MCC_Tematica__r.Name').includes('Facilitea')){
                component.set('v.isTematicaFacilitea', true);
            }else{
				component.set('v.isTematicaFacilitea', false);
			}
			// if(component.get('v.caso.RecordType.DeveloperName') !== 'CC_Cliente' ){
			// 	$A.enqueueAction(component.get('c.getActividadesTrasladoColaborador'));
			// }
			
			//Activa la casilla para cambiar el estado a Activo cuando el estado es pendiente cliente
			//
			if (!component.get('v.tieneActividad') && event.getParams().changeType === 'CHANGED' && !component.get('v.cerrarCaso')
				&& !component.get('v.cierroCaso') && !component.get('v.voyACerrar')
				&& component.get('v.caso.RecordType.DeveloperName') === 'CC_Cliente'
				&& component.get('v.botonGuardarCerrar')
				&& !component.get('v.ambitoCSBD')) {
				$A.enqueueAction(component.get('c.comprobarAgrupacionSolucion'));
			}

			let tituloOnboarding = component.get("c.mensajeValidacionPreguntas");
				tituloOnboarding.setParams({ "validacion": "TITULO_ONBOARDING" });
				tituloOnboarding.setCallback(this, function (response) {
					if (response.getState() === "SUCCESS") {
						let tituloMensaje = response.getReturnValue();
						component.set('v.tituloOnboarding',tituloMensaje.CC_Valor__c);
					}
				});
				$A.enqueueAction(tituloOnboarding);

				if (component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c') === 'Onboarding' || component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c') === 'Onboarding' || component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c') === 'Desistir' || component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c') === 'Desistir') {
					let tituloDerivar = component.get("c.tituloDerivar");
					if (component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c') === 'Onboarding' || component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c') === 'Onboarding') {
						tituloDerivar.setParams({ "validacion": "Texto modal Onboarding" });
					} else if (component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c') === 'Desistir' || component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c') === 'Desistir')  {
						tituloDerivar.setParams({ "validacion": "Texto modal Desistir" });
					}
						tituloDerivar.setCallback(this, function (response) {
							if (response.getState() === "SUCCESS") {
								let tituloMensaje = response.getReturnValue();
								component.set('v.tituloDerivar',tituloMensaje);
							}
						});
						$A.enqueueAction(tituloDerivar);

					let tituloYaDerivado = component.get("c.tituloYaDerivado");
					tituloYaDerivado.setParams({});
					tituloYaDerivado.setCallback(this, function (response) {
						if (response.getState() === "SUCCESS") {
							let titulo = response.getReturnValue();
							component.set('v.tituloYaDerivado', titulo);
						}
					});
					$A.enqueueAction(tituloYaDerivado);
				}
				
		} else if (event.getParams().changeType === 'ERROR') {
			console.error('force:recordData Error: ' + component.get('v.recordDataError'));
			helper.mostrarToast('error', 'Problema recuperando los datos del caso', component.get('v.recordDataError'));
		}
	},

	recordDataReload: function(component) {
		component.find('recordData').reloadRecord(true);
	},

	mccClasificacionRapida: function(component) {
		let detallesConsulta = component.find('CC_Detalles_Consulta__c').get('v.value');
		if (component.find('CC_Tipo_Contacto__c').get('v.value') !== ''
		&& component.find('selectItemMotivo').get('v.value') !== ''
		&& component.find('CC_Tipo_Contacto__c').get('v.value') === 'Incidencia') {
			let valorClasificacionRapida = component.get('c.clasificacionRapida');
			valorClasificacionRapida.setParams({'motivoId': component.find('selectItemMotivo').get('v.value')});
			valorClasificacionRapida.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					//actualizar campo detalles consulta
					let retorno = response.getReturnValue();
					if (retorno !== '') {
						if (detallesConsulta !== '' && detallesConsulta != null) {
							if (!detallesConsulta.includes(retorno)) {
								component.find('CC_Detalles_Consulta__c').set('v.value', detallesConsulta + ' ' + retorno);
							}
						} else {
							component.find('CC_Detalles_Consulta__c').set('v.value', retorno);
						}
					}
				}
			});
			$A.enqueueAction(valorClasificacionRapida);
		}
	},

	funcionesMotivo: function(component) {
		$A.enqueueAction(component.get('c.handleMotivoSeleccionado'));
		$A.enqueueAction(component.get('c.mccClasificacionRapida'));
	},

	comboboxCanalesOperativosFocus: function(component, event, helper) {
		if (!component.get('v.opcionesMccCargadas.canalesOperativos')) {
			helper.getOptionsCanalesOperativos(component);
		}
	},

	handleCanalOperativoSeleccionado: function(component, event, helper) {
		component.set('v.opcionesTematicas', null);
		component.set('v.opcionesProductos', null);
		component.set('v.opcionesMotivos', null);
		component.set('v.opcionesCausas', null);
		component.set('v.opcionesSoluciones', null);
		component.find('selectItemTematica').set('v.value', null);
		component.find('selectItemProducto').set('v.value', null);
		component.find('selectItemMotivo').set('v.value', null);
		component.find('selectItemCausa').set('v.value', null);
		component.find('selectItemSolucion').set('v.value', null);

		component.set('v.comboboxesInformados.canalOperativo', true);
		component.set('v.comboboxesInformados.tematica', false);
		component.set('v.comboboxesInformados.producto', false);
		component.set('v.comboboxesInformados.motivo', false);
		component.set('v.comboboxesInformados.causa', false);
		component.set('v.comboboxesInformados.solucion', false);

		component.set('v.opcionesMccCargadas.tematicas', false);


		helper.getOptionsTematicas(component);
	},

	comboboxTematicasFocus: function(component, event, helper) {
		if (!component.get('v.opcionesMccCargadas.tematicas')) {
			helper.getOptionsTematicas(component);
		}
	},

	handleTematicaSeleccionada: function(component, event, helper) {
		component.set('v.opcionesProductos', null);
		component.set('v.opcionesMotivos', null);
		component.set('v.opcionesCausas', null);
		component.set('v.opcionesSoluciones', null);
		component.find('selectItemProducto').set('v.value', null);
		component.find('selectItemMotivo').set('v.value', null);
		component.find('selectItemCausa').set('v.value', null);
		component.find('selectItemSolucion').set('v.value', null);

		component.set('v.comboboxesInformados.tematica', true);
		component.set('v.comboboxesInformados.producto', false);
		component.set('v.comboboxesInformados.motivo', false);
		component.set('v.comboboxesInformados.causa', false);
		component.set('v.comboboxesInformados.solucion', false);

		component.set('v.opcionesMccCargadas.productos', false);

		helper.getOptionsProductos(component);
	},

	comboboxProductosFocus: function(component, event, helper) {
		if (!component.get('v.opcionesMccCargadas.productos')) {
			helper.getOptionsProductos(component);
		}
	},

	handleProductoSeleccionado: function(component, event, helper) {
		component.set('v.opcionesMotivos', null);
		component.set('v.opcionesCausas', null);
		component.set('v.opcionesSoluciones', null);
		component.find('selectItemMotivo').set('v.value', null);
		component.find('selectItemCausa').set('v.value', null);
		component.find('selectItemSolucion').set('v.value', null);

		component.set('v.comboboxesInformados.producto', true);
		component.set('v.comboboxesInformados.motivo', false);
		component.set('v.comboboxesInformados.causa', false);
		component.set('v.comboboxesInformados.solucion', false);

		component.set('v.opcionesMccCargadas.motivos', false);

		helper.getOptionsMotivos(component);
	},

	comboboxMotivosFocus: function(component, event, helper) {
		if (!component.get('v.opcionesMccCargadas.motivos')) {
			helper.getOptionsMotivos(component);
		}
	},

	handleMotivoSeleccionado: function(component, event, helper) {
		component.set('v.opcionesCausas', null);
		component.set('v.opcionesSoluciones', null);
		component.find('selectItemCausa').set('v.value', null);
		component.find('selectItemSolucion').set('v.value', null);
		component.set('v.comboboxesInformados.motivo', true);
		component.set('v.comboboxesInformados.causa', false);
		component.set('v.comboboxesInformados.solucion', false);
		component.set('v.opcionesMccCargadas.causas', false);

		// Ambito Onboarding/Desistir
		let motivoId = component.find('selectItemMotivo').get('v.value');
		if(motivoId !== null && motivoId !== undefined && motivoId !== ''){
			let recuperarAmbitos = component.get('c.recuperarAmbitoMotivo');
			recuperarAmbitos.setParams({
				'recordId': motivoId
			});
			recuperarAmbitos.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let respuesta = response.getReturnValue();
					if (respuesta['Caixa'] === 'Onboarding' || respuesta['Caixa'] === 'Desistir' || respuesta['Imagin'] === 'Desistir' || respuesta['Imagin'] === 'Onboarding') {
						if (component.get('v.caso.AccountId') != null) {
							component.set('v.motivoOnboardingWS', true);
							//$A.enqueueAction(component.get('c.llamadaWSOnboarding'));
						} else {
							//$A.enqueueAction(component.get('c.modalOnboardingAbrir'));
							component.set('v.motivoOnboardingModal', true);
						}
					}
				}
			});
			$A.enqueueAction(recuperarAmbitos);
		}	
		// End ambito motivo

		helper.getOptionsCausas(component);
	},

	comboboxCausasFocus: function(component, event, helper) {
		if (!component.get('v.opcionesMccCargadas.causas')) {
			helper.getOptionsCausas(component);
		}
	},

	handleCausaSeleccionada: function(component, event, helper) {
		component.set('v.opcionesSoluciones', null);
		component.find('selectItemSolucion').set('v.value', null);

		component.set('v.comboboxesInformados.causa', true);
		component.set('v.comboboxesInformados.solucion', false);

		component.set('v.opcionesMccCargadas.soluciones', false);

		helper.getOptionsSoluciones(component);
	},

	comboboxSolucionesFocus: function(component, event, helper) {
		if (!component.get('v.opcionesMccCargadas.soluciones')) {
			helper.getOptionsSoluciones(component);
		}
	},

	comboboxCampanasFocus: function(component, event, helper) {
		if (!component.get('v.opcionesMccCargadas.campanas')) {
			helper.getOptionsCampanas(component);
		}
	},

	comboboxErroresTF7Focus: function(component, event, helper) {
		if (!component.get('v.opcionesMccCargadas.erroresTf7')) {
			helper.getOptionsErroresTf7(component);
		}
	},

	gestionaGuardarCerrarPrevio: function(component, event, helper) {
		component.set('v.cerrarCaso', event.getSource().getLocalId() === 'submitGuardarCerrar');
		let esImagin = 	(
			component.get('v.caso.Account.AV_IndicadoresClientes__c') != null && 
			component.get('v.caso.Account.AV_IndicadoresClientes__c') != undefined  && 
			component.get('v.caso.Account.AV_IndicadoresClientes__c').includes('28')
		);
		if (
			( esImagin && component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c') === 'Caso a Fraude' ) 
			||
			( !esImagin && component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c') === 'Caso a Fraude' )
		){
			let action = component.get("c.validarActividadesFraude");
			action.setParams({'recordId': component.get("v.recordId")});
			action.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					if (response.getReturnValue()) {
						component.set('v.isOpen', true);
					} else {
						component.set('v.isOpen', false);
						$A.enqueueAction(component.get('c.gestionaGuardarCerrar'));
					}
				}
			});
			$A.enqueueAction(action);
		} else if (component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c') === 'Onboarding' || component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c') === 'Onboarding' || component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c') === 'Desistir' || component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c') === 'Desistir') {
			if (component.get('v.caso.CBK_Case_Extension_Id__r.CC_DerivadoBPO__c') === false) {
				let action = component.get("c.comprobarCodigoOnboarding");
				action.setParams({'codigo': component.get('v.caso.CBK_Case_Extension_Id__r.CC_CodigoONB__c')});
				action.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						if (response.getReturnValue()) {
							component.set('v.onboardingDesistir', true);
						} else {
							$A.enqueueAction(component.get('c.gestionaGuardarCerrar'));
						}
					}
				});
				$A.enqueueAction(action);
			} else {
				component.set('v.onboardingYaDerivado', true);
			}
		} else {
			component.set('v.isOpen', false);
			component.set('v.onboardingDesistir', false);
			$A.enqueueAction(component.get('c.gestionaGuardarCerrar'));
		}
	},

	handleNoDerivarFraude: function(component, event, helper){
		component.set('v.isOpen', false);
		component.set('v.cerrarCaso', true);
		$A.enqueueAction(component.get('c.gestionaGuardarCerrar'));
	},

	handleNoDerivarFraudeCerrar: function(component, event, helper){
		component.set('v.isOpen', false);
	},


	gestionaGuardarCerrar: function(component, event, helper) {
		helper.inicioGuardar(component);
		//copiar el detalle consulta en el campo detalles solucion para los RT de Clientes
		if (
			(
				component.get('v.caso.CC_Detalles_Consulta__c') !== null  && 
				component.get('v.caso.CC_Detalles_Consulta__c') !== '' &&
				component.get('v.caso.CC_Detalles_Consulta__c') !== undefined
			)			
			&&
			component.get('v.caso.RecordType.DeveloperName') === 'CC_Cliente'  
		) {
			component.set('v.caso.CC_Detalles_Solucion__c', component.get('v.caso.CC_Detalles_Consulta__c'));
		}

		let agrupacionComprobacion = '';
		component.set('v.botonGuardarCerrar', true);
		if (component.get('v.cerrarCaso')) {
			component.set('v.cierroCaso', true);
			if (component.get('v.caso.RecordType.DeveloperName') === 'CC_Cliente') {
				component.set('v.voyACerrar', true);
        	}
			//Validaciones locales de campos obligatorios para el cierre
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

			//
			if (component.get('v.caso.CC_Canal_Procedencia__c') === 'Formulario Consultas Operativas' || component.get('v.caso.Origin') === 'Phone' || component.get('v.caso.Origin') === 'Chat') {
				//Comprobar si hay tareas abiertas de reapertura automatica
				let comprobarReaperturaValida = component.get('c.comprobarReaperturaValida');
				comprobarReaperturaValida.setParams({
					'recordId': component.get('v.recordId')
				});
				comprobarReaperturaValida.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						let reaperturaValidaApex = response.getReturnValue();
						if (reaperturaValidaApex === true) {
							if (!component.find('CC_Reapertura_Valida__c').get('v.value')) {
								//Si no ha informado el campo reapertura valida cuando existe una tarea se muestra error
								//helper.mostrarToast('error', 'Campo obligatorio', 'Es necesario que informes el campo Reapertura Válida');
								component.set('v.cierroCaso', false);
								component.set('v.cerrarCaso', false);
								component.set('v.noCerrarFCO', true);
								return;
							}
							//Si ha informado el campo guardamos el valor en la ultima tarea de reapertura valida (en el activity extension)
							let informarReaperturaValida = component.get('c.informarReaperturaValida');
							informarReaperturaValida.setParams({
								'recordId': component.get('v.recordId'),
								'valor': component.find('CC_Reapertura_Valida__c').get('v.value')
							});
							informarReaperturaValida.setCallback(this, response => {
							});
							$A.enqueueAction(informarReaperturaValida);

						}
					}
				});
				$A.enqueueAction(comprobarReaperturaValida);
			}

			if (camposObligatoriosNoInformados.length > 1) {
				helper.mostrarToast('info', 'Campos obligatorios', 'Es necesario que informes Los siguientes campos antes de cerrar el caso:' + camposObligatoriosNoInformados.join('\n\u00a0\u00a0\u00a0\u00a0\u00a0·\u00a0\u00a0'));
				helper.finGuardar(component);
				component.set('v.cerrarCaso', false);
				component.set('v.cierroCaso', false);
				return;
			}

			const caso = component.get('v.caso');
			let agrupacionComboBox = '';

			if (component.get('v.caso.RecordType.DeveloperName') === 'CC_Cliente') {
				if (component.find('selectItemSolucion').get('v.value')) {
					agrupacionComboBox = component.get('v.opcionesSoluciones').find(opcion => opcion.value === component.find('selectItemSolucion').get('v.value')).agrupacion;
				}
				if (agrupacionComboBox) {
					agrupacionComprobacion = agrupacionComboBox;
				} else if (caso.CC_MCC_Solucion__c) {
					agrupacionComprobacion = caso.CC_MCC_Solucion__r.CC_Agrupacion_Solucion__c != null ? caso.CC_MCC_Solucion__r.CC_Agrupacion_Solucion__c : '';
				}
			}
		}

		let selectedMccMotivo = component.get('v.opcionesMotivos').find(motivo => motivo.value === component.find('selectItemMotivo').get('v.value'));
		if (selectedMccMotivo != undefined) {
			component.set('v.seleccionado', selectedMccMotivo.label);
		}

		let onboardingWS  = component.get('v.motivoOnboardingWS');
		let onboardingModal = component.get('v.motivoOnboardingModal');
		let esImagin = 	(
			component.get('v.caso.Account.AV_IndicadoresClientes__c') != null && 
			component.get('v.caso.Account.AV_IndicadoresClientes__c') != undefined  && 
			component.get('v.caso.Account.AV_IndicadoresClientes__c').includes('28')
		);
		if (
			( esImagin && component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c') === 'Onboarding' ) 
			||
			( !esImagin && component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c') === 'Onboarding' )
		) {
			onboardingWS = component.get('v.caso.AccountId') != null ? true : false;
			onboardingModal = onboardingWS ? false : true;
		}

		// Llamada a Onboarding
		if (!component.get('v.cerrarCaso')) {
			if(onboardingWS){
			$A.enqueueAction(component.get('c.llamadaWSOnboarding'));
			} else if(onboardingModal){
				$A.enqueueAction(component.get('c.modalOnboardingAbrir'));
			}
		}
		// ---- Fin llamada a Onboarding ----

		//if (!component.get('v.continuarGuardarCerrar') && caso.RecordType.DeveloperName === 'CC_Cliente' && (agrupacionComprobacion === 'Derivar a oficina' || agrupacionComprobacion === 'Derivar a oficina: Limitación protocolo')) {

		//Validaciones en servidor
		let selectItemCanalOperativo = component.find('selectItemCanalOperativo');
		let validarGuardar = component.get('c.validarGuardarCerrar');
		let nuevoCanalRespuesta = component.get('v.caso.Origin') !== 'Propuestas de mejora' ? 
			component.find('modificarResp') !== undefined ? component.find('modificarResp').get('v.value') : null 
			: null;
		validarGuardar.setParams({
			'recordId': component.get('v.recordId'),
			'cerrar': component.get('v.cerrarCaso'),
			'nuevoCanalRespuesta': nuevoCanalRespuesta,
			'nuevoCanalOperativo': selectItemCanalOperativo ? selectItemCanalOperativo.get('v.value') : null,
			'nuevaTematica': component.find('selectItemTematica').get('v.value'),
			'nuevoProducto': component.find('selectItemProducto').get('v.value'),
			'nuevoMotivo': component.find('selectItemMotivo').get('v.value'),
			'agrupacionComprobacion': agrupacionComprobacion

		});
		//let rec = component.get('v.seleccionado');
		validarGuardar.setCallback(this, response => {
			if (response.getState() === 'ERROR') {
				//Se muestra un Toast de error y no se sigue adelante con el update de la recordEditForm
				let errors = validarGuardar.getError();
				if (errors) {
					let mensajeError = '';
					//eslint-disable-next-line no-return-assign
					errors.forEach(error => mensajeError += error.message + '\n');
					helper.mostrarToast('error', 'No se pudo actualizar Caso', mensajeError);
				}
				helper.finGuardar(component);
				component.set('v.botonGuardarCerrar', false);
			} else if (response.getState() === 'SUCCESS') { //Validaciones OK
				const responseValidarGuardar = response.getReturnValue();
				for (let key in responseValidarGuardar) {
					if (key === 'tieneActividad') {
						component.set('v.tieneActividad', responseValidarGuardar[key]);
					}else if (key === 'ambitoCSBD') {
						component.set('v.ambitoCSBD', responseValidarGuardar[key]);
					} else if (key === 'cambiarStatusAuto') {
						component.set('v.cambiarStatusAuto', responseValidarGuardar[key]);
						if(component.get('v.cambiarStatusAuto') === true){
						helper.recuperarMensajeToast(component, 'error', 'BLOQUEADO_ARGOS');
						}
					}
				}
				
				helper.guardar(component, responseValidarGuardar);
			}
		});
		$A.enqueueAction(validarGuardar);
		//let nuevoMotivo = component.find('selectItemMotivo').get('v.value');
	},

	recordEditFormOnLoad: function(component) {
		component.set('v.recordEditFormLoaded', true);

		if (component.find('estado').get('v.value') === 'Pendiente Cliente' && component.find('cambiarEstadoActivo')) {
			component.find('cambiarEstadoActivo').set('v.disabled', false);
		}


	},

	recordEditFormOnSuccess: function(component, event, helper) {
		//Si se ha modificado la clasificación se crea la actividad de retipificación
		if (component.get('v.retipificar')) {
			//Se crea la actividad de retipificación
			let crearActividadRetipificacion = component.get('c.crearActividadRetipificacion');
			crearActividadRetipificacion.setParams({
				'recordId': component.get('v.recordId'),
				'tematicaAnterior': component.get('v.tematicaAnterior'),
				'productoAnterior': component.get('v.productoAnterior'),
				'motivoAnterior': component.get('v.motivoAnterior')
			});
			crearActividadRetipificacion.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					//Se refresca el componente CC_MCC_Buscador
					let refrescar = $A.get('e.c:CC_Refresh_MCC_Clasificar');
					refrescar.setParam('recordId', component.get('v.recordId'));
					refrescar.fire();

					//Se refresca la vista para mostrar la nueva actividad
					$A.get('e.force:refreshView').fire();
				}
			});
			$A.enqueueAction(crearActividadRetipificacion);
			component.set('v.retipificar', false);
		}

		//Casilla "Cambiar estado a Pendiente Colaborador" marcada
		if (component.get('v.cambiarEstadoPendienteColaborador')) {
			let reabrirTareaTrasladoColaborador = component.get('c.reabrirTareaTrasladoColaborador');
			reabrirTareaTrasladoColaborador.setParam('recordId', component.get('v.recordId'));
			reabrirTareaTrasladoColaborador.setCallback(this, () => {
				component.set('v.cambiarEstadoPendienteColaborador', false);
			});
			$A.enqueueAction(reabrirTareaTrasladoColaborador);
		}

		//Casilla "Cambiar estado a Activo" marcada, ejecuta el proceso para cerrar las actividades de solicitud informacion
		if (component.get('v.cambiarEstadoActivo')) {
			let cerrarActividadSolicitudInformacion = component.get('c.cerrarActividadSolicitudInformacion ');
			cerrarActividadSolicitudInformacion.setParam('recordId', component.get('v.recordId'));
			cerrarActividadSolicitudInformacion.setCallback(this, () => {
				component.set('v.cambiarEstadoActivo', false);
			});
			$A.enqueueAction(cerrarActividadSolicitudInformacion);
		}


		helper.finGuardar(component);

		/*PENDiENTE CONFIRMACIÓN DEL CLIENTE PARA ACTIVAR ESTA PARTE
		if (component.get('v.cerrarCaso')) {
			let casoOrigenAbierto = component.get('c.casoOrigenAbierto');
			casoOrigenAbierto.setParam('idCaso', component.get('v.recordId'));
			casoOrigenAbierto.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					if (response.getReturnValue()) {
						component.set('v.casoOrigen', response.getReturnValue());
						$A.enqueueAction(component.get('c.modalCerrarCasoOrigenAbrir'));
					}
				}
			});
			$A.enqueueAction(casoOrigenAbierto);
		}*/
		if (component.get('v.cerrarCaso')) {
			helper.mostrarToast('success', 'Se cerró Caso', 'Se cerró correctamente el caso ' + component.get('v.caso.CaseNumber'));
			component.set('v.cerrarCaso', false);
		} else if ((component.get('v.caso.CC_Canal_Procedencia__c') === 'Formulario Consultas Operativas' || component.get('v.caso.Origin') === 'Phone' || component.get('v.caso.Origin') === 'Chat') && component.get('v.noCerrarFCO')) {
			helper.mostrarToast('error', 'Campo obligatorio', 'Es necesario que informes el campo Reapertura Válida');
		} else {
			helper.mostrarToast('success', 'Se actualizó Caso', 'Se actualizaron correctamente los datos del caso ' + component.get('v.caso.CaseNumber'));
		}
		/*if(component.get('v.continuarGuardarCerrar')) {
			$A.enqueueAction(component.get('c.modalDerivarCerrar'));
		}*/
	},

	recordEditFormOnError: function(component, event, helper) {
		console.error(JSON.stringify(event.getParam('detail')));
		console.error(JSON.stringify(event.detail));
		helper.finGuardar(component);
		component.set('v.cerrarCaso', false);
		helper.mostrarToast('error', 'Error actualizando Caso', event.getParam('detail'));
	},

	modalCerrarCasoOrigenAbrir: function(component) {
		$A.util.addClass(component.find('modalCerrarCasoOrigen'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
		window.setTimeout($A.getCallback(() => component.find('modalCerrarCasoOrigenCancelar').focus()), 200);
	},

	modalCerrarCasoOrigenCerrar: function(component) {
		$A.util.removeClass(component.find('modalCerrarCasoOrigen'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	modalCerrarCasoOrigenTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalCerrarCasoOrigenCerrar'));
		}
	},

	modalCerrarCasoOrigenNavegar: function(component) {
		let workspaceAPI = component.find('workspace');
		workspaceAPI.openSubtab({
			parentTabId: workspaceAPI.getEnclosingTabId(),
			url: '/lightning/r/Case/' + component.get('v.casoOrigen.Id') + '/view',
			focus: true
		});
	},

	confirmarCerrarCasoOrigen: function(component, event, helper) {
		component.find('modalCerrarCasoOrigenConfirmar').set('v.disabled', true);
		let cerrarCasoOrigen = component.get('c.cerrarCasoOrigen');
		cerrarCasoOrigen.setParams({idCasoOrigen: component.get('v.casoOrigen.Id'), idCaso: component.get('v.recordId')});
		cerrarCasoOrigen.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				$A.enqueueAction(component.get('c.modalCerrarCasoOrigenCerrar'));
				helper.mostrarToast('success', 'Se cerró caso origen', 'Se cerró correctamente el caso origen ' + component.get('v.casoOrigen.CaseNumber'));
			} else if (response.getState() === 'ERROR') {
				console.error(JSON.stringify(cerrarCasoOrigen.getError()));
				helper.mostrarToast('error', 'Error actualizando Caso', cerrarCasoOrigen.getError()[0].message);
			}
			component.find('modalCerrarCasoOrigenConfirmar').set('v.disabled', false);
		});
		$A.enqueueAction(cerrarCasoOrigen);
	},

	handleDerivarFraude: function(component, event, helper) {
		let validado = helper.camposObligatoriosNoInformados(component);
		if(validado){
			component.set('v.cerrarCaso', false);
			$A.enqueueAction(component.get('c.handleModalDerivar'));	
		} else {
			component.set('v.isOpen', false);
		}
	},

	handleModalDerivar: function(component, event, helper) {
		component.set('v.isOpen', false);
		component.set('v.cierroCaso', false);
		component.set('v.mostrarComponenteOperativaDerivar', true);
		$A.util.removeClass(component.find('modalOperativaOficina'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		if (component.get('v.cerrarCaso')) {
			helper.guardarCerrarAuxiliar(component);
		}
		component.set('v.cerrarCaso', false);
		window.setTimeout($A.getCallback(() => component.set('v.mostrarComponenteOperativaDerivar', true)), 200);
		$A.util.removeClass(component.find('modalOperativaOficina'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	handleModalDerivarCerrado: function(component) {
		$A.enqueueAction(component.get('c.modalDerivarCerrar'));
	},

	modalCerrarDerivarTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalDerivarCerrar'));
		}
	},

	modalDerivarCerrar: function(component, event, helper) {
		component.set('v.mostrarComponenteOperativaDerivar', false);
		component.set('v.guardando', false);
		component.set('v.continuarGuardarCerrar', false);


		//component.set('v.mostrarAvisoOperativaOficina', false);
		$A.util.removeClass(component.find('modalOperativaOficina'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
		if (component.get('v.cerrarCaso')) {
			component.set('v.cierroCaso', true);
			helper.guardarCerrarAuxiliar(component);
		}
	},

	comprobarAgrupacionSolucion: function(component, event, helper) {
		/*const caso = component.get('v.caso');
		let agrupacionComboBox = '';
		let agrupacionComprobacion = '';
		if(component.find('selectItemSolucion').get('v.value')) {
			agrupacionComboBox = component.get('v.opcionesSoluciones').find(opcion => opcion.value === component.find('selectItemSolucion').get('v.value')).agrupacion;
		}
		if(agrupacionComboBox) {
			agrupacionComprobacion = agrupacionComboBox;
		} else if (caso.CC_MCC_Solucion__c) {
			agrupacionComprobacion = caso.CC_MCC_Solucion__r.CC_Agrupacion_Solucion__c != null ? caso.CC_MCC_Solucion__r.CC_Agrupacion_Solucion__c : '';
		}

		if (!component.get('v.continuarGuardarCerrar') && caso.RecordType.DeveloperName === 'CC_Cliente' && (agrupacionComprobacion === 'Derivar a oficina' || agrupacionComprobacion === 'Derivar a oficina: Limitación protocolo')) {
			let comprobarTareaOperativaOficina = component.get('c.comprobarTareaOperativaOficina');
			comprobarTareaOperativaOficina.setParam('recordId', component.get('v.recordId'));
			comprobarTareaOperativaOficina.setCallback(this, responseComprobarTareaOperativaOficina => {
				if (responseComprobarTareaOperativaOficina.getState() === 'SUCCESS') {
					if (!responseComprobarTareaOperativaOficina.getReturnValue()) {*/
			component.set('v.mostrarAvisoOperativaOficina', true);
			component.set('v.continuarGuardarCerrar', true);
			component.set('v.botonGuardarCerrar', false);
			let esImagin = 	(
				component.get('v.caso.Account.AV_IndicadoresClientes__c') != null && 
				component.get('v.caso.Account.AV_IndicadoresClientes__c') != undefined  && 
				component.get('v.caso.Account.AV_IndicadoresClientes__c').includes('28')
			);
		// if (
		// 	( esImagin && component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Imagin__c') === 'Caso a Fraude' ) 
		// 	 ||
		// 	( !esImagin && component.get('v.caso.CC_MCC_Motivo__r.CC_Ambito_Tareas_Caixa__c') === 'Caso a Fraude' )
		// ) {
			helper.guardarCerrarAuxiliar(component);
		// }
		/*} else {
			// Código a ejecutar si ambas condiciones son verdaderas
						$A.util.addClass(component.find('modalOperativaOficina'), 'slds-fade-in-open');
						$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
						helper.guardar(component, responseValidarGuardar);
					}*/
		//}
		//});
		//$A.enqueueAction(comprobarTareaOperativaOficina);
		//}
	},
	validacionesLinksTF: function(component, event, helper) {
		let mccMotivoId = component.get('v.caso.CC_MCC_Motivo__c');
		let tieneFicha = component.get('v.caso.CC_MCC_Motivo__r.CC_Tipo_Ficha_TF__c');
		let caseOrigin  = component.get('v.caso.Origin');

		let canalesEscritos = ['Chat', 'Email','Comentarios Stores', 'Fax']; 		

		let autenticacionRequerida = true;
		if (canalesEscritos.includes(caseOrigin)) {
			autenticacionRequerida = false; //No se requiere autenticación para canales escritos
		}

		if (component.get('v.caso.CC_MCC_Motivo__r.CC_No_autenticar_TF__c')) {
        autenticacionRequerida = false; //No se requiere autenticación si el campo No Autenticar TF está marcado
		}

		 if (!autenticacionRequerida) {
        // Si no se requiere autenticación (es canal escrito o MCC tiene flag)
        if (tieneFicha) {
            let crearTarea = component.get('c.crearTareaTF9');
            crearTarea.setParams({recordId: component.get('v.recordId'), motivo: component.get('v.caso.CC_MCC_Motivo__r.CC_Tipo_Ficha_TF__c')});
            crearTarea.setCallback(this, response => {
                if (response.getState() === 'SUCCESS') {
                    let linkTF = response.getReturnValue();
                    if (linkTF) {
                        helper.recuperarMensajeToast(component, 'success', 'OK_TF');
                        window.open(linkTF, '_blank');
                    } else {
                        helper.recuperarMensajeToast(component, 'error', 'KO_TF');
                    }
                } else if (response.getState() === 'ERROR') {
                    helper.recuperarMensajeToast(component, 'error', 'ERROR_APEX_CREAR_TAREA'); // Nuevo mensaje de error para claridad
                }
            });
            $A.enqueueAction(crearTarea);
        } else {
            helper.recuperarMensajeToast(component, 'info', 'NO_FICHA');
        }

		} else {

		let comprobarAutenticacion = component.get('c.comprobarAutenticacion');
		comprobarAutenticacion.setParams({recordId: component.get('v.recordId')});
		comprobarAutenticacion.setCallback(this, response => {
			let statusUno = response.getState();
			if (response.getState() === 'SUCCESS') {
				let response1 = response.getReturnValue();
				if (response1 === true || component.get('v.caso.CC_MCC_Motivo__r.CC_No_autenticar_TF__c')) {
					if (tieneFicha) {
						let crearTarea = component.get('c.crearTareaTF9');
						crearTarea.setParams({recordId: component.get('v.recordId'), motivo: component.get('v.caso.CC_MCC_Motivo__r.CC_Tipo_Ficha_TF__c')});
						crearTarea.setCallback(this, response => {
							if (response.getState() === 'SUCCESS') {
								let linkTF = response.getReturnValue();
								if (linkTF) {
									//helper.mostrarToast('success', 'Se cerró correctamente la tarea', 'Se creo correctamente la tarea ');
									helper.recuperarMensajeToast(component, 'success', 'OK_TF');
									window.open(linkTF, '_blank');
								} else {
									//helper.mostrarToast('error', 'Error creando la tarea', 'Error en la creacion de la tarea');
									helper.recuperarMensajeToast(component, 'error', 'KO_TF');
								}
							}
						});
						$A.enqueueAction(crearTarea);

					} else {
						helper.recuperarMensajeToast(component, 'info', 'NO_FICHA');
						//helper.mostrarToast('info', 'Debes no hay link asociado', 'No hay link de TF relacionado con este Motivo');
					}

				} else {
					helper.recuperarMensajeToast(component, 'info', 'AUTENTICACION_NECESARIA');
					//helper.mostrarToast('info', 'Debes lanzar la autenticacion', 'Para utilizar esta operativa, debes primero autenticar al cliente desde Operativas');
				}


			} else if (response.getState() === 'ERROR') {
				helper.recuperarMensajeToast(component, 'info', 'ERROR_APEX_AUTENTICACION');

				//helper.mostrarToast('error', 'Error realizando las validaciones', 'Error en el Apex validando si hay autenticaciones');

			}

		});
		$A.enqueueAction(comprobarAutenticacion);

		}

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
		// component.set('v.valueInputDNI', null); // Cambiar por id?

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
		if (component.find('inputDNIOnboarding').get('v.value') == null || component.find('inputDNIOnboarding').get('v.value') == '') {
			component.set('v.botonValidarOnboarding', true);
		} else {
			component.set('v.botonValidarOnboarding', false);
		}
	},

	llamadaWSOnboarding: function(component, event, helper) {
		component.set('v.botonValidarOnboarding', true);
		let dni = component.find('inputDNIOnboarding').get('v.value');
		let wsOnboarding = component.get('c.llamadaWSOnboardingApex');
		wsOnboarding.setParams({
			'recordId': component.get('v.recordId'),
			'nif': dni
		});
		wsOnboarding.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let respuesta = response.getReturnValue();
				if (respuesta === 'El cliente no esta en proceso de Onboarding') {
					helper.recuperarMensajeToast(component, 'warning', 'CLIENTE_NO_ONBOARDING');
				} else if (respuesta === 'El cliente esta en proceso de Onboarding') {
					helper.recuperarMensajeToast(component, 'success', 'CLIENTE_PROCESO_ONBOARDING');
				}
			}
			$A.enqueueAction(component.get('c.modalOnboardingCerrar'));
		});
		$A.enqueueAction(wsOnboarding);
		component.set('v.botonValidarOnboarding', false);
	},

	envioCorreoOnboarding: function(component, event, helper) {
		component.set('v.onboardingDesistir', false);
		let envioCorreo = component.get('c.envioCorreoOnboardingApex');
		envioCorreo.setParams({'recordId': component.get('v.recordId')});
		envioCorreo.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				$A.enqueueAction(component.get('c.gestionaGuardarCerrar'));
			}
		});
		$A.enqueueAction(envioCorreo);
	},

	cerrarModalYaDerivado: function(component, event, helper) {
		component.set('v.onboardingYaDerivado', false);
		component.set('v.onboardingDesistir', false);
		$A.enqueueAction(component.get('c.gestionaGuardarCerrar'));
	}

	//-------Fin Metodos onboarding---------

	/*continuarGuardarCerrar: function(component) {
		component.set('v.continuarGuardarCerrar', true);
		$A.enqueueAction(component.get('c.gestionaGuardarCerrar'));
	}*/
});