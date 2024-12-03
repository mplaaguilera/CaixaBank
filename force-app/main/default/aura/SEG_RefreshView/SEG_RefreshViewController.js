({
    
   onInit: function(component, event, helper) {
        var empApi = component.find("empApi");
        empApi.setDebugFlag(true);
        empApi.subscribe("/topic/Excepciones", -1, function(message) {
			console.log('entraentraeeeee:' + message.data.sobject.Id);
            var excepciones = component.get('c.getExcepciones');
			excepciones.setParams({"objectId": message.data.sobject.Id});
        	excepciones.setCallback(this, function(response) {
				
                var lstTexto = response.getReturnValue();
				helper.mostrarToast('info', lstTexto.join('\n'), 'sticky');
        	});   
            
        	$A.enqueueAction(excepciones);  
        });
    },
    
   toggleAutoRefresh: function(component, event, helper) {

      const refreshInterval = component.get('v.refreshInterval');
   	  const intervalId = window.setInterval(() => {
      helper.refreshListView(component);
      }, refreshInterval * 500);
      component.set('v.intervalId', intervalId);
      
		/*
      const intervalId = component.get('v.intervalId');
      window.clearInterval(intervalId);
      component.set('v.intervalId', null);
      */
   },
             
})