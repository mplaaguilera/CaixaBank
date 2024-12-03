({
	doInit: function(component, event, helper) {
		let getRecType = component.get('c.getRecTypeCliente');
		getRecType.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.recordTypeNoCliente', response.getReturnValue());
			}
		})
		$A.enqueueAction(getRecType);
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
		
			//Gestión visual secciones
			component.set('v.bRes', false);
			component.set('v.bMostrarContactos', false);
			component.set('v.bMostrarRepresentantesPersonaFisica', false);
			component.set('v.bMostrarRepresentantesPersonaJuridica', false);
			component.set('v.bError', false);
			component.set('v.bInfo', false);


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
                //$A.get('e.force:refreshView').fire();
                component.set('v.bEsperaALF', false);
            });
            $A.enqueueAction(getIdentidad);
		
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

	asociarSoloAccSecundario: function(component, event, helper){
		//Gestión visual secciones
		let sCuenta = event.getSource().get('v.name');
		component.set('v.bEsperaSFDC', true);
		component.set('v.bRes', false);
		component.set('v.bError', false);
		component.set('v.bInfo', false);

		let sCaso = component.get('v.recordId');
		let action = component.get('c.crearReclamanteSecundario');
		action.setParams({'sID': sCuenta, 'sTipo': 'Cuenta', 'sCasoId': sCaso});
		action.setCallback(this, response => {
			component.set('v.bEsperaSFDC', false);
			if (response.getState() === 'SUCCESS') {
				//Contacto vinculado
				helper.mostrarToast('success', 'Se asoció correctamente el reclamante secundario al registro', 'Se asoció correctamente el reclamante secundario al registro.');
				component.set('v.sBusqueda', '');
			} else {
				//Mostrar error
				var errors = response.getError();
				//helper.mostrarToast('Error', 'Error', errors[0].message);
				helper.mostrarError(component, errors);
			}
			$A.get('e.force:refreshView').fire();
		});
		$A.enqueueAction(action);
	},

	asociarAcc: function(component, event, helper) {
		let sCuenta = event.getSource().get('v.name');
		component.set('v.bEsperaSFDC', true);
		let sTipoRegistro = component.get('v.sObjectName');
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
		
	},

	comprobarMultiplesReclamacionesContacto: function(component, event, helper){
		component.set('v.bEsperaSFDC', true);
		let contactId = event.getSource().get('v.name');
		component.set('v.rastroId', contactId);
		let action = component.get('c.comprobarMultiplesCasosCliente');
		action.setParams({'contactId': contactId, 'accountId': contactId});
		action.setCallback(this, response => {
			component.set('v.bEsperaSFDC', false);
			if (response.getState() === 'SUCCESS') {
				let sRetorno = response.getReturnValue();
				if (sRetorno) {
					component.set("v.modalSRultiplesCasos", true);
				}
				else{
					helper.asociarContacto(component, event);
				}
			} else {
				//Mostrar error
				component.set('v.bError', true);
				component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro.');
			}
			$A.get('e.force:refreshView').fire();
		});
		$A.enqueueAction(action);
	},

	comprobarMultiplesReclamacionesRepresentante: function(component, event, helper){
		component.set('v.bEsperaSFDC', true);
		let representante = event.getSource().get('v.name');
		component.set('v.rastroId', representante);
		let action = component.get('c.comprobarMultiplesCasosCliente');
		action.setParams({'contactId': representante, 'accountId': representante});
		action.setCallback(this, response => {
			component.set('v.bEsperaSFDC', false);
			if (response.getState() === 'SUCCESS') {
				let sRetorno = response.getReturnValue();
				if (sRetorno) {
					component.set("v.modalSRultiplesCasos", true);
				}
				else{
					helper.asociarRepresentante(component, event);
				}
			} else {
				//Mostrar error
				component.set('v.bError', true);
				component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro.');
			}
			$A.get('e.force:refreshView').fire();
		});
		$A.enqueueAction(action);
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
				component.set('v.contactoId',sRepresentanteId);
			} else {
				//Mostrar error
				var errors = response.getError();
                helper.mostrarError(component, errors);
				//helper.mostrarToast('Error', errors[0].message, 'error');
			}
			//$A.get('e.force:refreshView').fire();
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
            var pX = event.pageX - 150;
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

		finCargaSuccess: function(component, event, helper){
			component.set('v.modalCrearNoCliente', false);
			helper.insertarPermisos(component, event);
			helper.getRepresentantesOcontactos(component, event);
			
		},
		errorInsert: function(component, event, helper){
			component.set('v.esperaInsertNoCliente', false);
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"title": "Error",
				"message": "Ha surgido un error al insertar datos.",
				"type": "error"
			});
			toastEvent.fire();
			
		},
		handleSubmit: function(component, event, helper){
			component.set('v.esperaInsertNoCliente', true);
			event.preventDefault();
			const fields = event.getParam('fields');
			fields.PersonEmail = fields.CC_Email__c;
			component.find('recordEditForm').submit(fields);
			//component.set('v.modalCrearNoCliente', false);			
		},
    


seleccionarCuenta: function(component, event, helper) {
            let sCuenta = event.getSource().get('v.name');
            //component.set('v.bEsperaSFDC', true);
			//Llamada a Apex para insertar los shares sobre los accounts
			let insertarPermisos = component.get("c.insertarPermisosAccount");
			insertarPermisos.setParams({'cuenta': sCuenta});
			insertarPermisos.setCallback(this, function(response) {
				if(response.getState()==="SUCCESS"){
					component.set('v.cuentaId',sCuenta);
				}
			})
			$A.enqueueAction(insertarPermisos);

            //component.set('v.cuentaId',sCuenta);

			if(component.get('v.showContacts')===false){
				component.set('v.bRes',false);
			}
			


                let getRepresentantesOrContactosCliente;
                getRepresentantesOrContactosCliente = component.get('c.getRepresentantesOrContactosCliente');
                getRepresentantesOrContactosCliente.setParam('sCliente', sCuenta);
                getRepresentantesOrContactosCliente.setCallback(this, response => {
                    if (response.getState() === 'SUCCESS') {
                        let oRetorno = response.getReturnValue();
                        if (oRetorno !== null) {
                            if (oRetorno[0].representante !== undefined && oRetorno[0].representante !== false ) {
                                //Son representantes
                                component.set('v.oRepresentantes', oRetorno);
                                component.set('v.sTipoPersona', oRetorno[0].tipoPersonaCliente);
                                if (oRetorno[0].tipoPersonaCliente === 'F') {
                                    component.set('v.bMostrarRepresentantesPersonaFisica', true);
                                    component.set('v.bMostrarRepresentantesPersonaJuridica', false);
                                } else if (oRetorno[0].tipoPersonaCliente === 'J') {
                                    component.set('v.bMostrarRepresentantesPersonaJuridica', true);
                                    component.set('v.bMostrarRepresentantesPersonaFisica', false);
                                }
                            } else {

                                //Son contactos
                                if (oRetorno.length > 1) {
                                    //Hay más de un contacto
                                    component.set('v.oContactos', oRetorno);
                                    component.set('v.bMostrarContactos', true);
                                } else if (oRetorno.length === 1) {
                                    component.set('v.contactoId',oRetorno[0].idContacto);
                                    component.set('v.oContactos', oRetorno);
                                    component.set('v.bMostrarContactos', true);
                                }
                            }
                        }
                    } else {
                        //Mostrar error
                        component.set('v.bError', true);
                        component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro (consulta contactos/representantes).');
                    }
                   // $A.get('e.force:refreshView').fire();
                });
                $A.enqueueAction(getRepresentantesOrContactosCliente);
    },
    seleccionarContacto: function(component, event, helper) {
		let sContacto = event.getSource().get('v.name');
        component.set('v.contactoId', sContacto);
    }
});