({
  init: function (component, event, helper) {
    var idCaso = component.get("v.recordId");
    var getCaso = component.get("c.recuperarCaso");
    getCaso.setParam("caseId", idCaso);

    getCaso.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var casoActual = response.getReturnValue();
        component.set("v.caso", casoActual);
        var recordType = component.get("v.caso.RecordType.DeveloperName");
        var propietarioCaso = component.get("v.caso.OwnerId");
        component.set('v.para', component.get("v.caso.OS_Email__c"));

        if(casoActual.RecordType.Name == 'Reclamacion'){
          if(casoActual.CC_AcuseRecibo__c === '2'){
            component.set('v.acuseReciboEnviado', true);
          }
          if(casoActual.CC_Idioma__c != undefined){
            component.set('v.idiomaInformado', true);
          }
        }

        var getUser = component.get("c.recuperarUser");
        getUser.setParams({
          casoActual: casoActual,
          ownerCaso: propietarioCaso
        });
        getUser.setCallback(this, function (response) {
          let resp = response.getReturnValue();
          component.set("v.user", resp.UserId);
          component.set("v.isGestor", resp.SAC_General != undefined);
          component.set(
            "v.esPropietario",
            component.get("v.user") === component.get("v.caso.OwnerId")
          );
          component.set(
            "v.mostrarSupervisor",
            resp.mostrarSupervisor != undefined
          );
          component.set("v.showAllButtons", true);

          if (recordType == "SAC_Reclamacion") {
            var tienePretensiones = component.get("c.tienePretensiones");
            tienePretensiones.setParam("idCaso", component.get("v.recordId"));
            tienePretensiones.setCallback(this, function (response) {
              var wrapper = response.getReturnValue();
              component.set("v.tienePretensiones", wrapper.tienePretensiones);
              component.set("v.tienePretensionesPSD2", wrapper.tienePretensionesPSD2);
            });
            $A.enqueueAction(tienePretensiones);

            var propietarioGrupoCops = component.get("c.propietarioCOPSAdministrador");
            propietarioGrupoCops.setParams({ caso: casoActual });
            propietarioGrupoCops.setCallback(this, function (response) {
              component.set("v.propietarioCOPSOAdmin", response.getReturnValue());
            });
            $A.enqueueAction(propietarioGrupoCops);

            var esGrupoLetrados = component.get("c.esGrupoLetrado");
            esGrupoLetrados.setCallback(this, function (response) {
              component.set("v.esGrupoLetrado", response.getReturnValue());
            });
            $A.enqueueAction(esGrupoLetrados);

            var OwnerId = $A.get("$SObjectType.CurrentUser.Id");
            var idCase = component.get("v.recordId");

            var mostrarBtnPrePrincipal = component.get(
              "c.esPropietarioFamiliaCaso"
            );
            mostrarBtnPrePrincipal.setParams({
              caseId: idCase,
              userActual: OwnerId
            });
            mostrarBtnPrePrincipal.setCallback(this, function (response) {
              component.set(
                "v.usarBtnPretePrincipal",
                response.getReturnValue()
              );
            });
            $A.enqueueAction(mostrarBtnPrePrincipal);
          } else if (recordType == "SAC_Pretension") {
            var OwnerId = $A.get("$SObjectType.CurrentUser.Id");
            var idCase = component.get("v.recordId");

            var mostrarBtnPrePrincipal = component.get(
              "c.esPropietarioFamiliaCaso"
            );
            mostrarBtnPrePrincipal.setParams({
              caseId: idCase,
              userActual: OwnerId
            });
            mostrarBtnPrePrincipal.setCallback(this, function (response) {
              component.set(
                "v.usarBtnPretePrincipal",
                response.getReturnValue()
              );
            });
            $A.enqueueAction(mostrarBtnPrePrincipal);
          }
        });
        $A.enqueueAction(getUser);
      }
    });

    $A.enqueueAction(getCaso);
  },

  tomarPropiedad: function (component, event, helper) {
    component.set("v.isLoading", true);
    var idCase = component.get("v.recordId");
    var OwnerId = $A.get("$SObjectType.CurrentUser.Id");

    var actValidacionMultiple = component.get("c.multiplesCasosMismoAccount");
    actValidacionMultiple.setParams({
      caseId: idCase,
      ownerId: OwnerId
    });

    actValidacionMultiple.setCallback(this, function (response) {
      var state = response.getState();

      if (state == "SUCCESS") {
        if (
          response.getReturnValue() &&
          component.get("v.modalSRultiplesCasos") === false
        ) {
          component.set("v.modalSRultiplesCasos", true);
          component.set("v.isLoading", false);
        } else {
          var action = component.get("c.tomarPropiedadCaso");
          action.setParams({
            caseId: idCase,
            ownerId: OwnerId
          });

          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Éxito!",
            message: "Se ha cambiado el propietario correctamente.",
            type: "success"
          });

          action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
              component.set("v.modalSRultiplesCasos", false);
              component.set("v.isLoading", false);
              component.set("v.accts", response.getReturnValue());
              toastEvent.fire();
              //window.location.reload();
              $A.get("e.force:refreshView").fire();
              helper.reinit(component);
            } else {
              component.set("v.modalSRultiplesCasos", false);
              component.set("v.isLoading", false);

              var errors = response.getError();
              let toastParams = {
                title: "Error",
                message: errors[0].message,
                type: "error"
              };

              let toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams(toastParams);
              toastEvent.fire();
            }
          });

          $A.enqueueAction(action);
        }
      }
    });
    $A.enqueueAction(actValidacionMultiple);
  },

  tomarPropiedadConsulta: function (component, event, helper) {
    component.set("v.isLoading", true);
    var idCase = component.get("v.recordId");
    var OwnerId = $A.get("$SObjectType.CurrentUser.Id");

    var actValidacionMultiple = component.get(
      "c.multiplesCasosMismoAccountConsulta"
    );
    actValidacionMultiple.setParams({
      caseId: idCase,
      ownerId: OwnerId
    });

    actValidacionMultiple.setCallback(this, function (response) {
      var state = response.getState();

      if (state == "SUCCESS") {
        if (
          response.getReturnValue() &&
          component.get("v.modalSRultiplesCasos") === false
        ) {
          component.set("v.modalSRultiplesCasos", true);
          component.set("v.isLoading", false);
        } else {
          var action = component.get("c.tomarPropiedadCasoConsulta");
          action.setParams({
            caseId: idCase,
            ownerId: OwnerId
          });

          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Éxito!",
            message: "Se ha cambiado el propietario correctamente.",
            type: "success"
          });

          action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
              component.set("v.modalSRultiplesCasos", false);
              component.set("v.isLoading", false);
              component.set("v.accts", response.getReturnValue());
              toastEvent.fire();
              $A.get("e.force:refreshView").fire();
              helper.reinit(component);
            } else {
              component.set("v.modalSRultiplesCasos", false);
              component.set("v.isLoading", false);

              var errors = response.getError();
              let toastParams = {
                title: "Error",
                message: errors[0].message,
                type: "error"
              };
              let toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams(toastParams);
              toastEvent.fire();
            }
          });

          $A.enqueueAction(action);
        }
      }
    });
    $A.enqueueAction(actValidacionMultiple);
  },

  tomarPropiedadPretensiones: function (component, event, helper) {
    component.set("v.isLoading", true);
    var idCase = component.get("v.recordId");
    var OwnerId = $A.get("$SObjectType.CurrentUser.Id");
    let modalAvisoMCC = component.get("v.modalAvisomcc");

    if (modalAvisoMCC) {
      component.set("v.modalAvisomcc", false);
    }

    var action = component.get("c.tomarPropiedadPretensionesApex");
    action.setParams({
      caseId: idCase,
      ownerId: OwnerId
    });

    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: "Éxito!",
      message: "Se ha cambiado el propietario correctamente.",
      type: "success"
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        //component.set("v.modalSRultiplesCasos", false);
        component.set("v.isLoading", false);
        //component.set("v.accts", response.getReturnValue());
        toastEvent.fire();
        setTimeout(
          $A.getCallback(function () {
            var a = component.get("c.init");
            $A.enqueueAction(a);
          }),
          1000
        );

        //window.location.reload();
        $A.get("e.force:refreshView").fire();
        //helper.reinit(component);
      } else {
        component.set("v.modalSRultiplesCasos", false);
        component.set("v.isLoading", false);

        var errors = response.getError();
        let toastParams = {
          title: "Error",
          message: errors[0].message,
          type: "error"
        };

        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
      }
    });

    $A.enqueueAction(action);

    /*var actValidacionMultiple = component.get("c.multiplesCasosMismoAccount");
        actValidacionMultiple.setParams({
            'caseId': idCase,  
            'ownerId' : OwnerId
        });

        actValidacionMultiple.setCallback(this, function(response) {
			var state = response.getState();
            if(state == "SUCCESS") {
				if (response.getReturnValue() && component.get("v.modalSRultiplesCasos") == false)
				{
					
					component.set("v.modalSRultiplesCasos", true);
					component.set('v.isLoading', false);
				}
                else{
					var action = component.get("c.tomarPropiedadPretensiones");
					action.setParams({
						'caseId': idCase,  
						'ownerId' : OwnerId
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
							component.set('v.isLoading', false);
							component.set("v.accts", response.getReturnValue());
							toastEvent.fire();
							//window.location.reload();
							$A.get('e.force:refreshView').fire();
							helper.reinit(component);
							
						}
						else
						{
	
							component.set("v.modalSRultiplesCasos", false);
							component.set('v.isLoading', false);

							var errors = response.getError();
							let toastParams = {
								title: "Error",
								message: errors[0].message, 
								type: "error"
							};

							let toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams(toastParams);
							toastEvent.fire();
						}
					});
					
					$A.enqueueAction(action);
				}
			}
        });
		$A.enqueueAction(actValidacionMultiple);
		*/
  },

  modalCerrar: function (component, event, helper) {
    component.set("v.modalSRultiplesCasos", false);
  },
  abrirModalAdvertenciaDevolver: function (component, event, helper) {
    var idCase = component.get("v.recordId");
    var OwnerId = $A.get("$SObjectType.CurrentUser.Id");

    var actValidacionMultiple = component.get(
      "c.multiplesCasosMismoAccountAsignados"
    );
    actValidacionMultiple.setParams({
      caseId: idCase,
      ownerId: OwnerId
    });

    actValidacionMultiple.setCallback(this, function (response) {
      var state = response.getState();

      if (state == "SUCCESS" && response.getReturnValue()) {
        component.set("v.modalAdvertencia", true);
      } else {
        helper.fetchMotivos(component, event);
        component.set("v.modalCola", true);
        component.set("v.selectedMotivo", null);
      }
    });
    $A.enqueueAction(actValidacionMultiple);
  },

  abrirModalAdvertenciaDevolverPret: function (component, event, helper) {
    helper.fetchMotivos(component, event);
    component.set("v.modalColaPretensiones", true);
  },

  cerrarModalAdvertenciaDevolverPret: function (component, event, helper) {
    component.set("v.modalColaPretensiones", false);
  },

  devolverAColaPretensiones: function (component, event, helper) {
    component.set("v.isLoading", true);
    var idCase = component.get("v.recordId");
    var motivoDevolucion = component.get("v.selectedMotivoPret");
    var devolverPretensionesCola = component.get("c.devolverPretensionesApex");
    devolverPretensionesCola.setParams({
      caseId: idCase,
      motivo: motivoDevolucion
    });
    devolverPretensionesCola.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        component.set("v.modalColaPretensiones", false);
        component.set("v.isLoading", false);
        $A.get("e.force:refreshView").fire();

        component.set("v.modalColaPretensiones", false);
        component.set("v.isLoading", false);
        setTimeout(
          $A.getCallback(function () {
            var a = component.get("c.init");
            $A.enqueueAction(a);
          }),
          1000
        );

        //window.location.reload();
        $A.get("e.force:refreshView").fire();
      } else {
        component.set("v.modalColaPretensiones", false);
        component.set("v.isLoading", false);
        $A.get("e.force:refreshView").fire();
        helper.reinit(component);
        helper.mostrarToast(
          "error",
          "Error",
          "El caso no se ha devuelto a la cola genérica"
        );
      }
    });
    $A.enqueueAction(devolverPretensionesCola);
  },

  abrirModalAdvertenciaDevolverConsulta: function (component, event, helper) {
    var idCase = component.get("v.recordId");
    var OwnerId = $A.get("$SObjectType.CurrentUser.Id");

    var actValidacionMultiple = component.get(
      "c.casosMismoAccountAsignadosConsulta"
    );
    actValidacionMultiple.setParams({
      caseId: idCase,
      ownerId: OwnerId
    });

    actValidacionMultiple.setCallback(this, function (response) {
      var state = response.getState();

      if (state == "SUCCESS" && response.getReturnValue()) {
        component.set("v.modalAdvertencia", true);
      } else {
        helper.fetchMotivos(component, event);
        component.set("v.modalCola", true);
        component.set("v.selectedMotivo", null);
      }
    });
    $A.enqueueAction(actValidacionMultiple);
  },

  abrirModalSegBO: function (component, event, helper) {
    helper.fetchMotivos(component, event);
    component.set("v.modalAdvertencia", false);
    component.set("v.modalCola", true);
    component.set("v.selectedMotivo", null);
  },

  devolverACola: function (component, event, helper) {
    component.set("v.isLoading", true);
    var idCase = component.get("v.recordId");
    var motivos = component.get("v.motivosDevolver");
    var motivo = component.get("v.selectedMotivo");
    var motivoLabel;

    if (motivo != null) {
      var obserInput = component.find("observacionId").get("v.value");

      if (motivo == "SAC_Otros" && obserInput == undefined) {
        component.set("v.isLoading", false);

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Error!",
          message: "Si el motivo es 'Otros' debes informar una observación.",
          type: "error"
        });

        toastEvent.fire();
      } else {
        motivoLabel = motivos.find(function (item) {
          return item.value == motivo;
        }).label;

        var devolver = component.get("c.devolverCaso");
        var publicar = component.get("c.postOnChatter");
        publicar.setParams({
          caseId: idCase,
          observacion: obserInput,
          motivo: motivoLabel
        });
        devolver.setParams({ caseId: idCase, motivo: motivo });

        $A.enqueueAction(devolver);

        devolver.setCallback(this, function (response) {
          var state = response.getState();
          if (state == "SUCCESS") {
            component.set("v.modalCola", false);
            $A.get("e.force:refreshView").fire();
            helper.reinit(component);
            component.set("v.isLoading", false);
            component.set("v.modalCola", false);
            helper.mostrarToast(
              "success",
              "Caso devuelto",
              "El caso se ha devuelto a la cola genérica"
            );
          } else {
            var errors = response.getError();
            if (errors && errors[0] && errors[0].message) {
              helper.mostrarToast(
                "error",
                "No se ha podido devolver",
                "Error inesperado contacta con el administrador: " +
                  errors[0].message
              );
            } else {
              helper.mostrarToast(
                "error",
                "No se ha podido devolver",
                "Error inesperado contacta con el administrador"
              );
            }
          }
        });

        $A.enqueueAction(publicar);
      }
    } else if (motivo == null) {
      component.set("v.isLoading", false);

      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Error!",
        message:
          "Para devolver la reclamación es necesario informar un motivo.",
        type: "error"
      });

      toastEvent.fire();
    }
  },
  modalAsignarDevolverCerrar: function (component) {
    component.set("v.modalCola", false);
  },
  modalAdvertenciaDevolverCerrar: function (component) {
    component.set("v.modalAdvertencia", false);
  },

  derivar: function (component, event, helper) {
    component.set("v.isLoading", true);
    var idCase = component.get("v.recordId");
    var action = component.get("c.derivarACC");
    action.setParams({ idCasoDisparador: idCase });
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: "Éxito!",
      message: "Se ha derivado la reclamación a CC.",
      type: "success"
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.isLoading", false);
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
      } else {
        component.set("v.isLoading", false);
        var errors = response.getError();
        let mensageError;
        if(errors[0].message) {
            mensageError = errors[0].message;
        } else if(errors[0].pageErrors[0].message) {
            mensageError = errors[0].pageErrors[0].message;
        }
        let toastParams = {
          title: "Error",
          message: mensageError, 
          type: "error"
        };
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
      }
    });

    $A.enqueueAction(action);
  },
  asignarPretensionPrincipal: function (component, event, helper) {
    component.set("v.isLoading", true);
    var idCase = component.get("v.recordId");
    var casoActual = component.get("v.caso");
    var action = component.get("c.marcarPretensionPrincipal");
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: "Éxito!",
      message:
        "Se ha actualizado la pretensión actual como pretensión principal de la reclamación.",
      type: "success"
    });

    action.setParams({ pretension: casoActual });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.isLoading", false);
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
      } else {
        var errors = response.getError();
        let toastParams = {
          title: "Error",
          message:
            "Ha ocurrido un error a la hora de asignar la pretensión principal",
          type: "error"
        };
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
      }
    });

    $A.enqueueAction(action);
  },

  mostrarAvisoIdioma: function (component, event) {
    var botonPulsado = event.getSource().getLocalId();
    component.set("v.botonPulsado", botonPulsado);
    component.set("v.avisoIdioma", true);
  },

  aceptarAvisoIdiomas :  function(component, event, helper){

    var idiomaValido = component.get("v.idiomaInformado");

		if(idiomaValido){

      var checkmarcado = component.get("v.checkConfirmacionValidacion");

      if (checkmarcado) {
        component.set("v.avisoIdioma", false);

        var botonPulsado = component.get("v.botonPulsado");
        if(botonPulsado == 'derivar') {
          component.set("v.derivar", true);
        } else if(botonPulsado == 'derivarCC') {
          var a = component.get('c.derivar');
          $A.enqueueAction(a);
        }
      }else {
          var toastEventWarning = $A.get("e.force:showToast");
          toastEventWarning.setParams({
              "title": "Advertencia",
              "message": "Debe confirmar que ha validado el idioma de la reclamación",
              "type": "warning"
          });
          toastEventWarning.fire();
      }
    }else{
      var toastEventWarning = $A.get("e.force:showToast");
			toastEventWarning.setParams({
				"title": "Advertencia",
				"message": "Debe completar el idioma de la reclamación",
				"type": "warning"
			});
			toastEventWarning.fire();
    }
  },

  cerrarAvisoIdioma: function (component) {
    component.set("v.avisoIdioma", false);
  },

  derivacion: function (component) {
    component.set("v.derivar", true);
  },

  cerrarDerivar: function (component) {
    component.set("v.derivar", false);
  },

  modalReasignar: function (component, event, helper) {
    helper.fetchGruposLetrado(component, event);

    component.set("v.reasignar", true);
  },

  reasignarGrupoPretensiones: function (component, event, helper) {
    component.set("v.isLoading", true);

    if(component.get("v.motivoReasignar") !== '' && component.get("v.motivoReasignar") !== undefined){
      var idCase = component.get("v.recordId");
      var idGrupo = component.get("v.grupoLetradoSelected");
      var motivoReasignar = component.get("v.motivoReasignar");
      var action = component.get("c.reasignarPretensiones");
      action.setParams({ caseId: idCase, idGrupo: idGrupo, motivo: motivoReasignar });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set("v.isLoading", false);
          component.set("v.reasignar", false);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Éxito!",
            message: "Se han reasignado las pretensiones",
            type: "success"
          });
          toastEvent.fire();
          $A.get("e.force:refreshView").fire();
        } else {
          component.set("v.isLoading", false);
          component.set("v.reasignar", false);
          var errors = response.getError();
          let toastParams = {
            title: "Error",
            message:
              "Ha ocurrido un error a la hora de reasignar las pretensiones",
            type: "error"
          };
          let toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams(toastParams);
          toastEvent.fire();
        }
      });

      $A.enqueueAction(action);
    }else{
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Advertencia!",
        message: "Debe completar el motivo de la reasignación.",
        type: "warning"
      });
      toastEvent.fire();

      component.set("v.isLoading", false);
    }
  },

  cerrarModalReasignar: function (component) {
    component.set("v.reasignar", false);
  },

  modalReabrir: function (component) {
    component.set("v.reabrir", true);
  },

  cerrarModalReabrir: function (component) {
    component.set("v.reabrir", false);
  },

  modalConvertir: function (component) {
    component.set("v.convertir", true);
  },

  cerrarModalConvertir: function (component) {
    component.set("v.convertir", false);
    component.set("v.confirmarConvertir", false);
  },

  confirmarConsultaCOPS: function (component) {
    component.set("v.confirmarConvertir", true);
  },

  convertirAConsultaCOPS :  function(component, event, helper){
		component.set("v.isLoading", true);
    component.set("v.convertir", false);
    component.set("v.confirmarConvertir", false);
		let idCase = component.get("v.recordId");
		let resolucion = component.get("c.convertirReclamacion");
		resolucion.setParams({'caseId': idCase, 'naturaleza' : 'ConsultaCOPS'});
		resolucion.setCallback(this, function (response) {
			var state = response.getState();
			
			if (state == "SUCCESS") {
        component.set("v.isLoading", false);
				var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Éxito!",
          message: "Se ha convertido la reclamación a una Consulta COPS",
          type: "success"
        });
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
			}
			else{
				component.set("v.isLoading", false);
        var errors = response.getError();
        let toastParams = {
          title: "Error",
          message:
            "Ha ocurrido un error a la hora de convertir la reclamación a Consulta COPS",
          type: "error"
        };
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
			}
			
		});
		$A.enqueueAction(resolucion);
	},

  convertirAConsultaSAC :  function(component, event, helper){
		component.set("v.isLoading", true);
    component.set("v.convertir", false);
    component.set("v.confirmarConvertir", false);
		let idCase = component.get("v.recordId");
		let resolucion = component.get("c.convertirReclamacion");
		resolucion.setParams({'caseId': idCase, 'naturaleza' : 'Consulta'});
		resolucion.setCallback(this, function (response) {
			var state = response.getState();
			
			if (state == "SUCCESS") {
        component.set("v.isLoading", false);
				var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Éxito!",
          message: "Se ha convertido la reclamación a una Consulta SAC",
          type: "success"
        });
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
			}
			else{
				component.set("v.isLoading", false);
        var errors = response.getError();
        let toastParams = {
          title: "Error",
          message: errors[0].message, 
          type: "error"
        };
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
			}
			
		});
		$A.enqueueAction(resolucion);
	},


  modalCopiaMasiva: function (component) {
    let caso = component.get("v.caso");
    if (
      caso.SAC_PretensionPrincipal__c == null ||
      caso.SAC_PretensionPrincipal__c == ""
    ) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Atención",
        message:
          "No se puede hacer la copia masiva sin haber informado una pretensión principal",
        type: "error"
      });
      toastEvent.fire();
    } else {
      component.set("v.abrirCopiaMasiva", true);
    }
  },

  CerrarModalCopiaMasiva: function (component) {
    component.set("v.abrirCopiaMasiva", false);
  },

  llamadaReabrirReclamacion: function (component, event, helper) {

    component.find("motivoId").reportValidity();

    if(component.find("motivoId").get("v.value")!= null && component.find("motivoId").get("v.value")!= ""){
      component.set("v.reabrir", false);
      component.set("v.isLoading", true);
      var idCase = component.get("v.recordId");
      var motivoReabrir = component.find("motivoId").get("v.value");
      var action = component.get("c.reabrirReclamacion");
      action.setParams({ 'caseId' : idCase, 'motivoReabrir' : motivoReabrir });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set("v.isLoading", false);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Éxito!",
            message: "Se ha reabierto la reclamación",
            type: "success"
          });
          toastEvent.fire();
          $A.get("e.force:refreshView").fire();
        } else {
          component.set("v.isLoading", false);
          var errors = response.getError();
          let toastParams = {
            title: "Error",
            message: error.body.message,
            type: "error"
          };
          let toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams(toastParams);
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);

      component.find("motivoId").set("v.value", '');
    } 
  },
  modalNuevaReclamacion: function (component) {
    component.set("v.nuevaReclamacion", true);
  },
  cerrarNuevaReclamacion: function (component) {
    component.set("v.nuevaReclamacion", false);
  },

  llamadaNuevaReclamacion: function (component) {
    component.set("v.nuevaReclamacion", false);
    component.set("v.isLoading", true);
    var reclamacion = component.get("v.caso");
    var action = component.get("c.nuevaReclamacionVinculada");
    action.setParams({ casoCerrado: reclamacion });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.isLoading", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Éxito!",
          message: "Se ha creado la reclamación",
          type: "success"
        });
        //toastEvent.fire();
        //component.set("v.nuevaReclamacionPage2", true);
        $A.get("e.force:refreshView").fire();

        component.set("v.cases", response.getReturnValue());
      } else if (state === "ERROR") {
        var errors = response.getError();
        let toastParams = {
          title: "Error",
          message: error.body.message,
          type: "error"
        };
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
        component.set("v.isLoading", false);
      }
    });
    $A.enqueueAction(action);
  },

  modalNuevaReclamacionPage2: function (component) {
    component.set("v.nuevaReclamacionPage2", true);
  },
  cerrarNuevaReclamacionPage2: function (component) {
    component.set("v.nuevaReclamacionPage2", false);
    var caseIdNew = component.get("v.cases");
    var caseIdNew2 = caseIdNew[0];
    var sObectEvent = $A.get("e.force:navigateToSObject");
    sObectEvent.setParams({
      recordId: caseIdNew2,
      slideDevName: "related"
    });
    sObectEvent.fire();
  },

  receiveLWCData: function (component, event, helper) {
    component.set("v.abrirCopiaMasiva", event.getParam("dataToSend"));
    if (event.getParam("refrescar") === true) {
      $A.get("e.force:refreshView").fire();
    }
  },

  modalElevarSupervisor: function (component, event, helper) {
    component.set("v.modalParaSupervisor", true);
  },

  cerrarModalSupervisor: function (component) {
    component.set("v.modalParaSupervisor", false);
  },

  elevarASupervisor: function (component, event, helper) {
    var textoComentariosSupervisor = component
      .find("textoSupervisor")
      .get("v.value");
    
    if (textoComentariosSupervisor == null || textoComentariosSupervisor == '') {
      let toastParams = {
        title: "Precaución",
        message: "Recuerde completar los comentarios.",
        type: "warning"
      };
      let toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams(toastParams);
      toastEvent.fire();
    } else {
      component.set("v.modalParaSupervisor", false);
      component.set("v.isLoading", true);  
      var reclamacionJS = component.get("v.caso");
      var action = component.get("c.elevarCasoSupervisor");
      action.setParams({
        reclamacion: reclamacionJS,
        texto: textoComentariosSupervisor
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set("v.isLoading", false);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Éxito!",
            message: "Se ha elevado la reclamación",
            type: "success"
          });
          toastEvent.fire();
          $A.get("e.force:refreshView").fire();
        } else {
          component.set("v.isLoading", false);
          var errors = response.getError();
          let toastParams = {
            title: "Error",
            message: errors[0].pageErrors[0].message,
            type: "error"
          };
          let toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams(toastParams);
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    }
  },

  modalElevarSupervisorPre: function (component, event, helper) {
    component.set("v.modalParaSupervisorPre", true);
  },

  cerrarModalSupervisorPre: function (component) { 
    component.set("v.modalParaSupervisorPre", false);
  },

  elevarASupervisorPre: function (component, event, helper) {
    var textoComentariosSupervisor = component
      .find("textoSupervisor")
      .get("v.value");
    
    if (textoComentariosSupervisor == null || textoComentariosSupervisor == '') {
      let toastParams = {
        title: "Precaución",
        message: "Recuerde completar los comentarios.",
        type: "warning"
      };
      let toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams(toastParams);
      toastEvent.fire();
    } else { 
      component.set("v.modalParaSupervisorPre", false);
      component.set("v.isLoading", true);

      var idCase = component.get("v.recordId");
      var action = component.get("c.elevarCasoSupervisorPre");
      action.setParams({ caseId: idCase, texto: textoComentariosSupervisor });

      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set("v.isLoading", false);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Éxito!",
            message: "Todas la pretensiones se han elevado al supervisor.",
            type: "success"
          });
          toastEvent.fire();
          $A.get("e.force:refreshView").fire();
        } else {
          component.set("v.isLoading", false);
          var errors = response.getError();
          let toastParams = {
            title: "Error",
            message: errors[0].pageErrors[0].message,
            type: "error"
          };
          let toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams(toastParams);
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    }
  },

  modalDevolverPropietarioA: function (component, event, helper) {
    component.set("v.modalParaPropietarioAnterior", true);
  },

  cerrarDevolverPropietarioA: function (component) {
    component.set("v.modalParaPropietarioAnterior", false);
  },

  devolverPropietarioAnteriorJS: function (component, event, helper) {
    var textoComentariosSupervisor = component
      .find("textoSupervisor")
      .get("v.value");
    
    if (textoComentariosSupervisor == null || textoComentariosSupervisor == '') {
      let toastParams = {
        title: "Precaución",
        message: "Recuerde completar los comentarios.",
        type: "warning"
      };
      let toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams(toastParams);
      toastEvent.fire();
    } else {
      component.set("v.modalParaPropietarioAnterior", false);
      component.set("v.isLoading", true);
      var reclamacionJS = component.get("v.caso");

      var action = component.get("c.devolverPropietarioAnterior");
      action.setParams({
        reclamacion: reclamacionJS,
        texto: textoComentariosSupervisor
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set("v.isLoading", false);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Éxito!",
            message:
              "La reclamación se ha devuelto al propietario anterior con éxito.",
            type: "success"
          });
          toastEvent.fire();
          $A.get("e.force:refreshView").fire();
        } else {
          component.set("v.isLoading", false);
          var errors = response.getError();
          let toastParams = {
            title: "Error",
            message: errors[0].pageErrors[0].message,
            type: "error"
          };
          let toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams(toastParams);
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    }
  },

  modalDevolverSupervisores: function (component, event, helper) {
    component.set("v.modalParaSupervisores", true);
  },

  cerrarDevolverSupervisores: function (component) {
    component.set("v.modalParaSupervisores", false);
  },

  devolverASupervisoresJS: function (component, event, helper) {
    var textoComentariosSupervisor = component
      .find("textoSupervisor")
      .get("v.value");
    
    if (textoComentariosSupervisor == null || textoComentariosSupervisor == '') {
      let toastParams = {
        title: "Precaución",
        message: "Recuerde completar los comentarios.",
        type: "warning"
      };
      let toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams(toastParams);
      toastEvent.fire();
    } else {
      component.set("v.modalParaSupervisores", false);
      component.set("v.isLoading", true);
      var reclamacionJS = component.get("v.caso");

      var action = component.get("c.devolverCasoSupervisores");
      action.setParams({
        reclamacion: reclamacionJS,
        texto: textoComentariosSupervisor
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set("v.isLoading", false);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Éxito!",
            message: "Se ha elevado la reclamación",
            type: "success"
          });
          toastEvent.fire();
          $A.get("e.force:refreshView").fire();
        } else {
          component.set("v.isLoading", false);
          var errors = response.getError();
          let toastParams = {
            title: "Error",
            message: errors[0].pageErrors[0].message,
            type: "error"
          };
          let toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams(toastParams);
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    }
  },
  modalDevolverSupervisoresPre: function (component, event, helper) {
    component.set("v.modalDevolverSupervisoresPre", true);
  },

  cerrarDevolverSupervisoresPre: function (component) {
    component.set("v.modalDevolverSupervisoresPre", false);
  },

  devolverASupervisoresPreJS: function (component, event, helper) {
    var textoComentariosSupervisor = component
      .find("textoSupervisor")
      .get("v.value");
    
    if (textoComentariosSupervisor == null || textoComentariosSupervisor == '') {
      let toastParams = {
        title: "Precaución",
        message: "Recuerde completar los comentarios.",
        type: "warning"
      };
      let toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams(toastParams);
      toastEvent.fire();
    } else {
      component.set("v.modalDevolverSupervisoresPre", false);
      component.set("v.isLoading", true);
      var idCase = component.get("v.recordId");

      var action = component.get("c.devolverPretensionesSupervisores");
      action.setParams({ caseId: idCase, texto: textoComentariosSupervisor });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set("v.isLoading", false);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Éxito!",
            message: "Las pretensiones se ha devuelto al supervisor.",
            type: "success"
          });
          toastEvent.fire();
          $A.get("e.force:refreshView").fire();
        } else {
          component.set("v.isLoading", false);
          var errors = response.getError();
          let toastParams = {
            title: "Error",
            message: errors[0].pageErrors[0].message,
            type: "error"
          };
          let toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams(toastParams);
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    }
  },
  modalDevolverPropietarioAPre: function (component, event, helper) {
    component.set("v.modalParaPropietarioAnteriorPre", true);
  },

  cerrarDevolverPropietarioAPre: function (component) {
    component.set("v.modalParaPropietarioAnteriorPre", false);
  },

  devolverPropietarioAnteriorPreJS: function (component, event, helper) {

    var textoComentariosSupervisor = component
      .find("textoSupervisor")
      .get("v.value");
    
    if (textoComentariosSupervisor == null || textoComentariosSupervisor == '') {
        let toastParams = {
          title: "Precaución",
          message: "Recuerde completar los comentarios.", 
          type: "warning"
      };
      let toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams(toastParams);
      toastEvent.fire();
    } else {
      component.set("v.modalParaPropietarioAnteriorPre", false);
      component.set("v.isLoading", true);
      var idCase = component.get("v.recordId");
  
      var action = component.get("c.devolverPropietarioAnteriorPre");
      action.setParams({ caseId: idCase, texto: textoComentariosSupervisor });

      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set("v.isLoading", false);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Éxito!",
            message:
              "La(s) pretension(es) se han devuelto al propietario anterior con éxito.",
            type: "success"
          });
          toastEvent.fire();
          $A.get("e.force:refreshView").fire();
        } else {
          component.set("v.isLoading", false);
          var errors = response.getError();
          let toastParams = {
            title: "Error",
            message: errors[0].pageErrors[0].message,
            type: "error"
          };
          let toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams(toastParams);
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    }
  },

  openModalProrroga: function (component, event, helper) {
    component.set("v.procedencia", "Prorrogar");
    var idCaso = component.get("v.recordId");
    var action = component.get("c.rellenarCampoCuerpoMensajeProrroga");

    action.setParams({ caseId: idCaso });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.cuerpo", response.getReturnValue());
        component.set("v.cuerpoEC", response.getReturnValue());
        var actionSubject = component.get("c.rellenarCampoSubjectMensajeProrroga");
        actionSubject.setParams({ caseId: idCaso });
        actionSubject.setCallback(this, function (response) {
          if(response.getState() === "SUCCESS"){
            component.set("v.asunto", response.getReturnValue());    

          }else{
            let toastParams = {
              title: "Error",
              message: "Error", 
              type: "error"
            };
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
          }
        });
        $A.enqueueAction(actionSubject);
        $A.get("e.force:refreshView").fire();
      } else {
        component.set("v.cuerpo", "");
      }
    });
    $A.enqueueAction(action);
    component.set("v.modalParaProrrogar", true);
  },

  cerrarModalParaProrrogar: function (component) {
    component.set("v.modalParaProrrogar", false);
    component.set("v.procedencia", "");
  },

  abrirModalAvisoMcc: function (component, event, helper) {
    component.set("v.modalAvisomcc", true);
  },

  cerrarModalAvisoMcc: function (component) {
    component.set("v.modalAvisomcc", false);
  }
});