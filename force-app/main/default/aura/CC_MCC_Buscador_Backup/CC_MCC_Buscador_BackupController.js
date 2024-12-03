/* eslint-disable no-console */
/* eslint-disable no-undef */
({
    doInit: function(component, event, helper) {
        component.set('v.queryErrorMessage', '');
        component.set('v.queryErrorFound', false);
        component.set('v.lookupInputFocused', false);

        helper.datosCaso(component);

        /* Para cargar el componente con un registro seleccionado
        var lookupId = component.get('v.lookupId');
        var fields = component.get("v.fieldSet");
        var primaryDisplayField = component.get("v.primaryDisplayField");
        if (lookupId != undefined && lookupId != '' && lookupId != null) {
            var query = "SELECT " + fields.join(",") + " FROM CC_MCC__c WHERE Id = '" + lookupId + "' AND RecordType.DeveloperName = 'CC_Motivo' AND CC_Activo__c = true";
            var action = component.get("c.querySalesforceRecord");
            action.setParams({queryString: query});
            action.setCallback(this, function (response) {
                var responseState = response.getState();
                console.log('error ', response.getError()[0]);
                if (responseState === 'SUCCESS' && response.getReturnValue() != undefined && response.getReturnValue() != null && response.getReturnValue() != '') {
                    component.set('v.selectedIndex', undefined);
                    component.set("v.searching", false);
                    component.set('v.selectedObject', response.getReturnValue()[0]);
                    component.set('v.selectedObjectDisplayName', response.getReturnValue()[0][primaryDisplayField]);
                    component.set('v.value', '');
                } else {
                    console.log('error: ', response.getError());
                    component.set('v.queryErrorMessage', response.getError()[0]);
                    component.set('v.queryErrorFound', true);
                }
            });
            $A.enqueueAction(action);
        }
        */
    },

    searchRecords: function(component, event, helper) {
        let userEnteredValue = component.get("v.enteredValue");
        let conditions = component.get("v.whereCondition");
        let comparisonField = component.get("v.comparisonField");
        let objectList = component.get('v.objectList');
        let selectedObjectIndex = component.get('v.selectedIndex');

        switch (event.getParams().keyCode) {
            case 38: //up key
                if (objectList.length > 0) {
                    if (selectedObjectIndex != undefined && selectedObjectIndex - 1 >= 0) {
                        selectedObjectIndex--;
                    } else if (selectedObjectIndex != undefined && selectedObjectIndex - 1 < 0 || selectedObjectIndex == undefined) {
                        selectedObjectIndex = objectList.length - 1;
                    }
                    component.set('v.selectedIndex', selectedObjectIndex);
                }
                break;

            case 40: //down key
                if (objectList.length > 0) {
                    if (selectedObjectIndex != undefined && selectedObjectIndex + 1 < objectList.length) {
                        selectedObjectIndex++;
                    } else if (selectedObjectIndex != undefined && selectedObjectIndex + 1 == objectList.length || selectedObjectIndex == undefined) {
                        selectedObjectIndex = 0;
                    }
                    component.set('v.selectedIndex', selectedObjectIndex);
                }
                break;

            case 27: //escape key
                component.set('v.objectList', []);
                component.set('v.lookupInputFocused', false);
                break;

            case 13: //enterKey
                helper.onValueselect(component);
                break;

            case 39: //Right Key
            case 37: //Left Key
            case 35: //home
            case 36: //End
            case 16: //Shift
            case 17: //Control
            case 18: //Alt
                //don't to anything
                break;

            default: //any other character entered
                //Reseteo de los atributos de los resultados antes de hacer una nueva consulta
                component.set('v.selectedObject', undefined);
                component.set('v.selectedObjectDisplayName', '');
                component.set('v.queryErrorMessage', '');
                component.set('v.queryErrorFound', false);

                if (userEnteredValue.length >= component.get("v.minimumCharacter")) {
                    //Se guarda el literal de búsqueda actual
                    component.set('v.enteredValueTemp', userEnteredValue);

                    //Se programa la búsqueda para dentro de 200ms
                    window.setTimeout($A.getCallback(() => {
                        //Si el literal de búsqueda no ha cambiado en estos 200ms, se envía la solicitud al servidor
                        if (component.get('v.enteredValue') == component.get('v.enteredValueTemp')) {
                                component.set('v.searching', true);
                                component.set('v.objectList', []);
                                let comparisionStringArray = [];
                                //Se substituyen espacios por '%' para si cada palabra tiene un origen distinto
                                comparisonField.forEach(element => comparisionStringArray.push(element + " LIKE '%" + userEnteredValue.replace(/ /g, '%') + "%'"));

                                let query = 'SELECT ' + component.get('v.fieldSet').join(',') + ' FROM CC_MCC__c WHERE (' + comparisionStringArray.join(' OR ') + ')';
                                query += " AND RecordType.DeveloperName = 'CC_Motivo' AND CC_Activo__c = true";

                                let tipoCliente = component.get('v.tipoCliente');
                                if (tipoCliente != '' && tipoCliente != undefined) {
                                    query += " AND CC_Tipo_Cliente__c IN ('" + tipoCliente + "', 'Cliente/Empleado')";
                                } else {
                                    query += " AND CC_Tipo_Cliente__c IN ('Cliente', 'Cliente/Empleado')";
                                }

                                if (conditions != undefined && conditions != '') {
                                    query += " " + conditions;
                                }

                                query += " LIMIT " + component.get("v.limit");
                                let querySalesforceRecord = component.get('c.querySalesforceRecord');
                                querySalesforceRecord.setParams({'queryString': query});
                                querySalesforceRecord.setCallback(this, response => {
                                    if (response.getState() === 'SUCCESS') {
                                        component.set('v.objectList', response.getReturnValue());
                                        component.set("v.searching", false);
                                        component.set('v.selectedIndex', 0); //1?
                                    } else {
                                        component.set('v.queryErrorMessage', response.getError()[0].message);
                                        component.set('v.queryErrorFound', true);
                                        component.set('v.objectList', []);
                                        component.set('v.selectedIndex', undefined);
                                        component.set("v.searching", false);
                                        console.log('error', response.getError()[0].message)
                                    }
                                });
                                $A.enqueueAction(querySalesforceRecord);
                            }
                        }
                    ), 400);
                } else {
                    component.set('v.objectList', []);
                    component.set('v.selectedIndex', undefined);
                    component.set("v.searching", false);
                }
        }
    },

    showColorOnMouseEnter: function(component, event) {
        $A.util.addClass(event.currentTarget, 'highlight');
    },

    hideColorOnMouseLeave: function(component, event) {
        $A.util.removeClass(event.currentTarget, 'highlight');
    },

    inputBlurred: function(component) {
        //delaying the setting of this flag. This is to make sure that the flag is set post the selection of the dropdown.
        window.setTimeout($A.getCallback(() => component.set('v.lookupInputFocused', false)), 200);
    },

    inputInFocus: function(component) {
        component.set('v.lookupInputFocused', true);
    },

    removeSelectedOption: function(component) {
        component.set('v.selectedIndex', undefined);
        component.set('v.selectedObject', undefined);
        component.set('v.selectedObjectDisplayName', '');
        component.set('v.value', undefined);
        component.set('v.lookupId', '');
    },

    onRowSelected: function(component, event, helper) {
        component.set('v.selectedIndex', parseInt(event.currentTarget.dataset.currentIndex));
        helper.onValueselect(component);
    },

    seleccionar: function(component) {
        let propietario = component.get("c.getEsPropietarioCaso");
        propietario.setParams({sIdCaso : component.get("v.recordId")});
        propietario.setCallback(this, response => {
            if (response.getState() === "SUCCESS") {
                if (response.getReturnValue() == true) {
                    let actualizarCaso = component.get("c.actualizarCaso");
                    actualizarCaso.setParams({"idCaso": component.get('v.recordId'), "idMotivo": component.get('v.selectedObject.Id')});
                    actualizarCaso.setCallback(this, response => {
                        if (response.getState() === 'SUCCESS') {
                            if (response.getReturnValue() == false) {
                                let toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({"title": "No se puede actualizar.", "message": 'Los usuarios con perfil 3N no pueden clasificar casos.', "type": "error"});
                                toastEvent.fire();
                            }
                            $A.get('e.force:refreshView').fire(); //refresca la vista
                        } else {
                            let errores = response.getError();
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({"title": "Error al clasificar.", "message": errores[0].pageErrors[0].message, "type": "warning"});
                            toastEvent.fire();
                        }
                    });
                    $A.enqueueAction(actualizarCaso);

                    //Actualizamos la tipificación actual del caso.
                    let tipificar = component.get("c.getTipificacion");
                    tipificar.setParams({"idCaso": component.get('v.recordId')});
                    tipificar.setCallback(this, response => {
                        if (response.getState() === 'SUCCESS') {
                            let retorno = response.getReturnValue();
                            component.set('v.tematica', retorno.CC_MCC_Tematica__r.Name);
                            component.set('v.producto_servicio', retorno.CC_MCC_ProdServ__r.Name);
                            component.set('v.motivo', retorno.CC_MCC_Motivo__r.Name);
                        }
                    });
                    $A.enqueueAction(tipificar);

                    let evt = $A.get("e.c:CC_Refresh_MCC_Clasificar");
                    evt.setParams({"recordId": component.get("v.recordId")});
                    evt.fire();
                } else {
                    let toastPropietario = $A.get("e.force:showToast");
                    toastPropietario.setParams({"title": "Error al clasificar.", "message": "No puede clasificar el caso si no es propietario", "type": "error"});
                    toastPropietario.fire();
                }
            } else {
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({"title": "Error al clasificar.", "message": "Error comprobando propiedad del caso", "type": "error"});
                toastEvent.fire();
            }
        });
        $A.enqueueAction(propietario);
    }
})