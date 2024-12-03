({
    doInit : function(component, event, helper) {
        var idCaso = component.get("v.recordId");
        var getCaso = component.get("c.recuperarCaso");
        getCaso.setParam("caseId", idCaso);
        getCaso.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
              var casoActual = response.getReturnValue();
              component.set("v.caso", casoActual);
              var propietarioCaso = component.get("v.caso.OwnerId");
              console.log('owner '+ propietarioCaso);
      
              var getUser = component.get("c.recuperarUser");
              getUser.setParams({
                casoActual: casoActual,
                ownerCaso: propietarioCaso
              });
              getUser.setCallback(this, function (response) {
                let resp = response.getReturnValue();
                component.set("v.user", resp.UserId);
                component.set(
                  "v.esPropietario",
                  component.get("v.user") === component.get("v.caso.OwnerId")
                );
                });
                $A.enqueueAction(getUser);
            }
        });
        $A.enqueueAction(getCaso);

        var action2 = component.get("c.getPickListValuesIntoList");
        action2.setCallback(this, function(response){
            var state = response.getState();
            var options = component.get('v.options');
            if (state === "SUCCESS") { 
                let titulos = response.getReturnValue();
                for (var miTitulo in titulos) {
                    let titulo = titulos[miTitulo];
                    options.push({ label: titulo.nombrePlantilla, value: titulo.idPlantilla });
                }            
                component.set('v.options', JSON.parse(JSON.stringify(options)));

                var adjuntos = component.get('c.obtieneAdjuntos');
                adjuntos.setParams({'id': component.get("v.recordId")});
                adjuntos.setCallback(this, function(response) {
                    var state2 = response.getState();
                    if(state2 === 'SUCCESS'){
                        let ficherosAdjuntos = response.getReturnValue();
                        component.set('v.ficherosAdjuntos', ficherosAdjuntos);
                    }
                    else{
                        var errors2 = response.getError();
                        let toastParams = {
                            title: "Error",
                            message: errors2[0].pageErrors[0].message, 
                            type: "error"
                        };
                    let toastEvent2 = $A.get("e.force:showToast");
                    toastEvent2.setParams(toastParams);
                    toastEvent2.fire();
                    }
                })
                $A.enqueueAction(adjuntos);      
            } else{                 
                var errors = action2.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'No se ha podido recuperar el campo motivo',
                    message: errors[0].message,
                    type: 'error'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action2);

        var actionGrupos = component.get("c.recogerGruposParaEscalados");
        actionGrupos.setParams({ "idCase": idCaso });
        actionGrupos.setCallback(this, function(response) {
            var state = response.getState();
            var optionsEquipo = component.get('v.optionsEquipo');
            if(state === "SUCCESS"){
                let equipos = response.getReturnValue();
                for(var miEquipo in equipos){
                    let equipo = equipos[miEquipo];
                    optionsEquipo.push({label: equipo.Name, value: equipo.Id});
                   
                }
                component.set('v.optionsEquipo', JSON.parse(JSON.stringify(optionsEquipo)));
            }else{                 
                var errors = actionGrupos.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'No se ha podido recuperar el campo Equipo',
                    message: errors[0].message,
                    type: 'error'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(actionGrupos);

        var actionValidarEscalado = component.get("c.validacionesEscalados");
        actionValidarEscalado.setParams({ "caseId": idCaso });
        actionValidarEscalado.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set('v.necesitaEscalado', result.escalado);
                console.log('necesita escalado?'+ result.escalado);
                component.set("v.mensaje", result.mensaje);
                console.log('mensaje ? '+ result.mensaje);
                var grupoDestino = result.mapaGrupoDestino;
    
                    if (grupoDestino != null && grupoDestino != undefined && Object.keys(grupoDestino).length > 0) {
                        var options = [];
                        for (var ideGrupo in grupoDestino) {
                            var contenidoGrupo = grupoDestino[ideGrupo];
                            var opcAux = { label: contenidoGrupo, value: ideGrupo };
                            options.push(opcAux);
                        }
                        component.set("v.options", options);
                        console.log('opciones?'+ options);
                    }
    
            }
        });
        $A.enqueueAction(actionValidarEscalado);

    },

    valorEquipo: function (cmp, event) {
        cmp.set('v.valueEquipo', event.getParam("value"));
    },

    valorMotivo: function (cmp, event) {
        cmp.set('v.motivo', event.getParam("value"));
    },

    closeModal: function(component, event, helper){
        component.set("v.isModalOpen", false);
    },
    closeModalAdjuntos: function(component, event, helper){
        component.set("v.isModalAdjuntos", false);
        component.set("v.ficherosAdjuntos", null);
    },

    closeModalWarning: function(component, event, helper){
        component.set("v.isModalWarningOpen", false);
    },


    comprobarPropietario: function(component, event, helper) {
      console.log('entra comprobarPropietario');
      var idCaso = component.get("v.recordId");
      component.set("v.spinnerLoading", true);
      console.log('Llama esPropietario');
      // Llama a la acción de Apex para verificar si es propietario
      var actionEsPropietario = component.get("c.esPropietario");
      console.log('sale esPropietario');
      actionEsPropietario.setParams({ "caseId": idCaso });
      actionEsPropietario.setCallback(this, function(responseEsPropietario) {
          var stateEsPropietario = responseEsPropietario.getState();
          if (stateEsPropietario === "SUCCESS") {
              var esPropietario = responseEsPropietario.getReturnValue();
              

              if (esPropietario) {
                  // Si es propietario, llama a la acción de Apex para verificar escalados abiertos
                  var actionHayEscaladosAbiertos = component.get("c.hayEscaladosAbiertos");
                  actionHayEscaladosAbiertos.setParams({ "caseId": idCaso });

                  actionHayEscaladosAbiertos.setCallback(this, function(responseEscalados) {
                      var stateEscalados = responseEscalados.getState();
                      if (stateEscalados === "SUCCESS") {
                          var hayEscaladoAbierto = responseEscalados.getReturnValue();

                          if (hayEscaladoAbierto) {
                              // Muestra un mensaje si hay un escalado abierto
                              console.log('Escalado abierto');
                              var toastEvent = $A.get("e.force:showToast");
                              toastEvent.setParams({
                                  title: "La reclamación ya ha sido escalada",
                                  message: "Ya existe un escalado pendiente de respuesta en esta reclamación",
                                  type: "error"
                              });
                              toastEvent.fire();
                          } else {
                              // Abre un modal si no hay un escalado abierto
                              console.log('abre modal');
                              component.set("v.isModalOpen", true);
                             
                          }
                      } else {
                          // Maneja errores de la acción de Apex para escalados abiertos
                          // Muestra un mensaje de error
                          helper.handleApexError(component, responseEscalados.getError());
                      }
                  });

                  $A.enqueueAction(actionHayEscaladosAbiertos);
              } else {
                  // Abre un modal de advertencia si no es propietario
                  console.log('abre modal de advertencia');
                  component.set("v.isModalWarningOpen", true);
              }
          } else {
              // Maneja errores de la acción de Apex para esPropietario
              // Muestra un mensaje de error
              helper.handleApexError(component, responseEsPropietario.getError());
          }

          component.set("v.spinnerLoading", false);
      });

      $A.enqueueAction(actionEsPropietario);
  },    

  insertEscalado: function(component, event, handler){

    component.set("v.spinnerLoading", true);

    var recordId = component.get("v.recordId");
    var action = component.get("c.insertarEscalado");   
    var titulo = component.find("titulo").get("v.value");
    var propuesta = component.find("propuestaLetrado").get("v.value");
    var observaciones = component.find("observaciones").get("v.value");
    var motivo = component.get("v.motivo");
    var equipo = component.get("v.valueEquipo");
    let button = component.find('buttonSiguiente');
    button.set('v.disabled',true);
    

    if((titulo == null || titulo == '') || (propuesta == null || propuesta == '') ||(motivo == null || motivo == '')){
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Precaución',
                message: 'Recuerde completar el título, la propuesta y el motivo.',
                type: 'warning'
            });
            toastEvent.fire();
            component.set("v.spinnerLoading", false);
    }else {
        
        action.setParams({'caseId' : recordId, 'propuesta' : propuesta, 'titulo' : titulo, 'motivo' : motivo, 'observaciones' : observaciones, 'equipoId' : equipo});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                let idEscalado = response.getReturnValue();
                component.set("v.idEscalado", idEscalado);
                component.set("v.spinnerLoading", false);
                component.set("v.isModalAdjuntos", true);
                component.set("v.isModalOpen", false);
                $A.get('e.force:refreshView').fire();
                

            }else if (state === "ERROR") {
                var error = response.getError()[0];
                var message = (error && error.message) ? error.message : 'Error desconocido al crear el escalado.';
                var showToastEvent = $A.get("e.force:showToast");
                showToastEvent.setParams({
                    title: 'Fallo al crear el escalado',
                    message: message,
                    variant: 'error'
                });
                showToastEvent.fire();
                component.set("v.spinnerLoading", false);
            }
            
        });
        $A.enqueueAction(action);
    }


  },

  handleUploadFinished: function (component, event) {

    var recordId = component.get("v.recordId");
    var copiarArchivo = component.get("c.insertarAdjuntoCaso");
    copiarArchivo.setParams({'interaccionId' : recordId});
    copiarArchivo.setCallback(this, function(response){
        var state = response.getState();
        if (state === "SUCCESS") { 

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Éxito!",
                "message": "Los archivos se han subido con éxito.",
                "type": "success"
            });
            toastEvent.fire(); 
            
        }
    });
    $A.enqueueAction(copiarArchivo);
}

})