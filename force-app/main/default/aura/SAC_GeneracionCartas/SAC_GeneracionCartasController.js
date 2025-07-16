({
    inicio : function(component, event, helper)
    {
        //alert('inicio componente generacion');
        //console.log('console.log: ' + component.get("v.procedencia"));
        let busquedaCarta = component.get("c.SAC_BuscaCartaPrevia");
        let idCaso = component.get("v.caseId");
        let tipo = component.get("v.procedencia");

        busquedaCarta.setParams({'caseId': idCaso, 'tipoCarta': tipo});
        busquedaCarta.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                let respuesta = response.getReturnValue();
                component.set("v.idCarta", respuesta.idCarta);
                component.set("v.urlVisFo", respuesta.urlVF);
                
                component.set("v.direccion", respuesta.direccion);
                component.set("v.codigoPostal", respuesta.cp);
                component.set("v.poblacion", respuesta.poblacion);
                component.set("v.provincia", respuesta.provincia);
                component.set("v.paisSeleccionado", respuesta.pais);

                let paises = respuesta.opcionesPais;
                var options = component.get('v.options');
                
                for (var miPais in paises) {
                    let pais = paises[miPais];
                    options.push({ label: pais.nombrePlantilla, value: pais.idPlantilla });
                }       
                
                component.set('v.options', JSON.parse(JSON.stringify(options)));
                component.set("v.cuerpo", respuesta.cuerpo);

                let direccionCarta2 = component.get("v.direccion");
                let poblacionCarta2 = component.get("v.poblacion");
                let provinciaCarta2 = component.get("v.provincia");
                let paisCarta2 = component.get("v.paisSeleccionado");
                let codigoPostalCarta2 = component.get("v.codigoPostal");

                let dirTotal = '';
                if(direccionCarta2 != '' && direccionCarta2 !== undefined){
                    dirTotal = direccionCarta2;
                }
                if(codigoPostalCarta2 != '' && codigoPostalCarta2 !== undefined){
                    if(dirTotal != ''){
                        dirTotal = dirTotal + ', ' + codigoPostalCarta2;
                    }
                    else{
                        dirTotal = codigoPostalCarta2;
                    }
                }
                if(poblacionCarta2 != '' && poblacionCarta2 !== undefined){
                    if(dirTotal != ''){
                        dirTotal = dirTotal + ', ' + poblacionCarta2;
                    }
                    else{
                        dirTotal = poblacionCarta2;
                    }
                }
                if(provinciaCarta2 != '' && provinciaCarta2 !== undefined){
                    if(dirTotal != ''){
                        dirTotal = dirTotal + ', ' + provinciaCarta2;
                    }
                    else{
                        dirTotal = provinciaCarta2;
                    }
                }
                if(paisCarta2 != '' && paisCarta2 !== undefined){
                    if(dirTotal != ''){
                        dirTotal = dirTotal + ', ' + paisCarta2;
                    }
                    else{
                        dirTotal = paisCarta2;
                    }
                }
                component.set("v.direccionTotal", dirTotal);

                if((direccionCarta2 != '' && direccionCarta2 !== undefined) && 
                    (poblacionCarta2 != '' && poblacionCarta2 !== undefined) &&
                    (provinciaCarta2 != '' && provinciaCarta2 !== undefined) &&
                    //(paisCarta2 != '' && paisCarta2 !== undefined) &&
                    (codigoPostalCarta2 != '' && codigoPostalCarta2 !== undefined)){
                        component.set("v.habilitado", true);
                }

            }
            else{
                //alert(JSON.stringify(response.getError()));
                toastEvent.setParams({
                    "title": "Error al obtener la información del fichero.",
                    "message": 'El PDF no ha sido cargado.',
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        
        $A.enqueueAction(busquedaCarta);
        
    //    $A.enqueueAction(busquedaCarta);
    },
    posibleActualizacion : function(cmp, event, helper) {
        if (!cmp.get('v.isProgressing') && cmp.get('v.actAutomatica'))
        {
            cmp.set('v.isProgressing', true);
            cmp._interval = setInterval($A.getCallback(function () {
                var progress = cmp.get('v.progress');
                if(progress===100){
                    cmp.find("formularioMagicoDeCartas").submit();
                }
                cmp.set('v.progress', progress === 100 ? 0 : progress + 1);
            }), 200);
        }
    },
    handleCreateLoad : function(component, event, helper) {
        if(component.get("v.cuerpo")=="" || component.get("v.cuerpo")== null){
            var recordUi = event.getParam("recordUi");
            var cuerpo = recordUi.record.fields["SAC_Cuerpo__c"].value;
            component.set("v.cuerpo", cuerpo);

            if(component.get("v.cuerpoPrevio")=="" || component.get("v.cuerpoPrevio")== null){
                component.set("v.cuerpoPrevio", cuerpo);
            }

        }

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
        component.find('formularioMagicoDeCartas').submit(fields);
    },

    error : function(component, event, helper) {
        event.preventDefault();
        alert(JSON.stringify(event));
        console.log(event);
    },
    
    handleSuccess : function(component, event, helper) {
        var record = event.getParam("response");
        var apiName = record.apiName;
        var myRecordId = record.id; // ID of updated or created record
        component.set("v.idCarta",myRecordId);
        //$A.get('e.force:refreshView').fire();
        component.set("v.iteracionRefresco",component.get("v.iteracionRefresco")+1);
        component.set("v.act","&n="+component.get("v.iteracionRefresco"));
        component.set('v.isProgressing', false);
        clearInterval(component._interval);
        component.set('v.progress',0)
    },

    continuarCarta : function(component, event, helper) {
        component.set("v.verEditor","True");
        let busquedaCarta = component.get("c.SAC_BuscaCartaPrevia");
        let idCaso = component.get("v.caseId");
        let tipo = component.get("v.procedencia");

        busquedaCarta.setParams({'caseId': idCaso, 'tipoCarta': tipo});
        busquedaCarta.setCallback(this, function(response){
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.cuerpo", response.getReturnValue().cuerpo);
            }
        });
        $A.enqueueAction(busquedaCarta);
        
    },
    nuevaCarta : function(component, event, helper) {
        component.set("v.verEditor","True");
        //component.set("v.idCarta",'');
        let tipo = component.get ('v.procedencia');
        console.log(tipo);
        if(component.get("v.procedencia") != 'redacción'){
            console.log('dentro del if');
            component.set("v.cuerpo", component.get("v.plantilla"));  
            console.log('CGR test cuerpo'+ component.get("v.cuerpo"));
            
        }
        $A.get('e.force:refreshView').fire();
    },

    handleCreateLoad : function(component){

    },

    toggleProgress: function (cmp) {
        if (cmp.get('v.isProgressing')) {
            // stop
            cmp.set('v.isProgressing', false);
            clearInterval(cmp._interval);
        } else {
            // start
            cmp.set('v.isProgressing', true);
            cmp._interval = setInterval($A.getCallback(function () {
                var progress = cmp.get('v.progress');
                if(progress===100){
                    cmp.find("formularioMagicoDeCartas").submit();
/*
                    cmp.set("v.iteracionRefresco",cmp.get("v.iteracionRefresco")+1);
                    cmp.set("v.act","&n="+cmp.get("v.iteracionRefresco"));*/
                }
                cmp.set('v.progress', progress === 100 ? 0 : progress + 1);
            }), 200);
        }
    },

    cerrarEdicion : function(component, event, helper) {
        component.set("v.verEditor","false");
    },
    guardar: function(component, event, helper) {
        component.find("formularioMagicoDeCartas").submit();
        
    /*    setTimeout(() => {
            var adjuntarPDF = component.get('c.adjuntarPDFaCaso2');
            var caseId = component.get('v.caseId');
            var procede = component.get('v.procedencia');
            var urlVF = component.get('v.urlVisFo')+component.get('v.idCarta') + component.get('v.act');
            adjuntarPDF.setParams({'url': urlVF, 'parentId': caseId, 'procedencia': procede});
            adjuntarPDF.setCallback(this, function(response){
                console.log('entro callback '+response.getState());
                var toastEvent = $A.get("e.force:showToast");
                var state = response.getState();
                if (state === "SUCCESS") {
                    toastEvent.setParams({
                        "title": "Redacción guardada",
                        "message": 'El PDF ha sido generado y adjuntado al registro actual.',
                        "type": "success"
                    });
                    toastEvent.fire();
                }
                else{
                    toastEvent.setParams({
                        "title": "Error al guardar el fichero.",
                        "message": 'El PDF no ha sido generado.',
                        "type": "error"
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(adjuntarPDF);
        }, 1000); */
        
    },
    cerrarGuardar: function(component, event, helper) {
        component.find("formularioMagicoDeCartas").submit();

    /*    var adjuntarPDF = component.get('c.adjuntarPDFaCaso2');
        var caseId = component.get('v.caseId');
        var procede = component.get('v.procedencia');
        var urlVF = component.get('v.urlVisFo')+component.get('v.idCarta') + component.get('v.act');
        adjuntarPDF.setParams({'url': urlVF, 'parentId': caseId, 'procedencia': procede});
        adjuntarPDF.setCallback(this, function(response){
            //console.log('entro callback '+response.getState());
            var toastEvent = $A.get("e.force:showToast");
            var state = response.getState();
            if (state === "SUCCESS") {
                toastEvent.setParams({
                    "title": "PDF adjuntado al caso.",
                    "message": 'El PDF ha sido generado y adjuntado al registro actual.',
                    "type": "success"
                });
                toastEvent.fire();
            }
            else{
                toastEvent.setParams({
                    "title": "Error al adjuntar el fichero.",
                    "message": 'El PDF no ha sido generado.',
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(adjuntarPDF);

        */
        component.set("v.verEditor","false");
        component.set("v.cuerpo","");
        component.set("v.cuerpoPrevio","");
    },

    edicionEnvio : function(component, event, helper) {
        if (component.get('v.edicionEnvio')) {
            component.find("formularioMagicoDeCartas").submit();
            let direccionCarta = component.get("v.direccion");
            let poblacionCarta = component.get("v.poblacion");
            let provinciaCarta = component.get("v.provincia");
            let paisCarta = component.get("v.paisSeleccionado");
            let codigoPostalCarta = component.get("v.codigoPostal");

            //alert(direccionCarta + ' - ' +poblacionCarta + ' - ' +provinciaCarta + ' - ' +paisCarta + ' - ' + codigoPostalCarta);
            if((direccionCarta != '' && direccionCarta !== undefined) && 
                (poblacionCarta != '' && poblacionCarta !== undefined) &&
                (provinciaCarta != '' && provinciaCarta !== undefined) &&
                //(paisCarta != '' && paisCarta !== undefined) &&
                (codigoPostalCarta != '' && codigoPostalCarta !== undefined)){
                component.set("v.habilitado", true);
            }
            else{
                component.set("v.habilitado", false);
            }
            component.set('v.edicionEnvio', false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Datos actualizados.",
                "message": 'Los datos de dirección postal de la carta han sido modificados.',
                "type": "success"
            });
            toastEvent.fire();            
            
        } else {
            component.set('v.edicionEnvio', true);
        }
    }
})