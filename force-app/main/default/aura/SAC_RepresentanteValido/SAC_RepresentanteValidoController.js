({
    doInit : function(component, event, helper) {
        var actionGetCaso = component.get('c.getCase');
        var casoId = component.get("v.recordId");
        actionGetCaso.setParams({'caseId': casoId});
        actionGetCaso.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var caso = response.getReturnValue();
                    component.set('v.caso', caso);
                    let validaRep;

                    //Si cualquiera de estos campos tiene información, hay que validar el representante
                   /* if (caso.SAC_TipoDeRepresentante__c != null || caso.SAC_TipoDeDocumento__c != null || caso.SAC_NombreRepresentante__c != null ||
                        caso.SAC_EmailRepresentante__c != null || caso.SAC_DespachoRepresentante__c != null || caso.SAC_NumeroDelDocumento__c != null ||
                        caso.SAC_DireccionPostal__c != null || caso.SAC_TelefonoRepresentante__c != null || caso.SAC_PoderRepresentante__c) {
                        component.set('v.validarRepresentante', true);
                        validaRep = true;
                    } else {
                        component.set('v.validarRepresentante', false);
                        validaRep = false;
                    }*/

                         //Si cualquiera de estos campos tiene información, hay que validar el representante
                    if (caso.SAC_TipoDeRepresentante__c != null || caso.SAC_TipoDeDocumento__c != null || caso.SAC_NombreRepresentante__c != null ||
                        caso.SAC_EmailRepresentante__c != null || caso.SAC_DespachoRepresentante__c != null || caso.CBK_Case_Extension_Id__r.SAC_DespachoRepresentante__c != null || caso.SAC_NumeroDelDocumento__c != null ||
                        caso.SAC_DireccionPostal__c != null || caso.SAC_DireccionRepresentante__c != null  || caso.SAC_CodigoPostalRepresentante__c != null || caso.SAC_PoblacionRepresentante__c != null ||
                        caso.SAC_ProvinciaRepresentante__c != null || caso.SAC_PaisRepresentante__c != null || caso.SAC_TelefonoRepresentante__c != null || caso.SAC_PoderRepresentante__c) {
                        component.set('v.validarRepresentante', true);
                        validaRep = true;
                    } else {
                        component.set('v.validarRepresentante', false);
                        validaRep = false;
                    }

                    //Si se tiene que validar al representante y alguno de estos campos está vacío, hay que mostrar las validaciones de los campos
                    //Antes la condición después del email era &&
                    if (validaRep == true && (caso.SAC_TipoDeRepresentante__c == null || caso.SAC_TipoDeDocumento__c == null || caso.SAC_NombreRepresentante__c == null || caso.SAC_PoderRepresentante__c == false ||
                        caso.SAC_NumeroDelDocumento__c == null || 
                        (caso.SAC_EmailRepresentante__c == null || 
                        (caso.SAC_DireccionPostal__c == null || caso.SAC_DireccionRepresentante__c == null || caso.SAC_CodigoPostalRepresentante__c == null || caso.SAC_PoblacionRepresentante__c == null || caso.SAC_ProvinciaRepresentante__c == null || caso.SAC_PaisRepresentante__c == null || caso.SAC_PoderRepresentante__c == false) 
                    ))) {
                        component.set('v.validarCampos', true);
                    } else {
                        component.set('v.validarCampos', false);
                    }

                    //Validar nuevos campos direccion postal
                    if((caso.SAC_DireccionRepresentante__c != null && caso.SAC_DireccionRepresentante__c !='' && caso.SAC_DireccionRepresentante__c != undefined) && 
                        (caso.SAC_CodigoPostalRepresentante__c != null && caso.SAC_CodigoPostalRepresentante__c !='' && caso.SAC_CodigoPostalRepresentante__c != undefined) &&
                        (caso.SAC_PoblacionRepresentante__c != null && caso.SAC_PoblacionRepresentante__c != '' && caso.SAC_PoblacionRepresentante__c != undefined) &&
                        (caso.SAC_ProvinciaRepresentante__c != null && caso.SAC_ProvinciaRepresentante__c != '' && caso.SAC_ProvinciaRepresentante__c != undefined) && 
                        (caso.SAC_PaisRepresentante__c != null && caso.SAC_PaisRepresentante__c != '' && caso.SAC_PaisRepresentante__c != undefined) ){
                        component.set('v.direccionPostalInformada', true);
                    }
                    else{
                        component.set('v.direccionPostalInformada', false);
                    }

                    //Si cualquiera de estos campos tiene información, y además, el check SAC_UsarDatos__c está activo, hay que mostrar el mensaje del check
                    if ((caso.SAC_TipoDeRepresentante__c != null || caso.SAC_TipoDeDocumento__c != null || caso.SAC_NombreRepresentante__c != null ||
                        caso.SAC_EmailRepresentante__c != null || caso.SAC_DespachoRepresentante__c != null || caso.CBK_Case_Extension_Id__r.SAC_DespachoRepresentante__c != null || caso.SAC_NumeroDelDocumento__c != null ||
                        caso.SAC_DireccionPostal__c != null || caso.SAC_TelefonoRepresentante__c != null || caso.SAC_PoderRepresentante__c) && caso.SAC_UsarDatos__c) {
                        component.set('v.validarCheckALF', true);
                    } else {
                        component.set('v.validarCheckALF', false);
                    }

                    // if((component.get('v.validarRepresentante') === true && component.get('v.validarCampos') === false && component.get('v.direccionPostalInformada') === true) && component.get('v.validarCheckALF') === false){
                    //Comentado en el if recordtype reclamación, esto ahora se encuentra en el lwc sac_DespachoRepresentante
                    if((caso.RecordType.DeveloperName == 'SAC_ConsultaSAC' /*|| caso.RecordType.DeveloperName == 'SAC_Reclamacion'*/) && (caso.SAC_NumeroDelDocumento__c != null || caso.CBK_Case_Extension_Id__r.SAC_DespachoRepresentante__c != null /*caso.SAC_DespachoRepresentante__c != null*/)){
                        let comprobarCaracteristicas = component.get("c.comprobarCaractRepresentante");
                        //comprobarCaracteristicas.setParams({'documento': caso.SAC_NumeroDelDocumento__c, 'despacho': caso.SAC_DespachoRepresentante__c});
                        comprobarCaracteristicas.setParams({'documento': caso.SAC_NumeroDelDocumento__c, 'despacho': caso.CBK_Case_Extension_Id__r.SAC_DespachoRepresentante__c});
                        comprobarCaracteristicas.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                var caracteristica = response.getReturnValue();

                                if(caracteristica != null){
                                    component.set('v.listCaracteristicas', caracteristica);
                                    component.set('v.mostrarCaracteristicas', true);
                                }
                            }
                            else{
                                var errors = response.getError();
                                let toastParams = {
                                    title: "Error",
                                    message: "Error al comprobar las características asociadas al representante.", 
                                    type: "error"
                                };
                                let toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams(toastParams);
                                toastEvent.fire();
                            }
                        });
                        $A.enqueueAction(comprobarCaracteristicas);
                    }
                }
                else{
                    var errors = response.getError();
                }
            })
            $A.enqueueAction(actionGetCaso);
    }
})