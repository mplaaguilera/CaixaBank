({
    
   
    close: function(component, event, helper) {
       
       $A.get("e.force:closeQuickAction").fire();
     
   
  
     },save: function(component, event, helper) {
        
        // llama al evento del helper, que es el método de sumar días de la clase apex 
        helper.sumaDiasFechaVencimiento(component);

    }

})