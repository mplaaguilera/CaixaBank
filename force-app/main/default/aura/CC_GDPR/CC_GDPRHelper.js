({
    obtenerDerechosDelCliente : function(component) {
        let idCaso = component.get("v.recordId");
        let obtenerDerechosDelCliente = component.get('c.obtenerDerechosDelCliente');
		obtenerDerechosDelCliente.setParams({
            'idCaso': idCaso
        });
        obtenerDerechosDelCliente.setCallback(this, $A.getCallback(function (response) {
            let state = response.getState();
            component.set("v.loaded", true);
            if (state === "SUCCESS") {
                component.set('v.derechosCliente', response.getReturnValue());
            } else if (state === "ERROR") {
                let errors = response.getError();
            }
        }));
        $A.enqueueAction(obtenerDerechosDelCliente);
    },
    
    obtenerDerechosDelCaso : function(component) {
        let idCaso = component.get("v.recordId");
        let obtenerDerechosDelCaso = component.get('c.obtenerDerechosDelCaso');
		obtenerDerechosDelCaso.setParams({
            'idCaso': idCaso
        });
        obtenerDerechosDelCaso.setCallback(this, $A.getCallback(function (response) {
            let state = response.getState();
            component.set("v.loaded", true);
            if (state === "SUCCESS") {
                component.set('v.derechosCaso', response.getReturnValue());
            } else if (state === "ERROR") {
                let errors = response.getError();
            }
        }));
        $A.enqueueAction(obtenerDerechosDelCaso);
    },

    /*
     * Este método recibe como parámetros el RecordTypeId seleccionado
     * y el ApiName de objeto Derecho e invoca el evento force:createRecord
     * para abrir el modal de creación de registro.
     */
    showCreateRecordModal : function(component, recordTypeId, entityApiName) {
        let createRecordEvent = $A.get("e.force:createRecord");
        if (createRecordEvent) { //comprobamos si el evento está soportado
            if (recordTypeId) { // si tenemos el recordTypeId, invocamos el evento force:createRecord pasándole los parámetros
                createRecordEvent.setParams({
                    "entityApiName": entityApiName,
                    "recordTypeId": recordTypeId,
                    "defaultFieldValues": {
                        "CC_Nombre__c": component.get("v.caseRecord.Contact.FirstName") == null ? "" : component.get("v.caseRecord.Contact.FirstName").toUpperCase(),
                        "CC_Apellido1__c": component.get("v.caseRecord.Contact.LastName") == null ? "" : component.get("v.caseRecord.Contact.LastName").toUpperCase(),
                        "CC_DocumentoCliente__c": component.get("v.caseRecord.Account.CC_Numero_Documento__c") == null ? "" : component.get("v.caseRecord.Account.CC_Numero_Documento__c"),
                        "CC_NumPerso__c": component.get("v.caseRecord.Account.CC_NumPerso__c") == null ? "" : component.get("v.caseRecord.Account.CC_NumPerso__c"),
                        "CC_NombreVia__c": component.get("v.caseRecord.Account.BillingStreet") == null ? "" : component.get("v.caseRecord.Account.BillingStreet").toUpperCase(),
                        "CC_CodigoPostal__c": component.get("v.caseRecord.Account.BillingPostalCode") == null ? "" : component.get("v.caseRecord.Account.BillingPostalCode"),
                        "CC_Localidad__c": component.get("v.caseRecord.Account.BillingCity") == null ? "" : component.get("v.caseRecord.Account.BillingCity").toUpperCase(),
                        "CC_Caso__c": component.get("v.recordId"),
                        "CC_Cliente__c": component.get("v.caseRecord.AccountId")
                    }
                });
                createRecordEvent.fire();
            } else {
				alert('El derecho seleccionado no es válido');
            }
        } else {
            alert('Este evento no está soportado');
        }
    }
})