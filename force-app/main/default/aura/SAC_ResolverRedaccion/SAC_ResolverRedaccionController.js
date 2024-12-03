({

    comprobarSLA: function (component, event, helper) {
        var idCase = component.get("v.recordId");
        let comprobarSLA = component.get("c.comprobarSLARegulatorio");
        comprobarSLA.setParams({ 'idCaso': idCase });
        comprobarSLA.setCallback(this, function(response){
            let state = response.getState();
                if (state === "SUCCESS") {
                    let result = response.getReturnValue();

                    if(result === true){
                        if(component.get('v.almacenarDatos') === false){
                            helper.getMotivosDemora(component, event);
                        }
                        
                        component.set('v.mostrarMotivoDemora', true);     
                    }else if(result === false){
                        helper.setModal(component, event);
                    }
                }
        });
        $A.enqueueAction(comprobarSLA);

    },

    cerrarModalDemora: function (component, event, helper) {
        //component.set('v.cadenaBusqueda', '');
        component.set('v.mostrarMotivoDemora', false);
        component.set('v.almacenarDatos', true);
    },

    mostrarOpciones : function( component, event, helper ) {
        var disabled = component.get("v.disabled");
        component.set("v.mostrarMotivosDemora", true);

        if(!disabled) {
            component.set('v.cadenaBusqueda', '');
            var options = component.get("v.optionsDemora");
            options.forEach( function(element,index) {
                element.isVisible = true;
            });
            component.set("v.optionsDemora", options);
            if(!$A.util.isEmpty(component.get('v.optionsDemora'))) {
                $A.util.addClass(component.find('gruposCombobox'),'slds-is-open');
            } 
        }
    },

    seleccionarMotivo : function( component, event, helper ) {
        if(!$A.util.isEmpty(event.currentTarget.id)) {
            helper.seleccionarMotivoHelper(component, event);
        }
    },

    removePill : function( component, event, helper ){
        helper.removePillHelper(component, event);
    },

    handleBlur : function( component, event, helper ){
        helper.handleBlurHelper(component, event);
    },

    confirmarMotivos: function(component, event, helper){
        var comentarios;

        if(component.get('v.comentarios') !== undefined){
            comentarios = component.get('v.comentarios').trim();
        }
   
        var motivosSeleccionados = 0;
        component.set('v.comentarioObligatorio', false);

        var optionsDemora = component.get("v.optionsDemora");
        optionsDemora.forEach( function(element, index) {
            if(element.selected && element.Name.toLowerCase().trim().includes('otros')) {
                component.set('v.comentarioObligatorio', true);
            }
            if(element.selected){
                motivosSeleccionados++;
            }
        });

        if(motivosSeleccionados === 0){
            let toastParams = {
                title: "Precaución",
                message: 'Debe seleccionar algún motivo de la demora', 
                type: "warning"
            };
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
        }else if(component.get('v.comentarioObligatorio') === true && comentarios === ''){
            let toastParams = {
                title: "Precaución",
                message: 'Ha seleccionado el motivo "Otros", debe detallar un comentario', 
                type: "warning"
            };
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
        }else{
            component.set('v.almacenarDatos', false);
            component.set("v.mostrarMotivoDemora", false);
            helper.setModal(component, event);
        }
    },

    abrirModalAvisoResolver: function (component, event, helper) {
        component.set('v.modalAvisoResolver', true);
    },

    cerrarModalAvisoResolver: function (component, event, helper) {
        component.set('v.modalAvisoResolver', false);
    }
})