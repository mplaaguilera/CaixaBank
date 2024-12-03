({
	doInit: function(component, event, helper) {
		helper.helpInit(component);

		var recuperarTipoCodigo = component.get("c.getPickListValuesIntoListTipoCodigo");
		recuperarTipoCodigo.setCallback(this, function(response){
			var state = response.getState();
			var options = [];
			//options = component.get('v.optionsCodigo');
			if (state === "SUCCESS") { 
				let titulos = response.getReturnValue();
				for (var miTitulo in titulos) {
					let titulo = titulos[miTitulo];
					options.push({ label: titulo.nombrePlantilla, value: titulo.idPlantilla });
				}            

				component.set('v.optionsCodigo', JSON.parse(JSON.stringify(options)));
			}
		});
		$A.enqueueAction(recuperarTipoCodigo);

		var recuperarIdioma = component.get("c.getPickListValuesIntoListIdioma");
		recuperarIdioma.setCallback(this, function(response){
			var state = response.getState();
			var options = component.get('v.optionsIdioma');
			if (state === "SUCCESS") { 
				let titulos = response.getReturnValue();
				for (var miTitulo in titulos) {
					let titulo = titulos[miTitulo];
					options.push({ label: titulo.nombrePlantilla, value: titulo.idPlantilla });
				}            

				component.set('v.optionsIdioma', JSON.parse(JSON.stringify(options)));
			}
		});
		$A.enqueueAction(recuperarIdioma);

		var recuperarSexo = component.get("c.getPickListValuesIntoListSexo");
		recuperarSexo.setCallback(this, function(response){
			var state = response.getState();
			var options = component.get('v.optionsSexo');
			if (state === "SUCCESS") { 
				let titulos = response.getReturnValue();
				for (var miTitulo in titulos) {
					let titulo = titulos[miTitulo];
					options.push({ label: titulo.nombrePlantilla, value: titulo.idPlantilla });
				}            

				component.set('v.optionsSexo', JSON.parse(JSON.stringify(options)));
			}
		});
		$A.enqueueAction(recuperarSexo);
	},

	recordUpdated: function(component, event) {
		if (event.getParams().changeType === 'CHANGED') {
			if ('CC_No_Identificado__c' in event.getParams().changedFields
				|| 'CC_Fecha_Fin__c' in event.getParams().changedFields
				|| 'AccountId' in event.getParams().changedFields
				|| 'ContactId' in event.getParams().changedFields) {
				$A.enqueueAction(component.get('c.doInit'));
			}
		}
	},

	buscarAlfabetico: function(component, event, helper) {
		helper.helpInit(component);
		if (component.get('v.sObjectName') === 'CC_Llamada__c' && component.get('v.llamadaFinalizada')) {
			helper.mostrarToast('error', 'Operativa no disponible', 'No se permite identificar manualmente porque la llamada está finalizada.');
		} else {
			//Gestión visual secciones
			component.set('v.bRes', false);
			component.set('v.bMostrarContactos', false);
			component.set('v.bMostrarRepresentantesPersonaFisica', false);
			component.set('v.bMostrarRepresentantesPersonaJuridica', false);
			component.set('v.bError', false);
			component.set('v.bInfo', false);

			let getEsPropietarioCaso = component.get('c.getEsPropietarioCaso');
			getEsPropietarioCaso.setParams({'recordId': component.get('v.recordId')});
			getEsPropietarioCaso.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					if (response.getReturnValue()) { //Es propietario
						component.set('v.bEsperaALF', true);
						let getIdentidad = component.get('c.getIdentidad');
						getIdentidad.setParams({
							'tipoBusqueda': component.find('tipoBusqueda').get('v.value'),
							'valorBusqueda': component.get('v.sBusqueda').trim()
						});
						getIdentidad.setCallback(this, response => {
							if (response.getState() === 'SUCCESS') {
								let oMap = response.getReturnValue();
								if (oMap !== null) {
									if (oMap.CUENTAS.length > 0) {
										component.set('v.bRes', true);
										component.set('v.oCuentas', oMap.CUENTAS);
									} else {
										//Mostrar mensaje sin resultados
										component.set('v.bError', true);
										component.set('v.sMensErr', 'No se ha identificado ningún cliente.');
									}
								} else {
									//Mostrar mensaje sin resultados
									component.set('v.bError', true);
									component.set('v.sMensErr', 'No se ha identificado ningún cliente.');
								}
							} else {
								//Mostrar error
								component.set('v.bError', true);
								component.set('v.sMensErr', 'Se ha producido un error al realizar la consulta.');
							}
							//Refrescar vista
							$A.get('e.force:refreshView').fire();
							component.set('v.bEsperaALF', false);
						});
						$A.enqueueAction(getIdentidad);
					} else {
						component.set('v.bError', true);
						component.set('v.sMensErr', 'Debe ser propietario del registro para poder iniciar la identificación.');
					}
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al realizar la consulta.');
				}
			});
			$A.enqueueAction(getEsPropietarioCaso);
		}
	},

	navegarOrigen: function(component, event) {
		let sObectEvent = $A.get('e.force:navigateToSObject');
		sObectEvent.setParams({'recordId': event.srcElement.name});
		sObectEvent.fire();
	},

	asociarSoloAcc: function(component, event, helper) {
		component.set('v.rastroId', event.getSource().get('v.name'));
		helper.asociarSoloAcc(component, event);
	},

	asociarSoloAccPopUp: function(component, event, helper) {
		component.set('v.bEsperaPopUp', true);
		helper.asociarSoloAcc(component, event);
		component.set('v.modalSRultiplesCasos', false);
	},

	asociarAcc: function(component, event, helper) {
		let sCuenta = event.getSource().get('v.name');
		component.set('v.bEsperaSFDC', true);
		let sTipoRegistro = component.get('v.sObjectName');
		if (sTipoRegistro === 'Case') {
			let sCaso = component.get('v.recordId');
			let action = component.get('c.setClienteCaso');
			action.setParams({'sID': sCuenta, 'sTipo': 'Cuenta', 'sCasoId': sCaso});
			action.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				component.set('v.bError', false);
				if (response.getState() === 'SUCCESS') {
		
				} else {
					//Mostrar error
					var errors = response.getError();
					helper.mostrarError(component, errors);
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(action);
		} else if (sTipoRegistro === 'CC_Llamada__c') {
			let sLlamada = component.get('v.recordId');
			let setClienteLlamada = component.get('c.setClienteLlamada');
			setClienteLlamada.setParams({'sID': sCuenta, 'sTipo': 'Cuenta', 'sLlamadaId': sLlamada});
			setClienteLlamada.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				component.set('v.bError', false);
				if (response.getState() === 'SUCCESS') {
					let sRetorno = response.getReturnValue();
					if (sRetorno !== null) {
						if (sRetorno !== '') {
							//Error detectado
							component.set('v.bError', true);
							component.set('v.sMensErr', sRetorno);
						}
						component.set('v.cuentaId', sCuenta);
						helper.openSubtabCuenta(component, false);
					}
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al realizar la actualización de la llamada.');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(setClienteLlamada);
		}
	},

	comprobarMultiplesReclamacionesContacto: function(component, event, helper){
		component.set('v.bEsperaSFDC', true);
		let contactId = event.getSource().get('v.name');
		component.set('v.rastroId', contactId);
		let casoRelacionado = component.get('v.SAC_casoRelacionado');
		let rt = component.get('v.sacTipoDeCaso');
		let origen = component.get('v.origenConsulta');

		if(rt == 'SAC_Consulta'){
			if(origen === undefined){
				let toastEvent = $A.get('e.force:showToast');
				toastEvent.setParams({'title': 'Fallo al actualizar.', 'message': 'Para gestionar la consulta primero debe de indicar el origen de la misma.', 'type': 'error', 'mode': 'dismissable', 'duration': 4000});
				toastEvent.fire();
			}else{
				helper.asociarContacto(component, event);
			}
		} else if(rt == 'SAC_Reclamacion' && (casoRelacionado != null) ) {
			helper.asociarContacto(component, event);
		} else{
			let action = component.get('c.comprobarMultiplesCasosCliente');
			action.setParams({'contactId': contactId, 'accountId': contactId});
			action.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
						helper.asociarContacto(component, event);
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro.');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(action);
		}
		
	},

	comprobarMultiplesReclamacionesRepresentante: function(component, event, helper){
		component.set('v.bEsperaSFDC', true);
		let representante = event.getSource().get('v.name');
		component.set('v.rastroId', representante);
		let casoRelacionado = component.get('v.SAC_casoRelacionado');
		let rt = component.get('v.sacTipoDeCaso');
		let origen = component.get('v.origenConsulta');

		if(rt == 'SAC_Consulta'){
			if(origen === undefined){
				let toastEvent = $A.get('e.force:showToast');
				toastEvent.setParams({'title': 'Fallo al actualizar.', 'message': 'Para gestionar la consulta primero debe de indicar el origen de la misma.', 'type': 'error', 'mode': 'dismissable', 'duration': 4000});
				toastEvent.fire();
			}else{
				helper.asociarRepresentante(component, event);
			}
			
		}else if(rt == 'SAC_Reclamacion' && (casoRelacionado != null) ) {
			helper.asociarRepresentante(component, event);
		} else{
			let action = component.get('c.comprobarMultiplesCasosCliente');
			action.setParams({'contactId': representante, 'accountId': representante});
			action.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
						helper.asociarRepresentante(component, event);
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro.');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(action);
		}
	},

	comprobarCaractCliente: function(component, event, helper) {
		
		let idAccount = event.getSource().get('v.name');
		let rt = component.get('v.sacTipoDeCaso');

		if(rt == 'SAC_Consulta' || rt == 'SAC_ConsultaSAC'){
			if(component.get('v.bRes') === true && component.get('v.identificacionPrevia') !== undefined){
				helper.asociarSoloAccSecundario(component, event);
			}
			if(component.get('v.bRes') === true && component.get('v.identificacionPrevia') === undefined){
				helper.comprobarMultiplesReclamacionesCuenta(component, event);
			}
		}else{
			let action = component.get('c.comprobarCaracteristicasCliente');
			action.setParams({'accountId': idAccount});
			action.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					component.set('v.caracteristicasCliente', response.getReturnValue());
					let caracteristicas = response.getReturnValue();

					if(caracteristicas.length > 0 ){
						for ( let i = 0; i < caracteristicas.length; i++ ) {
							let caracteristica = caracteristicas[i];
							if ( caracteristica.CC_Caracteristica__r.Name ) {
								caracteristica.CC_Caracteristica__rName = caracteristica.CC_Caracteristica__r.Name;
							}
							if ( caracteristica.CC_Caracteristica__r.CC_Descripcion__c ) {
								caracteristica.CC_Caracteristica__rCC_Descripcion__c = caracteristica.CC_Caracteristica__r.CC_Descripcion__c;
							}
							
						}
						component.set("v.CaracteristicasList", caracteristicas);
						component.set('v.caracteristicasColumns', [
												{label: 'Nombre', fieldName: 'CC_Caracteristica__rName', type: 'text', wrapText: true},
												{label: 'Descripcion', fieldName: 'CC_Caracteristica__rCC_Descripcion__c', type: 'text', wrapText: true}
											]);
						component.set('v.modalCaracteristicas', true);
						component.set("v.miEvento", event);

					}else{
						if(component.get('v.bRes') === true && component.get('v.identificacionPrevia') !== undefined){
							helper.asociarSoloAccSecundario(component, event);
						}
						if(component.get('v.bRes') === true && component.get('v.identificacionPrevia') === undefined){
							helper.comprobarMultiplesReclamacionesCuenta(component, event);
						}
						
					}
					
				} else {
					//Mostrar error
					var errors = response.getError();
					helper.mostrarError(component, errors);
				}
				$A.get('e.force:refreshView').fire();
			});
			
			$A.enqueueAction(action);
		}
	},

	cerrarModalCaracteristicas: function(component, event, helper) {
		component.set('v.modalCaracteristicas', false);

		var miEvento = component.get("v.miEvento");
		if(miEvento){
			if(component.get('v.bRes') === true && component.get('v.identificacionPrevia') !== undefined){
				helper.asociarSoloAccSecundario(component, miEvento);
			}
			if(component.get('v.bRes') === true && component.get('v.identificacionPrevia') === undefined){
				helper.comprobarMultiplesReclamacionesCuenta(component, miEvento);
			}
		}
		
	},

	asociarRepresentante: function(component, event, helper) {
		component.set('v.rastroId', event.getSource().get('v.name'));
		helper.asociarRepresentante(component, event);
	},

	asociarRepresentantePopUp: function(component, event, helper) {
		component.set('v.bEsperaPopUp', true);
		helper.asociarRepresentante(component, event);
		component.set('v.modalSRultiplesCasos', false);
	},

	asociarRepresentanteSecundario : function(component, event, helper){
		let sRepresentanteId = event.getSource().get('v.name');
		component.set('v.bEsperaSFDC', true);
		component.set('v.bRes', false);
		component.set('v.bError', false);
		component.set('v.bInfo', false);

		let sCaso = component.get('v.recordId');
		let action = component.get('c.crearReclamanteSecundario');
		action.setParams({'sID': sRepresentanteId, 'sTipo': 'Representante', 'sCasoId': sCaso});
		action.setCallback(this, response => {
			component.set('v.bEsperaSFDC', false);
			if (response.getState() === 'SUCCESS') {
				//Contacto vinculado
				helper.mostrarToast('success', 'Se asoció correctamente el reclamante secundario al registro', 'Se asoció correctamente el reclamante secundario al registro.');
				component.set('v.sBusqueda', '');
			} else {
				//Mostrar error
				var errors = response.getError();
                helper.mostrarError(component, errors);
				//helper.mostrarToast('Error', errors[0].message, 'error');
			}
			$A.get('e.force:refreshView').fire();
		});
		$A.enqueueAction(action);
	},

	asociarContacto: function(component, event, helper) {
		component.set('v.rastroId', event.getSource().get('v.name'));
		helper.asociarContacto(component, event);
	},

	asociarContactoPopUp: function(component, event, helper) {
		component.set('v.bEsperaPopUp', true);
		helper.asociarContacto(component, event);
		component.set('v.modalSRultiplesCasos', false);
	},

	asociarReclamanteSecundario: function(component, event, helper) {
		let sContactoId = event.getSource().get('v.name');
		component.set('v.bEsperaSFDC', true);
		component.set('v.bRes', false);
		component.set('v.bError', false);
		component.set('v.bInfo', false);

		let sCaso = component.get('v.recordId');
		let action = component.get('c.crearReclamanteSecundario');
		action.setParams({'sID': sContactoId, 'sTipo': 'Contacto', 'sCasoId': sCaso});
		action.setCallback(this, response => {
			component.set('v.bEsperaSFDC', false);
			if (response.getState() === 'SUCCESS') {
				//Contacto vinculado
				helper.mostrarToast('success', 'Se asoció correctamente el reclamante secundario al registro', 'Se asoció correctamente el reclamante secundario al registro.');
				component.set('v.sBusqueda', '');
				helper.passDataToLWCsac_Reclamantes(component);
			} else {
				//Mostrar error
				var errors = response.getError();
                helper.mostrarError(component, errors);
				//helper.mostrarToast('Error', errors[0].message, 'error');
			}
			$A.get('e.force:refreshView').fire();
		});
		$A.enqueueAction(action);
	},

	volverACuentas: function(component) {
		component.set('v.bEsperaSFDC', false);
		component.set('v.bRes', true);
		component.set('v.bMostrarContactos', false);
		component.set('v.bMostrarRepresentantesPersonaFisica', false);
		component.set('v.bMostrarRepresentantesPersonaJuridica', false);
		component.set('v.bError', false);
		component.set('v.bInfo', false);
		$A.get('e.force:refreshView').fire();
	},

	valorBusquedaTeclaPulsada: function(component, event) {
		if (event.which === 13) { //Intro
			$A.enqueueAction(component.get('c.buscarAlfabetico'));
		}
	},

	handleActualizarIdentificacion: function(component, event, helper) {
		component.set('v.bEsperaSFDC', true);
		let action = component.get('c.actualizarIdentificacion');
		action.setParams({'recordId': component.get('v.recordId'), 'noIdentificado': true, 'tipoRegistro': component.get('v.sObjectName')});
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.clienteNoIdentificado', true);
				helper.mostrarToast('info', 'Cliente no se ha identificado', 'El cliente ' + (component.get('v.sObjectName') === 'Case' ? 'del caso' : 'de la llamada') + ' no se ha identificado.');
			}
			$A.get('e.force:refreshView').fire();
			component.set('v.bEsperaSFDC', false);
		});
		$A.enqueueAction(action);
	},

	handleChange: function(component) {
		component.set('v.bInfo', false);
		component.set('v.bError', false);

		if (!component.get('v.sBusqueda')) {
			component.set('v.bRes', false);
			component.set('v.bMostrarContactos', false);
			component.set('v.bMostrarRepresentantesPersonaFisica', false);
			component.set('v.bMostrarRepresentantesPersonaJuridica', false);
		}
	},

	modalCerrar : function(component, event, helper) {      	
		helper.modalCerrar(component, event);
	},

	asignarCliente : function(component, event, helper) {
		var idCase = component.get("v.recordId");

		var actValidacionMultiple = component.get("c.multiplesCasosMismoAccount");
        actValidacionMultiple.setParams({
            'caseId': idCase
        });

        actValidacionMultiple.setCallback(this, function(response) {
			var state = response.getState();
			
            if(state == "SUCCESS") {
				if (response.getReturnValue() && component.get("v.modalSRultiplesCasos") === false)
				{
					component.set("v.modalSRultiplesCasos", true);
				}
                else{
					var action = component.get("c.tomarPropiedadCaso");
					action.setParams({
						'caseId': idCase
					});
						
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"title": "Éxito!",
						"message": "Se ha cambiado el propietario correctamente.",
						"type": "success"
					});
					
					action.setCallback(this, function(response) {
						var state = response.getState();
						if(state == "SUCCESS") {
							component.set("v.modalSRultiplesCasos", false);
							component.set("v.accts", response.getReturnValue());
							toastEvent.fire();
							//window.location.reload();
							$A.get('e.force:refreshView').fire();
							helper.reinit(component);
							
						}
						else
						{
							var errors = response.getError();
							let toastParams = {
								title: "Error",
								message: errors[0].message, 
								type: "error"
							};
							let toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams(toastParams);
							toastEvent.fire();
							component.set("v.modalSRultiplesCasos", false);
						}
					});
					
					$A.enqueueAction(action);
				}
			}
        });
		$A.enqueueAction(actValidacionMultiple);
		
	},
    
        muestaDatosRegistro: function(component, event, helper){
            //alert("ID: " +event.srcElement.name);
            var cmpTarget = component.find('pop');
            $A.util.addClass(cmpTarget, 'slds-show');
            $A.util.removeClass(cmpTarget, 'slds-hide');
            
            var pY = event.clientY -135;
            var pX = event.clientX - 420;
            component.set("v.cardStyle", "top: "+pY+"px; left:"+pX+"px; position: fixed; height:270px; width:400px;");
            component.set("v.cardClienteId", event.srcElement.name);
        },
        ocultaDatosRegistro: function(component, event, helper){
            //alert("Salimos"+event.clientX);
            var cmpTarget = component.find('pop');
            $A.util.addClass(cmpTarget, 'slds-hide');
            $A.util.removeClass(cmpTarget, 'slds-show');
        },
		crearNoCliente: function(component, event, helper){
			component.set("v.modalCrearNoCliente", true);
		},
		ocultaModal: function(component, event, helper){
			component.set("v.modalCrearNoCliente", false);
		},
		guardarNoCliente: function(component, event, helper){
			//console.log('click guardar');
		},

		handleChangeCodigo : function(component, event, helper){

			component.set('v.newAccount.SAC_TipoDeCodigo__c', event.getParam("value"));

		},

		handleChangeSexo : function(component, event, helper){

			component.set('v.newAccount.CC_Sexo__pc', event.getParam("value"));

		},

		handleChangeIdioma : function(component, event, helper){

			component.set('v.newAccount.CC_Idioma__pc', event.getParam("value"));

		},

		handleChangeFname : function(component, event, helper){

			component.set('v.newAccount.FirstName', event.getParam("value"));
		},

		handleChangeLname : function(component, event, helper){

			component.set('v.newAccount.LastName', event.getParam("value"));

		},

		handleChangeFechaNac : function(component, event, helper){

			component.set('v.newAccount.CC_FechaNac__pc', event.getParam("value"));

		},

		handleChangePhone : function(component, event, helper){

			component.set('v.newAccount.Phone', event.getParam("value"));

		},

		handleChangeEmail : function(component, event, helper){
			
			component.set('v.newAccount.CC_Email__c', event.getParam("value"));

		},

		handleChangeNumDoc : function(component, event, helper){

			component.set('v.newAccount.CC_Numero_Documento__c', event.getParam("value"));

		},

		handleChangeStreet : function(component, event, helper){

			component.set('v.newAccount.BillingStreet', event.getParam("value"));

		},

		handleChangePostal : function(component, event, helper){

			component.set('v.newAccount.BillingPostalCode', event.getParam("value"));

		},

		handleChangeCity : function(component, event, helper){

			component.set('v.newAccount.BillingCity', event.getParam("value"));

		},

		handleChangeState : function(component, event, helper){

			component.set('v.newAccount.BillingState', event.getParam("value"));
	
		},

		handleChangeCountry : function(component, event, helper){

			component.set('v.newAccount.BillingCountry', event.getParam("value"));

		},

		insertNoCliente: function(component, event, helper){
			let crearNoCliente = component.get("c.crearNoCli");
			crearNoCliente.setParams({'firstName': component.get('v.newAccount.FirstName'),
										'lastName': component.get('v.newAccount.LastName'),
										'personEmail': component.get('v.newAccount.CC_Email__c'),
										//'CC_FechaNac': component.get('v.newAccount.CC_FechaNac__pc'),
										'phone': component.get('v.newAccount.Phone'),
										'sacTipoDeCodigo': component.get('v.newAccount.SAC_TipoDeCodigo__c'),
										'ccNumeroDocumento': component.get('v.newAccount.CC_Numero_Documento__c'),
										//'CC_Idioma': component.get('v.newAccount.CC_Idioma__pc'),
										//'CC_Sexo': component.get('v.newAccount.CC_Sexo__pc'),
										'billingStreet': component.get('v.newAccount.BillingStreet'),
										'billingPostalCode': component.get('v.newAccount.BillingPostalCode'),
										'billingCity': component.get('v.newAccount.BillingCity'),
										'billingState': component.get('v.newAccount.BillingState'),
										'billingCountry': component.get('v.newAccount.BillingCountry')
										});

			if(component.get('v.newAccount.FirstName') == '' || component.get('v.newAccount.LastName') == '' || component.get('v.newAccount.SAC_TipoDeCodigo__c') == '' || component.get('v.newAccount.CC_Numero_Documento__c') == '' /*|| component.get('v.newAccount.CC_FechaNac__pc') == ''*/){
				var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								"title": "Error!",
								"message": "Faltan campos obligatorios por rellenar.",
								"type": "error"
							});
							toastEvent.fire();
			}else{
				component.set('v.isLoading', true);
				component.set('v.modalCrearNoCliente', false);

				crearNoCliente.setCallback(this, function(response) {
					if(response.getState()==="SUCCESS"){

						component.set('v.esperaInsertNoCliente', true);
						component.set('v.isLoading', false);
						var idCase = component.get("v.recordId");
	
						//llamada a apex para vincular el recordId del no cliente como reclamante principal o secunadario del objeto case 
						let actualizarcaso = component.get("c.actualizarReclamanteNoCliente");
						actualizarcaso.setParams({'caseId': idCase, 'accountId': response.getReturnValue()});
						actualizarcaso.setCallback(this, function(response) {
						if(response.getState()==="SUCCESS"){
							component.set('v.identificacionPrevia', true);
							var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								"title": "Éxito!",
								"message": "Se ha insertado el registro correctamente.",
								"type": "success"
							});
							toastEvent.fire();
							component.set('v.esperaInsertNoCliente', false);
							$A.get('e.force:refreshView').fire();
							helper.passDataToLWCsac_Reclamantes(component);
						}
						else{
							var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								"title": "Error",
								"message": "Ha surgido un error al insertar datos.",
								"type": "error"
							});
							toastEvent.fire();
							component.set('v.esperaInsertNoCliente', false);
						}
					})
					$A.enqueueAction(actualizarcaso);
						}else{
							component.set('v.modalCrearNoCliente', true);
							component.set('v.isLoading', false);
							var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								"title": "Error",
								"message": "Ha surgido un error al insertar datos, revise los datos introducidos.",
								"type": "error"
							});
							toastEvent.fire();

						}
					})
	
				$A.enqueueAction(crearNoCliente);
			}
		}
});