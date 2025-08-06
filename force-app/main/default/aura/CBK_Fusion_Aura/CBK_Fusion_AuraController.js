({
    "init" : function(cmp) {
        // $A.get("e.force:closeQuickAction").fire();
        var action = cmp.get("c.exec");
        var result = "";
        var respuesta ="";
        var tipo = "warning";
        action.setParams({ idFusion : cmp.get("v.recordId") });
        cmp.set("v.ShowSpinner", true);

        action.setCallback(this, function(response) {
            cmp.set("v.ShowSpinner", false);
            var state = response.getState();
            if (state === "SUCCESS") {
                //cmp.set("v.Result", response.getReturnValue());
                respuesta = response.getReturnValue();
                result = respuesta.resultado;
                $A.get('e.force:refreshView').fire();
                if (respuesta.error=== false ) {
                    tipo = "success";   
                }
            }
            else if (state === "INCOMPLETE") {
                //cmp.set("v.Result", "INCOMPLETE");
                result ="INCOMPLETE";
                tipo = "error";
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                //cmp.set("v.Result", errors);
                result = errors;
                tipo = "error";
            }

            // Display the total in a "toast" status message
            var resultsToast = $A.get("e.force:showToast");
            console.log(result);
            resultsToast.setParams({
                "title": "Resultado del proceso",
                "message" : result,
                "type" : tipo
            });
            resultsToast.fire();
    
            // Close the action panel
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        });        
        $A.enqueueAction(action);
        
    }
})