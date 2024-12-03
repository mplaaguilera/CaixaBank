({
    setModal: function (component, event) {
        component.set('v.modalAvisoResolver', false);
        component.set('v.isLoading', true);
        var procedencia = component.get("v.procedencia");
        var idCase = component.get("v.recordId");        
        var envioMail = component.get('v.checkMail');
        var idCase = component.get("v.recordId");
        var action = component.get("c.finalizarRedaccion");
        action.setParams({ 'id': idCase, 'envioMail': envioMail });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(envioMail){
                    let toastParams = {
                        title: "Redacción resuelta.",
                        message: "Se ha cerrado el SLA y notificado al equipo responsable.",
                        type: "success"
                    };
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                }
                else{
                    let toastParams = {
                        title: "Redacción resuelta.",
                        message: "Se ha informado la fecha de resolución.",
                        type: "success"
                    };
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                }
                
                component.set('v.fechaRes', response.getReturnValue());

                let actionDemora = component.get("c.actualizarMotivosDemora");
                actionDemora.setParams({ 'idCaso': idCase, 'motivoDemora': component.get('v.values'), 'comentarioDemora': component.get('v.comentarios').trim() });
                actionDemora.setCallback(this, function(response){
                    let state = response.getState();
                        if (state === "SUCCESS") {
                            //$A.get('e.force:refreshView').fire();
                        }
                });
                $A.enqueueAction(actionDemora);
                component.set('v.isLoading', false);

            }else{
                var errors = response.getError();
                let toastEvent = $A.get('e.force:showToast');
                if(errors[0].message){
                    toastEvent.setParams({'title': 'Cliente no informado', 
                    'message': errors[0].message, 
                    'type': 'error',
                    'mode': 'dismissable',
                    'duration': 4000});
                }else if(errors[0].pageErrors[0].message){
                    toastEvent.setParams({'title': 'Error', 
                    'message': errors[0].pageErrors[0].message, 
                    'type': 'error',
                    'mode': 'dismissable',
                    'duration': 4000});
                }
                toastEvent.fire();

                component.set('v.almacenarDatos', true);
                component.set('v.isLoading', false);
            }
        });

        // $A.get('e.force:refreshView').fire();
        if(!envioMail){
            var appEvent = $A.get("e.c:SAC_PertimiteEmailRedaccion");
            appEvent.setParams({
                "etapa1" : true,
                "etapa2" : true,
                "etapa3" : true, 
                "checkboxRedaccion" : true,
                "procedencia" : procedencia});
            //component.set('v.isLoading', !component.get('v.isLoading'));
            appEvent.fire();
            $A.enqueueAction(action);
        }
        else{
            var appEvent = $A.get("e.c:SAC_PertimiteEmailRedaccion");
            appEvent.setParams({
                "etapa1" : true,
                "etapa2" : true,
                "etapa3" : true,
                "checkboxRedaccion" : false,
                "procedencia" : procedencia });
            appEvent.fire();
            $A.enqueueAction(action);
        }
      
    },

    getMotivosDemora: function(component, event){
        component.set('v.modalAvisoResolver', false);
        let motivosDemora = component.get("c.getMotivosDemora");
        motivosDemora.setCallback(this, function(response){
            let state = response.getState();
                if (state === "SUCCESS") {
                    let result = response.getReturnValue();
                    component.set('v.optionsDemora', result);

                    let infoCaso = component.get("c.devolverCaso");
                    infoCaso.setParams({ 'id': component.get("v.recordId") });
                    infoCaso.setCallback(this, function(response){
                        let state = response.getState();
                        if (state === "SUCCESS") {
                            let result = response.getReturnValue();
                            var optionsDemora = component.get('v.optionsDemora');
                            if(result.SAC_MotivoDemora__c !== ''){
                                var count = 0;
                                var values = component.get('v.values') || [];
                                
                                optionsDemora.forEach( function(element, index) {
                                    let valores = result.SAC_MotivoDemora__c.trim().split(',');
                                    valores.forEach(function(valor) {
                                        if (element.Name === valor.trim()) {
                                            element.selected = true;
                                            count++;
                                            values.push(element.Name);
                                        }
                                    });
                                });

                                component.set('v.values', values);
                                component.set('v.optionsDemora', optionsDemora);

                                if(count === 0){
                                    component.set('v.cadenaBusqueda', '');
                                }else if(count === 1){
                                    component.set('v.cadenaBusqueda', count + ' motivo seleccionado');
                                }else{
                                    component.set('v.cadenaBusqueda', count + ' motivos seleccionados');
                                }
                            }

                            if(result.SAC_ComentarioDemora__c !== undefined){
                                component.set('v.comentarios', result.SAC_ComentarioDemora__c);
                            }
                        }
                    });
                    $A.enqueueAction(infoCaso);
                }
        });
        $A.enqueueAction(motivosDemora);
    },

    seleccionarMotivoHelper : function(component, event) {
        var optionsDemora = component.get('v.optionsDemora');
        var values = component.get('v.values') || [];
        var value;
        var count = 0;
  
        optionsDemora.forEach( function(element, index) {
            if(element.Name === event.currentTarget.id) {            

                if(values.includes(element.Name)) {
                    values.splice(values.indexOf(element.Name), 1);
                } else {
                    values.push(element.Name);
                }
                element.selected = element.selected ? false : true;   
              
            }
            if(element.selected) {
                count++;
            }
        });

        component.set('v.value', value);
        component.set('v.values', values);
        component.set('v.optionsDemora', optionsDemora);

        if(count === 0){
            component.set('v.cadenaBusqueda', '');
        }else if(count === 1){
            component.set('v.cadenaBusqueda', count + ' motivo seleccionado');
        }else{
            component.set('v.cadenaBusqueda', count + ' motivos seleccionados');
        }
        
        component.set('v.mostrarMotivosDemora', false);

        event.preventDefault();
    },

    removePillHelper : function(component, event) {
        var value = event.getSource().get('v.name');
        var count = 0;
        var optionsDemora = component.get("v.optionsDemora");
        var values = component.get('v.values') || [];
        optionsDemora.forEach( function(element, index) {
            if(element.Name === value) {
                element.selected = false;
                values.splice(values.indexOf(element.Name), 1);
            }
            if(element.selected) {
                count++;
            }
        });
       
        if(count === 0){
            component.set('v.cadenaBusqueda', '');
        }else if(count === 1){
            component.set('v.cadenaBusqueda', count + ' motivo seleccionado');
        }else{
            component.set('v.cadenaBusqueda', count + ' motivos seleccionados');
        }

        component.set('v.values', values)
        component.set("v.optionsDemora", optionsDemora);
    },

    handleBlurHelper : function(component, event) {
        component.set('v.mostrarMotivosDemora', false);
        var count = 0;
        var optionsDemora = component.get("v.optionsDemora");
        optionsDemora.forEach( function(element, index) {
            if(element.selected) {
                count++;
            }
        });

        if(count === 0){
            component.set('v.cadenaBusqueda', '');
        }else if(count === 1){
            component.set('v.cadenaBusqueda', count + ' motivo seleccionado');
        }else{
            component.set('v.cadenaBusqueda', count + ' motivos seleccionados');
        }
    } 
})