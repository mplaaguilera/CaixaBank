({
    enviarRedaccionMail : function(component, event) {
        let idsFicherosAdjuntos = component.get("v.idsFicherosAdjuntos");

        var action = component.get("c.finalizarRedaccion");
        var idCaso = component.get("v.caso");

        this.cargarTagsImgCuerpo(component);

        if(component.get('v.todasImgConTag')){
            action.setParams({'id': idCaso.Id, 'para': component.get("v.para"), 'copia': component.get("v.copia"), 'copiaOculta': component.get("v.copiaOculta"), 'cuerpo': component.get("v.cuerpo"), 'asunto': component.get("v.asunto"), 'idAdjuntos': JSON.stringify(idsFicherosAdjuntos)});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    $A.get('e.force:refreshView').fire();
                    if(idCaso.Status == 'SAC_003'){
                        var mensajeInformativo = 'Correo enviado y acciones ejecutadas';
                    }else{
                        var mensajeInformativo = 'Correo enviado, reclamación cerrada por inadmisión';
                    }
                    let toastParams = {
                        title: "Éxito",
                        message: mensajeInformativo, 
                        type: "success"
                    };
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                    component.set('v.isLoading', false);
                    var cmpEvent = component.getEvent("cmpComponent");
                    cmpEvent.setParams({
                        "showComponente" : false,
                        "showButton": false}); 
                    cmpEvent.fire();
                }
                else{
                    component.set('v.isLoading', false);
                    var errors = response.getError();

                    let toastEvent = $A.get("e.force:showToast");
                    if(errors[0].message){
                        toastEvent.setParams({
                            'title': 'Error', 
                            'message': errors[0].message, 
                            'type': 'error',
                            'duration': 4000
                        });
                    }else if(errors[0].pageErrors[0].message){
                        toastEvent.setParams({
                            'title': 'Error', 
                            'message': errors[0].pageErrors[0].message, 
                            'type': 'error'
                        });
                    }
                    toastEvent.fire();
                }
            })
            $A.enqueueAction(action);
        }else{
            component.set('v.todasImgConTag', true);
            component.set('v.isLoading', false);

            let toastParams = {
                title: "Advertencia!",
                message: 'Todas las imágenes enviadas deben tener una descripción informada. Revíselas con el botón "Modificar descripción imágenes"',  
                type: "warning"
            };
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
        }
    },

    enviarConsultaMail : function(component, event) {
        //let ficherosAdjuntos = component.get("v.ficherosAdjuntos");
        let idsFicherosAdjuntos = [];
        /*for(let i = 0; i <ficherosAdjuntos.length; i++){
            idsFicherosAdjuntos.push(ficherosAdjuntos[i].Id);
        }*/

        idsFicherosAdjuntos = component.get("v.idsFicherosAdjuntos");

        var action = component.get("c.enviarEmail");
        var procede = component.get('v.procedencia');
        var idObj = '';
        if(procede == 'ConsultaDeReclamacion'){
            let obj = component.get("v.consulta");
            idObj = obj.Id;
        }
        else{
            let obj = component.get("v.caso");
            idObj = obj.Id;
        }

        this.cargarTagsImgCuerpo(component);

        if(component.get('v.todasImgConTag')){
            //var idCaso = component.get("v.caso");
            action.setParams({'id': idObj, 'para': component.get("v.para"), 'copia': component.get("v.copia"), 'copiaOculta': component.get("v.copiaOculta"), 'cuerpo': component.get("v.cuerpo"), 'asunto': component.get("v.asunto"), 'idAdjuntos': JSON.stringify(idsFicherosAdjuntos)});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    let toastParams = {
                        title: "Éxito",
                        message: 'Correo enviado.', 
                        type: "success"
                    };
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                    component.set('v.isLoading', false);
                    if(component.get('v.procedencia') == 'Resolver'){ 
                        var cmpEvent = component.getEvent("cmpEvent");
                        cmpEvent.setParams({"mostrarModalResolver" : true });
                        cmpEvent.fire();                
                    }
                    this.refreshAdjuntosComponent(component);
                }
                else{
                    component.set('v.isLoading', false);
                    var errors = response.getError();
                    let toastParams = {
                        title: "Error",
                        //message: "Ha fallado el envío del email, contacte con su administrador", 
                        message: errors[0].message,
                        type: "error"
                    };
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                }
            })

            $A.enqueueAction(action);
        }else{
            component.set('v.todasImgConTag', true);
            component.set('v.isLoading', false);

            let toastParams = {
                title: "Advertencia!",
                message: 'Todas las imágenes enviadas deben tener una descripción informada. Revíselas con el botón "Modificar descripción imágenes"',  
                type: "warning"
            };
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
        }
    },

    enviarProrrogaMail : function(component, event) {
        //component.get('v.procedencia');
        var action = component.get("c.prorrogarCaso");
        var asunto = component.get("v.asunto");
        if(asunto == null || asunto == '') {
            asunto = 'El caso con número ' + component.get('v.caso.CaseNumber') + ' ha sido prorrogado';
        }

        this.cargarTagsImgCuerpo(component);

        if(component.get('v.todasImgConTag')){
            let idsFicherosAdjuntos = component.get("v.idsFicherosAdjuntos");

            action.setParams({'id':component.get('v.caso.Id'), 'para':component.get('v.para'), 'copia':component.get('v.copia'), 'copiaOculta':component.get('v.copiaOculta'),
                'cuerpo': component.get("v.cuerpo"), 'asunto':asunto, 'idAdjuntos': JSON.stringify(idsFicherosAdjuntos)});

            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.isLoading', false);
                    component.set('v.modalParaProrrogar', false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Prorroga realizada correctamente",
                        "message": "Se ha actualizado el estado de la reclamación.",
                        "type": "success"
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
                else
                {
                    component.set('v.isLoading', false);
                    // component.set('v.modalParaProrrogar', false);
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
        }else{
            component.set('v.todasImgConTag', true);
            component.set('v.isLoading', false);

            let toastParams = {
                title: "Advertencia!",
                message: 'Todas las imágenes enviadas deben tener una descripción informada. Revíselas con el botón "Modificar descripción imágenes"',  
                type: "warning"
            };
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
        }
    },

    refreshAdjuntosComponent: function(component) {
        var adjuntosComponent = component.find("adjuntosComponent");
        adjuntosComponent.refresh();
    },

    cargarTagsImgCuerpo: function(component){
        //El rich text borra los atributos 'alt' de las etiquetas img, por lo que cada vez que se actualiza tenemos que recorrer el map de tag de imagenes
        //y en caso de haber imagenes con tag, asignar el tag a cada una de estas
        
        //Recupero el contenido del cuerpo y el mapa de tag de imagenes
        var cuerpo = component.get("v.cuerpo");
        var imageMap = component.get("v.imageTagsMap");

        //Encuentra todas las imagenes del cuerpo
        var parser = new DOMParser();
        var doc = parser.parseFromString(cuerpo, 'text/html');
        var images = Array.from(doc.querySelectorAll('img'));

        //Recorro las imagenes, y si tiene una entrada en el mapa de tags, le añado el atributo 'alt'
        images.forEach(function (image) {
            
            if(imageMap && imageMap.has(image.src)){
                var alt = imageMap.get(image.src);

                if (alt !== undefined && alt !== '') {
                    image.setAttribute('alt', alt);
                }else{
                    component.set('v.todasImgConTag', false);
                }
            }else{
                const baseUrl = doc.baseURI; 

                if(image.src !== baseUrl){
                    component.set('v.todasImgConTag', false);
                }
            }
        });       

        //Actualizo el valor del cuerpo con el contenido actualizado
        var updatedContent = doc.body.innerHTML;
        component.set("v.cuerpo", updatedContent);
    }
})