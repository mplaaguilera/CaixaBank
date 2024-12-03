({
    inicio : function(component, event, helper)
    {
        let busquedaCarta = component.get("c.buscaCartaPrevia");
        let idCaso = component.get("v.recordId");
        let tipo = component.get("v.procedencia");
        busquedaCarta.setParams({'caseId': idCaso, 'tipoCarta': tipo});
        busquedaCarta.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                let respuesta = response.getReturnValue();
                component.set('v.direccion', respuesta.direccion);
                component.set('v.codigoPostal', respuesta.cp);
                component.set('v.poblacion', respuesta.poblacion);
                component.set('v.provincia', respuesta.provincia);
                component.set('v.pais', respuesta.pais);
                component.set('v.idCarta', respuesta.idCarta);
                component.set('v.documentoRedaccion', respuesta.documentoRedaccion);
                component.set("v.idDocumentoRedaccion", respuesta.documentoRedaccion.Id);
                component.set("v.idVersion", respuesta.versionRedaccion.Id);
                component.set("v.idDoc", respuesta.documentoRedaccion.Id);

                let paises = respuesta.opcionesPais;
                var options = component.get('v.options');
                
                for (var miPais in paises) {
                    let pais = paises[miPais];
                    options.push({ label: pais.nombrePlantilla, value: pais.idPlantilla });
                }       
                
                component.set('v.options', JSON.parse(JSON.stringify(options)));

                var action4 = component.get('c.obtenerDatosEmail');
                action4.setParams({'idCaso': component.get("v.recordId"), 'soloEmail': false});
                action4.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var wrapper = response.getReturnValue();
                        component.set('v.para', wrapper.para );
                        component.set('v.asunto', wrapper.asunto);
                        component.set('v.cuerpo', wrapper.cuerpo);
                        component.set('v.copia', wrapper.copia);
                        component.set('v.caso', wrapper.caso); 
                    }
                    else{
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
                })
                $A.enqueueAction(action4);
            }
        });
        $A.enqueueAction(busquedaCarta);

    },

    clickModificar : function(component, event, helper) {
        component.set('v.clickActivado', true);
    },

    ocultaModal : function(component, event, helper) {
        component.set('v.clickActivado', false);
    },

    handleSuccess : function(component, event, helper) {
        var record = event.getParam("response");
        var apiName = record.apiName;
        var myRecordId = record.id; // ID of updated or created record
        component.set("v.idCarta",myRecordId);
    },

    cambioPais: function (cmp, event) {
        cmp.set('v.paisSeleccionado', event.getParam("value"));
    },

    handleSubmit : function(component, event, helper) {
        event.preventDefault();
        const fields = event.getParam('fields');
        fields.SAC_Direccion__c = component.get("v.direccion");
        fields.SAC_CP__c = component.get("v.codigoPostal");
        fields.SAC_Poblacion__c = component.get("v.poblacion");
        fields.SAC_Provincia__c = component.get("v.provincia");
        fields.SAC_Pais__c = component.get("v.paisSeleccionado");
        component.find('recordEditForm').submit(fields);
    },

    guardarDatos : function(component, event, helper) {

        let direccionCarta = component.get("v.direccion");
        let poblacionCarta = component.get("v.poblacion");
        let provinciaCarta = component.get("v.provincia");
        let paisCarta = component.get("v.paisSeleccionado");
        let codigoPostalCarta = component.get("v.codigoPostal");

        if((direccionCarta != '' && direccionCarta !== undefined) && 
        (poblacionCarta != '' && poblacionCarta !== undefined) &&
        (provinciaCarta != '' && provinciaCarta !== undefined) &&
        (paisCarta != '' && paisCarta !== undefined) &&
        (codigoPostalCarta != '' && codigoPostalCarta !== undefined)){
            component.find("editForm").submit();
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Datos actualizados.",
                "message": 'Los datos de dirección postal de la carta han sido modificados.',
                "type": "success"
            });
            toastEvent.fire();
            component.set('v.clickActivado', false);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Campos incompletos.",
                "message": 'Complete todos los campos para poder continuar con la modificación.',
                "type": "error"
            });
            toastEvent.fire();
        }
    },

    abrirModalValidarDoc :  function(component, event, helper){
        component.set('v.modalValidarDoc', true);
    },    

    cerrarModalValidarDoc :  function(component, event, helper){
        component.set('v.modalValidarDoc', false);
    }, 

    validarDocumentacion :  function(component, event, helper){
        var checkmarcado = component.get("v.checkConfirmacionValidacion");

        if (checkmarcado) {
            component.set('v.modalValidarDoc', false);
            helper.finalizar(component, event);
        }else {
            var toastEventWarning = $A.get("e.force:showToast");
            toastEventWarning.setParams({
                "title": "Advertencia",
                "message": "Debe confirmar que ha validado la correspondencia entre reclamante y documentación adjunta",
                "type": "warning"
            });
            toastEventWarning.fire();
        }
    } 
})