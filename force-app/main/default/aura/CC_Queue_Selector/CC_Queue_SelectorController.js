({
    init: function (component, event, helper) {
        var utilityAPI = component.find('utilitybar');
        var eventHandler = function(response){
            helper.handleUtilityClick(component,event,helper, response);
        };
        
        utilityAPI.getAllUtilityInfo().then(function (resp) {
            if (typeof resp !== 'undefined') {
                utilityAPI.onUtilityClick({
                    eventHandler: eventHandler
                }).then(function(response){
                    console.log(response);
                }).catch(function(error){
                    console.log(error);
                });                
            }
        });

        helper.loadColas(component,event,helper);        	
        helper.loadItems(component,event,helper);   

    },
    
    handleColaSeleccionada: function (component, event, helper) {
        var cola = event.getParam("value");
        component.set("v.cola", cola);         
		helper.loadItems(component,event,helper);   

    },
    refreshColaSeleccionada: function (component, event, helper) {
		helper.loadItems(component,event,helper);   

    },

    handleClickCancelar : function(component, event, helper) {
        //$A.get("e.force:closeQuickAction").fire(); 
    },
    
  registerUtilityClickHandler: function(component, event, helper){
        var utilityBarAPI = component.find("utilitybar");
	  var eventHandler = function(response){
            console.log(response);
        };
        
        utilityBarAPI.onUtilityClick({ 
               eventHandler: eventHandler 
        }).then(function(result){
            console.log(result);
        }).catch(function(error){
        	console.log(error);
        });
    }
})