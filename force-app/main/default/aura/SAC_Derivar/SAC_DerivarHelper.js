({
    helperMethod : function() {

    },

    doInitStartHelper : function(component) {
        $A.util.toggleClass(component.find('gruposCombobox'),'slds-is-open');
        var value = component.get('v.value');

        if( !$A.util.isEmpty(value) ) {
            var grupoAbuscar;
            var options = component.get('v.options');
            options.forEach( function(element, index) {

            if(element.Name == value) {
                grupoAbuscar = element.Name;
            }
        });

        component.set('v.grupoAbuscar', grupoAbuscar);
        component.set('v.options', options);
        }
    },

    handleBlurHelper : function(component, event) {
        var selectedValue;
        var previousLabel;
        var options;
        var grupoAbuscarId;


        options = component.get("v.options");
        selectedValue = component.get('v.value');

        options.forEach( function(element, index) {
            if(element.Name === selectedValue) {
                previousLabel = element.Name;
                grupoAbuscarId = element.Id;
            }
        });

        component.set('v.grupoAbuscar', previousLabel);
        component.set('v.grupoAbuscarId', grupoAbuscarId);
        component.set('v.mostrarGrupos', false); 
    },

    filtroBusquedaHelper : function(component) {
        component.set("v.mensaje", '');
        var caracteresMin = 0;

        var cadenaBusqueda = component.get('v.grupoAbuscar');
        var options = component.get("v.options");
        caracteresMin = component.get('v.caracteresMin');

        if(cadenaBusqueda.length >= caracteresMin) {

            var flag = true;
            options.forEach( function(element,index) {
                if(element.Name.toLowerCase().trim().includes(cadenaBusqueda.toLowerCase().trim())) {
                    element.isVisible = true;
                    flag = false;
                } else {
                    element.isVisible = false;
                }
            });
            component.set("v.options",options);
            if(flag) {
                component.set("v.mensaje", "No hay resultados para '" + cadenaBusqueda + "'");
                component.set('v.grupoAbuscar', cadenaBusqueda);
            }
               
        }else{
            component.set("v.mensaje", "Introduce valores para filtrar la búsqueda");
            component.set('v.oficinaSeleccionada', cadenaBusqueda);
        }
        $A.util.addClass(component.find('gruposCombobox'),'slds-is-open');
    },
     
    seleccionarGrupoHelper : function(component, event) {
        var options = component.get('v.options');
        var grupoAbuscar = component.get('v.grupoAbuscar');
        var grupoAbuscarId;
        var value;
        var esOficina;
        var cadenaBusqueda = 'oficina';
  
        options.forEach( function(element, index) {
            if(element.Name === event.currentTarget.id) {
                value = element.Name;
                grupoAbuscar = element.Name;
                grupoAbuscarId = element.Id;
                if(element.SAC_DeveloperName__c !== undefined){
                    esOficina = element.SAC_DeveloperName__c.toLowerCase().trim();
                }else{
                    esOficina = '';
                }
            }
        });

        component.set('v.value', value);
        component.set('v.options', options);
        component.set('v.grupoAbuscar', grupoAbuscar);
        component.set('v.grupoAbuscarId', grupoAbuscarId);
        component.set('v.mostrarGrupos', false);
        component.set('v.oficinaSeleccionada', '');
        component.set('v.emailOficina', '');

        var caso = component.get('v.caso');
        if(caso.RecordType.DeveloperName === 'SAC_Reclamacion' && caso.Status === 'SAC_001' && esOficina.includes(cadenaBusqueda)){  
            component.set('v.activarBuscadorOficinas', true);
        }else{
            component.set('v.activarBuscadorOficinas', false);
            component.set('v.idOfiSeleccionada', '');
        }

        $A.util.removeClass(component.find('gruposCombobox'),'slds-is-open');
    },

    comprobarEmails : function(component, event) {
        let para;
        let copia;
        let copiaOculta;

        if(component.get("v.numeroPantalla") === 2){
            para = component.get("v.paraGrupo");
            copia = component.get("v.CC");
            copiaOculta =  component.get("v.CCO");
        }else if(component.get("v.numeroPantalla") === 4){
            para = component.get("v.paraCliente");
            copia = component.get("v.CCCliente");
            copiaOculta =  component.get("v.CCOCliente");
        }

        var actionComprobarEmails = component.get("c.comprobarEmailsEnvio");
        actionComprobarEmails.setParams({'para': para, 'copia': copia, 'copiaOculta': copiaOculta});
        actionComprobarEmails.setCallback(this, function(response) {
			var state = response.getState();
            if (state === "SUCCESS") {
                let emailsNoValidos = response.getReturnValue();

                if(emailsNoValidos === ''){
                    //Todas las direcciones de email son validas (ninguna está activa en la blackList) luego avanzamos a la siguiente pantalla
                    var numeroPagina = component.get("v.numeroPantalla");
                    numeroPagina = numeroPagina + 1;
                    component.set("v.numeroPantalla", numeroPagina); 
                }else{
                    //Alguna de las direcciones de email no son validas (alguna está activa en la blackList) luego notificamos esto al usuario
                    component.set('v.isLoading', false);
                    let toastParams = {
                        title: "Error",
                        message: "No está permitido el envío de emails a esta dirección: " + emailsNoValidos + " de correo electrónico, por favor elimínela para proceder al envío",
                        type: "error"
                    };
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                }
            }
            else{
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
        })

        $A.enqueueAction(actionComprobarEmails);
    }
})