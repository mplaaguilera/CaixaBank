({
    doInit : function(component, event, helper) {

        let getInfo = component.get("c.getInfoInit");
        let registro = component.get("v.recordId");
        getInfo.setParams({'recordId' : registro});
        getInfo.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                component.set('v.caso', result.caso);

                component.set("v.direccion", result.caso.SAC_DireccionContacto__c);
                component.set("v.poblacion", result.caso.SAC_PoblacionContacto__c);
                component.set("v.provincia", result.caso.SAC_ProvinciaContacto__c);
                component.set("v.pais", result.caso.SAC_PaisContacto__c);
                component.set("v.codigoPostal", result.caso.SAC_CodigoPostalContacto__c);

                component.set('v.para', result.para);
                component.set('v.asunto', result.asunto);

                if(result.caso.SAC_DireccionContacto__c != '' && result.caso.SAC_DireccionContacto__c != undefined){
                    component.set('v.noTieneDireccionPostal', false);
                }
                else{
                    component.set('v.noTieneDireccionPostal', true);
                }
                if((result.caso.OS_Email__c != '' && result.caso.OS_Email__c != undefined) || (result.caso.SuppliedEmail != '' && result.caso.SuppliedEmail != undefined)){
                    component.set('v.noTieneEmail', false);

                    if(result.caso.OS_Email__c != '' && result.caso.OS_Email__c != undefined){
                        component.set('v.correoCasoInformado', true);
                        component.set('v.correoDelCaso', result.caso.OS_Email__c);
                    }else{
                        component.set('v.correoCasoInformado', false);
                    }
                    if(result.caso.SuppliedEmail != '' && result.caso.SuppliedEmail != undefined){
                        component.set('v.webEmailInformado', true);
                        component.set('v.webEmail', result.caso.SuppliedEmail);
                    }else{
                        component.set('v.webEmailInformado', false);
                    }
                }
                else{
                    component.set('v.noTieneEmail', true);
                }
                
                if( component.get("v.pais") === 'España' || component.get("v.pais") === 'españa' || component.get("v.pais") === 'ESPAÑA' ){
                    component.set("v.paisSeleccionado", '011'); 
                }

                let paises = result.opcionesPais;
                var options = [];
                
                for (var miPais in paises) {
                    let pais = paises[miPais];
                    options.push({ label: pais.nombrePlantilla, value: pais.idPlantilla }); 
                }       
                
                component.set('v.options', JSON.parse(JSON.stringify(options)));
            }
        });
        $A.enqueueAction(getInfo);
    },

    cerrar : function(component, event, helper) {
        component.set('v.envioCartaPostal', false);
        component.set('v.envioEmail', false);
        component.set("v.envioAcusePulsado", false);
        component.set("v.modalAcuseYaEnviado", false);
    },

    cambioPais: function (cmp, event) {
        cmp.set('v.paisSeleccionado', event.getParam("value"));  
    },

    enviarAcuse : function(component, event, helper) {
        
        let caso = component.get('v.caso');
        
        // Si el acuse ya ha sido enviado, mostramos mensaje informativo
        if(caso.CC_AcuseRecibo__c == '2'){
            component.set("v.modalAcuseYaEnviado", true);
        }else{
            component.set("v.envioAcusePulsado", true);
        }
    },

    enviarNuevoAcuse : function(component, event, helper) {
        component.set("v.modalAcuseYaEnviado", false);
        component.set("v.envioAcusePulsado", true);
    },

    enviarAcuseEmail : function(component, event, helper) {   
        
        if(component.get('v.correoCasoInformado') && component.get('v.webEmailInformado')){
            component.set('v.envioAcusePulsado', false);    
            component.set('v.envioEmail', true);
        }else{
            component.set('v.envioEmail', false);
            helper.envioAcuseEmailAuto(component, event);
        }
    },

    enviarAcuseCarta : function(component, event, helper) {
        component.set("v.envioAcusePulsado", false);
        component.set('v.envioCartaPostal', true);
    },

    volver : function(component, event, helper) {
        component.set('v.envioCartaPostal', false);
        component.set('v.envioEmail', false);
        component.set("v.envioAcusePulsado", true);
    },

    guardarDatos : function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.envioCartaPostal', false);
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
            component.set('v.envioAcusePulsado', false);
            let crearCarta = component.get("c.envioCartaPostal");
            let casoActual = component.get("v.caso");
            crearCarta.setParams({'caso' : casoActual, 'direccion' : direccionCarta, 'codigoPostal': codigoPostalCarta, 'poblacion': poblacionCarta, 'provincia' :provinciaCarta, 'pais': paisCarta});
            crearCarta.setCallback(this, function(response){
                let state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.isLoading', false);
                    //component.set('v.envioCartaPostal', false);
                    component.set('v.envioEmail', false);
                    component.set("v.envioAcusePulsado", false);
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Éxito!",
                        "message": "Se ha creado la carta de acuse de recibo.",
                        "type": "success"
                    });
                    toastEvent.fire(); 
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    component.set('v.isLoading', false);
                    component.set('v.envioAcusePulsado', false);
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "No se ha creado la carta de acuse de recibo.",
                        "type": "error"
                    });
                    toastEvent.fire(); 
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(crearCarta);
        }
        else{
            component.set('v.isLoading', false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Campos incompletos.",
                "message": 'Complete todos los campos para poder continuar con la modificación.',
                "type": "error"
            });
            toastEvent.fire();
        }
    },

    guardarDatosEmail  : function(component, event, helper) {
        component.set('v.envioCartaPostal', false);
        component.set('v.envioEmail', false);
        component.set("v.envioAcusePulsado", false);
        component.set('v.isLoading', true);
        let caso = component.get('v.caso');
        let para = component.get('v.para');
        let copia = component.get('v.copia');
        let cuerpo = component.get('v.cuerpo');
        let asunto = component.get('v.asunto');
        let ficherosAdjuntos = component.get('v.ficherosAdjuntos');
        let idsFicherosAdjuntos = [];

        for(let i = 0; i < ficherosAdjuntos.length; i++){
            idsFicherosAdjuntos.push(ficherosAdjuntos[i].Id);
        }
        
        var envio = component.get("c.envioEmail");
        envio.setParams({'casoApex': caso, 'para': para, 'copia':copia, 'cuerpo':cuerpo, 'asunto':asunto, 'ficherosAdjuntos': JSON.stringify(idsFicherosAdjuntos)});
        envio.setCallback(this, function(response) {
            component.set('v.isLoading', false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Acuse enviado",
                    "message": 'Se ha enviado la notificación al cliente.',
                    "type": "success"
                });
                component.set('v.envioCartaPostal', false);
                component.set('v.envioEmail', false);
                component.set("v.envioAcusePulsado", false);
                toastEvent.fire();                
                $A.get('e.force:refreshView').fire();
            }
            else{
                var error = response.getError();
                let toastParams = {
                    title: "Error",
                    message: error[0].pageErrors[0].message, 
                    type: "error"
                };

                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
        });
        $A.enqueueAction(envio);
    },
    
    clickComboBox : function(component, event, helper) {
        component.set('v.isLoading', true);
        document.getElementById("divCombo").style.display="block";

    },

    enviarCorreoCaso: function(component, event, helper) {
        component.set('v.viaEnvio', 'correoCaso');
        component.set('v.envioEmail', false);    
        helper.envioAcuseEmailAuto(component, event);
    },

    enviarWebEmail: function(component, event, helper) {
        component.set('v.viaEnvio', 'webEmail');
        component.set('v.envioEmail', false);    
        helper.envioAcuseEmailAuto(component, event);
    }
})