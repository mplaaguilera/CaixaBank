({
   init : function(component, event, helper) {
      var action = component.get("c.updateEvent");
      action.setParams({
         "recordId": component.get("v.recordId"),
         "stage": 'Realizada'
      });
  
      action.setCallback(this, function(response) {
          var state = response.getState();
          if(component.isValid() && state == "SUCCESS" && response.getReturnValue() == ''){

              var resultsToast = $A.get("e.force:showToast");
              resultsToast.setParams({
                  "type": "success",
                  "title": $A.get("$Label.c.CIBE_Guardado"),
                  "message": $A.get("$Label.c.Cibe_CerradoCorrectamente")
              });
               resultsToast.fire();
               window.location.reload()
            } else {
               var resultsToast = $A.get("e.force:showToast");
               resultsToast.setParams({
                  "type": "error",
                  "title": $A.get("$Label.c.CIBE_Error"),
                  "message": response.getReturnValue(),
                  "mode":"sticky"
               });
               resultsToast.fire();
               window.location.reload();
            }
          
      });
      $A.enqueueAction(action);
  }
})