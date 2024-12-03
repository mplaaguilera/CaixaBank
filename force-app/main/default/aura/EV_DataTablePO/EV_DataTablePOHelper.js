({
    getInitData : function(component) {
        component.set('v.columns', [
            {label: 'Variable Adobe Campaign', fieldName: 'varPublicoObjetivo', type: 'text'},
            {label: 'Tipo de variable', fieldName: 'variableType', type: 'text'},
            {label: 'Nombre de Variable', fieldName: 'variableNameURL', type: 'url', typeAttributes:{label:{fieldName: 'variableName'}},},
            {label: 'Tipo de criterio', fieldName: 'criterioType', type: 'text'},
            {label: 'Valor del criterio', fieldName: 'criterioValue', type: 'text'}
        ]);

        var getRecordsCall = component.get('c.getRecordsPO');
        getRecordsCall.setParams({ "idEvento" : component.get("v.recordId")});
        getRecordsCall.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.dataPO", response.getReturnValue());
            }
        });
        $A.enqueueAction(getRecordsCall);
    }
})